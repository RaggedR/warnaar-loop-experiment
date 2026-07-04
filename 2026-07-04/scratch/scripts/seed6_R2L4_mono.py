#!/usr/bin/env python3
"""Test: (a) does S1/S2 hold at 3|d profiles too (har as pure lattice expression)?
(b) is har_j(c + e_i) >= har_j(c) for all i, all c, j not in {2,4}?
(c) base case: har_j((0,0,1)) == 0 for all j?  (+ rotations)
Sweep capped reps c_i <= CMAX, all d included (except d=0), j <= J0."""
import sys
from seed6_R2L4_sweep import har_j, b_e

J0 = int(sys.argv[1]) if len(sys.argv) > 1 else 20
CMAX = int(sys.argv[2]) if len(sys.argv) > 2 else None
fails_a, fails_b = [], []
for j in range(0, J0+1):
    M = CMAX if CMAX else j + 2
    for c0 in range(M+1):
        for c1 in range(M+1):
            for c2 in range(M+1):
                c = (c0, c1, c2)
                if c == (0, 0, 0): continue
                h = har_j(c, j)
                if j not in (2, 4) and h < 0:
                    fails_a.append((j, c, h))
                if j == 4 and h < -(b_e(c, 2)-1):
                    fails_a.append((j, c, h, 'S2'))
                if j == 2 and h != -(b_e(c, 1)-1):
                    fails_a.append((j, c, h, 'har2'))
                # monotone steps (only need c inside box for both ends: check c+e_i)
                if j not in (2, 4):
                    for i in range(3):
                        cp = list(c); cp[i] += 1; cp = tuple(cp)
                        hp = har_j(cp, j)
                        if hp < h:
                            fails_b.append((j, c, i, h, hp))
    # base case
    for base in ((0,0,1),(0,1,0),(1,0,0)):
        hb = har_j(base, j)
        if hb != 0: print(f"BASE NONZERO j={j} c={base}: {hb}")
print(f"(a) S1/S2/har2 including 3|d: {len(fails_a)} failures")
for f in fails_a[:10]: print("   ", f)
print(f"(b) monotone steps j not in {{2,4}}: {len(fails_b)} failures")
for f in fails_b[:10]: print("   ", f)
print(f"(c) base d=1 profiles: har_j = 0 checked j <= {J0} (silence = pass)")
