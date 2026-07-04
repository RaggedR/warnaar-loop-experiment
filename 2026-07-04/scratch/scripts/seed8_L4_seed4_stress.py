#!/usr/bin/env python3
"""Seed 8 adversary, Mission B4: stress-test Seed 4's Step 1 lemmas and Step 2
claims at LARGER (d,m,W) than their sweeps (they did d<=9, W<=11-14), and hunt
counterexamples to the gap statements:
  2a-ii: every source (no e-descent) is a v-chain;
  2b   : no component has two sources (checkD singleton reachable-source).
"""
import sys
sys.path.insert(0, '.')
from seed4_R2L4_step1 import run
from seed4_R2L4_step2b import checkD, reachable_sources, vvec
from seed5_R2L3_crystal import all_chains, e_op, weight

def check_sources(d, c, m, W):
    """Hunt non-v-chain sources: enumerate chains, find those with no e-descent,
    test membership in the v-chain family {(vvec(c,k1),...,vvec(c,km)): k1>=...>=km>=0}."""
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    vfam = set()
    k = 0
    while sum(vvec(c, k)) <= W:
        k += 1
    kmax = k
    def gen(pref, last):
        if len(pref) == m:
            if sum(sum(a) for a in pref) <= W:
                vfam.add(tuple(pref))
            return
        for kk in range(last, -1, -1):
            gen(pref + [vvec(c, kk)], kk)
    gen([], kmax)
    srcs = []
    for A in CH:
        if all(e_op(A, c, m, kappa, d, 1, 1) is None for kappa in range(d)):
            srcs.append(A)
    bad = [A for A in srcs if A not in vfam]
    print(f"SRC: d={d} c={c} m={m} W={W}: chains={len(CH)} sources={len(srcs)} "
          f"non-v-chain sources={len(bad)}", flush=True)
    for A in bad[:5]:
        print("   NON-V-CHAIN SOURCE:", A)
    return len(bad) == 0

if __name__ == "__main__":
    ok = True
    # --- Step 1 lemmas at larger d and W ---
    cases = []
    for d, c in [(10,(4,3,3)), (10,(0,5,5)), (10,(10,0,0)), (11,(4,4,3)),
                 (11,(0,4,7)), (12,(5,4,3)), (12,(12,0,0)), (8,(0,1,7))]:
        for m in (1, 2, 3):
            cases.append((d, c, m, 13 if m <= 2 else 11))
    f = run(cases, None)
    ok &= not any(f.values())
    print("STEP1 LARGE:", "PASS" if not any(f.values()) else "FAIL", flush=True)
    # --- 2b: singleton reachable-source at larger W ---
    for (d, c, m, W) in [(10,(4,3,3),3,13), (11,(4,4,3),3,13), (12,(5,4,3),2,14),
                         (12,(12,0,0),2,14), (8,(3,3,2),3,13), (7,(3,2,2),3,13),
                         (5,(0,2,3),3,13), (4,(2,1,1),4,14), (2,(1,1,0),4,14)]:
        ok &= checkD(d, c, m, W)
    # --- 2a-ii: non-v-chain source hunt at larger W ---
    for (d, c, m, W) in [(10,(4,3,3),3,13), (11,(4,4,3),3,13), (12,(5,4,3),3,13),
                         (12,(12,0,0),3,14), (8,(3,3,2),3,13), (8,(0,1,7),3,13),
                         (7,(7,0,0),3,14), (4,(2,1,1),4,14), (2,(1,1,0),4,14),
                         (5,(3,1,1),3,14)]:
        ok &= check_sources(d, c, m, W)
    print("=== B4 STRESS VERDICT:", "ALL PASS" if ok else "ISSUES FOUND", "===")
