# -*- coding: utf-8 -*-
import os

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
DOCS = os.path.join(ROOT, "docs")
for dp, dns, fns in os.walk(DOCS):
    for fn in fns:
        if fn.endswith(".md"):
            rel = os.path.relpath(os.path.join(dp, fn), DOCS)
            if "M1-S1" in fn or fn == "\u76ee\u5f55.md" or "M10-S6" in fn:
                print(repr(rel))
