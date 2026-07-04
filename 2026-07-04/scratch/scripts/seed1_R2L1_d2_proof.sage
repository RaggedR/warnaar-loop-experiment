# Prove Q_n = q^{n^2} for d=2 algebraically.
# 
# For d=2, c=(c0,c1,c2) with c0+c1+c2=2, ell=gcd(2,3)=1.
# By cyclic invariance, Q_n is the same for all profiles.
# 
# Let's verify for c=(1,1,0) and understand the structure.
#
# g_m counts CPs of profile c with max exactly m.
# For d=2, the column-count states at each height are parameterized by
# triples (s0,s1,s2) with constraints depending on the profile.
#
# For c=(1,1,0): s1<=s0+1, s2<=s1, s0<=s2+1. 
# Number of valid states with weight w: always 2 for w >= 1.
# So g_m has a VERY specific structure.
#
# For multi-height m: states are m-tuples of column-count triples,
# each satisfying interlacing AND decreasing in each component.
#
# Claim: for d=2, g_m is determined by a transfer matrix of size 5x5
# (5 valid state types per height).

from sage.all import *

PREC = 60
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

# For d=2, c=(1,1,0), the valid single-height states are:
# With weight 3a: (a,a,a). One state.
# With weight 3a+1: (a,a+1,a) and (a+1,a,a). Two states.
# With weight 3a+2: (a+1,a+1,a). One state.
# With weight 3a+3: (a+1,a+2,a). One state.
# Wait, 3a+3 = 3(a+1), so this overlaps with weight 3(a+1) from base a+1.
# Let me think of the states modulo the base.

# At base a, the types are:
# T0: (a, a, a),     weight 3a
# T1: (a, a+1, a),   weight 3a+1
# T2: (a+1, a, a),   weight 3a+1
# T3: (a+1, a+1, a), weight 3a+2
# T4: (a+1, a+2, a), weight 3a+3 = 3(a+1)

# But T4 at base a has the same weight as T0 at base a+1.
# T4: (a+1, a+2, a) vs T0: (a+1, a+1, a+1). Different states, same weight.

# So per weight w:
# w = 3b: T0 at base b, T4 at base b-1 (if b>=1). Total: 1 + (1 if b>=1) = 1 or 2.
# w = 3b+1: T1 and T2 at base b. Total: 2.
# w = 3b+2: T3 at base b. Total: 1.

# Wait, for w=0: only (0,0,0). Count 1.
# w=1: (0,1,0) and (1,0,0). Count 2. ✓
# w=2: (1,1,0). Count 1.
# w=3: (1,1,1) [T0 at a=1] and (1,2,0) [T4 at a=0]. Count 2.
# w=4: (1,2,1) [T1 at a=1] and (2,1,1) [T2 at a=1]. Count 2.
# w=5: (2,2,1) [T3 at a=1]. Count 1.
# w=6: (2,2,2) [T0 at a=2] and (2,3,1) [T4 at a=1]. Count 2.

# So pattern: w=0: 1, w=1: 2, w=2: 1, w=3: 2, w=4: 2, w=5: 1, w=6: 2, ...
# The pattern for w >= 1 alternates 2, 1, 2 with period 3? No:
# w: 1,2,3,4,5,6,7,8,9
# c: 2,1,2,2,1,2,2,1,2
# So period 3: (2, 1, 2) for w mod 3 = (1, 2, 0).

# g_1 coefficient of q^w for w >= 1:
# w mod 3 = 0: 2
# w mod 3 = 1: 2  
# w mod 3 = 2: 1
# Total per period of 3: 2+2+1 = 5. Average: 5/3.
# But numerically we got coefficient = 2 for all w >= 1. That contradicts!

# Let me recheck numerically.
g1_coeffs = {}
for s0 in range(20):
    for s1 in range(min(s0+2, 20)):
        for s2 in range(min(s1+1, 20)):
            if s0 <= s2+1 and max(s0,s1,s2) >= 1:
                w = s0+s1+s2
                g1_coeffs[w] = g1_coeffs.get(w, 0) + 1

for w in range(15):
    print(f"g_1[q^{w}] = {g1_coeffs.get(w, 0)}")

# Hmm, let me also list the actual states for small weights
for w in range(7):
    states = []
    for s0 in range(w+1):
        for s1 in range(w-s0+1):
            s2 = w - s0 - s1
            if s2 >= 0 and s1 <= s0+1 and s2 <= s1 and s0 <= s2+1 and max(s0,s1,s2) >= 1:
                states.append((s0,s1,s2))
    print(f"w={w}: {len(states)} states: {states}")

