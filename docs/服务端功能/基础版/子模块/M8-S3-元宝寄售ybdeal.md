# M8-S3 元宝寄售ybdeal

> 所属主模块:[M8-经济交易系统](../主模块/M8-经济交易系统.md)

## 功能概述

以**元宝**计价的离线挂单交易(寄售/求购撮合)。卖家从背包挑最多 10 件物品、指定买家姓名与总价(1~99999 整数元宝)下单;订单出现在双方的"向我下单/正在出售"列表,买家确认后扣元宝、物品经服务端转移。支持历史查询与"最低卖家等级"防骚扰设置。

面板为 6 个页签(`panel.ybdeal :: query` 的 tag):1=向我下单(list_buy)、2=我正在出售(list_sell)、3=挂售下单(本地选物,不发请求)、4=历史买入、5=历史卖出、6=交易设置。每次切换页签都重新向服务端查询,无本地缓存翻页。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.main.panel.ybdeal.lua` | 面板:query(tag) 发查询、upt(tag) 渲染列表、挂售表单(买家姓名/价格/10 格选物)、购买与取消按钮 |
| `mir2/mir2.data.ybdeal.lua` | 数据层:parseMsg 解析四类列表、sign 双应答机制、parseSetting 读设置 |
| `mir2/mir2.scenes.main.ui.lua :: processMsg`(行 2233~2350) | 全部 SM 分发:错误码提示、removeBuyUnit/removeSellUnit、双 sign 汇合触发 sellUpt |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_YBDEAL_QUERY_BUY / SM_YBDEAL_QUERY_SELL… | 见下 | — | 切换对应页签或点刷新按钮 | 全部无参无 body(dataLen=0) |

各页签的请求/应答配对(panel.ybdeal :: query 与 data.ybdeal :: getName/getTag):

| 页签 tag | CM(请求) | 值 | SM(应答) | 值 | 本地列表名 |
|---|---|---|---|---|---|
| 1 | CM_YBDEAL_QUERY_BUY | 1252 | SM_YBDEAL_QUERY_BUY | 3001 | list_buy |
| 2 | CM_YBDEAL_QUERY_SELL | 1253 | SM_YBDEAL_QUERY_SELL | 3002 | list_sell |
| 4 | CM_YBDEAL_HISTROY_BUY | 1256 | SM_YBDEAL_HISTROY_BUY | 3005 | list_buyHis |
| 5 | CM_YBDEAL_HISTROY_SELL | 1257 | SM_YBDEAL_HISTROY_SELL | 3006 | list_sellHis |
| 6 | CM_DISPLAY_YBDEAL_SET | 4446 | SM_DISPLAY_YBDEAL_SET | 4446 | (设置值) |

操作类报文:

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_YBDEAL_REFER_ITEMS | 1251 | C→S | 挂售页"确认出售"(已选≥1 物、有买家名、价格合法) | tag=件数,body=TYBDealDataHead+TYBDealData×N |
| SM_YBDEAL_REFER_ITEMS1 | 3000 | S→C | 下单校验第一步 | recog=1 或 -1~-8/-11 |
| SM_YBDEAL_REFER_ITEMS2 | 3008 | S→C | 下单校验第二步 | recog=1 或 -1/-2/-5~-7;两步都=1 才算成功 |
| CM_YBDEAL_BUY | 1254 | C→S | "向我下单"页点购买并确认 | recog=订单号(id) |
| SM_YBDEAL_BUY | 3003 | S→C | 应答 | recog>0 成功;-1~-9 错误 |
| CM_YBDEAL_BUY_CANCEL | 1255 | C→S | 取消别人对我的下单 | recog=订单号 |
| SM_YBDEAL_BUY_CANCEL | 3004 | S→C | 应答 | recog>0 成功;-1 对方已取消;-2 未知错误 |
| CM_YBDEAL_SELL_CANCEL | 1258 | C→S | "正在出售"页取回/取消 | recog=订单号 |
| SM_YBDEAL_SELL_CANCEL | 3007 | S→C | 应答 | recog>0 成功;-1 已售出;-2 超时无法取回 |
| CM_YBDEAL_SET_OPERATE | 1265 | C→S | 设置页输入等级失焦(1~999) | param=新等级 |
| SM_YBDEAL_Set_Operate | 3015 | S→C | 应答 | recog=0 成功;-1 超 999 |
| CM_YBDEAL_OPENDEAL / SM_YBDEAL_OPENDEAL | 1259 / 3009 | (未用) | 常量存在,无引用 | |
| CM_YBDEAL_PROTECT / SM_YBDEAL_PROTECT | 1260 / 3010 | (未用) | 常量存在,无引用 | |
| SM_YBDEAL_SetInfo | 3016 | (未用) | 常量存在,无引用 | |

## 详细报文说明

### 列表查询:CM_YBDEAL_QUERY_*(1252/1253/1256/1257)

- 时机:打开面板默认查 tag1;点击任一页签(`common.tabs` 回调 → query(idx))或页内刷新按钮重发当前页签。
- 无 TDefaultMessage 字段、无 body。
- **没有分页参数**(任务假设的"分页 param"不存在):一次返回全部,param=条数上限受单包 dataLength(int16)限制——服务端应自行截断条数((未核实)建议 ≤100 条/包)。

### 列表应答:SM_YBDEAL_QUERY_BUY(3001)/QUERY_SELL(3002)/HISTROY_BUY(3005)/HISTROY_SELL(3006)

`mir2.data.ybdeal.lua :: parseMsg` 解析:

| TDefaultMessage 字段 | 用法 |
|---|---|
| ident | 决定写入哪个列表(list_buy/list_sell/list_buyHis/list_sellHis),解析前先清空该列表 |
| param | int16,**订单条数 N** |
| recog/tag/series | 未用 |

body = N 组重复,每组:

**① TYBDealClientItems(40 字节,非 packed)**

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | string(15) | name | 对方角色名(买家视角=卖家名,反之亦然;首字节长度 L≤15,占 16B) |
| 16 | uint | id | 订单号(后续 BUY/CANCEL 都用它作 recog) |
| 20 | int | num | 订单总价(元宝;"确认花费%d元宝购买"取此值) |
| 24 | byte | cnt | 随单物品件数 M(≤10) |
| 25 | byte | timeOut | ≠0 表示订单已过期(UI 标红"已过期";卖方取回需付 1 元宝——文案) |
| 26 | byte | getLost | ≠0 表示物品已被取回("正在出售"页隐藏该单) |
| 27 | byte | cancel | ≠0 表示买家已取消(UI 标红"买家已取消") |
| 28 | short | level | 对方等级(Lv 显示;历史记录不显示) |
| 32 | double | time | 下单时间(Delphi TDateTime,经 TDateTimeToUnixDate 显示) |

(对齐:name 16B 不对齐,uint 补齐至 16 起;level 补齐至偶偏移 28;time 补齐至 32;总长向上取整至 8 = 40。)

**② TClientItem × cnt(变长)**

每件随单物品一条完整 TClientItem(16B 基础 + KeyValueSize×4B 扩展,客户端按剩余 bufLen 连续读取)。注意 ybdeal 数据层给 item 打了本地补丁:`isPileUp = stdMode > 150`(stdMode 由 Index 查本地库得到),堆叠判断只影响 UI。

渲染过滤规则(`panel.ybdeal :: upt`):

| 列表 | 显示条件 | 状态标注 |
|---|---|---|
| list_buy(页1) | timeOut==0 且 cancel==0 | — |
| list_sell(页2) | getLost==0 | timeOut≠0→"已过期";cancel≠0→"买家已取消" |
| 历史(页4/5) | 全部显示 | 不显示对方等级 |

### 挂售下单:CM_YBDEAL_REFER_ITEMS(1251)

- 时机:页签 3(挂售)中从背包拖入最多 10 件未绑定物品,填买家姓名(非空)、整数价格 1~99999,点"确认出售"。发送前 `g_data.ybdeal:resetSign()` 清空双应答标志。
- TDefaultMessage 字段:**tag = 随单物品件数 num(1~10)**;recog/param/series 未用。
- body = 1 条头 + num 条明细 + 收尾 0x00:

**TYBDealDataHead(20 字节)**

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | string(15) | name | 买家姓名(GBK) |
| 16 | int | price | 总价(元宝,1~99999) |

**TYBDealData × num(每条 20 字节)**

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | string(15) | name | 物品名(客户端本地库名,仅展示用途) |
| 16 | int | makeIndex | 物品唯一索引(**服务端以此定位物品**) |

dataLen = 20 + num×20 + 1。

### 下单双应答:SM_YBDEAL_REFER_ITEMS1(3000)+SM_YBDEAL_REFER_ITEMS2(3008)

一次下单,服务端要回**两条**独立校验消息;客户端用 sign 表记录:`g_data.ybdeal.sign[3000]` 与 `sign[3008]` 都为 true 且面板开着时才执行 `sellUpt()`(切回页签 2 并刷新)。**任何一条失败都不再成功**——错误码互斥地分布在两条上,服务端可按校验阶段选择在哪条上报错(另一条可不发,但此时 sign 不齐,UI 停留在当前页;建议失败也把另一条补发 recog=1 或统一只走 ITEMS1,(未核实))。

SM_YBDEAL_REFER_ITEMS1(3000) 错误码(mir2.scenes.main.ui.lua 行 2286~2304):

| recog | 提示 |
|---|---|
| -1 | 买家账号不存在! |
| -2 | 请输入买家姓名! |
| -3 | 买家姓名含有非法字符! |
| -4 | 不能出售给自己! |
| -5 | 出售的物品不存在! |
| -6 | 出售的装备处于锁定状态! |
| -7 | 已经在交易状态!(物品被其他交易占用) |
| -8 | 输入的价格超出范围! |
| -11 | 未达到对方设定的交易等级!(对方在设置页设了门槛) |

SM_YBDEAL_REFER_ITEMS2(3008) 错误码(行 2312~2322):

| recog | 提示 |
|---|---|
| -1 | 输入的买家不合法! |
| -2 | 输入的价格超出范围! |
| -5 | 只能同时出售4单!(协议文案:每角色最多 4 笔未完成出售单) |
| -6 | 对方购买订单已满4单,无法接受新的订单! |
| -7 | 出售的物品不存在! |

两者 recog==1 为各自阶段通过。成功后物品从背包移除由服务端推送(M5-S1)体现,列表经页签 2 重查获得。

### 买家接单:CM_YBDEAL_BUY(1254)/SM_YBDEAL_BUY(3003)

- CM:recog = 订单号(TYBDealClientItems.id),无 body。确认弹窗文案"确认花费%d元宝购买这些物品么?"。
- SM 应答:

| recog | 客户端行为 |
|---|---|
| >0 | 成功:视为订单号,从 list_buy 移除并刷新页 1;元宝变化另经 SM_GETDIAMNUM_EXT 推送 |
| -1 | 包裹没有足够空间! |
| -2 | 对方已取消! |
| -3 | 元宝不足! |
| -4 | 发生未知错误! |
| -5 | 订单号错误! |
| -6 | 卖家不存在! |
| -8 / -9 | 未找到订单信息!(两个码同文案) |

### 买家取消:CM_YBDEAL_BUY_CANCEL(1255)/SM_YBDEAL_BUY_CANCEL(3004)

- CM:recog=订单号,无 body;确认文案"确认取消此单交易么?"。
- SM:recog>0 成功(从 list_buy 移除);-1"对方已取消!";-2"发生未知错误!"。

### 卖家取回/取消:CM_YBDEAL_SELL_CANCEL(1258)/SM_YBDEAL_SELL_CANCEL(3007)

- CM:recog=订单号,无 body。确认文案按状态区分:`timeOut≠0` 时为"订单已超时,**取回物品需支付1元宝**。是否取回?"(费用由服务端扣,报文本身无金额字段);否则"确认取消此单交易,取回物品么?"。
- SM:recog>0 成功(从 list_sell 移除并刷新页 2);-1"物品已售出!"(不可再取回);-2"超时无法取回!"。

### 交易设置:CM_DISPLAY_YBDEAL_SET(4446)/SM_DISPLAY_YBDEAL_SET(4446)/CM_YBDEAL_SET_OPERATE(1265)/SM_YBDEAL_Set_Operate(3015)

- 查询:切到页签 6 时发 CM_DISPLAY_YBDEAL_SET(4446,无参无 body)。应答 **recog = 当前允许向自己下单的卖家最低等级**,`data.ybdeal :: parseSetting` 存入 `self.level`;getTag 把 4446 映射为页签 6 渲染。
- 修改:输入框失焦且值合法(1~999 整数)即发 CM_YBDEAL_SET_OPERATE:**param = 新等级**,其余字段与 body 均无。
- 应答 SM_YBDEAL_Set_Operate(3015):recog=0"设置成功.";/-1"设置错误,设定等级超过最大等级999!"。注意成功后客户端不回写本地 level,直到下次查询 4446。
- 该设置的生效点在卖方下单链路:ITEMS1 的 recog=-11("未达到对方设定的交易等级")。

### 同号双向说明

`CM_DISPLAY_YBDEAL_SET` 与 `SM_DISPLAY_YBDEAL_SET` 数值同为 4446(globa1 行 2381~2382);整个摆摊段(见 S2)同样如此。分发实现必须按方向而非数值区分。

## 服务端实现要点(依客户端行为推断)

1. **订单状态机**:每笔订单至少含 状态{挂单/过期(timeOut)/买家取消(cancel)/已取回(getLost)/已完成}、单价 num、件数 cnt、双方 id/名字/等级、下单时间。四个列表是同一存储的四视图:buy=别人对我下的单,sell=我对别人下的单。
   - 客户端过滤逻辑表明:过期但未取回的单仍留在 list_sell 中(timeOut≠0 且 getLost==0);买家取消后卖方仍能看到(cancel≠0)。
2. **双阶段校验**:REFER_ITEMS 必须产出两条应答(3000 与 3008)。推荐拆分为:3000=目标玩家/物品基础校验,3008=限额(4 单)/容量校验;失败码严格对照上文表格,否则文案对不上。
3. **数量约束(来自协议文案,服务端应执行)**:单笔 ≤10 件;每角色同时 ≤4 笔未完成出售单;对方订单箱满(-6)拒收;物品上架超过 3 天终止交易、超时取回收 1 元宝(页签 6《交易协议》原文)。
4. **防骚扰门槛**:买方可设"最低卖家等级",卖方下单时不满足则 ITEMS1 回 -11。设置值持久化,登录后靠 4446 查询恢复。
5. **资金安全**:接单扣元宝与发货必须原子;元宝余额变化后补发 SM_GETDIAMNUM_EXT(1202)(见 S4),否则客户端显示不同步。
6. **物品名仅展示**:body 里的物品名(makeIndex 旁)不可信,一律以 makeIndex 反查物品实例;名字不符不影响交易。
7. **订单 id 用 uint**:TClientItem.id 字段为 uint;CM 侧 recog 是 int32,服务端分配订单号时应保持在 0x7FFFFFFF 内以免符号歧义。
