# G2.5 `core_dec.lua` 严格等价审计

审计模式：`deterministic-v2`（规范产物不嵌入生成时间或主机绝对路径）

## 最终结论

| 问题 | 结论 | 精确边界 |
|---|---|---|
| 重写版与未重写版的普通可执行逻辑是否等价 | **是** | 26/26 原型、1661 条 Lua 5.1 指令、366 个常量、129 个局部绑定、116 个 upvalue、527 次标识符使用均逐项相等；LuaJIT stripped chunk 逐字节相同。 |
| 是否发现重写引入的新 bug | **在本审计边界内未发现** | stripped LuaJIT 指令完全一致，8 组 mock 差分的轨迹/状态/错误/快照一致；不把调试元数据、native 内部或未覆盖分支误称为已证明。 |
| 原程序本身是否“无 bug” | **否** | 已动态复现 `cjson.decode` 返回 nil 后继续索引的继承 bug；另记录 15 项继承风险/契约/敏感行为。 |
| `core_dec_readable.lua` 静态源码是否明文可读 | **是** | UTF-8 全文可读；4714 个 escape AST 节点降为 3 个必要转义。 |
| 所有运行时/外部数据是否也已全明文 | **否** | 仍有动态索引、数字字符串转换、Base64/XXTEA、动态 `load`、外部 ZIP、远端响应和 `gplus` 内层不透明数据。 |
| `gplus.bin` 是否可在严格等价前提下改写 | **否** | 第一层已拆解并可逆；内层仍未知高熵。core 三处把该文件 MD5 作为 POST `code`，改字节会改变运行时可见行为。 |
| readable repack 是否一定被完整启动器接受 | **仅 Lua 层条件通过；native 未证** | 可见 loader 不比较 MD5/长度/内容；但 `getFileData(..., true)` 是 native，内部校验和 Lua 前置启动器检查不可由当前证据排除。 |
| 调试元数据是否逐字等价 | **否（预期）** | 局部名、源路径、行号、堆栈文本、line hook、未 strip dump 可观察到差异。 |

## “等价”的严格含义

本报告证明的是：在已核对的 Lua 5.1/LuaJIT 普通执行语义下，重写没有改变 opcode、操作数、常量、寄存器生命周期、闭包捕获、标识符绑定、作用域结构、运行时名称及已执行 mock 场景行为。

本报告**不**声称以下项目相同：源码字节、调试局部名、源码行号、错误原文、未 strip 字节码、外部服务器内容、native API 内部行为、所有可能分支/路径。

## 审计规模

- Lua 字节码原型：**26**（含 chunk；源函数 **25**）
- Lua 5.1 指令：**1661**
- 常量：**366**（字符串 361，数字 5）
- 局部变量/参数绑定：**129**
- 标识符使用：**527**（local 189、upvalue 336、global 2）
- 词法遮蔽关系：**2**
- upvalue 捕获槽：**116**
- 词法作用域：**127**（chunk 1 + block 126）
- 作用域内直接语义语句：**332**
- 运行时字段/键/方法/动态索引：**368**（静态 367、动态 1）
- 唯一静态运行时名称：**83**
- 隔离差分场景对：**8/8 行为相等**
- 动态原型入口覆盖：**26/26**；不是分支/路径覆盖

## 最强等价证据

1. **LuaJIT stripped bytecode 完全相同**
   - 长度：`10684` 字节
   - 双方 SHA-256：`fcae59b42c52ab534310fdb3ce02faff7b7f413a45b11439fbaea704bb1f9c75`
2. **逐原型**：26 行摘要、指令流、常量表、局部 PC 生命周期、upvalue 槽图全部通过。
3. **逐指令**：1661 行 opcode + operands 全部相等；CLOSURE 的进程地址已归一化，不作为语义证据。
4. **逐常量**：366 行的类型、表示和值全部相等。
5. **逐变量/参数**：129 行声明种类、词法作用域、起止 PC 全部相同。
6. **逐标识符使用**：527 次引用重新做词法解析，189 次绑定本函数 local、336 次绑定外层 upvalue、2 次绑定 global；0 个绑定差异。
7. **逐遮蔽关系**：2/2 相同：
   - `P01:L044 file_data_result` 遮蔽 `P01:L040 file_data_result`；
   - `P11:L000 local_version` 参数遮蔽外层 `P01:L015 local_version`。
8. **逐闭包捕获**：116 个 upvalue 的父 local/父 upvalue 槽和捕获指令相同；P13/P16 递归自捕获按 CLOSURE 后绑定伪指令解析。
9. **逐作用域**：127 个作用域的父子关系、函数深度、直接语句类型序列相同。
10. **逐运行时名称**：368 次字段/表键/方法/动态索引顺序和名称相同；`argeementText` 原拼写保留。
11. **动态差分**：文件、网络、引擎、退出均由 mock 截获，不做真实副作用；8 个场景对的轨迹、返回状态、规范化错误和快照相同。
12. **封包回读**：原 `core.bin` 重打包逐字节相同；readable repack 解密回读与 readable 源码逐字节相同。

## 动态测试的正确解读

“8/8 通过”表示**双方行为相等**，不是 8 个场景都业务成功。`json_decode_nil_inherited_error` 中原版和 readable 版都以相同 nil-index 错误失败，因此该场景是“等价通过、业务失败”。

“26/26 动态覆盖”只表示每个原型至少进入一次；没有证明所有 `if` 分支、错误分支、网络时序和 native 组合都被执行。

## 已确认的继承 bug 与风险

三处网络回调都有以下结构：

```lua
if not response_json then
    request_backup_update(true_value)
end
if not response_json.version or not response_json.content then
    -- response_json 为 nil 时在这里报错
end
```

可读版位置：`200 -> 206`、`313 -> 319`、`497 -> 503`。动态场景证明双方以同类规范化 nil-index 错误失败。它不是重写引入的；严格等价版刻意不修复，否则会改变原始行为。

`core_known_issues.csv` 共 **16** 行，还包括：未保护/类型异常的 JSON decode、无界重试可能、文件句柄泄漏、退出 API 非返回假设、忽略密钥派生 `pcall` 状态、非 200 静默停止、非原子缓存、未检查归档解密/写入/加载结果、nil/type 拼接、弱 UUID、明文 HTTP 下载执行、POST 未显式编码、anti-hook 覆盖错位、固定 kill-switch 和宿主环境依赖。全部标记为原版已有、非重写引入。

因此，结论只能是“**重写未引入已检测的新 bug**”，不能是“原程序无 bug”。

## 明文化边界

### 已明文化

- 控制流、注释、局部语义名、367 次静态运行时名称、普通字符串和中文协议文本可直接阅读。
- 源码无 NUL、无异常原始控制字节、无 `\xNN`/`\uNNNN`。
- 只剩 3 个必要语义转义：`\022`（密钥派生 gsub）、`\t`（制表符匹配）、`\n`（提示换行）。

### 仍不是“全静态明文”

- 1 次计算型动态索引；
- 34 次 `to_number("...")`（22 个唯一数字字符串）仍按原语义保留；
- 5 次运行时 Base64 decode、2 次 XXTEA decrypt、1 次动态 `load`、2 次外部 ZIP load；
- 服务器返回的加密内容、运行时 `globals.def.role.stuff`、外部 `core/core64.zip`；
- `gplus.bin` Base64 后的未知高熵内层载荷。

所以：**源码静态表面已明文化；所有运行时/外部载荷并未、也不能在保持严格等价时全部静态展开。**

## `gplus.bin` 边界

- 第一层 XXTEA 往返逐字节相同；
- 第一层明文长度：`20722` 字节，`#` 分为 `11` 段；
- 最后一段 Base64 长度：`20432`；
- 内层长度：`15324`，SHA-256：`1665d1c16c50ab2aad0f15a4878f47f40128e719569e814e59348843ad0cabbd`；
- 熵：`7.98798758` bits/byte，格式仍未识别，不能证明是明文 Lua。

core 三处读取 `gplus.bin` 的文件 MD5并拼入 POST `code`。因此给它换成“可读版”会改变可观察网络协议值，不能被称为严格等价。

## 部署 loader：条件通过，不越界承诺

可见 LuaJIT loader 的关键数据流：

- `getFileData(ycFunction, "core.bin", true)` 取得两个 Lua 返回值；
- 第一个返回值只做真值判断，假时调用 `core_func_byby()`；
- 第二个返回值未使用；
- 后续交给 `load` 的内容来自独立的 `var_0_123()`，不是上述两个返回值；
- 没有可见的 MD5、长度或内容比较；`core_func_checkbin` 无条件返回 `true` 且没有可见 Lua 调用。

原 `core.bin` 为 `23700` 字节 / MD5 `598eaa67b00deb9b566dbbaeabcb1699`；readable repack 为 `24460` 字节 / MD5 `76ec4eb28fa9c629519d31c8a523988b`。这些差异**不会单独触发可见 Lua 代码中的拒绝条件**。

但 `ycFunction.getFileData` 是 native。第三参数 `true` 的含义、native 内部校验、按全局名回调、启动器在 Lua 前的资源校验、32/64 位差异均未被当前证据覆盖。因此最终定性是：

> **Lua 层条件兼容：若 native 返回的第一个 Lua 值为真，则不会仅因文件长度/MD5变化而拒绝；完整 native 部署兼容性尚未证明。**

## 调试元数据例外

LuaJIT stripped chunk 相同不表示所有可观察元数据相同。`debug.getlocal`、错误堆栈行号、源文件名、line hook、未 strip dump 会观察到重命名/排版差异；程序普通逻辑没有显示依赖自身局部名或源码行号。

## 逐项证据文件

- `core_function_audit.csv`：26 个原型/函数
- `core_instruction_audit.csv`：1661 条 Lua 5.1 指令（逐 PC）
- `core_constant_audit.csv`：366 个常量
- `core_variable_scope_audit.csv`：129 个局部/参数绑定、生命周期、作用域与遮蔽参与标记
- `core_identifier_use_audit.csv`：527 次标识符使用及其解析绑定
- `core_shadowing_audit.csv`：2 个完整词法遮蔽关系
- `core_upvalue_audit.csv`：116 个闭包捕获
- `core_lexical_scope_audit.csv`：127 个词法作用域
- `core_runtime_name_occurrences.csv`：368 次运行时名称出现
- `core_runtime_name_summary.csv`：83 个唯一静态名称 + 1 个动态索引摘要
- `core_global_access_audit.csv`：2 次裸 global 操作码访问（`_G`、`_ENV`）
- `core_plaintext_audit.csv` / `core_remaining_escapes.csv`：明文化边界
- `core_loader_deployment_audit.csv`：loader 可见数据流与 native 边界
- `core_known_issues.csv`：16 项继承 bug/风险/契约/行为
- `runtime/core_differential_harness.lua` / `core_runtime_results.tsv`：隔离差分
- `raw/`：Lua 5.1/LuaJIT 列表、双方 stripped chunk、loader 证据摘录
- `core_equivalence_audit.json`：机器可读总报告
- `AUDIT_SHA256SUMS.txt`：所有审计产物哈希
