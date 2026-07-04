K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 2)
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

print("=== Ground state paths for level 2, A_2^(1) ===")
for Lambda_profile in [(2,0,0), (1,1,0), (0,0,2)]:
    b1 = None
    for b in elems:
        if phi_map[b] == Lambda_profile:
            b1 = b
            break
    if b1 is None:
        print(f"  Lambda={Lambda_profile}: no b1 found")
        continue
    path = [b1]
    cur = b1
    for step in range(8):
        next_phi = eps_map[cur]
        next_b = None
        for b in elems:
            if phi_map[b] == next_phi:
                next_b = b
                break
        if next_b is None:
            print(f"  Lambda={Lambda_profile}: chain broke at step {step}")
            break
        path.append(next_b)
        cur = next_b
    path_p = [elem_to_profile(b) for b in path]
    print(f"  Lambda={Lambda_profile}: GS = {path_p}")

# Now let's enumerate ALL paths of length n and compute energy-graded sums
# grouped by the Lambda (= phi(b_1) = highest weight)

# The energy function for a path (b_1,...,b_n) is:
# D = sum_{k=1}^{n-1} H(b_{k+1} tensor b_k)
# where H is the local energy function.

# Compute H matrix
T2 = crystals.TensorProduct(K, K)
H = {}
for b1 in elems:
    for b2 in elems:
        t = T2(b1, b2)
        H[(b1, b2)] = t.energy_function()

print("\n=== Energy matrix ===")
print("H(b1 tensor b2), rows=b1, cols=b2, indexed by profile:")
for b1 in elems:
    p1 = elem_to_profile(b1)
    row = [H[(b1,b2)] for b2 in elems]
    print(f"  {p1}: {row}")

# Enumerate all VALID paths of length n (with matching condition)
# p = (b_1, b_2, ..., b_n) with eps(b_k) = phi(b_{k+1})
# grouped by Lambda = phi(b_1) and the "ending" profile = profile(b_n)

from collections import defaultdict

for n_val in [1, 2, 3]:
    print(f"\n=== Valid paths of length {n_val} ===")
    
    # DP: paths[k] = dict mapping b_k -> {Lambda: sum_q}
    # or better: directly accumulate
    
    # Start: paths of length 1 are just single elements
    if n_val == 1:
        for Lambda_p in [(2,0,0), (1,1,0), (0,0,2)]:
            b1 = None
            for b in elems:
                if phi_map[b] == Lambda_p:
                    b1 = b
                    break
            print(f"  Lambda={Lambda_p}: sum = 1 (single element b1={elem_to_profile(b1)})")
        continue
    
    # For length n: enumerate all valid paths (b_1,...,b_n)
    # with eps(b_k) = phi(b_{k+1}) for k=1,...,n-1
    # Energy = sum H(b_{k+1}, b_k) for k=1,...,n-1
    
    # DP approach: dp[k][b_k] = sum over valid paths (b_1,...,b_k) with 
    # specific Lambda = phi(b_1) of q^{energy}
    # Indexed by (Lambda, b_k)
    
    dp = defaultdict(lambda: R(0))
    
    # k=1: dp[(Lambda, b_1)] = 1 if phi(b_1) = Lambda
    for b in elems:
        Lambda_p = phi_map[b]
        dp[(Lambda_p, b)] = R(1)
    
    for k in range(2, n_val + 1):
        new_dp = defaultdict(lambda: R(0))
        for (Lambda_p, b_prev), val in dp.items():
            if val == 0:
                continue
            # b_prev = b_{k-1}, need b_k with phi(b_k) = eps(b_{k-1})
            needed_phi = eps_map[b_prev]
            for b_next in elems:
                if phi_map[b_next] == needed_phi:
                    # Energy contribution: H(b_next, b_prev)
                    h = H[(b_next, b_prev)]
                    new_dp[(Lambda_p, b_next)] += val * q^h
        dp = new_dp
    
    # Sum over ending elements, grouped by Lambda and ending profile
    sums_by_Lambda = defaultdict(lambda: R(0))
    sums_by_Lambda_profile = defaultdict(lambda: R(0))
    
    for (Lambda_p, b_end), val in dp.items():
        sums_by_Lambda[Lambda_p] += val
        end_profile = elem_to_profile(b_end)
        sums_by_Lambda_profile[(Lambda_p, end_profile)] += val
    
    print(f"  Totals by Lambda (sum over all ending profiles):")
    for Lambda_p in sorted(sums_by_Lambda.keys()):
        s = sums_by_Lambda[Lambda_p]
        print(f"    Lambda={Lambda_p}: {s + O(q^15)}, at q=1: {s.polynomial()(1)}")
    
    print(f"  By (Lambda, ending profile):")
    for key in sorted(sums_by_Lambda_profile.keys()):
        s = sums_by_Lambda_profile[key]
        if s != 0:
            print(f"    Lambda={key[0]}, end={key[1]}: {s + O(q^15)}")

# Compare with known Q_n values for d=2
print("\n=== Known Q_n for d=2 (from CW computation) ===")
print("  Q_1((1,1,0)) = q")
print("  Q_1((2,0,0)) = q^2")
print("  Q_1((0,0,2)) = q")
print("  Q_2((1,1,0)) = q^4")
print("  Q_2((2,0,0)) = q^6")
print("  Q_3((1,1,0)) = q^9")

# For d=2, Q_n(c) = q^{n^2} for some profiles and q^{2n^2/...} for others.
# This is VERY sparse. Let me check if there's a simpler characterization.

# Actually for d=2:
# Q_n((1,1,0)) = q^{n^2}  (checked n=1,2,3)
# Q_n((2,0,0)) = q^{2n^2}???  No, Q_1 = q^2, Q_2 = q^6, Q_3 = q^{12}
# Q_n((2,0,0)) = q^{n(n+1)} since 2, 6, 12 = 1*2, 2*3, 3*4
# Hmm wait: n=1: q^2, n=2: q^6, n=3: q^12. Pattern: n=1: q^2, n=2: q^{6}, n=3: q^{12}
# Differences: 2, 4, 6 -> arithmetic. So Q_n = q^{n(n+1)} for (2,0,0)?
# n(n+1): 2, 6, 12. Yes!
# And for (1,1,0): Q_n = q^{n^2}. n^2: 1, 4, 9. Yes!

