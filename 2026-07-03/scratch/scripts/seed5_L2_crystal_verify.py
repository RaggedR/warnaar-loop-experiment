"""
Seed 5, Layer 2: Final verification -- can we identify Q_1 as a crystal character?

The key observation is that Q_1(1) = (d+1)(d+2)/6 - 1.

For d=7: (8)(9)/6 - 1 = 12 - 1 = 11.

The number 12 = (d+1)(d+2)/6 counts the C_3-orbits of dominant weights
at level d for sl_3. So Q_1(1) = #orbits - 1.

The "-1" removes one orbit. WHICH orbit?

Hypothesis: the removed orbit is the "trivial" orbit {(d,0,0), (0,d,0), (0,0,d)}.
This orbit has size 3 for d >= 1. But removing 1 orbit of size 3 from 12 orbits
gives 11 orbits, which matches Q_1(1) = 11.

BUT this counts orbits, not individual weights. Let me think about this
differently.

Actually: Q_1 is a polynomial of degree 6 (for d=7, c=(3,2,2)), not
a count of weights. The q-grading comes from the specialization at (q,q^2,q^3).

Let me check: if we take one representative from each of the 11 C_3-orbits
(excluding some specific orbit), and compute sum q^{a+2b+3c} over those
representatives, do we get Q_1?

No -- Q_1 has coefficients > 1 (e.g., 2q+3q^2+...), so it's not just a
simple sum over distinct representatives.

From the KEY POLYNOMIAL decomposition, we know Q_1 for d=7, c=(3,2,2) is:
  K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)}

where:
  K_{(0,0,1)} has monomials: {(0,0,1), (0,1,0), (1,0,0)} -> q^3 + q^2 + q^1
  K_{(0,0,2)} has monomials: {(0,0,2), (0,1,1), (0,2,0), (1,0,1), (1,1,0), (2,0,0)}
                             -> q^6 + q^5 + q^4 + q^4 + q^3 + q^2
  K_{(0,1,0)} has monomials: {(0,1,0), (1,0,0)} -> q^2 + q^1

Total monomials (with multiplicity):
  (1,0,0): 2  (from K_{(0,0,1)} and K_{(0,1,0)})
  (0,1,0): 2  (from K_{(0,0,1)} and K_{(0,1,0)})
  (0,0,1): 1  (from K_{(0,0,1)})
  (2,0,0): 1  (from K_{(0,0,2)})
  (1,1,0): 1  (from K_{(0,0,2)})
  (1,0,1): 1  (from K_{(0,0,2)})
  (0,2,0): 1  (from K_{(0,0,2)})
  (0,1,1): 1  (from K_{(0,0,2)})
  (0,0,2): 1  (from K_{(0,0,2)})

So 9 distinct weights at levels 1 and 2, with total multiplicity 11.
The weights at level 1 are exactly the compositions of 1 into 3 parts: 3 weights.
The weights at level 2 are exactly the compositions of 2 into 3 parts: 6 weights.
Total = 3 + 6 = 9 weights, but (1,0,0) and (0,1,0) appear with multiplicity 2.

THIS IS INTERESTING: the weights are NOT at level d=7. They are at levels 1 and 2.
This is the KEY OBSERVATION that the decomposition is about the GRADING structure,
not about level-d weight spaces.

Let me now check: what is the relationship between the number of compositions
of m into 3 nonneg parts and the key polynomial dimensions?

Number of compositions of m into 3 parts = C(m+2, 2) = (m+1)(m+2)/2
Sum over m=1 to M: C(3,2) + C(4,2) + ... = ...

For Q_1: the monomials are at levels 1 and 2 (for d=7, c=(3,2,2)).
Total = C(3,2) + C(4,2) = 3 + 6 = 9 distinct, but with multiplicities
making total 11.

For d=4, c=(2,1,1): Q_1 = K_{(0,0,1)} + K_{(1,0,0)}
  Monomials at level 1: {(0,0,1), (0,1,0), (1,0,0)} from K_{(0,0,1)}
                        + (1,0,0) from K_{(1,0,0)} = 4 total
  So all at level 1 only.

For d=5, c=(2,2,1): Q_1 = K_{(0,1,0)} + K_{(0,2,0)} + K_{(1,0,0)}
  Level 1: {(0,1,0), (1,0,0)} from K_{(0,1,0)} + (1,0,0) from K_{(1,0,0)} = 3
  Level 2: {(0,2,0), (1,1,0), (2,0,0)} from K_{(0,2,0)} = 3
  Total = 6

So the "level" of the monomials depends on d:
  d=2: level 1 only -> 1 monomial
  d=4: level 1 only -> 4 monomials
  d=5: levels 1-2 -> 6 monomials
  d=7: levels 1-2 -> 11 monomials

The max level in Q_1 seems to be floor((d-1)/3) or something similar.
  d=2: max level 1, floor((2-1)/3) = 0... no
  d=4: max level 1, floor(d/3) = 1? Or d mod 3 = 1, so...
  d=5: max level 2
  d=7: max level 2

Hmm. Let me think about this from the Demazure character perspective.

Actually, the KEY POLYNOMIAL index u determines the level: sum(u).
For Q_1:
  d=2: u = (1,0,0), level 1
  d=4: u in {(0,0,1), (1,0,0)}, levels 1
  d=5: u in {(0,1,0), (0,2,0), (1,0,0)}, levels 1,2
  d=7, c=(3,2,2): u in {(0,0,1), (0,0,2), (0,1,0)}, levels 1,1,2

The max level of key indices is:
  d=2: 1
  d=4: 1
  d=5: 2
  d=7: 2

Let me check more: what about d=8 (mod 3 = 2)?
"""

# Let me compute Q_1 for d=8, c=(3,3,2) 
# (d+1)(d+2)/6 - 1 = 9*10/6 - 1 = 15 - 1 = 14

from itertools import combinations
from math import gcd

MAX_Q = 60

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i+j > max_deg: continue
            result[i+j] = result.get(i+j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def poly_shift(p, s, max_deg=MAX_Q):
    return {k+s: v for k, v in p.items() if k+s <= max_deg}

def poly_scale(p, s):
    if s == 0: return {}
    return {k: v*s for k, v in p.items()}

def enumerate_profiles(d, k):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in enumerate_profiles(d-i, k-1):
            yield (i,) + rest

def compute_cJ(c, J):
    k = len(c)
    J_set = set(J)
    c_J = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set:
            c_J[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_J[i] += 1
    return tuple(c_J)

def build_CW_system(c, k=3):
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c:
        return []
    terms = []
    for size in range(1, len(I_c)+1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J):
                continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms

def compute_base_case_coeffs(k, max_n, max_q):
    result = {}
    prev_cum = {0: 1}
    result[0] = {0: 1}
    for n in range(1, max_n + 1):
        curr_cum = {}
        kn = k * n
        for p, c in prev_cum.items():
            j = 0
            while p + kn * j <= max_q:
                curr_cum[p + kn * j] = curr_cum.get(p + kn * j, 0) + c
                j += 1
        curr_cum = {p: c for p, c in curr_cum.items() if c != 0}
        result[n] = poly_sub(curr_cum, prev_cum)
        prev_cum = curr_cum
    return result

def solve_CW_and_Q(profile, max_n=1, max_q=MAX_Q):
    d = sum(profile)
    k = 3
    all_profiles = list(enumerate_profiles(d, k))
    zero_profile = tuple([0] * k)

    cw_system = {}
    for p in all_profiles:
        if p == zero_profile:
            continue
        cw_system[p] = build_CW_system(p, k)

    base_coeffs = compute_base_case_coeffs(k, max_n, max_q)
    B = {}
    B[zero_profile] = {}
    cum = {0: 1}
    for n in range(max_n + 1):
        if n == 0:
            B[zero_profile][0] = {0: 1}
        else:
            cum = poly_add(cum, base_coeffs.get(n, {}))
            B[zero_profile][n] = dict(cum)

    for p in all_profiles:
        if p == zero_profile:
            continue
        B[p] = {-1: {}}
    for p in all_profiles:
        B[p][0] = {0: 1}

    for n in range(1, max_n + 1):
        non_zero = [p for p in all_profiles if p != zero_profile]
        rhs = {}
        for p in non_zero:
            known = dict(B[p][n-1])
            for sign, s, target in cw_system[p]:
                if target == zero_profile:
                    contrib = poly_scale(B[zero_profile][n], sign)
                    contrib = poly_shift(contrib, n * s, max_q)
                    known = poly_add(known, contrib)
            rhs[p] = known
        for p in non_zero:
            B[p][n] = dict(rhs[p])
        max_iter = max_q // max(1, n) + 2
        for iteration in range(max_iter):
            changed = False
            for p in non_zero:
                new_val = dict(rhs[p])
                for sign, s, target in cw_system[p]:
                    if target != zero_profile:
                        contrib = poly_shift(B[target][n], n * s, max_q)
                        contrib = poly_scale(contrib, sign)
                        new_val = poly_add(new_val, contrib)
                if new_val != B[p][n]:
                    changed = True
                B[p][n] = new_val
            if not changed:
                break

    b_coeffs = {}
    for m in range(max_n + 1):
        if m == 0:
            b_coeffs[m] = B[profile][0]
        else:
            b_coeffs[m] = poly_sub(B[profile][m], B[profile][m-1])

    ell = gcd(d, k)
    Q_polys = {}
    for n in range(max_n + 1):
        inner = {}
        for m in range(n+1):
            sign = (-1)**m
            shift = m*(m+1)//2
            if shift > max_q: break
            ratio = {0: 1}
            for i in range(m+1, n+1):
                factor = {0: 1, i: -1}
                ratio = poly_mul(ratio, factor, max_q)
            b = b_coeffs.get(n-m, {})
            term = poly_mul(ratio, b, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)
        Q_polys[n] = {k: v for k, v in inner.items() if v != 0}
    return Q_polys

# Compute Q_1 for d=8
profiles_d8 = [(3, 3, 2), (4, 3, 1), (5, 2, 1)]
for profile in profiles_d8:
    d = sum(profile)
    if d % 3 == 0:
        continue
    base = (d+1)*(d+2)//6 - 1
    Qs = solve_CW_and_Q(profile, max_n=1, max_q=40)
    Q1 = Qs.get(1, {})
    q1_val = sum(Q1.values())
    all_pos = all(v >= 0 for v in Q1.values())
    
    parts = []
    for e in sorted(Q1.keys()):
        c = Q1[e]
        if c == 1: parts.append(f"q^{e}")
        else: parts.append(f"{c}q^{e}")
    
    print(f"d={d}, c={profile}: Q_1 = {' + '.join(parts)}")
    print(f"  Q_1(1) = {q1_val}, expected = {base}, pos = {all_pos}")

# Now try key polynomial decomposition for d=8
print("\n" + "=" * 70)
print("KEY POLYNOMIAL DECOMPOSITION FOR d=8")
print("=" * 70)

def demazure_op(poly, i, num_vars=3):
    result = {}
    for exp, coeff in poly.items():
        exp_list = list(exp)
        a, b = exp_list[i], exp_list[i+1]
        if a >= b:
            for j in range(a - b + 1):
                new_exp = list(exp)
                new_exp[i] = a - j
                new_exp[i+1] = b + j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) + coeff
        else:
            for j in range(b - a - 1):
                new_exp = list(exp)
                new_exp[i] = a + 1 + j
                new_exp[i+1] = b - 1 - j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) - coeff
    return {k: v for k, v in result.items() if v != 0}

def compute_key_poly(u, num_vars=3):
    u = tuple(u)
    is_dom = all(u[i] >= u[i+1] for i in range(len(u)-1))
    if is_dom:
        return {u: 1}
    for i in range(len(u)-1):
        if u[i] < u[i+1]:
            u_swapped = list(u)
            u_swapped[i], u_swapped[i+1] = u_swapped[i+1], u_swapped[i]
            u_swapped = tuple(u_swapped)
            K_swapped = compute_key_poly(u_swapped, num_vars)
            return demazure_op(K_swapped, i, num_vars)
    return {u: 1}

def specialize_key(u, exponents=(1, 2, 3)):
    K = compute_key_poly(u, len(exponents))
    result = {}
    for exp, coeff in K.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

import numpy as np
from scipy.optimize import linprog

for profile in profiles_d8:
    d = sum(profile)
    if d % 3 == 0:
        continue
    Qs = solve_CW_and_Q(profile, max_n=1, max_q=40)
    Q1 = Qs.get(1, {})
    if not Q1:
        continue
    
    max_deg = max(Q1.keys())
    min_deg = min(Q1.keys())
    
    # Build key polynomial candidates
    key_specs = {}
    for a in range(max_deg + 1):
        for b in range(max_deg + 1):
            for c_val in range(max_deg + 1):
                u = (a, b, c_val)
                K = specialize_key(u, (1, 2, 3))
                if not K: continue
                if max(K.keys()) > max_deg or min(K.keys()) < min_deg: continue
                if any(v < 0 for v in K.values()): continue
                key_specs[u] = K
    
    cand_list = sorted(key_specs.keys())
    n_vars = len(cand_list)
    degrees = list(range(min_deg, max_deg + 1))
    n_eq = len(degrees)
    
    A = np.zeros((n_eq, n_vars))
    b_vec = np.zeros(n_eq)
    for i, deg in enumerate(degrees):
        b_vec[i] = Q1.get(deg, 0)
        for j, u in enumerate(cand_list):
            A[i, j] = key_specs[u].get(deg, 0)
    
    c_obj = np.array([sum(u) for u in cand_list], dtype=float)
    result = linprog(c_obj, A_eq=A, b_eq=b_vec, bounds=[(0, None)] * n_vars, method='highs')
    
    if result.success:
        x = result.x
        x_int = np.round(x).astype(int)
        residual = A @ x_int - b_vec
        if np.all(residual == 0) and np.all(x_int >= 0):
            print(f"\nd={d}, c={profile}: KEY DECOMPOSITION FOUND!")
            total = 0
            for j, u in enumerate(cand_list):
                if x_int[j] > 0:
                    dim = sum(key_specs[u].values())
                    level = sum(u)
                    total += x_int[j] * dim
                    print(f"  {x_int[j]} * K_{u} (dim={dim}, level={level})")
            print(f"  Total = {total}")
        else:
            print(f"\nd={d}, c={profile}: LP solved but integer rounding failed")
    else:
        print(f"\nd={d}, c={profile}: LP infeasible")

