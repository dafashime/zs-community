# -*- coding: utf-8 -*-
"""Compare white-pig (bz) protocol constants/records vs base version."""
import re, json, os

BASE = r"D:\Dev\ZhanS\client-other\res\rebuilt-src\mir2"
BZ = r"D:\Dev\ZhanS\client-other\res\rebuilt-src-bz\白猪G2.5_0518_lua_plain_readable_20260710_014719\mir2"
OUT = r"D:\Dev\ZhanS\_tmp\proto-docs"

def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

def parse_constants(path):
    """Return ordered dict name->value (last assignment wins)."""
    const = {}
    order = []
    text = decode(open(path, "rb").read())
    for m in re.finditer(r"^\s*([A-Z][A-Z0-9_]+)\s*=\s*(0x[0-9A-Fa-f]+|\d+(?:\.\d+)?)\s*$", text, re.M):
        name, val = m.group(1), m.group(2)
        v = float(val)
        if v == int(v):
            v = int(v)
        if name not in const:
            order.append(name)
        const[name] = v
    return const, order

base_c, base_o = parse_constants(os.path.join(BASE, "mir2.def.globa1.lua"))
bz_c, bz_o = parse_constants(os.path.join(BZ, "mir2.def.globa1.lua"))

same = {}      # name -> value (identical)
diff = {}      # name -> (base, bz)  SAME NAME DIFFERENT VALUE - CRITICAL
bz_only = {}   # name -> value
base_only = {} # name -> value
for n in bz_o:
    if n in base_c:
        if base_c[n] == bz_c[n]:
            same[n] = bz_c[n]
        else:
            diff[n] = (base_c[n], bz_c[n])
    else:
        bz_only[n] = bz_c[n]
for n in base_o:
    if n not in bz_c:
        base_only[n] = base_c[n]

print("base consts:", len(base_c), " bz consts:", len(bz_c))
print("same value:", len(same), " DIFF value:", len(diff), " bz-only:", len(bz_only), " base-only:", len(base_only))

def dump(name, d, f):
    f.write(f"== {name} ({len(d)}) ==\n")
    for n in sorted(d, key=lambda x: (x[1] if isinstance(x, tuple) else 0)):
        pass
    for n in sorted(d):
        f.write(f"{n} = {d[n]}\n")
    f.write("\n")

with open(os.path.join(OUT, "bz_constant_diff.txt"), "w", encoding="utf-8") as f:
    f.write(f"base consts: {len(base_c)}  bz consts: {len(bz_c)}\n")
    f.write(f"same: {len(same)}  DIFF: {len(diff)}  bz-only: {len(bz_only)}  base-only: {len(base_only)}\n\n")
    f.write("== 同名不同值 (CRITICAL) ==\n")
    for n in sorted(diff):
        f.write(f"{n}: base={diff[n][0]}  bz={diff[n][1]}\n")
    f.write("\n")
    f.write("== 白猪版独有 ==\n")
    for n in sorted(bz_only):
        f.write(f"{n} = {bz_only[n]}\n")
    f.write("\n")
    f.write("== 基础版独有 ==\n")
    for n in sorted(base_only):
        f.write(f"{n} = {base_only[n]}\n")

json.dump({"same": same, "diff": diff, "bz_only": bz_only, "base_only": base_only},
          open(os.path.join(OUT, "bz_constant_diff.json"), "w", encoding="utf-8"),
          ensure_ascii=False, indent=1)

# ---- records comparison ----
import importlib.util
def extract_records(path):
    text = decode(open(path, "rb").read())
    full = re.sub(r"--[^\n]*", "", text)
    lines = full.split("\n")
    recs = {}
    for i, ln in enumerate(lines):
        m = re.match(r"^\s*(?:(?:local\s+)?(?:def\.)?([A-Za-z_][A-Za-z0-9_]*))\s*=\s*\{", ln)
        if not m:
            continue
        name = m.group(1)
        stripped = ln.lstrip()
        if stripped.startswith("local "):
            continue
        brace = ln.find("{")
        body_full = "\n".join(lines[i:])
        d = 1
        j = brace + 1
        while j < len(body_full) and d > 0:
            c = body_full[j]
            if c == "{": d += 1
            elif c == "}": d -= 1
            j += 1
        recs[name] = body_full[brace+1:j-1]
    return recs

base_r = extract_records(os.path.join(BASE, "mir2.def.globa2.lua"))
bz_r = extract_records(os.path.join(BZ, "mir2.def.globa2.lua"))
r_same = set(base_r) & set(bz_r)
r_bz = set(bz_r) - set(base_r)
r_base = set(base_r) - set(bz_r)
print("base records:", len(base_r), " bz records:", len(bz_r), " common:", len(r_same), " bz-only:", len(r_bz), " base-only:", len(r_base))
with open(os.path.join(OUT, "bz_record_diff.txt"), "w", encoding="utf-8") as f:
    f.write(f"base: {len(base_r)}  bz: {len(bz_r)}  common: {len(r_same)}  bz-only: {len(r_bz)}  base-only: {len(r_base)}\n\n")
    f.write("== 白猪版独有记录 ==\n")
    for n in sorted(r_bz):
        f.write(f"{n}\n")
    f.write("\n== 基础版独有记录 ==\n")
    for n in sorted(r_base):
        f.write(f"{n}\n")
    f.write("\n== 同名记录内容差异 ==\n")
    for n in sorted(r_same):
        if base_r[n].strip() != bz_r[n].strip():
            f.write(f"{n}: base[{len(base_r[n])}B] bz[{len(bz_r[n])}B] 内容不同\n")
