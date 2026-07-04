"""
Seed 5 R2 L2 — Plan C: Q_n from Uncu's PROVED S_11 formulas (arXiv Uncu 2024, Thm thm:m11)
vs CW ground truth (seed5_R2L2_qn_d8.json), ALL 15 canonical orbits at d=8, n=0..4.

S_11(z;rho|sigma) = sum_{r1>=r2>=r3>=0, s1>=s2>=s3>=0} z^{r1}
   q^{sum_i (r_i^2 - r_i s_i + s_i^2 + rho_i r_i + sigma_i s_i) + 2 r3 s3}
   / [(q)_{r1-r2}(q)_{r2-r3}(q)_{s1-s2}(q)_{s2-s3}(q)_{r3}(q)_{s3}(q)_{r3+s3+1}]

Q_{n,c} = (q)_n * (q)_infty * [z^n] H_c(z,q).
[z^n] S_11 = restrict r1 = n.  (1-z)S: [z^n]S - [z^{n-1}]S.  z*S: [z^{n-1}]S.
"""
from sage.all import *
import json

PREC = 300
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()

_qp = {0: R(1)}
def qpoch(n):
    if n < 0:
        return None
    if n not in _qp:
        _qp[n] = qpoch(n - 1) * (1 - q**n)
    return _qp[n]

_qpi = {}
def qpoch_inv(n):
    if n not in _qpi:
        _qpi[n] = qpoch(n)**(-1)
    return _qpi[n]

qinf = R(1)
for i in range(1, PREC):
    qinf *= 1 - q**i

SMAX = 40

_T = {}
def T(n, rho, sig):
    """[z^n] S_11(z; rho|sigma) as power series (r1 = n)."""
    key = (n, rho, sig)
    if key in _T:
        return _T[key]
    if n < 0:
        return R(0)
    res = R(0)
    r1 = n
    for r2 in range(r1 + 1):
        for r3 in range(r2 + 1):
            for s1 in range(SMAX):
                base1 = (r1*r1 - r1*s1 + s1*s1 + rho[0]*r1 + sig[0]*s1)
                if base1 - 2*SMAX*SMAX >= PREC:
                    break
                for s2 in range(s1 + 1):
                    for s3 in range(min(s2, SMAX) + 1):
                        e = (r1*r1 - r1*s1 + s1*s1 + rho[0]*r1 + sig[0]*s1
                             + r2*r2 - r2*s2 + s2*s2 + rho[1]*r2 + sig[1]*s2
                             + r3*r3 - r3*s3 + s3*s3 + rho[2]*r3 + sig[2]*s3
                             + 2*r3*s3)
                        if e >= PREC:
                            continue
                        den = (qpoch_inv(r1-r2) * qpoch_inv(r2-r3) * qpoch_inv(r3)
                               * qpoch_inv(s1-s2) * qpoch_inv(s2-s3) * qpoch_inv(s3)
                               * qpoch_inv(r3+s3+1))
                        res += q**e * den
    _T[key] = res
    return res

# H_c formulas: list of (coefftype, rho, sigma); coefftype in {'1','-q','-q(1-z)','+qz'}
FORM = {
 (8,0,0): [('1',(1,1,1),(1,1,1))],
 (7,1,0): [('1',(0,1,1),(1,1,1))],
 (7,0,1): [('1',(1,1,1),(0,1,1)), ('-q(1-z)',(2,1,1),(1,1,1))],
 (6,2,0): [('1',(0,0,1),(1,1,1))],
 (6,1,1): [('1',(0,1,1),(0,1,1)), ('-q',(1,1,1),(1,1,1))],
 (6,0,2): [('1',(1,1,1),(0,0,1)), ('-q(1-z)',(2,1,1),(0,1,1))],
 (5,3,0): [('1',(0,0,0),(1,1,1))],
 (5,2,1): [('1',(0,0,1),(0,1,1)), ('-q',(0,1,1),(1,1,1))],
 (5,1,2): [('1',(0,1,1),(0,0,1)), ('-q',(1,1,1),(0,1,1))],
 (5,0,3): [('1',(1,1,1),(0,0,0)), ('-q(1-z)',(2,1,1),(0,0,1))],
 (4,3,1): [('1',(0,0,0),(0,1,1)), ('-q',(0,0,1),(1,1,1))],
 (4,2,2): [('1',(0,0,1),(0,0,1)), ('-q',(0,1,1),(0,1,1))],
 (4,1,3): [('1',(0,1,1),(0,0,0)), ('-q',(1,1,1),(0,0,1))],
 (3,3,2): [('1',(0,0,0),(0,0,1)), ('-q',(0,0,1),(0,1,1))],
 (4,4,0): [('1',(1,0,0),(0,1,1)), ('-q',(1,0,1),(1,1,1)), ('+qz',(2,1,1),(0,0,0))],
}

def zn_H(c, n):
    """[z^n] H_c."""
    res = R(0)
    for (typ, rho, sig) in FORM[c]:
        if typ == '1':
            res += T(n, rho, sig)
        elif typ == '-q':
            res += -q * T(n, rho, sig)
        elif typ == '-q(1-z)':
            res += -q * (T(n, rho, sig) - T(n - 1, rho, sig))
        elif typ == '+qz':
            res += q * T(n - 1, rho, sig)
    return res

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

CHECKTO = PREC - 20
allok = True
for c in FORM:
    # sanity at n=0: H_c(0,q) = 1/(q)_inf  => (q)_inf*[z^0]H = 1
    h0 = qinf * zn_H(c, 0)
    ok0 = all(h0[i] == (1 if i == 0 else 0) for i in range(CHECKTO))
    line = f"c={c}: n0-init={ok0}"
    for n in range(1, 5):
        Qn = qpoch(n) * qinf * zn_H(c, n)
        truth = QN[f"{c}|{n}"]
        tc = truth + [0] * (CHECKTO - len(truth))
        ok = all(Qn[i] == tc[i] for i in range(CHECKTO))
        allok &= ok and ok0
        line += f"  n={n}:{ok}"
    print(line)

print(f"\nALL UNCU S11 (PROVED) CHECKS vs CW ground truth, 15 orbits, n=1..4: {allok}")
