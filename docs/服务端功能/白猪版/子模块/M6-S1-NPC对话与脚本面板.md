# M6-S1 NPC对话与脚本面板

> 所属主模块:[M6-NPC与商店](../主模块/M6-NPC与商店.md) · 基础版对照:[M6-S1 NPC对话与脚本面板](../../基础版/子模块/M6-S1-NPC对话与脚本面板.md)

## 与基础版差异摘要

CM_CLICKNPC(1010)、SM_MERCHANTSAY(643) 脚本文法(`NPC名/正文{cmd}按钮区`、`|` 分行、`^` 分列、`<>` 标记、`\` 剔除)、CM_MERCHANTDLGSELECT(1011) 命令回传(`@@` 输入型 0x0D 拼接)、SM_MERCHANT_QUERY(2831)/CM_MERCHANT_QUERY(1110)——**与基础版完全一致**(白猪版 `core/mir2.scenes.main.panel.npc.lua` 仅 UI 差异)。

### 白猪版特有:自由交易面板(freedeal)的脚本命令

`core/mir2.scenes.main.panel.freedeal.lua`(白猪"自由交易"UI)复用 NPC 指令通道,与服务端 NPC 脚本交互:

| 事件 | 报文 | 参数 |
|---|---|---|
| 寄售/上架确认(JSH_SELL) | `CM_COMMIT_ITEM(4634)` | `series=1`,`recog=merchant`(NPC id),`param=Loword(makeIndex)`,`tag=Hiword(makeIndex)`,strs=物品名 |
| 下架(JSH_DOWN / JSH_TIMEOUT_DOWN) | `CM_MERCHANTDLGSELECT(1011)` | `recog=merchant`,strs=`"@NDownItem~" .. tmp_act` |
| 取回/结算(JSH_SAVING) | `CM_MERCHANTDLGSELECT(1011)` | `recog=merchant`,strs=`"@NReceiveItem~" .. tmp_act` |
| 购买(JSH_BUY) | `CM_MERCHANTDLGSELECT(1011)` | `recog=merchant`,strs=`"@NBuyItem~" .. rightPage` |
| 查询背包 | `CM_QUERYBAGITEMS(81)` | 无参(freedeal 行 550-551) |

- `merchant` 来源:自由交易面板通过 NPC 打开(merchant=NPC 的 roleid/序号,以打开流程代码为准(未核实))。
- 服务端要点:自由交易是**纯脚本协议**——NPC 脚本实现 `@NDownItem`(下架)/`@NReceiveItem`(取回)/`@NBuyItem`(购买,带页码)命令,配合商品列表(寄售列表)与 CM_COMMIT_ITEM(4634,series=1) 上架即可;客户端不解析这些命令的语义,原样回传。

## 服务端实现要点

1. 脚本文法按基础版 M6-S1;
2. 自由交易命令族(@N*)按服务端脚本约定实现,客户端回传格式如上。
