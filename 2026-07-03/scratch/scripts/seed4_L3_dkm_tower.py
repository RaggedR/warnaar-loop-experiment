"""
Seed 4, Layer 3: Extended D_k^m tower computation.
Compute D_k^m for d=4,5,7 with k,m up to 6.
Look for patterns: factorization, q-Pochhammer divisibility, ratios.
Also compute d=9 (d == 0 mod 3) to test Seed 7's claim.
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 300

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

def poly_min_neg(p):
    negs = [(deg, v) for deg, v in p.items() if v < 0]
    if not negs: return None
    return min(negs, key=lambda x: x[1])

# Main computation
test_cases = [
    (4, [(2,1,1)], 6, 200),
    (5, [(2,2,1)], 6, 250),
    (7, [(3,2,2)], 5, 200),
    (9, [(3,3,3), (4,3,2)], 4, 250),
]

for d, profile_list, m_max, max_q in test_cases:
    print(f"\n{'='*80}")
    print(f"d={d}, m_max={m_max}, max_q={max_q}")
    print(f"{'='*80}")

    g, profiles = compute_gn_system(d, m_max, max_q)

    for profile in profile_list:
        base = (d+1)*(d+2)//6
        ell = gcd(d, 3)
        print(f"\nProfile {profile}, d={d}, base={base}, ell={ell}")

        h = {}
        for m in range(m_max + 1):
            h[m] = compute_hm(g, profile, m, max_q)
            hm_sum = sum(h[m].values()) if h[m] else 0
            neg = poly_min_neg(h[m])
            print(f"  h_{m}: sum={hm_sum}, expected={base**m}, maxdeg={max(h[m].keys()) if h[m] else 0}, neg={neg}")

        D = defaultdict(dict)
        for m in range(m_max + 1):
            D[0][m] = dict(h[m])
        for k in range(1, m_max + 1):
            for m in range(k, m_max + 1):
                D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

        print(f"\n  D_k^m positivity check:")
        all_nonneg = True
        for k in range(m_max + 1):
            for m in range(k, m_max + 1):
                Dkm = D[k].get(m, {})
                Dkm_sum = sum(Dkm.values()) if Dkm else 0
                expected = (base - 1)**k * base**(m - k)
                neg = poly_min_neg(Dkm)
                status = "OK" if neg is None else f"NEG at {neg}"
                if neg is not None: all_nonneg = False
                print(f"    D_{k}^{m}: sum={Dkm_sum} (exp={expected}), {status}")

        if all_nonneg:
            print(f"\n  *** ALL D_k^m >= 0 for d={d}, profile {profile} ***")
        else:
            print(f"\n  *** SOME D_k^m NEGATIVE for d={d}, profile {profile} ***")

        # Domination check
        print(f"\n  Domination D_k^m >= q^(k+1) * D_k^(m-1):")
        for k in range(min(4, m_max)):
            for m in range(k + 1, min(k + 4, m_max + 1)):
                Dkm = D[k].get(m, {})
                Dkm1_shifted = poly_shift(D[k].get(m - 1, {}), k + 1, max_q)
                diff = poly_sub(Dkm, Dkm1_shifted)
                neg = poly_min_neg(diff)
                s = sum(diff.values()) if diff else 0
                status = "OK" if neg is None else f"FAILS at {neg}"
                print(f"    D_{k}^{m} - q^{k+1}*D_{k}^{m-1}: sum={s}, {status}")

        # Leading structure
        print(f"\n  Leading terms of D_k^m:")
        for k in range(min(4, m_max + 1)):
            for m in range(k, min(k + 3, m_max + 1)):
                Dkm = D[k].get(m, {})
                if not Dkm: continue
                items = sorted(Dkm.items())
                print(f"    D_{k}^{m}: first 5 = {items[:5]}, last 3 = {items[-3:]}")

        # Ratio D_k^m / D_k^{m-1} at q=1
        print(f"\n  Ratio D_k^m(1)/D_k^(m-1)(1):")
        for k in range(min(4, m_max + 1)):
            for m in range(max(k,1), min(k + 4, m_max + 1)):
                s1 = sum(D[k].get(m, {}).values())
                s0 = sum(D[k].get(m-1, {}).values())
                if s0: print(f"    D_{k}^{m}/D_{k}^{m-1} = {s1}/{s0} = {s1/s0:.4f}")
