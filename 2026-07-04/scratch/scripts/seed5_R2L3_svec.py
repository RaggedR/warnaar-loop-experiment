#!/usr/bin/env python3
"""s-vector reformulation tests.
s_m := g_m / P_{m-1} = (b_m - b_{m-1}) + q^{(m-1)d} b_{m-1}   (identity check T0)
T5 (strong):  (1-q^m) s_m - q s_{m-1} >= 0 ?
T6 (target=PHI): (1-q^m) s_m - q(1-q^{(m-1)d}) s_{m-1} >= 0 ?  [== f0/P_{m-1}]
C1: r_m = b_m - b_{m-1} == char of {A in vacuum comp of X_m : bottom level != 0} ?
"""
import importlib.util
from collections import deque
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys
SGN, TDIR = 1, 1

def sub(a,b): return [x-y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k]

def vac_component(c, m, W, d):
    empty = tuple(tuple((0,0,0)) for _ in range(m))
    seen={empty}; q=deque([empty])
    while q:
        A=q.popleft()
        for k in range(d):
            for op in (crys.f_op, crys.e_op):
                B=op(A,c,m,k,d,SGN,TDIR)
                if B is not None and crys.weight(B)<=W and B not in seen:
                    seen.add(B); q.append(B)
    return seen

def test(d,c,mmax,W):
    print(f"d={d} c={c} W={W}")
    betas={0:[1]+[0]*W}
    for m in range(1,mmax+1): betas[m]=fac.series_beta(c,m,W,d)
    G={0:[1]+[0]*W}
    for m in range(1,mmax+1): G[m]=fac.mul(betas[m],fac.partsleq(m-1,d,W),W)
    s={}
    s[0]=[1]+[0]*W  # g_0 = 1, P_{-1}=1
    s[1]=sub(betas[1],[1]+[0]*W)  # g_1 = G_1 - 1
    for m in range(2,mmax+1):
        r=sub(betas[m],betas[m-1])
        s[m]=[r[w]+(betas[m-1][w-(m-1)*d] if w>=(m-1)*d else 0) for w in range(W+1)]
    # T0 sanity: s_m * P_{m-1} == g_m
    for m in range(1,mmax+1):
        gm=sub(G[m],G[m-1])
        assert fac.mul(s[m],fac.partsleq(m-1,d,W),W)==gm, f"T0 fail m={m}"
    for m in range(1,mmax+1):
        t5=sub(sub(s[m],shift(s[m],m)),shift(s[m-1],1))
        rhs=sub(shift(s[m-1],1),shift(s[m-1],1+(m-1)*d))
        t6=sub(sub(s[m],shift(s[m],m)),rhs)
        # C1
        vac=vac_component(c,m,W,d)
        rC=[0]*(W+1)
        for A in vac:
            if A[-1]!=(0,0,0): rC[crys.weight(A)]+=1
        r=sub(betas[m],betas[m-1])
        c1 = (rC==r)
        print(f"  m={m}: T5 min={min(t5)} {'OK' if min(t5)>=0 else 'FAIL'}; T6 min={min(t6)} {'OK' if min(t6)>=0 else 'FAIL'}; C1(r_m=vac-with-bottom) {c1}")
        if min(t5)<0: print(f"      t5={t5}")
        if not c1: print(f"      r={r}\n      rC={rC}")

if __name__=="__main__":
    for (d,c,mmax,W) in [(4,(2,1,1),4,12),(4,(0,2,2),3,12),(4,(4,0,0),3,12),
                          (4,(0,3,1),3,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                          (2,(1,1,0),4,10),(2,(2,0,0),4,10),(3,(0,2,1),3,10)]:
        test(d,c,mmax,W)
        print()
