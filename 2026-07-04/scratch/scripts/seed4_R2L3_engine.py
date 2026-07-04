#!/usr/bin/env python3
"""Seed 4, Round 2, Layer 3 - engine.

Exact Z[q] arithmetic. Verifies:
  (V0) H-recursion produces exact polynomials (division by 1+q^m+q^{2m} exact).
  (V1) brute-force spot check: (q;q)_m F_{c,m} == H_{c,m} mod q^N for m<=2.
  (V2) Identity T1: N_2(c) = sum_{c'!=c} q^{2EMD(c',c)} H_1(c') + (q+q^3+q^5)
                    - (q+q^2+q^3+q^4+q^5) H_1(c).
  (V3) Identity T2 split + lemmas L-ball, L-harnack.
Polynomials = list of int coefficients, index = exponent.
"""
import sys

def ptrim(p):
    while p and p[-1] == 0: p.pop()
    return p

def padd(a, b, sa=1, sb=1):
    n = max(len(a), len(b))
    r = [0]*n
    for i, x in enumerate(a): r[i] += sa*x
    for i, x in enumerate(b): r[i] += sb*x
    return ptrim(r)

def pshift(a, k):
    return [0]*k + list(a)

def pmul(a, b):
    if not a or not b: return []
    r = [0]*(len(a)+len(b)-1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                r[i+j] += x*y
    return ptrim(r)

def pdiv_exact(num, den):
    num = list(num); r = []
    if not ptrim(list(num)): return []
    dd = len(den)-1; dl = den[-1]
    for i in range(len(num)-1-dd, -1, -1):
        c = num[i+dd]
        if c % dl != 0: raise ValueError("non-exact division")
        c //= dl
        if c:
            for j, y in enumerate(den):
                num[i+j] -= c*y
        r.append(c)
    if any(num): raise ValueError("nonzero remainder")
    r.reverse()
    return ptrim(r)

def pneg_ok(p):
    return all(x >= 0 for x in p)

def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d-a+1)]

def EMD(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def H_tower(d, mmax):
    ps = profiles(d)
    H = [{c: [1] for c in ps}]
    for m in range(1, mmax+1):
        den = [0]*(2*m+1); den[0] = 1; den[m] += 1; den[2*m] += 1
        Hm = {}
        for c in ps:
            num = []
            for cp in ps:
                num = padd(num, pshift(H[m-1][cp], m*EMD(cp, c)))
            Hm[c] = pdiv_exact(num, den)
        H.append(Hm)
    return ps, H

def brute_F(c, m, N):
    """F_{c,m} truncated via chain model: m nested threshold vectors
    x^(t) in Z>=0^3, x^{(t)}_{i+1} <= x^{(t)}_i + c_{(i+1)%3} cyclically,
    x^(t+1) <= x^(t) componentwise; weight q^{sum |x^(t)|}."""
    def chains_ok(x):
        for i in range(3):
            if x[(i+1) % 3] > x[i] + c[(i+1) % 3]:
                return False
        return True
    coef = [0]*(N+1)
    def rec(t, prev, wt):
        if wt > N: return
        if t == m:
            coef[wt] += 1
            return
        ub = prev if prev else (N, N, N)
        for a in range(min(ub[0], N-wt)+1):
            for b in range(min(ub[1], N-wt-a)+1):
                for cc in range(min(ub[2], N-wt-a-b)+1):
                    x = (a, b, cc)
                    if chains_ok(x):
                        rec(t+1, x, wt+a+b+cc)
    rec(0, None, 0)
    return coef

def qpoch(m):
    p = [1]
    for i in range(1, m+1):
        p = pmul(p, padd([1], pshift([1], i), 1, -1))
    return p

def run(d, brute_N=14, do_brute=True):
    ps, H = H_tower(d, 2)
    print(f"=== d={d}: {len(ps)} profiles; H-tower exact division OK (V0)")
    if do_brute:
        import random
        random.seed(0)
        sample = ps if len(ps) <= 6 else random.sample(ps, 4)
        for c in sample:
            for m in (1, 2):
                F = brute_F(c, m, brute_N)
                cut = brute_N - 6
                Hm = pmul(qpoch(m), F)
                Hm = (Hm + [0]*cut)[:cut]
                target = (H[m][c] + [0]*cut)[:cut]
                if Hm != target:
                    print(f"  BRUTE MISMATCH c={c} m={m}\n   brute={Hm}\n   Hrec ={target}")
                    return False
        print(f"  V1 brute-force spot check OK (m<=2, {len(sample)} profiles, mod q^{brute_N-6})")
    ok_T1 = ok_T2 = ok_ball = ok_har = True
    fail_har = []
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    for c in ps:
        H1c, H2c = H[1][c], H[2][c]
        Q2 = padd(padd(H2c, pmul([1, 1], H1c), 1, -1), [0, 1])
        N2 = pmul([1, 0, 1, 0, 1], Q2)
        if not pneg_ok(N2):
            print(f"  !! N_2 not nonneg at c={c} (unexpected)"); return False
        rhs = [0, 1, 0, 1, 0, 1]
        for cp in ps:
            if cp == c: continue
            rhs = padd(rhs, pshift(H[1][cp], 2*EMD(cp, c)))
        rhs = padd(rhs, pmul([0, 1, 1, 1, 1, 1], H1c), 1, -1)
        if rhs != N2:
            ok_T1 = False
            print(f"  T1 FAILS at c={c}")
        ball = []
        for cp in ps:
            ball = padd(ball, pshift([1], 2*EMD(cp, c)))
        ballterm = padd(ball, [1, 0, 1, 0, 1], 1, -1)
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(cp, c)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        if padd(list(ballterm), har) != N2:
            ok_T2 = False
            print(f"  T2 FAILS at c={c}")
        if not pneg_ok(ballterm):
            ok_ball = False
            print(f"  L-ball FAILS at c={c}: {ballterm[:8]}")
        if not pneg_ok(har):
            ok_har = False
            fail_har.append((c, har))
    print(f"  T1 identity: {'OK' if ok_T1 else 'FAIL'}")
    print(f"  T2 identity: {'OK' if ok_T2 else 'FAIL'}")
    print(f"  L-ball: {'OK' if ok_ball else 'FAIL'}")
    print(f"  L-harnack: {'OK all profiles' if ok_har else f'FAIL at {len(fail_har)}/{len(ps)} profiles'}")
    for c, har in fail_har[:6]:
        negs = [(i, x) for i, x in enumerate(har) if x < 0]
        print(f"    c={c}: negative coeffs {negs}")
    return ok_T1 and ok_T2

if __name__ == "__main__":
    for d in (4, 5, 7):
        run(d, do_brute=(d <= 5))
