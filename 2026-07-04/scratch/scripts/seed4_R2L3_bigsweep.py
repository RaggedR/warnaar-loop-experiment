#!/usr/bin/env python3
"""Big sweep: verify S1 (har_j >= 0, j not in {2,4}), S2 (har_2 = -(n1-1),
har_4 >= -(n2-1)), and the formula har_4 = sum_{e'=1}(b_2-b_1)(c') - b_3(c),
for d up to DMAX, checking ALL j (full polynomial). Also confirm cap
sufficiency M=j for j<=12 across the sweep."""
import sys
from seed4_R2L3_engine import *
from collections import defaultdict

DMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 36
capdata = defaultdict(lambda: defaultdict(set))
allok = True
for d in [x for x in range(1, DMAX+1) if x % 3 != 0]:
    ps, H = H_tower(d, 1)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    sph = {}
    for c in ps:
        b = defaultdict(int)
        for cp in ps: b[EMD(cp, c)] += 1
        sph[c] = b
    for c in ps:
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        har += [0]*(6-len(har))
        n1, n2 = sph[c][1], sph[c][2]
        if har[2] != -(n1-1):
            print(f"S2@2 FAIL d={d} c={c}"); allok = False
        if har[4] < -(n2-1):
            print(f"S2@4 FAIL d={d} c={c}"); allok = False
        # har_4 formula
        f4 = sum(sph[cp][2] - sph[cp][1] for cp in ps if EMD(cp, c) == 1) - sph[c][3]
        if har[4] != f4:
            print(f"har4-formula FAIL d={d} c={c}: {har[4]} vs {f4}"); allok = False
        for j, x in enumerate(har):
            if j not in (2, 4) and x < 0:
                print(f"S1 FAIL d={d} c={c} j={j} coeff={x}"); allok = False
            if j <= 12:
                capdata[j][tuple(min(y, j) for y in c)].add(x)
        if len(har) <= 12:
            for j in range(len(har), 13):
                capdata[j][tuple(min(y, j) for y in c)].add(0)
    print(f"d={d} done", flush=True)
print("ALL S1/S2/har4-formula OK" if allok else "FAILURES FOUND")
for j in range(13):
    bad = {k: v for k, v in capdata[j].items() if len(v) > 1}
    ncaps = len(capdata[j])
    full = all(len(set(min(x, j) for x in k)) >= 0 for k in capdata[j])
    # coverage: does sweep realize the all-j cap (j,j,j)?
    cov = tuple([j]*3) in capdata[j]
    print(f"j={j}: cap M=j {'HOLDS' if not bad else 'FAILS'} over sweep; "
          f"{ncaps} capped classes seen; (j,j,j) realized: {cov}")
