# -*- coding: utf-8 -*-
"""Cross-reference CM/SM/LM constant usage across rebuilt-src lua files."""
import re, json, os, collections

ROOT = r"D:\Dev\ZhanS\client-other\res\rebuilt-src"
OUT = r"D:\Dev\ZhanS\_tmp\proto-docs"

def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

usage = collections.defaultdict(lambda: collections.defaultdict(list))  # const -> file -> [line strings]
const_re = re.compile(r"\b((?:CM|SM|LM)_[A-Z0-9_]+)\b")

for dirpath, dirnames, filenames in os.walk(ROOT):
    for fn in filenames:
        if not fn.endswith(".lua"):
            continue
        p = os.path.join(dirpath, fn)
        rel = os.path.relpath(p, ROOT).replace("\\", "/")
        try:
            text = decode(open(p, "rb").read())
        except Exception as e:
            print("ERR", p, e)
            continue
        for i, line in enumerate(text.split("\n"), 1):
            for m in const_re.finditer(line):
                usage[m.group(1)][rel].append(i)

# summary: const -> set of files
summary = {}
for c, files in usage.items():
    summary[c] = {f: v[:40] for f, v in sorted(files.items())}

with open(os.path.join(OUT, "usage.json"), "w", encoding="utf-8") as f:
    json.dump(summary, f, ensure_ascii=False, indent=1)

# readable
with open(os.path.join(OUT, "usage.txt"), "w", encoding="utf-8") as f:
    for c in sorted(summary.keys()):
        f.write(c + "\n")
        for fl, lns in summary[c].items():
            f.write(f"    {fl}: {lns}\n")
print("consts used:", len(summary))
