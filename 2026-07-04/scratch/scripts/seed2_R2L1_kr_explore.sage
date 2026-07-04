# Seed 2, Round 2, Layer 1: Explore KR crystals and energy functions
# Goal: Compute energy-graded data on B^{1,d}^{tensor n} for type A_2^(1)
# and compare with Q_{n,c}(q)

from sage.all import *

# First: understand the KR crystal B^{1,d} for d=4
print("=" * 60)
print("KR Crystal B^{1,4} for A_2^(1)")
print("=" * 60)

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
elts = list(K)
print(f"Number of elements: {len(elts)}")
print(f"Expected: C(4+2,2) = {binomial(6,2)}")

# Print elements and their (classical) weights
print("\nElements and classical weights:")
for b in elts:
    print(f"  {b} -> wt = {b.weight()}")

print("\n" + "=" * 60)
print("One-dimensional configuration sum for B^{1,4}")
print("=" * 60)

# The 1d config sum is sum_{b in B} q^{energy(b)} * e^{wt(b)}
# For a single factor, this is just the character
# For tensor products, the energy function provides the q-grading

# Let's compute the one_dimensional_configuration_sum
# This gives sum_b q^{D(b)} * e^{wt(b)} where D is the energy
R = QQ['q']
q = R.gen()

try:
    ocs1 = K.one_dimensional_configuration_sum(q=q)
    print(f"1d config sum (n=1): {ocs1}")
except Exception as e:
    print(f"Error computing 1d config sum: {e}")

print("\n" + "=" * 60)
print("Tensor product B^{1,4} tensor B^{1,4}")
print("=" * 60)

# Tensor product
T2 = crystals.TensorProduct(K, K)
print(f"Number of elements in B^{{1,4}} x B^{{1,4}}: {T2.cardinality()}")
print(f"Expected: 15^2 = {15**2}")

# Compute 1d config sum for tensor product
try:
    ocs2 = T2.one_dimensional_configuration_sum(q=q)
    print(f"\n1d config sum (n=2):")
    print(f"  {ocs2}")
except Exception as e:
    print(f"Error: {e}")

# Also try the energy_function method if available
print("\n" + "=" * 60)
print("Energy function values on B^{1,4} x B^{1,4}")
print("=" * 60)

# Sample some elements and their energy
count = 0
energy_dist = {}
for b in T2:
    try:
        e = b.energy_function()
        if e not in energy_dist:
            energy_dist[e] = 0
        energy_dist[e] += 1
        if count < 10:
            print(f"  {b} -> energy = {e}, wt = {b.weight()}")
        count += 1
    except Exception as ex:
        if count < 3:
            print(f"  Error on {b}: {ex}")
        count += 1
        break

print(f"\nTotal elements processed: {count}")
print(f"Energy distribution: {dict(sorted(energy_dist.items()))}")
print(f"Sum of counts: {sum(energy_dist.values())}")

