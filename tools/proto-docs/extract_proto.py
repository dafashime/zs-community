# -*- coding: utf-8 -*-
"""Extract protocol constants and record definitions from rebuilt-src."""
import re, json, os, sys

SRC = r"D:\Dev\ZhanS\client-other\res\rebuilt-src\mir2"
OUT = r"D:\Dev\ZhanS\_tmp\proto-docs"
os.makedirs(OUT, exist_ok=True)

def read_bytes(p):
    with open(p, "rb") as f:
        return f.read()

def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

# ---------- 1. constants from globa1.lua ----------
g1 = decode(read_bytes(os.path.join(SRC, "mir2.def.globa1.lua")))
const = {}   # name -> value
order = []
for m in re.finditer(r"^\s*([A-Z][A-Z0-9_]+)\s*=\s*(0x[0-9A-Fa-f]+|\d+(?:\.\d+)?)\s*$", g1, re.M):
    name, val = m.group(1), m.group(2)
    v = float(val)
    if v == int(v):
        v = int(v)
    if name not in const:
        order.append(name)
    const[name] = v

with open(os.path.join(OUT, "constants.json"), "w", encoding="utf-8") as f:
    json.dump({n: const[n] for n in order}, f, ensure_ascii=False, indent=1)

cm = {n: v for n, v in const.items() if n.startswith("CM_")}
sm = {n: v for n, v in const.items() if n.startswith("SM_")}
other = {n: v for n, v in const.items() if not (n.startswith("CM_") or n.startswith("SM_"))}
print("CM count:", len(cm), " SM count:", len(sm), " other:", len(other))

# ---------- 2. record definitions from globa2.lua def table ----------
g2raw = read_bytes(os.path.join(SRC, "mir2.def.globa2.lua"))
g2 = g2raw.decode("utf-8", errors="replace")

# take the `local def = { ... }` block up to the line starting with `}` at column 0 followed by functions
start = g2.index("local def = {")
end = g2.index("\n}", start) + 2
block = g2[start:end]
body = block[block.index("{"):]

# tokenize: strip comments
body = re.sub(r"--[^\n]*", "", body)

records = {}
# split top-level entries: find `NAME = {` at depth 1
i = 0
depth = 0
name_re = re.compile(r"([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\{")
entries = []
stack = []
cur_name = None
cur_start = None
for m in re.finditer(r"\{|\}|([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?=\{)", body):
    tok = m.group(0)
    if tok == "{":
        depth += 1
        if depth == 2 and cur_name is None:
            # entering a named record at depth 2? handled below
            pass
    elif tok == "}":
        depth -= 1
    else:
        # name = {
        nm = m.group(1)
        if depth == 1:
            cur_name = nm
            cur_start = m.start()
        elif depth >= 2 and cur_name:
            entries.append((cur_name, nm))

# simpler approach: manual scan
records = {}
lines = body.split("\n")
cur = None
fields = []
paren_field = []
i = 0
def parse_record_block(text):
    """Parse one record's inner field list."""
    fields = []
    attrs = {}
    # bare key = value attrs (e.g. `packed = true`) may sit among fields
    for m in re.finditer(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^\n,}]+)", text, re.M):
        k, v = m.group(1), m.group(2).strip()
        if k not in ("local", "return"):
            attrs[k] = v
    # find all top-level {...} groups inside
    depth = 0
    cur = ""
    groups = []
    for ch in text:
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
            # attribute like packed = true
            mm = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)", grp_s, re.S)
            if mm:
                attrs[mm.group(1)] = mm.group(2).strip()
                continue
        # normal field: {"type","name"[,...]}
        parts = re.findall(r'"([^"]*)"|(\b[a-zA-Z_][a-zA-Z0-9_]*\b\s*=\s*[^,}]+)', grp_s)
        vals = [p[0] if p[0] else p[1] for p in parts]
        # also plain numbers like 15
        nums = []
        # reconstruct: split top-level commas
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

# iterate records over WHOLE file: table-literal keys (`\tNAME = {`) and later `def.NAME = {` assignments
full = re.sub(r"--[^\n]*", "", g2)
lines = full.split("\n")
rec_iter = []
for i, ln in enumerate(lines):
    m = re.match(r"^\s*(?:(?:local\s+)?(?:def\.)?([A-Za-z_][A-Za-z0-9_]*))\s*=\s*\{", ln)
    if m:
        name = m.group(1)
        stripped = ln.lstrip()
        if stripped.startswith("local "):
            continue  # skip `local def = {` etc.
        rec_iter.append((name, i))
JUNK = {"byte", "short", "int", "uint", "double", "ID", "string", "tables", "configs", "record", "array", "dynamicArray", "def"}
records = {}
for name, li in rec_iter:
    if name in JUNK:
        continue
    s = 0
    # find the '{' on that line
    brace = lines[li].find("{")
    if brace < 0:
        continue
    # reconstruct full text from this line onward
    body_full = "\n".join(lines[li:])
    s = brace + 1
    d = 1
    j = s
    while j < len(body_full) and d > 0:
        c = body_full[j]
        if c == "{": d += 1
        elif c == "}": d -= 1
        j += 1
    inner = body_full[s:j-1]
    fields, attrs = parse_record_block(inner)
    records[name] = {"fields": fields, "attrs": attrs}

print("records parsed:", len(records))
with open(os.path.join(OUT, "records.json"), "w", encoding="utf-8") as f:
    json.dump(records, f, ensure_ascii=False, indent=1)

# readable dump
with open(os.path.join(OUT, "records.txt"), "w", encoding="utf-8") as f:
    for name, rec in records.items():
        f.write(f"{name}" + ("  [packed]" if "packed" in rec["attrs"] else "") + "\n")
        for fl in rec["fields"]:
            f.write("    " + " | ".join(fl) + "\n")
        f.write("\n")

# ---------- 3. constants readable ----------
with open(os.path.join(OUT, "constants.txt"), "w", encoding="utf-8") as f:
    for n in order:
        f.write(f"{const[n]:<12} {n}\n")

print("done -> ", OUT)
