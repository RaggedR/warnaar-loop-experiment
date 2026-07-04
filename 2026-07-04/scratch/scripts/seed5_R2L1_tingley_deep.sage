# Deep dive: understand max(pi) in terms of (crystal element, partition)
# 
# From Tingley Thm 4.13:
# |pi| = deg(v(pi)) + n * |lambda(pi)| where n = 3 for our case
# z^{max(pi)} grading: max(pi) = ???
#
# Key: in the abacus model, the k-th column corresponds to the k-th set of beads.
# The "column length" of a CP is max(pi). In the Kyoto path model,
# path length = number of columns that differ from ground state.
#
# But lambda(pi) also affects which columns are non-trivial!
# 
# Let me think about this via the bivariate GF.
# F_c(z,q) = sum_{pi} z^{max(pi)} q^{|pi|}
# = sum_{(v, lambda)} z^{max(pi(v,lambda))} q^{deg(v) + 3|lambda|}
#
# The key question is: what is max(pi(v,lambda)) as a function of v and lambda?
#
# From the construction: abacus config psi maps to (gamma(psi), lambda(psi))
# where gamma is the tight part and lambda is the partition.
# The CP pi(psi) has max(pi) = max over all rows i of the max entry in row i.
#
# For the tight config gamma: the CP pi(gamma) has some max value, call it depth(v).
# Adding the partition lambda shifts beads further. Each box of lambda(psi)
# adds one step to some bead, increasing some CP entry by 1.
# But the max might not increase if the new max is in a different column.
#
# Actually, I think max(pi(psi)) = max(depth(v), lambda_1)... no, that's wrong too.
#
# Let me think about it differently. The weight of psi is deg(v) + n*|lambda|.
# And max(pi(psi)) relates to how far the beads have traveled.
#
# In the Kyoto path model: path = (b_1, b_2, ...) in B^{1,d}^{tensor ...}
# The tight config gamma corresponds to choosing b_1, b_2, ... from B^{1,d}
# such that the path condition holds.
# The partition lambda adds "extra weight" distributed among the columns.
#
# The k-th column of the CP corresponds to the k-th tensor factor b_k.
# When b_k = ground_state_k, that column contributes nothing to the CP.
# When b_k != ground_state_k, it contributes to the CP entries.
# The partition lambda(psi) is obtained by the T_k operators which ADD
# beads in column k -- each added bead corresponds to incrementing the
# CP entry in column k by 1.
#
# So max(pi) = max_k (column_k_max) 
# where column_k_max = (displacement of b_k from ground state) + (lambda_k contribution)
#
# Hmm, this is getting complicated. Let me try a completely different angle.
#
# ALTERNATIVE APPROACH: Instead of trying to bijectively identify Q_n with 
# crystal elements, let me look at what the (zq;q)_inf factor does to the
# unrestricted generating function.
#
# Unrestricted: F_c(q) = ch_q(V(Lambda)) / (q^3;q^3)_inf  (Tingley Thm 4.14)
# But actually Tingley's result is for cylindric partitions of type (n, ell),
# and the GF factors as V_Lambda tensor F.
#
# Let me verify Tingley's partition function formula for d=2.

R.<q> = PowerSeriesRing(ZZ, default_prec=100)

# The principally specialized character of V(Lambda) for A_2^(1):
# For Lambda = level-d weight, the specialized character is:
# ch_q(V(Lambda)) = q^{h_Lambda} / prod_{m>=1}(1-q^m)^2 * product over positive roots
# This is the Kac-Weyl formula.

# For A_2^(1) at level 2, Lambda = 2*Lambda_0:
# The character is known. Let me use SageMath to compute it.

# Actually, let me use Borodin's product formula directly.
# For profile c = (c_0, c_1, c_2) with d=2, t=5:
# F_c(q) = 1/(q^5;q^5)_inf * product terms

# For c = (1,1,0), k=3, d_{i,j} values:
# d_{1,2} = c_1 = 1, d_{2,3} = c_2 = 0, d_{1,3} = c_1+c_2 = 1
# d_{2,1} = c_2 = 0, d_{3,1} = c_2+c_0 = 1... wait the indexing is different.
# Let me re-read Borodin's formula.

# Borodin: F_c(q) = 1/(q^t;q^t)_inf * 
#   prod_{i=1}^k prod_{j=i+1}^k prod_{m=1}^{c_i} 1/(q^{m+d_{i+1,j}+j-i};q^t)_inf
#   * prod_{i=2}^k prod_{j=2}^{i-1} prod_{m=1}^{c_i} 1/(q^{t-(m+d_{j,i-1}+i-j)};q^t)_inf
#
# where d_{i,j} = c_i + c_{i+1} + ... + c_j
# k = 3 (number of partitions), t = d + k = 5

# Wait, the conjecture uses r=3 partitions (indexed 0,1,2) but Borodin 
# uses k partitions (indexed 1,...,k). Let me use Borodin's convention.
# c = (c_1, c_2, c_3) = (1, 1, 0) in 1-indexed for profile (1,1,0)

c1, c2, c3 = 1, 1, 0
t = 5
# d_{i,j} = c_i + ... + c_j
d12 = c1 + c2  # = 2
d13 = c1 + c2 + c3  # = 2
d23 = c2 + c3  # = 1
d21 = c2  # For j < i? Actually d_{j,i-1} for the second product...
# Hmm the indexing is confusing. Let me just compute for specific profile.

# Actually let me skip Borodin and use my CW-computed g_m values.
# I already computed g_m for d=2 earlier. The unrestricted GF is:
# F_c(q) = sum_{m>=0} g_m(c)

# For profile (1,1,0), d=2:
# g_0 = 1, g_1 = 2q + 2q^2 + ..., g_2 = 2q^2 + 3q^3 + ...
# F_c(q) = 1 + 2q + 4q^2 + 5q^3 + 8q^4 + ...

# This should equal ch_q(V(Lambda)) / (q^3;q^3)_inf (from Tingley)

# Actually, let me check: Tingley's result is for cylindric plane partitions
# of type (n, ell), and his formula is:
# sum_{pi of type (n,ell)} q^{|pi|} = 
#   prod_{v in B_Lambda} 1/(1-q^{deg(v)}) * 1/(q^n;q^n)_inf
# Wait no, it's:
# = ch_q(V_Lambda) / (q^n;q^n)_inf  (Tingley's Theorem 4.14)
# where n = 3 in our case.

# So F_c(q) = ch_q(V(Lambda)) / (q^3;q^3)_inf

# And the bivariate version:
# F_c(z,q) = sum_m z^m g_m(c) 
# In terms of (v, lambda): 
# F_c(z,q) = sum_{v in B_Lambda} sum_{lambda partition} z^{f(v,lambda)} q^{deg(v)+3|lambda|}
# where f(v,lambda) = max(pi(v,lambda))

# The (zq;q)_inf factor:
# (zq;q)_inf * F_c(z,q) = (zq;q)_inf * ch_q(V_Lambda)/? (not straightforward in z)

# Let me try a COMPLETELY DIFFERENT approach.
# Instead of trying to understand Tingley's bijection in detail,
# let me compute Q_n for d=4 and d=5 and look for patterns
# that suggest a representation-theoretic interpretation.

# From the correct Q_n computation (d=4, profile (2,1,1)):
# Q_1 = 2q + q^2 + q^3  (4 terms with total 4)
# This has 4 "objects" with degrees 1,1,2,3.

# Q_1(1) = 4 = binom(6,2) - 1 = 15 - 1 = 14? No, that's wrong.
# Wait: for d=4, (d+1)(d+2)/6 - 1 = 5*6/6 - 1 = 5 - 1 = 4. Yes, Q_1(1) = 4.

# So Q_1 counts 4 objects. For A_2^(1) at level 4:
# B^{1,4} has 15 elements. B(Lambda) is infinite.
# The GL_3 key polynomial decomposition says Q_1 decomposes into Demazure characters.

# Let me check: does Q_1((2,1,1)) = 2q + q^2 + q^3 match some 
# weight-space component of a Demazure character?

# The 4 elements correspond to something with principal grading.
# Degrees: 1 (x2), 2 (x1), 3 (x1).

# For sl_3 with highest weight Lambda = (2,1,1) mapped somehow to sl_3 weight:
# The profile (2,1,1) with d=4 corresponds to some dominant weight of sl_3.
# The mapping: c_i = multiplicity of entry i+1 in the SSYT.
# So (2,1,1) -> SSYT [[1,1,2,3]] which has classical weight 
# (2,1,1) in the sense of (m_1, m_2, m_3) = counts.

# In sl_3, the weight of [[1,1,2,3]] is:
# Under the standard action, element e with entries: weight = sum_i m_i * epsilon_i
# where epsilon_i are the standard basis vectors.
# = 2*epsilon_1 + epsilon_2 + epsilon_3 = (2,1,1)
# Minus the average: center of mass = 4/3, so weight = (2/3, -1/3, -1/3)
# In Lambda_1, Lambda_2 basis: (2/3, -1/3, -1/3) = ... hmm

# Actually the finite weight (for sl_3) is:
# Lambda_1 coefficient = m_1 - m_2 = 2 - 1 = 1
# Lambda_2 coefficient = m_2 - m_3 = 1 - 1 = 0
# So the finite weight is Lambda_1 (fundamental weight).
# The Demazure character for this weight with appropriate word would give
# a polynomial in q.

# For the KR crystal B^{1,4} element [[1,1,2,3]] with profile (2,1,1):
# Classical sl_3 weight: m = (m_1-m_2, m_2-m_3) = (1, 0)
# The 4 elements of Q_1 should form some weight space at this value.

# But Q_1(1) = 4 = dim of what? For sl_3, dim of weight (1,0) in various reps:
# In adj rep (V(1,1)): weight (1,0) has dim 1
# In V(2,1): weight (1,0) has dim... need to compute

# Actually the number 4 = binom(d+2,2)/3 - 1 + 1 is suspicious.
# For d=4: 15/3 - 1 = 4. Hmm, 15/3 = 5 > 4.
# 5*6/6 - 1 = 4. That's the formula (d+1)(d+2)/6 - 1.

# The "number of profiles - 1" per orbit:
# 15 profiles, C_3 acts, giving 5 orbits of size 3 each.
# Per orbit: 5 - 1 = 4? That matches!
# Q_n(1) = (number of C_3 orbits - 1)^n? 
# Orbits: (4,0,0),(0,4,0),(0,0,4); (3,1,0),(1,0,3),(0,3,1); 
# (2,2,0),(0,2,2),(2,0,2); (2,1,1),(1,1,2),(1,2,1); (3,0,1),(0,1,3),(1,3,0)
# 5 orbits. Q_1(1) = 5-1 = 4. YES!

# For d=2: 6 profiles, 2 orbits, Q_1(1) = 2-1 = 1. YES!
# For d=5: 21 profiles, 7 orbits, Q_1(1) = 7-1 = 6.
# (d+1)(d+2)/6 - 1 = 6*7/6 - 1 = 7-1 = 6. YES!

# So Q_n(1) = (number of C_3 orbits of profiles - 1)^n.

# This is interesting but already known. The question is: what are the 
# graded objects that Q_n counts?

# KEY INSIGHT: The number of C_3 orbits of profiles = number of elements of
# B^{1,d}/C_3 = number of classically distinct elements.
# And (orbits - 1) suggests removing one element (the "identity" / ground state orbit).

# What if Q_n counts elements of (B^{1,d}/C_3 - {ground state})^n with some grading?
# Or elements of (B^{1,d} - {C_3 orbit of ground state})^n /C_3?

# For d=2: orbits are {(2,0,0),(0,2,0),(0,0,2)} and {(1,1,0),(1,0,1),(0,1,1)}
# Removing one orbit gives 1 orbit = 1 object.
# Q_1((1,1,0)) = q. This single object has degree 1.
# Q_1((2,0,0)) = q^2. Different degree for different profile!

# So Q_1 depends on the profile, even though Q_1(1) = 1 for all profiles.
# The grading distinguishes profiles within the same "value" count.

# For d=4, Q_1((2,1,1)) = 2q + q^2 + q^3 counts 4 objects with degrees 1,1,2,3.
# These 4 objects = 4 orbits - the orbit containing the profile (2,1,1)? 
# No, there are 5 orbits and we subtract 1 to get 4.

# What gets subtracted? Maybe the orbit containing the profile c itself?
# Or the orbit of the "maximal" profile?

# For d=2: Q_1(c) for c = (1,1,0): subtract orbit {(2,0,0),(0,2,0),(0,0,2)}? 
# 2 orbits - 1 = 1. Degree q^1.
# For c = (2,0,0): subtract orbit {(1,1,0),(1,0,1),(0,1,1)}?
# 2 orbits - 1 = 1. Degree q^2.

# Hmm, the degree depends on which orbit is subtracted...

# Let me just compute Q_1 for ALL profiles for d=4 and look for a pattern.

print("=== Q_1 for ALL d=4 profiles ===")
# Need to recompute. Use the CW method.

# Reuse the compute_all function from earlier
def compute_all_gm(d, m_max, prec=150):
    profiles = []
    for a in range(d+1):
        for b in range(d+1-a):
            profiles.append((a, b, d-a-b))
    
    prof_set = set(profiles)
    prof_idx = {p: i for i, p in enumerate(profiles)}
    N = len(profiles)
    
    g = {}
    F_partial = {}
    for c in profiles:
        g[(c, 0)] = R(1)
        F_partial[(c, 0)] = R(1)
    
    for m in range(1, m_max + 1):
        A_mat = [[R(0)]*N for _ in range(N)]
        b_vec = [R(0)]*N
        
        for ci, c in enumerate(profiles):
            Ic = [i for i in range(3) if c[i] > 0]
            subsets = []
            nI = len(Ic)
            for mask in range(1, 2**nI):
                subsets.append([Ic[i] for i in range(nI) if mask & (1<<i)])
            
            A_mat[ci][ci] = R(1)
            
            for J in subsets:
                sJ = len(J)
                k = 3
                result = list(c)
                for i in range(k):
                    if i in J and ((i-1)%k) not in J:
                        result[i] -= 1
                    elif i not in J and ((i-1)%k) in J:
                        result[i] += 1
                cJ = tuple(result)
                sign = (-1)**(sJ - 1)
                
                if any(x < 0 for x in cJ) or cJ not in prof_set:
                    continue
                
                cj_idx = prof_idx[cJ]
                b_vec[ci] += sign * q^(m*sJ) * F_partial[(cJ, m-1)]
                A_mat[ci][cj_idx] -= sign * q^(m*sJ)
        
        # Solve (I-B)g = b via Neumann series
        B_mat = [[R(0)]*N for _ in range(N)]
        for i in range(N):
            for j in range(N):
                B_mat[i][j] = (R(1) if i==j else R(0)) - A_mat[i][j]
        
        g_vec = list(b_vec)
        Bk_b = list(b_vec)
        
        for iteration in range(prec // m + 5):
            new_Bk_b = [R(0)]*N
            for i in range(N):
                for j in range(N):
                    new_Bk_b[i] += B_mat[i][j] * Bk_b[j]
            Bk_b = new_Bk_b
            if all(Bk_b[i].valuation() >= prec for i in range(N)):
                break
            for i in range(N):
                g_vec[i] += Bk_b[i]
        
        for ci, c in enumerate(profiles):
            g[(c, m)] = g_vec[ci]
            F_partial[(c, m)] = F_partial[(c, m-1)] + g[(c, m)]
    
    return g, F_partial, profiles

d = 4
ell = gcd(d, 3)
g4, F4, profs4 = compute_all_gm(d, 2, prec=80)

def compute_Qn(c, n, d, g_data):
    ell = gcd(d, 3)
    def ck(k):
        if k == 0: return R(1)
        return (-1)^k * q^(k*(k+1)//2) / prod(1-q^i for i in range(1,k+1))
    def qpoch_ell(n):
        return prod(1 - q^(ell*i) for i in range(1, n+1))
    h_n = sum(ck(k) * g_data[(c, n-k)] for k in range(n+1))
    return qpoch_ell(n) * h_n

for c in profs4:
    Q1 = compute_Qn(c, 1, d, g4)
    Q1_trunc = Q1 + O(q^20)
    print(f"  c={c}: Q_1 = {Q1_trunc}")

