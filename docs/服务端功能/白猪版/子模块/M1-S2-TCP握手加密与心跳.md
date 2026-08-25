# M1-S2 TCP握手加密与心跳

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md) · 基础版对照:[M1-S2 TCP握手加密与心跳](../../基础版/子模块/M1-S2-TCP握手加密与心跳.md)

## 与基础版差异摘要

帧格式(TClientMessage 12B + TDefaultMessage 12B)、cmd=23/24/25 语义、握手序列(SM_RUNGATEDYN 回执)与基础版**完全一致**。白猪版唯一新增:**可选的 TigerGate 整帧编码层 + cmd=29 心跳帧**,挂在 `count2 == 1 and def.openNewTigerGate` 条件上(源码:`mir2/mir2.single.net.lua`)。

**当前状态:默认关闭。** `def.openNewTigerGate` 在 0518 明文树与生产热更树中均**无任何赋值点**(grep 全树核实,仅 net.lua 四处引用),运行时为 nil。因此白猪版客户端当前按与基础版完全相同的二进制帧协议通信。若未来服务端要求开启(通过 config/热更给 def 注入该字段),协议切换为下述编码形态——服务端实现时应同时兼容两种收流。

## 白猪版特有行为:TigerGate 编码层(核心差异)

### 触发条件

```lua
if count2 == 1 and def.openNewTigerGate then
    net2.server:send(callback(帧字节串, count))   -- 编码文本帧
else
    net2.server:send(帧字节串, sendLen)           -- 与基础版相同(二进制帧)
end
```

- `count2`:在 `net2.connect(ip, port, target, sessionid, areaid)` 中置位——**传入 sessionid(=1)时为第二次连接(游戏网关/重连/公告重拨);首连(areaid)=0**。即 TigerGate 只作用于会话连接,登录网关首连不受影响。
- 被编码的发送点(全部 4 处):握手包(handler 连接成功分支)、SM_RUNGATEDYN 回执(handler)、LM_PING(sendPing)、全部业务消息(net2.send 尾部)。

### 编码算法(callback(self, value),源码 9-49 行)

1. 密钥表 `text` = 固定 64 字符串:`"1Y0lSUQMH+mbKXRTBtFiWvLx32/gNAzGr674oeyn5dCEp8jDqasI9VcwJPhufkOZ"`;
2. 轮转种子 `value` = `count`(维护值,见下);`value ~= 0` 时表右旋 `value % 63` 位:`text2 = text[value%63+1..64] .. text[1..value%63]`;`value==0`(首包)不轮转;
3. 对整帧二进制(含 TClientMessage 头 + payload 全部字节)按标准 base64 的 **3 字节 → 4 字符** 结构编码,但查表用 `text2`(第 4 字符的取值计算 `value2 = math.fmod(math.floor(count6/262144), 64) + 1`,`count6` 为 3 字节大端拼接值,每轮 `count6 = count6 * 64` 取下一字符);不足 3 字节的尾部补 `=`(每缺 1 字节补 1 个 `=`);
4. 结果末尾拼接 **`"|LH"`** 后缀,整串作为文本发出。

> 逆操作(服务端解码):去尾部 `|LH` → 按 64 字符表 `text2`(同一轮转规则)反查 base64 → 还原二进制帧。轮转种子 = 上一帧的 `dataIndex`(见下)。

### count 种子维护

| 时机 | 赋值 | 说明 |
|---|---|---|
| 握手包发出后(handler) | `count = net.dataIndex` | dataIndex=sessionID(第二次连接时) |
| cmd=29 心跳发出后(onUpdate) | `count = net.dataIndex` | dataIndex=发送时刻时间戳 |
| 其余业务发送 | 不更新 | 复用最近一次值 |

即:轮转种子随握手/心跳逐帧滚动,业务包沿用最近值。服务端解码时必须**按帧维护**该种子(首包 value=0 不轮转,其后按上一帧 dataIndex 轮转)。

### cmd=29 心跳帧(白猪版新增)

- 构造(onUpdate,51-65 行):`TClientMessage{ sign=0xFF44FF44, cmd=29, dataIndex=socket.gettime() }`(12B,无 TDefaultMessage 无 body);
- 周期:**30 秒**(`scheduleScriptFunc(onUpdate, 30, false)`,连接成功且发送握手后注册,全局单例 `Timer` 防重);
- 发送:`count4 == 1`(已编码过至少一次)时经 callback 编码后发送,否则原样二进制发送;随后 `count = net.dataIndex`(该心跳的 dataIndex,即时间戳);
- **下行处理:客户端不解析 cmd=29**(processLoop 仅处理 23/24/25,其余 `print("discard msg")` 丢弃)→ 服务端可不回应答,或按需回应(客户端无消费)。

### 服务端实现要点(若开启 TigerGate)

1. **收流判别**:同一 TCP 流上可能混有二进制帧(编码前/未开启时)与文本帧(`|LH` 结尾)——需先按尾缀/首字节特征判别再分别解析;
2. 文本帧解码:去 `|LH` → 逆变体 base64(密钥表 `text`,按上一帧 dataIndex 轮转)→ 得标准二进制帧 → 按基础版帧解析;
3. 维护每连接种子 `count`(= 上一帧 dataIndex;首帧 0);
4. cmd=29 上行心跳:仅当收到时可选回应(无强制要求),但注意其 dataIndex 是时间戳,可用于该连接的密钥轮转同步;
5. 编码侧(服务端→客户端下行)无需编码——**客户端接收路径无任何解码逻辑**(callback 只用于上行),服务端下行一律按基础版二进制帧发送。

## 其余差异(白猪版 net.lua)

- `net2.send` 开头新增 `if not net2.server then print("server failed"); return end` 保护(基础版无,断线后调用不再崩溃);
- 其余(队列、waitMsg、setMatchMode 白名单 9 条、net.record/str/strs 等)与基础版一致。

## 服务端实现要点

1. 默认按基础版二进制帧协议实现即可兼容白猪版(当前开关关闭);
2. 预留 TigerGate 解码能力(上述算法)以便服务端侧开启;开启后仅上行变文本帧,下行不变;
3. cmd=29 心跳可忽略,不影响连接保活判断(客户端 30s 一发,仅当开启编码时有协议意义)。
