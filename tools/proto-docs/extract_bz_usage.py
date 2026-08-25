# -*- coding: utf-8 -*-
"""White-pig usage surface vs base usage surface."""
import re, json, os, collections

BASE = r"D:\Dev\ZhanS\client-other\res\rebuilt-src"
BZ = r"D:\Dev\ZhanS\client-other\res\rebuilt-src-bz\白猪G2.5_0518_lua_plain_readable_20260710_014719"
OUT = r"D:\Dev\ZhanS\_tmp\proto-docs"

def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

def usage_of(root, extra_dirs=None):
    """const -> {file -> [lines]} for references OUTSIDE the globa1 definition file."""
    usage = collections.defaultdict(lambda: collections.defaultdict(list))
    const_re = re.compile(r"\b((?:CM|SM|LM)_[A-Z0-9_]+)\b")
    targets = [root]
    for dp, dns, fns in os.walk(root):
        for fn in fns:
            if not fn.endswith(".lua"):
                continue
            p = os.path.join(dp, fn)
            rel = os.path.relpath(p, root).replace("\\", "/")
            if "def.globa1" in rel:
                continue
            try:
                text = decode(open(p, "rb").read())
            except Exception:
                continue
            for i, line in enumerate(text.split("\n"), 1):
                for m in const_re.finditer(line):
                    usage[m.group(1)][rel].append(i)
    return usage

base_u = usage_of(BASE)
bz_u = usage_of(BZ)

base_set = set(base_u)
bz_set = set(bz_u)
only_bz = sorted(bz_set - base_set)
only_base = sorted(base_set - bz_set)
common = sorted(base_set & bz_set)

print("base used:", len(base_set), " bz used:", len(bz_set))
print("only bz:", len(only_bz), " only base:", len(only_base), " common:", len(common))

def fmt(d, keys):
    return {k: d[k] for k in keys}

with open(os.path.join(OUT, "bz_usage_diff.txt"), "w", encoding="utf-8") as f:
    f.write(f"base used: {len(base_set)}  bz used: {len(bz_set)}\n")
    f.write(f"only bz: {len(only_bz)}  only base: {len(only_base)}  common: {len(common)}\n\n")
    f.write("== 仅白猪版使用 ==\n")
    for k in only_bz:
        f.write(f"{k}: " + ", ".join(f"{fl}:{lns[:4]}" for fl, lns in sorted(bz_u[k].items())) + "\n")
    f.write("\n== 仅基础版使用 ==\n")
    for k in only_base:
        f.write(f"{k}: " + ", ".join(f"{fl}:{lns[:4]}" for fl, lns in sorted(base_u[k].items())) + "\n")

json.dump({"only_bz": {k: dict(bz_u[k]) for k in only_bz},
           "only_base": {k: dict(base_u[k]) for k in only_base},
           "common": common},
          open(os.path.join(OUT, "bz_usage_diff.json"), "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)
