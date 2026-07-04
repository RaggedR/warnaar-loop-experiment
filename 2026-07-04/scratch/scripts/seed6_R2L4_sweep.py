#!/usr/bin/env python3
"""Seed 6 R2L4: UNCONDITIONAL sweep of S1@j / S2@j for all d, via the PROVED sharp
cap M_j = j-1 (see prove-seed6-layer4.md [CAP-SHARP]).

For coefficient j it suffices to check every profile with all c_i <= j+1 and 3 !| d
(realization corollary). Checks:
  j not in {2,4}:  har_j(c) >= 0                        (S1@j)
  j == 2:          har_2(c) == -(b_1(c)-1)              (exact vanishing)
  j == 4:          har_4(c) >= -(b_2(c)-1)              (S2, ball-absorbed exactly)
Any pass at level j ==> [q^j] N_2(c) >= 0 for ALL profiles c, ALL d with gcd(d,3)=1.
"""
import sys, time
from functools import lru_cache

def g(s, t): return 3*max(0, t, -s) + s - t

@lru_cache(maxsize=None)
def sphere(e):
    return tuple((s, t) for s in range(-e, e+1) for t in range(-e, e+1) if g(s, t) == e)

@lru_cache(maxsize=None)
def _A(cap_c, k):
    """A_k for capped profile cap_c (each entry already min'd at >= k)."""
    c0, c1, c2 = cap_c
    cnt = 0
    for s in range(-k, k+1):
        for t in range(-k, k+1):
            gv = g(s, t)
            if gv <= k and (k - gv) % 3 == 0 and s >= -c0 and t >= -c1 and s+t <= c2:
                cnt += 1
    return cnt

def A_k(c, k):
    if k < 0: return 0
    key = (min(c[0], k), min(c[1], k), min(c[2], k))
    # canonicalize by rotation (EMD is C3-rotation invariant, verified)
    key = min(key, (key[1], key[2], key[0]), (key[2], key[0], key[1]))
    return _A(key, k)

def q1coef(c, k):
    if k <= 0: return 0
    return A_k(c, k) - A_k(c, k-1)

def har_j(c, j):
    c0, c1, c2 = c
    tot = 0
    for e in range(1, (j-1)//2 + 1):
        k = j - 2*e
        for (s, t) in sphere(e):
            if s >= -c0 and t >= -c1 and s+t <= c2:
                tot += q1coef((c0+s, c1+t, c2-s-t), k)
    tot -= sum(q1coef(c, j-i) for i in range(1, 6))
    return tot

def b_e(c, e):
    c0, c1, c2 = c
    return sum(1 for (s, t) in sphere(e) if s >= -c0 and t >= -c1 and s+t <= c2)

def reps(j):
    M = j + 1
    for c0 in range(M+1):
        for c1 in range(M+1):
            for c2 in range(M+1):
                if (c0+c1+c2) % 3 != 0:
                    yield (c0, c1, c2)

def check_level(j):
    t0 = time.time(); n = 0; worst = None
    for c in reps(j):
        n += 1
        h = har_j(c, j)
        if j == 2:
            need = -(b_e(c, 1) - 1)
            assert h == need, f"har_2 != -(b1-1) at c={c}: {h} vs {need}"
        elif j == 4:
            lb = -(b_e(c, 2) - 1)
            assert h >= lb, f"S2 FAILS at c={c}: har_4={h} < {lb}"
            if worst is None or h - lb < worst[0]: worst = (h - lb, c, h)
        else:
            assert h >= 0, f"S1 FAILS at j={j} c={c}: har_j={h}"
            if worst is None or h < worst[0]: worst = (h, c, h)
    print(f"j={j:2d}: {n} capped reps checked, min margin {worst[0] if worst else 'n/a'}"
          f" at c={worst[1] if worst else ''}  [{time.time()-t0:.1f}s]", flush=True)

if __name__ == "__main__":
    J0 = int(sys.argv[1]) if len(sys.argv) > 1 else 20
    for j in range(0, J0+1):
        check_level(j)
    print(f"ALL LEVELS j <= {J0} PASS: S1@j (j not in {{2,4}}), har_2 exact, S2@4.")
    print("==> [q^j] N_2 >= 0 for j <= %d, ALL profiles, ALL d with gcd(d,3)=1, UNCONDITIONALLY." % J0)
