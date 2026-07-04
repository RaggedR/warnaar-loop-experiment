"""
Seed 5, Layer 2: Analyze the Q_1 key polynomial decompositions
across all profiles and d values. Look for the crystal structure.

Key observation from the data:
  d=2, c=(1,1,0): Q_1 = q          -> 1*K_{(0,0,0)} ? No, Q_1 = q^1.
                                       Actually Q_1 = q, and K_{(1,0,0)}(q) = q.
  d=4, c=(2,1,1): Q_1 = 2q + q^2 + q^3 -> K_{(0,0,1)} + K_{(1,0,0)} at (q,q^2,q^3)
  d=5, c=(2,2,1): Q_1 = 2q + 2q^2 + q^3 + q^4 -> K_{(0,1,0)} + K_{(0,2,0)} + K_{(1,0,0)}
  d=7, c=(3,2,2): Q_1 = 2q+3q^2+2q^3+2q^4+q^5+q^6 -> K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)}
  d=7, c=(4,2,1): Q_1 = 2q+2q^2+2q^3+2q^4+q^5+q^6+q^8 -> K_{(0,0,1)} + K_{(0,0,2)} + K_{(1,0,0)} + K_{(3,1,1)}

Question: Is Q_1 always the character of a set of sl_3 weights at level d?
The evaluation Q_1(1) = (d+1)(d+2)/6 - 1 = number of nontrivial C_3-orbits
of sl_3 level-d dominant weights.

Recall: sl_3 dominant weights at level d are triples (a,b,c) with a+b+c = d,
a,b,c >= 0. The number is (d+1)(d+2)/2. The C_3 group acts by cyclic
permutation (a,b,c) -> (b,c,a). Orbits: the fixed points are (d/3,d/3,d/3)
when d divisible by 3. Number of orbits = (d+1)(d+2)/6 when d not div by 3.
The trivial orbit (0,0,...) doesn't exist here since we have level d.
Wait: the orbit of (d,0,0) is {(d,0,0), (0,d,0), (0,0,d)}, size 3.

Actually the weight (0,0,0) is NOT at level d (it's at level 0).
The trivial weight at level d would need a+b+c=d.

So (d+1)(d+2)/6 counts C_3 orbits of level-d weights.
And Q_1(1) = (d+1)(d+2)/6 - 1 is one less than that.

The -1 is the subtraction of one orbit. Which orbit is removed?
The orbit {(d,0,0), (0,d,0), (0,0,d)} has size 3 for d >= 1.
But (d+1)(d+2)/6 - 1 does not match subtracting 1 orbit of size 3...

Actually Q_1(1) = base - 1 where base = (d+1)(d+2)/6.
And Q_n(1) = (base - 1)^n.

Let me think about this differently. The key polynomial decomposition of Q_1
tells us which sl_3 Demazure modules appear. Let me catalog the weights.
"""

import sys


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


def specialize_key_poly(u, exponents=(1, 2, 3)):
    K = compute_key_poly(u, len(exponents))
    result = {}
    for exp, coeff in K.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


print("=" * 70)
print("ANALYSIS OF Q_1 DECOMPOSITIONS")
print("=" * 70)

# Catalog the decompositions found
decomps = {
    (2, (1,1,0)): {(0, 0, 1): 1},
    (4, (2,1,1)): {(0, 0, 1): 1, (1, 0, 0): 1},
    (5, (2,2,1)): {(0, 1, 0): 1, (0, 2, 0): 1, (1, 0, 0): 1},
    (7, (3,2,2)): {(0, 0, 1): 1, (0, 0, 2): 1, (0, 1, 0): 1},
    (7, (4,2,1)): {(0, 0, 1): 1, (0, 0, 2): 1, (1, 0, 0): 1, (3, 1, 1): 1},
}

for (d, profile), decomp in decomps.items():
    base = (d+1)*(d+2)//6
    print(f"\nd={d}, c={profile}, Q_1(1) = {base - 1}")
    print(f"  Decomposition into {len(decomp)} Demazure characters:")
    
    total_at_1 = 0
    for u, mult in sorted(decomp.items()):
        K = compute_key_poly(u, 3)
        K_spec = specialize_key_poly(u, (1, 2, 3))
        val_at_1 = sum(K_spec.values())
        total_at_1 += mult * val_at_1
        
        # List the weight space of K_u
        weights = sorted(K.keys())
        level = sum(u)  # sum of components = "level" in some sense
        print(f"    {mult} * K_{u}: level={level}, dim={val_at_1}, weights={weights}")
    
    print(f"  Total at q=1: {total_at_1}")
    
    # List all sl_3 dominant weights at level d
    dom_weights = []
    for a in range(d+1):
        for b in range(d+1-a):
            c = d - a - b
            dom_weights.append((a, b, c))
    
    # C_3 orbits
    orbits = []
    seen = set()
    for w in dom_weights:
        if w in seen:
            continue
        orbit = set()
        ww = w
        for _ in range(3):
            orbit.add(ww)
            seen.add(ww)
            ww = (ww[1], ww[2], ww[0])
        orbits.append(sorted(orbit))
    
    print(f"  Level-{d} dominant weights: {len(dom_weights)}")
    print(f"  C_3 orbits: {len(orbits)}")
    print(f"  (d+1)(d+2)/6 = {base}")
    print(f"  Q_1(1) = {base - 1} = {base} - 1")

# Now examine the CRYSTAL STRUCTURE
print("\n" + "=" * 70)
print("CRYSTAL STRUCTURE ANALYSIS")
print("=" * 70)

# For each decomposition, compute the monomials in K_u
# and check if they correspond to sl_3 weight orbits
for (d, profile), decomp in decomps.items():
    print(f"\nd={d}, c={profile}:")
    
    all_monomials = {}
    for u, mult in decomp.items():
        K = compute_key_poly(u, 3)
        for exp, coeff in K.items():
            all_monomials[exp] = all_monomials.get(exp, 0) + mult * coeff
    
    # Group by total weight (sum of exponents)
    by_level = {}
    for exp, coeff in sorted(all_monomials.items()):
        lev = sum(exp)
        if lev not in by_level:
            by_level[lev] = []
        by_level[lev].append((exp, coeff))
    
    print(f"  Monomials by total degree:")
    for lev in sorted(by_level.keys()):
        entries = by_level[lev]
        print(f"    degree {lev}: {entries}")
    
    print(f"  Total monomials: {sum(all_monomials.values())}, expected Q_1(1) = {(d+1)*(d+2)//6 - 1}")

# Check: are the KEY INDICES related to C_3 orbit representatives?
print("\n" + "=" * 70)
print("KEY INDICES vs C_3 ORBIT REPRESENTATIVES")
print("=" * 70)

for (d, profile), decomp in decomps.items():
    print(f"\nd={d}, c={profile}:")
    print(f"  Key polynomial indices: {sorted(decomp.keys())}")
    
    # C_3 orbit representatives at level d (excluding some?)
    dom_weights = []
    for a in range(d+1):
        for b in range(d+1-a):
            c = d - a - b
            dom_weights.append((a, b, c))
    
    # What's the connection? The indices are NOT at level d.
    # Let me check if the WEIGHTS in the decomposition are at level d or nearby.
    all_weights = set()
    for u, mult in decomp.items():
        K = compute_key_poly(u, 3)
        for exp in K.keys():
            all_weights.add(exp)
    
    weight_levels = sorted(set(sum(w) for w in all_weights))
    print(f"  Weight levels: {weight_levels}")
    
    # The key indices have small components.
    # For d=7, c=(3,2,2): indices are (0,0,1), (0,0,2), (0,1,0)
    # These sum to 1, 2, 1 respectively. Not level d.
    
    # But perhaps the KEY INDEX relates to the weight after subtracting
    # the "reference weight" rho or something similar?
    
    # Alternative: the indices relate to the EXPONENTS in the specialization.
    # K_u(q,q^2,q^3) assigns weight e1*a + e2*b + e3*c to monomial x^(a,b,c).
    # The minimal degree of Q_1 is always 1 (for d >= 2).
    # K_{(0,0,1)} starts at degree 3, K_{(0,1,0)} at degree 2, K_{(1,0,0)} at degree 1.
    
    # Wait, that's not right. Let me check.
    for u in sorted(decomp.keys()):
        K_spec = specialize_key_poly(u, (1,2,3))
        print(f"    K_{u}(q,q^2,q^3) min_deg={min(K_spec.keys())}, val_at_1={sum(K_spec.values())}")

print("\n" + "=" * 70)
print("PATTERN SEARCH: Which key polys appear for which d?")
print("=" * 70)

# Let me also compute Q_1 for d=2,4,5 with the CW system to get exact polynomials
# and verify the decompositions are correct
for (d, profile), decomp in decomps.items():
    total_poly = {}
    for u, mult in decomp.items():
        K_spec = specialize_key_poly(u, (1, 2, 3))
        for deg, c in K_spec.items():
            total_poly[deg] = total_poly.get(deg, 0) + mult * c
    
    total_poly = {k: v for k, v in total_poly.items() if v != 0}
    
    parts = []
    for e in sorted(total_poly.keys()):
        c = total_poly[e]
        if c == 1: parts.append(f"q^{e}")
        else: parts.append(f"{c}q^{e}")
    print(f"d={d}, c={profile}: Q_1 = {' + '.join(parts)}")

print("\n" + "=" * 70)
print("KEY OBSERVATION: Schur polynomial content")
print("=" * 70)

# For dominant weights, K_lambda = s_lambda (Schur polynomial)
# K_{(0,0,1)} = s_{(1)} = x1+x2+x3 => at (q,q^2,q^3) = q+q^2+q^3 (dim=3)
# K_{(0,0,2)} = s_{(2)} = x1^2+x1x2+x1x3+x2^2+x2x3+x3^2 => q^2+q^3+q^4*2+q^5+q^6 (dim=6)
# Wait, that's for GL_3 symmetric functions.

# Let me check: is K_{(0,0,m)} always the symmetric Schur polynomial s_m?
for m in range(1, 5):
    u = (0, 0, m)
    K = compute_key_poly(u, 3)
    print(f"K_{u}:")
    for exp, c in sorted(K.items()):
        print(f"  x^{exp}: {c}")
    K_spec = specialize_key_poly(u, (1, 2, 3))
    parts = []
    for e in sorted(K_spec.keys()):
        c = K_spec[e]
        if c == 1: parts.append(f"q^{e}")
        else: parts.append(f"{c}q^{e}")
    print(f"  at (q,q^2,q^3): {' + '.join(parts)}")
    print(f"  dim = {sum(K_spec.values())} = C(m+2, 2) = {(m+1)*(m+2)//2}")

# K_{(0,1,0)} is a Demazure character, not Schur
for u in [(0, 1, 0), (0, 2, 0), (1, 0, 0), (1, 1, 0), (3, 1, 1)]:
    K = compute_key_poly(u, 3)
    K_spec = specialize_key_poly(u, (1, 2, 3))
    print(f"\nK_{u}: dim={sum(K_spec.values())}")
    for exp, c in sorted(K.items()):
        print(f"  x^{exp}: {c}")

