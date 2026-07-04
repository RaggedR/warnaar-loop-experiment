#!/usr/bin/env python3
"""L-harnack' analysis: har(c) := sum_{c'!=c} q^{2EMD(c',c)} Q_1(c')
   - q(1+q+q^2+q^3+q^4) Q_1(c).  Claim: har(c) >= -q^2-q^4, negatives only
   at exponents {2,4}, each >= -1. Plus ball counting n1,n2 >= 1."""
from seed4_R2L3_engine import *

for d in (4, 5, 7, 8, 10, 11, 13):
    ps, H = H_tower(d, 1)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    worst = {}
    bad = []
    n1min = n2min = 10**9
    for c in ps:
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        negs = [(i, x) for i, x in enumerate(har) if x < 0]
        for i, x in negs:
            worst[i] = min(worst.get(i, 0), x)
        if any(i not in (2, 4) or x < -1 for i, x in negs):
            bad.append((c, negs))
        n1 = sum(1 for cp in ps if EMD(cp, c) == 1)
        n2 = sum(1 for cp in ps if EMD(cp, c) == 2)
        n1min = min(n1min, n1); n2min = min(n2min, n2)
    print(f"d={d}: worst negative coeffs by exponent: {worst}; "
          f"violations of (only exp 2,4, >=-1): {len(bad)}; n1min={n1min} n2min={n2min}")
    for c, negs in bad[:5]:
        print(f"   c={c}: {negs}")
