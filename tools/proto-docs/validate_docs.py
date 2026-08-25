# -*- coding: utf-8 -*-
"""Validate generated docs: message-number values vs globa1.lua, link integrity, coverage."""
import re, os, json, collections

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
SRC = os.path.join(ROOT, "client", "src", "mir2")
DOCS = os.path.join(ROOT, "docs", "服务端功能", "基础版")
TMP = os.path.join(_HERE, "_out")

def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

# 1. load truth constants
truth = {}
for line in open(os.path.join(SRC, "mir2.def.globa1.lua"), "rb").read().decode("utf-8", errors="replace").split("\n"):
    m = re.match(r"\s*([A-Z][A-Z0-9_]+)\s*=\s*(\d+)\s*$", line)
    if m:
        truth[m.group(1)] = int(m.group(2))
# net.lua local protocol codes
truth["LM_DYN_ENCRYPT_CODE"] = 23
truth["LM_GET_ENCRYPT"] = 24
truth["LM_PING"] = 25

# usage map (constants actually referenced by client code)
usage = json.load(open(os.path.join(TMP, "usage.json"), encoding="utf-8"))

# 2. scan docs
doc_refs = {}      # name -> set of values cited
bad = []
links_bad = []
files = []
for dp, dns, fns in os.walk(DOCS):
    for fn in fns:
        if fn.endswith(".md"):
            files.append(os.path.join(dp, fn))

for p in sorted(files):
    text = open(p, "rb").read().decode("utf-8", errors="replace")
    rel = os.path.relpath(p, DOCS)
    # refs like CM_WALK(3010) possibly with fullwidth? capture ascii parens
    for m in re.finditer(r"\b((?:CM|SM|LM)_[A-Z0-9_]+)\((\d+)\)", text):
        name, val = m.group(1), int(m.group(2))
        doc_refs.setdefault(name, set()).add(val)
        if name not in truth:
            bad.append(f"{rel}: {name} 不在 globa1 常量表")
        elif truth[name] != val:
            bad.append(f"{rel}: {name} 数值 {val} != 实际 {truth[name]}")
    # bare refs without value: count only
    # links
    for m in re.finditer(r"\]\(([^)#]+)\)", text):
        target = m.group(1).strip()
        if target.startswith(("http://", "https://")):
            continue
        tp = os.path.normpath(os.path.join(os.path.dirname(p), target))
        if not os.path.exists(tp):
            links_bad.append(f"{rel}: 断链 {target}")

# 3. coverage of used constants
documented = set()
for name, vals in doc_refs.items():
    documented.add(name)

missing = []
for c in sorted(usage.keys()):
    if c not in documented:
        missing.append(c)

print("docs scanned:", len(files))
print("distinct consts cited with value:", len(doc_refs))
print("value errors:", len(bad))
for b in bad[:60]:
    print("  BAD:", b)
print("broken links:", len(links_bad))
for b in links_bad[:40]:
    print("  LINK:", b)
json.dump(missing, open(os.path.join(TMP, "not_documented.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("used-but-not-cited-with-value count:", len(missing), "(see not_documented.json)")
