"""
Seed 4, Layer 2: Compute Q_{n,c}(q) for d=7 profiles using CW recurrence.
Adapts seed8_corteel_welsh.py for d=7 with higher precision.
"""
from collections import defaultdict
from math import gcd
from itertools import combinations

MAX_Q_DEG = 80
MAX_Y_DEG = 3

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
    return {k + s: v for k, v in p.items() if k + s <= max_deg}

def poly_str(p, max_terms=20):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    s = " + ".join(parts).replace("+ -", "- ")
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ... ({len(parts)} terms)"
    return s if parts else "0"

def biv_add(f, g, max_y=MAX_Y_DEG):
    result = {}
    for n in set(list(f.keys()) + list(g.keys())):
        if n > max_y: continue
        s = poly_add(f.get(n, {}), g.get(n, {}))
        if s: result[n] = s
    return result

def biv_scale(f, s):
    return {n: poly_scale(p, s) for n, p in f.items() if p}

def biv_yq_shift(f, q_shift, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG):
    result = {}
    for n, pn in f.items():
        if n > max_y: continue
        shifted = poly_shift(pn, n * q_shift, max_q)
        if shifted: result[n] = shifted
    return result

def biv_mul_inv_1_minus_yqa(f, a, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG):
    result = {}
    for n in range(max_y + 1):
        s = {}
        for m in range(n + 1):
            shift = m * a
            if shift > max_q: break
            p_nm = f.get(n - m, {})
            if p_nm:
                s = poly_add(s, poly_shift(p_nm, shift, max_q))
        if s: result[n] = s
    return result

def compute_Fc_bivariate(c_tuple, max_y=MAX_Y_DEG, max_q=MAX_Q_DEG, memo=None):
    if memo is None: memo = {}
    c_tuple = tuple(c_tuple)
    if c_tuple in memo: return memo[c_tuple]
    
    k = len(c_tuple)
    d = sum(c_tuple)
    
    if d == 0:
        result = {}
        prev_cum = {0: 1}
        result[0] = {0: 1}
        for n in range(1, max_y + 1):
            curr_cum = {}
            for p, c in prev_cum.items():
                j = 0
                while p + k * n * j <= max_q:
                    curr_cum[p + k * n * j] = curr_cum.get(p + k * n * j, 0) + c
                    j += 1
            curr_cum = {p: c for p, c in curr_cum.items() if c != 0}
            coeff_n = poly_sub(curr_cum, prev_cum)
            if coeff_n: result[n] = coeff_n
            prev_cum = curr_cum
        memo[c_tuple] = result
        return result
    
    I_c = [i for i in range(k) if c_tuple[i] > 0]
    if not I_c:
        raise ValueError(f"I_c empty but d={d}")
    
    result = None
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            J_set = set(J)
            sign = (-1) ** (size - 1)
            c_J = list(c_tuple)
            for i in range(k):
                i_prev = (i - 1) % k
                if i in J_set and i_prev not in J_set: c_J[i] -= 1
                elif i not in J_set and i_prev in J_set: c_J[i] += 1
            c_J = tuple(c_J)
            if any(x < 0 for x in c_J): continue
            
            F_cJ = compute_Fc_bivariate(c_J, max_y, max_q, memo)
            F_shifted = biv_yq_shift(F_cJ, size, max_y, max_q)
            F_div = biv_mul_inv_1_minus_yqa(F_shifted, size, max_y, max_q)
            F_term = biv_scale(F_div, sign)
            
            if result is None: result = F_term
            else: result = biv_add(result, F_term, max_y)
    
    if result is None: result = {}
    memo[c_tuple] = result
    return result

def compute_Q_from_Fc(Fc_biv, profile, n_max, max_q=MAX_Q_DEG):
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)
    
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
    
    def qpoch_fin(n):
        result = {0: 1}
        for i in range(1, n + 1):
            exp = ell * i
            new = {}
            for p, c in result.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + exp <= max_q:
                    new[p + exp] = new.get(p + exp, 0) - c
            result = {k: v for k, v in new.items() if v != 0}
        return result
    
    Q_polys = {}
    for n in range(n_max + 1):
        inner = {}
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            if shift > max_q: break
            inv_m = inv_qpoch(m)
            b_nm = Fc_biv.get(n - m, {})
            term = poly_mul(inv_m, b_nm, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)
        
        qpn = qpoch_fin(n)
        Q_n = poly_mul(qpn, inner, max_q)
        Q_polys[n] = {k: v for k, v in Q_n.items() if v != 0}
    
    return Q_polys

# Compute for d=7 profiles
profiles_d7 = [
    (3, 2, 2),  # canonical representative
    (4, 2, 1),  # second canonical class with all c_i > 0
    (1, 3, 3),  # third
]

for profile in profiles_d7:
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)
    expected_base = (d + 1) * (d + 2) // 6 - 1
    print(f"\n{'='*70}")
    print(f"Profile c = {profile}, d = {d}, ell = {ell}")
    print(f"Expected Q_n(1) = {expected_base}^n")
    print(f"{'='*70}")
    
    max_y = 3
    max_q = 80
    
    memo = {}
    print("Computing F_c(y,q)...")
    Fc = compute_Fc_bivariate(profile, max_y, max_q, memo)
    print(f"  Memo size: {len(memo)} profiles cached")
    
    Q_polys = compute_Q_from_Fc(Fc, profile, max_y, max_q)
    
    for n in range(max_y + 1):
        Q = Q_polys.get(n, {})
        q1 = sum(Q.values())
        neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
        all_pos = len(neg) == 0
        
        if Q:
            min_deg = min(Q.keys())
            max_deg = max(Q.keys())
            num_terms = len(Q)
        else:
            min_deg = max_deg = num_terms = 0
        
        print(f"\n  Q_{n}(q): {num_terms} terms, deg [{min_deg}, {max_deg}]")
        print(f"    Q(1) = {q1}, expected = {expected_base**n}, match = {q1 == expected_base**n}")
        if all_pos:
            print(f"    ALL NONNEGATIVE")
        else:
            print(f"    NEGATIVE coefficients: {neg[:10]}")
        
        # Print first and last few terms
        if Q:
            sorted_terms = sorted(Q.items())
            first5 = sorted_terms[:5]
            last5 = sorted_terms[-5:]
            print(f"    First: {first5}")
            print(f"    Last:  {last5}")

