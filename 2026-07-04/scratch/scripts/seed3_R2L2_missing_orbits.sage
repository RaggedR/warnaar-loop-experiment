"""
Seed 3, R2L2, Script 8: hunt bounded forms for the two missing d=4 orbits (0,2,2),(0,3,1).
Ansatz family:
  H_{c,m} =? sum_{n1,n2} q^{n1^2+n2^2-n1n2 + a*n1 + b*n2} [m+delta, n1]_q [2n1+eps, n2]_q * PF
with PF in {1, 1+q^{n1+n2+1}, 1+q^{n1+1}, 1+q^{n2+1}, 1+q^{2n1+n2+2}... small set},
a,b in {0,1,2}, eps in {0,1}, delta in {0,1}.
Also try 2-term combos of plain forms: plain(a,b,eps) + q^w * plain(a2,b2,eps2), w in {0,1,2}.
Match m = 0..5 exactly.
"""
from itertools import product as iproduct
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def compute_H(d, m_max):
    profs = profiles(d)
    Hs = [{c: Rq(1) for c in profs}]
    for m in range(1, m_max+1):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*emd(cp, c)) * Hs[m-1][cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0
            Hnew[c] = quo
        Hs.append(Hnew)
    return Hs

def qbin(n, k):
    if k < 0 or k > n: return Rq(0)
    return Rq(q_binomial(n, k))

M = 5
Hs = compute_H(4, M)
targets = {c: [Hs[m][c] for m in range(M+1)] for c in [(0,2,2), (0,3,1)]}

PFs = {
    '1': lambda n1, n2: Rq(1),
    '1+q^(n1+n2+1)': lambda n1, n2: 1 + q^(n1+n2+1),
    '1+q^(n1+1)': lambda n1, n2: 1 + q^(n1+1),
    '1+q^(n2+1)': lambda n1, n2: 1 + q^(n2+1),
    '1+q^(2n1+n2+2)': lambda n1, n2: 1 + q^(2*n1+n2+2),
    '1+q^(n1+n2+1)+q^(2n1+n2+2)': lambda n1, n2: 1 + q^(n1+n2+1) + q^(2*n1+n2+2),
}

def plain(m, a, b, eps, delta=0, pf=None):
    s = Rq(0)
    for n1 in range(m+delta+1):
        for n2 in range(2*n1+eps+1):
            t = q^(n1^2+n2^2-n1*n2 + a*n1 + b*n2) * qbin(m+delta, n1) * qbin(2*n1+eps, n2)
            if pf is not None: t *= pf(n1, n2)
            s += t
    return s

print("--- single-form search with prefactors ---")
for c, Hv in targets.items():
    hits = []
    for a, b, eps, delta in iproduct(range(3), range(3), range(2), range(2)):
        for pfname, pf in PFs.items():
            if all(plain(m, a, b, eps, delta, pf) == Hv[m] for m in range(M+1)):
                hits.append((a, b, eps, delta, pfname))
    print(f"  c={c}: {hits if hits else 'none'}", flush=True)

print("--- two-term combos of plain forms ---")
forms = {}
for a, b, eps in iproduct(range(3), range(3), range(2)):
    forms[(a,b,eps)] = [plain(m, a, b, eps) for m in range(M+1)]
keys = list(forms)
for c, Hv in targets.items():
    hits = []
    for k1 in keys:
        for k2 in keys:
            for w in range(4):
                if all(forms[k1][m] + q^w * forms[k2][m] == Hv[m] for m in range(M+1)):
                    hits.append((k1, k2, w))
    print(f"  c={c}: {hits if hits else 'none'}", flush=True)
