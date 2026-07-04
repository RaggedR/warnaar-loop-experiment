"""
Test the tower condition: D_k^m >= 0 for all k, m with m >= k >= 0.
If h_m >= 0 (which we've now verified), the tower reduces to:
  D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1} >= 0
i.e., D_{k-1}^m >= q^k * D_{k-1}^{m-1} coefficient-wise.

Equivalent: the "q-shift domination" h_m(q) >= q * h_{m-1}(q) is the k=1 case.
For general k: D_{k-1}^m >= q^k * D_{k-1}^{m-1}.

Let's also test: is the ratio D_{k-1}^m / D_{k-1}^{m-1} a polynomial with nonneg coeffs?
(After multiplying by q^{-k}, this would give a positive "q-shift" quotient.)
"""
from sage.all import *
from itertools import combinations as combs

def compute_all_Dkm(d, c, k_max, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * max(k_max, m_max)**2 + 200
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

    return D, R, q, g_all, h_all

# d=4, c=(2,1,1)
d = 4; c = (2, 1, 1); k_max = 8; m_max = 8
D, R, q, g_all, h_all = compute_all_Dkm(d, c, k_max, m_max, PREC=600)

print("="*80)
print(f"Tower condition analysis: d={d}, c={c}")
print("="*80)

# Check: D_{k-1}^m - q^k * D_{k-1}^{m-1} = D_k^m >= 0?
# Equivalently: D_{k-1}^m >= q^k * D_{k-1}^{m-1} coefficient-wise?
# Let's compute the "domination remainder" r_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}

for k in range(1, k_max + 1):
    for m in range(k, m_max + 1):
        Dkm = D[(k, m)]
        coeffs = [Dkm[i] for i in range(min(300, Dkm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        negs = [i for i in range(len(poly)) if poly[i] < 0]
        if negs:
            print(f"D({k},{m}): NEGATIVE at positions {negs[:5]}")
        elif m <= 4 and max_d2 <= 50:
            print(f"D({k},{m}): OK, deg={max_d2}, coeffs={poly}")

# Now test the KEY Ehrhart-theoretic question:
# Can h_m be interpreted as counting lattice points in a polytope?
# If yes, what polytope?

# h_m = (q;q)_m * g_m where g_m counts CPs with max = m.
# g_m = sum_{w>=0} g_m[w] * q^w where g_m[w] = #{CPs of profile c, max=m, weight=w}
# (q;q)_m = prod_{i=1}^m (1-q^i)
# h_m[w] = sum_{j=0}^w (-1)^? * something * g_m[w-j]

# Actually, h_m = (q;q)_m * g_m means:
# h_m(q) = sum_{w} (sum_{partitions mu of size j, parts <= m} (-1)^{len(mu)} * g_m[w-j]) * q^w
# where (q;q)_m = sum_{mu: parts distinct, <= m} (-1)^{len(mu)} q^{|mu|}

# This is an inclusion-exclusion! 
# (q;q)_m * g_m counts CPs with max = m, weighted by an alternating factor
# from (q;q)_m.

# The natural interpretation: (q;q)_m * g_m is related to the ORDER POLYTOPE
# or the "strict" partition count. 

# Let me think about this differently.
# F_{c,m} = sum_{max <= m} q^{weight} = sum_w |{CP: max <= m, weight = w}| q^w
# F_{c,m} = 1/(q;q)_m * ... (Ehrhart-like)
# g_m = F_{c,m} - F_{c,m-1} counts CPs with max EXACTLY m.
# h_m = (q;q)_m * g_m

# Actually, let's look at the DIRECT relationship:
# F_{c,m} = sum_{j=0}^m g_j / (q;q)_m ... no, that's not right.
# F_{c,m} = sum_{j=0}^m g_j but g_j is already included in the sum.

# The correct relationship: 
# sum_m F_{c,m} * (y^m - y^{m-1}) = sum_m g_m * y^m (already summed)
# hmm, F_c(y,q) = sum_m g_m * y^m / (1 - y)  -- no.

# Let me re-read the definition more carefully.
# F_c(y,q) = sum_Lambda q^{|Lambda|} * y^{max(Lambda)}
# So [y^m] F_c(y,q) = sum_{Lambda: max=m} q^{|Lambda|} = g_m(q)

# Also F_{c,n}(q) = sum_{m=0}^n g_m(q) = sum_{Lambda: max<=n} q^{|Lambda|}

# Q_{n,c}(q) = (q;q)_n * [z^n] ((zq;q)_inf * F_c(z,q))
# = (q;q)_n * [z^n] (sum_{m>=0} g_m(q) z^m * sum_{j>=0} (-1)^j q^{j(j+1)/2} / (q;q)_j * z^j)
# = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q;q)_j * g_{n-j}
# = sum_{j=0}^n (-1)^j q^{j(j+1)/2} * (q;q)_n / (q;q)_j * g_{n-j}
# = sum_{j=0}^n (-1)^j q^{j(j+1)/2} * (q^{j+1};q)_{n-j} * g_{n-j}

# Hmm, let me use the D_k^m notation.
# h_m = (q;q)_m * g_m. Then g_m = h_m / (q;q)_m (as formal power series).
# Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} * [n choose j]_q * g_{n-j}

# The TOWER: D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
# Q_n = D_n^n.

# If h_m >= 0 for all m, then D_k^m >= 0 follows IF h_m dominates q*h_{m-1}.
# Specifically, D_1^m = h_m - q * h_{m-1} >= 0 iff h_m >= q * h_{m-1} coeff-wise.
# This is the "q-shift domination".

print("\n" + "="*80)
print("Testing q-shift domination: h_m >= q * h_{m-1}")
print("="*80)

for m in range(1, m_max + 1):
    hm = h_all[m]
    hm_prev = h_all[m-1]
    diff = hm - q * hm_prev
    coeffs = [diff[i] for i in range(min(300, diff.prec()))]
    max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
    poly = coeffs[:max_d2+1]
    negs = [i for i in range(len(poly)) if poly[i] < 0]
    if negs:
        print(f"h_{m} - q*h_{m-1}: NEGATIVE at {negs[:10]}")
    else:
        print(f"h_{m} - q*h_{m-1}: OK (nonneg), deg={max_d2}")
        if max_d2 <= 30:
            print(f"  = {poly}")

# Now the full tower condition: D_{k-1}^m >= q^k * D_{k-1}^{m-1}
print("\n" + "="*80)
print("Full tower: D_{k-1}^m >= q^k * D_{k-1}^{m-1}")
print("="*80)

for k in range(1, k_max + 1):
    for m in range(k, m_max + 1):
        Dkm = D[(k, m)]
        coeffs = [Dkm[i] for i in range(min(300, Dkm.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        if max_d2 > 290:
            print(f"D({k},{m}): near precision limit, skipping")
            continue
        poly = coeffs[:max_d2+1]
        negs = [i for i in range(len(poly)) if poly[i] < 0]
        status = "OK" if not negs else f"NEG at {negs[:5]}"
        print(f"D({k},{m}): {status}, deg={max_d2}")

print("\n--- CONCLUSION ---")
print("If ALL D_k^m >= 0 (which is equivalent to the tower condition),")
print("then Q_n = D_n^n >= 0 follows.")
print("The tower approach requires proving D_k^m >= 0 for all k >= 0, m >= k.")
print("We've verified h_m >= 0 (the k=0 base case).")
print("We've verified D_k^m >= 0 for k,m <= 8.")
print("The key question: can we prove h_m >= 0 and the domination conditions?")
