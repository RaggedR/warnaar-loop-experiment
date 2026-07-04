# Investigate the inductive structure of Q_n
# From the synthesis: Q_n uses a recurrence involving Q_{n-1} and Q_{n-2}
# Also: D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}, with Q_n = D_n^n

# Key observation for d=2: Q_n = q^{n^2}?? Let me verify.
# Q_0 = 1, Q_1 = q, Q_2 = q^4
# n^2: 0, 1, 4. YES!
# Let me check Q_3.

from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm(c, m, prec=PREC):
    """g_m for profile c with column-count parameterization."""
    k = len(c)
    result = R(0)
    if m == 0:
        return R(1)
    
    # For m >= 1, use recursive column-count approach
    # State at each height h: (s0, s1, s2) with interlacing
    # For m layers, use transfer matrix
    
    # For m=1: single layer
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
        for a0 in range(prec // 3):
            for a1 in range(min(a0 + c[1] + 1, prec // 3)):
                for a2 in range(min(a1 + c[2] + 1, prec // 3)):
                    if a0 <= a2 + c[0]:
                        for b0 in range(min(a0 + 1, prec // 3)):
                            for b1 in range(min(b0 + c[1] + 1, a1 + 1, prec // 3)):
                                for b2 in range(min(b1 + c[2] + 1, a2 + 1, prec // 3)):
                                    if b0 <= b2 + c[0] and max(b0, b1, b2) >= 1:
                                        total = a0+a1+a2+b0+b1+b2
                                        if total < prec:
                                            result += q**total
        return result
    
    if m == 3:
        lim = prec // 4
        for a0 in range(lim):
            for a1 in range(min(a0 + c[1] + 1, lim)):
                for a2 in range(min(a1 + c[2] + 1, lim)):
                    if a0 > a2 + c[0]: continue
                    for b0 in range(min(a0 + 1, lim)):
                        for b1 in range(min(b0 + c[1] + 1, a1 + 1, lim)):
                            for b2 in range(min(b1 + c[2] + 1, a2 + 1, lim)):
                                if b0 > b2 + c[0]: continue
                                for c0 in range(min(b0 + 1, lim)):
                                    for c1_v in range(min(c0 + c[1] + 1, b1 + 1, lim)):
                                        for c2 in range(min(c1_v + c[2] + 1, b2 + 1, lim)):
                                            if c0 <= c2 + c[0] and max(c0, c1_v, c2) >= 1:
                                                total = a0+a1+a2+b0+b1+b2+c0+c1_v+c2
                                                if total < prec:
                                                    result += q**total
        return result
    
    return None

def compute_Qn(c, N, prec=PREC):
    d = sum(c); ell = gcd(d, 3)
    gm = {}
    for m in range(N + 1):
        gm[m] = compute_gm(c, m, prec)
        if gm[m] is None:
            return None
    
    results = []
    for n in range(N + 1):
        zn = R(0)
        for j in range(n + 1):
            k = n - j
            sign = (-1)**k
            qpow = q**(k*(k+1)//2)
            denom = R(1)
            for i in range(1, k+1):
                denom *= (1 - q**i)
            zn += sign * qpow / denom * gm[j]
        
        qell_n = R(1)
        for i in range(1, n+1):
            qell_n *= (1 - q**(ell*i))
        
        Qn = qell_n * zn
        # Extract polynomial
        coeffs = [Qn[i] for i in range(prec)]
        last = 0
        for i in range(prec-1, -1, -1):
            if coeffs[i] != 0: last = i; break
        
        poly = coeffs[:last+1]
        results.append(poly)
        
        neg = [c for c in poly if c < 0]
        print(f"  Q_{n}(c={c}): deg={last}, Q(1)={sum(poly)}, neg={'YES' if neg else 'no'}")
        if last <= 40:
            print(f"    = {poly}")
    
    return results

# d=2, c=(1,1,0) -- checking Q_3
print("=== d=2, c=(1,1,0) ===")
c = (1, 1, 0)
Q_d2 = compute_Qn(c, 3, prec=80)

# d=4, various profiles
print("\n=== d=4, c=(2,1,1) ===")
c = (2, 1, 1)
Q_d4_211 = compute_Qn(c, 2, prec=60)

print("\n=== d=4, c=(4,0,0) ===")
c = (4, 0, 0)
Q_d4_400 = compute_Qn(c, 2, prec=60)

print("\n=== d=4, c=(2,2,0) ===")
c = (2, 2, 0)
Q_d4_220 = compute_Qn(c, 2, prec=60)

