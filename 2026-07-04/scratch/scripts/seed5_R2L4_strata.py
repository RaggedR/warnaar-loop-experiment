#!/usr/bin/env python3
"""Inspect stratum characters w_k := char{A in vac(X_m): max = k}.
Print w_k, and the 'cofactor' w_k / s_k (series division), to hunt structure."""
import importlib.util
from collections import deque
BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("fac", BASE + "seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys
SGN, TDIR = 1, 1

def sub(a,b): return [x-y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k] if k>0 else a[:]

def divser(a, b, W):
    """a / b as power series with valuation handling. Returns None if not divisible."""
    va = next((i for i,x in enumerate(a) if x), None)
    vb = next((i for i,x in enumerate(b) if x), None)
    if vb is None: return None
    if va is None: return [0]*(W+1)
    if va < vb: return None
    a2 = a[vb:] + [0]*vb
    b2 = b[vb:] + [0]*vb
    out = [0]*(W+1)
    for w in range(W+1-vb):
        acc = a2[w] - sum(out[j]*b2[w-j] for j in range(w))
        if acc % b2[0] != 0: return None
        out[w] = acc // b2[0]
    return out  # valid to W-vb; trailing entries beyond W-vb unreliable

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
    for m in range(2, mmax+1):
        vac = vac_component(c, m, W, d)
        strata = {}
        for A in vac:
            strata.setdefault(maxpart(A), set()).add(A)
        print(f" m={m}:")
        for k in sorted(strata):
            wk = char(strata[k], W)
            print(f"  w_{k} = {wk}")
            if k >= 1:
                cof = divser(wk, S[k], W)
                print(f"    w_{k}/s_{k} = {cof}")
            print(f"    s_{k}     = {S[k]}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),3,12),(2,(1,1,0),4,10),(5,(3,1,1),3,11)]:
        test(d, c, mmax, W)
