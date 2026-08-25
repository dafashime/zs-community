# zs-community —— 战神引擎 Lua 客户端源码与研究资料

> 战神(热血传奇类 MMO)引擎 Lua 客户端的**社区研究版**仓库:三套可对照的明文源码、服务端交互协议文档、旧服务端架设指南。
> 本仓库面向**协议研究、服务端重写、客户端改造**的开发者。

## 目录结构

```
zs-community/
├── docs/                          文档总目录
│   ├── 服务端功能/                 服务端交互协议文档(重点!)
│   │   ├── 基础版/                基础版协议:目录 + 主模块 10 + 子模块 37
│   │   └── 白猪版/                白猪 G2.5 协议差异:目录 + 主模块 10 + 子模块 37
│   ├── 功能模块对比.md              基础版 vs 白猪 G2.5 全量模块对比
│   ├── 列表界面展示.md              base/mod 列表界面对比与素材谱系
│   └── 魔改包(白筑).md             白筑包研究全集(结构/字节码/转码)
├── client/
│   ├── src/                       战神基础版 Lua 源码(开发树,含插桩 upt/main.lua,用于编译打包)
│   ├── src-bs/                    战神基础版 Lua 源码(原始纯净版,仅作参考对照)
│   ├── src-bz/                    战神白猪版 G2.5 全明文 Lua 源码(含 32/64 双份 + 工具产物)
│   ├── build/                     打包构建配置(*_build.php / verify_*.php)
│   ├── lib/                       引擎工程(不入库;由 BaiZhuClient.zip 解压而来,见下方 Getting Started)
│   └── 编译指南.md                 客户端编译与打包完整流程(含 BaiZhuClient.zip 获取)
├── bin/
│   └── run-win-client.bat         客户端一键运行脚本(定位 client/lib 下的 exe)
├── server/
│   └── 架设指南.md                 旧服务端(MirServerZS)架设指南
├── tools/proto-docs/              协议提取/校验脚本(可复现文档结论)
├── README.md                      本文档
├── AGENTS.md                      仓库维护指南(三树模型/编码规则/构建)
└── .gitignore
```

## 三个源码树怎么用

| 目录 | 内容 | 用途 |
|---|---|---|
| `client/src` | 基础版全量 327 文件(mir2 218 + an 20 + framework 83 + upt 6),`upt/main.lua` 带调试插桩(trace/TCP 8844 控制台/LUAMODE 分支) | **协议研究的基准树**;配合 `client/build/*.php` 可编译出 `mir2.zip` 等运行包 |
| `client/src-bs` | 基础版原始纯净 327 文件(仅 `upt/main.lua` 与 src 不同) | 对照参考:区分"原版行为"与"调试插桩" |
| `client/src-bz` | 白猪 G2.5 全明文(mir2 203 + core 82 + upt 6,32/64 双份) | 商业魔改版参考:UI/交互重写、协议扩展点 |

## Getting Started(快速上手)

> 三分钟路线图。完整细节分别见 `client/编译指南.md`(客户端)与 `server/架设指南.md`(服务端)。

### 路线 A:只读研究(零依赖)

源码与文档都在仓库里,直接看:

- 协议研究:先读 [docs/服务端功能/基础版/目录.md](docs/服务端功能/基础版/目录.md)(协议总览:帧格式、记录对齐规则)→ 按业务域进主模块/子模块;
- 源码对照:`client/src`(基础版开发树)↔ `client/src-bz`(白猪版),消息号常量在 `client/src/mir2/mir2.def.globa1.lua`;
- 工具:`tools/proto-docs/*.py` 可复现文档中的常量/尺寸/差异结论。

### 路线 B:编译并运行客户端(Windows + VS2022)

1. **下载原始工程包** `BaiZhuClient.zip`(Quick-Cocos2dx-Community 3.6.1 Win32/Android 工程,含引擎 `frameworks/`、资源 `res/`、Lua 壳 `src/`,解压约 8.3 GB)——下载地址见仓库 Release 页,详见 `client/编译指南.md` §0;
2. **解压到 `client/lib/`**,校验 `client/lib/frameworks/runtime-src/proj.win32/BaiZhuClient.sln` 存在(该目录已被 .gitignore 排除,不入库);
3. **编译**(需 VS2022 + MSVC v143 + Windows SDK 10.0.22621,见 `client/编译指南.md` §3):
   ```powershell
   & "D:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" `
     "client\lib\frameworks\runtime-src\proj.win32\BaiZhuClient.sln" `
     /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v143 /m /nologo
   ```
4. **运行**:`bin\run-win-client.bat`(自动定位 `client/lib` 下的 exe 与 DLL,工作目录已按 Quick 工程约定设置);
5. (可选)重编译 Lua 逻辑包:`client/src` 明文 → LuaJIT beta2 字节码 → `mir2.zip` 覆盖到 `client/lib/res/`(见 `client/编译指南.md` §4;工程内已带 beta2 luajit.exe)。

### 路线 C:架设旧服务端联调(可选)

1. 读 [server/架设指南.md](server/架设指南.md)——架设**红月复古 · 天龙引擎**纯本地单机服,需要 3 个下载包:
   - `MirServerZS.zip`(约 7 MB,改过的配置层 + 热更素材)
   - `红月.zip`(约 640 MB,服务端程序与数据)
   - `2024天龙一键启动器.rar`(约 226 MB,**解压密码 888888**,MySQL 二进制 + 启动器)
2. 按指南 §2 解压合并、§6 改绝对路径、§7 启动顺序(MySQL→启动器 8088→openresty 8089→LoginGate 7000→DBServer→GameGate 7100);
3. 客户端对接:客户端 `def.setSF("127.0.0.1", 8089, "mir2666")`(8088 启动器无 /serverlist,必须走 8089;详见指南 §8/§9 常见坑)。

## 文档怎么读

1. **想重写服务端**:先读 `docs/服务端功能/基础版/目录.md` → 按业务域进主模块/子模块。
2. **想兼容白猪版客户端**:读 `docs/服务端功能/白猪版/目录.md`(与基础版的差异:4 个独有常量、移动扩展、遥控指令通道、TigerGate 加密层)。
3. **想架设旧服务端**:读 `server/架设指南.md`。
4. **想对比两版模块差异**:读 `docs/功能模块对比.md`。

## 关键事实速览

- 消息号常量:`client/src/mir2/mir2.def.globa1.lua`(CM_* 上行 / SM_* 下行,约 2000 条)
- 协议结构体(record):`mir2/mir2.def.globa2.lua`(127 个,含 C 风格对齐规则)
- 网络层:`mir2/mir2.single.net.lua`(帧格式:0xFF44FF44 魔数 + cmd 23/24/25)
- 白猪版与基础版消息号**完全同值**(仅 4 个白猪独有),差异在使用面与传输层
- 线上字符串一律 **GBK**(客户端在边界做 UTF-8/GBK 转换)

## 未包含在本仓库的内容

- Quick-Cocos2dx 引擎工程(client/lib/,体积大且不入库,按 Getting Started 路线 B 获取)
- 资源包(mir2.zip / map.zip / rs.zip / data/*.zip 等生成物,可按 `client/编译指南.md` 自行编译或从原 APK 提取)
- 旧服务端完整程序(仅保留架设指南;MirServerZS 整包见路线 C)

## 编码与贡献约定

见 [AGENTS.md](AGENTS.md):`client/src*` 为**源码字节保真区**(GBK/ANSI/UTF-8 混合,禁止批量转码),新文档与工具一律 UTF-8。

## AI 协作:skill 链接(本地重建)

仓库内置学习导航 skill:`zhans-qidong`(架设/编译/功能文档查询指引)。内容在 `.agents/skills/zhans-qidong/SKILL.md`(已入库);`.claude/skills` 为**本地符号链接**(不入库),Windows 上重建:

```powershell
cmd /c mklink /D .claude\skills .agents\skills   # 需开发者模式或管理员
# 或无需权限的等价形式(junction):
cmd /c mklink /J .claude\skills .agents\skills
```

## 协议研究工具(可复现本文档结论)

`tools/proto-docs/` 收录了生成协议文档所用的提取与校验脚本:

- `extract_proto.py` —— 从 `mir2.def.globa1/globa2.lua` 提取消息号常量与 record 定义
- `extract_usage.py` —— 消息号 ↔ 源码文件交叉引用
- `extract_bz_diff.py` / `extract_bz_records.py` / `extract_bz_usage.py` —— 白猪版 vs 基础版差异对比
- `classify_bz_only.py` —— 甄别"仅白猪使用"常量的真假引用(局部变量名/悬空引用)
- `validate_docs.py` —— 校验 docs 内消息号数值与链接(对照 globa1)
- `sizes.py` / `dump_sizes.py` —— 按 C 对齐规则计算 record 线上尺寸

用法:把 `client/src/mir2/mir2.def.globa1.lua` 路径传入脚本即可复算。
