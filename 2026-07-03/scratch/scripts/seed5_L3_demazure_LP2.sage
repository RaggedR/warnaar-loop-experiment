"""
Seed 5, Layer 3: LP-based decomposition of Q into key polynomials.
"""
from itertools import product as iprod

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()
Rpoly3 = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
x1, x2, x3 = Rpoly3.gens()
xvars = [x1, x2, x3]

def demazure_op(f, i):
    xi, xip1 = xvars[i], xvars[i+1]
    swap = {xvars[j]: xvars[j] for j in range(3)}
    swap[xi] = xip1; swap[xip1] = xi
    f_s = f.subs(swap)
    return Rpoly3((xi * f - xip1 * f_s) // (xi - xip1))

def key_polynomial(u):
    lam = sorted(u, reverse=True)
    if list(u) == list(lam):
        return x1**u[0] * x2**u[1] * x3**u[2]
    from itertools import permutations
    best_w, best_len = None, 100
    for perm in permutations(range(3)):
        if all(lam[perm[i]] == u[i] for i in range(3)):
            inv = sum(1 for a in range(3) for b in range(a+1,3) if perm[a] > perm[b])
            if inv < best_len: best_w, best_len = list(perm), inv
    if best_w is None: return None
    w, word = list(best_w), []
    while w != [0,1,2]:
        for i in range(2):
            if w[i] > w[i+1]: w[i], w[i+1] = w[i+1], w[i]; word.append(i); break
    word.reverse()
    f = x1**lam[0] * x2**lam[1] * x3**lam[2]
    for i in word: f = demazure_op(f, i)
    return f

def specialize(K_poly):
    if K_poly is None or K_poly == 0: return R_poly(0)
    result = R_poly(0)
    for coeff, mon in zip(K_poly.coefficients(), K_poly.monomials()):
        degs = mon.degrees()
        result += coeff * q_var**(degs[0] + 2*degs[1] + 3*degs[2])
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
                if K_q != 0: key_data[u] = K_q

# Deduplicate
spec_to_keys = {}
for u, K_q in key_data.items():
    key = str(K_q)
    if key not in spec_to_keys: spec_to_keys[key] = []
    spec_to_keys[key].append(u)
unique_specs = {min(us): key_data[min(us)] for us in spec_to_keys.values()}
print(f"{len(key_data)} key polys, {len(unique_specs)} unique specs")

def decompose_LP(target_poly, key_specs, max_deg):
    """LP decomposition using scipy."""
    import numpy as np
    try:
        from scipy.optimize import linprog, milp, LinearConstraint, Bounds
    except ImportError:
        print("scipy not available, trying simple approach")
        return None

    target_vec = np.array([int(target_poly[i]) for i in range(max_deg+1)])

    valid_keys = [(u, K_q) for u, K_q in sorted(key_specs.items()) if K_q.degree() <= max_deg]
    n_keys = len(valid_keys)

    # Build coefficient matrix
    A = np.zeros((max_deg+1, n_keys))
    for j, (u, K_q) in enumerate(valid_keys):
        for i in range(max_deg+1):
            A[i,j] = int(K_q[i]) if i <= K_q.degree() else 0

    # Solve: A @ x = target_vec, x >= 0, x integer, minimize sum(x)
    from scipy.optimize import linprog
    # First solve relaxed LP
    c = np.ones(n_keys)
    A_eq = A
    b_eq = target_vec

    res = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=[(0, None)]*n_keys, method='highs')
    if not res.success:
        print(f"  LP infeasible: {res.message}")
        return None

    # Round to integers and check
    x_round = np.round(res.x).astype(int)
    if np.all(x_round >= 0) and np.allclose(A @ x_round, target_vec):
        solution = {}
        for j in range(n_keys):
            if x_round[j] > 0:
                solution[valid_keys[j][0]] = int(x_round[j])
        return solution

    # Try ILP with milp
    try:
        from scipy.optimize import milp, LinearConstraint, Bounds
        from scipy.sparse import csc_matrix

        constraints = LinearConstraint(csc_matrix(A), target_vec, target_vec)
        integrality = np.ones(n_keys)
        bounds = Bounds(lb=0, ub=np.inf)

        result = milp(c, constraints=constraints, integrality=integrality, bounds=bounds)
        if result.success:
            solution = {}
            for j in range(n_keys):
                val = int(round(result.x[j]))
                if val > 0:
                    solution[valid_keys[j][0]] = val
            return solution
        else:
            print(f"  MILP failed: {result.message}")
            return None
    except Exception as e:
        print(f"  MILP error: {e}")
        return None

# Q values
Q1_322 = 2*q_var + 3*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6
Q1_421 = 2*q_var + 2*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6 + q_var**8
Q2_322 = q_var**3 + 5*q_var**4 + 7*q_var**5 + 10*q_var**6 + 10*q_var**7 + 12*q_var**8 + 10*q_var**9 + 11*q_var**10 + 9*q_var**11 + 9*q_var**12 + 7*q_var**13 + 7*q_var**14 + 5*q_var**15 + 5*q_var**16 + 3*q_var**17 + 3*q_var**18 + 2*q_var**19 + 2*q_var**20 + q_var**21 + q_var**22 + q_var**24

for name, poly, md in [("Q_1 c=(3,2,2)", Q1_322, 10),
                         ("Q_1 c=(4,2,1)", Q1_421, 10),
                         ("Q_2 c=(3,2,2)", Q2_322, 25)]:
    print(f"\n{'='*60}")
    print(f"LP decomposition: {name}")
    print(f"{'='*60}")
    sol = decompose_LP(poly, unique_specs, md)
    if sol:
        total = 0
        for u, m in sorted(sol.items()):
            dim = unique_specs[u](q=1)
            total += m * dim
            print(f"  {m} * K_{u}  (dim={dim}, K_q={unique_specs[u]})")
        print(f"  Total dim: {total} (target: {poly(q=1)})")
    else:
        print("  No decomposition found")
