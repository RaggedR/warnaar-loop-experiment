"""
Seed 5 R2 L2 — extend to n=5,6 at d=8:
(a) CW/adjugate ground truth Q_n for all 45 profiles, n=5,6 (positivity + Q_n(1)=14^n),
(b) Warnaar k=3 fermionic Q_n for 5 covered orbits at n=5,6,
(c) Uncu proved S_11 Q_n for all 15 orbits at n=5,6.
PREC=450 >= 6*36+200 = 416.
"""
from sage.all import *
import itertools

D = 8
PREC = 450
NMAX = 6
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()

profiles = [(a, b, D - a - b) for a in range(D + 1) for b in range(D - a + 1)]
idx = {c: i for i, c in enumerate(profiles)}
NP = len(profiles)

def emd(c, cp):
    g = [0, c[1] - cp[1], c[1] + c[2] - cp[1] - cp[2]]
    return sum(g) - 3 * min(g)

_qp = {0: R(1)}
def qpoch(n):
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

# ---------- (a) CW ground truth ----------
F = {0: [R(1)] * NP}
EM = [[emd(c, cp) for cp in profiles] for c in profiles]
for m in range(1, NMAX + 1):
    inv = (1 - q**(3*m))**(-1)
    F[m] = [sum(q**(m * EM[i][j]) * F[m-1][j] for j in range(NP)) * inv for i in range(NP)]
phi = {0: F[0]}
for m in range(1, NMAX + 1):
    phi[m] = [F[m][i] - F[m-1][i] for i in range(NP)]

CHECKTO = PREC - 20
Qtruth = {}
allpos = True
for n in [5, 6]:
    for i, c in enumerate(profiles):
        s = R(0)
        for j in range(n + 1):
            s += (-1)**j * q**(j*(j+1)//2) * qpoch_inv(j) * phi[n-j][i]
        Qn = qpoch(n) * s
        coeffs = [Qn[t] for t in range(CHECKTO)]
        deg = max((t for t in range(CHECKTO) if coeffs[t] != 0), default=-1)
        ok = (sum(coeffs) == 14**n) and all(v >= 0 for v in coeffs)
        if not ok:
            allpos = False
            print(f"PROBLEM n={n} c={c}")
        Qtruth[(c, n)] = coeffs
print(f"(a) CW: all 45 profiles, n=5,6: polynomial-window nonneg + Q_n(1)=14^n: {allpos}")

# ---------- (b) Warnaar fermionic ----------
K = 3
def qbinom(nv, mv):
    if mv < 0 or mv > nv or nv < 0:
        return R(0)
    return qpoch(nv) * qpoch_inv(mv) * qpoch_inv(nv - mv)

def ferm_Qn(k, n, s=None, balanced=False):
    result = R(0)
    nl = [0]*(k+1); nl[1] = n
    def enum_n(idx):
        nonlocal result
        if idx > k:
            ml = [0]*(k+1); ml[k] = 2*nl[k]
            def enum_m(j):
                nonlocal result
                if j < 1:
                    e = nl[k]**2
                    if not balanced:
                        e += sum(nl[i] for i in range(s, k+1))
                    for i in range(1, k):
                        e += nl[i]**2 - nl[i]*ml[i] + ml[i]**2
                        if not balanced:
                            e += ml[i]
                    if e >= PREC:
                        return
                    co = R(1)
                    for i in range(1, k):
                        co *= qbinom(nl[i], nl[i+1]) * qbinom(nl[i]-nl[i+1]+ml[i+1], ml[i])
                    result += q**e * co
                    return
                for mj in range(nl[j]-nl[j+1]+ml[j+1] + 1):
                    ml[j] = mj
                    enum_m(j-1)
            enum_m(k-1)
            return
        for ni in range(nl[idx-1] + 1):
            nl[idx] = ni
            enum_n(idx+1)
    enum_n(2)
    return result

okb = True
for s in range(1, K+2):
    c = (3*K - s, s - 1, 0)
    for n in [5, 6]:
        fq = ferm_Qn(K, n, s=s)
        ok = all(fq[t] == Qtruth[(c, n)][t] for t in range(CHECKTO))
        okb &= ok
        print(f"(b) Warnaar ferm c={c} n={n}: {ok}")
c = (K, K, K-1)
for n in [5, 6]:
    fq = ferm_Qn(K, n, balanced=True)
    ok = all(fq[t] == Qtruth[(c, n)][t] for t in range(CHECKTO))
    okb &= ok
    print(f"(b) Warnaar ferm c={c} n={n}: {ok}")
print(f"(b) all: {okb}")

# ---------- (c) Uncu S11 ----------
SMAX = 45
_dens = {}
def den_s(a, b, s3, r3):
    key = (a, b, s3, r3)
    if key not in _dens:
        _dens[key] = qpoch_inv(a)*qpoch_inv(b)*qpoch_inv(s3)*qpoch_inv(r3+s3+1)
    return _dens[key]

_T = {}
def T(n, rho, sig):
    key = (n, rho, sig)
    if key in _T:
        return _T[key]
    if n < 0:
        return R(0)
    res = R(0)
    r1 = n
    for r2 in range(r1 + 1):
        for r3 in range(r2 + 1):
            denr = qpoch_inv(r1-r2)*qpoch_inv(r2-r3)*qpoch_inv(r3)
            acc = R(0)
            base_r = r1*r1 + r2*r2 + r3*r3 + rho[0]*r1 + rho[1]*r2 + rho[2]*r3
            for s1 in range(SMAX):
                if s1*s1 - r1*s1 + sig[0]*s1 + base_r >= PREC and s1 > r1 + 2:
                    break
                for s2 in range(s1 + 1):
                    for s3 in range(s2 + 1):
                        e = (base_r - r1*s1 - r2*s2 - r3*s3
                             + s1*s1 + s2*s2 + s3*s3
                             + sig[0]*s1 + sig[1]*s2 + sig[2]*s3 + 2*r3*s3)
                        if e >= PREC:
                            continue
                        acc += q**e * den_s(s1-s2, s2-s3, s3, r3)
            res += denr * acc
    _T[key] = res
    return res

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
    res = R(0)
    for (typ, rho, sig) in FORM[c]:
        if typ == '1':
            res += T(n, rho, sig)
        elif typ == '-q':
            res += -q * T(n, rho, sig)
        elif typ == '-q(1-z)':
            res += -q * (T(n, rho, sig) - T(n-1, rho, sig))
        elif typ == '+qz':
            res += q * T(n-1, rho, sig)
    return res

okc = True
for c in FORM:
    line = f"(c) Uncu c={c}:"
    for n in [5, 6]:
        Qn = qpoch(n) * qinf * zn_H(c, n)
        ok = all(Qn[t] == Qtruth[(c, n)][t] for t in range(CHECKTO))
        okc &= ok
        line += f" n={n}:{ok}"
    print(line, flush=True)
print(f"(c) all: {okc}")
print(f"\nGRAND: (a)={allpos} (b)={okb} (c)={okc}")
