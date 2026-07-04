"""
Seed 6, Round 2, Layer 1: Verify Warnaar's fermionic formula for Q_n.

For d = 3k-1 (mod 3k+2 case), profile c = (3k-s, s-1, 0):

GK_c(z,q) = 1/(zq;q)_inf * sum_{n_1,...,n_k >= 0, m_1,...,m_{k-1} >= 0}
  z^{n_1} q^{n_k^2 + sum_{i=s}^k n_i} / (q)_{n_1}
  * prod_{i=1}^{k-1} q^{n_i^2 - n_i*m_i + m_i^2 + m_i} [n_i;n_{i+1}] [n_i-n_{i+1}+m_{i+1};m_i]

Then Q_{n,c}(q) = (q;q)_n * [z^n](FERM) where (q;q)_n cancels 1/(q)_{n_1=n}.

So Q_n = sum_{n_2,...,n_k >= 0, m_1,...,m_{k-1} >= 0}
  q^{n_k^2 + sum_{i=s}^k n_i}
  * prod_{i=1}^{k-1} q^{n_i^2 - n_i*m_i + m_i^2 + m_i} [n_i;n_{i+1}] [n_i-n_{i+1}+m_{i+1};m_i]

with n_1 = n, m_k = 2*n_k.
"""

from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qbinom(n, m, q_var=q):
    """q-binomial [n choose m]_q. Returns 0 if m < 0 or m > n."""
    if m < 0 or m > n:
        return R(0)
    if m == 0 or m == n:
        return R(1)
    result = R(1)
    for i in range(m):
        result *= (1 - q_var**(n - i)) / (1 - q_var**(i + 1))
    return result

def qpoch(a, n):
    """(a;q)_n = prod_{i=0}^{n-1} (1 - a*q^i)"""
    result = R(1)
    for i in range(n):
        result *= (1 - a * q**i)
    return result

def fermionic_Qn(k, s, n):
    """
    Compute Q_n for profile (3k-s, s-1, 0) using the fermionic multisum.
    d = 3k-1, modulus = 3k+2.
    
    n_1 = n (fixed by z^n extraction, (q;q)_n cancels).
    n_2,...,n_k >= 0 with n_i >= n_{i+1} (from q-binomial constraint)
    m_1,...,m_{k-1} >= 0 with m_i <= n_i - n_{i+1} + m_{i+1} (from q-binomial)
    m_k := 2*n_k.
    
    Exponent: n_k^2 + sum_{i=s}^k n_i + sum_{i=1}^{k-1} (n_i^2 - n_i*m_i + m_i^2 + m_i)
    """
    if k == 1:
        # Only n_1 = n, m_k = 2*n_k = 2*n_1 = 2n. No inner sum variables.
        # Q_n = q^{n^2 + n} (if s=1) or q^{n^2} (if s=2, but s <= k+1=2)
        # Wait: for k=1, the product is empty (i goes 1 to k-1=0).
        # So Q_n = q^{n_1^2 + sum_{i=s}^1 n_i} = q^{n^2 + n} if s=1, q^{n^2} if s=2.
        # BUT WAIT: Warnaar says s ranges 1 <= s <= k+1 = 2.
        # For s=1: sum_{i=1}^1 n_i = n. Q_n = q^{n^2 + n}.
        # For s=2: sum_{i=2}^1 n_i = 0. Q_n = q^{n^2}.
        # WRONG: This gives a monomial, but Q_n should be a polynomial with Q_n(1) = 4.
        # 
        # I think I'm missing something. Let me re-examine.
        # 
        # Actually for k=1, d = 3*1-1 = 2. Profile (3-s, s-1, 0).
        # s=1: profile (2, 0, 0). s=2: profile (1, 0, 0)... but d=2 needs c_0+c_1+c_2=2.
        # s=1: (2,0,0). s=2: (1,1,0).
        # 
        # Q_n(1) = ((2+1)(2+2)/6 - 1)^n = (12/6 - 1)^n = 1^n = 1. Hmm that seems low.
        # Wait: d=2, so (d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 2-1 = 1. So Q_n(1) = 1^n = 1.
        # That means Q_n is either 0 (impossible since Q_0 = 1) or just 1 for n=0 and 
        # a single monomial for n >= 1.
        # Actually for d=2: Q_1(1) = 1. So Q_1 = q^a for some a.
        # For s=1 (profile (2,0,0)): Q_1 = q^{1+1} = q^2? Let me check.
        # For s=2 (profile (1,1,0)): Q_1 = q^1 = q?
        # Need to verify this against direct computation.
        if s == 1:
            return q**(n**2 + n)
        else:
            return q**(n**2)
    
    # General k >= 2
    result = R(0)
    n_vals = [0] * (k + 1)  # n_1,...,n_k (1-indexed in n_vals[1],...,n_vals[k])
    n_vals[1] = n
    
    # Recursive enumeration of n_2,...,n_k and m_1,...,m_{k-1}
    # Constraint: 0 <= n_{i+1} <= n_i (from q-binomial [n_i choose n_{i+1}])
    
    def recurse(idx):
        """Enumerate n_{idx}, ..., n_k, then m_1,...,m_{k-1}"""
        nonlocal result
        if idx > k:
            # All n_i are set. Now enumerate m_1,...,m_{k-1}.
            m_vals = [0] * (k + 1)  # m_1,...,m_{k-1}, m_k = 2*n_k
            m_vals[k] = 2 * n_vals[k]
            
            def enum_m(j):
                nonlocal result
                if j < 1:
                    # All m values set. Compute the term.
                    # Exponent part
                    exp_val = n_vals[k]**2
                    for i in range(s, k+1):
                        exp_val += n_vals[i]
                    for i in range(1, k):
                        exp_val += n_vals[i]**2 - n_vals[i]*m_vals[i] + m_vals[i]**2 + m_vals[i]
                    
                    # q-binomial part
                    coeff = R(1)
                    for i in range(1, k):
                        coeff *= qbinom(n_vals[i], n_vals[i+1])
                        coeff *= qbinom(n_vals[i] - n_vals[i+1] + m_vals[i+1], m_vals[i])
                    
                    if coeff != 0 and exp_val < PREC:
                        result += q**exp_val * coeff
                    return
                
                # m_j ranges: need n_j - n_{j+1} + m_{j+1} >= m_j >= 0
                upper = n_vals[j] - n_vals[j+1] + m_vals[j+1]
                for mj in range(max(0, 0), upper + 1):
                    m_vals[j] = mj
                    enum_m(j - 1)
            
            enum_m(k - 1)
            return
        
        # n_{idx} ranges from 0 to n_{idx-1}
        for ni in range(n_vals[idx - 1] + 1):
            n_vals[idx] = ni
            recurse(idx + 1)
    
    recurse(2)
    return result


# ============================================================
# ALSO: compute Q_n from the CW recurrence (direct enumeration)
# ============================================================

def compute_gm(c, m, prec=PREC):
    """Compute g_m = F_{c,m} = sum over CPs with max <= m of q^size.
    Uses direct enumeration via column counts at each height."""
    k_parts = len(c)
    if m == 0:
        return R(1)
    
    if m > 3:
        print(f"  Warning: m={m} too large for direct enumeration")
        return None
    
    # For each height h = 1,...,m, we have (s_0^h, s_1^h, s_2^h)
    # with s_{(i+1)%3}^h <= s_i^h + c_{(i+1)%3}
    # and s_i^h >= s_i^{h+1} (decreasing in height)
    # At least one s_i^m >= 1 (max = m requires some part >= m)
    
    # Actually, F_{c,m} counts CPs with max ENTRY at most m.
    # We DON'T require max = m. So it includes max < m too.
    
    # Bound: s_i^1 < prec (since each contributes s_i to total size)
    S = int(prec // m) + 1  # max value of any s
    
    if m == 1:
        result = R(0)
        for s0 in range(S):
            for s1 in range(min(s0 + c[1] + 1, S)):
                for s2 in range(min(s1 + c[2] + 1, S)):
                    if s0 <= s2 + c[0]:
                        total = s0 + s1 + s2
                        if total < prec:
                            result += q**total
        return result
    
    if m == 2:
        result = R(0)
        S2 = min(S, int(prec // 2) + 1)
        for a0 in range(S2):
            for a1 in range(min(a0 + c[1] + 1, S2)):
                for a2 in range(min(a1 + c[2] + 1, S2)):
                    if a0 <= a2 + c[0]:
                        for b0 in range(min(a0 + 1, S2)):
                            for b1 in range(min(b0 + c[1] + 1, a1 + 1, S2)):
                                for b2 in range(min(b1 + c[2] + 1, a2 + 1, S2)):
                                    if b0 <= b2 + c[0]:
                                        total = a0+a1+a2+b0+b1+b2
                                        if total < prec:
                                            result += q**total
        return result
    
    return None

def compute_Qn_direct(c, n, prec=PREC):
    """Compute Q_n from the definition using direct g_m computation."""
    # Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m z^m g_m)
    # (zq;q)_inf = sum_j z^j (-1)^j q^{j(j+1)/2} / (q;q)_j
    # [z^n] of product = sum_{m+j=n, m>=0, j>=0} g_m * (-1)^j q^{j(j+1)/2} / (q;q)_j
    
    ell = gcd(sum(c), 3)
    result = R(0)
    for j in range(n + 1):
        m = n - j
        gm = compute_gm(c, m, prec=prec)
        if gm is None:
            print(f"  Cannot compute g_{m}")
            return None
        sign = (-1)**j
        coeff = sign * q**(j*(j+1)//2)
        # Divide by (q;q)_j
        denom = R(1)
        for i in range(1, j + 1):
            denom *= (1 - q**i)
        result += coeff * gm / denom
    
    # Multiply by (q^ell;q^ell)_n
    for i in range(1, n + 1):
        result *= (1 - q**(ell * i))
    
    return result

# ============================================================
# TEST 1: d=2, k=1
# ============================================================
print("=" * 60)
print("TEST 1: d=2, k=1 (Warnaar proved)")
print("=" * 60)

# s=1: profile (2,0,0)
print("\nProfile (2,0,0) [s=1]:")
Q1_ferm = fermionic_Qn(1, 1, 1)
print(f"  Fermionic Q_1 = {Q1_ferm}")
Q1_direct = compute_Qn_direct((2, 0, 0), 1, prec=30)
print(f"  Direct Q_1 = {Q1_direct}")

# s=2: profile (1,1,0)  
print("\nProfile (1,1,0) [s=2]:")
Q1_ferm2 = fermionic_Qn(1, 2, 1)
print(f"  Fermionic Q_1 = {Q1_ferm2}")
Q1_direct2 = compute_Qn_direct((1, 1, 0), 1, prec=30)
print(f"  Direct Q_1 = {Q1_direct2}")

# ============================================================
# TEST 2: d=5, k=2 (mod 8 case)
# ============================================================
print("\n" + "=" * 60)
print("TEST 2: d=5, k=2 (modulus 8, Warnaar proved)")
print("=" * 60)

# s=1: profile (5,0,0). s=2: profile (4,1,0). s=3: profile (3,2,0).
for s in [1, 2, 3]:
    c = (3*2-s, s-1, 0)
    print(f"\nProfile {c} [s={s}]:")
    Q1_ferm = fermionic_Qn(2, s, 1)
    Q1_direct = compute_Qn_direct(c, 1, prec=50)
    
    ferm_coeffs = [Q1_ferm[i] for i in range(30)]
    dir_coeffs = [Q1_direct[i] for i in range(30)]
    
    print(f"  Fermionic Q_1 coeffs: {ferm_coeffs[:15]}")
    print(f"  Direct Q_1 coeffs:    {dir_coeffs[:15]}")
    print(f"  Match: {ferm_coeffs[:15] == dir_coeffs[:15]}")
    print(f"  Q_1(1) fermionic: {sum(ferm_coeffs)}")
    print(f"  Q_1(1) direct:    {sum(dir_coeffs)}")
    expected = (5+1)*(5+2)//6 - 1
    print(f"  Expected Q_1(1):  {expected}")

# ============================================================
# TEST 3: d=4, k=2 (mod 7, from 3k+1=7 case)
# ============================================================
print("\n" + "=" * 60)
print("TEST 3: d=4, k=2 (modulus 7, 3k+1 case)")
print("=" * 60)
# The 3k+1 case has d = 3k-2. For k=2: d=4. Modulus = 3k+1 = 7.
# Conjecture 5 (3k+1 case) profiles are different. Let me check the formula.
# Need to look up the 3k+1 version...
# For now, let me just compute Q_n directly for d=4 profiles.

for c in [(2,1,1), (3,1,0), (4,0,0), (2,2,0), (1,2,1)]:
    Q1 = compute_Qn_direct(c, 1, prec=40)
    if Q1 is not None:
        coeffs = [Q1[i] for i in range(20)]
        print(f"\n  c={c}: Q_1 coeffs = {coeffs[:15]}, sum = {sum(coeffs)}")
        neg = [i for i in range(20) if Q1[i] < 0]
        if neg:
            print(f"  NEGATIVE at positions: {neg}")
        else:
            print(f"  All nonneg: YES")

