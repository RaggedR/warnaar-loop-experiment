#!/usr/bin/env python3
"""Level-3 lift probe. T1-analogue at n=3:
N_3(c) = sum_{c'!=c} q^{3e'} H_2(c') + q(1+q+q^2)(1+q^3+q^6) H_1(c)
         - (q+...+q^8) H_2(c) - (q^3+q^6+q^9).
Verify, then split H_2 = 1 + R2, H_1 = 1 + Q1 and examine negativity pattern of
har3(c) := sum_{c'!=c} q^{3e'} R2(c') + q(1+q+q^2)(1+q^3+q^6) Q1(c)
           - (q+...+q^8) R2(c),
constant part ball3(c) := sum_{c'!=c} q^{3e'} + [q+..+q^8 terms constants]."""
from seed4_R2L3_engine import *

for d in (4, 5):
    ps, H = H_tower(d, 3)
    ok = True
    negpat = {}
    for c in ps:
        H1c, H2c, H3c = H[1][c], H[2][c], H[3][c]
        # Q3 via Q-transform
        Q3 = padd(padd(padd(H3c, pmul([1,1,1], H2c), 1, -1),
                       pmul([0,1,1,1], H1c)), [0,0,0,1], 1, -1)
        N3 = pmul([1,0,0,1,0,0,1], Q3)
        if not pneg_ok(N3):
            print(f"  !! N_3 negative at c={c}"); continue
        # T1-analogue RHS
        rhs = padd([], [0,0,0,1,0,0,1,0,0,1], 1, -1)  # -(q^3+q^6+q^9)
        for cp in ps:
            if cp == c: continue
            rhs = padd(rhs, pshift(H[2][cp], 3*EMD(cp, c)))
        rhs = padd(rhs, pmul(pmul([0,1,1,1],[1,0,0,1,0,0,1]), H1c))
        eight = [0]+[1]*8
        rhs = padd(rhs, pmul(eight, H2c), 1, -1)
        if rhs != N3:
            ok = False; print(f"  T1-analogue FAILS at c={c}")
        # split: R2 = H2 - 1, Q1 = H1 - 1
        R2 = {cp: padd(H[2][cp], [1], 1, -1) for cp in ps}
        Q1c = padd(H1c, [1], 1, -1)
        har3 = []
        for cp in ps:
            if cp == c: continue
            har3 = padd(har3, pshift(R2[cp], 3*EMD(cp, c)))
        har3 = padd(har3, pmul(pmul([0,1,1,1],[1,0,0,1,0,0,1]), Q1c))
        har3 = padd(har3, pmul(eight, R2[c]), 1, -1)
        negs = tuple((j, x) for j, x in enumerate(har3) if x < 0)
        negpat[c] = negs
    print(f"d={d}: T1-analogue {'OK' if ok else 'FAIL'}")
    pats = {}
    for c, negs in negpat.items():
        pats.setdefault(negs, []).append(c)
    for negs, cs in sorted(pats.items(), key=lambda kv: -len(kv[1])):
        print(f"   negs={negs}: {len(cs)} profiles e.g. {cs[:3]}")
