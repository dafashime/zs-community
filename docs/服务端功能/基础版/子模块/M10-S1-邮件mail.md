# M10-S1 邮件 mail

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md)

## 功能概述

邮件系统分四个页签:系统邮件(sys)、物品售卖通知(sell)、摊位过期退回(offtm)、玩家留言(msg)。客户端采用"列表 + 按需读正文"的两级拉取模型:打开页签先拉摘要列表,点开某封未加载的邮件再拉正文与附件明细;附件领取、删除、清空均逐条确认后由服务端回执驱动本地状态迁移。

另有两条独立链路:

- **未读数红点**:服务端随时可推送 `SM_MAIL_INFO(4464)`,主界面 notice 按钮显示未读数,打开邮件面板时清除。
- **新邮件轮询**:进入游戏(`SM_LOGON(50)` 处理尾部)启动定时器,每 1800 秒发送一次 `CM_SYSTEM_NEWMAIL(4464)` 探测(`mir2.data.mail.lua :: startSchedule`,由 `ground.lua :: processMsg` L69 触发)。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2.data.mail.lua` | `g_data.mail`:四类列表缓存、`set`(解析列表)、`parseMail`(解析正文)、`attach/del`(本地状态迁移)、轮询调度 |
| `mir2.scenes.main.panel.mail.lua` | 面板 UI 与 `operatorMail`(全部 CM 发送出口)、售卖邮件"一键领取"循环(startAuto) |
| `mir2.scenes.main.ui.lua :: processMsg` L2150-2232 | 全部 SM 处理与错误分支提示 |
| `mir2.scenes.main.common.notice.lua :: uptMailCnt/removeMailCnt` | 未读数红点显示/清除 |
| `mir2.def.globa2.lua` L3273-3368 | TMailListInfo / TMailInfo / TMailMsg 记录定义 |
| `mir2.scenes.main.ground.lua` L69 | SM_LOGON 后启动轮询 |

## 报文总览

分类 tag 取值来自 `mir2.data.mail.lua :: cfg`:`sys=1`、`sell=4`、`offtm=5`、`msg=6`。下表"分类"即该值。

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_FETCH_MAIL_LIST | 4460 | C→S | 打开面板初始页签/切换页签/读信后"返回"/删除后刷新 | param=分类 |
| SM_FETCH_MAIL_LIST | 4460 | S→C | 应答列表 | recog=±1;body 按 tag 分四种布局 |
| CM_FETCH_MAIL_INFO | 4461 | C→S | 点击尚未加载正文的邮件(recog=id) | param=分类 |
| SM_FETCH_MAIL_INFO | 4461 | S→C | 返回正文+附件明细 | recog=1 时 body=TMailInfo+items |
| CM_FETCH_ATTACH | 4462 | C→S | 点"领取"或一键领取循环 | recog=id,param=分类 |
| SM_FETCH_ATTACH | 4462 | S→C | 领取结果六分支 | recog=-1..-5 各有文案 |
| CM_DEL_MAIL | 4463 | C→S | 删除单封(有未领附件时先弹确认框) | recog=id,param=分类 |
| SM_DEL_MAIL | 4463 | S→C | 删除结果 | recog=±1 |
| SM_MAIL_INFO | 4464 | S→C | 服务端推送未读数 | recog=数量,tag=分类(推测,见详述) |
| CM_SYSTEM_NEWMAIL | 4464 | C→S | 进图后每 1800s 轮询 | 无参无体;与上行同号不同向 |
| CM_FETCH_ATTACH_OFFTM | 4468 | C→S | 摊位过期页"一键领取" | recog=data.id,param=5 |
| SM_FETCH_ATTACH_OFFTM | 4468 | S→C | 结果三分支 | recog=1/-1/-2 |
| CM_CLEAR_ALLMAIL | 4495 | C→S | 系统信/售卖信页"清空"按钮 | param=分类 |
| SM_CLEAR_ALLMAIL | 4495 | S→C | 清空结果 | 客户端以 `CM_CLEAR_ALLMAIL == ident` 接收(ui.lua L2223) |

## 详细报文说明

### CM_FETCH_MAIL_LIST(4460) → SM_FETCH_MAIL_LIST(4460)

发出(`panel/mail.lua :: operatorMail "list"`):

```lua
net.send({ CM_FETCH_MAIL_LIST, param = self.tag })
```

| TDefaultMessage 字段 | 用法 |
|---|---|
| recog | 未用 |
| param | 邮件分类 tag(1/4/5/6) |
| tag / series | 未用 |
| body | 无(dataLen=0) |

应答(`ui.lua` L2150 → `data/mail.lua :: set`):

- `recog == -1`:提示"数据出错!"。
- `recog == 1`:`msg.param`=记录条数 cnt,`msg.tag`=本次分类,body 布局按 tag 分四类,**四类互不相同**:

**tag=1(系统邮件)** — cnt × TMailListInfo(记录字段顺序即线上编码顺序):

| 偏移 | 类型 | 字段 | 说明 |
|---|---|---|---|
| 变长 | int | id | 邮件 id |
| | string[20] | title | 标题,GBK,首字节长度 |
| | string[14] | sender | 发件人 |
| | int | mailState | 1=未读,其他=已读 |
| | int | attachState | 1=有附件可领,2=已领,其他=空 |
| | double | time | Delphi TDateTime,客户端 `TDateTimeToUnixDate` 转 Unix 秒 |

(非 packed,C 对齐,尺寸以记录系统为准。)

**tag=4(售卖通知)** — 先 cnt × TMailListInfo,**紧接** cnt × TClientItem(标准物品记录,字段见 records.txt / 物品模块),第 i 个 itemEx 对应第 i 封邮件。

**tag=5(摊位退回)** — cnt 次(TMailInfo + TClientItem×cnt);仅 `cnt>0` 的条目进列表(全部退回物品在一封聚合邮件中展示)。

**tag=6(玩家留言)** — cnt × TMailMsg:`string name[14]; double time; string msg[50]`。

成功后面板按 tag 渲染对应页签(`showContentByTag`)。

### CM_FETCH_MAIL_INFO(4461) → SM_FETCH_MAIL_INFO(4461)

发出:`recog=id, param=分类`,无 body。触发点:点击列表项但 `g_data.mail.infos.<分类>[id]` 不存在(`extendNode` 点击回调、`sysMail(id)` 开头)。

应答(`ui.lua` L2160 → `data/mail.lua :: parseMail`):

- `recog == 1`:body = TMailInfo + TClientItem×`data.cnt`。TMailInfo(globa2 L3301):`int id; string sender[14]; string title[20]; string context[200] —— 正文; int mailState; int attachState; int type; double time; int gold; int yb; int cnt; int mark`。
  解析后按 id 归属到 sys 或 sell 缓存并打开详情;gold/yb>0 且 attachState==1 时展示金额。
- `recog == -1`:提示"邮件查询失败!"(源码笔误写作 `elseif ident == -1`,实际依赖服务端返回 recog=-1 才能命中,ui.lua L2167)。

### CM_FETCH_ATTACH(4462) → SM_FETCH_ATTACH(4462)

发出:`recog=id, param=分类`,无 body。触发:系统邮件"领取全部"、售卖信展开区"领取"、一键领取循环(`startAuto` 逐封找 attachState==1)。

应答(`ui.lua` L2170):

| recog | 客户端行为 |
|---|---|
| 1 | 本地 attachState→2,提示"领取附件成功.",刷新详情 |
| -1 | "您的包裹空间不足！" |
| -2 | "没有奖励可以领取！" |
| -3 | "金币超过上限！" |
| -4 | "领取元宝失败！" |
| -5 | "不在安全区无法领取附件！"(**领取需处于安全区**) |

任一失败都会终止一键领取循环(`stopAuto`)。

### CM_DEL_MAIL(4463) → SM_DEL_MAIL(4463)

发出:`recog=id, param=分类`,无 body。attachState==1 时客户端先弹确认框再发。

应答(`ui.lua` L2194):recog=1 从本地缓存移除——sys 类自动展示下一封 id(无则提示"已经是最后一封邮件."并重拉列表);sell 类移除节点。recog=-1 提示"删除邮件失败！"。

### SM_MAIL_INFO(4464) / CM_SYSTEM_NEWMAIL(4464)

- 下行(S→C,`ui.lua` L2220):`recog`=未读邮件数,直接驱动主界面红点数字;`msg.tag` 存入 `notice.mailTag`(推测为邮件分类,与 cfg 编号一致)(未核实)。此推送可在任意时刻到达。
- 上行(C→S):无参无体空包。`mail:startSchedule()` 在 SM_LOGON 后注册 1800s 周期任务(`scheduler.scheduleGlobal(...,1800)`,单位秒)。服务端收到后应重新计算未读数并以 SM_MAIL_INFO(4464) 回推(客户端不处理本轮询的直接应答)(未核实服务端是否还有其他响应形式)。

### CM_FETCH_ATTACH_OFFTM(4468) → SM_FETCH_ATTACH_OFFTM(4468)

发出:`recog=g_data.mail.offtm[1].id, param=5`,无 body。摊位过期页唯一按钮("您的摊位已过期,物品已退回")。

应答(`ui.lua` L2208):recog=1 → `mail:attachOfftm()` 清空 offtm 并刷新页签;-1 "您的包裹空间不足！";-2 "没有过期摊位物品！"。

### CM_CLEAR_ALLMAIL(4495) → 同号回执

发出:`param=分类, recog/tag/series 未用`,无 body。系统信/售卖信页右下"清空"按钮。

应答(4495,`ui.lua` L2223 以 CM 常量接收):recog=1 提示"清除成功";-1 提示"清除失败！"。两种情况都刷新当前页签(重拉列表)。

## 服务端实现要点

1. **分类编号是协议的一部分**:param/tag 全程使用 1/4/5/6,不是 0 起。
2. **列表 body 是"记录流水"而非嵌套结构**:sell 类必须先连续写 cnt 条 TMailListInfo 再连续写 cnt 条 TClientItem;offtm 类是"TMailInfo+其 items"交替流。编码顺序不可颠倒。
3. **string 字段为首字节长度 + GBK 内容**(BRIEF §6),title 最长 20、sender 14、context 200、留言 msg 50;超长会被客户端截断显示。
4. time 为 Delphi TDateTime double(非 Unix 秒),客户端负责转换;服务端按 TDateTime 编码。
5. **安全区限制**在服务端侧执行(附件领取 recog=-5);包裹空间检查同样由服务端判定(-1)。
6. 未读数推送(4464)与轮询(同号)共用 ident,服务端需同时支持"被动推送"与"对空包轮询的回应"两种模式。
7. 删除/清空的幂等性:客户端可能因重试重复发送同一 id 的删除请求,重复返回 recog=1 即可。
8. 旧常量 8000~8004(SM_MAILLIST 等)在本树无引用,无需实现。
