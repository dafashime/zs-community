# M2-S1 私服列表(sfselect)

> 所属主模块: [M2-选区与角色管理](../主模块/M2-选区与角色管理.md)

## 功能概述

`sfselect` 场景是客户端启动后的第一个场景:通过 **HTTP** 向列表服务器拉取私服(区服)列表,展示"新服榜/人气榜"、搜索框、轮播广告与公告;玩家点击某个服务器后,客户端只把该服的 HTTP 登录中心地址写入 `def.loginCenter*`,然后切换到 `login` 场景——**本子模块不建立任何 TCP 连接,不收发任何 CM/SM 消息**。真正的游戏 TCP 连接在 M2-S2(经 login 场景 `SM_SELECT_SERVER`)才建立。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.sfselect.scene.lua` | 场景主体:`requestSfList`(HTTP 请求)、`searchServer/gotoServer`(选择进入)、公告解析、开发者测试入口 |
| `mir2/mir2.scenes.sfselect.sflist.lua` | 列表控件:新服榜(rank1)/人气榜(rank2)排序、搜索、条目点击 → `gotoServer` |
| `mir2/mir2.scenes.sfselect.sflistitem.lua` | 单条服务器条目渲染(serverName + desc) |
| `mir2/mir2.def.init.lua` | `def.setSF`:拼出 `def.sfAuthUrl`;`def.setLoginCenter/setSFNotice/resetLoginCenter` |
| `mir2/mir2.single.cache.lua`(`cache.*`) | `getLastSfServer/setLastSfServer`(上次登录服)、`getIsFirstLaunchGame/setIsFirstLaunchGame`(本地记忆,非服务端数据) |

## 报文总览

本子模块无 TCP 报文,只有 1 个 HTTP 接口;表末列出选择后交接给 M2-S2 的 TCP 消息(详述见 S2)。

| 消息/请求 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| GET `/serverlist?password=xxx` | HTTP | C→S | 场景 `ctor()` 即请求(`sfselect.scene.lua :: requestSfList`) | URL = `def.sfAuthUrl = "http://" .. ip .. ":" .. port .. "/serverlist?password=" .. password`(`mir2.def.init.lua :: def.setSF`,行 38-43);当前默认 `def.setSF("127.0.0.1", 8089, "mir2666")`(行 47),运营包由构建配置替换 |
| (HTTP 应答) | 200 + JSON | S→C | 同上 | 非 200 或请求 failed → 弹窗「退出(os.exit)/重试」 |
| SM_SERVER_LIST(4001)(交接) | 4001 | S→C | 进入 login 场景后 | 触发 CM_SELECT_SERVER,见 S2 |
| CM_SELECT_SERVER(4002)(交接) | 4002 | C→S | 玩家选定区组(login 场景自动) | 见 S2 |
| SM_SELECT_SERVER(4002)(交接) | 4002 | S→C | 服务端返回网关信息 | 见 S2 |

## 详细报文说明

### GET /serverlist?password=xxx

- **触发时机**:sfselect 场景创建即发(`sfselect.scene.lua :: ctor → requestSfList`);失败弹窗选「重试」时重新发起。
- **请求**:`network.createHTTPRequest(..., url, "GET")`,无自定义头、无 body。
- **应答要求**:
  - HTTP 状态码必须为 200,否则按失败处理(退出/重试弹窗,`requestSfList` 行 265-273)。
  - body 为 JSON,顶层结构 `{ "serverlist": {...} }`;`json.decode` 失败时按空表 `{}` 继续,后续取字段安全失效。

#### 响应 JSON 字段表(全部来自解析代码,字段名逐字核实)

| 路径 | 类型 | 用途 | 来源 |
|---|---|---|---|
| `serverlist.kaifubiao` | number | `== 0` 时置 `cache.setIsFirstLaunchGame(true)` → 走"首次启动"模式(手动输入服务器名搜索进入),并隐藏"开发者测试入口";非 0 走普通列表模式(`requestSfList` 行 281-284、`showRightBtns` 行 130-132)。除 0 外的语义未核实 | `sfselect.scene.lua` |
| `serverlist.notice` | string | 富文本公告,存入 `def.sfNotice`(`def.setSFNotice`),点公告按钮弹出。格式:`<b 属性.../>正文<t .../>` 的自绘标记循环解析(`showNotice`/`parseContent`,行 429-516);属性含 `size`、`urlcolor=r|g|b`、`textcolor=r|g|b`、`urladdr`、`urltext`,正文中 `\n` 转换行 | `sfselect.scene.lua` |
| `serverlist.imglist[]` | array | 轮播广告图数组,每项至少含 `url`(字符串图片地址),用 `an.newNetSprite(v.url)` 异步加载(`updateAdPageView` 行 380-412) | `sfselect.scene.lua` |
| `serverlist.servers[]` | array | 服务器条目数组,排序后渲染列表 | `sflist.lua :: refreshScrollView` |
| `servers[].servername` | string | 服务器名:列表首列显示;**搜索/直接进入的唯一匹配键**(输入需与 servername 完全一致,`searchServer` 用 `string.find` 且要求匹配区间覆盖全名,`sfselect.scene.lua :: searchServer` 行 329-339);也是"上次登录的服务器"按钮的缓存键 | sflist/sfselect |
| `servers[].desc` | string | 列表第二列简介文案(`sflistitem.lua :: setData`) | sflistitem |
| `servers[].serverip` | string | 该服 HTTP 登录中心地址,格式 `"host:port"`;`string.split(":")` 后 port 缺省取 **8088**(`gotoServer` 行 356-366)。注意这是登录中心(HTTP /account 所在),不是游戏网关 | sfselect/sflist |
| `servers[].serverid` | string | 区组标识串(如 `"1997dw"`),原样存入 `def.serverId` | `mir2.def.init.lua :: setLoginCenter` |
| `servers[].isactive` | number | `> 0` 才会进入候选列表并显示(`refreshScrollView` 行 173-177、`searchServer` 行 318-322) | sflist/sfselect |
| `servers[].rank1` | number | 新服榜排序键升序(`sflist.lua :: selectRank` 行 145-147) | sflist |
| `servers[].rank2` | number | 人气榜排序键升序(行 156-158) | sflist |

编码说明:`sflistitem.setData` 对 `servername/desc` 直接调用 `string.utf8len/utf8sub`,因此该接口的 JSON 文本必须是 **UTF-8**(GBK 字节流会导致 utf8 处理异常);这与 TCP 通道一律 GBK 不同。(行为依据代码推断,未实测异常表现。)

### 选择服务器后的流转(无报文,仅本地状态)

`sfselect.scene.lua :: gotoServer`(列表条目点击经 `sflist.onTouchSfList → gotoServer`)与 `showRightBtns` 中"上次登录的服务器""开发者测试入口"殊途同归:

1. 弹窗确认「即将进入:servername」。
2. 解析 `serverip` → `def.setLoginCenter(ip, port or 8088, servername, serverid)`(`mir2.def.init.lua`,行 53-59:同时写 `def.loginCenter/loginCenterIP/loginCenterPort/serverName/serverId`)。
3. `cache.setLastSfServer(servername)`(scene 版还调 `cache.setIsFirstLaunchGame(false)`;sflist 版不调,差异未核实是否有意)。
4. `game.gotoscene("login", {logout=false}, ...)` —— 之后流程移交 M1/M2-S2。

## 服务端实现要点

1. **这是一个纯 HTTP 接口**:实现 `/serverlist?password=` 即可让客户端完成选服;`password` 查询参数服务端自行校验(旧 openresty 登录中心有同名接口可对照,本仓库参考 `server-svc/mud2.0/logincenter/`)。
2. 必须返回 HTTP 200 + 合法 JSON,且**顶层必须有 `serverlist` 键**;`kaifubiao=0` 会把客户端锁进"输入名称进入"模式(且隐藏开发入口),不确定语义时给非 0 值走普通列表。
3. `servers[].isactive <= 0` 的条目对玩家完全不可见(包括搜索),下架请用它而不是删条目。
4. `serverip` 填的是**登录中心**地址(host:port,缺省 8088);不要填 TCP 网关端口,否则下一步 `/account` 与 `SM_SELECT_SERVER` 流程无从谈起。
5. 列表文案用 UTF-8;公告富文本若不需要,给 `notice` 空串即可(客户端判空跳过解析循环)。
6. 本子模块超时不重试请求本身,只提供「退出/重试」人工选择;服务端响应慢会造成黑屏等待,建议快速应答。
