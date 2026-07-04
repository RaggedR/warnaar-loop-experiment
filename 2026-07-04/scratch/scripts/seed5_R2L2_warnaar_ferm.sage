"""
Seed 5 R2 L2 — Plan B: Warnaar's Conjecture 2 fermionic Q_n vs CW ground truth (JSON),
d=8 (k=3), covered profiles (8,0,0),(7,1,0),(6,2,0),(5,3,0) [s=1..4] and balanced (3,3,2),
n = 1..4.  Fermionic formula from warnaar chunk_021 (Con_cylindric):

  covered:  Q_n = sum_{n_2..n_k, m_1..m_{k-1}} q^{n_k^2 + sum_{i=s}^k n_i
                    + sum_{i<k}(n_i^2 - n_i m_i + m_i^2 + m_i)} prod [n_i;n_{i+1}][n_i-n_{i+1}+m_{i+1};m_i]
  balanced: same without the '+m_i' and without linear n_i terms.
  n_1 = n, m_k = 2 n_k.
"""
from sage.all import *
import json

PREC = 300
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()
K = 3

def qbinom(nv, mv):
    if mv < 0 or mv > nv or nv < 0:
        return R(0)
    num, den = R(1), R(1)
    for i in range(mv):
        num *= 1 - q**(nv - i)
        den *= 1 - q**(i + 1)
    return num * (den**(-1))

def ferm_Qn(k, n, s=None, balanced=False):
    """s=None+balanced=True: balanced profile; else profile (3k-s,s-1,0)."""
    result = R(0)
    n_list = [0] * (k + 1)
    n_list[1] = n
    def enum_n(idx):
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
                        coeff *= qbinom(n_list[i], n_list[i+1])
                        coeff *= qbinom(n_list[i] - n_list[i+1] + m_list[i+1], m_list[i])
                    result += q**exp * coeff
                    return
                upper = n_list[j] - n_list[j+1] + m_list[j+1]
                for mj in range(upper + 1):
                    m_list[j] = mj
                    enum_m(j - 1)
            enum_m(k - 1)
            return
        for ni in range(n_list[idx-1] + 1):
            n_list[idx] = ni
            enum_n(idx + 1)
    enum_n(2)
    return result

with open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json') as f:
    QN = json.load(f)

def check(c, n, ferm):
    key = f"{c}|{n}"
    truth = QN[key]
    fc = [ferm[i] for i in range(PREC - 10)]
    tc = truth + [0]*(PREC - 10 - len(truth))
    ok = fc == tc[:len(fc)]
    print(f"  c={c} n={n}: match={ok}  deg_truth={len(truth)-1}")
    return ok

allok = True
for s in range(1, K + 2):
    c = (3*K - s, s - 1, 0)
    print(f"s={s}, c={c}:")
    for n in range(1, 5):
        allok &= check(c, n, ferm_Qn(K, n, s=s))

c = (K, K, K - 1)
print(f"balanced c={c}:")
for n in range(1, 5):
    allok &= check(c, n, ferm_Qn(K, n, balanced=True))

print(f"\nALL WARNAAR k=3 FERMIONIC CHECKS (n=1..4): {allok}")
