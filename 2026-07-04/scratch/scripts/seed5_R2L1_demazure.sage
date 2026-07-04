# Check if Q_1 for d=4 matches a Demazure character of sl_3
# 
# For A_2^(1) at level d, the KR crystal B^{1,d} gives a finite-dimensional
# sl_3 representation (by forgetting the 0-arrow). Its crystal graph
# decomposes into irreducible sl_3 components.
#
# For B^{1,4}: 15 elements with finite sl_3 crystal structure.
# The classical decomposition of B^{1,4} as sl_3 module should give
# some direct sum of V(mu) for various highest weights mu.

K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 4)
elems = list(K)

# Get the classical sl_3 crystal structure (forget e_0, f_0)
print("=== Classical sl_3 crystal structure of B^{1,4} ===")
print("Elements with their sl_3 (finite) weights:")
for b in elems:
    tab = list(b.to_tableau())[0]
    p = (tab.count(1), tab.count(2), tab.count(3))
    # Classical weight in terms of epsilon_i: (p[0], p[1], p[2])
    # In terms of fundamental weights: Lambda_1 coeff = p[0]-p[1], Lambda_2 coeff = p[1]-p[2]
    wt_L1 = p[0] - p[1]
    wt_L2 = p[1] - p[2]
    # f_1, f_2 arrows
    f1b = b.f(1)
    f2b = b.f(2)
    print(f"  {p}: sl_3 wt=({wt_L1},{wt_L2}), f_1->{f1b}, f_2->{f2b}")

# As a classical sl_3 module, B^{1,4} = V(4,0) (the 15-dim symmetric power S^4(V))
# This is because B^{1,d} = B^{1,d} for A_2^(1) classically is S^d(C^3)

# Actually for type A_2^(1), the KR crystal B^{1,d} is classically isomorphic to
# the irreducible sl_3 crystal B(d*Lambda_1) = S^d(C^3), which has dimension binom(d+2,2).

# Now Q_1 for profile c gives a polynomial. The question is: in the representation
# V(4*Lambda_1) = S^4(C^3), can we identify Q_1(c,q) with the principally graded
# character of some submodule or quotient?

# V(4*Lambda_1) has weights (4-3k, 2k-4+2j) for various k,j
# More precisely, weight (m_1, m_2, m_3) with m_1+m_2+m_3 = 4:
# sl_3 weight = (m_1-m_2)*Lambda_1 + (m_2-m_3)*Lambda_2

# The profiles are exactly the weight spaces!
# Each profile c = (c_0, c_1, c_2) is a weight of S^d(C^3).

# The principal grading: degree of weight (c_0, c_1, c_2) is...
# actually the principal grading assigns degree 1 to f_1 and f_2.
# So degree of element b = distance from highest weight in crystal graph.
# For S^4(C^3): highest weight (4,0,0), degree 0.
# f_1: (4,0,0) -> (3,1,0), degree 1
# f_2: (4,0,0) -> ... no, f_2 on (4,0,0) is 0 since there's no 2 to change to 3.
# f_1: changes rightmost 1 to 2. So (4,0,0) = [[1,1,1,1]] -> f_1 -> [[1,1,1,2]] = (3,1,0), degree 1
# f_1 on (3,1,0) = [[1,1,1,2]] -> [[1,1,2,2]] = (2,2,0), degree 2
# f_2 on (3,1,0) = [[1,1,1,2]] -> [[1,1,1,3]] = (3,0,1), degree 1
# etc.

# The PRINCIPAL grading of weight c in S^d(C^3):
# deg(c_0, c_1, c_2) = c_1 + 2*c_2 (distance from highest weight (d,0,0))
# Because each f_1 changes a 1 to 2 (adding 1 to degree) and
# each f_2 changes a 2 to 3 (adding 1 to degree).
# To go from (d,0,0) to (c_0, c_1, c_2) we need (d-c_0) applications of f_1
# and c_2 applications of f_2... not quite right.

# The principal grading for the HIGHEST weight (d,0,0):
# deg(b) = sum of indices of arrows used to reach b from highest weight
# Since f_1 and f_2 each have degree 1 in principal grading:
# deg = number of f-operators applied = depth in crystal graph

# For SSYT [[1,...,1,2,...,2,3,...,3]] with (c_0, c_1, c_2):
# depth = c_1 + 2*c_2 (since each 2 costs one f_1, each 3 costs one f_1 + one f_2)

# So: in S^4(C^3), the degree of profile c is c_1 + 2*c_2.
# Now Q_1(c) should relate to the principally graded character MINUS something.

# Q_1(1) = 4 = 15 - 1 - (something that sums to 10)?
# No: 4 = binom(6,2)/1 - 1 = 15 - 1 = ... wait 15 - 1 = 14 != 4.
# (d+1)(d+2)/6 - 1 = 5*6/6 - 1 = 5 - 1 = 4.
# So 4 = 5 - 1 where 5 = number of orbits.

# Let me just compute the principal grading for all profiles:
R.<q> = PowerSeriesRing(ZZ, default_prec=100)

d = 4
profiles = []
for a in range(d+1):
    for b in range(d+1-a):
        profiles.append((a, b, d-a-b))

print("\n=== Principal grading of S^4(C^3) ===")
char_Sd = R(0)
for c in profiles:
    deg = c[1] + 2*c[2]
    char_Sd += q^deg
    print(f"  {c}: degree = {deg}")
print(f"  Character: {char_Sd}")

# Character of S^4(C^3) with principal grading:
# = 1 + q + 2q^2 + 2q^3 + 3q^4 + 2q^5 + 2q^6 + q^7 + q^8
# Sum = 15 ✓

# Now Q_1(c) for each profile c:
print("\n=== Q_1 for d=4 (precomputed) ===")
Q1_data = {
    (4,0,0): R(q^2 + q^3 + q^4 + q^6),
    (3,1,0): R(q + q^2 + q^3 + q^4),
    (2,2,0): R(q + 2*q^2 + q^4),
    (2,1,1): R(2*q + q^2 + q^3),
    (3,0,1): R(q + q^2 + q^3 + q^5),
    (0,0,4): R(q^2 + q^3 + q^4 + q^6),
    (0,4,0): R(q^2 + q^3 + q^4 + q^6),
    (1,3,0): R(q + q^2 + q^3 + q^4),
    (0,3,1): R(q + q^2 + q^3 + q^5),
    (1,0,3): R(q + q^2 + q^3 + q^5),
    (0,1,3): R(q + q^2 + q^3 + q^5),
    (1,2,1): R(2*q + q^2 + q^3),
    (1,1,2): R(2*q + q^2 + q^3),
    (0,2,2): R(q + 2*q^2 + q^4),
    (2,0,2): R(q + 2*q^2 + q^4),
}

# Sum over ALL profiles Q_1(c):
total_Q1 = sum(Q1_data[c] for c in profiles)
print(f"Sum of Q_1 over all profiles: {total_Q1}")

# If Q_1 were a character of some module evaluated at different weights,
# the sum over all weights should give the total character.

# The sum is: let me compute...
for c in profiles:
    print(f"  Q_1({c}) = {Q1_data[c]}")

print(f"\nTotal: {total_Q1}")
print(f"Total at q=1: {total_Q1.polynomial()(1)} (should be 15*4 = 60)")

# Now: can Q_1 be related to the Demazure character D_{w}(Lambda)?
# From Round 1: Q_1 = D_{s_1 s_2} - 1 for balanced profiles.
# D_{s_1 s_2}(d*Lambda_0) for A_2^(1)?

# For balanced profile c = (2,1,1):
# Q_1 = 2q + q^2 + q^3 = q(2 + q + q^2)
# D_{s_1 s_2} - 1 would be a Demazure character minus the constant term.

# In the finite sl_3 setting:
# D_{s_1}(4*Lambda_1) = character of the subspace generated by applying f_1 to highest weight
# This would be: (4,0,0), (3,1,0), (2,2,0), (1,3,0), (0,4,0)
# with principal grading: 0, 1, 2, 3, 4
# So D_{s_1}(4*Lambda_1) = 1 + q + q^2 + q^3 + q^4

# D_{s_1 s_2}(4*Lambda_1) = apply f_2 as well:
# Starting from D_{s_1}: {(4,0,0), (3,1,0), (2,2,0), (1,3,0), (0,4,0)}
# Apply f_2 to each:
# f_2(3,1,0) = (3,0,1): degree = 0+2 = 2 (principal from HW)
# f_2(2,2,0) = (2,1,1): degree = 1+2 = 3
# f_2(1,3,0) = (1,2,1): degree = 2+2 = 4
# f_2(0,4,0) = (0,3,1): degree = 3+2 = 5
# And further f_2 applications...

# Actually I need to be more precise about Demazure crystals.
# B_{s_1}(Lambda) = {b in B(Lambda) : b is reachable from u_Lambda by f_1 only}
# B_{s_1 s_2}(Lambda) = {b : b reachable from B_{s_1}(Lambda) by f_2}

# For the CLASSICAL S^4(C^3):
# B_{s_1}(4*Lambda_1): apply f_1 repeatedly to (4,0,0):
# (4,0,0) -> (3,1,0) -> (2,2,0) -> (1,3,0) -> (0,4,0)
# B_{s_1 s_2}(4*Lambda_1): apply f_2 to all elements of B_{s_1}:
# (4,0,0) -> f_2 -> nothing (no 2's to change to 3's)
# (3,1,0) -> f_2 -> (3,0,1)
# (2,2,0) -> f_2 -> (2,1,1)
# (1,3,0) -> f_2 -> (1,2,1)
# (0,4,0) -> f_2 -> (0,3,1)
# Then apply f_2 again:
# (3,0,1) -> f_2 -> nothing
# (2,1,1) -> f_2 -> (2,0,2)
# (1,2,1) -> f_2 -> (1,1,2)
# (0,3,1) -> f_2 -> (0,2,2)
# And again:
# (2,0,2) -> f_2 -> nothing
# (1,1,2) -> f_2 -> (1,0,3)
# (0,2,2) -> f_2 -> (0,1,3)
# And:
# (1,0,3) -> f_2 -> nothing
# (0,1,3) -> f_2 -> (0,0,4)
# And (0,0,4) -> f_2 -> nothing

# So B_{s_1 s_2} = ALL 15 elements = full crystal.
# This is because s_1 s_2 generates the full Weyl group of sl_3 by repetition.

# For the AFFINE Demazure crystal, things are different.
# The Demazure crystal B_w(Lambda) in the AFFINE crystal B(Lambda)
# depends on the Weyl group element w of the AFFINE Weyl group.

# The relevant element for "truncated paths of length n" would be
# the translation element t_Lambda^n in the affine Weyl group.
# The Demazure crystal B_{t_Lambda^n}(Lambda) consists of elements
# reachable from u_Lambda by applying f_i operators in the order
# given by a reduced word for t_Lambda^n.

# For A_2^(1), the translation by Lambda_0 is:
# t_{Lambda_0} = s_0 s_1 s_2 (in some order, or a different reduced word)
# Actually t_{Lambda_0} = s_2 s_1 s_0 or similar.

# The key theorem (KKMMNN): 
# The Demazure crystal B_{t_Lambda^n}(Lambda) in the path model
# equals the set of paths that agree with ground state beyond position n.
# And the graded character of this Demazure module (with energy grading)
# equals the 1d configuration sum X_n(Lambda, q).

# But we showed that for B^{1,d}, the valid Kyoto paths are DETERMINISTIC
# (each phi value has exactly one element), so X_n = single monomial.
# This means the Demazure crystal B_{t_Lambda^n}(Lambda) has exactly 1 element!
# That's clearly wrong for the INFINITE crystal.

# The issue: B^{1,d} for A_2^(1) with d > 1 is NOT a perfect crystal
# of level 1. It's level d. And the Kyoto path model for level d
# uses B^{1,d} as the perfect crystal, with level d ground states.

# For level d > 1, the ground state paths are well-defined, but the
# Demazure crystal in the path model can still have many elements
# because the CRYSTAL OPERATORS e_i, f_i on the FULL tensor product
# can change multiple factors simultaneously.

# Wait -- I showed earlier that phi is injective on B^{1,d} for A_2^(1).
# This means the Kyoto path model has UNIQUE ground state paths
# (determined by the chain of eps/phi matching), and NO other valid paths!
# So the crystal B(Lambda) in the path model consists of only the ground state!
# This can't be right.

# The issue is that paths in the Kyoto model are NOT restricted to 
# paths where eps(b_k) = phi(b_{k+1}). The crystal operators f_i
# act on the TENSOR product using the tensor product rule, and they
# CAN produce elements where the matching condition is violated.
# The "matching condition" is just the property of the GROUND STATE path.
# Other elements of B(Lambda) arise from applying crystal operators
# to the ground state.

# So the set of PATHS in B(Lambda) using B^{1,d} is:
# ALL paths p = ...b_3 b_2 b_1 in (B^{1,d})^{tensor inf}
# such that p differs from ground state in finitely many places,
# AND p is in the connected component of the ground state under 
# the crystal operators.

# The crystal operators on the infinite tensor product use the tensor product rule:
# f_i acts on the RIGHTMOST position where it can act (after cancellation with e_i)
# This can change b_k for various k, not just one at a time.

# So even though each b_k in B^{1,d} is determined by its phi,
# the crystal operators on the tensor product can create "mismatches"
# where eps(b_k) != phi(b_{k+1}).

# This is the key insight I was missing! The paths in B(Lambda) are NOT
# chains of eps-phi matched elements. They are arbitrary elements of the 
# tensor product that are connected to the ground state by crystal operators.

print("\n\n=== KEY INSIGHT ===")
print("Kyoto paths are NOT eps-phi chains. They are elements of (B^{1,d})^{tensor n}")
print("connected to the ground state via crystal operators on the tensor product.")
print("The eps-phi matching is ONLY for the ground state.")
print("Other paths arise from applying f_i to the ground state,")
print("which changes MULTIPLE tensor factors via the tensor product rule.")

# Let me now compute the DEMAZURE subcrystal of the tensor product
# B^{1,4}^{tensor 2} connected to a ground state.

print("\n=== Demazure subcrystal of B^{1,4}^{tensor 2} ===")

K4 = crystals.KirillovReshetikhin(['A', 2, 1], 1, 4)
T = crystals.TensorProduct(K4, K4)

# The ground state for Lambda=(2,1,1) is b_1=[[1,1,2,3]], b_2=[[1,2,2,3]]
# (phi(b_1) = (2,1,1) which has profile mapping, and eps(b_1) = phi(b_2))

# Actually for A_2^(1) with eps-phi matching:
# b_1 with phi = (2,1,1): the unique element with this phi is [[1,1,2,3]] (profile (2,1,1))
# eps([[1,1,2,3]]) = (1,1,2) -> phi(b_2) = (1,1,2) -> b_2 = [[1,2,3,3]] (profile (1,1,2))
# This is the ground state: gs = [[1,2,3,3]] tensor [[1,1,2,3]]

print("Ground state for Lambda=(2,1,1):")
b1_gs = None
for b in K4:
    if tuple(b.phi(i) for i in [0,1,2]) == (2,1,1):
        b1_gs = b
        break
print(f"  b_1 = {b1_gs}, profile = {elem_to_profile(b1_gs)}")

needed_phi = tuple(b1_gs.epsilon(i) for i in [0,1,2])
b2_gs = None
for b in K4:
    if tuple(b.phi(i) for i in [0,1,2]) == needed_phi:
        b2_gs = b
        break
print(f"  b_2 = {b2_gs}, profile = {elem_to_profile(b2_gs)}")

gs = T(b2_gs, b1_gs)
print(f"  Ground state element: {gs}")
print(f"  Energy: {gs.energy_function()}")

# Now apply all crystal operators to this ground state
# to get the connected component (= Demazure subcrystal if we restrict)
from collections import deque

visited = set()
to_visit = deque()
to_visit.append(gs)
visited.add(gs)

while to_visit:
    elem = to_visit.popleft()
    for i in [0, 1, 2]:
        for op in [elem.f(i), elem.e(i)]:
            if op is not None and op not in visited:
                visited.add(op)
                to_visit.append(op)

print(f"\nConnected component size: {len(visited)}")

# Compute energy-graded character of this component
energy_sums = defaultdict(lambda: R(0))
for elem in visited:
    e = elem.energy_function()
    # Get profile of the "right" element (b_1)
    b1_comp = elem[1]  # rightmost factor
    p = elem_to_profile(b1_comp)
    energy_sums[p] += q^e

print("\nEnergy-graded sums by profile of b_1:")
for p in sorted(energy_sums.keys()):
    s = energy_sums[p]
    print(f"  profile {p}: {s + O(q^20)}")

# Sum over all profiles
total = sum(energy_sums.values())
print(f"\nTotal: {total + O(q^20)}")
print(f"Total at q=1: {total.polynomial()(1)}")

# Compare with P_2 and Q_2 for Lambda = (2,1,1)
print("\nQ_2((2,1,1)) = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12")
print(f"Q_2((2,1,1))(1) = 16")

def elem_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

