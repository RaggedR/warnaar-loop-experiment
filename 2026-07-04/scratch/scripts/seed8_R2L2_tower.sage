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
    """return first negative index or None"""
    for i in range(upto):
        if f[i] < 0:
            return i
    return None

def run(d, profiles, m_max, k_max, PREC):
    print("="*70)
    print("d = %d, m_max = %d, k_max = %d, PREC = %d" % (d, m_max, k_max, PREC))
    budget = 3*m_max*m_max + 60   # generous bound on total multiplier degree
    SAFE = PREC - budget
    print("safe check window: [0, %d)" % SAFE)
    all_ok = True
    for c in profiles:
        g_all, R, q = compute_gs(d, c, m_max, PREC)
        # brackets: f[k][m]; use dict
        f = {}
        for m in range(0, m_max+1):
            f[(-1, m)] = g_all[m]
        for k in range(0, k_max+1):
            for m in range(k+1, m_max+1):
                f[(k, m)] = (1-q**(m-k))*f[(k-1, m)] - q**(k+1)*f[(k-1, m-1)]
        # pochhammers
        poch = [R(1)]
        for i in range(1, m_max+2):
            poch.append(poch[-1]*(1-q**i))
        # sanity: D_{k+1}^m = poch[m-k-1]*f[(k,m)] vs direct tower from h
        D = {}
        for m in range(0, m_max+1):
            D[(0, m)] = poch[m]*g_all[m]
        for k in range(1, k_max+2):
            for m in range(k, m_max+1):
                D[(k, m)] = D[(k-1, m)] - q**k * D[(k-1, m-1)]
        sane = True
        for k in range(0, k_max+1):
            for m in range(k+1, m_max+1):
                diff = D[(k+1, m)] - poch[m-k-1]*f[(k, m)]
                if any(diff[i] != 0 for i in range(SAFE)):
                    sane = False
                    print("  SANITY FAIL c=%s k=%d m=%d" % (c, k, m))
        # MASTER check
        for k in range(-1, k_max+1):
            for m in range(k+1 if k >= 0 else 1, m_max+1):
                jmax = m - k - 1
                prod = f[(k, m)]
                for j in range(0, jmax+1):
                    if j > 0:
                        prod = prod*(1-q**j)
                    bad = check_nonneg(prod, SAFE)
                    if bad is not None:
                        all_ok = False
                        print("  MASTER FAIL d=%d c=%s k=%d m=%d j=%d first_neg_at=%d coeff=%s"
                              % (d, c, k, m, j, bad, prod[bad]))
                # exactness: j = m-k should fail (for k>=0; for k=-1 j=m+1)
                jx = jmax + 1
                prodx = prod*(1-q**jx)
                badx = check_nonneg(prodx, SAFE)
                exact = "EXACT" if badx is not None else "no-fail-at-j=%d" % jx
                print("  c=%s k=%2d m=%d: j=0..%d OK [sane=%s], boundary j=%d: %s"
                      % (c, k, m, jmax, sane, jx, exact))
        sys.stdout.flush()
    print("d=%d ALL MASTER CHECKS %s" % (d, "PASS" if all_ok else "***FAILURES***"))
    return all_ok

if True:
    import time
    t0 = time.time()
    which = sys.argv[1] if len(sys.argv) > 1 else 'small'
    if which == 'small':
        # d=2, all orbit reps, deep m
        run(2, [(2,0,0),(1,1,0)], 8, 4, 6*64+220)
        # d=4, all 5 orbit reps
        run(4, [(4,0,0),(3,1,0),(3,0,1),(2,2,0),(2,1,1)], 7, 4, 6*49+220)
    elif which == 'd5':
        run(5, [(5,0,0),(4,1,0),(4,0,1),(3,2,0),(3,0,2),(3,1,1),(2,2,1)], 6, 4, 6*36+220)
    elif which == 'd7':
        run(7, [(7,0,0),(6,1,0),(5,1,1),(4,2,1),(3,3,1),(3,2,2)], 5, 3, 6*25+220)
    print("elapsed: %.1fs" % (time.time()-t0))
