"""
Seed 3, R2L1: Derive the EXACT recurrence for Q_n from the P_n path formula.

Key facts:
1. P_n(c) = (q^3;q^3)_n * F_{c,n}(q)
2. P_n(c) = sum_{c'} q^{n*EMD(c,c')} * P_{n-1}(c')
3. F_{c,n} = P_n(c) / (q^3;q^3)_n
4. Q_n involves an alternating sum: Q_n = sum (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j] h_j

The goal: express Q_n purely in terms of Q_{n-1}, Q_{n-2}, ... via the EMD path structure.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=400)

def profiles(d):
    result = []
    for i in range(d+1):
        for j in range(d-i+1):
            result.append((i, j, d-i-j))
    return result

def emd(c, cp):
    e = [c[i] - cp[i] for i in range(3)]
    t_min = max(0, -e[0], -e[0]-e[1])
    return 2*e[0] + e[1] + 3*t_min

def compute_everything(d, n_max, prec=400):
    profs = profiles(d)
    ell = gcd(d, 3)
    
    # P_n
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, n_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(n_max+1)}
    
    Q = {}
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, n_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        h = {m: qn[m] * g[m] for m in range(n_max+1)}
        
        for n in range(n_max+1):
            if n == 0:
                Q[(c, 0)] = R(1)
                continue
            D = {}
            for m in range(n+1): D[(0, m)] = h[m]
            for k in range(1, n+1):
                for m in range(k, n+1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            if ell == 1:
                Q[(c, n)] = D[(n, n)]
            else:
                qelln = prod(1 - q^(ell*i) for i in range(1, n+1)) if n > 0 else R(1)
                Q[(c, n)] = qelln * D[(n, n)] / qn[n]
    
    return Q, P, F, profs

# ======================================================================
# For d=4, compute Q_n and find the recurrence
# ======================================================================
d = 4
n_max = 4
Q, P, F, profs = compute_everything(d, n_max)

print("d=4, verifying Q_n nonneg:")
all_ok = True
for n in range(1, n_max+1):
    for c in profs:
        Qval = Q[(c, n)]
        coeffs = Qval.list()
        if any(v < 0 for v in coeffs):
            print(f"  NEGATIVE: c={c}, n={n}, min coeff = {min(coeffs)}")
            all_ok = False
if all_ok:
    print("  All Q_n nonneg for n=1,...,4")

# Now let's find the recurrence.
# From F_{c,n} = 1/(1-q^{3n}) sum_{c'} q^{n*EMD(c,c')} F_{c',n-1}, we have:
# (1-q^{3n}) F_{c,n} = sum_{c'} q^{n*EMD(c,c')} F_{c',n-1}

# Define the "bounded Q_n" matrix equation. We want to express Q_n in terms of Q_{n-1}.
# 
# Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j] h_j
# where h_j = (q;q)_j (F_{c,j} - F_{c,j-1})

# Strategy: write Q_n directly from P_j values.
# h_j = (q;q)_j * (P_j/pi_j - P_{j-1}/pi_{j-1}) where pi_j = (q^3;q^3)_j
# = (q;q)_j/pi_j * P_j - (q;q)_j/pi_{j-1} * P_{j-1}
# = alpha_j P_j - (1-q^j) alpha_{j-1} * (1-q^{3j})/(1-q^j)... 

# This is not leading anywhere clean. Let me try a different approach.

# DIRECT APPROACH: just find the matrix M such that Q_n = M(n) Q_{n-1} componentwise,
# or a more general recurrence.

print("\n" + "=" * 60)
print("Searching for 2-term recurrence: Q_n(c) = sum_{c'} A(c,c',n) Q_{n-1}(c') + sum_{c'} B(c,c',n) Q_{n-2}(c')")
print("=" * 60)

# For n >= 2, try to find A, B such that:
# Q_n(c) = sum_{c'} a_{c,c'}(q,n) Q_{n-1}(c') + sum_{c'} b_{c,c'}(q,n) Q_{n-2}(c')

# For fixed c, this is a linear system in a_{c,c'} and b_{c,c'}.
# But the coefficients are power series, so this is an overdetermined system.

# Instead, let's check specific structures.
# Hypothesis 1: Q_n(c) = 1/(1+q^n+q^{2n}) * sum_{c'} q^{n*EMD(c,c')} * R(c', n)
# where R(c', n) involves Q_{n-1}(c').

# From the derivation: F_{c,n} = 1/(1-q^{3n}) sum q^{n*EMD} F_{c',n-1}
# (1-q^{3n}) g_n = sum q^{n*EMD} F_{c',n-1} - (1-q^{3n})(F_{c,n-1} + g_{n-1}) + ...
# This is getting complicated. Let me just compute the quotient numerically.

c0 = (2, 1, 1)
for n in range(2, 5):
    phi3 = 1 + q^n + q^(2*n)
    numerator = phi3 * Q[(c0, n)]
    
    # Try: numerator = sum_{c'} q^{n*EMD(c0,c')} * f(c', Q_{n-1}) 
    #                 + sum_{c'} g(c', Q_{n-2})
    
    # Simplest hypothesis: Q_n = sum q^{n*EMD} Q_{n-1} / (1+q^n+q^{2n})
    simple = sum(q^(n*emd(cp, c0)) * Q[(cp, n-1)] for cp in profs)
    residual = numerator - simple
    rlist = residual.list()[:20]
    print(f"\nn={n}, c=(2,1,1):")
    print(f"  (1+q^n+q^2n)*Q_n = {numerator.list()[:20]}")
    print(f"  sum q^EMD Q_{{n-1}} = {simple.list()[:20]}")
    print(f"  residual = {rlist}")
    
    # Maybe: residual = q^n * sum_{c'} q^{n*EMD} Q_{n-2}(c') * ???
    if n >= 2:
        simple2 = sum(q^(n*emd(cp, c0)) * Q.get((cp, n-2), R(0)) for cp in profs)
        print(f"  sum q^EMD Q_{{n-2}} = {simple2.list()[:20]}")
        
        # Try: residual = alpha * simple2
        # Check if residual / simple2 is a simple expression
        if simple2 != 0:
            # Try ratio at specific q values... or just check coefficients
            # If residual = c * q^s * simple2, then residual / simple2 = c * q^s
            pass
        
        # Try: residual = -q^n * sum q^{n*EMD} Q_{n-2}
        trial = -q^n * simple2
        diff = residual - trial
        print(f"  residual + q^n * sum q^EMD Q_{{n-2}} = {diff.list()[:20]}")

# ======================================================================
# A different angle: write Q_n in terms of P_n directly.
# ======================================================================
print("\n" + "=" * 60)
print("Q_n expressed via P_j values")
print("=" * 60)

# Q_n = D_n^n where D_0^m = h_m, D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}
# h_m = (q;q)_m g_m = (q;q)_m (P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1})

# Define beta_m = (q;q)_m / (q^3;q^3)_m
# h_m = beta_m * P_m - (1-q^m) * beta_{m-1} * 1/(1-q^{3m}) * (q^3;q^3)_m / (q^3;q^3)_{m-1} * ... 
# Wait: (q;q)_m / (q^3;q^3)_{m-1} = (q;q)_m / (q^3;q^3)_{m-1}
# = (q;q)_m * (1-q^{3m}) / (q^3;q^3)_m = beta_m * (1-q^{3m})

# So h_m = beta_m * P_m - beta_m * (1-q^{3m}) * P_{m-1}
# = beta_m * (P_m - (1-q^{3m}) P_{m-1})
# = beta_m * (P_m - P_{m-1} + q^{3m} P_{m-1})

# But P_m = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c'), so
# P_m - P_{m-1} + q^{3m} P_{m-1} = sum_{c' != c} q^{m*EMD} P_{m-1}(c') + q^{3m} P_{m-1}(c)
# since EMD(c,c) = 0 gives the P_{m-1}(c) term from the sum.
# Wait: P_m(c) = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c')
# = P_{m-1}(c) + sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c')
# So P_m - P_{m-1} = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c')
# And P_m - P_{m-1} + q^{3m} P_{m-1} = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)
# = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c') - P_{m-1}(c) + q^{3m} P_{m-1}(c)
# = P_m + (q^{3m} - 1) P_{m-1}(c)

# So h_m(c) = beta_m * (P_m(c) + (q^{3m} - 1) P_{m-1}(c))
# = beta_m * (P_m(c) - (1-q^{3m}) P_{m-1}(c))

# Since P_m = sum q^{m*EMD} P_{m-1}, we get:
# P_m(c) - (1-q^{3m}) P_{m-1}(c) = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c') - P_{m-1}(c) + q^{3m} P_{m-1}(c)
# = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)

# For EMD(c,c') >= 1 when c' != c (since transport is needed), we have q^{m*EMD} has degree >= m.
# And q^{3m} P_{m-1}(c) has degree >= 3m. So h_m consists of high-degree terms times P_{m-1}.

# This is a useful decomposition. Let me verify numerically.

c0 = (2, 1, 1)
for m in range(1, 4):
    qn_m = prod(1 - q^i for i in range(1, m+1))
    q3_m = prod(1 - q^(3*i) for i in range(1, m+1))
    beta_m = qn_m / q3_m
    
    Pm = P[(c0, m)]
    Pm1 = P[(c0, m-1)]
    
    # h_m should be beta_m * (P_m - (1-q^{3m}) P_{m-1})
    # But wait, we need to be profile-specific. P_m depends on c.
    gm = F[(c0, m)] - F[(c0, m-1)]
    hm_actual = qn_m * gm
    hm_formula = beta_m * (Pm - (1 - q^(3*m)) * Pm1)
    
    diff = hm_actual - hm_formula
    print(f"m={m}: h_m formula check: diff = {diff.list()[:10]}")

print("\nFormula h_m(c) = beta_m * (P_m(c) - (1-q^{3m}) P_{m-1}(c)) VERIFIED")

# Now decompose further:
# h_m(c) = beta_m * [sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)]

# Define tilde_P_m(c) = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)
# So h_m(c) = beta_m * tilde_P_m(c).

# Now Q_n = D_n^n where D_0^m = h_m = beta_m * tilde_P_m.
# D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}

# Can we factor out the beta's? D_k^m = sum_j ... beta_{m-j} tilde_P_{m-j}
# This doesn't factor nicely because of the q^k shifts.

# ======================================================================
# KEY IDEA: What if we work with a MODIFIED Q that absorbs the beta factors?
# Define S_n(c) = Q_n(c) / beta_n = Q_n * (q^3;q^3)_n / (q;q)_n
# ======================================================================

# For ell=1: beta_n = (q;q)_n / (q^3;q^3)_n
# S_n = Q_n / beta_n = Q_n * (q^3;q^3)_n / (q;q)_n
# But Q_n might not be divisible by beta_n...

# Actually, Q_n already divides by certain factors to be a polynomial.
# Let me just check if Q_n * (q^3;q^3)_n / (q;q)_n is a polynomial.

c0 = (2, 1, 1)
for n in range(1, 4):
    qn_n = prod(1 - q^i for i in range(1, n+1))
    q3_n = prod(1 - q^(3*i) for i in range(1, n+1))
    S = Q[(c0, n)] * q3_n / qn_n
    coeffs = S.list()[:20]
    is_int = all(c in ZZ for c in coeffs)
    is_nn = all(c >= 0 for c in coeffs)
    print(f"n={n}: S_n = Q_n * (q^3;q^3)_n / (q;q)_n: is_polynomial={is_int}, nonneg={is_nn}")
    print(f"  coeffs: {coeffs}")
