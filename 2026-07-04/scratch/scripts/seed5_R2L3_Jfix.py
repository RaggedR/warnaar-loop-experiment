#!/usr/bin/env python3
"""Fixed-point J design: choose color via IMAGE-side canonical rule K.

J(A) = f_kappa(A) for kappa in FP(A) = {kappa : f_kappa(A) defined, K(f_kappa(A)) = kappa}.
Injectivity is STRUCTURAL: A = e_{K(B)}(B).  Tie-break within FP(A) is free
==> use it to favor property (P) (add at level m when bottom is zero).
Only TOTALITY (FP(A) nonempty) needs testing.

Image-side rules K tested:
  K_least(B) = least kappa with eps_kappa(B) > 0
  K_tmax(B)  = color of globally T-maximal surviving ')' across all colors
  K_smax(B)  = color of surviving ')' with (max s, then max T, then max color)
"""
import importlib.util
spec = importlib.util.spec_from_file_location("crys",
    "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L3_crystal.py")
crys = importlib.util.module_from_spec(spec); spec.loader.exec_module(crys)
SGN, TDIR = 1, 1

def surviving(B, c, m, kappa, d):
    br = crys.boxes_add_remove(B, c, m, kappa, d, SGN, TDIR)
    return crys.reduce_brackets(br)

def K_least(B, c, m, d):
    for kappa in range(d):
        adds, rems = surviving(B, c, m, kappa, d)
        if rems: return kappa
    return None

def K_tmax(B, c, m, d):
    best = None
    for kappa in range(d):
        adds, rems = surviving(B, c, m, kappa, d)
        if rems:
            T, (i, s) = rems[-1]  # the box e_kappa would remove
            key = (T, kappa)
            if best is None or key > best[0]: best = (key, kappa)
    return None if best is None else best[1]

def K_smax(B, c, m, d):
    best = None
    for kappa in range(d):
        adds, rems = surviving(B, c, m, kappa, d)
        if rems:
            T, (i, s) = rems[-1]
            key = (s, T, kappa)
            if best is None or key > best[0]: best = (key, kappa)
    return None if best is None else best[1]

KRULES = {"K_least": K_least, "K_tmax": K_tmax, "K_smax": K_smax}

def f_target(A, c, m, kappa, d):
    adds, rems = surviving(A, c, m, kappa, d)
    if not adds: return None
    T, (i, s) = adds[0]
    return (T, i, s)

def maxlev(A, m):
    for s in range(m, 0, -1):
        if sum(A[s-1]) > 0: return s
    return 0

def test(d, c, m, W):
    X = crys.all_chains(c, m, W, require_bottom_nonzero=False)
    print(f"d={d} c={c} m={m} W={W}  |X|={len(X)}")
    for name, K in KRULES.items():
        n_empty = 0; empty_ex = []
        n_Pcases = 0; n_Pfail = 0; pfail_ex = []
        images = {}; n_coll = 0
        for A in X:
            FP = []
            for kappa in range(d):
                t = f_target(A, c, m, kappa, d)
                if t is None: continue
                T, i, s = t
                B = crys.apply_add(A, i, s)
                if K(B, c, m, d) == kappa:
                    FP.append((kappa, i, s, B))
            if not FP:
                n_empty += 1
                if len(empty_ex) < 3: empty_ex.append(A)
                continue
            ml = maxlev(A, m)
            # tie-break: prefer s == m if bottom empty (property P), else first
            choice = None
            if ml == m - 1:
                n_Pcases += 1
                for (kappa, i, s, B) in FP:
                    if s == m: choice = (kappa, i, s, B); break
                if choice is None:
                    n_Pfail += 1
                    if len(pfail_ex) < 3: pfail_ex.append((A, FP))
                    choice = FP[0]
            else:
                choice = FP[0]
            kappa, i, s, B = choice
            if B in images: n_coll += 1   # sanity: should be 0
            else: images[B] = A
        print(f"  {name:7s}: FP_empty={n_empty} collisions={n_coll} Pcases={n_Pcases} Pfail={n_Pfail}")
        for A in empty_ex: print(f"      empty ex: {A}")
        for A, FP in pfail_ex: print(f"      Pfail ex: {A} FP={[(k,i,s) for k,i,s,_ in FP]}")

if __name__ == "__main__":
    cases = [(4,(2,1,1),1,8), (4,(2,1,1),2,9), (4,(2,1,1),3,9),
             (4,(0,2,2),2,9), (4,(4,0,0),2,8), (4,(0,3,1),2,8),
             (5,(3,1,1),2,8), (5,(1,1,3),2,8), (7,(3,2,2),2,8)]
    for case in cases:
        test(*case)
