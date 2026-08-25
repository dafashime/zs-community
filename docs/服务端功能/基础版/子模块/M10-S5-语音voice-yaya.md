# M10-S5 语音 voice-yaya

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md)

## 功能概述

语音 = **音频面(Yaya SDK + HTTP,不经游戏 TCP)+ 控制面(游戏 TCP 4447~4459 频道管理)** 两层:

- **录音发送**:按下录音按钮 → 原生 voice 接口录 amr(iOS 录 wav 后转 amr)→ `yaya.uploadVoice` 经 Yaya SDK 上传(含语音转文字)→ SDK 回调给出 `url/text/dur/expand(msgID)` → 客户端把它编码为聊天富文本 `{@vi<url>|<dur>|<msgID>}<转写文本>` 走 **CM_SAY(3030,param=1 富文本)** 发出。**msgID = `string.sub(crypto.md5(socket.gettime()), 1, 8)`**(`mir2.single.voice.lua :: startRecord`,L37)。
- **接收播放**:对方从聊天消息解析出 `{@vi}` 段 → 点击气泡 → 本地无缓存文件则 **HTTP GET url** 下载 amr(`network.createHTTPRequest`,`voice.download`)→ 播放;本地缓存文件名 = `md5(user..msgID.."mir2voice")` 前 16 位。
- **实时语音频道**:行会/战队/队伍/公共频道的管理(创建、进出、自由/指挥模式、禁言、踢人、管理员)是独立的 CM/SM 组 4447~4459,成员名单由服务端权威维护并广播 NOTIFY 消息;真正"上麦说话"的音频流走 Yaya SDK 的房间(login/mic),不经过游戏服务器转发。

Yaya appid 硬编码 `"1000309"`(`mir2.single.yaya.lua`)。

## 涉及源文件

| 文件 | 角色 |
|---|---|
| `mir2.single.voice.lua` | msgID/文件名生成、录音状态机、HTTP 下载、播放队列 |
| `mir2.single.yaya.lua` | Yaya SDK 桥(luaj/luaoc):initSDK/login/logout/mic/uploadVoice/uploadPic/sendText 与全部 `call_*` 回调分发(yaya_callback) |
| `mir2.data.voice.lua` | `g_data.voice`:频道头(TClientChannelHeadInfo)+成员表(TClientMemberInfo)与频道日志文案 |
| `mir2.scenes.main.panel.voice.lua` | 频道面板:全部频道管理 CM 发送、SM 列表解析、错误码表(-1..-30,-99)、channelType 映射 |
| `mir2.scenes.main.ui.lua` L2351-2467 | 全部频道 SM 处理(错误码弹窗 + 成员/模式/禁言/管理员变更) |
| `mir2.scenes.main.common.voiceBtn.lua` / `voiceTip.lua` | 录音按钮触摸状态机与音量动画(纯本地) |
| `mir2.scenes.main.common.voiceListenner.lua` | voice 回调:onUploadEnd → common.say 发聊天消息;播放状态联动 |
| `mir2.scenes.main.common.yayaListenner.lua` | yaya 回调:micEnd/realtimeVoice 等提示(纯 SDK 面) |
| `mir2.scenes.main.console.widget.voiceBtnJIT.lua` | 血球旁上麦按钮:yaya.mic 切换(SDK 面) |

## 报文总览

### 游戏 TCP(频道控制面)

channelType 编码(panel/voice.lua L1306):`0=ctPublic 公共,1=ctPersonal 个人,2=ctGuild 行会,3=ctCorps 战队,4=ctGroup 队伍`。

| 消息 | 值 | 方向 | 触发时机 | 备注 |
|---|---|---|---|---|
| CM_CHANNEL_CREATE | 4447 | C→S | 频道列表页"创建频道"弹窗确认(名字过敏感词、密码≤6位数字、人数2~200 校验后) | body=TCnlCreateParam 记录 |
| SM_CHANNEL_CREATE | 4447 | S→C | 创建结果 | recog==0 成功静默;≠0 弹错误码文案 |
| CM_QUERY_CHANNEL_LIST | 4453 | C→S | 打开面板"公共"页签(load) | 无参无体 |
| SM_SEND_CHANNEL_LIST | 4453 | S→C | 返回公共频道列表 | param=条数,body=TClientChannelInfo×N |
| CM_QUERY_CHANNEL_MEMBERS | 4454 | C→S | 打开行会/战队/队伍页签 | param=2/3/4(channelType) |
| SM_SEND_CHANNEL_MEMBERS | 4454 | S→C | 双语义:series==1 为"进入频道后的全量数据";series≠1 为预览(recog 可为错误码) | 详下文 |
| CM_CHANNEL_ENTER | 4448 | C→S | 列表点"进入"(recog=id);或组队/行会页直接进入(requestEnter(nil, channelType)) | param=channelType,body=密码(可选) |
| SM_CHANNEL_ENTER | 4448 | S→C | 结果错误码(recog==0 时成功数据走 4454 series=1) | |
| CM_CHANNEL_EXIT | 4449 | C→S | 频道内"退出"按钮 | 无参无体 |
| SM_CHANNEL_EXIT | 4449 | S→C | 错误码回执 | |
| CM_CHANNEL_CHANGE_MODE | 4450 | C→S | 管理员点"指挥模式/自由模式" | recog=频道ID,param=1 指挥/0 自由 |
| SM_CHANNEL_CHANGE_MODE | 4450 | S→C | 错误码回执;成功变更走 NOTIFY 4457 | |
| CM_CHANNEL_CHANGE_MUTE | 4451 | C→S | 管理员对选中成员禁言/解禁 | recog=频道ID,param=(当前isMute+1)%2,body=成员名 |
| SM_CHANNEL_CHANGE_MUTE | 4451 | S→C | 错误码回执;成功走 NOTIFY 4458 | |
| CM_CHANNEL_KICK_OUT | 4452 | C→S | 管理员踢人 | recog=频道ID,body=成员名 |
| SM_CHANNEL_KICK_OUT | 4452 | S→C | 错误码回执;成功被踢者收 NOTIFY 4456(tag=1) | |
| SM_NOTIFY_CHANNEL_ENTER | 4455 | S→C | 有人加入当前频道 | body=名字,param=isAdmin,tag=isMute |
| SM_NOTIFY_CHANNEL_EXIT | 4456 | S→C | 有人离开 | body=名字,tag=1 被踢/2 主动退/3 频道解散 |
| SM_NOTIFY_CHANNEL_CHANGE_MODE | 4457 | S→C | 频道模式被切换 | param=0 自由/1 指挥 |
| SM_NOTIFY_CHANNEL_CHANGE_MUTE | 4458 | S→C | 成员禁言态变更 | body=名字,param=isMute |
| SM_NOTIFY_CHANNEL_CHANGE_ADMIN | 4459 | S→C | 管理员授予/撤销 | body=名字,param=isAdmin |

### 音频面(HTTP/SDK,非游戏 TCP)

| 链路 | 载体 | 说明 |
|---|---|---|
| 上传 amr | Yaya SDK `uploadVoiceAndTranslate(path,dur,expand=msgID,retainTime=8)` | URL 由 SDK 服务端分配;retainTime 提示服务端保留时长(单位未核实) |
| 上传回调 | `yaya.call_uploadVoiceEnd{result,errMsg,url,text,dur,expand}` | result≠0 失败 tip errMsg |
| 聊天携带 | CM_SAY(3030) param=1,body 含 `{@vi<url>|<dur>|<msgID>}<text>`(`/` 替换为 `!`) | 归聊天模块协议,此处登记关联 |
| 下载 amr | HTTP GET url(200 才落盘 cache.getVoiceAmr()) | voice.download;iOS 再 convert2wav |
| 图片消息 | `yaya.uploadPic(path,size,msgID,filetype=jpg)` → `{@pi<url>|<size>|<msgID>}` | 同一富文本体系(chatPic) |

## 详细报文说明

### CM_CHANNEL_CREATE(4447)

发出(`panel/voice.lua` L491-495):

```lua
net.send({ CM_CHANNEL_CREATE }, nil,
    getRecord("TCnlCreateParam", { channelName = msgbox.nameInput:getString() }))
```

body 记录 TCnlCreateParam(globa2 L3478,**非 packed**):

| 类型 | 字段 | 说明 |
|---|---|---|
| string[15] | channelName | 频道名(GBK,UI 限 7 字) |
| byte | needPw | 1=有密码/0=无(UI 收集于 var_7,但实际构造记录时未传入——见下方要点 3) |
| string[6] | pw | 密码(数字) |
| byte | memberMax | 最大人数(UI 限 2~200) |

应答 SM_CHANNEL_CREATE(4447):recog==0 成功(客户端无额外动作);recog≠0 用 `codes` 表翻译弹窗:-1 已有频道未退出 / -2 频道数量满 / -3 **需 35 级** / -4 已在频道 / -5 密码须数字 / -6 人数超范围。

### CM_QUERY_CHANNEL_LIST(4453) → SM_SEND_CHANNEL_LIST(4453)

发出:无参无体。应答:`msg.param`=条数 N,body=N 条 TClientChannelInfo(globa2 L3446):

| 类型 | 字段 | 说明 |
|---|---|---|
| int | ID | 频道 id(进入时回填 recog) |
| string[15] | name | 频道名 |
| int | memberCount | 当前人数 |
| string[15] | creatorName | 创建者 |
| byte | channelType | 0/1(公共/个人) |
| byte | maxMem | 人数上限(byte,>255 会溢出——服务端注意钳制) |
| short | publicID | 公告/序号 id(用途未核实) |

### CM_QUERY_CHANNEL_MEMBERS(4454)/CM_CHANNEL_ENTER(4448) → SM_SEND_CHANNEL_MEMBERS(4454)

发出:

```lua
net.send({ CM_QUERY_CHANNEL_MEMBERS, param = param })        -- param: 2 行会 / 3 战队 / 4 队伍
net.send({ CM_CHANNEL_ENTER, recog = id, param = channelType }, password and { password })
net.send({ CM_CHANNEL_ENTER, recog = nil, param = channelType })  -- 组队/行会直入(requestEnter(nil, type))
```

应答 SM_SEND_CHANNEL_MEMBERS 双语义(`ui.lua` L2391 → panel L180):

- **series == 1**(进入频道成功的全量推送):先 TClientChannelHeadInfo(globa2 L3498:`int ID; string name[15]; byte mode(0 自由/1 指挥); short publicID`),再 `msg.param` 条 TClientMemberInfo(`string name[15]; byte isAdmin; byte isMute`)。写入 `g_data.voice` 并切换 UI 到频道内视图。
- **series ≠ 1**(页签预览):`recog != 0` 时按错误码表弹窗;recog==0 时 body 同上结构(head+members),仅作只读展示。

### CM_CHANNEL_EXIT(4449) / CM_CHANNEL_CHANGE_MODE(4450) / CM_CHANNEL_CHANGE_MUTE(4451) / CM_CHANNEL_KICK_OUT(4452)

发出字段一览:

| 消息 | recog | param | body |
|---|---|---|---|
| CM_CHANNEL_EXIT | 未用 | 未用 | 无 |
| CM_CHANNEL_CHANGE_MODE | 频道 ID(roomData.ID) | 1=切指挥,0=切自由(仅管理员,客户端已校验 mode 与权限) | 无 |
| CM_CHANNEL_CHANGE_MUTE | 频道 ID | 目标 isMute 值(当前值取反) | 成员名(单字符串) |
| CM_CHANNEL_KICK_OUT | 频道 ID | 未用 | 成员名 |

对应 SM(同号)仅在 `recog != 0` 时按错误码表弹窗(ui.lua L2363-2386);成功的结果一律通过 NOTIFY 组广播:

- **SM_NOTIFY_CHANNEL_ENTER(4455)**:body=名字(net.str 整段 GBK 转 UTF-8);param=isAdmin,tag=isMute。
- **SM_NOTIFY_CHANNEL_EXIT(4456)**:body=名字;`tag`=离开类型:**1=被管理员踢出**(本人收到时弹窗"你被管理员踢出语音频道")、**2=主动退出**("你已退出语音频道")、**3=频道解散**("你所在的语音频道已解散");本人离开会重置 g_data.voice 并退出频道内 UI。
- **SM_NOTIFY_CHANNEL_CHANGE_MODE(4457)**:param=新 mode;客户端随后强制 `yaya.mic(false)` 下麦并刷新上麦按钮。
- **SM_NOTIFY_CHANNEL_CHANGE_MUTE(4458)**:body=名字,param=isMute(1 禁言/0 解禁);若目标是自己同样强制下麦。
- **SM_NOTIFY_CHANNEL_CHANGE_ADMIN(4459)**:body=名字,param=isAdmin(1 授予/0 撤销)。

### 错误码表(panel/voice.lua codes,L1167-1296,服务端回填 recog)

| recog | 文案摘要 | | recog | 文案摘要 |
|---|---|---|---|---|
| -1 | 已有频道,请先退出再创建 | | -16 | [切换频道] 频道不存在 |
| -2 | [创建] 频道数量已满 | | -17 | [踢出] 只有管理员才可操作 |
| -3 | [创建] 需要 35 级 | | -18 | [踢出] 不是该频道成员 |
| -4 | [创建] 已经进入频道 | | -19 | [踢出] 对方不是该频道成员 |
| -5 | [创建] 输入密码需为数字 | | -20 | [踢出] 频道不存在 |
| -6 | [创建] 输入人数需在范围内 | | -21 | [踢出] 不能将管理员踢出 |
| -7 | [进入] 频道不存在 | | -22 | [禁言] 只有管理员才可操作 |
| -8 | [进入] 密码不正确或其它错误 | | -23 | [禁言] 频道不存在 |
| -9 | [进入] 频道(行会/战队/队伍)不存在 | | -24 | [禁言] 不是该频道成员 |
| -10 | [进入] 该频道成员已满 | | -25 | [禁言] 对方不是该频道成员 |
| -11 | [退出] 频道不存在 | | -26 | [禁言] 不能将管理员禁言 |
| -12 | [退出] 不是该频道成员 | | -27 | 玩家名错误或不在线 |
| -13 | [退出] 您不在频道中(踢人时=对方不在频道中) | | -28 | (成员列表)频道不存在 |
| -14 | [切换] 只有管理员才可操作 | | -29 | (成员列表)频道未创建 |
| -15 | [切换] 不是该频道成员 | | -30 | 系统繁忙，请稍后再试;-99 未知错误 |

### 音频面流程(与聊天消息的关联)

1. 录制:`voice.startRecord(player)` 生成 `msgID=md5(socket.gettime()) 前8位`;60s 超时自动停止。
2. 上传:`voice.upload → yaya.uploadVoice(amrPath, dur秒, expand=msgID)`;SDK 异步回调 `call_uploadVoiceEnd{result, errMsg, url, text, dur, expand}`。
3. 发送:`voiceListenner.onUploadEnd`(result==0)组装富文本经 `common.say` 发 **CM_SAY(3030) 且 param=1**(hasRich 标记):`{@vi<url>|<dur>|<expand/msgID>}<text>`(url 内 `/`→`!`)。私聊频道时自动带 `/目标名 ` 前缀,喊话带 `!` 等(getSayText)。
4. 接收:聊天渲染端 decodeMsg 还原 `{@vi}`,点击气泡 → `voice.play(user,msgID,channel,url,dur)`;缓存缺失时 HTTP GET url(非 200 即失败回调)。**服务端只需原样转发 SAY 文本,不需要理解 {@vi} 内容**;url 必须是客户端可直接 GET 的地址(Yaya CDN)。
5. 自动播放:设置 chat.autoPlayVoice 各频道开关命中时 `voice.autoPlay` 依次续播。

## 服务端实现要点

1. 4447~4459 是一组自洽协议:请求应答用同号 SM(仅回错误码),成功状态一律靠 4455~4459 广播,包括发起者自己也要收到 NOTIFY(否则本地状态不更新)。
2. 频道成员名单以服务端为准;TClientMemberInfo(name,isAdmin,isMute)与 head(mode,publicID)在 4454(series==1)和各 NOTIFY 中保持一致。
3. 权限检查必须做在服务端:切模式/禁言/踢人的管理员身份、创建频道 35 级(-3)、人数上限、密码校验(-8)、玩家在线(-27)。
4. SM_NOTIFY_CHANNEL_EXIT 的 tag 三值语义(1 踢/2 自退/3 解散)直接影响客户端弹窗文案,不可混用;"踢人"成功时应给被踢者发 tag=1,给频道其余人发 tag=2 视角(或按需)(未核实旧服具体区分)。
5. 音频二进制不过游戏服:url/text 由第三方(Yaya)云生成;服务端只透传聊天文本。若要私有化部署语音,需同时替换 SDK 回调里的 url 域与 retainTime 语义。
6. msgID 是客户端随机生成的去重键(时间戳 md5 前 8 位),服务端不应假设其唯一性跨客户端成立;同一 msgID 的重复聊天包按普通消息处理即可。
7. maxMem 字段是 byte:频道人数上限 >255 会溢出,创建时服务端应把 memberMax 钳制到 ≤255(UI 允许到 200)。
