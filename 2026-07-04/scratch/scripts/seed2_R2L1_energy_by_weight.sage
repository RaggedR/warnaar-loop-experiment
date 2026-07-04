# Seed 2, R2L1: Energy distribution by classical weight on B^{1,4}^{tensor 2}
# Compare with Q_{n,c}(q) for d=4

from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

# For type A_2^(1), the classical weight lattice is spanned by Lambda[1], Lambda[2]
# (Lambda[0] is the affine fundamental weight)
# Classical weight = weight projected to finite part

# Map from KR crystal elements to compositions (c_0, c_1, c_2)
# Element [[a_1, a_2, ..., a_d]] where a_i in {1,2,3}
# Content: c_i = number of (i+1)'s in the element
# So c_0 = #{1's}, c_1 = #{2's}, c_2 = #{3's}

def element_to_profile(b):
    """Map KR crystal element to profile (c_0, c_1, c_2)"""
    tab = list(b.value.to_tableau())[0]  # single row
    c0 = tab.count(1)
    c1 = tab.count(2)
    c2 = tab.count(3)
    return (c0, c1, c2)

# Verify the mapping for B^{1,4}
print("Element to profile mapping for B^{1,4}:")
for b in K:
    prof = element_to_profile(b)
    print(f"  {b} -> {prof}")

print("\n" + "=" * 60)
print("Energy-graded weight decomposition of B^{1,4}^{tensor 2}")
print("=" * 60)

T2 = crystals.TensorProduct(K, K)

# For tensor product b1 tensor b2, the "profile pair" is (prof(b1), prof(b2))
# But we want to understand Q_{n,c} which is about bounded CPs of profile c
# The key question: is there a map from tensor product elements to profiles
# such that energy-graded character by profile = Q_{n,c}?

# First approach: group by profile of the RIGHT factor (or LEFT)
# and compute energy polynomial for each group

energy_by_right_prof = defaultdict(lambda: R(0))
energy_by_left_prof = defaultdict(lambda: R(0))
energy_by_prof_pair = defaultdict(lambda: R(0))

for b in T2:
    e = b.energy_function()
    b1, b2 = b.value[0], b.value[1]
    prof1 = element_to_profile(b1)
    prof2 = element_to_profile(b2)
    energy_by_right_prof[prof2] += q**e
    energy_by_left_prof[prof1] += q**e
    energy_by_prof_pair[(prof1, prof2)] += q**e

print("\nGrouped by RIGHT factor profile:")
for prof in sorted(energy_by_right_prof.keys()):
    poly = energy_by_right_prof[prof]
    print(f"  c={prof}: {poly}  [eval at q=1: {poly(q=1)}]")

print("\nGrouped by LEFT factor profile:")
for prof in sorted(energy_by_left_prof.keys()):
    poly = energy_by_left_prof[prof]
    print(f"  c={prof}: {poly}  [eval at q=1: {poly(q=1)}]")

# Also compute the total config sum (no weight decomposition)
total = sum(q**b.energy_function() for b in T2)
print(f"\nTotal config sum: {total}")
print(f"Total at q=1: {total(q=1)}")

# For reference: Q_{n,c}(1) for d=4, ell=1
# Q_n(1) = ((d+1)(d+2)/6 - 1)^n = (5*6/6 - 1)^n = (5-1)^n = 4^n
# So Q_1(1) = 4, Q_2(1) = 16
print(f"\nExpected Q_2(1) = 4^2 = 16")
print(f"Number of profiles = 15")
print(f"Sum of Q_2(1) over all 15 profiles = 15 * 16 = 240")

