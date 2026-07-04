"""
Seed 3, R2L2, Script 7:
 (a) Monotonicity H_{c,m} >= H_{c,m-1} for d=7,8,10,11 (exact, m<=5).
 (b) Verify Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m} against the
     D-tower Q_n for d=4 (Q_2 at (2,1,1) known: 1+q+q^3+2q^4+q^5+3q^6+2q^7+2q^8+q^9+q^10+q^12).
"""
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

for d in [7, 8, 10, 11]:
    Hs = compute_H(d, 5)
    profs = profiles(d)
    bad = [(c, m) for m in range(1, 6) for c in profs
           if any(v < 0 for v in (Hs[m][c] - Hs[m-1][c]).list())]
    print(f"d={d}: monotonicity H_m >= H_(m-1), m<=5: {'HOLDS all profiles' if not bad else f'FAILS {bad[:5]}'}", flush=True)

# (b) Q_n check for d=4
def qbin(n, k):
    if k < 0 or k > n: return Rq(0)
    return Rq(q_binomial(n, k))

Hs = compute_H(4, 4)
c = (2, 1, 1)
for n in range(5):
    Qn = sum((-1)^(n-m) * q^(binomial(n-m, 2)) * qbin(n, m) * Hs[m][c] for m in range(n+1))
    nn = all(v >= 0 for v in Qn.list())
    print(f"d=4 c={c} Q_{n} via H-transform: {Qn if Qn.degree() <= 14 else str(Qn)[:80]}  nonneg={nn}")
print("expected Q_2 = 1+q+q^3+2q^4+q^5+3q^6+2q^7+2q^8+q^9+q^10+q^12")
