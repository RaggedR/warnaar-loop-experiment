#!/usr/bin/env python3
"""Stress-test the bounded factorization G_m = beta_m * prod_{j=1}^{m-1} 1/(1-q^{jd})
across d in {2,3,6,8} (incl. 3|d) and higher m/W, plus f0/P_{m-1} >= 0."""
import importlib.util
spec = importlib.util.spec_from_file_location("fac",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)

def test(d, c, m, W):
    G = fac.series_G(c, m, W)
    B = fac.series_beta(c, m, W, d)
    P = fac.partsleq(m-1, d, W)
    pred = fac.mul(B, P, W)
    ok = pred == G
    print(f"d={d} c={c} m={m} W={W}: factorization {'HOLDS' if ok else 'FAILS'}")
    if not ok:
        print(f"   G   ={G}")
        print(f"   B*P ={pred}")

if __name__ == "__main__":
    cases = [
        (2,(1,1,0),2,10),(2,(1,1,0),3,10),(2,(2,0,0),2,10),(2,(2,0,0),3,10),(2,(0,1,1),4,10),
        (3,(1,1,1),2,10),(3,(1,1,1),3,10),(3,(3,0,0),2,10),(3,(0,2,1),2,10),(3,(0,2,1),3,10),
        (6,(2,2,2),2,10),(6,(0,3,3),2,10),(6,(1,2,3),2,10),
        (8,(4,2,2),2,10),(8,(0,5,3),2,10),
        (4,(2,1,1),5,13),(4,(0,3,1),4,12),(4,(0,2,2),4,12),(4,(4,0,0),4,12),(4,(0,1,3),3,12),
        (5,(0,2,3),3,11),(5,(5,0,0),2,11),
    ]
    for (d,c,m,W) in cases:
        test(d,c,m,W)
