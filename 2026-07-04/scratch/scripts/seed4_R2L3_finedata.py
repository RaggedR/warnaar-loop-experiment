#!/usr/bin/env python3
"""Fine data: per profile c record (rank, har_2, n1, har_4, n2); test
S1: har_j >= 0 for j not in {2,4};
S2: har_2 >= -(n1-1), har_4 >= -(n2-1);
and classify who achieves the negatives."""
from seed4_R2L3_engine import *
from collections import Counter

def rank(c): return sum(1 for x in c if x > 0)

for d in (1, 2, 4, 5, 7, 8, 10, 11, 13, 14):
    ps, H = H_tower(d, 1)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    S1ok = S2ok = True
    tab = Counter()   # (rank, har2, n1, har4, n2) -> count
    for c in ps:
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        har += [0]*(6-len(har))
        if any(x < 0 for j, x in enumerate(har) if j not in (2, 4)):
            S1ok = False
            print(f"  S1 FAIL c={c}: {[(j,x) for j,x in enumerate(har) if x<0 and j not in (2,4)]}")
        n1 = sum(1 for cp in ps if EMD(cp, c) == 1)
        n2 = sum(1 for cp in ps if EMD(cp, c) == 2)
        if har[2] < -(n1-1) or har[4] < -(n2-1):
            S2ok = False
            print(f"  S2 FAIL c={c}: har2={har[2]} n1={n1} har4={har[4]} n2={n2}")
        tab[(rank(c), har[2] if har[2]<0 else 0, n1, har[4] if har[4]<0 else 0, n2)] += 1
    print(f"d={d}: S1 {'OK' if S1ok else 'FAIL'}  S2 {'OK' if S2ok else 'FAIL'}")
    for k, v in sorted(tab.items()):
        print(f"   (rank,har2-,n1,har4-,n2)={k}: {v} profiles")
