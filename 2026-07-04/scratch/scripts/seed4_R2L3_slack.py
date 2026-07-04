#!/usr/bin/env python3
"""Where is S1 tight? For each d, profile c: compute har_j for all j; report
minimum slack by j-band (low j<=6, middle, top 6), tight (slack 0) locations.
Also check EMD triangle inequality and palindromicity of N_2 or har."""
from seed4_R2L3_engine import *
from collections import defaultdict

def rank(c): return sum(1 for x in c if x > 0)

for d in (4, 5, 7, 8, 11):
    ps, H = H_tower(d, 1)
    # triangle inequality check
    tri = all(EMD(a, b) <= EMD(a, x) + EMD(x, b)
              for a in ps for b in ps for x in ps)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    tight = defaultdict(int)  # j -> count of (c) with har_j == 0 and j not in 2,4
    minslack_mid = 10**9
    deg_report = []
    for c in ps:
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        for j, x in enumerate(har):
            if j in (2, 4): continue
            if x == 0 and j <= (len(har)-1):
                tight[j] += 1
            if 6 <= j <= len(har)-7:
                minslack_mid = min(minslack_mid, x)
        # top structure: last few coefficients of har
        deg_report.append((c, har[-4:] if len(har) >= 4 else har))
    tightj = sorted(tight.items())
    print(f"d={d}: triangle-ineq={'OK' if tri else 'FAIL'}; "
          f"min middle slack={minslack_mid}; tight-at-zero j's: {tightj[:12]}")
    for c, tail in deg_report[:4]:
        print(f"   c={c} har tail {tail}")
