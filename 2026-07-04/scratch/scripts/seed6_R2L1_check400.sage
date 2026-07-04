"""Check Q_1 for c=(4,0,0) with very high precision."""
from sage.all import *

# Precision warning from Round 1: need >= 6*max(k,m)^2 + 50
# For m=1: need >= 6 + 50 = 56. Let's use 400.
PREC = 400
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

c = (4, 0, 0)
ell = 1

# Compute g_1 for c=(4,0,0)
# s_0 >= s_1 >= s_2, s_0 <= s_2 + 4
# max(s_i) >= 1
g1 = R(1)  # empty CP
S = 200  # max column count
for s0 in range(1, S):  # s_0 >= 1 for max=1 CPs
    for s1 in range(s0 + 1):
        for s2 in range(s1 + 1):
            if s0 <= s2 + 4:
                total = s0 + s1 + s2
                if total < PREC:
                    g1 += q**total

# g_1 should stabilize at (d+1)(d+2)/6 = 5 for large enough degree
# Let's check the first 20 coefficients of g_1
print(f"g_1 coefficients (first 20): {[g1[i] for i in range(20)]}")

# [z^1]((zq;q)_inf * F_c(z,q)) = g_1 - q/(1-q)
# Q_1 = (1 - q) * (g_1 - q/(1-q))
#      = (1-q)*g_1 - q

Q1 = (1 - q**ell) * g1 + (-q) / (1 - q) * (1 - q**ell)
# Simplify: (1-q) * g_1 + (-q/(1-q)) * (1-q) = (1-q)*g_1 - q
Q1 = (1 - q) * g1 - q

Q1_coeffs = [Q1[i] for i in range(20)]
print(f"Q_1 coefficients: {Q1_coeffs}")
print(f"Q_1(1) = {sum([Q1[i] for i in range(100)])}")

# Wait, but the formula should be:
# [z^1] = sum_{m+j=1} g_m * (-1)^j q^{j(j+1)/2} / (q;q)_j
# = g_1 * 1 + g_0 * (-q) / (q;q)_1
# = g_1 + (-q) / (1-q)
# = g_1 - q/(1-q)

# Q_1 = (q^ell;q^ell)_1 * [z^1] = (1-q) * (g_1 - q/(1-q))
# = (1-q)*g_1 - q

# Check the arithmetic:
# (1-q)*g_1 at q^0: 1*1 = 1
# (1-q)*g_1 at q^1: 1*g_1[1] - g_1[0] = 1 - 1 = 0
# Minus q: -q at q^0: 0, at q^1: -1
# Q_1[0] = 1
# Q_1[1] = 0 - 1 = -1

# So Q_1 = 1 - q + ...
# This has constant term 1 and coefficient of q is -1.

# BUT WAIT: should Q_n have a constant term?
# Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# At q=0: (q;q)_n|_{q=0} = 1. 
# F_c(z,0) = sum_m z^m * #{CPs with size 0 and max <= m}
# CPs with size 0: all partitions are empty. Max = 0.
# So F_c(z,0) = sum_{m >= 0} z^m = 1/(1-z).
# (zq;q)_inf|_{q=0} = 1.
# (zq;q)_inf * F_c(z,q)|_{q=0} = 1/(1-z) = sum z^m.
# [z^n] = 1.
# So Q_n(0) = 1. The constant term IS 1.

# For profile (2,1,1):
# g_1|_{q=0} = 1, g_1[1] = 3
# (1-q)*g_1 at q^0 = 1, at q^1 = 3-1 = 2
# Q_1 at q^0 = 1, q^1 = 2-1 = 1. Correct: [1,1,1,1].

# For profile (4,0,0):
# g_1|_{q=0} = 1, g_1[1] = 1
# (1-q)*g_1 at q^0 = 1, at q^1 = 1-1 = 0
# Q_1[1] = 0 - 1 = -1. Hmm.

# So the negative coefficient is real. Is this profile actually excluded somehow?
# d=4, c=(4,0,0). d is not divisible by 3. But the profile has c_1 = c_2 = 0.
# Let me check: the interlacing conditions are:
# lambda^1_j >= lambda^2_{j+0} (since c_1 = 0)
# lambda^2_j >= lambda^0_{j+0} (since c_2 = 0)
# lambda^0_j >= lambda^1_{j+4} (since c_0 = 4)
# So lambda^1 >= lambda^2 >= lambda^0 entrywise, and lambda^0_j >= lambda^1_{j+4}.
# That means lambda^2 = lambda^0 entrywise (since lambda^2 >= lambda^0 and lambda^0 <= lambda^2 only if they're equal).
# Wait: lambda^1_j >= lambda^2_j and lambda^2_j >= lambda^0_j and lambda^0_j >= lambda^1_{j+4}.
# So lambda^1 >= lambda^2 >= lambda^0 entrywise.
# That's fine, no equality forced.

# Actually wait -- this IS correct. Profile (4,0,0) with d=4 gives Q_1 with a negative
# coefficient. But maybe this profile IS allowed by the conjecture?
# The conjecture says c = (c_0,c_1,c_2) with d = c_0+c_1+c_2 not divisible by 3.
# c = (4,0,0), d = 4 not divisible by 3. So the conjecture DOES claim Q_1 >= 0.

# Let me check if Round 1 found this. They say "Q_1 >= 0 for d not div by 3" (GREEN).
# But for c=(4,0,0) I get Q_1 = 1 - q + ... which has -1 at q^1.
# EITHER my computation is wrong OR Round 1 made an error.

# Let me try another approach to verify.
# For c=(4,0,0), I_c = {0} (only c_0 > 0).
# CW recurrence: J must be a nonempty subset of I_c = {0}.
# Only J = {0}. shift_profile((4,0,0), {0}): 
# i=0 in J, prev=2 not in J: c_0 -> 4-1=3
# i=1 not in J, prev=0 in J: c_1 -> 0+1=1
# i=2 not in J, prev=1 not in J: c_2 -> 0
# c({0}) = (3,1,0).

# So F_{(4,0,0)}(y,q) = F_{(3,1,0)}(yq, q) / (1 - yq)

# F_{c,0} = 1 for any c.
# F_{c,1} = g_1.

# For c=(3,1,0): g_1 should be larger because c_1=1 allows more freedom.
c2 = (3, 1, 0)
g1_2 = R(1)
for s0 in range(1, S):
    for s1 in range(min(s0 + c2[1] + 1, S)):
        for s2 in range(min(s1 + c2[2] + 1, S)):
            if s0 <= s2 + c2[0]:
                if max(s0, s1, s2) >= 1:
                    total = s0 + s1 + s2
                    if total < PREC:
                        g1_2 += q**total

print(f"\ng_1 for (3,1,0) first 20: {[g1_2[i] for i in range(20)]}")

# Use CW to compute g_1 for (4,0,0) from (3,1,0):
# F_{(4,0,0)}(y,q) = F_{(3,1,0)}(yq, q) / (1-yq)
# [y^1] F_{(4,0,0)} = [y^1][F_{(3,1,0)}(yq, q)/(1-yq)]
# F_{(3,1,0)}(yq, q) = sum_m (yq)^m g_m^{(3,1,0)} = sum_m y^m q^m g_m^{(3,1,0)}
# 1/(1-yq) = sum_j y^j q^j
# [y^1] = sum_{m+j=1} q^m g_m * q^j = q^0 g_1^{(3,1,0)} * q + q^1 g_0^{(3,1,0)} * q^0
# Wait, let me be careful:
# [y^1](sum_m y^m q^m g_m * sum_j y^j q^j) = sum_{m+j=1} q^m g_m q^j
# = q^1 g_1^{(3,1,0)} * q^0 + q^0 g_0^{(3,1,0)} * q^1
# Hmm that's q*g_1' + q = q*(g_1' + 1) where g_1' = g_1^{(3,1,0)}

# Actually let me redo more carefully.
# F(y,q) = sum_m y^m g_m(q)
# F_{(3,1,0)}(yq, q) = sum_m (yq)^m g_m^{(3,1,0)} = sum_m y^m q^m g_m^{(3,1,0)}
# Divided by (1-yq):
# F_{(4,0,0)}(y,q) = [sum_m y^m q^m g_m^{(3,1,0)}] * [sum_j y^j q^j]
# = sum_N y^N * [sum_{m+j=N} q^{m+j} g_m^{(3,1,0)}]  ... wait q^{m+j} = q^N? No.
# = sum_N y^N * [sum_{m=0}^N q^m g_m^{(3,1,0)} * q^{N-m}]
# = sum_N y^N q^N * [sum_{m=0}^N g_m^{(3,1,0)}]

# Hmm that doesn't look right either. Let me think again.
# (yq)^m = y^m * q^m. And y^j * q^j in the 1/(1-yq) expansion.
# Product: y^{m+j} * q^{m+j}. So [y^N] = sum_{m+j=N} q^{m+j} g_m = sum_m q^N g_m = q^N sum_{m=0}^N g_m.
# So g_N^{(4,0,0)} = q^N * sum_{m=0}^N g_m^{(3,1,0)}.

# For N=1: g_1^{(4,0,0)} = q * (g_0^{(3,1,0)} + g_1^{(3,1,0)}) = q * (1 + g_1^{(3,1,0)})
g1_check = q * (1 + g1_2)
print(f"g_1 for (4,0,0) via CW first 20: {[g1_check[i] for i in range(20)]}")
print(f"g_1 for (4,0,0) direct first 20: {[g1[i] for i in range(20)]}")
print(f"Match: {[g1_check[i] for i in range(15)] == [g1[i] for i in range(15)]}")

