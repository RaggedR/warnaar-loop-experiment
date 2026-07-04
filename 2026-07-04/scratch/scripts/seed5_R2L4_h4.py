#!/usr/bin/env python3
"""H4 test: profile translation T_k (add profile c to first k levels) as boson mode.

(a) T_m(vac(X_m)) subseteq vac(X_m) (hence subseteq U)?  Test on all A in vac with
    weight(A) + m*d <= W (BFS-complete range).
    Also: char(U \ T_m(vac)) == w_m := s_m - q^{md} b_m ?
(b) vac(X_m) cap {max <= m-1}  ==  vac(X_{m-1}) \ T_{m-1}(vac(X_{m-1}))
    (as SETS, via append-zero-level embedding), weight-truncated suitably.
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


def T(A, c, k):
    return tuple(tuple(A[s][i] + c[i] for i in range(3)) if s < k else A[s]
                 for s in range(len(A)))


def char(S, W):
    g = [0] * (W + 1)
    for A in S:
        w = crys.weight(A)
        if w <= W:
            g[w] += 1
    return g


def test(d, c, m, W):
    vac_m = vac_component(c, m, W, d)
    md = m * d
    # (a)
    dom = [A for A in vac_m if crys.weight(A) + md <= W]
    bad_a = [A for A in dom if T(A, c, m) not in vac_m]
    U = {A for A in vac_m if maxpart(A) == m}
    timg = {T(A, c, m) for A in dom}
    assert timg <= {A for A in vac_m if maxpart(A) == m} or bad_a, "T image not max=m?"
    # char(U \ T(vac)) vs w_m = s_m - q^{md} b_m; equivalent check:
    # char(U) - char(timg-restricted) — only reliable to W (timg complete to W since dom complete)
    chU = char(U, W)
    chT = char(timg, W) if not bad_a else None
    # w_m via next bound m+1... instead use algebra: w_m = char(U) - q^{md} char(vac_m)
    chvac = char(vac_m, W)
    wm_alg = [chU[w] - (chvac[w - md] if w >= md else 0) for w in range(W + 1)]
    diff_ok = None
    if chT is not None:
        diff = [chU[w] - chT[w] for w in range(W + 1)]
        diff_ok = (diff == wm_alg)  # holds iff T injective into U with char q^{md} b_m
    # (b)
    vac_m1 = vac_component(c, m - 1, W, d)
    k1d = (m - 1) * d
    dom1 = {A for A in vac_m1 if crys.weight(A) + k1d <= W}
    timg1 = {T(A, c, m - 1) for A in dom1}
    lowstrat = {A[:-1] for A in vac_m if maxpart(A) <= m - 1}  # drop zero bottom level
    # compare on complete weight range: lowstrat complete to W; vac_m1 \ timg1 complete to W
    rhs = {A for A in vac_m1 if A not in timg1 and crys.weight(A) <= W}
    # note: timg1 is only complete for weights <= W (since dom1 complete to W-k1d) — fine.
    same = (lowstrat == rhs)
    print(f"d={d} c={c} m={m} W={W}: (a) T_m(vac) in vac: "
          f"{'OK' if not bad_a else f'FAIL x{len(bad_a)} e.g. {bad_a[0]}'} "
          f"[{len(dom)} tested]; U\\T == w_m: {diff_ok}; "
          f"(b) lowstrat == vac(X_(m-1)) \\ T_(m-1): {'OK' if same else 'FAIL'} "
          f"[|lhs|={len(lowstrat)} |rhs|={len(rhs)}]")
    if not same:
        onlyL = list(lowstrat - rhs)[:3]; onlyR = list(rhs - lowstrat)[:3]
        print(f"    only-lhs: {onlyL}\n    only-rhs: {onlyR}")
    return (not bad_a) and diff_ok and same


if __name__ == "__main__":
    allok = True
    for (d, c, m, W) in [(4, (2, 1, 1), 2, 12), (4, (2, 1, 1), 3, 14),
                         (4, (0, 2, 2), 2, 12), (4, (0, 2, 2), 3, 14),
                         (4, (4, 0, 0), 2, 12), (4, (4, 0, 0), 3, 14),
                         (4, (0, 3, 1), 2, 12), (4, (0, 3, 1), 3, 13),
                         (5, (3, 1, 1), 2, 13), (5, (3, 1, 1), 3, 16),
                         (7, (3, 2, 2), 2, 15), (8, (3, 3, 2), 2, 17),
                         (2, (1, 1, 0), 2, 9), (2, (1, 1, 0), 3, 10),
                         (2, (1, 1, 0), 4, 11), (2, (2, 0, 0), 3, 10),
                         (2, (2, 0, 0), 4, 11)]:
        allok &= test(d, c, m, W)
    print("ALL OK" if allok else "SOME FAILURES")
