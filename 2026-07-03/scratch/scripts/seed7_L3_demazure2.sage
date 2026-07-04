"""
Seed 7 Layer 3: Demazure character computation for sl3-hat.
Fix: use weight_space instead of weight_lattice.
"""
from sage.all import *

print("="*70)
print("DEMAZURE CHARACTER COMPUTATION FOR sl3-hat (v2)")
print("="*70)

ct = CartanType(['A', 2, 1])

# Use WEIGHT SPACE (not lattice)
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()
print(f"Lambda_0 = {Lambda[0]}")
print(f"Lambda_1 = {Lambda[1]}")
print(f"Lambda_2 = {Lambda[2]}")
print(f"delta = {delta}")
print(f"alpha_0 = {alpha[0]}")

# ---- Test with d=2 first ----
print("\n" + "="*70)
print("d=2, c=(2,0,0): Crystal B(2*Lambda_0)")
print("="*70)

C = crystals.LSPaths(ct, 2*Lambda[0])
hw = C.module_generators[0]
print(f"Crystal created. HW element: {hw}")
print(f"HW weight: {hw.weight()}")

# Enumerate elements (the crystal is infinite for affine types!)
# We need to work with Demazure subcrystals which are finite.
print("\nEnumerating first elements...")
count = 0
elements = []
for b in C:
    elements.append(b)
    count += 1
    if count >= 50:
        break
print(f"Got {count} elements (crystal is infinite for affine type)")

# ---- Demazure subcrystal ----
print("\n--- Computing Demazure subcrystals ---")

def demazure_set(crystal, word):
    """
    Compute the Demazure subcrystal for a reduced word.
    word: list of simple reflection indices [i_1, i_2, ..., i_l]
    such that w = s_{i_1} * s_{i_2} * ... * s_{i_l}
    
    Algorithm: Start with {hw}. For i_l, i_{l-1}, ..., i_1 (right to left):
      For each b in current set, add all f_i^k(b) for k >= 0.
    """
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


def weight_to_grade(wt, highest_wt, level):
    """
    Convert a weight to a grade (non-negative integer).
    For affine weight mu of level l, the grade is:
    grade = (highest_wt - mu) applied to the scaling element d.
    
    In practice, for A_2^(1) at level l:
    wt = a_0*Lambda_0 + a_1*Lambda_1 + a_2*Lambda_2 - n*delta
    grade = n (coefficient of delta in hw - wt)
    """
    diff = highest_wt - wt
    # Extract the coefficient of delta
    # In the extended weight space, delta = alpha_0 + alpha_1 + alpha_2
    # The coefficient of delta is the scalar 'c' in diff = finite_part + c*delta
    # We can use the level and the inner product with the derivation d.
    
    # For the extended weight space, there's a method
    # Actually, let's just use the scalar product with the derivation
    # The derivation d is defined so that <d, alpha_i> = delta_{i,0}
    # and <d, Lambda_i> = 0.
    
    # So <d, diff> = <d, hw - wt> gives the grade.
    # But we need access to d...
    
    # Alternative: express diff in terms of simple roots and delta
    # diff = hw - wt = sum c_i alpha_i + n * delta
    # For A_2^(1): delta = alpha_0 + alpha_1 + alpha_2
    
    # Let me just compute it from the weight directly.
    # wt = hw - sum_{i} n_i alpha_i
    # The grade is related to n_0 (coefficient of alpha_0)
    
    # Actually, the simplest way: 
    # For the LS path crystal, the energy function gives the grade.
    # But let me try a different approach.
    
    # In A_2^(1), Lambda_0 + Lambda_1 + Lambda_2 = delta (NO, that's wrong)
    # alpha_0 + alpha_1 + alpha_2 = delta
    # Lambda_0 - Lambda_1 = -alpha_1 - alpha_0/... no, the relations are more complex
    
    # Let me just use the coefficient extraction.
    # The weight space has basis Lambda_0, Lambda_1, Lambda_2 (or alpha_0, alpha_1, alpha_2, delta, ...)
    
    # For the extended weight space of A_2^(1), a weight is:
    # mu = c * Lambda_0 + ... + level*Lambda_0 + ... - grade * delta + ...
    # Hmm, this is getting complicated.
    
    # Let me use a practical method: compute the degree from the
    # alpha_0 coordinate.
    # For A_2^(1) at level l, if hw = l*Lambda_0, then
    # the grading operator is d (canonical central element dual).
    # The practical formula: grade(b) = -<wt(b), c> where c = ...
    # No wait, let me try:
    
    # In SageMath, the weight space element has coefficients.
    # Let me just check what wt looks like.
    return None


# Let's just print the weights and figure out the grading
print("\nDemazure crystal for word [] (just hw):")
D = demazure_set(C, [])
for b in D:
    print(f"  {b}: weight = {b.weight()}")

print("\nDemazure crystal for word [0]:")
D = demazure_set(C, [0])
for b in sorted(D, key=str):
    print(f"  weight = {b.weight()}")
print(f"  Size: {len(D)}")

print("\nDemazure crystal for word [1,0]:")
D = demazure_set(C, [1,0])
for b in sorted(D, key=str):
    print(f"  weight = {b.weight()}")
print(f"  Size: {len(D)}")

print("\nDemazure crystal for word [2,1,0]:")
D = demazure_set(C, [2,1,0])
for b in sorted(D, key=str):
    print(f"  weight = {b.weight()}")
print(f"  Size: {len(D)}")

print("\nDemazure crystal for word [0,1,2,0]:")
D = demazure_set(C, [0,1,2,0])
for b in sorted(D, key=str):
    print(f"  weight = {b.weight()}")
print(f"  Size: {len(D)}")

# Try the translation element: in A_2^(1), 
# t_{-theta} = s_0 s_1 s_2 s_1 (for the highest root theta of A_2)
# Or maybe s_0 * s_1 * s_2 works differently.

# For A_2^(1), the affine Weyl group is generated by s_0, s_1, s_2.
# The translation by the null root direction uses specific products.
# The Coxeter element is s_0 s_1 s_2 (length 3).
# Powers of the Coxeter element give "depth" in some sense.

for word in [[0,1,2], [0,2,1], [1,0,2], [1,2,0], [2,0,1], [2,1,0],
             [0,1,2,0,1,2], [1,2,0,1,2,0]]:
    D = demazure_set(C, word)
    print(f"\nWord {word}: |D| = {len(D)}")

# Also check the SageMath built-in Demazure crystal
print("\n--- Trying SageMath built-in Demazure crystal ---")
try:
    # SageMath has a DemazureCrystal class
    W = WeylGroup(ct, prefix='s')
    s = W.simple_reflections()
    w = s[0] * s[1] * s[2]
    print(f"w = s0*s1*s2, reduced word = {w.reduced_word()}")
    
    DC = crystals.Demazure(C, w)
    print(f"Demazure crystal created: {DC}")
    print(f"Size: {DC.cardinality()}")
except Exception as e:
    print(f"Error: {e}")
    # Try alternative approach
    try:
        from sage.combinat.crystals.demazure import DemazureCrystalByTruncation
        print("Trying DemazureCrystalByTruncation...")
    except:
        pass

