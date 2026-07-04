# Compute Q_n for d=2 (all profiles) and d=4, then decompose into key polys
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
from collections import defaultdict

def demazure_op(i, poly_dict):
    result = {}
    for (e1, e2, e3), c in poly_dict.items():
        exps = [e1, e2, e3]
        e_up = list(exps); e_up[i] += 1; key1 = tuple(e_up)
        result[key1] = result.get(key1, 0) + c
        e_swap = list(exps); e_swap[i], e_swap[i+1] = e_swap[i+1], e_swap[i]
        e_swap[i+1] += 1; key2 = tuple(e_swap)
        result[key2] = result.get(key2, 0) - c
    
    groups = defaultdict(lambda: defaultdict(int))
    for (e1, e2, e3), c in result.items():
        exps = [e1, e2, e3]
        other_exp = list(exps)
        ei = other_exp[i]; ej = other_exp[i+1]
        other_exp[i] = 0; other_exp[i+1] = 0
        groups[tuple(other_exp)][(ei, ej)] += c
    
    final = {}
    for other_exp, bivar in groups.items():
        remainder = dict(bivar); quotient = {}
        for _ in range(1000):
            best = None
            for (a, b) in sorted(remainder.keys(), key=lambda x: (-x[0]-x[1], -x[0])):
                if remainder.get((a,b), 0) != 0: best = (a, b); break
            if best is None: break
            a, b = best; c = remainder[(a, b)]
            if a > 0:
                quotient[(a-1,b)] = quotient.get((a-1,b), 0) + c
                remainder[(a, b)] = 0
                remainder[(a-1, b+1)] = remainder.get((a-1, b+1), 0) + c
            else: break
        for (qi, qj), c in quotient.items():
            if c != 0:
                full_exp = list(other_exp); full_exp[i] += qi; full_exp[i+1] += qj
                final[tuple(full_exp)] = final.get(tuple(full_exp), 0) + c
    return {k: v for k, v in final.items() if v != 0}

def key_polynomial(alpha, cache={}):
    if alpha in cache: return cache[alpha]
    a = list(alpha)
    if a[0] >= a[1] >= a[2]:
        r = {tuple(a): 1}
    else:
        for i in range(2):
            if a[i] < a[i+1]:
                a_new = list(a); a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
                kappa_s = key_polynomial(tuple(a_new))
                r = demazure_op(i, kappa_s)
                break
    cache[alpha] = r
    return r

def specialise_to_array(poly_dict, max_deg):
    arr = np.zeros(max_deg + 1, dtype=int)
    for (e1, e2, e3), c in poly_dict.items():
        deg = e1 + 2*e2 + 3*e3
        if deg <= max_deg: arr[deg] += c
    return arr

def build_key_basis(max_deg):
    basis = []; seen = set()
    for c_val in range(max_deg // 3 + 1):
        for b_val in range((max_deg - 3*c_val) // 2 + 1):
            for a_val in range(max_deg - 2*b_val - 3*c_val + 1):
                alpha = (a_val, b_val, c_val)
                kp = key_polynomial(alpha)
                arr = specialise_to_array(kp, max_deg)
                arr_key = tuple(arr)
                if arr_key not in seen and any(arr != 0):
                    seen.add(arr_key)
                    basis.append((alpha, arr))
    return basis

def decompose(target_coeffs, max_deg):
    """Decompose into key polys. Returns list of (alpha, mult) or None."""
    target = np.array(target_coeffs, dtype=float)
    basis = build_key_basis(max_deg)
    nb = len(basis)
    A_mat = np.zeros((max_deg + 1, nb), dtype=float)
    for j, (alpha, arr) in enumerate(basis):
        A_mat[:, j] = arr[:max_deg+1]
    
    c_obj = np.ones(nb)
    constraints = LinearConstraint(A_mat, target, target)
    integrality = np.ones(nb)
    bounds = Bounds(0, np.inf)
    result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
    
    if result.success:
        x_sol = np.round(result.x).astype(int)
        check = A_mat @ x_sol
        if np.allclose(check, target):
            terms = [(basis[j][0], x_sol[j]) for j in range(nb) if x_sol[j] > 0]
            return terms
    return None

# EMD computation
def emd(c1, c2):
    return 3*max(0, c2[1]-c1[1], c1[0]-c2[0]) + (c2[0]-c1[0]) - (c2[1]-c1[1])

# Compute Q_n via EMD path formula + q-binomial transform
def profiles(d):
    """All compositions of d into 3 parts."""
    result = []
    for a in range(d+1):
        for b in range(d-a+1):
            c = d - a - b
            result.append((a, b, c))
    return result

def compute_Pn(target_c, n, profs):
    """P_n(target_c) via EMD path formula (recursive)."""
    if n == 0:
        return [1]  # polynomial = 1
    
    result_coeffs = defaultdict(int)
    for c_prev in profs:
        P_prev = compute_Pn(c_prev, n-1, profs)
        e = emd(target_c, c_prev)
        # q^{n*e} * P_prev
        for deg, coeff in enumerate(P_prev):
            if coeff != 0:
                result_coeffs[deg + n * e] += coeff
    
    max_d = max(result_coeffs.keys()) if result_coeffs else 0
    result = [result_coeffs.get(i, 0) for i in range(max_d + 1)]
    return result

def qbinom_coeffs(n, k):
    """Return [n choose k]_q as list of coefficients."""
    if k < 0 or k > n: return [0]
    if k == 0: return [1]
    # [n choose k]_q = [n-1 choose k-1]_q * q^{n-k} + [n-1 choose k]_q * ... 
    # Actually use the product formula: prod_{i=1}^k (1-q^{n-k+i})/(1-q^i)
    # Compute as polynomial multiplication
    num = [1]
    for i in range(1, k+1):
        # multiply by (1 - q^{n-k+i})
        factor = [0] * (n-k+i+1)
        factor[0] = 1
        factor[n-k+i] = -1
        new_num = [0] * (len(num) + len(factor) - 1)
        for a, ca in enumerate(num):
            for b, cb in enumerate(factor):
                new_num[a+b] += ca * cb
        num = new_num
    
    den = [1]
    for i in range(1, k+1):
        # multiply by (1 - q^i)
        factor = [0] * (i+1)
        factor[0] = 1
        factor[i] = -1
        new_den = [0] * (len(den) + len(factor) - 1)
        for a, ca in enumerate(den):
            for b, cb in enumerate(factor):
                new_den[a+b] += ca * cb
        den = new_den
    
    # Polynomial division num / den
    result = [0] * (len(num) - len(den) + 1)
    rem = list(num)
    for i in range(len(result)):
        if i < len(rem):
            result[i] = rem[i] // den[0]  # den[0] = 1
            for j in range(len(den)):
                if i+j < len(rem):
                    rem[i+j] -= result[i] * den[j]
    
    # Trim trailing zeros
    while result and result[-1] == 0:
        result.pop()
    return result if result else [0]

def poly_mult_scalar(poly, scalar, shift=0):
    """scalar * q^shift * poly"""
    if scalar == 0: return [0]
    result = [0] * (len(poly) + shift)
    for i, c in enumerate(poly):
        result[i + shift] += scalar * c
    return result

def poly_add(p1, p2):
    result = [0] * max(len(p1), len(p2))
    for i, c in enumerate(p1): result[i] += c
    for i, c in enumerate(p2): result[i] += c
    return result

def compute_Qn(target_c, n, profs):
    """Q_n = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q P_j"""
    result = [0]
    for j in range(n + 1):
        k = n - j
        Pj = compute_Pn(target_c, j, profs)
        qb = qbinom_coeffs(n, j)
        # (-1)^k * q^{k(k+1)/2} * qb * Pj
        shift = k * (k + 1) // 2
        sign = (-1) ** k
        
        # qb * Pj
        prod = [0] * (len(qb) + len(Pj) - 1)
        for a, ca in enumerate(qb):
            for b, cb in enumerate(Pj):
                prod[a+b] += ca * cb
        
        term = poly_mult_scalar(prod, sign, shift)
        result = poly_add(result, term)
    
    # Trim trailing zeros
    while result and result[-1] == 0:
        result.pop()
    return result if result else [0]

# Test for d=2
print("=" * 70)
print("d=2: ALL profiles")
print("=" * 70)
d = 2
profs = profiles(d)
print(f"Profiles: {profs}")

for n in [1, 2, 3]:
    print(f"\n--- n = {n} ---")
    for c in profs:
        Q = compute_Qn(c, n, profs)
        neg = [Q[i] for i in range(len(Q)) if Q[i] < 0]
        max_deg = len(Q) - 1
        
        decomp = decompose(Q, max_deg)
        
        mult_str = ""
        if decomp:
            mults = [m for _, m in decomp]
            mult_str = f"mults={mults}, all_1={all(m==1 for m in mults)}, count={len(decomp)}"
        else:
            mult_str = "NO DECOMPOSITION"
        
        eval_1 = sum(Q)
        print(f"  c={c}: deg={max_deg}, Q(1)={eval_1}, neg={'YES' if neg else 'no'}, {mult_str}")

# Test for d=4
print("\n\n" + "=" * 70)
print("d=4: selected profiles")  
print("=" * 70)
d = 4
profs4 = profiles(d)
print(f"Number of profiles: {len(profs4)}")

# Just do n=1 for all profiles (d=4 is expensive for higher n)
n = 1
print(f"\n--- n = {n} ---")
for c in profs4:
    Q = compute_Qn(c, n, profs4)
    neg = [Q[i] for i in range(len(Q)) if Q[i] < 0]
    max_deg = len(Q) - 1
    
    decomp = decompose(Q, max_deg)
    
    mult_str = ""
    if decomp:
        mults = [m for _, m in decomp]
        mult_str = f"all_1={all(m==1 for m in mults)}, count={len(decomp)}"
    else:
        mult_str = "NO DECOMPOSITION"
    
    eval_1 = sum(Q)
    print(f"  c={c}: deg={max_deg}, Q(1)={eval_1}, neg={'YES' if neg else 'no'}, {mult_str}")

