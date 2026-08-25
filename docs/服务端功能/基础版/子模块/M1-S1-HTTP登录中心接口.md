# M1-S1 HTTP登录中心接口

> 所属主模块:[M1-登录与接入](../主模块/M1-登录与接入.md)

## 功能概述

登录接入的 HTTP 阶段,全部为**明文 HTTP + JSON/查询串**,无 HTTPS、无签名。承担四类职责:

1. **区服列表获取**:`POST /account`(空请求体)→ JSON 区服树(verinfo/servers/notice/shopurl),决定后续 TCP 首连的 ip/port 与 areaID;
2. **账号操作**:注册 `/reg`、绑定游客 `/bind`、改密 `/modifypsw`、登录取票 `GET /account?id=&psw=`(响应携带 TCP 鉴权要用的 `ticket`);
3. **区配置补丁下载**:`GET /downloadconfig/<configName>` → zip 落盘解压;
4. 本地兜底:`parseJson("config/serverlist.json")` 覆盖服务器列表(Win32 调试构建)。

另有一个同族接口 `GET /serverlist?password=`(`def.sfAuthUrl`)归 [M2-S1 私服列表sfselect](M2-S1-私服列表sfselect.md),本篇只登记其存在。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2/mir2.def.init.lua` | `setLoginCenter(ip,port,…)` 拼 `def.loginCenter = "http://ip:port"`(行 53-59);`setSF` 拼 `def.sfAuthUrl`(行 38-43,注意 `def.sfPort = pert` 为源码笔误,sfPort 实际为 nil);出厂默认 `setLoginCenter("127.0.0.1", 8088, "君临复古", "1997dw")`、`setSF("127.0.0.1", 8089, "mir2666")`(行 46-47、61) |
| `mir2/mir2.scenes.login.areas.lua` | `requestServerList`(POST /account)、`selectServer/enterGame`(选择后写 def.*)、`requestConfigZip`(GET /downloadconfig)、`extend`(本地 serverlist.json 兜底) |
| `mir2/mir2.scenes.login.loginer.lua` | 通用 HTTP 小客户端:`selectServer/genUrl/send_/send/onRequestEvent/onEvt`,以及 `login/register/bind/chgPsw/verifyReceipt` 五个业务封装 |
| `mir2/mir2.scenes.login.login.lua` | 输入层:`submit` 收账号密码→`m:login`;`onCetSvrEvt(code,desc,res)` 消费 `{code,des,…}`,code==0 回调 `scene:loginEnd(res)` |
| `mir2/mir2.scenes.login.scene.lua` | `loginEnd(data)`(行 431-442)解析 ticket/forces/last/phone 并发起 TCP;`onRepServerList`(行 444-447)选区完成后转登录层 |
| `mir2/mir2.data.login.lua` | `g_data.login`:verinfo/servers/notice/forces/netLastName/ticket/ac/pw 存储 |
| `upt/main.lua` | 本机栈强制 `def.setSF("127.0.0.1",8089,"mir2666")`,`def.loginCenterIP/Port` 为 nil 时兜底 `127.0.0.1:8088`(行 250-352,pcall 包裹) |

## 报文总览

| 接口 | 值/URL | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| 区服列表 | `POST http://<loginCenterIP>:<loginCenterPort>/account`,**空请求体** | C→S | areas 层构造即拉(`areas :: ctor → requestServerList`,行 11-14、63) | 与"登录取票"同名不同法,见下 |
| 账号登录 | `GET http://<ip>:<port>/account?id=<acc>&psw=<pw>`(游客:`?guest=1&id=<uuid>`) | C→S | 登录层点"登录"/游客按钮(`loginer :: login`,行 167-181) | 参数名是 **id/psw**,不是 account/password |
| 注册 | `GET …/reg?id=&psw=&safecode=` | C→S | 注册面板确定(`loginer :: register`,行 151-157) | |
| 绑定游客 | `GET …/bind?id=&psw=&safecode=&machineid=<uuid>` | C→S | 绑定面板确定(`loginer :: bind`,行 142-149) | |
| 改密 | `GET …/modifypsw?id=&psw=&safecode=` | C→S | 改密面板确定(`loginer :: chgPsw`,行 159-165) | psw=新密码 |
| iOS 凭据回执 | `POST …/paycb`(addPOSTValue:productid/gameorderid/iosreceipt/extend/tid) | C→S | `loginer :: verifyReceipt`(行 183-192);本模块仅列接口,细节归 M8-S4 货币与充值 | |
| 区配置补丁 | `GET http://<loginCenter>/downloadconfig/<configName>`,超时 200s | C→S | 选定区且本地 zip 缺失/版本不符(`areas :: requestConfigZip`,行 375-451) | 响应是 **zip 二进制**,非 JSON |
| 私服列表 | `GET http://<sfIp>:<port>/serverlist?password=<sfPassword>` | C→S | sfselect 场景 `requestSfList`(**归 M2-S1**) | |
| 本地兜底 | `parseJson("config/serverlist.json")` → `g_data.login:setServerList(data.servers)` | 本地 | 仅 `WIN32_OPERATE` 构建调 `areas :: extend`(行 556-578),覆盖网络列表的 servers 字段 | 非接口 |

通用传输行为(`loginer.lua :: send_/send/onRequestEvent`,行 53-140):

- GET:参数经 `genUrl` 以 `?k=v&k=v` 追加,**不做 URL 转义**;POST:逐个 `req:addPOSTValue(k,v)`。
- 单飞防重入:`self.sending` 存在时直接忽略新请求(行 83-85)。
- 网络失败自动重试 3 次,延迟 `0.5 × 1.4^(3-retry)` 秒指数退避;3 次耗尽才回调错误(行 125-137)。
- 应答处理:HTTP 状态 200~300 且 `json.decode` 成功 → `onEvt(r.code, r.des, r, ex)`;解码失败只打日志 `"decode failed!"` 后静默(行 117-124)。

## 详细报文说明

### 1. POST /account —— 拉取区服列表

- **时机**:login 场景进入后显示 areas 层(`scene:onEnterTransitionFinish`,`params.logout==false` 分支)即触发;失败弹窗可无限重试。
- **方法/编码**:`network.createHTTPRequest(cb, url, "POST")`(`areas.lua:19-63`),**未调用任何 addPOSTValue → 请求体为空**,服务端不能靠 body 区分本次调用。
- **成功分支**(HTTP 200):JSON 形状(客户端实际读取的字段逐一列出,`areas.lua:57-61` + `loadServer/selectServer` 的消费点):

```json
{
  "serverlist": {
    "verinfo":  [ { "verid": 1, "vername": "复古版", "clientver": 185 } ],
    "shopurl":  "http://…",
    "servers":  [ { "name": "君临复古", "id": 3, "zoneid": 1, "zonename": "电信一区",
                    "zoneip": "127.0.0.1:7000", "area": 0, "ver": 185,
                    "suggest": 1, "heat": 2, "force": 0,
                    "ConfigName": "patch1.zip", "ConfigVer": 3, "serverinfo": {} } ],
    "notice":   "<b size=20 urlcolor=255|0|0 textcolor=255|255|255 urladdr=http://… urltext=官网 /><t a=b\\n />…"
  },
  "last": "上次登录的区服名(name 字段精确匹配)"
}
```

| 字段 | 用途(消费点) |
|---|---|
| `serverlist.verinfo[].verid/vername/clientver` | 版本分类页签;`clientver` 经 `getClientVer` 变成 `def.gameVersionType`(areas.lua:293-295) |
| `serverlist.shopurl` | 商城 URL(g_data.login.shopUrl) |
| `serverlist.servers[]` | 区服条目;分组按 `verid`、排序按 `zoneid`;`suggest>0` 进推荐;`heat` 贴热度角标;`force` 非 0 时点击弹 `forces[force]` 文案并禁止进入(areas.lua:179-183) |
| `servers[].zoneid/zonename/zoneip/area/serverinfo/ConfigName/ConfigVer` | 进入时写入 `def.setGameServer(zoneid, zoneip, area, clientVer, serverinfo, ConfigName, ConfigVer)`(areas.lua:295)——**zoneip 即 TCP 首连地址,area 即首连握手 dataIndex(areaID)** |
| `serverlist.notice` | 公告富文本(`<b …/>` 块,size/textcolor/urlcolor/urladdr/urltext 参数,`\n` 写作 `\\n`),`showNotice` 解析显示(areas.lua:463-545) |
| `last` | 与 `servers[].name` 匹配出"上次登录"快捷按钮(areas.lua:150-152) |

- **失败分支**:事件 `failed` → 弹"获取服务器列表失败."〔退出/重试〕,退出即 `os.exit(0)`;HTTP 状态 ≠200 → 同文案弹窗,确定后 `os.exit(0)`(areas.lua:20-51)。**没有超时重试**(与 loginer 不同)。
- **客户端后续动作**:解析 → `loadServer()` 渲染列表;玩家选定区服 `enterGame`:
  1. `def.setGameServer(...)`(含 areaID);
  2. 若条目带 `ConfigName+ConfigVer`:比对 `<writable>/config/<serverId>/<zoneid>/configver.json` 的 `ver`,不一致或缺 zip → `requestConfigZip()`;否则直接 `serverlistCallback()` → login 场景 `onRepServerList` → 显示账号输入层。

### 2. GET /downloadconfig/&lt;configName&gt; —— 区配置补丁下载

- **URL**:`def.loginCenter .. "/downloadconfig/" .. def.configName`(`areas.lua:376`);**方法 GET**,超时 200 秒(`httpReq:setTimeout(200)`,行 449)。
- **成功分支**(HTTP 200,响应体为 zip):
  1. `saveResponseData` 到 `<writable>/config/<def.serverId>/<def.zoneid>/<ConfigName>`;
  2. 同目录写 `configver.json`,内容 `{"ver": <ConfigVer>}`;
  3. `ycFunction:unzip` 解压到该目录下 `config/` 子目录(areas.lua:417-437);
  4. 回调 `serverlistCallback()` 进入登录输入层。
- **失败分支**:`failed` 或状态 ≠200 → 移除遮罩,弹"获取该区补丁失败.",无自动重试(行 386-415),流程停在遮罩页(玩家无路可走——服务端必须保证该接口对已发布 configName 可用)。

### 3. GET /account?id=&lt;acc&gt;&amp;psw=&lt;pw&gt; —— 账号登录取 ticket

- **时机**:登录输入层点"登录"(先本地校验账号/密码长度 ≥4,`login.lua:41-56`)或"游客登录"(`self.m:login(nil,nil,1)`)。
- **参数编码**:query 串,**明文**,无 md5——全工程 `crypto.md5` 只出现在 IOS_REVIEW 分支对设备 uuid 的摘要(login.scene.lua:255)及资源校验(pic/voice/cache),口令从不散列。游客模式参数为 `guest=1&id=<uuid>`(uuid 来自设备信息或随机生成落盘)。
- **响应 JSON**(`loginer.onRequestEvent` → `onEvt(r.code,r.des,r)` → `login.onCetSvrEvt` → `scene:loginEnd(data)`,login.scene.lua:431-442):

```json
{
  "code": 0,
  "des": "任意文案",
  "ticket": "TCP鉴权票据(CM_LOGIN_AUTH strs[1] 原样回传)",
  "last": "上次区服名",
  "phone": "手机号",
  "list": { "forces": { "1": "封停公告文案", "…": "…" } }
}
```

- **成功分支**:`code == 0` → `loginEndCallback(res)`:存 `g_data.login.ticket/phone`、`setForceList(list.forces)`、`setNetLastName(last)`,然后 `connectServer()` 进入 TCP 阶段(M1-S3);有保存过的账号则 `cache.saveAccount(ac,pw)` 明文落盘发生在 SM_LOGIN_AUTH 成功之后(M1-S3)。
- **失败分支**:`code ~= 0` → 弹 `des` 文案;`code == -110` 时文案强制替换为"当前设备似乎未曾以游客身份进入过游戏"(login.lua:249-251)。
- **注意**:`_isLoginProc` 标志区分"登录中"与"面板操作"两类回调路径,但服务端只需关心 code/des 语义。

### 4~6. GET /reg、/bind、/modifypsw

- 三者共用 `send_` 管线,响应只需 `{code, des}`:`code==0` 时关闭面板(reg/bind/modifypsw 的 onCetSvrEvt else 路径),非 0 弹 des。
- 客户端本地校验(服务端可复用):三字段长度 ≥6,字符集限 `[0-9a-zA-Z!@#$]`(login.lua:110-124 等)。
- `/bind` 额外带 `machineid=<uuid>`(绑定当前设备游客身份)。

### 7. POST /paycb(iOS 凭据回执)

- POST 表单:`productid / gameorderid / iosreceipt / extend / tid`(`loginer.verifyReceipt`);响应 `{code,des}`。属充值域,详见 M8-S4(此处仅登记接口存在)。

## 服务端实现要点

1. **同路径双语义**:`/account` 同时承载 POST(拉列表,空体)与 GET(id/psw 登录)两种完全不同的响应形状。实现路由必须按方法区分;按路径缓存会互相污染。
2. **JSON 形状兼容**:客户端用 `ret.serverlist.verinfo` 等多级直取(`json.decode(...) or {}` 只兜最外层),任何一级缺失都会 Lua 报错卡在登录页。`verinfo/servers/shopurl/notice/last` 必须齐全;`servers[]` 条目的 `zoneid/zonename/zoneip/area` 决定能否进游戏,缺 `area` 时 areaID=0(`tonumber(nil) or 0`)。
3. **code 即真理,des 只是文案**:所有账号接口成功判定都是 `code==0`。本仓库 根目录 AGENTS.md 对旧服务端的实测记录:**des="被封" 也曾伴随 code=0 正常放行**(客户端不解析 des 内容做任何拦截)——服务端若要做封禁提示,必须同时给非 0 code;反过来,想发运营公告可直接滥用 des。此结论来自仓库文档而非客户端源码,(旧服务端实测记录,未从本树代码核实)。
4. **编码**:HTTP/JSON 全程 UTF-8;GBK 只出现在 TCP 侧(M1-S3)。但 query 串**不做 URL 转义**:登录口令仅校验长度 ≥4 无字符集限制,含 `? & % 空格 中文(UTF-8 多字节)` 的口令会原样拼进 query——服务端解析 query 时需容忍未转义字节(或接受这是旧协议缺陷);注册/改密路径因字符集白名单 `%w!@#$` 无此风险。
5. **凭据强度**:id/psw 明文过网,ticket 是唯一会话凭据(TCP 阶段 `CM_LOGIN_AUTH` strs[1] 原样回传)。服务端应让 ticket 单次有效、短时效,并在 CM_LOGIN_AUTH 校验后作废。
6. **卡死点**:① `/account`(POST)不通或返回非 200 → 玩家只能退出/无限重试;② `/downloadconfig` 失败 → 流程停在遮罩页无法继续;③ 登录 GET 失败 3 次重试后静默(仅日志),界面停在输入层。三者都不会自愈,必须保证可用性。
7. **本机栈事实**(调试参考,来自 `upt/main.lua` 行 250-352):启动器会对本机栈强制 sf 列表指向 `127.0.0.1:8089/mir2666`(openresty),登录中心兜底 `127.0.0.1:8088`;`def.sfPort = pert` 笔误使 `def.sfPort` 恒为 nil(sfAuthUrl 用局部 port 不受影响)。
