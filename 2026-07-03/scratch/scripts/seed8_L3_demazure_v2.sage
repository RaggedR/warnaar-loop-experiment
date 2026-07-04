"""
Seed 8, Layer 3: Demazure character check using weight SPACE (not lattice).
"""
print("="*80)
print("Demazure character computation for A_2^(1)")
print("="*80)

# Fix: Use weight_space instead of weight_lattice
ct = CartanType(['A', 2, 1])
P = RootSystem(ct).weight_space(extended=True)
Lambda = P.fundamental_weights()
alpha = P.simple_roots()

# For d=4, profile c=(2,1,1)
print("\n--- d=4, c=(2,1,1) ---")
lam = 2*Lambda[0] + Lambda[1] + Lambda[2]
print(f"Lambda = {lam}, level = {lam.level()}")

C = crystals.LSPaths(lam)
hw_list = list(C.highest_weight_vectors())
hw = hw_list[0]
print(f"HW vector: {hw}")

# Demazure subcrystal enumeration
# For A_2^(1), the Coxeter element is s_0 s_1 s_2.
# The n-th power of the Coxeter element gives a word of length 3n.

print("\nDemazure subcrystals (Coxeter word [0,1,2]^n):")
for depth in range(1, 10):
    word = [i % 3 for i in range(3*depth)]
    try:
        D = C.demazure_subcrystal(hw, word)
        elts = list(D)
        n_elts = len(elts)
        
        # For d=4: base = 5-1 = 4, h_m(1) = 5^m
        # Matching: 5 = h_1, 25 = h_2, 4 = Q_1, 16 = Q_2
        marker = ""
        if n_elts in [4, 5, 16, 25, 64, 125, 256, 625, 1024, 3125]:
            marker = " ***"
        print(f"  depth={depth} (word_len={3*depth}): {n_elts} elements{marker}")
        
        if n_elts > 1000:
            break
    except Exception as e:
        print(f"  depth={depth}: ERROR - {str(e)[:80]}")
        break

# Try reverse Coxeter
print("\nReverse Coxeter word [2,1,0]^n:")
for depth in range(1, 10):
    word = [(2-i) % 3 for i in range(3*depth)]
    try:
        D = C.demazure_subcrystal(hw, word)
        elts = list(D)
        n_elts = len(elts)
        marker = ""
        if n_elts in [4, 5, 16, 25, 64, 125, 256, 625, 1024, 3125]:
            marker = " ***"
        print(f"  depth={depth}: {n_elts} elements{marker}")
        if n_elts > 1000:
            break
    except Exception as e:
        print(f"  depth={depth}: ERROR - {str(e)[:80]}")
        break

# Try various word patterns
print("\nOther word patterns:")
words_to_try = {
    "s1s0": [1,0],
    "s2s0": [2,0],
    "s0s2": [0,2],
    "(10)^3": [1,0]*3,
    "(20)^3": [2,0]*3,
    "(120)^2": [1,2,0]*2,
    "(201)^2": [2,0,1]*2,
    "(021)^2": [0,2,1]*2,
    "(102)^2": [1,0,2]*2,
    "(120)^3": [1,2,0]*3,
    "(201)^3": [2,0,1]*3,
    "(102)^3": [1,0,2]*3,
    "(021)^3": [0,2,1]*3,
    "(120)^4": [1,2,0]*4,
    "(201)^4": [2,0,1]*4,
    "0120210": [0,1,2,0,2,1,0],
    "01020102": [0,1,0,2,0,1,0,2],
    "0102012": [0,1,0,2,0,1,2],
}

for name, word in sorted(words_to_try.items()):
    try:
        D = C.demazure_subcrystal(hw, word)
        elts = list(D)
        n_elts = len(elts)
        marker = ""
        if n_elts in [4, 5, 16, 25, 64, 125, 256, 625]:
            marker = " ***"
        print(f"  {name:20s}: {n_elts} elements{marker}")
    except Exception as e:
        print(f"  {name:20s}: ERROR")

# Now try to compute the graded character (principal specialization)
print("\n\n--- Graded character computation ---")

# For the Demazure crystal that matches Q_1(1) = 4 or h_1(1) = 5,
# compute the principal specialization.

# In the affine weight lattice, the grade of element b is defined by:
# wt(b) = lam - sum n_i alpha_i - k delta
# grade = sum n_i (for principal spec e^{-alpha_i} -> q for each i)
# Or alternatively: grade = k (coefficient of delta)

# For LS paths, the weight is expressed in fundamental weights.
# Let's compute it.

# First find the word that gives 5 elements (= h_1(1))
target_words = {}
for depth in range(1, 8):
    for pattern in [[0,1,2], [2,1,0], [1,2,0], [0,2,1], [1,0,2], [2,0,1]]:
        word = pattern * depth
        try:
            D = C.demazure_subcrystal(hw, word)
            elts = list(D)
            n = len(elts)
            if n == 5 and str(pattern) not in target_words:
                target_words[str(pattern)] = (word, elts)
            elif n == 25 and str(pattern)+"_25" not in target_words:
                target_words[str(pattern)+"_25"] = (word, elts)
        except:
            pass

for name, (word, elts) in target_words.items():
    print(f"\nWord pattern {name}, {len(elts)} elements:")
    for b in elts:
        wt = b.weight()
        # Express weight in terms of fundamental weights and delta
        print(f"  {b}: weight = {wt}")
    
    # Compute graded character: group by weight
    weight_dict = {}
    for b in elts:
        wt = b.weight()
        key = str(wt)
        weight_dict[key] = weight_dict.get(key, 0) + 1
    print(f"  Weight distribution: {weight_dict}")

# Also check: what is the character of the full level-4 integrable module?
# This should be an infinite crystal.
print("\n\n--- Full crystal exploration ---")
# Use the subcrystal method to get elements up to depth N from HW
# (BFS in the crystal graph)

from collections import deque

visited = set()
queue = deque()
queue.append((hw, 0))
visited.add(hw)

depth_count = {}
max_depth = 20

while queue:
    b, d_val = queue.popleft()
    if d_val > max_depth:
        continue
    depth_count[d_val] = depth_count.get(d_val, 0) + 1
    
    # Apply crystal operators f_0, f_1, f_2
    for i in [0, 1, 2]:
        b_next = b.f(i)
        if b_next is not None and b_next not in visited:
            visited.add(b_next)
            queue.append((b_next, d_val + 1))

print("Crystal elements by BFS depth from highest weight:")
total = 0
for d_val in sorted(depth_count.keys()):
    total += depth_count[d_val]
    print(f"  depth {d_val}: {depth_count[d_val]} new elements (cumulative: {total})")

# The cumulative count at depth n should match |Demazure crystal| for
# some appropriate word.
print(f"\nCumulative counts: {[sum(depth_count.get(i,0) for i in range(d_val+1)) for d_val in range(min(max_depth+1, max(depth_count.keys())+1))]}")

# Check: does the BFS depth = Demazure depth for some word?
# Compare cumulative counts with Demazure crystal sizes.

print("\n\nDone.")
