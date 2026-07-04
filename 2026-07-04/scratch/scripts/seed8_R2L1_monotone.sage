"""
Test: is the bracket delta_m - q^m * g_m "totally monotone" in the sense that
iterated application of (1-q^j) preserves nonnegativity?

Formally: define f_0 = delta_m - q^m * g_m (nonneg power series)
           f_1 = (1-q) * f_0
           f_2 = (1-q^2) * f_1
           ...
           f_{m-1} = (1-q^{m-1}) * f_{m-2}

We need: f_{m-1} = (q;q)_{m-1} * f_0 = D_1^m has nonneg coefficients.
Is each intermediate f_j nonneg?
"""
from sage.all import *
from itertools import combinations as combs

def compute_gs(d, c, m_max, PREC=None):
    if PREC is None:
        PREC = 6 * m_max**2 + 200
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N_size = len(compositions)
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
    A_poly = matrix(Rx, N_size, N_size, 0)
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
        A_eval = matrix(R, N_size, N_size)
        for i in range(N_size):
            for j in range(N_size):
                poly = A_poly[i,j]
                v = R(0)
                for k2, coeff in enumerate(poly.list()):
                    v += coeff * val**k2
                A_eval[i,j] = v
        return A_eval

    I_mat = matrix(R, N_size, N_size, lambda i,j: R(1) if i==j else R(0))
    v_all = [vector(R, [R(1)] * N_size)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)

    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])

    return g_all, R, q

d = 4; c = (2, 1, 1); m_max = 6
g_all, R, q = compute_gs(d, c, m_max, PREC=500)

for m in range(1, 6):
    print("=" * 60)
    print("m = %d" % m)
    print("=" * 60)
    
    delta_m = g_all[m] - q * g_all[m-1]
    f0 = delta_m - q**m * g_all[m]
    
    coeffs_f0 = [f0[i] for i in range(50)]
    print("f_0 = delta_%d - q^%d * g_%d:" % (m, m, m))
    print("  first 20: %s" % coeffs_f0[:20])
    
    # Check if f0 is eventually constant
    diffs = [coeffs_f0[i+1] - coeffs_f0[i] for i in range(len(coeffs_f0)-1)]
    last_nonzero_diff = max((i for i in range(len(diffs)) if diffs[i] != 0), default=-1)
    if last_nonzero_diff >= 0 and last_nonzero_diff < 40:
        print("  eventually constant from index %d, value = %d" % (last_nonzero_diff+1, coeffs_f0[last_nonzero_diff+1]))
    
    # Apply (1-q), (1-q^2), ... iteratively
    f = f0
    for j in range(1, m):
        f = (1 - q**j) * f
        coeffs_f = [f[i] for i in range(80)]
        
        # Check nonnegativity
        max_d2 = max((i for i in range(len(coeffs_f)) if coeffs_f[i] != 0), default=0)
        if max_d2 < 70:  # it's a polynomial
            poly = coeffs_f[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            print("  f_%d = (q;q)_%d * f_0: deg=%d, nonneg=%s" % (j, j, max_d2, len(negs)==0))
            if max_d2 <= 30:
                print("    = %s" % poly)
        else:
            # Still a power series
            negs = [i for i in range(60) if coeffs_f[i] < 0]
            print("  f_%d = (q;q)_%d * f_0: power series, nonneg(first 60)=%s" % (j, j, len(negs)==0))
            print("    first 20: %s" % coeffs_f[:20])
    
    # Final: f_{m-1} should be D_1^m
    print("  D_1^%d (should match f_{m-1}):" % m)
    
    # Verify
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    hm = qpoch(m) * g_all[m]
    hm1 = qpoch(m-1) * g_all[m-1] if m >= 1 else R(1)
    D1m = hm - q * hm1
    coeffs_D1m = [D1m[i] for i in range(80)]
    max_d2 = max((i for i in range(len(coeffs_D1m)) if coeffs_D1m[i] != 0), default=0)
    poly_D1m = coeffs_D1m[:max_d2+1]
    print("    D_1^%d = %s" % (m, poly_D1m[:30]))
    
    # Verify match with f_{m-1}
    final_f = qpoch(m-1) * f0
    diff = final_f - D1m
    match = all(diff[i] == 0 for i in range(min(50, diff.prec())))
    print("    Match with (q;q)_{m-1} * f_0: %s" % match)

# KEY STRUCTURAL PROPERTY TEST:
# Is f0 = delta_m - q^m * g_m a "completely monotone" power series?
# A power series sum a_n q^n is completely monotone (CM) if:
# (-1)^k Delta^k a_n >= 0 for all k, n >= 0
# where Delta is the forward difference operator.
# This is equivalent to: (1-q)^k * f(q) has nonneg coefficients for all k >= 0.
# And by Hausdorff's theorem, CM sequences are exactly moment sequences of prob. measures on [0,1].

# For us, we need a WEAKER condition: (q;q)_{m-1} * f0 has nonneg coefficients.
# (q;q)_{m-1} = (1-q)(1-q^2)...(1-q^{m-1}).
# This is like a "q-deformed complete monotonicity" condition.

print("\n" + "=" * 60)
print("COMPLETE MONOTONICITY TEST")
print("=" * 60)

for m in range(2, 5):
    delta_m = g_all[m] - q * g_all[m-1]
    f0 = delta_m - q**m * g_all[m]
    
    print("\nm=%d:" % m)
    
    # Apply (1-q^j) for j = 1, 2, 3, ...
    f = f0
    for j in range(1, 8):
        f = (1 - q**j) * f
        coeffs = [f[i] for i in range(80)]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        if max_d2 < 70:
            poly = coeffs[:max_d2+1]
            negs = [i for i in range(len(poly)) if poly[i] < 0]
            print("  (1-q)(1-q^2)...(1-q^%d) * f0: deg=%d, nonneg=%s" % (j, max_d2, len(negs)==0))
        else:
            negs = [i for i in range(60) if coeffs[i] < 0]
            print("  (1-q)(1-q^2)...(1-q^%d) * f0: series, nonneg(60)=%s" % (j, len(negs)==0))
