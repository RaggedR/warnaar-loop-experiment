#!/usr/bin/env python3
"""Seed 4 Layer 4: source enumeration + combinatorics recon.
Source = chain with eps_k = 0 for all k. Compare source GF with
partitions into parts {d, 2d, ..., (m-1)d}; print source shapes."""
import sys
from collections import Counter
sys.path.insert(0, '.')
from seed5_R2L3_crystal import (all_chains, weight, boxes_add_remove,
                                reduce_brackets)

def is_source(A, c, m, d):
    for kappa in range(d):
        br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
        adds, rems = reduce_brackets(br)
        if rems:
            return False
    return True

def part_gf(d, m, W):
    """partitions into parts {d,...,(m-1)d}, counts by weight <= W"""
    gf = [0]*(W+1); gf[0] = 1
    for p in [j*d for j in range(1, m)]:
        for w in range(p, W+1):
            gf[w] += gf[w-p]
    return gf

def recon(d, c, m, W, show=True):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    srcs = [A for A in CH if is_source(A, c, m, d)]
    cnt = Counter(weight(A) for A in srcs)
    gf = part_gf(d, m, W)
    ok = all(cnt.get(w, 0) == gf[w] for w in range(W+1))
    print(f"d={d} c={c} m={m} W={W}: sources={len(srcs)} GF-match={ok}")
    if not ok:
        print("  mismatch:", [(w, cnt.get(w,0), gf[w]) for w in range(W+1)
                              if cnt.get(w,0) != gf[w]])
    if show:
        for A in sorted(srcs, key=weight):
            print("   ", weight(A), A)
    return srcs

if __name__ == "__main__":
    # the crux case from planning: d=4 c=(2,1,1) m=3 up to W=16
    recon(4, (2,1,1), 3, 16)
    recon(4, (0,2,2), 3, 16, show=True)
