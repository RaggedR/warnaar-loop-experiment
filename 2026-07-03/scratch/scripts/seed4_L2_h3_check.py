"""Quick check: is h_3 for d=7 truncated? Sum should be 12^3 = 1728."""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 120

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

d = 7; n_max = 3; max_q = 120; profile = (3, 2, 2)
profiles = all_profiles(d, 3)
trans = {c: get_transitions(c) for c in profiles}
g = defaultdict(lambda: defaultdict(dict))
for c in profiles: g[0][c] = {0: 1}

for n in range(1, n_max + 1):
    print(f"Computing g_{n}...")
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

# Compute h_3
gm = g[3].get(profile, {})
qpoch = {0: 1}
for i in range(1, 4):
    new = {}
    for p, c in qpoch.items():
        if p <= max_q: new[p] = new.get(p, 0) + c
        if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
    qpoch = {k: v for k, v in new.items() if v != 0}
h3 = poly_mul(qpoch, gm, max_q)
h3_sum = sum(h3.values())
neg_h3 = [(k, v) for k, v in sorted(h3.items()) if v < 0]
max_deg_h3 = max(h3.keys()) if h3 else 0

print(f"\nh_3 for d=7, c=(3,2,2):")
print(f"  sum = {h3_sum} (expected {12**3} = 1728)")
print(f"  max_deg = {max_deg_h3}")
print(f"  neg = {neg_h3[:5] if neg_h3 else 'NONE'}")

# Print tail
tail = [(k, v) for k, v in sorted(h3.items()) if k >= max_deg_h3 - 20]
print(f"  tail: {tail}")

# Also verify h_m - q*h_{m-1} >= 0 for m=3
h2 = poly_mul(qpoch, g[2].get(profile, {}), max_q)  # wrong qpoch
# Recompute h_2
qpoch2 = {0: 1}
for i in range(1, 3):
    new = {}
    for p, c in qpoch2.items():
        if p <= max_q: new[p] = new.get(p, 0) + c
        if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
    qpoch2 = {k: v for k, v in new.items() if v != 0}
h2 = poly_mul(qpoch2, g[2].get(profile, {}), max_q)

q_h2 = poly_shift(h2, 1, max_q)
diff = poly_sub(h3, q_h2)
neg_diff = [(k, v) for k, v in sorted(diff.items()) if v < 0]
print(f"\n  h_3 - q*h_2: neg = {neg_diff[:5] if neg_diff else 'NONE'}")
print(f"  h_3 - q*h_2 sum = {sum(diff.values()) if diff else 0}")

