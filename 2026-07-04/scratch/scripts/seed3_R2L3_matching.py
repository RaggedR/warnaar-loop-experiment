"""
Seed 3, R2L3, Script 6: Hall-condition / max-matching test for the
full-column move-set.

Question A (f_0 target): does the bipartite graph
   u in C_m  ~  w in C_m,  w = u + col_i (valid), wt(w) = wt(u)+m
admit a matching saturating the domain, at every weight? (Images
automatically avoid im(phi) since |bottom| >= 2.)

Question B (monotonicity raw bracket, T4): same with domain F_m-chains
(zero levels allowed), i.e. does "insert a part of size m" saturate
F_m -> C_m?

If Hall FAILS anywhere: the move-set itself is inadequate -> no design
of 'insert one part m' type can work. If Hall HOLDS: search for the
canonical rule.
"""
from itertools import product
from collections import Counter, defaultdict
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

def addcol(ch, i, c):
    b = tuple(tuple(a[j] + (1 if j == i else 0) for j in range(3)) for a in ch)
    if all(in_S(a, c) for a in b):
        return b
    return None

def hopcroft(adj, left):
    # simple Kuhn's algorithm (sizes are small)
    matchL, matchR = {}, {}
    def try_kuhn(u, seen):
        for w in adj[u]:
            if w in seen: continue
            seen.add(w)
            if w not in matchR or try_kuhn(matchR[w], seen):
                matchL[u] = w; matchR[w] = u
                return True
        return False
    cnt = 0
    for u in left:
        if try_kuhn(u, set()):
            cnt += 1
    return cnt, matchL

def test(d, c, m, W, domain_nonzero, label):
    Cm_img = set(chains(c, m, W + m))
    dom_all = chains(c, m, W, nonzero=domain_nonzero)
    byw = defaultdict(list)
    for ch in dom_all:
        byw[wt(ch)].append(ch)
    allok = True
    for N in sorted(byw):
        left = byw[N]
        adj = {}
        deadend = []
        for u in left:
            imgs = []
            for i in range(3):
                b = addcol(u, i, c)
                if b is not None and b in Cm_img:
                    imgs.append(b)
            adj[u] = imgs
            if not imgs:
                deadend.append(u)
        cnt, _ = hopcroft(adj, left)
        if cnt < len(left):
            allok = False
            print(f"  HALL FAIL {label} d={d} c={c} m={m} wt={N}: matched {cnt}/{len(left)}, deadends={len(deadend)}")
            if deadend:
                print("    deadend example:", deadend[0])
            else:
                # find a violating structure: report unmatched vertex
                pass
    print(f"{'OK' if allok else 'FAIL'} {label} d={d} c={c} m={m} W={W} |dom|={len(dom_all)}")
    return allok

if __name__ == '__main__':
    cases = [
        (2, (1,1,0), 3), (2, (2,0,0), 3),
        (4, (2,1,1), 2), (4, (2,1,1), 3), (4, (4,0,0), 2), (4, (4,0,0), 3),
        (4, (3,1,0), 2), (4, (3,1,0), 3), (4, (2,2,0), 2), (4, (0,2,2), 2),
        (4, (0,3,1), 2), (4, (0,1,3), 2),
        (5, (2,2,1), 2), (5, (3,1,1), 2), (5, (3,1,1), 3), (5, (5,0,0), 2),
        (5, (0,4,1), 2), (5, (0,4,1), 3),
        (7, (3,2,2), 2), (7, (4,2,1), 2), (7, (7,0,0), 2),
    ]
    okA = okB = True
    for (d, c, m) in cases:
        W = 10 if d <= 4 else 9
        okA = test(d, c, m, W, True, "A(f0:C_m->C_m)") and okA
        sys.stdout.flush()
    print("QUESTION A (psi within full-column move-set):", "VIABLE (Hall holds)" if okA else "INADEQUATE")
    for (d, c, m) in cases:
        W = 10 if d <= 4 else 9
        okB = test(d, c, m, W, False, "B(mono:F_m->C_m)") and okB
        sys.stdout.flush()
    print("QUESTION B (raw-bracket insertion move-set):", "VIABLE (Hall holds)" if okB else "INADEQUATE")
