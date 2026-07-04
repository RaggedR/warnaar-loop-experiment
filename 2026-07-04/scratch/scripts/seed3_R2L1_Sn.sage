"""
Seed 3, R2L1: Explore S_n = Q_n * (q^3;q^3)_n / (q;q)_n

Key finding: S_n is a nonneg polynomial, and has a cleaner relationship to the
EMD path sum P_n.

Since h_m(c) = beta_m * (P_m(c) - (1-q^{3m}) P_{m-1}(c))
where beta_m = (q;q)_m / (q^3;q^3)_m,

we can define tilde_h_m(c) = h_m / beta_m = P_m(c) - (1-q^{3m}) P_{m-1}(c)
= sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)

Then Q_n = D_n^n where D is the iterated q-difference of h_m,
and S_n = Q_n / beta_n = Q_n * (q^3;q^3)_n / (q;q)_n.

The question: does S_n satisfy a recurrence involving only the EMD path weights?
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

def compute_all(d, n_max, prec=400):
    profs = profiles(d)
    ell = gcd(d, 3)
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, n_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(n_max+1)}
    
    Q = {}
    S = {}
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, n_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        h = {m: qn[m] * g[m] for m in range(n_max+1)}
        
        Q[(c, 0)] = R(1)
        S[(c, 0)] = R(1)
        for n in range(1, n_max+1):
            D = {}
            for m in range(n+1): D[(0, m)] = h[m]
            for k in range(1, n+1):
                for m in range(k, n+1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            
            if ell == 1:
                Q[(c, n)] = D[(n, n)]
            else:
                qelln = prod(1 - q^(ell*i) for i in range(1, n+1))
                Q[(c, n)] = qelln * D[(n, n)] / qn[n]
            
            S[(c, n)] = Q[(c, n)] * q3[n] / qn[n]
    
    return Q, S, P, F, profs

# ======================================================================
# Test for d=4
# ======================================================================
d = 4
n_max = 4
Q, S, P, F, profs = compute_all(d, n_max)

print("=" * 60)
print(f"d={d}: S_n(c) = Q_n * (q^3;q^3)_n / (q;q)_n")  
print("=" * 60)

# Check S_n nonneg
for n in range(1, n_max+1):
    all_nn = all(all(c >= 0 for c in S[(p, n)].list()) for p in profs)
    print(f"n={n}: all S_n nonneg = {all_nn}")

# Recurrence search for S_n
print("\nRecurrence search for S_n:")
c0 = (2, 1, 1)
for n in range(2, n_max+1):
    # Try: (1-q^{3n}) S_n(c) = sum_{c'} alpha(c,c',n) S_{n-1}(c')
    lhs = (1 - q^(3*n)) * S[(c0, n)]
    
    # First try simple EMD weights
    rhs1 = sum(q^(n*emd(cp, c0)) * S[(cp, n-1)] for cp in profs)
    diff1 = lhs - rhs1
    print(f"\nn={n}: (1-q^3n) S_n - sum q^(n*EMD) S_{{n-1}}:")
    print(f"  = {diff1.list()[:15]}")
    
    # Try: (1+q^n+q^{2n}) S_n = sum q^{n*EMD} S_{n-1} + correction
    lhs2 = (1 + q^n + q^(2*n)) * S[(c0, n)]
    diff2 = lhs2 - rhs1
    print(f"  (1+q^n+q^2n) S_n - sum q^EMD S_{{n-1}} = {diff2.list()[:15]}")
    
    # Try subtracting q^n * sum S_{n-1}
    rhs3 = sum(q^(n*emd(cp, c0)) * (1 - q^n) * S[(cp, n-1)] for cp in profs)
    diff3 = lhs - rhs3
    print(f"  (1-q^3n) S_n - sum q^EMD (1-q^n) S_{{n-1}} = {diff3.list()[:15]}")

# ======================================================================
# Let me try yet another approach: express S_n directly via P_n.
# S_n = Q_n * (q^3;q^3)_n / (q;q)_n
# Since h_m = beta_m * tilde_h_m where tilde_h_m = P_m - (1-q^{3m}) P_{m-1},
# we have Q_n = D_n^n(h_.) and S_n = D_n^n(h_.) / beta_n.
# Can we simplify by noting that D_k^m(beta_. * tilde_h_.) has a factored form?
# ======================================================================

print("\n" + "=" * 60)
print("Direct computation: tilde_h_m and its q-differences")
print("=" * 60)

# tilde_h_m(c) = P_m(c) - (1-q^{3m}) P_{m-1}(c)
# = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c') - P_{m-1}(c) + q^{3m} P_{m-1}(c)
# = sum_{c'!=c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)

c0 = (2, 1, 1)
for m in range(5):
    th = P[(c0, m)] - (1-q^(3*m))*P.get((c0, m-1), R(0)) if m > 0 else R(1)
    print(f"tilde_h_{m}({c0}) first 15 coeffs: {th.list()[:15]}")

# Now compute the iterated q-difference of tilde_h_m
print("\nIterated q-difference of tilde_h (no beta factor):")
for n in range(1, 4):
    tD = {}
    for m in range(n+1):
        tD[(0, m)] = P[(c0, m)] - (1-q^(3*m))*P.get((c0, m-1), R(0)) if m > 0 else R(1)
    for k in range(1, n+1):
        for m in range(k, n+1):
            tD[(k, m)] = tD[(k-1, m)] - q^k * tD.get((k-1, m-1), R(0))
    
    tQn = tD[(n, n)]
    # Compare with S_n
    ratio = S[(c0, n)] / tQn if tQn != 0 else "undefined"
    if isinstance(ratio, type(R(0))):
        print(f"n={n}: S_n / tD_n^n = {ratio.list()[:10]}")
    else:
        print(f"n={n}: ratio undefined")

# So S_n != tD_n^n in general. The beta_m factors don't factor out of the q-difference.
# This is because D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1} mixes h_m values with different
# beta factors (beta_m vs beta_{m-1}).

# ======================================================================
# CRUCIAL TEST: Is S_n(c) = [z^n](1/(zq;q)_n * f(z)) for some manifestly positive f?
# In other words, is there a manifestly positive bounded generating function whose
# z^n coefficient (times (q^3;q^3)_n) gives S_n?
# ======================================================================

# If S_n has a representation as a sum of products of q-binomials with nonneg coefficients,
# that would prove Q_n >= 0 (since Q_n = S_n * (q;q)_n / (q^3;q^3)_n and (q;q)_n / (q^3;q^3)_n
# has nonneg coefficients... wait, does it?

print("\n" + "=" * 60)
print("Checking (q;q)_n / (q^3;q^3)_n for nonnegativity")
print("=" * 60)

for n in range(1, 6):
    qn_n = prod(1 - q^i for i in range(1, n+1))
    q3_n = prod(1 - q^(3*i) for i in range(1, n+1))
    ratio = qn_n / q3_n
    coeffs = ratio.list()[:30]
    is_nn = all(c >= 0 for c in coeffs)
    print(f"n={n}: (q;q)_n / (q^3;q^3)_n nonneg = {is_nn}, coeffs = {coeffs[:20]}")

# If (q;q)_n / (q^3;q^3)_n has NEGATIVE coefficients, then S_n nonneg does NOT
# directly imply Q_n nonneg. But if it has nonneg coefficients, then
# Q_n = S_n * beta_n where beta_n = (q;q)_n / (q^3;q^3)_n is also nonneg,
# wait no: Q_n = S_n * beta_n = S_n * (q;q)_n / (q^3;q^3)_n.
# But S_n is a polynomial and beta_n is a power series. The product being a polynomial
# requires exact cancellation.
# 
# Actually, Q_n IS a polynomial and S_n is also a polynomial (verified above).
# Q_n = S_n * (q;q)_n / (q^3;q^3)_n means (q^3;q^3)_n * Q_n = (q;q)_n * S_n.
# Both sides are polynomials. If S_n >= 0 and beta_n >= 0, then Q_n >= 0.
# But S_n = Q_n / beta_n = Q_n * (q^3;q^3)_n / (q;q)_n.
# For Q_n >= 0 to follow from S_n >= 0, we'd need beta_n >= 0.

# But beta_n = (q;q)_n / (q^3;q^3)_n is a POWER SERIES, not a polynomial.
# E.g., for n=1: (1-q)/(1-q^3) = (1-q)/((1-q)(1+q+q^2)) = 1/(1+q+q^2)
# = 1 - q - q^2 + q^3 + q^4 - ... which has NEGATIVE coefficients!

# So S_n >= 0 does NOT imply Q_n >= 0 via this route.
# However, S_n >= 0 is STILL an interesting fact that might be provable.
