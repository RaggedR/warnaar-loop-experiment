#!/usr/bin/env python3
"""Test factorization G_m(q) = beta_m(q) * prod_{j=1}^{m-1} 1/(1-q^{jd}),
where beta_m = character of the crystal component of the EMPTY chain
(bounded operators, colors mod d), G_m = GF of all max<=m chains.

Also: is component of empty chain computable by BFS with f-ops only? Yes
(source unique + connected means f-closure of source = component... need e-closure
too in truncation? f-BFS from source gives everything reachable downward; since
source is the unique e-minimal and component connected, f-BFS suffices IF every
element has an e-path up to the source that stays... e f-paths: standard: every
element reached by f's from source? True in a highest-weight-like component? Not
automatic, so BFS with BOTH e and f, seeded at empty chain, weight <= W."""
import importlib.util
from collections import defaultdict, deque
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)
SGN, TDIR = 1, 1

def series_G(c, m, W):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    g = [0]*(W+1)
    for A in X: g[crys.weight(A)] += 1
    return g

def series_beta(c, m, W, d):
    empty = tuple(tuple((0,0,0)) for _ in range(m))
    seen = {empty}
    q = deque([empty])
    while q:
        A = q.popleft()
        for kappa in range(d):
            B = crys.f_op(A, c, m, kappa, d, SGN, TDIR)
            if B is not None and crys.weight(B) <= W and B not in seen:
                seen.add(B); q.append(B)
            Bp = crys.e_op(A, c, m, kappa, d, SGN, TDIR)
            if Bp is not None and Bp not in seen:
                seen.add(Bp); q.append(Bp)
    g = [0]*(W+1)
    for A in seen: g[crys.weight(A)] += 1
    return g

def mul(a, b, W):
    out = [0]*(W+1)
    for i, x in enumerate(a):
        if x == 0 or i > W: continue
        for j, y in enumerate(b):
            if i+j > W: break
            out[i+j] += x*y
    return out

def partsleq(k, step, W):
    # gen fn of partitions with <= k parts, parts multiples of step... parts size step*j any j>=1? 
    # prod_{j=1}^{k} 1/(1-q^{step*j})
    g = [0]*(W+1); g[0] = 1
    for j in range(1, k+1):
        s = step*j
        for w in range(s, W+1):
            g[w] += g[w-s]
    return g

def test(d, c, m, W):
    G = series_G(c, m, W)
    B = series_beta(c, m, W, d)
    P = partsleq(m-1, d, W)
    pred = mul(B, P, W)
    ok = pred == G
    print(f"d={d} c={c} m={m} W={W}: factorization {'HOLDS' if ok else 'FAILS'}")
    if not ok:
        print(f"   G   ={G}")
        print(f"   B*P ={pred}")
        print(f"   beta={B}")

if __name__ == "__main__":
    for (d, c, m, W) in [(4,(2,1,1),1,12), (4,(2,1,1),2,12), (4,(2,1,1),3,12),
                          (4,(2,1,1),4,12),
                          (4,(0,2,2),2,12), (4,(0,2,2),3,12),
                          (4,(4,0,0),2,12), (4,(0,3,1),2,12), (4,(0,3,1),3,11),
                          (5,(3,1,1),2,11), (5,(1,1,3),2,11), (5,(3,1,1),3,11),
                          (7,(3,2,2),2,10), (7,(1,2,4),2,10)]:
        test(d, c, m, W)
