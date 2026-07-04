"""
Deep check: h_m for d=4, c=(2,1,1), m up to 10 with very high precision.
Also check d=7 profiles.
"""
from sage.all import *
from itertools import combinations as combs

def compute_hm_single(d, c, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * m_max**2 + 200
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
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

    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result

    results = {}
    for m in range(1, m_max + 1):
        gm = v_all[m][ci_idx] - v_all[m-1][ci_idx]
        hm = qpoch(m) * gm
        results[m] = hm
    
    return results, R, q

# d=4, c=(2,1,1), m up to 8 (very high precision)
print("d=4, c=(2,1,1), h_m for m=1..8:")
m_max = 8
PREC = 6 * m_max**2 + 200  # = 584
res4, R4, q4 = compute_hm_single(4, (2,1,1), m_max, PREC)
for m in range(1, m_max+1):
    hm = res4[m]
    coeffs = [hm[i] for i in range(min(PREC-10, hm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    # Degree should be d*m*(m+1)/2 - something
    poly = coeffs[:max_d2+1]
    negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
    is_nonneg = len(negs) == 0
    eval1 = sum(poly)
    print(f"  h_{m}: deg={max_d2}, eval(1)={eval1}, nonneg={is_nonneg}")
    if negs:
        print(f"    NEGATIVE at: {negs[:10]}")
    # Check if degree is within precision
    if max_d2 > PREC - 20:
        print(f"    WARNING: degree {max_d2} near precision limit {PREC}")

# d=7, various profiles  
print("\nd=7, c=(3,2,2), h_m for m=1..5:")
m_max2 = 5
PREC2 = 6 * m_max2**2 + 200
res7, R7, q7 = compute_hm_single(7, (3,2,2), m_max2, PREC2)
for m in range(1, m_max2+1):
    hm = res7[m]
    coeffs = [hm[i] for i in range(min(PREC2-10, hm.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    negs = [(i, poly[i]) for i in range(len(poly)) if poly[i] < 0]
    eval1 = sum(poly)
    print(f"  h_{m}: deg={max_d2}, eval(1)={eval1}, nonneg={len(negs)==0}")
    if negs:
        print(f"    NEGATIVE at: {negs[:10]}")
    if max_d2 > PREC2 - 20:
        print(f"    WARNING: near precision limit")

# The key question: was the synthesis wrong about h_m < 0?
# Or was there a different definition of h_m being used?
# Let's also check: D_0^m = h_m in the synthesis notation.
# h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1}
# This is what we compute. If all nonneg, then the D_k^m tower
# base case IS valid, and the whole tower approach works!
print("\nIf h_m >= 0 for all m, then D_k^m >= 0 for all k >= 0, m >= k")
print("follows by induction since D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}")
print("Wait, that's SUBTRACTION. D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}")
print("So even if D_{k-1}^m >= 0, the subtraction of q^k * D_{k-1}^{m-1} could make it negative.")
print("The tower needs: D_{k-1}^m >= q^k * D_{k-1}^{m-1} coefficient-wise.")
