"""
FIXED computation. The key distinction:
- F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}
- [y^m] F_c(y,q) = G_m = generating function for CPs with max EXACTLY m (not <= m)
- F_{c,n}(q) = sum_{m=0}^n G_m = generating function for max <= n

So Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
where F_c(z,q) = sum_m z^m G_m.

Now (zq;q)_inf * F_c(z,q) = sum_j z^j (-1)^j q^{j(j+1)/2}/(q;q)_j * sum_m z^m G_m.

[z^n] = sum_{j+m=n} (-1)^j q^{j(j+1)/2}/(q;q)_j * G_m
      = sum_{j=0}^n (-1)^j q^{j(j+1)/2}/(q;q)_j * G_{n-j}

And G_m = F_{c,m} - F_{c,m-1} for m >= 1, G_0 = F_{c,0} = 1.
"""
from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_Fcm(c, m, prec=PREC):
    """Compute F_{c,m} = sum over CPs with max <= m of q^{|Lambda|}.
    This is the CUMULATIVE generating function."""
    if m == 0:
        return R(1)
    
    if m == 1:
        result = R(1)
        S = min(100, prec)
        for s0 in range(1, S):
            for s1 in range(min(s0 + c[1] + 1, S)):
                for s2 in range(min(s1 + c[2] + 1, S)):
                    if s0 <= s2 + c[0]:
                        total = s0 + s1 + s2
                        if total < prec:
                            result += q**total
        return result
    
    if m == 2:
        result = R(1)
        S = min(50, int(prec/2) + 1)
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

def compute_Qn(c, n, prec=PREC):
    """Compute Q_n using F_{c,m} values."""
    ell = gcd(sum(c), 3)
    
    # G_m = F_{c,m} - F_{c,m-1}
    F_vals = {}
    for m in range(n + 1):
        F_vals[m] = compute_Fcm(c, m, prec=prec)
        if F_vals[m] is None:
            return None
    
    G_vals = {}
    G_vals[0] = F_vals[0]  # = 1
    for m in range(1, n + 1):
        G_vals[m] = F_vals[m] - F_vals[m - 1]
    
    # [z^n] = sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q;q)_j * G_{n-j}
    result = R(0)
    for j in range(n + 1):
        m = n - j
        sign = (-1)**j
        qpow = q**(j*(j+1)//2)
        qfact = R(1)
        for i in range(1, j + 1):
            qfact *= (1 - q**i)
        result += sign * qpow * G_vals[m] / qfact
    
    # Multiply by (q^ell;q^ell)_n
    for i in range(1, n + 1):
        result *= (1 - q**(ell * i))
    
    return result

# ============================================================
# Test all d=4 profiles
# ============================================================
print("=" * 60)
print("d=4 profiles, Q_1")
print("=" * 60)

d = 4
expected = (d+1)*(d+2)//6 - 1  # = 4

for c in [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,1,1), (2,0,2), (1,3,0), (1,2,1), (1,1,2), (1,0,3), (0,4,0), (0,3,1), (0,2,2), (0,1,3), (0,0,4)]:
    if sum(c) != d:
        continue
    Q1 = compute_Qn(c, 1, prec=80)
    if Q1 is not None:
        coeffs = [Q1[i] for i in range(20)]
        neg = [i for i in range(20) if Q1[i] < 0]
        print(f"c={c}: Q_1 = {coeffs[:12]}, sum={sum(coeffs)}, neg={neg if neg else 'NONE'}")

# Check the "exactly max = m" interpretation
print("\n\nVerification of G_m vs F_m:")
c = (4, 0, 0)
F0 = compute_Fcm(c, 0, prec=30)
F1 = compute_Fcm(c, 1, prec=30)
G0 = F0
G1 = F1 - F0
print(f"F_0 = {F0}")
print(f"F_1 first 15 = {[F1[i] for i in range(15)]}")
print(f"G_0 = {G0}")
print(f"G_1 first 15 = {[G1[i] for i in range(15)]}")

# Q_1 = (1-q) * (G_1 + G_0 * (-q))
# Wait: [z^1] = G_1 * 1 + G_0 * (-q)/(q;q)_1
# Q_1 = (1-q) * [G_1 - q*G_0/(1-q)]
# = (1-q)*G_1 - q*G_0
# = (1-q)*G_1 - q

Q1_manual = (1 - q) * G1 - q
print(f"\nQ_1 manual first 15 = {[Q1_manual[i] for i in range(15)]}")

Q1_auto = compute_Qn(c, 1, prec=30)
print(f"Q_1 auto first 15 = {[Q1_auto[i] for i in range(15)]}")

# Also test d=2
print("\n" + "=" * 60)
print("d=2 profiles, Q_1")
print("=" * 60)

for c in [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]:
    Q1 = compute_Qn(c, 1, prec=40)
    if Q1 is not None:
        coeffs = [Q1[i] for i in range(15)]
        neg = [i for i in range(15) if Q1[i] < 0]
        print(f"c={c}: Q_1 = {coeffs[:10]}, sum={sum(coeffs)}, neg={neg if neg else 'NONE'}")

