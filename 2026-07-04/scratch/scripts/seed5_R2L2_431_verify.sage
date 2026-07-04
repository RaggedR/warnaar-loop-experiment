"""Verify the (4,3,1) CDU-style candidate at n=4 (PREC 300, vs JSON truth)."""
from sage.all import *
import json

PREC = 300
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()
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

def ferm_generic(n, lin, prec):
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
                    if e >= prec:
                        continue
                    result += q**e * (qbinom(n1,n2)*qbinom(n1-n2+m2,m1)
                                      *qbinom(n2,n3)*qbinom(n2-n3+m3,m2))
    return result

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

c = (4,3,1)
cands = [((0,0,0,1,0,0), 0, 1, (1,0,0,1,1,0)),
         ((0,0,0,1,0,0), 0, 0, (1,0,0,1,1,1)),
         ((0,0,0,1,0,0), 1, 0, (0,0,0,1,1,0))]
n = 4
t = QN[f"{c}|{n}"]; CH = PREC - 10; tv = (t + [0]*CH)[:CH]
for (lin1, u, v0, lin2) in cands:
    f = ferm_generic(n, lin1, PREC) + q**(n*u+v0) * (1-q**n) * ferm_generic(n-1, lin2, PREC)
    ok = all(f[i] == tv[i] for i in range(CH))
    print(f"(4,3,1) n=4 cand lin1={lin1} u={u} v={v0} lin2={lin2}: {ok}")
