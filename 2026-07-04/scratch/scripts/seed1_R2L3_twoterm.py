"""Two-term ferm decompositions for the d=4 missing orbits:
H_m =? ferm(m,a1,b1,c1) + q^{t} ferm(m,a2,b2,c2)  (t constant, >=1)
or with monomial weight q^{t}: search p1 s.t. residual r_m = H_m - ferm(m,p1)
is coefficientwise nonneg for m<=5, then match r_m/q^{val} against ferm grid.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed1_R2L3_fermfit import ferm
from seed1_R2L3_engine import H_tower, psub, pneg, pstr

def val(p): return min(p) if p else None

orbits, _, hist = H_tower(4, 7, 'target_first')
reps = [o[0] for o in orbits]
grid = [(a,b,c) for a in range(-1,5) for b in range(-2,5) for c in range(-2,6)]

for rep in [(0,1,3),(0,2,2)]:
    i = reps.index(rep)
    H = [hist[m][i] for m in range(8)]
    print(f"=== d=4 H{rep} ===  H_1 = {pstr(H[1])}")
    nfound = 0
    for p1 in grid:
        r = [psub(H[m], ferm(m,*p1)) for m in range(8)]
        if any(pneg(r[m]) for m in range(8)): continue
        if r[0] != {}:  # ferm(0,*)=1 always, so residual at m=0 must be 0
            continue
        vs = sorted(set(val(r[m]) for m in range(1,8) if r[m]))
        if len(vs) != 1: continue
        t = vs[0]
        rn = [{e-t: v for e, v in r[m].items()} for m in range(8)]
        # rn[m] should be a ferm at level m? but rn[0]={} while ferm(0)=1 -> allow shape (q^t stuff)
        # match rn against ferm at same level m (for m>=1)
        for p2 in grid:
            if all(ferm(m,*p2) == rn[m] for m in range(1,8)):
                print(f"  H{rep} = ferm{p1} + q^{t} ferm{p2}  [but m=0 residual 0 vs ferm=1 -- mismatch at m=0]")
                nfound += 1
    if nfound == 0:
        print("  no two-term decomposition in grid (residual-nonneg + constant-val + ferm match)")
