# 白猪版(G2.5)协议简报 —— 给文档分析代理的公共事实

本文档面向 `docs/服务端功能/白猪版/` 系列文档的编写。白猪版源码 = `client-other/res/rebuilt-src-bz/白猪G2.5_0518_lua_plain_readable_20260710_014719/`(mir2 203 + core 82 + upt 6,含 mir264/core64 64 位镜像副本,内容与 32 位一致,分析时忽略 64 位副本)。生产热更树 `rebuilt-src-bz-prod/` 提供参考(.bc 字节码为主,可读 .lua 可查)。

## 1. 核心结论:与基础版协议同源

已用脚本全量对比(结论可复核,引用 `_tmp/proto-docs/bz_constant_diff.txt` / `bz_record_field_diff.md` / `bz_usage_diff.txt`):

- **消息号常量 2002 个全部同值**,同名不同值 0,基础版独有 0,**白猪独有仅 4 个**:
  - `SM_MAPWEATHER = 57`(场景天气)
  - `SM_MAP_RANGE_PICK = 5044`(范围拾取)
  - `CM_USERRELIVE = 4675`(请求复活)
  - `SM_YSGUISHU = 1314`(鬼术类技能动作)
- **记录(结构体)127 个全部同字段同布局**(2 个仅成员函数写法差异 `function(self)` vs `function (self)`,不影响线上字节)。记录尺寸/对齐规则与基础版完全一致(见基础版目录.md §1.4)。
- **帧格式/握手/心跳与基础版一致**:TClientMessage 12B(sign=0xFF44FF44, cmd 23/24/25)+ TDefaultMessage 12B;cmd=24 握手、SM_RUNGATEDYN 回执、LM_PING。详见基础版 `主模块/M1-登录与接入.md` 与 `子模块/M1-S2-TCP握手加密与心跳.md`。

## 2. 白猪版 net.lua 的 TigerGate 加密层(核心差异,必须写入 M1-S2)

`mir2/mir2.single.net.lua`(白猪版)相对基础版新增了**可选的整帧编码层**,全部挂在两个条件上:

```lua
if count2 == 1 and def.openNewTigerGate then
    net2.server:send(callback(帧字节串, count))
else
    net2.server:send(帧字节串, sendLen)   -- 与基础版相同
```

- `count2`:`net.connect` 时若传了 `sessionid`(即**第二次连接/游戏网关/重连**)=1;首连(areaid)=0。
- `def.openNewTigerGate`:**全树无赋值点**(grep 核实,仅 net.lua 引用),运行时为 nil → 当前两棵树(0518 明文 + 生产热更)实际**默认关闭**编码层。若生产 config/服务端要求开启,协议变为下述形态(文档须如实说明两种形态并存)。
- `callback(self, value)` 编码算法:
  1. 密钥表 `text` = 64 字符常量串 `"1Y0lSUQMH+mbKXRTBtFiWvLx32/gNAzGr674oeyn5dCEp8jDqasI9VcwJPhufkOZ"`;
  2. `value` = 轮转种子(`count`,上次发送的 dataIndex;首包为 0 不轮转);`text2 = 右旋 value%63 位后的表`;
  3. 把整帧二进制按 **3 字节→4 字符** 变体 base64 编码(用 text2 查表,不足 3 字节补 `=`),**末尾拼 `"|LH"`**;
  4. 结果作为文本串发送(整个帧变成文本,不再是二进制帧流)。
- `count` 更新时机:握手包(handler 内 `count = net.dataIndex`)与 **cmd=29 心跳帧**(onUpdate 内 `count = net.dataIndex`)。
- **cmd=29 心跳帧**:`onUpdate` 每 **30 秒**(`scheduleScriptFunc(onUpdate, 30, false)`)构造 `TClientMessage{cmd=29, sign=魔数, dataIndex=socket.gettime()}`(12B,无 TDefaultMessage);`count4==1`(已编码过一次)时经 callback 编码发送,否则原样发送。**客户端不解析下行 cmd=29**(processLoop 只处理 23/24/25,其余 discard)→ 服务端可回可不回。
- 服务端实现要点:若开启 TigerGate 模式,收流需先做"文本帧 vs 二进制帧"判别:文本以 `|LH` 结尾 → 去后缀 → 逆变体 base64(64 字符表轮转同上)→ 得标准二进制帧;种子 = 上一帧的 dataIndex(需按帧维护)。所有业务消息/握手/RUNGATEDYN 回执/LM_PING 均可能被编码。
- `net2.send` 另增加 `if not net2.server then return end` 保护(基础版无)。

## 3. 使用面差异(白猪版文档各子模块的核心内容)

白猪版真实引用 630 个常量,基础版 601 个,共用 600 个;**仅白猪版使用 30 个,仅基础版使用 1 个(CM_DBLCLICKUSEITEM 1017)**。30 个白猪独用须甄别三类:

### 3a. 真上行(客户端→服务端,net.send 内)
| 常量 | 值 | 发送点 | 说明(以代码为准再写) |
|---|---|---|---|
| CM_RUN3 | 4108 | core/controller.lua ~1705 | 三档跑步?需读上下文 |
| CM_HEAVYHIT2 | (悬空?查 globa1) | core/controller.lua ~1560-1567 | 需读上下文确认是否真消息/局部变量 |
| CM_PICKUP_RANGE | 4278 | core/controller.lua ~1744 | 范围拾取请求 |
| CM_SHANGMA_OK | 4106 | core/role/hero.lua ~474 | 上马确认? |
| CM_TURN2 | (两树 globa1 均无定义) | core/controller.lua | **已核实为局部变量名**(`local num, hitType, CM_TURN2 = math.random(3)`),非协议,文档注明即可 |

### 3b. 真下行(processMsg/checkExist 分支)
| 常量 | 值 | 处理点 | 说明 |
|---|---|---|---|
| SM_SHANGMA_OK | 3413 | ground_hk.lua ~1275 / ui.lua ~2727 | 上马成功(坐骑?) |
| SM_XIAMA_OK | 3414 | ground_hk.lua ~1283 / ui.lua ~2735 | 下马成功 |
| SM_MAP_RANGE_PICK | 5044 | ui.lua ~2541 | 范围拾取应答(白猪独有常量) |
| SM_ASS_BLOODHIT_MOVE | 3558 | ground_hk.lua ~992 / role_hk.lua ~1674 | 血剑位移动作(基础版有定义未用) |
| SM_LYHIT / SM_SFZHIT / SM_XHHIT | 悬空(两树 globa1 均无定义) | role_hk.lua ~1573-1597 | 新技能动作(龙渊/弑法/血痕?) |
| SM_YSGUISHU | 1314 | ground_hk.lua ~1133 | 鬼术动作(白猪独有常量) |
| SM_MAPWEATHER | 57 | (找处理点) | 天气(白猪独有常量) |
| CM_USERRELIVE | 4675 | (找发送点) | 请求复活(白猪独有常量) |

### 3c. 非网络(借名本地事件/字符串)
`mir2/mir2.single.bzEvents.lua` 是本地事件总线(EventProtocol),其 `CM_FILTER/CM_MSGBOX/CM_ZONEMSG/CM_TIPS_SHOW/CM_CACHEJOB/CM_SETABIL/CM_NO_BACKCD/CM_UNLIMITEDMOVE/CM_BAN_ATTACK/CM_RSITEM/CM_BANMOVE/CM_CHANGEBAG/CM_TAKEOFF/CM_NEED_BAG_PASS/CM_PASS_OK/CM_FIX_RUN` 等键名**与消息常量同名但为本地事件名**;触发源是 `mir2.bz.functions.lua` 解析的服务端指令串(`color2[2]`),真正出网的只有:
- `CM_TAKEOFF`/`CM_RSITEM` 事件 → 实际发 `CM_TAKEOFFITEM`/`CM_TAKEONITEM`(标准消息,见基础版 M5-S2);
- `CM_BANMOVE`/`OFFFILTER`/`CM_FILTER` 事件 → 发 **CM_SAY(3030) + 特殊前缀文本**:`"FLTR|gray|roleid|毫秒"`、`"FLTR|<色>|roleid|毫秒"`、`"FROFF|<名>|roleid"`、`"FLTR|<色>|<名>|<值>"`(分隔符 `bzmir.hline`,需查 bzmir 定义,推测为 `|` 或特殊字符)——白猪"服务端遥控客户端"通道,服务端需识别这些 CM_SAY 前缀并回执;
- 指令串本身经哪条 SM 下发?(查 bz.functions 的指令来源,推测 SM_MERCHANTSAY/系统消息文本,以代码为准)。

## 4. 白猪版文件结构差异(文档范围)

- `mir2/mir2.def.bzinit.lua`(6300+ 行):白猪初始化/防篡改(`checkMd5`、`core_func_byby` 门禁,本地行为);`mir2.def.bzinit` 里可能有服务端配置读取。
- `mir2/mir2.bz.functions.lua`(2900 行):白猪指令解析/本地事件处理/一键换装等。
- `mir2/mir2.cc.lua`、`mir2.def.zz.lua`(mir.def.zz)、`mir2.data.serialize.lua`:本地工具/本地事件,除非有 net.send 否则不写。
- `mir2/mir2.scenes.bz.scene.lua`:**白猪专属场景**,查其网络交互(登录/进入游戏流程差异)。
- `mir2/mir2.single.viap.lua`:查是否 HTTP/网络(可能是验证/公告通道)。
- core 82 文件:白猪重写的 UI/场景(ui.lua、ground.lua、controller.lua、panelFactory/luaPanelFactory、bag8/9/10、storage8/9/10、chatNew/chatOld、chargeNew、freedeal、near、webView、Menu 等)——**面板只是 UI,报文仍走基础版同号消息**,差异在触发时机/参数组合,写文档时与基础版对应面板文档对照。
- 生产树 `rebuilt-src-bz-prod/mir2/` 有 `mir2.data.mall.bc`(商城)等 136 个 .bc——字节码无法读,文档标注"存在但无明文,布局参照基础版对应消息"即可。

## 5. 写作要求(每篇文档)

1. **定位 = 差异文档**:白猪版与基础版协议同源,不要重复展开基础版已写的完整报文布局;每篇文档 = ① 该域白猪版使用面差异表(仅白猪用/仅基础版用/两者差异行为)② 白猪新增/扩展报文详述(字段、参数、触发)③ 指向基础版对应文档的相对链接(`../../基础版/主模块/Mx-xxx.md`)。
2. 所有消息号数值必须 grep 白猪版 `mir2/mir2.def.globa1.lua` 核实(与基础版同值,但以白猪版文件为准)。
3. 标注来源文件:函数(白猪版路径)。
4. 悬空引用(globa1 无定义)如实写"无定义,线上值未知,勿实现"。
5. 不确定标"(未核实)"。简体中文,UTF-8。
6. 只写服务端交互,不写本地 UI 逻辑。
