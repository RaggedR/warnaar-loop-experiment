"""
Seed 8 R2 L2: test the second-order injection for f_0^{(m)} >= 0.

Model: CP of profile c (r=3), max<=m  <->  chain a^(1) >= ... >= a^(m) in
S = { a in Z>=0^3 : a[i] <= a[(i-1)%3] + c[i] for i=0,1,2 }, weight = sum |a^(s)|.
max exactly m <-> all levels nonzero.

f_0^{(m)} = g_m - q g_{m-1} - q^m g_m >= 0 would follow from:
  phi: C_{m-1} -> C_m weight +1 (proven injection lemma: append e_i at bottom,
       i = least index with c_i>0 and a^(m-1)_i >= 1)
  psi: C_m -> C_m weight +m (greedy ribbon: add e_{i_s} at each level)
  both injective, images disjoint (auto: bottom-level size 1 vs >= 2).

This script exhaustively tests: model correctness (chain counts = g_m from
transfer matrix, cross-checked separately), phi/psi well-definedness,
injectivity, disjointness, for small d, c, m, weight <= W.
"""
from itertools import product
import sys
from collections import Counter

def in_S(a, c):
    return all(a[i] >= 0 and a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states(c, W):
    return [a for a in product(range(W+1), repeat=3) if sum(a) <= W and in_S(a, c)]

def leq(b, a):
    return all(b[i] <= a[i] for i in range(3))

def chains(c, m, W, nonzero=True):
    """all chains a^(1)>=...>=a^(m) in S, total weight <= W, all levels nonzero."""
    S = states(c, W)
    out = []
    def rec(pref, rem):
        if len(pref) == m:
            out.append(tuple(pref)); return
        lo = (m - len(pref) - 1)  # min weight for remaining levels
        for a in S:
            if nonzero and sum(a) == 0: continue
            if sum(a) > rem - lo: continue
            if pref and not leq(a, pref[-1]): continue
            rec(pref + [a], rem - sum(a))
    rec([], W)
    return out

def slack(a, c):
    return [i for i in range(3) if a[i] < a[(i-1) % 3] + c[i]]

def psi(ch, c):
    m = len(ch)
    idx = [None]*m
    sl = slack(ch[m-1], c)
    assert sl, "no slack coordinate!"
    idx[m-1] = sl[0]
    for s in range(m-2, -1, -1):
        sls = slack(ch[s], c)
        assert sls
        idx[s] = idx[s+1] if idx[s+1] in sls else sls[0]
    b = []
    for s in range(m):
        v = list(ch[s]); v[idx[s]] += 1; b.append(tuple(v))
    # validity checks
    for s in range(m):
        assert in_S(b[s], c), ("psi output not in S", ch, idx, s)
        if s+1 < m:
            assert leq(b[s+1], b[s]), ("psi output not a chain", ch, idx, s)
    return tuple(b)

def phi(ch, c):
    """ch is chain of length m-1 (all nonzero); append e_i at bottom."""
    a = ch[-1]
    cand = [i for i in range(3) if c[i] > 0 and a[i] >= 1]
    if not cand:
        return None  # lemma says this cannot happen
    i = cand[0]
    e = tuple(1 if j == i else 0 for j in range(3))
    # e must satisfy in_S and e <= a
    if not in_S(e, c) or not leq(e, a):
        return ("INVALID", ch, i)
    return ch + (e,)

def test(d, c, m, W):
    Cm = chains(c, m, W + m)     # need weight up to W+m for images
    Cm_set = set(Cm)
    Cm_dom = [ch for ch in Cm if sum(sum(a) for a in ch) <= W]
    Cm1 = chains(c, m-1, W - 1 + 1)  # weight <= W-1 so image weight <= W... keep simple: W
    Cm1_dom = [ch for ch in Cm1 if sum(sum(a) for a in ch) <= W - 1]

    # test psi
    images = {}
    for ch in Cm_dom:
        b = psi(ch, c)
        wtb = sum(sum(a) for a in b)
        wta = sum(sum(a) for a in ch)
        assert wtb == wta + m, ("wrong weight", ch, b)
        assert b in Cm_set, ("psi image not enumerated?!", b)
        if b in images:
            print("PSI COLLISION d=%d c=%s m=%d:" % (d, c, m))
            print("   a =", images[b]); print("   a'=", ch); print("   b =", b)
            return False
        images[b] = ch
    # test phi + disjointness
    phi_img = set()
    for ch in Cm1_dom:
        b = phi(ch, c)
        if b is None:
            print("PHI UNDEFINED (no candidate) d=%d c=%s m=%d ch=%s" % (d, c, m, ch))
            return False
        if isinstance(b, tuple) and b and b[0] == "INVALID":
            print("PHI INVALID:", b); return False
        assert sum(sum(a) for a in b) == sum(sum(a) for a in ch) + 1
        if b in phi_img:
            print("PHI COLLISION"); return False
        phi_img.add(b)
    overlap = phi_img & set(images.keys())
    if overlap:
        print("IMAGE OVERLAP d=%d c=%s m=%d: %s" % (d, c, m, list(overlap)[:3]))
        return False
    print("OK d=%d c=%s m=%d W=%d: |C_m dom|=%d psi-injective, |C_{m-1} dom|=%d phi ok, disjoint"
          % (d, c, m, W, len(Cm_dom), len(Cm1_dom)))
    return True

def count_check(d, c, m, W):
    """f_0 coefficient check by pure enumeration: N-th coeff of g_m - q g_{m-1} - q^m g_m >= 0"""
    from collections import Counter
    cm = Counter(sum(sum(a) for a in ch) for ch in chains(c, m, W))
    cm1 = Counter(sum(sum(a) for a in ch) for ch in chains(c, m-1, W))
    bad = []
    for N in range(W+1):
        v = cm[N] - cm1[N-1] - cm[N-m]
        if v < 0: bad.append((N, v))
    print("count_check d=%d c=%s m=%d W=%d: %s" % (d, c, m, W, "OK" if not bad else bad))

if __name__ == '__main__':
    ok = True
    cases = [
        (2, (1,1,0), 2, 10), (2, (1,1,0), 3, 10), (2, (2,0,0), 2, 10), (2, (2,0,0), 3, 10),
        (4, (2,1,1), 2, 10), (4, (2,1,1), 3, 9), (4, (4,0,0), 2, 9), (4, (3,1,0), 3, 9),
        (4, (2,2,0), 2, 9), (4, (3,0,1), 2, 9),
        (5, (2,2,1), 2, 9), (5, (3,1,1), 3, 8), (5, (5,0,0), 2, 8),
        (7, (3,2,2), 2, 8), (7, (4,2,1), 2, 8),
        (3, (1,1,1), 2, 8), (3, (2,1,0), 2, 8),  # d divisible by 3 too: model level
    ]
    for (d, c, m, W) in cases:
        ok = test(d, c, m, W) and ok
        sys.stdout.flush()
    for (d, c, m, W) in [(4, (2,1,1), 2, 12), (4, (2,1,1), 3, 12), (2, (1,1,0), 4, 12)]:
        count_check(d, c, m, W)
    print("ALL:", "PASS" if ok else "FAIL")
