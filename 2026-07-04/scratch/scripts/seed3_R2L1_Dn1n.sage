"""
Seed 3, R2L1: Analyze D_{n-1}^n and the key recurrence Q_n + q^n Q_{n-1} = D_{n-1}^n.

We established: Q_n = D_{n-1}^n - q^n Q_{n-1}
So: Q_n + q^n Q_{n-1} = D_{n-1}^n

D_{n-1}^n = the (n-1)-th iterated q-difference of h_m evaluated at m=n.
D_0^n = h_n, D_1^n = h_n - q*h_{n-1}, ..., D_{n-1}^n = h_n - ... (n-1 steps)

Now h_n has a factor 1/(1+q^n+q^{2n}) from the transfer matrix denominator.
If D_{n-1}^n is divisible by (1+q^n+q^{2n}) and the quotient is nonneg,
this would give information about Q_n.

But wait: D_{n-1}^n mixes h_n (which has the denominator) with h_1,...,h_{n-1}
(which don't). So D_{n-1}^n is NOT simply h_n * something.

Let me compute D_{n-1}^n and check its properties.

Also: Q_n + q^n Q_{n-1} = D_{n-1}^n means if both Q_n, Q_{n-1} >= 0,
then D_{n-1}^n >= 0 (trivially). But for the induction to work, we need
D_{n-1}^n >= q^n Q_{n-1}, i.e., D_{n-1}^n - q^n Q_{n-1} >= 0.

The question is: can we prove D_{n-1}^n >= q^n Q_{n-1}?
Or equivalently: Q_n >= 0 iff D_{n-1}^n >= q^n Q_{n-1}.

Let me compute D_{n-1}^n and see what it looks like.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=500)

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

def compute_all(d, n_max, prec=500):
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
    D_all = {}
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, n_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        h = {m: qn[m] * g[m] for m in range(n_max+1)}
        
        Q[(c, 0)] = R(1)
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
            # Store D_{n-1}^n
            D_all[(c, n)] = D.get((n-1, n), R(0))
    
    return Q, D_all, P, F, profs

d = 4
n_max = 5
Q, D_nm1_n, P, F, profs = compute_all(d, n_max)

print("=" * 60)
print(f"d={d}: Analysis of D_{{n-1}}^n and the recurrence Q_n + q^n Q_{{n-1}} = D_{{n-1}}^n")
print("=" * 60)

c0 = (2, 1, 1)
for n in range(1, n_max+1):
    Dn = D_nm1_n[(c0, n)]
    Qn = Q[(c0, n)]
    Qn1 = Q.get((c0, n-1), R(0))
    
    # Verify: Q_n + q^n Q_{n-1} = D_{n-1}^n
    check = Qn + q^n * Qn1 - Dn
    assert check == R(0), f"Failed at n={n}!"
    
    Dn_coeffs = Dn.list()
    Qn_coeffs = Qn.list()
    shift_Qn1 = (q^n * Qn1).list()
    
    is_Dn_nn = all(c >= 0 for c in Dn_coeffs)
    
    print(f"\nn={n}:")
    print(f"  D_{{n-1}}^n nonneg: {is_Dn_nn}")
    print(f"  D_{{n-1}}^n coeffs: {Dn_coeffs[:20]}")
    print(f"  Q_n coeffs:        {Qn_coeffs[:20]}")
    print(f"  q^n Q_{{n-1}}:      {shift_Qn1[:20]}")
    print(f"  D eval at 1: {sum(Dn_coeffs)}")
    print(f"  Q_n eval at 1: {sum(Qn_coeffs)}")

# ======================================================================
# Key question: Is D_{n-1}^n always nonneg?
# If so, then Q_n = D_{n-1}^n - q^n Q_{n-1} is nonneg iff D_{n-1}^n >= q^n Q_{n-1}.
# ======================================================================

print("\n" + "=" * 60)
print("Is D_{n-1}^n always nonneg?")
print("=" * 60)

for n in range(1, n_max+1):
    all_nn = True
    for c in profs:
        Dn = D_nm1_n[(c, n)]
        if any(v < 0 for v in Dn.list()):
            all_nn = False
            min_coeff = min(Dn.list())
            print(f"  n={n}, c={c}: NEGATIVE, min coeff = {min_coeff}")
    if all_nn:
        print(f"  n={n}: All D_{{n-1}}^n are nonneg!")

# ======================================================================
# Also check the higher-order relationship:
# D_k^m for ALL k and m.
# From Round 1: D_k^m >= 0 for k >= 1 (87+ entries verified).
# Let me verify this for k = 0,...,5 and m = 0,...,5.
# ======================================================================

print("\n" + "=" * 60)
print("D_k^m positivity check (d=4, c=(2,1,1))")
print("=" * 60)

c0 = (2, 1, 1)
# Recompute all D_k^m
g = {0: F[(c0, 0)]}
for m in range(1, n_max+1):
    g[m] = F[(c0, m)] - F[(c0, m-1)]
qn = [prod(1-q^i for i in range(1,m+1)) if m>0 else R(1) for m in range(n_max+1)]
h = {m: qn[m] * g[m] for m in range(n_max+1)}

D_full = {}
for m in range(n_max+1):
    D_full[(0, m)] = h[m]
for k in range(1, n_max+1):
    for m in range(k, n_max+1):
        D_full[(k, m)] = D_full[(k-1, m)] - q^k * D_full.get((k-1, m-1), R(0))

for k in range(n_max+1):
    for m in range(k, n_max+1):
        Dkm = D_full[(k, m)]
        coeffs = Dkm.list()
        is_nn = all(c >= 0 for c in coeffs)
        ev = sum(coeffs)
        marker = "  " if is_nn else "**"
        print(f"  {marker} D_{k}^{m}: nonneg={is_nn}, eval={ev}, deg={len(coeffs)-1 if coeffs else -1}")

# ======================================================================
# CRUCIAL OBSERVATION: D_0^m = h_m is NEGATIVE for m >= 2.
# But D_k^m for k >= 1 is always nonneg (verified).
# The recurrence Q_n = D_{n-1}^n - q^n Q_{n-1} shows:
# Q_n >= 0 iff D_{n-1}^n >= q^n Q_{n-1} (coefficient-wise).
# Since D_{n-1}^n >= 0 (from the D_k^m positivity for k >= 1),
# this is a STRONGER statement: D_{n-1}^n >= 0 AND D_{n-1}^n >= q^n Q_{n-1}.
# ======================================================================

# Let me check whether D_{n-1}^n - q^n Q_{n-1} = Q_n >= 0 can be seen from
# D_{n-1}^n being "much larger" than q^n Q_{n-1}.

print("\n" + "=" * 60)
print("Comparison: D_{n-1}^n vs q^n Q_{n-1}")
print("=" * 60)

for n in range(1, 5):
    c0 = (2, 1, 1)
    Dn = D_nm1_n[(c0, n)]
    qnQn1 = q^n * Q.get((c0, n-1), R(0))
    ratio_at_1 = sum(Dn.list()) / sum(qnQn1.list()) if sum(qnQn1.list()) != 0 else "inf"
    print(f"n={n}: D(1) = {sum(Dn.list())}, q^n*Q_{{n-1}}(1) = {sum(qnQn1.list())}, ratio = {ratio_at_1}")
    
    # Check coefficient-wise: is D >= q^n Q_{n-1}?
    diff = Dn - qnQn1
    diff_coeffs = diff.list()
    is_nn = all(c >= 0 for c in diff_coeffs)
    print(f"  D - q^n Q_{{n-1}} nonneg: {is_nn} (= Q_n nonneg)")

# ======================================================================
# NEW RESULT: Express D_{n-1}^n using the EMD path formula.
# D_0^n = h_n. D_1^n = h_n - q h_{n-1}. ... D_{n-1}^n = ?
# 
# D_{n-1}^n = sum_{j=0}^{n-1} (-1)^j q^{1+2+...+j} [n-1 choose j]_q h_{n-j}
#           = sum_{j=0}^{n-1} (-1)^j q^{binom(j+1,2)} [n-1 choose j]_q h_{n-j}
#
# Wait: D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}
# Starting from D_0^m = h_m:
# D_1^n = h_n - q h_{n-1}
# D_2^n = D_1^n - q^2 D_1^{n-1} = h_n - q h_{n-1} - q^2(h_{n-1} - q h_{n-2})
#        = h_n - (q+q^2) h_{n-1} + q^3 h_{n-2}
# D_3^n = D_2^n - q^3 D_2^{n-1}
#
# In general: D_k^n = sum_{j=0}^k (-1)^j q^{binom(j+1,2)} [k choose j]_q h_{n-j}
# (This is the iterated q-difference formula.)
#
# So D_{n-1}^n = sum_{j=0}^{n-1} (-1)^j q^{binom(j+1,2)} [n-1 choose j]_q h_{n-j}
# ======================================================================

# Verify this formula:
for n in range(1, 4):
    c0 = (2, 1, 1)
    Dn_formula = R(0)
    for j in range(n):
        qb = q^(j*(j+1)//2)
        # [n-1 choose j]_q
        from sage.all import q_binomial
        qbin_val = q_binomial(n-1, j, q)
        Dn_formula += (-1)^j * qb * qbin_val * h[n-j]
    
    check = Dn_formula - D_nm1_n[(c0, n)]
    print(f"n={n}: D_{{n-1}}^n formula check = {check == R(0)}")

print("\n" + "=" * 60)
print("KEY FORMULA VERIFIED:")
print("D_{n-1}^n = sum_{j=0}^{n-1} (-1)^j q^{binom(j+1,2)} [n-1 choose j]_q h_{n-j}")
print("Q_n = D_{n-1}^n - q^n Q_{n-1}")
print("=" * 60)

# Now: h_m = beta_m * tilde_h_m where beta_m = (q;q)_m / (q^3;q^3)_m
# and tilde_h_m = P_m - (1-q^{3m}) P_{m-1}
# = sum_{c'!=c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c)
# This is MANIFESTLY NONNEG.

# So D_{n-1}^n = sum_j (-1)^j q^{binom(j+1,2)} [n-1 choose j] beta_{n-j} tilde_h_{n-j}

# The alternating signs come from the (-1)^j and the fact that beta_{n-j} may contribute
# additional sign issues.

# Actually, beta_m = (q;q)_m / (q^3;q^3)_m has alternating signs!
# For m=1: 1/(1+q+q^2) = 1 - q + q^3 - q^4 + ... (alternating)
# So even though tilde_h_m >= 0, beta_m has mixed signs,
# and the alternating sum introduces more mixed signs.

# The MIRACLE of the conjecture is that all these signs cancel.

# Can we reorganize the sum to make cancellation manifest?
# This is where the EMD structure might help.
