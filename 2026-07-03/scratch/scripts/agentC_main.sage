# Agent C: Main computation script
# Computes Q_n for various d and profiles, investigates structure

from itertools import product as iproduct

def compositions(d, k=3):
    """All compositions of d into k nonneg parts."""
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in compositions(d-i, k-1):
            yield (i,) + rest

def build_CW_matrix(d, R=None):
    """Build the Corteel-Welsh shift matrix A(x) for compositions of d into 3 parts.
    Returns a matrix over the polynomial ring R[x]."""
    if R is None:
        R = PolynomialRing(QQ, 'x')
    x = R.gen()
    
    comps = list(compositions(d))
    n = len(comps)
    
    # The CW shift: for J subset of I_c = {i : c_i > 0}, nonempty,
    # the shifted profile c(J) is defined by the shift rules.
    # A(x)[c', c] = sum over nonempty J in I_c: (-1)^{|J|-1} x^{|J|} * delta(c(J) = c')
    
    A = matrix(R, n, n)
    
    for idx, c in enumerate(comps):
        I_c = [i for i in range(3) if c[i] > 0]
        if not I_c:
            continue
        
        # Enumerate all nonempty subsets of I_c
        for r in range(1, len(I_c)+1):
            from itertools import combinations
            for J in combinations(I_c, r):
                J_set = set(J)
                # Compute c(J)
                c_new = list(c)
                for i in range(3):
                    i_prev = (i - 1) % 3
                    if i in J_set and i_prev not in J_set:
                        c_new[i] -= 1
                    elif i not in J_set and i_prev in J_set:
                        c_new[i] += 1
                
                c_new = tuple(c_new)
                if any(ci < 0 for ci in c_new):
                    continue
                if sum(c_new) != d:
                    continue
                
                # Find index of c_new
                if c_new in comps:
                    jdx = comps.index(c_new)
                    sign = (-1)**(r - 1)
                    A[jdx, idx] += sign * x**r
    
    return A, comps

def compute_Qn_from_matrix(d, n_max=3, prec=100):
    """Compute Q_n for all profiles of d into 3 parts."""
    R = PolynomialRing(QQ, 'q')
    q = R.gen()
    
    comps = list(compositions(d))
    num_comps = len(comps)
    
    # Build CW matrix M(q^k) for each k and compute the matrix product
    # F_n = prod_{k=1}^n (I - M(q^k))^{-1} * v_0
    # where v_0 = (1, ..., 1)
    # P_n = (q^3; q^3)_n * F_n (component-wise)
    # Q_n = [z^n]((zq;q)_inf * sum_j F_j z^j)
    #      = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_j
    # But we need F_j as polynomials, so we need to be more careful.
    
    # Actually: H_c(z,q) = (zq;q)_inf * F_c(z,q)
    # F_c(z,q) = sum_m z^m * g_m(c)
    # where g_m = F_{c,m}(q) = sum of q^|Lambda| over CPPs with max = m
    # So H_c(z,q) = sum_n z^n * (sum_{m=0}^n h_{n,m} * g_m)
    # where (zq;q)_inf = sum_n z^n * a_n with a_n = (-1)^n q^{n(n+1)/2} / (q;q)_n
    # Q_n = (q;q)_n * [z^n] H_c = (q;q)_n * sum_{m=0}^n a_{n-m} * g_m
    
    # We compute g_m via the transfer matrix.
    # g_0 = 1 for all profiles
    # g_m(c) = sum_{c'} M(q^m)[c, c'] * g_{m-1}(c')
    # i.e., g_m = M(q^m) * g_{m-1} (as a vector over profiles)
    
    # Build M symbolically first, then specialize
    Rx = PolynomialRing(QQ, 'x')
    x_var = Rx.gen()
    A_sym, comp_list = build_CW_matrix(d, Rx)
    
    # Truncate to given precision
    S = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q_s = S.gen()
    
    results = {}
    
    # Compute g_m vectors for m = 0, ..., n_max
    g_vectors = []
    # g_0 = (1, 1, ..., 1)
    g_0 = vector(S, [S(1)] * num_comps)
    g_vectors.append(g_0)
    
    for m in range(1, n_max + 1):
        # Build M(q^m) by substituting x = q^m in A_sym
        M_m = matrix(S, num_comps, num_comps)
        for i in range(num_comps):
            for j in range(num_comps):
                poly = A_sym[i,j]
                # Evaluate at x = q^m
                val = S(0)
                for coeff, mon in zip(poly.coefficients(), poly.monomials()):
                    deg = mon.degree()
                    val += coeff * q_s^(m * deg)
                M_m[i,j] = val
        
        g_m = M_m * g_vectors[-1]
        g_vectors.append(g_m)
    
    # Now compute Q_n for each profile
    for n in range(1, n_max + 1):
        for c_idx, c in enumerate(comp_list):
            # Q_n(c) = (q;q)_n * sum_{m=0}^n a_{n-m} * g_m(c)
            # a_k = (-1)^k * q^{k(k+1)/2} / (q;q)_k
            
            q_fact_n = prod(1 - q_s^i for i in range(1, n+1))
            
            Qn = S(0)
            for m in range(n+1):
                k = n - m
                # a_k = (-1)^k * q^{k(k+1)/2} / (q;q)_k
                q_fact_k = prod(1 - q_s^i for i in range(1, k+1)) if k > 0 else S(1)
                a_k = (-1)**k * q_s^(k*(k+1)//2) / q_fact_k
                Qn += a_k * g_vectors[m][c_idx]
            
            Qn = q_fact_n * Qn
            
            # Truncate and check polynomial
            Qn_trunc = Qn.truncate(prec)
            
            # Check if polynomial (all coeffs beyond some point are 0)
            coeffs = [Qn_trunc[i] for i in range(prec)]
            
            # Find max nonzero degree
            max_deg = 0
            for i in range(prec-1, -1, -1):
                if coeffs[i] != 0:
                    max_deg = i
                    break
            
            poly_coeffs = coeffs[:max_deg+1]
            is_nonneg = all(c >= 0 for c in poly_coeffs)
            has_neg = any(c < 0 for c in poly_coeffs)
            
            eval_at_1 = sum(poly_coeffs)
            
            if n <= 2 or (d <= 5):
                print(f"d={d}, c={c}, n={n}: Q_n(1) = {eval_at_1}, nonneg = {is_nonneg}, deg = {max_deg}")
                if has_neg:
                    neg_coeffs = [(i, poly_coeffs[i]) for i in range(len(poly_coeffs)) if poly_coeffs[i] < 0]
                    print(f"  NEGATIVE coefficients at: {neg_coeffs[:5]}")
                if max_deg <= 30:
                    print(f"  Q_n = {poly_coeffs}")
            
            results[(d, c, n)] = {
                'coeffs': poly_coeffs,
                'eval1': eval_at_1,
                'nonneg': is_nonneg,
                'deg': max_deg
            }
    
    return results

# Run computations
print("=" * 70)
print("COMPUTATION 1: Q_n for d=2 (k=1, trivial case)")
print("=" * 70)
res2 = compute_Qn_from_matrix(2, n_max=4, prec=50)

print()
print("=" * 70)
print("COMPUTATION 2: Q_n for d=4 (k=2, first nontrivial)")
print("=" * 70)
res4 = compute_Qn_from_matrix(4, n_max=3, prec=80)

print()
print("=" * 70)
print("COMPUTATION 3: Q_n for d=5 (k=2, other parity)")
print("=" * 70)
res5 = compute_Qn_from_matrix(5, n_max=2, prec=80)
