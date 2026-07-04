"""
Seed 3, R2L3, Script 1: exact structure of the differences D_{c,m} = H_{c,m} - H_{c,m-1}.

Answers Q1-Q5 of scratch/prove-seed3-layer3.md. All EXACT in ZZ[q] except Q3 (power series).
"""
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    t_min = max(0, -e[0], -e[0]-e[1])
    return 2*e[0] + e[1] + 3*t_min

def rho(a): return (a[1], a[2], a[0])

def op(d, x_exp, v):
    """Apply the transfer operator with x = q^{x_exp} to rotation-invariant vector v,
    dividing exactly by 1 + q^{x_exp} + q^{2 x_exp}. Returns dict or raises."""
    profs = profiles(d)
    div = 1 + q^x_exp + q^(2*x_exp)
    out = {}
    for c in profs:
        rhs = sum(q^(x_exp*emd(cp, c)) * v[cp] for cp in profs)
        quo, rem = rhs.quo_rem(div)
        assert rem == 0, f"division not exact x_exp={x_exp} c={c}"
        out[c] = quo
    return out

def compute_H(d, m_max):
    profs = profiles(d)
    Hs = [{c: Rq(1) for c in profs}]
    for m in range(1, m_max+1):
        Hs.append(op(d, m, Hs[m-1]))
    return Hs

def nonneg(p): return all(v >= 0 for v in p.list())

def cJ(c, J):
    out = list(c)
    for i in range(3):
        inJ = i in J; prevJ = ((i-1) % 3) in J
        if inJ and not prevJ: out[i] -= 1
        elif prevJ and not inJ: out[i] += 1
    return tuple(out)

def subsets_I(c):
    I = [i for i in range(3) if c[i] > 0]
    from itertools import combinations
    for r in range(1, len(I)+1):
        for J in combinations(I, r): yield set(J)

cases = [(2, 8), (4, 7), (5, 6), (7, 4)]

for d, m_max in cases:
    profs = profiles(d)
    Hs = compute_H(d, m_max)
    D = [None] + [{c: Hs[m][c] - Hs[m-1][c] for c in profs} for m in range(1, m_max+1)]
    print(f"\n================ d={d}, m<={m_max} ================")
    # sanity: monotonicity
    bad = [(c, m) for m in range(1, m_max+1) for c in profs if not nonneg(D[m][c])]
    print("Monotonicity D>=0:", "PASS" if not bad else f"FAIL {bad[:5]}")

    # Q1: U(q^m) D_{m-1} >= 0 ?
    q1_fail = []
    for m in range(2, m_max+1):
        UD = op(d, m, D[m-1])
        for c in profs:
            if not nonneg(UD[c]): q1_fail.append((m, c))
    print("Q1 (U(q^m)D_{m-1} >= 0):", "PASS all" if not q1_fail else f"FAIL at {q1_fail[:6]} ({len(q1_fail)} total)")

    # Q2: [U(q^m)-U(q^{m-1})] H_{m-2} >= 0 ?
    q2_fail = []
    for m in range(2, m_max+1):
        Um = op(d, m, Hs[m-2]); Um1 = op(d, m-1, Hs[m-2])
        for c in profs:
            if not nonneg(Um[c] - Um1[c]): q2_fail.append((m, c))
    print("Q2 ([U(q^m)-U(q^{m-1})]H_{m-2} >= 0):", "PASS all" if not q2_fail else f"FAIL at {q2_fail[:6]} ({len(q2_fail)} total)")

    # Q4: raw vector (A^T - q^m I) H_{m-1} >= 0 ?
    q4_fail = []
    for m in range(1, m_max+1):
        for c in profs:
            w = -q^m * Hs[m-1][c]
            for cp in profs:
                for J in subsets_I(cp):
                    if cJ(cp, J) == c:
                        w += (-1)^(len(J)-1) * q^(m*len(J)) * Hs[m-1][cp]
            if not nonneg(w): q4_fail.append((m, c))
    print("Q4 (raw (A^T - q^m I)H_{m-1} >= 0):", "PASS all" if not q4_fail else f"FAIL at {q4_fail[:6]} ({len(q4_fail)} of {m_max*len(profs)})")

    # Q5 structure: lowest-degree of D, and divisibility by q^m
    print("Q5: valuation of D_{c,m} vs m (is D divisible by q^m?):")
    for c in sorted(set(min([c, rho(c), rho(rho(c))]) for c in profs)):
        vals = [D[m][c].valuation() if D[m][c] != 0 else None for m in range(1, m_max+1)]
        print(f"   c={c}: val(D_m) = {vals}")
