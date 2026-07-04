"""
Seed 2, Layer 3: Compute D_k^m for d=4 and d=7, all k,m up to 5.
D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}, Q_n = D_n^n.
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


def run_Dkm_analysis(d, profile, m_max, max_q):
    base = (d + 1) * (d + 2) // 6
    print(f"\n{'='*70}")
    print(f"d={d}, profile={profile}, base={base}, m_max={m_max}")
    print(f"{'='*70}")

    g, profiles = compute_gn_system(d, m_max, max_q)

    h = {}
    for m in range(m_max + 1):
        h[m] = compute_hm(g, profile, m, max_q)
        hval = poly_eval1(h[m])
        expected = base ** m
        deg = max(h[m].keys()) if h[m] else 0
        status = "EXACT" if hval == expected else f"TRUNCATED (got {hval})"
        print(f"  h_{m}: eval1={hval}, expected={expected}, deg={deg}, {status}")

    D = defaultdict(dict)
    for m in range(m_max + 1):
        D[0][m] = dict(h[m])

    for k in range(1, m_max + 1):
        for m in range(k, m_max + 1):
            D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

    print(f"\n  D_k^m table (eval1, expected=(base-1)^k*base^(m-k), nonneg?, deg):")
    all_nonneg = True
    for k in range(m_max + 1):
        for m in range(k, m_max + 1):
            Dkm = D[k].get(m, {})
            val1 = poly_eval1(Dkm)
            expected_val = (base - 1)**k * base**(m - k)
            neg = [(e, v) for e, v in sorted(Dkm.items()) if v < 0]
            deg = max(Dkm.keys()) if Dkm else 0
            coeffs = poly_to_list(Dkm)
            nonneg_str = "NONNEG" if not neg else f"NEG@{[e for e,v in neg[:3]]}"
            eval_str = "ok" if val1 == expected_val else f"TRUNC({val1}/{expected_val})"
            
            if len(coeffs) <= 40:
                print(f"    D_{k}^{m}: {coeffs}")
                print(f"         eval1={val1} {eval_str}, deg={deg}, {nonneg_str}")
            else:
                print(f"    D_{k}^{m}: deg={deg}, eval1={val1} {eval_str}, {nonneg_str}")
            
            if neg:
                all_nonneg = False

    if all_nonneg:
        print(f"\n  *** ALL D_k^m >= 0 ***")
    else:
        print(f"\n  *** SOME D_k^m NEGATIVE ***")

    # Verify Q_n = D_n^n
    print(f"\n  Verifying Q_n = D_n^n:")
    for n in range(min(m_max + 1, 4)):
        Q_n = compute_Q_direct(g, profile, n, max_q)
        D_nn = D[n].get(n, {})
        diff = poly_sub(Q_n, D_nn)
        match = (not diff or all(v == 0 for v in diff.values()))
        print(f"    n={n}: Q(1)={poly_eval1(Q_n)}, D_n^n(1)={poly_eval1(D_nn)}, match={match}")

    return D, g


# d=4
print("PART 1: d=4")
D4, g4 = run_Dkm_analysis(4, (2,1,1), 5, 160)

# d=7
print("\nPART 2: d=7, profile (3,2,2)")
D7, g7 = run_Dkm_analysis(7, (3,2,2), 5, 200)

print("\nPART 2b: d=7, profile (4,2,1)")
D7b, g7b = run_Dkm_analysis(7, (4,2,1), 5, 200)
