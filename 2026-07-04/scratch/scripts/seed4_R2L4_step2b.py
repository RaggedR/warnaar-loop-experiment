#!/usr/bin/env python3
"""Seed 4 Layer 4, Step 2 continued:
 (D) GLOBAL confluence: for every chain, the set of sources reachable by e-descents
     is a SINGLETON (memoized full descent). Stronger than (C).
 (E) v-chain word structure: print/classify bracket words W_kappa of v-chains.
 (F) minimal meet depth for the depth-4 NOMEET divergences.
"""
import sys
from functools import lru_cache
from collections import Counter
sys.path.insert(0, '.')
from seed5_R2L3_crystal import (all_chains, weight, boxes_add_remove,
                                reduce_brackets, e_op)

def reachable_sources(CH, c, m, d):
    memo = {}
    def rec(A):
        if A in memo: return memo[A]
        outs = set()
        for kappa in range(d):
            B = e_op(A, c, m, kappa, d, 1, 1)
            if B is not None:
                outs |= rec(B)
        if not outs:
            outs = frozenset([A])
        else:
            outs = frozenset(outs)
        memo[A] = outs
        return outs
    # process by increasing weight to keep recursion shallow
    for A in sorted(CH, key=weight):
        rec(A)
    return memo

def checkD(d, c, m, W):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    memo = reachable_sources(CH, c, m, d)
    bad = [(A, S) for A, S in memo.items() if len(S) != 1]
    print(f"D: d={d} c={c} m={m} W={W}: chains={len(CH)} multi-source-reachable={len(bad)}")
    for A, S in bad[:3]:
        print("   BAD:", A, "->", sorted(S))
    return len(bad) == 0

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def word_str(br):
    return ''.join('(' if t == 1 else ')' for (_, t, _) in br)

def checkE(d, c, m, kseqs):
    print(f"E: d={d} c={c} m={m}")
    for ks in kseqs:
        A = tuple(vvec(c, k) for k in ks) 
        pats = []
        for kappa in range(d):
            br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
            adds, rems = reduce_brackets(br)
            assert len(rems) == 0 or True
            pats.append((kappa, word_str(br), len(adds), len(rems)))
        print(f"  ks={ks} A={A}")
        for kappa, wstr, na, nr in pats:
            print(f"    kappa={kappa}: word={wstr!r} phi={na} eps={nr}")

def down_step(A, c, m, d):
    out = []
    for kappa in range(d):
        B = e_op(A, c, m, kappa, d, 1, 1)
        if B is not None:
            out.append(B)
    return out

def meet_depth(B1, B2, c, m, d, maxdepth=20):
    S1, S2 = {B1}, {B2}
    F1, F2 = {B1}, {B2}
    for depth in range(1, maxdepth+1):
        F1 = {C for B in F1 for C in down_step(B, c, m, d)} - S1
        S1 |= F1
        if S1 & S2: return depth
        F2 = {C for B in F2 for C in down_step(B, c, m, d)} - S2
        S2 |= F2
        if S1 & S2: return depth
        if not F1 and not F2: return None
    return None

def checkF(d, c, m, W):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    depths = Counter()
    for A in CH:
        Es = {}
        for kappa in range(d):
            B = e_op(A, c, m, kappa, d, 1, 1)
            if B is not None: Es[kappa] = B
        ks = sorted(Es)
        for x in range(len(ks)):
            for y in range(x+1, len(ks)):
                ka, la = ks[x], ks[y]
                dist = (la-ka) % d
                adj = (dist == 1 or dist == d-1)
                md = meet_depth(Es[ka], Es[la], c, m, d)
                depths[(adj, md)] += 1
    print(f"F: d={d} c={c} m={m} W={W}: meet-depth histogram (adj, depth): "
          f"{dict(sorted(depths.items(), key=str))}")
    nomeet = sum(v for (adj, md), v in depths.items() if md is None)
    return nomeet == 0

if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else 'DEF'
    ok = True
    if 'D' in which:
        for (d, c, m, W) in [(2,(1,1,0),3,12), (2,(2,0,0),3,12), (3,(0,2,1),3,11),
                             (4,(2,1,1),3,12), (4,(0,1,3),3,12), (4,(0,2,2),3,12),
                             (5,(3,1,1),2,12), (7,(7,0,0),2,12), (4,(2,1,1),4,12)]:
            ok &= checkD(d, c, m, W)
    if 'E' in which:
        checkE(4, (2,1,1), 3, [(0,0,0),(1,0,0),(2,0,0),(1,1,0),(2,1,0),(2,2,0),(3,1,0)])
        checkE(2, (1,1,0), 3, [(1,0,0),(2,1,0)])
        checkE(4, (0,2,2), 3, [(1,0,0),(2,1,0)])
        checkE(4, (4,0,0), 3, [(1,0,0),(2,1,0)])
        checkE(5, (0,2,3), 2, [(1,0),(2,0),(3,0)]) if False else None
        checkE(5, (3,1,1), 2, [(1,0),(2,0)])
    if 'F' in which:
        for (d, c, m, W) in [(2,(1,1,0),3,10), (4,(2,1,1),3,10), (3,(0,2,1),3,9)]:
            ok &= checkF(d, c, m, W)
    print("DONE", "OK" if ok else "ISSUES")
