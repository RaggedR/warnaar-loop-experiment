# Correct Q_n computation using g_m (column-count parameterization)
# and key polynomial decomposition
from sage.all import *

PREC = 120
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm(c, m, prec=PREC):
    """g_m for profile c at max=m using column-count parameterization."""
    k = len(c)
    result = R(0)
    if m == 0:
        return R(1)
    if m == 1:
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
        for a0 in range(prec // 2):
            for a1 in range(min(a0 + c[1] + 1, prec // 2)):
                for a2 in range(min(a1 + c[2] + 1, prec // 2)):
                    if a0 <= a2 + c[0]:
                        for b0 in range(min(a0 + 1, prec // 2)):
                            for b1 in range(min(b0 + c[1] + 1, a1 + 1, prec // 2)):
                                for b2 in range(min(b1 + c[2] + 1, a2 + 1, prec // 2)):
                                    if b0 <= b2 + c[0] and max(b0, b1, b2) >= 1:
                                        total = a0+a1+a2+b0+b1+b2
                                        if total < prec:
                                            result += q**total
        return result
    return None

def compute_Qn_directly(c, N, prec=PREC):
    """Compute Q_n for n=0..N using g_m and the formula:
    Q_n = (q;q)_n * sum_{j+k=n} (-1)^k q^{k(k+1)/2} / (q;q)_k * g_j"""
    d = sum(c)
    ell = gcd(d, 3)
    
    gm = {}
    for m in range(N + 1):
        gm[m] = compute_gm(c, m, prec)
        if gm[m] is None:
            print(f"  g_{m} computation not supported for m={m}")
            return None
    
    results = []
    for n in range(N + 1):
        # [z^n] = sum_{j=0}^n g_j * (-1)^{n-j} * q^{(n-j)(n-j+1)/2} / (q;q)_{n-j}
        zn = R(0)
        for j in range(n + 1):
            k = n - j
            sign = (-1)**k
            qpow = q**(k*(k+1)//2)
            denom = R(1)
            for i in range(1, k+1):
                denom *= (1 - q**i)
            zn += sign * qpow / denom * gm[j]
        
        # Q_n = (q^ell;q^ell)_n * zn
        qell_n = R(1)
        for i in range(1, n+1):
            qell_n *= (1 - q**(ell*i))
        
        Qn = qell_n * zn
        # Extract polynomial part (should stabilize)
        Qn_poly_coeffs = [Qn[i] for i in range(prec)]
        # Find where it becomes zero
        last_nonzero = 0
        for i in range(prec-1, -1, -1):
            if Qn_poly_coeffs[i] != 0:
                last_nonzero = i
                break
        
        poly_coeffs = Qn_poly_coeffs[:last_nonzero+1]
        results.append(poly_coeffs)
        
        # Check if polynomial (tail is zero)
        tail = [Qn_poly_coeffs[i] for i in range(last_nonzero+1, min(last_nonzero+20, prec))]
        is_poly = all(t == 0 for t in tail)
        
        neg = [c for c in poly_coeffs if c < 0]
        eval1 = sum(poly_coeffs)
        
        print(f"  Q_{n}: deg={last_nonzero}, Q(1)={eval1}, polynomial={is_poly}, neg={'YES' if neg else 'no'}")
        if last_nonzero <= 30:
            print(f"    coeffs = {poly_coeffs}")
    
    return results

# d=4, c=(2,1,1) - the standard test case
print("=" * 60)
print("d=4, c=(2,1,1)")
print("=" * 60)
c = (2, 1, 1)
Q_d4 = compute_Qn_directly(c, 2, prec=100)

# d=4, c=(1,1,2)  
print("\n" + "=" * 60)
print("d=4, c=(1,1,2)")
print("=" * 60)
c = (1, 1, 2)
Q_d4b = compute_Qn_directly(c, 2, prec=100)

# d=2, c=(1,1,0)
print("\n" + "=" * 60)
print("d=2, c=(1,1,0)")
print("=" * 60)
c = (1, 1, 0)
Q_d2 = compute_Qn_directly(c, 2, prec=80)

# d=5, c=(2,2,1)
print("\n" + "=" * 60)
print("d=5, c=(2,2,1)")
print("=" * 60)
c = (2, 2, 1)
Q_d5 = compute_Qn_directly(c, 2, prec=100)

