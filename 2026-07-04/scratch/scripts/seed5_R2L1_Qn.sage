# Compute Q_n from P_n via the q-binomial transform
# Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
# P_m = (q^ell;q^ell)_m * F_{c,m}
# So F_{c,m} = P_m / (q^ell;q^ell)_m
#
# [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n c_{n-j} * g_j
# where c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k
# and g_j = F_{c,j} - F_{c,j-1}
#
# So h_n = sum_{j=0}^n c_{n-j} * (F_{c,j} - F_{c,j-1})
#        = sum_{j=0}^n c_{n-j} * F_{c,j} - sum_{j=1}^n c_{n-j} * F_{c,j-1}
#        = sum_{j=0}^n c_{n-j} * F_{c,j} - sum_{j=0}^{n-1} c_{n-1-j} * F_{c,j}
#        Hmm, shift: in second sum, let j' = j-1, then sum_{j'=0}^{n-1} c_{n-1-j'} F_{c,j'}
#        So h_n = c_n F_{c,0} + sum_{j=1}^{n-1} (c_{n-j} - c_{n-1-j}) F_{c,j} + c_0 * (F_{c,n} - F_{c,n-1})
#        Hmm this is getting messy. Let me just compute directly.
#
# h_n = sum_{j=0}^n c_{n-j} g_j = sum_{j=0}^n c_j g_{n-j}
# 
# Alternatively, since F_{c,m} = P_m / (q^ell;q^ell)_m:
# h_n = sum_{j=0}^n c_{n-j} (F_{c,j} - F_{c,j-1})
# = sum_{j=0}^n c_{n-j} F_{c,j} - sum_{j=0}^{n-1} c_{n-1-j} F_{c,j}  [NOT RIGHT - shifts don't match]
#
# Let me just do it directly:
# h_n = sum_{j=0}^n c_{n-j} * g_j where g_j = F_{c,j} - F_{c,j-1}
# = sum_{j=0}^n c_{n-j} * (P_j/(q^ell;q^ell)_j - P_{j-1}/(q^ell;q^ell)_{j-1})
# with P_{-1} = 0
# Q_n = (q^ell;q^ell)_n * h_n

# But this requires computing P_j / (q^ell;q^ell)_j which is an infinite series.
# Better: use the Abel summation / change of summation order:
#
# h_n = sum_{j=0}^n c_{n-j} g_j
# Substitute g_j = F_{c,j} - F_{c,j-1}:
# h_n = sum_{j=0}^n c_{n-j} F_{c,j} - sum_{j=1}^n c_{n-j} F_{c,j-1}
# = sum_{j=0}^n c_{n-j} F_{c,j} - sum_{j=0}^{n-1} c_{n-1-j} F_{c,j}
# = c_0 F_{c,n} + sum_{j=0}^{n-1} (c_{n-j} - c_{n-1-j}) F_{c,j}
# = F_{c,n} + sum_{j=0}^{n-1} (c_{n-j} - c_{n-1-j}) F_{c,j}
#
# Note c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k
# c_k - c_{k-1} = (-1)^k q^{k(k+1)/2}/(q;q)_k - (-1)^{k-1} q^{k(k-1)/2}/(q;q)_{k-1}
# = (-1)^{k-1} q^{k(k-1)/2}/(q;q)_{k-1} * (-q^k/(1-q^k) - 1)
# = (-1)^{k-1} q^{k(k-1)/2}/(q;q)_{k-1} * (-(q^k + 1 - q^k)/(1-q^k))
# = (-1)^{k-1} q^{k(k-1)/2}/(q;q)_{k-1} * (-1/(1-q^k))
# = (-1)^k q^{k(k-1)/2} / (q;q)_k
# Wait that gives c_k - c_{k-1} = ... let me just compute.

# CLEANER APPROACH: Use the synthesis formula directly.
# From the synthesis "Core Diagnosis":
# Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^ell;q^ell)_j
# Hmm, but P_j / (q^ell;q^ell)_j = F_{c,j}...
# Actually let me look at this differently.

# We want: Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
# With ell = 1 for d=2:
# (zq;q)_inf = prod_{i>=1}(1-zq^i)
# F_c(z,q) = sum_m g_m z^m = sum_m (F_{c,m} - F_{c,m-1}) z^m

# Now multiply:
# (zq;q)_inf * F_c(z,q) = prod_{i>=1}(1-zq^i) * sum_m F_{c,m} z^m (NOT g_m!)
# Wait no: F_c(z,q) = sum_m g_m z^m where g_m counts CPs with max EXACTLY m.
# F_c(z,q) != sum_m F_{c,m} z^m.
# F_c(1,q) = F_c(q) = sum_m g_m = lim F_{c,n}.

# We have: [z^n](sum_k a_k z^k * sum_m b_m z^m) = sum_{k+m=n} a_k b_m

# With a_k = [z^k](zq;q)_inf, b_m = g_m:
# h_n = sum_{k=0}^n a_k g_{n-k}

# But g_m is an INFINITE power series in q. That's fine for formal computation
# but we need to handle it correctly.

# KEY INSIGHT: We can rewrite using F_{c,m} = sum_{j=0}^m g_j:
# sum_{k=0}^n a_k g_{n-k} = sum_{k=0}^n a_k (F_{c,n-k} - F_{c,n-k-1})
# (Abel summation)
# = a_0 F_{c,n} + sum_{k=1}^n (a_k - a_{k-1}) F_{c,n-k} - a_n F_{c,-1}
# Hmm, the formula is:
# sum_{k=0}^n a_k (F_{c,n-k} - F_{c,n-k-1})  [with F_{c,-1} = 0]
# = -sum_{k=0}^n a_k F_{c,n-k-1} + sum_{k=0}^n a_k F_{c,n-k}
# = sum_{j=0}^n a_{n-j} F_{c,j} - sum_{j=0}^{n-1} a_{n-j-1+1} F_{c,j} ... this is messy

# Let me just compute numerically using P_m:

prec = 200
R.<q> = PowerSeriesRing(QQ, default_prec=prec)

def emd_profiles(c, cp):
    """Simplified EMD on Z/3Z"""
    r = 3
    best = None
    for shift in range(r):
        cs = tuple(c[(i+shift) % r] for i in range(r))
        d_val = 0
        running = 0
        for i in range(r-1):
            running += cp[i] - cs[i]
            d_val += abs(running)
        if best is None or d_val < best:
            best = d_val
    return best

def compute_Pn_all(d, n_max, prec=200):
    """Compute P_n(c) for all profiles c, n=0..n_max, using EMD path formula."""
    R_local.<q_local> = PowerSeriesRing(QQ, default_prec=prec)
    
    profiles = []
    for a in range(d+1):
        for b in range(d+1-a):
            profiles.append((a, b, d-a-b))
    
    num_p = len(profiles)
    
    # EMD matrix
    emd_mat = [[emd_profiles(profiles[i], profiles[j]) for j in range(num_p)] for i in range(num_p)]
    
    # DP
    results = {}  # results[(profile, n)] = P_n(profile)
    
    dp_prev = {i: R_local(1) for i in range(num_p)}  # P_0 = 1 for all profiles
    for i in range(num_p):
        results[(profiles[i], 0)] = R_local(1)
    
    for k in range(1, n_max + 1):
        dp_curr = {}
        for i in range(num_p):
            dp_curr[i] = R_local(0)
            for j in range(num_p):
                dp_curr[i] += dp_prev[j] * q_local^(k * emd_mat[i][j])
            results[(profiles[i], k)] = dp_curr[i]
        dp_prev = dp_curr
    
    return results, profiles, R_local

def compute_Qn(profile, n_val, d, P_data, profiles, R_local, prec=200):
    """Compute Q_n using the definition with the q-binomial transform.
    Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
    where F_c(z,q) = sum_m g_m z^m, g_m = F_{c,m} - F_{c,m-1},
    F_{c,m} = P_m / (q^ell;q^ell)_m.
    
    h_n = sum_{k=0}^n c_k * g_{n-k}
    where c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k
    and g_j = P_j/(q^ell;q^ell)_j - P_{j-1}/(q^ell;q^ell)_{j-1}
    
    Q_n = (q^ell;q^ell)_n * h_n
    """
    ell = gcd(d, 3)
    q_local = R_local.gen()
    
    def qpoch_ell(m):
        """(q^ell;q^ell)_m"""
        result = R_local(1)
        for i in range(1, m+1):
            result *= (1 - q_local^(ell*i))
        return result
    
    def c_coeff(k):
        """(-1)^k q^{k(k+1)/2} / (q;q)_k"""
        if k < 0:
            return R_local(0)
        num = (-1)^k * q_local^(k*(k+1)//2)
        den = R_local(1)
        for i in range(1, k+1):
            den *= (1 - q_local^i)
        return num / den
    
    # Compute h_n = sum_{k=0}^n c_k * g_{n-k}
    # where g_j = P_j/qpoch_ell(j) - P_{j-1}/qpoch_ell(j-1) (P_{-1} = 0)
    
    h_n = R_local(0)
    for k in range(n_val + 1):
        j = n_val - k
        # g_j
        Fj = P_data[(profile, j)] / qpoch_ell(j)
        if j > 0:
            Fjm1 = P_data[(profile, j-1)] / qpoch_ell(j-1)
        else:
            Fjm1 = R_local(0)
        g_j = Fj - Fjm1
        h_n += c_coeff(k) * g_j
    
    Q_n = qpoch_ell(n_val) * h_n
    return Q_n

# Compute for d=2
print("=== Q_n for d=2 ===")
d = 2
ell = gcd(d, 3)
print(f"d={d}, ell={ell}")

P_data, profiles, Rl = compute_Pn_all(d, 5, prec=prec)

for profile in [(1,1,0), (2,0,0), (0,1,1)]:
    print(f"\nProfile {profile}:")
    for n in range(1, 4):
        Qn = compute_Qn(profile, n, d, P_data, profiles, Rl, prec=prec)
        # Check if it's a polynomial
        Qn_trunc = Qn + O(Rl.gen()^80)
        print(f"  Q_{n} = {Qn_trunc}")
        # Check evaluation
        try:
            val = Qn.polynomial()(1)
            print(f"  Q_{n}(1) = {val}")
        except:
            print(f"  Q_{n}(1) [from first 80 terms] = {sum(Qn_trunc.list())}")
        print(f"  Expected Q_{n}(1) = {((d+1)*(d+2)//6 - 1)^n}")

# Now compute for d=4
print("\n\n=== Q_n for d=4 ===")
d = 4
ell = gcd(d, 3)
print(f"d={d}, ell={ell}")

P_data4, profiles4, Rl4 = compute_Pn_all(d, 4, prec=prec)

for profile in [(2,1,1), (4,0,0), (1,2,1)]:
    print(f"\nProfile {profile}:")
    for n in range(1, 3):
        Qn = compute_Qn(profile, n, d, P_data4, profiles4, Rl4, prec=prec)
        Qn_trunc = Qn + O(Rl4.gen()^60)
        print(f"  Q_{n} first terms = {Qn_trunc}")
        print(f"  Q_{n}(1) [truncated] = {sum(Qn_trunc.list())}")
        print(f"  Expected Q_{n}(1) = {((d+1)*(d+2)//6 - 1)^n}")
        # Check positivity
        coeffs = Qn_trunc.list()
        neg_coeffs = [(i, c) for i, c in enumerate(coeffs) if c < 0]
        if neg_coeffs:
            print(f"  NEGATIVE coefficients: {neg_coeffs[:5]}")
        else:
            print(f"  All coefficients nonneg (up to degree {len(coeffs)-1})")

