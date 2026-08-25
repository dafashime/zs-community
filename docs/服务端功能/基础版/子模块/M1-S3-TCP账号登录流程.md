# M1-S3 TCP账号登录流程

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md)

## 功能概述

HTTP 阶段拿到 `ticket` 后(`scene:loginEnd`),login 场景发起 **两段先后建立的 TCP 连接**完成"选区 + 账号鉴权":

- **连接①(首连,dataIndex=areaID)**:到 `/account` 列表条目 `zoneip` 指向的登录/选区网关,完成 cmd=24 握手后接收 `SM_SERVER_LIST(4001)`,回 `CM_SELECT_SERVER(4002)` 选区组,收 `SM_SELECT_SERVER(4002)` 取得游戏侧网关 ip/port/sessionID;
- **连接②(dataIndex=sessionID)**:到 SM_SELECT_SERVER 给出的 ip:port 重新握手,接收 `SM_LOGIN(4003)` → 回 `CM_LOGIN_AUTH(4004)` 提交 ticket → 收 `SM_LOGIN_AUTH(4004,param=1)` 取回登录结果与 reconnectID → 服务端推 `SM_CHR_LIST(4010)`(缓存)→ `SM_LOGIN_ALREADY_ONLINE(4041)`(顶号询问或直接放行)→ 开门动画进 select 场景。

期间穿插排队(SM_LOGIN_QUEUE)、密保(SM_REQUIRE_MIBAO)、图形验证码(SM_NEED_VALIDATE_IMAGE)、维护(SM_SELCHR_ERR)等分支。本篇覆盖 login 场景 `processMsg` 的**全部分支**(mir2.scenes.login.scene.lua 行 187-429)。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.scenes.login.scene.lua` | `connectServer`(行 45-64,TCP 入口与 ip:port 拆分)、`processMsg` 全分支、`loginEnd`(行 431-442)、断线弹窗 |
| `mir2/mir2.data.login.lua` | `setGroupList`(SM_SERVER_LIST body 解析,行 82-92)、`setQueueData`(行 106-116)、recIP/recPort/recSession/serverMsg/loginRet1/2/roleInfo 存储 |
| `mir2/mir2.def.globa2.lua` | TServerGroupInfo/TSelectServerMsg/TSelectServerMsg2/TLoginIdResult/TLoginIdResult2 记录定义(尺寸算式见下) |
| `mir2/mir2.scenes.login.door.lua` | 进入选人前的开门动画;结束 `net.remove(scene)`+切 select,无协议 |
| `mir2/mir2.single.net.lua` | `net.match` 发送白名单(select 阶段门控,M2 已述)、`net.send` strs 编码 |

## 报文总览

| 消息/接口 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| SM_SERVER_LIST | 4001 | S→C | 连接①握手后服务端主动下发 | param=组数,body=N×TServerGroupInfo |
| CM_SELECT_SERVER | 4002 | C→S | 解析完区组列表后自动回复 | strs=所选组名 |
| SM_SELECT_SERVER | 4002 | S→C | 区组选择结果 | 成功则发起连接② |
| SM_LOGIN | 4003 | S→C | 连接②握手后服务端主动下发 | 客户端只认"该发 CM_LOGIN_AUTH 了" |
| CM_LOGIN_AUTH | 4004 | C→S | 收到 SM_LOGIN 立即回复 | strs=ticket/""/gameType/mac |
| SM_LOGIN_AUTH | 4004 | S→C | ticket 校验结果 | param=0/1/2 三类分支 |
| SM_CHR_LIST | 4010 | S→C | 鉴权通过后推送角色列表 | 本场景仅缓存 |
| SM_LOGIN_ALREADY_ONLINE | 4041 | S→C | 顶号询问(recog=1)或放行信号(recog=0) | |
| CM_LOGIN_ALREADY_ONLINE | 4041 | C→S | 仅回应 recog=1 询问:param=1 强登/0 取消 | |
| SM_LOGIN_QUEUE | 4332 | S→C | 服务器爆满排队 | param/tag/series=位次/数量/秒 |
| SM_REQUIRE_MIBAO | 4020 | S→C | 要求密保验证 | 转交 g_data.security(M10-S2) |
| SM_NEED_VALIDATE_IMAGE / CM_SUBMIT_VALIDATE_IMAGE | 4027 | 双向 | 图形验证码挑战/提交 | buf=图片原始数据 |
| SM_SELCHR_ERR | 4042 | S→C | 服务器维护中 | 弹窗无跳转(login 场景) |
| SM_SDOA_AUTH_NOTIFY_RESULT / _ERROR | 4008 / 4009 | S→C | sdoa 通知 | login 场景空处理 |
| CM_IDPASSWORD | 2001 | — | **从不发送**(见文末专节) | |

## 时序总览

```text
login 场景(loginEnd 存好 ticket)
│
│ net.connect(zoneip拆出的ip, port, self, nil, def.areaID)   ← 连接① dataIndex=areaID
│ ── cmd=24 握手(M1-S2)
│◄─── SM_SERVER_LIST(4001) param=N [N×TServerGroupInfo]
│──── CM_SELECT_SERVER(4002) {组名}                (recog=-1,param=1,tag=useIGW=1)
│◄─── SM_SELECT_SERVER(4002)
│      ├─ recog==0: series=2满员/3维护/4配置不一致 → 弹窗停留
│      └─ 成功: recIP/recPort/recSession ← recog=sessionID
│         net.connect(ip, port, self, sessionID)             ← 连接② dataIndex=sessionid
│ ── cmd=24 握手
│◄─── SM_LOGIN(4003)
│──── CM_LOGIN_AUTH(4004) {ticket,"",gametea,mobile-mac-address}
│◄─── SM_LOGIN_AUTH(4004)
│      ├─ param=1: TLoginIdResult(42B)/TLoginIdResult2(87B) → 存 reconnectID
│      ├─ param=2: 忽略(继续等后续包)
│      └─ 其他 : buf 文案 或 recog=-1..-5 错误弹窗
│◄─── SM_REQUIRE_MIBAO(4020)?   → security 流程
│◄─── SM_NEED_VALIDATE_IMAGE(4027)? → CM_SUBMIT_VALIDATE_IMAGE(4027)
│◄─── SM_LOGIN_QUEUE(4332)?     → 排队数值缓存(select 场景显示)
│◄─── SM_CHR_LIST(4010)          → 仅缓存 roleInfo
│◄─── SM_LOGIN_ALREADY_ONLINE(4041)
│      ├─ recog=1: "是否强行登录?" → CM_LOGIN_ALREADY_ONLINE param=1/0
│      │            强登且 roleInfo.msg.recog==1 → 开门动画
│      └─ recog≠1: 直接开门动画
│ 开门动画(door) → select 场景(M2-S2 接手)
```

## 详细报文说明

### 1. SM_SERVER_LIST(4001) —— 区组列表下发

- **时机**:连接①握手完成后由服务端主动下发(客户端被动等待,**不发它玩家就停在连接完成状态**)。
- **字段**:`msg.param = 组数 N`;解析入口 `g_data.login:setGroupList(msg,buf,bufLen)`(data.login.lua:82-92):
  - `param > 0` 才解析;
  - **`assert(msg.series ~= 1, "sdoa登录方式已淘汰!")`——series=1 会直接抛错**,服务端必须保证 series≠1;
- **body 布局**:N 条连续 `TServerGroupInfo`(非 packed,单条 **40 字节**):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | char*15(16B) | groupName | 区组名,GBK,补 0x00(readChars 按 16B 截取后 a2u) |
| 16 | char*23(24B) | groupDesc | 区组描述,GBK |

- **应答**:客户端取 `groupIndex`(默认 1)对应组的 `groupName`,立即发 CM_SELECT_SERVER。

### 2. CM_SELECT_SERVER(4002) —— 选择区组

- **字段**(`login.scene.lua :: processMsg` 行 207-215):

| 字段 | 值 | 说明 |
|---|---|---|
| recog | -1 | 固定 |
| param | 1 | 固定 |
| tag | `def.useIGW` = 1(def.init.lua:20) | 是否使用 IGW 网关 |
| series | 0 | 固定 |
| strs | `{groupName}` | body = `0x00` 前导 + GBK 组名(BRIEF §4 编码) |

### 3. SM_SELECT_SERVER(4002) —— 选区结果(两段连接的枢纽)

- **失败分支**(`msg.recog == 0`,行 217-228):按 `series` 弹文案——2="你选择的服务器满员"、3="你选择的服务器正在维护中"、4="配置的区组ID或服务器名字不一致";其余 series 无文案。客户端解除遮罩,停留在选区界面。
- **成功分支**(行 229-249),TDefaultMessage 四个字段的复用:

| 字段 | 含义 | 还原方式 |
|---|---|---|
| recog | sessionID(会话票据) | 直取;存 `g_data.login.recSession` |
| param | 端口(int16 承载,**端口 >32767 无法表达**) | 直取;存 `recPort` |
| tag\|series | 32 位 IP 整数 | `MakeLong(tag,series)=tag|(series<<16)`,再 `int2ip` 按**小端**写出 4 字节 a.b.c.d(an.funcs.lua:124-133);即 tag=低 16 位(IP 第 1、2 段),series=高 16 位(第 3、4 段) |

- **body 布局**:先解 `TSelectServerMsg`(非 packed,**20 字节**);剩余 ≥ `TSelectServerMsg2` 尺寸(**36 字节**)时追加解析(serverName 为新协议扩展):

TSelectServerMsg(20B):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | int32 | areaID | 大区 ID |
| 4 | int32 | groupID | 区组 ID |
| 8 | byte×4 | sdoa/other1/other2/other3 | 标志位(sdoa 应为 0) |
| 12 | char*7(8B) | suffix | 后缀串,GBK |

TSelectServerMsg2(36B)= 上述 20B(oldMsg)+ `char*15`(16B)`serverName`。

- **客户端后续动作**:存 `recIP/recPort/recSession/serverMsg(/serverMsg2)`,`scheduler.performWithDelayGlobal(…,0)` 发起**连接②**:`net.connect(ip, port, self, sessionID)`——第 4 参是 sessionid,故连接②握手帧 dataIndex=**sessionid**(与连接①的 areaID 语义差异,主模块专节)。

### 4. SM_LOGIN(4003) —— 鉴权邀请

- 连接②握手后服务端下发;客户端不读任何字段(param==1 有分支但为空操作,行 279-281),唯一动作是回 CM_LOGIN_AUTH。
- 注意同一消息在 notice/reconnect/main/select 场景的语义完全不同(回 CM_RECONNECT,M1-S4)。服务端必须清楚:**SM_LOGIN 是"要求鉴权",在哪个场景收到决定客户端回哪种消息**——重连场景收到它时客户端没有有效 ticket 可用,只有 reconnectID。

### 5. CM_LOGIN_AUTH(4004) —— ticket 鉴权上行

- **字段**(行 267-277):

| 字段 | 值 | 说明 |
|---|---|---|
| recog | `def.MIR_VERSION_NUMBER` = **131532307**(def.init.lua:22) | 客户端版本号 |
| param | `net.platformCode()` = **2** | 平台码 |
| strs | `{ticket, "", def.gameType, "mobile-mac-address"}` | 4 段字符串 |

body 布局(`net.send` strs 编码:每段 u2a→GBK,段间 1 字节 0x00 分隔,整体前再加 1 字节 0x00):

| 偏移 | 内容 | 说明 |
|---|---|---|
| 0 | 0x00 | 前导占位 |
| 1..L₁ | ticket(GBK) | HTTP /account 返回的 ticket 原文 |
| … | 0x00 | 分隔(第 2 段是空串,只贡献分隔字节) |
| … | `def.gameType`= `"gametea"`(ASCII 即 GBK 兼容) | 渠道标识 |
| … | 0x00 分隔 + `"mobile-mac-address"` | 占位 MAC |

总长 `L = 1 + L₁ + 1 + 0 + 1 + 7 + 1 + 18`。
- **IOS_REVIEW 变体**(行 251-266):strs 变为 `{crypto.md5(uuid), "123456", gameType, "mobile-mac-address"}`——审核包特殊通道,常规服务端可不实现但应容忍。

### 6. SM_LOGIN_AUTH(4004) —— 鉴权结果(param 三分支)

- **`param == 2`**(行 284-285):空操作——中间态通知,客户端继续等后续帧。
- **`param == 1`**(行 286-304):成功携带登录身份结果。**用 body 长度判别记录版本**:

```lua
if ret1:size() < bufLen then   -- ret1:size() == 42
    -- 按 TLoginIdResult2(87B) 解码,reconnectID ← ret2.reconnectID
else
    -- 按 TLoginIdResult(42B) 解码(无 reconnectID)
end
```

TLoginIdResult(packed=true,**42 字节**):`ptID` char*20(21B)+ `digitID` char*20(21B);尺寸算式 `(20+1)+(20+1)`,packed 不对齐(globa2:168-180)。

TLoginIdResult2(packed=true,**87 字节**)(globa2:181-206):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | char*20(21B) | oldMsg | 兼容 v1 的 ptID 位 |
| 21 | char*20(21B) | serverName | 服务器名,GBK |
| 42 | int32 | areaID | 大区 ID |
| 46 | int32 | groupID | 区组 ID |
| 50 | string36(37B) | reconnectID | **首字节=长度 L**,后跟 L 字节(重连凭据,M1-S4) |

尺寸算式 `21+21+4+4+(36+1)=87`(char*/string 均 N+1,BRIEF §6)。判别式意味着:**v1 必须恰好 42 字节,v2 必须 >42 字节(实际 87)**;发 43~86 的畸形长度会被当 v2 解码失败(record decode faild 报错,reconnectID 为空)。

- 客户端动作:v2 时 `g_data.reconnctID = reconnectID`(**后续所有 CM_RECONNECT 的唯一来源**);`cache.saveAccount(ac,pw)` 明文落盘记住密码;隐藏登录输入层。v1 时无 reconnectID 更新——此后若走重连流程,`CM_RECONNECT` 的 strs 为 nil(无 body),(服务端何时发 v1 未核实;保守做法是永远发 v2)。
- **其他(param=0 等,行 306-334)错误分支**:buf 非空 → 直接弹 `net.str(buf)` 的 GBK 文本(自定义错误文案通道);否则按 recog:

| recog | 文案 |
|---|---|
| -1 | "[失败]:认证失败" |
| -2 | "[失败]:认证超时,请重新登录" |
| -3 | "[失败]:系统错误" |
| -4 | "[失败]:系统繁忙,请稍后登录" |
| -5 | "[失败]:对不起,发生连接错误,请稍后登陆" |
| 其他 | "[失败]:登陆错误" |

同时解锁 submitting 状态、移除选区遮罩,允许重新提交。

### 7. SM_CHR_LIST(4010) —— 角色列表(仅缓存)

- login 场景把 `{msg, buf, bufLen}` 原样存入 `g_data.login.roleInfo`(行 335-340),**不渲染**;真正消费在 select 场景(`g_data.select:receiveChrs`,归 M2-S2)。
- 缓存的 msg.recog 在顶号强登分支被再次检查(`roleInfo.msg.recog == 1` 才开门,行 398)——即服务端应以 `recog=1` 表示"列表有效"(M2-S2 同结论)。
- **顺序敏感**:必须在 SM_LOGIN_ALREADY_ONLINE(recog=1)之前到达,否则强登点击时 `roleInfo.msg` 为 nil 直接脚本报错(按当前源码推断,(未核实旧版本行为))。

### 8. SM_LOGIN_ALREADY_ONLINE(4041) —— 顶号询问/放行

- **`recog == 1`(账号在线,行 394-413)**:弹"此账号目前在线,是否强行登录?"
  - 确定(idx=1):若 `roleInfo.msg.recog==1` → 显示 door 层并 `receiveChrs(roleInfo)`(直接进选人);
  - 取消(idx=0):仅移除遮罩,留在登录层;
  - **两条路径都会回发 `CM_LOGIN_ALREADY_ONLINE(4041)`,param = 1(强登)/ 0(取消)**,无 body。
- **`recog ~= 1`(通常 0,行 414-417)**:直接开门进选人,**客户端不回任何包**——这是"免询问放行"信号。

### 9. SM_LOGIN_QUEUE(4332) —— 排队

- `g_data.login:setQueueData(msg)`(data.login.lua:106-116):`pos=msg.param`(当前位次)、`cnt=msg.tag`(数量,**UI 从未显示**)、`sec=msg.series`(预计等待秒数)。
- 展示在进入 select 场景之后(`select.scene :: onEnterTransitionFinish` 读 queue 弹框:"您排在第 pos 位"、"预计等待 sec 秒/分钟",sec==0 显示"正在估算...",select.scene.lua:805-841);取消按钮发 `CM_SELCHR_EXIT(4039)`。
- 服务端可重复发送更新数值(setQueueData 幂等覆盖);`msg=nil` 调用可清除(客户端内部使用)。

### 10. SM_NEED_VALIDATE_IMAGE(4027) / CM_SUBMIT_VALIDATE_IMAGE(4027) —— 图形验证码

- **下行**:buf=图片原始数据,`ycFunction:makeTexWithRawData(buf, msg.tag, msg.series, bufLen)` 生成纹理——tag/series 疑似宽高((未核实具体语义));`param > 0` 时额外出现"换一张"按钮(行 349-393)。
- **上行**:确定 → `CM_SUBMIT_VALIDATE_IMAGE(4027)`,strs={用户输入};换一张 → 同消息号 `param=1` 无 body;取消 → `os.exit(1)` 直接退出游戏。

### 11. 其余分支

| 消息 | 行为(login.scene) |
|---|---|
| SM_REQUIRE_MIBAO(4020) | `g_data.security:setLoginBit(msg,buf,bufLen)`——密保验证流程,细节归 M10-S2/M2-S2 |
| SM_SDOA_AUTH_NOTIFY_RESULT(4008) / _ERROR(4009) | 空处理(行 341-344) |
| SM_OUTOFCONNECTION(4018) | **无分支**——落入 `return false`,仅 DEBUG 日志 "unprocessed"(对比:select 场景会弹重连框) |
| SM_OUTOFCONNECTION_KICKOUT(4040) | **无分支**(同上;踢下线文案只在 notice/reconnect/select/main 场景生效) |
| SM_SELCHR_ERR(4042) | 弹"服务器维护中,请稍后再试",确定后**停留原地**(不跳转;对比 notice/reconnect/main 会回登录) |
| ident=11706(硬编码) | login 场景无此分支;main 场景"重连失败,请重新登陆"(M1-S4) |

### CM_IDPASSWORD(2001)在哪发?——从不发送

任务常见假设"TCP 登录先发 CM_IDPASSWORD(account/password)"在本客户端**不成立**,代码事实:

- `CM_IDPASSWORD = 2001` 仅存在于常量表(globa1:682),据 `工作底稿（未随仓库分发）/usage.json` 全工程零引用;`SM_PASSWD_FAIL(503)` 同样无处理点,且**不存在 SM_PASSWD_OK 常量**。
- 凭据验证链 = HTTP `GET /account?id=&psw=`(明文,M1-S1)取得 ticket → TCP `CM_LOGIN_AUTH(4004,strs[1]=ticket)`。**账号密码从不过 TCP**。
- **职责划分**:凭据验证只发生在 login 场景(HTTP 阶段 + 连接②的 CM_LOGIN_AUTH);select 场景 ctor 起 `net.setMatchMode(true)` 开启发送白名单(仅 CM_SELCHR/CM_DELCHR/CM_QUERYDELCHR/CM_SELCHR_EXIT/CM_NEWCHR/CM_RECOVERCHR/CM_SUBMIT_MIBAO/CM_RECONNECT/CM_LOGIN_ALREADY_ONLINE 九种,net.lua:267-269),凭据类消息在选人阶段物理上不可能发出。跳转链:login(凭据+选区)→ door 动画 → select(角色管理,M2)。

## 服务端实现要点

1. **两段连接都要完整握手**(M1-S2),且连接②握手 dataIndex 必须等于 SM_SELECT_SERVER.recog 签发的 sessionID——这是服务端把"选区结果"和"登录会话"对上的唯一钩子。
2. **卡死点(不回包后果)**:
   - 不发 SM_SERVER_LIST → 玩家停在"正在连接服务器"黑屏文案;
   - SM_SELECT_SERVER 不回或 recog=0 不带正确 series → 停在选区页;
   - 连接②后不发 SM_LOGIN → 玩家已连上但永不提交 ticket;
   - SM_LOGIN_AUTH 不回 param=1 → 登录层不隐藏,无法进选人;
   - 不发 SM_CHR_LIST → roleInfo 为空,后续 ALREADY_ONLINE 强登分支直接 Lua 报错;
   - 不发 SM_LOGIN_ALREADY_ONLINE(recog≠1)→ 永远停在 login 场景。
3. **记录尺寸必须精确**:SM_SERVER_LIST 的 N×40B;SM_SELECT_SERVER 的 20B(+可选 16B 尾巴凑成 36B 结构);SM_LOGIN_AUTH 只允许 42B(v1)或 87B(v2)两种 body 长度。全部 GBK、小端、char*/string 按 N+1。
4. **端口 16 位限制**:SM_SELECT_SERVER.param 是 int16,监听端口需 ≤32767,否则被截断。
5. **IP 打包公式**:服务端把点分 IPv4 的 4 段 `a.b.c.d` 打包为 `tag = a|(b<<8)`,`series = c|(d<<8)`(客户端 `MakeLong(tag,series)=tag|(series<<16)` 后按小端还原)。
6. **错误文案双通道**:SM_LOGIN_AUTH 失败时优先读 buf 全文(GBK 自定义文案),buf 空才落到 recog=-1..-5 固定文案;想给玩家精确原因就走 buf。
7. **顶号互踢协议**:询问(recog=1)必须等客户端 CM_LOGIN_ALREADY_ONLINE(param=1/0)再决定顶掉谁;放行信号用 recog=0 且**不要期待回包**。
