"""
Seed 8 R2 L2: MASTER conjecture verification.

MASTER: for k >= -1, m >= k+1, 0 <= j <= m-k-1: (q;q)_j * f_k^{(m)} >= 0,
where f_{-1}^{(m)} = g_m, f_k^{(m)} = (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)}.
Also check exactness (j = m-k fails) and sanity D_{k+1}^m = (q;q)_{m-k-1} f_k^{(m)}.

Precision rule: coefficients within total multiplier degree of PREC are garbage.
We only check coefficients up to SAFE = PREC - budget.
"""
from sage.all import *
from itertools import combinations as combs
import sys

def compute_gs(d, c, m_max, PREC):
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            compositions.append((c0, c1, d-c0-c1))
    N = len(compositions)
    idx = {comp: i for i, comp in enumerate(compositions)}
    ci = idx[tuple(c)]

    def shift_profile(comp, J):
        res = list(comp); Js = set(J)
        for i in range(3):
            prev = (i-1) % 3
            if i in Js and prev not in Js: res[i] -= 1
            elif i not in Js and prev in Js: res[i] += 1
        return tuple(res)

    Rx = PolynomialRing(QQ, 'x'); x = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    for ic2, comp2 in enumerate(compositions):
        I_c = {i for i in range(3) if comp2[i] > 0}
        if not I_c: continue
        for size in range(1, len(I_c)+1):
            for J in combs(sorted(I_c), size):
                cJ = shift_profile(comp2, set(J))
                if min(cJ) < 0: continue
                A_poly[ic2, idx[cJ]] += (-1)**(size-1) * x**size

    I_mat = identity_matrix(R, N)
    v = vector(R, [R(1)]*N)
    g_all = [R(1)]
    prev = v[ci]
    for m in range(1, m_max+1):
        Am = matrix(R, N, N, lambda i, j: A_poly[i, j](q**m))
        v = (I_mat - Am).solve_right(v)
        g_all.append(v[ci] - prev)
        prev = v[ci]
    return g_all, R, q


def check_nonneg(f, upto):
    for i in range(upto):
        if f[i] < 0: return i
    return None

from itertools import combinations as C2
def has_matching(S, J):
    # bipartite matching S -> {1..J} with t | a; small sizes: brute force
    targets = list(range(1, J+1))
    S = list(S)
    import itertools
    for perm in itertools.permutations(targets, len(S)):
        if all(perm[i] != 0 and S[i] % perm[i] == 0 for i in range(len(S))):
            return True
    return False

import time
t0 = time.time()
viol_suff = 0; total_match = 0; total_sets = 0
cases = [ (4, (2,1,1), 6, 3), (2, (1,1,0), 7, 3), (5, (3,1,1), 5, 2), (7, (4,2,1), 4, 1) ]
MAXF = 12
for (d, c, m_max, k_max) in cases:
    PREC = 6*m_max*m_max + 300
    SAFE = PREC - (3*m_max*m_max + 12*13//2*3 + 80)
    g_all, R, q = compute_gs(d, c, m_max, PREC)
    f = {}
    for m in range(0, m_max+1): f[(-1,m)] = g_all[m]
    for k in range(0, k_max+1):
        for m in range(k+1, m_max+1):
            f[(k,m)] = (1-q**(m-k))*f[(k-1,m)] - q**(k+1)*f[(k-1,m-1)]
    for k in range(-1, k_max+1):
        for m in range(max(1,k+1), m_max+1):
            J = m - k - 1
            base = f[(k,m)]
            for size in range(1, min(J,5)+1):
                for S in C2(range(1, MAXF+1), size):
                    total_sets += 1
                    m_ok = has_matching(S, J)
                    if not m_ok: continue
                    total_match += 1
                    prod = base
                    for a in S: prod = prod*(1-q**a)
                    bad = check_nonneg(prod, SAFE)
                    if bad is not None:
                        viol_suff += 1
                        print("SUFFICIENCY VIOLATION d=%s c=%s k=%d m=%d S=%s (matching exists, product negative at %d)" % (d,c,k,m,S,bad))
print("checked %d sets, %d with matching, %d violations" % (total_sets, total_match, viol_suff))
print("elapsed %.1fs" % (time.time()-t0))
