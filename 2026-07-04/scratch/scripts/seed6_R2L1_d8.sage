"""Test d=8, k=3 (modulus 11) — FIRST UNPROVED CASE."""
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

def fermionic_Qn(k, s, n, balanced=False):
    """Fermionic Q_n. If balanced, use (k,k,k-1) formula (no +m_i, no +n_i shift)."""
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
                    if not balanced:
                        for i in range(s, k + 1):
                            exp += n_list[i]
                    for i in range(1, k):
                        exp += n_list[i]**2 - n_list[i]*m_list[i] + m_list[i]**2
                        if not balanced:
                            exp += m_list[i]
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
    return None

def compute_Qn_direct(c, n_val, prec=PREC):
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

# d=8, k=3 profiles (3k-s, s-1, 0)
print("d=8, k=3 (modulus 11)")
print("=" * 60)

for s in [1, 2, 3, 4]:
    c = (9 - s, s - 1, 0)
    print(f"\ns={s}, c={c}:")
    Q1_ferm = fermionic_Qn(3, s, 1)
    Q1_dir = compute_Qn_direct(c, 1, prec=60)
    
    f1 = [Q1_ferm[i] for i in range(25)]
    d1 = [Q1_dir[i] for i in range(25)]
    print(f"  Ferm: {f1}")
    print(f"  Dir:  {d1}")
    print(f"  Match: {f1 == d1}")
    exp_val = (8+1)*(8+2)//6 - 1  # = 14
    print(f"  Q_1(1): ferm={sum(f1)}, dir={sum(d1)}, expected={exp_val}")

# Balanced k=3: (3,3,2), d=8
c = (3, 3, 2)
print(f"\nBalanced c={c}:")
Q1_ferm = fermionic_Qn(3, 0, 1, balanced=True)
Q1_dir = compute_Qn_direct(c, 1, prec=60)
f1 = [Q1_ferm[i] for i in range(25)]
d1 = [Q1_dir[i] for i in range(25)]
print(f"  Ferm: {f1}")
print(f"  Dir:  {d1}")
print(f"  Match: {f1 == d1}")

