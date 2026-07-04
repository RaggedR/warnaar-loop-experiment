"""
Seed 4, Layer 3: Analyze h_m using SageMath symmetric function tools.
Check if h_m equals a known positive object:
- Hall-Littlewood specialization
- Demazure character
- Ehrhart h*-polynomial
"""

# Use SageMath's polynomial ring
R.<q> = QQ[]

# First, let's compute h_m directly using the CW system
# We need the infrastructure from the Python scripts

from itertools import combinations
from collections import defaultdict

def all_profiles(d, k=3):
    if k == 1: return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c); J_set = set(J); c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set: c_new[i] -= 1
        elif i not in J_set and i_prev in J_set: c_new[i] += 1
    return tuple(c_new)

def get_transitions(c):
    k = len(c); I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    trans = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            sign = (-1) ** (size - 1)
            cJ = shifted_profile(c, J)
            if any(x < 0 for x in cJ): continue
            trans.append((sign, size, cJ))
    return trans

def compute_gn_sage(d, n_max, prec=200):
    """Compute g_n using SageMath polynomials (exact arithmetic)."""
    profiles = all_profiles(d)
    trans = {c: get_transitions(c) for c in profiles}

    S = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q_ps = S.gen()

    g = defaultdict(lambda: defaultdict(lambda: S(0)))
    for c in profiles:
        g[0][c] = S(1)

    for n in range(1, n_max + 1):
        print(f"  Computing g_{n}...")
        # Build RHS for each profile
        rhs = {}
        for c in profiles:
            r = S(0)
            for sign, s, cJ in trans[c]:
                partial = sum(g[m][cJ] for m in range(n))
                r += sign * q_ps^(n*s) * partial
            rhs[c] = r

        # Solve (I - A(q^n)) g_n = rhs degree by degree
        # Since A(q^n) has entries q^{n*s} with s >= 1, the system is triangular in degree
        curr = {c: S(0) for c in profiles}

        # Convert to polynomial, solve iteratively
        for deg in range(prec):
            for c in profiles:
                val = rhs[c][deg] if deg < len(list(rhs[c])) else 0
                for sign, s, cJ in trans[c]:
                    src_deg = deg - n * s
                    if src_deg >= 0:
                        val += sign * (curr[cJ][src_deg] if src_deg < len(list(curr[cJ])) else 0)
                if val != 0:
                    curr[c] += val * q_ps^deg

        for c in profiles:
            g[n][c] = curr[c]

    return g, profiles

def compute_hm_sage(g, profile, m, prec):
    """h_m = (q;q)_m * g_m"""
    S = g[0][profile].parent()
    q_ps = S.gen()
    qpoch = S(1)
    for i in range(1, m + 1):
        qpoch *= (1 - q_ps^i)
    return qpoch * g[m][profile]

# Compute for d=4 first (small, fast)
print("="*60)
print("d=4, profile (2,1,1)")
print("="*60)
d = 4
profile = (2,1,1)
prec = 100
g, profiles = compute_gn_sage(d, 6, prec)

base = (d+1)*(d+2)//6
print(f"base = {base}")

for m in range(7):
    hm = compute_hm_sage(g, profile, m, prec)
    # Convert to polynomial
    hm_poly = R(0)
    for i in range(prec):
        c = hm[i]
        if c != 0:
            hm_poly += c * q^i
    print(f"\nh_{m} = {hm_poly}")
    print(f"  h_{m}(1) = {hm_poly(q=1)}, expected = {base^m}")
    # Check all coefficients nonneg
    coeffs = hm_poly.coefficients(sparse=False) if hm_poly != 0 else [0]
    all_nn = all(c >= 0 for c in coeffs)
    print(f"  All coefficients >= 0: {all_nn}")

# Now check h_1 against known objects
print("\n" + "="*60)
print("Checking h_1 against Hall-Littlewood specializations")
print("="*60)

# h_1 for d=4, c=(2,1,1) should be 3q + q^2 + q^3
# Hall-Littlewood P_lambda(x;t) at principal spec x=(q,q^2,...,q^r)
# For GL_3 (r=3): x1=q, x2=q^2, x3=q^3
Sym = SymmetricFunctions(QQ['t'].fraction_field())
HL = Sym.hall_littlewood(t=var('t')).P()
s = Sym.schur()
m_basis = Sym.monomial()
p_basis = Sym.powersum()

# Try principal specialization of HL at t=q
# Actually, let's work in a different way
# Check if h_1 for various d matches a character

print("\n" + "="*60)
print("Checking h_m structure for d=7")
print("="*60)
d = 7
profile = (3,2,2)
prec = 80
g7, profiles7 = compute_gn_sage(d, 4, prec)

base7 = (d+1)*(d+2)//6
print(f"base = {base7}")

h7 = {}
for m in range(5):
    hm = compute_hm_sage(g7, profile, m, prec)
    hm_poly = R(0)
    for i in range(prec):
        c = hm[i]
        if c != 0:
            hm_poly += c * q^i
    h7[m] = hm_poly
    print(f"\nh_{m} = {hm_poly}")
    print(f"  h_{m}(1) = {hm_poly(q=1)}, expected = {base7^m}")
    coeffs = hm_poly.coefficients(sparse=False) if hm_poly != 0 else [0]
    all_nn = all(c >= 0 for c in coeffs)
    print(f"  All coefficients >= 0: {all_nn}")

# Check domination h_m >= q * h_{m-1}
print("\n" + "="*60)
print("Domination check h_m - q*h_{m-1} for d=7")
print("="*60)
for m in range(1, 5):
    diff = h7[m] - q * h7[m-1]
    coeffs = diff.coefficients(sparse=False) if diff != 0 else [0]
    all_nn = all(c >= 0 for c in coeffs)
    print(f"h_{m} - q*h_{m-1}: all nonneg = {all_nn}, sum at q=1 = {diff(q=1)}, expected = {(base7-1)*base7^(m-1)}")
    if not all_nn:
        neg_coeffs = [(i, coeffs[i]) for i in range(len(coeffs)) if coeffs[i] < 0]
        print(f"  NEGATIVE coefficients: {neg_coeffs[:10]}")

# Now compute D_k^m and look at structure
print("\n" + "="*60)
print("D_k^m tower for d=7, profile (3,2,2)")
print("="*60)
D7 = {}
for m in range(5):
    D7[(0,m)] = h7[m]
for k in range(1, 5):
    for m in range(k, 5):
        D7[(k,m)] = D7[(k-1,m)] - q^k * D7[(k-1,m-1)]

for k in range(5):
    for m in range(k, 5):
        p = D7[(k,m)]
        coeffs = p.coefficients(sparse=False) if p != 0 else [0]
        all_nn = all(c >= 0 for c in coeffs)
        print(f"D_{k}^{m}: sum={p(q=1)}, nonneg={all_nn}, deg={p.degree() if p != 0 else 0}")

# Key test: is D_1^m = h_m - q*h_{m-1} a single Demazure character?
print("\n" + "="*60)
print("D_1^m = h_m - q*h_{m-1} for d=7")
print("="*60)
for m in range(1, 5):
    p = D7[(1,m)]
    print(f"D_1^{m} = {p}")

