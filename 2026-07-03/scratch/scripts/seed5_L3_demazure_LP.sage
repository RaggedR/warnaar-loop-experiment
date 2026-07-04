"""
Seed 5, Layer 3: LP-based decomposition of Q into key polynomials.
Also uses SageMath's WeylCharacterRing to get Demazure characters properly.
"""
from itertools import product as iprod
from sage.all import *

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

Rpoly3 = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
x1, x2, x3 = Rpoly3.gens()
xvars = [x1, x2, x3]

def demazure_op(f, i):
    xi, xip1 = xvars[i], xvars[i+1]
    swap = {xvars[j]: xvars[j] for j in range(3)}
    swap[xi] = xip1
    swap[xip1] = xi
    f_s = f.subs(swap)
    num = xi * f - xip1 * f_s
    return Rpoly3(num // (xi - xip1))

def key_polynomial(u):
    lam = sorted(u, reverse=True)
    u_list = list(u)
    lam_list = list(lam)

    if u_list == lam_list:
        return x1**u[0] * x2**u[1] * x3**u[2]

    from itertools import permutations
    best_w = None
    best_len = 100
    for perm in permutations(range(3)):
        if all(lam_list[perm[i]] == u_list[i] for i in range(3)):
            inv = sum(1 for a in range(3) for b in range(a+1,3) if perm[a] > perm[b])
            if inv < best_len:
                best_w = list(perm)
                best_len = inv
    if best_w is None:
        return None

    w = list(best_w)
    word = []
    while w != [0,1,2]:
        for i in range(2):
            if w[i] > w[i+1]:
                w[i], w[i+1] = w[i+1], w[i]
                word.append(i)
                break
    word.reverse()

    f = x1**lam[0] * x2**lam[1] * x3**lam[2]
    for i in word:
        f = demazure_op(f, i)
    return f

def specialize(K_poly):
    if K_poly is None or K_poly == 0:
        return R_poly(0)
    result = R_poly(0)
    for coeff, mon in zip(K_poly.coefficients(), K_poly.monomials()):
        degs = mon.degrees()
        total_q_deg = degs[0]*1 + degs[1]*2 + degs[2]*3
        result += coeff * q_var**total_q_deg
    return result

# Generate key polys
max_level = 12
key_data = {}
for level in range(max_level + 1):
    for u in iprod(range(level+1), repeat=3):
        if sum(u) == level:
            K = key_polynomial(u)
            if K is not None:
                K_q = specialize(K)
                if K_q != 0:
                    key_data[u] = K_q

print(f"Generated {len(key_data)} key polynomials up to level {max_level}")

# Deduplicate: some key polys may give the same specialization
spec_to_keys = {}
for u, K_q in key_data.items():
    key = tuple(K_q.dict().items())
    if key not in spec_to_keys:
        spec_to_keys[key] = []
    spec_to_keys[key].append(u)

# For LP, use unique specializations only
unique_specs = {}
for key, us in spec_to_keys.items():
    rep = min(us)  # canonical representative
    unique_specs[rep] = key_data[rep]

print(f"  {len(unique_specs)} unique specializations")

def decompose_LP(target_poly, key_specs, max_deg):
    """Use LP to find nonneg integer decomposition."""
    from sage.numerical.mip import MixedIntegerLinearProgram

    # Extract coefficient vector of target
    target_coeffs = {}
    for i in range(max_deg + 1):
        c = target_poly[i] if i <= target_poly.degree() else 0
        if c != 0:
            target_coeffs[i] = c

    # Filter key specs to those with max degree <= max_deg
    valid_keys = {}
    for u, K_q in key_specs.items():
        if K_q.degree() <= max_deg and K_q != 0:
            valid_keys[u] = K_q

    key_list = sorted(valid_keys.keys())
    n_keys = len(key_list)

    p = MixedIntegerLinearProgram(maximization=False)
    a = p.new_variable(integer=True, nonneg=True)

    # Constraint: for each q-degree, sum of coefficients = target coefficient
    for deg in range(max_deg + 1):
        lhs = sum(a[j] * (valid_keys[key_list[j]][deg] if deg <= valid_keys[key_list[j]].degree() else 0) for j in range(n_keys))
        target_val = target_coeffs.get(deg, 0)
        p.add_constraint(lhs == target_val)

    # Minimize total number of components (or total multiplicity)
    p.set_objective(sum(a[j] for j in range(n_keys)))

    try:
        p.solve()
        solution = {}
        for j in range(n_keys):
            val = p.get_values(a[j])
            if val > 0.5:
                solution[key_list[j]] = int(round(val))
        return solution
    except Exception as e:
        print(f"  LP failed: {e}")
        return None

# Q values
Q1_322 = 2*q_var + 3*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6
Q1_421 = 2*q_var + 2*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6 + q_var**8

Q2_322 = q_var**3 + 5*q_var**4 + 7*q_var**5 + 10*q_var**6 + 10*q_var**7 + 12*q_var**8 + 10*q_var**9 + 11*q_var**10 + 9*q_var**11 + 9*q_var**12 + 7*q_var**13 + 7*q_var**14 + 5*q_var**15 + 5*q_var**16 + 3*q_var**17 + 3*q_var**18 + 2*q_var**19 + 2*q_var**20 + q_var**21 + q_var**22 + q_var**24

# Decompose Q_1 for (3,2,2) via LP
print("\n" + "="*60)
print("LP decomposition: Q_1 for d=7, c=(3,2,2)")
print("="*60)
sol = decompose_LP(Q1_322, unique_specs, 10)
if sol:
    total = 0
    for u, m in sorted(sol.items()):
        dim = unique_specs[u](q=1)
        total += m * dim
        print(f"  {m} * K_{u}  (K_q = {unique_specs[u]}, dim={dim})")
    print(f"  Total dim: {total}")

# Decompose Q_1 for (4,2,1) via LP
print("\n" + "="*60)
print("LP decomposition: Q_1 for d=7, c=(4,2,1)")
print("="*60)
sol = decompose_LP(Q1_421, unique_specs, 10)
if sol:
    total = 0
    for u, m in sorted(sol.items()):
        dim = unique_specs[u](q=1)
        total += m * dim
        print(f"  {m} * K_{u}  (K_q = {unique_specs[u]}, dim={dim})")
    print(f"  Total dim: {total}")

# Decompose Q_2 for (3,2,2) via LP
print("\n" + "="*60)
print("LP decomposition: Q_2 for d=7, c=(3,2,2)")
print("="*60)
sol = decompose_LP(Q2_322, unique_specs, 25)
if sol:
    total = 0
    for u, m in sorted(sol.items()):
        dim = unique_specs[u](q=1)
        total += m * dim
        print(f"  {m} * K_{u}  (K_q = {unique_specs[u]}, dim={dim})")
    print(f"  Total dim: {total} (should be 121)")
