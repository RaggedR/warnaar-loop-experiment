"""
Carefully verify the definition of Q_n.

Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))

where F_c(z,q) = sum_{m >= 0} z^m g_m(q)
and g_m = F_{c,m} = sum over CPs with max <= m of q^{|Lambda|}.

Note: g_0 = 1 (empty partition), g_1 = 1 + sum_{max=1}, etc.
The "max" means the maximum entry across all partitions.

(zq;q)_inf = prod_{j>=1} (1 - zq^j) = sum_{j>=0} (-1)^j z^j q^{j(j+1)/2} / (q;q)_j

WAIT: (zq;q)_inf means (zq; q)_inf = prod_{j>=0} (1 - zq^{j+1}) = prod_{j>=1} (1 - zq^j).
In standard notation, (a;q)_inf = prod_{j>=0}(1-aq^j).
So (zq;q)_inf = prod_{j>=0}(1 - zq^{j+1}) = prod_{j>=1}(1-zq^j).

Using the q-exponential: (z;q)_inf = sum_{j>=0} (-z)^j q^{j(j-1)/2} / (q;q)_j.
So (zq;q)_inf = sum_{j>=0} (-zq)^j q^{j(j-1)/2} / (q;q)_j
             = sum_{j>=0} (-1)^j z^j q^{j + j(j-1)/2} / (q;q)_j
             = sum_{j>=0} (-1)^j z^j q^{j(j+1)/2} / (q;q)_j.

OK, my formula was correct.
"""
from sage.all import *

PREC = 100
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm_careful(c, m, prec=PREC):
    """Compute g_m = F_{c,m} via direct enumeration for small m."""
    if m == 0:
        return R(1)
    
    if m == 1:
        result = R(1)  # Include the empty CP (all zero partitions)
        # CPs with max entry exactly 1:
        # Each partition lambda^i has parts in {0,1}.
        # So lambda^i is just a number of 1's: s_i = length of parts equal to 1.
        # Interlacing: s_{(i+1)%3} <= s_i + c_{(i+1)%3}
        # Size: s_0 + s_1 + s_2.
        # Need max(s_0, s_1, s_2) >= 1 (at least one part = 1).
        # Wait, NO. max entry = 1 means at least one lambda^i has first part = 1.
        # That means at least one s_i >= 1.
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
        # Two heights. At height 1: (a0, a1, a2). At height 2: (b0, b1, b2).
        # b_i <= a_i. Interlacing at each height.
        # Includes CPs with max = 0 (g_0 included) and max = 1 and max = 2.
        result = R(1)  # g_0 contribution (empty CP)
        S = int(prec // 2) + 1
        for a0 in range(S):
            for a1 in range(min(a0 + c[1] + 1, S)):
                for a2 in range(min(a1 + c[2] + 1, S)):
                    if a0 <= a2 + c[0]:
                        if max(a0, a1, a2) >= 1:
                            # This is a CP with max >= 1 and max <= 2
                            # Height 1 contributes a0+a1+a2
                            # Now enumerate height 2
                            for b0 in range(a0 + 1):  # b0 <= a0
                                for b1 in range(min(b0 + c[1] + 1, a1 + 1)):
                                    for b2 in range(min(b1 + c[2] + 1, a2 + 1)):
                                        if b0 <= b2 + c[0]:
                                            total = a0+a1+a2+b0+b1+b2
                                            if total < prec:
                                                result += q**total
        return result
    return None

# Test d=4, c=(4,0,0)
c = (4, 0, 0)
print(f"Profile {c}, d={sum(c)}, ell={gcd(sum(c),3)}")
ell = gcd(sum(c), 3)

g0 = compute_gm_careful(c, 0, prec=30)
g1 = compute_gm_careful(c, 1, prec=30)

print(f"g_0 = {g0}")
g1_coeffs = [g1[i] for i in range(15)]
print(f"g_1 first 15 coeffs = {g1_coeffs}")

# [z^1]((zq;q)_inf * F_c(z,q)):
# = sum_{m+j=1} g_m * (-1)^j * q^{j(j+1)/2} / (q;q)_j
# = g_1 * (j=0: 1) + g_0 * (j=1: -q^1 / (1-q))
# = g_1 - q/(1-q)
zn_coeff = g1 + g0 * (-q) / (1 - q)
print(f"[z^1] first 15 = {[zn_coeff[i] for i in range(15)]}")

# Q_1 = (q^ell;q^ell)_1 * [z^1]
Q1 = (1 - q**ell) * zn_coeff
print(f"Q_1 first 15 = {[Q1[i] for i in range(15)]}")

# Let me try to understand what's happening.
# g_0 = 1 (just the empty CP).
# q/(1-q) = q + q^2 + q^3 + ...
# So [z^1] = g_1 - q/(1-q).
# g_1 = 1 + sum_{max=1 CPs} q^size
# g_1 starts with 1 (empty CP contribution).
# For c=(4,0,0): interlacing s_1 <= s_0+0=s_0, s_2 <= s_1+0=s_1, s_0 <= s_2+4
# So s_0 >= s_1 >= s_2 and s_0 <= s_2+4.
# max(s_0,s_1,s_2) >= 1 means s_0 >= 1.
# s_0 can range 1,...
# Size = s_0+s_1+s_2 >= 1.

# Let me enumerate small terms:
print("\nEnumerating max=1 CPs for c=(4,0,0):")
count = 0
for s0 in range(10):
    for s1 in range(s0+1):
        for s2 in range(s1+1):
            if s0 <= s2 + 4:
                if s0 >= 1:
                    size = s0+s1+s2
                    if size < 20:
                        print(f"  ({s0},{s1},{s2}) size={size}")
                        count += 1
print(f"Total max=1 CPs with size < 20: {count}")

# Now check balanced profile (2,1,1) directly
print("\n" + "=" * 60)
c = (2, 1, 1)
print(f"Profile {c}, d={sum(c)}, ell={gcd(sum(c),3)}")
ell = gcd(sum(c), 3)

g0 = R(1)
g1 = compute_gm_careful(c, 1, prec=30)
g1_coeffs = [g1[i] for i in range(15)]
print(f"g_1 first 15 = {g1_coeffs}")

zn1 = g1 - q / (1 - q)
Q1 = (1 - q**ell) * zn1
Q1_coeffs = [Q1[i] for i in range(15)]
print(f"Q_1 = {Q1_coeffs}")
print(f"Q_1(1) = {sum(Q1_coeffs)}")
print(f"Expected: {(4+1)*(4+2)//6 - 1}")

# Check: for d=4, expected Q_1(1) = 15/6 - 1 = 2.5 - 1? No.
# (d+1)(d+2)/6 - 1 = 5*6/6 - 1 = 5 - 1 = 4.
print(f"Computed: (d+1)(d+2)/6 - 1 = {(4+1)*(4+2)/6 - 1}")

# But with unified formula: ell*(d+4)*(d-1)/6
print(f"Unified: ell*(d+4)*(d-1)/6 = {ell*(4+4)*(4-1)/6}")

