# Correct computation using the CW functional equation directly
# instead of the EMD path formula (which has orientation ambiguity)

# Strategy: compute F_c(y,q) via the CW functional equation iteratively
# g_m = [y^m] F_c(y,q) for each profile c

# CW equation: F_c(y,q) = sum_{J subset I_c, J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q)/(1-yq^|J|)

# This is a functional equation in y. For computing [y^m]:
# [y^m] F_c(y,q) = sum_J (-1)^{|J|-1} * [y^m](F_{c(J)}(yq^|J|, q)/(1-yq^|J|))
# = sum_J (-1)^{|J|-1} * q^{m|J|} * [y^m](F_{c(J)}(y, q) * 1/(1-yq^|J|/q^{...}))
# Hmm this is getting complicated. Let me think again.

# Actually [y^m](f(yq^s, q)/(1-yq^s)) 
# = [y^m](sum_k f_k (yq^s)^k * sum_j (yq^s)^j)
# = [y^m](sum_n (sum_{k+j=n} f_k) * q^{ns} * y^n)
# = q^{ms} * sum_{k=0}^m f_k
# = q^{ms} * F_{c(J),m}(q)   [partial sums of g]

# Wait: [y^m](f(yq^s)/(1-yq^s)) where f(y) = sum g_k y^k
# = [y^m](sum_k g_k q^{ks} y^k * sum_j q^{js} y^j)
# = sum_{k+j=m, k>=0, j>=0} g_k q^{(k+j)s}
# = q^{ms} sum_{k=0}^m g_k
# = q^{ms} * F_{c(J),m}

# So: g_m(c) = [y^m] F_c(y,q) = sum_J (-1)^{|J|-1} q^{m|J|} F_{c(J),m}(q)

# And F_{c,m}(q) = sum_{j=0}^m g_j(c)

# This gives a recurrence! We can compute g_m(c) for all profiles c simultaneously
# using the equation:
# g_m(c) = sum_J (-1)^{|J|-1} q^{m|J|} * sum_{j=0}^m g_j(c(J))

# But this is circular: g_m(c) depends on g_m(c(J)). Unless c(J) != c for all J.
# Actually it CAN be c(J) = c. E.g. J = I_c when all c_i > 0.

# Let me re-read the CW equation more carefully.
# Profile c = (c_0, ..., c_{k-1}), I_c = {i : c_i > 0}
# For J subset I_c nonempty:
# c_i(J) = c_i - 1 if i in J and (i-1) mod k not in J
#         = c_i + 1 if i not in J and (i-1) mod k in J
#         = c_i otherwise

# So c(J) = c only if for all i:
# either (i in J and (i-1) in J) or (i not in J and (i-1) not in J)
# i.e., J is a union of consecutive blocks. For k=3, J = {0,1,2} = I_c (if all c_i > 0).
# Then c(J) = c. |J| = 3.

# So for profiles with all c_i > 0, the term with J = I_c gives:
# (-1)^2 q^{3m} F_{c,m}
# So: g_m(c) = q^{3m} F_{c,m} + other terms involving F_{c(J),m} for J proper subset
# => g_m(c) - q^{3m}(g_0(c)+...+g_m(c)) = other terms
# => g_m(c)(1 - q^{3m}) - q^{3m}*F_{c,m-1} = other terms
# => g_m(c) = (q^{3m} F_{c,m-1} + other terms)/(1-q^{3m})

# This gives a valid recurrence as long as we can compute "other terms"
# from g_j(c') for c' != c and j <= m.

# For the case k=3, r=3:
# There are t = d+3 total, and binom(d+2,2) profiles.

# Let me implement this properly.

R.<q> = PowerSeriesRing(ZZ, default_prec=150)

def get_profiles(d):
    profs = []
    for a in range(d+1):
        for b in range(d+1-a):
            profs.append((a, b, d-a-b))
    return profs

def shifted_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        i_in_J = i in J
        im1_in_J = ((i-1) % k) in J
        if i_in_J and not im1_in_J:
            result[i] -= 1
        elif not i_in_J and im1_in_J:
            result[i] += 1
    return tuple(result)

def all_nonempty_subsets(S):
    result = []
    n = len(S)
    for mask in range(1, 2**n):
        subset = [S[i] for i in range(n) if mask & (1 << i)]
        result.append(subset)
    return result

def compute_gm_all(d, m_max, prec=150):
    """Compute g_m(c) for all profiles c and m = 0, ..., m_max"""
    profiles = get_profiles(d)
    prof_set = set(profiles)
    
    # g_0(c) = 1 for the zero profile... wait, g_0 = F_{c,0} which counts 
    # CPs with max = 0 = empty CP. Size = 0. So g_0(c) = 1 for all c.
    
    # F_{c,0} = 1 (just the empty partition triple)
    
    g = {}  # g[(c, m)] = g_m(c)
    F_partial = {}  # F_partial[(c, m)] = F_{c,m} = sum_{j=0}^m g_j(c)
    
    for c in profiles:
        g[(c, 0)] = R(1)
        F_partial[(c, 0)] = R(1)
    
    for m in range(1, m_max + 1):
        for c in profiles:
            Ic = [i for i in range(3) if c[i] > 0]
            subsets = all_nonempty_subsets(Ic)
            
            rhs = R(0)
            self_term_coeff = R(0)  # coefficient of F_{c,m} from J where c(J) = c
            
            for J in subsets:
                sJ = len(J)
                cJ = shifted_profile(c, J)
                sign = (-1)**(sJ - 1)
                
                if cJ == c:
                    # This contributes sign * q^{m*sJ} * F_{c,m}
                    # = sign * q^{m*sJ} * (F_{c,m-1} + g_m(c))
                    self_term_coeff += sign * q^(m * sJ)
                    rhs += sign * q^(m * sJ) * F_partial[(c, m-1)]
                else:
                    if cJ not in prof_set:
                        # Invalid profile (negative entry)
                        continue
                    rhs += sign * q^(m * sJ) * F_partial[(cJ, m)]
            
            # g_m(c) = self_term_coeff * g_m(c) + rhs
            # (1 - self_term_coeff) * g_m(c) = rhs
            
            denom = 1 - self_term_coeff
            
            # Check if denom is invertible
            if denom[0] == 0:
                print(f"WARNING: denom starts at 0 for c={c}, m={m}")
                g[(c, m)] = R(0)
            else:
                g[(c, m)] = rhs / denom
            
            F_partial[(c, m)] = F_partial[(c, m-1)] + g[(c, m)]
    
    return g, F_partial, profiles

# Test d=2
print("=== d=2 ===")
d = 2
g, F, profs = compute_gm_all(d, 5, prec=150)

for c in [(1,1,0), (2,0,0), (0,1,1)]:
    print(f"\nProfile {c}:")
    for m in range(4):
        print(f"  g_{m} = {g[(c,m)] + O(q^20)}")
        print(f"  F_{{c,{m}}} = {F[(c,m)] + O(q^20)}")

# Now compute Q_n from these
def compute_Qn_from_g(c, n, d, g_data, prec=150):
    """Q_n = (q^ell;q^ell)_n * sum_{k=0}^n c_k g_{n-k}(c)
    where c_k = (-1)^k q^{k(k+1)/2} / (q;q)_k
    """
    ell = gcd(d, 3)
    
    def ck(k):
        if k == 0: return R(1)
        return (-1)^k * q^(k*(k+1)//2) / prod(1-q^i for i in range(1,k+1))
    
    def qpoch_ell(n):
        return prod(1 - q^(ell*i) for i in range(1, n+1))
    
    h_n = sum(ck(k) * g_data[(c, n-k)] for k in range(n+1))
    return qpoch_ell(n) * h_n

print("\n=== Q_n for d=2 ===")
for c in [(1,1,0), (2,0,0), (0,1,1)]:
    print(f"\nProfile {c}:")
    for n in range(1, 4):
        Qn = compute_Qn_from_g(c, n, d, g, prec=150)
        Qn_trunc = Qn + O(q^50)
        print(f"  Q_{n} = {Qn_trunc}")
        coeffs = (Qn + O(q^50)).list()
        print(f"  Q_{n}(1) = {sum(coeffs)}")

print("\n\n=== d=4 ===")
d = 4
g4, F4, profs4 = compute_gm_all(d, 4, prec=150)

print("Q_n for d=4:")
for c in [(2,1,1), (4,0,0), (1,2,1)]:
    print(f"\nProfile {c}:")
    for n in range(1, 3):
        Qn = compute_Qn_from_g(c, n, d, g4, prec=150)
        Qn_trunc = Qn + O(q^40)
        print(f"  Q_{n} = {Qn_trunc}")
        coeffs = (Qn + O(q^40)).list()
        neg = [(i,v) for i,v in enumerate(coeffs) if v < 0]
        print(f"  Q_{n}(1) = {sum(coeffs)}, neg coeffs: {neg[:5] if neg else 'NONE'}")

