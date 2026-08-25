# M5-S5 配药mixingDrug

> 所属主模块:[M5-物品与装备](../主模块/M5-物品与装备.md)
> 关联:[M6-S2 商店买卖](../子模块/M6-S2-商店买卖.md)(老版 NPC 配药通道)、[M5-S1 背包与物品操作](../子模块/M5-S1-背包与物品操作.md)(材料/成品经通用物品消息入包)

## 功能概述

本树存在**两套配药系统**:

1. **老版 NPC 配药**(合成列表):走 NPC 面板的 "synthesis" 列表,消息为 `SM_SENDMAKEDRUGITEMS(712)` / `CM_USERMAKEDRUGITEM(1034)` / `SM_MAKEDRUG_FAIL(714)` —— 布局与商店通道完全相同,已由 [M6-S2](M6-S2-商店买卖.md) 详述,本文不重复。
2. **新版生活技能配药面板**(`panel.mixingDrug`):独立消息族 **4639~4645**,含配方配置下发、状态机(未学习/未炼制/炼制中/已完成)、炼制进度、领取。本文详述此套。

新版特点:**面板打开完全由服务端驱动**——客户端不存在任何"打开配药面板"的上行请求(全树无 `CM_ALL_MAKEDRUG_STATUS_QUERY(4639)` 发送点,grep 核实),服务端推 `SM_ALL_MAKEDRUG_STATUS(4639)` 才显示面板。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.data.mixingDrug.lua` | `saveConfig`/`set`/`query`/`update` —— 报文布局证据 |
| `mir2/mir2.scenes.main.panel.mixingDrug.lua` | 面板 UI 与全部上行发送点(行 55/162/293/392/402) |
| `mir2/mir2.scenes.main.ui.lua` | SM 分发分支(行 2497-2544) |
| `mir2/mir2.def.globa2.lua` | TMixingDrugConfig / TMixingDrugListInfo / TMixingDrugBegin / TMixingDrugDuring / TMixingDrugLevelInfo 定义 |
| `mir2/mir2.def.items.lua` | 材料/成品道具定义(客户端本地,cfg.consume/cfg.generate 引用其 name) |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| SM_SEND_MAKEDDRUG_CONFIG | 4645 | S→C | 配方配置下发(时机未核实,推测登录后/进游戏时) | body=N×TMixingDrugConfig |
| SM_ALL_MAKEDRUG_STATUS | 4639 | S→C | 服务端主动推(打开面板) | body=N×TMixingDrugListInfo;同号 CM 无发送点 |
| CM_MAKEDRUG_STATUS_QUERY | 4640 | C→S | 面板 tab 切换(panel 行 55) | recog=配方 id;同号回执 |
| SM_MAKEDRUG_STATUS | 4640 | S→C | 状态查询应答 | tag=状态;body 随状态变化 |
| CM_LEARN_LIVINGSKILL | 4643 | C→S | 点"学习"按钮(panel 行 162) | recog=配方 id;同号回执 |
| SM_LEARN_LIVINGSKILL | 4643 | S→C | 学习结果 | recog=1 成功/其他失败 |
| CM_CAN_MAKEDRUG_QUERY | 4641 | C→S | 点"炼制"按钮(panel 行 293,先本地校验金币) | recog=配方 id,param=炼制次数;同号回执 |
| SM_CAN_MAKEDRUG | 4641 | S→C | 开始炼制结果 | param=0 开始/1 材料不足/2 金币不足 |
| CM_GAIN_MAKEDDRUG | 4642 | C→S | 炼制完成点领取按钮(panel 行 392/402) | recog=配方 id,param=0 存仓库/1 入背包;注意常量名笔误 MAKEDDRUG(双D) |
| SM_GAIN_MAKEDDRUG | 4642 | S→C | 领取结果 | param=1 成功/其他失败 |
| SM_MAKEDRUG_SUCCESS | 713 | S→C | 老版通道,客户端无处理分支 | 见 M6-S2 死路径清单 |
| SM_MAKEDRUG_FAIL | 714 | S→C | 老版通道失败 | recog=2/3/4(见 M6-S2) |

## 详细报文说明

### SM_SEND_MAKEDDRUG_CONFIG(4645)——配方配置

- 分发:`ui.lua` 行 2497 → `mixingDrug:saveConfig`。`bufLen / getRecordSize("TMixingDrugConfig")` 循环解包,按 id 供面板查询。
- body:TMixingDrugConfig 数组,单条 **134 字节**(6×short=12 + string[20]=21 + string[100]=101,2 字节对齐,无 int 成员):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | short | id | 配方 id(面板 recog 用) |
| 2 | short | consume | 材料物品 id(def.items 索引) |
| 4 | short | generate | 成品物品 id |
| 6 | short | input | 每次炼制消耗材料个数 |
| 8 | short | output | 每次产出成品个数 |
| 10 | short | resid | 面板 tab 图片索引(`tab_<resid>.png`) |
| 12 | string[20] | name | GBK,21B(长度前缀) |
| 33 | string[100] | desc | GBK,101B(长度前缀) |

- TDefaultMessage 字段:未使用。

### SM_ALL_MAKEDRUG_STATUS(4639)——配方状态全量(打开面板)

- 分发:`ui.lua` 行 2499 → `mixingDrug:set` 存 `lst`,随后**无条件打开面板**(先 hide 再 show)。客户端无对应上行(全树无 `CM_ALL_MAKEDRUG_STATUS_QUERY` 发送点)——**面板何时弹出完全由服务端决定**(如满足某条件时推送)。
- body:TMixingDrugListInfo 数组,单条 **4 字节**:
  - short id;short state。state 语义(面板文案):0=未学习 / 1=未炼制 / 2=炼制中 / 3=已完成。
- 服务端要点:此包应在服务端判定玩家可进入配药界面时推送;推了面板就弹,不推玩家无法主动打开(除非走其他入口,本树未见)。

### CM_MAKEDRUG_STATUS_QUERY(4640)/SM_MAKEDRUG_STATUS(4640)——单项状态查询(同号回执)

- 上行:切换面板 tab 时(panel 行 55-58),`recog`=配方 id,其余字段未用,无 body。
- 应答:`ui.lua` 行 2507 → `mixingDrug:query`:
  - `recog`=配方 id(与请求一致);
  - `tag`=状态:`1`=炼制中(begin)/`2`=进行中(during)/`3`=已完成(ended)。**注意 query 同时用 tag 更新列表 state**;
  - `param`=tag==3 时成品物品条数;
  - body 结构(按 tag 分支,末尾统一追加 TMixingDrugLevelInfo):
    - tag=1:TMixingDrugBegin(8B)= `int time`(炼制总时长,**秒**;面板显示 `time×次数 分钟`)+ `int price`(每次金币单价;总价=price×次数);
    - tag=2:TMixingDrugDuring(8B)= `int time`(**剩余秒数**;本地每秒减一,归零自动刷新)+ `int cnt`(炼制份数);
    - tag=3:`param` 条 TClientItem(成品+失败产物混合,面板按物品名与 cfg.generate 匹配区分);
    - 尾部:TMixingDrugLevelInfo(12B)= short lv @0 + [2B 对齐填充] + int curExp @4 + int maxExp @8(熟练度显示 `curExp/maxExp`)。
- 服务端要点:任何状态都必须**带 LevelInfo 尾部**,否则 `net.record` 截断后 query 合并失败;tag 只取 1/2/3,其余值 query 不解析 body 但仍读 LevelInfo。

### CM_LEARN_LIVINGSKILL(4643)/SM_LEARN_LIVINGSKILL(4643)——学习配方(同号回执)

- 上行:状态=0(未学习)详情页点"学习"(panel 行 162-165),`recog`=配方 id,无 body。
- 应答:`ui.lua` 行 2535:`recog==1` → "学习成功"并刷新面板(tab 重发 4640);其他 → "学习失败"。
- 服务端要点:成功应答后**必须把该配方状态改为 1 并重推状态数据**(客户端刷新即重查 4640),失败码语义客户端不区分。

### CM_CAN_MAKEDRUG_QUERY(4641)/SM_CAN_MAKEDRUG(4641)——开始炼制(同号回执)

- 上行:状态=1(未炼制)页点"炼制"(panel 行 293-297),本地先校验 `背包材料数 ≥ cfg.input` 与 `金币 ≥ price×次数`,通过后发:`recog`=配方 id,`param`=炼制次数(cnt),无 body。
- 应答:`ui.lua` 行 2513:
  - param=0 → "开始炼制",客户端 refresh(重发 4640 拉新状态);
  - param=1 → "材料不足";
  - param=2 → "金币不足"。
- 服务端要点:**客户端只是乐观 UI,是否真扣材料/金币以服务端校验为准**;开始成功后应把状态置 2(炼制中),之后客户端通过 4640 查询拿到 TMixingDrugDuring 倒计时。若服务端不置状态 2,客户端 refresh 后仍停在"未炼制"页可无限重复提交——需服务端按实际扣材料。

### CM_GAIN_MAKEDDRUG(4642)/SM_GAIN_MAKEDDRUG(4642)——领取成品(同号回执,注意常量名双D笔误)

- 上行:状态=3(已完成)页两个按钮(panel 行 392/402):`recog`=配方 id,`param`=0 存仓库 / 1 直接入背包;无 body。
- 应答:`ui.lua` 行 2525:param==1 → "存放成功"并 refresh;其他 → "存放失败"。
- 服务端要点:领取成功后成品/失败产物经通用物品消息族入包(见 M5-S1),并把状态复位(1=未炼制,可再次炼制);`SM_GAIN_MAKEDDRUG` 只作结果提示,不携带物品数据。

### 面板交互时序(服务端视角)

```
服务端推 SM_SEND_MAKEDDRUG_CONFIG(4645)          → 客户端缓存配方
服务端推 SM_ALL_MAKEDRUG_STATUS(4639)             → 客户端弹面板
玩家切 tab → CM_MAKEDRUG_STATUS_QUERY(4640,recog=id)
服务端回 SM_MAKEDRUG_STATUS(4640,tag=状态,body=…+LevelInfo)
玩家学习 → CM_LEARN_LIVINGSKILL(4643) → 回 SM_LEARN_LIVINGSKILL(recog=1)
玩家炼制 → CM_CAN_MAKEDRUG_QUERY(4641,param=次数) → 回 SM_CAN_MAKEDRUG(param=0/1/2)
客户端 refresh → 重发 4640 → tag=2 倒计时(本地每秒-1,归零自动 refresh)
倒计时结束(服务端完成)→ 客户端 refresh → 4640 → tag=3 + 成品 TClientItem 列表
玩家领取 → CM_GAIN_MAKEDDRUG(4642,param=0/1) → 回 SM_GAIN_MAKEDDRUG(param=1) + 通用物品入包
```

### 补充细节

- **老版 FAIL 错误码补全**:`SM_MAKEDRUG_FAIL(714)` 的 `recog=2` 为"合成成功,获取物品失败"(ui.lua 行 855-866 三分支:2/3/4),即合成已扣料但入包失败——服务端应保证此态必发通用物品增量。
- **仓库路径的入仓通道**:领取 param=0(存仓库)成功后,仓库数据经 **SM_STORAGE_ADDITEM(717)** 增量表达(推断:客户端只消费通用增量,该消息正是为外部系统直投仓库设计,见 [M5-S3 仓库](M5-S3-仓库.md))。
- **熟练度无独立推送**:lv/curExp/maxExp 只随 4640 应答下发,升级事件没有专用消息——服务端在等级变化后等客户端下一次查询即可。
- **SP 特殊配药族(未接入)**:`CM_QUERY_SP_MAKEDRUG(3043)/CM_START_SP_MAKEDRUG(3044)/CM_GETBACK_SP_MAKEDRUG(3045)` 与 `SM_QUERY_SP_MAKEDRUG(1520)/SM_START_SP_MAKEDRUG(1521)/SM_GETBACK_SP_MAKEDRUG(1522)` 定义存在但全树无 send/分支,服务端无需实现。

## 服务端实现要点

1. **面板不可主动打开**:没有上行请求消息;只有 SM_ALL_MAKEDRUG_STATUS 能弹面板。重写服务端时若要做"玩家点击打开配药面板",需要扩展协议(本树不支持)。
2. **状态机一致性**:0 未学习 →(4643)→ 1 未炼制 →(4641)→ 2 炼制中 →(时间到)→ 3 已完成 →(4642)→ 1。每个 CM 都要有同号回执,否则面板停留在乐观状态。**4640 应答的 tag 必须与 4639 状态表的 state 一致**,否则页签文案与详情页错位。
3. **body 顺序敏感**:4640 应答的 body 是「状态数据 + LevelInfo 尾部」固定顺序;tag=3 时 TClientItem 条数由 param 给出;LevelInfo 12B 含 2 字节对齐填充,解析时别漏。
4. 时长单位为**秒**(int),面板按分钟展示并本地倒计时;服务端应保证 4640 返回的 time 与真实剩余时间一致,客户端到点后自动重查。炼制计时权威在服务端。
5. 领取去向由 param 区分(0 仓库/1 背包);成功后物品经 M5 通用消息下发(背包 SM_ADDITEM / 仓库 SM_STORAGE_ADDITEM),不要依赖本消息携带物品。**仓库满要回失败(param≠1)并把成品保留在"已完成"态供再次领取**。
6. 老版 NPC 通道(712/1034/714)与新面板(4639-4645)并存,互不调用;重写时两者都要实现(老版细节见 M6-S2)。
7. 学习失败客户端不区分原因(一律"学习失败");需要细文案时另发 SM_SYSMESSAGE 族。
