# -*- coding: utf-8 -*-
import os

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
DOCS = os.path.join(ROOT, "docs")
WZ = "\u767d\u732a\u7248"          # 白猪版
SUB = "\u5b50\u6a21\u5757"          # 子模块
MULU = "\u76ee\u5f55.md"            # 目录.md
SC = "\u751f\u4ea7\u70ed\u66f4\u6811"  # 生产热更树
GEN = "\u6839\u76ee\u5f55"          # 根目录

def walk_replace(old, new, label):
    n = 0
    for dp, dns, fns in os.walk(DOCS):
        for fn in fns:
            if not fn.endswith(".md"):
                continue
            p = os.path.join(dp, fn)
            t = open(p, "rb").read().decode("utf-8", errors="replace")
            t2 = t.replace(old, new)
            if t2 != t:
                open(p, "w", encoding="utf-8").write(t2)
                n += 1
    print(label, "->", n)

# 1. client-other AGENTS.md -> 根目录 AGENTS.md
walk_replace("client-other AGENTS.md", GEN + " AGENTS.md", "AGENTS ref")
# 2. 生产热更树 `rebuilt-src-bz-prod/mir2/` -> 生产热更树(未随本仓库分发)...
walk_replace(SC + " `rebuilt-src-bz-prod/mir2/`",
             SC + "(rebuild-src-bz-prod,\u672a\u968f\u672c\u4ed3\u5e93\u5206\u53d1)mir2/", "prod ref")
# 3. rebuilt-src-bz-prod/mir2/mir2.data.mall.bc -> (未随本仓库分发)...
walk_replace("rebuilt-src-bz-prod/mir2/mir2.data.mall.bc",
             "rebuild-src-bz-prod(\u672a\u968f\u672c\u4ed3\u5e93\u5206\u53d1)mir2/mir2.data.mall.bc", "mall ref")

# 验证残留
res = []
for dp, dns, fns in os.walk(DOCS):
    for fn in fns:
        if fn.endswith(".md"):
            t = open(os.path.join(dp, fn), "rb").read().decode("utf-8", errors="replace")
            for kw in ("client-other", "_tmp", "MirServerZS", "rebuilt-src-bz"):
                if kw in t:
                    res.append((fn, kw))
print("residual:", res)
