"""
Seed 3, R2L3, Script 8: fractional-matching route for f_0^{(m)} >= 0.

Ribbon graph: u in C_m (wt N-m) -> w in C_m (wt N), w = u + one box per level.
Fractional matching x(u,w) = 1/r_out(u) saturates the domain; it is feasible
(inflow(w) <= 1 for all w) IFF sum_{u->w} 1/r_out(u) <= 1.

Sufficient local condition: for every edge (u,w): r_out(u) >= r_in(w).
Test both:
  L1: local degree condition min over edges of r_out(u) - r_in(w) >= 0 ?
  L2: uniform-inflow feasibility max over w of sum 1/r_out(u) <= 1 ?
(L1 => L2 => f_0 coefficient inequality at this weight.)
"""
from itertools import product
from collections import defaultdict
from fractions import Fraction
import sys

def in_S(a, c):
    return all(a[i] >= 0 and a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states(c, W):
    return [a for a in product(range(W+1), repeat=3) if sum(a) <= W and in_S(a, c)]

def leq(b, a):
    return all(b[i] <= a[i] for i in range(3))

def chains(c, m, W, nonzero=True):
    S = states(c, W)
    out = []
    def rec(pref, rem):
        if len(pref) == m:
            out.append(tuple(pref)); return
        lo = (m - len(pref) - 1) if nonzero else 0
        for a in S:
            if nonzero and sum(a) == 0: continue
            if sum(a) > rem - lo: continue
            if pref and not leq(a, pref[-1]): continue
            rec(pref + [a], rem - sum(a))
    rec([], W)
    return out

def wt(ch):
    return sum(sum(a) for a in ch)

def ribbons_out(u, c):
    """all valid w = u + one box per level (w a chain, levels in S)."""
    m = len(u)
    out = []
    def rec(s, cur):
        if s == m:
            out.append(tuple(cur)); return
        for i in range(3):
            a = tuple(u[s][j] + (1 if j == i else 0) for j in range(3))
            if not in_S(a, c): continue
            if s > 0 and not leq(a, cur[-1]): continue
            rec(s+1, cur + [a])
    rec(0, [])
    return set(out)

def ribbons_in(w, c):
    """all valid u = w - one box per level (u a chain in C_m: levels in S, nonzero)."""
    m = len(w)
    out = []
    def rec(s, cur):
        if s == m:
            out.append(tuple(cur)); return
        for i in range(3):
            if w[s][i] == 0: continue
            a = tuple(w[s][j] - (1 if j == i else 0) for j in range(3))
            if sum(a) == 0: continue
            if not in_S(a, c): continue
            if s > 0 and not leq(a, cur[-1]): continue
            rec(s+1, cur + [a])
    rec(0, [])
    return set(out)

def test(d, c, m, W):
    dom = chains(c, m, W)
    byw = defaultdict(list)
    for ch in dom:
        byw[wt(ch)].append(ch)
    minL1 = None; maxL2 = Fraction(0); badL1 = badL2 = 0
    exL1 = exL2 = None
    inflow = defaultdict(Fraction)
    rout = {}
    for u in dom:
        R = ribbons_out(u, c)
        rout[u] = len(R)
        if len(R) == 0:
            print(f"  DEADEND?! {u}"); continue
        for w in R:
            inflow[w] += Fraction(1, len(R))
    # L1 over edges, L2 over images
    for u in dom:
        for w in ribbons_out(u, c):
            rin = len(ribbons_in(w, c))
            diff = rout[u] - rin
            if minL1 is None or diff < minL1:
                minL1 = diff; exL1 = (u, w, rout[u], rin)
            if diff < 0: badL1 += 1
    for w, f in inflow.items():
        if f > maxL2:
            maxL2 = f; exL2 = w
        if f > 1: badL2 += 1
    print(f"d={d} c={c} m={m} W={W}: L1 min(rout-rin)={minL1} (bad edges {badL1}); "
          f"L2 max inflow={maxL2} (bad {badL2})")
    if badL1 and not badL2:
        print("   L1 fails but uniform fractional matching still feasible")
    if badL2:
        print("   L2 FAIL example w:", exL2, "inflow", maxL2)
    sys.stdout.flush()
    return badL2 == 0

if __name__ == '__main__':
    cases = [
        (2, (1,1,0), 2, 11), (2, (1,1,0), 3, 11), (2, (1,1,0), 4, 11),
        (2, (2,0,0), 2, 11), (2, (2,0,0), 3, 11),
        (4, (2,1,1), 2, 10), (4, (2,1,1), 3, 10), (4, (4,0,0), 2, 10),
        (4, (4,0,0), 3, 10), (4, (3,1,0), 2, 10), (4, (3,1,0), 3, 10),
        (4, (2,2,0), 2, 10), (4, (0,2,2), 2, 10), (4, (0,3,1), 2, 10),
        (5, (2,2,1), 2, 9), (5, (3,1,1), 2, 9), (5, (3,1,1), 3, 9),
        (5, (5,0,0), 2, 9), (5, (0,4,1), 2, 9),
        (7, (3,2,2), 2, 9), (7, (4,2,1), 2, 9), (7, (7,0,0), 2, 9),
    ]
    ok = True
    for (d, c, m, W) in cases:
        ok = test(d, c, m, W) and ok
    print("UNIFORM FRACTIONAL MATCHING:", "FEASIBLE everywhere" if ok else "INFEASIBLE somewhere")
