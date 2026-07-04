"""
Seed 5, Layer 3: Compute the character of the [1,2] Demazure crystal
and compare with h_1 and Q_1 for c=(3,2,2), d=7.

Word [1,2] gives 12 elements. h_1(1) = 12.
"""

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

C = crystals.LSPaths(['A',2,1], [3,2,2])
hw = list(C.highest_weight_vectors())[0]

def build_demazure_word(root, word, max_size=50000):
    elements = {root}
    for i in reversed(word):
        new_elements = set(elements)
        for b in list(elements):
            current = b
            while True:
                next_b = current.f(i)
                if next_b is None or next_b in new_elements:
                    break
                new_elements.add(next_b)
                current = next_b
                if len(new_elements) > max_size:
                    return new_elements
        elements = new_elements
    return elements

# Build the [1,2] Demazure crystal
elems_12 = build_demazure_word(hw, [1, 2])
print(f"Demazure crystal for word [1,2]: {len(elems_12)} elements")

# Get the weight lattice
WL = RootSystem(['A',2,1]).weight_lattice()
Lambda = WL.fundamental_weights()
delta = WL.null_root()

print(f"\nWeights of all {len(elems_12)} elements:")
hw_wt = hw.weight()
print(f"Highest weight: {hw_wt}")
print(f"Level = {hw_wt.level()}")

# For each element, compute the weight and the "energy" (delta coefficient)
weight_data = []
for b in elems_12:
    wt = b.weight()
    # Extract coefficients in terms of Lambda_0, Lambda_1, Lambda_2
    # and the imaginary root delta

    # In SageMath's weight lattice for affine type,
    # wt = sum a_i Lambda_i + n*delta
    # We can extract n as the "null root coefficient"

    # The weight can be decomposed as:
    # finite part: a_1 Lambda_1 + a_2 Lambda_2 (mod Lambda_0 and delta)
    # level: a_0 + a_1 + a_2 = d = 7
    # energy: coefficient of delta

    # For principal specialization: q^{-n_delta}
    # where n_delta is the coefficient of delta in the weight

    # Extract components
    d_coeff = wt.scalar(WL.null_coroot())  # This might give the level
    # Actually the null coroot for A_2^(1) is alpha_0^vee + alpha_1^vee + alpha_2^vee
    # and <Lambda_i, null_coroot> = 1 for all i, <delta, null_coroot> = 0

    # So wt.scalar(null_coroot) = level = 7 for all elements (level is preserved)

    # To get the delta coefficient, we need a different approach.
    # The weight lattice element can be written as:
    # wt = a_0 Lambda_0 + a_1 Lambda_1 + a_2 Lambda_2 + n delta

    # SageMath stores weights in the weight lattice.
    # Let me try to extract the coefficients.

    coeffs = {}
    for key, val in wt:
        coeffs[str(key)] = val

    weight_data.append((b, wt, coeffs))

# Print the weights
for b, wt, coeffs in weight_data:
    print(f"  {wt}")

# Let me try a different approach: use the energy function from the crystal
print("\n" + "="*60)
print("Energy function analysis")
print("="*60)

# For LS paths, there's an energy function D(b) that gives the grading
# Let me check if SageMath provides this
for b in list(elems_12)[:5]:
    print(f"  Element weight: {b.weight()}")
    # Check for energy function
    try:
        e = b.energy_function()
        print(f"  Energy: {e}")
    except:
        pass
    try:
        e = b.epsilon(0) + b.epsilon(1) + b.epsilon(2)
        print(f"  Sum epsilon: {e}")
    except:
        pass

    # The phi and epsilon functions
    for i in [0, 1, 2]:
        print(f"    phi_{i} = {b.phi(i)}, epsilon_{i} = {b.epsilon(i)}")

# Alternative approach to grading: use the degree function
# For the principal specialization of hat{sl}_3, the q-grading comes from
# the null root delta.
# wt = finite_part + n*delta, and q-degree = -n (relative to highest weight)

# The weight of hw is 3*Lambda_0 + 2*Lambda_1 + 2*Lambda_2
# For other elements, wt = something + n*delta
# The q-degree is: <hw_wt - wt, d_vec> where d_vec is related to the null root

# In affine type A_2^(1):
# delta = alpha_0 + alpha_1 + alpha_2
# The "depth" of a weight relative to hw is the coefficient of delta in (hw - wt)

# Let me compute this using the root system
RS = RootSystem(['A',2,1])
WL = RS.weight_lattice()
AL = RS.root_lattice()

# Simple roots
alpha = AL.simple_roots()
# Simple coroots
alpha_vee = RS.coroot_lattice().simple_roots()

# For each element, compute the "depth" = number of delta's below hw
print("\n" + "="*60)
print("Computing depth of each element")
print("="*60)

# The difference hw_wt - wt should be in the positive root cone
# We can compute the coefficient of delta as follows:
# If hw_wt - wt = sum n_i alpha_i + m*delta, then m = ...

# Actually, for LS paths with weight in the weight lattice,
# the weight is expressed directly. Let me try to extract delta coefficient.

# In SageMath: for the weight lattice of ['A',2,1],
# the basis elements are Lambda[0], Lambda[1], Lambda[2]
# and delta (the null root in the weight lattice)

# Let's check:
print(f"delta in weight lattice: {delta}")
print(f"Lambda[0] = {Lambda[0]}")

# Can we decompose?
for b, wt, _ in weight_data:
    # Compute wt - hw_wt
    diff = wt - hw_wt
    # diff should be in the root lattice (as a weight)
    # For affine type: diff = sum n_i alpha_i
    # where alpha_i = 2*Lambda_i - Lambda_{i-1} - Lambda_{i+1} (for A_2^(1))
    # and delta = alpha_0 + alpha_1 + alpha_2

    # Express diff in terms of simple roots
    # Actually, let me just look at the Lambda coefficients
    # wt = a0 Lambda_0 + a1 Lambda_1 + a2 Lambda_2
    # diff = (a0-3) Lambda_0 + (a1-2) Lambda_1 + (a2-2) Lambda_2
    # Since diff is in the root lattice, and Lambda_i are NOT in the root lattice,
    # this means the diff involves delta too.

    # Let me try: wt - hw_wt = n0 alpha_0 + n1 alpha_1 + n2 alpha_2
    # where alpha_0 = 2Lambda_0 - Lambda_1 - Lambda_2 + delta
    # alpha_1 = -Lambda_0 + 2Lambda_1 - Lambda_2
    # alpha_2 = -Lambda_0 - Lambda_1 + 2Lambda_2

    # Hmm, this is getting complicated. Let me just look at the scalar products.
    pass

# Simpler approach: just look at how many times we applied f_i
# The depth = total number of f operators applied to reach this element

# Actually, for LS paths, there's a much simpler grading:
# the "string length" or "distance from highest weight in the crystal graph"

# Let me compute distance from hw using BFS
from collections import deque
dist = {hw: 0}
queue = deque([hw])
while queue:
    b = queue.popleft()
    for i in [0, 1, 2]:
        b_next = b.f(i)
        if b_next is not None and b_next in elems_12 and b_next not in dist:
            dist[b_next] = dist[b] + 1
            queue.append(b_next)

# Distribution of distances
from collections import Counter
dist_counts = Counter(dist.values())
print(f"\nDistance distribution from hw in Demazure crystal [1,2]:")
for d_val in sorted(dist_counts.keys()):
    print(f"  distance {d_val}: {dist_counts[d_val]} elements")
print(f"  Total: {sum(dist_counts.values())}")

# Now let me try: for the [1,2] Demazure crystal, the character should be
# related to h_1. h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
# Total h_1(1) = 12.

# The distribution above tells us how many elements are at each "distance"
# from hw. If distance maps to q-degree, the character is:
# sum_{d} count_d * q^d

# Let me also check what happens with the [1,2,0,1,2] word (dim=2916)
# since h_2(1) = 144 and Q_2(1) = 121

print("\n" + "="*60)
print("Larger Demazure crystals")
print("="*60)

# Key hypothesis: 
# Word s_1 s_2 corresponds to depth 1 -> h_1
# Word s_1 s_2 s_0 corresponds to some deeper structure
# The CW functional equation relates depth N to depth N-1 via the affine reflection s_0

# For Q_n: we need to subtract (the (zq;q)_inf factor).
# The alternating sum Q_n = sum (-1)^j q^{j(j+1)/2} [n choose j] h_{n-j}
# is the finite type character extraction from the affine character.

# This suggests:
# - The FULL affine module character (at principal specialization) is F_c(z,q)
# - The finite-type extraction (multiplying by (zq;q)_inf) gives Q_{n,c}(q)
# - The Demazure module at word w_n gives h_n

# So it's h_n (not Q_n) that should match Demazure characters directly!

# Let me verify: [1,2] gives dim 12 = h_1(1) = 12. Check!
# What about [1,2,0,1,2]? Should this give h_2?
# h_2(1) = 144 but dim([1,2,0,1,2]) = 2916. Not matching.

# What about nested Demazure? Apply [1,2] then [0] then [1,2]?
# This is the word [1,2,0,1,2] which gives 2916. Not 144.

# So the word [1,2] -> dim 12 = h_1(1) is suggestive but the pattern
# for h_2 is not straightforward.

# Let me try: the Demazure module for the translation element.
# In A_2^(1), the translation by omega_1 is t_{omega_1} = s_0 s_1
# (in the affine Weyl group notation)

# So t_{omega_1}^n is (s_0 s_1)^n, corresponding to the word [0,1,0,1,...,0,1]

for n in range(1, 6):
    word = [0, 1] * n  # (s_0 s_1)^n
    elems = build_demazure_word(hw, word, max_size=200000)
    print(f"  Word {word}: dim = {len(elems)}")

# Try (s_1 s_2)^n
for n in range(1, 6):
    word = [1, 2] * n
    elems = build_demazure_word(hw, word, max_size=200000)
    print(f"  Word {word}: dim = {len(elems)}")

# Try s_1 s_0 repeated (this is t_{Lambda_1} in some conventions)
for n in range(1, 5):
    word = [1, 0] * n
    elems = build_demazure_word(hw, word, max_size=200000)
    print(f"  Word {word}: dim = {len(elems)}")

print("\n")
# Important: for hat{sl}_3, we need a specific word related to n
# The key formulae: in A_2^(1), the Coxeter element is s_0 s_1 s_2 (length 3)
# The translation elements are products of reflections:
# In the extended affine Weyl group: t_{\Lambda_1} = \tau s_0 (if \tau is the diagram automorphism)
# But for A_2^(1), the outer automorphism \tau cycles 0->1->2->0
# So t_{\Lambda_0} = s_0 \tau^{-1} is not a product of simple reflections alone.

# Let me try the specific word that I think should give the right answer:
# For c=(3,2,2), the Demazure module at depth n might need the word
# (s_2 s_1 s_0)^n * something, or a word tuned to the profile.

# Actually, let me think about this differently.
# The cylindric partition with max <= n has n "layers" (each layer adds values up to n).
# The CW recurrence adds one layer at a time, using the shifted profiles via s_0.
# So the natural word should involve s_0 (the affine reflection) for depth.

# Dimension pattern needed:
# h_0(1) = 1, h_1(1) = 12, h_2(1) = 144, h_3(1) = 1728
# These are 12^m. So each "depth step" multiplies dim by 12 = base+1 = (d+1)(d+2)/6.

# No standard Demazure crystal has exponential growth with a short word.
# The growth with word [1,2] repeated:
# [1,2]: 12
# [1,2,1,2]: ? 
# If it grows exponentially, that would match.

# Also: in the theory of Kirillov-Reshetikhin crystals (KR crystals),
# the tensor product B^{r,1} ⊗ ... ⊗ B^{r,1} (n times) gives a crystal whose
# dimension is (dim B^{r,1})^n. For A_2^(1) at level d=7, B^{1,1} might give the
# right dimension.

# Let me check KR crystals
print("="*60)
print("Kirillov-Reshetikhin crystals for A_2^(1)")
print("="*60)

try:
    for r in [1, 2]:
        for s in [1, 2, 3]:
            KR = crystals.KirillovReshetikhin(['A',2,1], r, s)
            dim = KR.cardinality()
            print(f"  B^{{{r},{s}}}: dim = {dim}")
except Exception as e:
    print(f"  Error: {e}")

# The standard representation has dim 3 for sl_3.
# For level-d representations, we might need KR crystals B^{r,s} with
# specific r,s related to d.

# Actually, let me try B^{1,1}^{tensor n}: this should give 3^n for A_2.
# But we need 12^n... So we need a different crystal.

# For the level-d module: the multiplicity of the weight space might give
# the right answer. Let me think about this differently.

# The key insight from the literature (Schilling, Shimozono):
# cylindric partitions of profile c = (c0,c1,c2) with max <= n correspond to
# certain paths in the affine crystal B(Lambda) where Lambda = sum c_i Lambda_i.
# The generating function F_{c,n}(q) is the principally specialized character
# of the Demazure module B_{w_n}(Lambda).

# The word w_n should be a specific n-fold product of affine reflections.
# For k=3: the word should involve all three reflections cyclically.

# From Schilling-Shimozono theory (level-restricted paths):
# The one-dimensional sum (1dsum) equals the principally specialized
# Demazure character, where the Demazure module is cut out by
# the affine Weyl group element t_{-lambda} where lambda is a specific weight.

# For our case: F_{c,n}(q) should be the character of B_{t_mu^n}(Lambda)
# for some translation element t_mu.

# The translation by Lambda_0 in A_2^(1) is:
# t_{Lambda_0} corresponds to the word s_0 (s_1 s_2 s_1)^? 
# This is getting complicated. Let me try to just match dimensions.

# Search for words giving dim 12^n
print("\n" + "="*60)
print("Searching for words giving dimensions 12, 144, 1728...")
print("="*60)

# We know [1,2] -> 12. Now search words of length 4-6 giving 144.
from itertools import product as iprod

# Only try a subset to keep runtime manageable
for length in [4, 5]:
    found = False
    for word in iprod([0,1,2], repeat=length):
        word = list(word)
        # Check if it's a valid reduced word (no consecutive repeats)
        valid = True
        for i in range(len(word)-1):
            if word[i] == word[i+1]:
                valid = False
                break
        if not valid:
            continue

        elems = build_demazure_word(hw, word, max_size=200)
        if len(elems) == 144:
            print(f"  FOUND! Word {word}: dim = 144 = 12^2")
            found = True
        elif len(elems) == 12:
            pass  # Already known
    if found:
        break

if not found:
    print("  No word of length <= 5 gives dim 144")
