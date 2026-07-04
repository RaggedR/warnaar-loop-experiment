"""
Seed 3, Layer 3: Injection analysis for the domination D_{k-1}^m >= q^k * D_{k-1}^{m-1}.

The question: is there an injection phi: Objects(D_{k-1}^{m-1}, weight w) -> Objects(D_{k-1}^m, weight w+k)
that maps each object at weight w to a distinct object at weight w+k?

This is equivalent to: for each coefficient [q^w] D_{k-1}^{m-1}, we need [q^{w+k}] D_{k-1}^m >= [q^w] D_{k-1}^{m-1}.

We study the coefficient-by-coefficient comparison at k=1 (base case of induction):
h_m(q) >= q * h_{m-1}(q) coefficient-wise.
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 150

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

# For d=4, study the k=1 base case: h_m >= q * h_{m-1}
d = 4
profile = (2, 1, 1)
max_q = 150
n_max = 6

print(f"d={d}, profile={profile}")
print(f"Base case of induction: h_m >= q * h_{{m-1}} coefficient-wise\n")

g, profiles = compute_gn_system(d, n_max, max_q)

h = {}
for m in range(n_max + 1):
    h[m] = compute_hm(g, profile, m, max_q)

# Study h_m - q*h_{m-1} for several m
for m in range(1, n_max + 1):
    delta = poly_sub(h[m], poly_shift(h[m-1], 1, max_q))
    deg_delta = max(delta.keys()) if delta else 0
    delta_sum = sum(delta.values()) if delta else 0
    min_coeff = min(delta.values()) if delta else 0

    hm_coeffs = [h[m].get(i, 0) for i in range(min(30, deg_delta+1))]
    shifted_coeffs = [h[m-1].get(i-1, 0) for i in range(min(30, deg_delta+1))]
    delta_coeffs = [delta.get(i, 0) for i in range(min(30, deg_delta+1))]

    print(f"\nm={m}: h_{m}(1)={sum(h[m].values())}, h_{{m-1}}(1)={sum(h[m-1].values())}, delta(1)={delta_sum}, min={min_coeff}")
    print(f"  h_{m}:     {hm_coeffs}")
    print(f"  q*h_{{m-1}}: {shifted_coeffs}")
    print(f"  delta:    {delta_coeffs}")

# Now study the RATIO pattern: for each degree w, compute h_m[w+1] / h_{m-1}[w]
print("\n\n=== RATIO ANALYSIS: h_m[w+1] / h_{m-1}[w] ===")
for m in range(1, 5):
    print(f"\nm={m}:")
    for w in range(min(25, max(h[m-1].keys()) if h[m-1] else 0)):
        hm1_w = h[m-1].get(w, 0)
        hm_w1 = h[m].get(w+1, 0)
        if hm1_w > 0:
            ratio = hm_w1 / hm1_w
            surplus = hm_w1 - hm1_w
            print(f"  w={w}: h_{m-1}[{w}]={hm1_w}, h_{m}[{w+1}]={hm_w1}, ratio={ratio:.3f}, surplus={surplus}")

# Now do the same for k=2: D_1^m >= q^2 * D_1^{m-1}
print("\n\n=== k=2: D_1^m >= q^2 * D_1^{m-1} ===")
D = defaultdict(dict)
for m in range(n_max + 1):
    D[0][m] = dict(h[m])
for k in range(1, n_max + 1):
    for m in range(k, n_max + 1):
        D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

for m in range(2, min(n_max+1, 6)):
    delta = poly_sub(D[1][m], poly_shift(D[1][m-1], 2, max_q))
    deg_delta = max(delta.keys()) if delta else 0
    delta_sum = sum(delta.values()) if delta else 0
    min_coeff = min(delta.values()) if delta else 0

    d1m_coeffs = [D[1][m].get(i, 0) for i in range(min(30, deg_delta+1))]
    shifted_coeffs = [D[1][m-1].get(i-2, 0) for i in range(min(30, deg_delta+1))]
    delta_coeffs = [delta.get(i, 0) for i in range(min(30, deg_delta+1))]

    print(f"\nm={m}: D_1^{m}(1)={sum(D[1][m].values())}, D_1^{{m-1}}(1)={sum(D[1][m-1].values())}, delta(1)={delta_sum}, min={min_coeff}")
    print(f"  D_1^{m}:      {d1m_coeffs}")
    print(f"  q^2*D_1^{{m-1}}: {shifted_coeffs}")
    print(f"  delta:       {delta_coeffs}")

print("\nDone.")
