# -*- coding: utf-8 -*-
"""Dump complete record size table."""
import json, os

_HERE = os.path.dirname(os.path.abspath(__file__))
recs = json.load(open(os.path.join(_HERE, "_out", "records.json"), encoding="utf-8"))
memo = {}

def size_of(name):
    if name in memo:
        return memo[name]
    r = recs[name]
    fields = r["fields"]
    packed = "packed" in r["attrs"]
    cnt = 0
    def align(n):
        nonlocal cnt
        if cnt % n != 0:
            cnt += n - cnt % n
    for f in fields:
        t = f[0].strip('"')
        if t == "byte":
            cnt += 1
        elif t == "short":
            if not packed: align(2)
            cnt += 2
        elif t in ("int", "uint"):
            if not packed: align(4)
            cnt += 4
        elif t in ("double", "ID"):
            if not packed: align(8)
            cnt += 8
        elif t in ("char*", "string"):
            cnt += int(f[2]) + 1
        elif t == "record":
            cnt += size_of(f[2].strip('"'))
        elif t == "array":
            n = int(f[2]); sub = f[3].strip('"')
            if sub == "record":
                cnt += n * size_of(f[4].strip('"'))
            elif sub in ("char*", "string"):
                cnt += n * (int(f[4]) + 1)
            elif sub == "byte":
                cnt += n
            elif sub == "short":
                cnt += n * 2
            else:
                cnt += n * 4
    if not packed:
        mx = 1
        for f in fields:
            t = f[0].strip('"')
            if t in ("double", "ID"):
                mx = 8
            elif t in ("int", "uint"):
                mx = max(mx, 4)
            elif t in ("short", "record"):
                mx = max(mx, 2)
        align(mx)
    memo[name] = cnt
    return cnt

rows = []
for n in sorted(recs):
    try:
        rows.append((n, size_of(n), "packed" in recs[n]["attrs"]))
    except Exception as e:
        rows.append((n, "ERR " + str(e), "packed" in recs[n]["attrs"]))
for n, s, p in rows:
    print("%-30s %-8s %s" % (n, s, "packed" if p else ""))
