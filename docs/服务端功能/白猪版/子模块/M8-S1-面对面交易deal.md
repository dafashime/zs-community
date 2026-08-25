# M8-S1 面对面交易deal

> 所属主模块:[M8-经济交易系统](../主模块/M8-经济交易系统.md) · 基础版对照:[M8-S1 面对面交易deal](../../基础版/子模块/M8-S1-面对面交易deal.md)

## 与基础版差异摘要

**协议无差异。** 白猪版 `core/mir2.scenes.main.panel.deal.lua` 发送集合与基础版一致:CM_DEALCANCEL、CM_DEALEND(1030)、CM_DEALADDITEM(recog=makeIndex + strs=名字)、CM_DEALCHGGOLD(recog=金币);应答族 SM_DEALTRY/SM_DEALADDITEM_OK/FAIL 等见基础版 M8-S1。4 秒节流(`lastTime.deal`)同基础版。

## 服务端实现要点

按基础版 M8-S1 实现。
