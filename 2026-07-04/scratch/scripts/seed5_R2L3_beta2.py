#!/usr/bin/env python3
"""(1) Sanity: f_0 via factorization == f_0 via direct chain enumeration.
(2) Test stronger reductions: is f_0^(m) / P_k nonneg for k=m-2, m-1?
    D := f_0 / P_{m-2} = (1-q^m)(gamma beta_m - beta_{m-1}) - q(beta_{m-1} - (1-q^{(m-2)d}) beta_{m-2})
    E := f_0 / P_{m-1}
(3) beta_m - beta_{m-1} starts at q^m? (embedding depth)"""
import importlib.util
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
_sG = fac.series_G
def _safe(c,m,W):
    return ([1]+[0]*W) if m<=0 else _sG(c,m,W)
fac.series_G=_safe
crys = fac.crys

def sub(a,b): return [x-y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k]

def pdiv(a, b, W):
    # a / b as power series, b[0]=1
    out = [0]*(W+1)
    r = list(a)
    for i in range(W+1):
        out[i] = r[i]
        if out[i]:
            for j in range(1, W+1-i):
                r[i+j] -= out[i]*b[j]
    return out

def Ppoly(k, d, W):
    return fac.partsleq(k, d, W)

def test(d, c, mmax, W):
    print(f"d={d} c={c} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1):
        betas[m] = fac.series_beta(c, m, W, d)
    G = {0: [1]+[0]*W}
    for m in range(1, mmax+1):
        G[m] = fac.mul(betas[m], Ppoly(m-1, d, W), W)
    g = {0: [1]+[0]*W}
    for m in range(1, mmax+1):
        g[m] = sub(G[m], G[m-1])
    for m in range(1, mmax+1):
        f0 = sub(sub(g[m], shift(g[m], m)), shift(g[m-1], 1))
        # direct
        gd_m = fac.series_G(c, m, W); gd_m1 = fac.series_G(c, m-1, W) if m>=2 else [1]+[0]*W
        gm_exact = sub(fac.series_G(c, m, W), fac.series_G(c, m-1, W) if m >= 1 else [0]*(W+1))
        gm1_exact = sub(fac.series_G(c, m-1, W), fac.series_G(c, m-2, W)) if m >= 2 else ([1]+[0]*W if m==1 else None)
        if m == 1:
            gm1_exact = sub(fac.series_G(c, 0, W) if False else [1]+[0]*W, [0]*(W+1))
        f0d = sub(sub(gm_exact, shift(gm_exact, m)), shift(gm1_exact, 1))
        same = f0 == f0d
        # quotients
        div1 = pdiv(f0, Ppoly(m-1, d, W), W) if m >= 1 else None
        div2 = pdiv(f0, Ppoly(max(m-2,0), d, W), W)
        dm = sub(betas[m], betas[m-1])
        first = next((i for i,x in enumerate(dm) if x), None)
        print(f"  m={m}: f0 factor==direct: {same}; f0/P_(m-1) min={min(div1)}; f0/P_(m-2) min={min(div2)}; (beta_m-beta_(m-1)) first nonzero at {first}")
        if min(div1) >= 0:
            print(f"        f0/P_(m-1) = {div1}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12), (4,(0,2,2),3,12), (4,(4,0,0),3,12),
                             (4,(0,3,1),3,11), (5,(3,1,1),3,11), (7,(3,2,2),2,10)]:
        test(d, c, mmax, W)
        print()
