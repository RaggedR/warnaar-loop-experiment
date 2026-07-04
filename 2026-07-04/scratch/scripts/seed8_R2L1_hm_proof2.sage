"""
Analyze the factorization h_m = (q;q)_{m-1} * N_m / Phi_3(q^m)
where N_m = adj(I-A(q^m)) * A(q^m) * F_{c,m-1} and Phi_3 = 1+x+x^2.
"""
from sage.all import *
from itertools import combinations as combs

def analyze_factorization(d, c, m_max, PREC=None):
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

    for m in range(1, m_max + 1):
        # Compute N_m / Phi_3(q^m) as a power series
        # N_m = det(I-A(q^m)) * g_m = -(q^{3m}-1) * g_m
        det_val = -(q**(3*m) - 1)
        Nm = det_val * g_all[m]
        
        cyclotomic = 1 + q**m + q**(2*m)
        Nm_div_cyc = Nm / cyclotomic
        
        # This should equal (1-q^m) * g_m (since det = (1-q^m)*Phi_3(q^m))
        check = Nm_div_cyc - (1 - q**m) * g_all[m]
        is_match = all(check[i] == 0 for i in range(min(50, check.prec())))
        
        # h_m = (q;q)_{m-1} * Nm_div_cyc
        hm = qpoch(m) * g_all[m]
        hm_check = qpoch(m-1) * Nm_div_cyc
        diff = hm - hm_check
        formula_ok = all(diff[i] == 0 for i in range(min(50, diff.prec())))
        
        two_m = 2*m
        print("m=%d:" % m)
        print("  Nm/Phi3(q^m) = (1-q^m)*gm : %s" % is_match)
        print("  h_m = (q;q)_{m-1} * (1-q^m)*gm : %s" % formula_ok)
        
        # So h_m = (q;q)_{m-1} * (1-q^m) * g_m = (q;q)_m * g_m. Tautology!
        # The factorization doesn't give us anything new.
        
        # Let's try a DIFFERENT decomposition.
        # From the manifestly positive path formula (Agent B):
        # P_n = (q^3;q^3)_n * F_{c,n} = sum over paths of monomials.
        # P_n is manifestly positive.
        # Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n,j]_q * P_j / (q^3;q^3)_j * (q;q)_n / (q;q)_j ... 
        # Hmm, this involves the q-binomial transform which is the source of signs.
        
        # Instead, let's look at the SHIFTED STRUCTURE:
        # D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
        # If we set E_k^m = D_k^m / (q;q)_k, then:
        # E_k^m = (D_{k-1}^m - q^k * D_{k-1}^{m-1}) / (q;q)_k
        # Hmm, (q;q)_k = (1-q^k) * (q;q)_{k-1}
        # E_k^m = [D_{k-1}^m - q^k * D_{k-1}^{m-1}] / [(1-q^k) * (q;q)_{k-1}]

        # Since D_{k-1}^m = (q;q)_{k-1} * E_{k-1}^m:
        # E_k^m = [(q;q)_{k-1} * E_{k-1}^m - q^k * (q;q)_{k-1} * E_{k-1}^{m-1}] / [(1-q^k) * (q;q)_{k-1}]
        # = [E_{k-1}^m - q^k * E_{k-1}^{m-1}] / (1-q^k)
        
        # This is interesting! E_k^m = [E_{k-1}^m - q^k * E_{k-1}^{m-1}] / (1-q^k)
        # where E_0^m = h_m / (q;q)_0 = h_m.
        # Actually wait, D_0^m = h_m, so E_0^m = h_m / 1 = h_m.
        # E_1^m = [h_m - q * h_{m-1}] / (1-q) = D_1^m / (1-q).
        # But D_1^m = h_m - q*h_{m-1} is nonneg, and (1-q) = 1 - q has alternating signs...
        # Actually dividing a nonneg polynomial by (1-q) doesn't preserve nonnegativity in general.
        # 1/(1-q) = 1 + q + q^2 + ... as a power series.
        # If D_1^m = sum a_i q^i with a_i >= 0, then E_1^m = D_1^m / (1-q) = sum_i (sum_{j<=i} a_j) q^i
        # which has nonneg coefficients (partial sums of nonneg sequence)!
        
        # So E_1^m = D_1^m / (1-q) is nonneg because D_1^m is nonneg and 1/(1-q) has nonneg coeffs!
        
        # Similarly: E_2^m = [E_1^m - q^2 * E_1^{m-1}] / (1-q^2)
        # If E_1^m - q^2 * E_1^{m-1} >= 0, then dividing by (1-q^2) = (1-q)(1+q)...
        # 1/(1-q^2) = 1 + q^2 + q^4 + ... has nonneg coeffs.
        # So E_2^m is nonneg IF E_1^m >= q^2 * E_1^{m-1} coefficient-wise.
        
        # This is a REFORMULATION of the tower condition!
        # E_k^m = D_k^m / (q;q)_k
        # The tower condition D_k^m >= 0 is equivalent to E_k^m * (q;q)_k >= 0.
        # But since E_k^m >= 0 (if we can prove it) and (q;q)_k has alternating signs,
        # this doesn't directly give D_k^m >= 0.
        
        # Wait, I confused myself. D_k^m IS a polynomial with nonneg coefficients.
        # E_k^m = D_k^m / (q;q)_k. If D_k^m has nonneg coefficients and (q;q)_k
        # divides it in the polynomial ring, then E_k^m is a well-defined polynomial.
        # But E_k^m could have negative coefficients!
        
        # Let me just compute E_k^m and check.
    
    # Compute E_k^m = D_k^m / (q;q)_k
    D = {}
    for m2 in range(m_max + 1):
        D[(0, m2)] = qpoch(m2) * g_all[m2]
    for k in range(1, m_max + 1):
        for m2 in range(k, m_max + 1):
            D[(k, m2)] = D[(k-1, m2)] - q**k * D[(k-1, m2-1)]
    
    print("\n--- E_k^m = D_k^m / (q;q)_k ---")
    for k in range(m_max + 1):
        qk = qpoch(k)
        for m2 in range(k, m_max + 1):
            Dkm = D[(k, m2)]
            # Check if (q;q)_k divides D_k^m
            # Try to compute the quotient as a power series
            Ekm = Dkm / qk if k > 0 else Dkm
            coeffs = [Ekm[i] for i in range(min(80, Ekm.prec()))]
            # Is it a polynomial? (finite support)
            last_nonzero = max((i for i in range(len(coeffs)) if coeffs[i] != 0), default=0)
            is_nonneg = all(c >= 0 for c in coeffs[:last_nonzero+1])
            # Since g_m is a power series, E_k^m might be too
            print("  E(%d,%d): first 15 = %s, nonneg=%s" % (k, m2, coeffs[:15], is_nonneg))

analyze_factorization(4, (2,1,1), 4, PREC=300)
