"""Test Q_2 for profiles NOT covered by Warnaar's fermionic formula at d=8."""
from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_Fcm(c, m, prec=PREC):
    if m == 0:
        return R(1)
    if m == 1:
        result = R(1)
        S = min(40, prec)
        for s0 in range(S):
            for s1 in range(min(s0 + c[1] + 1, S)):
                for s2 in range(min(s1 + c[2] + 1, S)):
                    if s0 <= s2 + c[0]:
                        if max(s0, s1, s2) >= 1:
                            total = s0 + s1 + s2
                            if total < prec:
                                result += q**total
        return result
    if m == 2:
        result = R(1)
        S = min(20, int(prec/2) + 1)
        for a0 in range(S):
            for a1 in range(min(a0 + c[1] + 1, S)):
                for a2 in range(min(a1 + c[2] + 1, S)):
                    if a0 <= a2 + c[0]:
                        if max(a0, a1, a2) >= 1:
                            for b0 in range(a0 + 1):
                                for b1 in range(min(b0 + c[1] + 1, a1 + 1)):
                                    for b2 in range(min(b1 + c[2] + 1, a2 + 1)):
                                        if b0 <= b2 + c[0]:
                                            total = a0+a1+a2+b0+b1+b2
                                            if total < prec:
                                                result += q**total
        return result
    return None

def compute_Qn(c, n_val, prec=PREC):
    ell = gcd(sum(c), 3)
    F = {}
    for m in range(n_val + 1):
        F[m] = compute_Fcm(c, m, prec=prec)
        if F[m] is None:
            return None
    G = {0: F[0]}
    for m in range(1, n_val + 1):
        G[m] = F[m] - F[m - 1]
    result = R(0)
    for j in range(n_val + 1):
        m = n_val - j
        qfact = R(1)
        for i in range(1, j + 1):
            qfact *= (1 - q**i)
        result += (-1)**j * q**(j*(j+1)//2) * G[m] / qfact
    for i in range(1, n_val + 1):
        result *= (1 - q**(ell * i))
    return result

# Test Q_2 for uncovered profiles at d=8
# Uncovered: (1,1,6), (1,2,5), (1,3,4), (1,4,3), (1,5,2), (2,2,4), etc.
print("Q_2 for uncovered d=8 profiles")
print("=" * 60)

for c in [(1,1,6), (2,2,4), (1,3,4), (4,4,0)]:
    print(f"\nc={c}, d={sum(c)}:")
    Q2 = compute_Qn(c, 2, prec=100)
    if Q2 is not None:
        coeffs = [Q2[i] for i in range(40)]
        neg = [i for i in range(40) if Q2[i] < 0]
        print(f"  Q_2 coeffs[:20] = {coeffs[:20]}")
        print(f"  Q_2(1) = {sum(coeffs)}, expected = {14**2}")
        if neg:
            print(f"  NEGATIVE at {neg}")
        else:
            print(f"  All nonneg: YES")
    else:
        print(f"  Cannot compute (m=2 too complex for this profile)")

# Also test a covered profile for comparison
c = (8, 0, 0)
print(f"\nc={c} (covered):")
Q2 = compute_Qn(c, 2, prec=100)
if Q2 is not None:
    coeffs = [Q2[i] for i in range(40)]
    neg = [i for i in range(40) if Q2[i] < 0]
    print(f"  Q_2 coeffs[:20] = {coeffs[:20]}")
    print(f"  Q_2(1) = {sum(coeffs)}, expected = {14**2}")
    if neg:
        print(f"  NEGATIVE at {neg}")
    else:
        print(f"  All nonneg: YES")

