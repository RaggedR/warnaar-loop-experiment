#!/usr/bin/env python3
"""Component analysis of the bounded chain crystal (colors mod d, sgn=+1,tdir=+1).

For each connected component (within weight <= W): source (unique e-min element),
its weight w0, its phi-vector (phi_kappa = #surviving '(' per color) = <Lambda,h_k>,
and the truncated character (counts by weight - w0).
Tests:
  H1: components with equal phi-vector (up to rotation? exactly) have equal
      truncated characters (as far as both are complete, i.e. up to W - max(w0)).
  H2: sum over components of q^{w0} char = G_m(q).  (sanity)
Also report: source list per (d,c,m), phi vectors, and how source sets differ
between bound m-1 and m.
"""
import importlib.util
from collections import defaultdict
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)
SGN, TDIR = 1, 1

class DSU:
    def __init__(s): s.p = {}
    def find(s, x):
        while s.p.setdefault(x, x) != x:
            s.p[x] = s.p[s.p[x]]; x = s.p[x]
        return x
    def union(s, a, b): s.p[s.find(a)] = s.find(b)

def analyze(d, c, m, W, verbose=True):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    Xset = set(X)
    dsu = DSU()
    for A in X:
        for kappa in range(d):
            B = crys.f_op(A, c, m, kappa, d, SGN, TDIR)
            if B is not None and B in Xset:
                dsu.union(A, B)
    comps = defaultdict(list)
    for A in X: comps[dsu.find(A)].append(A)
    info = []
    for root, mem in comps.items():
        # source(s): no e_kappa defined
        srcs = []
        for A in mem:
            if all(crys.e_op(A, c, m, kappa, d, SGN, TDIR) is None for kappa in range(d)):
                srcs.append(A)
        char = defaultdict(int)
        for A in mem: char[crys.weight(A)] += 1
        w0 = min(char)
        rel = tuple(char.get(w0+k, 0) for k in range(W - w0 + 1))
        phis = []
        for A in srcs:
            phi = []
            for kappa in range(d):
                adds, rems = crys.reduce_brackets(
                    crys.boxes_add_remove(A, c, m, kappa, d, SGN, TDIR))
                phi.append(len(adds))
            phis.append(tuple(phi))
        info.append((w0, srcs, phis, rel, len(mem)))
    info.sort()
    if verbose:
        print(f"d={d} c={c} m={m} W={W}: |X|={len(X)}, #components={len(info)}")
        for w0, srcs, phis, rel, sz in info:
            trunc = W - w0
            print(f"  w0={w0} #src={len(srcs)} phi={phis} size={sz}")
            print(f"     src={srcs}")
            print(f"     char[0..{trunc}]={rel[:trunc+1]}")
    # H1 check: group by phi (single source expected)
    bad = []
    byphi = defaultdict(list)
    for w0, srcs, phis, rel, sz in info:
        if len(srcs) != 1: bad.append(("multi-source", w0, srcs))
        byphi[phis[0] if phis else None].append((w0, rel))
    for phi, lst in byphi.items():
        if len(lst) < 2: continue
        # compare truncated chars pairwise on common valid range
        for i in range(len(lst)):
            for j in range(i+1, len(lst)):
                w0i, ri = lst[i]; w0j, rj = lst[j]
                n = min(W - w0i, W - w0j) + 1
                if ri[:n] != rj[:n]:
                    bad.append(("char-mismatch", phi, (w0i, ri[:n]), (w0j, rj[:n])))
    print(f"  H1 violations: {len(bad)}")
    for b in bad[:6]: print(f"    {b}")
    return info

if __name__ == "__main__":
    for (d, c, m, W) in [(4,(2,1,1),1,10), (4,(2,1,1),2,10), (4,(2,1,1),3,10),
                          (4,(0,2,2),2,10), (4,(4,0,0),2,10),
                          (5,(3,1,1),2,9)]:
        analyze(d, c, m, W)
        print()
