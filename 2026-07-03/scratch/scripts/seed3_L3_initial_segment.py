"""
Seed 3, Layer 3: Study the "initial segment preservation" in h_m.

Key observation: h_{m+1}[w+1] = h_m[w] for small w, then h_{m+1}[w+1] > h_m[w] for larger w.

This means the injection phi: Objects(h_{m-1}, w) -> Objects(h_m, w+1) is a BIJECTION
for small weights. The "new" objects in D_k^m = h_m - q*h_{m-1} only appear at larger weights.

Can we characterize the initial segment length? How many coefficients are preserved?
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 200

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items(): result[k] = result.get(k, 0) + v
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

def compute_gn_system(d, n_max, max_q=MAX_Q_DEG, k=3):
    profiles = all_profiles(d, k)
    trans = {c: get_transitions(c) for c in profiles}
    g = defaultdict(lambda: defaultdict(dict))
    for c in profiles: g[0][c] = {0: 1}
    for n in range(1, n_max + 1):
        rhs = {}
        for c in profiles:
            r = {}
            for sign, s, cJ in trans[c]:
                partial_sum = {}
                for m in range(n): partial_sum = poly_add(partial_sum, g[m][cJ])
                term = poly_shift(poly_scale(partial_sum, sign), n * s, max_q)
                r = poly_add(r, term)
            rhs[c] = r
        curr_gn = {c: {} for c in profiles}
        for deg in range(max_q + 1):
            for c in profiles:
                val = rhs[c].get(deg, 0)
                for sign, s, cJ in trans[c]:
                    src_deg = deg - n * s
                    if src_deg >= 0: val += sign * curr_gn[cJ].get(src_deg, 0)
                if val != 0: curr_gn[c][deg] = val
        for c in profiles: g[n][c] = curr_gn[c]
    return g, profiles

def compute_hm(g, profile, m, max_q):
    gm = g[m].get(profile, {})
    qpoch = {0: 1}
    for i in range(1, m + 1):
        new = {}
        for p, c in qpoch.items():
            if p <= max_q: new[p] = new.get(p, 0) + c
            if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
        qpoch = {k: v for k, v in new.items() if v != 0}
    return poly_mul(qpoch, gm, max_q)

# Compute for d=4
for d, profile in [(4, (2,1,1)), (5, (2,2,1)), (7, (3,2,2))]:
    max_q = 200 if d <= 5 else 100
    n_max = 7 if d <= 5 else 5
    
    print(f"\n{'='*70}")
    print(f"d={d}, profile={profile}")
    print(f"{'='*70}")
    
    g, profiles = compute_gn_system(d, n_max, max_q)
    
    h = {}
    for m in range(n_max + 1):
        h[m] = compute_hm(g, profile, m, max_q)
    
    # For each pair (m, m+1), find how many leading coefficients match
    print(f"\n  Initial segment preservation: h_{{m+1}}[w+1] = h_m[w] for how many w?")
    for m in range(n_max):
        # Find min degree of h_m
        if not h[m]:
            continue
        min_deg = min(h[m].keys())
        max_deg_m = max(h[m].keys())
        
        # Count matching coefficients
        match_count = 0
        for w in range(min_deg, max_deg_m + 1):
            hm_w = h[m].get(w, 0)
            hm1_w1 = h[m+1].get(w+1, 0)
            if hm_w == hm1_w1 and hm_w > 0:
                match_count += 1
            elif hm_w > 0:
                break  # First mismatch
        
        # Also compute min_deg of D_1^{m+1} = h_{m+1} - q*h_m
        D1 = poly_sub(h[m+1], poly_shift(h[m], 1, max_q))
        D1_min = min(D1.keys()) if D1 else None
        h_m1_min = min(h[m+1].keys()) if h[m+1] else None
        
        print(f"    m={m}: {match_count} matching coeffs, "
              f"min_deg(h_{m})={min_deg}, min_deg(h_{m+1})={h_m1_min}, "
              f"min_deg(D_1^{m+1})={D1_min}")
    
    # Study the minimum degree pattern
    print(f"\n  Minimum degrees:")
    for m in range(n_max + 1):
        if h[m]:
            md = min(h[m].keys())
            print(f"    min_deg(h_{m}) = {md}")
    
    # Now study the D_k^m tower minimum degrees
    D = defaultdict(dict)
    for m in range(n_max + 1):
        D[0][m] = dict(h[m])
    for k in range(1, n_max + 1):
        for m in range(k, n_max + 1):
            D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))
    
    print(f"\n  D_k^m minimum degree table:")
    header = "  k\\m " + "".join(f"{m:>8}" for m in range(min(n_max+1, 8)))
    print(header)
    for k in range(min(n_max+1, 7)):
        row = f"  {k}   "
        for m in range(min(n_max+1, 8)):
            if m >= k and D[k].get(m):
                md = min(D[k][m].keys())
                row += f"{md:>8}"
            else:
                row += "       -"
        print(row)
    
    # CRITICAL: study the leading coefficient at min degree
    print(f"\n  D_k^m leading coefficient (at min degree):")
    header = "  k\\m " + "".join(f"{m:>8}" for m in range(min(n_max+1, 8)))
    print(header)
    for k in range(min(n_max+1, 7)):
        row = f"  {k}   "
        for m in range(min(n_max+1, 8)):
            if m >= k and D[k].get(m):
                md = min(D[k][m].keys())
                lc = D[k][m][md]
                row += f"{lc:>8}"
            else:
                row += "       -"
        print(row)

print("\nDone.")
