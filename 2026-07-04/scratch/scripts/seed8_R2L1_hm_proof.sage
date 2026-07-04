"""
Attempt to prove h_m >= 0 via the factorization:
h_m = (q;q)_{m-1} * [adj(I-A(q^m)) * A(q^m) * F_{c,m-1}]_c / (1+q^m+q^{2m})

The key insight: let's define
  S_m(c) = [adj(I-A(q^m)) * A(q^m) * F_{c,m-1}]_c / (1+q^m+q^{2m})

Then h_m(c) = (q;q)_{m-1} * S_m(c).

Since h_m is known to be a POLYNOMIAL (Welsh 2021), and (q;q)_{m-1} is a polynomial
with leading term (-1)^{m-1} q^{(m-1)m/2}, S_m must also be such that the product
is a polynomial.

QUESTION: Is S_m itself a polynomial with nonneg coefficients?
If so, h_m = (q;q)_{m-1} * S_m would have alternating signs, which contradicts h_m >= 0.
So S_m cannot simply be nonneg.

Let me re-examine the factorization more carefully.

Actually, let me reconsider. We have:
g_m = (I-A(q^m))^{-1} * A(q^m) * F_{c,m-1}
    = adj(I-A(q^m)) * A(q^m) * F_{c,m-1} / det(I-A(q^m))
    = adj(I-A(q^m)) * A(q^m) * F_{c,m-1} / (-(q^{3m}-1))
    = adj(I-A(q^m)) * A(q^m) * F_{c,m-1} / ((1-q^m)(1+q^m+q^{2m}))

So g_m = [adj * A * F_{m-1}]_c / ((1-q^m)(1+q^m+q^{2m}))

And h_m = (q;q)_m * g_m
       = (1-q)(1-q^2)...(1-q^m) * g_m
       = (1-q)(1-q^2)...(1-q^{m-1}) * (1-q^m) * g_m
       = (q;q)_{m-1} * (1-q^m) * g_m
       = (q;q)_{m-1} * [adj * A * F_{m-1}]_c / (1+q^m+q^{2m})

Now define N_m(c) = [adj(I-A(q^m)) * A(q^m) * F_{c,m-1}]_c = (1+q^m+q^{2m}) * S_m(c).

The question is about the structure of N_m(c).

Let's compute N_m explicitly and see if we can understand its sign structure.
"""
from sage.all import *
from itertools import combinations as combs

def compute_Nm(d, c, m_max, PREC=None):
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

    v_all = [vector(R, [R(1)] * N)]
    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v_next = Bm.inverse() * v_all[-1]
        v_all.append(v_next)

    g_all = [R(1)]
    for m in range(1, m_max + 1):
        g_all.append(v_all[m][ci_idx] - v_all[m-1][ci_idx])

    for m in range(1, m_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        
        # adj(I-A(q^m)) = matrix of cofactors
        adj_Bm = Bm.adjugate()
        
        # N_m(c) = [adj_Bm * Am * F_{c,m-1}]_c
        # = sum_{c'} sum_{c''} adj_Bm[ci, c''] * Am[c'', c'] * F_{c,m-1}[c']
        # But F_{c,m-1} is v_all[m-1] (vector indexed by compositions)
        
        Nm_vec = adj_Bm * Am * v_all[m-1]
        Nm_c = Nm_vec[ci_idx]
        
        # Check: Nm_c should equal det(Bm) * g_m * (-1) ... wait.
        # g_m = Bm^{-1} * Am * F_{m-1} at position ci
        # Bm^{-1} = adj(Bm) / det(Bm)
        # So g_m = adj(Bm) * Am * F_{m-1} / det(Bm) at position ci
        # Nm_c = adj(Bm) * Am * F_{m-1} at position ci = det(Bm) * g_m
        
        det_Bm = Bm.determinant()
        
        # Verify: Nm_c == det_Bm * g_m
        check = Nm_c - det_Bm * g_all[m]
        is_zero = all(check[i] == 0 for i in range(min(50, check.prec())))
        
        print(f"m={m}:")
        print(f"  det(I-A(q^m)) = -(q^{3*m}-1)")
        
        coeffs_Nm = [Nm_c[i] for i in range(min(80, Nm_c.prec()))]
        max_d_Nm = max((i for i in range(len(coeffs_Nm)) if coeffs_Nm[i] != 0), default=0)
        # N_m is a power series, not a polynomial
        print(f"  N_m first 20 coeffs: {coeffs_Nm[:20]}")
        print(f"  Nm == det*gm check: {is_zero}")
        
        # h_m = (q;q)_{m-1} * Nm / (1+q^m+q^{2m})
        # Since det = -(q^{3m}-1) = (1-q^m)(1+q^m+q^{2m}),
        # g_m = Nm / det = Nm / ((1-q^m)(1+q^m+q^{2m}))
        # h_m = (q;q)_m * g_m = (q;q)_{m-1} * (1-q^m) * g_m
        #     = (q;q)_{m-1} * (1-q^m) * Nm / ((1-q^m)(1+q^m+q^{2m}))
        #     = (q;q)_{m-1} * Nm / (1+q^m+q^{2m})
        
        cyclotomic = 1 + q**m + q**(2*m)
        
        # Compute Nm / (1+q^m+q^{2m}) as a power series
        Nm_div_cyc = Nm_c / cyclotomic
        coeffs_div = [Nm_div_cyc[i] for i in range(min(80, Nm_div_cyc.prec()))]
        print(f"  N_m / (1+q^m+q^{2m}) first 20 coeffs: {coeffs_div[:20]}")
        
        # h_m via this route
        hm_check = qpoch(m-1) * Nm_div_cyc
        hm_direct = qpoch(m) * g_all[m]
        diff = hm_check - hm_direct
        match = all(diff[i] == 0 for i in range(min(50, diff.prec())))
        print(f"  h_m formula match: {match}")
        
        # Is Nm / (1+q^m+q^{2m}) nonneg?
        is_nonneg_div = all(c >= 0 for c in coeffs_div[:50] if True)
        print(f"  N_m/(1+q^m+q^{2m}) nonneg (first 50): {is_nonneg_div}")
        
        # Key: N_m is a power series. Is N_m/(1+q^m+q^{2m}) nonneg?
        negs = [i for i in range(min(50, len(coeffs_div))) if coeffs_div[i] < 0]
        if negs:
            print(f"  NEGATIVE at: {negs[:5]}")

d = 4; c = (2, 1, 1)
print(f"d={d}, c={c}")
compute_Nm(d, c, 4, PREC=300)

print("\n\nd=2, c=(1,1,0)")
compute_Nm(2, (1,1,0), 4, PREC=300)
