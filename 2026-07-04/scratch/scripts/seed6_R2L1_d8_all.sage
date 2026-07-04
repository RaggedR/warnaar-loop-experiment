"""Test ALL d=8 profiles for Q_1 positivity."""
from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_Fcm(c, m, prec=PREC):
    if m == 0:
        return R(1)
    if m == 1:
        result = R(1)
        S = min(60, prec)
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

def compute_Q1(c, prec=PREC):
    ell = gcd(sum(c), 3)
    F0 = compute_Fcm(c, 0, prec=prec)
    F1 = compute_Fcm(c, 1, prec=prec)
    G0 = F0
    G1 = F1 - F0
    # [z^1] = G_1 - q * G_0 / (1-q)
    zn = G1 - q * G0 / (1 - q)
    Q1 = (1 - q**ell) * zn
    return Q1

d = 8
print(f"ALL profiles for d={d}, Q_1 positivity check")
print("=" * 60)

all_nonneg = True
for c0 in range(d + 1):
    for c1 in range(d - c0 + 1):
        c2 = d - c0 - c1
        c = (c0, c1, c2)
        Q1 = compute_Q1(c, prec=80)
        coeffs = [Q1[i] for i in range(30)]
        neg = [i for i in range(30) if Q1[i] < 0]
        total = sum(coeffs)
        status = "NONNEG" if not neg else f"NEG at {neg}"
        if neg:
            all_nonneg = False
        # Only print if negative or interesting
        if neg:
            print(f"c={c}: Q_1 coeffs={coeffs[:15]}, sum={total}, {status}")

if all_nonneg:
    print(f"\nALL {(d+1)*(d+2)//2} profiles have Q_1 >= 0!")
else:
    print(f"\nSome profiles have negative Q_1 coefficients!")

# Count distinct Q_1 polynomials up to cyclic permutation
from collections import defaultdict
orbits = defaultdict(list)
for c0 in range(d + 1):
    for c1 in range(d - c0 + 1):
        c2 = d - c0 - c1
        c = (c0, c1, c2)
        canonical = min(c, (c1,c2,c0), (c2,c0,c1))
        orbits[canonical].append(c)

print(f"\n{len(orbits)} distinct orbits. Sample Q_1 values:")
for canon, members in sorted(orbits.items()):
    Q1 = compute_Q1(members[0], prec=60)
    coeffs = [Q1[i] for i in range(20)]
    nonzero = [(i, Q1[i]) for i in range(20) if Q1[i] != 0]
    print(f"  {canon} ({len(members)} members): {nonzero[:10]}, sum={sum(coeffs)}")

