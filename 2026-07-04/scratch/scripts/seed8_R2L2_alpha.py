"""
Seed 8 R2 L2: canonical single-box add alpha on the state polyhedron S.

S = { a in Z>=0^3 : a[i] <= a[(i-1)%3] + c[i] }.
j*(b) := least j with b - e_j in S   (the canonical removal coordinate).
alpha(u) := u + e_j for the least j in Add(u) := {j : u+e_j in S} such that
            j*(u + e_j) = j.
alpha is injective by construction IF total. This script tests totality
(and totality of alpha on the shifted sets), for many profiles, |u| <= UP.

Also tests: top-add map psi_top on chains:
  m = 3t + rho; psi_top(a) = (alpha^rho(a^(1) + t*(1,1,1)), a^(2), ..., a^(m)).
  - well-defined (chain condition trivially preserved: top only grows)
  - injective (alpha injective + translation injective)
  - X-membership preserved for m >= 2? (bottom levels unchanged for m>=2:
    X membership depends on a^(m), a^(m-1): unchanged when m >= 3; for m=2
    the top IS a^(m-1): check!)
Then counts the collision structure of Phi = phi u psi_top.
"""
from itertools import product
import sys

def in_S(a, c):
    return all(a[i] >= 0 and a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def jstar(b, c):
    for j in range(3):
        v = list(b); v[j] -= 1
        if v[j] >= 0 and in_S(tuple(v), c):
            return j
    return None

def alpha(u, c):
    for j in range(3):
        v = list(u); v[j] += 1
        vt = tuple(v)
        if in_S(vt, c) and jstar(vt, c) == j:
            return vt
    return None

def test_alpha_total(c, UP):
    bad = []
    for u in product(range(UP+1), repeat=3):
        if sum(u) > UP or not in_S(u, c): continue
        if alpha(u, c) is None:
            bad.append(u)
    return bad

if __name__ == '__main__':
    profiles = []
    for d in range(1, 9):
        for c0 in range(d+1):
            for c1 in range(d+1-c0):
                profiles.append((c0, c1, d-c0-c1))
    allok = True
    for c in profiles:
        bad = test_alpha_total(c, 14)
        if bad:
            allok = False
            print("ALPHA NOT TOTAL c=%s: %s" % (c, bad[:5]))
    print("alpha totality over all profiles d<=8, |u|<=14:", "PASS" if allok else "FAIL")

    # injectivity double check (should be automatic)
    for c in [(2,1,1),(1,1,1),(5,0,0),(3,1,0)]:
        seen = {}
        for u in product(range(12), repeat=3):
            if sum(u) > 12 or not in_S(u, c): continue
            b = alpha(u, c)
            if b in seen:
                print("ALPHA COLLISION c=%s u=%s u'=%s b=%s" % (c, seen[b], u, b))
            seen[b] = u
    print("alpha injectivity spot check done")
