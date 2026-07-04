# The CW equation for g_m(c) depends on F_{c(J),m} for J where c(J) != c
# Those F values in turn depend on g_m(c(J)), which may circularly depend on c.
# 
# The system of equations is actually LINEAR in {g_m(c) : all profiles c}
# for each fixed m. Let me set it up as a linear system and solve.

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
        if i in J and ((i-1)%k) not in J:
            result[i] -= 1
        elif i not in J and ((i-1)%k) in J:
            result[i] += 1
    return tuple(result)

def all_nonempty_subsets(S):
    n = len(S)
    return [[S[i] for i in range(n) if mask & (1<<i)] for mask in range(1, 2**n)]

def compute_all(d, m_max, prec=150):
    profiles = get_profiles(d)
    prof_idx = {p: i for i, p in enumerate(profiles)}
    N = len(profiles)
    
    g = {}
    F_partial = {}
    
    for c in profiles:
        g[(c, 0)] = R(1)
        F_partial[(c, 0)] = R(1)
    
    for m in range(1, m_max + 1):
        # Set up linear system: for each profile c,
        # g_m(c) = sum over J of (-1)^{|J|-1} q^{m|J|} * (F_{c(J),m-1} + g_m(c(J)) * [c(J) valid])
        # But if c(J) = c, the g_m(c(J)) = g_m(c) is the unknown.
        # Rearranging: g_m(c) * (1 - sum_{J: c(J)=c} (-1)^{|J|-1} q^{m|J|})
        #            - sum_{J: c(J)!=c, valid} (-1)^{|J|-1} q^{m|J|} g_m(c(J))
        #            = sum_J (-1)^{|J|-1} q^{m|J|} F_{c(J),m-1}
        
        # This is: A * g_m_vec = b
        # where g_m_vec = [g_m(c) for c in profiles]
        
        # Build the matrix A and vector b over the power series ring
        # A[i][j] = coefficient of g_m(profiles[j]) in the equation for profiles[i]
        # b[i] = RHS constant term
        
        A_mat = [[R(0)]*N for _ in range(N)]
        b_vec = [R(0)]*N
        
        for ci, c in enumerate(profiles):
            Ic = [i for i in range(3) if c[i] > 0]
            subsets = all_nonempty_subsets(Ic)
            
            # Diagonal: coefficient of g_m(c) is 1 - sum_{J:c(J)=c} (-1)^{|J|-1} q^{m|J|}
            A_mat[ci][ci] = R(1)
            
            for J in subsets:
                sJ = len(J)
                cJ = shifted_profile(c, J)
                sign = (-1)**(sJ - 1)
                
                # Check cJ is valid (all entries >= 0)
                if any(x < 0 for x in cJ):
                    continue
                if cJ not in prof_idx:
                    continue
                    
                cj_idx = prof_idx[cJ]
                
                # Contribution: sign * q^{m*sJ} * (F_{cJ,m-1} + g_m(cJ))
                # F_{cJ,m-1} goes to b_vec
                # g_m(cJ) goes to A_mat
                
                b_vec[ci] += sign * q^(m*sJ) * F_partial[(cJ, m-1)]
                A_mat[ci][cj_idx] -= sign * q^(m*sJ)
        
        # Solve A * g_m_vec = b
        # Since A is over power series, use Gaussian elimination or Cramer's rule
        # For small N, we can solve iteratively using the fact that A is close to identity
        
        # A = I - B where B has entries starting at q^m or higher
        # So A^{-1} = I + B + B^2 + ... (converges in power series ring)
        
        # Actually let's just solve using SageMath's matrix inverse
        # But matrices over power series rings can be tricky.
        
        # For now, let me use iterative solution:
        # g = A^{-1} b = (I-B)^{-1} b = b + B*b + B^2*b + ...
        
        B_mat = [[R(0)]*N for _ in range(N)]
        for i in range(N):
            for j in range(N):
                if i == j:
                    B_mat[i][j] = R(1) - A_mat[i][j]  # = -diag correction
                else:
                    B_mat[i][j] = -A_mat[i][j]  # = off-diagonal B entries
        # So A = I - B, i.e. B[i][j] = delta_{ij} - A[i][j]
        # Wait: A = I - B means B = I - A
        # A[i][i] = 1 - something, A[i][j!=i] = -something
        # B[i][i] = something (starts at q^m), B[i][j!=i] = something (starts at q^m)
        
        # g = sum_{k=0}^{prec/m} B^k b
        g_vec = list(b_vec)
        Bk_b = list(b_vec)
        
        for iteration in range(prec // m + 5):
            # Bk_b = B * Bk_b
            new_Bk_b = [R(0)]*N
            for i in range(N):
                for j in range(N):
                    new_Bk_b[i] += B_mat[i][j] * Bk_b[j]
            Bk_b = new_Bk_b
            
            # Check if all zero (converged)
            all_zero = all(Bk_b[i].valuation() >= prec for i in range(N))
            if all_zero:
                break
            
            for i in range(N):
                g_vec[i] += Bk_b[i]
        
        for ci, c in enumerate(profiles):
            g[(c, m)] = g_vec[ci]
            F_partial[(c, m)] = F_partial[(c, m-1)] + g[(c, m)]
    
    return g, F_partial, profiles

# Test d=2
print("=== d=2 ===")
d = 2
g, F, profs = compute_all(d, 5, prec=150)

for c in [(1,1,0), (2,0,0)]:
    print(f"\nProfile {c}:")
    for m in range(4):
        print(f"  g_{m} = {g[(c,m)] + O(q^15)}")

# Compute Q_n
def compute_Qn(c, n, d, g_data, prec=150):
    ell = gcd(d, 3)
    def ck(k):
        if k == 0: return R(1)
        return (-1)^k * q^(k*(k+1)//2) / prod(1-q^i for i in range(1,k+1))
    def qpoch_ell(n):
        return prod(1 - q^(ell*i) for i in range(1, n+1))
    h_n = sum(ck(k) * g_data[(c, n-k)] for k in range(n+1))
    return qpoch_ell(n) * h_n

print("\n=== Q_n for d=2 ===")
ell = gcd(d, 3)
expected_eval = ((d+1)*(d+2)//6 - 1)
print(f"Expected Q_n(1) = {expected_eval}^n")

for c in [(1,1,0), (2,0,0), (0,1,1)]:
    print(f"\nProfile {c}:")
    for n in range(1, 4):
        Qn = compute_Qn(c, n, d, g, prec=150)
        Qn_trunc = Qn + O(q^40)
        coeffs = Qn_trunc.list()
        neg = [(i,v) for i,v in enumerate(coeffs) if v < 0]
        print(f"  Q_{n} = {Qn_trunc}")
        print(f"  Q_{n}(1) = {sum(coeffs)}, neg: {neg[:3] if neg else 'NONE'}")

# Test d=4
print("\n\n=== d=4 ===")
d = 4
g4, F4, profs4 = compute_all(d, 3, prec=150)

ell = gcd(d, 3)
expected_eval = ((d+1)*(d+2)//6 - 1)
print(f"Expected Q_n(1) = {expected_eval}^n")

for c in [(2,1,1), (4,0,0)]:
    print(f"\nProfile {c}:")
    for n in range(1, 3):
        Qn = compute_Qn(c, n, d, g4, prec=150)
        Qn_trunc = Qn + O(q^30)
        coeffs = Qn_trunc.list()
        neg = [(i,v) for i,v in enumerate(coeffs) if v < 0]
        print(f"  Q_{n} = {Qn_trunc}")
        print(f"  Q_{n}(1) = {sum(coeffs)}, neg: {neg[:3] if neg else 'NONE'}")

