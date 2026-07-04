"""Seed 4: Analyze degree bounds and structural patterns in Q_{n,c}(q)."""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed4_transfer_matrix import compute_F, multiply_series, qpoch_series, inverse_series
from math import gcd

def compute_Q_full(c_profile, n_max, prec):
    d = sum(c_profile); k = 3; l = gcd(d, k)
    F_bounded = {N: compute_F(c_profile, N, prec) for N in range(n_max + 1)}
    a = {0: list(F_bounded[0])}
    for N in range(1, n_max+1):
        a[N] = [F_bounded[N][i] - F_bounded[N-1][i] for i in range(prec)]
    euler = {}
    for m in range(n_max + 1):
        qp = qpoch_series(1, 1, m, prec)
        inv = inverse_series(qp, prec)
        shift = m * (m + 1) // 2; sign = (-1) ** m
        ec = [0] * prec
        for i in range(prec):
            if i + shift < prec: ec[i + shift] = sign * inv[i]
        euler[m] = ec
    Q = {0: [0]*prec}; Q[0][0] = 1
    for n in range(1, n_max + 1):
        zn = [0] * prec
        for j in range(n + 1):
            conv = multiply_series(euler[j], a[n-j], prec)
            for i in range(prec): zn[i] += conv[i]
        qpoch_ln = qpoch_series(l, l, n, prec)
        Q[n] = multiply_series(qpoch_ln, zn, prec)
    return Q

if __name__ == "__main__":
    for c_profile in [(1,1,0), (2,0,0), (2,1,1), (2,2,0)]:
        d = sum(c_profile)
        if d % 3 == 0: continue
        prec = max(80, 4 * d * 16)
        print(f"\nc = {c_profile}, d = {d}")
        Q = compute_Q_full(c_profile, 4, prec)
        for n in range(5):
            nz = [(i,Q[n][i]) for i in range(prec) if Q[n][i] != 0]
            if nz:
                mn = min(i for i,v in nz)
                mx = max(i for i,v in nz)
                neg = any(v < 0 for _,v in nz)
                print(f"  Q_{n}: deg [{mn}, {mx}], sum={sum(Q[n])}, #terms={len(nz)}, neg={neg}")
            else:
                print(f"  Q_{n}: empty")
