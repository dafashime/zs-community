# -*- coding: utf-8 -*-
"""Precise record field comparison: parse (type, name, len) tuples, compare sequences."""
import re, json, os

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
BASE = os.path.join(ROOT, "client", "src", "mir2")
BZ = os.path.join(ROOT, "client", "src-bz", "白猪G2.5_0518_lua_plain_readable_20260710_014719", "mir2")
OUT = os.path.join(_HERE, "_out")


def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

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

def parse_fields(inner):
    """Return (fields, attrs) from record inner text."""
    fields = []
    attrs = {}
    for m in re.finditer(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^\n,}]+)", inner, re.M):
        k, v = m.group(1), m.group(2).strip()
        if k not in ("local", "return"):
            attrs[k] = v
    depth = 0
    cur = ""
    groups = []
    for ch in inner:
        if ch == "{":
            depth += 1
            if depth == 1:
                cur = ""
                continue
        elif ch == "}":
            depth -= 1
            if depth == 0:
                groups.append(cur)
                cur = ""
                continue
        if depth >= 1:
            cur += ch
    for grp in groups:
        grp_s = grp.strip()
        if "=" in grp_s and not grp_s.strip().startswith('"'):
            continue
        elems = []
        d = 0
        e = ""
        for ch in grp_s:
            if ch == "{":
                d += 1; e += ch
            elif ch == "}":
                d -= 1; e += ch
            elif ch == "," and d == 0:
                elems.append(e.strip()); e = ""
            else:
                e += ch
        if e.strip():
            elems.append(e.strip())
        fields.append(elems)
    return fields, attrs

base_r = extract_records(os.path.join(BASE, "mir2.def.globa2.lua"))
bz_r = extract_records(os.path.join(BZ, "mir2.def.globa2.lua"))

out = []
same = 0
changed = []
base_only = []
bz_only = []
for n in sorted(set(base_r) | set(bz_r)):
    if n not in base_r:
        bz_only.append(n)
        continue
    if n not in bz_r:
        base_only.append(n)
        continue
    bf, ba = parse_fields(base_r[n])
    zf, za = parse_fields(bz_r[n])
    if bf == zf and ba == za:
        same += 1
    else:
        changed.append(n)
        out.append(f"### {n}\n")
        out.append(f"- attrs: base={ba} bz={za}\n")
        out.append("- base fields:\n")
        for f in bf:
            out.append(f"  {f}\n")
        out.append("- bz fields:\n")
        for f in zf:
            out.append(f"  {f}\n")
        out.append("\n")

print("records same:", same, " changed:", len(changed), " base_only:", len(base_only), " bz_only:", len(bz_only))
with open(os.path.join(OUT, "bz_record_field_diff.md"), "w", encoding="utf-8") as f:
    f.write(f"# 白猪版记录字段差异\n\nsame: {same}  changed: {len(changed)}  base_only: {base_only}  bz_only: {bz_only}\n\n")
    f.writelines(out)
