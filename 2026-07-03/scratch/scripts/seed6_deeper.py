#!/usr/bin/env python3
"""
Seed 6: Deeper computation of Q_{n,c}(q) for d=4,5,7,8 and mod-14 analysis.
Also explore connection to Nandi/Takigiku-Tsuchioka double sums.
"""
from fractions import Fraction

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_multiply(a, b, q_bound):
    result = {}
    for da, ca in a.items():
        if da > q_bound: continue
        for db, cb in b.items():
            d = da + db
            if d > q_bound: continue
            result[d] = result.get(d, 0) + ca * cb
    return {k: v for k, v in result.items() if v != 0}

def poly_inverse(p, q_bound):
    c0 = p.get(0, 0)
    assert c0 != 0
    inv_c0 = Fraction(1, c0)
    result = {0: inv_c0}
    for d in range(1, q_bound + 1):
        s = Fraction(0)
        for j in range(1, d + 1):
            pj = p.get(j, 0)
            rj = result.get(d - j, 0)
            if pj != 0 and rj != 0:
                s += Fraction(pj) * Fraction(rj)
        result[d] = -inv_c0 * s
    return result

def q_pochhammer_inf(a_exp, q_exp, q_bound):
    result = {0: 1}
    i = 0
    while True:
        power = a_exp + q_exp * i
        if power > q_bound: break
        new_result = {}
        for deg, coeff in result.items():
            if deg <= q_bound:
                new_result[deg] = new_result.get(deg, 0) + coeff
            if deg + power <= q_bound:
                new_result[deg + power] = new_result.get(deg + power, 0) - coeff
        result = {k: v for k, v in new_result.items() if v != 0}
        i += 1
    return result

def borodin_product(c, q_bound):
    k = len(c)
    ell = sum(c)
    t = k + ell
    c1 = list(c)
    def d_sum(i, j):
        return sum(c1[ii-1] for ii in range(i, j+1))
    denom = q_pochhammer_inf(t, t, q_bound)
    result = poly_inverse(denom, q_bound)
    for i in range(1, k+1):
        for j in range(i+1, k+1):
            for m in range(1, c1[i-1]+1):
                exp = m + d_sum(i+1, j) + j - i
                if 0 < exp <= q_bound:
                    factor = q_pochhammer_inf(exp, t, q_bound)
                    result = poly_multiply(result, poly_inverse(factor, q_bound), q_bound)
    for i in range(2, k+1):
        for j in range(2, i):
            for m in range(1, c1[i-1]+1):
                exp = t - (m + d_sum(j, i-1) + i - j)
                if 0 < exp <= q_bound:
                    factor = q_pochhammer_inf(exp, t, q_bound)
                    result = poly_multiply(result, poly_inverse(factor, q_bound), q_bound)
    return result

def compute_Fcn_layer(c, n, q_bound):
    """Compute F_{c,n}(q) using layer decomposition for max <= n."""
    c1, c2, c3 = c
    if n == 0:
        return {0: 1}
    
    # For general n, use recursive layer approach.
    # A cylindric partition with max <= n decomposes into n layers,
    # each a "binary cylindric partition" (max 1), with nesting constraints.
    # Layer m: R(m) = (R_1(m), R_2(m), R_3(m)) with interlacing.
    # Constraint: R_i(m) >= R_i(m+1).
    
    # For n=1: direct enumeration
    if n == 1:
        result = {}
        for L1 in range(q_bound + 1):
            for L2 in range(min(L1 + c2, q_bound - L1) + 1):
                L3_min = max(0, L1 - c1)
                L3_max = min(L2 + c3, q_bound - L1 - L2)
                for L3 in range(L3_min, L3_max + 1):
                    if L2 < L3 - c3: continue
                    size = L1 + L2 + L3
                    if size <= q_bound:
                        result[size] = result.get(size, 0) + 1
        return result
    
    # For n >= 2: nested enumeration (expensive but doable for small n)
    # Use dynamic programming. Process layers from top (n) to bottom (1).
    # State: (R_1, R_2, R_3) at current layer.
    # Transition: next layer's (R_1', R_2', R_3') with R_i' >= R_i and interlacing.
    
    # Start from layer n (topmost, smallest R values).
    # Build up layer by layer.
    
    # dp[layer][(R1,R2,R3)] = polynomial in q tracking cumulative size
    # This is too memory-intensive for large R values.
    # Let's cap R values.
    R_max = q_bound // n  # rough upper bound on any R_i at any layer
    
    # Initialize: layer n (topmost)
    # Valid (R1,R2,R3) with interlacing, R_i in [0, R_max]
    dp = {}
    for R1 in range(R_max + 1):
        for R2 in range(min(R1 + c2, R_max) + 1):
            R3_min = max(0, R1 - c1)
            R3_max = min(R2 + c3, R_max)
            for R3 in range(R3_min, R3_max + 1):
                if R2 < R3 - c3: continue
                size = R1 + R2 + R3
                if size <= q_bound:
                    key = (R1, R2, R3)
                    dp[key] = {size: dp.get(key, {}).get(size, 0) + 1}
                    dp[key] = {size: 1}
    
    # Process layers n-1 down to 1
    for layer in range(n-1, 0, -1):
        new_dp = {}
        for (R1_prev, R2_prev, R3_prev), poly_prev in dp.items():
            # Next layer: (R1, R2, R3) with R_i >= R_i_prev and interlacing
            for R1 in range(R1_prev, R_max + 1):
                for R2 in range(max(R2_prev, 0), min(R1 + c2, R_max) + 1):
                    R3_min = max(R3_prev, max(0, R1 - c1))
                    R3_max = min(R2 + c3, R_max)
                    for R3 in range(R3_min, R3_max + 1):
                        if R2 < R3 - c3: continue
                        add_size = R1 + R2 + R3
                        key = (R1, R2, R3)
                        # Shift poly_prev by add_size
                        shifted = {k + add_size: v for k, v in poly_prev.items() if k + add_size <= q_bound}
                        if key not in new_dp:
                            new_dp[key] = {}
                        new_dp[key] = poly_add(new_dp.get(key, {}), shifted)
        dp = new_dp
    
    # Sum over all final states
    result = {}
    for poly in dp.values():
        result = poly_add(result, poly)
    return result


def compute_Q(c, n_max, q_bound):
    """Compute Q_{n,c}(q) for n = 1, ..., n_max."""
    d = sum(c)
    ell = 1  # gcd(d, 3) = 1 since d not div by 3
    
    # Compute F_{c,m}(q) for m = 0, ..., n_max
    Fcm = {}
    for m in range(n_max + 1):
        print(f"  Computing F_{{c,{m}}}(q) ...")
        Fcm[m] = compute_Fcn_layer(c, m, q_bound)
    
    # f_m = F_{c,m} - F_{c,m-1}
    fm = {0: {0: 1}}
    for m in range(1, n_max + 1):
        fm[m] = poly_add(Fcm[m], {k: -v for k, v in Fcm[m-1].items()})
    
    # Compute (zq;q)_inf coefficients: a_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
    # As rational power series, we need a_j as polynomials (they are just monomials times 1/(q;q)_j).
    # Actually a_j is a power series: (-1)^j * q^{j(j+1)/2} * (1/(q;q)_j)
    # where 1/(q;q)_j = sum_{partitions with at most j parts} q^{|lambda|}
    
    # Compute a_j(q) as truncated power series
    def compute_aj(j, qb):
        if j == 0:
            return {0: Fraction(1)}
        sign = (-1)**j
        shift = j*(j+1)//2
        # 1/(q;q)_j
        qqj = {0: 1}
        for i in range(1, j+1):
            qqj = poly_multiply(qqj, {0: 1, i: -1}, qb)
        inv_qqj = poly_inverse(qqj, qb)
        # Multiply by (-1)^j and shift by q^{j(j+1)/2}
        result = {}
        for deg, coeff in inv_qqj.items():
            new_deg = deg + shift
            if new_deg <= qb:
                result[new_deg] = sign * coeff
        return result
    
    results = {}
    for n in range(1, n_max + 1):
        # [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n a_j * f_{n-j}
        zn = {}
        for j in range(n + 1):
            aj = compute_aj(j, q_bound)
            fn_j = fm[n - j]
            prod = poly_multiply(aj, fn_j, q_bound)
            zn = poly_add(zn, prod)
        
        # Q_n = (q;q)_n * zn
        # Compute (q;q)_n
        qqn = {0: 1}
        for i in range(1, n + 1):
            qqn = poly_multiply(qqn, {0: 1, i: -1}, q_bound)
        
        Qn = poly_multiply(qqn, zn, q_bound)
        
        # Convert to integers
        Qn_int = {}
        for deg, val in sorted(Qn.items()):
            if isinstance(val, Fraction):
                assert val.denominator == 1, f"Non-integer coefficient at q^{deg}: {val}"
                Qn_int[deg] = int(val)
            else:
                Qn_int[deg] = int(val)
        
        results[n] = Qn_int
    
    return results


def analyze_Q_mod14(Q_poly):
    """Analyze Q polynomial modulo 14 residues."""
    residue_counts = {}
    for deg, coeff in sorted(Q_poly.items()):
        r = deg % 14
        if r not in residue_counts:
            residue_counts[r] = []
        residue_counts[r].append((deg, coeff))
    return residue_counts


def main():
    q_bound = 30
    
    # d=4 case (more interesting)
    for c in [(2, 1, 1), (1, 2, 1), (1, 1, 2)]:
        d = sum(c)
        expected = (d+1)*(d+2)//6 - 1
        print(f"\n{'='*60}")
        print(f"Profile c = {c}, d = {d}, t = {3+d}")
        print(f"Q_{{n,c}}(1) should be {expected}^n")
        print(f"{'='*60}")
        
        Qs = compute_Q(c, 3, q_bound)
        
        for n, Qn in Qs.items():
            print(f"\nQ_{{{n},c}}(q):")
            all_nonneg = True
            for deg in range(q_bound + 1):
                val = Qn.get(deg, 0)
                if val != 0:
                    print(f"  q^{deg}: {val}")
                if val < 0:
                    all_nonneg = False
            
            Qn_sum = sum(Qn.values())
            print(f"  Q_{{{n}}}(1) = {Qn_sum} (expected {expected**n})")
            print(f"  All nonneg: {all_nonneg}")
            
            if n == 1:
                mod14 = analyze_Q_mod14(Qn)
                print(f"  Mod 14 analysis:")
                for r in sorted(mod14.keys()):
                    terms = mod14[r]
                    print(f"    residue {r}: {terms}")
    
    # d=5 case
    c = (2, 2, 1)
    d = sum(c)
    expected = (d+1)*(d+2)//6 - 1
    print(f"\n{'='*60}")
    print(f"Profile c = {c}, d = {d}, t = {3+d}")
    print(f"Q_{{n,c}}(1) should be {expected}^n")
    print(f"{'='*60}")
    
    Qs = compute_Q(c, 2, q_bound)
    for n, Qn in Qs.items():
        print(f"\nQ_{{{n},c}}(q):")
        all_nonneg = True
        for deg in range(q_bound + 1):
            val = Qn.get(deg, 0)
            if val != 0:
                print(f"  q^{deg}: {val}")
            if val < 0:
                all_nonneg = False
        Qn_sum = sum(Qn.values())
        print(f"  Q_{{{n}}}(1) = {Qn_sum} (expected {expected**n})")
        print(f"  All nonneg: {all_nonneg}")
    
    # Now try d=7 (mod 14 = 7, t = 10) — connects to Takigiku-Tsuchioka
    # c = (3, 2, 2) gives d=7
    c = (3, 2, 2)
    d = sum(c)
    expected = (d+1)*(d+2)//6 - 1
    print(f"\n{'='*60}")
    print(f"Profile c = {c}, d = {d}, t = {3+d}")
    print(f"Q_{{n,c}}(1) should be {expected}^n")
    print(f"{'='*60}")
    
    Qs = compute_Q(c, 1, min(q_bound, 20))
    for n, Qn in Qs.items():
        print(f"\nQ_{{{n},c}}(q):")
        all_nonneg = True
        for deg in range(q_bound + 1):
            val = Qn.get(deg, 0)
            if val != 0:
                print(f"  q^{deg}: {val}")
            if val < 0:
                all_nonneg = False
        Qn_sum = sum(Qn.values())
        print(f"  Q_{{{n}}}(1) = {Qn_sum} (expected {expected**n})")
        print(f"  All nonneg: {all_nonneg}")

if __name__ == "__main__":
    main()
