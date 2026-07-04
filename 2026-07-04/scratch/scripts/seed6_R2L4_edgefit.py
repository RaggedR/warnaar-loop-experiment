#!/usr/bin/env python3
"""Fit exact quadratics for D(j,a) = har_edge(j,a) - har_edge(j,a-1) per
(j mod 6, a mod 6) on two chambers: LOW 1 <= a <= floor(j/2), HIGH ceil(j/2) <= a <= j-4.
Then verify on a large grid and dump the polynomials + minima."""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from seed6_R2L4_edge import har_edge
from fractions import Fraction as F

def D(j, a): return har_edge(j, a) - har_edge(j, a - 1)

MONS = [(0,0),(1,0),(0,1),(2,0),(1,1),(0,2)]

def solve(pts):
    A = [[F(j**p * a**q) for (p, q) in MONS] + [F(val)] for (j, a, val) in pts]
    n = len(MONS); r = 0
    for c in range(n):
        piv = next((i for i in range(r, len(A)) if A[i][c] != 0), None)
        if piv is None: return None
        A[r], A[piv] = A[piv], A[r]
        A[r] = [x / A[r][c] for x in A[r]]
        for i in range(len(A)):
            if i != r and A[i][c] != 0:
                A[i] = [x - A[i][c] * y for x, y in zip(A[i], A[r])]
        r += 1
        if r == n: break
    for i in range(r, len(A)):
        if A[i][n] != 0: return None
    return [A[i][n] for i in range(n)]

def in_low(j, a):  return 1 <= a <= j // 2
def in_high(j, a): return (j + 1) // 2 <= a <= j - 4

def sample(rj, ra, chamber, njs=5):
    pts = []
    js = [j for j in range(48, 400) if j % 6 == rj][:njs]
    for j in js:
        cnt = 0
        for a in range(1, j - 3):
            if a % 6 != ra: continue
            if chamber == 'low' and not (8 <= a <= j // 2 - 8): continue
            if chamber == 'high' and not (j // 2 + 8 <= a <= j - 10): continue
            pts.append((j, a, D(j, a))); cnt += 1
            if cnt >= 4: break
    return pts

def fit_all():
    out = {}
    for ch in ('low', 'high'):
        for rj in range(6):
            for ra in range(6):
                sol = solve(sample(rj, ra, ch))
                assert sol is not None, (ch, rj, ra)
                out[(ch, rj, ra)] = sol
    return out

def evalp(sol, j, a):
    return sum(c * j**p * a**q for c, (p, q) in zip(sol, MONS))

if __name__ == "__main__":
    polys = fit_all()
    print("fitted 72 classes")
    bad = 0
    for j in range(5, 261):
        if j in (2, 4): continue
        for a in range(1, j - 3):
            ch = 'low' if in_low(j, a) else 'high'
            v = evalp(polys[(ch, j % 6, a % 6)], j, a)
            if v != D(j, a):
                bad += 1
                if bad <= 10: print("MISMATCH", j, a, v, D(j, a))
    print("grid verification 5<=j<=260, 1<=a<=j-4: mismatches =", bad)
    names = ["1", "j", "a", "j^2", "ja", "a^2"]
    for key in sorted(polys):
        s = " + ".join(f"({c}){n}" for c, n in zip(polys[key], names) if c != 0)
        print(key, s if s else "(0)")
