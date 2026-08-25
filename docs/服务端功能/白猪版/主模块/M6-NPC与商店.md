# M6 NPC与商店

> 所属系列:[白猪版服务端功能文档](../目录.md) · 基础版对照:[M6-NPC与商店](../../基础版/主模块/M6-NPC与商店.md)

## 模块边界

NPC 点击与脚本文本协议、商店买卖、自由交易(freedeal)。与基础版协议同号同布局,差异:

1. **遥控指令通道**:聊天文本前缀指令(FLTR/FROFF 等)会触发客户端回发 CM_SAY——服务端需识别;详见 [M4-S4](../子模块/M4-S4-系统消息与提示.md) 与 [M7-S1](../子模块/M7-S1-聊天频道.md);
2. **自由交易面板 freedeal**:复用 NPC 指令通道(CM_COMMIT_ITEM 4634 series=1 + CM_MERCHANTDLGSELECT 1011 的 @N 命令族)——见 [M6-S1](../子模块/M6-S1-NPC对话与脚本面板.md);
3. NPC 脚本文法(SM_MERCHANTSAY 643)与商店买卖(SM_SENDGOODSLIST 645/CM_USERBUYITEM 1014/CM_USERSELLITEM 等)与基础版一致——见 [M6-S2](../子模块/M6-S2-商店买卖.md)。

## 子模块一览表

| 子模块 | 内容 | 差异 |
|---|---|---|
| [M6-S1 NPC对话与脚本面板](../子模块/M6-S1-NPC对话与脚本面板.md) | SM_MERCHANTSAY 文法、@命令回传 | freedeal 的 @N 命令族 |
| [M6-S2 商店买卖](../子模块/M6-S2-商店买卖.md) | 商品列表/买卖/修理/寄存 | 无差异 |

## 消息号速查表(白猪版差异项)

| 消息 | 值 | 方向 | 说明 |
|---|---|---|---|
| CM_COMMIT_ITEM | 4634 | C→S | 兑换/提交(基础版同有;freedeal 用 series=1 + recog=merchant + param/tag=makeIndex + strs=物品名) |
| CM_MERCHANTDLGSELECT | 1011 | C→S | 脚本命令回传(freedeal 用 `@NDownItem~`/`@NReceiveItem~`/`@NBuyItem~` 前缀) |

其余同基础版 M6 速查表。

## 服务端实现要点

按基础版 M6 实现;若支持自由交易,NPC 脚本需实现 `@NDownItem`/`@NReceiveItem`/`@NBuyItem` 等命令(以服务端脚本约定为准,客户端只回传命令串)。
