"""Debug: why did Q_1(0,4,0) != Q_1(4,0,0)?"""
from sage.all import *

PREC = 100
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_Fcm(c, m, prec=PREC):
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

# Direct test
for c_test in [(4,0,0), (0,4,0)]:
    F0 = compute_Fcm(c_test, 0, prec=30)
    F1 = compute_Fcm(c_test, 1, prec=30)
    G0 = F0  # = 1
    G1 = F1 - F0
    
    # [z^1] = G_1 + G_0 * (-q)/(q;q)_1
    # = G_1 - q/(1-q)
    zn = G1 - q / (1 - q)
    
    ell = gcd(sum(c_test), 3)
    Q1 = (1 - q**ell) * zn
    
    print(f"c={c_test}:")
    print(f"  F_0 = {F0}, F_1[:10] = {[F1[i] for i in range(10)]}")
    print(f"  G_0 = {G0}, G_1[:10] = {[G1[i] for i in range(10)]}")
    print(f"  [z^1][:10] = {[zn[i] for i in range(10)]}")
    print(f"  Q_1[:10] = {[Q1[i] for i in range(10)]}")
    print()

