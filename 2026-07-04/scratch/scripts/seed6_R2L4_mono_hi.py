#!/usr/bin/env python3
"""HM verification for higher j (complete per j via CAP-SHARP, box j+2)."""
import sys
from seed6_R2L4_sweep import har_j
for j in [x for x in range(19, int(sys.argv[1])+1) if x not in (2,4)]:
    M = j + 2; fails = 0; total = 0
    for c0 in range(M+1):
        for c1 in range(M+1):
            for c2 in range(M+1):
                c = (c0, c1, c2); d = c0+c1+c2
                if d % 3 == 0: continue
                h = har_j(c, j)
                steps = [(1,0,0),(0,1,0),(0,0,1)] if d % 3 == 1 else \
                        [(2,0,0),(0,2,0),(0,0,2),(1,1,0),(1,0,1),(0,1,1)]
                for st in steps:
                    total += 1
                    if har_j((c0+st[0], c1+st[1], c2+st[2]), j) < h:
                        fails += 1; print(f"HM FAIL j={j} c={c} step={st}", flush=True)
    print(f"HM j={j}: {total} steps, {fails} failures", flush=True)
print("DONE")
