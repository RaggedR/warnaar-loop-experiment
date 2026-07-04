#!/usr/bin/env python3
"""
Seed 6, Layer 2: Verify g_1 monotonicity and Q_1 positivity argument.

g_1(q) = F_{c,1}(q) / F_{c,0}(q) = F_{c,1}(q) (since F_{c,0}=1).
More precisely, g_1(q) = [z^1]F_c(z,q) = f_1(q) = F_{c,1}(q) - 1.

Wait: F_{c,0}(q) = 1 (only the empty partition). 
F_{c,1}(q) = sum of q^{|Lambda|} over Lambda with max <= 1.
f_1(q) = F_{c,1}(q) - F_{c,0}(q) = F_{c,1}(q) - 1 (cylindric partitions with max EXACTLY 1).

Q_1 = (1-q) * (f_1 + a_1 * 1) where a_1 = -q/(1-q) = -sum_{j>=1} q^j.
So Q_1 = (1-q) * (f_1 - q/(1-q)) = (1-q)*f_1 - q.

Write f_1 = sum_{k>=1} a_k q^k. Then:
(1-q)*f_1 = sum_k a_k q^k - sum_k a_k q^{k+1}
           = a_1 q + sum_{k>=2} (a_k - a_{k-1}) q^k

Q_1 = a_1 q - q + sum_{k>=2} (a_k - a_{k-1}) q^k
    = (a_1 - 1) q + sum_{k>=2} (a_k - a_{k-1}) q^k

For Q_1 to have nonneg coefficients:
- a_1 >= 2 (coefficient of q is a_1 - 1 >= 1)
- a_k >= a_{k-1} for all k >= 2 (monotonically increasing)
- f_1 is eventually zero (it's a power series, not a polynomial, but the 
  differences a_k - a_{k-1} must eventually become zero)

Wait, f_1 is NOT a polynomial -- it's an infinite power series. Let me reconsider.

Actually, g_1(q) = [z^1]F_c(z,q) counts cylindric partitions with max exactly 1.
These have parts in {0,1}, so each lambda^(i) = (1^{L_i}) and the size is L_1+L_2+L_3.
The interlacing conditions give linear constraints on (L_1,L_2,L_3).
So f_1(q) = sum over valid (L_1,L_2,L_3) with L_i >= 0 of q^{L_1+L_2+L_3}.

This is a RATIONAL function in q (lattice point counting in a polyhedral cone).

Q_1 = (1-q)*f_1 - q. Since f_1 is a rational function with denominator dividing
some product of (1-q^a), the product (1-q)*f_1 may have cancellation.

Let's compute f_1 explicitly for several profiles.
"""

from fractions import Fraction

def compute_f1(c, q_bound):
    """Compute f_1(q) = sum over valid (L1,L2,L3) of q^{L1+L2+L3},
    where L_i >= 0 and interlacing conditions hold, and at least one L_i > 0."""
    c0, c1, c2 = c
    # Conditions: L1 >= L2 - c1, L2 >= L3 - c2, L3 >= L1 - c0
    # Equiv: L2 <= L1 + c1, L3 <= L2 + c2, L1 <= L3 + c0
    # At least one L_i > 0.
    
    result = {}
    for L1 in range(q_bound + 1):
        for L2 in range(min(L1 + c1, q_bound - L1) + 1):
            L3_min = max(0, L1 - c0)
            L3_max = min(L2 + c2, q_bound - L1 - L2)
            for L3 in range(L3_min, L3_max + 1):
                if L2 < L3 - c2:
                    continue
                if L1 + L2 + L3 == 0:
                    continue
                s = L1 + L2 + L3
                if s <= q_bound:
                    result[s] = result.get(s, 0) + 1
    return result

def main():
    q_bound = 40
    
    test_cases = [
        (2, (1,1,0)),
        (2, (2,0,0)),
        (4, (2,1,1)),
        (4, (3,1,0)),
        (4, (1,1,2)),
        (5, (2,2,1)),
        (7, (3,2,2)),
        (7, (4,2,1)),
        (7, (5,1,1)),
        (8, (3,3,2)),
    ]
    
    for d, c in test_cases:
        f1 = compute_f1(c, q_bound)
        
        # Compute coefficients
        coeffs = [f1.get(k, 0) for k in range(q_bound + 1)]
        
        # Check monotonicity
        monotone = True
        first_decrease = None
        for k in range(2, q_bound + 1):
            if coeffs[k] < coeffs[k-1]:
                if first_decrease is None:
                    first_decrease = k
                monotone = False
        
        # Check stable value
        stable = coeffs[-1]
        stable_start = None
        for k in range(q_bound, 0, -1):
            if coeffs[k] != stable:
                stable_start = k + 1
                break
        
        # Compute Q_1 = (1-q)*f_1 - q
        Q1 = {}
        for k, v in f1.items():
            Q1[k] = Q1.get(k, 0) + v
            if k + 1 <= q_bound:
                Q1[k+1] = Q1.get(k+1, 0) - v
        Q1[1] = Q1.get(1, 0) - 1
        Q1 = {k: v for k, v in Q1.items() if v != 0}
        
        nonneg = all(v >= 0 for v in Q1.values())
        
        # Is Q1 a polynomial (finite support)?
        max_deg = max(Q1.keys()) if Q1 else 0
        is_poly = (max_deg < q_bound - 5)  # finite support well within bounds
        
        print(f"d={d}, c={c}:")
        print(f"  f_1 coeffs (first 15): {coeffs[1:16]}")
        print(f"  Stable value: {stable} (= (d+1)(d+2)/6 = {(d+1)*(d+2)//6})")
        print(f"  Monotone (weakly increasing): {monotone}" + 
              (f" (first decrease at k={first_decrease})" if not monotone else ""))
        print(f"  Stabilizes at degree: {stable_start}")
        
        Q1_str = " + ".join(f"{v}q^{k}" for k, v in sorted(Q1.items()) if v != 0 and k <= 20)
        print(f"  Q_1 = {Q1_str}")
        print(f"  Q_1(1) = {sum(Q1.values())} (expected {(d+1)*(d+2)//6 - 1})")
        print(f"  Q_1 nonneg: {nonneg}")
        print(f"  Q_1 is polynomial: {is_poly} (max degree {max_deg})")
        
        # The positivity argument:
        # Q_1[1] = f_1[1] - 1 = a_1 - 1
        # Q_1[k] = a_k - a_{k-1} for k >= 2 (where f_1 has stabilized)
        # After stabilization: a_k = a_{k-1} = stable, so Q_1[k] = 0.
        # So Q_1 is indeed a polynomial, and its coefficients are:
        # [k=1]: a_1 - 1
        # [k>=2]: a_k - a_{k-1}
        # Monotonicity of a_k and a_1 >= 2 implies all nonneg.
        
        if monotone and coeffs[1] >= 2:
            print(f"  ** POSITIVITY PROOF for Q_1: a_1={coeffs[1]} >= 2 AND f_1 monotone => Q_1 >= 0 **")
        print()

if __name__ == "__main__":
    main()
