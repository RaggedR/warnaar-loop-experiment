"""
CDU-style ansatz for uncovered orbits: bivariate-positive numerator with a z-shift term:
  Q_n = F(lin1, n) + q^{u*n+v} * (1-q^n) * F(lin2, n-1)
(second term from z*q^{...} numerator monomial: n1=n-1, leftover (1-q^n)).
Match n=1 (hash over lin2 too costly; direct double loop with early filter), verify n=2,3.
"""
from sage.all import *
import json, itertools

PREC = 100
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
                    co = (qbinom(n1, n2) * qbinom(n1-n2+m2, m1)
                          * qbinom(n2, n3) * qbinom(n2-n3+m3, m2))
                    result += q**e * co
    return result

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

LINS = [l for l in itertools.product(range(3), range(3), range(3), range(3), range(3), range(3))]
CH1 = 35
# n=1 vectors for first term (n1=1) and second term (n1=0 -> F = q^{c0} only from all-zero vars? n1=0: n2=n3=m1=m2=0 -> q^{c0})
V1 = {lin: tuple(ferm_generic(1, lin, CH1)[i] for i in range(CH1)) for lin in LINS}
# second term at n=1: q^{u+v} (1-q) * F(lin2, 0) = q^{u+v+c0'} (1-q). Only depends on w=u+v+c0'.
uncovered = [(7,0,1),(6,0,2),(6,1,1),(5,0,3),(5,2,1),(5,1,2),(4,4,0),(4,3,1),(4,1,3),(4,2,2)]

for c in uncovered:
    t1 = QN[f"{c}|1"]; t1 = tuple((t1 + [0]*CH1)[:CH1])
    # candidates: t1 - V1[lin1] must equal q^w (1-q) for some w>=1, or be zero (pure single term already excluded)
    cands = []
    for lin1, v in V1.items():
        diff = [t1[i] - v[i] for i in range(CH1)]
        nz = [i for i, d in enumerate(diff) if d != 0]
        if len(nz) == 2 and diff[nz[0]] == 1 and diff[nz[1]] == -1 and nz[1] == nz[0]+1:
            w = nz[0]  # q^w - q^{w+1}
            cands.append((lin1, w))
    # verify n=2: second term = q^{u*2+v}(1-q^2) F(lin2,1); w = u+v+? -- treat second term linear data:
    # parametrize: second term = q^{u*n+v} (1-q^n) F(lin2, n-1). At n=1: exponent shift w' = u+v+c0(lin2).
    # scan u in 0..4, lin2 in LINS with u+v+c0 = w  (v>=0)
    good = []
    t2 = QN[f"{c}|2"]; CH2 = 60; t2v = tuple((t2 + [0]*CH2)[:CH2])
    for (lin1, w) in cands:
        f2a = ferm_generic(2, lin1, CH2)
        for u in range(5):
            for lin2 in LINS:
                v0 = w - u - lin2[5]
                if v0 < 0:
                    continue
                f2 = f2a + q**(2*u+v0) * (1-q**2) * ferm_generic(1, lin2, CH2)
                if tuple(f2[i] for i in range(CH2)) == t2v:
                    good.append((lin1, u, v0, lin2))
    # verify n=3
    t3 = QN[f"{c}|3"]; t3v = tuple((t3 + [0]*PREC)[:PREC-5])
    good3 = []
    for (lin1, u, v0, lin2) in good:
        f3 = ferm_generic(3, lin1, PREC) + q**(3*u+v0) * (1-q**3) * ferm_generic(2, lin2, PREC)
        if tuple(f3[i] for i in range(PREC-5)) == t3v:
            good3.append((lin1, u, v0, lin2))
    print(f"c={c}: n1-cands={len(cands)}, n2-good={len(good)}, n3-good={good3[:4]}{' ...' if len(good3)>4 else ''}", flush=True)
