# Seed 7 R2L1: Build transfer matrix A(x) for d=7, verify adjugate monomial theorem
# and explore the structure for Gaussian elimination

from itertools import combinations

def profiles(d):
    """All compositions (c0, c1, c2) with c0+c1+c2 = d, c_i >= 0."""
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def I_c(c):
    """Indices i where c_i > 0."""
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    """
    Given composition c and nonempty J subset of I_c,
    compute the shifted profile c(J).
    c_i(J) = c_i - 1 if i in J and (i-1) mod 3 not in J
           = c_i + 1 if i not in J and (i-1) mod 3 in J
           = c_i otherwise
    """
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

def build_transfer_matrix(d):
    """
    Build the transfer matrix A(x) for the CW system.
    The CW functional equation is:
    F_c(y,q) = sum_{empty != J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
    
    In the matrix formulation with x = yq^n for the bounded case:
    F_{c,n} - sum_J (-1)^{|J|-1} x^{|J|} F_{c(J),n-1} / ... 
    
    Actually, let me think about this more carefully.
    The transfer matrix encodes how profiles map to shifted profiles.
    """
    profs = profiles(d)
    prof_idx = {p: i for i, p in enumerate(profs)}
    N = len(profs)
    
    R = PolynomialRing(QQ, 'x')
    x = R.gen()
    
    # The matrix A(x) is defined so that (I - A(x)) * F_vector = something
    # From the CW recurrence, A(x)[c, c'] = sum over J such that c(J) = c' of (-1)^{|J|-1} x^{|J|} / (1-x*q^{|J|})
    # But wait, for the matrix inversion approach, we need to be more careful.
    
    # Let me look at it differently. The CW equation says:
    # F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
    # 
    # Define G_c(y,q) = (1-y) F_c(y,q). Then:
    # Actually, let's follow Agent B's approach. The key is the matrix (I - A(x)).
    
    # From synthesis: Agent B proved adj(I-A(x))[c,c'] = x^{EMD(c,c')}.
    # The matrix A(x) comes from the CW recurrence. Let me build it directly.
    
    # The CW recurrence in matrix form: for each profile c, 
    # F_c(y,q) = sum_{J != empty, J subset I_c} (-1)^{|J|-1} * 1/(1-y*q^|J|) * F_{c(J)}(y*q^|J|, q)
    
    # For the bounded generating function F_{c,n}(q), the transfer matrix approach gives:
    # vec(F_{.,n}) = A(q^n) * vec(F_{.,n-1})  approximately
    
    # Let me just build the A(x) matrix as described in the synthesis:
    # The matrix should satisfy the property that det(I-A(x)) = -(x^3-1).
    
    # From the CW recurrence, A(x) has entry A[c, c'] = coefficient telling how
    # F_{c'} contributes to F_c via the shift c(J) = c'.
    
    # For each c and each J subset I_c:
    #   c(J) is the target profile
    #   contribution is (-1)^{|J|-1} * x^{|J|} / (1 - x^{|J|})  ? 
    # No, let me reconsider.
    
    # The equation is F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1-yq^|J|)
    # 
    # If we set y = x (a formal variable tracking the max-part level), then:
    # F_c(x) = sum_J (-1)^{|J|-1} / (1-xq^|J|) * F_{c(J)}(xq^|J|)
    #
    # For the TRANSFER MATRIX for bounded CPs (max <= n), we look at the n-th level:
    # g_n(c) = F_{c,n} - F_{c,n-1} = number of CPs with max exactly n.
    # The recurrence for g_n involves a matrix multiplication.
    
    # Actually, Agent B derived: F_{c,n} = prod_{k=1}^n (I-A(q^k))^{-1} * v_0
    # where A(x) encodes the CW shifts.
    
    # Let me build A(x) explicitly. For each profile c:
    # The CW recurrence says (rewriting):
    # F_c(y,q) * (something) = sum of F_{c'} terms
    # 
    # More precisely, A(x)[c, c'] = sum over J s.t. c(J) = c' of (-1)^{|J|-1} * x^{|J|}
    
    # This is the "bare" transfer matrix without the (1-x) denominators.
    # Let me try this and check if det(I - A(x)) = -(x^3 - 1).
    
    A = matrix(R, N, N)
    for i, c in enumerate(profs):
        ic = I_c(c)
        # Generate all nonempty subsets of I_c
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    j = prof_idx[cp]
                    A[i, j] += (-1)**(size-1) * x**size
    
    return A, profs, prof_idx

# Build for d=7
print("Building transfer matrix for d=7...")
A, profs, prof_idx = build_transfer_matrix(7)
N = len(profs)
print(f"Matrix size: {N}x{N}")
print(f"Number of profiles: {N}")

# Check det(I - A(x))
R = A.base_ring()
x = R.gen()
I_mat = matrix(R, N, N, lambda i,j: 1 if i==j else 0)
M = I_mat - A

print("\nComputing determinant of (I - A(x))...")
det_val = M.determinant()
print(f"det(I - A(x)) = {det_val}")
print(f"Expected: -(x^3 - 1) = {-(x^3 - 1)}")
print(f"Match: {det_val == -(x^3 - 1)}")
