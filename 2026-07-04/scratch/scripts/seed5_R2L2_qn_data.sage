"""
Seed 5 R2 L2 — Part A: exact Q_{n,c} for all 45 profiles at d=8, n=0..4,
via the bounded Corteel-Welsh F-system inverted with the (proved) Adjugate Monomial Theorem.

System: phi_{c,m} := [z^m] F_c(z,q),  F_{c,m} := sum_{j<=m} phi_{c,j} (bounded GF, max <= m).
CW => phi_{c,m} = sum_{0<J<=I_c} (-1)^{|J|-1} q^{m|J|} F_{c(J),m}
   => (I - A(q^m)) F_{.,m} = F_{.,m-1},  A(x)[c,c(J)] += (-1)^{|J|-1} x^{|J|}.
Adjugate Monomial Theorem (Seed 4, GREEN): adj(I-A(x))[c,c'] = x^{EMD(c,c')},
det(I-A(x)) = 1-x^3  =>  F_{c,m} = (1-q^{3m})^{-1} sum_{c'} q^{m EMD(c,c')} F_{c',m-1}.

Q_{n,c} = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2}/(q;q)_j * phi_{c,n-j}.  (ell=1 for d=8)
"""
from sage.all import *
import json, itertools

D = 8
PREC = 400
NMAX = 4
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()

profiles = [(a, b, D - a - b) for a in range(D + 1) for b in range(D - a + 1)]
idx = {c: i for i, c in enumerate(profiles)}
NP = len(profiles)
print(f"{NP} profiles at d={D}")

# ---------- c(J) ----------
def cJ(c, J):
    out = []
    for i in range(3):
        v = c[i]
        if i in J and ((i - 1) % 3) not in J:
            v -= 1
        elif i not in J and ((i - 1) % 3) in J:
            v += 1
        out.append(v)
    return tuple(out)

# ---------- A(x) as dict of dicts of poly-in-x coefficient lists ----------
Rx = PolynomialRing(ZZ, 'x')
x = Rx.gen()
A = [[Rx(0)] * NP for _ in range(NP)]
for c in profiles:
    Ic = [i for i in range(3) if c[i] > 0]
    for r in range(1, len(Ic) + 1):
        for J in itertools.combinations(Ic, r):
            cp = cJ(c, set(J))
            assert min(cp) >= 0 and sum(cp) == D, (c, J, cp)
            A[idx[c]][idx[cp]] += (-1) ** (r - 1) * x ** r

MA = matrix(Rx, A)
I_A = matrix.identity(Rx, NP) - MA

# ---------- EMD (clockwise transport on Z/3) ----------
def emd(c, cp):
    # f_{i-1} - f_i = cp_i - c_i, flows f_i >= 0 on edge i -> i+1
    g0 = 0
    g1 = c[1] - cp[1]
    g2 = c[1] + c[2] - cp[1] - cp[2]
    g = [g0, g1, g2]
    return sum(g) - 3 * min(g)

M = matrix(Rx, [[x ** emd(c, cp) for cp in profiles] for c in profiles])

# ---------- verify adjugate identity ----------
P1 = I_A * M
ok1 = all(P1[i][j] == ((1 - x ** 3) if i == j else 0) for i in range(NP) for j in range(NP))
P2 = M * I_A
ok2 = all(P2[i][j] == ((1 - x ** 3) if i == j else 0) for i in range(NP) for j in range(NP))
print(f"(I-A)*q^EMD == (1-x^3)I : {ok1};  q^EMD*(I-A) == (1-x^3)I : {ok2}")
assert ok1 and ok2

# ---------- iterate bounded system ----------
F = {0: [R(1)] * NP}
for m in range(1, NMAX + 1):
    inv = (1 - q ** (3 * m)) ** (-1)
    newF = []
    for i, c in enumerate(profiles):
        s = R(0)
        for j, cp in enumerate(profiles):
            s += q ** (m * emd(c, cp)) * F[m - 1][j]
        newF.append(s * inv)
    F[m] = newF
    print(f"level m={m} done")

# ---------- sanity: F_{c,1} vs direct enumeration (seed6 style) ----------
def direct_F1(c, prec=120):
    res = R(1)
    S = 100
    for s0 in range(S):
        for s1 in range(min(s0 + c[1] + 1, S)):
            for s2 in range(min(s1 + c[2] + 1, S)):
                if s0 <= s2 + c[0] and max(s0, s1, s2) >= 1 and s0 + s1 + s2 < prec:
                    res += q ** (s0 + s1 + s2)
    return res

for c in [(8, 0, 0), (7, 0, 1), (5, 2, 1), (3, 3, 2), (4, 4, 0)]:
    a = F[1][idx[c]]
    b = direct_F1(c)
    match = all(a[i] == b[i] for i in range(100))
    print(f"F_(c,1) direct check {c}: {match}")
    assert match

# ---------- phi and Q_n ----------
def qfact(n):
    r = R(1)
    for i in range(1, n + 1):
        r *= 1 - q ** i
    return r

phi = {0: F[0]}
for m in range(1, NMAX + 1):
    phi[m] = [F[m][i] - F[m - 1][i] for i in range(NP)]

Q = {}
for n in range(NMAX + 1):
    Qn = []
    for i in range(NP):
        s = R(0)
        for j in range(n + 1):
            s += (-1) ** j * q ** (j * (j + 1) // 2) / qfact(j) * phi[n - j][i]
        Qn.append(qfact(n) * s)
    Q[n] = Qn

# ---------- polynomiality + evaluation checks ----------
CHECK_TO = PREC - 20
results = {}
allok = True
for n in range(NMAX + 1):
    for i, c in enumerate(profiles):
        coeffs = [Q[n][i][t] for t in range(CHECK_TO)]
        # find degree: last nonzero
        deg = max((t for t in range(CHECK_TO) if coeffs[t] != 0), default=-1)
        tail0 = all(coeffs[t] == 0 for t in range(deg + 1, CHECK_TO))
        val1 = sum(coeffs)
        neg = [t for t in range(CHECK_TO) if coeffs[t] < 0]
        ok = tail0 and val1 == 14 ** n and not neg
        if not ok:
            allok = False
            print(f"PROBLEM n={n} c={c}: deg={deg} tail0={tail0} val1={val1} (want {14**n}) neg={neg[:5]}")
        results[f"{c}|{n}"] = coeffs[:deg + 1]
print(f"All Q_n polynomial, nonneg, Q_n(1)=14^n for n=0..{NMAX}, all 45 profiles: {allok}")

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json', 'w') as f:
    json.dump({k: [int(v) for v in vv] for k, vv in results.items()}, f)
print("saved seed5_R2L2_qn_d8.json")

# print canonical-orbit Q_1..Q_3 degrees for the record
def canon(c):
    return min(c, (c[1], c[2], c[0]), (c[2], c[0], c[1]))
seen = set()
for c in profiles:
    k = canon(c)
    if k in seen:
        continue
    seen.add(k)
    for n in [1, 2, 3]:
        cs = results[f"{c}|{n}"]
        print(f"c={c} n={n}: deg={len(cs)-1}, Q_n={cs if n==1 else '...'}")
