# M10-S6 快捷键 GM命令与杂项

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md)

## 功能概述

收录五个"判断涉网性"的组件与 GM 命令通道:

| 组件 | 涉网结论 |
|---|---|
| 快捷键 hotKey | **技能键绑定上报服务器**(CM_MAGICKEYCHANGE 1008);其余键位纯本地 cache.saveHotKey |
| 推送 jpush | **服务端可下发别名**(SM_JPUSH_SETALIAS 4498)→ 调 SDK setAlias;本树 `IGNORE_JPUSH=true` 使 SDK 全部为空桩 |
| 反外挂 plugCheck | 设计上周期发 CM_SPEEDHACKUSER(1042) 校时;**本树未接线且 net.send_old 为空桩,实际不发包**(详见下文,重点核实结论) |
| 龙环按钮 loongsRingBtn | 纯本地控件(切图按钮),无报文;本树未发现引用方 |
| UI 自定义 UIEditor/diy/diySave | 纯本地(cache 存取),不上传服务器 |

GM 命令:**全部经聊天通道 CM_SAY(3030) 发送,body 为 `@命令 [参数…]` 文本(GBK)**。清单来自客户端本地两处:`mir2.def.cmds.lua`(硬编码常用 @命令)与 `mir2.def.gmCmd.lua`(读资源包内 `config/cmd.txt` 的完整 GM 命令表,m2debug 调试控制台使用)。回执/提示复用普通聊天下行(SM_SYSMSG 等,归聊天模块)(未核实专用回执消息)。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2.data.hotKey.lua :: setMagicHotKey/loadMagicHotKey` | 技能热键与 CM_MAGICKEYCHANGE 发送 |
| `mir2.scenes.main.pc.hotKeySetting.lua` / `magicKeySetting.lua` | PC 键位设置 UI(本地保存 + 触发技能键上报) |
| `mir2.scenes.main.scene.lua` L394-397(initHotKey L403-408) | SM_JPUSH_SETALIAS 处理;键位表从 cache 装载 |
| `mir2.single.jpush.lua` | JPush SDK 桥与空桩(IGNORE_JPUSH=true,L91) |
| `mir2.scenes.main.common.plugCheck.lua` | 加速检测状态机(get/verify/kill)——本树死代码 |
| `mir2.def.cmds.lua` / `mir2.def.gmCmd.lua` | @命令清单(cmd.txt 解析:字段 `名称;描述;命令;参数表Lua串;?;分类`) |
| `mir2.single.m2debug.lua` L1757-2100 | 调试控制台 GM 命令目录与发送(@doresou/@upuserskill 等) |
| `mir2.scenes.main.console.btnCallbacks.lua :: handle_cmd/sendCmd` L463-529 | 主界面命令按钮发送出口(0.5s 限速) |
| `mir2.scenes.main.common.centerTopTip.lua` | "卡位恢复/回城复活"快捷命令条 |
| `mir2.scenes.main.common.keyboardEx.lua :: loadCMD` L254-288 | 移动端键盘 @命令快捷插入(插入后仍走聊天发送) |
| `mir2.loongsRingBtn.lua` | 切图按钮控件(纯本地) |
| `mir2.scenes.main.panel.UIEditor.lua` / `diy.lua` / `diySave.lua` | UI 自定义布局编辑器与存档(纯本地 cache.*) |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_MAGICKEYCHANGE | 1008 | C→S | 设置/清除技能快捷键 | recog=magicId,param=按键码或 0 |
| SM_JPUSH_SETALIAS | 4498 | S→C | 服务端要求设置推送别名(推测登录后任意时机) | body=alias 字符串 |
| CM_SPEEDHACKUSER | 1042 | C→S | plugCheck 探针(设计值:init 后每 5s/warning 每帧);**本树实际不发包** | 无参无体,期望应答带服务器时间 |
| CM_SOFTCLOSE | 1009 | C→S | 小退(scene:smallExit)、plugCheck.kill、Android 返回键退出 | 无参无体 |
| CM_SAY | 3030 | C→S | 所有 @命令/GM 命令的唯一通道 | body="@cmd args"(GBK) |

## 详细报文说明

### CM_MAGICKEYCHANGE(1008) —— 技能快捷键上报

发出(`data/hotKey.lua :: setMagicHotKey(keyid, magicId)`):

```lua
-- 先清除该技能旧键:
net.send({ CM_MAGICKEYCHANGE, param = 0, recog = magicId })
-- 再绑定新键:
net.send({ CM_MAGICKEYCHANGE, recog = magicId, param = keyCode })
```

| TDefaultMessage 字段 | 用法 |
|---|---|
| recog | 技能 magicId |
| param | 按键 ASCII 码:keyid 6~13 → '1'~'8'(49~56);keyid 18~25 → 'A'~'H'(65~72);**param=0 表示解绑** |
| tag / series | 未用 |
| body | 无 |

触发点:`panel/magicKeySetting.lua` L31(拖技能到 F1~F8 对应格)、`loadMagicHotKey`(登录后按服务端下发的 `magic.key` 回放绑定——TClientMagic 的 key 字段即服务器侧持久化的键码,详技能模块)。**其余所有非技能键位的增删改查只写 `cache.saveHotKey(角色名)`,零报文**(`pc/hotKeySetting.lua` L147)。

应答:本树无处理分支(沉默成功)(未核实是否存在错误回执)。

### SM_JPUSH_SETALIAS(4498) —— 推送别名下发

处理(`main.scene.lua` L394-397):

```lua
local alias = net.str(buf)   -- 整个 body 按 GBK→UTF-8 读为字符串
jpush.setAlias(alias)
```

body 布局:单字符串(GBK,长度=dataLength,无长度前缀、无分隔符),内容为别名(推测为角色名/账号标识)(未核实格式约定)。触发时机由服务端决定,客户端在 main 场景全程监听(推测登录进图后下发一次)(未核实)。注意:本树 `IGNORE_JPUSH = true`(jpush.lua L91),Android/iOS 分支均不编译,`setAlias` 命中最后的空桩分支——**基础版上此消息被接收但无实际效果**;白猪生产版等商业分支才会真正调 SDK。服务端实现时应照常下发(协议保留),客户端侧效果取决于构建开关。

### CM_SPEEDHACKUSER(1042) 与 plugCheck(重点核实结论)

设计逻辑(`common/plugCheck.lua`,完整状态机):

1. `update(dt)` 由外部每帧驱动(本树**未找到任何 import/调用点**,模块未被装载):init 态 1s 后首发探针;normal 态每 5s 一次;warning 态每帧一次。
2. `get()`:`net.send_old({ CM_SPEEDHACKUSER })` —— **而 net.send_old 在本树是空桩(net.lua L248-252 只打日志)**,即使模块被接也不会发出任何字节。
3. `verify(serverTime)`(应答解析入口,同样无人调用):比较往返耗时(<2s 才算 init 成功)、时钟偏差(|client−server−基准diff|>5s 计警告)、响应超时 60s;累计超限(初始 20 次/偏差 8 次/长往返 10 次)判定作弊。
4. `kill()`:发 **CM_SOFTCLOSE(1009)** 并弹窗退出("此次开加速辅助已被系统记录!"/错误代码 -1 speed、1 timeOut、2 initErr、3 sendTimeLong)。

给服务端的建议:若要兼容未来重新接线的基础版,收到 1042(无参无体)应立即回一条携带服务器时间戳的消息(plugCheck.verify 的入参形态为秒级整数;具体应答 ident 本树无法确认——**未核实**,需对照商业版或服务端资料)。

### CM_SOFTCLOSE(1009)

三处发送,均无参无体:`scene:smallExit()`(小退回选人流程)、`plugCheck.kill()`、Android 返回键确认退出(main.scene.lua L33)。语义=客户端主动正常断开;服务端应清理会话而非记为异常掉线。

### GM 命令清单与发送方式

**发送通道唯一**:CM_SAY(3030),body 为 GBK 文本,首字符 `@`。各入口:

| 入口 | 命令示例 | 位置 |
|---|---|---|
| def.cmds.all(硬编码) | @千里传音(实际发 `@传`)、@传送/@sdgo、@天地合一、@允许天地合一、@允许求婚、@拒绝求婚、@允许收徒、@拒绝收徒、@加入门派、@退出门派 | mir2.def.cmds.lua |
| def.cmds.custom | 卡位恢复=`@resetpoint`、回城复活=`@relive`(centerTopTip 死亡/卡位提示条按钮直接发) | centerTopTip.lua L41-45 |
| btnCallbacks.handle_cmd | @拒绝私聊、@禁止交易、@师徒传送、@夫妻传送(sendCmd,0.5s 限速,"你操作太快了!!!") | btnCallbacks.lua L463-529 |
| @传送 带坐标输入框 | `config[2].." "..输入`(默认填充 d5071 样例) | btnCallbacks.lua L477-512 |
| 千里传音频道 | getSayText 自动加前缀 `@传 `(data/chat.lua L236) | chat.lua |
| keyboardEx 快捷条 | 把上述命令插入聊天输入框,随普通聊天发送 | keyboardEx.lua L266-285 |
| m2debug 调试控制台 | 完整 GM 表(config/cmd.txt):如 `@doresou <技能名>`、`@upusersell…`/`@upuserskill <角色名> <技能名> <等级>` | m2debug.lua L1232-1276、L2038-2076 |

**cmd.txt 格式**(def.gmCmd.lua,`;` 分隔 6 列):`显示名;中文描述;<真实命令(不带@)>;参数提示表(Lua table 串,如 {"角色名","怪物名"});(第5列未用);分类(common=常用)`。m2debug 拼装规则:`"@"..data[3]..(" "..每个非空参数)`,再经 emoji 编码后 CM_SAY 发送。

权限回执:@命令的成败提示走服务端普通聊天/系统消息下行(客户端无专门分支);非法或越权命令通常表现为服务端忽略或回系统文案(未核实具体 ident,归聊天模块统一处理)。

### 称号域(查询/设置/更新/耐久)

称号面板挂在 equip 面板 "title" 页,数据存 `g_data.player.titleInfo`(按 ActorID 分组)。**客户端只发查询,设置类全由服务端推送**(CM_SET_CURTITLE 等无发送点,见"定义未用")。

| 消息 | 值 | 方向 | 时机/字段 | body |
|---|---|---|---|---|
| CM_QUERY_TITLE | 3202 | C→S | 查看他人:随 CM_QUERYUSERSTATE 连发(pc.operate.lua L769、widget.lock.lua L65),recog=对方 roleid,param=x,tag=y,无 body | — |
| SM_SEND_TITLEINFO | 2870 | S→C | 称号全量应答(ui.lua L440 → `player:initTitle`) | recog=ActorID,**tag=条数**,param=当前称号ID(tag==1 时客户端强制置 0);body=tag 条 TClientTitleInfo |
| SM_SET_CURTITLE | 2871 | S→C | 佩戴/卸下结果(ui.lua L446,series==0 才处理 → `setTitleResult`) | tag==0 → 卸下(curTitleID=0);否则 curTitleID=param |
| SM_UPDATE_TITLE | 2874 | S→C | 称号增/删(ui.lua L454 → `updateTitleInfo`) | tag==0 → body=1 条 TClientTitleInfo 新增/替换(按 ID);tag≠0 → param=ID 删除 |
| SM_UPDATE_TITLE_DURA | 3318 | S→C | 剩余次数变化(ui.lua L460 → `updateTitleCount`) | param=称号 ID,tag=新 UseTimes |

**TClientTitleInfo**(packed,**53 字节**,globa2 定义):short ID;byte TitleType;string TitleName[16],占 17B,GBK;uint LeftTime;short Look;byte Add_PerAddForceValue;byte Add_MaxMP;byte UseTimes;byte DisPlayType;short Reserve;short Add_MaxHP;byte Add_MAC/Add_AC/Add_DC/Add_MC/Add_SC;byte Add_MaxMAC/Add_MaxAC/Add_MaxDC/Add_MaxMC/Add_MaxSC;byte Add_QuickRate;byte Add_Union_Damage;byte Add_Union_Damage_Percent;uint Add_Exp;byte Add_Exp_Percent;byte Add_UnBreakValue。

**定义未用**(无发送点/无处理分支,服务端可暂不实现):CM_SET_CURTITLE(3200)、CM_SET_SHOWTITLE(3201)、SM_SET_SHOWTITLE(2872)、SM_SHOW_HIDE_TITLE(2873)、CM_TITLE_MAP_MOVE(3203)、CM_SET_TITLE_TASK(3204)、CM_GET_TITLE_TASK_SALARY(3205)、SM_OPEN_DOMINATE_TITLE_PANEL(2890)、SM_TITLE_TASK_BRIEF_INFO(2891)、SM_TITLE_TASK_INFO_UPDATE(2892)、SM_TAKE_DOMINATE_TITLE_SALARY(2893)、SM_OPEN_TITLE_PANEL(3319)、CM_TITLE_RELATION_OPERATE(3298)、CM_CORPS_SET_MEMBER_TITLE(4526)。其中"主宰者称号任务"族(3204/3205/2890-2893)若需支持,协议形状只能参考商业版资料(未核实)。

### 杂项组件涉网性判定

| 组件 | 判定 | 依据 |
|---|---|---|
| loongsRingBtn | **纯本地** | 仅用 SpriteFrame 切图+触摸回调构造按钮;全树 grep 无引用方(预留控件)(未核实其在商业版的用途) |
| UIEditor | **纯本地** | 658 行全部为节点添加/属性编辑 UI,无 net.send/cache/http |
| diy / diySave | **纯本地,不上传服务器** | 方案列表/应用/删除全部 `cache.getDiy/saveDiy/removeDiy(角色名,…)`;"_current""_list" 为保留键 |
| voiceBtnJIT | SDK 面(不产生游戏 TCP 报文) | 点击按频道模式/禁言态调 `yaya.mic(bool, 自己名字)` |

## 服务端实现要点

1. CM_MAGICKEYCHANGE 必须持久化:param 是按键 ASCII(49~56/65~72)或 0;下次登录经 TClientMagic.key 回给客户端(loadMagicHotKey 依赖它还原键位)。
2. SM_JPUSH_SETALIAS 的 body 是裸字符串(无长度前缀),推送时机与内容由服务端自定;基础版客户端会收下但无动作,不影响协议兼容。
3. CM_SPEEDHACKUSER 目前不会到达;若实现,请保持幂等并尽快回应时间值(设计阈值:RTT<2s、允许偏差 5s)。CM_SOFTCLOSE 到达时按主动下线处理。
4. @命令解析建议集中在一个入口:剥离首个 `@`,按空白切分(注意 S4 所述 @sdgo 双空格),先查权限再执行;未知命令回系统提示即可。命令表以服务端为准,客户端 cmd.txt 只是展示层。
5. 千里传音的实际前缀是 `@传`(不是 `@千里传音`),做敏感词过滤/统计时注意映射。
