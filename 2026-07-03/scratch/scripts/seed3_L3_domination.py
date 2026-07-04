"""
Seed 3, Layer 3: Study the domination condition D_{k-1}^m >= q^k * D_{k-1}^{m-1}.
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

def poly_to_list(p, max_d=None):
    if not p: return []
    if max_d is None:
        max_d = max(p.keys())
    return [p.get(i, 0) for i in range(max_d + 1)]

# Main
for d, profile_list in [(4, [(2,1,1)]), (5, [(2,2,1)]), (7, [(3,2,2)])]:
    max_q = 120 if d <= 5 else 80
    n_max = 5 if d <= 5 else 4

    print(f"\n{'='*70}")
    print(f"d={d}")
    print(f"{'='*70}")

    g, profiles = compute_gn_system(d, n_max, max_q)

    for profile in profile_list:
        base = (d+1)*(d+2)//6
        print(f"\nProfile {profile}, base={base}, base-1={base-1}")

        h = {}
        for m in range(n_max + 1):
            h[m] = compute_hm(g, profile, m, max_q)

        D = defaultdict(dict)
        for m in range(n_max + 1):
            D[0][m] = dict(h[m])

        for k in range(1, n_max + 1):
            for m in range(k, n_max + 1):
                D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

        # D_k^m(1) table
        print(f"\n  === D_k^m(1) TABLE ===")
        header = "  k\\m " + "".join(f"{m:>10}" for m in range(n_max+1))
        print(header)
        for k in range(n_max+1):
            row = f"  {k}   "
            for m in range(n_max+1):
                if m >= k:
                    val = sum(D[k][m].values()) if D[k].get(m) else 0
                    row += f"{val:>10}"
                else:
                    row += "         -"
            print(row)

        # Domination condition
        print(f"\n  === DOMINATION: D_{{k-1}}^m >= q^k * D_{{k-1}}^{{m-1}} ===")
        for k in range(1, min(n_max+1, 5)):
            print(f"\n  k={k}:")
            for m in range(k, min(n_max+1, 6)):
                lhs = D[k-1].get(m, {})
                rhs_shifted = poly_shift(D[k-1].get(m-1, {}), k, max_q)
                delta = poly_sub(lhs, rhs_shifted)

                neg_coeffs = [(e, v) for e, v in sorted(delta.items()) if v < 0]
                min_coeff = min(delta.values()) if delta else 0

                lhs_at_1 = sum(lhs.values()) if lhs else 0
                rhs_at_1 = sum(D[k-1].get(m-1, {}).values()) if D[k-1].get(m-1) else 0

                print(f"    m={m}: D_{k-1}^{m}(1)={lhs_at_1}, D_{k-1}^{{m-1}}(1)={rhs_at_1}, "
                      f"delta(1)={lhs_at_1-rhs_at_1}, min_coeff={min_coeff}, neg={len(neg_coeffs)}")
                if neg_coeffs:
                    print(f"      NEGATIVE: {neg_coeffs[:10]}")

        # Print D_k^m polynomials
        print(f"\n  === D_k^m coefficients ===")
        for k in range(min(4, n_max+1)):
            for m in range(k, min(k+3, n_max+1)):
                Dkm = D[k].get(m, {})
                coeffs = poly_to_list(Dkm)[:40]
                Dkm_sum = sum(Dkm.values()) if Dkm else 0
                print(f"    D_{k}^{m}: sum={Dkm_sum}, deg={max(Dkm.keys()) if Dkm else 0}, first={coeffs}")

print("\nDone.")
