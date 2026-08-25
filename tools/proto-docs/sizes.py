# -*- coding: utf-8 -*-
"""Compute C-style aligned record sizes following globa2 generateConfigs rules."""
import json

recs = json.load(open(r"D:\Dev\ZhanS\_tmp\proto-docs\records.json", encoding="utf-8"))

def size_of(name, memo=None):
    memo = memo or {}
    if name in memo:
        return memo[name]
    fields = recs[name]["fields"]
    packed = "packed" in recs.get(name, {}).get("attrs", {})
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
            cnt += size_of(f[2].strip('"'), memo)
        elif t == "array":
            n = int(f[2]); sub = f[3].strip('"')
            if sub == "record":
                cnt += n * size_of(f[4].strip('"'), memo)
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

for n in ["TClientTitleInfo", "TXinfaNormalOrderItem", "TXFHeroOrderItem", "THeroOrderItem",
          "TLogDesc", "TMixingDrugConfig", "TMixingDrugBegin", "TMixingDrugDuring",
          "TMixingDrugLevelInfo", "TMixingDrugListInfo", "TStallHeadInfo", "TStallBodyInfo",
          "TStallMsg", "TEventMessage2", "TMessageBodyWL", "TNewClientMagic", "TClientSkillExp",
          "TNewHeroLook", "TUserStateInfo", "TClientFriendRelation", "TClientAttentionRelation",
          "TClientNormalBlackRelation", "TGuildDesc", "TCorpsDesc", "TGuildMember", "TGuildSimpleDesc",
          "TRecruitCondition", "TRefuseRequestType", "TYBDealClientItems"]:
    if n in recs:
        print(n, size_of(n))
    else:
        print(n, "MISSING")
