# M1-S3 TCP账号登录流程

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md) · 基础版对照:[M1-S3 TCP账号登录流程](../../基础版/子模块/M1-S3-TCP账号登录流程.md)

## 与基础版差异摘要

**协议无差异。** 白猪版登录序列与基础版逐条一致(已对照 `mir2/mir2.scenes.login.scene.lua` 与基础版同文件):

- HTTP 取票(`/account?id=&psw=`)→ `net.connect(ip, port, self, nil, def.areaID)`(首连 dataIndex=areaID);
- 连接成功 → 发 cmd=24 握手帧(reservationByte=2);
- `SM_LOGIN` → 回 `CM_RECONNECT`(strs=reconnectID);`SM_LOGIN_AUTH` param=1 时按 bufLen 判别 `TLoginIdResult`(42B)/`TLoginIdResult2`(87B);
- 顶号(`SM_LOGIN_ALREADY_ONLINE` recog=1 → `CM_LOGIN_ALREADY_ONLINE` param=1/0)、排队(`SM_LOGIN_QUEUE`)、踢下线(`SM_OUTOFCONNECTION_KICKOUT`)同基础版;
- `CM_IDPASSWORD(2001)` **仍不发送**(HTTP 取票制)。

## 白猪版特有行为

1. **TigerGate 条件挂载**:本流程的所有上行(握手、SM_RUNGATEDYN 回执、业务消息)在 `count2==1 and def.openNewTigerGate` 时走编码层——注意**首连 count2=0 不受影响**,二次连接(选服后/重连)才可能启用;当前开关默认关闭(详见 [M1-S2](M1-S2-TCP握手加密与心跳.md))。
2. 登录场景的 `/account` serverTime 轮询(见 M1-S1)与 TCP 登录并行,不影响报文序列。

## 服务端实现要点

与基础版 M1-S3 完全一致:按基础版文档实现登录序列、票据(TLoginIdResult2.reconnectID)、排队与顶号协商;无需为白猪版做特殊分支。
