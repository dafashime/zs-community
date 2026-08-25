# M6-S1 NPC对话与脚本面板

> 所属主模块:[M6-NPC与商店](../主模块/M6-NPC与商店.md)

## 功能概述

玩家点击场景中的 NPC → 客户端发 `CM_CLICKNPC(1010)`;服务端回 `SM_MERCHANTSAY(643)` 下发对话文本。对话文本不是纯文本,而是一套**脚本标记文法**(详见"服务端实现要点"):内嵌 `<按钮文字/命令串>` 即渲染为可点按钮,玩家点击后客户端把命令串原样经 `CM_MERCHANTDLGSELECT(1011)` 回传服务端,形成"服务端下发页面→玩家选择→回传命令→下发下一页"的脚本会话循环。

特殊分支:

- `@@` 开头的输入型命令:客户端先弹输入框,把用户输入以 `0x0D`(CR)拼在命令串后一并发送;
- `@@helper` 命令:客户端本地执行 Lua 片段(挂机助手脚本),只把剩余命令段回传;
- 骰子 NPC:服务端发 `SM_PLAYDICE(1200)`,客户端播放掷骰动画后自动回发 `CM_MERCHANTDLGSELECT` 续接脚本;
- 询问/输入框:`SM_MERCHANT_QUERY(2831)` 要求玩家输入文字或确认,应答走 `CM_MERCHANT_QUERY(1110)`。

注意:**SM_MERCHANTSAY 本身没有任何分页字段**(recog=NPC id、param=头像编号但当前面板未使用)。多页对话完全靠脚本命令实现——每页末尾放 `<下一页/@page1>` 类按钮,点击即回传对应命令由服务端下发下一段文本。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.main.pc.operate.lua :: onMouseLeft_end` | PC 端鼠标点击 NPC → 发 CM_CLICKNPC |
| `mir2/mir2.scenes.main.console.controller.lua :: 触摸 ended 处理` | 移动端触摸 NPC → 发 CM_CLICKNPC |
| `mir2/mir2.scenes.main.common.helper.guide.lua :: guide:talkWithNPC` | 新手引导按名字找 NPC 自动发起对话 |
| `mir2/mir2.scenes.main.ui.lua :: mainui:processMsg` | SM_MERCHANTSAY / SM_MERCHANTDLGCLOSE / SM_MERCHANT_QUERY / SM_PLAYDICE 分发 |
| `mir2/mir2.scenes.main.panel.npc.lua` | NPC 对话面板:body 文法解析(parseContent/parseCcmd)、按钮回传(clickCMD)、询问输入框(showInput)、骰子结果(common.showBosonResult 被调用) |
| `mir2/mir2.scenes.main.common.common.lua :: common.showBosonResult` | SM_PLAYDICE 解析与动画后回传 |
| `mir2/mir2.scenes.main.role.npc.lua` | NPC 对象本地渲染(race/appr 外观),无网络交互,仅提供被点击的 roleid |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_CLICKNPC | 1010 | C→S | 点击 NPC(松手时)/引导 talkWithNPC | 仅 recog,无 body |
| SM_MERCHANTSAY | 643 | S→C | 服务端脚本输出对话页 | body=GBK 全文,首个 `/` 前= NPC 名 |
| SM_MERCHANTDLGCLOSE | 644 | S→C | 服务端要求收起对话框 | 无 body 处理,直接 hidePanel("npc") |
| CM_MERCHANTDLGSELECT | 1011 | C→S | 玩家点击脚本按钮/骰子动画结束 | body=命令串(可含 CR+输入) |
| SM_MERCHANT_QUERY | 2831 | S→C | 服务端要求输入/确认 | 按 msg.tag 分支 |
| CM_MERCHANT_QUERY | 1110 | C→S | 玩家对询问框作出回应 | 回传原 recog/param/tag,series=按钮码 |
| SM_HIDEMERCHANT_QUERY | 2832 | S→C | (未核实预期时机) | 客户端定义了常量但**无处理分支**,发了等于没发 |
| SM_PLAYDICE | 1200 | S→C | 骰子 NPC 开奖 | body=TMessageBodyWL+命令串;param=骰子个数 |

## 详细报文说明

### CM_CLICKNPC(1010)— 请求与 NPC 对话

- **触发时机**:三个发送点(`mir2.scenes.main.pc.operate.lua :: onMouseLeft_end` 行 509、`mir2.scenes.main.console.controller.lua` 行 298、`mir2.scenes.main.common.helper.guide.lua :: guide:talkWithNPC` 行 321):
  - 玩家在 NPC 身上**直接点击/触摸抬起瞬间**立即发送——客户端没有"先走近再发送"的逻辑,是否允许对话(距离判定)完全由服务端裁决;
  - 发送前客户端仅做目标类型判断:`role.__cname == "npc"`(role.npc.lua 构造的 NPC 对象);引导流程为延迟 0 秒的定时器回调发送。
- **TDefaultMessage 字段**:

| 字段 | 用法 |
|---|---|
| recog | NPC 的 roleid(int32,即场景对象 id,来自 SM_TURN/SM_DISAPPEAR 等感知消息族,M3-S2) |
| param / tag / series | 不填(=0) |
| body | 无(dataLen=0) |

- **期望应答**:正常情况服务端回 `SM_MERCHANTSAY(643)`;若服务端判定不可交互可不回包(客户端无超时提示,(未核实)是否有其它应答约定)。若服务端随后要开商店等,可在脚本命令响应中再发 M6-S2 的列表类消息。

### SM_MERCHANTSAY(643)— NPC 对话内容(脚本文本协议)

- **处理位置**:`mir2.scenes.main.ui.lua :: mainui:processMsg`(行 648 起)+ `mir2.scenes.main.panel.npc.lua :: npc:ctor / parseContent / parseCcmd`。
- **TDefaultMessage 字段**:

| 字段 | 用法 |
|---|---|
| recog | NPC id,后续所有 `CM_MERCHANTDLGSELECT` 原样回传此值 |
| param | 头像编号(face),传入面板参数但**当前面板代码未使用**(未核实旧版是否显示头像) |
| tag / series | 未使用(=0) |

- **body 布局**:单个 GBK 字符串(`net.str(buf)` 整体读取并转 UTF-8),格式为:

```
NPC名字/正文……
```

第一个 `/` 之前是 NPC 名(空名则不显示标题),之后全部是正文。正文的完整文法见"服务端实现要点"。客户端收到后总是先销毁旧 npc 面板再新建——每次 SM_MERCHANTSAY 就是一整页新内容。

- **应答/错误分支**:无需应答;玩家点按钮则发 CM_MERCHANTDLGSELECT,服务端也可主动发 `SM_MERCHANTDLGCLOSE(644)` 关闭(处理:仅 `hidePanel("npc")`,无字段使用)。

### CM_MERCHANTDLGSELECT(1011)— 脚本命令回传

- **处理位置**:`mir2.scenes.main.panel.npc.lua :: npc:clickCMD(merchant, cmdstr)`(行 259 起);另一调用点 `mir2.scenes.main.common.common.lua :: common.showBosonResult`(骰子,见下)。
- **触发时机**:玩家点击对话中的任一脚本按钮(`<…>` 标记或 `{cmd}` 区按钮);部分命令先弹输入框再发送。
- **TDefaultMessage 字段**:

| 字段 | 用法 |
|---|---|
| recog | NPC id(SM_MERCHANTSAY 的 recog 原样回传) |
| param / tag / series | 不填(=0) |
| body | 命令串,1 个字符串段(net.send strs 帧:首字节 0x00 占位 + GBK 内容) |

- **body 内容按 cmdstr 形态分类**(`clickCMD` 内部逻辑):

| cmdstr 形态 | 客户端行为 | 实际发送的 body |
|---|---|---|
| 普通 / `@xxx`(单 @,如 `@buy`、`@sell`、`@main`) | 直接发送 | `@xxx` 原样 |
| `@@buildguildnow` | 弹输入框(建行会名称) | `@@buildguildnow` + `0x0D` + 输入文本(同一字符串段内拼接) |
| `@@guildwar` | 弹输入框(对方行会名) | `@@guildwar` + `0x0D` + 输入文本 |
| `@@InPutInteger*`(find 匹配) | 弹输入框,校验必须为数字且 ≤2147483646 | `@@InPutInteger...` + `0x0D` + 数字文本 |
| 其它任意 `@@xxx` | 弹输入框(拒绝含 `/` 或 `\`) | `@@xxx` + `0x0D` + 输入文本 |
| `@@helper<Lua代码>@<cmd>` | **本地执行** `<Lua代码>`(loadstring,环境仅含 `helper`=挂机助手对象),然后发送 `"@"..cmd` 部分;无第二段则不发包 | `@<cmd>` |
| `@@StrengthenEquip` | 仅本地打开强化装备(fusion)面板,**不发包** | — |
| `@@StrengthenCloth` | 仅本地打开强化衣服(strengthen)面板,**不发包** | — |

- **期望应答**:服务端按命令继续下发 `SM_MERCHANTSAY`(下一页)或业务消息(如 `SM_SENDGOODSLIST`,见 M6-S2)。

### SM_MERCHANT_QUERY(2831)/ CM_MERCHANT_QUERY(1110)— 询问与应答

- **处理位置**:`mir2.scenes.main.ui.lua :: mainui:processMsg`(行 672 起)与 `mir2.scenes.main.panel.npc.lua :: npc:showInput`(行 390 起)。
- **SM_MERCHANT_QUERY 字段**:recog=会话标识(sessionid),tag=类型,param=随 tag 语义透传,body=`net.str(buf)` 提示文本。
- **tag 分支**:

| msg.tag | 客户端行为 | 应答 |
|---|---|---|
| 0 | `npc:showInput`:弹出带单行输入框的确认框(msgbox hasCancel 配置:确定→idx=1,取消→idx=0);tag=3 时 showInput 直接返回不弹窗 | 玩家按确定(idx==1):复用原 msg 字段改发 `CM_MERCHANT_QUERY(1110)`,`series=idx`(即 **series=1**),body=输入文本(校验非空、不含 `/` 和 `\`);取消不发包。注:代码里仅 `msg.tag == 0` 时才把输入文本放入 body,其余 tag 发空 body |
| 1 | 弹两按钮确认框,btnTexts={"取消","同意"}(第 i 个按钮回调 idx=i) | 无论点了哪个都回发 `CM_MERCHANT_QUERY(1110)`:recog=sessionid、param=原 param、tag=1、`series=idx-1`(取消 idx=1→series=0;同意 idx=2→series=1),无 body |
| 3 | 什么都不做 | — |

- **错误分支**:无;服务端需自行容忍玩家不回应(取消/关框不发包)。

### SM_PLAYDICE(1200)— 骰子 NPC 开奖

- **处理位置**:`mir2.scenes.main.ui.lua :: mainui:processMsg`(行 961)→ `mir2.scenes.main.common.common.lua :: common.showBosonResult`(行 788)。
- **前置条件**:bufLen 必须大于 `getRecordSize("TMessageBodyWL")`(16 字节),否则忽略。
- **body 布局**:

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | record TMessageBodyWL | wl | 16 字节:int param1 / int param2 / int tag1 / int tag2(实际只读 param1) |
| 16 | char[] | npcSay | 其余字节作为 GBK 字符串(`net.str`),为开奖后续脚本命令 |

- **字段用法**:点数从 `wl.param1` 四个字节取:`Lobyte(Loword(param1))`、`Hibyte(Loword(param1))`、`Lobyte(Hiword(param1))`、`Hibyte(Hiword(param1))`,值为 0 的跳过(msg.param=diceCount 被读出但实际不参与过滤)。msg.recog 在回传时用作 NPC id。
- **应答**:客户端先延迟 0.6s,再播放 6 帧、帧间隔 0.65s 的随机掷骰动画(约 3.9s),动画一结束即发送 `CM_MERCHANTDLGSELECT(1011)`,recog=msg.recog,body=npcSay 原样回传——**npcSay 就是服务端要求客户端在动画结束后代发的下一条脚本命令**。

### SM_HIDEMERCHANT_QUERY(2832)

常量定义存在(`mir2.def.globa1.lua` 行 1111),全树 grep 无任何 processMsg 分支引用——本客户端不处理该消息。(未核实)服务端语义。

### SM_SHOWBOOK(2812)——书本展示(未处理)

`ui.lua` 行 963 分支体仅 `print("书本")`,无任何 UI/数据动作——本客户端不实现看书功能,服务端下发无害但也无效果。(未核实)服务端语义(推测为脚本"看书"类动作的回显通道)。

## 服务端实现要点

1. **脚本文本协议是重写重点**。`SM_MERCHANTSAY` 的 body 是一套完整标记文法,解析逻辑在 `panel.npc.lua :: parseContent / parseCcmd`,重写服务端的脚本引擎输出必须逐字符兼容:
   - 整体结构:`NPC名字/正文{cmd}按钮区`。第一个 `/` 分隔名字;`{cmd}` 为可选分隔标记,其后内容不再作为正文渲染,而是解析成底部按钮排;
   - 正文按 `|` 分行,行内按 `^` 分列(列宽均分,用于双栏排版);
   - 行内 `<>` 标记:`<文字/命令>` = 可点击按钮(默认黄字),`<文字>` = 红色普通文字,`<文字/命令/red>` 或 `<文字/命令/色号>` 指定颜色(red 映射调色板 249,数字色号经 def.colors.get 查表);`<C>`、`</C>` 被忽略;`<FONTSIZE/n>` 设置字号;`/FCOLOR` 作为命令串时视为纯文字;
   - 正文中所有 `\` 字符会被剔除(gsub);
   - `{cmd}` 按钮区同样按 `|` 分行,每行的全部 `<文字/命令>` 平铺为该行按钮(等距横排),点击效果与正文按钮一致;
   - **编码**:线上全程 GBK;客户端整体 a2u 后解析,因此服务端写入的字节必须是 GBK 且不要在多字节汉字中间出现 `/ < > | ^ { } \` 等保留字符的误配。
2. **命令回传是裸字符串契约**:客户端不解析 `@buy` 这类命令的语义,服务端必须能接受自己下发过的任意命令串被原样回传;`@@` 输入型命令的输入内容用单个 `0x0D` 拼接在命令串之后(不是独立字符串段),解析时按第一个 CR 切分。
3. **`@@helper` 是客户端本地执行的 Lua 片段**(环境白名单只有挂机助手对象),服务端脚本可以借此驱动客户端挂机行为,随后只会收到 `"@"..第二段` 的回传;`@@StrengthenEquip` / `@@StrengthenCloth` 纯本地开面板,不会有任何回包,脚本里不要等待这两个命令的服务器事件。
4. **无分页字段**:想要多页对话只能靠脚本命令翻页;商品列表的分页见 M6-S2(CM_USERGETDETAILITEM 的 param 偏移)。
5. **SM_MERCHANT_QUERY 的 series 语义不对称**(tag=0 输入框确定→series=1;tag=1 确认框取消/同意→series=0/1),重写时按上表逐一实现;SM_MERCHANT_QUERY(recog,param) 三元组必须原样回传,服务端用它定位是哪次询问。
6. **骰子流程**:SM_PLAYDICE 的 npcSay 由客户端在动画结束后代发,服务端在收到这条 CM_MERCHANTDLGSELECT 前不应下发下一页内容。
7. 本模块所有请求都不阻塞消息队列(未见 net.setWaitMsg 依赖),但对话链路是脚本状态机,服务端应保证每个合法命令都有下文(新页或关闭指令 SM_MERCHANTDLGCLOSE)。
