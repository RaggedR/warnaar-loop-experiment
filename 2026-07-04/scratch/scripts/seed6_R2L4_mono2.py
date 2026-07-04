#!/usr/bin/env python3
"""Refined monotonicity test (residue-respecting steps only):
  (M1) d = |c| == 1 mod 3:  har_j(c + e_i) >= har_j(c)            (target d == 2)
  (M2) d == 2 mod 3:        har_j(c + e_i + e_k) >= har_j(c), i<=k (target d == 1 mod 3)
for j not in {2,4}. Also S2-analogues at j=4 and j=2 tracked separately.
Box c_i <= CMAX (default j+2), j <= J0."""
import sys
from seed6_R2L4_sweep import har_j, b_e

J0 = int(sys.argv[1]) if len(sys.argv) > 1 else 18
CM = int(sys.argv[2]) if len(sys.argv) > 2 else 0
fails = []
tight = 0; total = 0
for j in [x for x in range(0, J0+1) if x not in (2,4)]:
    M = CM if CM else j + 2
    for c0 in range(M+1):
        for c1 in range(M+1):
            for c2 in range(M+1):
                c = (c0, c1, c2); d = c0+c1+c2
                if d % 3 == 0: continue
                h = har_j(c, j)
                if d % 3 == 1:
                    steps = [(1,0,0),(0,1,0),(0,0,1)]
                else:
                    steps = [(2,0,0),(0,2,0),(0,0,2),(1,1,0),(1,0,1),(0,1,1)]
                for st in steps:
                    cp = (c0+st[0], c1+st[1], c2+st[2])
                    hp = har_j(cp, j)
                    total += 1
                    if hp < h: fails.append((j, c, st, h, hp))
                    elif hp == h: tight += 1
print(f"j <= {J0}, box {CM if CM else 'j+2'}: {total} residue-respecting steps, "
      f"{len(fails)} FAILURES, {tight} tight (equality)")
for f in fails[:20]: print("   ", f)
