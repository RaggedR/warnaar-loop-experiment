#!/usr/bin/env python3
"""Test candidate J maps (total injective weight+1 self-maps with bottom-fill property P).

J-reduction (see scratch log): if J: X -> X (X = bounded length-m chains, bottom may be 0)
satisfies (J1) total+injective+weight+1, (J2) adds boxes only, (P) A with a^(m)=0,
a^(m-1)!=0 ==> J adds at level m, then f_0^(m) >= 0.

Candidates (convention sgn=+1, tdir=+1, verified in seed5_R2L3_crystal):
  J_least : f_kappa for the least color kappa with f_kappa defined.
  J_tmin  : among all colors with f defined, apply f at the color whose target box
            (first surviving '(') has globally minimal T; tie-break by color.
  J_smax  : among candidate target boxes (first surviving '(' per color), pick the
            one with deepest level s (then min T, then color).  [bottom-preferring]
"""
import sys, importlib.util
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)

SGN, TDIR = 1, 1

def f_target(A, c, m, kappa, d):
    br = crys.boxes_add_remove(A, c, m, kappa, d, SGN, TDIR)
    adds, rems = crys.reduce_brackets(br)
    if not adds: return None
    T, (i, s) = adds[0]
    return (T, i, s)

def J_least(A, c, m, d):
    for kappa in range(d):
        t = f_target(A, c, m, kappa, d)
        if t is not None:
            T, i, s = t
            return crys.apply_add(A, i, s), (kappa, i, s)
    return None, None

def J_tmin(A, c, m, d):
    best = None
    for kappa in range(d):
        t = f_target(A, c, m, kappa, d)
        if t is not None:
            T, i, s = t
            key = (T, kappa)
            if best is None or key < best[0]:
                best = (key, kappa, i, s)
    if best is None: return None, None
    _, kappa, i, s = best
    return crys.apply_add(A, i, s), (kappa, i, s)

def J_smax(A, c, m, d):
    best = None
    for kappa in range(d):
        t = f_target(A, c, m, kappa, d)
        if t is not None:
            T, i, s = t
            key = (-s, T, kappa)
            if best is None or key < best[0]:
                best = (key, kappa, i, s)
    if best is None: return None, None
    _, kappa, i, s = best
    return crys.apply_add(A, i, s), (kappa, i, s)

RULES = {"J_least": J_least, "J_tmin": J_tmin, "J_smax": J_smax}

def maxlev(A, m):
    """largest s with a^(s) != 0, or 0."""
    for s in range(m, 0, -1):
        if sum(A[s-1]) > 0: return s
    return 0

def test(d, c, m, W):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    out = {}
    for name, rule in RULES.items():
        images = {}
        n_total_fail = 0; n_collide = 0; n_Pfail = 0; n_Pcases = 0
        Pfail_ex = None; coll_ex = None
        for A in X:
            B, info = rule(A, c, m, d)
            if B is None:
                n_total_fail += 1; continue
            if B in images:
                n_collide += 1
                if coll_ex is None: coll_ex = (images[B], A, B)
            else:
                images[B] = A
            ml = maxlev(A, m)
            if ml == m - 1:
                n_Pcases += 1
                kappa, i, s = info
                if s != m:
                    n_Pfail += 1
                    if Pfail_ex is None: Pfail_ex = (A, info)
        out[name] = (n_total_fail, n_collide, n_Pcases, n_Pfail, coll_ex, Pfail_ex)
    return out, len(X)

if __name__ == "__main__":
    cases = [(4,(2,1,1),1,8), (4,(2,1,1),2,9), (4,(2,1,1),3,9),
             (4,(0,2,2),2,9), (4,(4,0,0),2,8), (4,(0,3,1),2,8),
             (5,(3,1,1),2,8), (5,(1,1,3),2,8), (7,(3,2,2),2,8)]
    for (d, c, m, W) in cases:
        out, nX = test(d, c, m, W)
        print(f"d={d} c={c} m={m} W={W}  |X|={nX}")
        for name, (tf, col, pc, pf, cex, pex) in out.items():
            print(f"  {name:8s}: total_fail={tf} collisions={col} Pcases={pc} Pfail={pf}")
            if col and cex:
                print(f"      coll ex: {cex[0]} & {cex[1]} -> {cex[2]}")
            if pf and pex:
                print(f"      Pfail ex: {pex[0]} added {pex[1]}")
