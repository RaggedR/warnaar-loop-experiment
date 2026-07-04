#!/usr/bin/env python3
"""beta-map test (Session 2, RESULT-4 follow-up).

Candidate injection for the Y-term of the RESULT 3 three-term inequality:
  beta: Y = {A in vac(X_m): max(A) = m-1}  ->  U = {max = m},  weight +1,
  beta(A) = f_kappa(A) for some color kappa such that the added box lands at
  level m (necessarily at (i, 1, m) for some column i).

Injectivity is AUTOMATIC given totality (Seed 4 L4 Step 1 proved ef = id):
the image B has a unique level-m box; its color determines kappa; A = e_kappa(B).

TEST T1 (totality): for every A in Y (BFS-complete weights only), does some
kappa in Z/d have f_kappa(A) adding its box at level m?
TEST T2 (image profile): image of the canonical choice (smallest column i)
vs |{B in U : exactly one level-m box}| — data for co-designing alpha.
TEST T3 (stronger local statement, for proof design): for A in Y, for which
partition-addable level-m boxes b does f_{color(b)}(A) add exactly b?
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


def added_box(A, B):
    for s in range(len(A)):
        for i in range(3):
            if B[s][i] != A[s][i]:
                return (i, B[s][i], s + 1)
    return None


def test(d, c, m, W):
    vac = vac_component(c, m, W, d)
    Off = crys.offsets(c)
    Y = [A for A in vac if maxpart(A) == m - 1]
    U = {A for A in vac if maxpart(A) == m}
    fails_T1 = 0
    n_multi = 0
    n_checked = 0
    img = set()
    t3_add_total = t3_add_hit = 0
    for A in Y:
        if crys.weight(A) + 1 > W:
            continue
        n_checked += 1
        hits = []
        for k in range(d):
            B = crys.f_op(A, c, m, k, d, SGN, TDIR)
            if B is None:
                continue
            box = added_box(A, B)
            if box[2] == m:
                hits.append((k, B, box))
        for i in range(3):
            if A[m - 1][i] == 0 and A[m - 2][i] > 0:
                t3_add_total += 1
                kb = (m - 1 + Off[i]) % d
                B = crys.f_op(A, c, m, kb, d, SGN, TDIR)
                if B is not None and added_box(A, B) == (i, 1, m):
                    t3_add_hit += 1
        if not hits:
            fails_T1 += 1
            if fails_T1 <= 5:
                print(f"  T1 FAIL d={d} c={c} m={m}: A={A}")
            continue
        if len(hits) > 1:
            n_multi += 1
        k, B, box = min(hits, key=lambda h: h[2][0])
        assert B in U, "image left the stratum?!"
        img.add(B)
    one_box_U = {B for B in U if sum(B[m - 1]) == 1}
    print(f"d={d} c={c} m={m} W={W}: |Y|={len(Y)} checked={n_checked} "
          f"T1 {'OK' if fails_T1 == 0 else f'FAILS x{fails_T1}'}; "
          f"multi-hit {n_multi}; |img|={len(img)} (inj={'OK' if len(img)==n_checked else 'FAIL'}); "
          f"|U one-level-m-box|={len(one_box_U)}; "
          f"T3 chosen-by-own-color: {t3_add_hit}/{t3_add_total}")
    return fails_T1 == 0 and len(img) == n_checked


if __name__ == "__main__":
    allok = True
    for (d, c, m, W) in [(4, (2, 1, 1), 2, 11), (4, (2, 1, 1), 3, 12),
                         (4, (0, 2, 2), 2, 11), (4, (0, 2, 2), 3, 12),
                         (4, (4, 0, 0), 2, 11), (4, (4, 0, 0), 3, 12),
                         (4, (0, 3, 1), 2, 11), (4, (0, 3, 1), 3, 11),
                         (5, (3, 1, 1), 2, 11), (5, (3, 1, 1), 3, 11),
                         (7, (3, 2, 2), 2, 10), (8, (3, 3, 2), 2, 10),
                         (2, (1, 1, 0), 2, 10), (2, (1, 1, 0), 3, 10),
                         (2, (1, 1, 0), 4, 11), (2, (2, 0, 0), 3, 10),
                         (2, (2, 0, 0), 4, 11)]:
        allok &= test(d, c, m, W)
    print("ALL OK" if allok else "SOME FAILURES")
