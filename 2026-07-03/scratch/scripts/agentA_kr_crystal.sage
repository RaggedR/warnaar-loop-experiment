"""
Agent A: Compute energy function on KR crystal tensor products B^{1,d}^{tensor n}
for A_2^(1) and compare with cylindric partition generating functions.
"""

from sage.all import *

# Test for several d values
print("=" * 60)
print("KR Crystal B^{1,d} for A_2^(1)")
print("=" * 60)

for d in [2, 4, 5]:
    print(f"\n--- d = {d} ---")
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    print(f"B^{{1,{d}}} has {K.cardinality()} elements")

    # List elements with their classical weights
    weight_counts = {}
    for b in K:
        wt = b.weight()
        cl = tuple(wt[i] for i in range(3))
        if cl not in weight_counts:
            weight_counts[cl] = 0
        weight_counts[cl] += 1

    print(f"Weight multiplicities: {len(weight_counts)} distinct weights")
    for w in sorted(weight_counts.keys()):
        print(f"  weight {w}: multiplicity {weight_counts[w]}")

print("\n" + "=" * 60)
print("Sample elements of B^{1,4}")
print("=" * 60)

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
count = 0
for b in K:
    wt = b.weight()
    print(f"  {b} -> affine weight ({wt[0]}, {wt[1]}, {wt[2]})")
    count += 1
    if count >= 15:
        break

print("\n" + "=" * 60)
print("Tensor product B^{1,4} x B^{1,4}: energy function")
print("=" * 60)

T = tensor([K, K])
print(f"B^{{1,4}} tensor B^{{1,4}} has {T.cardinality()} elements")

R = PolynomialRing(ZZ, 'q')
q = R.gen()

energy_by_weight = {}
for b in T:
    wt = b.weight()
    cl = tuple(wt[i] for i in range(3))
    e = b.energy_function()

    if cl not in energy_by_weight:
        energy_by_weight[cl] = R(0)
    energy_by_weight[cl] += q**e

print(f"\nEnergy-graded weight multiplicities:")
for w in sorted(energy_by_weight.keys()):
    poly = energy_by_weight[w]
    if poly != 0:
        print(f"  weight {w}: {poly}")
