"""
Seed 3, Layer 3: Verify universality for d=2 (simplest case where Warnaar proved Q_n >= 0).
For d=2, c=(1,1,0) or (1,0,1) or (0,1,1), base=2, Q_n = q^{n^2} (single term!).
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

d = 2
profile = (1, 1, 0)
max_q = 200
n_max = 10

print(f"d={d}, profile={profile}, base={(d+1)*(d+2)//6}")

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

print("\nh_m polynomials:")
for m in range(min(8, n_max+1)):
    hm = h[m]
    coeffs = [hm.get(i, 0) for i in range(max(hm.keys())+1)] if hm else [0]
    print(f"  h_{m} = {coeffs[:20]}")

print("\nD_k^m min_deg table:")
header = "  k\\m " + "".join(f"{m:>6}" for m in range(min(n_max+1, 11)))
print(header)
for k in range(min(n_max+1, 9)):
    row = f"  {k}   "
    for m in range(min(n_max+1, 11)):
        if m >= k and D[k].get(m):
            md = min(D[k][m].keys())
            row += f"{md:>6}"
        else:
            row += "     -"
    print(row)

print("\nD_k^m leading coefficient:")
header = "  k\\m " + "".join(f"{m:>6}" for m in range(min(n_max+1, 11)))
print(header)
for k in range(min(n_max+1, 9)):
    row = f"  {k}   "
    for m in range(min(n_max+1, 11)):
        if m >= k and D[k].get(m):
            md = min(D[k][m].keys())
            lc = D[k][m][md]
            row += f"{lc:>6}"
        else:
            row += "     -"
    print(row)

print("\nQ_n = D_n^n:")
for n in range(min(8, n_max+1)):
    Dnn = D[n].get(n, {})
    if Dnn:
        coeffs = [Dnn.get(i, 0) for i in range(max(Dnn.keys())+1)]
        print(f"  Q_{n} = {coeffs[:20]}")
    else:
        print(f"  Q_{n} = {{}}")

print("\nDone.")
