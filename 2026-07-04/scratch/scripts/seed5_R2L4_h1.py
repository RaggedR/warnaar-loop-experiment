#!/usr/bin/env python3
"""H1 test: char{A in vac(X_m): bottom != 0} == s_m = r_m + q^{(m-1)d} b_{m-1}?
H1L test: char{A in comp_lam: bottom != 0} == q^{|lam|} s_m for EVERY component?
(RESULT 7c only refuted r_m for this set; s_m never compared.)"""
import importlib.util
from collections import deque
BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("fac", BASE + "seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys
SGN, TDIR = 1, 1

def sub(a, b): return [x - y for x, y in zip(a, b)]

def components(c, m, W, d):
    """Partition all bounded chains (weight <= W) into crystal components via BFS.
    Returns list of (source_set_min_weight, set_of_chains). Truncation caveat: only
    edges within weight <= W."""
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    Xset = set(X)
    seen = set()
    comps = []
    for A0 in X:
        if A0 in seen: continue
        comp = {A0}; q = deque([A0])
        while q:
            A = q.popleft()
            for k in range(d):
                for op in (crys.f_op, crys.e_op):
                    B = op(A, c, m, k, d, SGN, TDIR)
                    if B is not None and B in Xset and B not in comp:
                        comp.add(B); q.append(B)
        seen |= comp
        comps.append(comp)
    return comps

def char(S, W):
    g = [0]*(W+1)
    for A in S: g[crys.weight(A)] += 1
    return g

def test(d, c, mmax, W):
    print(f"d={d} c={c} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1): betas[m] = fac.series_beta(c, m, W, d)
    for m in range(1, mmax+1):
        # s_m
        if m == 1:
            s = sub(betas[1], [1]+[0]*W)
        else:
            r = sub(betas[m], betas[m-1])
            s = [r[w] + (betas[m-1][w-(m-1)*d] if w >= (m-1)*d else 0) for w in range(W+1)]
        comps = components(c, m, W, d)
        # vacuum component = the one containing empty chain
        empty = tuple(tuple((0,0,0)) for _ in range(m))
        # safe truncation for comparisons: source weight lam; comp char reliable up to W
        # but bottom!=0 char of comp_lam should equal q^{|lam|} s_m up to W (chars of comps
        # are only complete to W; fine since both sides truncated at W).
        ok_all = True
        for comp in sorted(comps, key=lambda S: min(crys.weight(A) for A in S)):
            lam = min(crys.weight(A) for A in comp)
            V = {A for A in comp if A[-1] != (0,0,0)}
            cv = char(V, W)
            pred = [ (s[w-lam] if w >= lam else 0) for w in range(W+1) ]
            # truncation: comp enumerated only to W, but shifted s too; compare to W - 0
            match = cv == pred
            if lam == 0:
                print(f"  m={m} VACUUM: H1 {'OK' if match else 'FAIL'}")
                if not match:
                    print(f"    char V = {cv}")
                    print(f"    s_m    = {pred}")
            if not match: ok_all = False
        print(f"  m={m}: H1L all components {'OK' if ok_all else 'FAIL'} ({len(comps)} comps)")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12),(4,(0,2,2),3,12),(4,(4,0,0),3,12),
                             (4,(0,3,1),3,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                             (2,(1,1,0),4,10),(2,(2,0,0),4,10),(8,(3,3,2),2,10)]:
        test(d, c, mmax, W)
        print()
