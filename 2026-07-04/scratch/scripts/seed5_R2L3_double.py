#!/usr/bin/env python3
"""Test DOUBLE-PRODUCT positivity: (q;q)_m (q^d;q^d)_{m-1} F_{c,m} = (q;q)_m beta_m >= 0 ?"""
import importlib.util
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
def qfac(m, W):
    g=[0]*(W+1); g[0]=1
    for j in range(1,m+1):
        ng=[0]*(W+1)
        for w in range(W+1):
            ng[w]=g[w]-(g[w-j] if w>=j else 0)
        g=ng
    return g
def test(d,c,m,W):
    b=fac.series_beta(c,m,W,d)
    hb=fac.mul(qfac(m,W),b,W)
    print(f"d={d} c={c} m={m} W={W}: (q;q)_m beta_m min={min(hb)} {'OK' if min(hb)>=0 else 'FAIL'} {hb}")
if __name__=="__main__":
    for (d,c,m,W) in [(4,(2,1,1),1,12),(4,(2,1,1),2,12),(4,(2,1,1),3,12),(4,(2,1,1),4,12),
                       (4,(0,2,2),2,12),(4,(0,2,2),3,12),(4,(4,0,0),2,12),(4,(4,0,0),3,12),
                       (4,(0,3,1),2,12),(4,(0,3,1),3,12),(5,(3,1,1),2,11),(5,(3,1,1),3,11),
                       (5,(5,0,0),2,11),(7,(3,2,2),2,10),(2,(1,1,0),3,10),(2,(2,0,0),3,10)]:
        test(d,c,m,W)
