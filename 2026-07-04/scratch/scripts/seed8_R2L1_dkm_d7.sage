"""
Check D_k^m for d=7, c=(3,2,2) where h_m should have negative coefficients for m>=2.
Also d=5, c=(2,2,1) for contrast.
"""
from sage.all import *
from itertools import combinations as combs

def compute_Dkm(d, c, k_max, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * max(k_max, m_max)**2 + 100
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    r = 3
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N = len(compositions)
    comp_idx = {comp: i for i, comp in enumerate(compositions)}
    ci_idx = comp_idx[c]

    def shift_profile(comp, J):
        result = list(comp)
        J_set = set(J)
        for i in range(3):
            prev = (i - 1) % 3
            if i in J_set and prev not in J_set:
                result[i] -= 1
            elif i not in J_set and prev in J_set:
                result[i] += 1
        return tuple(result)

    Rx = PolynomialRing(QQ, 'x')
    x_var = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    for ic2, comp2 in enumerate(compositions):
        I_c = {i for i in range(3) if comp2[i] > 0}
        if not I_c:
            continue
        for size in range(1, len(I_c) + 1):
            for J in combs(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(comp2, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                jcJ = comp_idx[cJ]
                A_poly[ic2, jcJ] += sign * x_var**size

    def eval_A(val):
        A_eval = matrix(R, N, N)
        for i in range(N):
            for j in range(N):
                poly = A_poly[i,j]
                v = R(0)
                for k2, coeff in enumerate(poly.list()):
                    v += coeff * val**k2
                A_eval[i,j] = v
        return A_eval

    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    v_all = [vector(R, [R(1)] * N)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)

    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])

    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result

    h_all = [R(1)]
    for m in range(1, m_max + 1):
        h_all.append(qpoch(m) * g_all[m])

    D = {}
    for m in range(m_max + 1):
        D[(0, m)] = h_all[m]
    for k in range(1, k_max + 1):
        for m in range(k, m_max + 1):
            D[(k, m)] = D[(k-1, m)] - q**k * D[(k-1, m-1)]

    return D, R, q

# Test d=4, c=(2,1,1) - h_2 should be nonneg according to our computation
print("d=4, c=(2,1,1):")
D4, R4, q4 = compute_Dkm(4, (2,1,1), 4, 4, PREC=400)
for m in range(1, 5):
    Dkm = D4[(0, m)]
    coeffs = [Dkm[i] for i in range(min(200, Dkm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
    print(f"  h_{m}: deg={max_d2}, nonneg={len(negs)==0}, negs={negs[:5]}")
    if max_d2 <= 30:
        print(f"    {poly}")

# Now d=7, c=(3,2,2) - this is where synthesis says h_m<0 for m>=2
print("\nd=7, c=(3,2,2):")
D7, R7, q7 = compute_Dkm(7, (3,2,2), 4, 4, PREC=600)
for m in range(1, 5):
    Dkm = D7[(0, m)]
    coeffs = [Dkm[i] for i in range(min(300, Dkm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
    print(f"  h_{m}: deg={max_d2}, nonneg={len(negs)==0}, negs={negs[:10]}")

# Check D_1^m for d=7
for m in range(1, 5):
    Dkm = D7[(1, m)]
    coeffs = [Dkm[i] for i in range(min(300, Dkm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
    print(f"  D(1,{m}): deg={max_d2}, nonneg={len(negs)==0}, negs={negs[:10]}")

# D_k^m(1) table for d=7
print("\nD_k^m(1) for d=7:")
for k in range(5):
    row = f"k={k}: "
    for m in range(max(k,1), 5):
        if (k,m) in D7 and m >= k:
            Dkm = D7[(k,m)]
            coeffs = [Dkm[i] for i in range(min(300, Dkm.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            val = sum(coeffs[:max_d2+1])
            row += f"D({k},{m})={int(val)}  "
    print(row)
