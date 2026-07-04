"""
Seed 2, Layer 3: Analyze the structure of D_k^m more deeply.

Key questions:
1. What is the degree structure? deg(D_k^m) as function of k, m?
2. What is the "mass" removed at each step? D_{k-1}^m - D_k^m = q^k * D_{k-1}^{m-1}
3. Is there a pattern in the minimum degree of D_k^m?
4. Does the q-difference D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1} have a 
   bead/partition interpretation via Tingley?
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


def analyze_Dkm(d, profile, m_max, max_q):
    base = (d + 1) * (d + 2) // 6
    print(f"\n{'='*70}")
    print(f"d={d}, profile={profile}, base={base}, m_max={m_max}")
    print(f"{'='*70}")

    g, profiles = compute_gn_system(d, m_max, max_q)

    h = {}
    for m in range(m_max + 1):
        h[m] = compute_hm(g, profile, m, max_q)

    D = defaultdict(dict)
    for m in range(m_max + 1):
        D[0][m] = dict(h[m])
    for k in range(1, m_max + 1):
        for m in range(k, m_max + 1):
            D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))

    # Analyze degree structure
    print(f"\n  Degree table (min_deg, max_deg):")
    print(f"  {'k\\m':>6}", end="")
    for m in range(m_max + 1):
        print(f"  {'m='+str(m):>14}", end="")
    print()
    
    for k in range(m_max + 1):
        print(f"  k={k:>2}  ", end="")
        for m in range(m_max + 1):
            if m < k:
                print(f"  {'---':>14}", end="")
                continue
            Dkm = D[k].get(m, {})
            if not Dkm:
                print(f"  {'0':>14}", end="")
                continue
            mn = min(Dkm.keys())
            mx = max(Dkm.keys())
            print(f"  ({mn},{mx}){' ':>6}", end="")
        print()

    # Analyze minimum degree pattern
    print(f"\n  Minimum degree of D_k^m:")
    for k in range(m_max + 1):
        for m in range(k, m_max + 1):
            Dkm = D[k].get(m, {})
            if Dkm:
                mn = min(Dkm.keys())
                print(f"    min_deg(D_{k}^{m}) = {mn}")

    # Analyze the "removed mass" pattern
    print(f"\n  Removed mass: q^k * D_{{k-1}}^{{m-1}} for each step k->k:")
    for k in range(1, min(m_max + 1, 4)):
        for m in range(k, min(m_max + 1, 4)):
            removed = poly_shift(D[k-1][m-1], k, max_q)
            rem_coeffs = poly_to_list(removed)
            if len(rem_coeffs) <= 30:
                print(f"    q^{k} * D_{k-1}^{m-1}: {rem_coeffs}, eval1={poly_eval1(removed)}")

    # Analyze D_k^m / (base-1)^k pattern
    # At q=1: D_k^m(1) = (base-1)^k * base^{m-k}
    # So the "normalized" polynomial D_k^m / (base-1)^k should have eval1 = base^{m-k}
    # Question: is there a structural pattern where D_k^m factors?

    # Check if D_k^m has a factor of the form q^{k(k+1)/2} (triangular number)
    print(f"\n  Leading coefficient of D_k^m at min degree:")
    for k in range(m_max + 1):
        for m in range(k, min(m_max + 1, 5)):
            Dkm = D[k].get(m, {})
            if Dkm:
                mn = min(Dkm.keys())
                lc = Dkm[mn]
                tri = k * (k + 1) // 2  # triangular number
                print(f"    D_{k}^{m}: min_deg={mn}, coeff={lc}, k(k+1)/2={tri}, min_deg-tri={mn-tri}")

    # Check the domination: D_{k-1}^m - q^k D_{k-1}^{m-1} >= 0
    # This means: for each degree d, D_{k-1}^m[d] >= D_{k-1}^{m-1}[d-k]
    print(f"\n  Domination check (D_{{k-1}}^m[d] >= D_{{k-1}}^{{m-1}}[d-k]):")
    for k in range(1, min(m_max + 1, 5)):
        for m in range(k, min(m_max + 1, 5)):
            Dk1m = D[k-1].get(m, {})
            Dk1m1 = D[k-1].get(m-1, {})
            violations = []
            max_d = max(max(Dk1m.keys(), default=0), max(Dk1m1.keys(), default=0) + k)
            for d in range(max_d + 1):
                lhs = Dk1m.get(d, 0)
                rhs = Dk1m1.get(d - k, 0)
                if lhs < rhs:
                    violations.append((d, lhs, rhs))
            if violations:
                print(f"    k={k}, m={m}: VIOLATED at {violations[:5]}")
            else:
                # Show some ratios
                ratios = []
                for d in range(max_d + 1):
                    lhs = Dk1m.get(d, 0)
                    rhs = Dk1m1.get(d - k, 0)
                    if rhs > 0:
                        ratios.append((d, lhs, rhs, lhs/rhs))
                if ratios:
                    min_ratio = min(r[3] for r in ratios)
                    avg_ratio = sum(r[3] for r in ratios) / len(ratios)
                    print(f"    k={k}, m={m}: OK, min_ratio={min_ratio:.3f}, avg_ratio={avg_ratio:.3f}")

    return D

# d=4
D4 = analyze_Dkm(4, (2,1,1), 5, 160)

# d=7
D7 = analyze_Dkm(7, (3,2,2), 5, 200)
