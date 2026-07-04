"""
Seed 7 — Analysis of Q_1 for various profiles.

Q_{1,c}(q) = (1-q) * g_1(q) - q

where g_1(q) = sum over binary cylindric partitions with max exactly 1.

A binary cylindric partition of profile c = (c_0, c_1, c_2) is determined by
(L_0, L_1, L_2) where L_i >= 0 and:
  L_1 <= L_0 + c_1
  L_2 <= L_1 + c_2  
  L_0 <= L_2 + c_0

Weight = L_0 + L_1 + L_2, and max >= 1 means not all L_i = 0.

g_1(q) = (sum over valid (L_0,L_1,L_2) of q^{L_0+L_1+L_2}) - 1
"""

from math import gcd

def compute_g1_rational(c, max_q=50):
    """Compute g_1(q) by direct summation up to max_q."""
    c0, c1, c2 = c
    coeffs = {}
    for w in range(1, max_q + 1):
        count = 0
        for L0 in range(w + 1):
            for L1 in range(w - L0 + 1):
                L2 = w - L0 - L1
                if L2 < 0: continue
                if L1 <= L0 + c1 and L2 <= L1 + c2 and L0 <= L2 + c0:
                    count += 1
        if count > 0:
            coeffs[w] = count
    return coeffs

def multiply_1_minus_q(p, max_q=50):
    """Multiply polynomial p by (1-q)."""
    result = dict(p)
    for k, v in p.items():
        if k + 1 <= max_q:
            result[k+1] = result.get(k+1, 0) - v
    return {k: v for k, v in result.items() if v != 0}

if __name__ == "__main__":
    profiles = [
        (1, 1, 0),  # d=2
        (2, 0, 0),  # d=2
        (0, 1, 1),  # d=2
        (2, 1, 1),  # d=4
        (1, 2, 1),  # d=4
        (1, 1, 2),  # d=4
        (3, 1, 0),  # d=4
        (2, 2, 1),  # d=5
        (3, 1, 1),  # d=5
        (1, 3, 1),  # d=5
        (4, 2, 1),  # d=7
        (3, 2, 2),  # d=7
        (3, 3, 1),  # d=7
    ]
    
    max_q = 30
    
    print("Q_1 analysis")
    print("Q_{1,c}(q) = (1-q)*g_1(q) - q")
    print("="*70)
    
    for c in profiles:
        d = sum(c)
        if d % 3 == 0: continue
        expected = (d+1)*(d+2)//6 - 1
        
        g1 = compute_g1_rational(c, max_q)
        
        # Q_1 = (1-q)*g_1 - q
        temp = multiply_1_minus_q(g1, max_q)
        # subtract q
        temp[1] = temp.get(1, 0) - 1
        Q1 = {k: v for k, v in temp.items() if v != 0}
        
        all_pos = all(v >= 0 for v in Q1.values())
        q1_val = sum(Q1.values())
        
        # Print first few coefficients of g_1
        g1_terms = sorted(g1.items())[:8]
        g1_str = " + ".join(f"{v}q^{e}" for e, v in g1_terms)
        
        Q1_terms = sorted(Q1.items())[:10]
        Q1_str = " + ".join(f"{v}q^{e}" if v != 1 else f"q^{e}" for e, v in Q1_terms if v > 0)
        neg_terms = [(e,v) for e,v in Q1_terms if v < 0]
        
        print(f"\nc = {c}, d = {d}, expected Q_1(1) = {expected}")
        print(f"  g_1 = {g1_str} + ...")
        print(f"  Q_1 = {Q1_str}")
        if neg_terms:
            print(f"  NEGATIVE TERMS: {neg_terms}")
        print(f"  Q_1(1) = {q1_val}, expected {expected}, match: {q1_val == expected}")
        print(f"  All non-negative: {all_pos}")
        
        # Check pattern: is g_1 = (something nice) / (1-q)?
        # If g_1 = a_1 q + a_2 q^2 + ... then (1-q)*g_1 has finite many terms
        # iff g_1 is eventually periodic with period 1 (i.e., constant coefficients eventually)
        
        # Check if g_1 coefficients stabilize
        g1_vals = [g1.get(w, 0) for w in range(1, max_q + 1)]
        
        # Check for polynomial behavior: do (1-q)*g_1 coefficients eventually vanish?
        temp2 = multiply_1_minus_q(g1, max_q)
        temp2_vals = [(e, temp2.get(e, 0)) for e in range(1, max_q + 1)]
        nonzero_high = [(e,v) for e,v in temp2_vals if v != 0 and e > d + 5]
        
        if not nonzero_high:
            print(f"  (1-q)*g_1 is a POLYNOMIAL (terminates)")
        else:
            print(f"  (1-q)*g_1 has nonzero coefficients up to q^{max(e for e,v in nonzero_high)}")
    
    # Deeper analysis: for c=(2,1,1), compute g_1 closed form
    print("\n" + "="*70)
    print("DETAILED: g_1 for c = (2,1,1)")
    c = (2,1,1)
    g1 = compute_g1_rational(c, 40)
    g1_vals = [g1.get(w, 0) for w in range(1, 41)]
    print(f"  g_1 coefficients: {g1_vals[:20]}")
    
    # Check: is (1-q)^k * g_1 a polynomial for some k?
    temp = dict(g1)
    for k in range(1, 5):
        temp = multiply_1_minus_q(temp, 50)
        max_nonzero = max((e for e,v in temp.items() if v != 0), default=0)
        print(f"  (1-q)^{k} * g_1: max nonzero term at q^{max_nonzero}, all pos: {all(v >= 0 for v in temp.values())}")
        if max_nonzero < 10:
            print(f"    = {dict(sorted(temp.items()))}")
