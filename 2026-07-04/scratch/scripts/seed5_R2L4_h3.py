#!/usr/bin/env python3
"""H3' test: for k <= m-1, char{A in vac(X_m): max = k} == s_k - q^{kd} b_k  (STABILIZED
strata, m-independent), while the top stratum k=m has char s_m (H1). Also test finite
support of w_k and candidate stratum inequalities:
  T7:  w_k - q w_{k-1} - q^k w_k >= 0 ?
  T7b: w_k >= q w_{k-1} ?
"""
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
    print(f"=== d={d} c={c} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1): betas[m] = fac.series_beta(c, m, W, d)
    S = {m: s_series(betas, m, W, d) for m in range(0, mmax+1)}
    Wk = {0: [1]+[0]*W}
    for k in range(1, mmax):  # stabilized w_k = s_k - q^{kd} b_k
        Wk[k] = sub(S[k], shift(betas[k], k*d))
    for m in range(2, mmax+1):
        vac = vac_component(c, m, W, d)
        strata = {}
        for A in vac:
            strata.setdefault(maxpart(A), set()).add(A)
        allok = True
        for k in range(0, m):
            got = char(strata.get(k, set()), W)
            if got != Wk[k]:
                allok = False
                print(f"  m={m} k={k} H3' FAIL: got={got}")
                print(f"                       pred={Wk[k]}")
        top_ok = char(strata.get(m, set()), W) == S[m]
        print(f"  m={m}: H3' strata k<m {'OK' if allok else 'FAIL'}; top=s_m {'OK' if top_ok else 'FAIL'}")
    # stratum inequalities on stabilized w's
    for k in range(1, mmax):
        t7 = sub(sub(Wk[k], shift(Wk[k-1],1)), shift(Wk[k],k))
        t7b = sub(Wk[k], shift(Wk[k-1],1))
        # only compare where reliable: w_k has support bounded; W-window fine
        print(f"  k={k}: w_k={Wk[k]}")
        print(f"     T7 min={min(t7)} {'OK' if min(t7)>=0 else 'FAIL'}; T7b min={min(t7b)} {'OK' if min(t7b)>=0 else 'FAIL'}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12),(4,(0,2,2),3,12),(4,(4,0,0),3,12),
                             (4,(0,3,1),3,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                             (2,(1,1,0),4,10),(2,(2,0,0),4,10),(8,(3,3,2),2,10)]:
        test(d, c, mmax, W)
        print()
