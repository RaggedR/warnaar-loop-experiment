"""
Seed 7 Layer 3: THE CRITICAL COMPUTATION
Test whether Q_{n,c}(q) matches Demazure characters of sl3-hat at level d.

Strategy:
1. Build the LS path crystal for A_2^(1) at various weights
2. Compute Demazure subcrystals using Weyl group elements
3. Compare principally specialized characters with Q_{n,c}(q)
"""
from sage.all import *

print("="*70)
print("DEMAZURE CHARACTER COMPUTATION FOR sl3-hat")
print("="*70)

# ---- Step 1: Explore crystal structure for small d first ----

print("\n--- Step 1: d=2, c=(2,0,0) => Lambda = 2*Lambda_0 ---")
print("This should be trivial (known case)")

# For A_2^(1), the Cartan type
ct = CartanType(['A', 2, 1])
print(f"Cartan type: {ct}")
print(f"Dynkin diagram: {ct.dynkin_diagram()}")

# The weight lattice
WL = RootSystem(ct).weight_lattice(extended=True)
Lambda = WL.fundamental_weights()
print(f"Fundamental weights: Lambda_0={Lambda[0]}, Lambda_1={Lambda[1]}, Lambda_2={Lambda[2]}")

# Create the crystal at level 2 with weight 2*Lambda_0
try:
    C = crystals.LSPaths(ct, 2*Lambda[0])
    print(f"Crystal B(2*Lambda_0) created, type: {type(C)}")
    # Get the highest weight element
    hw = C.module_generators[0]
    print(f"Highest weight element: {hw}")
except Exception as e:
    print(f"Error creating crystal: {e}")

# ---- Step 2: Demazure crystal ----
# A Demazure crystal D_w(Lambda) is the set of elements in B(Lambda)
# reachable from the highest weight element by applying crystal operators
# f_i for i in a reduced word for w.

# For the affine Weyl group of A_2^(1), we have generators s_0, s_1, s_2.
# The "depth n" Demazure module should correspond to translation elements.

# The affine Weyl group element for "depth n":
# In A_2^(1), the translation t_alpha for a root alpha is a Weyl group element.
# The relevant element is likely (s_0 s_1 s_2)^n or similar.

W = WeylGroup(ct, prefix='s')
print(f"\nWeyl group generators: {W.simple_reflections()}")

s = W.simple_reflections()
s0, s1, s2 = s[0], s[1], s[2]

# Try small Weyl group elements and compute Demazure crystals
print("\n--- Step 2: Demazure subcrystals of B(2*Lambda_0) ---")

# The Demazure crystal for w is obtained by:
# Start from highest weight, apply f_{i_1}, then f_{i_2}, etc.
# for a reduced word w = s_{i_1} s_{i_2} ... s_{i_l}

def demazure_character(crystal, w, principal_spec=None):
    """
    Compute the Demazure crystal character.
    crystal: a SageMath crystal
    w: a Weyl group element (given as a list of simple reflection indices)
    principal_spec: if given, specialize weight -> q-polynomial
    
    Returns the set of crystal elements in the Demazure subcrystal.
    """
    hw = crystal.module_generators[0]
    
    # Build Demazure set by applying crystal operators
    # For reduced word [i_1, i_2, ..., i_l]:
    # D = {hw}
    # For j = l, l-1, ..., 1:
    #   D = D union {f_{i_j}^k(b) : b in D, k >= 1}
    
    current = {hw}
    for i in reversed(w):
        new = set()
        for b in current:
            # Apply f_i repeatedly
            x = b
            while True:
                new.add(x)
                y = x.f(i)
                if y is None:
                    break
                x = y
        current = new
    
    return current


# For d=2, let's start with small words
# The principal specialization maps weight a_0*Lambda_0 + a_1*Lambda_1 + a_2*Lambda_2
# to q^{energy} where energy is related to the grading.

# Actually for LS path crystals, each element has a weight.
# The principal specialization is: for weight mu, the contribution is q^{depth(mu)}
# where depth = level*n - <mu, rho^vee> or similar.

# In SageMath, the energy function on LS paths gives the grading.
# Let's check what methods are available.

C = crystals.LSPaths(ct, 2*Lambda[0])
hw = C.module_generators[0]
print(f"hw weight: {hw.weight()}")

# Check available methods
print(f"\nMethods on crystal element: {[m for m in dir(hw) if not m.startswith('_') and 'ener' in m.lower()]}")
print(f"Weight-related methods: {[m for m in dir(hw) if not m.startswith('_') and 'weigh' in m.lower()]}")

# Try to get the weight
w_hw = hw.weight()
print(f"Weight of hw: {w_hw}")

# The delta element (null root)
delta = WL.null_root()
print(f"Delta (null root): {delta}")

# For principal specialization, we need the "energy" or "degree" function.
# In the affine setting, the weight is Lambda - sum n_i alpha_i.
# The "grade" is the coefficient of delta in the weight.

# Let's enumerate a few elements
print("\n--- Enumerating crystal elements ---")
count = 0
for b in C:
    if count < 20:
        print(f"  {b} -> weight {b.weight()}")
    count += 1
    if count > 100:
        print(f"  ... (stopped at {count} elements)")
        break

if count <= 100:
    print(f"Total elements in B(2*Lambda_0): {count}")

