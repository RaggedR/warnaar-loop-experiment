"""
Seed 8, Layer 2: Investigate whether positivity propagates through the CW recurrence.

The CW system gives:
  B_n(c) = B_{n-1}(c) + sum_J sign(J) * q^{n|J|} * B_n(c(J))

where B_n(c) = F_{c,n}(q) = sum_{m=0}^n b_m(c).

The key observation: Q_{n,c} = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
                              = sum_{j=0}^n (-1)^j q^{j(j+1)/2} (q^{j+1};q)_{n-j} b_{n-j}(c)

We want to understand the "per-layer" contribution delta_n = B_n - B_{n-1} = b_n
and how Q_n relates to Q_{n-1} through the CW structure.

Specifically:
1. Is there a direct recursion Q_n = f(Q_{n-1}, ...) that is manifestly positive?
2. Can we define P_n(c) = sum_{m=0}^n q^{m(m+1)/2} * [n choose m]_q * B_m(c) * (-1)^m
   and show it has nonneg coefficients?

Let's compute the incremental contributions layer by layer and look for structure.
"""

from itertools import combinations
from math import gcd


MAX_Q = 80
MAX_N = 5


def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i+j > max_deg: continue
            result[i+j] = result.get(i+j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def poly_shift(p, s, max_deg=MAX_Q):
    return {k+s: v for k, v in p.items() if k+s <= max_deg}

def poly_scale(p, s):
    if s == 0: return {}
    return {k: v*s for k, v in p.items()}

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
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ... ({len(parts)} terms)"
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"

def enumerate_profiles(d, k):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in enumerate_profiles(d-i, k-1):
            yield (i,) + rest

def compute_cJ(c, J):
    k = len(c)
    J_set = set(J)
    c_J = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set:
            c_J[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_J[i] += 1
    return tuple(c_J)

def build_CW_system(c, k=3):
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    terms = []
    for size in range(1, len(I_c)+1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J): continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms

def compute_base_case_coeffs(k, max_n, max_q):
    result = {}
    prev_cum = {0: 1}
    result[0] = {0: 1}
    for n in range(1, max_n + 1):
        curr_cum = {}
        kn = k * n
        for p, c in prev_cum.items():
            j = 0
            while p + kn * j <= max_q:
                curr_cum[p + kn * j] = curr_cum.get(p + kn * j, 0) + c
                j += 1
        curr_cum = {p: c for p, c in curr_cum.items() if c != 0}
        result[n] = poly_sub(curr_cum, prev_cum)
        prev_cum = curr_cum
    return result

def solve_CW_system_full(target_profile, k, max_n, max_q):
    """Returns b_m(c) and B_m(c) for all profiles c and all m."""
    d = sum(target_profile)
    all_profiles = list(enumerate_profiles(d, k))
    zero_profile = tuple([0] * k)
    
    cw_system = {}
    for p in all_profiles:
        if p == zero_profile: continue
        cw_system[p] = build_CW_system(p, k)
    
    base_coeffs = compute_base_case_coeffs(k, max_n, max_q)
    B = {}
    B[zero_profile] = {}
    cum = {0: 1}
    for n in range(max_n + 1):
        if n == 0:
            B[zero_profile][0] = {0: 1}
        else:
            cum = poly_add(cum, base_coeffs.get(n, {}))
            B[zero_profile][n] = dict(cum)
    
    for p in all_profiles:
        if p == zero_profile: continue
        B[p] = {-1: {}}
    for p in all_profiles:
        B[p][0] = {0: 1}
    
    non_zero = [p for p in all_profiles if p != zero_profile]
    
    for n in range(1, max_n + 1):
        rhs = {}
        for p in non_zero:
            known = dict(B[p][n-1])
            for sign, s, target in cw_system[p]:
                if target == zero_profile:
                    contrib = poly_scale(B[zero_profile][n], sign)
                    contrib = poly_shift(contrib, n * s, max_q)
                    known = poly_add(known, contrib)
            rhs[p] = known
        
        for p in non_zero:
            B[p][n] = dict(rhs[p])
        
        max_iter = max_q // max(1, n) + 2
        for iteration in range(max_iter):
            changed = False
            for p in non_zero:
                new_val = dict(rhs[p])
                for sign, s, target in cw_system[p]:
                    if target != zero_profile:
                        contrib = poly_shift(B[target][n], n * s, max_q)
                        contrib = poly_scale(contrib, sign)
                        new_val = poly_add(new_val, contrib)
                if new_val != B[p][n]:
                    changed = True
                B[p][n] = new_val
            if not changed:
                break
    
    b = {}
    for p in all_profiles:
        b[p] = {}
        for m in range(max_n + 1):
            if m == 0:
                b[p][m] = B[p][0]
            else:
                b[p][m] = poly_sub(B[p][m], B[p][m-1])
    
    return b, B


def compute_Q_from_b(b_coeffs, profile, max_n, max_q):
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)
    
    def qpoch_fin(n):
        result = {0: 1}
        for i in range(1, n+1):
            exp = ell * i
            new = {}
            for p, c in result.items():
                if p <= max_q: new[p] = new.get(p, 0) + c
                if p + exp <= max_q: new[p + exp] = new.get(p + exp, 0) - c
            result = {k: v for k, v in new.items() if v != 0}
        return result
    
    def inv_qpoch(m):
        result = {0: 1}
        for i in range(1, m+1):
            new = {}
            for p, c in result.items():
                j = 0
                while p + i * j <= max_q:
                    new[p + i * j] = new.get(p + i * j, 0) + c
                    j += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result
    
    Q_polys = {}
    for n in range(max_n + 1):
        inner = {}
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            if shift > max_q: break
            inv_m = inv_qpoch(m)
            b = b_coeffs.get(n - m, {})
            term = poly_mul(inv_m, b, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)
        
        qpn = qpoch_fin(n)
        Q = poly_mul(qpn, inner, max_q)
        Q_polys[n] = {k: v for k, v in Q.items() if v != 0}
    
    return Q_polys


def main():
    profile = (2, 1, 1)
    d = sum(profile)
    k = 3
    max_n = MAX_N
    max_q = MAX_Q
    
    print(f"Profile c = {profile}, d = {d}")
    print(f"="*80)
    
    b, B = solve_CW_system_full(profile, k, max_n, max_q)
    Q = compute_Q_from_b(b[profile], profile, max_n, max_q)
    
    # Show the layer-by-layer structure
    print("\n--- Layer-by-layer analysis ---")
    for n in range(max_n + 1):
        bn = b[profile][n]
        Bn = B[profile][n]
        Qn = Q[n]
        print(f"\nn = {n}:")
        print(f"  b_{n}(c) = {poly_str(bn)}")
        print(f"  B_{n}(c) = {poly_str(Bn)}")
        print(f"  Q_{n}(q) = {poly_str(Qn)}")
        print(f"  Q_{n}(1) = {sum(Qn.values())}")
    
    # Now investigate: what is Q_n - Q_{n-1} * Q_1?
    # And more generally: the "Q-increment"
    print("\n\n--- Q_n structure analysis ---")
    Q1 = Q[1]
    for n in range(2, max_n + 1):
        Qn = Q[n]
        # Compute Q_{n-1} * Q_1
        Qn1_Q1 = poly_mul(Q[n-1], Q1, max_q)
        diff = poly_sub(Qn, Qn1_Q1)
        neg_diff = {k: v for k, v in diff.items() if v < 0}
        print(f"\nQ_{n} - Q_{{n-1}} * Q_1:")
        print(f"  = {poly_str(diff)}")
        print(f"  sum = {sum(diff.values())}")
        print(f"  neg coefficients: {len(neg_diff)} terms")
        if neg_diff:
            print(f"  neg examples: {sorted(neg_diff.items())[:5]}")
    
    # Check: is there a q-recursion Q_n = A_n * Q_{n-1} + B_n * Q_{n-2}?
    print("\n\n--- Searching for Q_n recursion ---")
    if max_n >= 3:
        # Q_2 = a(q)*Q_1 + b(q)*Q_0 ?
        # Q_2 - a*Q_1 - b = 0
        # We know Q_0 = 1, so b(q) = Q_2 - a(q)*Q_1
        # At q=1: 16 = 4*a + b, and Q_3 = a*Q_2 + b*Q_1 => 64 = 16a + 4b
        # => 64 = 16a + 4(16-4a) = 64. Always true! So the q=1 recursion is degenerate.
        
        # Try: Q_n = (Q_1 + alpha_n * q^{something}) * Q_{n-1} + ...
        # This is getting complicated. Let me instead look at ratios.
        pass
    
    # Key analysis: the CW recurrence for the INCREMENT delta_n = b_n
    # b_n(c) = sum_J sign(J) * q^{n|J|} * B_n(c(J))
    # This says: the new layer at height n involves ALL the profiles' cumulative GFs.
    
    # Let's see if we can write Q_n in terms of B values directly.
    # Q_n = sum_j (-1)^j q^{T_j} * (q^{j+1};q)_{n-j} * b_{n-j}
    # where b_{n-j} = sum_J sign(J) * q^{(n-j)*|J|} * B_{n-j}(c(J))
    
    # Substituting:
    # Q_n = sum_j (-1)^j q^{T_j} * (q^{j+1};q)_{n-j} * sum_J sign(J) * q^{(n-j)*|J|} * B_{n-j}(c(J))
    
    # This double sum is the key. Can we interchange the order?
    # Q_n = sum_J sign(J) * sum_j (-1)^j q^{T_j + (n-j)*|J|} * (q^{j+1};q)_{n-j} * B_{n-j}(c(J))
    
    # For each J, we have a "modified Q_n" applied to B_{n-j}(c(J)) with a shifted weight.
    # This is a more structured version of the "cross-N" problem.
    
    # Let me test a specific idea: define for each profile c,
    # R_n(c) = sum_j (-1)^j q^{T_j} * (q^{j+1};q)_{n-j} * B_{n-j}(c)
    # = (q;q)_n * [z^n]((zq;q)_inf * sum_m B_m(c) * z^m)
    # = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q) / (1-z))   (NO: B_m = sum_{i<=m} b_i, not b_m)
    
    # Actually: sum_m B_m(c) z^m = sum_m sum_{i<=m} b_i(c) z^m 
    #         = sum_i b_i(c) * z^i / (1-z)
    #         = F_c(z,q) / (1-z)
    
    # So R_n(c) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q) / (1-z))
    # And from b_n = sum_J sign(J) q^{n*s} B_n(c(J)):
    # Q_n = sum_J sign(J) * R_n^{(s)}(c(J))
    # where R_n^{(s)} is R with a q^{n*s} weight modification.
    
    # Hmm, this is getting circular. Let me try a different angle.
    
    # DIRECT ANALYSIS: for d=4, look at Q_n coefficient by coefficient
    # and identify WHERE each coefficient comes from in the CW structure.
    print("\n\n--- Coefficient tracking for d=4, c=(2,1,1) ---")
    print("Q polynomials (full):")
    for n in range(min(max_n+1, 5)):
        Qn = Q[n]
        coeffs = {}
        if Qn:
            for deg in range(max(Qn.keys())+1):
                coeffs[deg] = Qn.get(deg, 0)
        print(f"  Q_{n}: ", end="")
        if coeffs:
            maxd = max(k for k,v in coeffs.items() if v != 0)
            print([coeffs.get(i, 0) for i in range(maxd+1)])
        else:
            print([1])
    
    # Check: is Q_n related to q-multinomials?
    # For d=2: Q_n = q^{n^2} = q-analogue of 1^n.
    # For d=4: Q_n(1) = 4^n. Is Q_n the principal specialization of some 
    #          symmetric function in 4 variables?
    
    # The key test: does Q_n = sum over some indexing set S_n of q^{weight(s)}?
    # If so, |S_n| = 4^n. What are these objects?
    
    # For n=1: Q_1 = 2q + q^2 + q^3. These are 4 objects with weights 1,1,2,3.
    # For n=2: Q_2 has 16 objects (sum = 16).
    
    # HYPOTHESIS: the 4 objects for d=4, n=1 correspond to the 4 nontrivial 
    # C_3-orbits of level-4 dominant weights (minus the trivial orbit).
    # Wait: there are 5 C_3 orbits total, 0 trivial (since 4 != 3k), so
    # Q(1) = 5-1 = 4. The "minus 1" removes... what?
    
    # Actually: (d+1)(d+2)/6 = 5*6/6 = 5 orbits, and base = 5-1 = 4.
    # So we remove 1 orbit. Which one?
    
    # For d=4, the orbits are:
    # (4,0,0),(0,4,0),(0,0,4) -> orbit of size 3
    # (3,1,0),(1,0,3),(0,3,1) -> orbit of size 3
    # (2,2,0),(2,0,2),(0,2,2) -> orbit of size 3
    # (3,0,1),(0,1,3),(1,3,0) -> orbit of size 3
    # (2,1,1),(1,1,2),(1,2,1) -> orbit of size 3
    
    # All orbits have size 3 (since 4 is not divisible by 3, no fixed points).
    # We remove 1 orbit to get base=4. 
    
    # What does "removing" an orbit mean? The Q_n(1) formula gives 
    # ((d+1)(d+2)/6 - 1)^n, not ((d+1)(d+2)/6)^n. So we remove one 
    # "state" from the alphabet. 
    
    # h_m(1) = ((d+1)(d+2)/6)^m = 5^m. This counts words of length m 
    # in an alphabet of size 5 (all 5 orbits). 
    # Q_n(1) = 4^n removes the contribution of one orbit.
    # The alternating q-binomial transform removes it.
    
    # So the removed orbit is the "trivial" one -- but all orbits are size 3!
    # There's no trivial orbit for d=4.
    
    # INSIGHT: The removed orbit is not "trivial" in the group theory sense.
    # It's the orbit (0,0,...) = the empty partition contribution.
    # In the h_m framework, h_m counts something with an extra "ground state"
    # that the Q_n formula removes via the Euler convolution.
    
    # The q-version: h_m(q) contributes an extra "q^0" state (or more precisely,
    # its m-fold convolution contributes a constant term that gets removed).
    
    print("\n\n--- h_m to Q_n relationship ---")
    h_polys = {}
    for m in range(max_n + 1):
        qpoch = {0: 1}
        for i in range(1, m+1):
            new = {}
            for p, c in qpoch.items():
                if p <= max_q: new[p] = new.get(p, 0) + c
                if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
            qpoch = {k: v for k, v in new.items() if v != 0}
        bm = b[profile][m]
        h = poly_mul(qpoch, bm, max_q)
        h_polys[m] = h
    
    # h_0 = 1 (the "removed" state at q=1 is the constant 1)
    # h_m for m>=1 has nonneg coefficients (conjectured)
    # Q_n = sum_j (-1)^j q^{T_j} [n choose j]_q h_{n-j}
    #     = sum_j (-1)^j q^{T_j} [n choose j]_q h_{n-j}
    # Since h_0 = 1, the j=n term contributes (-1)^n q^{T_n} * 1 = (-1)^n q^{n(n+1)/2}
    
    # For d=4, n=2: T_2 = 3, so j=2 term = q^3. And Q_2 starts at q^3. Coincidence?
    # For d=4, n=3: T_3 = 6, and the first few terms of Q_3...
    
    print("h_m polynomials:")
    for m in range(max_n + 1):
        print(f"  h_{m} = {poly_str(h_polys[m])}")
    
    # Now let's look at the SELF-CONVOLUTION structure of h_m.
    # If h_m were exactly h_1^m (m-fold convolution product), then Q_n would 
    # be ((h_1) - 1)^n = (h_1 - 1)^n in some q-deformed sense.
    # But h_m != h_1^m in general.
    
    # Check: h_2 vs h_1^2
    h1_sq = poly_mul(h_polys[1], h_polys[1], max_q)
    diff_h = poly_sub(h_polys[2], h1_sq)
    print(f"\nh_2 - h_1^2 = {poly_str(diff_h)}")
    print(f"  -> h_2 {'=' if not diff_h else '!='} h_1^2")
    
    if max_n >= 3:
        h1_cube = poly_mul(poly_mul(h_polys[1], h_polys[1], max_q), h_polys[1], max_q)
        diff_h3 = poly_sub(h_polys[3], h1_cube)
        print(f"h_3 - h_1^3 = {poly_str(diff_h3)}")
    
    # Now try d=7
    print("\n\n" + "="*80)
    print("d=7, c=(3,2,2)")
    print("="*80)
    
    profile7 = (3, 2, 2)
    b7, B7 = solve_CW_system_full(profile7, k, max_n, max_q)
    Q7 = compute_Q_from_b(b7[profile7], profile7, max_n, max_q)
    
    print("\nQ polynomials (coefficient lists):")
    for n in range(min(max_n+1, 5)):
        Qn = Q7[n]
        if Qn:
            maxd = max(k for k,v in Qn.items() if v != 0)
            coeffs = [Qn.get(i, 0) for i in range(maxd+1)]
            print(f"  Q_{n}: {coeffs}")
        else:
            print(f"  Q_{n}: [1]")
    
    # h_m for d=7
    h7_polys = {}
    for m in range(max_n + 1):
        qpoch = {0: 1}
        for i in range(1, m+1):
            new = {}
            for p, c in qpoch.items():
                if p <= max_q: new[p] = new.get(p, 0) + c
                if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
            qpoch = {k: v for k, v in new.items() if v != 0}
        bm = b7[profile7][m]
        h = poly_mul(qpoch, bm, max_q)
        h7_polys[m] = h
    
    print("\nh_m for d=7:")
    for m in range(max_n + 1):
        h = h7_polys[m]
        neg = {k: v for k, v in h.items() if v < 0}
        print(f"  h_{m}: sum={sum(h.values())}, nonneg={len(neg)==0}, " + 
              f"coeffs={poly_str(h, 15)}")
    
    # Check h_2 vs h_1^2 for d=7
    h1_sq_7 = poly_mul(h7_polys[1], h7_polys[1], max_q)
    diff_h7 = poly_sub(h7_polys[2], h1_sq_7)
    print(f"\nh_2 - h_1^2 (d=7) = {poly_str(diff_h7)}")
    neg_diff7 = {k: v for k, v in diff_h7.items() if v < 0}
    print(f"  nonneg: {len(neg_diff7)==0}")
    
    # CRITICAL TEST: Is h_2 - h_1^2 nonneg? 
    # If so, the "excess" h_2 has over the convolution square is nonneg,
    # which means the h_m sequence is SUPER-MULTIPLICATIVE coefficientwise.
    
    # Also check: is h_m / h_{m-1} (as formal division) well-defined and nonneg?
    # This would mean each new layer multiplies by a nonneg polynomial.


if __name__ == "__main__":
    main()
