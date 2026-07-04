#!/usr/bin/env python3
"""Cap-Compression test: does har_j(c) depend only on (min(c_i, M_j))_i?
Test M_j = j and M_j = j+1 across d in {7,8,10,11,13,14,16,17}."""
from seed4_R2L3_engine import *
from collections import defaultdict

def harpoly(d):
    ps, H = H_tower(d, 1)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    out = {}
    for c in ps:
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        out[c] = har
    return out

JMAX = 9
data = defaultdict(lambda: defaultdict(set))  # j -> capped -> set of har_j values
for d in (7, 8, 10, 11, 13, 14, 16, 17):
    hp = harpoly(d)
    for c, har in hp.items():
        for j in range(0, JMAX+1):
            v = har[j] if j < len(har) else 0
            for M in (j, j+1, j+2):
                capped = tuple(min(x, M) for x in c)
                data[(j, M)][capped].add(v)
for j in range(0, JMAX+1):
    for M in (j, j+1, j+2):
        bad = {k: v for k, v in data[(j, M)].items() if len(v) > 1}
        if not bad:
            print(f"j={j}: cap M={M} SUFFICES (har_j determined by min(c_i,{M}))")
            break
    else:
        print(f"j={j}: caps j, j+1, j+2 all INSUFFICIENT; e.g. {list(bad.items())[:2]}")
