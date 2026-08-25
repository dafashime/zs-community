# M10-S4 大地图与标记 bigmap-mark

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md)

## 功能概述

四个组件,涉网程度差异极大:

1. **大地图面板 bigmap**:世界图/当前地图双页签。涉网点有三处——打开期间轮询**队友位置**(CM/SM_MEMBERS_POSITION_INFO 4629)、"快捷寻路"里拉取**地图 NPC 列表**(CM/SM_QUERY_MAP_NPC 4610)、"传送"按钮发 **@sdgo 文本命令**(CM_SAY)。收藏坐标(likes)纯本地。
2. **他人位置查看 bigmapOther**:从聊天富文本 `{@ps...}`(坐标分享)点开,显示他人在某图的落点;若自己也在该图,提供"传送"(net.send_old 桩,实际不发包)与"寻路"。数据源是聊天消息而非独立协议。
3. **人名标记 mark**:屏幕上给玩家名加色标的优先级列表(near/group/friend/chat/guild 五级,上限 30),输入全部来自本地事件(聊天、好友表、行会表、组队),自身零报文。
4. **小地图 minimap**:贴图来自本地资源 `data/mmap/<id>.png` 或由地图数据即时生成缓存(`common.getMinimapTexture`),**拉的是资源不是协议**,点击只是开关 bigmap 面板。

另有服务端主动下行的 `SM_AUTOMOVE_MAPPATH(2850)`(脚本自动跨图寻路路径)与 `SM_PLAYER_POSITION(4628)`(行会职位推送)在本组数据层落地。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2.scenes.main.panel.bigmap.lua` | 大地图面板:队友位置轮询(L580-593)、@sdgo(L387-391)、NPC 查询(L726-743)、收藏 UI |
| `mir2.data.bigmap.lua` | `g_data.bigmap`:likes(本地 cache)/npcs(addNpcs 解析 SM_QUERY_MAP_NPC)/group(getGroupInfo 解析队友位置)/scriptAutoPath |
| `mir2.def.bigmap.lua` | 本地 `config/bigmap.txt` 静态标注(id;文本;x;y) |
| `mir2.scenes.main.panel.bigmapOther.lua` | 他人位置浮窗;"@传送"按钮(L80-84,net.send_old 空桩) |
| `mir2.scenes.main.common.chatPos.lua` + `common.encodeRich`(common.lua L59) | 聊天坐标分享组件与 `{@ps}` 编解码 |
| `mir2.scenes.main.ui.lua` L1262(SM_PLAYER_POSITION)/L2468-2481(SM_QUERY_MAP_NPC、SM_MEMBERS_POSITION_INFO、SM_AUTOMOVE_MAPPATH) | SM 分派 |
| `mir2.data.mark.lua` | 人名标记优先级列表(纯本地) |
| `mir2.scenes.main.panel.minimap.lua` | 小地图(纯本地资源) |
| `mir2.def.globa2.lua` L3532-3576 | TNpcDesc / TGroupMemPosition / TMapPathNode 记录 |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_MEMBERS_POSITION_INFO | 4629 | C→S | 加载本地图时立即一次;此后每 1s 一次(仅当 `#g_data.player.groupMembers > 0`) | 无参无体 |
| SM_MEMBERS_POSITION_INFO | 4629 | S→C | 应答队友位置 | 仅 recog==0 有效:param=人数,body=TGroupMemPosition×N |
| CM_QUERY_MAP_NPC | 4610 | C→S | 快捷寻路首次查看某图 NPC 列表且无缓存 | param=0 当前图/param=1 其他图(body=mapid 字符串) |
| SM_QUERY_MAP_NPC | 4610 | S→C | 返回 NPC 名+坐标列表 | tag=条数,body=TNpcDesc×N |
| CM_SAY | 3030 | C→S | 大地图"传送"按钮:@sdgo 命令(需佩戴传送戒指) | body="@sdgo␣␣x␣y"(注意源码双空格) |
| SM_PLAYER_POSITION | 4628 | S→C | (触发方未核实)行会职位推送:tag=职位码 | 客户端仅存 g_data.guild.posInfo |
| SM_AUTOMOVE_MAPPATH | 2850 | S→C | 服务端脚本要求自动寻路:recog=节点数,body=TMapPathNode×N | 触发它的 CM 在本树未出现 |

## 详细报文说明

### CM_MEMBERS_POSITION_INFO(4629) → SM_MEMBERS_POSITION_INFO(4629)

发出(`panel/bigmap.lua :: loadLocalMap` 尾部 L580-593):

```lua
net.send({ CM_MEMBERS_POSITION_INFO })   -- 无参无体
```

- 进入/切换到"本地地图"页签且查看的是当前所在地图时立即发一次;
- 同时注册 1s 周期任务,每次发送前检查 `table.nums(g_data.player.groupMembers) > 0`,无队伍则不发;
- 面板关闭(onCleanup→unscheduleHandle)停止。

应答(`ui.lua` L2474 → `data/bigmap.lua :: getGroupInfo`):**recog 必须为 0 才解析**(非 0 整包忽略);`msg.param`=成员数 N;body 为 N 条 TGroupMemPosition(globa2 L3547):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 变长 | string[15] | name | 成员名(GBK) |
| | int | x | 地图 X 坐标 |
| | int | y | 地图 Y 坐标 |

客户端把点位画到大地图上(绿色点+名字)。非队伍成员/自己不在此列(自己位置本地画)。

### CM_QUERY_MAP_NPC(4610) → SM_QUERY_MAP_NPC(4610)

发出(`panel/bigmap.lua :: loadQuickPath → createList("NPC")`,L726-743):仅当 `g_data.bigmap:getNpcs(地图标题)` 无缓存时:

```lua
-- 查询当前所在地图:
net.send({ CM_QUERY_MAP_NPC, param = 0 })
-- 查询其他地图(世界图切过来):
net.send({ CM_QUERY_MAP_NPC, param = 1 }, { self.mapid })   -- body: mapid 字符串
```

发送前 `g_data.client:setLastNpcMap{title, id}` 记录请求目标——应答不带图标识,靠这个回填。

应答(`ui.lua` L2468 → `data/bigmap.lua :: addNpcs`):`msg.tag`=NPC 条数 N;body 为 N 条 TNpcDesc(globa2 L3532):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 变长 | string[15] | name | NPC 名(GBK) |
| | short | x | 坐标 X |
| | short | y | 坐标 Y |

解析结果按 `g_data.client.npcMap.title` 存入本地缓存(下次同图不再请求),并刷新快捷寻路列表。结果集按"地图标题"索引——同一 mapid 不同标题会重复请求。

### @sdgo 传送(CM_SAY 3030)

发出(`panel/bigmap.lua :: sdgo` L351-392):条件=目标坐标可走、与本地图同一地图、佩戴"传送戒指"(7/8 号装备位任一名字匹配),否则弹窗提示:

```lua
net.send({ CM_SAY }, { "@sdgo " .. " " .. x .. " " .. y })
```

body 实际为 `"@sdgo  333 333"`(命令与 x 之间两个空格,源码原样)。这是文本 GM/命令通道,服务端在 SAY 处理中按 `@sdgo` 前缀解析两个整数坐标执行瞬移(权限/戒指校验应在服务端再做一遍)。

### bigmapOther 的"@传送"(无效路径,已核实)

`panel/bigmapOther.lua` L80-84 使用:

```lua
net.send_old({ CM_SAY }, { "@传送 " .. x .. " " .. y })
```

而 `net.send_old` 在本树是空实现(`single/net.lua` L248-252,只打日志)**不产生任何报文**。即基础版客户端的"查看他人位置后一键传送"按钮是死的;服务端无需为其实现 `@传送` 处理(但保留解析无害)。bigmapOther 自身的数据(mapData={user,mapID,mapTitle,x,y})来自聊天 `{@ps<mapID>|<mapTitle>|<x>|<y>}` 富文本(common.lua L59-60),经 chatPos 组件点击展开——属聊天协议,不在本报文总览重复计数。

### SM_AUTOMOVE_MAPPATH(2850)

处理:`ui.lua` L2482 → `data/bigmap.lua :: scriptAutoPath`。`msg.recog`=节点数 N,body=N 条 TMapPathNode(globa2 L3562,`string name[15]; short x; short y`,name 存 mapid)。随后 autoFindPath 控制器沿路径自动行走。本树未发现请求它的 CM(应为服务端脚本/NPC 对话主动推送)(未核实触发场景)。

### SM_PLAYER_POSITION(4628)

处理:`ui.lua` L1262:仅 `g_data.guild.posInfo = msg.tag`(tag=职位码,配合文案表 ""/"副队长"/"队长"/"副会长"/"会长")。无 body 解析,无后续动作;请求方在本树未出现(未核实)。

### 纯本地部分(一句话归档)

- **收藏坐标**:addLike/removeLike/isExistLike 全走 `cache.saveBigmap/getBigmap`(按地图名存 JSON),"您可以在快捷寻路中找到您收藏的坐标"。
- **静态标注**:def.bigmap 启动读 `config/bigmap.txt`,格式 `mapid;文本(/L=换行);x;y` 多行。
- **mark 人名标记**:优先级 near=1 < group=2 < friend=3 < chat=4 < guild=5,reorder 后截断 30 条;addNear/addGroup/addFriend/addChat/addGuild 由各系统在收到对应网络数据后调用,mark 文件本身零报文。
- **minimap**:贴图 `data/mmap/<minimapID>.png`(def.map.getMinimapID 映射),缺失则 makeMinimap 从地图数据生成并落盘;点击面板仅切换 bigmap 显示。

## 服务端实现要点

1. 4629 是**秒级高频轮询**,必须轻量:无队伍时可直接不回或回 recog≠0(客户端会忽略);有队伍时 recog=0 + param=N + TGroupMemPosition 流。坐标用 int(非 short)。
2. 4610 的应答不含地图回执字段,服务端应假设客户端按最近一次请求的图应答;NPC 名长度上限 15 字节(GBK),超长会被记录系统截断。
3. `@sdgo` 属聊天文本命令:注意客户端发的是**双空格**,解析时应按空白切分而非单空格匹配;执行前服务端需自行校验传送戒指与坐标合法性(客户端校验可被绕过)。
4. `@传送`(bigmapOther)在本树不会上线,可不实现;若旧版服务端支持,兼容解析亦无冲突。
5. SM_QUERY_MAP_NPC 结果会被客户端永久缓存(本次会话),NPC 移动/增删后旧坐标不会刷新——需要实时性时应改用其他机制。
6. TGroupMemPosition/TNpcDesc/TMapPathNode 的 string[15] 均为首字节长度+GBK(BRIEF §6),记录非 packed。
