"""
Test the domination condition: E_{k-1}^m >= q^k * E_{k-1}^{m-1}
where E_k^m = D_k^m / (q;q)_k.

For k=1: E_0^m = h_m, need h_m >= q * h_{m-1}.
For k=2: E_1^m >= q^2 * E_1^{m-1} where E_1^m = D_1^m / (1-q).

The injection lemma proves g_m >= q * g_{m-1} (for power series).
Can we show h_m >= q * h_{m-1}?

h_m - q*h_{m-1} = (q;q)_m * g_m - q * (q;q)_{m-1} * g_{m-1}
= (q;q)_{m-1} * [(1-q^m)*g_m - q*g_{m-1}]
= (q;q)_{m-1} * [g_m - q^m*g_m - q*g_{m-1}]
= (q;q)_{m-1} * [(g_m - q*g_{m-1}) - q^m*g_m]

By injection lemma: g_m - q*g_{m-1} >= 0 (call this delta_m >= 0).
So h_m - q*h_{m-1} = (q;q)_{m-1} * [delta_m - q^m * g_m]

The question: is delta_m - q^m * g_m such that (q;q)_{m-1} times it is nonneg?
Let's compute.
"""
from sage.all import *
from itertools import combinations as combs

def full_analysis(d, c, m_max, PREC=None):
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
    
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result

    v_all = [vector(R, [R(1)] * N_size)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)

    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])

    h_all = [R(1)]
    for m in range(1, m_max + 1):
        h_all.append(qpoch(m) * g_all[m])

    # Injection lemma: delta_m = g_m - q*g_{m-1} >= 0
    print("--- Injection lemma check ---")
    for m in range(1, m_max + 1):
        delta = g_all[m] - q * g_all[m-1]
        coeffs = [delta[i] for i in range(min(50, delta.prec()))]
        negs = [i for i in range(len(coeffs)) if coeffs[i] < 0]
        print("  delta_%d first 15: %s, nonneg=%s" % (m, coeffs[:15], len(negs)==0))

    # Now analyze: delta_m - q^m * g_m
    print("\n--- delta_m - q^m * g_m ---")
    for m in range(1, min(5, m_max + 1)):
        delta = g_all[m] - q * g_all[m-1]
        remainder = delta - q**m * g_all[m]
        coeffs = [remainder[i] for i in range(min(50, remainder.prec()))]
        print("  m=%d: first 20 = %s" % (m, coeffs[:20]))
        # This is a power series. What are its signs?
        negs = [i for i in range(min(50, len(coeffs))) if coeffs[i] < 0]
        pos = [i for i in range(min(50, len(coeffs))) if coeffs[i] > 0]
        print("  neg at: %s" % negs[:10])
        print("  pos at: %s" % pos[:10])

    # The deeper question: how does (q;q)_{m-1} * [delta_m - q^m*g_m] come out nonneg?
    # Let's verify the product directly
    print("\n--- (q;q)_{m-1} * (delta_m - q^m * g_m) = h_m - q*h_{m-1} ---")
    for m in range(1, min(5, m_max + 1)):
        delta = g_all[m] - q * g_all[m-1]
        bracket = delta - q**m * g_all[m]
        product = qpoch(m-1) * bracket
        # This should equal h_m - q*h_{m-1}
        D1m = h_all[m] - q * h_all[m-1]
        diff = product - D1m
        match = all(diff[i] == 0 for i in range(min(30, diff.prec())))
        coeffs = [product[i] for i in range(min(80, product.prec()))]
        max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
        poly = coeffs[:max_d2+1]
        is_nonneg = all(c >= 0 for c in poly)
        print("  m=%d: match=%s, nonneg=%s, deg=%d" % (m, match, is_nonneg, max_d2))
        if max_d2 <= 30:
            print("  poly = %s" % poly)

    # Alternative approach: DIRECT q-analogue of injection
    # Instead of g_m >= q*g_{m-1}, try to show:
    # h_m(q) >= q * h_{m-1}(q) directly by finding an injection on h_m objects.
    #
    # What does h_m count? If h_m has nonneg coefficients, it counts SOMETHING.
    # The q-shift h_m -> q*h_{m-1} means: each h_m-object at weight w 
    # maps to an h_{m-1}-object at weight w-1.
    # Finding this injection would prove D_1^m = h_m - q*h_{m-1} >= 0.
    
    # For the general tower: D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
    # Need: each D_{k-1}^m-object at weight w maps to a D_{k-1}^{m-1}-object at weight w-k.
    # This is a "q^k-shift injection".

    print("\n--- Generalized injection: D_{k-1}^m >= q^k * D_{k-1}^{m-1} ---")
    D = {}
    for m2 in range(m_max + 1):
        D[(0, m2)] = h_all[m2]
    for k in range(1, m_max + 1):
        for m2 in range(k, m_max + 1):
            D[(k, m2)] = D[(k-1, m2)] - q**k * D[(k-1, m2-1)]
    
    for k in range(1, min(5, m_max)):
        for m2 in range(k+1, min(k+4, m_max+1)):
            # Check D_{k-1}^m >= q^k * D_{k-1}^{m-1}
            lhs = D[(k-1, m2)]
            rhs = q**k * D[(k-1, m2-1)]
            diff = lhs - rhs  # Should be D_k^m >= 0
            coeffs = [diff[i] for i in range(min(80, diff.prec()))]
            max_d2 = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            poly = coeffs[:max_d2+1]
            is_nonneg = all(c >= 0 for c in poly)
            
            # Also check RATIO D_{k-1}^m / D_{k-1}^{m-1} as power series
            if D[(k-1, m2-1)] != R(0):
                ratio = D[(k-1, m2)] / D[(k-1, m2-1)]
                ratio_coeffs = [ratio[i] for i in range(min(30, ratio.prec()))]
                # The ratio should be >= q^k, meaning ratio - q^k >= 0
                ratio_shifted = ratio - q**k
                rs_coeffs = [ratio_shifted[i] for i in range(min(30, ratio_shifted.prec()))]
                rs_nonneg = all(c >= 0 for c in rs_coeffs[:20])
            else:
                rs_nonneg = True
                
            print("  D(%d,%d) >= q^%d * D(%d,%d): nonneg=%s, ratio-q^k nonneg=%s" % 
                  (k-1, m2, k, k-1, m2-1, is_nonneg, rs_nonneg))

full_analysis(4, (2,1,1), 6, PREC=400)
