# Correct analytic computation for d=2, c=(1,1,0)
# The column-count states at height h: (s0, s1, s2) in Z_>=0^3
# with s1 <= s0+1, s2 <= s1, s0 <= s2+1.
# Weight = s0 + s1 + s2.

# For max=m: m heights, each with a state (s^0_h, s^1_h, s^2_h)
# and s^i_{h+1} <= s^i_h (column heights decrease).

# At each height h, the GF for the state is:
# sum over valid (s0,s1,s2) of q^{s0+s1+s2}
# For c=(1,1,0): constraints are s1<=s0+1, s2<=s1, s0<=s2+1.
# This means s0-s2 in {0,1}, s1 in {s2, ..., s0+1}.
# Case s0=s2: s1 in {s2,...,s2+1} = {s2, s2+1}. Weight: s0+s1+s2 = 2s2+s1 = {3s2, 3s2+1}.
# Case s0=s2+1: s1 in {s2,...,s2+2} = {s2, s2+1, s2+2}. Weight = s2+1+s1+s2 = 2s2+1+s1.
#   s1=s2: weight 3s2+1. s1=s2+1: weight 3s2+2. s1=s2+2: weight 3s2+3.

# So the valid states parameterized by s2=a and type:
# s0=a, s1=a: (a,a,a), weight 3a. Type 1.
# s0=a, s1=a+1: wait, s1<=s0+1=a+1 and s2=a<=s1. So s1 in {a, a+1}? No:
# s2 <= s1 and s1 <= s0+1. s2=a, s0=a. s1 in {a, a+1}? s2=a<=s1 requires s1>=a.
# s1<=a+1. So s1 in {a, a+1}.

# Let me be more systematic.
# s0, s2: s0 in {s2, s2+1}.
# Case A: s0=s2=a. s1 in [a, a+1]. Types: (a,a,a) w=3a, (a,a+1,a) w=3a+1.
# Case B: s0=s2+1. s2=a, s0=a+1. s1 in [a, a+2]. Types: 
#   (a+1,a,a) w=3a+1, (a+1,a+1,a) w=3a+2, (a+1,a+2,a) w=3a+3.

# So 5 types per base a >= 0:
# Weight 3a: 1 state
# Weight 3a+1: 2 states
# Weight 3a+2: 1 state
# Weight 3a+3: 1 state (same as weight 3(a+1): counted again)

# Actually for base a, the weights are 3a, 3a+1, 3a+1, 3a+2, 3a+3.
# weight 3a+3 = 3(a+1). But the state (a+1, a+2, a) has s0=a+1, s1=a+2, s2=a.
# Check: s1=a+2 <= s0+1=a+2. s2=a<=s1=a+2. s0=a+1<=s2+1=a+1. All OK.

# So for weight n:
# n = 3a: 1 state (type (a,a,a))
# n = 3a+1: 2 states ((a,a+1,a) and (a+1,a,a))
# n = 3a+2: 1 state ((a+1,a+1,a))
# n = 3a+3 = 3(a+1): 1 state from base a, PLUS the 1 state from base a+1 type (a+1,a+1,a+1)

# Hmm, so for weight w:
# w=0: (0,0,0). 1 state.
# w=1: (0,1,0) and (1,0,0). 2 states.
# w=2: (1,1,0). 1 state.
# w=3: (1,1,1) from base 1 type (a,a,a), AND (1,2,0) from base 0 type (a+1,a+2,a). 2 states.
# w=4: (1,2,1) and (2,1,1). 2 states.
# ...

# The pattern: coefficient of q^w in g_1 (max exactly 1, so w >= 1):
# w=1: 2, w=2: 1, w=3: 2, w=4: 2, w=5: 1, w=6: 2, ...
# Wait, numerically we got all coefficients = 2. Let me recheck.

from sage.all import *

PREC = 30
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

g1 = R(0)
for s0 in range(20):
    for s1 in range(min(s0+2, 20)):  # s1 <= s0+1
        for s2 in range(min(s1+1, 20)):  # s2 <= s1
            if s0 <= s2+1 and max(s0,s1,s2) >= 1:
                total = s0+s1+s2
                if total < PREC:
                    g1 += q**total

# Show first 10 coefficients
for w in range(10):
    print(f"  g_1[q^{w}] = {g1[w]}")

# All are 2 for w >= 1? Let me check w=2:
# States with weight 2: (1,1,0) -- 1 state. Not 2!
# Wait, I need to list ALL valid (s0,s1,s2) with s0+s1+s2=2, max>=1:
# (2,0,0): s1=0<=3, s2=0<=0, s0=2<=0+1=1? NO. Invalid.
# (1,1,0): s1=1<=2, s2=0<=1, s0=1<=0+1=1. Valid.
# (1,0,1): s2=1<=s1=0? Invalid.
# (0,2,0): s1=2<=s0+1=1? Invalid.
# (0,1,1): s1=1<=1, s2=1<=1, s0=0<=1+1=2. Valid.
# (0,0,2): s2=2<=0? Invalid.
# So 2 states. coefficient = 2. Correct!

# And w=3:
# (3,0,0): s0=3<=s2+1=1? Invalid.
# (2,1,0): s1=1<=3, s2=0<=1, s0=2<=1? Invalid.
# (2,0,1): s1=0<=3, s2=1<=0? Invalid.
# (1,2,0): s1=2<=2, s2=0<=2, s0=1<=1. Valid.
# (1,1,1): s1=1<=2, s2=1<=1, s0=1<=2. Valid.
# (1,0,2): s2=2<=0? Invalid.
# (0,2,1): s1=2<=1? Invalid.
# (0,1,2): s2=2<=1? Invalid.
# (0,0,3): Invalid.
# (0,3,0): Invalid.
# So 2 states: (1,2,0) and (1,1,1). Coefficient = 2.

print(f"\ng_1 = {g1}")
print(f"g_1 stabilizes at coefficient 2 for all q^w, w >= 1")

# So F_{c,1} = 1 + g_1 = 1 + 2q + 2q^2 + ... = 1 + 2q/(1-q) = (1+q)/(1-q)
# (1-q)*F_{c,1} = 1+q. Makes sense.

# Q_1 = (1-q)*(g_1 - q/(1-q)) 
# Wait, let me redo. [z^1] = g_1 + g_0 * c_1 where c_1 = -q/(1-q)
# = g_1 - q/(1-q) where g_0=1.
# g_1 = 2q/(1-q). So [z^1] = 2q/(1-q) - q/(1-q) = q/(1-q).
# Q_1 = (1-q) * q/(1-q) = q. Correct!

print(f"\n[z^1] = g_1 - q/(1-q) = 2q/(1-q) - q/(1-q) = q/(1-q)")
print(f"Q_1 = (1-q) * q/(1-q) = q. CORRECT!")

# Now let me compute g_2 and Q_2 for d=2.
# g_2 counts CPs with max exactly 2.
# Two heights: h=1 state (a0,a1,a2), h=2 state (b0,b1,b2)
# with b_i <= a_i (columns decrease), same interlacing at each height.
# max=2 means at least one b_i >= 1.

g2 = R(0)
for a0 in range(15):
    for a1 in range(min(a0+2, 15)):
        for a2 in range(min(a1+1, 15)):
            if a0 > a2+1: continue
            for b0 in range(min(a0+1, 15)):
                for b1 in range(min(b0+2, a1+1, 15)):
                    for b2 in range(min(b1+1, a2+1, 15)):
                        if b0 <= b2+1 and max(b0,b1,b2) >= 1:
                            total = a0+a1+a2+b0+b1+b2
                            if total < PREC:
                                g2 += q**total

print(f"\ng_2 = {g2}")
for w in range(15):
    print(f"  g_2[q^{w}] = {g2[w]}")

# Now Q_2
# [z^2] = g_2 + g_1*c_1 + g_0*c_2
# c_1 = -q/(1-q), c_2 = q^3/((1-q)(1-q^2))
# Q_2 = (1-q)(1-q^2) * [z^2]

c1_coeff = -q/(1-q)
c2_coeff = q**3 / ((1-q)*(1-q**2))

z2 = g2 + g1*c1_coeff + c2_coeff
Q2 = (1-q)*(1-q**2)*z2
print(f"\nQ_2 = {Q2}")
Q2_poly = Q2.polynomial()
print(f"Q_2 polynomial = {Q2_poly}")
print(f"Q_2(1) = {Q2_poly(1)}")

# g_3 for d=2
g3 = R(0)
lim = 10
for a0 in range(lim):
    for a1 in range(min(a0+2, lim)):
        for a2 in range(min(a1+1, lim)):
            if a0 > a2+1: continue
            for b0 in range(min(a0+1, lim)):
                for b1 in range(min(b0+2, a1+1, lim)):
                    for b2 in range(min(b1+1, a2+1, lim)):
                        if b0 > b2+1: continue
                        for c0 in range(min(b0+1, lim)):
                            for c1v in range(min(c0+2, b1+1, lim)):
                                for c2 in range(min(c1v+1, b2+1, lim)):
                                    if c0 <= c2+1 and max(c0,c1v,c2) >= 1:
                                        total = a0+a1+a2+b0+b1+b2+c0+c1v+c2
                                        if total < PREC:
                                            g3 += q**total

print(f"\ng_3 = {g3}")

# Q_3
c3_coeff = -q**6 / ((1-q)*(1-q**2)*(1-q**3))
z3 = g3 + g2*c1_coeff + g1*c2_coeff + c3_coeff
Q3 = (1-q)*(1-q**2)*(1-q**3)*z3
print(f"\nQ_3 = {Q3}")
Q3_poly = Q3.polynomial()
print(f"Q_3 polynomial = {Q3_poly}")
print(f"Q_3(1) = {Q3_poly(1)}")

