# M10-S2 安全密保 security

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md)

## 功能概述

两套相互独立的机制:

1. **登录密保(账号级)**:选人阶段服务端要求回答密保卡的第 N1/N2/N3/N4 位数字。`SM_REQUIRE_MIBAO(4020)` 下发 4 个位序号,客户端弹全屏输入框,玩家输入 4 位数字后以 `CM_SUBMIT_MIBAO(4020)` 回传。验证通过前无法正常进入角色流程。
2. **装备密宝(角色级)**:装备可被"密宝"绑定锁定。服务端通过 `SM_LOCKEQUIP(689)` 推送绑定/解锁状态机(param 0~19 多分支);被绑定的装备需点击血球右下角密宝按钮发起解锁(`CM_LOCK_UNLOCK_EQUIP(1084)`),再在弹出的验证框输入 5 位动态密码(`CM_TRY_UNLOCK_EQUIP(1068)`)。锁定状态切换结果由 `SM_LOCK_EQUIP_STATE(1201)` 回执。

**本模块不走 HTTP**:全树核查 `mir2.data.security.lua` 与 `panel/security.lua`,无任何 URL/HTTP 调用;手机/邮箱绑定功能在本基础版客户端中不存在。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2.data.security.lua` | `g_data.security`:`setLoginBit`(解析登录密保位)、`setEquipBit`(存装备密保位序号) |
| `mir2.scenes.login.scene.lua :: processMsg` L345 | SM_REQUIRE_MIBAO 入口 |
| `mir2.scenes.select.scene.lua` L573-654(showSecurity)/L88(onEnter 触发)/L615-642(提交) | 登录密保 UI 与 CM_SUBMIT_MIBAO 发送 |
| `mir2.scenes.main.common.common.lua :: setBindEquipState`(L905)/`setLockEquipState`(L878) | SM_LOCKEQUIP / SM_LOCK_EQUIP_STATE 的全部状态机 |
| `mir2.scenes.main.panel.security.lua :: submit` | CM_TRY_UNLOCK_EQUIP 发送(5 位动态密码) |
| `mir2.scenes.main.panel.equip.lua` L246-280 | 密宝按钮:CM_LOCK_UNLOCK_EQUIP 发送与本地限速 |
| `mir2.scenes.main.ui.lua` L1982-1985 | 两个 SM 的分派 |
| `mir2.single.net.lua :: net.match` L267 | select 场景 match 模式发送白名单含 CM_SUBMIT_MIBAO |

## 报文总览

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| SM_REQUIRE_MIBAO | 4020 | S→C | 服务端判定该账号需密保验证时(login 场景收到) | body=4 字节位序号 |
| CM_SUBMIT_MIBAO | 4020 | C→S | 选人场景密保框点"确定" | param=1,body=4 位数字串 |
| SM_LOCKEQUIP | 689 | S→C | 装备密宝状态变化/登录同步 | param=0..18、19 多分支;series 可携带位序号 |
| CM_TRY_UNLOCK_EQUIP | 1068 | C→S | 密保验证面板点"确定" | recog=5 位数字数值,param=tag,body=字符串 |
| SM_LOCK_EQUIP_STATE | 1201 | S→C | 锁定/解锁操作结果 | recog=时间值,param=1/2 |
| CM_LOCK_UNLOCK_EQUIP | 1084 | C→S | 装备栏密宝按钮 | 无参无体,双端限速 |
| CM_BOUND_MIBAO / SM_BOUND_MIBAO | 4022 | 双向 | (常量存在,本树无任何调用/处理——推测为绑定密保卡流程,未核实) | |
| CM_UNBOUND_MIBAO / SM_UNBOUND_MIBAO | 4023 | 双向 | (常量存在,本树无任何调用/处理——推测为解绑密保卡流程,未核实) | |
| CM_LOCK_UNLOCK_EQUIP2 | 4032 | C→S | (常量存在,本树无调用) | 注意 4032 同时是 SM_SHENYOU_CONFIG 的值 |
| SM_NEED_VALIDATE_IMAGE / CM_SUBMIT_VALIDATE_IMAGE | 4027 | 双向 | 登录图形验证码(login 场景),属 M1 登录流程,此处仅备注相邻性 | |

## 详细报文说明

### SM_REQUIRE_MIBAO(4020) → CM_SUBMIT_MIBAO(4020)

**下行**(login.scene.lua L345 → `data/security.lua :: setLoginBit`):

```lua
self.loginBit = net.strSplitWithLen(buf, 1, 4)   -- 连续读 4 组,每组 1 字节
```

body 布局:

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 0 | byte | bit1 | 要求回答的密保第几位(用于提示语"请依次输入密保的第 x,x,x,x 位") |
| 1 | byte | bit2 | 同上 |
| 2 | byte | bit3 | 同上 |
| 3 | byte | bit4 | 同上 |

recog/param/tag/series 未使用。(未核实位序号的合法范围与是否允许 0/负数表示特殊态。)

**上行**(`select.scene.lua` L620-626):进入选人场景时若 `loginBit` 存在即弹窗(`showSecurity`),输入须为 4 位数字:

```lua
net.send({ CM_SUBMIT_MIBAO, param = 1 }, { text })   -- body: "1234"(GBK)
```

| TDefaultMessage 字段 | 用法 |
|---|---|
| recog | 未用 |
| param | 固定 1 |
| tag / series | 未用 |
| body | 4 位数字字符串(net.send 经 u2a 转 GBK) |

**应答**:本树没有针对该提交的专用处理分支;验证成功后服务端应继续正常的角色流程消息(SM_CHR_LIST 等),失败行为(如断开/重发 SM_REQUIRE_MIBAO)未核实。注意 select 场景处于 `net.setMatchMode(true)` 门控下,白名单(`net.match`)显式放行 CM_SUBMIT_MIBAO,说明它是该场景唯一预期的业务上行之一。

### SM_LOCKEQUIP(689) —— 装备密宝状态机

处理:`ui.lua` L1984 → `common.setBindEquipState(msg)`。无 body,全部语义在 param/recog/series:

前置:当 `param < 9` 且 `recog > 0` 时,客户端按"剩余毫秒 = `g_data.equip.lockTime`(180000,本地常量) − recog"换算出 mm:ss 倒计时文案 → **recog = 距离可解锁的剩余毫秒数**。

| param | 含义(服务端应保证的语义) | 客户端表现 |
|---|---|---|
| 0 | 装备已被密宝绑定,recog>0 时附带剩余时间文案 | 红字提示"你的装备已经被密宝绑定…点击血球右下角的密宝按钮进行验证";显示锁图标 |
| 1 | 需先完成密宝验证才能使用该功能 | 提示"…后可点击游戏界面右下角的密宝按钮…" |
| 2 | 解绑失败(游戏中) | "装备解绑失败,游戏中断" |
| 3 | 解绑成功 | 提示 + 隐藏锁图标(setEquipLockVisible false) |
| 4 | 密宝时间偏差 | "装备解绑失败,密宝时间偏差,请到网页上矫正密宝时间"(暗示动态密码与服务器时间相关) |
| 5 | 服务器忙 | "服务器忙，请稍后再试..." |
| 6 | 会话过期 | "请重新登录后，再来进行此操作" |
| 8 | 绑定通知 | series>10000 时 `setEquipBit(series)`(**series 直接携带密保位序号串**,如 12345→第 1,2,3,4,5 位);"请点击血球右下角的密宝按钮进行验证"+显示锁图标 |
| 9 | 要求验证 | 若已有 equipBit 且验证面板未开,自动弹出 security 面板(tag=1) |
| 10~18 | 预留空分支(客户端 Nothing) | 无 |
| 19(PPW_SM_EQUIP_SPLIT,globa1 L2090) | 预留空分支 | 无 |
| 其他(param≥9 且非上列) | "装备解绑失败，请稍后再试..." | 兜底分支 |

### CM_TRY_UNLOCK_EQUIP(1068)

发出(`panel/security.lua :: submit`):面板标题由 `equipBit` 各位拼出"请依次输入密保的第 x,x,x,x 位",要求 **5 位数字**:

```lua
net.send({ CM_TRY_UNLOCK_EQUIP, recog = tonumber(str), param = self.tag }, { str })
```

| TDefaultMessage 字段 | 用法 |
|---|---|
| recog | 5 位数字的十进制数值(冗余编码,body 里还有原串) |
| param | 打开面板时的 tag(当前唯一来源是 SM_LOCKEQUIP param==9 自动弹出时传 1)(其他入口未核实) |
| tag / series | 未用 |
| body | 5 位数字字符串(GBK) |

期望应答:本树未见专用 SM;从状态机看,解锁结果应通过 `SM_LOCKEQUIP(689)` 的 param 分支(3 成功/2 失败/4 时间偏差/5 忙/6 重登)回执(推断,未核实是否存在其他专用应答消息)。

### CM_LOCK_UNLOCK_EQUIP(1084) → SM_LOCK_EQUIP_STATE(1201)

发出(`panel/equip.lua` L266):密宝按钮点击,**无参无体**。客户端双重限速:距上次点击 <3s 直接忽略;`serverUnlockTime` 未耗尽时提示"请等待 N 秒之后再解锁装备"。按钮仅在 `g_data.security.equipBit 存在 或 lockState>0` 时创建(英雄页签除外)。

应答(`ui.lua` L1982 → `common.setLockEquipState`):

| 字段 | 用法 |
|---|---|
| recog | 写入 `g_data.equip.serverUnlockTime`(下次可切换的时间基准;具体历元未核实) |
| param | 1=已锁定("点击'密宝'按钮可进行解锁");2=已解锁("再点击'密宝'按钮可对装备进行锁定") |
| body | 无 |

param=1 → `lockState=1`,state=false;param=2 → `lockState=2`,state=true;其他 param 客户端静默忽略。

### 常量级残留(本树不可达)

- `CM_BOUND_MIBAO(4022)`/`SM_BOUND_MIBAO(4022)`、`CM_UNBOUND_MIBAO(4023)`/`SM_UNBOUND_MIBAO(4023)`:仅 globa1 定义,无任何 send/handle。与 M2 的 CM_SUBMIT_MIBAO(4020)同族但独立成套,推测对应网页/客服端操作的密保卡绑定与解绑回执(未核实)。
- `CM_LOCK_UNLOCK_EQUIP2(4032)`:仅定义,无使用。
- 图形验证码对 `SM_NEED_VALIDATE_IMAGE(4027)`:login 场景弹码图输入框,"确定"发 `CM_SUBMIT_VALIDATE_IMAGE(4027)` body=输入内容、"换一张"发 `param=1` 空体请求新图。完整流程归 M1 登录模块。

## 服务端实现要点

1. **两套密保号码不同**:登录密保问答走 4020(与请求同号回环),装备密宝走 689/1068/1084/1201 四消息组,勿混用。
2. SM_REQUIRE_MIBAO 的 body 是 4 个裸字节(非字符串、非 `/` 分割),每字节一个位序号。
3. SM_LOCKEQUIP 的 param 分支表必须完整实现 0~9;10~19 可发但客户端无表现。series>10000 才会被当作位序号写入 equipBit,注意阈值。
4. 装备锁定的冷却计算依赖 `SM_LOCK_EQUIP_STATE.recog`:客户端用它减去本地经过时间得到剩余秒。若下发 0,则按钮点击不会被倒计时拦截(仅剩本地 3s 限速)。
5. CM_TRY_UNLOCK_EQUIP 的 5 位动态密码若与时间挂钩(参见 param=4 文案),服务端需实现基于服务器时间的 TOTP 式校验与容差。
6. select 场景的 match 白名单只放行少数消息(含 CM_SUBMIT_MIBAO),验证期间不要指望客户端发出其他业务包。
