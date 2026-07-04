"""
Verify Warnaar's fermionic formula against direct computation of Q_n.

Key identity (if Warnaar's Conjecture 2 holds):

(zq;q)_inf * GK_c(z,q) = FERM(z,q)

=> Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n](FERM(z,q))

FERM(z,q) = sum_{n_1,...,n_k >= 0, m_1,...,m_{k-1} >= 0}
  z^{n_1} q^{exponent} / (q)_{n_1}
  * prod q-binomials

With n_1 = n, the (q;q)_n cancels:

Q_n = sum_{n_2,...,n_k >= 0, m_1,...,m_{k-1} >= 0}
  q^{exponent} * prod q-binomials

This is a MANIFESTLY POSITIVE multisum (all terms nonneg).
"""
from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qbinom(n_val, m_val):
    """q-binomial coefficient [n choose m]_q."""
    if m_val < 0 or m_val > n_val or n_val < 0:
        return R(0)
    if m_val == 0 or m_val == n_val:
        return R(1)
    result = R(1)
    for i in range(m_val):
        result *= (1 - q**(n_val - i)) / (1 - q**(i + 1))
    return result

def fermionic_Qn_mod3k2(k, s, n):
    """
    Q_n for profile (3k-s, s-1, 0) via fermionic formula.
    Modulus = 3k+2, d = 3k-1.
    
    Q_n = sum_{n_2,...,n_k, m_1,...,m_{k-1}}
      q^{n_k^2 + sum_{i=s}^k n_i + sum_{i=1}^{k-1}(n_i^2 - n_i*m_i + m_i^2 + m_i)}
      * prod_{i=1}^{k-1} [n_i choose n_{i+1}] * [n_i - n_{i+1} + m_{i+1} choose m_i]
    
    with n_1 = n, m_k = 2*n_k.
    """
    if k == 1:
        # No inner sum. Q_n = q^{n^2 + sum_{i=s}^1 n_i}
        if s <= 1:
            return q**(n**2 + n)
        else:
            return q**(n**2)
    
    result = R(0)
    n_list = [0] * (k + 1)  # 1-indexed: n_list[i] = n_i
    n_list[1] = n
    
    def enumerate_vars(idx):
        nonlocal result
        if idx > k:
            # n_i all set. Enumerate m_1,...,m_{k-1}
            m_list = [0] * (k + 1)
            m_list[k] = 2 * n_list[k]
            
            def enum_m(j):
                nonlocal result
                if j < 1:
                    # Compute term
                    exp = n_list[k]**2
                    for i in range(s, k + 1):
                        exp += n_list[i]
                    for i in range(1, k):
                        exp += n_list[i]**2 - n_list[i]*m_list[i] + m_list[i]**2 + m_list[i]
                    
                    if exp >= PREC:
                        return
                    
                    coeff = R(1)
                    for i in range(1, k):
                        coeff *= qbinom(n_list[i], n_list[i + 1])
                        coeff *= qbinom(n_list[i] - n_list[i + 1] + m_list[i + 1], m_list[i])
                    
                    result += q**exp * coeff
                    return
                
                upper = n_list[j] - n_list[j + 1] + m_list[j + 1]
                for mj in range(upper + 1):
                    m_list[j] = mj
                    enum_m(j - 1)
            
            enum_m(k - 1)
            return
        
        for ni in range(n_list[idx - 1] + 1):
            n_list[idx] = ni
            enumerate_vars(idx + 1)
    
    enumerate_vars(2)
    return result

def compute_Fcm(c, m, prec=PREC):
    """F_{c,m} via direct enumeration."""
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
    if m == 2:
        result = R(1)
        S = min(30, int(prec/2) + 1)
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

def compute_Qn_direct(c, n, prec=PREC):
    """Q_n from definition."""
    ell = gcd(sum(c), 3)
    F = {}
    for m in range(n + 1):
        F[m] = compute_Fcm(c, m, prec=prec)
        if F[m] is None:
            return None
    G = {0: F[0]}
    for m in range(1, n + 1):
        G[m] = F[m] - F[m - 1]
    
    result = R(0)
    for j in range(n + 1):
        m = n - j
        qfact = R(1)
        for i in range(1, j + 1):
            qfact *= (1 - q**i)
        result += (-1)**j * q**(j*(j+1)//2) * G[m] / qfact
    
    for i in range(1, n + 1):
        result *= (1 - q**(ell * i))
    return result

# ============================================================
# TEST: d=2, k=1
# ============================================================
print("=" * 60)
print("d=2, k=1 (modulus 5)")
print("=" * 60)

for s in [1, 2]:
    c = (3*1 - s, s - 1, 0)
    print(f"\ns={s}, c={c}:")
    Q1_ferm = fermionic_Qn_mod3k2(1, s, 1)
    Q1_dir = compute_Qn_direct(c, 1, prec=30)
    print(f"  Fermionic Q_1: {[Q1_ferm[i] for i in range(10)]}")
    print(f"  Direct Q_1:    {[Q1_dir[i] for i in range(10)]}")
    print(f"  Match: {[Q1_ferm[i] for i in range(10)] == [Q1_dir[i] for i in range(10)]}")

# ============================================================
# TEST: d=5, k=2 (modulus 8)
# ============================================================
print("\n" + "=" * 60)
print("d=5, k=2 (modulus 8)")
print("=" * 60)

for s in [1, 2, 3]:
    c = (3*2 - s, s - 1, 0)
    print(f"\ns={s}, c={c}:")
    
    Q1_ferm = fermionic_Qn_mod3k2(2, s, 1)
    Q1_dir = compute_Qn_direct(c, 1, prec=50)
    
    f_coeffs = [Q1_ferm[i] for i in range(15)]
    d_coeffs = [Q1_dir[i] for i in range(15)]
    print(f"  Fermionic Q_1: {f_coeffs}")
    print(f"  Direct Q_1:    {d_coeffs}")
    print(f"  Match: {f_coeffs == d_coeffs}")
    print(f"  Q_1(1) ferm={sum(f_coeffs)}, dir={sum(d_coeffs)}, expected={(5+1)*(5+2)//6-1}")

# n=2 for a profile
print("\n\nTesting n=2:")
c = (4, 1, 0)
Q2_ferm = fermionic_Qn_mod3k2(2, 2, 2)
Q2_dir = compute_Qn_direct(c, 2, prec=80)

f2 = [Q2_ferm[i] for i in range(25)]
d2 = [Q2_dir[i] for i in range(25)] if Q2_dir is not None else None
print(f"c={c}, n=2:")
print(f"  Ferm: {f2}")
if d2:
    print(f"  Dir:  {d2}")
    print(f"  Match: {f2 == d2}")
    print(f"  Q_2(1) ferm={sum(f2)}, dir={sum(d2)}, expected={(5+1)*(5+2)//6-1}**2={((5+1)*(5+2)//6-1)**2}")

