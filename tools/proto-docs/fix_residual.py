# -*- coding: utf-8 -*-
import os

DOCS = r"D:\ZhanS\zs-community\docs"

def fix(rel, old, new):
    p = os.path.join(DOCS, rel)
    t = open(p, "rb").read().decode("utf-8", errors="replace")
    if old in t:
        open(p, "w", encoding="utf-8").write(t.replace(old, new))
        print("fixed:", rel)
    else:
        print("NOT FOUND:", rel, "|", old[:40])

fix(os.path.join("白猪版", "子模块", "M1-S1-HTTP登录中心接口.md"),
    "client-other AGENTS.md", "根目录 AGENTS.md")
fix(os.path.join("白猪版", "目录.md"),
    "生产热更树 `rebuilt-src-bz-prod/mir2/`",
    "生产热更树(rebuild-src-bz-prod,未随本仓库分发)mir2/")
fix(os.path.join("白猪版", "子模块", "M10-S6-快捷键GM命令与杂项.md"),
    "生产热更树 `rebuilt-src-bz-prod/mir2/mir2.data.mall.bc`",
    "生产热更树(未随本仓库分发)mir2/mir2.data.mall.bc")
