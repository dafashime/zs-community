# M8-S2 摆摊stall

> 所属主模块:[M8-经济交易系统](../主模块/M8-经济交易系统.md) · 基础版对照:[M8-S2 摆摊stall](../../基础版/子模块/M8-S2-摆摊stall.md)

## 与基础版差异摘要

**协议无差异。** 摆摊(CM_ADD_STALLITEM,价格 body int32、币种 tag 0金/1元宝、数量 param)、浏览他人摊位、SM_QUERY_STALL 五分支、SM_START_STALL 九种错误码、摊位实体(SM_SHOWEVENT param=41 + TEventMessage2 64B)——与基础版一致(基础版 M8-S2 详述)。白猪版 `stall.lua`/`stallOther.lua` 仅 UI 差异。

## 服务端实现要点

按基础版 M8-S2 实现。
