# G2.5 `core_dec.lua` / `gplus.bin` 最终验收

## 验收结论

| 验收对象 | 结论 | 边界 |
|---|---|---|
| `core_dec_readable.lua` 普通可执行逻辑 | **通过** | 在 Lua 5.1/LuaJIT 普通执行语义下，与原始有效载荷严格等价；不包含调试元数据逐字同一承诺。 |
| 重写是否引入新 bug | **在本审计边界内未发现** | 字节码、绑定、作用域、名称和 8 组隔离差分均相等；未覆盖分支、native 内部和外部服务不越界声称。 |
| 原程序是否无 bug | **不通过该说法** | 原版自身登记 16 项继承 bug/风险/契约/敏感行为；严格等价版有意保留。 |
| `core_dec_readable.lua` 静态源码明文化 | **通过** | UTF-8 可读，4714 个 escape AST 节点降为 3 个必要语义转义。 |
| 所有运行时/外部数据全明文 | **未实现，也不能据现有证据声称** | 仍有远端响应、动态解密/加载、外部 ZIP、动态索引及 `gplus.bin` 未知内层。 |
| `core_readable_repacked.bin` 封包结构 | **通过** | 使用原 XXTEA/长度帧回包，本地回读与 readable 源码逐字节一致。 |
| readable repack 完整部署兼容性 | **Lua 层条件通过；native 未证** | 可见 Lua loader 不因 MD5/长度/内容变化单独拒绝；native `getFileData` 内部和启动器前置校验不可见。 |
| `gplus.bin` 第一层还原 | **通过** | 第一层 XXTEA 帧可逆，11 段结构和 Base64 内层已提取。 |
| `gplus.bin` 全部明文/严格等价重写 | **未通过** | Base64 后为未知高熵内层；core 三处把文件 MD5 作为 POST `code`，改字节会改变可观察行为。 |

## 核心严格等价证据

- **26** 个 Lua 原型（含 chunk，源函数 25 个）。
- **1661** 条 Lua 5.1 指令的 opcode 与 operands 逐 PC 相同。
- **366** 个常量相同：361 个字符串、5 个数字。
- **129** 个局部/参数绑定的声明种类、作用域、local index、起止 PC 相同。
- **527** 次语义标识符使用重新词法解析后绑定相同：local 189、upvalue 336、global 2；差异 0。
- **2** 条完整遮蔽关系相同：
  1. `P01:L044 file_data_result` 遮蔽 `P01:L040 file_data_result`；
  2. `P11:L000 local_version` 参数遮蔽外层 `P01:L015 local_version`。
- **116** 个 upvalue 捕获槽相同；P13/P16 递归局部函数的 post-CLOSURE 自捕获已额外验证目标寄存器、MOVE 槽、post-PC 生命周期起点、local index 和 AST local-function/child 对应关系。
- **127** 个词法作用域相同；直接语义语句合计 **332**：function call 89、if 87、variable declaration 83、return 38、assignment 18、function declaration 17。
- **368** 次运行时名称出现相同：field access 360、table key 5、method 2、dynamic index 1；367 次静态、83 个唯一静态名。
- LuaJIT `string.dump(chunk, true)` 双方均为 **10684** 字节，SHA-256 均为  
  `fcae59b42c52ab534310fdb3ce02faff7b7f413a45b11439fbaea704bb1f9c75`。

## 动态差分证据

- 8/8 隔离 mock 场景的调用轨迹、成功/失败状态、规范化错误和状态快照相同。
- 26/26 原型入口至少触达一次；这是**原型入口覆盖**，不是所有分支/路径覆盖。
- `json_decode_nil_inherited_error` 场景中，双方均以相同规范化 nil-index 错误失败；因此它是“等价通过”，不是“业务成功”。
- 测试截获文件、网络、引擎和退出副作用，不会真实联网、写业务文件或退出宿主。

## 文件与哈希基线

| 文件 | 长度 | SHA-256 |
|---|---:|---|
| 原始 `core.bin` | 23700 | `3d4b889a3bcfab778ae8aa4e69ad3f9ff0da40f9958f0edbc106d000af1f5616` |
| `core_dec_original_payload.lua` | 23696 | `d9d07d89be75df6dbaeae146ce235a63cbc119a01893ca21918a4008b3cc6b00` |
| `core_dec_readable.lua` | 24455 | `123ba1bfdbae6326cfd18a75cd486bc1884e4dcb8fd78b9d5d6fb5919ba598fa` |
| `core_readable_repacked.bin` | 24460 | `cfbf245f909324154b8576e8d140e70af0e4e7d93b901ddcac7266d878c2bd46` |
| 原始 `gplus.bin` | 20728 | `7803e9dda5dc7649dbaca2ccad19eebd48473713446bc8c283df438ef034b96f` |

原 `core.bin` 解包回读与原始有效载荷相同，原载荷重新封包后与原 `core.bin` 逐字节相同；readable repack 解包回读与 readable 源码逐字节相同。

## 明文化边界

### 已完成

- 控制流、注释、局部语义命名、普通字符串、中文协议文本及所有静态运行时名称可直接阅读。
- 源码无 NUL、无异常原始控制字节、无 `\xNN`/`\uNNNN`。
- 只剩 3 个必要转义：`\022`、`\t`、`\n`。

### 未静态展开

- 1 次计算型动态索引；
- 34 次 `to_number("...")`（22 个唯一字符串）；
- 5 次运行时 Base64 decode、2 次 XXTEA decrypt、1 次动态 Lua `load`、2 次外部 ZIP load；
- 外部服务器响应、运行时宿主数据、`core/core64.zip`；
- `gplus.bin` Base64 后的未知高熵内层。

因此准确表述是：**core 静态源码表面已明文化；全部运行时/外部载荷没有全明文化。**

## `gplus.bin` 边界

- 第一层有效 ASCII 明文：20722 字节，按 `#` 分为 11 段。
- 最后一段 Base64：20432 字节。
- Base64 解码内层：15324 字节。
- 内层 SHA-256：`1665d1c16c50ab2aad0f15a4878f47f40128e719569e814e59348843ad0cabbd`。
- 内层熵约 7.98798758 bits/byte；未识别为 LuaJIT、Lua 源码、ZIP、PE、ELF 或常见压缩格式。
- 第一层 pack/unpack 可逆；内层格式、密钥和语义没有可验证证明。

在 strict equivalence 目标下，不提供伪造的“可读 gplus 重写版”：文件 MD5 是远端协议输入，任何改字节都会改变行为。

## 部署 loader 边界

可见 LuaJIT 数据流证明：

1. `getFileData(ycFunction, "core.bin", true)` 接收两个返回值；
2. 第一个只做真值判断，假时调用退出逻辑；
3. 第二个未使用；
4. 送入 `load` 的内容来自独立 `var_0_123()`；
5. 没有可见的 MD5、长度或内容比较；`core_func_checkbin` 无条件返回 true 且没有可见 Lua 调用。

独立 loader 交叉核验还确认：两份原始自定义 opcode chunk 均为 307172 字节、SHA-256  
`470b1bc14cc84edb2fdb35c0e64374b90717456415bc06801b0a6583d46f367f`；去掉不同 chunkname 后的解密字节码体均为 307891 字节、SHA-256  
`7aa2afb6bcc8c96b26cc715cf69d04dc5e580d4f67651b7998952c12e9f2b8ba`。

这只能证明可见 Lua 层的条件兼容；不能排除 native API 内部、按全局名回调、启动器资源清单或架构差异。

## 原版继承问题

`core_known_issues.csv` 登记 **16** 项，全部满足：

- `present_in_original = true`
- `introduced_by_rewrite = false`

其中包括 JSON decode nil 后继续访问、decode/type 未保护、潜在无界重试、文件句柄泄漏、退出 API 非返回假设、忽略密钥派生 `pcall` 状态、非 200 静默停止、非原子/未检查缓存写入、归档解密/写入/加载结果未检查、nil/type 拼接、弱 UUID、明文 HTTP 下载并执行、POST 未显式编码、anti-hook 覆盖错位、固定远程 kill-switch 和宿主环境依赖。

严格等价版没有修复这些行为；若修复就会偏离“与原版完全等价”的目标。应另建 hardened 分支，而不是修改本 strict-equivalent 产物。

## 审计生成器与可复现性验收

- 审计 schema：**2**；规范产物不嵌入动态时间或主机绝对路径。
- Python AST 中 `assert` 节点：**0**；所有强制检查使用不会被 `python -O` 删除的显式 `require`。
- 最终 `PASS/FAIL` 由 **20** 项聚合验证计算，不是硬编码常量。
- normal 与 `python -O` 重跑：规范文件 **31/31** 逐字节相同。
- 替换 `output-root`，以及同时替换 `base-root`/`output-root`：规范文件 **31/31** 逐字节相同。
- 篡改负对照在 `python -O` 下非零退出，且没有输出 `PASS`。
- `AUDIT_SHA256SUMS.txt` 应包含除自身外的 **30** 个审计文件；最终验收时逐项存在且哈希正确。

## 独立交叉复核矩阵

| 复核方向 | 结果 |
|---|---|
| Poincare：输入框架、长度帧、文件哈希 | PASS |
| Harvey：Lua 5.1/LuaJIT 字节码独立解析 | PASS；独立解析 1522 条 LuaJIT 指令、116 个 upvalue descriptor、379 个 KGC 槽和 1 个 numeric 槽，差异 0 |
| Feynman：隔离运行时差分及风险边界 | PASS；确认 8 组行为相同，同时强调原版 bug 和路径覆盖限制 |
| Anscombe：静态明文化与运行时名称面 | PASS；确认静态源码可读，但外部/动态载荷并非全明文 |
| Aquinas：变量/作用域/跨函数遮蔽审查 | 首轮发现缺少跨函数完整遮蔽证明；已补充 527 次标识符解析和 2 条遮蔽关系后通过主审 |
| Carson：部署 loader 可见数据流 | PASS（条件结论）；完整 native 兼容性未证 |
| Gauss：最终一致性、失败闭锁和可复现性 | 首轮发现 3 项生成器缺陷；修复后独立复核 **PASS，未发现剩余问题** |

## 调试元数据例外

重命名和重新排版必然改变局部调试名、源路径、行号、错误堆栈文本、line hook 和未 strip dump。程序普通逻辑没有显示依赖这些元数据，但如果调用 `debug.*`、安装 hook 或逐字比较错误文本，则可观察到差异。

## 最终交付入口

- 人类可读总报告：`CORE_EQUIVALENCE_AUDIT.md`
- 机器可读总报告：`core_equivalence_audit.json`
- 本最终验收：`FINAL_ACCEPTANCE.md`
- 完整逐行证据：`core_*.csv`
- 原始/字节码证据：`raw/`
- 动态差分证据：`runtime/`
- 审计生成器：`audit_core_equivalence.py`
- 完整性清单：`AUDIT_SHA256SUMS.txt`

**最终定性：`core_dec_readable.lua` 在已定义的普通执行语义边界内验收通过；“原程序无 bug”“所有运行时数据全明文”“gplus 内层已还原”“完整 native loader 一定接受”四种说法均不成立。**
