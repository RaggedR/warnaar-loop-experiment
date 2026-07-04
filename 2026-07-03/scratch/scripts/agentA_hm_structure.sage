"""
Agent A: Study the structure of h_m = (q;q)_m * g_m to find WHY it's nonneg.

Key observations so far:
- g_m is a power series that eventually becomes a quasi-polynomial
- (q;q)_m * g_m is a polynomial (the cancellation is exact)
- h_m should be nonneg for d not-equiv 0 mod 3

Let me compute h_m for several m values and look for patterns
that might suggest a combinatorial interpretation.
"""
from sage.all import *

PREC = 100
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm_columns(c, m, prec=PREC):
    """
    Compute g_m using the column representation.
    For max = m: each lambda^i has column counts s^i = (s^i_1, ..., s^i_m)
    with s^i_1 >= s^i_2 >= ... >= s^i_m >= 0.
    Interlacing at each height h: s^{(i+1) mod k}_h <= s^i_h + c_{(i+1) mod k}
    Max = m: at least one s^i_m >= 1.
    Size = sum_i sum_h s^i_h.
    """
    k = len(c)
    result = R(0)
    
    if m == 0:
        return R(1)
    
    if m >= 4:
        print(f"  m={m} too large for direct computation")
        return None
    
    # For k=3, m levels, need to enumerate (s^0_1,...,s^0_m, s^1_1,...,s^1_m, s^2_1,...,s^2_m)
    # Subject to: s^i_h >= s^i_{h+1} (column decreasing)
    #             s^{(i+1)%3}_h <= s^i_h + c_{(i+1)%3} at each h
    #             max(s^0_m, s^1_m, s^2_m) >= 1

    # For m=1: 3 variables
    if m == 1:
        for s0 in range(prec):
            for s1 in range(min(s0 + c[1] + 1, prec)):
                for s2 in range(min(s1 + c[2] + 1, prec)):
                    if s0 <= s2 + c[0]:
                        if max(s0, s1, s2) >= 1:
                            total = s0 + s1 + s2
                            if total < prec:
                                result += q**total
        return result
    
    if m == 2:
        # 6 variables: (a0,a1,a2) at h=1, (b0,b1,b2) at h=2
        # b_i <= a_i, interlacing at both levels, max requires some b_i >= 1
        max_s = min(prec // (2*k), 40)
        for a0 in range(max_s):
            for a1 in range(min(a0 + c[1] + 1, max_s)):
                for a2 in range(min(a1 + c[2] + 1, max_s)):
                    if a0 <= a2 + c[0]:
                        for b0 in range(min(a0+1, max_s)):
                            for b1 in range(min(b0+c[1]+1, a1+1, max_s)):
                                for b2 in range(min(b1+c[2]+1, a2+1, max_s)):
                                    if b0 <= b2 + c[0]:
                                        if max(b0, b1, b2) >= 1:
                                            total = a0+a1+a2+b0+b1+b2
                                            if total < prec:
                                                result += q**total
        return result
    
    if m == 3:
        # 9 variables - this is slower
        max_s = min(prec // (3*k), 20)
        for a0 in range(max_s):
            for a1 in range(min(a0+c[1]+1, max_s)):
                for a2 in range(min(a1+c[2]+1, max_s)):
                    if a0 > a2 + c[0]:
                        continue
                    for b0 in range(min(a0+1, max_s)):
                        for b1 in range(min(b0+c[1]+1, a1+1, max_s)):
                            for b2 in range(min(b1+c[2]+1, a2+1, max_s)):
                                if b0 > b2 + c[0]:
                                    continue
                                for e0 in range(min(b0+1, max_s)):
                                    for e1 in range(min(e0+c[1]+1, b1+1, max_s)):
                                        for e2 in range(min(e1+c[2]+1, b2+1, max_s)):
                                            if e0 > e2 + c[0]:
                                                continue
                                            if max(e0, e1, e2) >= 1:
                                                total = a0+a1+a2+b0+b1+b2+e0+e1+e2
                                                if total < prec:
                                                    result += q**total
        return result

def qpoch_poly(m, prec=PREC):
    result = R(1)
    for i in range(1, m+1):
        result *= (1 - q**i)
    return result

# Compute h_m for d=4, c=(2,1,1) and d=7, c=(3,2,2)
for c_profile in [(2,1,1), (3,2,2)]:
    d = sum(c_profile)
    L = (d+1)*(d+2)//6 - 1  # Expected Q_1(1)
    print(f"\n{'='*60}")
    print(f"Profile {c_profile}, d={d}, Q_n(1) = {L}^n")
    print(f"{'='*60}")
    
    for m in range(1, 4):
        gm = compute_gm_columns(c_profile, m, prec=60)
        if gm is None:
            continue
        hm = qpoch_poly(m, prec=60) * gm
        coeffs = [hm[i] for i in range(40)]
        # Find where it becomes zero
        last_nonzero = max([i for i in range(40) if coeffs[i] != 0], default=-1)
        print(f"\n  h_{m} coefficients (degree {last_nonzero}):")
        print(f"    {coeffs[:last_nonzero+3]}")
        print(f"    h_{m}(1) = {sum(coeffs)}")
        neg = [i for i in range(40) if coeffs[i] < 0]
        if neg:
            print(f"    NEGATIVE at positions: {neg}")
        else:
            print(f"    ALL NONNEG!")
        
        # Check if h_m has a nice q-binomial decomposition
        # h_m should evaluate to L^m - something at q=1
        print(f"    Expected from tower: h_{m}(1) relates to the combinatorics")

# Now test d=3 (should fail)
print(f"\n{'='*60}")
print(f"Profile (1,1,1), d=3 (should have h_1 < 0)")
print(f"{'='*60}")

c = (1,1,1)
g1 = compute_gm_columns(c, 1, prec=40)
h1 = (1-q) * g1
coeffs = [h1[i] for i in range(30)]
print(f"  g_1 first terms: {[g1[i] for i in range(15)]}")
print(f"  h_1 coefficients: {coeffs[:15]}")
neg = [i for i in range(30) if coeffs[i] < 0]
print(f"  Negative at: {neg if neg else 'NONE'}")

# And d=6
c = (2,2,2)
g1 = compute_gm_columns(c, 1, prec=40)
h1 = (1-q) * g1
coeffs = [h1[i] for i in range(30)]
print(f"\nProfile (2,2,2), d=6:")
print(f"  g_1 first terms: {[g1[i] for i in range(15)]}")
print(f"  h_1 coefficients: {coeffs[:15]}")
neg = [i for i in range(30) if coeffs[i] < 0]
print(f"  Negative at: {neg if neg else 'NONE'}")

