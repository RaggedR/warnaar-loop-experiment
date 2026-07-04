"""
Seed 4, Layer 3: Compute Q_n for d=9 directly with high precision.
Since h_m has negative coefficients for d=9, the D_k^m tower doesn't directly
apply. But Q_n might still be nonneg (Seed 7's claim).

For d=9, ell = gcd(9,3) = 3, so Q_n = (q^3;q^3)_n * [z^n]((zq)_inf * F_c(z,q))

The key question: is Q_n nonneg for d=9?
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 500  # Need more for d=9

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
        print(f"  Computing g_{n} for d={d}...")
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

def compute_Q(g, profile, n, max_q):
    d = sum(profile)
    k = len(profile)
    ell = gcd(d, k)
    
    # Compute 1/(q;q)_j for j up to n
    def inv_qpoch(j):
        result = {0: 1}
        for i in range(1, j + 1):
            new = {}
            for p, c in result.items():
                exp = 0
                while p + i * exp <= max_q:
                    new[p + i * exp] = new.get(p + i * exp, 0) + c
                    exp += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result
    
    # inner = sum_j (-1)^j q^{j(j+1)/2} / (q;q)_j * g_{n-j}
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
    
    # Q_n = (q^ell;q^ell)_n * inner
    qpn = {0: 1}
    for i in range(1, n + 1):
        exp = ell * i
        new = {}
        for p, c in qpn.items():
            if p <= max_q: new[p] = new.get(p, 0) + c
            if p + exp <= max_q: new[p + exp] = new.get(p + exp, 0) - c
        qpn = {k: v for k, v in new.items() if v != 0}
    
    return poly_mul(qpn, inner, max_q)

# Compute for d=9 with smaller max_q but enough for Q_1
# For Q_1 with d=9: deg(Q_1) should be around (d-1)*1 = 8*1 = 8... 
# but wait, for d ≡ 0 mod 3 the formula is different.

# First try d=3 (smallest case with d ≡ 0 mod 3)
print("="*60)
print("d=3, checking Q_n positivity")
print("="*60)
d = 3
max_q = 100
g3, profiles3 = compute_gn_system(d, 4, max_q)

for profile in [(1,1,1), (2,1,0), (3,0,0)]:
    print(f"\nProfile {profile}:")
    for n in range(5):
        Qn = compute_Q(g3, profile, n, max_q)
        Qn_sum = sum(Qn.values()) if Qn else 0
        neg = [(deg, v) for deg, v in sorted(Qn.items()) if v < 0]
        items = sorted(Qn.items())
        print(f"  Q_{n}: sum={Qn_sum}, neg={neg[:5]}")
        if n <= 2 and items:
            print(f"    = {' + '.join(f'{v}q^{d}' for d,v in items[:15])}")

# d=6
print("\n" + "="*60)
print("d=6, checking Q_n positivity")
print("="*60)
d = 6
max_q = 200
g6, profiles6 = compute_gn_system(d, 3, max_q)

for profile in [(2,2,2), (3,2,1), (4,1,1)]:
    print(f"\nProfile {profile}:")
    for n in range(4):
        Qn = compute_Q(g6, profile, n, max_q)
        Qn_sum = sum(Qn.values()) if Qn else 0
        neg = [(deg, v) for deg, v in sorted(Qn.items()) if v < 0]
        print(f"  Q_{n}: sum={Qn_sum}, neg={neg[:5]}")

# d=9 (just Q_1)
print("\n" + "="*60)
print("d=9, checking Q_1 positivity")
print("="*60)
d = 9
max_q = 400
g9, profiles9 = compute_gn_system(d, 1, max_q)

for profile in [(3,3,3), (4,3,2), (5,2,2)]:
    print(f"\nProfile {profile}:")
    Qn = compute_Q(g9, profile, 1, max_q)
    Qn_sum = sum(Qn.values()) if Qn else 0
    neg = [(deg, v) for deg, v in sorted(Qn.items()) if v < 0]
    items = sorted(Qn.items())
    print(f"  Q_1: sum={Qn_sum}, neg={neg[:10]}")
    if items:
        print(f"    first 15: {items[:15]}")
        print(f"    last 5: {items[-5:]}")

