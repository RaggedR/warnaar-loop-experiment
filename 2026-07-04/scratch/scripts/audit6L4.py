#!/usr/bin/env python3
"""Independent auditor implementation for Seed 6 Layer 4 claims.

Written from scratch from synthesis-layer3.md section 4(iv):
  EMD(c,c') = 3*max(0, c'1-c1, c0-c'0) + (c'0-c0) - (c'1-c1)
  (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c,c')} H_{c',m-1},  H_{c,0}=1  (target-first)
  Q1 = H1 - 1;  Q2 = H2 - (1+q) H1 + q   (= D_{2,2}, rederived from D-tower)
  N2 = (1+q^2+q^4) Q2
Claimed T2 split under audit: N2 = [B_c(q^2)-1-q^2-q^4] + har(c),
  har(c) = sum_{c'!=c} q^{2 EMD(c,c')} Q1(c') - q(1+q+q^2+q^3+q^4) Q1(c).

All arithmetic exact integers. Polynomials = dict{exp: coeff} (different data
structure from Seed 6's list representation, on purpose).
"""
import sys
from functools import lru_cache

# ---------------- polynomial dicts ----------------
def norm(p):
    return {e: c for e, c in p.items() if c != 0}

def add(p, q, s=1):
    r = dict(p)
    for e, c in q.items():
        r[e] = r.get(e, 0) + s * c
    return norm(r)

def shift(p, k):
    return {e + k: c for e, c in p.items()}

def mul(p, q):
    r = {}
    for e1, c1 in p.items():
        for e2, c2 in q.items():
            r[e1 + e2] = r.get(e1 + e2, 0) + c1 * c2
    return norm(r)

def divide_exact(num, den):
    """num / den, assert exact. den dict."""
    num = dict(num)
    dmax = max(den) if den else 0
    lead = den[dmax]
    quo = {}
    while num:
        e = max(num)
        if e < dmax:
            raise AssertionError("remainder")
        c = num[e]
        assert c % lead == 0
        k = c // lead
        quo[e - dmax] = k
        for de, dc in den.items():
            num[e - dmax + de] = num.get(e - dmax + de, 0) - k * dc
        num = norm(num)
    return quo

def coef(p, j):
    return p.get(j, 0)

# ---------------- profiles / EMD ----------------
def EMD(c, cp):
    return 3 * max(0, cp[1] - c[1], c[0] - cp[0]) + (cp[0] - c[0]) - (cp[1] - c[1])

def profiles(d):
    return [(a, b, d - a - b) for a in range(d + 1) for b in range(d + 1 - a)]

# ---------------- ground-truth tower ----------------
def tower(d, mmax=2):
    ps = profiles(d)
    H = [{c: {0: 1} for c in ps}]
    for m in range(1, mmax + 1):
        den = {0: 1, m: 1, 2 * m: 1}
        # careful: for m where exponents collide (never here since m>=1: 0<m<2m) fine
        Hm = {}
        for c in ps:
            num = {}
            for cp in ps:
                for e, cc in H[m - 1][cp].items():
                    k = e + m * EMD(c, cp)
                    num[k] = num.get(k, 0) + cc
            Hm[c] = divide_exact(norm(num), den)
        H.append(Hm)
    return ps, H

def har_direct(d):
    """har(c) via T2 definition from Q1; also assert N2 identity (T1/T2)."""
    ps, H = tower(d, 2)
    one = {0: 1}
    Q1 = {c: add(H[1][c], one, -1) for c in ps}
    out = {}
    for c in ps:
        Q2 = add(add(H[2][c], mul({0: 1, 1: 1}, H[1][c]), -1), {1: 1})
        N2 = mul({0: 1, 2: 1, 4: 1}, Q2)
        har = {}
        for cp in ps:
            if cp == c:
                continue
            har = add(har, shift(Q1[cp], 2 * EMD(c, cp)))
        har = add(har, mul({1: 1, 2: 1, 3: 1, 4: 1, 5: 1}, Q1[c]), -1)
        ball = {}
        for cp in ps:
            ball[2 * EMD(c, cp)] = ball.get(2 * EMD(c, cp), 0) + 1
        ballterm = add(norm(ball), {0: 1, 2: 1, 4: 1}, -1)
        assert add(ballterm, har) == N2, ("T2 FAILS", d, c)
        assert all(v >= 0 for v in ballterm.values()), ("ball neg", d, c)
        out[c] = har
    return out

# ---------------- my local formula ----------------
def gg(s, t):
    return 3 * max(0, t, -s) + s - t

@lru_cache(maxsize=None)
def sphere(e):
    """all u=(s,t) with gg==e; brute force over the box."""
    return tuple((s, t) for s in range(-e, e + 1) for t in range(-e, e + 1)
                 if gg(s, t) == e)

def b_e_raw(c, e):
    if e == 0:
        return 1
    return sum(1 for (s, t) in sphere(e)
               if s >= -c[0] and t >= -c[1] and s + t <= c[2])

def q1coef_raw(c, k):
    """[q^k]Q1(c) = A_k - A_{k-1} - [k==0]; A_k = sum_{e<=k, e=k mod 3} b_e."""
    if k <= 0:
        return 0
    Ak = sum(b_e_raw(c, e) for e in range(k % 3, k + 1, 3))
    Ak1 = sum(b_e_raw(c, e) for e in range((k - 1) % 3, k, 3))
    return Ak - Ak1

# memoized on capped key (cap property of Q1 is elementary: b_e probes only
# min(c_i,e); independently spot-checked in check_q1cap before use)
@lru_cache(maxsize=None)
def _q1c(key, k):
    return q1coef_raw(key, k)

def q1coef(c, k):
    if k <= 0:
        return 0
    return _q1c((min(c[0], k), min(c[1], k), min(c[2], k)), k)

def har_local(c, j, memo=True):
    qc = q1coef if memo else q1coef_raw
    tot = 0
    for e in range(1, (j - 1) // 2 + 1):
        k = j - 2 * e
        for (s, t) in sphere(e):
            if s >= -c[0] and t >= -c[1] and s + t <= c[2]:
                tot += qc((c[0] + s, c[1] + t, c[2] - s - t), k)
    tot -= sum(qc(c, j - i) for i in range(1, 6))
    return tot

# ---------------- checks ----------------
def check_sphere():
    for e in range(1, 60):
        pts = sphere(e)
        assert len(pts) == 3 * e, e
        for (s, t) in pts:
            assert max(abs(s), abs(t), abs(s + t)) <= e, (e, s, t)  # F1
    print("OK sphere: |S_e| = 3e and F1 (|u_i| <= e) for e <= 59")

def check_q1cap():
    import random
    random.seed(1)
    for _ in range(300):
        k = random.randint(1, 15)
        c = tuple(random.randint(0, 40) for _ in range(3))
        key = tuple(min(x, k) for x in c)
        assert q1coef_raw(c, k) == q1coef_raw(key, k), (c, k)
    print("OK Q1-cap: [q^k]Q1(c) == [q^k]Q1(min(c,k)) on 300 random samples")

def check_engine_vs_local():
    for d in (1, 2, 4, 5, 7, 8, 10, 11):
        hars = har_direct(d)
        for c, har in hars.items():
            hi = max(har) if har else 0
            for j in range(0, max(hi + 3, 21)):
                assert coef(har, j) == har_local(c, j, memo=False), (d, c, j)
        print(f"OK d={d}: T2 identity holds; har(direct) == har(local formula), all profiles, all j")

def check_capsharp():
    import random
    random.seed(7)
    n = 0
    for _ in range(200):
        j = random.randint(1, 20)
        c = tuple(random.choice([0, 1, 2, 3, j - 2, j - 1, j, j + 1, j + 5,
                                 j + 40, 200]) for _ in range(3))
        c = tuple(max(0, x) for x in c)
        key = tuple(min(x, j - 1) for x in c)
        # a random second representative of the same capped class
        c2 = tuple(x if x <= j - 2 else random.choice([j - 1, j, j + 17, 500])
                   for x in c)
        assert har_local(c, j) == har_local(key, j) == har_local(c2, j), (j, c)
        n += 1
    print(f"OK CAP-SHARP numeric: {n} random classes, har_j(c) == har_j(min(c,j-1)) == har_j(c2)")

def check_3d_counterexample():
    v13 = har_local((1, 1, 1), 13)
    v15 = har_local((0, 1, 2), 15)
    print(f"har_13((1,1,1)) = {v13}   (claimed -1)")
    print(f"har_15((0,1,2)) = {v15}   (claimed -1)")
    assert v13 == -1 and v15 == -1

def har_inf_formula(j):
    if j <= 5:
        return [0, 0, -2, 1, 0, 10][j]
    if j % 2 == 0:
        p = j // 2
        assert (p - 1) * (2 * p * p + 5 * p - 20) % 2 == 0
        return (p - 1) * (2 * p * p + 5 * p - 20) // 2
    p = (j - 1) // 2
    return p * (p + 1) * (p + 2) - 10 * p + 5

def check_r0():
    # (a) closed forms == defining sum, j <= 400
    for j in range(0, 401):
        E = (j - 1) // 2
        u = lambda k: k + 1 if k >= 1 else 0
        s = sum(3 * e * (j - 2 * e + 1) for e in range(1, E + 1)) \
            - sum(u(j - i) for i in range(1, 6))
        assert s == har_inf_formula(j), j
        if j != 2:
            assert s >= 0, j
    print("OK R0 closed forms == defining sum for j <= 400; >= 0 for j != 2")
    # (b) u_k = k+1 in the free lattice: b_e = 3e -> A_k - A_{k-1} = k+1, k <= 500
    for k in range(1, 501):
        Ak = (1 if k % 3 == 0 else 0) + sum(3 * e for e in range(k % 3, k + 1, 3) if e > 0)
        Ak1 = (1 if (k - 1) % 3 == 0 else 0) + sum(3 * e for e in range((k - 1) % 3, k, 3) if e > 0)
        assert Ak - Ak1 == k + 1, k
    print("OK R0 free-lattice count u_k = k+1 for k <= 500")
    # (c) har_j(c) == har_inf for deep-interior c, via my local formula
    for j in range(0, 26):
        c = (j + 3, j - 1 if j >= 1 else 0, j + 60)
        assert har_local(c, j) == har_inf_formula(j), j
    print("OK R0: har_j(c) == har^inf_j at boundary case min c_i = j-1, j <= 25")

if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    if which in ("all", "base"):
        check_sphere()
        check_q1cap()
        check_engine_vs_local()
        check_capsharp()
        check_3d_counterexample()
        check_r0()
        print("BASE AUDIT PASSES")

# ---------------- har memo by capped class ----------------
@lru_cache(maxsize=None)
def _har_capped(key, j):
    return har_local(key, j)

def har_j(c, j):
    key = tuple(min(x, j - 1) for x in c)
    key = min(key, (key[1], key[2], key[0]), (key[2], key[0], key[1]))
    return _har_capped(key, j)

def sweep_level(j):
    """S1@j (or exact har_2 / S2@4) over the full box c_i <= j+1, 3 nmid d."""
    import time
    t0 = time.time()
    M = j + 1
    n = 0
    worst = None
    for c0 in range(M + 1):
        for c1 in range(M + 1):
            for c2 in range(M + 1):
                if (c0 + c1 + c2) % 3 == 0:
                    continue
                c = (c0, c1, c2)
                n += 1
                h = har_j(c, j)
                if j == 2:
                    assert h == -(b_e_raw(c, 1) - 1), c
                elif j == 4:
                    m = h + (b_e_raw(c, 2) - 1)
                    assert m >= 0, c
                    if worst is None or m < worst[0]:
                        worst = (m, c)
                else:
                    assert h >= 0, (j, c, h)
                    if worst is None or h < worst[0]:
                        worst = (h, c)
    print(f"AUDIT sweep j={j}: {n} profiles in box, PASS, min margin "
          f"{worst[0] if worst else 'exact'} at {worst[1] if worst else ''} "
          f"[{time.time()-t0:.0f}s]", flush=True)

def hm_level(j):
    """HM (M1/M2) over box c_i <= j+2 (superset of claimed-sufficient j+1)."""
    import time
    t0 = time.time()
    M = j + 2
    fails = total = 0
    for c0 in range(M + 1):
        for c1 in range(M + 1):
            for c2 in range(M + 1):
                d = c0 + c1 + c2
                if d % 3 == 0:
                    continue
                h = har_j((c0, c1, c2), j)
                if d % 3 == 1:
                    steps = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
                else:
                    steps = ((2, 0, 0), (0, 2, 0), (0, 0, 2),
                             (1, 1, 0), (1, 0, 1), (0, 1, 1))
                for st in steps:
                    total += 1
                    if har_j((c0 + st[0], c1 + st[1], c2 + st[2]), j) < h:
                        fails += 1
                        print(f"HM FAIL j={j} c={(c0,c1,c2)} step={st}", flush=True)
    print(f"AUDIT HM j={j}: {total} steps, {fails} failures [{time.time()-t0:.0f}s]",
          flush=True)

if __name__ == "__main__" and len(sys.argv) > 1:
    if sys.argv[1] == "sweep":
        for j in [int(x) for x in sys.argv[2:]]:
            _har_capped.cache_clear(); _q1c.cache_clear()
            sweep_level(j)
    if sys.argv[1] == "hm":
        for j in [int(x) for x in sys.argv[2:]]:
            _har_capped.cache_clear(); _q1c.cache_clear()
            hm_level(j)
