# core_dec.lua 与 gplus.bin 还原说明

## core_dec.lua

- `core_dec.lua` 原文件实际包含 **23696 字节 Lua 源码 + 4 字节小端原文长度**。末尾 `90 5c 00 00` 是十进制 **23696**，不是损坏字符。
- `core_dec_readable.lua` 已完成格式化、十进制转义字符串解码、局部变量语义化重命名以及 `table["field"]` 到 `table.field` 的等价改写。
- 运行时可见的全局名和字段名全部保留，包括原始拼写 `argeementText`。
- 使用随包 LuaJIT 验证：语法通过，且 `string.dump(chunk, true)` 与原始有效载荷逐字节相同，长度均为 **10684** 字节。
- `core_readable_repacked.bin` 使用原始 XXTEA 算法和长度帧重新封装；本地按同一算法回读后与 `core_dec_readable.lua` 完全一致。可见 Lua loader 不会仅因字节数或 MD5 改变而拒绝，但完整 native loader 的最终接受性仍是未证项。

### 原始行为提示

该脚本会访问内置远程地址，将返回内容解密后通过 `load`/`pcall` 执行；本次还原没有删除或改变这段行为，只增加了注释。

## gplus.bin

- 第一层同样是 XXTEA 长度帧：解密帧 **20728** 字节，其中有效内容 **20722** 字节、零填充 **2** 字节、末尾 4 字节为原文长度。
- 有效内容由 `#` 分成 **11** 段，长度为：`[15, 17, 17, 16, 27, 27, 29, 29, 27, 76, 20432]`。
- 第 10 段含嵌入时间戳 `1775916252`：UTC `2026-04-11T14:04:12+00:00`，中国标准时间 `2026-04-11T22:04:12+08:00`。它代表生成时间还是失效时间，现有文件本身无法证明。
- 最后一段是 Base64；解码得到 **15324** 字节高熵二进制，SHA-256 为 `1665d1c16c50ab2aad0f15a4878f47f40128e719569e814e59348843ad0cabbd`。
- 该内层数据没有 LuaJIT、Lua 源码、ZIP、PE、ELF 或常见压缩格式文件头，也不能被 LuaJIT 直接加载。使用文件中明显候选值（`Zsq20200811`、时间戳、第一层密钥等）尝试常见 XXTEA/AES/RC4 组合，没有得到可验证的第二层明文。
- 在 `core_dec_readable.lua` 的调用链中，`getFileData("gplus.bin", true)` 的第一返回值没有使用，第二返回值（文件 MD5）被放入 POST 参数 `code`。因此它更像远端授权/识别凭据，而不是本地执行的 Lua 模块。修改任意字节都会改变 MD5，不能声称“重写后仍等价”。

## 文件说明

- `core_dec_original_payload.lua`：去掉长度尾标记后的原始有效 Lua 源码。
- `core_dec_readable.lua`：可读性重写版。
- `core_readable_repacked.bin`：由可读版重新封装得到的 core.bin。
- `gplus_layer1_plain.txt`：gplus 第一层有效明文（已去掉填充和长度尾标记）。
- `gplus_payload_base64.txt`：最后一段 Base64 文本。
- `gplus_payload.bin`：Base64 解码后的未知高熵载荷。
- `manifest.json`：哈希、长度、时间戳与验证结果。
- `xxtea_frame_tool.py`：可重复执行的拆包/回包工具。


## 严格等价审计（2026-07-10）

完整逐项审计位于 `audit/CORE_EQUIVALENCE_AUDIT.md`，机器可读汇总位于
`audit/core_equivalence_audit.json`。审计结果：

- 26 个 Lua 5.1 原型、1661 条指令（opcode + operands）和 366 个常量逐项等价。
- 129 个局部/参数绑定、527 次语义标识符使用、2 组跨作用域遮蔽关系、116 个 upvalue、127 个词法作用域均逐项解析到相同绑定。
- 368 次运行时名称出现（字段、表键、方法、动态索引）逐项保留；LuaJIT stripped chunk 为 10684 字节且逐字节相同。
- 8/8 隔离差分场景结果相同，并触达 26/26 个原型入口；这证明的是“原型入口覆盖”，**不是**所有分支/路径覆盖。
- 未发现重写引入的新 bug；但不能声称原程序无 bug。审计登记了 16 项原版继承问题/风险，包括 JSON nil 后继续访问、未保护解码、重试/文件句柄/写入检查、远程明文 HTTP 动态代码执行等。
- `core_dec_readable.lua` 的静态源码已明文化；运行时远端内容、外部 ZIP、动态加载内容以及 `gplus.bin` 的高熵内层并未全部明文化。静态转换统计还包括 34 次 `to_number("...")`（22 个唯一字符串）、5 次 Base64 解码、2 次 XXTEA 解密、1 次动态 Lua `load` 和 2 次外部 ZIP 加载。
- 可见 Lua loader 层没有对新 `core.bin` 的 MD5、长度或内容做拒绝性比较，因此不会仅因 repack 后字节变化而拒绝；native `getFileData(..., true)` 内部、启动器前置校验及完整部署链仍未证明。
- 调试元数据（局部名、源文件名、行号、堆栈文本及 debug/hook 可观察值）因重命名和排版而不同，这是预期差异，不属于“调试完全同一”。

最终验收摘要见 `audit/FINAL_ACCEPTANCE.md`；逐行表格与原始证据见
`audit/*.csv`、`audit/raw/`、`audit/runtime/`；`audit/AUDIT_SHA256SUMS.txt`
可用于校验审计产物完整性。
