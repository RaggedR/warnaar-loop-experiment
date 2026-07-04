#!/usr/bin/env python3
"""Seed 4 Layer 4, Step 2 recon:
 (A) source characterization: sources == v-chains (v_{k,i} = sum_{t=0}^{k-1} c_{(i-t)%3}),
     k_1 >= ... >= k_{m-1} >= 0, bottom level 0.
 (B) local confluence: for kappa != lambda with e_kappa(A), e_lambda(A) both defined,
     do they commute / have common descendant within <= 2 down-steps?
 (C) unique source per component (exhaustive, W-truncated components).
"""
import sys
from collections import Counter
sys.path.insert(0, '.')
from seed5_R2L3_crystal import (all_chains, weight, boxes_add_remove,
                                reduce_brackets, e_op, f_op)

def eps_all(A, c, m, d):
    out = []
    for kappa in range(d):
        br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
        adds, rems = reduce_brackets(br)
        out.append(len(rems))
    return out

def is_source(A, c, m, d):
    return all(e == 0 for e in eps_all(A, c, m, d))

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def vchains(c, m, d, W):
    out = set()
    def rec(prefix, kprev):
        if len(prefix) == m - 1:
            A = tuple(prefix) + (((0,0,0)),)
            if weight(A) <= W:
                out.add(A)
            return
        for k in range(kprev, -1, -1):
            if sum(weight_partial(prefix)) if False else True:
                pass
        for k in range(kprev, -1, -1):
            rec(prefix + [vvec(c, k)], k)
    def weight_partial(p): return [sum(x) for x in p]
    # simpler: iterate all decreasing k-sequences
    def rec2(prefix, kmax):
        if len(prefix) == m - 1:
            A = tuple(prefix) + ((0,0,0),)
            if sum(sum(x) for x in A) <= W:
                out.add(A)
            return
        for k in range(kmax, -1, -1):
            rec2(prefix + [vvec(c, k)], k)
    out = set()
    KMAX = W // d + 1
    rec2([], KMAX)
    return {A for A in out if sum(sum(x) for x in A) <= W}

def checkA(d, c, m, W):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    srcs = {A for A in CH if is_source(A, c, m, d)}
    vch = vchains(c, m, d, W) if m >= 1 else set()
    if m == 1:
        vch = {((0,0,0),)}
    ok = srcs == vch
    print(f"A: d={d} c={c} m={m} W={W}: sources={len(srcs)} vchains={len(vch)} MATCH={ok}")
    if not ok:
        print("   src-not-v:", sorted(srcs - vch)[:5])
        print("   v-not-src:", sorted(vch - srcs)[:5])
    return ok

def down_reachable(A, c, m, d, depth):
    """all chains reachable by <= depth e-steps"""
    frontier = {A}; seen = {A}
    for _ in range(depth):
        nxt = set()
        for B in frontier:
            for kappa in range(d):
                Bp = e_op(B, c, m, kappa, d, 1, 1)
                if Bp is not None and Bp not in seen:
                    nxt.add(Bp); seen.add(Bp)
        frontier = nxt
    return seen

def checkB(d, c, m, W):
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    stats = Counter(); bad = 0
    for A in CH:
        Es = {}
        for kappa in range(d):
            B = e_op(A, c, m, kappa, d, 1, 1)
            if B is not None:
                Es[kappa] = B
        ks = sorted(Es)
        for x in range(len(ks)):
            for y in range(x+1, len(ks)):
                ka, la = ks[x], ks[y]
                B1, B2 = Es[ka], Es[la]
                C1 = e_op(B1, c, m, la, d, 1, 1)
                C2 = e_op(B2, c, m, ka, d, 1, 1)
                dist = (la - ka) % d
                adj = dist == 1 or dist == d - 1
                if C1 is not None and C1 == C2:
                    stats[('commute', adj)] += 1
                else:
                    # common descendant within 2 more steps?
                    D1 = down_reachable(B1, c, m, d, 3)
                    D2 = down_reachable(B2, c, m, d, 3)
                    if D1 & D2:
                        stats[('meet<=4', adj)] += 1
                    else:
                        stats[('NOMEET', adj)] += 1; bad += 1
                        if bad <= 5:
                            print("   NOMEET:", d, c, m, A, ka, la)
    print(f"B: d={d} c={c} m={m} W={W}:", dict(stats), "bad:", bad)
    return bad == 0

def checkC(d, c, m, W):
    """exhaustive components on W-truncated set; NOTE truncation can cut components,
    so only count sources found among W-truncated components whose min weight + d <= W
    (heuristic safety)."""
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    CHset = set(CH)
    # union-find over e-edges (f-edges same graph)
    parent = {A: A for A in CH}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry: parent[rx] = ry
    for A in CH:
        for kappa in range(d):
            B = e_op(A, c, m, kappa, d, 1, 1)
            if B is not None:
                if B not in CHset:
                    print("  weight-drop out of set?? impossible"); continue
                union(A, B)
    comps = {}
    for A in CH:
        comps.setdefault(find(A), []).append(A)
    bad = 0
    for root, members in comps.items():
        srcs = [A for A in members if is_source(A, c, m, d)]
        if len(srcs) != 1:
            bad += 1
            print(f"   component with {len(srcs)} sources, minwt={min(map(weight,members))}, e.g. {srcs[:2]}")
    print(f"C: d={d} c={c} m={m} W={W}: components={len(comps)} multi/zero-source={bad}")
    return bad == 0

if __name__ == "__main__":
    cases = [(2,(1,1,0),3,12), (2,(2,0,0),3,12), (3,(1,1,1),3,11), (3,(0,2,1),3,11),
             (4,(2,1,1),3,13), (4,(0,2,2),3,13), (4,(4,0,0),3,13), (4,(0,1,3),3,12),
             (4,(0,3,1),3,12), (4,(2,1,1),4,12), (5,(3,1,1),3,12), (5,(0,2,3),2,12),
             (6,(2,2,2),2,13), (7,(3,2,2),2,13), (7,(7,0,0),2,14), (8,(3,3,2),2,13)]
    allok = True
    for (d, c, m, W) in cases:
        okA = checkA(d, c, m, W)
        allok &= okA
    print("=== B (local confluence) ===")
    for (d, c, m, W) in [(2,(1,1,0),3,10), (3,(0,2,1),3,9), (4,(2,1,1),3,10),
                         (4,(0,3,1),2,10), (5,(3,1,1),2,10), (7,(7,0,0),2,10)]:
        allok &= checkB(d, c, m, W)
    print("=== C (unique source per component, W-truncated) ===")
    for (d, c, m, W) in [(2,(1,1,0),3,12), (3,(0,2,1),3,11), (4,(2,1,1),3,12),
                         (4,(0,1,3),3,12), (5,(3,1,1),2,12), (7,(7,0,0),2,12)]:
        allok &= checkC(d, c, m, W)
    print("ALL OK" if allok else "ISSUES FOUND (see above)")
