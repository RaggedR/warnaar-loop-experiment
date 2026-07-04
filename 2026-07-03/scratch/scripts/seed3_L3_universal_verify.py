"""
Verify ISP propagation for d=5 and d=7.
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
                term = poly_shift({k2: v*sign for k2,v in partial_sum.items()}, n * s, max_q)
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

for d, prof_list in [(5, [(2,2,1)]), (7, [(3,2,2), (4,2,1)])]:
    max_q = 120 if d <= 5 else 80
    n_max = 7 if d <= 5 else 5
    
    g, profiles = compute_gn_system(d, n_max, max_q)
    
    for profile in prof_list:
        print(f"\nd={d}, profile={profile}")
        h = {}
        for m in range(n_max + 1):
            h[m] = compute_hm(g, profile, m, max_q)
        
        D = defaultdict(dict)
        for m in range(n_max + 1):
            D[0][m] = dict(h[m])
        for k in range(1, n_max + 1):
            for m in range(k, n_max + 1):
                D[k][m] = poly_sub(D[k-1][m], poly_shift(D[k-1][m-1], k, max_q))
        
        all_ok = True
        for k in range(min(6, n_max)):
            for m in range(k+1, min(n_max+1, k+7)):
                Dk_m = D[k].get(m, {})
                Dk_m1 = D[k].get(m-1, {})
                if not Dk_m1 or not Dk_m:
                    continue
                min_m1 = min(Dk_m1.keys())
                shift = k + 1
                
                match_count = 0
                for j in range(50):
                    w = min_m1 + j
                    if Dk_m1.get(w, 0) == 0:
                        break
                    if Dk_m.get(w + shift, 0) == Dk_m1.get(w, 0):
                        match_count += 1
                    else:
                        break
                
                expected = m - (k + 2 + 1) // 2
                if match_count != expected:
                    print(f"  FAIL: k={k}, m={m}: ISP={match_count}, expected={expected}")
                    all_ok = False
        
        if all_ok:
            print(f"  ALL ISP checks passed! (k <= {min(5, n_max-1)}, m <= {min(n_max, 12)})")
        
        # Also verify min_deg formula
        mindeg_ok = True
        for k in range(min(6, n_max)):
            for m in range(k, min(n_max+1, k+7)):
                Dk_m = D[k].get(m, {})
                if not Dk_m: continue
                actual = min(Dk_m.keys())
                expected = (k+1)*m - (k+2)**2//4 + 1
                if actual != expected:
                    print(f"  FAIL min_deg: k={k}, m={m}: actual={actual}, expected={expected}")
                    mindeg_ok = False
        
        if mindeg_ok:
            print(f"  ALL min_deg checks passed!")

print("\nDone.")
