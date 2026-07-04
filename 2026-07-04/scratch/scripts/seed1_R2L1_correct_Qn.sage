# Correct computation of Q_n using:
# P_n = (q^3;q^3)_n * F_{c,n} (manifestly positive path formula)
# Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m F_m z^m)
# F_m = P_m / (q^3;q^3)_m (power series)

from sage.all import *
from collections import defaultdict

R = PowerSeriesRing(QQ, 'q', default_prec=300)
q = R.gen()

# EMD computation  
def emd(c1, c2):
    return 3*max(0, c2[1]-c1[1], c1[0]-c2[0]) + (c2[0]-c1[0]) - (c2[1]-c1[1])

def profiles(d):
    result = []
    for a in range(d+1):
        for b in range(d-a+1):
            c = d - a - b
            result.append((a, b, c))
    return result

# Compute P_n (polynomial) via EMD path formula
def compute_Pn_poly(target_c, n, profs, R):
    q = R.gen()
    if n == 0:
        return R(1)
    result = R(0)
    for c_prev in profs:
        P_prev = compute_Pn_poly(c_prev, n-1, profs, R)
        e = emd(target_c, c_prev)
        result += q**(n * e) * P_prev
    return result

# Compute Q_n correctly
def compute_Qn_correct(target_c, N, d, profs, prec=300):
    R2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = R2.gen()
    
    r = 3
    ell = gcd(d, r)
    
    # Compute P_m for m = 0..N
    Pm_list = []
    for m in range(N + 1):
        Pm = compute_Pn_poly(target_c, m, profs, R2)
        Pm_list.append(Pm)
        print(f"  P_{m}(1) = {Pm.polynomial()(1)}")
    
    # (q^3;q^3)_m
    def qpoch3(m):
        result = R2(1)
        for i in range(1, m+1):
            result *= (1 - q2**(3*i))
        return result
    
    # (q;q)_k
    def qpoch1(k):
        result = R2(1)
        for i in range(1, k+1):
            result *= (1 - q2**i)
        return result
    
    # (q^ell;q^ell)_n
    def qpoch_ell(n):
        result = R2(1)
        for i in range(1, n+1):
            result *= (1 - q2**(ell*i))
        return result
    
    # Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m F_m z^m)
    # [z^n] = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_j
    # F_j = P_j / (q^3;q^3)_j
    
    results = []
    for n in range(N + 1):
        s = R2(0)
        for j in range(n + 1):
            k = n - j
            sign = (-1)**k
            qpow = q2**(k*(k+1)//2)
            Fj = Pm_list[j] / qpoch3(j)  # power series
            s += sign * qpow / qpoch1(k) * Fj
        
        Qn = qpoch_ell(n) * s
        # This should be a polynomial (or at least have finitely many nonzero terms)
        Qn_trunc = Qn.add_bigoh(prec)
        Qn_poly = Qn_trunc.polynomial()
        
        print(f"\nQ_{n}({target_c}) = {Qn_poly}")
        print(f"  Q_{n}(1) = {Qn_poly(1)}")
        
        neg = [c for c in Qn_poly.coefficients() if c < 0]
        if neg:
            print(f"  *** NEGATIVE: {neg[:5]}")
        else:
            print(f"  All nonneg!")
        
        results.append(Qn_poly)
    
    return results

# d=2
print("=" * 60)
print("d=2, c=(1,1,0)")
print("=" * 60)
d = 2
profs = profiles(d)
c_target = (1, 1, 0)
Qn_list = compute_Qn_correct(c_target, 3, d, profs, prec=300)

# d=4
print("\n\n" + "=" * 60)
print("d=4, c=(2,1,1)")
print("=" * 60)
d = 4
profs4 = profiles(d)
c_target = (2, 1, 1)
Qn_list4 = compute_Qn_correct(c_target, 2, d, profs4, prec=300)

