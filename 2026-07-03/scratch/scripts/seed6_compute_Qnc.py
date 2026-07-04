#!/usr/bin/env python3
"""
Seed 6, Layer 1: Compute Q_{n,c}(q) for small cases.
Profile c=(c_1,...,c_k) with k=3, d=c_1+c_2+c_3 not div by 3.
Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
where F_c(z,q) = sum_{Lambda} q^|Lambda| z^{max(Lambda)}.
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
    """Compute 1/p(q) as power series truncated to degree q_bound. p(0) must be nonzero."""
    c0 = p.get(0, 0)
    assert c0 != 0
    inv_c0 = Fraction(1, c0) if isinstance(c0, int) else Fraction(c0).limit_denominator()**(-1)
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
    """Compute (q^a; q^b)_inf truncated to degree q_bound."""
    result = {0: 1}
    i = 0
    while True:
        power = a_exp + q_exp * i
        if power > q_bound:
            break
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
    """Compute F_c(q) using Borodin's product formula."""
    k = len(c)
    ell = sum(c)
    t = k + ell
    c1 = list(c)  # 0-indexed internally, but formula is 1-indexed

    def d_sum(i, j):
        # d_{i,j} = c_i + ... + c_j, 1-indexed
        return sum(c1[ii-1] for ii in range(i, j+1))

    # Start with 1/(q^t; q^t)_inf
    denom = q_pochhammer_inf(t, t, q_bound)
    result = poly_inverse(denom, q_bound)

    # First product
    for i in range(1, k+1):
        for j in range(i+1, k+1):
            for m in range(1, c1[i-1]+1):
                exp = m + d_sum(i+1, j) + j - i
                if exp > 0 and exp <= q_bound:
                    factor = q_pochhammer_inf(exp, t, q_bound)
                    result = poly_multiply(result, poly_inverse(factor, q_bound), q_bound)

    # Second product
    for i in range(2, k+1):
        for j in range(2, i):
            for m in range(1, c1[i-1]+1):
                exp = t - (m + d_sum(j, i-1) + i - j)
                if exp > 0 and exp <= q_bound:
                    factor = q_pochhammer_inf(exp, t, q_bound)
                    result = poly_multiply(result, poly_inverse(factor, q_bound), q_bound)

    return result

def enumerate_max1_cylindric(c, q_bound):
    """
    For profile c=(c1,c2,c3) with k=3, enumerate cylindric partitions
    with max entry exactly m, for all m, up to total size q_bound.
    
    Each partition lambda^(i) with parts in {0,...,max_val} is determined
    by a weakly decreasing sequence.
    
    For max_val=1: each lambda^(i) = (1^{L_i}) for some L_i >= 0.
    Interlacing conditions (1-indexed, k=3):
      lambda^(1)_j >= lambda^(2)_{j+c_2}  =>  L_2 <= L_1 + c_2 ... no:
      means: if j+c_2 <= L_2 (so lam^(2) has a 1 there), then j <= L_1.
      So L_2 - c_2 <= L_1, i.e., L_2 <= L_1 + c_2. Wait:
      j+c_2 <= L_2 => j <= L_2 - c_2. We need j <= L_1 for all such j.
      So L_2 - c_2 <= L_1. I.e., L_1 >= L_2 - c_2.
      
    Similarly:
      lambda^(2)_j >= lambda^(3)_{j+c_3}: L_2 >= L_3 - c_3 ... no:
      j+c_3 <= L_3 => j <= L_3 - c_3. Need j <= L_2. So L_3 - c_3 <= L_2.
      I.e., L_2 >= L_3 - c_3.
      
      lambda^(3)_j >= lambda^(1)_{j+c_1}: L_3 >= L_1 - c_1.
    
    Summary: L_1 >= L_2 - c_2, L_2 >= L_3 - c_3, L_3 >= L_1 - c_1.
    Equivalently: L_2 <= L_1 + c_2, L_3 <= L_2 + c_3, L_1 <= L_3 + c_1.
    """
    c1, c2, c3 = c
    
    # For each max value m, compute f_m(q) = sum over cylindric partitions with max exactly m.
    # For max = 0: only the zero partition, f_0 = 1.
    
    # For max = 1: each lambda^(i) = (1^{L_i}), size = L_1 + L_2 + L_3.
    # Conditions: L_2 <= L_1 + c_2, L_3 <= L_2 + c_3, L_1 <= L_3 + c_1.
    # At least one L_i >= 1 (since max = 1).
    
    f1_coeffs = {}
    for L1 in range(q_bound + 1):
        L2_max = min(L1 + c2, q_bound - L1)
        for L2 in range(max(0, L1 - c1 - c3 if False else 0), L2_max + 1):
            # L_3 conditions: L_3 >= L_1 - c_1, L_3 <= L_2 + c_3
            L3_min = max(0, L1 - c1)
            L3_max = min(L2 + c3, q_bound - L1 - L2)
            for L3 in range(L3_min, L3_max + 1):
                # Check L_2 >= L_3 - c_3
                if L2 < L3 - c3:
                    continue
                if L1 + L2 + L3 == 0:
                    continue  # max = 0, not max = 1
                size = L1 + L2 + L3
                if size <= q_bound:
                    f1_coeffs[size] = f1_coeffs.get(size, 0) + 1
    
    return f1_coeffs


def compute_Fcn_for_binary_partitions(c, n, q_bound):
    """
    Compute F_{c,n}(q) for small n by enumerating cylindric partitions
    with max entry <= n.
    
    For max entry <= n, each lambda^(i) is a partition with parts in {0,...,n}.
    For n=0: only empty, F_{c,0} = 1.
    For n=1: parts in {0,1}, each lambda^(i) = (1^{L_i}).
    For n=2: parts in {0,1,2}, need more complex enumeration.
    """
    if n == 0:
        return {0: 1}
    
    c1, c2, c3 = c
    
    if n == 1:
        # Each lambda^(i) = (1^{L_i})
        # Conditions: L_2 <= L_1 + c_2, L_3 <= L_2 + c_3, L_1 <= L_3 + c_1
        result = {}
        for L1 in range(q_bound + 1):
            for L2 in range(min(L1 + c2, q_bound - L1) + 1):
                L3_min = max(0, L1 - c1)
                L3_max = min(L2 + c3, q_bound - L1 - L2)
                for L3 in range(L3_min, L3_max + 1):
                    if L2 < L3 - c3:
                        continue
                    size = L1 + L2 + L3
                    if size <= q_bound:
                        result[size] = result.get(size, 0) + 1
        return result
    
    # For n >= 2: more complex. Use layer decomposition.
    # A cylindric partition with max <= n can be decomposed into n layers.
    # Layer m (for m=1,...,n): defines which parts are >= m.
    # Let R_i(m) = #{j: lambda^(i)_j >= m}. These satisfy:
    # R_1(m) >= R_2(m) - c_2, etc. (same interlacing at each level).
    # Wait, is that right? Let me think.
    # lambda^(1)_j >= lambda^(2)_{j+c_2} for all j.
    # If lambda^(2)_{j+c_2} >= m, then lambda^(1)_j >= m.
    # So R_1(m) >= R_2(m) - c_2? No:
    # #{j: lambda^(1)_j >= m} >= #{j: lambda^(2)_{j+c_2} >= m, and j >= 1}
    # = #{j+c_2 >= 1: lambda^(2)_{j+c_2} >= m} = #{s >= c_2+1: lambda^(2)_s >= m}
    # Hmm not quite. This approach needs more care.
    
    # Actually, the layer decomposition gives:
    # The cylindric partition is equivalent to n cylindric partitions of max 1.
    # Specifically, define mu^(i,m)_j = 1 if lambda^(i)_j >= m, else 0.
    # Then mu^(i,m) = (1^{R_i(m)}) and the interlacing conditions become:
    # For each m: (mu^(1,m), mu^(2,m), mu^(3,m)) satisfies the SAME interlacing as the original.
    # Plus: R_i(m) >= R_i(m+1) (from lambda^(i) being weakly decreasing).
    
    # So F_{c,n}(q) = sum over n-tuples (R(1), ..., R(n)) of valid layer configurations
    # where R(m) = (R_1(m), R_2(m), R_3(m)) satisfies interlacing AND
    # R_i(m) >= R_i(m+1).
    # The total size is sum_m sum_i R_i(m).
    
    # This is a product/sum that can be computed recursively.
    # At each layer m, we choose (R_1, R_2, R_3) satisfying interlacing,
    # and R_i >= R_i(next layer).
    
    # For n=2: two layers. Layer 1: (A1,A2,A3) with interlacing. Layer 2: (B1,B2,B3) with interlacing AND B_i <= A_i.
    result = {}
    for A1 in range(q_bound + 1):
        for A2 in range(min(A1 + c2, q_bound - A1) + 1):
            A3_min = max(0, A1 - c1)
            A3_max = min(A2 + c3, q_bound - A1 - A2)
            for A3 in range(A3_min, A3_max + 1):
                if A2 < A3 - c3:
                    continue
                sA = A1 + A2 + A3
                if sA > q_bound:
                    continue
                # Layer 2: (B1,B2,B3) with B_i <= A_i and interlacing
                for B1 in range(A1 + 1):
                    for B2 in range(min(B1 + c2, A2) + 1):
                        B3_min = max(0, B1 - c1)
                        B3_max = min(B2 + c3, A3)
                        for B3 in range(B3_min, B3_max + 1):
                            if B2 < B3 - c3:
                                continue
                            size = sA + B1 + B2 + B3
                            if size <= q_bound:
                                result[size] = result.get(size, 0) + 1
    return result


def main():
    q_bound = 25
    
    profiles = [
        ((1, 1, 0), 2),
        ((2, 0, 0), 2),
        ((1, 0, 1), 2),
        ((2, 1, 1), 4),
        ((1, 2, 1), 4),
        ((2, 2, 1), 5),
    ]
    
    for c, d in profiles:
        print("=" * 60)
        print(f"Profile c = {c}, d = {d}, t = {3+d}")
        print("=" * 60)
        
        # Borodin product (unrestricted)
        Fc = borodin_product(c, q_bound)
        print("F_c(q) unrestricted (first 15 coefficients):")
        for deg in range(15):
            print(f"  q^{deg}: {Fc.get(deg, Fraction(0))}")
        
        # F_{c,0} = 1
        Fc0 = {0: 1}
        
        # F_{c,1}
        Fc1 = compute_Fcn_for_binary_partitions(c, 1, q_bound)
        print(f"\nF_{{c,1}}(q) (max entry <= 1, first 15):")
        for deg in range(15):
            print(f"  q^{deg}: {Fc1.get(deg, 0)}")
        
        # f_0 and f_1
        f0 = {0: 1}
        f1 = poly_add(Fc1, {k: -v for k, v in Fc0.items()})
        
        # Compute Q_{1,c}(q)
        # [z^1]((zq;q)_inf * F_c(z,q)) = a_0*f_1 + a_1*f_0
        # a_0 = 1, a_1 = -q/(1-q) = -q - q^2 - ...
        a1_series = {deg: -1 for deg in range(1, q_bound+1)}
        z1 = poly_add(f1, a1_series)
        
        # Q_1 = (q;q)_1 * z1 = (1-q) * z1
        Q1 = poly_multiply({0: 1, 1: -1}, z1, q_bound)
        
        print(f"\nQ_{{1,c}}(q):")
        all_nonneg = True
        for deg in range(min(15, q_bound+1)):
            val = Q1.get(deg, 0)
            if val != 0:
                print(f"  q^{deg}: {val}")
            if val < 0:
                all_nonneg = False
        
        Q1_sum = sum(int(v) for v in Q1.values())
        expected = (d+1)*(d+2)//6 - 1
        print(f"Q_{{1,c}}(1) = {Q1_sum} (expected {expected})")
        print(f"All coefficients nonneg: {all_nonneg}")
        
        # For n=2, we need f_2 as well
        if d <= 2:  # Only feasible for small d
            Fc2 = compute_Fcn_for_binary_partitions(c, 2, q_bound)
            f2 = poly_add(Fc2, {k: -v for k, v in Fc1.items()})
            
            # [z^2]((zq;q)_inf * F_c(z,q)) = a_0*f_2 + a_1*f_1 + a_2*f_0
            # a_2 = q^3/((1-q)(1-q^2))
            # (q;q)_2 = (1-q)(1-q^2)
            qq2 = poly_multiply({0: 1, 1: -1}, {0: 1, 2: -1}, q_bound)
            a2_denom = poly_inverse(qq2, q_bound)
            a2 = {k+3: v for k, v in a2_denom.items() if k+3 <= q_bound}
            
            z2_part1 = f2
            # a_1*f_1: need to multiply each term of f1 by (-q^{deg+1}/(1-q))
            # a_1 = -q/(1-q) as power series
            a1f1 = poly_multiply(a1_series, f1, q_bound)
            z2_part2 = a1f1
            z2_part3 = a2  # a_2 * f_0 = a_2
            
            z2 = poly_add(poly_add(z2_part1, z2_part2), z2_part3)
            
            # Q_2 = (q;q)_2 * z2
            Q2 = poly_multiply(qq2, z2, q_bound)
            
            print(f"\nQ_{{2,c}}(q):")
            all_nonneg2 = True
            for deg in range(min(15, q_bound+1)):
                val = Q2.get(deg, 0)
                if isinstance(val, Fraction):
                    val = int(val) if val.denominator == 1 else val
                if val != 0:
                    print(f"  q^{deg}: {val}")
                if isinstance(val, (int, Fraction)) and val < 0:
                    all_nonneg2 = False
            
            Q2_sum = sum(int(v) if isinstance(v, Fraction) and v.denominator == 1 else v for v in Q2.values())
            expected2 = expected ** 2
            print(f"Q_{{2,c}}(1) = {Q2_sum} (expected {expected}^2 = {expected2})")
            print(f"All coefficients nonneg: {all_nonneg2}")
        
        print()

if __name__ == "__main__":
    main()
