"""
Seed 7 Layer 3: Level-rank dual approach.

Instead of hat{sl}_3 at level d, try hat{sl}_t at level 3
where t = d + 3 (the circumference of the cylinder).

For d=4: t=7, so try A_6^(1) at level 3.
The highest weight should be 3*Lambda_0 (or similar).

Level-rank duality: Characters of hat{sl}_k at level d
are related to characters of hat{sl}_t at level k (with k=3 here).
"""
from sage.all import *

R = PolynomialRing(ZZ, 'q')
q = R.gen()

# ======================================================================
# d=4: hat{sl}_7 (A_6^(1)) at level 3
# ======================================================================
print("="*70)
print("Level-rank dual: A_6^(1) at level 3")
print("d=4, t=7, k=3")
print("="*70)

ct7 = CartanType(['A', 6, 1])
WS7 = RootSystem(ct7).weight_space(extended=True)
Lambda7 = WS7.fundamental_weights()
alpha7 = WS7.simple_roots()

# At level 3: highest weight should have c_0 + ... + c_6 = 3.
# The profile c = (2,1,1) for k=3, d=4 needs to be mapped to
# a highest weight of A_6^(1) at level 3.

# Under level-rank duality, a level-d weight of hat{sl}_3
# (with labels summing to d) maps to a level-3 weight of hat{sl}_t.
# The mapping goes through partitions/Young diagrams.

# For hat{sl}_3 at level d=4 with weight (c_0, c_1, c_2) = (2,1,1):
# The corresponding weight for hat{sl}_7 at level 3:
# We need to find the dual partition.

# The level-rank duality maps:
# hat{sl}_k level d <-> hat{sl}_d+k level k
# Wait, that doesn't look right either. Let me be precise.

# From Tsuchioka/Nakanishi-Tsuchiya:
# The affine Lie algebra hat{sl}_k at level ell has
# representations indexed by level-ell dominant weights.
# Under level-rank duality between hat{sl}_k at level ell
# and hat{sl}_ell at level k, the representations are related
# through transposition of Young diagrams.

# For k=3, ell=d: hat{sl}_3 level d <-> hat{sl}_d level 3
# But wait, the cylinder has circumference t = d + k.
# The right dual might be hat{sl}_t level... hmm.

# Actually, the correct statement from the literature:
# Cylindric partitions of profile c with k parts and sum d
# are in bijection with elements of a crystal of
# hat{sl}_t at level ??? (where t = d + k).

# I think the correct duality is:
# B^{k,d}_c (cylindric partitions) <-> crystal of hat{sl}_k at level d
# The dual statement: exchange rows and columns of the cylindric partition
# gives hat{sl}_d at level k. (When gcd(k,d)=1.)

# For d=4, k=3: hat{sl}_3 at level 4 <-> hat{sl}_4 at level 3.
# So try A_3^(1) at level 3.

print("\n--- Trying A_3^(1) at level 3 ---")
ct4 = CartanType(['A', 3, 1])
WS4 = RootSystem(ct4).weight_space(extended=True)
Lambda4 = WS4.fundamental_weights()
alpha4 = WS4.simple_roots()

# Level 3: highest weight with sum of labels = 3.
# Options: 3*L0, 2*L0+L1, L0+L1+L2, etc.
# The profile c=(2,1,1) of hat{sl}_3 at level 4 dualizes to what?

# Under level-rank duality, the weight Lambda = sum c_i Lambda_i of hat{sl}_3
# maps to a weight of hat{sl}_4 determined by the "complement" partition.

# For hat{sl}_3 at level 4: weight (c_0,c_1,c_2) = (2,1,1)
# Associated partition: from c = (2,1,1) build a partition with at most 3-1=2 rows
# and at most 4 columns. The dual partition has at most 4-1=3 rows.
# Then the dual weight of hat{sl}_4 has labels determined by this transposed partition.

# Actually, the level-rank duality for cylindric partitions is more subtle.
# Let me just try various level-3 weights of A_3^(1) computationally.

def extract_grade_general(wt, hw_wt, ct_local):
    """Extract principal grade for general type."""
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    
    n = ct_local.rank()  # number of nodes in Dynkin diagram
    WS_local = RootSystem(ct_local).weight_space(extended=True)
    alpha_local = WS_local.simple_roots()
    
    # For A_{n-1}^(1), delta = sum alpha_i
    # The principal grade is sum n_i where diff = sum n_i alpha_i
    
    # We need to solve for n_i. Use the pairing with fundamental coweights.
    # <Lambda_i, alpha_j^vee> = delta_{ij}
    
    # Actually for the weight space, monomial_coefficients gives the
    # Lambda-basis coefficients. The delta coefficient gives n_0 directly.
    
    d_delta = coeffs.get('delta', 0)
    d_vals = [coeffs.get(i, 0) for i in range(n)]
    
    # For A_{n-1}^(1), the Cartan matrix is cyclic.
    # Solving is complex. Let me just use the principal grade formula:
    # diff expressed in Lambda_i basis: diff = sum d_i Lambda_i + d_delta * delta
    # alpha_j = -Lambda_{j-1} + 2*Lambda_j - Lambda_{j+1} (mod n) + delta_{j,0}*delta
    # So diff = sum n_j alpha_j gives:
    # d_delta = n_0 (from the delta coefficient)
    # d_i = -n_{i+1} + 2*n_i - n_{i-1} (finite Cartan matrix entries, cyclic)
    # Sum of d_i = 0 (consistent with affine)
    # Principal grade = sum n_j
    
    # For simplicity, use n_0 = d_delta, then solve for others using Cartan matrix.
    # For general A_{n-1}^(1), this is a cyclic tridiagonal system.
    
    # Let me use a direct approach: compute n_0 from delta, then
    # use the relation d_i + d_{i-1}... it's complex.
    # Just compute the total grade using the formula:
    # principal grade = <diff, sum_i Lambda_i^vee> / ... 
    
    # Actually, the simplest: for A_{n-1}^(1), all marks a_i = 1.
    # The principal grade is deg = sum n_i.
    # We know: sum d_i = 0, d_delta = n_0.
    # And: 2*n_i - n_{i-1} - n_{i+1} = d_i + delta_{i,0}*d_delta
    #   (since alpha_0 = 2L_0 - L_1 - L_{n-1} + delta for A_{n-1}^(1))
    
    # Sum the relation: sum (2*n_i - n_{i-1} - n_{i+1}) = sum d_i + d_delta = d_delta
    # LHS = 0 (telescoping on a cycle). So d_delta = 0... that can't be right.
    
    # Let me just compute it numerically for the specific case.
    # For A_3^(1): indices 0,1,2,3. n_0 = d_delta.
    # 2*n_0 - n_3 - n_1 = d_0 + d_delta (alpha_0 has +delta)
    # Actually: alpha_0 = 2*L_0 - L_1 - L_3 + delta
    #           alpha_1 = -L_0 + 2*L_1 - L_2
    #           alpha_2 = -L_1 + 2*L_2 - L_3
    #           alpha_3 = -L_2 + 2*L_3 - L_0
    
    # From diff = n_0*a_0 + n_1*a_1 + n_2*a_2 + n_3*a_3:
    # L_0 coeff: 2*n_0 - n_1 - n_3 = d_0 (since alpha_0 has +delta, d_delta included)
    # Actually no: alpha_0 = 2*L_0 - L_1 - L_3 + delta
    # L_0 coeff of diff: 2*n_0 - n_1 - n_3 = d_0 (Lambda_0 coefficient)
    # L_1 coeff: -n_0 + 2*n_1 - n_2 = d_1
    # L_2 coeff: -n_1 + 2*n_2 - n_3 = d_2
    # L_3 coeff: -n_0 - n_2 + 2*n_3 = d_3
    # delta coeff: n_0 = d_delta
    
    # So n_0 = d_delta. Then from L_0: -n_1 - n_3 = d_0 - 2*d_delta.
    # From L_1: -d_delta + 2*n_1 - n_2 = d_1. So 2*n_1 - n_2 = d_1 + d_delta.
    # From L_2: -n_1 + 2*n_2 - n_3 = d_2.
    # From L_3: -d_delta - n_2 + 2*n_3 = d_3. So -n_2 + 2*n_3 = d_3 + d_delta.
    
    # Sum of last three: 2*n_1 - n_2 - n_1 + 2*n_2 - n_3 - n_2 + 2*n_3
    #   = n_1 + n_3 = (d_1 + d_delta) + d_2 + (d_3 + d_delta)
    #   = d_1 + d_2 + d_3 + 2*d_delta
    # And n_1 + n_3 = -(d_0 - 2*d_delta) = -d_0 + 2*d_delta
    # So: -d_0 + 2*d_delta = d_1 + d_2 + d_3 + 2*d_delta
    # => -d_0 = d_1 + d_2 + d_3 => d_0 + d_1 + d_2 + d_3 = 0. ✓ (level matching)
    
    # Solve: n_0 = d_delta, n_1 + n_3 = -d_0 + 2*d_delta
    # From 2*n_1 - n_2 = d_1 + d_delta and -n_1 + 2*n_2 - n_3 = d_2:
    # n_2 = 2*n_1 - d_1 - d_delta
    # -n_1 + 2*(2*n_1 - d_1 - d_delta) - n_3 = d_2
    # 3*n_1 - 2*d_1 - 2*d_delta - n_3 = d_2
    # n_3 = 3*n_1 - 2*d_1 - 2*d_delta - d_2
    # And n_1 + n_3 = -d_0 + 2*d_delta:
    # n_1 + 3*n_1 - 2*d_1 - 2*d_delta - d_2 = -d_0 + 2*d_delta
    # 4*n_1 = -d_0 + 4*d_delta + 2*d_1 + d_2
    # n_1 = (-d_0 + 4*d_delta + 2*d_1 + d_2) / 4
    
    if n == 4:  # A_3^(1)
        n_0 = d_delta
        n_1_num = -d_vals[0] + 4*d_delta + 2*d_vals[1] + d_vals[2]
        if n_1_num % 4 != 0:
            return None  # Not expressible
        n_1 = n_1_num // 4
        n_2 = 2*n_1 - d_vals[1] - d_delta
        n_3 = 3*n_1 - 2*d_vals[1] - 2*d_delta - d_vals[2]
        grade = n_0 + n_1 + n_2 + n_3
        return grade
    
    # For general case, just return None
    return None


def demazure_set_gen(crystal, word):
    hw = crystal.module_generators[0]
    current = set([hw])
    for i in reversed(word):
        new_set = set()
        for b in current:
            x = b
            while x is not None:
                new_set.add(x)
                x = x.f(i)
        current = new_set
    return current


def demazure_char_gen(crystal, word, hw_wt, ct_local):
    D = demazure_set_gen(crystal, word)
    char = R(0)
    for b in D:
        grade = extract_grade_general(b.weight(), hw_wt, ct_local)
        if grade is None or grade < 0:
            return None
        char += q**grade
    return char


# Test: A_3^(1) at level 3 with weight 3*L_0
print("\n--- A_3^(1), B(3*L_0) ---")
hw_test = 3*Lambda4[0]
C_test = crystals.LSPaths(ct4, hw_test)

for name, word in [
    ('e', []),
    ('s0', [0]),
    ('s1', [1]),
    ('s0s1', [0,1]),
    ('s1s0', [1,0]),
    ('s3s2s1', [3,2,1]),
    ('s0s1s2', [0,1,2]),
    ('s3s2s1s0', [3,2,1,0]),
    ('s0s1s2s3', [0,1,2,3]),
]:
    char = demazure_char_gen(C_test, word, hw_test, ct4)
    if char is not None:
        print(f"  D_{name} = {char}  [sum={char(1)}]")
    else:
        print(f"  D_{name}: grade extraction failed")


# Also try weight L_0 + L_1 + L_2 (another level-3 weight)
print("\n--- A_3^(1), B(L_0 + L_1 + L_2) ---")
hw_test2 = Lambda4[0] + Lambda4[1] + Lambda4[2]
C_test2 = crystals.LSPaths(ct4, hw_test2)

for name, word in [
    ('e', []),
    ('s0', [0]),
    ('s1', [1]),
    ('s3', [3]),
    ('s3s0', [3,0]),
    ('s1s0', [1,0]),
    ('s2s1', [2,1]),
    ('s3s2', [3,2]),
    ('s0s1', [0,1]),
    ('s3s2s1', [3,2,1]),
    ('s0s1s2', [0,1,2]),
    ('s3s0s1', [3,0,1]),
]:
    char = demazure_char_gen(C_test2, word, hw_test2, ct4)
    if char is not None:
        print(f"  D_{name} = {char}  [sum={char(1)}]")
    else:
        print(f"  D_{name}: grade extraction failed")


# For level-rank duality, the correct weight of hat{sl}_4 at level 3
# corresponding to profile c=(2,1,1) of hat{sl}_3 at level 4:
# We need the dual of the partition associated to (2,1,1).
# Weight (2,1,1) of hat{sl}_3: this labels a level-4 weight.
# The partition associated: from c = (c_0, c_1, c_2) = (2,1,1),
# the partition lambda has rows determined by c_1, c_2 (dropping c_0).
# lambda = (c_1, c_2) = (1, 1) = (1,1). Transpose: (2) = (2).
# Then the dual weight of hat{sl}_4 at level 3:
# lambda^t = (2), so (d_1, d_2, d_3) could be (2, 0, 0) and d_0 = 3 - 2 = 1.
# Weight: L_0 + 2*L_1.

print("\n--- A_3^(1), B(L_0 + 2*L_1) -- level-rank dual of (2,1,1)? ---")
hw_dual = Lambda4[0] + 2*Lambda4[1]
C_dual = crystals.LSPaths(ct4, hw_dual)

for name, word in [
    ('e', []),
    ('s0', [0]),
    ('s1', [1]),
    ('s3', [3]),
    ('s3s0', [3,0]),
    ('s3s2', [3,2]),
    ('s1s0', [1,0]),
    ('s0s3', [0,3]),
    ('s3s2s1', [3,2,1]),
    ('s0s3s2', [0,3,2]),
    ('s3s2s1s0', [3,2,1,0]),
]:
    char = demazure_char_gen(C_dual, word, hw_dual, ct4)
    if char is not None:
        print(f"  D_{name} = {char}  [sum={char(1)}]")
    else:
        print(f"  D_{name}: grade extraction failed")

