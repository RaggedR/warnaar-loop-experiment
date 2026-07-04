#!/usr/bin/env python3
"""Finite-poly reduction tests.
b~_m := sum_{k<=m} w_k  (w_k = s_k - q^{kd} b_k stabilized strata; w_0 = 1).
Tests:
  E1: b_m == b~_m / (1-q^{md})   i.e. b~_m == b_m - q^{md} b_m
  E2: G_m == b~_m * P_m          (strengthened factorization; (q^d;q^d)_m F_{c,m} = b~_m)
  E3: finite support of w_k, b~_k (heuristic: zero tail within window)
  FT: FT_m := (1-q^m)(w_m + q^{md} b~_{m-1}) - q(1-q^{md})(w_{m-1} + q^{(m-1)d} b~_{m-2}) >= 0 ?
      (FT_m = T6_m * (1-q^{md}); FT_m >= 0 IMPLIES SHARP-F0 at m.)
  FTa: (1-q^m) w_m - q(1-q^{md}) w_{m-1} >= 0 ?
  FTb: q^d (1-q^m) b~_{m-1} - q (1-q^{md}) b~_{m-2} >= 0 ?   (FT = FTa + q^{(m-1)d} FTb)
  Sanity: FT_m == T6_m*(1-q^{md}) numerically.
"""
import importlib.util
BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("fac", BASE + "seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)

def sub(a,b): return [x-y for x,y in zip(a,b)]
def add(a,b): return [x+y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k] if k>0 else a[:]

def s_series(betas, m, W, d):
    if m == 0: return [1]+[0]*W
    if m == 1: return sub(betas[1], [1]+[0]*W)
    r = sub(betas[m], betas[m-1])
    return [r[w] + (betas[m-1][w-(m-1)*d] if w >= (m-1)*d else 0) for w in range(W+1)]

def test(d, c, mmax, W):
    print(f"=== d={d} c={c} mmax={mmax} W={W}")
    betas = {0: [1]+[0]*W}
    for m in range(1, mmax+1): betas[m] = fac.series_beta(c, m, W, d)
    S = {m: s_series(betas, m, W, d) for m in range(0, mmax+1)}
    wk = {0: [1]+[0]*W}
    for k in range(1, mmax+1):
        wk[k] = sub(S[k], shift(betas[k], k*d))
    bt = {0: [1]+[0]*W}   # b~_0 = w_0 = 1 (vac of X_1 restricted to max<=0 = {empty})
    for k in range(1, mmax+1):
        bt[k] = add(bt[k-1], wk[k])
    G = {0: [1]+[0]*W}
    for m in range(1, mmax+1): G[m] = fac.mul(betas[m], fac.partsleq(m-1, d, W), W)
    for m in range(1, mmax+1):
        e1 = bt[m] == sub(betas[m], shift(betas[m], m*d))
        e2 = G[m] == fac.mul(bt[m], fac.partsleq(m, d, W), W)
        # finite support heuristic: last nonzero index of w_m, bt_m
        lw = max((i for i,x in enumerate(wk[m]) if x), default=-1)
        lb = max((i for i,x in enumerate(bt[m]) if x), default=-1)
        neg_w = min(wk[m]); neg_bt = min(bt[m])
        print(f" m={m}: E1 {'OK' if e1 else 'FAIL'}  E2 {'OK' if e2 else 'FAIL'}  "
              f"w_m>=0 {'OK' if neg_w>=0 else 'FAIL'}  bt_m>=0 {'OK' if neg_bt>=0 else 'FAIL'}  "
              f"lastnz(w_m)={lw}/{W} lastnz(bt_m)={lb}/{W}")
    for m in range(1, mmax+1):
        t6 = sub(sub(S[m], shift(S[m], m)), sub(shift(S[m-1],1), shift(S[m-1],1+(m-1)*d)))
        lhs = add(wk[m], shift(bt[m-1], m*d)) if m>=1 else None
        ft = sub(sub(lhs, shift(lhs, m)), sub(shift(add(wk[m-1], shift(bt[m-2], (m-1)*d) if m>=2 else [0]*(W+1)),1),
                 shift(add(wk[m-1], shift(bt[m-2], (m-1)*d) if m>=2 else [0]*(W+1)),1+m*d)))
        # m=1: w_0 + q^0 b~_{-1}? define s_0 rep: (1-q^{0})... handle m>=2 only
        if m < 2:
            continue
        sanity = ft == sub(t6, shift(t6, m*d))
        fta = sub(sub(wk[m], shift(wk[m], m)), sub(shift(wk[m-1],1), shift(wk[m-1],1+m*d)))
        ftb = sub(sub(shift(bt[m-1],d), shift(bt[m-1],d+m)), sub(shift(bt[m-2],1), shift(bt[m-2],1+m*d)))
        print(f" m={m}: FT min={min(ft)} {'OK' if min(ft)>=0 else 'FAIL'} (sanity {'OK' if sanity else 'FAIL'}); "
              f"FTa min={min(fta)} {'OK' if min(fta)>=0 else 'FAIL'}; FTb min={min(ftb)} {'OK' if min(ftb)>=0 else 'FAIL'}")

if __name__ == "__main__":
    for (d, c, mmax, W) in [(4,(2,1,1),4,12),(4,(0,2,2),3,12),(4,(4,0,0),3,12),
                             (4,(0,3,1),3,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                             (2,(1,1,0),4,10),(2,(2,0,0),4,10),(8,(3,3,2),2,10)]:
        test(d, c, mmax, W)
        print()
