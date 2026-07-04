# Seed 2, R2L1: Demazure crystals and Q_n comparison
from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

# Get elements properly
elts = list(K)
hw = elts[0]  # [[1,1,1,1]] should be highest weight
print(f"HW element: {hw}, weight: {hw.weight()}")

# Build Demazure crystal by using f operators on crystal elements directly
def demazure_crystal(crystal, hw_elt, word):
    """Build Demazure crystal D_w from hw_elt by applying f_i in order given by word."""
    current = set([hw_elt])
    for i in word:
        new = set(current)
        changed = True
        while changed:
            changed = False
            for b in list(new):
                fb = b.f(i)
                if fb is not None and fb not in new:
                    new.add(fb)
                    changed = True
        current = new
    return current

# Build D_{s_1 s_2}: word = [1,2] (apply f_2 first, then f_1 -- wait,
# D_{s_1 s_2} means apply f_1 then f_2? Let me check convention.)
# Convention: D_{s_{i_1} ... s_{i_k}} = f_{i_1}^* ... f_{i_k}^* {hw}
# where f_i^* means "apply f_i maximally"
# So D_{s_1 s_2}: apply f_2 first, then f_1

for word in [[2], [1], [2,1], [1,2], [0], [0,2], [0,1], [2,0], [1,0],
             [2,1,0], [1,2,0], [0,2,1], [0,1,2]]:
    D = demazure_crystal(K, hw, word)
    # Character by profile
    char = defaultdict(int)
    for b in D:
        char[element_to_profile(b)] += 1
    word_str = ','.join(str(i) for i in word)
    total = sum(char.values())
    print(f"D_[{word_str}]: size={total}, char={dict(sorted(char.items()))}")

print("\n" + "=" * 60)
print("Comparing with Q_1 values")
print("=" * 60)

# Q_1(1) = 4 for all profiles
# D_{s_1 s_2} (word [2,1]) has size 5, so D-1 = 4
# But Q_1 depends on profile!

# The key insight from Round 1: Q_1 = D_{s_1 s_2}(q^rho) - 1
# where the q-grading comes from the principal grading q^rho
# But this only works for balanced profiles

# Let me check: for the D_{s_1 s_2} crystal, what is the q-graded character
# using principal specialization?

# Principal specialization: x_i -> q^i
# For A_2: x_1 -> q, x_2 -> q^2, x_3 -> q^3
# (or equivalently, e^{Lambda_1} -> q, e^{Lambda_2} -> q^2)

D_word = [2,1]  # D_{s_1 s_2}
D_set = demazure_crystal(K, hw, D_word)

# Principal grading: weight (a*Lambda_1 + b*Lambda_2) -> q^{a+2b}
# Or more precisely, for A_2 root system:
# Lambda_1 = (2/3, -1/3, -1/3), Lambda_2 = (1/3, 1/3, -2/3) in epsilon basis
# Principal grading: rho = Lambda_1 + Lambda_2, <rho, alpha_1> = <rho, alpha_2> = 1
# For weight lambda = n_1*Lambda_1 + n_2*Lambda_2:
# <lambda, rho^vee> = n_1 + n_2 (principal grading)

# Actually, for element with content (c_0, c_1, c_2) with c_0+c_1+c_2=d:
# classical weight in epsilon basis: sum c_i * epsilon_i
# Principal grading with rho = (1, 0, -1): <wt, rho> = c_0 - c_2

# Hmm, let me just compute the standard principal specialization
print("\nPrincipal grading (c_0 - c_2) on D_{s_1 s_2}:")
D_char_q = R(0)
for b in D_set:
    prof = element_to_profile(b)
    grade = prof[0] - prof[2]
    D_char_q += q**(grade + 4)  # shift to make nonneg
    print(f"  {b}: prof={prof}, grade={prof[0]-prof[2]}")

print(f"\nD graded char (shifted): {D_char_q}")

# Alternative: use energy function for grading
# For a single crystal B^{1,4}, all elements have energy 0
# So energy grading is trivial for n=1

# The real question is for n=2: can we find a q-grading on B^{1,4}^{tensor 2}
# (or a subcrystal thereof) that matches Q_2?

# Let me focus on the ENERGY FUNCTION on tensor products
# and see if summing over right-factor = c gives Q-related things

print("\n" + "=" * 60)
print("Energy on B^{1,4}^2 by right profile, then transform to Q_2")
print("=" * 60)

T2 = crystals.TensorProduct(K, K)

# From my earlier computation, the energy polynomials by right profile are:
# c=(2,1,1): 7q^3 + 5q^2 + 2q + 1 [eval 15]
# These sum to 15 at q=1, not 16 = Q_2(1)

# But wait: Q_2(1) = 4^2 = 16 per profile.
# Sum over all 15 profiles: 15*16 = 240
# Total crystal elements: 15^2 = 225
# So they don't match by count!

# The relationship must be more indirect.
# Let me re-examine: maybe the ODCS relates to F_{c,n}, not Q_n
# And Q_n is obtained from F_{c,n} via the (zq;q)_inf transform

# The (KMN)^2 character formula says:
# ch L(Lambda) = sum_{paths p} q^{D(p)} e^{wt(p)}
# = sum_n F_{c,n}(q) z^n  (in some appropriate sense)

# Let me check: does the ODCS by weight component match F_{c,n}?

# F_{c,1}(1) for profile c = number of CPs of profile c with max <= 1
# For c=(2,1,1), we computed F_{c,1} = 1 + 3q + 4q^2 + 5q^3 + 5q^4 + ...
# F_{c,1}(1) diverges (infinite sum)

# Wait no -- F_{c,1}(1) should be finite!
# Cylindric partitions with max <= 1: parts in {0,1}
# For c=(2,1,1), the number of valid (a_0,a_1,a_2) is infinite
# because you can have a_0 = a_1 = a_2 = N for any N

# Hmm, so F_{c,1}(q) is actually a rational function (power series that's not a polynomial)
# That makes sense from Borodin's product formula

# OK so F_{c,n}(q) is a power series, and Q_n is extracted from F_c(z,q) via
# a transform that produces a polynomial

# The connection to KR crystals must go through the character formula
# Let me try to compute ch L(d*Lambda_0) using the Kyoto path model
# and compare with the cylindric partition GF

print("\n" + "=" * 60)
print("Level-d module L(d*Lambda_0) character via paths")
print("=" * 60)

# For A_2^(1), the character of L(d*Lambda_0) is:
# ch L(d*Lambda_0) = sum over paths of q^{energy} * x^{wt}
# where paths are semi-infinite sequences ...b_3 b_2 b_1 in B^{1,d}
# ending at the ground state

# The ground state for Lambda_0 is the element with epsilon = Lambda_0
# For B^{1,d} of type A_2^(1): Lambda_0 restricted to classical part is 0
# So the ground state has classical weight 0
# That's the element with content (d/3, d/3, d/3) if d is divisible by 3
# For d=4: no element has equal content! 

# For B^{1,d}, the ground state for d*Lambda_0:
# We need epsilon(b) = d*Lambda_0 where epsilon = sum eps_i Lambda_i
# For the element with content (c_0, c_1, c_2):
# epsilon_0 = c_0 (how many 1's can be raised by e_0)
# Actually this is more complex for affine crystals

# Let me just check what SageMath gives us
# The one_dimensional_configuration_sum at n=2 already has the right structure
# Let me parse it carefully

# Actually, the key insight might be simpler than I think.
# Let me compute F_{c,n} for d=4 using the transfer matrix from Round 1
# and then see if ODCS gives us the same thing

# Transfer matrix approach: the state space is the set of profiles
# A_{c,c'} = q^{some function of c,c'} where transitions are valid steps

print("\n" + "=" * 60)
print("Transfer matrix A for d=4")
print("=" * 60)

# From Round 1: the CW recurrence gives a transfer matrix
# F_{c,N} = (I-A(q^N))^{-1} ... product formula
# A(x) has entries A_{c,c'}(x) = x if c -> c' is a valid step

# Actually, the transfer matrix A is defined by:
# A_{c,c'} encodes how profile c' at level N-1 contributes to profile c at level N

# From the Adjugate Monomial Theorem:
# adj(I-A(x))[c,c'] = x^{EMD(c,c')}
# So (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')} / det(I-A(x))
# and det(I-A(x)) = -(x^3-1)

# Therefore (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')} / (1-x^3)
#                                = -x^{EMD(c,c')} / (x^3-1)

# So F_{c,N} = [product formula using these entries]

# Hmm, let me think about this differently.
# The transfer matrix acts on the vector of partition GFs

# Actually, let me just check: is the energy function on KR crystals
# equal to the EMD?

print("Energy function H on B^{1,4} tensor B^{1,4} by profile pair:")
energy_matrix = {}
for b in T2:
    prof1 = element_to_profile(b[0])
    prof2 = element_to_profile(b[1])
    e = b.energy_function()
    key = (prof1, prof2)
    if key not in energy_matrix:
        energy_matrix[key] = set()
    energy_matrix[key].add(e)

# Check if energy is constant on each profile pair
all_constant = True
for key in sorted(energy_matrix.keys()):
    energies = energy_matrix[key]
    if len(energies) > 1:
        all_constant = False
    if key[0] <= key[1]:  # avoid duplicates
        print(f"  ({key[0]}, {key[1]}): energies = {sorted(energies)}")

print(f"\nEnergy constant on profile pairs? {all_constant}")

# If energy is NOT constant on profile pairs, then the connection is 
# more subtle than "energy = EMD"

