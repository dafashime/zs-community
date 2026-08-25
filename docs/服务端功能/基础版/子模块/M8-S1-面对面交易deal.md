# M8-S1 面对面交易deal

> 所属主模块:[M8-经济交易系统](../主模块/M8-经济交易系统.md)

## 功能概述

两名玩家面对面进行的点对点物品/金币交换。流程为:发起 → 双方各自放入物品与金币(实时可见对方动作)→ 双方分别点击"交易"确认 → 服务端交割。任一方取消或离线,已放入的物品与金钱全部退回。

客户端不发送"取回物品"报文(`CM_DEALDELITEM(1027)` 定义了但本构建无调用点),即**物品一旦放进交易栏,本构建玩家无法自行取回,只能取消整单**——服务端重写时可据此简化,但 `SM_DEALDELITEM_OK/FAIL` 仍建议保留兼容。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.main.console.btnCallbacks.lua :: handle_panel`(key=="deal") | 发起入口:主界面"交易"按钮,3 秒节流后发 CM_DEALTRY |
| `mir2/mir2.scenes.main.panel.deal.lua` | 交易窗面板:放物(putItem)、放钱(putGold)、确认/取消按钮、4 秒节流 |
| `mir2/mir2.scenes.main.ui.lua :: processMsg`(SM_DEAL* 分支,行 965~1055) | 全部交易应答的中央分发;维护本地交易账本 `g_data.client.dealItems/dealGold/dealItem` |
| `mir2/mir2.data.client.lua` | 本地账本:setLastTime/checkLastTime(节流)、setNowDealItem/addDealItem/clearDealItem/setDealGold |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_DEALTRY | 1025 | C→S | 点击"交易"按钮(距上次 deal 操作 >3s) | body 为空字符串串 |
| SM_DEALMENU | 673 | S→C | 服务端受理成功 | body=对方名字;打开交易窗+背包 |
| SM_DEALTRY_FAIL | 674 | S→C | 受理失败(不对面等) | 提示"交易被取消。要正确交易你必须和对方面对面。" |
| CM_DEALADDITEM | 1026 | C→S | 从背包拖物品进自己交易栏(4s 节流) | recog=MakeIndex,body=物品名 |
| SM_DEALADDITEM_OK | 675 | S→C | 放入成功 | 物品入本地账本并显示 |
| SM_DEALADDITEM_FAIL | 676 | S→C | 放入失败 | 物品回背包 |
| CM_DEALDELITEM | 1027 | C→S | (未用) | 常量存在,无调用点 |
| SM_DEALDELITEM_OK / FAIL | 677 / 678 | S→C | (空处理) | 客户端分支体为注释占位 |
| SM_DEALREMOTEADDITEM | 682 | S→C | 对方放入物品 | body=TClientItem(16B 精简读法) |
| SM_DEALREMOTEDELITEM | 683 | S→C | 对方取回物品 | body=TClientItem;**客户端会调面板上不存在的方法**(见详细说明) |
| CM_DEALCHGGOLD | 1029 | C→S | 输入金额确认放入金币(4s 节流) | recog=金额 |
| SM_DEALCHGGOLD_OK | 684 | S→C | 改钱应答 | recog=交易栏我的金额;param/tag=持有金币 |
| SM_DEALCHGGOLD_FAIL | 685 | S→C | 改钱失败 | **客户端与 OK 分支共用同一处理代码** |
| SM_DEALREMOTECHGGOLD | 686 | S→C | 对方改钱 | recog=对方交易栏金额 |
| CM_DEALEND | 1030 | C→S | 点"交易"确认(4s 节流) | 无参无 body |
| SM_DEALSUCCESS | 687 | S→C | 双方均确认,交割完成 | 关窗清账本 |
| CM_DEALCANCEL | 1028 | C→S | 点关闭按钮取消(4s 节流) | 无参无 body |
| SM_DEALCANCEL | 681 | S→C | 任一方取消/掉线等,交易终止 | 账本内物品金钱退回背包 |

## 详细报文说明

### 发起:CM_DEALTRY(1025)

- 时机:`mir2.scenes.main.console.btnCallbacks.lua :: handle_panel`,`g_data.client:checkLastTime("deal", 3)` 通过(距上次 deal 时间戳 >3 秒)才发送,并发送后 `setLastTime("deal", true)` 记时间戳。
- TDefaultMessage 字段:recog/param/tag/series 全部缺省(=0)。
- body:`net.send({CM_DEALTRY}, {""})` —— strs 数组只有一个**空字符串**,按 net.send 规则(每条 GBK 化 + 尾部补 1 字节 0x00),body 长度 = 1,内容 = 单个 `0x00`。
- ⚠️ **对方名字没有随包发送**。本构建唯一发起入口就是该按钮,服务端无法从报文得知目标是谁(推断:旧引擎语义下依赖服务端自行判定"与谁交易",如按距离取唯一相邻玩家;具体匹配策略未核实)。服务端重写必须自行定义目标选择规则。

### 发起应答:SM_DEALMENU(673)/SM_DEALTRY_FAIL(674)

- SM_DEALMENU:`mir2.scenes.main.ui.lua :: processMsg` 取 `net.str(buf)`(整个 body 按 GBK→UTF-8 解码)作为**对方角色名**,打开 deal 面板与背包面板。body = 对方名字 GBK 字节串(变长,dataLength 决定)。
- 两者的公共副作用:`g_data.client:setLastTime("deal")`(**不带第二参数 = 清除节流时间戳**),允许后续操作立即进行。
- SM_DEALTRY_FAIL 仅弹提示,不开窗。

### 放入物品:CM_DEALADDITEM(1026)

- 时机:`mir2.scenes.main.panel.deal.lua :: putItem`,从背包拖拽物品到自己的交易栏时。前置条件:
  1. `g_data.client.dealItem == nil`(上一件物品尚未得到应答时不允许再放,提示"放入失败,当前网络慢,请重试!");
  2. `checkLastTime("deal", 4)` 通过(4 秒节流)。
- 客户端行为(乐观更新):先把物品从背包 UI 删除、记入 `dealItem`,置 `setLastTime("deal", true)`,然后发包。
- TDefaultMessage 字段:

| 字段 | 用法 |
|---|---|
| recog | int32,物品 MakeIndex |
| param/tag/series | 0 |

- body:strs = `{物品名}`(物品名取自客户端本地物品库 `data.getVar("name")`)→ body = GBK 物品名字节 + 收尾 `0x00`。

### 放物应答:SM_DEALADDITEM_OK(675)/SM_DEALADDITEM_FAIL(676)

两者都先 `setLastTime("deal")` 清节流,再处理挂起的 `g_data.client.dealItem`:

| 分支 | 客户端行为(mir2.scenes.main.ui.lua :: processMsg) |
|---|---|
| OK(675) | 物品加入本地账本 dealItems 并画到自己交易栏 |
| FAIL(676) | 物品放回背包(g_data.bag:addItem + 背包面板刷新) |

两者最后都清空 `dealItem` 挂起标记。**每个 CM_DEALADDITEM 必须恰好回一条 OK 或 FAIL**,否则客户端卡在"网络慢"状态且背包少一件(仅重启界面可恢复)。

### 对方放/取物品:SM_DEALREMOTEADDITEM(682)/SM_DEALREMOTEDELITEM(683)

body 布局 = `TClientItem`(packed 记录,基础 16 字节;`mir2.def.globa2.lua :: def.TClientItem`):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | uint | makeIndex | 物品唯一索引 |
| 4 | short | Index | 物品外观/标准索引(客户端据它查本地 StdItem 库) |
| 6 | short | dura | 持久/堆叠数量 |
| 8 | short | duraMax | 最大持久 |
| 10 | short | KeyValueSize | 扩展键值对个数 |
| 12 | uint | _Reserved | 保留 |
| (16) | TClientKeyValue×KeyValueSize | extendFields | 每个为 {short ValueType; short ValueNumber}(4B);**此两条消息中客户端按固定 16 字节读取,扩展区被忽略** |

注意:`mir2.scenes.main.ui.lua` 处理这两条消息时用的是 `net.record(item, buf, getRecordSize("TClientItem"))`,而 packed 记录的 `getRecordSize` 不含 dynamicArray,**固定返回 16**。因此服务端发精简 TClientItem(KeyValueSize=0,共 16B)即可;若带扩展也不会被解析。

⚠️ 已知缺陷(如实记录):SM_DEALREMOTEDELITEM 分支调用 `self.panels.deal:delItem("target", item)`,而 `panel.deal` 类**没有定义 delItem 方法**,收到该包会触发 Lua 运行时错误。服务端仍应按协议发送(保持协议完整),但需知会此风险;更稳妥做法是配合 SM_DEALCANCEL 重置整个窗口。

### 放入金币:CM_DEALCHGGOLD(1029)

- 时机:`mir2.scenes.main.panel.deal.lua :: putGold`,把金币图标拖到交易栏弹出的输入框确认后。校验:输入为 ≥1 的整数;`lastTime.deal` 为空或距今 >4 秒(否则提示"网络异常,请重试")。
- TDefaultMessage 字段:**recog = int32 金币数量**,param/tag/series=0。无 body(dataLen=0)。
- 注意:金额只放在 32 位 recog 里,int16 的 param/tag 未用于拆分。

### 改钱应答:SM_DEALCHGGOLD_OK(684)/SM_DEALCHGGOLD_FAIL(685)

`mir2.scenes.main.ui.lua :: processMsg` 中两分支**完全相同**(写成一个 or 条件):

| 字段 | 含义 |
|---|---|
| recog | int32,交易栏中"我的"金币总额,刷新到交易窗口 |
| param + tag | `MakeLong(param, tag) = param \| (tag<<16)`,即 32 位**当前持有金币总量**,刷新顶部/背包金币显示(common.goldChanged,增加时会播报差额) |

FAIL 时服务端应回传**原值**(交易栏金额不变、持有金币不变),因为客户端不做区分。同时两分支都会 `setLastTime("deal")` 清节流。

### 对方改钱:SM_DEALREMOTECHGGOLD(686)

recog = 对方交易栏金币总额,仅刷新对面一栏显示。无 body。

### 确认:CM_DEALEND(1030) → SM_DEALSUCCESS(687)

- 时机:点击交易窗"交易"按钮(`panel.deal :: ctor` 内回调),`lastTime.deal` 空或 >4 秒才发。
- CM_DEALEND 无字段无 body。
- 成功:服务端交割后向**双方**各发 SM_DEALSUCCESS(687)。客户端关窗、清 dealGold/dealItems 账本。随后金币变化经 SM_GOLDCHANGED(653)、物品变化经背包相关推送体现(属 M5-S1)。
- 本客户端**没有**名为 SM_DEALSENDOK 的消息(常量表中不存在);"我方确认已受理"没有独立应答,只有最终 SUCCESS/CANCEL 两种结局。

### 取消:CM_DEALCANCEL(1028) → SM_DEALCANCEL(681)

- CM_DEALCANCEL:点关闭按钮触发,同样受 4 秒节流(节流未过时**静默不发**,窗口却已关闭——服务端会话靠超时回收)。
- SM_DEALCANCEL(任一方取消/掉线/超时,服务端发给双方):
  - 把本地账本 dealItems 中所有物品逐件放回背包;
  - 若 dealGold>0,持有金币加回(`common.goldChanged(g_data.player.gold + dealGold)`);
  - 挂起的 dealItem 也退回;
  - 清账本、关窗。
- 因此 SM_DEALCANCEL 必须在物品已被扣走的前提下保证到达;服务端对断线方的回滚也应以 SM_DEALCANCEL 形式通知在线方。

### 节流汇总(文件::函数级)

| 操作 | 节流键 | 间隔 | 位置 |
|---|---|---|---|
| 发起交易 | deal | 3s | btnCallbacks.handle_panel |
| 放物品/放金币/确认/取消 | deal | 4s | panel.deal putItem/putGold/ctor 回调 |
| 节流重置 | — | — | ui.processMsg 各 OK/FAIL/MENU 分支 `setLastTime("deal")`(清除) |

## 服务端实现要点(依客户端行为推断)

1. **双确认交割**:两端各发一次 CM_DEALEND 后才交割(SM_DEALSUCCESS)。服务端须维护"每端已确认"标志;一端确认后另一端长时间未确认应超时取消(超时时长客户端无约定,(未核实)建议 ≤30s 并推 SM_DEALCANCEL)。
2. **锁定语义**:经典 Mir2 规则是任一侧改动(放物/改钱/取消)会重置双方确认状态。本构建客户端无对应显示逻辑,但服务端必须这么做,否则 A 确认后 B 改钱会造成单方损失。
3. **面对面校验**:CM_DEALTRY 不带目标名,服务端需按自身规则选目标(同屏最近玩家/(未核实));受理失败一律回 SM_DEALTRY_FAIL。
4. **每请求必答**:CM_DEALADDITEM、CM_DEALCHGGOLD 都有乐观更新,OK/FAIL 缺一会导致客户端状态永久错位。
5. **金额上限**:客户端只限制输入 ≥1;服务端必须校验持有金币是否足够,不足走 SM_DEALCHGGOLD_FAIL(回原值)。
6. **物品合法性**:MakeIndex 归属、绑定、堆叠数量由服务端复核;FAIL 即回滚背包。
7. **会话清理**:交易一方掉线时,对在线方推 SM_DEALCANCEL(含退回语义),不要只做服务端静默回滚。
