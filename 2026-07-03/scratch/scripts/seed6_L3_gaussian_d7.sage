"""
Seed 6, Layer 3: Uncu-style Gaussian elimination for d=7.
Use SageMath's matrix tools over QQ(q) to set up and solve the CW system.
"""

from sage.all import *

# The CW recurrence: F_c(y,q) = sum_{J subset I_c, J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
# Where I_c = {i : c_i > 0} and c(J) is the shifted profile.

def shifted_profile(c, J):
    """
    Compute the shifted profile c(J).
    c = (c_0, ..., c_{k-1}), J subset of I_c = {i : c_i > 0}.
    
    c_i(J) = c_i - 1  if i in J and (i-1) mod k not in J
    c_i(J) = c_i + 1  if i not in J and (i-1) mod k in J
    c_i(J) = c_i      otherwise
    """
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

def get_Ic(c):
    """Return the set of indices where c_i > 0."""
    return frozenset(i for i in range(len(c)) if c[i] > 0)

def all_nonempty_subsets(S):
    """Generate all nonempty subsets of S."""
    S = list(S)
    n = len(S)
    for mask in range(1, 1 << n):
        yield frozenset(S[j] for j in range(n) if mask & (1 << j))

def build_cw_system(d, k=3):
    """
    Build the CW linear system for the bounded generating functions.
    
    The CW recurrence for F_{c,n} (coefficient of y^n in F_c(y,q)):
    
    F_{c,n}(q) = sum_{J} (-1)^{|J|-1} * sum_{m=0}^{n} q^{|J|*m} * F_{c(J),n-m}(q)
                 -- NO WAIT, let me be more careful.
    
    Actually, the CW recurrence at the level of the bounded GF:
    
    F_{c}(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1 - yq^{|J|})
    
    Taking [y^n]:
    F_{c,n} = sum_J (-1)^{|J|-1} sum_{m=0}^{n} q^{|J|*m} [y^{n-m}] F_{c(J)}(yq^{|J|}, q)
    
    Actually, if we define G_c(y) = F_c(y,q) (suppressing q), then
    G_c(y) = sum_J (-1)^{|J|-1} G_{c(J)}(yq^{|J|}) / (1 - yq^{|J|})
    
    and [y^n] G_c(y) = F_{c,n}(q).
    
    [y^n] of G_{c(J)}(yq^{|J|}) / (1 - yq^{|J|}) 
      = sum_{m=0}^{n} q^{|J|*m} * [y^{n-m}] G_{c(J)}(yq^{|J|})
      = sum_{m=0}^{n} q^{|J|*m} * q^{|J|*(n-m)} * F_{c(J),n-m}
      
    Wait, [y^j] G_{c(J)}(yq^s) = q^{sj} F_{c(J),j}. So:
    
    [y^n] G_{c(J)}(yq^s) / (1-yq^s) = sum_{m=0}^n q^{sm} * q^{s(n-m)} * F_{c(J),n-m}
    
    Hmm, that doesn't look right. Let me redo:
    
    H(y) = G(yq^s)/(1-yq^s), where s = |J|.
    
    [y^n] H(y) = sum_{m=0}^n [y^m](1/(1-yq^s)) * [y^{n-m}] G(yq^s)
               = sum_{m=0}^n q^{sm} * q^{s(n-m)} F_{c(J),n-m}
               = q^{sn} sum_{m=0}^n F_{c(J),n-m}
    
    Wait: [y^m] 1/(1-yq^s) = q^{sm}. And [y^j] G(yq^s) = q^{sj} F_{c(J),j}.
    
    So [y^n] H(y) = sum_{j=0}^n q^{s(n-j)} q^{sj} F_{c(J),j} = sum_{j=0}^n q^{sn} F_{c(J),j}
    
    Hmm, that gives q^{sn} * sum_{j=0}^n F_{c(J),j}. That doesn't look right either.
    
    Let me be even more careful:
    [y^n] H(y) = [y^n] sum_{m >= 0} (yq^s)^m * G(yq^s)
               = sum_{m >= 0} [y^{n-m}] (yq^s)^m G(yq^s)
    
    No wait, 1/(1-yq^s) = sum_{m >= 0} y^m q^{sm}.
    
    [y^n] (sum_{m >= 0} y^m q^{sm}) * G(yq^s) 
    = sum_{m=0}^n q^{sm} * [y^{n-m}] G(yq^s)
    = sum_{m=0}^n q^{sm} * q^{s(n-m)} * [y^{n-m}] G(y)   -- NO!
    
    [y^j] G(yq^s) = [y^j] sum_i F_{c(J),i} (yq^s)^i = q^{sj} F_{c(J),j}
    
    So [y^n] H = sum_{m=0}^n q^{sm} * q^{s(n-m)} F_{c(J),n-m}
               = q^{sn} sum_{m=0}^n F_{c(J),n-m}
               = q^{sn} sum_{j=0}^n F_{c(J),j}
    
    This is: [y^n] H(y) = q^{sn} * (F_{c(J),0} + F_{c(J),1} + ... + F_{c(J),n})
    
    Since F_{c,0} = 1 for all c.
    
    So the CW recurrence becomes:
    F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} sum_{j=0}^n F_{c(J),j}
    """
    # Actually, let me just use the simpler layer-by-layer form.
    # From the synthesis: (I - A(q^n)) F_n = F_{n-1}
    # where A(x) has entries encoding the CW shifts.
    
    # Let me instead just compute F_{c,n} for all profiles at d=7 via the recurrence.
    # I'll implement this directly.
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            compositions.append((c0, c1, c2))
    
    comp_idx = {c: i for i, c in enumerate(compositions)}
    N = len(compositions)
    
    print(f"d={d}: {N} compositions")
    
    # Build the matrix A(x) over QQ[x]
    # From the CW recurrence: F_{c,n} = F_{c,n-1} + sum_J (-1)^{|J|-1} x^{|J|} F_{c(J),n}
    # where x = q^n. Wait, this isn't quite right either.
    
    # Actually, from Layer 2 scratch: (I - A(q^n)) F_n = F_{n-1}
    # So A_{c, c'} encodes the CW coupling.
    
    # Let me re-derive from the CW functional equation.
    # The CW recurrence for y-indexed GFs:
    #   F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1-yq^{|J|})
    # 
    # For bounded GFs: F_c(y,q) = sum_n F_{c,n}(q) y^n, F_{c,0} = 1.
    #
    # Substituting y -> yq^s in GF: F_{c(J)}(yq^s, q) = sum_n F_{c(J),n} y^n q^{sn}
    # 
    # So [y^n] of F_{c(J)}(yq^s)/(1-yq^s):
    # = sum_{m=0}^n (q^s)^m * q^{s(n-m)} F_{c(J),n-m}
    # = q^{sn} sum_{j=0}^n F_{c(J),j}
    
    # Therefore:
    # F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} sum_{j=0}^n F_{c(J),j}
    
    # Writing S_{c,n} = sum_{j=0}^n F_{c,j}:
    # F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} S_{c(J),n}
    # S_{c,n} = S_{c,n-1} + F_{c,n}
    
    # So: F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} (S_{c(J),n-1} + F_{c(J),n})
    # Rearranging:
    # F_{c,n} - sum_J (-1)^{|J|-1} q^{|J|n} F_{c(J),n} = sum_J (-1)^{|J|-1} q^{|J|n} S_{c(J),n-1}
    
    # This is a LINEAR SYSTEM in the unknowns {F_{c,n}} with coefficients in Q[q]
    # (for fixed n, treating q^n as a single parameter x).
    
    # The RHS involves S_{c(J),n-1} which are known from the previous step.
    
    # Let x = q^n. The system is:
    # (I - A(x)) F_n = b(x, S_{n-1})
    
    # where A(x)_{c, c'} = sum over J such that c(J) = c' of (-1)^{|J|-1} x^{|J|}
    
    # Actually wait. The CW shift c(J) maps c to some c'. Multiple J's can map
    # c to the same c'. Let me compute this.
    
    return compositions, comp_idx

def compute_A_matrix(compositions, comp_idx, d):
    """
    Compute the matrix A(x) where (I - A(x))F_n = RHS.
    
    A_{c, c'} = sum_{J : c(J) = c'} (-1)^{|J|-1} x^{|J|}
    """
    R = PolynomialRing(QQ, 'x')
    x = R.gen()
    
    N = len(compositions)
    A = matrix(R, N, N)
    
    for i, c in enumerate(compositions):
        Ic = get_Ic(c)
        if not Ic:  # no positive entries
            continue
        for J in all_nonempty_subsets(Ic):
            cp = shifted_profile(c, J)
            if cp in comp_idx:
                j = comp_idx[cp]
                s = len(J)
                sign = (-1)**(s - 1)
                A[i, j] += sign * x**s
    
    return A

# =========================================================
# Build and analyze the CW system for d=7
# =========================================================

print("Building CW system for d=7...")
compositions, comp_idx = build_cw_system(7)
A = compute_A_matrix(compositions, comp_idx, 7)

print(f"Matrix A(x) is {A.nrows()} x {A.ncols()}")
print(f"Number of nonzero entries: {sum(1 for i in range(A.nrows()) for j in range(A.ncols()) if A[i,j] != 0)}")

# Compute (I - A(x)) and try Gaussian elimination
R = A.base_ring()
x = R.gen()
N = A.nrows()
I_mat = matrix.identity(R, N)
M = I_mat - A

print("\nAttempting symbolic Gaussian elimination...")
print("(This may take a while for 36x36 over QQ[x])")

# Convert to fraction field for exact elimination
F = FractionField(R)
M_frac = M.change_ring(F)

try:
    # Compute the inverse (I - A)^{-1}
    # This is the transfer matrix: F_n = (I-A(q^n))^{-1} * b_n
    
    # First, let's just compute the determinant
    det_M = M.determinant()
    print(f"\ndet(I - A(x)) = {det_M}")
    print(f"  Degree: {det_M.degree()}")
    print(f"  Factored: attempting factorization...")
    det_factored = det_M.factor()
    print(f"  Factored: {det_factored}")
except Exception as e:
    print(f"  Error: {e}")

# Try a smaller case first: d=4
print("\n" + "=" * 60)
print("CW system for d=4 (15x15)")
print("=" * 60)

compositions4, comp_idx4 = build_cw_system(4)
A4 = compute_A_matrix(compositions4, comp_idx4, 4)

R4 = A4.base_ring()
x4 = R4.gen()
N4 = A4.nrows()
I4 = matrix.identity(R4, N4)
M4 = I4 - A4

det_M4 = M4.determinant()
print(f"\ndet(I - A(x)) for d=4: degree {det_M4.degree()}")
det_M4_factored = det_M4.factor()
print(f"Factored: {det_M4_factored}")

# And d=2
print("\n" + "=" * 60)
print("CW system for d=2 (6x6)")
print("=" * 60)

compositions2, comp_idx2 = build_cw_system(2)
A2 = compute_A_matrix(compositions2, comp_idx2, 2)

R2 = A2.base_ring()
x2 = R2.gen()
N2 = A2.nrows()
I2 = matrix.identity(R2, N2)
M2 = I2 - A2

det_M2 = M2.determinant()
print(f"\ndet(I - A(x)) for d=2: degree {det_M2.degree()}")
det_M2_factored = det_M2.factor()
print(f"Factored: {det_M2_factored}")

# Now extract the specific row for the target profile
# For d=2, profile (1,1,0):
print("\n--- Solving for F_{(1,1,0),n} at d=2 ---")
c_target = (1, 1, 0)
idx_target = comp_idx2[c_target]

# The RHS for n=1: b = S_{n-1} terms
# S_{c,0} = F_{c,0} = 1 for all c
# b_c = sum_J (-1)^{|J|-1} x^{|J|} S_{c(J),0} = sum_J (-1)^{|J|-1} x^{|J|}
# = sum_J (-1)^{|J|-1} x^{|J|} * 1

# For general n: b_c(n) = sum_J (-1)^{|J|-1} q^{|J|n} S_{c(J),n-1}
# At n=1: b_c = sum_J (-1)^{|J|-1} x^{|J|} (since S_{c(J),0} = 1)

# Compute b for n=1 (S_{c,0} = 1 for all c)
b_vec = vector(R2, N2)
for i, c in enumerate(compositions2):
    Ic = get_Ic(c)
    if not Ic:
        continue
    for J in all_nonempty_subsets(Ic):
        s = len(J)
        sign = (-1)**(s - 1)
        b_vec[i] += sign * x2**s

print(f"b vector for n=1: {b_vec}")

# Solve M2 * F1 = b (where F1 is the vector of F_{c,1})
M2_frac = M2.change_ring(FractionField(R2))
b_frac = b_vec.change_ring(FractionField(R2))
F1 = M2_frac.solve_right(b_frac)
print(f"\nF_{{c,1}} for all profiles at d=2:")
for i, c in enumerate(compositions2):
    print(f"  F_{{({c[0]},{c[1]},{c[2]}),1}} = {F1[i]}")

