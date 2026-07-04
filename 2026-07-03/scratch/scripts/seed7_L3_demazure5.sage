"""
Seed 7 Layer 3: Compute graded Demazure characters with proper grade extraction.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()

# Weight space: elements have coefficients in basis {Lambda_0, Lambda_1, Lambda_2, delta}
# alpha_0 = 2*Lambda_0 - Lambda_1 - Lambda_2 + delta  => coeffs {0:2, 1:-1, 2:-1, delta:1}
# alpha_1 = -Lambda_0 + 2*Lambda_1 - Lambda_2          => coeffs {0:-1, 1:2, 2:-1}
# alpha_2 = -Lambda_0 - Lambda_1 + 2*Lambda_2          => coeffs {0:-1, 1:-1, 2:2}

# To solve diff = n0*alpha_0 + n1*alpha_1 + n2*alpha_2:
# Lambda_0 coeff: 2*n0 - n1 - n2 = d0
# Lambda_1 coeff: -n0 + 2*n1 - n2 = d1
# Lambda_2 coeff: -n0 - n1 + 2*n2 = d2
# delta coeff: n0 = d_delta
# So n0 = d_delta (directly from the delta coefficient!)
# Then: 2*d_delta - n1 - n2 = d0 => n1 + n2 = 2*d_delta - d0
#        -d_delta + 2*n1 - n2 = d1 => 2*n1 - n2 = d1 + d_delta
#        3*n1 = (2*d_delta - d0) + (d1 + d_delta) = 3*d_delta - d0 + d1
#        n1 = d_delta - d0/3 + d1/3 ... hmm, should be integer.
# From the system: n0 = d_delta, and then
#   -n1 - n2 = d0 - 2*d_delta
#   2*n1 - n2 = d1 + d_delta
# Adding: n1 = d0 - 2*d_delta + d1 + d_delta = d0 + d1 - d_delta ... no.
# Subtracting first from second: 3*n1 = d1 + d_delta - (d0 - 2*d_delta) = d1 - d0 + 3*d_delta
# n1 = (d1 - d0 + 3*d_delta) / 3
# n2 = (d2 - d0 + 3*d_delta) / 3

# For the first non-trivial weight diff = {0:2, 1:-1, 2:-1, delta:1}:
# n0 = 1, n1 = (-1-2+3)/3 = 0, n2 = (-1-2+3)/3 = 0.
# So diff = 1*alpha_0. Grade = 1. ✓

# For diff = {0:4, 1:-2, 2:-2, delta:2}:
# n0 = 2, n1 = (-2-4+6)/3 = 0, n2 = (-2-4+6)/3 = 0.
# diff = 2*alpha_0. Grade = 2. ✓

# For diff = {0:1, 1:1, 2:-2, delta:1}:
# n0 = 1, n1 = (1-1+3)/3 = 1, n2 = (-2-1+3)/3 = 0.
# diff = alpha_0 + alpha_1. Grade = 2. ✓

def extract_grade(wt, hw_wt):
    """Extract n0, n1, n2 such that hw_wt - wt = n0*alpha_0 + n1*alpha_1 + n2*alpha_2.
    Returns (n0, n1, n2) and grade = n0 + n1 + n2."""
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    d0 = coeffs.get(0, 0)
    d1 = coeffs.get(1, 0)
    d2 = coeffs.get(2, 0)
    d_delta = coeffs.get('delta', 0)
    
    n0 = d_delta
    n1_num = d1 - d0 + 3*d_delta
    n2_num = d2 - d0 + 3*d_delta
    
    assert n1_num % 3 == 0, f"n1 not integer: {n1_num}/3 for diff={diff}"
    assert n2_num % 3 == 0, f"n2 not integer: {n2_num}/3 for diff={diff}"
    
    n1 = n1_num // 3
    n2 = n2_num // 3
    
    # Verify
    check = n0 * alpha[0] + n1 * alpha[1] + n2 * alpha[2]
    assert check == diff, f"Verification failed: {check} != {diff}"
    
    grade = n0 + n1 + n2
    return n0, n1, n2, grade


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


def demazure_character_poly(crystal, word, hw_wt, var_name='q'):
    """Compute the principally specialized Demazure character as a polynomial in q.
    Each element contributes q^grade where grade = n0 + n1 + n2."""
    R = PolynomialRing(ZZ, var_name)
    q = R.gen()
    
    D = demazure_set(crystal, word)
    char = R(0)
    for b in D:
        n0, n1, n2, grade = extract_grade(b.weight(), hw_wt)
        char += q^grade
    
    return char


# ======================================================================
# d=2: B(2*Lambda_0)
# ======================================================================
print("="*70)
print("d=2: B(2*Lambda_0), base = (3*4/6 - 1) = 1")
print("Expected: Q_0 = 1, Q_n(1) = 1 for all n")
print("="*70)

C2 = crystals.LSPaths(ct, 2*Lambda[0])
hw2 = 2*Lambda[0]

# Try various Weyl group words
words_to_try = {
    'e': [],
    's0': [0],
    's1': [1],
    's2': [2],
    's0s1': [0,1],
    's1s0': [1,0],
    's2s1': [2,1],
    's0s1s2': [0,1,2],
    's1s2s0': [1,2,0],
    's2s0s1': [2,0,1],
    's2s1s0': [2,1,0],
    's1s0s2': [1,0,2],
    's0s2s1': [0,2,1],
    's0s1s2s0': [0,1,2,0],
    's1s2s0s1': [1,2,0,1],
    's2s0s1s2': [2,0,1,2],
    's0s1s2s0s1': [0,1,2,0,1],
    's1s2s0s1s2': [1,2,0,1,2],
    's0s1s2s0s1s2': [0,1,2,0,1,2],
    's1s2s0s1s2s0': [1,2,0,1,2,0],
    's2s0s1s2s0s1': [2,0,1,2,0,1],
}

for name, word in sorted(words_to_try.items(), key=lambda x: (len(x[1]), x[0])):
    try:
        char = demazure_character_poly(C2, word, hw2)
        print(f"  D_{name}: |D|={char(1)}, char = {char}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# d=4: B(c0*Lambda_0 + c1*Lambda_1 + c2*Lambda_2) for profile (2,1,1)
# ======================================================================
print("\n" + "="*70)
print("d=4: B(2*L0 + L1 + L2), base = (5*6/6 - 1) = 4")
print("Expected: Q_0 = 1, Q_1(1) = 4")
print("="*70)

C4 = crystals.LSPaths(ct, 2*Lambda[0] + Lambda[1] + Lambda[2])
hw4 = 2*Lambda[0] + Lambda[1] + Lambda[2]

for name, word in sorted(words_to_try.items(), key=lambda x: (len(x[1]), x[0])):
    try:
        char = demazure_character_poly(C4, word, hw4)
        if char(1) <= 200:  # don't print huge ones
            print(f"  D_{name}: |D|={char(1)}, char = {char}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# Check: what is Q_1 for d=4, c=(2,1,1)?
# For d=4, base = 4, so Q_1(1) = 4.
# Warnaar proved this case. Let's see what Q_1 looks like.
# From earlier computations: 
# For d=4, c=(2,1,1): Q_1 = q + q^2 + q^3 + q^4 (sum = 4, ✓ if ell=1)
# Actually wait - is the conjecture for 0-indexed or 1-indexed profiles?
# c = (c_0, c_1, c_2) with c_0 + c_1 + c_2 = d
# For d=4: c = (2,1,1) means c_0=2, c_1=1, c_2=1
# ======================================================================

# Also try (4,0,0)
print("\n--- d=4, B(4*Lambda_0), just Lambda_0 ---")
C4b = crystals.LSPaths(ct, 4*Lambda[0])
hw4b = 4*Lambda[0]
for name in ['e', 's0', 's0s1', 's0s1s2', 's0s1s2s0', 's0s1s2s0s1', 's0s1s2s0s1s2']:
    word = words_to_try[name]
    try:
        char = demazure_character_poly(C4b, word, hw4b)
        print(f"  D_{name}: |D|={char(1)}, char = {char}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")

