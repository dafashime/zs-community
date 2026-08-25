# M1-S2 TCP握手加密与心跳

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md)

## 功能概述

`mir2.single.net.lua` 是全部 TCP 交互的单一入口。本篇只覆盖**帧层**行为:连接建立后的一次性握手帧(cmd=24)、网关动态加密回执链(SM_RUNGATEDYN)、DEBUG 心跳(cmd=25),以及帧重组/断线事件——这些是每条连接的公共前缀,与具体业务消息无关。

公共帧格式(TClientMessage 12B 头、TDefaultMessage 12B、record 对齐规则)以系列目录 §一 为准,不在此重复。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.single.net.lua` | 全部本篇逻辑:`connect/close/handler/processLoop/processMsg/send/sendPing/newClientMsg/callback` |
| `frameworks/runtime-src/Classes/Mir2ByteStreamCompat.cpp` | `ycSocket:create(sign, cmd)` 本机字节流/套接字实现(权威);Lua 侧 `net.useLuasocket=false` 走 ODSocket 分支(net.lua:49-58) |
| `mir2/mir2.scenes.*.lua`(各场景) | 经 `net.add(self)` 注册,实现 `processMsg`(业务分发,M1-S3/S4)与 `socketEvent(data,status)`(断线事件,status=2 连接失败/3 断开) |
| `mir2/mir2.single.m2debug.lua` | DEBUG 构建安装的 5 秒心跳定时器(行 281-286) |
| `mir2/mir2.scenes.main.scene.lua` | ctor 中 DEBUG>0 时立即发一次心跳(行 51-54) |

## 报文总览

| 消息/接口 | 值/URL | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| 握手帧 cmd=`LM_GET_ENCRYPT` | 24(net.lua:15) | C→S | socket 连接成功事件(eventType==1)立即一次 | `willCode` 防重发;dataIndex=areaID 或 sessionID |
| 握手应答 cmd=24 下行 | 24 | S→C | (未核实服务端是否必发) | 客户端仅打日志 `"net.LM_GET_ENCRYPT"`,无任何消费(processLoop 行 180-181) |
| SM_RUNGATEDYN | 205(globa1:537) | S→C → C→S | 网关下发动态加密数据时 | 客户端把 ident+buf **原样回声**(net.handler 行 90-105) |
| 业务帧 cmd=`LM_DYN_ENCRYPT_CODE` | 23(net.lua:10) | 双向 | 握手后的所有业务消息 | 载荷=TDefaultMessage+body;dataIndex=自增序号 |
| 心跳 cmd=`LM_PING` | 25(net.lua:11) | C→S(下行回显可选) | 仅 DEBUG 构建:main 场景进场一次 + 每 5 秒 | 无 TDefaultMessage 无 body;下行 cmd=25 用于显示 ping 值 |

## 详细报文说明

### 1. 连接建立与握手帧(cmd=24,LM_GET_ENCRYPT)

- **时机**:底层回调 eventType==1(`CONNECTED`)→ `net.handler` 行 117-135:先把 `net.code = math.random(65535) + 1000`,然后若 `not net.willCode` 立即发送握手帧并置位(`willCode` 保证**每条连接只发一次**,`net.close()` 会复位)。
- **帧布局**(`getRecord("TClientMessage", {...})`,行 123-128):

| 偏移 | 类型 | 字段 | 值 |
|---|---|---|---|
| 0 | uint32 | sign | `0xFF44FF44`(4282711876) |
| 4 | uint8 | reservationByte | `net.platformCode()` = **2** |
| 5 | uint8 | cmd | **24** |
| 6 | int16 | dataLength | 0(record 默认) |
| 8 | uint32 | dataIndex | `net.dataIndex`:首连=**areaID**(`def.setGameServer` 的 `tonumber(area) or 0`),二连/重连=**sessionID**(见主模块专节) |

- **客户端后续动作**:发出后即认为连接可用,**不等任何应答**就允许业务消息出网(`net.send` 无状态检查)。此后所有业务消息由 `newClientMsg`(行 394-404)用 cmd=23 封装,dataIndex 换成自增 `net.code`(每发一条 +1)。
- **服务端下行 cmd=24 帧**:进入队列后 `processLoop` 只打一行日志 `"net.LM_GET_ENCRYPT"` 就丢弃(行 180-181),**不改变任何客户端状态**。即:对客户端而言握手是纯上行宣告;是否存在"真正的密钥交换应答",从 Lua 侧看答案是否定的——见下一条。

### 2. SM_RUNGATEDYN(205) —— 网关动态加密回执链

这是 Lua 层唯一可见的"加密相关"双向交互,也是任务关注点"cmd=24 只打日志,真正交换靠什么"的代码事实:

- **下行**:服务端以普通业务帧(cmd=23)发送 `TDefaultMessage{ident=SM_RUNGATEDYN(205), recog/param/tag/series}` + 任意长度 buf。该 ident 在 `net.handler`(eventType==0,行 90-105)被**内联拦截,不进场景队列**。
- **客户端立即回声**:重组一帧发回——
  - 外层:`TClientMessage{sign, cmd=23, dataLength = 12 + bufLen, dataIndex = 新的自增 net.code}`;
  - 内层:`TDefaultMessage{recog/ident/param/tag/series 五个字段原样复制}`;
  - 尾部:buf 二进制原样 `writeCString` 透传。
- **语义推断**:网关下发动态密钥/挑战数据,客户端回声确认收到。buf 内容格式、是否要求先完成此交换才放行其他 CM,**Lua 侧无任何阻塞或校验逻辑**(未核实服务端行为;旧 GateServer 为保护壳,无法直接对照)。

### 3. 心跳(cmd=25,LM_PING)

- **发送**:`net.sendPing`(行 254-261)构造 `TClientMessage{sign, cmd=25}`,**reservationByte/dataIndex/dataLength 全部保持 record 默认值(0)**——与握手帧填平台码/dataIndex 不同,勿混淆;无 TDefaultMessage、无 body。
- **发送时机(仅 DEBUG 构建)**:
  - main 场景 ctor:`if DEBUG > 0 then net.sendPing() …`(main.scene.lua:51-54),进场立即一次;
  - `m2debug.lua:281-286`:`scheduler.scheduleGlobal` 每 5 秒,`main_scene` 存在期间循环发送并刷新 `g_data.client.lastTime.ping`。
  - 非 DEBUG 构建完全不发(m2debug else 分支把 print/dump 置空)。
- **服务端回应**:任意 cmd=25 下行帧(通常原样回显即可)进入队列后,`processLoop` 行 182-187 计算 `RTT = (now − lastTime.ping)×1000` 并写到调试悬浮标签 `"ping值: Xms"`;若 `lastTime.ping` 不存在则静默丢弃。心跳仅服务于 DEBUG 显示,**不影响正常游戏逻辑**。

### 4. 帧重组与事件模型(服务端排障须知)

- **粘包/半包**:`net.callback`(行 549-604)维护本地缓冲,按 12B 头解析;sign 不匹配时**丢 1 字节重新同步**(行 591-594);载荷不足时整帧退回缓冲等待。服务端只需保证帧字节完整。
- **下行分派**:`net.handler(eventType==0)`:ident=205 内联回声;629(SM_ACT_GOOD)/630(SM_ACT_FAIL) 直通 `processMsg`;其余进队列,由 `processLoop` 每帧切片处理(单批 ≤30ms,行 192-194);`net.setWaitMsg(ident,…)` 可让队列只放行等待的消息(main 场景进场等 SM_NEWMAP 时使用)。
- **断线事件**:eventType:0=数据、1=已连接、2=连接失败、3=关闭(行 116-145);除 1 外都会广播给各注册对象的 `socketEvent(nil, status)`,status 2/3 触发重连弹窗(M1-S4)。`net.connect` 开头强制 `net.close()`(清 targets/code/willCode/waitMsg/buf/msgs)。

## 服务端实现要点

1. **握手帧必须容忍"无应答式"客户端**:客户端发完 cmd=24 立刻可能发业务 CM。若新服务端设计为"收到 cmd=24 → 回应答 → 放行业务",必须自行缓冲先到的业务帧;照抄"只打日志"的旧客户端行为不会出错,但**不要期待客户端消费 cmd=24 应答的内容**。
2. **动态加密的唯一约束是 SM_RUNGATEDYN 回执形状**:ident/recog/param/tag/series 原样返回 + buf 透传 + 新自增 dataIndex。若网关方案需要密钥协商,数据全部走这条链的 buf;(buf 具体算法未核实,Lua 侧无参与)。
3. **dataIndex 三种语义别混用**:握手帧=areaID 或 sessionID(按连接批次)、业务帧=自增序号、心跳帧=0。会话校验只能依赖握手帧的 dataIndex 与后续应用层字段(ticket/reconnectID),不能依赖业务帧 dataIndex。
4. **心跳可缺席**:正常(非 DEBUG)客户端不发心跳也无超时逻辑(Lua 侧未见,(原生层超时未核实));但服务端自己要处理死链清理,且必须容忍未知 cmd 帧类型(客户端同样只认 23/24/25,其余 `discard msg`)。
5. **卡死点**:本篇无强制等待型交互(客户端不因缺少 cmd=24 应答而停);真正的卡死点都在业务应答缺失(M1-S3/S4 各节标注)。
