#!/usr/bin/env python3
"""Extended HALL-VACUUM verification + structure statistics.

For the RESULT 3 target  U(w-m) u Y(w-1) u Z'(w-1-(m-1)d) -> U(w) (containment):
 - extend the verified range (m=4 cases, more profiles);
 - per-weight SURPLUS  #U(w) - #left(w)  (tight weights force bijections);
 - min left-degree per part (singleton Hall); in particular the Y-part edge is
   necessarily 'add one box at level m', so min-degree >= 1 for Y proves the
   relaxed beta-map (set-level, not crystal-op) is TOTAL and injective standalone.
"""
import importlib.util
from collections import deque

BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("crys", BASE + "seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)
SGN, TDIR = 1, 1


def vac_component(c, m, W, d):
    empty = tuple(tuple((0, 0, 0)) for _ in range(m))
    seen = {empty}; q = deque([empty])
    while q:
        A = q.popleft()
        for k in range(d):
            for op in (crys.f_op, crys.e_op):
                B = op(A, c, m, k, d, SGN, TDIR)
                if B is not None and crys.weight(B) <= W and B not in seen:
                    seen.add(B); q.append(B)
    return seen


def maxpart(A):
    mp = 0
    for s, a in enumerate(A, 1):
        if a != (0, 0, 0):
            mp = s
    return mp


def contains(B, A):
    return all(B[s][i] >= A[s][i] for s in range(len(A)) for i in range(3))


def kuhn(adj, nleft, nright):
    matchR = [-1] * nright
    def try_k(u, vis):
        for v in adj[u]:
            if not vis[v]:
                vis[v] = True
                if matchR[v] == -1 or try_k(matchR[v], vis):
                    matchR[v] = u
                    return True
        return False
    cnt = 0
    for u in range(nleft):
        if try_k(u, [False] * nright):
            cnt += 1
    return cnt


def test(d, c, m, W):
    vac = vac_component(c, m, W, d)
    U, Y, Z = {}, {}, {}
    for A in vac:
        w = crys.weight(A)
        mp = maxpart(A)
        (U if mp == m else (Y if mp == m - 1 else Z)).setdefault(w, []).append(A)
    sh = 1 + (m - 1) * d
    allok = True
    min_deg = {'U': None, 'Y': None, 'Z': None}
    tight = []
    for w in range(W + 1):
        left = [(A, 'U') for A in U.get(w - m, [])] + [(A, 'Y') for A in Y.get(w - 1, [])] \
             + [(A, 'Z') for A in Z.get(w - sh, [])]
        right = U.get(w, [])
        if not left:
            continue
        adj = []
        for A, tag in left:
            nbrs = [j for j, B in enumerate(right) if contains(B, A)]
            adj.append(nbrs)
            dg = len(nbrs)
            if min_deg[tag] is None or dg < min_deg[tag]:
                min_deg[tag] = dg
        matched = kuhn(adj, len(left), len(right))
        if matched < len(left):
            allok = False
            print(f"  HALL FAIL d={d} c={c} m={m} w={w}: |left|={len(left)} matched={matched}")
        surplus = len(right) - len(left)
        if surplus <= 0:
            tight.append((w, surplus))
    print(f"d={d} c={c} m={m} W={W}: {'HALL OK' if allok else 'HALL FAIL'}; "
          f"min-deg U/Y/Z = {min_deg['U']}/{min_deg['Y']}/{min_deg['Z']}; "
          f"tight/negative-surplus weights: {tight if tight else 'none'}")
    return allok


if __name__ == "__main__":
    allok = True
    for (d, c, m, W) in [(4, (2, 1, 1), 4, 13), (4, (0, 2, 2), 4, 13),
                         (4, (4, 0, 0), 4, 13), (4, (0, 3, 1), 4, 12),
                         (5, (3, 1, 1), 4, 12), (5, (1, 1, 3), 2, 11),
                         (5, (1, 1, 3), 3, 11),
                         (7, (3, 2, 2), 3, 11), (7, (1, 2, 4), 2, 11),
                         (8, (3, 3, 2), 3, 11), (2, (1, 1, 0), 5, 11),
                         (2, (2, 0, 0), 5, 11), (2, (0, 1, 1), 3, 10)]:
        allok &= test(d, c, m, W)
    print("ALL OK" if allok else "SOME FAILURES")
