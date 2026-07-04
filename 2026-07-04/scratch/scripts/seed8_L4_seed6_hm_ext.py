#!/usr/bin/env python3
"""Seed 8 adversary, Mission B5: extend Seed 6's HM verification to j=31..40
(CAP-SHARP box M=j+2, same criterion as seed6_R2L4_mono_hi.py), with caching
of har_j per (c,j) to halve work across steps."""
import sys, time
sys.path.insert(0, '.')
from seed6_R2L4_sweep import har_j
JMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 40
for j in [x for x in range(31, JMAX+1) if x not in (2,4)]:
    t0 = time.time(); M = j + 2; fails = 0; total = 0
    cache = {}
    def H(c):
        if c not in cache: cache[c] = har_j(c, j)
        return cache[c]
    for c0 in range(M+1):
        for c1 in range(M+1):
            for c2 in range(M+1):
                c = (c0, c1, c2); d = c0+c1+c2
                if d % 3 == 0: continue
                h = H(c)
                steps = [(1,0,0),(0,1,0),(0,0,1)] if d % 3 == 1 else \
                        [(2,0,0),(0,2,0),(0,0,2),(1,1,0),(1,0,1),(0,1,1)]
                for st in steps:
                    total += 1
                    if H((c0+st[0], c1+st[1], c2+st[2])) < h:
                        fails += 1; print(f"HM FAIL j={j} c={c} step={st}", flush=True)
    print(f"HM j={j}: {total} steps, {fails} failures ({time.time()-t0:.0f}s)", flush=True)
print("DONE")
