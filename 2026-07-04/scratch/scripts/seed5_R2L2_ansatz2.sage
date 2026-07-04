"""
Two-term z-free numerator ansatz: Q_n = F(lin1) + F(lin2), lin in {0..3}^5 x {0..3},
matched at n=1 via hash pairing, verified at n=2 and n=3.
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

LINS = list(itertools.product(range(4), range(4), range(4), range(4), range(4), range(4)))
CH1 = 40
print(f"precomputing {len(LINS)} n=1 vectors...", flush=True)
V1 = {}
for lin in LINS:
    f1 = ferm_generic(1, lin, CH1)
    V1[lin] = tuple(f1[i] for i in range(CH1))
# hash: vector -> list of lins
from collections import defaultdict
H = defaultdict(list)
for lin, v in V1.items():
    H[v].append(lin)

uncovered = [(7,0,1),(6,0,2),(6,1,1),(5,0,3),(5,2,1),(5,1,2),(4,4,0),(4,3,1),(4,1,3),(4,2,2)]
CH2 = 60

for c in uncovered:
    t1 = QN[f"{c}|1"]; t1 = tuple((t1 + [0]*CH1)[:CH1])
    cands = set()
    for lin, v in V1.items():
        need = tuple(t1[i] - v[i] for i in range(CH1))
        if min(need) < 0:
            continue
        for lin2 in H.get(need, []):
            cands.add(tuple(sorted([lin, lin2])))
    # verify at n=2 then n=3
    t2 = QN[f"{c}|2"]; t2v = tuple((t2 + [0]*CH2)[:CH2])
    good = []
    for (l1, l2) in cands:
        f2 = ferm_generic(2, l1, CH2) + ferm_generic(2, l2, CH2)
        if tuple(f2[i] for i in range(CH2)) == t2v:
            good.append((l1, l2))
    good3 = []
    t3 = QN[f"{c}|3"]; t3v = tuple((t3 + [0]*PREC)[:PREC-5])
    for (l1, l2) in good:
        f3 = ferm_generic(3, l1, PREC) + ferm_generic(3, l2, PREC)
        if tuple(f3[i] for i in range(PREC-5)) == t3v:
            good3.append((l1, l2))
    print(f"c={c}: n=1 pairs={len(cands)}, n=2 survivors={len(good)}, n=3 survivors={good3}", flush=True)
