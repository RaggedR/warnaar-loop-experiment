# Seed 2, R2L1: One-dimensional configuration sum (ODCS) 
# The ODCS is the key tool connecting KR crystals to partition identities
# For type A_2^(1) at level d, it should relate to cylindric partition GFs

from sage.all import *

# The ODCS for a perfect crystal B of level l is:
# X(B, lambda, q) = sum_{paths p: ground state -> lambda} q^{energy(p)}
# where paths are semi-infinite sequences in B

# In SageMath, this is computed via the Kyoto path model
# For B = B^{1,s} (KR crystal of type A_2^(1), node 1, column s)

# B^{1,s} is a perfect crystal of level s for A_2^(1)

# Let's try the path model approach
print("=" * 60)
print("Kyoto Path Model for A_2^(1)")
print("=" * 60)

# For d=4, B^{1,4} is a perfect crystal of level 4
# The ground state path for Lambda_0 is the constant path at the element
# with weight Lambda_0 (restricted to classical part)

# In SageMath, we can compute the ODCS via:
# K.one_dimensional_configuration_sum() -- but this wasn't available on KR directly

# Let's try via the path model
K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

# Check if K is a perfect crystal
print(f"B^{{1,4}} cardinality: {K.cardinality()}")

# The classical decomposition of B^{1,4}
# As an A_2 crystal, B^{1,4} decomposes into irreducibles
# B^{1,s} for A_2 = symmetric power Sym^s(V) where V is the standard rep
# So as A_2-crystal, B^{1,s} is a single irreducible with highest weight s*Lambda_1
print(f"\nClassical highest weight elements:")
for b in K:
    if b.is_highest_weight(index_set=[1,2]):
        print(f"  {b} (weight {b.weight()})")

# Now let's work with tensor products and the energy function
# The ODCS for a tensor product B^{tensor n} is:
# sum_{b in B^{tensor n}} q^{D(b)} * e^{wt(b)}
# where D(b) is the intrinsic energy

# This is what one_dimensional_configuration_sum computes on TensorProduct
R = QQ['q']
q = R.gen()

# n=1: trivial (energy = 0)
print("\n" + "=" * 60)
print("n=1 ODCS")
print("=" * 60)
T1 = crystals.TensorProduct(K)
try:
    ocs1 = T1.one_dimensional_configuration_sum(q=q)
    print(f"ODCS(n=1) = {ocs1}")
except Exception as e:
    print(f"Error: {e}")

# n=2
print("\n" + "=" * 60)
print("n=2 ODCS")  
print("=" * 60)
T2 = crystals.TensorProduct(K, K)
ocs2 = T2.one_dimensional_configuration_sum(q=q)
print(f"ODCS(n=2) has {len(str(ocs2).split(' + '))} terms")

# The ODCS decomposes into classical weight components
# Each component is a polynomial in q times e^{lambda}
# Let's extract the weight-zero component (if any)

# For A_2^(1) with level d=4, the relevant highest weight is
# Lambda_0 + (d-1)*Lambda_0 ... no wait

# Actually, let me think about what the ODCS should match
# The connection to cylindric partitions should be through the 
# (KMN)^2 character formula:
# ch L(Lambda) = sum_{paths} q^{energy} e^{wt}
# where L(Lambda) is an integrable highest weight module

# For A_2^(1) at level d, L(d*Lambda_0) has character related to
# cylindric partitions of some profile

# Let me try the paths approach directly
print("\n" + "=" * 60)
print("Path realization / Demazure crystals")
print("=" * 60)

# Demazure crystal for B^{1,4}: the set of elements reachable from
# highest weight by applying f_i operators in a specific order

# For A_2^(1), the Weyl group element w determines which Demazure subcrystal
# Round 1 found Q_1 = D_{s_1 s_2} - 1 for balanced profiles

# Let me check: what is the Demazure crystal D_{s_1 s_2} in B^{1,4}?
print("\nDemazure subcrystals of B^{1,4}:")

# Highest weight element
hw = None
for b in K:
    if b.is_highest_weight():
        hw = b
        break
print(f"Affine highest weight element: {hw}")

# Find classical highest weight
for b in K:
    if b.is_highest_weight(index_set=[1,2]):
        print(f"Classical HW: {b}")

# Apply f_2 then f_1 to build D_{s_1 s_2}
# s_1 s_2 means: first apply s_2, then s_1
# In Demazure crystal terms: start from HW, apply f_2^max, then f_1^max

print("\nBuilding Demazure crystal D_{s_1 s_2} from HW [[1,1,1,1]]:")
current = {K([[1,1,1,1]])}
print(f"  Start: {current}")

# Apply f_2
new = set(current)
changed = True
while changed:
    changed = False
    for b in list(new):
        fb = b.f(2)
        if fb is not None and fb not in new:
            new.add(fb)
            changed = True
print(f"  After f_2: {new}")

# Apply f_1
changed = True
while changed:
    changed = False
    for b in list(new):
        fb = b.f(1)
        if fb is not None and fb not in new:
            new.add(fb)
            changed = True
print(f"  After f_1: {new}")
print(f"  Size of D_{{s_1 s_2}}: {len(new)}")

# Character of D_{s_1 s_2}
from collections import defaultdict
def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

char_D = defaultdict(int)
for b in new:
    char_D[element_to_profile(b)] += 1
print(f"\n  Character by profile:")
for prof in sorted(char_D.keys()):
    print(f"    c={prof}: {char_D[prof]}")
print(f"  Total: {sum(char_D.values())}")
print(f"  D_{{s_1 s_2}} - 1 would give {sum(char_D.values()) - 1} at q=1, expected Q_1(1) = 4")

# Hmm, D_{s_1 s_2} has 5 elements, so D_{s_1 s_2} - 1 = 4. 
# That matches Q_1(1) = 4!

# But Q_1 depends on the profile. So maybe different profiles give different
# Demazure characters?

# Let me compute D_w for other Weyl group elements
print("\n\nBuilding various Demazure crystals:")
for word in [[1,2], [2,1], [0,1], [0,2], [1,0], [2,0], 
             [1,2,0], [2,1,0], [0,1,2], [0,2,1]]:
    current = {K([[1,1,1,1]])}
    for i in word:
        changed = True
        while changed:
            changed = False
            for b in list(current):
                fb = b.f(i)
                if fb is not None and fb not in current:
                    current.add(fb)
                    changed = True
    # Compute character
    char = defaultdict(int)
    for b in current:
        char[element_to_profile(b)] += 1
    word_str = ''.join(f's_{i}' for i in word)
    print(f"  D_{{{word_str}}}: size={len(current)}, profiles={dict(sorted(char.items()))}")

