"""Verify iterated q-difference positivity for d=8 (second unproved case)."""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 60

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

def compute_gn_system(d, n_max, max_q, k=3):
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

d = 8
n_max = 2
max_q = 60
profile = (3, 3, 2)
base = (d+1)*(d+2)//6
expected_base = base - 1

print(f"d={d}, profile={profile}, base={base}, Q_n(1)={expected_base}^n")
print(f"Number of profiles: {len(all_profiles(d, 3))}")

g, profiles = compute_gn_system(d, n_max, max_q)

# Compute h_m
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

h = {}
for m in range(n_max + 1):
    h[m] = compute_hm(g, profile, m, max_q)
    neg = [(k, v) for k, v in sorted(h[m].items()) if v < 0]
    print(f"\n  h_{m}: sum={sum(h[m].values())}, neg={neg[:3] if neg else 'NONE'}")

# Compute D_k^m
D = defaultdict(dict)
for m in range(n_max + 1):
    D[0][m] = dict(h[m])

for k in range(1, n_max + 1):
    for m in range(k, n_max + 1):
        D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

print(f"\n  D_k^m table:")
all_pos = True
for k in range(n_max + 1):
    for m in range(k, n_max + 1):
        Dkm = D[k].get(m, {})
        neg = [(e, v) for e, v in sorted(Dkm.items()) if v < 0]
        Dkm_sum = sum(Dkm.values()) if Dkm else 0
        expected = (expected_base)**k * base**(m-k)
        status = "OK" if not neg else f"NEG: {neg[:5]}"
        print(f"    D_{k}^{m}: sum={Dkm_sum} (exp {expected}), {status}")
        if neg: all_pos = False

# Compute Q_n directly and verify
ell = gcd(d, 3)
for n in range(n_max + 1):
    def inv_qpoch(m):
        result = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in result.items():
                j = 0
                while p + i * j <= max_q:
                    new[p + i * j] = new.get(p + i * j, 0) + c
                    j += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result
    inner = {}
    for j in range(n + 1):
        sign = (-1) ** j
        shift = j * (j + 1) // 2
        if shift > max_q: break
        inv_j = inv_qpoch(j)
        gm = g[n - j].get(profile, {})
        term = poly_mul(inv_j, gm, max_q)
        term = poly_shift(term, shift, max_q)
        term = poly_scale(term, sign)
        inner = poly_add(inner, term)
    qpn = {0: 1}
    for i in range(1, n + 1):
        exp = ell * i
        new = {}
        for p, c in qpn.items():
            if p <= max_q: new[p] = new.get(p, 0) + c
            if p + exp <= max_q: new[p + exp] = new.get(p + exp, 0) - c
        qpn = {k: v for k, v in new.items() if v != 0}
    Q_n = poly_mul(qpn, inner, max_q)
    Q_n = {k: v for k, v in Q_n.items() if v != 0}
    neg_Q = [(k, v) for k, v in sorted(Q_n.items()) if v < 0]
    q1 = sum(Q_n.values())
    D_nn = D[n].get(n, {})
    diff = poly_sub(Q_n, D_nn)
    match = not diff or all(v == 0 for v in diff.values())
    print(f"\n  Q_{n}(1)={q1} (exp {expected_base**n}), Q=D? {match}, neg={neg_Q[:3] if neg_Q else 'NONE'}")

if all_pos:
    print(f"\n*** ALL D_k^m >= 0 for d={d} ***")
