# M1-S1 HTTP登录中心接口

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md) · 基础版对照:[M1-S1 HTTP登录中心接口](../../基础版/子模块/M1-S1-HTTP登录中心接口.md)

## 与基础版差异摘要

接口族、方法、参数名与响应 JSON 形状**与基础版一致**,三处差异:

1. **服务器地址来源**:`areas.requestServerList` 与 `loginer.selectServer` 使用 `bzmir.gateIP / bzmir.gatePort`(由 `def.setLoginCenter(ip, port, ...)` 写入,`mir2.def.init.lua` 45-46 行),不再是 `def.loginCenterIP/Port`;
2. **新增 serverTime 时钟校准轮询**:登录场景定时(初始 500+random(50,100)ms,`scheduleGlobal` 循环)POST `/account`,取响应 `stime`(秒)写入 `g_data.login.serverTime`(`areas.lua` 106-129 行)——服务端在 /account 响应 JSON 中携带 `stime` 即可,缺失不影响登录;
3. `loginer.verifyReceipt(gameorderid, productid, iosreceipt, ...)` 为**空实现**(支付收据验证禁用,充值见 M8-S4)。

## 接口清单(白猪版实测,`mir2/mir2.scenes.login.loginer.lua`)

`loginer.send(op, params, reqfunc)`:`reqfunc` 默认 GET(参数拼 query),POST 时 `addPOSTValue`;响应 `json.decode` 取 `code/des/...`;失败自动重试 3 次(退避 0.5×1.4^n 秒)。

| 接口 | 方法 | 参数 | 说明 |
|---|---|---|---|
| `/account` | GET | `id`、`psw` | 账号密码登录取票(与基础版相同) |
| `/account` | GET | `guest=1`、`id=uuid` | 游客登录(白猪版保留) |
| `/account` | POST | (无参) | serverTime 轮询,响应含 `stime` |
| `/reg` | GET | `id`、`psw`、`safecode`[,`agent`] | 注册;`def.agent.openGameAgent` 时附带 agent |
| `/bind` | GET | `id`、`psw`、`safecode`、`machineid=uuid` | 绑定/密保 |
| `/modifypsw` | GET | `id`、`psw`、`safecode` | 修改密码 |
| `/serverlist?password=` | GET | — | 私服列表(def.sfAuthUrl,归 M2-S1) |
| `/downloadconfig/<configName>` | GET | — | 配置包下载(areas.requestConfigZip,与基础版同) |

## 服务端实现要点

1. 全部接口与基础版兼容即可;`code=0` 即成功(旧服务端 `des="被封"` 仅为文案,见基础版 M1-S1);
2. `/account` 建议返回 `{ code, des, serverlist:{verinfo, shopurl, servers, notice}, last, stime }` 以同时满足列表与时钟校准;
3. 账号密码线上为明文(无 md5),与基础版一致。
