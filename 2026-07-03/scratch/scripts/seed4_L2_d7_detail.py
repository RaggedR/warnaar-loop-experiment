"""
Seed 4, Layer 2: Detailed Q_{n,c}(q) for d=7, printing full polynomials.
Also compute h_m = (q;q)_m * g_m and check h_m non-negativity.
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 80

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
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

def poly_str(p):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"

def all_profiles(d, k=3):
    if k == 1: return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c)
    J_set = set(J)
    c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set: c_new[i] -= 1
        elif i not in J_set and i_prev in J_set: c_new[i] += 1
    return tuple(c_new)

def get_transitions(c):
    k = len(c)
    I_c = [i for i in range(k) if c[i] > 0]
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
    for c in profiles:
        g[0][c] = {0: 1}
    
    for n in range(1, n_max + 1):
        rhs = {}
        for c in profiles:
            r = {}
            for sign, s, cJ in trans[c]:
                partial_sum = {}
                for m in range(n):
                    partial_sum = poly_add(partial_sum, g[m][cJ])
                term = poly_shift(poly_scale(partial_sum, sign), n * s, max_q)
                r = poly_add(r, term)
            rhs[c] = r
        
        curr_gn = {c: {} for c in profiles}
        for deg in range(max_q + 1):
            for c in profiles:
                val = rhs[c].get(deg, 0)
                for sign, s, cJ in trans[c]:
                    src_deg = deg - n * s
                    if src_deg >= 0:
                        val += sign * curr_gn[cJ].get(src_deg, 0)
                if val != 0:
                    curr_gn[c][deg] = val
        
        for c in profiles:
            g[n][c] = curr_gn[c]
    
    return g, profiles

# Compute for d=7
d = 7
n_max = 2
max_q = 80

print(f"Computing g_n for d={d}...")
g, profiles = compute_gn_system(d, n_max, max_q)

# Focus on profiles (3,2,2), (4,2,1), (1,3,3)
test_profiles = [(3, 2, 2), (4, 2, 1), (1, 3, 3), (2, 2, 3)]
ell = gcd(d, 3)
expected_base = (d + 1) * (d + 2) // 6 - 1

for profile in test_profiles:
    print(f"\n{'='*70}")
    print(f"Profile {profile}, d={d}, ell={ell}, base={expected_base}")
    print(f"{'='*70}")
    
    # Print g_n
    for nn in range(n_max + 1):
        gn = g[nn].get(profile, {})
        if gn:
            print(f"\n  g_{nn}: {poly_str(gn)}")
            print(f"    sum = {sum(gn.values())}")
    
    # Compute h_m = (q;q)_m * g_m and check positivity
    print(f"\n  h_m = (q;q)_m * g_m:")
    for m in range(n_max + 1):
        gm = g[m].get(profile, {})
        # (q;q)_m = prod_{i=1}^m (1-q^i)
        qpoch = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in qpoch.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + i <= max_q:
                    new[p + i] = new.get(p + i, 0) - c
            qpoch = {k: v for k, v in new.items() if v != 0}
        
        hm = poly_mul(qpoch, gm, max_q)
        neg_h = [(k, v) for k, v in sorted(hm.items()) if v < 0]
        print(f"    h_{m}: {poly_str(hm)}")
        print(f"      sum = {sum(hm.values())}, neg = {neg_h[:5] if neg_h else 'NONE'}")
    
    # Compute Q_n
    print(f"\n  Q_n:")
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
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + exp <= max_q:
                    new[p + exp] = new.get(p + exp, 0) - c
            qpn = {k: v for k, v in new.items() if v != 0}
        
        Q_n = poly_mul(qpn, inner, max_q)
        Q_n = {k: v for k, v in Q_n.items() if v != 0}
        neg = [(k, v) for k, v in sorted(Q_n.items()) if v < 0]
        q1 = sum(Q_n.values())
        
        print(f"    Q_{n} = {poly_str(Q_n)}")
        print(f"      Q(1)={q1} (exp {expected_base**n}), {'ALL NONNEG' if not neg else 'NEG: '+str(neg[:5])}")

