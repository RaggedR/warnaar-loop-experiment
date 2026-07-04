"""Check cyclic invariance of G_m and why c_0=0 gives wrong Q_1."""
from sage.all import *

PREC = 100
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_Fcm(c, m, prec=PREC):
    """F_{c,m} = number of CPs with max <= m."""
    if m == 0:
        return R(1)
    if m == 1:
        result = R(1)
        S = min(50, prec)
        for s0 in range(S):
            for s1 in range(min(s0 + c[1] + 1, S)):
                for s2 in range(min(s1 + c[2] + 1, S)):
                    if s0 <= s2 + c[0]:
                        if max(s0, s1, s2) >= 1:
                            total = s0 + s1 + s2
                            if total < prec:
                                result += q**total
        return result
    return None

# Check F_{c,1} for cyclic permutations
for c in [(4,0,0), (0,4,0), (0,0,4)]:
    F1 = compute_Fcm(c, 1, prec=30)
    print(f"F_{{1}} for c={c}: {[F1[i] for i in range(15)]}")

print()

# Hmm, they should be the SAME due to cyclic symmetry.
# The cyclic shift (c_0,c_1,c_2) -> (c_1,c_2,c_0) corresponds to
# relabeling the partitions: lambda^0 -> lambda^1 -> lambda^2 -> lambda^0
# This permutes the interlacing conditions cyclically.
# The size and max are both preserved.
# So F_c = F_{sigma(c)} for cyclic sigma. In particular F_{c,m} should be invariant.

# But wait: the indexing in my enumeration uses SPECIFIC interlacing.
# For c = (c_0, c_1, c_2):
# lambda^i_j >= lambda^{i+1}_{j + c_{i+1}} for i = 0,1 (mod 3 for i=2)
# So:
# c = (4,0,0): lambda^0_j >= lambda^1_{j+0}, lambda^1_j >= lambda^2_{j+0}, lambda^2_j >= lambda^0_{j+4}
#   => lambda^0 >= lambda^1 >= lambda^2 entrywise, lambda^2_j >= lambda^0_{j+4}
# c = (0,4,0): lambda^0_j >= lambda^1_{j+4}, lambda^1_j >= lambda^2_{j+0}, lambda^2_j >= lambda^0_{j+0}
#   => lambda^1 >= lambda^2 >= lambda^0 entrywise, lambda^0_j >= lambda^1_{j+4}
# c = (0,0,4): lambda^0_j >= lambda^1_{j+0}, lambda^1_j >= lambda^2_{j+4}, lambda^2_j >= lambda^0_{j+0}
#   => lambda^0 >= lambda^1 >= lambda^2... wait no: lambda^2 >= lambda^0 entrywise too?
#   lambda^2_j >= lambda^0_{j+0} = lambda^0_j AND lambda^0_j >= lambda^1_j
#   So lambda^2 >= lambda^0 >= lambda^1, and lambda^1_j >= lambda^2_{j+4}

# For c=(4,0,0) in column counts at height h:
# s^1_h <= s^0_h + c[1] = s^0_h + 0 = s^0_h   (lambda^1 <= lambda^0)
# s^2_h <= s^1_h + c[2] = s^1_h + 0 = s^1_h   (lambda^2 <= lambda^1)  
# s^0_h <= s^2_h + c[0] = s^2_h + 4

# So s^2 <= s^1 <= s^0 <= s^2 + 4. size = s^0 + s^1 + s^2.

# For c=(0,4,0):
# s^1_h <= s^0_h + c[1] = s^0_h + 4
# s^2_h <= s^1_h + c[2] = s^1_h
# s^0_h <= s^2_h + c[0] = s^2_h

# So s^0 <= s^2 <= s^1 <= s^0 + 4. size = s^0 + s^1 + s^2.

# By substituting (a,b,c) = (s^0, s^1, s^2) for (4,0,0): a >= b >= c, a <= c+4
# For (0,4,0): c >= a, b >= c, b <= a+4. Substitute u=b, v=c, w=a: u >= v >= w, u <= w+4.
# Same set of constraints! And size = u+v+w = a+b+c.

# So F_{c,1} SHOULD be the same. Let me check my enumeration more carefully.
# My enumeration for c=(0,4,0):
# s0 in range(S), s1 in range(s0+4+1), s2 in range(s1+0+1=s1+1), s0 <= s2+0=s2
# So s0 <= s2 <= s1, s1 <= s0+4.
# min(s0,s1,s2)... I need max >= 1, so max(s0,s1,s2) = s1 >= 1.

# For c=(4,0,0):
# s0 in range(S), s1 in range(s0+0+1=s0+1), s2 in range(s1+0+1=s1+1), s0 <= s2+4
# So s2 <= s1 <= s0, s0 <= s2+4.  
# max(s0,s1,s2) = s0 >= 1.

# The SIZE = s0+s1+s2 is symmetric. Both enumerate the same triples (just with
# different variable names). So F_{c,1} should be the same.

# But my enumeration ranges over s0 from 0. For (4,0,0), s0 goes to S.
# For (0,4,0), s0 goes to S too, but then s1 goes to s0+4, which is larger!
# That means more terms. But the constraint s0 <= s2 limits things.

# Let me check: for (0,4,0) with s0=0:
# s1 in range(5): s1=0,1,2,3,4
# s2 in range(s1+1) and s0=0<=s2
# So s2 ranges from 0 to s1.
# For s1=1, s2=0 or 1: (0,1,0) size=1 and (0,1,1) size=2.
# For (4,0,0), can we get size=1? s0 >= 1, s2 <= s1 <= s0, s0 <= s2+4.
# s0=1, s1=0 or 1, s2 <= s1. 
# s0=1, s1=1, s2=0 or 1: (1,1,0) size=2, (1,1,1) size=3.
# s0=1, s1=0, s2=0: (1,0,0) size=1.
# So size=1 appears in both: (1,0,0) for (4,0,0) and (0,1,0) for (0,4,0). Good.

# Wait, let me just verify F_1 for these two profiles numerically.
print("Detailed comparison:")
for c in [(4,0,0), (0,4,0)]:
    F1 = compute_Fcm(c, 1, prec=20)
    print(f"  F_1({c}) = {[F1[i] for i in range(15)]}")

# If they match, the issue must be in the Q_n computation somehow.
# If they DON'T match, there's a bug in my enumeration.

