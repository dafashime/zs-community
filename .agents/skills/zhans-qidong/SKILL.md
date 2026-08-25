---
name: zhans-qidong
description: 战神(zs-community)仓库学习导航:旧服务端架设、客户端编译、服务端功能文档查询。当用户询问"怎么架设服务器"、"怎么编译客户端"、"XX 功能/报文/消息号"时使用。
---

# zhans-qidong — 战神仓库学习导航

本 skill 指引如何学习 `zs-community` 仓库(战神引擎 Lua 客户端源码 + 服务端交互协议研究资料)。

## 仓库地图

```
zs-community/
├── docs/服务端功能/{基础版,白猪版}/   协议文档(核心!主模块10 + 子模块37 各一套)
├── client/
│   ├── src/        基础版 Lua 源码(开发树,消息号常量在 src/mir2/mir2.def.globa1.lua)
│   ├── src-bs/     基础版纯净源码(对照参考)
│   ├── src-bz/     白猪 G2.5 全明文(商业魔改版参考)
│   ├── build/      Lua 包打包配置(*.php)
│   ├── lib/        引擎工程(不入库,由 BaiZhuClient.zip 解压,含 res/ 运行时包)
│   └── 编译指南.md  客户端编译与打包完整流程
├── server/架设指南.md   旧服务端(MirServerZS)架设
├── bin/run-win-client.bat   客户端一键启动
└── tools/proto-docs/   协议提取/校验脚本(可复现文档结论)
```

## 三类核心问题怎么答

### 1. 架设(旧服务端)

- 入口:`server/架设指南.md`;
- 需要 3 个下载包:`MirServerZS.zip`(配置层)、`红月.zip`(程序与数据)、`2024天龙一键启动器.rar`(密码 888888,MySQL 二进制+启动器);
- 关键步骤:解压合并 → 按 §6 改绝对路径 → 按 §7 启动(MySQL→天龙启动器 8088→openresty 8089→LoginGate 7000→DBServer→GameGate 7100);
- 客户端对接:SF 列表走 8089(`def.setSF("127.0.0.1", 8089, "mir2666")`),登录中心 8088,账号 `888888/888888`;
- 常见坑:登录后"失去连接"= DBService.ini `PublicIp1/2/3` 未改 127.0.0.1(改后重启 DBServer)。

### 2. 客户端编译

- 入口:`client/编译指南.md`;
- 前提:下载 `BaiZhuClient.zip` 解压到 `client/lib/`(引擎工程不入库);
- 环境:VS2022 + MSVC v143 + Windows SDK 10.0.22621;
- 构建:`MSBuild.exe client/lib/frameworks/runtime-src/proj.win32/BaiZhuClient.sln /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v143 /m /nologo`(无需 QUICK_V3_ROOT,已改相对路径);
- 运行:`bin\run-win-client.bat`;
- Lua 包重编译(可选):`client/src` 明文 → LuaJIT beta2 字节码 → zip/XXTEA(工程内已带 beta2 luajit,打包配置在 `client/build/*.php`)。

### 3. 功能文档查询(协议/报文/消息号)

- 总入口:`docs/服务端功能/基础版/目录.md`(协议总览:帧格式、记录对齐规则、分发架构);
- 按业务域进主模块/子模块(登录接入、选区角色、游戏世界、战斗技能、物品装备、NPC商店、社交、经济交易、英雄、辅助);
- 白猪版差异:`docs/服务端功能/白猪版/目录.md`(与基础版同号同布局,仅 4 个独有常量 + TigerGate 加密层);
- 查消息号:直接 grep `client/src/mir2/mir2.def.globa1.lua`(CM_* 上行 / SM_* 下行,数值以该文件为准);
- 查结构体(record):`client/src/mir2/mir2.def.globa2.lua`(127 个,注意 C 风格对齐与 GBK 字符串);
- 复现工具:`tools/proto-docs/*.py`(先跑 extract_proto.py 生成 _out/,再跑 validate_docs.py 校验)。

## 回答风格

- 优先引用文档路径(相对仓库根),给出可直接执行的命令;
- 不确定的协议细节标注"(未核实)",以源码为准,不编造消息号;
- 用户问"某个功能/报文"时,先定位到对应子模块文档,再按需展开源码细节。

## 重要声明

本仓库功能与文档会**持续被 AI 不断完善**——协议文档、工具脚本、编译/架设指南都会随研究深入持续更新;遇到文档与源码不一致时,以 `client/src*` 源码为准,并欢迎反馈修正。
