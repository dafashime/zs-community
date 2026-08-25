# M6 NPC与商店

> 子模块:[M6-S1 NPC对话与脚本面板](../子模块/M6-S1-NPC对话与脚本面板.md) · [M6-S2 商店买卖](../子模块/M6-S2-商店买卖.md)

## 模块边界

**本模块覆盖**(全部交互由 `mir2.scenes.main.panel.npc.lua` 的 NPC 面板承载,入口分发在 `mir2.scenes.main.ui.lua :: mainui:processMsg`):

- 点击 NPC 与对话打开:`CM_CLICKNPC` → `SM_MERCHANTSAY` / `SM_MERCHANTDLGCLOSE`;
- NPC 脚本按钮/输入框回传:`CM_MERCHANTDLGSELECT`(含 `@@` 输入型命令、骰子动画回传)、`SM_MERCHANT_QUERY` → `CM_MERCHANT_QUERY`;
- 商人商店:`SM_SENDGOODSLIST` 商品列表、`SM_SENDDETAILGOODS` 明细分页、`CM_USERBUYITEM` 买入及成败应答;
- 出售/修理/寄存拖拽框:`SM_SENDUSERSELL` / `SM_SENDUSERREPAIR` / `SM_SENDUSERSTORAGEITEM` 打开,报价查询 `CM_MERCHANTQUERYSELLPRICE` / `CM_MERCHANTQUERYREPAIRCOST`,确认 `CM_USERSELLITEM` / `CM_USERREPAIRITEM` / `CM_USERSTORAGEITEM` 及应答;
- NPC 合成(配药)通道:`SM_SENDMAKEDRUGITEMS` → `CM_USERMAKEDRUGITEM` → `SM_MAKEDRUG_FAIL`;
- 兑换通道:`SM_OPEN_COMMIT_ITEM` → `CM_COMMIT_ITEM` → `SM_COMMIT_ITEM`。

**不在本模块**(易混淆项,均已在子模块中标注交叉引用):

| 功能 | 归属 | 说明 |
|---|---|---|
| 仓库列表与取回面板 | M5-S3 | 走 `SM_SAVEITEMLIST(704)` 独立仓库面板;但寄存/取回的 CM 消息与本模块共用 |
| 宝箱(treasureBox) | M5-S4 | **不走 NPC 通道**,用独立消息族 `CM_BOX2_TRYOPEN(1085)` 等;`mir2.scenes.main.panel.treasureBox.lua` 无任何 CM_CLICKNPC/MERCHANTSAY 交互 |
| 元宝商城(panel.shop) | M8-S4 | 数据层 `mir2.data.shop.lua`(g_data.shop)解析 `SM_SHOPITEMS(812)`;IAP/GHOME 充值族同属 M8-S4 |
| 配药状态查询 | M5-S5 | `panel.mixingDrug.lua` 走 `CM_MAKEDRUG_STATUS_QUERY(4640)`;与 NPC 合成通道(`CM_USERMAKEDRUGITEM`)是两回事 |

另:托管/挂机(autoRat,`mir2.scenes.main.console.autoRat.lua`)为纯客户端本地自动战斗系统,**没有任何 NPC 通道报文**,不涉及本模块。

## 子模块一览表

| 子模块 | 内容 | 核心链路 |
|---|---|---|
| [M6-S1 NPC对话与脚本面板](../子模块/M6-S1-NPC对话与脚本面板.md) | 点击 NPC、对话文本协议(`<命令>` 标记文法)、脚本按钮回传、输入框类交互、骰子 NPC | `CM_CLICKNPC` → `SM_MERCHANTSAY` → `CM_MERCHANTDLGSELECT` 循环 |
| [M6-S2 商店买卖](../子模块/M6-S2-商店买卖.md) | 商品列表/明细分页、买入、出售、修理、寄存、合成、兑换,及元宝商城边界说明 | `SM_SENDGOODSLIST` → `CM_USERBUYITEM`;拖拽框 → 报价查询 → 确认提交 |

## 消息号速查表

数值均已对照 `mir2/mir2.def.globa1.lua` 逐条核实。方向:C→S = 客户端发出,S→C = 服务端下发。

### S1 对话与脚本(详见 M6-S1)

| 消息 | 十进制值 | 方向 | 一句话 |
|---|---|---|---|
| CM_CLICKNPC | 1010 | C→S | 点击/引导触发与某 NPC 对话(recog=NPC id,无 body) |
| SM_MERCHANTSAY | 643 | S→C | NPC 对话内容(首段=NPC 名,余为脚本文本+按钮标记) |
| SM_MERCHANTDLGCLOSE | 644 | S→C | 服务端要求关闭 NPC 对话面板 |
| CM_MERCHANTDLGSELECT | 1011 | C→S | 玩家点了脚本按钮,body=命令串(GBK,可含 CR+输入内容) |
| SM_MERCHANT_QUERY | 2831 | S→C | 服务端弹询问/输入框(tag=0 输入框 / tag=1 确认框 / tag=3 忽略) |
| CM_MERCHANT_QUERY | 1110 | C→S | 对上述询问的应答(series 区分按钮,body=输入文本) |
| SM_HIDEMERCHANT_QUERY | 2832 | S→C | 本客户端无处理分支(定义未使用) |
| SM_PLAYDICE | 1200 | S→C | 骰子 NPC 掷点结果(TMessageBodyWL+回传命令),播完动画客户端回发 CM_MERCHANTDLGSELECT |

### S2 商店买卖(详见 M6-S2)

| 消息 | 十进制值 | 方向 | 一句话 |
|---|---|---|---|
| SM_SENDGOODSLIST | 645 | S→C | 打开商品分类列表(PNewMarketInfo 数组,count=msg.param) |
| CM_USERGETDETAILITEM | 1015 | C→S | 请求某分类的商品明细/翻页(body=分类名,param=页偏移) |
| SM_SENDDETAILGOODS | 652 | S→C | 商品明细列表(TClientItem 数组,tag=当前偏移) |
| CM_USERBUYITEM | 1014 | C→S | 买入(param/tag=商品标识 Loword/Hiword,body=物品名);0.5s 节流 |
| SM_BUYITEM_SUCCESS | 650 | S→C | 买入成功(recog=最新金币,param/tag=所购条目 makeIndex) |
| SM_BUYITEM_FAIL | 651 | S→C | 买入失败(recog=1 已售出 / 2 背包满 / 3 钱不够) |
| SM_SENDUSERSELL | 646 | S→C | 打开"出售"拖拽框 |
| CM_MERCHANTQUERYSELLPRICE | 1012 | C→S | 查询某物出售价(param/tag=makeIndex) |
| SM_SENDBUYPRICE | 647 | S→C | 报价应答(recog=价格,负数显示 ???? 金币) |
| CM_USERSELLITEM | 1013 | C→S | 确认卖出(5s 节流;series 原样回传) |
| SM_USERSELLITEM_OK | 648 | S→C | 卖出成功,物品从背包移除 |
| SM_USERSELLITEM_FAIL | 649 | S→C | 卖出失败,物品退回背包 |
| SM_SENDUSERREPAIR | 668 | S→C | 打开"修理"拖拽框 |
| CM_MERCHANTQUERYREPAIRCOST | 1024 | C→S | 查询修理费用 |
| SM_SENDREPAIRCOST | 671 | S→C | 修理费应答(与 SM_SENDBUYPRICE 同一显示分支) |
| CM_USERREPAIRITEM | 1023 | C→S | 确认修理 |
| SM_USERREPAIRITEM_OK | 669 | S→C | 修理成功(param=新持久,tag=新持久上限) |
| SM_USERREPAIRITEM_FAIL | 670 | S→C | 修理失败("您不能修理此物品.") |
| SM_SENDUSERSTORAGEITEM | 700 | S→C | 打开"保管物品"拖拽框 |
| CM_USERSTORAGEITEM | 1031 | C→S | 寄存物品到仓库 |
| SM_STORAGE_OK | 701 | S→C | 寄存成功(物品入仓库面板) |
| SM_STORAGE_FULL | 702 | S→C | 仓库已满 |
| SM_STORAGE_FAIL | 703 | S→C | 寄存失败 |
| CM_USERTAKEBACKSTORAGEITEM | 1032 | C→S | 取回寄存物品(NPC 列表分支为死路径;实际由仓库面板发送,见 M5-S3) |
| SM_GETSTORAGEITEM_OK | 705 | S→C | 取回成功(recog=makeIndex) |
| SM_GETSTORAGEITEM_FAIL | 706 | S→C | 取回失败(-1 超重 / -2 交易中 / -3 绑定) |
| SM_GETSTORAGEITEM_FULLBAG | 707 | S→C | 背包满无法取回 |
| SM_SAVEITEMLIST | 704 | S→C | 仓库物品总列表(独立仓库面板,M5-S3 详述) |
| SM_SENDMAKEDRUGITEMS | 712 | S→C | NPC 配药材料列表(PNewMarketInfo 数组) |
| CM_USERMAKEDRUGITEM | 1034 | C→S | 提交配药合成 |
| SM_MAKEDRUG_SUCCESS | 713 | S→C | 客户端无处理分支(定义未使用)(未核实服务端语义) |
| SM_MAKEDRUG_FAIL | 714 | S→C | 配药失败(recog=2 得物失败 / 3 钱不够 / 4 材料不足) |
| SM_OPEN_COMMIT_ITEM | 4635 | S→C | 打开"兑换"拖拽框(series=兑换序号,body=提示文本) |
| CM_COMMIT_ITEM | 4634 | C→S | 兑换确认(series 回传 SM_OPEN_COMMIT_ITEM 的 series) |
| SM_COMMIT_ITEM | 4634 | S→C | 兑换结果(**与 CM 同号**:param=1 成功 / 0 失败+body 文案) |
| CM_USERPLAYDRINKITEM | —(常量未定义) | C→S | "请酒"分支引用了该常量,但 rebuilt-src 全树无定义(死路径,见 M6-S2) |

### 边界外交叉引用(数值备查,详见对应模块)

| 消息 | 十进制值 | 方向 | 归属 |
|---|---|---|---|
| SM_SHOPITEMS | 812 | S→C | 元宝商城商品(M8-S4) |
| SM_FIRSTSHOP | 815 | S→C | 元宝商城特惠页(M8-S4) |
| SM_DOSHOP_FAIL | 816 | S→C | 元宝商城购买失败(M8-S4) |
| CM_REQSEESHOP | 1046 | C→S | 请求元宝商城列表(M8-S4) |
| CM_DOSHOP | 1048 | C→S | 元宝商城购买(M8-S4) |
| CM_BOX2_TRYOPEN / SM_BOX2_TRYOPEN | 1085 / 961 | 双向 | 宝箱开启(M5-S4,不走 NPC 通道) |
| CM_BOX2_ROTATE / SM_BOX2_ROTATE | 1086 / 962 | 双向 | 宝箱抽奖转动(M5-S4) |
| CM_BOX2_GETPRIZE / SM_BOX2_GETPRIZE | 1087 / 963 | 双向 | 宝箱领奖(M5-S4) |
| CM_BOX2_CLOSE | 1088 | C→S | 关闭宝箱(M5-S4) |
| CM_GHOME_PAY_READY / SM_GHOME_PAY_READY | 4482 | 双向 | IAP 充值就绪(M8-S4) |
| CM_GHOME_PAY_FAILED | 4483 | C→S | 充值失败上报(M8-S4) |
| CM_QUERY_GHOME_ORDER / SM_SEND_GHOME_ORDER_RESULT | 4484 | 双向 | 充值订单查询(M8-S4) |
| SM_GHOME_UNFINISH_ORDER | 4485 | S→C | 未完成订单通知(M8-S4) |
