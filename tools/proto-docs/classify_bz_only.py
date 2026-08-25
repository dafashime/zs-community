# -*- coding: utf-8 -*-
"""Distinguish real protocol references from local-variable name collisions in bz usage list."""
import json, re, os

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
BZ = os.path.join(ROOT, "client", "src-bz", "白猪G2.5_0518_lua_plain_readable_20260710_014719")


def decode(b):
    for enc in ("utf-8", "gbk"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("latin-1")

data = json.load(open(os.path.join(_HERE, "_out", "bz_usage_diff.json"), encoding="utf-8"))
only_bz = data["only_bz"]

def classify(name, file, lines):
    """Look at each reference line: real usage patterns vs local var."""
    p = os.path.join(BZ, file)
    if not os.path.exists(p):
        return "file-missing"
    text = decode(open(p, "rb").read()).split("\n")
    real = []
    for ln in lines:
        if ln - 1 >= len(text):
            continue
        line = text[ln - 1]
        # local var: appears in a `local ... =` or `, NAME =` assignment position
        m = re.search(r"\b%s\b" % name, line)
        if not m:
            continue
        start = line[:m.start()]
        after = line[m.end():]
        if re.search(r"local\s+[\w,\s]*$", start) or re.match(r"\s*=[^=]", after):
            # local declaration or real assignment (single `=`) to it -> variable
            continue
        if re.search(r"=\s*$", start):
            # `x = NAME` assignment where NAME is the VALUE: could be msg ident usage
            real.append((ln, line.strip()))
            continue
        real.append((ln, line.strip()))
    return real

result = {}
for name, files in only_bz.items():
    # dedupe 32/64 mirrors: analyze first occurrence set
    seen = set()
    entries = []
    for fl, lns in files.items():
        if fl.endswith("64/") or "/mir264/" in fl or fl.startswith("mir264/") or "mir264" in fl:
            continue  # skip 64-bit mirrors
        if fl in seen:
            continue
        seen.add(fl)
        entries.extend(classify(name, fl, lns))
    result[name] = entries

with open(os.path.join(_HERE, "_out", "bz_only_real.txt"), "w", encoding="utf-8") as f:
    for name in sorted(result):
        f.write(f"== {name} ==\n")
        if not result[name]:
            f.write("   (no real usage found)\n")
        for ln, line in result[name]:
            f.write(f"   {ln}: {line}\n")
        f.write("\n")

real_count = sum(1 for v in result.values() if v)
print("names:", len(result), " with real usage:", real_count)
