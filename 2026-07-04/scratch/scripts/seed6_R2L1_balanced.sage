"""
Test the balanced profile (k,k,k-1) fermionic formula.
For k=2: c = (2,2,1), d=5. Warnaar's Conjecture 2 gives:

GK_{(k,k,k-1)}(z,q) = 1/(zq;q)_inf * sum z^{n_1} q^{n_k^2} / (q)_{n_1}
  * prod_{i=1}^{k-1} q^{n_i^2 - n_i*m_i + m_i^2} [n_i;n_{i+1}] [n_i-n_{i+1}+m_{i+1};m_i]

Note: the balanced case has NO +m_i term in the exponent, and NO +sum n_i shift.
Compared to the (3k-s,s-1,0) case which has +m_i and +sum_{i=s}^k n_i.

So Q_n for balanced profile (k,k,k-1):
Q_n = sum_{n_2,...,n_k, m_1,...,m_{k-1}}
  q^{n_k^2 + sum_{i=1}^{k-1}(n_i^2 - n_i*m_i + m_i^2)}
  * prod [n_i;n_{i+1}] [n_i-n_{i+1}+m_{i+1};m_i]

with n_1=n, m_k=2*n_k.
"""
from sage.all import *

PREC = 200
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qbinom(n_val, m_val):
    if m_val < 0 or m_val > n_val or n_val < 0:
        return R(0)
    if m_val == 0 or m_val == n_val:
        return R(1)
    result = R(1)
    for i in range(m_val):
        result *= (1 - q**(n_val - i)) / (1 - q**(i + 1))
    return result

def fermionic_Qn_balanced(k, n):
    """Q_n for balanced profile (k,k,k-1) via fermionic formula."""
    if k == 1:
        # c = (1,1,0), d=2. n_1=n, m_k=2n. Exponent = n^2. No prod.
        return q**(n**2)
    
    result = R(0)
    n_list = [0] * (k + 1)
    n_list[1] = n
    
    def enumerate_vars(idx):
        nonlocal result
        if idx > k:
            m_list = [0] * (k + 1)
            m_list[k] = 2 * n_list[k]
            
            def enum_m(j):
                nonlocal result
                if j < 1:
                    exp = n_list[k]**2
                    for i in range(1, k):
                        exp += n_list[i]**2 - n_list[i]*m_list[i] + m_list[i]**2
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
# Test balanced profiles
# ============================================================
print("Balanced profile tests")
print("=" * 60)

# k=1: c=(1,1,0), d=2
c = (1, 1, 0)
Q1_ferm = fermionic_Qn_balanced(1, 1)
Q1_dir = compute_Qn_direct(c, 1, prec=30)
print(f"k=1, c={c}: ferm={[Q1_ferm[i] for i in range(10)]}, dir={[Q1_dir[i] for i in range(10)]}, match={[Q1_ferm[i] for i in range(8)] == [Q1_dir[i] for i in range(8)]}")

# k=2: c=(2,2,1), d=5
c = (2, 2, 1)
Q1_ferm = fermionic_Qn_balanced(2, 1)
Q1_dir = compute_Qn_direct(c, 1, prec=30)
print(f"k=2, c={c}: ferm={[Q1_ferm[i] for i in range(12)]}, dir={[Q1_dir[i] for i in range(12)]}, match={[Q1_ferm[i] for i in range(10)] == [Q1_dir[i] for i in range(10)]}")

Q2_ferm = fermionic_Qn_balanced(2, 2)
Q2_dir = compute_Qn_direct(c, 2, prec=60)
if Q2_dir is not None:
    f2 = [Q2_ferm[i] for i in range(20)]
    d2 = [Q2_dir[i] for i in range(20)]
    print(f"k=2, n=2: ferm={f2}, dir={d2}, match={f2==d2}")

# ============================================================
# Now the BIG test: d=8, k=3 (modulus 11)
# This is the FIRST UNPROVED case!
# ============================================================
print("\n" + "=" * 60)
print("d=8, k=3 (modulus 11) — UNPROVED")
print("=" * 60)

# Profiles: (3k-s, s-1, 0) = (9-s, s-1, 0) for s=1,...,4
for s in [1, 2, 3, 4]:
    c = (3*3 - s, s - 1, 0)
    print(f"\ns={s}, c={c}, d={sum(c)}:")
    
    Q1_ferm = fermionic_Qn_mod3k2_general(3, s, 1)
    Q1_dir = compute_Qn_direct(c, 1, prec=40)
    
    f1 = [Q1_ferm[i] for i in range(20)]
    d1 = [Q1_dir[i] for i in range(20)]
    print(f"  Ferm Q_1: {f1}")
    print(f"  Dir Q_1:  {d1}")
    print(f"  Match: {f1 == d1}")
    print(f"  Q_1(1): ferm={sum(f1)}, dir={sum(d1)}, expected={(8+1)*(8+2)//6-1}")

def fermionic_Qn_mod3k2_general(k, s, n):
    """General version for modulus 3k+2."""
    result = R(0)
    n_list = [0] * (k + 1)
    n_list[1] = n
    
    def enumerate_vars(idx):
        nonlocal result
        if idx > k:
            m_list = [0] * (k + 1)
            m_list[k] = 2 * n_list[k]
            def enum_m(j):
                nonlocal result
                if j < 1:
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

# Run the test again with the function defined before use
print("\n" + "=" * 60)
print("d=8, k=3 (modulus 11) — RERUN")
print("=" * 60)

for s in [1, 2, 3, 4]:
    c = (3*3 - s, s - 1, 0)
    print(f"\ns={s}, c={c}, d={sum(c)}:")
    
    Q1_ferm = fermionic_Qn_mod3k2_general(3, s, 1)
    Q1_dir = compute_Qn_direct(c, 1, prec=40)
    
    f1 = [Q1_ferm[i] for i in range(20)]
    d1 = [Q1_dir[i] for i in range(20)]
    print(f"  Ferm Q_1: {f1}")
    print(f"  Dir Q_1:  {d1}")
    print(f"  Match: {f1 == d1}")
    exp_val = (8+1)*(8+2)//6 - 1
    print(f"  Q_1(1): ferm={sum(f1)}, dir={sum(d1)}, expected={exp_val}")

# Balanced for k=3: c=(3,3,2), d=8
c = (3, 3, 2)
Q1_ferm = fermionic_Qn_balanced(3, 1)
Q1_dir = compute_Qn_direct(c, 1, prec=40)
f1 = [Q1_ferm[i] for i in range(20)]
d1 = [Q1_dir[i] for i in range(20)]
print(f"\nBalanced k=3, c={c}:")
print(f"  Ferm: {f1}")
print(f"  Dir:  {d1}")
print(f"  Match: {f1 == d1}")

