"""
Seed 5, Layer 3: GL_3 Demazure character (key polynomial) decomposition of Q_{n,c}(q).
Uses SageMath's WeylCharacterRing for A2.
"""

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

# WeylCharacterRing for A2 = sl_3
A2 = WeylCharacterRing("A2", style="coroots")

# Demazure characters for GL_3 using crystal bases
# K_u(x1,x2,x3) for u = (u1,u2,u3) is the key polynomial.
# In the coroot notation for A2, dominant weights are (a,b) corresponding to
# a*omega_1 + b*omega_2, where omega_1, omega_2 are fundamental weights.
# The GL_3 weight (u1,u2,u3) corresponds to:
# In terms of simple roots: alpha_1 = e_1 - e_2, alpha_2 = e_2 - e_3
# Fundamental weights: omega_1 = e_1, omega_2 = e_1 + e_2
# Weight (u1,u2,u3) = u1*e_1 + u2*e_2 + u3*e_3
# = (u1-u2)*omega_1 + (u2-u3)*omega_2 + u3*(e_1+e_2+e_3)
# Since e_1+e_2+e_3 = det (central in GL_3), for SL_3 it acts trivially.
# So (u1,u2,u3) maps to ((u1-u2), (u2-u3)) in coroot notation IF u1>=u2>=u3.

# For Demazure characters of non-dominant weights, we need the crystal approach.
# K_u = sum over Demazure crystal of weight u of x^{wt(b)}

# Let's use crystals directly.
def key_poly_via_crystal(u, q_val):
    """
    Compute K_u(q, q^2, q^3) using SageMath's crystal machinery.
    u = (u1, u2, u3) is a composition (not necessarily dominant).
    """
    # Sort u to get the dominant weight
    lam = tuple(sorted(u, reverse=True))
    # The dominant weight in coroot notation for A2
    coroot_wt = (lam[0] - lam[1], lam[1] - lam[2])

    # Build crystal of type A2 with this highest weight
    if coroot_wt == (0, 0):
        # Trivial representation
        return q_val**sum(u) if u == (0,0,0) else 0

    C = crystals.Tableaux("A2", shape=[lam[0]-lam[2], lam[1]-lam[2]])

    # Compute K_u: Demazure crystal corresponding to weight u
    # We need to find the permutation w such that w(lam) = u
    # Then K_u = sum over elements in Demazure crystal B_w(lam)

    # Find the permutation: u is a permutation of lam
    # Sorted indices
    from itertools import permutations
    target = list(u)
    source = list(lam)

    # Find permutation w such that w applied to source gives target
    w = None
    for p in permutations(range(3)):
        if all(source[p[i]] == target[i] for i in range(3)):
            w = p
            break

    if w is None:
        return None  # u is not a permutation of a dominant weight

    # Convert permutation to Weyl group element
    W = WeylGroup("A2", prefix="s")

    # Map permutation (in S_3) to Weyl group element
    # S_3 permutations: (0,1,2) = id, (1,0,2) = s1, (0,2,1) = s2,
    # (2,0,1) = s1s2, (1,2,0) = s2s1, (2,1,0) = s1s2s1 = w0
    perm_to_weyl = {
        (0,1,2): W.one(),
        (1,0,2): W.simple_reflections()[1],
        (0,2,1): W.simple_reflections()[2],
    }

    s1 = W.simple_reflections()[1]
    s2 = W.simple_reflections()[2]

    # Build all elements
    perm_map = {}
    for w_elem in W:
        # w_elem acts on weights. For the natural representation:
        # s1 swaps positions 1,2; s2 swaps positions 2,3
        # We need the permutation on coordinates.
        mat = w_elem.matrix()
        # omega_1 -> e_1, omega_2 -> e_1 + e_2
        # Coroot action on GL_3 weights...
        # Actually, let's just enumerate
        pass

    # Simpler approach: directly compute Demazure characters from the crystal
    # using the Demazure operator

    # For u not dominant, K_u = pi_{i1} pi_{i2} ... pi_{ik} (x^lam)
    # where s_{i1}...s_{ik} is a reduced word for the permutation bringing lam to u.

    # Alternative: just enumerate ALL elements in the crystal and compute
    # their weights, then manually select the Demazure subcrystal.

    # For simplicity, let me compute ALL key polynomials K_u at the specialization
    # (q, q^2, q^3) by directly using the crystal structure.

    # Weight of a tableau element b: wt(b) = (w1, w2, w3) where wi = # of i's in b
    # At specialization (q, q^2, q^3): monomial value = q^{w1 + 2*w2 + 3*w3}

    # The Demazure subcrystal B_w(lam) consists of elements reachable from
    # the highest weight element by applying f_i operators in a specific pattern
    # determined by w.

    # For GL_3/SL_3 with 3 elements in S_3, let me enumerate:

    # First, list all crystal elements
    elements = list(C)

    # Shift: add (lam[2], lam[2], lam[2]) back (since we subtracted it for the shape)
    shift = lam[2]

    all_weights = {}
    for b in elements:
        wt = b.weight()
        # wt is in the weight lattice of A2
        # Convert to GL_3 coordinates: (w1, w2, w3)
        # wt = w1*e1 + w2*e2 + w3*e3, where e1-e2 = alpha_1, e2-e3 = alpha_2
        # In SageMath's convention for A2 tableaux:
        # weight of entry i is e_i
        # So wt(b) already gives us coefficients in the fundamental weight basis

        # For tableaux of type A2: entries are 1,2,3
        # weight = (#1's)*epsilon_1 + (#2's)*epsilon_2 + (#3's)*epsilon_3
        # In the ambient space, this is already a GL_3 weight.

        # SageMath gives weight in terms of the weight lattice.
        # For type A2: wt = a*Lambda_1 + b*Lambda_2
        # Lambda_1 = (2/3, -1/3, -1/3), Lambda_2 = (1/3, 1/3, -2/3) in epsilon basis
        # epsilon_1 = Lambda_1 + (1/3,1/3,1/3)

        # Actually for tableaux, the weight function returns in ambient coordinates
        # Let me just count entries
        pass

    # Better: use a completely different, simpler approach.
    # Compute key polynomials directly via Demazure operators.
    return None

def demazure_operator(f, i, vars):
    """
    Apply the i-th Demazure operator pi_i to polynomial f.
    pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})
    where s_i swaps x_i and x_{i+1}.
    """
    x = vars
    n = len(x)
    assert 0 <= i < n - 1

    # s_i(f): swap x_i and x_{i+1} in f
    swap_dict = {x[j]: x[j] for j in range(n)}
    swap_dict[x[i]] = x[i+1]
    swap_dict[x[i+1]] = x[i]

    f_swapped = f.subs(swap_dict)

    # pi_i(f) = (x_i * f - x_{i+1} * f_swapped) / (x_i - x_{i+1})
    num = x[i] * f - x[i+1] * f_swapped
    result = num // (x[i] - x[i+1])

    return result

def key_polynomial(u):
    """
    Compute K_u(x1, x2, x3) for composition u = (u1, u2, u3).
    Uses the recursive definition via Demazure operators.
    """
    Rpoly = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
    x1, x2, x3 = Rpoly.gens()
    x = [x1, x2, x3]

    # Start with x^{sort(u)} and apply Demazure operators
    lam = sorted(u, reverse=True)

    # If u is dominant, K_u = x^u
    if list(u) == lam:
        return x1**u[0] * x2**u[1] * x3**u[2]

    # Find the permutation w such that w(lam) = u
    # Then K_u = pi_w(x^lam) where pi_w = pi_{i1} ... pi_{ik} for reduced word

    # For n=3, find which swaps are needed
    # Permutations of 3 elements: at most 3 simple transpositions

    # Build permutation: w(lam) = u means w permutes coordinates
    lam_list = list(lam)
    u_list = list(u)

    # Find w in one-line notation: if lam = (a,b,c) and u = (?,?,?)
    # w(i) = j means position j of lam goes to position i of u
    # e.g., if lam = (3,2,1) and u = (2,3,1), then w = (2,1,3) in one-line

    # Handle repeated entries
    from itertools import permutations
    best_w = None
    best_len = 100

    for perm in permutations(range(3)):
        if all(lam_list[perm[i]] == u_list[i] for i in range(3)):
            # Count inversions (length of permutation)
            inv = sum(1 for a in range(3) for b in range(a+1, 3) if perm[a] > perm[b])
            if inv < best_len:
                best_w = perm
                best_len = inv

    if best_w is None:
        return None

    # Find reduced word for permutation best_w
    # Permutations of {0,1,2}: bubble sort gives reduced word
    w = list(best_w)
    word = []
    while w != [0, 1, 2]:
        for i in range(2):
            if w[i] > w[i+1]:
                w[i], w[i+1] = w[i+1], w[i]
                word.append(i)
                break

    # Reverse to get the right order (we sorted back to identity, so reverse)
    word.reverse()

    # Apply Demazure operators
    f = x1**lam[0] * x2**lam[1] * x3**lam[2]
    for i in word:
        f = demazure_operator(f, i, x)

    return f

def specialize_key(K_poly, q_val):
    """Specialize K(x1,x2,x3) at x1=q, x2=q^2, x3=q^3."""
    if K_poly is None:
        return None
    Rpoly = K_poly.parent()
    x1, x2, x3 = Rpoly.gens()

    result = R_poly(0)
    for exp, coeff in K_poly.dict().items():
        # exp is a tuple (e1, e2, e3)
        if isinstance(exp, (list, tuple)):
            e1, e2, e3 = exp
        else:
            e1 = exp.get(x1, 0) if hasattr(exp, 'get') else 0
            e2 = exp.get(x2, 0) if hasattr(exp, 'get') else 0
            e3 = exp.get(x3, 0) if hasattr(exp, 'get') else 0
        result += coeff * q_val**(e1 + 2*e2 + 3*e3)

    return result

# Test: compute some key polynomials
print("Testing key polynomial computation:")
for u in [(1,0,0), (0,1,0), (0,0,1), (2,0,0), (0,2,0), (0,0,2), (1,1,0), (0,1,1), (1,0,1)]:
    K = key_polynomial(u)
    K_spec = specialize_key(K, q_var)
    print(f"  K_{u} = {K}")
    print(f"    K_{u}(q,q^2,q^3) = {K_spec}")

# Now enumerate all key polynomials up to a maximum total degree
# and try to decompose Q_1 and Q_2
print()
print("="*60)
print("Key polynomial decomposition of Q_1 for d=7, c=(3,2,2)")
print("="*60)

# Q_1 from our computation
Q1_322 = 2*q_var + 3*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6

# Generate all key polynomials K_u(q,q^2,q^3) with sum(u) <= max_level
max_level = 8
key_polys = {}
for level in range(max_level + 1):
    from itertools import product as iprod
    for u in iprod(range(level+1), repeat=3):
        if sum(u) == level:
            K = key_polynomial(u)
            K_spec = specialize_key(K, q_var)
            if K_spec is not None and K_spec != 0:
                key_polys[u] = K_spec

print(f"Generated {len(key_polys)} key polynomials up to level {max_level}")

# Greedy decomposition of Q_1
residual = Q1_322
decomp = {}
# Try subtracting key polynomials greedily, largest first
sorted_keys = sorted(key_polys.keys(), key=lambda u: (-sum(u), u))

for u in sorted_keys:
    K_spec = key_polys[u]
    if K_spec == 0:
        continue
    # How many times can we subtract K_spec from residual?
    while True:
        test = residual - K_spec
        # Check if test has all nonneg coefficients
        if test == 0:
            decomp[u] = decomp.get(u, 0) + 1
            residual = test
            break
        coeffs = test.coefficients()
        if all(c >= 0 for c in coeffs):
            decomp[u] = decomp.get(u, 0) + 1
            residual = test
        else:
            break
    if residual == 0:
        break

if residual == 0:
    print("SUCCESS: Q_1 decomposes into key polynomials!")
    total_dim = 0
    for u, mult in sorted(decomp.items()):
        dim = key_polys[u](q=1) if key_polys[u] != 0 else 0
        total_dim += mult * dim
        print(f"  {mult} * K_{u}  (dim={dim})")
    print(f"  Total dimension: {total_dim} (should be {Q1_322(q=1)})")
else:
    print(f"Greedy decomposition incomplete. Residual = {residual}")

# Also try Q_1 for c=(4,2,1)
print()
print("="*60)
print("Key polynomial decomposition of Q_1 for d=7, c=(4,2,1)")
print("="*60)

Q1_421 = 2*q_var + 2*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6 + q_var**8

residual = Q1_421
decomp = {}
sorted_keys = sorted(key_polys.keys(), key=lambda u: (-sum(u), u))

for u in sorted_keys:
    K_spec = key_polys[u]
    if K_spec == 0:
        continue
    while True:
        test = residual - K_spec
        if test == 0:
            decomp[u] = decomp.get(u, 0) + 1
            residual = test
            break
        coeffs = test.coefficients()
        if all(c >= 0 for c in coeffs):
            decomp[u] = decomp.get(u, 0) + 1
            residual = test
        else:
            break
    if residual == 0:
        break

if residual == 0:
    print("SUCCESS: Q_1 decomposes into key polynomials!")
    total_dim = 0
    for u, mult in sorted(decomp.items()):
        dim = key_polys[u](q=1) if key_polys[u] != 0 else 0
        total_dim += mult * dim
        print(f"  {mult} * K_{u}  (dim={dim})")
    print(f"  Total dimension: {total_dim} (should be {Q1_421(q=1)})")
else:
    print(f"Greedy decomposition incomplete. Residual = {residual}")
    print(f"  Remaining terms: {residual}")
