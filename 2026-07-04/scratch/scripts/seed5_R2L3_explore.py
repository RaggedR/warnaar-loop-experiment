#!/usr/bin/env python3
"""Explore bounded crystal: components, sources, phi/eps stats, totality."""
import sys
sys.path.insert(0, '.')
from seed5_R2L3_crystal import *

def explore(c, m, W, d):
    sgn, tdir = 1, 1
    CH = all_chains(c, m, W, require_bottom_nonzero=False)
    CHset = set(CH)
    print(f"d={d} c={c} m={m} W={W}: {len(CH)} bounded chains (max<=m)")
    # totality stats on C_m (bottom nonzero)
    no_f = []; no_e = []
    for A in CH:
        phis = []
        epss = []
        for kappa in range(d):
            ph, ep = phi_eps(A, c, m, kappa, d, sgn, tdir)
            phis.append(ph); epss.append(ep)
        if sum(phis) == 0: no_f.append(A)
        if sum(epss) == 0: no_e.append(A)
    print(f"  chains with NO f_kappa applicable: {len(no_f)}")
    for A in no_f[:10]:
        print(f"    {A} wt={weight(A)} bottom={A[-1]}")
    print(f"  sources (no e_kappa applicable): {len(no_e)}")
    wts = {}
    for A in no_e:
        wts.setdefault(weight(A), []).append(A)
    for w in sorted(wts):
        print(f"    wt={w}: {len(wts[w])}: {wts[w] if len(wts[w])<=6 else wts[w][:6]}")
    # components via union-find on f-edges (within weight <= W)
    parent = {A: A for A in CH}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry: parent[rx] = ry
    for A in CH:
        for kappa in range(d):
            B = f_op(A, c, m, kappa, d, sgn, tdir)
            if B is not None and B in CHset:
                union(A, B)
    comps = {}
    for A in CH:
        comps.setdefault(find(A), []).append(A)
    print(f"  components (W-truncated!): {len(comps)}")
    # component weight GFs: min weight, sources per component
    info = []
    for root, mem in comps.items():
        srcs = [A for A in mem if all(phi_eps(A, c, m, k, d, sgn, tdir)[1] == 0 for k in range(d))]
        minw = min(weight(A) for A in mem)
        info.append((minw, len(mem), len(srcs)))
    info.sort()
    from collections import Counter
    print("  (minwt, size, #sources) counts:", Counter((a, cc) for a, b, cc in info))
    lowinfo = [x for x in info if x[0] <= 3]
    print("  low components:", lowinfo[:20])

if __name__ == "__main__":
    explore((2,1,1), 2, 9, 4)
    explore((0,2,2), 2, 9, 4)
    explore((2,1,1), 3, 10, 4)
