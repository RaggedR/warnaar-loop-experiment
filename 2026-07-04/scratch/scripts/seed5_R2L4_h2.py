#!/usr/bin/env python3
"""H2' test: char{A in vac(X_m): max(A) = m-1} == (1-q^{(m-1)d}) s_{m-1}?
(max(A) = m-1 <=> bottom level = 0, level m-1 != 0.)
Also record full stratum characters char{max = k in vac(X_m)} for inspection."""
import importlib.util
from collections import deque
BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("fac", BASE + "seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys
SGN, TDIR = 1, 1

def sub(a,b): return [x-y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k] if k>0 else a[:]

def vac_component(c, m, W, d):
    empty = tuple(tuple((0,0,0)) for _ in range(m))
    seen = {empty}; q = deque([empty])
    while q:
        A = q.popleft()
        for k in range(d):
            for op in (crys.f_op, crys.e_op):
                B = op(A, c, m, k, d, SGN, TDIR)
                if B is not None and crys.weight(B) <= W and B not in seen:
                    seen.add(B); q.append(B)
    return seen

def maxpart(A):
    # number of nonzero levels from top: chain A = (a^(1) >= ... >= a^(m)); max part = largest s with a^(s) != 0
    mp = 0
    for s, a in enumerate(A, 1):
        if a != (0,0,0): mp = s
    return mp

def char(S, W):
    g = [0]*(W+1)
    for A in S: g[crys.weight(A)] += 1
    return g

def s_series(betas, m, W, d):
    if m == 0: return [1]+[0]*W
    if m == 1: return sub(betas[1], [1]+[0]*W)
    r = sub(betas[m], betas[m-1])
    return [r[w] + (betas[m-1][w-(m-1)*d] if w >= (m-1)*d else 0) for w in range(W+1)]

def test(d, c, mmax, W):
    print(f"d={d} c={c} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1): betas[m] = fac.series_beta(c, m, W, d)
    for m in range(2, mmax+1):
        vac = vac_component(c, m, W, d)
        strata = {}
        for A in vac:
            strata.setdefault(maxpart(A), set()).add(A)
        sm1 = s_series(betas, m-1, W, d)
        pred = sub(sm1, shift(sm1, (m-1)*d))
        got = char(strata.get(m-1, set()), W)
        ok = got == pred
        print(f"  m={m}: H2' (max=m-1 stratum) {'OK' if ok else 'FAIL'}")
        if not ok:
            print(f"    got  = {got}")
            print(f"    pred = {pred}")
        # dump all strata vs candidate products for inspection
        for k in sorted(strata):
            sk = s_series(betas, k, W, d)
            # candidate: s_k * prod_{j=k}^{m-1}(1-q^{jd})  (H2 general, expected to fail low k)
            cand = sk[:]
            for j in range(k, m):
                cand = sub(cand, shift(cand, j*d))
            gk = char(strata[k], W)
            tag = "==H2" if gk == cand else "!=H2"
            print(f"    stratum k={k}: {tag}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12),(4,(0,2,2),3,12),(4,(4,0,0),3,12),
                             (4,(0,3,1),3,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                             (2,(1,1,0),4,10),(2,(2,0,0),4,10),(8,(3,3,2),2,10)]:
        test(d, c, mmax, W)
        print()
