"""
Seed 4, Layer 2: q-binomial transform positivity analysis.

Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}

This is the key formula. We know h_m >= 0 (coefficient-wise) and h_m(1) = base^m
where base = (d+1)(d+2)/6.

Question: Under what conditions on a non-negative polynomial sequence {h_m}
does the alternating q-binomial transform produce a non-negative result?

APPROACH 1: Factor the transform.
  Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j] h_{n-j}
  
  By the q-Vandermonde or Cauchy identity, this factors if h_m has special structure.
  
  In particular, if h_m = prod_{i=1}^r h_m^{(i)} (multiplicative), and each factor
  has the right form, the transform might factor into positive pieces.

APPROACH 2: Induction on n.
  Q_0 = h_0 = 1 >= 0. OK.
  Q_1 = h_1 - q h_0 = h_1 - q. Since h_1 starts with >= 2 terms at q^1, this is >= 0.
  Q_2 = h_2 - q(1+q) h_1 + q^3 h_0 = h_2 - (q+q^2) h_1 + q^3.
  
  For Q_2 >= 0: h_2 must dominate (q+q^2) h_1 - q^3 coefficient-wise.
  From our data: h_2 for d=7, c=(3,2,2):
    h_2 = 3q^2 + 6q^3 + 10q^4 + 11q^5 + 13q^6 + 12q^7 + 13q^8 + ...
    (q+q^2) h_1 = (q+q^2)(3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6)
               = 3q^2 + 6q^3 + 5q^4 + 4q^5 + 3q^6 + 2q^7 + q^8
    h_2 - (q+q^2)h_1 + q^3 = 0 + q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + ... = Q_2
  
  The cancellation at q^2 is EXACT (3 - 3 = 0). This is not a coincidence.

APPROACH 3: Study the "ratio" h_{m+1}/h_m.
  If h_m grows like base^m, the ratio should approach base (at q=1).
  The q-deformed ratio tells us about the coefficient growth.

Let me compute h_m for d=4 and d=7 and study the ratio structure.
"""

from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 80

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q_DEG):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i + j > max_deg: continue
            result[i + j] = result.get(i + j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def poly_scale(p, s):
    if s == 0: return {}
    return {k: v * s for k, v in p.items()}

def poly_shift(p, s, max_deg=MAX_Q_DEG):
    return {k + s: v for k, v in p.items() if k + s <= max_deg and k + s >= 0}

def all_profiles(d, k=3):
    if k == 1: return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c)
    J_set = set(J)
    c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set: c_new[i] -= 1
        elif i not in J_set and i_prev in J_set: c_new[i] += 1
    return tuple(c_new)

def get_transitions(c):
    k = len(c)
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    trans = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            sign = (-1) ** (size - 1)
            cJ = shifted_profile(c, J)
            if any(x < 0 for x in cJ): continue
            trans.append((sign, size, cJ))
    return trans

def compute_gn_system(d, n_max, max_q=MAX_Q_DEG, k=3):
    profiles = all_profiles(d, k)
    trans = {c: get_transitions(c) for c in profiles}
    g = defaultdict(lambda: defaultdict(dict))
    for c in profiles:
        g[0][c] = {0: 1}
    
    for n in range(1, n_max + 1):
        rhs = {}
        for c in profiles:
            r = {}
            for sign, s, cJ in trans[c]:
                partial_sum = {}
                for m in range(n):
                    partial_sum = poly_add(partial_sum, g[m][cJ])
                term = poly_shift(poly_scale(partial_sum, sign), n * s, max_q)
                r = poly_add(r, term)
            rhs[c] = r
        
        curr_gn = {c: {} for c in profiles}
        for deg in range(max_q + 1):
            for c in profiles:
                val = rhs[c].get(deg, 0)
                for sign, s, cJ in trans[c]:
                    src_deg = deg - n * s
                    if src_deg >= 0:
                        val += sign * curr_gn[cJ].get(src_deg, 0)
                if val != 0:
                    curr_gn[c][deg] = val
        
        for c in profiles:
            g[n][c] = curr_gn[c]
    
    return g, profiles

# Compute h_m for d=4 and d=7
for d, profile, n_max in [(4, (2, 1, 1), 4), (7, (3, 2, 2), 3)]:
    max_q = 50 if d <= 5 else 40
    ell = gcd(d, 3)
    base = (d + 1) * (d + 2) // 6
    
    print(f"\n{'='*70}")
    print(f"d={d}, profile={profile}, base={base}")
    print(f"{'='*70}")
    
    g, profiles = compute_gn_system(d, n_max, max_q)
    
    # Compute h_m = (q;q)_m * g_m
    h = {}
    for m in range(n_max + 1):
        gm = g[m].get(profile, {})
        qpoch = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in qpoch.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + i <= max_q:
                    new[p + i] = new.get(p + i, 0) - c
            qpoch = {k: v for k, v in new.items() if v != 0}
        h[m] = poly_mul(qpoch, gm, max_q)
        
        neg_h = [(k, v) for k, v in sorted(h[m].items()) if v < 0]
        h_sum = sum(h[m].values()) if h[m] else 0
        min_d = min(h[m].keys()) if h[m] else 0
        max_d = max(h[m].keys()) if h[m] else 0
        print(f"\n  h_{m}: sum={h_sum} (expected {base**m}), deg [{min_d}, {max_d}]")
        print(f"    neg = {neg_h[:5] if neg_h else 'NONE'}")
        # Print coefficients
        if h[m]:
            coeffs = sorted(h[m].items())
            print(f"    coeffs: {coeffs}")
    
    # Key structural check: is h_m related to h_1^m?
    if n_max >= 2:
        h1_sq = poly_mul(h[1], h[1], max_q)
        diff = poly_sub(h[2], h1_sq)
        print(f"\n  h_2 - h_1^2:")
        neg_diff = [(k, v) for k, v in sorted(diff.items()) if v < 0]
        pos_diff = [(k, v) for k, v in sorted(diff.items()) if v > 0]
        print(f"    Negative terms: {neg_diff[:10]}")
        print(f"    Positive terms: {pos_diff[:10]}")
        print(f"    Sum: {sum(diff.values()) if diff else 0} (expected {base**2 - base**2} = 0)")
    
    # Check: does h_m coefficient-dominate q * h_{m-1}?
    # i.e., h_m - q * h_{m-1} >= 0 coefficient-wise?
    for m in range(1, n_max + 1):
        q_hm1 = poly_shift(h[m-1], 1, max_q)  # q * h_{m-1}
        diff = poly_sub(h[m], q_hm1)
        neg = [(k, v) for k, v in sorted(diff.items()) if v < 0]
        print(f"\n  h_{m} - q*h_{m-1}: neg = {neg[:5] if neg else 'NONE'}, sum = {sum(diff.values()) if diff else 0}")
    
    # Check: does h_m coefficient-dominate q^m * h_{m-1}?
    for m in range(1, n_max + 1):
        qm_hm1 = poly_shift(h[m-1], m, max_q)
        diff = poly_sub(h[m], qm_hm1)
        neg = [(k, v) for k, v in sorted(diff.items()) if v < 0]
        print(f"\n  h_{m} - q^{m}*h_{m-1}: neg = {neg[:5] if neg else 'NONE'}, sum = {sum(diff.values()) if diff else 0}")

