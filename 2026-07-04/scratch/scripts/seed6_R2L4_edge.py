#!/usr/bin/env python3
"""Seed 6 R2L4 -- EDGE REGION (exactly one small coordinate) exact 1-D reduction.

Region-1 profiles: c = (B0, B1, a) with B0, B1 >= j-1 (capped big), small third
coordinate a; the s+t <= a constraint is the only active one.  By C3 rotation
invariance of EMD this covers any single-small position.

Hand-derived formulas (VERIFIED here against the raw engine):
  mu_e(v)  = #{u in S_e : u0+u1 = v} = 1 + [|v| <= e-1 and v == e mod 2], |v| <= e
  b_e(x)   = floor(3(x+e)/2) + 1  for -e <= x <= e-1;  3e for x >= e;  0 below
  B(q;a) - B(q;a-1) = q^a/(1-q) + q^{a+2}/(1-q^2)   (a >= 1)
    [jump of b_e at e = a is 1; at e > a it is 1 + [e == a mod 2]]
  => Delta H1 = (1-q)/(1-q^3) * (above) = q^a/(1-q^2)
  => w_k(a) - w_k(a-1) = [k >= a and k == a mod 2]
  => w_k(x) := [q^k] H1(edge, small coord x) = min(k, floor((k+x)/2)) + 1, k >= 1.

  har_edge(j, a) = sum_{e=1}^{E} sum_{v=-e}^{min(e,a)} mu_e(v) w_{j-2e}(a-v)
                   - sum_{i=1}^{5} w_{j-i}(a),   E = floor((j-1)/2)
  (valid: neighbors keep both big coordinates >= j-1-e >= j-2e = k.)
"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from seed6_R2L4_engine import sphere_cached, local_har_j, q1coef, b_e as raw_b_e

def mu(e, v):
    if abs(v) > e: return 0
    return 1 + (1 if abs(v) <= e - 1 and (v - e) % 2 == 0 else 0)

def b_edge(e, x):
    if e == 0: return 1 if x >= 0 else 0
    if x >= e: return 3 * e
    if x < -e: return 0
    return (3 * (x + e)) // 2 + 1

def w(k, x):
    if k <= 0: return 0
    return min(k, (k + x) // 2) + 1

def har_edge(j, a):
    E = (j - 1) // 2
    tot = 0
    for e in range(1, E + 1):
        k = j - 2 * e
        for v in range(-e, min(e, a) + 1):
            tot += mu(e, v) * w(k, a - v)
    tot -= sum(w(j - i, a) for i in range(1, 6))
    return tot

def verify(jmax=40):
    from collections import Counter
    for e in range(1, 60):
        cnt = Counter(s + t for (s, t) in sphere_cached(e))
        for v in range(-e - 2, e + 3):
            assert cnt.get(v, 0) == mu(e, v), (e, v)
    print("mu_e(v) formula OK (e <= 59)")
    for e in range(0, 40):
        for x in range(0, 45):
            assert b_edge(e, x) == raw_b_e((100, 100, x), e), (e, x)
    print("b_e(x) edge formula OK")
    for k in range(1, 60):
        for x in range(0, 70):
            assert w(k, x) == q1coef((100, 100, x), k), (k, x)
    print("w_k(x) closed form OK (k <= 59)")
    for j in range(0, jmax + 1):
        B = j + 2
        for a in range(0, j + 3):
            assert har_edge(j, a) == local_har_j((B, B, a), j), (j, a)
        a = min(3, j)
        assert local_har_j((a, B, B), j) == local_har_j((B, a, B), j) == har_edge(j, a)
    print(f"har_edge(j,a) == raw engine, j <= {jmax}, all a (incl. rotations)")

if __name__ == "__main__":
    verify(int(sys.argv[1]) if len(sys.argv) > 1 else 40)
    print("ALL EDGE CHECKS PASS")
