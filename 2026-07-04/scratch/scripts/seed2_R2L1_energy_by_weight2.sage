# Seed 2, R2L1: Energy distribution by weight on B^{1,4}^{tensor 2}
from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

def element_to_profile(b):
    """Map KR crystal element to profile (c_0, c_1, c_2)"""
    tab = list(b.to_tableau())[0]
    c0 = tab.count(1)
    c1 = tab.count(2)
    c2 = tab.count(3)
    return (c0, c1, c2)

T2 = crystals.TensorProduct(K, K)

energy_by_right_prof = defaultdict(lambda: R(0))
energy_by_left_prof = defaultdict(lambda: R(0))

for b in T2:
    e = b.energy_function()
    # Access components of tensor product
    components = b._list  # or b.list()
    try:
        b1 = components[0]
        b2 = components[1]
    except:
        # Try alternative access
        b1, b2 = list(b)
    prof1 = element_to_profile(b1)
    prof2 = element_to_profile(b2)
    energy_by_right_prof[prof2] += q**e
    energy_by_left_prof[prof1] += q**e

print("Grouped by RIGHT factor profile:")
for prof in sorted(energy_by_right_prof.keys()):
    poly = energy_by_right_prof[prof]
    print(f"  c={prof}: {poly}  [q=1: {poly(q=1)}]")

print("\nGrouped by LEFT factor profile:")
for prof in sorted(energy_by_left_prof.keys()):
    poly = energy_by_left_prof[prof]
    print(f"  c={prof}: {poly}  [q=1: {poly(q=1)}]")

