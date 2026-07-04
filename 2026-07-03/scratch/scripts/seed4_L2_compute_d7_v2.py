"""
Seed 4, Layer 2: Compute Q_{n,c}(q) for d=7 using iterative CW approach.

The CW recurrence F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|})
preserves d, so recursion on profiles cycles forever.

The correct approach: extract [y^n] coefficients iteratively.
F_c(y,q) = sum_n g_n^c(q) y^n where g_n^c = [y^n] F_c(y,q).

From the CW recurrence:
  g_n^c(q) = sum_{J} (-1)^{|J|-1} sum_{m=0}^n q^{m|J|} g_{n-m}^{c(J)}(q) * q^{(n-m)|J|}

Wait, let me be more careful.

F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|})

If F_{c(J)}(y,q) = sum_m g_m^{c(J)} y^m, then
F_{c(J)}(yq^s,q) = sum_m g_m^{c(J)} q^{ms} y^m
and dividing by (1-yq^s):
F_{c(J)}(yq^s,q)/(1-yq^s) = sum_n y^n sum_{m=0}^n q^{ms} q^{(n-m)s} g_m^{c(J)}
                            = sum_n y^n q^{ns} sum_{m=0}^n g_m^{c(J)} ... 

Hmm wait. Let me redo:
F_{c(J)}(yq^s,q) = sum_m g_m^{c(J)} (yq^s)^m = sum_m g_m^{c(J)} q^{ms} y^m

1/(1-yq^s) = sum_{k>=0} (yq^s)^k = sum_k q^{ks} y^k

Product: [y^n] of product = sum_{m=0}^n g_m^{c(J)} q^{ms} q^{(n-m)s}
         = q^{ns} sum_{m=0}^n g_m^{c(J)}

So g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} sum_{m=0}^n g_m^{c(J)}

This is a system: g_n^c depends on g_m^{c(J)} for ALL m <= n.

For n=0: g_0^c = sum_J (-1)^{|J|-1} g_0^{c(J)}
This is a linear system in the unknowns {g_0^c : c with sum=d}.
But g_0^c = F_c(0,q) = 1 for all c. Let's verify:
  sum_J (-1)^{|J|-1} * 1 = sum_{s=1}^{|I_c|} (-1)^{s-1} C(|I_c|,s) = 1 - (1-1)^{|I_c|} = 1
for |I_c| >= 1. Good, consistent.

For n=1: g_1^c = sum_J (-1)^{|J|-1} q^{|J|} (g_0^{c(J)} + g_1^{c(J)})
              = sum_J (-1)^{|J|-1} q^{|J|} (1 + g_1^{c(J)})

This is a LINEAR system in {g_1^c : c with sum=d}, with known inhomogeneous terms.

For general n: g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} [sum_{m=0}^{n-1} g_m^{c(J)} + g_n^{c(J)}]

So if we know g_0,...,g_{n-1} for all profiles, g_n is determined by a linear system.
"""

from collections import defaultdict
from itertools import combinations
from math import gcd
import sys

MAX_Q_DEG = 60

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

def poly_str(p, max_terms=15):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ... ({len(parts)} terms)"
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
    """Get CW transitions for profile c."""
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
    """
    Compute g_n^c(q) for all profiles c with sum=d and n=0,...,n_max.
    
    g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} [sum_{m=0}^{n-1} g_m^{c(J)} + g_n^{c(J)}]
    
    Rearranging:
    g_n^c - sum_J (-1)^{|J|-1} q^{n|J|} g_n^{c(J)} = sum_J (-1)^{|J|-1} q^{n|J|} sum_{m=0}^{n-1} g_m^{c(J)}
    
    This is a linear system in {g_n^c} with known RHS (from previous steps).
    """
    profiles = all_profiles(d, k)
    N = len(profiles)
    prof_idx = {c: i for i, c in enumerate(profiles)}
    
    # Precompute transitions
    trans = {c: get_transitions(c) for c in profiles}
    
    # g[n][c] = polynomial in q
    g = defaultdict(lambda: defaultdict(dict))
    
    # Base case: g_0^c = 1 for all c
    for c in profiles:
        g[0][c] = {0: 1}
    
    for n in range(1, n_max + 1):
        print(f"  Computing g_{n} for all {N} profiles...")
        
        # Build and solve the linear system g_n^c - sum_J ... g_n^{c(J)} = RHS
        # The system is: for each profile c,
        # g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} [sum_{m=0}^{n-1} g_m^{c(J)} + g_n^{c(J)}]
        #
        # Since the system involves polynomial coefficients (q^{n|J|}) multiplying
        # the unknowns g_n^{c(J)}, this is NOT a simple matrix system.
        # The "matrix" has polynomial entries, making Gaussian elimination very expensive.
        #
        # Alternative: ITERATE. Guess g_n^c = 0 and iterate the fixed point:
        # g_n^c <- sum_J (-1)^{|J|-1} q^{n|J|} [sum_{m=0}^{n-1} g_m^{c(J)} + g_n^{c(J)}]
        #
        # But this may not converge. Let's try it.
        
        # Compute the "known" part: RHS = sum_J (-1)^{|J|-1} q^{n|J|} sum_{m=0}^{n-1} g_m^{c(J)}
        rhs = {}
        for c in profiles:
            r = {}
            for sign, s, cJ in trans[c]:
                partial_sum = {}
                for m in range(n):
                    partial_sum = poly_add(partial_sum, g[m][cJ])
                # Multiply by sign * q^{n*s}
                term = poly_shift(poly_scale(partial_sum, sign), n * s, max_q)
                r = poly_add(r, term)
            rhs[c] = r
        
        # Now solve: g_n^c = rhs^c + sum_J (-1)^{|J|-1} q^{n|J|} g_n^{c(J)}
        # This is a system with polynomial-entry "matrix". 
        # Key insight: the q^{n|J|} factor means the homogeneous part starts at degree n.
        # So if we build g_n degree by degree, degree d of g_n^c depends only on 
        # degrees < d of g_n^{c(J)} (since q^{n|J|} shifts by at least n >= 1).
        
        # This means we can solve DEGREE BY DEGREE!
        curr_gn = {c: {} for c in profiles}
        
        for deg in range(max_q + 1):
            for c in profiles:
                # Coefficient of q^deg in g_n^c:
                # = [q^deg] rhs^c + sum_J (-1)^{|J|-1} [q^{deg - n*|J|}] g_n^{c(J)}
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

def compute_Q(g, profile, n_max, max_q=MAX_Q_DEG):
    """Compute Q_{n,c}(q) from g_n^c."""
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)
    
    Q_polys = {}
    for n in range(n_max + 1):
        # Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
        # [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q;q)_j * g_{n-j}^c(q)
        # where g_m^c = [y^m] F_c(y,q) as computed above.
        
        # Actually, g_m^c here is the coefficient of y^m in F_c(y,q),
        # which equals F_{c,m}(q) - F_{c,m-1}(q) = [count with max EXACTLY m].
        # No wait - the CW recurrence gives F_c(y,q) directly, so g_m = [y^m] F_c(y,q).
        # We need to check what [y^m] means in the context.
        
        # F_c(y,q) = sum_Lambda q^{|Lambda|} y^{max(Lambda)}
        # So [y^m] F_c = sum_{Lambda: max=m} q^{|Lambda|} = (F_{c,m} - F_{c,m-1})(q)
        # where F_{c,m} counts max <= m.
        
        # For the Q formula:
        # Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m g_m z^m)
        # = (q^ell;q^ell)_n * sum_{j+m=n} euler_j * g_m
        # where euler_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
        
        # Compute 1/(q;q)_j as power series
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
        
        # Multiply by (q^ell;q^ell)_n
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
        Q_polys[n] = {k: v for k, v in Q_n.items() if v != 0}
    
    return Q_polys

# Main computation
for d in [4, 5, 7]:
    print(f"\n{'='*70}")
    print(f"d = {d}")
    print(f"{'='*70}")
    
    n_max = 2 if d >= 7 else 3
    max_q = 60 if d <= 5 else 50
    
    g, profiles = compute_gn_system(d, n_max, max_q)
    
    # Pick representative profiles
    test_profiles = []
    for c in profiles:
        if all(ci > 0 for ci in c) and c == min(
            tuple(c[(s+i)%3] for i in range(3)) for s in range(3)
        ):
            test_profiles.append(c)
    
    if not test_profiles:
        # Fall back to profiles with at most one zero
        for c in profiles:
            if sum(1 for ci in c if ci > 0) >= 2 and c <= tuple(c[(1+i)%3] for i in range(3)):
                test_profiles.append(c)
                if len(test_profiles) >= 2: break
    
    expected_base = (d + 1) * (d + 2) // 6 - 1
    
    for profile in test_profiles[:3]:
        print(f"\n  Profile {profile}:")
        ell = gcd(d, 3)
        
        # Show g_n values
        for nn in range(n_max + 1):
            gn = g[nn].get(profile, {})
            s = sum(gn.values()) if gn else 0
            print(f"    g_{nn} sum = {s}, first terms: {poly_str(gn, 8)}")
        
        Q_polys = compute_Q(g, profile, n_max, max_q)
        
        for nn in range(n_max + 1):
            Q = Q_polys.get(nn, {})
            q1 = sum(Q.values())
            neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
            
            if Q:
                min_deg = min(Q.keys())
                max_deg = max(Q.keys())
                num_terms = len(Q)
            else:
                min_deg = max_deg = num_terms = 0
            
            print(f"    Q_{nn}: {num_terms} terms, deg [{min_deg}, {max_deg}], Q(1)={q1} (exp {expected_base**nn}), {'OK' if not neg else 'NEG: '+str(neg[:5])}")

