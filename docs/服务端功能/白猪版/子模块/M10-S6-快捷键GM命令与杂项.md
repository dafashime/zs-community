# M10-S6 快捷键GM命令与杂项

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md) · 基础版对照:[M10-S6 快捷键GM命令与杂项](../../基础版/子模块/M10-S6-快捷键GM命令与杂项.md)

## 与基础版差异摘要

快捷键(CM_MAGICKEYCHANGE 1008)、推送别名(SM_JPUSH_SETALIAS 4498)、@命令通道(CM_SAY 3030)、GM 命令表——**与基础版一致**(基础版 M10-S6 详述)。白猪版新增/特有组件:

### webView 面板(`core/mir2.scenes.main.panel.webView.lua`)

纯 WebView 容器(默认 `https://www.baidu.com`,URL 由打开参数指定;chargeNew 教程页复用)。**无游戏协议**。

### 动态面板工厂(panelFactory / luaPanelFactory)

`mir2.def.bzinit.lua` 注册为 `def.role.PF/LPF`。本地面板注册/创建/切换基础设施(`createPanel/showPanel/togglePanel/processMsg`),**无新报文**;面板内按钮交互复用 @命令通道(`def.role.sendCM("@命令~参数")`,经 CM_SAY,分隔符 `~` = `bzmir.cmdcnt`),面板数据来自本地配置(`def.role.getConfig`)或刷新指令(`refresh(data)` 按 `|` 分段解析)。

### 商城 mall(生产树)

- 生产热更树 `rebuild-src-bz-prod(未随本仓库分发)mir2/mir2.data.mall.bc` 存在(字节码);
- **明文树(mir2/core)无 mall 实现、无 MALL 相关消息引用**;
- 商城协议(商品列表/购买)无明文可考,**协议未知(未核实)**,重写服务端时若需支持,应抓包或对照生产服务端资料;初步推测复用 SM_SHOPITEMS(812)/TClientShop 或独立消息族。

### 其他白猪组件涉网性

| 组件 | 判定 |
|---|---|
| X8Check.lua / plugCheck | 本地检测;`net.send_old` 为空桩,实际不发包(同基础版) |
| common_hk / ground_hk / role_hk | UI 变体,协议同 |
| 卡片/属性提示(attrTips/cusTipsBar/TipsBar) | 纯本地 |
| bzconfig / bzUIConfig | 本地配置(bzconfig.zip 明文,非协议) |

## 服务端实现要点

1. 按基础版 M10-S6 实现(热键/别名/@命令/GM);
2. @命令通道需支持 `~` 分隔参数格式(白猪版 sendCM 用 `@cmd~p1~p2`);
3. 商城协议待定(未核实)。
