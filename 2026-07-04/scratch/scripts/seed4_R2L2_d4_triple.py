"""
d=4 missing orbits (0,1,3), (0,2,2): bounded triple-sum ansatz
H_m = sum_{n,m1,n2} q^{n^2-n*m1+m1^2+n2^2 + a*n + b*m1 + c*n2} [m n][n n2][n+n2 m1]
search a,b,c in [-2..3].
Also re-check all five orbits in this template.
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed4_R2L2_orbit_system import H_tower
from seed4_R2L2_d2_closed_form import qbinom

MMAX = 4
orbits, U, hist = H_tower(4, MMAX)
reps = [o[0] for o in orbits]

def triple(m, a, b, c):
    s = {}
    for n in range(0, m+1):
        bmn = qbinom(m, n)
        for n2 in range(0, n+1):
            b2 = qbinom(n, n2)
            pre = {}
            for k1, v1 in bmn.items():
                for k2, v2 in b2.items():
                    pre[k1+k2] = pre.get(k1+k2, 0) + v1*v2
            for m1 in range(0, n+n2+1):
                e = n*n - n*m1 + m1*m1 + n2*n2 + a*n + b*m1 + c*n2
                if e < 0: continue
                b3 = qbinom(n+n2, m1)
                for k1, v1 in pre.items():
                    for k2, v2 in b3.items():
                        s[k1+k2+e] = s.get(k1+k2+e, 0) + v1*v2
    return {k: v for k, v in s.items() if v}

R = range(-2, 4)
for i, rep in enumerate(reps):
    found = []
    for a in R:
        for b in R:
            for c in R:
                if all(triple(m, a, b, c) == hist[m][i] for m in range(MMAX+1)):
                    found.append((a, b, c))
    print(f"{rep}: {found if found else 'NONE'}")
