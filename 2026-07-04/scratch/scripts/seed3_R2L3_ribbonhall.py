"""
Seed 3, R2L3, Script 7: Hall test for the RIBBON move-set (Seed 8's design
space closure): w = u + (e_{i_1},...,e_{i_m}), any coordinate per level,
such that w is a valid chain in C_m. Weight +m. Bottom |.| >= 2 so images
avoid im(phi) automatically.

If Hall holds: a (canonical) injection exists inside ribbon moves ->
Seed 8's failures were rule failures, not move-set failures.
If Hall fails: ALL one-box-per-level designs are dead; need richer moves.

Also: Hall test for the RICH move-set: w >= u componentwise (levelwise),
wt(w) = wt(u) + m, w in C_m -- i.e. arbitrary distribution of the m added
boxes (any skew addition). This is the outer limit of "monotone" designs.
"""
from itertools import product
from collections import defaultdict
import sys
sys.setrecursionlimit(100000)

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

def hopcroft(adj, left):
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
    return cnt

def ribbon_images(u, c, Cm_set):
    m = len(u)
    out = set()
    def rec(s, cur):
        if s == m:
            out.add(tuple(cur)); return
        for i in range(3):
            a = tuple(u[s][j] + (1 if j == i else 0) for j in range(3))
            if not in_S(a, c): continue
            if s > 0 and not leq(a, cur[-1]): continue
            rec(s+1, cur + [a])
    rec(0, [])
    return [w for w in out if w in Cm_set]

def test(d, c, m, W, mode):
    Cm_img_list = chains(c, m, W + m)
    Cm_set = set(Cm_img_list)
    dom_all = chains(c, m, W)
    byw = defaultdict(list)
    for ch in dom_all:
        byw[wt(ch)].append(ch)
    imgbyw = defaultdict(list)
    for ch in Cm_img_list:
        imgbyw[wt(ch)].append(ch)
    allok = True
    worst = 0
    for N in sorted(byw):
        left = byw[N]
        adj = {}
        for u in left:
            if mode == "ribbon":
                adj[u] = ribbon_images(u, c, Cm_set)
            else:  # rich: any w >= u with wt +m
                adj[u] = [w for w in imgbyw[N+m]
                          if all(leq(u[s], w[s]) for s in range(m))]
        cnt = hopcroft(adj, left)
        if cnt < len(left):
            allok = False
            worst = max(worst, len(left)-cnt)
            dead = [u for u in left if not adj[u]]
            print(f"  HALL FAIL [{mode}] d={d} c={c} m={m} wt={N}: {cnt}/{len(left)} deadends={len(dead)}")
            if dead: print("    deadend:", dead[0])
    print(f"{'OK' if allok else 'FAIL'} [{mode}] d={d} c={c} m={m} W={W} |dom|={len(dom_all)} maxdef={worst}")
    sys.stdout.flush()
    return allok

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
    for mode in ["ribbon", "rich"]:
        ok = True
        for (d, c, m, W) in cases:
            ok = test(d, c, m, W, mode) and ok
        print(f"MOVE-SET {mode}: {'VIABLE (Hall holds everywhere)' if ok else 'INADEQUATE'}")
        sys.stdout.flush()
