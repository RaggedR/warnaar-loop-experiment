#!/usr/bin/env python3
"""
Seed 6: Detailed analysis of Q_{1,c}(q) across many profiles.
Test whether Q_1 depends only on d or also on the specific profile.
"""
from fractions import Fraction

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_multiply(a, b, q_bound):
    result = {}
    for da, ca in a.items():
        if da > q_bound: continue
        for db, cb in b.items():
            d = da + db
            if d > q_bound: continue
            result[d] = result.get(d, 0) + ca * cb
    return {k: v for k, v in result.items() if v != 0}

def poly_inverse(p, q_bound):
    c0 = p.get(0, 0)
    assert c0 != 0
    inv_c0 = Fraction(1, c0)
    result = {0: inv_c0}
    for d in range(1, q_bound + 1):
        s = Fraction(0)
        for j in range(1, d + 1):
            pj = p.get(j, 0)
            rj = result.get(d - j, 0)
            if pj != 0 and rj != 0:
                s += Fraction(pj) * Fraction(rj)
        result[d] = -inv_c0 * s
    return result

def q_pochhammer_inf(a_exp, q_exp, q_bound):
    result = {0: 1}
    i = 0
    while True:
        power = a_exp + q_exp * i
        if power > q_bound: break
        new_result = {}
        for deg, coeff in result.items():
            if deg <= q_bound:
                new_result[deg] = new_result.get(deg, 0) + coeff
            if deg + power <= q_bound:
                new_result[deg + power] = new_result.get(deg + power, 0) - coeff
        result = {k: v for k, v in new_result.items() if v != 0}
        i += 1
    return result

def compute_Fc1(c, q_bound):
    """F_{c,1}(q) for max entry <= 1."""
    c1, c2, c3 = c
    result = {}
    for L1 in range(q_bound + 1):
        for L2 in range(min(L1 + c2, q_bound - L1) + 1):
            L3_min = max(0, L1 - c1)
            L3_max = min(L2 + c3, q_bound - L1 - L2)
            for L3 in range(L3_min, L3_max + 1):
                if L2 < L3 - c3: continue
                size = L1 + L2 + L3
                if size <= q_bound:
                    result[size] = result.get(size, 0) + 1
    return result

def compute_Q1(c, q_bound):
    """Compute Q_{1,c}(q)."""
    Fc0 = {0: 1}
    Fc1 = compute_Fc1(c, q_bound)
    f0 = {0: 1}
    f1 = poly_add(Fc1, {k: -v for k, v in Fc0.items()})
    
    # [z^1]((zq;q)_inf * F_c(z,q)) = a_0*f_1 + a_1*f_0 = f_1 - q/(1-q)
    a1_series = {deg: -1 for deg in range(1, q_bound+1)}
    z1 = poly_add(f1, a1_series)
    
    # Q_1 = (1-q) * z1
    Q1 = poly_multiply({0: 1, 1: -1}, z1, q_bound)
    return {k: int(v) if isinstance(v, Fraction) else v for k, v in Q1.items()}

def main():
    q_bound = 40
    
    # Generate all profiles for each d
    for d in [2, 4, 5, 7, 8, 10, 11]:
        if d % 3 == 0:
            continue
        print(f"\nd = {d}, expected Q_1(1) = {(d+1)*(d+2)//6 - 1}")
        print("-" * 50)
        
        # Generate profiles: all (c0,c1,c2) with c0+c1+c2=d, ci >= 0
        profiles = []
        for c0 in range(d+1):
            for c1 in range(d-c0+1):
                c2 = d - c0 - c1
                profiles.append((c0, c1, c2))
        
        # Compute Q_1 for a selection of profiles
        Q1_polys = {}
        for c in profiles[:10]:  # cap at 10 for speed
            Q1 = compute_Q1(c, q_bound)
            coeffs = tuple(sorted(Q1.items()))
            print(f"  c = {c}: Q_1 = ", end="")
            terms = []
            for deg in range(q_bound+1):
                v = Q1.get(deg, 0)
                if v != 0:
                    terms.append(f"{v}q^{deg}")
            print(" + ".join(terms) if terms else "0")
            
            key = coeffs
            if key not in Q1_polys:
                Q1_polys[key] = []
            Q1_polys[key].append(c)
        
        print(f"  Distinct Q_1 polynomials: {len(Q1_polys)}")
        if len(Q1_polys) > 1:
            print("  WARNING: Q_1 depends on the profile, not just d!")
            for poly, profs in Q1_polys.items():
                print(f"    {dict(poly)} <- {profs}")
        
        # Check properties of Q_1
        sample_Q1 = compute_Q1(profiles[0], q_bound)
        nonzero_degs = sorted([k for k, v in sample_Q1.items() if v != 0])
        print(f"  Nonzero degrees: {nonzero_degs}")
        print(f"  Number of nonzero terms: {len(nonzero_degs)}")
        print(f"  Sum: {sum(v for v in sample_Q1.values())}")
        all_pos = all(v >= 0 for v in sample_Q1.values())
        print(f"  All nonneg: {all_pos}")

if __name__ == "__main__":
    main()
