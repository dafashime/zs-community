# M8-S2 摆摊stall

> 所属主模块:[M8-经济交易系统](../主模块/M8-经济交易系统.md)

## 功能概述

玩家在城内指定区域开设限时摊位(4 档等级 = 5/10/15/20 格,按时长支付金币),上架物品(金币价或元宝价)后开摊;其他玩家点击地图上的摊位实体浏览并购买,还可给摊主留言(留言经邮件系统送达,见 M10-S1)。

分两侧:**自己摊位**(`panel.stall` + `data.stall`)与**他人摊位**(`panel.stallOther` + `data.stallOther`,后者是前者的克隆扩展)。同一消息号按 CM 发出、SM 应答(同值双向)。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.main.console.btnCallbacks.lua :: handle_panel`(key=="stall") | 主界面"摆摊"按钮:发 CM_QUERY_STALL(body=自己摊位 ID,初始为 0) |
| `mir2/mir2.scenes.main.console.controller.lua :: 触地回调`(行 368~399)/`mir2/mir2.scenes.main.pc.operate.lua`(行 532~563) | 点击地图摊位实体:发 CM_QUERY_STALL(body=该摊位 ID) |
| `mir2/mir2.scenes.main.panel.stall.lua` | 自己摊位面板:选档(showChoosePanel)、改名、上下架、开/停摊 |
| `mir2/mir2.scenes.main.panel.stallOther.lua` | 浏览他人摊位:购买(showBuyPanel)、留言 |
| `mir2/mir2.data.stall.lua` | 自己摊位数据:set(msg,buf,bufLen) 整体解析;uptAddItem/uptDelItem 增量更新 |
| `mir2/mir2.data.stallOther.lua` | 他人摊位数据:uptDelItem(msg) 按 recog 减数量 |
| `mir2/mir2.scenes.main.role.stall.lua` + `mir2.scenes.main.map.map.lua :: showEvent`(ET_STALL_EVENT 分支) | 地图摊位实体(NPC 形象+摊名),来自 SM_SHOWEVENT 推送 |
| `mir2/mir2.scenes.main.ui.lua :: processMsg`(行 2020~2147) | 全部 SM 的分发与错误码提示 |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_QUERY_STALL | 4418 | C→S | 点"摆摊"按钮或点他人摊位实体 | body=ID(double):自己摊位 id 或目标摊位 id;首次为 0(推断服务端把 0 当"查自己") |
| SM_QUERY_STALL | 4418 | S→C | 上项应答 | recog/tag 组合区分结果,body=TStallHeadInfo+… |
| CM_SET_STALL_TIMELV | 4419 | C→S | 选档确认 / 格子满时升级确认 | tag=目标等级,param=时长(小时/allTm) |
| SM_SET_STALL_TIMELV | 4419 | S→C | 应答 | recog=1 成功;-1 金币不足;-2 时间超上限;-3 等级超上限 |
| CM_SET_STALL_NAME | 4420 | C→S | 编辑摊名点确认 | body=GBK 名字串 |
| SM_SET_STALL_NAME | 4420 | S→C | 应答 | recog=1/-1 过长/-2 不合法/-3 摆摊中禁改 |
| CM_ADD_STALLITEM | 4421 | C→S | 出售设置框确认 | recog=MakeIndex,tag=币种,param=数量,body=int 价格 |
| SM_ADD_STALLITEM | 4421 | S→C | 仅失败应答 | recog=-1~-5;成功改推 SM_UPT_ADD_STALLITEM |
| CM_DEL_STALLITEM | 4422 | C→S | 点击已上架物品取回 | recog=MakeIndex |
| SM_DEL_STALLITEM | 4422 | S→C | 失败应答 | recog=-1 物品已售出;成功走 SM_UPT_DEL_STALLITEM |
| CM_CANCEL_STALL | 4423 | C→S | (本构建不发送) | 客户端无收摊按钮入口 |
| SM_CANCEL_STALL | 4423 | S→C | 服务端主动:到期/异常终止 | recog=-1 摊不存在或已过期;-2 包裹满,物品转邮件 |
| CM_START_STALL | 4424 | C→S | 点"开摆"(已有物品且未开摊) | 无参无 body |
| SM_START_STALL | 4424 | S→C | 应答 | recog=1 成功;-1~-9 九种失败(见详表) |
| CM_PAUSE_STALL | 4425 | C→S | 点"暂停"(state==1 时) | 无参无 body |
| SM_PAUSE_STALL | 4425 | S→C | 应答 | recog=1 暂停成功(state→2);无错误分支 |
| CM_BUY_STALLITEM | 4426 | C→S | 购买确认框确定 | recog=MakeIndex,series=数量,body=摊主 ID(double) |
| SM_BUY_STALLITEM | 4426 | S→C | 失败应答 | recog=-1~-7;成功经正常发货推送(M5)+SM_UPT_OTHER_DEL_STALLITEM |
| SM_UPT_ADD_STALLITEM | 4428 | S→C | 自己摊位新增一格 | body=TStallBodyInfo+TClientItem |
| SM_UPT_DEL_STALLITEM | 4427 | S→C | 自己摊位移除一格 | recog=MakeIndex |
| SM_UPT_OTHER_DEL_STALLITEM | 4429 | S→C | 他人摊位格子售出/减少 | recog=MakeIndex,param=剩余数量(0=移除) |
| CM_MESSAGE_STALL | 4467 | C→S | 买家写留言确认(≤25 个 UTF-8 字符) | body=TStallMsg(64B) |
| SM_MESSAGE_STALL | 4467 | S→C | 应答 | recog=1 成功/-1 失败 |
| CM_QUERY_STALL_STATUS | 4481 | C→S | (定义未发送) | 无客户端调用点 |
| SM_QUERY_STALL_STATUS | 4481 | S→C | 服务端主动推剩余时间 | recog=剩余秒数 |

另:摊位地图实体的出现/消失由通用事件报文承载:`SM_SHOWEVENT(804)`(param=41=`ET_STALL_EVENT`,body=TEventMessage2)/`SM_HIDEEVENT(805)`(recog=事件 serverID)。机制归 [M3-S2],此处只展开摊位分支。

## 详细报文说明

### 查询摊位:CM_QUERY_STALL(4418)

- 时机 1(`btnCallbacks.handle_panel`,key=="stall"):若正浏览他人摊位(stallOther 面板开着),先关它并发包**回到自己的摊位**(body 用 `g_data.stall.id`);若自己面板开着仅关闭;否则发查询打开自己摊位。
- 时机 2(`console.controller.lua` / `pc.operate.lua`):点击目标类型为 "stall"(map.stalls 中的摊位实体)时,若当前无摊位面板则发包,body 用被点摊位实体的 `id`。
- body:`net.send({CM_QUERY_STALL}, nil, { {"ID", id} })`

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | double | ID | 摊位 id(8B 小端 IEEE754 承载的整数 id) |
| 8 | byte | 0x00 | net.send 收尾占位字节(dataLen=9) |

### 查询应答:SM_QUERY_STALL(4418)

`mir2.scenes.main.ui.lua :: processMsg` 按 recog/tag 分支:

| recog | tag | 含义 | body |
|---|---|---|---|
| 1 | 0 | 自己的摊位 → 打开 panel.stall | 全量摊位数据 |
| 1 | >0 | 他人的摊位 → 打开 panel.stallOther | 同上 |
| -1 | 1 | 查询摊位失败(目标没摆摊) | 无 |
| -2 | 0 | 有摊位物品未处理,先到邮件领取再摆摊 | 无 |
| -3 | 0 | 服务器错误 | 无 |

成功时 body 由三段顺序拼接(`mir2.data.stall.lua :: set`):

**① TStallHeadInfo(88 字节,非 packed,含对齐填充)**

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | ID/double | id | 摊位 id(回填 g_data.stall.id) |
| 8 | string(14) | player | 摊主角色名(首字节长度 L,L≤14,占 15B) |
| 23 | string(30) | name | 摊位名/广告语(占 31B) |
| 54 | int | level | 摊位等级 1~4(格子数 = level×5) |
| 60 | int | state | 0=未开 1=营业中 2=暂停 |
| 64 | int | allTm | 购买总时长(小时) |
| 68 | int | time | 剩余秒数(>0 时客户端启动本地倒计时) |
| 72 | double | startTm | 开始时间((未核实)语义为 Delphi TDateTime) |
| 80 | int | msgCnt | 未读买家留言条数(UI 提示去邮件查看) |
| 84 | int | cnt | 后续物品格数 N |

(对齐说明:string 不参与对齐;int 在偶偏移处补齐至 4 的倍数,double 补齐至 8;总长向上取整至 8 的倍数 = 88。)

**② TStallBodyInfo × cnt(每条 16 字节)**

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | uint | makeIndex | 物品唯一索引 |
| 4 | int | cnt | 上架数量 |
| 8 | int | type | 币种:0=金币 1=元宝(panel.stall.addItem 渲染依据) |
| 12 | int | price | 单价 |

**③ TClientItem × cnt(变长,packed)**

- 结构同 [M8-S1 §对方放取物品]:makeIndex(uint)+Index/dura/duraMax/KeyValueSize(short×4)+_Reserved(uint)=16B 基础,后跟 KeyValueSize 个 TClientKeyValue(各 4B)。此处客户端用剩余 bufLen 连续解析,**扩展键值区会被读取**,必须按真实 KeyValueSize 编码。
- 解析顺序注意:先读完全部 cnt 条 TStallBodyInfo,再读全部 cnt 条 TClientItem(两个独立循环,`mir2.data.stall.lua :: set` 行 18~26)。

### 设置等级/时长:CM_SET_STALL_TIMELV(4419)/SM_SET_STALL_TIMELV(4419)

- 时机 A:初次选档面板"确定"(`panel.stall :: showChoosePanel`):本地校验等级≠0、时长≠0、持有金币 ≥ 单价表[2000,4000,7000,12000][level]×小时数,然后发包。字段:**tag=level(1~4),param=timeValue(1~12 小时)**。
- 时机 B:出售栏满时的升级确认框(`putInItem`):tag=level+1,param=`g_data.stall.allTm`(已购总小时数,非增量)。
- SM_SET_STALL_TIMELV 应答:

| recog | 客户端行为 |
|---|---|
| 1 | 成功:本地 setLevel/setAllTm,并默认摊名为"<玩家名>的摊位"(纯本地显示);重建格子 UI |
| -1 | 提示"金币不足!"(服务端此时也不应扣费) |
| -2 | 提示"设置摆摊的时间超过上限!" |
| -3 | 提示"设置摆摊的等级超过上限!" |

费用扣取完全由服务端掌握(客户端只做预估提示)。

### 改摊名:CM_SET_STALL_NAME(4420)/SM_SET_STALL_NAME(4420)

- 时机:摊位面板名称输入框旁按钮再次点击(提交态)。
- body:strs=`{名字}` → GBK 字节 + 收尾 0x00。
- SM 应答:recog=1"修改摊位名称成功."/-1"摊位名称过长!"/-2"摊位名称不合法!"/-3"摆摊中无法进行修改!"

### 上架:CM_ADD_STALLITEM(4421)/SM_ADD_STALLITEM(4421)

- 时机:`panel.stall :: showItemSetting` 确认。前置校验(客户端):绑定物品不可出售;数量 wN 为 1~999 整数(非堆叠物强制 1,堆叠物 ≤dura);金币单价 1~5000000,元宝单价 0.1~99999(wP 截断到 0.1 精度)。
- TDefaultMessage 字段:

| 字段 | 用法 |
|---|---|
| recog | int32,MakeIndex |
| tag | int16,币种:0=金币 1=元宝 |
| param | int16,出售数量 wN |

- body:`{ {"int", price} }` → **int32 单价(小端)+ 收尾 0x00,dataLen=5**。
  ⚠️ 元宝价格虽允许输入一位小数,但写入 int32 时小数被截断(如 10.5 → 线上 10);服务端按整数元宝处理即可,小数定价是否另有缩放(未核实),建议服务端只接受整数。
- SM_ADD_STALLITEM **只有失败分支**(成功不发本消息,改推 SM_UPT_ADD_STALLITEM):

| recog | 提示 |
|---|---|
| -1 | 增加物品失败! |
| -2 | 摊位不存在! |
| -3 | 物品不存在! |
| -4 | 输入的数量不正确! |
| -5 | 绑定的物品不可出售! |

### 上架成功推送:SM_UPT_ADD_STALLITEM(4428)

body 两段连续(`g_data.stall:uptAddItem`):

| 顺序 | 记录 | 尺寸 |
|---|---|---|
| 1 | TStallBodyInfo(makeIndex,cnt,type,price) | 16B |
| 2 | TClientItem(含扩展区,按 KeyValueSize 变长) | 16+KeyValueSize×4 B |

客户端把它放进第一个空格(容量 = level×5 内),返回 makeIndex 供面板渲染。

### 下架:CM_DEL_STALLITEM(4422)/SM_DEL_STALLITEM(4422)/SM_UPT_DEL_STALLITEM(4427)

- CM:recog=MakeIndex,无 body(`panel.stall :: getBackItem`)。
- SM_DEL_STALLITEM 失败:recog=-1"物品已售出!"。
- 成功:服务端向摊主发 SM_UPT_DEL_STALLITEM(recog=MakeIndex),客户端从 `g_data.stall.items` 移除并刷新;(推断)物品经正常物品入包流程返还(M5-S1),协议上无专用回包体。

### 开/停摊:CM_START_STALL(4424)/SM_START_STALL(4424)、CM_PAUSE_STALL(4425)/SM_PAUSE_STALL(4425)

- CM_START_STALL:无参无 body。前置:state≠1 且至少 1 件上架物品。
- SM_START_STALL recog 表(mir2.scenes.main.ui.lua 行 2092~2114):

| recog | 含义 |
|---|---|
| 1 | 摆摊成功 → state=1,本地按 allTm×3600 启动倒计时 |
| -1 | 已有摊位,不能重复摆摊 |
| -2 | 缺少摆摊材料 |
| -3 | 金币不足(开摊扣时长的时点,(未核实)也可能在 SET_TIMELV 已扣) |
| -4 | 创建摊位失败 |
| -5 | 该范围内有其他玩家 |
| -6 | 该范围不足以进行摆摊 |
| -7 | 摊位时间已结束 |
| -8 | 没有摆放物品售卖 |
| -9 | 边界城区外无法摆摊 |

- CM_PAUSE_STALL:state==1 时才可发,无参无 body;SM recog=1 → state=2("暂停摆摊成功.")。无错误分支。

### 收摊:SM_CANCEL_STALL(4423)(服务端主动)

本构建客户端没有发送 CM_CANCEL_STALL 的入口(常量保留)。服务端在摊位到期、玩家主动收摊(经由其他途径/(未核实))或异常终止时推送:

| recog | 客户端行为 |
|---|---|
| -1 | 仅调试日志(other 频道:"stall isn't exist or stall time is over") |
| -2 | 提示"您的包裹空间不足,请到邮件收回物品!"——即正常情况下摊位内滞留物品应转入邮件(M10-S1) |

### 购买:CM_BUY_STALLITEM(4426)/SM_BUY_STALLITEM(4426)

- 时机:`panel.stallOther :: showBuyPanel` 确认框。堆叠物可选数量 1~999(≤摊位格子上架剩余量),非堆叠固定 1;总价 = 单价×数量(展示用)。
- TDefaultMessage 字段:

| 字段 | 用法 |
|---|---|
| recog | int32,所购物品 MakeIndex |
| series | int16,购买数量 |
| param/tag | 0 |

- body:`{ {"ID", g_data.stallOther.id} }` → double 摊主(摊位)id 8B + 收尾 0x00,dataLen=9。
- SM 应答失败分支:

| recog | 提示 |
|---|---|
| -1 | 包裹空间不足! |
| -2 | 元宝不足! |
| -3 | 金币不足! |
| -4 | 已售完! |
| -5 | 摊位已取消或不存在! |
| -6 | 购买的物品数量超过出售数量! |
| -7 | 扣除元宝失败!(元宝单扣款失败专用) |

- 成功:买家侧走常规物品获得/货币扣减推送(SM_ADDITEM 族属 M5-S1,元宝变化经 SM_GETDIAMNUM_EXT 属 M8-S4);同时服务端向**所有正在浏览该摊位的玩家(含卖家自己)**发 SM_UPT_OTHER_DEL_STALLITEM(4429):recog=MakeIndex,param=剩余数量;param=0 时该格删除,>0 时同步 dura(堆叠数)(`mir2.data.stallOther.lua :: uptDelItem`)。

### 买家留言:CM_MESSAGE_STALL(4467)/SM_MESSAGE_STALL(4467)

- 时机:`panel.stallOther :: showStallPanel` 留言按钮,文本 UTF-8 长度须 1~25。
- body = `getRecord("TStallMsg", {id, msg})`(非 packed,64 字节):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | ID/double | id | 目标摊位 id |
| 8 | string(50) | msg | 留言内容(GBK,首字节长度 L,L≤50,占 51B) |
| 59 | — | 对齐填充 5B 至 64 | |

(线上再追加 net.send 收尾 0x00,dataLen=65。)

- SM:recog=1"留言成功."/ -1"留言失败!"。留言内容服务端转投邮件给摊主;摊主下次查询摊位时 head.msgCnt 显示未读条数。

### 摊位剩余时间推送:SM_QUERY_STALL_STATUS(4481)

- 服务端主动下发(登录恢复摊位、整点同步等时机由服务端定),recog=剩余秒数,无 body。客户端 `g_data.stall:setTime(msg.recog)` 重启本地倒计时。
- CM_QUERY_STALL_STATUS(4481) 定义存在但无调用点,服务端不必实现其请求处理。

### 地图摊位实体:SM_SHOWEVENT(804)/SM_HIDEEVENT(805) 的摊位分支

- 服务端开摊/收摊时对周边玩家下发 SM_SHOWEVENT:`recog`=事件 serverID,`param`=41(mapDef.ET_STALL_EVENT),`Loword(tag)`=tile x,`series`=tile y,body 选择 **TEventMessage2**(bufLen==64 时命中;若 bufLen==12 会按 TEventMessage 解析而丢失摊位信息):
  
| 偏移 | 类型 | 字段 | 摊位语义(role.stall.lua 取用) |
|---|---|---|---|
| 0 | short | ident | 事件标识 |
| 2 | short | msg | 摊位等级(1~4,决定 stallN.png 贴图) |
| 4 | uint | tickLapse | 剩余/经过 tick((未核实)) |
| 8 | string(14) | desc | 摊主角色名 |
| 23 | string(30) | name | 摊位名 |
| 56 | ID/double | id | 摊位 id(点击查询/购买/留言都用它) |

- 收摊/离场发 SM_HIDEEVENT:recog=事件 serverID,无 body。
- 通用事件机制的其余类型归 [M3-S2 对象感知与角色呈现]。

## 服务端实现要点(依客户端行为推断)

1. **摊位是持久会话**:state/time/allTm/id 都由服务端维护;掉线重连后客户端靠 CM_QUERY_STALL(id=0/自己 id)拉回完整状态,再靠 SM_QUERY_STALL_STATUS 校准倒计时。
2. **上下架采用"命令+广播"模型**:CM 只回失败;成功统一走 SM_UPT_ADD/DEL_STALLITEM 推给自己(以及可能的浏览者),购买则广播 SM_UPT_OTHER_DEL_STALLITEM。服务端需要按"谁在看这个摊"维护订阅关系。
3. **价格双币种**:type=0 扣买家金币(type=1 扣元宝),分别对应失败码 -3 与 -2/-7;扣款、发货、下架必须在一个事务里完成。
4. **格子数硬约束**:level×5(level≤4);上架超过容量、非空格重复占用都应拒绝(-1/-4)。
5. **滞留物品走邮件**:收摊/到期时若包裹放不下,转邮件并可用 SM_CANCEL_STALL(-2)提醒;这是客户端唯一的回收指引路径。
6. **摊名与留言都是玩家输入**:GBK 存储,长度校验(名字、留言 ≤50 字节线上限制)必须在服务端复核,防溢出与脏话过滤另计。
7. **范围规则**:开始摆摊的位置合法性(-5/-6/-9)完全由服务端判定;客户端不做任何预检。
