#!/usr/bin/env python3
"""Pin the brute-force <-> H-recursion profile convention: try all 6 symmetries."""
from seed4_R2L3_engine import *

def sym_variants(c):
    rots = [c, (c[1], c[2], c[0]), (c[2], c[0], c[1])]
    out = []
    for i, r in enumerate(rots):
        out.append((f"rot{i}", r))
        out.append((f"rot{i}rev", (r[2], r[1], r[0])))
    return out

for d in (4, 5):
    ps, H = H_tower(d, 2)
    N = 16; cut = N - 6
    # for each c, find which variant's brute F matches H-rec
    matchsets = None
    for c in ps:
        target1 = (H[1][c] + [0]*cut)[:cut]
        target2 = (H[2][c] + [0]*cut)[:cut]
        good = set()
        for name, v in sym_variants(c):
            F1 = brute_F(v, 1, N)
            Hm1 = (pmul(qpoch(1), F1) + [0]*cut)[:cut]
            if Hm1 == target1:
                F2 = brute_F(v, 2, N)
                Hm2 = (pmul(qpoch(2), F2) + [0]*cut)[:cut]
                if Hm2 == target2:
                    good.add(name)
        if matchsets is None: matchsets = good
        else: matchsets &= good
        if not good:
            print(f"d={d} c={c}: NO variant matches")
    print(f"d={d}: variants matching all profiles m<=2: {sorted(matchsets)}")
