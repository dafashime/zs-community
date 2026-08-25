# G2.5 Lua readable rewrite

This directory is a readability-only rewrite of the restored launcher Lua sources.

## Guarantees

- Source file/module names and the six package directories are preserved.
- Original UTF-8 BOM presence and CRLF/LF newline style are preserved per file.
- Decompiled variable/parameter/iterator identifiers such as `var_1_2`, `arg_3_0`, and `iter_4_1` were replaced with readable names. Runtime-visible global names, table keys, and object member names are preserved exactly.
- Every output was loaded with the launcher's bundled LuaJIT.
- Every output's stripped LuaJIT bytecode was compared byte-for-byte with its source file.

## Compatibility note

Two decompiler-style names, `var_0_123` and `var_0_124`, remain only as runtime-visible global entry points in the 32-bit and 64-bit `mir2.def.bzinit.lua` files. Their declarations and references are intentionally preserved because changing a runtime global API name could break external startup code. No rename-safe local, parameter, or iterator identifiers remain.

## Validation result

- Files: **582/582 passed**
- Syntax-valid: **582/582**
- Bytecode-identical: **582/582**
- Encoding preserved: **582/582**
- Newline style preserved: **582/582**
- Rename-safe local/parameter/iterator occurrences: **241539 -> 0**
- Unique symbols renamed: **49356**

## Packages

- `core`: 82 files
- `core64`: 82 files
- `mir2`: 203 files
- `mir264`: 203 files
- `upt`: 6 files
- `upt64`: 6 files

Detailed evidence is in `validation.json`; the independent second-pass audit is in `quality_audit.json`; per-symbol naming decisions are in `renaming.json`; file mapping is in `mapping.csv`.
