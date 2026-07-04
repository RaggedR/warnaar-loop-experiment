#!/usr/bin/env python3
"""Scale test of T6: f0/P_{m-1} >= 0 for gcd(d,3)=1."""
import importlib.util
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
def sub(a,b): return [x-y for x,y in zip(a,b)]
def shift(a,k): return [0]*k + a[:len(a)-k]
def test(d,c,mmax,W):
    betas={0:[1]+[0]*W}
    for m in range(1,mmax+1): betas[m]=fac.series_beta(c,m,W,d)
    s={0:[1]+[0]*W, 1:sub(betas[1],[1]+[0]*W)}
    for m in range(2,mmax+1):
        r=sub(betas[m],betas[m-1])
        s[m]=[r[w]+(betas[m-1][w-(m-1)*d] if w>=(m-1)*d else 0) for w in range(W+1)]
    for m in range(1,mmax+1):
        rhs=sub(shift(s[m-1],1),shift(s[m-1],1+(m-1)*d))
        t6=sub(sub(s[m],shift(s[m],m)),rhs)
        print(f"d={d} c={c} m={m} W={W}: T6 min={min(t6)} {'OK' if min(t6)>=0 else 'FAIL'} t6={t6}")
if __name__=="__main__":
    for (d,c,mmax,W) in [(4,(2,1,1),5,13),(4,(0,3,1),4,13),(4,(0,2,2),4,13),(4,(4,0,0),4,13),
                          (4,(0,1,3),3,13),(5,(3,1,1),4,12),(5,(0,2,3),3,12),(5,(5,0,0),3,12),
                          (7,(3,2,2),3,11),(7,(1,2,4),2,11),(8,(4,2,2),2,11),(8,(0,5,3),2,11),
                          (2,(1,1,0),5,11),(2,(2,0,0),5,11)]:
        test(d,c,mmax,W)
