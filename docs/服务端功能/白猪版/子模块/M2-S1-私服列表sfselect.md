# M2-S1 私服列表sfselect

> 所属主模块:[M2-选区与角色管理](../主模块/M2-选区与角色管理.md) · 基础版对照:[M2-S1 私服列表sfselect](../../基础版/子模块/M2-S1-私服列表sfselect.md)

## 与基础版差异摘要

**HTTP 接口与 JSON 结构完全一致**,差异仅在入口流程:

- `def.sfAuthUrl = "http://<ip>:<port>/serverlist?password=<密码>"`(`mir2.def.init.lua` 55 行,密码默认 "7g9egjkew",白猪版 `mir2.init.lua` 289 行 `def.setSF(def.gateIP, def.gatePort, "7g9egjkew")`);
- 白猪版默认 `def.skipSFselect` 可跳过私服列表直进 login(bz.scene 逻辑);
- 响应 JSON 结构(kaifubiao/notice/imglist[].url/servers[].servername·desc·serverip·serverid·isactive·rank1·rank2)与基础版 M2-S1 相同;
- 选择后 `def.setLoginCenter(serverip, serverid?)` 写 `bzmir.gateIP/gatePort`,再进 login 场景(同基础版)。

## 服务端实现要点

同基础版 M2-S1;无需为白猪版做额外处理。
