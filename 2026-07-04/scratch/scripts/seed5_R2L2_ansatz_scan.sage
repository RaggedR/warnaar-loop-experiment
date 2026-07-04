"""
Seed 5 R2 L2 — Plan D: scan for single-term Warnaar-type positive multisum ansatz
for the 10 uncovered orbits at d=8 (k=3).

Ansatz: Q_n = sum_{n2,n3,m1,m2} q^{ n3^2 + n1^2+n2^2 - n1 m1 - n2 m2 + m1^2 + m2^2
                                    + a1*n1 + a2*n2 + a3*n3 + b1*m1 + b2*m2 + c0 }
              * [n1;n2][n1-n2+m2;m1][n2;n3][n2-n3+m3;m2],  n1=n, m3=2n3,
with a_i in {0,1,2}, b_i in {0,1,2}, c0 in {0,1,2}.  Compare to truth n=1,2.
"""
from sage.all import *
import json, itertools

PREC = 60
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()
K = 3

_qp = {0: R(1)}
def qpoch(n):
    if n not in _qp:
        _qp[n] = qpoch(n-1) * (1 - q**n)
    return _qp[n]
_qpi = {}
def qpoch_inv(n):
    if n not in _qpi:
        _qpi[n] = qpoch(n)**(-1)
    return _qpi[n]
def qbinom(nv, mv):
    if mv < 0 or mv > nv or nv < 0:
        return R(0)
    return qpoch(nv) * qpoch_inv(mv) * qpoch_inv(nv-mv)

def ferm_generic(n, lin):
    a1, a2, a3, b1, b2, c0 = lin
    result = R(0)
    n1 = n
    for n2 in range(n1+1):
        for n3 in range(n2+1):
            m3 = 2*n3
            for m2 in range(n2-n3+m3+1):
                for m1 in range(n1-n2+m2+1):
                    e = (n3**2 + n1**2 + n2**2 - n1*m1 - n2*m2 + m1**2 + m2**2
                         + a1*n1 + a2*n2 + a3*n3 + b1*m1 + b2*m2 + c0)
                    if e >= PREC:
                        continue
                    co = (qbinom(n1, n2) * qbinom(n1-n2+m2, m1)
                          * qbinom(n2, n3) * qbinom(n2-n3+m3, m2))
                    result += q**e * co
    return result

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

uncovered = [(7,0,1),(6,0,2),(6,1,1),(5,0,3),(5,2,1),(5,1,2),(4,4,0),(4,3,1),(4,1,3),(4,2,2)]
CH = 45

for c in uncovered:
    t1 = QN[f"{c}|1"]; t1 = t1 + [0]*(CH-len(t1))
    t2 = QN[f"{c}|2"]; t2 = t2 + [0]*(CH-len(t2))
    hits = []
    for lin in itertools.product(range(3), range(3), range(3), range(3), range(3), range(2)):
        f1 = ferm_generic(1, lin)
        if [f1[i] for i in range(CH)] != t1[:CH]:
            continue
        f2 = ferm_generic(2, lin)
        if [f2[i] for i in range(CH)] == t2[:CH]:
            hits.append(lin)
    print(f"c={c}: single-term hits (a1,a2,a3,b1,b2,c0) = {hits}", flush=True)
