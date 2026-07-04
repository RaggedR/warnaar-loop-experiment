#!/usr/bin/env python3
"""Explore beta_m series and candidate inequalities implying f_0^(m) >= 0.

With P_k = prod_{j<=k} 1/(1-q^{jd}), G_m = P_{m-1} beta_m (verified),
g_m = G_m - G_{m-1},  f_0^(m) = (1-q^m) g_m - q g_{m-1}.

Candidates (coefficientwise):
  I1: beta_m >= beta_{m-1}
  I2: (1-q^m) beta_m >= q beta_{m-1}                 (naive analogue)
  I3: (1-q^m) beta_m >= (1-q^{(m-1)d})(1+q-q^m) beta_{m-1}   (sufficient given u,v>=0)
  I4: f_0 itself recomputed from betas == f_0 from chains (sanity)
"""
import importlib.util
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys

def sub(a, b): return [x-y for x, y in zip(a, b)]
def shift(a, k): return [0]*k + a[:len(a)-k]
def mulpoly(a, b, W): return fac.mul(a, b, W)

def test(d, c, mmax, W):
    print(f"d={d} c={c} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1):
        betas[m] = fac.series_beta(c, m, W, d)
    for m in range(1, mmax+1):
        print(f"  beta_{m} = {betas[m]}")
    G = {m: mulpoly(betas[m], fac.partsleq(m-1, d, W), W) for m in range(0, mmax+1)}
    G[0] = [1]+[0]*W  # max <= 0: empty only... beta_0 P_-1: fine
    g = {m: sub(G[m], G[m-1]) for m in range(1, mmax+1)}
    g[0] = [1]+[0]*W
    for m in range(1, mmax+1):
        # I1
        i1 = sub(betas[m], betas[m-1])
        # I2
        i2 = sub(sub(betas[m], shift(betas[m], m)), shift(betas[m-1], 1))
        print(f"  m={m}: I1(beta_m-beta_(m-1)) min={min(i1)} {'OK' if min(i1)>=0 else 'FAIL'} : {i1}")
        print(f"        I2((1-q^m)b_m - q b_(m-1)) min={min(i2)} {'OK' if min(i2)>=0 else 'FAIL'} : {i2}")
        if m >= 2:
            lhs = sub(betas[m], shift(betas[m], m))
            rhs_poly = [0]*(W+1)
            # (1 - q^{(m-1)d})(1 + q - q^m)
            terms = {0: 1, 1: 1, m: -1}
            for e, cf in list(terms.items()):
                if e+(m-1)*d <= W:
                    terms[e+(m-1)*d] = terms.get(e+(m-1)*d, 0) - cf
            for e, cf in terms.items():
                if e <= W: rhs_poly[e] += cf
            rhs = mulpoly(rhs_poly, betas[m-1], W)
            i3 = sub(lhs, rhs)
            print(f"        I3 min={min(i3)} {'OK' if min(i3)>=0 else 'FAIL'}")
        # sanity f_0 from factorization vs direct
        f0 = sub(sub(g[m], shift(g[m], m)), shift(g[m-1], 1))
        gm_direct = fac.crys and None
        print(f"        f0 via factorization: min={min(f0)} {'OK' if min(f0)>=0 else 'NEG!'} : {f0}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12), (4,(0,2,2),3,12), (4,(4,0,0),3,12),
                             (4,(0,3,1),3,11), (5,(3,1,1),3,11), (7,(3,2,2),2,10)]:
        test(d, c, mmax, W)
        print()
