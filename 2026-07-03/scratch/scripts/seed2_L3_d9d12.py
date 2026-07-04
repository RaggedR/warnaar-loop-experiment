"""
Seed 2, Layer 3: Test positivity for d=9 and d=12.
d=9: base = 10*11/6 = 55/3 -- NOT integer, so d=9 equiv 0 mod 3
d=12: base = 13*14/6 = 91/3 -- NOT integer, so d=12 equiv 0 mod 3

Wait: base = (d+1)(d+2)/6 - 1. Let me recalculate.
d=9: (10)(11)/6 - 1 = 110/6 - 1. Hmm, 110/6 is not integer.
Actually for d equiv 0 mod 3, the formula gives non-integer.

Let me check what the synthesis says: "Positivity for d equiv 0 mod 3 holds 
in all computed cases (d=3, 6). The conjecture's restriction is about the 
evaluation formula, not positivity."

So for d=9 (equiv 0 mod 3), we test positivity of Q_n without checking evaluation.
For d=10 (not equiv 0 mod 3): base = 11*12/6 - 1 = 22-1 = 21.
For d=11 (not equiv 0 mod 3): base = 12*13/6 - 1 = 26-1 = 25.

Let me do d=8 (already partly done), d=9, d=10.
d=8: base = 9*10/6 - 1 = 15-1 = 14, profiles like (3,3,2)
d=9: 3|d, special
d=10: base = 11*12/6 - 1 = 22-1 = 21
"""
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
def poly_eval1(p):
    return sum(p.values()) if p else 0
def poly_to_list(p):
    if not p: return [0]
    md = max(p.keys())
    return [p.get(i, 0) for i in range(md + 1)]

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

def compute_Q_direct(g, profile, n, max_q):
    ell = gcd(sum(profile), len(profile))
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
    return poly_mul(qpn, inner, max_q)


# Test d=9 (equiv 0 mod 3)
for d, profiles_to_test in [
    (9, [(3,3,3), (4,3,2), (5,3,1)]),
    (12, [(4,4,4), (5,4,3), (6,4,2)]),
]:
    ell = gcd(d, 3)
    print(f"\n{'='*70}")
    print(f"d={d}, ell=gcd({d},3)={ell}")
    if d % 3 == 0:
        print(f"  NOTE: d equiv 0 mod 3, base formula not integer")
    else:
        base = (d+1)*(d+2)//6 - 1
        print(f"  base = {base}")
    print(f"{'='*70}")
    
    n_max = 3
    max_q = MAX_Q_DEG
    g, all_profs = compute_gn_system(d, n_max, max_q)
    
    for profile in profiles_to_test:
        if profile not in [(c0,c1,c2) for c0 in range(d+1) for c1 in range(d-c0+1) for c2 in [d-c0-c1]]:
            print(f"  Profile {profile} not valid for d={d}")
            continue
        
        print(f"\n  Profile {profile}:")
        for n in range(n_max + 1):
            Qn = compute_Q_direct(g, profile, n, max_q)
            coeffs = poly_to_list(Qn)
            neg = [i for i, c in enumerate(coeffs) if c < 0]
            val1 = poly_eval1(Qn)
            deg = max(Qn.keys()) if Qn else 0
            
            if len(coeffs) <= 30:
                print(f"    Q_{n}: {coeffs}")
            else:
                print(f"    Q_{n}: deg={deg}, #terms={len(Qn)}")
            
            if neg:
                print(f"      *** NEGATIVE at degrees {neg[:10]} ***")
            else:
                print(f"      NONNEG, eval1={val1}, deg={deg}")
