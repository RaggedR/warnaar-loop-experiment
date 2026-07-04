"""
Seed 5, Layer 3: GL_3 Demazure character (key polynomial) decomposition.
Fixed specialization: x1=q, x2=q^2, x3=q^3.
"""

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

Rpoly3 = PolynomialRing(ZZ, ['x1', 'x2', 'x3'])
x1, x2, x3 = Rpoly3.gens()
xvars = [x1, x2, x3]

def demazure_op(f, i):
    """pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})"""
    xi, xip1 = xvars[i], xvars[i+1]
    swap = {xvars[j]: xvars[j] for j in range(3)}
    swap[xi] = xip1
    swap[xip1] = xi
    f_s = f.subs(swap)
    num = xi * f - xip1 * f_s
    return Rpoly3(num // (xi - xip1))

def key_polynomial(u):
    """K_u(x1,x2,x3) via Demazure operators."""
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

    # Reduced word via bubble sort
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
    """K(x1,x2,x3) -> K(q, q^2, q^3)"""
    if K_poly is None or K_poly == 0:
        return R_poly(0)
    result = R_poly(0)
    for coeff, mon in zip(K_poly.coefficients(), K_poly.monomials()):
        degs = mon.degrees()  # (e1, e2, e3)
        total_q_deg = degs[0]*1 + degs[1]*2 + degs[2]*3
        result += coeff * q_var**total_q_deg
    return result

# Verify specialization
print("Key polynomials and their specializations:")
for u in [(1,0,0), (0,1,0), (0,0,1), (2,0,0), (0,2,0), (0,0,2), (1,1,0), (0,1,1), (1,0,1)]:
    K = key_polynomial(u)
    K_q = specialize(K)
    print(f"  K_{u} = {K}  ->  {K_q}  (at q=1: {K_q(q=1)})")

# Generate all key polys up to level 10
max_level = 10
key_data = {}  # u -> (K_poly, K_q_spec)
from itertools import product as iprod
for level in range(max_level + 1):
    for u in iprod(range(level+1), repeat=3):
        if sum(u) == level:
            K = key_polynomial(u)
            if K is not None:
                K_q = specialize(K)
                if K_q != 0:
                    key_data[u] = (K, K_q)

print(f"\nGenerated {len(key_data)} nonzero key polynomials up to level {max_level}")

# Q_1 values from our computation
Q1_322 = 2*q_var + 3*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6
Q1_421 = 2*q_var + 2*q_var**2 + 2*q_var**3 + 2*q_var**4 + q_var**5 + q_var**6 + q_var**8

def decompose_greedy(target, key_data, strategy='small_first'):
    """Try to decompose target as nonneg combination of key poly specializations."""
    residual = R_poly(target)
    decomp = {}

    if strategy == 'small_first':
        sorted_keys = sorted(key_data.keys(), key=lambda u: (sum(u), u))
    else:
        sorted_keys = sorted(key_data.keys(), key=lambda u: (-sum(u), u))

    for u in sorted_keys:
        K_q = key_data[u][1]
        if K_q == 0:
            continue
        while residual != 0:
            test = residual - K_q
            if test == 0:
                decomp[u] = decomp.get(u, 0) + 1
                residual = test
                break
            # Check nonneg
            ok = True
            for c in test.coefficients():
                if c < 0:
                    ok = False
                    break
            if ok:
                decomp[u] = decomp.get(u, 0) + 1
                residual = test
            else:
                break
        if residual == 0:
            break
    return decomp, residual

# Decompose Q_1 for (3,2,2)
print("\n" + "="*60)
print("Decomposing Q_1 for d=7, c=(3,2,2)")
print(f"Q_1 = {Q1_322}")
print("="*60)

for strat in ['small_first', 'large_first']:
    decomp, res = decompose_greedy(Q1_322, key_data, strat)
    print(f"\n  Strategy: {strat}")
    if res == 0:
        print("  SUCCESS!")
        total = 0
        for u, m in sorted(decomp.items()):
            dim = key_data[u][1](q=1)
            total += m * dim
            print(f"    {m} * K_{u}  (dim={dim})")
        print(f"  Total dim: {total}")
    else:
        print(f"  Residual: {res}")

# Decompose Q_1 for (4,2,1)
print("\n" + "="*60)
print("Decomposing Q_1 for d=7, c=(4,2,1)")
print(f"Q_1 = {Q1_421}")
print("="*60)

for strat in ['small_first', 'large_first']:
    decomp, res = decompose_greedy(Q1_421, key_data, strat)
    print(f"\n  Strategy: {strat}")
    if res == 0:
        print("  SUCCESS!")
        total = 0
        for u, m in sorted(decomp.items()):
            dim = key_data[u][1](q=1)
            total += m * dim
            print(f"    {m} * K_{u}  (dim={dim})")
        print(f"  Total dim: {total}")
    else:
        print(f"  Residual: {res}")

# Now Q_2
print("\n" + "="*60)
print("Decomposing Q_2 for d=7, c=(3,2,2)")
Q2_322 = q_var**3 + 5*q_var**4 + 7*q_var**5 + 10*q_var**6 + 10*q_var**7 + 12*q_var**8 + 10*q_var**9 + 11*q_var**10 + 9*q_var**11 + 9*q_var**12 + 7*q_var**13 + 7*q_var**14 + 5*q_var**15 + 5*q_var**16 + 3*q_var**17 + 3*q_var**18 + 2*q_var**19 + 2*q_var**20 + q_var**21 + q_var**22 + q_var**24
print(f"Q_2 = {Q2_322}")
print("="*60)

for strat in ['small_first', 'large_first']:
    decomp, res = decompose_greedy(Q2_322, key_data, strat)
    print(f"\n  Strategy: {strat}")
    if res == 0:
        print("  SUCCESS!")
        total = 0
        for u, m in sorted(decomp.items()):
            dim = key_data[u][1](q=1)
            total += m * dim
            print(f"    {m} * K_{u}  (dim={dim})")
        print(f"  Total dim: {total}")
    else:
        print(f"  Residual: {res}")
