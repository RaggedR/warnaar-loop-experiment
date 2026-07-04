"""Seed 2, R2 L3: distortion-move (M1) fits for the d=8 frontier orbits.

Candidate: Q_n = delta_{n,0} + ferm_M1(n; lin, i_shift)
in the Warnaar k=3 basis (5-fold sum, m3 := 2*n3), where M1(i) shifts the
top of the i-th m-binomial by -1 and inserts the factor (1+q^{m_i - t_i' + m_{i+1}}).

Scan lin in {0,1}^5 x i in {1,2} against ground truth (seed5_R2L2_qn_d8.json),
n = 1..3 at PREC 200; verify hits at n = 4.
"""
from sage.all import *
import json, itertools

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

def ferm_M1(n, lin, i_shift, prec):
    """Q_n-level sum: (q)_n * [z^n] GKt-candidate = finite sum (denom (q)_{n1} cancels).

    i_shift in {0,1,2}: 0 = no shift (covered basis), 1/2 = M1 on binomial 1/2.
    """
    a1, a2, a3, b1, b2 = lin
    result = R(0)
    n1 = n
    for n2 in range(n1+1):
        for n3 in range(n2+1):
            m3 = 2*n3
            t2 = n2 - n3 + m3
            t2e = t2 - 1 if i_shift == 2 else t2
            for m2 in range(t2e+1):
                t1 = n1 - n2 + m2
                t1e = t1 - 1 if i_shift == 1 else t1
                for m1 in range(t1e+1):
                    e = (n1**2 + n2**2 + n3**2 - n1*m1 - n2*m2 + m1**2 + m2**2
                         + a1*n1 + a2*n2 + a3*n3 + b1*m1 + b2*m2)
                    if e >= prec:
                        continue
                    base = (qbinom(n1,n2) * qbinom(t1e,m1)
                            * qbinom(n2,n3) * qbinom(t2e,m2))
                    term = q**e * base
                    if i_shift == 1:
                        f = m1 - n1 + n2 + 1
                        term = term + (q**(e+f) * base if e+f < prec else 0)
                    elif i_shift == 2:
                        f = m2 - n2 + n3 + 1
                        term = term + (q**(e+f) * base if e+f < prec else 0)
                    result += term
    return result

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

def truth(c, n, ncheck):
    t = QN[f"{c}|{n}"]
    return (t + [0]*ncheck)[:ncheck]

covered = {(8,0,0): (1,1,1,1,1), (7,1,0): (0,1,1,1,1), (6,2,0): (0,0,1,1,1),
           (5,3,0): (0,0,0,1,1), (3,3,2): (0,0,0,0,0)}
print("== sanity (covered orbits, no shift) ==")
CH = 180
for c, lin in covered.items():
    ok = all(all(ferm_M1(n, lin, 0, 200)[i] == truth(c,n,CH)[i] for i in range(CH))
             for n in [1,2,3])
    print(f"  {c} lin={lin}: {'OK' if ok else 'FAIL'}")

frontier = [(5,2,1), (6,1,1), (5,1,2), (4,1,3), (4,2,2)]
print("== M1 scan, n=1..3 ==")
hits = {}
for c in frontier:
    tr = {n: truth(c, n, CH) for n in [1,2,3]}
    for lin in itertools.product([0,1], repeat=5):
        for ish in [1,2]:
            ok = True
            for n in [1,2,3]:
                f = ferm_M1(n, lin, ish, 200)
                if any(f[i] != tr[n][i] for i in range(CH)):
                    ok = False
                    break
            if ok:
                hits.setdefault(c, []).append((lin, ish))
                print(f"  HIT {c}: lin={lin} shift={ish}")
    if c not in hits:
        print(f"  {c}: no hit in {{0,1}}^5 x {{1,2}}")

print("== verify hits at n=4, PREC 300 ==")
CH4 = 280
for c, lst in hits.items():
    tr4 = truth(c, 4, CH4)
    for (lin, ish) in lst:
        f = ferm_M1(4, lin, ish, PREC)
        ok = all(f[i] == tr4[i] for i in range(CH4))
        print(f"  {c} lin={lin} shift={ish} n=4: {'OK' if ok else 'FAIL'}")
