"""
Seed 3, Layer 3: Attempt to prove D_k^m >= 0 by induction on k.

Key reformulation: D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}

The domination D_{k-1}^m >= q^k * D_{k-1}^{m-1} means:
  [q^w] D_{k-1}^m >= [q^{w-k}] D_{k-1}^{m-1} for all w >= k.

We know:
  D_{k-1}^m(1) = (base-1)^{k-1} * base^{m-k+1}
  D_{k-1}^{m-1}(1) = (base-1)^{k-1} * base^{m-k}
  Ratio = base = (d+1)(d+2)/6

So at q=1, the domination holds with ratio = base.
The question is whether this "uniform domination by factor base" 
also holds coefficient-wise.

STRATEGY: Study the RATIO D_{k-1}^m[w+k] / D_{k-1}^{m-1}[w] for each weight w.
If this ratio is always >= 1, the domination holds.

Better: study WHEN the ratio first drops to 1 (the tightest point).
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

# Focus on d=4, profile (2,1,1)
d = 4; profile = (2,1,1); max_q = 200; n_max = 8
base = (d+1)*(d+2)//6

g, profiles = compute_gn_system(d, n_max, max_q)

h = {}
for m in range(n_max + 1):
    h[m] = compute_hm(g, profile, m, max_q)

D = defaultdict(dict)
for m in range(n_max + 1):
    D[0][m] = dict(h[m])
for k in range(1, n_max + 1):
    for m in range(k, n_max + 1):
        D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

# For each k, study the minimum ratio D_{k-1}^m[w+k] / D_{k-1}^{m-1}[w]
print(f"d={d}, profile={profile}, base={base}")
print(f"\n=== RATIO ANALYSIS ===")
print("For each (k, m), show the minimum ratio D_{k-1}^m[w+k] / D_{k-1}^{m-1}[w]")
print("(over all w where D_{k-1}^{m-1}[w] > 0)")

for k in range(1, 7):
    for m in range(k, min(n_max+1, k+5)):
        lhs = D[k-1].get(m, {})
        rhs = D[k-1].get(m-1, {})
        if not rhs:
            continue
        
        min_ratio = float('inf')
        tightest_w = None
        ratios = []
        for w in sorted(rhs.keys()):
            if rhs[w] > 0:
                lhs_val = lhs.get(w + k, 0)
                ratio = lhs_val / rhs[w]
                ratios.append((w, rhs[w], lhs_val, ratio))
                if ratio < min_ratio:
                    min_ratio = ratio
                    tightest_w = w
        
        print(f"\n  k={k}, m={m}: min_ratio={min_ratio:.3f} at w={tightest_w}")
        # Show first few ratios
        for w, rval, lval, r in ratios[:8]:
            print(f"    w={w}: D_{k-1}^{{m-1}}[{w}]={rval}, D_{k-1}^{m}[{w+k}]={lval}, ratio={r:.3f}")

# KEY: Check if the initial m coefficients of D_{k-1}^m match those of 
# D_{k-1}^{m-1} shifted by k.
# This is the "initial segment preservation at level k"
print(f"\n\n=== INITIAL SEGMENT PRESERVATION AT EACH LEVEL ===")
for k in range(0, 6):
    print(f"\n  Level k={k}:")
    for m in range(k+1, min(n_max+1, k+6)):
        Dk_m = D[k].get(m, {})
        Dk_m1 = D[k].get(m-1, {})
        if not Dk_m1:
            continue
        
        min_deg_m1 = min(Dk_m1.keys()) if Dk_m1 else None
        
        # Count how many leading coefficients of D_k^m match D_k^{m-1} shifted by (k+1)
        # (Note: D_k^m should be compared to D_k^{m-1} shifted by something)
        # Actually the recurrence is D_{k+1}^m = D_k^m - q^{k+1} D_k^{m-1}
        # So D_k^m starts with the same coefficients as q^{k+1} * D_k^{m-1}
        # shifted by (k+1), for some initial segment
        
        match_count = 0
        for w in sorted(Dk_m1.keys()):
            if Dk_m1[w] > 0:
                lhs_val = Dk_m.get(w + k + 1, 0)
                if lhs_val == Dk_m1[w]:
                    match_count += 1
                else:
                    break
        
        print(f"    D_{k}^{m} matches q^{k+1}*D_{k}^{{m-1}} for {match_count} leading coefficients")

print("\nDone.")
