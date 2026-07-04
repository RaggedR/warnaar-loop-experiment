# d=4 case: B^{1,4} for A_2^(1) has 15 elements
# Much richer structure than d=2

K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 4)
elems = list(K)
R.<q> = PowerSeriesRing(ZZ, default_prec=100)

def elem_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

eps_map = {}
phi_map = {}
for b in elems:
    eps_map[b] = tuple(b.epsilon(i) for i in [0,1,2])
    phi_map[b] = tuple(b.phi(i) for i in [0,1,2])

# Build phi-to-elements lookup (may have multiple elements with same phi)
from collections import defaultdict
phi_to_elems = defaultdict(list)
for b in elems:
    phi_to_elems[phi_map[b]].append(b)

print("=== B^{1,4} phi values and multiplicity ===")
for phi_val in sorted(phi_to_elems.keys()):
    elts = phi_to_elems[phi_val]
    profiles = [elem_to_profile(b) for b in elts]
    print(f"  phi={phi_val}: {len(elts)} elements, profiles={profiles}")

# Energy matrix
T2 = crystals.TensorProduct(K, K)
H = {}
for b1 in elems:
    for b2 in elems:
        t = T2(b1, b2)
        H[(b1, b2)] = t.energy_function()

# For d=4, the matching condition eps(b_k) = phi(b_{k+1}) now allows CHOICES
# because multiple elements can have the same phi value.

# Let's compute the path sums for length n=1,2 and compare with Q_n

# Ground state paths
print("\n=== Ground states ===")
for Lambda_p in [(2,1,1), (4,0,0), (1,2,1)]:
    b1_list = phi_to_elems[Lambda_p]
    if not b1_list:
        print(f"  Lambda={Lambda_p}: no b1 found")
        continue
    for b1 in b1_list:
        path = [b1]
        cur = b1
        for step in range(8):
            needed_phi = eps_map[cur]
            candidates = phi_to_elems[needed_phi]
            # For ground state, there should be a unique "minimal energy" choice
            # Actually the ground state path is defined to have energy 0
            # It's the unique path satisfying certain conditions
            # For now just show the candidates
            if len(candidates) == 1:
                path.append(candidates[0])
                cur = candidates[0]
            else:
                # Multiple choices - ground state is the one giving 0 energy
                min_e = min(H[(c, cur)] for c in candidates)
                for c in candidates:
                    if H[(c, cur)] == min_e:
                        path.append(c)
                        cur = c
                        break
        
        path_p = [elem_to_profile(b) for b in path]
        print(f"  Lambda={Lambda_p}, b1={elem_to_profile(b1)}: {path_p[:6]}...")

# Now compute valid path sums
print("\n=== Valid path sums for d=4 ===")
for n_val in [1, 2]:
    print(f"\n--- Length {n_val} ---")
    
    dp = defaultdict(lambda: R(0))
    for b in elems:
        dp[(phi_map[b], b)] = R(1)
    
    for k in range(2, n_val + 1):
        new_dp = defaultdict(lambda: R(0))
        for (Lambda_p, b_prev), val in dp.items():
            if val == 0:
                continue
            needed_phi = eps_map[b_prev]
            for b_next in phi_to_elems[needed_phi]:
                h = H[(b_next, b_prev)]
                new_dp[(Lambda_p, b_next)] += val * q^h
        dp = new_dp
    
    sums_by_Lambda = defaultdict(lambda: R(0))
    for (Lambda_p, b_end), val in dp.items():
        sums_by_Lambda[Lambda_p] += val
    
    print("  By Lambda:")
    for Lambda_p in [(2,1,1), (4,0,0), (1,2,1), (0,2,2), (1,1,2)]:
        s = sums_by_Lambda.get(Lambda_p, R(0))
        if s != 0:
            print(f"    Lambda={Lambda_p}: {s + O(q^15)}, q=1: {s.polynomial()(1)}")

# Compare with Q_n for d=4
print("\n=== Q_n for d=4 (computed earlier) ===")
print("  Q_1((2,1,1)) = 2q + q^2 + q^3")
print("  Q_1((4,0,0)) = q^2 + q^3 + q^4 + q^6")
print("  Q_1((1,2,1)) = 2q + q^2 + q^3")
print("  Q_2((2,1,1)) = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12")
print("  Q_2((4,0,0)) = 2q^6 + q^7 + 2q^8 + 2q^9 + 2q^10 + q^11 + 2q^12 + q^13 + q^14 + q^15 + q^18")

# Key question: does Q_n equal some energy-weighted sum over a SUBSET of paths?
# Or some transformed version?

# The Kyoto path energy for length n and Lambda gives a much simpler object
# than Q_n. For d=2, it was just q^(something). For d=4, let's see.

