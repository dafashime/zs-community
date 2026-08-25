# AGENTS.md —— zs-community(战神引擎 Lua 客户端源码研究仓库)

> 本仓库 = 战神引擎 Lua 客户端(基础版 + 白猪 G2.5 商业魔改版)的**社区研究版**:
> 三套明文源码树 + 服务端交互协议文档 + 旧服务端架设指南。
> 面向协议研究、服务端重写与客户端改造,不包含引擎工程与资源包。

## 1. Lua 源码树(重要:三树模型)

| | `client/src/` | `client/src-bs/` | `client/src-bz/` |
|---|---|---|---|
| 内容 | **基础版开发树**:全量 327 文件(mir2 218 + an 20 + framework 83 + upt 6)+ 插桩 `upt/main.lua`(trace/TCP 8844 控制台/LUAMODE 分支) | **基础版原始纯净** 327 文件(仅 `upt/main.lua` 与 src 不同) | **白猪 G2.5 全明文**:`mir2` 203 + `core` 82 + `upt` 6(32/64 双份 + 工具产物) |
| 运行对应 | `LUAMODE="base"`(`mir2.zip`)与 `LUAMODE="mod"`(`mir2_modpatch.zip`)均由本树流程管理 | —(仅参考) | —(仅参考;协议差异研究素材) |
| 用途 | **开发/研究基准树**:基于基础版迁移白猪功能(对照 `功能模块对比.md`);配合 `client/build/*.php` 编译运行包 | 参考 | 参考/迁移素材(白猪重写了大部分 UI/交互) |

- 白猪生产热更树(`rebuilt-src-bz-prod`,216 条目:68 源码 .lua + 136 字节码 .bc + config)是 mod 模式生产构建源,**未随本仓库分发**(字节码 .bc 无研究价值,如需要可另行获取)。
- **编码规则**:三树均为 GBK/UTF-8 混合(保留原编码,禁止批量转码;改 GBK 文件用 codepage 936)。

## 2. 构建/打包

- 打包配置在 `client/build/`(原 `res/rebuilt/*.php`):`mir2_build.php` / `an_build.php` / `upt_build.php` + `verify_*.php`;
- 需要 Quick-Cocos2dx-Community 3.6.x 引擎的 `compile_scripts.php`(PHP + luajit)执行:
  ```powershell
  php <quick>/bin/lib/compile_scripts.php -c client/build/mir2_build.php
  ```
- 运行时加载链:`upt.zip`(main)→ `an.zip`/`framework_precompiled.zip` → `LUAMODE=="mod" ? mir2_modpatch.zip : mir2.zip` → 配置层;
- 素材:mod 用红月包 rs.zip;白筑通用 rs.zip(97MB)缺 mainlogo/newui 素材,勿用。

## 3. 关键事实/边界(历史踩坑)

- 白筑出厂包 `mir2_encrypted.zip`(216 模块)= **NPJ 混淆,未破解**(模块名可读;内容只有热更 204 转码可用)
- 本地旧服务器:8088 天龙启动器(/account,不提供 /serverlist)、8089 openresty(/serverlist?password=mir2666)、7000 LoginGate、7100 GameGate;账号 888888/888888(sqlite/MySQL 注意 des="被封"仅为文案 code=0 即成功)
- mod 入口用 `bzmir.gateIP/gatePort` 与 `def.loginCenterIP`(nil 会导致"获取服务器信息失败"循环)
- **协议结论(已核实,见 docs)**:白猪版与基础版消息号常量 2002 个全同值、记录 127 个全同布局;白猪独有仅 4 个常量(SM_MAPWEATHER/SM_MAP_RANGE_PICK/CM_USERRELIVE/SM_YSGUISHU);白猪版 net.lua 含 TigerGate 可选编码层(默认关闭)

## 4. Git 规范

- 提交范围:`client/src*`、`client/build/*.php`、`docs/`、`server/`、根目录 md 文档
- **不提交**:任何 `*.zip` 生成物、`*.bc`、`Debug.win32/` 构建输出、`_mumu/` 工作区
- 破坏性操作须先备份;源码改动前先确认 bs/bz 归属

## 5. 文档索引

- `README.md` —— 仓库总览与快速上手
- `docs/服务端功能/基础版/目录.md` —— **服务端重写核心文档**:帧格式/记录系统/10 主模块/37 子模块
- `docs/服务端功能/白猪版/目录.md` —— 白猪版协议差异(使用面/TigerGate/遥控指令)
- `客户端编译指南.md` —— 编译与打包流程
- `功能模块对比.md` —— base vs 白猪 G2.5 全量模块对比
- `列表界面展示.md` —— base/mod 列表界面对比
- `魔改包(白筑).md` —— 白筑包研究全集
- `server/架设指南.md` —— 旧服务端(MirServerZS)架设
