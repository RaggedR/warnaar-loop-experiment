"""
Seed 7 Layer 3: Focus on Demazure crystal computation.
Explore what SageMath provides for affine Demazure characters.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()

print("="*70)
print("EXPLORING SAGEMATH DEMAZURE TOOLS")
print("="*70)

# 1. Check if there's a Demazure character formula built-in
print("\n--- Available crystal types ---")
print([x for x in dir(crystals) if 'dem' in x.lower() or 'Dem' in x])
print([x for x in dir(crystals) if 'key' in x.lower() or 'Key' in x])

# 2. Check WeylCharacterRing for affine types
try:
    WCR = WeylCharacterRing(ct)
    print(f"\nWeylCharacterRing for A_2^(1): {WCR}")
except Exception as e:
    print(f"\nWeylCharacterRing for affine type: {e}")

# Try finite type first
print("\n--- Finite type A_2 Demazure characters ---")
ct_fin = CartanType(['A', 2])
WCR_fin = WeylCharacterRing(ct_fin, style='coroots')
print(f"WeylCharacterRing for A_2: {WCR_fin}")

# Demazure characters for A_2
# The key polynomial K_w(x_1, x_2, x_3) for a weight is the Demazure character.
# In SageMath, this is computed via the crystal.

# Create a finite crystal
C_fin = crystals.Tableaux(['A', 2], shape=[2, 1])
print(f"Crystal B(2,1) for A_2: {C_fin}")
print(f"Size: {C_fin.cardinality()}")

# Demazure operator on characters
W_fin = WeylGroup(ct_fin, prefix='s')
s_fin = W_fin.simple_reflections()
print(f"s1 = {s_fin[1]}, s2 = {s_fin[2]}")

# The Demazure operator D_i acts on characters
# D_i(e^mu) = (e^mu - e^{s_i(mu) - alpha_i}) / (1 - e^{-alpha_i})
# This is the "isobaric divided difference" or pi_i operator.

# 3. Back to affine: compute Demazure subcrystals manually
print("\n" + "="*70)
print("DEMAZURE SUBCRYSTALS OF B(Lambda_0) FOR A_2^(1)")
print("="*70)

# Start with the simplest case: the basic representation B(Lambda_0)
# which has level 1 (d=1... wait, d=1 is not interesting for us).
# Actually for d=1, k=3, t=4, the base would be (2)(3)/6-1 = 0,
# so Q_n(1) = 0^n. Not useful.

# Let's work with B(2*Lambda_0) for d=2, k=3, t=5.
print("\n--- B(2*Lambda_0) ---")
C = crystals.LSPaths(ct, 2*Lambda[0])
hw = C.module_generators[0]

# Build Demazure subcrystals and compute their "energy" characters
def demazure_set(crystal, word):
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

# For the grading, I need the "energy" or "depth" of each crystal element.
# In the LS path crystal, the weight gives the affine weight.
# The depth is the number of times we've descended in the null root direction.

# For a weight mu = hw - sum n_i alpha_i, the "affine depth" involves
# the coefficient of alpha_0.

# Key insight: For the PRINCIPAL grading, each alpha_i has grade 1.
# So the principal grade of hw - mu is sum n_i.
# But this gives the total depth, and for Q_{n,c}(q) we need the
# SIZE of the cylindric partition as the q-weight.

# For cylindric partitions, the weight |Lambda| corresponds to:
# |Lambda| = <hw - mu, rho^vee> where rho^vee = sum of fundamental coweights
# or something similar.

# Actually, let me think about this differently.
# The principally specialized character is obtained by setting
# e^{-alpha_i} = q for all i. This means:
# e^mu = e^{hw} * q^{sum n_i} if mu = hw - sum n_i alpha_i
# So the principal specialization of the character is:
# ch_q = sum_{mu in weights} mult(mu) * q^{<hw-mu, sum_i Lambda_i^vee>}
# But in the principal specialization, we just use q^{grade} where grade = sum n_i.

# Let me compute the weight of each crystal element and extract the grade.

def weight_to_principal_grade(wt, hw_wt):
    """
    For A_2^(1), compute the principal grade of wt relative to hw_wt.
    The principal grade is the total coefficient when expressing hw_wt - wt
    in terms of simple roots.
    
    wt and hw_wt are in the extended weight space.
    diff = hw_wt - wt should be a non-negative combination of alpha_0, alpha_1, alpha_2.
    """
    diff = hw_wt - wt
    
    # Express diff in terms of alpha_0, alpha_1, alpha_2
    # Using the fact that <alpha_i, alpha_j^vee> = A_{ij} (Cartan matrix)
    # and <Lambda_i, alpha_j^vee> = delta_{ij}
    # So <diff, alpha_j^vee> = sum_i n_i A_{ij}
    
    # For A_2^(1), the Cartan matrix is:
    # [[2, -1, -1], [-1, 2, -1], [-1, -1, 2]]
    # (with the convention for the affine type)
    
    # Compute <diff, alpha_i^vee> for i = 0, 1, 2
    coroots = RootSystem(ct).coroot_space()
    
    # Actually, in SageMath we can use the pairing directly
    # But diff is in the weight space and we need to pair with coroots
    
    # The weight space has a method scalar for this
    a0v = WS.simple_coroots()[0]
    a1v = WS.simple_coroots()[1]
    a2v = WS.simple_coroots()[2]
    
    d0 = diff.scalar(a0v)
    d1 = diff.scalar(a1v)
    d2 = diff.scalar(a2v)
    
    # Now solve: n_0 * A[0] + n_1 * A[1] + n_2 * A[2] = [d0, d1, d2]
    # where A[i] is the i-th row of the Cartan matrix
    # A = [[2,-1,-1],[-1,2,-1],[-1,-1,2]]
    # Solve: 2n0 - n1 - n2 = d0, -n0 + 2n1 - n2 = d1, -n0 - n1 + 2n2 = d2
    # Sum: 0 = d0 + d1 + d2 (should be 0 for affine weights at the same level)
    # The inverse of the finite part...
    
    # For A_2^(1), the Cartan matrix has rank 2 (null vector is (1,1,1)).
    # So we can't uniquely solve for n_0, n_1, n_2 from the inner products alone.
    # But we know n_i >= 0 and the grade is n_0 + n_1 + n_2.
    
    # Using the relation: from the sum d0 + d1 + d2 = 0,
    # and 2n0 - n1 - n2 = d0 => 2n0 - (n_total - n0) = d0 => 3n0 = d0 + n_total
    # Similarly 3n1 = d1 + n_total, 3n2 = d2 + n_total.
    # So n_total = 3n0 - d0 = 3n1 - d1 = 3n2 - d2
    # We need n0 = (d0 + n_total)/3 >= 0 => n_total >= -d0
    # Similarly for n1, n2.
    
    # But we have a free parameter (n_total itself). This is because 
    # the null root delta = alpha_0 + alpha_1 + alpha_2 is in the radical.
    # The weights are only determined up to multiples of delta.
    
    # For LS paths, the weight should be well-defined including the delta component.
    # Let me check if the weight includes the delta part.
    
    # In the extended weight space, weights include a delta component.
    # The "level" is well-defined, and the "grade" should be extractable.
    
    # Let me try: diff should be expressible uniquely as
    # diff = n_0*alpha_0 + n_1*alpha_1 + n_2*alpha_2
    # where the alpha_i include the delta component.
    
    # Actually, in the EXTENDED weight space, there are 4 basis elements:
    # Lambda_0, Lambda_1, Lambda_2, and delta (or the derivation d).
    # The weight space is 4-dimensional, but {alpha_0, alpha_1, alpha_2} span
    # only a 3-dimensional subspace (since delta = alpha_0 + alpha_1 + alpha_2).
    # So there IS a unique decomposition.
    
    # Hmm, actually {alpha_0, alpha_1, alpha_2} span 3 dimensions out of 4.
    # So diff = sum n_i alpha_i + constant * (something orthogonal).
    # But for crystal paths, diff should be exactly a sum of simple roots.
    
    # Let me try the direct approach: just compute the delta coefficient of diff.
    # diff = sum n_i alpha_i
    # The delta coefficient is: delta appears as alpha_0 + alpha_1 + alpha_2 in the
    # simple root decomposition. So if diff = n_0 alpha_0 + n_1 alpha_1 + n_2 alpha_2,
    # the "number of deltas" is min(n_0, n_1, n_2), and the principal grade is n_0+n_1+n_2.
    
    # Let me try using the monomial_coefficients method
    try:
        coeffs = diff.monomial_coefficients()
        # print(f"  diff coeffs: {coeffs}")
        # For the weight space, the keys might be Lambda indices or alpha indices
        return coeffs
    except:
        return str(diff)


# Test with a few elements
print("\nFirst 20 crystal elements and their weights:")
count = 0
for b in C:
    wt = b.weight()
    diff = 2*Lambda[0] - wt
    coeffs = diff.monomial_coefficients()
    grade_info = weight_to_principal_grade(wt, 2*Lambda[0])
    if count < 20:
        print(f"  wt = {wt}, diff = {diff}, coeffs = {coeffs}")
    count += 1
    if count > 200:
        break

# Let me try to understand the weight space basis better
print(f"\nalpha_0 = {alpha[0]}")
print(f"alpha_0 coeffs = {alpha[0].monomial_coefficients()}")
print(f"alpha_1 = {alpha[1]}")  
print(f"alpha_1 coeffs = {alpha[1].monomial_coefficients()}")
print(f"alpha_2 = {alpha[2]}")
print(f"alpha_2 coeffs = {alpha[2].monomial_coefficients()}")
print(f"delta = {delta}")
print(f"delta coeffs = {delta.monomial_coefficients()}")

# So the weight space has generators indexed by 0, 1, 2 (= Lambda_0, Lambda_1, Lambda_2)
# and possibly 'delta'.
# alpha_0 = 2*Lambda_0 - Lambda_1 - Lambda_2 + delta
# So in coefficients: {0: 2, 1: -1, 2: -1, 'delta': 1} (or similar)

