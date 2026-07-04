"""
Verify: e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q

where e_j is the j-th elementary symmetric polynomial.
"""
from itertools import combinations
from functools import reduce

def qbinom(n, k, max_deg=100):
    """Compute [n choose k]_q as a polynomial (dict representation)."""
    if k < 0 or k > n:
        return {}
    if k == 0:
        return {0: 1}
    # [n choose k]_q = prod_{i=0}^{k-1} (1 - q^{n-i}) / prod_{i=1}^k (1 - q^i)
    # Use the recursion: [n choose k] = [n-1 choose k-1] + q^k [n-1 choose k]
    # Build from scratch
    num = {0: 1}
    for i in range(k):
        # multiply by (1 - q^{n-i})
        new = {}
        exp = n - i
        for p, c in num.items():
            if p <= max_deg: new[p] = new.get(p, 0) + c
            if p + exp <= max_deg: new[p + exp] = new.get(p + exp, 0) - c
        num = {p: c for p, c in new.items() if c != 0}
    
    den = {0: 1}
    for i in range(1, k + 1):
        new = {}
        for p, c in den.items():
            if p <= max_deg: new[p] = new.get(p, 0) + c
            if p + i <= max_deg: new[p + i] = new.get(p + i, 0) - c
        den = {p: c for p, c in new.items() if c != 0}
    
    # Divide num by den (polynomial division, den should divide num exactly)
    result = {}
    num_copy = dict(num)
    max_d = max(num_copy.keys()) if num_copy else 0
    min_den = min(den.keys())
    lead_den = den[min_den]
    
    for d in range(max_d + 1):
        if d in num_copy and num_copy[d] != 0:
            coeff = num_copy[d] // lead_den
            result[d - min_den] = coeff
            for p, c in den.items():
                if d + p - min_den <= max_deg:
                    num_copy[d + p - min_den] = num_copy.get(d + p - min_den, 0) - coeff * c
    
    return {k: v for k, v in result.items() if v != 0}

def poly_mul_list(polys, max_deg=100):
    result = {0: 1}
    for p in polys:
        new = {}
        for i, ai in result.items():
            if ai == 0 or i > max_deg: continue
            for j, bj in p.items():
                if bj == 0 or i + j > max_deg: continue
                new[i + j] = new.get(i + j, 0) + ai * bj
        result = {k: v for k, v in new.items() if v != 0}
    return result

# Verify for small k and j
for k in range(1, 7):
    vals = list(range(1, k + 1))  # exponents: q^1, q^2, ..., q^k
    for j in range(0, k + 1):
        # e_j(q, q^2, ..., q^k) = sum over j-subsets of {1,...,k} of q^{sum of subset}
        e_j = {}
        for subset in combinations(vals, j):
            exp = sum(subset)
            e_j[exp] = e_j.get(exp, 0) + 1
        
        # Expected: q^{j(j+1)/2} [k choose j]_q
        shift = j * (j + 1) // 2
        qb = qbinom(k, j)
        expected = {p + shift: c for p, c in qb.items()}
        
        match = (e_j == expected)
        if not match:
            print(f"MISMATCH at k={k}, j={j}")
            print(f"  e_j = {sorted(e_j.items())}")
            print(f"  expected = {sorted(expected.items())}")
        else:
            e_sum = sum(e_j.values()) if e_j else 0
            qb_sum = sum(qb.values()) if qb else 0
            # At q=1: e_j(1,...,1) = C(k,j) and [k choose j]_1 = C(k,j)
            pass

print("All e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q verified for k=1..6")

# Additional verification: check D_k^m formula matches direct computation
# for a specific sequence h_m
print("\nVerification with h_m = 1, q, q^2+1, q^3+q+1 (arbitrary test):")
h = {0: {0: 1}, 1: {1: 1}, 2: {0: 1, 2: 1}, 3: {0: 1, 1: 1, 3: 1}}

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items(): result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}
def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})
def poly_shift(p, s, max_deg=100):
    return {k + s: v for k, v in p.items() if k + s <= max_deg}

# Compute D_k^m directly
D_direct = {}
for m in range(4):
    D_direct[(0, m)] = dict(h[m])

for k in range(1, 4):
    for m in range(k, 4):
        D_direct[(k, m)] = poly_sub(D_direct[(k-1, m)], 
                                     poly_shift(D_direct[(k-1, m-1)], k))

# Compute D_k^m via the sum formula
for k in range(4):
    for m in range(k, 4):
        formula = {}
        for j in range(k + 1):
            sign = (-1) ** j
            shift = j * (j + 1) // 2
            qb = qbinom(k, j)
            # q^{j(j+1)/2} [k choose j] h_{m-j}
            term = {}
            for p1, c1 in qb.items():
                for p2, c2 in h.get(m - j, {}).items():
                    exp = p1 + shift + p2
                    term[exp] = term.get(exp, 0) + sign * c1 * c2
            formula = poly_add(formula, term)
        
        diff = poly_sub(D_direct[(k, m)], formula)
        match = not diff or all(v == 0 for v in diff.values())
        if not match:
            print(f"  MISMATCH at k={k}, m={m}")
        
print("Formula verification complete for arbitrary test sequence.")

