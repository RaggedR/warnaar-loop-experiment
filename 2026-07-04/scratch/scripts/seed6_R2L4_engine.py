#!/usr/bin/env python3
"""Seed 6, Round 2, Layer 4 — true-convention engine for the Ehrhart route to S1.

Conventions (synthesis-layer3.md section 4(iv), TRUE labels, target-first):
  EMD(c,c') = 3*max(0, c'1-c1, c0-c'0) + (c'0-c0) - (c'1-c1)
  (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c,c')} H_{c',m-1}   [c = TARGET]
  har(c) = sum_{c'!=c} q^{2*EMD(c,c')} Q1(c') - q(1+q+q^2+q^3+q^4) Q1(c)
  N2(c)  = [B_c(q^2) - 1 - q^2 - q^4] + har(c),  B_c(q) = sum_{c'} q^{EMD(c,c')}.

Two computations of har_j:
  (a) FULL: exact polynomial H-recursion (like seed8 engine), then T2 split.
  (b) LOCAL: sphere geometry.  g(s,t) = 3*max(0,t,-s) + s - t  (deviation coords
      u = c'-c, s=u0, t=u1);  b_e(c) = #{sphere_e points valid in Delta};
      [q^k]H1 = A_k - A_{k-1}, A_k = sum_{e<=k, e==k mod 3} b_e;
      har_j(c) = sum_{e>=1} sum_{p in sphere_e valid} q1coef(c+p, j-2e)
                 - sum_{i=1..5} q1coef(c, j-i).
Checks: T1/T2 true-convention identities; (a)==(b); EMD rotation invariance;
interior closed form har^inf_j.
"""
import sys
from functools import lru_cache

# ---------- polynomial helpers (list of ints, index = exponent) ----------
def ptrim(p):
    while p and p[-1] == 0: p.pop()
    return p
def padd(a, b, sa=1, sb=1):
    n = max(len(a), len(b)); r = [0]*n
    for i, x in enumerate(a): r[i] += sa*x
    for i, x in enumerate(b): r[i] += sb*x
    return ptrim(r)
def pshift(a, k): return [0]*k + list(a)
def pmul(a, b):
    if not a or not b: return []
    r = [0]*(len(a)+len(b)-1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b): r[i+j] += x*y
    return ptrim(r)
def pdiv_exact(num, den):
    num = list(num); r = []
    if not ptrim(list(num)): return []
    dd = len(den)-1; dl = den[-1]
    for i in range(len(num)-1-dd, -1, -1):
        c = num[i+dd]
        assert c % dl == 0
        c //= dl
        if c:
            for j, y in enumerate(den): num[i+j] -= c*y
        r.append(c)
    assert not any(num), "nonzero remainder"
    r.reverse(); return ptrim(r)

# ---------- profiles / EMD (TRUE convention) ----------
def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d-a+1)]

def EMD(c, cp):  # target-first: distance from target c out to source cp
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def g(s, t):
    return 3*max(0, t, -s) + s - t

# ---------- (a) FULL engine ----------
def H_tower(d, mmax):
    ps = profiles(d)
    H = [{c: [1] for c in ps}]
    for m in range(1, mmax+1):
        den = [0]*(2*m+1); den[0] = 1; den[m] += 1; den[2*m] += 1
        Hm = {}
        for c in ps:
            num = []
            for cp in ps:
                num = padd(num, pshift(H[m-1][cp], m*EMD(c, cp)))  # TARGET-FIRST
            Hm[c] = pdiv_exact(num, den)
        H.append(Hm)
    return ps, H

def full_har_and_checks(d):
    """Returns dict c -> har poly; asserts T1, T2, N2 = ball + har."""
    ps, H = H_tower(d, 2)
    Q1 = {cp: padd(H[1][cp], [1], 1, -1) for cp in ps}
    out = {}
    for c in ps:
        H1c, H2c = H[1][c], H[2][c]
        Q2 = padd(padd(H2c, pmul([1, 1], H1c), 1, -1), [0, 1])
        N2 = pmul([1, 0, 1, 0, 1], Q2)
        # T1: N2 = sum_{c'!=c} q^{2EMD(c,c')} H1(c') + (q+q^3+q^5) - (q+..+q^5) H1(c)
        rhs = [0, 1, 0, 1, 0, 1]
        for cp in ps:
            if cp == c: continue
            rhs = padd(rhs, pshift(H[1][cp], 2*EMD(c, cp)))
        rhs = padd(rhs, pmul([0, 1, 1, 1, 1, 1], H1c), 1, -1)
        assert rhs == N2, f"T1 fails at d={d} c={c}"
        # T2 split
        ball = []
        for cp in ps:
            ball = padd(ball, pshift([1], 2*EMD(c, cp)))
        ballterm = padd(ball, [1, 0, 1, 0, 1], 1, -1)
        har = [0, 1, 0, 1, 0, 1]  # start from T1 rhs and subtract ball pieces
        har = []
        for cp in ps:
            if cp == c: continue
            har = padd(har, pshift(Q1[cp], 2*EMD(c, cp)))
        har = padd(har, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
        assert padd(list(ballterm), list(har)) == N2, f"T2 fails at d={d} c={c}"
        assert all(x >= 0 for x in ballterm), f"ball term negative at d={d} c={c}"
        out[c] = har
    return out

# ---------- (b) LOCAL engine ----------
def sphere(e):
    """Lattice points with g == e (e >= 1), via box filter (correct, O(e^2))."""
    pts = []
    for s in range(-e, e+1):
        for t in range(-e, e+1):
            if g(s, t) == e: pts.append((s, t))
    return pts

@lru_cache(maxsize=None)
def sphere_cached(e): return tuple(sphere(e))

def b_e(c, e):
    if e == 0: return 1
    c0, c1, c2 = c
    return sum(1 for (s, t) in sphere_cached(e)
               if s >= -c0 and t >= -c1 and s+t <= c2)

def A_k(c, k):
    if k < 0: return 0
    return sum(b_e(c, e) for e in range(k % 3, k+1, 3))

def q1coef(c, k):
    if k <= 0: return 0
    return A_k(c, k) - A_k(c, k-1)

def local_har_j(c, j):
    c0, c1, c2 = c
    tot = 0
    for e in range(1, (j-1)//2 + 1):
        k = j - 2*e
        for (s, t) in sphere_cached(e):
            if s >= -c0 and t >= -c1 and s+t <= c2:
                tot += q1coef((c0+s, c1+t, c2-s-t), k)
    tot -= sum(q1coef(c, j-i) for i in range(1, 6))
    return tot

# ---------- checks ----------
def check_sphere_size():
    for e in range(1, 40):
        assert len(sphere(e)) == 3*e, e
    print("sphere sizes 3e OK (e<=39)")

def check_rotation(d):
    ps = profiles(d)
    rot = lambda c: (c[1], c[2], c[0])
    for c in ps:
        for cp in ps:
            if EMD(c, cp) != EMD(rot(c), rot(cp)):
                print(f"EMD NOT rotation invariant: {c},{cp}"); return False
    print(f"EMD C3-rotation invariance OK d={d}")
    return True

def check_full_vs_local(d):
    hars = full_har_and_checks(d)
    print(f"d={d}: T1/T2 identities OK (true convention), ball >= 0 OK")
    for c, har in hars.items():
        deg = len(har) - 1
        for j in range(0, deg+3):
            hv = har[j] if j < len(har) else 0
            lv = local_har_j(c, j)
            assert hv == lv, f"LOCAL MISMATCH d={d} c={c} j={j}: full={hv} local={lv}"
    print(f"d={d}: local sphere computation == full engine har, all profiles, all j")
    # S1/S2 in true convention
    for c, har in hars.items():
        rank = sum(1 for x in c if x >= 1)
        b2 = b_e(c, 2)
        for j, v in enumerate(har):
            if j == 2:
                assert v == -(rank-1), f"har_2 != -(b1-1) at {c}"
            elif j == 4:
                assert v >= -(b2-1), f"S2 fails at {c}"
            else:
                assert v >= 0, f"S1 fails at d={d} c={c} j={j}: {v}"
    print(f"d={d}: S1/S2 + har_2 = -(b1-1) exact, all profiles")

def har_inf(j):
    """Hand-derived interior closed form."""
    if j <= 5: return [0, 0, -2, 1, 0, 10][j]
    if j % 2 == 0:
        p = j//2; return (p-1)*(2*p*p+5*p-20)//2
    p = (j-1)//2; return p*(p+1)*(p+2) - 10*p + 5

def check_interior():
    c = (60, 58, 60)  # d=178, 178 mod 3 = 1, min=58 >= 2j for j <= 29
    for j in range(0, 30):
        lv = local_har_j(c, j)
        hv = har_inf(j)
        assert lv == hv, f"interior mismatch j={j}: local={lv} formula={hv}"
    print("interior closed form har^inf_j verified j<=29 at c=(60,58,60), d=178")

if __name__ == "__main__":
    check_sphere_size()
    check_rotation(5)
    for d in (4, 5, 7):
        check_full_vs_local(d)
    check_interior()
    print("ALL CHECKS PASS")
