"""
Seed 3, R2L3, Script 5: INJECTION DESIGN #4 -- full-column insertion.

Target: f_0^{(m)} = (1-q^m) g_m - q g_{m-1} >= 0, i.e. need
  phi: C_{m-1} -> C_m weight +1 (PROVED, bottom-append), and
  psi: C_m -> C_m weight +m, injective, image disjoint from im(phi).

Design #4: psi(u) = u + col_i, add e_i to EVERY level s=1..m, where
i = least COMMON-SLACK coordinate (slack at every level of u).
This is "insert a new part of size m into component i" -- a genuine part,
not a broken ribbon (Seed 8 attempt 1) nor a single box (attempts 2/3).

Tests:
 T1 (totality): every chain in C_m has a common-slack coordinate?
 T2 (injectivity): psi with i = least common-slack coord injective?
 T3 (disjointness): im(psi) cap im(phi) empty (expected automatic).
 T4 (bonus, synthesis mission 2a): raw bracket g_m >= q^m F_m ?
"""
from itertools import product
from collections import Counter
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

def slackset(a, c):
    return set(i for i in range(3) if a[i] < a[(i-1) % 3] + c[i])

def common_slack(ch, c):
    s = set([0,1,2])
    for a in ch:
        s &= slackset(a, c)
    return sorted(s)

def psi(ch, c):
    cs = common_slack(ch, c)
    if not cs:
        return None
    i = cs[0]
    return tuple(tuple(a[j] + (1 if j == i else 0) for j in range(3)) for a in ch), i

def phi(ch, c):
    a = ch[-1]
    cand = [i for i in range(3) if c[i] > 0 and a[i] >= 1]
    if not cand:
        return None
    i = cand[0]
    e = tuple(1 if j == i else 0 for j in range(3))
    return ch + (e,)

def test(d, c, m, W):
    Cm_all = chains(c, m, W + m)
    Cm_set = set(Cm_all)
    Cm_dom = [ch for ch in Cm_all if wt(ch) <= W]
    Cm1 = chains(c, m-1, W)
    Cm1_dom = [ch for ch in Cm1 if wt(ch) <= W - 1]
    fails = []
    images = {}
    n_nocs = 0
    for ch in Cm_dom:
        r = psi(ch, c)
        if r is None:
            n_nocs += 1
            if n_nocs <= 3:
                fails.append(("T1 no common slack", ch))
            continue
        b, i = r
        assert wt(b) == wt(ch) + m
        assert all(in_S(a, c) for a in b) and all(leq(b[s+1], b[s]) for s in range(m-1))
        assert b in Cm_set
        if b in images:
            fails.append(("T2 collision", images[b], ch, b))
        images[b] = ch
    if n_nocs:
        fails.append(("T1 TOTAL no-common-slack count", n_nocs, "of", len(Cm_dom)))
    phi_img = set()
    for ch in Cm1_dom:
        b = phi(ch, c)
        if b is None:
            fails.append(("phi undefined", ch)); continue
        phi_img.add(b)
    ov = phi_img & set(images.keys())
    if ov:
        fails.append(("T3 overlap", sorted(ov)[:2]))
    status = "OK" if not fails else "FAIL"
    print(f"{status} d={d} c={c} m={m} W={W}: |dom|={len(Cm_dom)}, psi-defined={len(Cm_dom)-n_nocs}")
    for f in fails[:6]:
        print("   ", f)
    return not fails

def rawbracket(d, c, m, W):
    gm = Counter(wt(ch) for ch in chains(c, m, W))
    Fm = Counter(wt(ch) for ch in chains(c, m, W, nonzero=False))
    bad = [(N, gm[N] - Fm[N-m]) for N in range(W+1) if gm[N] - Fm[N-m] < 0]
    print(f"T4 raw g_m >= q^m F_m: d={d} c={c} m={m} W={W}: {'OK' if not bad else bad[:8]}")

if __name__ == '__main__':
    cases = [
        (2, (1,1,0), 2, 11), (2, (1,1,0), 3, 11), (2, (1,1,0), 4, 11),
        (2, (2,0,0), 2, 11), (2, (2,0,0), 3, 11),
        (4, (2,1,1), 2, 10), (4, (2,1,1), 3, 10), (4, (4,0,0), 2, 10),
        (4, (4,0,0), 3, 9), (4, (3,1,0), 2, 10), (4, (3,1,0), 3, 9),
        (4, (2,2,0), 2, 10), (4, (2,2,0), 3, 9), (4, (0,2,2), 2, 10),
        (4, (0,3,1), 2, 10), (4, (0,1,3), 2, 10),
        (5, (2,2,1), 2, 9), (5, (3,1,1), 2, 9), (5, (3,1,1), 3, 9),
        (5, (5,0,0), 2, 9), (5, (0,4,1), 2, 9),
        (7, (3,2,2), 2, 9), (7, (4,2,1), 2, 9), (7, (7,0,0), 2, 9),
    ]
    ok = True
    for (d, c, m, W) in cases:
        ok = test(d, c, m, W) and ok
        sys.stdout.flush()
    print("PSI-#4 ALL:", "PASS" if ok else "FAIL")
    for (d, c, m, W) in [(2,(1,1,0),3,12), (4,(2,1,1),2,12), (4,(2,1,1),3,12),
                         (4,(4,0,0),3,11), (5,(3,1,1),3,10), (7,(4,2,1),2,10)]:
        rawbracket(d, c, m, W)
        sys.stdout.flush()
