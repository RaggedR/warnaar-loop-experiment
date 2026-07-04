"""
Investigate the structure of h_m = (q;q)_m * g_m more deeply.

h_m is a polynomial with nonneg coefficients. What combinatorial objects does it count?

Key identity: g_m(q) = sum_{w>=0} #{CPs with max=m, weight w} q^w
is a generating function for lattice points in a cone.

(q;q)_m = product_{i=1}^m (1 - q^i) is the "q-factorial" normalization.

For ordinary partitions: if g_m(q) = sum q^{|lambda|} over partitions lambda
with largest part = m, then (q;q)_m * g_m = q^m (since there's essentially
a bijection to "column-strict" objects).

For CPs: h_m = (q;q)_m * g_m counts... what?

Observation: (q;q)_m * g_m is the coefficient of y^m in (q;q)_m * F_c(y,q)
restricted to max = m terms.

Actually, from the transfer matrix:
F_{c,m} = prod_{k=1}^m (I - A(q^k))^{-1} * v_0
g_m = F_{c,m} - F_{c,m-1}

So (q;q)_m * g_m = (q;q)_m * [prod_{k=1}^m (I-A(q^k))^{-1} - prod_{k=1}^{m-1} (I-A(q^k))^{-1}] v_0

Let B_k = (I - A(q^k)). Then:
F_{c,m} = B_m^{-1} B_{m-1}^{-1} ... B_1^{-1} v_0
g_m = B_m^{-1} ... B_1^{-1} v_0 - B_{m-1}^{-1} ... B_1^{-1} v_0
    = [B_m^{-1} - I] * B_{m-1}^{-1} ... B_1^{-1} v_0
    = B_m^{-1} [I - B_m] * F_{c,m-1}
    = B_m^{-1} * A(q^m) * F_{c,m-1}

So g_m = (I - A(q^m))^{-1} * A(q^m) * F_{c,m-1}

And h_m = (q;q)_m * g_m
       = (q;q)_m * (I - A(q^m))^{-1} * A(q^m) * F_{c,m-1}

Since (q;q)_m = (1-q^m) * (q;q)_{m-1}:
h_m = (1-q^m) * (q;q)_{m-1} * (I - A(q^m))^{-1} * A(q^m) * F_{c,m-1}

Now (I - A(q^m))^{-1} = adj(I-A(q^m)) / det(I-A(q^m)).
det(I-A(q^m)) = -(q^{3m} - 1) = (1-q^m)(1+q^m+q^{2m}).

So (1-q^m) * (I-A(q^m))^{-1} = (1-q^m) * adj(I-A(q^m)) / ((1-q^m)(1+q^m+q^{2m}))
                                = adj(I-A(q^m)) / (1+q^m+q^{2m})

Therefore:
h_m = (q;q)_{m-1} * adj(I-A(q^m)) * A(q^m) * F_{c,m-1} / (1+q^m+q^{2m})

And from the Adjugate Monomial Theorem: adj(I-A(x))[c,c'] = x^{EMD(c,c')}

So adj(I-A(q^m)) * A(q^m) = matrix M where M[c,c''] = sum_{c'} q^{m*EMD(c,c')} * A(q^m)[c',c'']

This gives:
h_m[c] = (q;q)_{m-1} / (1+q^m+q^{2m}) * sum_{c'',c'} q^{m*EMD(c,c')} * A(q^m)[c',c''] * F_{c,m-1}[c'']

The (1+q^m+q^{2m}) factor in the denominator is crucial -- it's the cyclotomic polynomial Phi_3(q^m).

Let me verify this factorization computationally.
"""
from sage.all import *
from itertools import combinations as combs

def compute_hm_via_adjugate(d, c, m_max, PREC=None):
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
    
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    # Compute F_{c,m-1} and h_m via adjugate formula
    v_all = [vector(R, [R(1)] * N)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)
    
    # Standard h_m computation
    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])
    
    h_all = [R(1)]
    for m in range(1, m_max + 1):
        h_all.append(qpoch(m) * g_all[m])
    
    # Check the factorization: h_m * (1 + q^m + q^{2m}) should be nice
    for m in range(1, m_max + 1):
        hm = h_all[m]
        cyclotomic = 1 + q**m + q**(2*m)
        product = hm * cyclotomic
        coeffs_hm = [hm[i] for i in range(min(150, hm.prec()))]
        max_d2 = max((i for i in range(len(coeffs_hm)) if coeffs_hm[i] != 0), default=0)
        poly_hm = coeffs_hm[:max_d2+1]
        
        coeffs_prod = [product[i] for i in range(min(150, product.prec()))]
        max_d3 = max((i for i in range(len(coeffs_prod)) if coeffs_prod[i] != 0), default=0)
        poly_prod = coeffs_prod[:max_d3+1]
        
        print(f"m={m}:")
        if max_d2 <= 30:
            print(f"  h_{m} = {poly_hm}")
        print(f"  deg(h_{m}) = {max_d2}")
        if max_d3 <= 40:
            print(f"  h_{m} * (1+q^{m}+q^{{{2*m}}}) = {poly_prod}")
        print(f"  deg product = {max_d3}")
        
        # Check: does h_m * (1+q^m+q^{2m}) = (q;q)_{m-1} * [some nice thing]?
        # We know h_m = (q;q)_{m-1} * adj(I-A(q^m)) * A(q^m) * F_{c,m-1} / (1+q^m+q^{2m})
        # So h_m * (1+q^m+q^{2m}) = (q;q)_{m-1} * [something nonneg?]
        
        if m >= 1:
            qpoch_m1 = qpoch(m-1)
            if qpoch_m1 != R(0):
                quotient = product / qpoch_m1
                # This should be a polynomial (or power series with finite support)
                coeffs_q = [quotient[i] for i in range(min(150, quotient.prec()))]
                max_d4 = max((i for i in range(len(coeffs_q)) if coeffs_q[i] != 0), default=0)
                poly_q = coeffs_q[:max_d4+1]
                is_nonneg = all(c >= 0 for c in poly_q)
                if max_d4 <= 40:
                    print(f"  h_{m}*(1+q^{m}+q^{{{2*m}}})/(q;q)_{{{m-1}}} = {poly_q}")
                print(f"  deg = {max_d4}, nonneg = {is_nonneg}")
    
    return h_all

print("d=4, c=(2,1,1):")
h4 = compute_hm_via_adjugate(4, (2,1,1), 5, PREC=400)

print("\n\nd=2, c=(1,1,0):")
h2 = compute_hm_via_adjugate(2, (1,1,0), 5, PREC=400)
