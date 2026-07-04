# Fix: define elem_to_profile before using it
R.<q> = PowerSeriesRing(ZZ, default_prec=100)
from collections import defaultdict, deque

K4 = crystals.KirillovReshetikhin(['A', 2, 1], 1, 4)
elems = list(K4)

def elem_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

eps_map = {}
phi_map = {}
for b in elems:
    eps_map[b] = tuple(b.epsilon(i) for i in [0,1,2])
    phi_map[b] = tuple(b.phi(i) for i in [0,1,2])

phi_to_elems = defaultdict(list)
for b in elems:
    phi_to_elems[phi_map[b]].append(b)

T = crystals.TensorProduct(K4, K4)

# Ground state for Lambda=(2,1,1):
b1_gs = None
for b in elems:
    if phi_map[b] == (2,1,1):
        b1_gs = b
        break
print(f"b_1 = {b1_gs}, profile = {elem_to_profile(b1_gs)}")

needed_phi = eps_map[b1_gs]
b2_gs = phi_to_elems[needed_phi][0]
print(f"b_2 = {b2_gs}, profile = {elem_to_profile(b2_gs)}")

gs = T(b2_gs, b1_gs)
print(f"Ground state: {gs}")
print(f"Energy: {gs.energy_function()}")

# BFS to find connected component under crystal operators
visited = set()
to_visit = deque([gs])
visited.add(gs)

while to_visit:
    elem = to_visit.popleft()
    for i in [0, 1, 2]:
        for op in [elem.f(i), elem.e(i)]:
            if op is not None and op not in visited:
                visited.add(op)
                to_visit.append(op)

print(f"\nConnected component of ground state: {len(visited)} elements")
print(f"Total elements in T: {T.cardinality()}")

# Compute energy-graded character grouped by profiles
energy_by_right = defaultdict(lambda: R(0))
energy_by_left = defaultdict(lambda: R(0))
energy_total = R(0)

for elem in visited:
    e = elem.energy_function()
    b1 = elem[1]  # rightmost
    b2 = elem[0]  # leftmost
    p1 = elem_to_profile(b1)
    p2 = elem_to_profile(b2)
    energy_by_right[p1] += q^e
    energy_by_left[p2] += q^e
    energy_total += q^e

print(f"\nTotal energy sum: {energy_total + O(q^20)}")

print("\nBy profile of b_1 (right end):")
for p in sorted(energy_by_right.keys()):
    s = energy_by_right[p]
    print(f"  {p}: {s + O(q^20)}, sum={s.polynomial()(1)}")

print("\nBy profile of b_2 (left end):")
for p in sorted(energy_by_left.keys()):
    s = energy_by_left[p]
    print(f"  {p}: {s + O(q^20)}, sum={s.polynomial()(1)}")

# Compare with Q_2 and P_2
print("\n=== Comparison with Q_2((2,1,1)) ===")
print("Q_2((2,1,1)) = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12")
print(f"Q_2(1) = 16")

# And P_2((2,1,1)):
# P_2 = (q;q)_2 * F_{c,2} 
# Need to compute this separately.

# The FULL tensor product B^{1,4}^{tensor 2} has 225 elements.
# The connected component of the ground state for Lambda=(2,1,1) 
# gives us a specific subcrystal. Let's see how it compares.

# Now try a DEMAZURE subcrystal (only f operators, not e):
demazure = set()
to_visit_d = deque([gs])
demazure.add(gs)

while to_visit_d:
    elem = to_visit_d.popleft()
    for i in [0, 1, 2]:
        fi = elem.f(i)
        if fi is not None and fi not in demazure:
            demazure.add(fi)
            to_visit_d.append(fi)

print(f"\nDemazure subcrystal (f only): {len(demazure)} elements")

# Energy of Demazure elements
dem_energy = R(0)
dem_by_right = defaultdict(lambda: R(0))
for elem in demazure:
    e = elem.energy_function()
    b1 = elem[1]
    p1 = elem_to_profile(b1)
    dem_energy += q^e
    dem_by_right[p1] += q^e

print(f"Demazure energy sum: {dem_energy + O(q^20)}")
print(f"Demazure energy sum at q=1: {dem_energy.polynomial()(1)}")

print("\nDemazure by profile of b_1:")
for p in sorted(dem_by_right.keys()):
    s = dem_by_right[p]
    print(f"  {p}: {s + O(q^20)}")

