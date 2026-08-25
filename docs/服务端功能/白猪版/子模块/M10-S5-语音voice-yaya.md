# M10-S5 语音voice-yaya

> 所属主模块:[M10-辅助系统](../主模块/M10-辅助系统.md) · 基础版对照:[M10-S5 语音voice-yaya](../../基础版/子模块/M10-S5-语音voice-yaya.md)

## 与基础版差异摘要

**协议无差异。** 语音频道控制面(4447-4459 族,错误码 -1..-30/-99)、富文本 `{@vi url|dur|msgID}` 经 CM_SAY param=1、音频面走 HTTP/Yaya SDK——与基础版一致(基础版 M10-S5 详述)。白猪版 `mir2.data.voice.lua`/`core/panel.voice.lua` 相同。

## 服务端实现要点

按基础版 M10-S5 实现。
