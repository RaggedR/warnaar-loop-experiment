#!/usr/bin/env python3
"""JOINT Hall test for the containment architecture of f_0^(m) >= 0.

f_0^(m) >= 0 <=> injections Theta: C_{m-1} -> C_m (wt+1) and psi: C_m -> C_m (wt+m),
jointly injective (disjoint images). Structural hope: both are CONTAINMENT maps
(image chain contains source chain as box sets, i.e. B >= A componentwise-levelwise).

Joint bipartite graph at target weight w:
  Left = C_{m-1} at w-1  (embedded as bottom-zero length-m chains)  [Theta side]
       + C_m at w-m                                                  [psi side]
  Right = C_m at w.
  Edges: B >= A levelwise (containment), with the right box-count difference.
Question: saturating matching for all w <= W?  If NO: every containment-based
(box-adding) design is impossible; proof must rearrange boxes.
"""
import importlib.util
from collections import defaultdict, deque
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)

def maxlev(A, m):
    for s in range(m, 0, -1):
        if sum(A[s-1]) > 0: return s
    return 0

def contains(B, A, m):
    return all(B[s][i] >= A[s][i] for s in range(m) for i in range(3))

def hopcroft_karp(adj, left):
    INF = float('inf'); matchL = {u: None for u in left}; matchR = {}
    def bfs():
        dist = {}; q = deque(); found = False
        for u in left:
            if matchL[u] is None: dist[u] = 0; q.append(u)
            else: dist[u] = INF
        while q:
            u = q.popleft()
            for v in adj[u]:
                w = matchR.get(v)
                if w is None: found = True
                elif dist.get(w, INF) == INF: dist[w] = dist[u] + 1; q.append(w)
        return found, dist
    def dfs(u, dist):
        for v in adj[u]:
            w = matchR.get(v)
            if w is None or (dist.get(w) == dist[u] + 1 and dfs(w, dist)):
                matchL[u] = v; matchR[v] = u; return True
        dist[u] = INF; return False
    res = 0
    while True:
        found, dist = bfs()
        if not found: break
        for u in left:
            if matchL[u] is None and dfs(u, dist): res += 1
    return res

def test(d, c, m, W):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    Cm = defaultdict(list); Cm1 = defaultdict(list)
    for A in X:
        ml = maxlev(A, m); w = crys.weight(A)
        if ml == m: Cm[w].append(A)
        elif ml == m-1: Cm1[w].append(A)
    allok = True
    for w in range(1, W+1):
        L = [("T", A) for A in Cm1.get(w-1, [])] + \
            ([("P", A) for A in Cm.get(w-m, [])] if w-m >= 0 else [])
        R = Cm.get(w, [])
        if not L: continue
        adj = {}
        for tag, A in L:
            adj[(tag, A)] = [B for B in R if contains(B, A, m)]
        msize = hopcroft_karp(adj, L)
        if msize < len(L):
            allok = False
            print(f"  JOINT HALL FAILS at w={w}: matched {msize}/{len(L)} (|R|={len(R)})")
    if allok:
        print(f"  joint containment matching EXISTS for all w<={W}")

if __name__ == "__main__":
    cases = [(4,(2,1,1),1,9), (4,(2,1,1),2,9), (4,(2,1,1),3,9),
             (4,(0,2,2),2,9), (4,(4,0,0),2,9), (4,(0,3,1),2,9),
             (5,(3,1,1),2,8), (5,(1,1,3),2,8), (7,(3,2,2),2,8),
             (4,(2,1,1),4,10), (4,(0,2,2),3,9)]
    for (d, c, m, W) in cases:
        print(f"d={d} c={c} m={m} W={W}")
        test(d, c, m, W)
