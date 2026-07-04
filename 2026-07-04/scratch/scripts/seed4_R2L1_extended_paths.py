"""
Explore Q_2 on the extended path space for d=4.

Q_n = (q^ell; q^ell)_n * [z^n] ((zq;q)_inf * F_c(z,q))

The key identity connecting P_n and Q_n:
P_n = (q^3;q^3)_n * F_{c,n}  (manifestly positive, sum of EMD path monomials)

Q_n = sum_{j=0}^{n} (-1)^{n-j} q^{binom(n-j+1,2)} * [n choose j]_q * P_j / (q^ell;q^ell)_j

Wait, let me be more careful. We have:
(zq;q)_inf = sum_{m>=0} (-1)^m q^{binom(m+1,2)} / (q;q)_m * z^m

So [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^{n} (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}

And Q_n = (q^ell;q^ell)_n * sum_{j=0}^{n} (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}

Since P_j = (q^3;q^3)_j * F_{c,j} (for ell=1 when gcd(d,3)=1):

Q_n = (q;q)_n * sum_{j=0}^{n} (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * P_j / (q^3;q^3)_j

Hmm, this mixes ell=1 and ell=3 factors. Let me just compute directly.

For d=4, ell = gcd(4,3) = 1.

Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}

Note (q;q)_n / (q;q)_{n-j} = ... this simplifies.

Actually, (q;q)_n * 1/(q;q)_{n-j} * 1/(q;q)_j * (q;q)_j = [n choose j]_q * (q;q)_j

So Q_n = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * (q;q)_j * F_{c,j}

But (q;q)_j * F_{c,j} = h_j (the bounded partition polynomial from the synthesis).

And P_j = (q^3;q^3)_j * F_{c,j}.

Let me just compute everything numerically with high precision.
"""

from sympy import symbols, Rational, Poly, expand, binomial
from functools import lru_cache

q = symbols('q')

def q_pochhammer(a_expr, n, q_sym=q):
    """Compute (a;q)_n = prod_{i=0}^{n-1} (1 - a*q^i)"""
    result = 1
    for i in range(n):
        result *= (1 - a_expr * q_sym**i)
    return expand(result)

def q_binomial(n, k, q_sym=q):
    """Compute [n choose k]_q"""
    if k < 0 or k > n:
        return 0
    num = q_pochhammer(q_sym, n, q_sym)
    den_k = q_pochhammer(q_sym, k, q_sym)
    den_nk = q_pochhammer(q_sym, n-k, q_sym)
    # This is (q;q)_n / ((q;q)_k * (q;q)_{n-k})
    from sympy import cancel
    return cancel(num / (den_k * den_nk))

# For d=4, the profiles are compositions of 4 into 3 nonneg parts
def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def emd_clockwise(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def compute_P_n_via_paths(d, c, n_max, prec=30):
    """
    P_n(c) = (q^3;q^3)_n * F_{c,n}
    = sum over paths (c^0,...,c^n=c) of q^{sum_{k=1}^n k*EMD(c^k, c^{k-1})}
    
    We compute this by dynamic programming.
    """
    profs = profiles(d)
    
    # P_n[c] = sum over paths ending at c of weight product
    # Use truncated polynomials for efficiency
    
    # DP: path_sum[k][c] = sum over paths of length k ending at c of q^{weight}
    # path_sum[0][c] = 1 for all c (path of length 0 ending at c)
    # path_sum[k][c] = sum_{c'} path_sum[k-1][c'] * q^{k*EMD(c, c')}
    
    # Start: path_sum[0] = {c: 1 for all c}
    # But P_n(c) sums only paths ending at c, so we want path_sum[n][c]
    
    # Actually the formula is:
    # P_n(c) = sum_{c^0, ..., c^{n-1}} prod_{k=1}^n q^{k * EMD(c^k, c^{k-1})}
    # where c^n = c (fixed endpoint)
    
    # DP: Let val[k][c'] = sum over paths c^0,...,c^k with c^k = c' of prod_{i=1}^k q^{i*EMD(c^i,c^{i-1})}
    # val[0][c'] = 1 for all c' (any starting point)
    # val[k][c'] = sum_{c''} val[k-1][c''] * q^{k*EMD(c', c'')}
    
    from sympy import Poly as SPoly
    
    results = {}
    
    # Initialize: val[0][c'] = 1 for all profiles c'
    val = {p: Poly(1, q) for p in profs}
    results[0] = {p: Poly(1, q) for p in profs}
    
    for k in range(1, n_max+1):
        new_val = {}
        for cp in profs:
            s = Poly(0, q)
            for cpp in profs:
                e = emd_clockwise(cp, cpp)
                weight = Poly(q**(k*e), q)
                s = s + val[cpp] * weight
            # Truncate to prec terms
            new_val[cp] = s.trunc(q**prec) if hasattr(s, 'trunc') else s
        val = new_val
        results[k] = dict(val)
        print(f"  P_{k} computed")
    
    return results

def compute_Q_n(d, c, n, P_vals, prec=30):
    """
    Q_n(c) = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}
    
    where F_{c,j} = P_j(c) / (q^3;q^3)_j
    and ell = gcd(d, 3)
    """
    from sympy import Poly as SPoly
    ell = 3 if d % 3 == 0 else 1
    
    # (q^ell; q^ell)_n as a polynomial
    qell_n = Poly(q_pochhammer(q**ell, n), q)
    
    total = Poly(0, q)
    for j in range(n+1):
        # (-1)^{n-j} * q^{binom(n-j+1,2)}
        sign = (-1)**(n-j)
        shift = (n-j)*(n-j+1)//2
        
        # 1/(q;q)_{n-j}
        qq_nj = expand(q_pochhammer(q, n-j))
        
        # F_{c,j} = P_j(c) / (q^3;q^3)_j
        P_j = P_vals[j][c]
        q3_j = Poly(expand(q_pochhammer(q**3, j)), q)
        
        # term = sign * q^shift * P_j / (q3_j * qq_nj)
        # This should all simplify to a polynomial when multiplied by qell_n
        # Let me compute numerator and divide at the end
        
        # Actually, let me just compute everything as rational functions and check
        from sympy import cancel, Rational
        term_num = sign * q**shift * P_j.as_expr()
        term_den = q3_j.as_expr() * qq_nj
        
        # Q_n = qell_n * sum(term_num/term_den)
        # Need to be careful with polynomial division
        term = cancel(term_num / term_den)
        total = total.as_expr() + term if not isinstance(total, int) else term
    
    Q_n = expand(qell_n.as_expr() * total)
    return Poly(Q_n, q)

# Test for d=4, a specific profile
d = 4
c = (2, 1, 1)  # A representative profile
print(f"Computing P_n for d={d}, profiles of {d}")
P_vals = compute_P_n_via_paths(d, c, n_max=2, prec=40)

print(f"\nP_0({c}) = {P_vals[0][c].as_expr()}")
print(f"P_1({c}) = {P_vals[1][c].as_expr()}")
print(f"P_2({c}) = {P_vals[2][c].as_expr()}")

# Count number of profiles
profs = profiles(d)
print(f"\nNumber of profiles for d={d}: {len(profs)}")

# Print EMD table for d=4
print(f"\nEMD table for d={d}:")
print(f"{'c':>12s} | {'c_prime':>12s} | EMD")
for cp in profs[:6]:
    for cpp in profs[:6]:
        e = emd_clockwise(cp, cpp)
        print(f"{str(cp):>12s} | {str(cpp):>12s} | {e}")

