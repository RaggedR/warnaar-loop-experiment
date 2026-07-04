"""
d=4: fit fermionic double sums to the 5 orbit tower values.
Ansatz: H_m = sum_{n,j>=0} q^{n^2 - n j + j^2 + a n + b j} [m n]_q [2n+c j]_q
(a,b in {-1,0,1,2}, c in {-1,0,1}). Warnaar k=2 forms predict:
 orbit (1,1,2): a=b=0, c=0
 orbit (0,0,4): a=1, b=1, c=0
 orbit (0,3,1): a=0, b=1, c=0
Search for orbits (0,1,3) and (0,2,2).
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed4_R2L2_orbit_system import H_tower, padd, pstr
from seed4_R2L2_d2_closed_form import qbinom

MMAX = 5
orbits, U, hist = H_tower(4, MMAX)
reps = [o[0] for o in orbits]
print("orbit reps:", reps)

def ferm(m, a, b, c):
    s = {}
    for n in range(0, m+1):
        top = 2*n + c
        if top < 0: continue
        bmn = qbinom(m, n)
        for j in range(0, top+1):
            e = n*n - n*j + j*j + a*n + b*j
            if e < 0: continue
            t = qbinom(top, j)
            for k1, v1 in bmn.items():
                for k2, v2 in t.items():
                    s[k1+k2+e] = s.get(k1+k2+e, 0) + v1*v2
    return {k: v for k, v in s.items() if v}

# check the three predicted ones, and search for the other two
predicted = {(1,1,2): (0,0,0), (0,0,4): (1,1,0), (0,3,1): (0,1,0)}
for rep, (a,b,c) in predicted.items():
    i = reps.index(rep)
    ok = all(ferm(m,a,b,c) == hist[m][i] for m in range(MMAX+1))
    print(f"{rep}: ansatz (a,b,c)=({a},{b},{c}) -> {'MATCH m<=%d' % MMAX if ok else 'FAIL'}")

for rep in [(0,1,3), (0,2,2)]:
    i = reps.index(rep)
    found = []
    for a in range(-1, 3):
        for b in range(-1, 3):
            for c in range(-1, 2):
                if all(ferm(m,a,b,c) == hist[m][i] for m in range(MMAX+1)):
                    found.append((a,b,c))
    print(f"{rep}: matches {found if found else 'NONE in simple ansatz'}")
