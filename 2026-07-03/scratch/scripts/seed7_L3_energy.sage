"""
Seed 7 Layer 3: Energy function vs principal grading.

Key insight: the q-weight in Q_{n,c}(q) is the SIZE of the cylindric partition,
which corresponds to the ENERGY function on the crystal, not the principal grading.

The energy function E(b) for LS path crystals is:
  For b in B(Lambda), E(b) = <hw - wt(b), rho^vee> / (level)
where rho^vee is the Weyl vector of the finite part.

Actually for affine crystals, the correct grading for the principally specialized
character (which gives q-dimension) is:
  q-weight = -(coefficient of delta in the weight)

Let me figure out which grading matches the cylindric partition weight.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()

R = PolynomialRing(ZZ, 'q')
q = R.gen()

def extract_all_gradings(wt, hw_wt):
    """Extract multiple possible gradings for comparison."""
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    d0 = coeffs.get(0, 0)
    d1 = coeffs.get(1, 0)
    d2 = coeffs.get(2, 0)
    d_delta = coeffs.get('delta', 0)
    
    # Root decomposition: diff = n0*alpha_0 + n1*alpha_1 + n2*alpha_2
    n0 = d_delta
    n1 = (d1 - d0 + 3*d_delta) // 3
    n2 = (d2 - d0 + 3*d_delta) // 3
    
    principal_grade = n0 + n1 + n2  # grade 1 for each alpha_i
    
    # The "homogeneous grading" assigns grade 1 to alpha_0, grade 0 to alpha_1, alpha_2
    # This counts "affine depth" = number of delta's essentially
    homogeneous_grade = n0
    
    # The "Weyl vector grading" uses <rho, diff>
    # For A_2: rho = Lambda_1 + Lambda_2 (sum of fundamental weights of finite part)
    # <rho, alpha_0> = <rho, delta - theta> = <rho, delta> - <rho, theta>
    # For A_2: theta = alpha_1 + alpha_2, <rho, theta> = 2
    # <rho, delta> = 0 (delta is in the radical)
    # So <rho, alpha_0> = -2
    # <rho, alpha_1> = <Lambda_1+Lambda_2, alpha_1> = 1
    # <rho, alpha_2> = 1
    weyl_grade = -2*n0 + n1 + n2
    
    # The "level grading" or "energy":
    # For the LS path crystal, the energy is related to the
    # principal specialization index.
    # In the affine setting, the relevant grading for the character
    # formula is: e^{Lambda - n*delta - finite_wt} -> q^n * (finite char)
    # The coefficient of delta in the weight gives the "n" part.
    
    # delta = alpha_0 + alpha_1 + alpha_2
    # diff = n0*a0 + n1*a1 + n2*a2
    # = min(n0,n1,n2)*delta + remaining
    delta_coeff = min(n0, n1, n2)
    
    return {
        'n0': n0, 'n1': n1, 'n2': n2,
        'principal': principal_grade,
        'homogeneous': homogeneous_grade,
        'weyl': weyl_grade,
        'delta': delta_coeff,
    }


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


def demazure_char_all_gradings(crystal, word, hw_wt):
    """Compute Demazure character with multiple grading choices."""
    D = demazure_set(crystal, word)
    chars = {}
    for grading_name in ['principal', 'homogeneous', 'delta']:
        char = R(0)
        for b in D:
            info = extract_all_gradings(b.weight(), hw_wt)
            grade = info[grading_name]
            if grade >= 0:
                char += q**grade
            else:
                # Negative grade - use 1/q (not a polynomial, skip)
                char = None
                break
        chars[grading_name] = char
    return chars, len(D)


# ======================================================================
# Test with d=4, c=(2,1,1)
# ======================================================================
print("="*70)
print("Grading comparison for B(2*L0 + L1 + L2)")
print("="*70)

hw = 2*Lambda[0] + Lambda[1] + Lambda[2]
C = crystals.LSPaths(ct, hw)

# Print individual elements for small words
print("\nElements of D_{s1s2}:")
D = demazure_set(C, [1,2])
for b in sorted(D, key=lambda x: str(x)):
    info = extract_all_gradings(b.weight(), hw)
    print(f"  wt={b.weight()}, n=({info['n0']},{info['n1']},{info['n2']}), "
          f"principal={info['principal']}, homog={info['homogeneous']}, delta={info['delta']}")

# Compare gradings for several words
print("\n" + "="*70)
print("Demazure characters with different gradings")
print("="*70)

for name, word in [
    ('e', []),
    ('s1s2', [1,2]),
    ('s0s1s2', [0,1,2]),
    ('s2s1s0', [2,1,0]),
    ('s0s1s2s0', [0,1,2,0]),
    ('s1s2s0s1', [1,2,0,1]),
    ('s2s0s1s2', [2,0,1,2]),
    ('s0s1s2s0s1s2', [0,1,2,0,1,2]),
]:
    chars, size = demazure_char_all_gradings(C, word, hw)
    print(f"\nD_{name} (|D|={size}):")
    for gname, char in chars.items():
        if char is not None:
            print(f"  {gname}: {char}  [sum={char(1)}]")
        else:
            print(f"  {gname}: (has negative grades)")


# ======================================================================
# Also check: does F_{c,N} match D_w with delta grading?
# ======================================================================
print("\n" + "="*70)
print("Testing: F_{c,N} with the delta grading")
print("="*70)

# For cylindric partitions, the q-weight is the SIZE = total number of boxes.
# Each box at level m in partition lambda^i contributes 1 to the weight.
# In the crystal, each alpha_i lowers a weight, and the size of the
# corresponding cylindric partition is related to the energy.

# The key connection (from Tingley, Tsuchioka):
# Cylindric partition of profile c <-> element of crystal B(Lambda)
# where Lambda = c_0*L0 + c_1*L1 + c_2*L2.
# The SIZE of the cylindric partition = energy of the crystal element.

# Energy for LS path crystals might be available via:
print("\nChecking energy methods on LS path elements:")
hw_elem = C.module_generators[0]
energy_methods = [m for m in dir(hw_elem) if 'ener' in m.lower()]
print(f"Energy methods: {energy_methods}")

# Also check for grading / degree methods
grade_methods = [m for m in dir(hw_elem) if any(k in m.lower() for k in ['grad', 'deg', 'depth'])]
print(f"Grade/degree methods: {grade_methods}")

# Check if there's a sigma method (for Kyoto path model)
kyoto_methods = [m for m in dir(hw_elem) if any(k in m.lower() for k in ['sigma', 'epsilon', 'phi', 'string'])]
print(f"Kyoto methods: {kyoto_methods}")

# Let me also check the tensor product approach
# B(Lambda) for affine type can be realized as a tensor product of
# level-1 perfect crystals via the Kyoto path model.
# In this model, the energy is naturally defined.

# But for LS paths, the grading comes from the weight.
# For type A_2^(1) at level d, the weight of an element is:
# Lambda - sum n_i alpha_i
# The null root coefficient in the sum gives the "affine depth".

# Actually, the correct formula for the principally specialized character
# of a Demazure module is:
# ch_q(D_w(Lambda)) = sum_{b in D_w} q^{<rho, Lambda - wt(b)>}  (???)
# No, the correct one is:
# ch_q(V(Lambda)) = sum_{mu} dim(V(Lambda)_mu) * q^{dep(mu)}
# where dep(mu) is such that the character gives a theta function.

# For affine Lie algebras, the graded character uses:
# q^{-<Lambda + rho, Lambda + rho>/(2(k+h^v))} * sum e^mu * q^{-|mu|^2/(2(k+h^v))}
# This is very different from the principal grading.

# Let me try yet another grading: the "principal degree"
# In the principal grading of A_2^(1), the degree of alpha_i is:
# deg(alpha_0) = 1 (since a_0 = 1 for A_2^(1) where a_i are marks)
# deg(alpha_1) = 1
# deg(alpha_2) = 1
# So the principal degree is the same as the "total" n0+n1+n2.

# But for the homogeneous grading:
# deg(alpha_0) = 1 (delta component)
# deg(alpha_1) = 0
# deg(alpha_2) = 0
# The homogeneous degree = n0 = coefficient of alpha_0.

# For cylindric partitions, the relationship between SIZE and these gradings
# is not n0 + n1 + n2 (that would grow too fast).
# It should be related to n0 (the "affine depth") scaled by something.

# Let me check by looking at the d=2 case where everything is small.
print("\n" + "="*70)
print("d=2: B(L0 + L1 + L2) -- level 3, probably not right")
print("Actually: B(L0 + L1) for d=2")
print("="*70)

# Actually for d=2, c=(1,1,0): Lambda = L0 + L1
# The crystal B(L0 + L1) has level 2.
# F_{c,1} has coefficients: 1, 2, 2, 2, 2, ... (from earlier output)
# g_1 starts: 0, 1, 1, 1, 1, ... (coefficients of q^0, q^1, q^2, ...)
# Wait: g_1 = F_{c,1} - 1 starts: 0, 2, 2, 2, 2, ...

# Hmm, g_1 should count cylindric partitions with max entry exactly 1.
# Let me check the elements of D_{s1} (or some small word) for B(L0+L1).

hw2 = Lambda[0] + Lambda[1]
C2 = crystals.LSPaths(ct, hw2)

print("\nElements of D_{s0} for B(L0+L1):")
D = demazure_set(C2, [0])
for b in sorted(D, key=lambda x: str(x)):
    info = extract_all_gradings(b.weight(), hw2)
    print(f"  wt={b.weight()}, n=({info['n0']},{info['n1']},{info['n2']}), "
          f"principal={info['principal']}, homog={info['homogeneous']}, delta={info['delta']}")

print("\nElements of D_{s2s0} for B(L0+L1):")
D = demazure_set(C2, [2,0])
for b in sorted(D, key=lambda x: str(x)):
    info = extract_all_gradings(b.weight(), hw2)
    print(f"  wt={b.weight()}, n=({info['n0']},{info['n1']},{info['n2']}), "
          f"principal={info['principal']}, homog={info['homogeneous']}")

print("\nElements of D_{s1s2s0} for B(L0+L1):")
D = demazure_set(C2, [1,2,0])
for b in sorted(D, key=lambda x: str(x)):
    info = extract_all_gradings(b.weight(), hw2)
    print(f"  wt={b.weight()}, n=({info['n0']},{info['n1']},{info['n2']}), "
          f"principal={info['principal']}, homog={info['homogeneous']}")

