# -*- coding: utf-8 -*-
import os

DOCS = "D:/ZhanS/zs-community/docs"
for dp, dns, fns in os.walk(DOCS):
    for fn in fns:
        if fn.endswith(".md"):
            rel = os.path.relpath(os.path.join(dp, fn), DOCS)
            if "M1-S1" in fn or fn == "\u76ee\u5f55.md" or "M10-S6" in fn:
                print(repr(rel))
