"""
Seed 1 R2 L3: generalized two-variable fermionic ansatz search.
genferm(m; A,B,C,a,b,al,be,c) = sum_{n,j>=0} q^{A n^2 + B nj + C j^2 + a n + b j} [m,n] [al*n + be*m + c, j]
Targets: d=4 missing orbits (0,1,3), (0,2,2); all d=5 orbits.
Filter on m=1..3, verify on m<=7.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed1_R2L3_fermfit import qbinom
from seed1_R2L3_engine import H_tower

def genferm(m, A, B, C, a, b, al, be, c, cap=None):
    out = {}
    for n in range(0, m+1):
        bn = qbinom(m, n)
        if not bn: continue
        top = al*n + be*m + c
        if top < 0:
            if n == 0 and be == 0 and c < 0:  # [neg,0]=1 only j=0
                pass
        for j in range(0, max(top, 0)+1):
            bj = qbinom(top, j)
            if not bj: continue
            e0 = A*n*n + B*n*j + C*j*j + a*n + b*j
            for e1, c1 in bn:
                for e2, c2 in bj:
                    e = e0+e1+e2
                    out[e] = out.get(e, 0) + c1*c2
    return {k: v for k, v in out.items() if v}

def search(targets, label):
    """targets: dict name -> seq (list of polys m=0..7)"""
    from itertools import product
    grid = list(product([1,2], [-2,-1,0,1], [1,2,3], range(-2,5), range(-2,5),
                        [0,1,2,3], [0,1], range(-2,5)))
    print(f"--- {label}: grid size {len(grid)} ---")
    found = {nm: [] for nm in targets}
    for (A,B,C,a,b,al,be,c) in grid:
        # quick sanity: m=0 must give 1 (H_0 = 1): sum over n=0 only
        f0 = genferm(0, A,B,C,a,b,al,be,c)
        if f0 != {0:1}: continue
        f1 = genferm(1, A,B,C,a,b,al,be,c)
        cands = [nm for nm, sq in targets.items() if sq[1] == f1]
        if not cands: continue
        f2 = genferm(2, A,B,C,a,b,al,be,c)
        cands = [nm for nm in cands if targets[nm][2] == f2]
        if not cands: continue
        f3 = genferm(3, A,B,C,a,b,al,be,c)
        cands = [nm for nm in cands if targets[nm][3] == f3]
        if not cands: continue
        for nm in cands:
            ok = all(genferm(m, A,B,C,a,b,al,be,c) == targets[nm][m] for m in range(4, 8))
            if ok:
                found[nm].append((A,B,C,a,b,al,be,c))
                print(f"  MATCH m<=7: {nm} = genferm(A={A},B={B},C={C},a={a},b={b},alpha={al},beta={be},c={c})")
    for nm in targets:
        if not found[nm]:
            print(f"  no match: {nm}")
    return found

if __name__ == "__main__":
    orbits4, _, h4 = H_tower(4, 7, 'target_first')
    reps4 = [o[0] for o in orbits4]
    t4 = {f"d4 H{r}": [h4[m][reps4.index(r)] for m in range(8)] for r in [(0,1,3),(0,2,2)]}
    search(t4, "d=4 missing orbits")
    orbits5, _, h5 = H_tower(5, 7, 'target_first')
    reps5 = [o[0] for o in orbits5]
    t5 = {f"d5 H{r}": [h5[m][reps5.index(r)] for m in range(8)] for r in reps5}
    search(t5, "d=5 all orbits")
