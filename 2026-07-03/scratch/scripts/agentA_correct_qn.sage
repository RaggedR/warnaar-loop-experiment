"""
Agent A: Correct computation of Q_n as a POLYNOMIAL.

The issue: g_m are power series, but Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
is a polynomial. We need to carefully compute the z^n coefficient of
(zq;q)_inf * sum_m z^m g_m
and then multiply by (q;q)_n.

The cancellation that makes this a polynomial comes from the alternating
signs in (zq;q)_inf = sum_j z^j (-1)^j q^{j(j+1)/2} / (q;q)_j
"""
from sage.all import *

PREC = 80  # high precision to see the polynomial structure

R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm(c, m, prec=PREC):
    """
    Compute g_m = coefficient of y^m in F_c(y,q).
    For max = m, each partition lambda^i has parts in {0,...,m}.
    Represent lambda^i by its "column counts" (s_1,...,s_m) where s_j = #{parts >= j}.
    The column counts satisfy s_1 >= s_2 >= ... >= s_m >= 0.
    
    Size contribution from lambda^i = s_1 + s_2 + ... + s_m.
    
    Interlacing: lambda^i_j >= lambda^{i+1}_{j + c_{i+1 mod k}}
    In column counts: s^i_h >= s^{i+1}_h + c_{i+1 mod k}... no this is wrong.
    
    Let me think column-by-column. At height h (1 <= h <= m):
    s^i_h = #{parts of lambda^i >= h}
    The interlacing lambda^i_j >= lambda^{i+1}_{j + c_{(i+1) mod k}} implies:
    for each h, s^i_h >= s^{(i+1) mod k}_h + c_{(i+1) mod k}... 
    WAIT: this is NOT correct in general.
    
    The interlacing is a ROW condition: the j-th row of lambda^i >= the (j+c_{i+1})-th row of lambda^{i+1}.
    This does NOT translate simply to column inequalities.
    
    Actually it does: lambda^i_j >= lambda^{i+1}_{j+c} means that the j-th 
    row of lambda^i is at least as long as the (j+c)-th row of lambda^{i+1}.
    In column language: #{parts of lambda^i >= h} >= #{parts of lambda^{i+1} >= h} - c
    Wait no. Let me think again.
    
    lambda^i_j >= lambda^{i+1}_{j+c}: for every j, the j-th part of lambda^i >= the (j+c)-th part of lambda^{i+1}.
    This means: for height h, the set of positions where lambda^i >= h contains {1,...,s^i_h}.
    The constraint says: if lambda^{i+1}_{j+c} >= h (i.e., j+c <= s^{i+1}_h, i.e., j <= s^{i+1}_h - c),
    then lambda^i_j >= h (i.e., j <= s^i_h).
    So s^{i+1}_h - c <= s^i_h, i.e., s^i_h >= s^{i+1}_h - c, i.e., s^{i+1}_h <= s^i_h + c.
    
    This is an inequality AT EACH HEIGHT h!
    So for each h: s^{(i+1) mod k}_h <= s^i_h + c_{(i+1) mod k}
    
    For k=3, c=(c_0, c_1, c_2):
    s^1_h <= s^0_h + c_1
    s^2_h <= s^1_h + c_2
    s^0_h <= s^2_h + c_0
    
    And the s^i values at different heights satisfy s^i_1 >= s^i_2 >= ... >= s^i_m >= 0.
    
    Size = sum_i sum_h s^i_h.
    Max = m requires at least one s^i_m >= 1.
    """
    k = len(c)
    result = R(0)
    
    if m == 0:
        return R(1)  # Empty partition
    
    if m == 1:
        # Only one level. State: (s_0, s_1, s_2)
        # s_1 <= s_0 + c[1], s_2 <= s_1 + c[2], s_0 <= s_2 + c[0]
        # At least one s_i >= 1
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
        # Two levels: h=1 and h=2
        # At h=1: (a0, a1, a2) with a1<=a0+c1, a2<=a1+c2, a0<=a2+c0
        # At h=2: (b0, b1, b2) with b1<=b0+c1, b2<=b1+c2, b0<=b2+c0
        # And b_i <= a_i (column decreasing)
        # Max=2 requires some b_i >= 1
        for a0 in range(prec // 2):
            for a1 in range(min(a0 + c[1] + 1, prec // 2)):
                for a2 in range(min(a1 + c[2] + 1, prec // 2)):
                    if a0 <= a2 + c[0]:
                        for b0 in range(min(a0 + 1, prec // 2)):
                            for b1 in range(min(b0 + c[1] + 1, a1 + 1, prec // 2)):
                                for b2 in range(min(b1 + c[2] + 1, a2 + 1, prec // 2)):
                                    if b0 <= b2 + c[0]:
                                        if max(b0, b1, b2) >= 1:
                                            total = a0+a1+a2+b0+b1+b2
                                            if total < prec:
                                                result += q**total
        return result
    
    return None  # Too complex for m >= 3

# Compute for d=4, c=(2,1,1)
c = (2, 1, 1)
print(f"Profile: {c}, d = {sum(c)}")

g0 = compute_gm(c, 0)
g1 = compute_gm(c, 1)
g2 = compute_gm(c, 2)

print(f"g_0 = {g0}")
print(f"g_1 first terms = {g1}")
print(f"g_2 first terms = {g2}")

# Q_1 = (q;q)_1 * [z^1]((zq;q)_inf * F(z,q))
# [z^1] = g_1 * (term for j=0) + g_0 * (term for j=1)
# = g_1 * 1 + g_0 * (-q)/(q;q)_0... wait no.
# (zq;q)_inf = sum_j z^j * (-1)^j * q^{j(j+1)/2} / (q;q)_j
# [z^n] of product = sum_{m+j=n} g_m * (-1)^j * q^{j(j+1)/2} / (q;q)_j
# For n=1: (m,j) = (1,0) or (0,1)
# = g_1 * 1 + g_0 * (-q)/(1) = g_1 - q

Q1 = (1-q) * (g1 - q)
# Wait that's wrong too. Let me be careful.
# [z^1] = g_1 * ((-1)^0 q^0 / (q;q)_0) + g_0 * ((-1)^1 q^1 / (q;q)_1)
# = g_1 - q*g_0/(1-q) = g_1 - q/(1-q)
# Q_1 = (q;q)_1 * [z^1] = (1-q) * (g_1 - q/(1-q)) = (1-q)*g_1 - q

Q1 = (1-q) * g1 - q
print(f"\nQ_1 = (1-q)*g_1 - q")

# Let's see the first few coefficients
coeffs = [Q1[i] for i in range(40)]
print(f"Q_1 coefficients: {coeffs}")
print(f"Q_1(1) = {sum(coeffs)}")

# Wait: g_1 stabilizes at 5 (= (d+1)(d+2)/6 - 1 = 4? No, 5*6/6 = 5.)
# So (1-q)*g_1 stabilizes at 0 (geometric series effect).
# But it's still an infinite series! (1-q) * sum_{n>=1} a_n q^n where a_n -> 5
# = sum_{n>=1} (a_n - a_{n-1}) q^n - a_0
# If a_n stabilizes at 5, then a_n - a_{n-1} = 0 for large n, so this IS a polynomial!

# Let me check: Q_1 should be a POLYNOMIAL (finite number of nonzero coeffs)
nonzero_pos = [i for i in range(40) if Q1[i] != 0]
print(f"Nonzero positions: {nonzero_pos}")

# Great! So Q_1 is indeed a polynomial once g_1 stabilizes.
# For c=(2,1,1), g_1 stabilizes at 5 (starting from coefficient of q^3).
# (1-q)*g_1 = sum (a_n - a_{n-1}) q^n where a_1=3, a_2=4, a_3=5, a_n=5 for n>=3.
# = 3q + q^2 + q^3 + 0 + 0 + ...
# Q_1 = (1-q)*g_1 - q = 3q + q^2 + q^3 - q = 2q + q^2 + q^3
# Q_1(1) = 2 + 1 + 1 = 4. Correct!

print(f"\nVerification: Q_1(1) = {sum(coeffs)} (expected {(sum(c)+1)*(sum(c)+2)//6 - 1})")

# Now for Q_2:
# Q_2 = (q;q)_2 * [z^2]
# [z^2] = g_2 * 1 + g_1 * (-q)/(1-q) + g_0 * q^3/((1-q)(1-q^2))
# Q_2 = (1-q)(1-q^2) * [g_2 - g_1*q/(1-q) + q^3/((1-q)(1-q^2))]
# = (1-q)(1-q^2)*g_2 - (1-q^2)*q*g_1 + q^3

Q2 = (1-q)*(1-q**2)*g2 - (1-q**2)*q*g1 + q**3
coeffs2 = [Q2[i] for i in range(40)]
nonzero2 = [i for i in range(40) if Q2[i] != 0]
print(f"\nQ_2 coefficients: {coeffs2}")
print(f"Nonzero positions: {nonzero2}")
print(f"Q_2(1) = {sum(coeffs2)} (expected {((sum(c)+1)*(sum(c)+2)//6 - 1)**2})")
print(f"All nonneg? {all(c >= 0 for c in coeffs2)}")

# h_2 = (1-q)(1-q^2)*g_2
h2 = (1-q)*(1-q**2)*g2
coeffs_h2 = [h2[i] for i in range(40)]
print(f"\nh_2 coefficients: {coeffs_h2}")
print(f"h_2 all nonneg? {all(c >= 0 for c in coeffs_h2)}")

# Also check Q_1 and Q_2 for more profiles
print("\n" + "=" * 60)
print("Q_1 and Q_2 for all representative d=4 profiles")
print("=" * 60)

for c in [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,1,1)]:
    g1 = compute_gm(c, 1, prec=30)
    Q1 = (1-q)*g1 - q
    c1 = [Q1[i] for i in range(20)]
    nz1 = [i for i in range(20) if Q1[i] != 0]
    neg1 = [i for i in range(20) if Q1[i] < 0]
    
    print(f"\nc={c}:")
    print(f"  Q_1 coeffs: {c1[:15]}, Q_1(1)={sum(c1)}")
    print(f"  Nonzero at: {nz1}, Negative: {neg1 if neg1 else 'NONE'}")

# And d=7 profiles  
print("\n" + "=" * 60)
print("Q_1 for representative d=7 profiles")
print("=" * 60)

for c in [(7,0,0), (5,1,1), (4,2,1), (3,3,1), (3,2,2)]:
    g1 = compute_gm(c, 1, prec=30)
    Q1 = (1-q)*g1 - q
    c1 = [Q1[i] for i in range(25)]
    print(f"c={c}: Q_1 = polynomial, coeffs = {c1[:15]}, sum = {sum(c1)}")
    neg1 = [i for i in range(25) if Q1[i] < 0]
    if neg1:
        print(f"  NEGATIVE at: {neg1}")

