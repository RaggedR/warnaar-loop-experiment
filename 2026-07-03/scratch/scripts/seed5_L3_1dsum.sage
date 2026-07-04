"""
Seed 5, Layer 3: One-dimensional configuration sum approach.

Key insight: B^{1,7} has dim 36 = # profiles for d=7.
This is NOT a coincidence -- B^{r,s} for type A_2^(1) has dim = binom(s+2, 2).
For s=7: binom(9,2) = 36. These are compositions of 7 into 3 nonneg parts.

The one-dimensional configuration sum for tensor products of KR crystals
should give the principally specialized character.

For cylindric partitions with max <= n, we might need
B^{1,c_0} tensor B^{1,c_1} tensor B^{1,c_2}... but that doesn't seem right.
Or maybe tensor(B^{1,7}, n times)?

Let me explore: what is the 1dsum of B^{1,7}^{tensor n}?
"""

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

# First, understand B^{1,7} for A_2^(1)
B = crystals.KirillovReshetikhin(['A',2,1], 1, 7)
print(f"B^{{1,7}} for A_2^(1): dim = {B.cardinality()}")

# List elements and their weights
print("\nElements of B^{1,7}:")
for b in sorted(B, key=lambda x: str(x)):
    wt = b.weight()
    RS = RootSystem(['A',2,1])
    alpha_vee = RS.coroot_lattice().simple_roots()
    a0 = wt.scalar(alpha_vee[0])
    a1 = wt.scalar(alpha_vee[1])
    a2 = wt.scalar(alpha_vee[2])
    print(f"  {b}: wt = ({a0},{a1},{a2})")

# The 1dsum for a tensor product T = B_1 tensor ... tensor B_n
# is sum over highest weight elements b of T of q^{D(b)}
# where D is the energy function (or degree function).

# For KR crystals, the one_dimensional_configuration_sum is a built-in method.
# Let me try it.
print("\n" + "="*60)
print("One-dimensional configuration sum for B^{1,7}^{n}")
print("="*60)

# The 1dsum formula: for a tensor product B_1 x ... x B_n,
# the one-dimensional configuration sum equals
# sum over paths of q^{energy}

# SageMath has this for tensor products of KR crystals
# The key function is one_dimensional_configuration_sum

# For a single KR crystal:
try:
    result = B.one_dimensional_configuration_sum(q=q_var)
    print(f"1dsum of B^{{1,7}}: {result}")
except Exception as e:
    print(f"Error for 1dsum: {e}")

# For tensor product:
try:
    T2 = crystals.TensorProduct(B, B)
    result2 = T2.one_dimensional_configuration_sum(q=q_var)
    print(f"1dsum of B^{{1,7}}^2: {result2}")
except Exception as e:
    print(f"Error for tensor 1dsum: {e}")

# Let me try using the fermionic formula instead
# The Schilling-Shimozono approach uses rigged configurations
print("\n" + "="*60)
print("Rigged configurations approach")
print("="*60)

# For type A_2^(1), level 7:
# The rigged configuration crystal RC(B) is isomorphic to the tensor product
# via the bijection Phi.

try:
    RC = crystals.RiggedConfigurations(['A',2,1], [[1,7]])
    print(f"RC for B^{{1,7}}: dim = {RC.cardinality()}")
except Exception as e:
    print(f"Error: {e}")

# Try the simpler case first: B^{1,1} for A_2^(1)
print("\n" + "="*60)
print("Simple case: B^{1,1} for A_2^(1)")
print("="*60)

B11 = crystals.KirillovReshetikhin(['A',2,1], 1, 1)
print(f"B^{{1,1}}: dim = {B11.cardinality()}")

# Tensor products of B^{1,1}
for n in range(1, 5):
    try:
        Bs = [B11] * n
        T = crystals.TensorProduct(*Bs)
        # Compute 1dsum
        # The one_dimensional_configuration_sum might not work directly for tensor products
        # Let me use the rigged configuration approach
        RC = crystals.RiggedConfigurations(['A',2,1], [[1,1]]*n)
        print(f"  RC for B^{{1,1}}^{n}: dim = {RC.cardinality()}")
    except Exception as e:
        print(f"  Error for n={n}: {e}")

# Now try the approach from the literature:
# For cylindric partitions of profile (c0,c1,c2) with k=3:
# The generating function F_c(q) is related to the character of
# L(Lambda) for hat{sl}_3 with Lambda = sum c_i Lambda_i.

# The BOUNDED version F_{c,n}(q) should be related to the
# one-dimensional configuration sum of B^{1,c0} x B^{1,c1} x B^{1,c2}
# repeated n times... or something like that.

# Actually, the key reference is Schilling-Shimozono (1999):
# "Fermionic formulas for level-restricted generalized Kostka polynomials
# and coset branching functions"
# They prove that the 1d config sum equals a Demazure character at principal spec.

# For cylindric partitions, the relevant object is:
# tensor product B^{1,1}^{d} (d copies of the fundamental crystal)
# at level 3 (since k=3).

# Wait, level-rank duality: cylindric partitions of profile c = (c0,c1,c2)
# with k=3 parts correspond to level-3 representations of hat{sl}_{d+3} (type A_{d+2}^(1)).
# Under this duality, the bounded version (max <= n) should be related to
# Demazure modules in the level-3 module of A_{d+2}^(1).

# This is the OTHER direction of level-rank duality mentioned in the synthesis
# (Seed 8's proposal vs Seed 7's proposal).

# Let me try: for d=7, use A_9^(1) = hat{sl}_{10} at level 3
# The KR crystal B^{1,1} for A_9^(1) has dim 10.
# Tensor product B^{1,1}^3: dim = 10^3 = 1000.
# But we need dim related to the partition structure.

print("\n" + "="*60)
print("Level-rank dual: A_9^(1) at level 3")
print("="*60)

# For d=7, t=10, the dual algebra is A_9^(1) = hat{sl}_{10}
# Level 3 fundamental weights: Lambda_0, Lambda_1, ..., Lambda_9

try:
    B_dual = crystals.KirillovReshetikhin(['A',9,1], 1, 1)
    print(f"B^{{1,1}} for A_9^(1): dim = {B_dual.cardinality()}")

    # The cylindric partition profile (c0,c1,c2) with c0+c1+c2 = 7
    # should correspond to a weight in A_9^(1) at level 3
    # Level-rank duality: level k=3 of A_{t-1}^(1) = A_9^(1)
    # maps to level d=7 of A_{k-1}^(1) = A_2^(1)

    # The highest weight in the dual should be:
    # For profile (3,2,2): sum = 7, the weight in A_9^(1) at level 3 should be
    # 3*Lambda_0 + ... (not sure about the exact mapping)

    # Actually, the level-rank duality for cylindric partitions gives:
    # A cylindric partition of profile (c0,...,c_{k-1}) with max <= n
    # <-> A configuration in the level-k module of A_{t-1}^(1)
    # where the "depth" is related to n.

    # For k=3, t=10: level 3 of A_9^(1)
    # The KR crystals for level 3 would be B^{r,s} with r <= 3

    # The relevant tensor product might be B^{3,n} (rectangular KR crystal)
    # or n copies of B^{3,1}

    B31 = crystals.KirillovReshetikhin(['A',9,1], 3, 1)
    print(f"B^{{3,1}} for A_9^(1): dim = {B31.cardinality()}")

    B32 = crystals.KirillovReshetikhin(['A',9,1], 3, 2)
    print(f"B^{{3,2}} for A_9^(1): dim = {B32.cardinality()}")

    # For level 3 at A_9^(1): a single B^{3,1} is a 3-column strip of height 10
    # It's a minuscule representation.
    # dim B^{3,1} = binom(10, 3) = 120

    # Tensor product B^{3,1}^n would have dim 120^n
    # h_1(1) = 12 != 120, so this isn't directly right either.

    # The specific weight must match the profile c = (3,2,2).

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

# Let me go back to basics: what is the connection between
# Q_{n,c}(q) and KEY polynomials that we've already verified?

# We KNOW:
# Q_1 for c=(3,2,2) = K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)} at (q,q^2,q^3)
# This is a sum of GL_3 Demazure characters.

# These are characters of Demazure modules in FINITE type A_2 (not affine).
# K_{(0,0,1)} = s_{(1)} = character of fundamental rep V(omega_1)
# K_{(0,0,2)} = s_{(2)} = character of Sym^2(V(omega_1))
# K_{(0,1,0)} = Demazure truncation of V(omega_1)

# So Q_1 is the character of:
# V(omega_1) + Sym^2(V(omega_1)) + B_{s_1}(V(omega_1))

# where B_{s_1}(V(omega_1)) is the Demazure submodule for w = s_1.

# The TOTAL weight (at q=1) is 3 + 6 + 2 = 11.

# For Q_2, the decomposition involves higher-level key polynomials.
# The KEY question is: is there a RULE that determines which Demazure modules
# appear and with what multiplicity?

# Maybe: the decomposition comes from a tensor product decomposition.
# Q_n = character of some n-fold tensor product or plethysm.

print("\n" + "="*60)
print("Tensor product analysis")
print("="*60)

# Check: does V(omega_1) tensor V(omega_1) contain Q_2 components?
A2 = WeylCharacterRing("A2", style="coroots")
V1 = A2([1,0])  # fundamental rep
S2 = A2([2,0])  # Sym^2

# Q_1 components:
# K_(0,0,1) -> full V(omega_1) = A2([1,0])
# K_(0,0,2) -> full Sym^2(V(omega_1)) = A2([2,0])
# K_(0,1,0) -> Demazure truncation, not an irrep

# At q=1, Q_1 involves V(1,0) and V(2,0) and a Demazure truncation.
# This is NOT a direct sum of irreducibles.
# So tensor product of irreducibles won't work directly.

# But at the character level:
# Q_1 * Q_1 should involve Q_2 (if it's a tensor product character)
# Q_1(1)^2 = 121 = Q_2(1). So dimensions match!

# Check: Q_1^2 vs Q_2 as polynomials
print("Q_1^2 vs Q_2:")
Q1 = 2*q_var + 3*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6
Q2 = q_var**3 + 5*q_var**4 + 7*q_var**5 + 10*q_var**6 + 10*q_var**7 + 12*q_var**8 + 10*q_var**9 + 11*q_var**10 + 9*q_var**11 + 9*q_var**12 + 7*q_var**13 + 7*q_var**14 + 5*q_var**15 + 5*q_var**16 + 3*q_var**17 + 3*q_var**18 + 2*q_var**19 + 2*q_var**20 + q_var**21 + q_var**22 + q_var**24
Q1sq = Q1 * Q1
diff = Q2 - Q1sq
print(f"  Q_1^2 = {Q1sq}")
print(f"  Q_2   = {Q2}")
print(f"  Q_2 - Q_1^2 = {diff}")
print(f"  Q_2 - Q_1^2 has neg coeffs: {any(c < 0 for c in diff.coefficients())}")
