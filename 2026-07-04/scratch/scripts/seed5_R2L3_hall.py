#!/usr/bin/env python3
"""EXISTENCE test (Hall/matching) for the J-reduction with J = one crystal operator step.

For each weight w < W: bipartite graph X_w -> X_{w+1}, edges A -> f_kappa(A).
(P)-constraint: if maxlev(A) == m-1 (bottom zero, level exactly m-1), only allow
edges where the added box is at level s = m.
Question: does a matching saturating X_w exist for all w?  (Hopcroft-Karp)
Also test WITHOUT the crystal restriction: edges = add any single box (valid chain);
this tests whether the constrained-injection existence is about the poset itself.
"""
import importlib.util
from collections import defaultdict, deque
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)
SGN, TDIR = 1, 1

def maxlev(A, m):
    for s in range(m, 0, -1):
        if sum(A[s-1]) > 0: return s
    return 0

def crystal_edges(A, c, m, d):
    out = []
    for kappa in range(d):
        br = crys.boxes_add_remove(A, c, m, kappa, d, SGN, TDIR)
        adds, rems = crys.reduce_brackets(br)
        if adds:
            T, (i, s) = adds[0]
            out.append((crys.apply_add(A, i, s), s))
    return out

def allbox_edges(A, c, m, d):
    out = []
    for i in range(3):
        for s in range(1, m+1):
            B = crys.apply_add(A, i, s)
            if crys.valid_chain(B, c, m):
                out.append((B, s))
    return out

def hopcroft_karp(adj, left):
    INF = float('inf')
    matchL = {u: None for u in left}
    matchR = {}
    def bfs():
        dist = {}
        q = deque()
        for u in left:
            if matchL[u] is None:
                dist[u] = 0; q.append(u)
            else:
                dist[u] = INF
        found = False
        while q:
            u = q.popleft()
            for v in adj[u]:
                w = matchR.get(v)
                if w is None:
                    found = True
                elif dist.get(w, INF) == INF:
                    dist[w] = dist[u] + 1; q.append(w)
        return found, dist
    def dfs(u, dist):
        for v in adj[u]:
            w = matchR.get(v)
            if w is None or (dist.get(w) == dist[u] + 1 and dfs(w, dist)):
                matchL[u] = v; matchR[v] = u
                return True
        dist[u] = float('inf')
        return False
    res = 0
    while True:
        found, dist = bfs()
        if not found: break
        for u in left:
            if matchL[u] is None and dfs(u, dist):
                res += 1
    return res

def test(d, c, m, W, edgefun, label):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    byw = defaultdict(list)
    for A in X: byw[crys.weight(A)].append(A)
    ok = True
    for w in range(0, W):
        L = byw[w]
        if not L: continue
        adj = {}
        for A in L:
            ml = maxlev(A, m)
            edges = edgefun(A, c, m, d)
            if ml == m - 1:
                adj[A] = [B for (B, s) in edges if s == m]
            else:
                adj[A] = [B for (B, s) in edges]
        msize = hopcroft_karp(adj, L)
        if msize < len(L):
            ok = False
            print(f"  {label}: HALL FAILS at w={w}: matched {msize}/{len(L)}")
            # find a deficient set witness? just report unmatched examples
    if ok:
        print(f"  {label}: saturating (P)-constrained matching EXISTS for all w<{W}")

if __name__ == "__main__":
    cases = [(4,(2,1,1),1,8), (4,(2,1,1),2,9), (4,(2,1,1),3,9),
             (4,(0,2,2),2,9), (4,(4,0,0),2,9), (4,(0,3,1),2,9),
             (5,(3,1,1),2,8), (5,(1,1,3),2,8), (7,(3,2,2),2,8)]
    for (d, c, m, W) in cases:
        print(f"d={d} c={c} m={m} W={W}")
        test(d, c, m, W, crystal_edges, "crystal-f")
        test(d, c, m, W, allbox_edges, "any-box  ")
