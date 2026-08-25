# 协议基础简报(给文档分析代理的公共事实)

本文件是 `client-other/res/rebuilt-src` Lua 客户端网络协议的已核实公共事实。写文档时直接引用,不要重新推导,也不要与这些结论矛盾。

## 1. 源码位置

- 源码根:`client-other/res/rebuilt-src/`(mir2/ an/ upt/ framework_precompiled/)
- 消息号常量:`mir2/mir2.def.globa1.lua`(约 1787 条 `CM_*`/`SM_*`/`LM_*` 常量)
- 记录(结构体)定义:`mir2/mir2.def.globa2.lua`(初始 `local def` 表 + 全文 `def.XXX = {...}` 追加定义,共 **118** 个记录;提取底稿 `_tmp\proto-docs\records.txt`)
- 网络层:`mir2/mir2.single.net.lua`
- 调试名表:`mir2/mir2.single.m2debug.lua`(cmNames/smNames,可读消息名)
- 本机字节流实现(Win32 本地化改造,权威):`frameworks/runtime-src/Classes/Mir2ByteStreamCompat.cpp`
- 消息号↔文件交叉引用表(已生成):`D:\Dev\ZhanS\_tmp\proto-docs\usage.json`(常量→文件→行号列表)
- 记录定义提取表:`D:\Dev\ZhanS\_tmp\proto-docs\records.json` / `records.txt`
- 全部常量数值表:`D:\Dev\ZhanS\_tmp\proto-docs\constants.txt`

## 2. TCP 帧格式(小端)

一条 TCP 业务帧 = `TClientMessage`(12 字节头) + `dataLength` 字节载荷。

TClientMessage(12B,偏移按实际布局):
| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | uint32 | sign | 固定 `0xFF44FF44`(4282711876,`net.SEGMENTATION_IDENT`) |
| 4 | uint8 | reservationByte | 平台码 `net.platformCode()`=2 |
| 5 | uint8 | cmd | 23=`LM_DYN_ENCRYPT_CODE`(业务消息) / 24=`LM_GET_ENCRYPT`(握手) / 25=`LM_PING`(心跳) |
| 6 | int16 | dataLength | 后续载荷字节数 |
| 8 | uint32 | dataIndex | 握手时=areaID 或 sessionID;业务消息=自增序号(net.code,初始 random(65535)+1000,每发一条+1) |

cmd=23 时,载荷 = `TDefaultMessage`(12B) + body(`dataLength-12` 字节):

TDefaultMessage(12B):
| 偏移 | 类型 | 字段 |
|---|---|---|
| 0 | int32 | recog |
| 4 | int16 | ident(消息号 CM_*/SM_*) |
| 6 | int16 | param |
| 8 | int16 | tag |
| 10 | int16 | series |

服务端下行的特殊 ident 在 net.handler 内联处理:
- `SM_RUNGATEDYN`:客户端把 gate 下发的 default + buf 原样再包一层 TClientMessage(cmd=23)+TDefaultMessage 回发(网关动态加密回执)。
- `SM_ACT_GOOD` / `SM_ACT_FAIL`:直接走 processMsg 分发。
- 其余全部进队列由 `net.processLoop`(每帧≤30ms)分发。

## 3. 连接生命周期

1. `net.connect(ip, port, target, sessionid?, areaid?)`:记录 dataIndex=areaid(有则)否则 sessionid。
2. 连接成功事件 → 发握手帧 cmd=24(LM_GET_ENCRYPT),reservationByte=平台码2,dataIndex=dataIndex。`net.willCode` 防重发。
3. 之后所有业务消息用 cmd=23 封装。
4. 心跳:cmd=25(LM_PING),无 TDefaultMessage、无 body(DEBUG 下定时发送并显示 ping 值)。
5. 登录相关场景(select/login/main/notice/reconnect)各自 `net.add(self)` 注册 processMsg;main 场景额外注册 ui 与 ground;`net.setWaitMsg(ident,...)` 用于阻塞等待特定消息(其余消息暂存队列)。

## 4. 发送辅助(net.send)

`net.send(msg, strs, data)`:
- `msg[1]`=CM_* 消息号;可选字段 `msg.recog/param/tag/series` 填入 TDefaultMessage。
- `strs`:字符串数组,每条先 `ycFunction:u2a`(UTF-8→GBK)转 GBK;多条之间跳过 1 个字节(缓冲区 memset 0,即 0x00 分隔);body 总长前再加 1 字节(0x00)。
- `data`:record(getRecord 构造)或 `{ {"byte",v}, {"short",v}, {"int",v}, {"uint",v}, {"ID"/"double",v}, {"char*",s,len}, {"string",s,len} }` 数组。
- 无 strs 且无 data 时 dataLen=0。

## 5. 接收辅助

- `net.record(name, buf, bufLen)`:按记录定义解包。
- `net.str(buf)`:`readChars` 读整个 body 并 GBK→UTF-8;`net.strs(buf, c)` 按 `/` 分割(聊天等)。
- `net.byte/int/uint/double`:顺序读原始字段并返回剩余串。
- `Loword/Hibyte/Lobyte/Hibyte`、`checkExist(v, ...)` 为 globa1/globa2 提供的位运算/成员判断助手。

## 6. 记录(record)系统语义 —— 服务端重写必须遵守

定义形如 `{ { "类型", "字段名"[, 长度或引用] }, ... }`,可选属性 `packed=true`。

类型与线上尺寸(baseVarSize):
| 类型 | 尺寸 | 编码 |
|---|---|---|
| byte | 1 | 无符号单字节 |
| short | 2 | 小端 int16 |
| int / uint | 4 | 小端 int32/uint32 |
| double / ID | 8 | 小端 IEEE754 double(ID=角色/对象唯一 id 用 double 承载) |
| char* (声明长 N) | N+1 | 定长 GBK 字节区:内容不足补 0x00(writeChars 只写实际字节,余量保持 0;readChars 读 N+1 字节后 a2u) |
| string (声明长 N) | N+1 | 变长:**首字节=长度 L**,后跟 L 字节 GBK(readString 以长度字节为准) |
| record | 嵌套记录尺寸 | 递归 |
| array N of type | N×元素尺寸 | 定长数组;元素可为 record/string/数值 |
| dynamicArray | 动态 | 按 len 字段循环读取(解码期以 bufLen 截断) |

**对齐规则(极重要)**:非 packed 记录按 C 风格自然对齐——每个 short 成员前填充至偶数偏移,int/uint/double 前 4/8 字节对齐;整条记录总尺寸向上取整到最大成员对齐值(fillCheck)。`packed=true`(如 TLoginIdResult)不填充。因此记录线上尺寸 ≠ 字段简单相加,必须用对齐后的尺寸。

已核实的常用记录(详见 records.txt):TClientItem、TStdItem、TAbility/TAllAbility/TClientAbility、TFeature、TNewCharDesc/TCharDesc、TClientMagic、TClientGroupMemInfo、TClientNearbyGroupInfo、TMessageCapitalInfo、TMirCharinfoEx、TOsVersion3、TGSDateLen 等。

## 7. 文本编码

- 线上所有字符串一律 **GBK**(writeString/writeChars 前 u2a,读取后 a2u)。文档中注明"GBK"即可,不必展开 iconv 细节。
- 聊天/NPC 文本类 body 常为 `/` 分割的多段字符串。

## 8. 文档写作要求(每个代理必读)

1. 只写服务端交互:触发时机(玩家做什么)、发出的 CM 报文(消息号数值、recog/param/tag/series 用法、body 布局)、期望的服务端响应(SM 及其布局、错误分支)。不要写客户端本地 UI/渲染/动画逻辑,不要写本地状态机细节(仅当影响报文时序时一句带过)。
2. 每个消息号给出十进制数值,格式如 `CM_WALK(3010)`。数值必须从 `mir2.def.globa1.lua` grep 核实,禁止凭记忆。
3. 每个功能块标注来源文件与函数名(如 `mir2.scenes.main.ui.lua :: processMsg` / `mir2.data.bag.lua :: dropItem`),保证可追溯。
4. body 布局用表格:偏移/类型/字段/说明;record 类型直接引用记录名字段表并展开关键记录。
5. 若某 SM 有多个 param/tag/recog 分支含义,逐一列出。
6. 不确定的内容明确标注"(未核实)"而不是猜测。
7. 文档语言:简体中文;文件 UTF-8。
