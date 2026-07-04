#!/usr/bin/env python3
"""HALL-VACUUM test (RESULT 3 form): per weight w, is there a saturating matching
  left = U(w-m) u Y(w-1) u Z'(w-1-(m-1)d)  ->  right = U(w)
with CONTAINMENT edges (B >= A levelwise componentwise), inside vac(X_m)?
U = {max=m}, Y = {max=m-1}, Z' = {max<=m-2} in vac(X_m).
Reliable weights: w <= W (BFS complete to W)."""
import importlib.util
from collections import deque
BASE = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/"
spec = importlib.util.spec_from_file_location("fac", BASE + "seed5_R2L3_factor.py")
fac = importlib.util.module_from_spec(spec); spec.loader.exec_module(fac)
crys = fac.crys
SGN, TDIR = 1, 1

def vac_component(c, m, W, d):
    empty = tuple(tuple((0,0,0)) for _ in range(m))
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
        if a != (0,0,0): mp = s
    return mp

def contains(B, A):
    return all(B[s][i] >= A[s][i] for s in range(len(A)) for i in range(3))

def kuhn(adj, nleft, nright):
    matchR = [-1]*nright
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
        if try_k(u, [False]*nright): cnt += 1
    return cnt

def test(d, c, m, W):
    vac = vac_component(c, m, W, d)
    byw = {}
    for A in vac:
        byw.setdefault(crys.weight(A), []).append(A)
    U, Y, Z = {}, {}, {}
    for w, lst in byw.items():
        for A in lst:
            mp = maxpart(A)
            tgt = U if mp == m else (Y if mp == m-1 else Z)
            tgt.setdefault(w, []).append(A)
    sh = 1 + (m-1)*d
    worst = 0; allok = True
    for w in range(W+1):
        left = [(A, 'U') for A in U.get(w-m, [])] + [(A, 'Y') for A in Y.get(w-1, [])] \
             + [(A, 'Z') for A in Z.get(w-sh, [])]
        right = U.get(w, [])
        if not left: continue
        ridx = {B: j for j, B in enumerate(right)}
        adj = []
        for A, tag in left:
            adj.append([j for B, j in ridx.items() if contains(B, A)])
        matched = kuhn(adj, len(left), len(right))
        deficiency = len(left) - matched
        if deficiency > 0:
            allok = False
            worst = max(worst, deficiency)
            print(f"  d={d} c={c} m={m} w={w}: HALL FAIL |left|={len(left)} matched={matched} "
                  f"(|U|={len(U.get(w-m,[]))} |Y|={len(Y.get(w-1,[]))} |Z'|={len(Z.get(w-sh,[]))} -> |right|={len(right)})")
    print(f"d={d} c={c} m={m} W={W}: HALL-VACUUM containment "
          f"{'HOLDS (deficiency 0 all weights)' if allok else f'FAILS (worst deficiency {worst})'}")

if __name__ == "__main__":
    for (d, c, m, W) in [(4,(2,1,1),2,11),(4,(2,1,1),3,12),(4,(0,2,2),2,11),(4,(0,2,2),3,12),
                          (4,(4,0,0),2,11),(4,(4,0,0),3,12),(4,(0,3,1),2,11),(4,(0,3,1),3,11),
                          (5,(3,1,1),2,11),(5,(3,1,1),3,11),(7,(3,2,2),2,10),
                          (2,(1,1,0),2,10),(2,(1,1,0),3,10),(2,(1,1,0),4,11),
                          (2,(2,0,0),3,10),(2,(2,0,0),4,11),(8,(3,3,2),2,10)]:
        test(d, c, m, W)
