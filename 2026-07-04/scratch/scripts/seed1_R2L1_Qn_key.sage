# Compute Q_{n,c}(q) and decompose into GL_3 key polynomials
from sage.all import *

R.<q> = PowerSeriesRing(QQ, default_prec=200)

# F_{c,n} values for c=(1,1,0), d=2, computed by enumeration
# Pasted from the previous script

def enumerate_CPs(c, n, max_parts=10):
    """Enumerate cylindric partitions of profile c with max entry <= n."""
    r = len(c)
    from itertools import product as iprod
    
    def gen_partitions(max_val, length):
        if length == 0:
            yield ()
            return
        if length == 1:
            for v in range(max_val + 1):
                yield (v,)
            return
        for first in range(max_val + 1):
            for rest in gen_partitions(first, length - 1):
                yield (first,) + rest
    
    def check_interlacing(lams, c, r, L):
        for i in range(r):
            i_next = (i + 1) % r
            c_next = c[i_next]
            for j in range(L):
                lhs = lams[i][j] if j < len(lams[i]) else 0
                rhs_idx = j + c_next
                rhs = lams[i_next][rhs_idx] if rhs_idx < len(lams[i_next]) else 0
                if lhs < rhs:
                    return False
        return True
    
    count_by_size = {}
    all_parts = list(gen_partitions(n, max_parts))
    
    total = 0
    for combo in iprod(all_parts, repeat=r):
        if check_interlacing(combo, c, r, max_parts):
            size = sum(sum(p) for p in combo)
            count_by_size[size] = count_by_size.get(size, 0) + 1
            total += 1
    
    return count_by_size

def compute_Qn(c, N, prec=200):
    """Compute Q_{n,c}(q) for n = 0, 1, ..., N"""
    R2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = R2.gen()
    
    d = sum(c)
    r = len(c)
    ell = gcd(d, r)
    
    # Compute F_{c,m} for m = 0, ..., N
    Fcm = []
    for m in range(N + 1):
        counts = enumerate_CPs(c, m, max_parts=8)
        F = sum(cnt * q2**sz for sz, cnt in counts.items()) + R2(0)
        Fcm.append(F)
    
    # g_m = F_{c,m} - F_{c,m-1}, g_0 = F_{c,0} = 1
    gm = [Fcm[0]]
    for m in range(1, N + 1):
        gm.append(Fcm[m] - Fcm[m-1])
    
    # h_m = (q;q)_m * g_m  ... but actually Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
    # Let's use the q-binomial transform directly
    # [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^{inf} [z^n of (zq;q)_inf * z^j * g_j(q)]
    # (zq;q)_inf = sum_{k>=0} (-1)^k q^{k(k+1)/2} / (q;q)_k * z^k
    # So [z^n] = sum_{j=0}^n (-1)^{n-j} q^{(n-j)(n-j+1)/2} / (q;q)_{n-j} * g_j
    
    # Q_n = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * g_j
    
    # Or equivalently using the iterated q-difference:
    # h_m = (q;q)_m * g_m (but we showed h_m < 0 for m >= 2)
    # D_0^m = h_m
    # D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
    # Q_n = D_n^n
    
    # Let's use the direct formula
    def qpoch(a, q_var, n):
        """(a; q)_n"""
        result = R2(1)
        for i in range(n):
            result *= (1 - a * q_var**i)
        return result
    
    Qn_list = []
    qell_n = R2(1)  # (q^ell;q^ell)_0 = 1
    
    for n in range(N + 1):
        if n > 0:
            qell_n *= (1 - q2**(ell * n))
        
        # sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * g_j
        s = R2(0)
        for j in range(n + 1):
            k = n - j
            sign = (-1)**k
            qpow = q2**(k*(k+1)//2)
            denom = qpoch(q2, q2, k)  # (q;q)_k
            if j < len(gm):
                s += sign * qpow * gm[j] / denom
        
        Qn = qell_n * s
        # Truncate to polynomial
        Qn_poly = Qn.polynomial()
        Qn_list.append(Qn_poly)
        print(f"Q_{n} = {Qn_poly}")
        print(f"  Q_{n}(1) = {Qn_poly(1)}")
        
        # Check nonnegativity
        coeffs = Qn_poly.coefficients()
        neg = [c for c in coeffs if c < 0]
        if neg:
            print(f"  *** NEGATIVE COEFFICIENTS: {neg}")
        else:
            print(f"  All coefficients nonneg!")
    
    return Qn_list

# For d=2, c=(1,1,0)
print("=" * 60)
print("d=2, c=(1,1,0)")
print("=" * 60)
c = (1, 1, 0)
Qn = compute_Qn(c, 3, prec=200)

# Now compute GL_3 key polynomials at (q, q^2, q^3)
print("\n\n" + "=" * 60)
print("GL_3 key polynomials (Demazure characters)")
print("=" * 60)

# Key polynomials kappa_alpha(x1,x2,x3) for alpha = (a1,a2,a3) with a1 >= a2 >= a3 >= 0
# These are the Demazure characters.
# For a dominant weight alpha, kappa_alpha = x^alpha (monomial)
# For general alpha, apply divided difference operators.

# In GL_3, key polynomials are indexed by compositions (a,b,c) in Z^3_>=0
# and can be computed via Kohnert's rule or the Demazure operator formula.

# The specialization is x1 = q, x2 = q^2, x3 = q^3
# So kappa_{(a,b,c)}(q, q^2, q^3) = sum of q^{...} terms

# Let me use SageMath's built-in Demazure characters
# WeylCharacterRing for GL_3

# Actually, key polynomials in SageMath:
# Use the key_polynomial function or Demazure operators

# For GL_3, key polynomials are indexed by weak compositions of length 3
# kappa_alpha = pi_w(x^alpha) where w is the appropriate permutation

P = PolynomialRing(QQ, 'x1,x2,x3')
x1, x2, x3 = P.gens()

def demazure_op(i, f):
    """Apply the i-th Demazure operator (pi_i) to f in P = QQ[x1,x2,x3].
    pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})
    where s_i swaps x_i and x_{i+1}."""
    vars = [x1, x2, x3]
    xi = vars[i-1]
    xj = vars[i]  # i+1 in 1-indexed = i in 0-indexed
    
    # Apply s_i to f (swap x_i and x_{i+1})
    subs_dict = {xi: xj, xj: xi}
    sf = f.subs(subs_dict)
    
    num = xi * f - xj * sf
    result = P(num) // P(xi - xj)
    return result

def key_polynomial(alpha):
    """Compute the key polynomial kappa_alpha for alpha = (a1,a2,a3).
    First sort alpha to get the dominant weight, tracking the permutation,
    then apply the Demazure operators."""
    a = list(alpha)
    n = len(a)
    
    # Find the permutation w such that w(alpha) is dominant (weakly decreasing)
    # We need the shortest permutation
    # Actually, the key polynomial kappa_alpha = pi_w(x^{sort(alpha)})
    # where w is the sorting permutation
    
    # Better: use the recursive definition
    # If alpha is dominant (weakly decreasing), kappa_alpha = Schur-like (actually x^alpha for dominant)
    # Wait, that's wrong. For dominant alpha, kappa_alpha is the Schur polynomial? No.
    # For dominant alpha, kappa_alpha = x^alpha when it's the "top" key polynomial
    # Actually, kappa_alpha for dominant alpha is the Schur polynomial? Let me think...
    
    # No. The key polynomial for a dominant weight is NOT the Schur polynomial.
    # Key polynomials form a basis, and for dominant weight lambda,
    # kappa_lambda = x^lambda (the leading monomial).
    
    # For general alpha, we use: if alpha_i < alpha_{i+1}, then
    # kappa_alpha = pi_i(kappa_{s_i(alpha)})
    
    # Let's implement this recursively
    # Base case: alpha is weakly decreasing => kappa_alpha = x1^a1 * x2^a2 * x3^a3
    
    # Check if weakly decreasing
    if all(a[i] >= a[i+1] for i in range(n-1)):
        return x1**a[0] * x2**a[1] * x3**a[2]
    
    # Find i such that a[i] < a[i+1] (0-indexed)
    for i in range(n-1):
        if a[i] < a[i+1]:
            # Apply s_{i+1} (1-indexed) to alpha
            a_new = list(a)
            a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
            kappa_s = key_polynomial(tuple(a_new))
            return demazure_op(i+1, kappa_s)
    
    # Should not reach here
    return None

# Test: key polynomial for (2,1,0) should be x1^2 * x2 (dominant, so monomial)
print(f"kappa_(2,1,0) = {key_polynomial((2,1,0))}")
print(f"kappa_(1,2,0) = {key_polynomial((1,2,0))}")
print(f"kappa_(0,1,2) = {key_polynomial((0,1,2))}")
print(f"kappa_(1,0,0) = {key_polynomial((1,0,0))}")

# Specialise at (q, q^2, q^3)
Rq = PolynomialRing(QQ, 'q')
qq = Rq.gen()

def specialise_key(alpha):
    """Evaluate kappa_alpha at x1=q, x2=q^2, x3=q^3."""
    kp = key_polynomial(alpha)
    # Replace x1->q, x2->q^2, x3->q^3
    result = Rq(0)
    for coeff, mon in zip(kp.coefficients(), kp.monomials()):
        exp = mon.degrees()  # (e1, e2, e3)
        power = exp[0] * 1 + exp[1] * 2 + exp[2] * 3
        result += coeff * qq**power
    return result

print(f"\nSpecialised key polynomials at (q, q^2, q^3):")
for alpha in [(2,1,0), (1,2,0), (0,1,2), (1,0,0), (0,1,0), (0,0,1), (1,1,0), (0,1,1), (1,0,1)]:
    print(f"  kappa_{alpha} -> {specialise_key(alpha)}")

# Now try to decompose Q_1 for d=2 into key polynomials
print(f"\n\nQ_1 for d=2, c=(1,1,0): {Qn[1]}")
print(f"Q_1(1) = {Qn[1](1)} (should be (1*6*1/6)^1 = 1 since d=2, ell=1, (d+4)(d-1)/6 = 6*1/6 = 1)")
# Wait: ell*(d+4)(d-1)/6 = 1*(6)(1)/6 = 1. So Q_1(1) = 1.
# That means Q_1 has only a single term? Let me check...

