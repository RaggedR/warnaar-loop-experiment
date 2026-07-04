"""
d=4 orbits (0,1,3),(0,2,2): search H_m = ferm(a1,b1,c1) + q^{e} ferm(a2,b2,c2)
where ferm(a,b,c) = sum_{n,j} q^{n^2-nj+j^2+an+bj}[m n][2n+c j],
requiring the second piece to have NO n=0 constant (piece2 restricted to n>=1)
so that H_m(0)=1 works. Filter on m<=2, verify on m<=4.
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed4_R2L2_orbit_system import H_tower, padd, psub
from seed4_R2L2_d2_closed_form import qbinom

MMAX = 4
orbits, U, hist = H_tower(4, MMAX)
reps = [o[0] for o in orbits]

from functools import lru_cache
@lru_cache(maxsize=None)
def ferm(m, a, b, c, nmin=0):
    s = {}
    for n in range(nmin, m+1):
        top = 2*n + c
        if top < 0: continue
        bmn = qbinom(m, n)
        for j in range(0, top+1):
            e = n*n - n*j + j*j + a*n + b*j
            if e < 0: return None
            t = qbinom(top, j)
            for k1, v1 in bmn.items():
                for k2, v2 in t.items():
                    s[k1+k2+e] = s.get(k1+k2+e, 0) + v1*v2
    return tuple(sorted({k: v for k, v in s.items() if v}.items()))

R1 = [(a,b,c) for a in range(-2,4) for b in range(-2,4) for c in range(-2,3)]
for rep in [(0,1,3), (0,2,2)]:
    i = reps.index(rep)
    targets = {m: hist[m][i] for m in range(MMAX+1)}
    found = []
    for p1 in R1:
        f1_2 = ferm(2, *p1)
        if f1_2 is None: continue
        # residual at m=1,2 must be a nonneg poly
        for p2 in R1:
            ok = True
            for m in (1, 2):
                f1 = ferm(m, *p1); f2 = ferm(m, *p2, 1)
                if f1 is None or f2 is None: ok = False; break
                tot = padd(dict(f1), dict(f2))
                if tot != targets[m]: ok = False; break
            if ok:
                # verify m=0,3,4
                if all(padd(dict(ferm(m,*p1)), dict(ferm(m,*p2,1))) == targets[m] for m in (0,3,4)):
                    found.append((p1, p2))
    print(f"{rep}: {found[:8] if found else 'NONE'} ({len(found)} total)")
