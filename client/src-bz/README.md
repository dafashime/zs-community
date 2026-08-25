# rebuilt-src-bz（白猪 G2.5 全明文源码树 · 仅参考）

> **本树 = `D:\Downloads\战神资源\白猪g2.5明文去混淆.zip` 的完整解压，只做参考/分析用，不参与任何构建。**

## 来源与内容

- 来源：`白猪G2.5_明文包改造_20260710_163247.rar` 的明文可读版（工具去混淆重写），2026-07-10 生成。
- 结构（每个模块均有 32/64 双份）：
  - `白猪G2.5_0518_lua_plain_readable_20260710_014719/`
    - `mir2/` + `mir264/`：**203** 个游戏模块明文（`.lua`）
    - `core/` + `core64/`：**82** 个核心/UI 模块明文
    - `upt/` + `upt64/`：**6** 个启动模块明文
    - `mapping.csv` / `renaming.json` / `validation.json` / `quality_audit.json`：去混淆工具的映射与校验产物
  - `白猪G2.5_core_gplus_restored_20260710_134136/`：core.zip 的 gplus 还原 + 等价性审计工具链（audit/、xxtea_frame_tool.py 等）

## 已知事实

- 这是 **G2.5-0518 构建代**的白猪（白筑）家族源码；生产热更 204 = 白筑团队**改写版**（124 个模块不同），因此本树源码**不能**与生产 `.bc` 字节级互换，但可读、可编译、可作迁移参考。
- **`mir2.def.role` 不在本树**（白猪 NPJ 出厂包独占；热更 204 与 G2.5 明文均无）。mod 运行时用 bs 版顶替，见 `../rebuilt-src-bz-prod/reference/`。
- `_hk` 命名：`common/ground/map.map/role.role/role.ani/item/autoRat` 的无后缀 `.lua` 是 `return require(..._hk)` 壳，**主体在同目录 `*_hk.lua`**（在 core/ 中）。
- `panel.bag`/`panel.chat` 是分派壳：`def.openBigBag`（bag8/bag9）、`def.openChatLeftPanel`（chatNew/chatOld）。
- 编码：GBK/UTF-8 混合，保持原样，禁止批量转码。

## 与其它树的关系

| 树 | 内容 | 用途 |
|---|---|---|
| `../rebuilt-src` | 基础版全量 327 文件 + 插桩 `upt/main.lua` | **开发树**：LUAMODE=base/mod 双模式构建源 |
| `../rebuilt-src-bs` | 基础版原始纯净 327 文件 | 参考（最原始基础版） |
| `rebuilt-src-bz`（本树） | 白猪 G2.5 全明文 291 模块/份 | **参考/迁移素材** |
| `../rebuilt-src-bz-prod` | 白猪**生产热更 216 条目**（68 等价源码 + 136 `.bc` + config 层 + build_modpatch.ps1） | mod 模式 modpatch 构建源 |

模块级对比见 `../../功能模块对比.md`（base vs G2.5 逐模块表）。
