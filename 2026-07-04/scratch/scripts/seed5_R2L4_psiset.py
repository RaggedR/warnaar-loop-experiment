#!/usr/bin/env python3
"""U-term probe (handoff item 3): psi(A) = A + e_i at EVERY level (weight +m).
For A in vac(X_m) with max = m:
 Q3 (existence): is there i such that psi_i(A) is a valid chain?
 Q4 (vac closure): does every valid psi_i(A) stay in vac?
 Also: |bottom| >= 2 for images (disjointness from beta image) — automatic
 since bottom gains a box and already had >= 1.
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


def psi(A, i):
    return tuple(tuple(a[j] + (1 if j == i else 0) for j in range(3)) for a in A)


def test(d, c, m, W):
    vac = vac_component(c, m, W, d)
    Uw = [A for A in vac if maxpart(A) == m and crys.weight(A) + m <= W]
    q3_viol = q4_viol = 0
    nval = ninvac = 0
    for A in Uw:
        val = []
        for i in range(3):
            B = psi(A, i)
            if crys.valid_chain(B, c, m):
                val.append((i, B))
        if not val:
            q3_viol += 1
            if q3_viol <= 3:
                print(f"  Q3 viol d={d} c={c} m={m}: A={A}")
        for i, B in val:
            nval += 1
            if B in vac:
                ninvac += 1
            else:
                q4_viol += 1
                if q4_viol <= 3:
                    print(f"  Q4 viol d={d} c={c} m={m}: A={A} i={i}")
    print(f"d={d} c={c} m={m} W={W}: |U dom|={len(Uw)}; "
          f"Q3 (exists valid i) {'HOLDS' if q3_viol == 0 else f'FAILS x{q3_viol}'}; "
          f"Q4 (vac closure) {'HOLDS' if q4_viol == 0 else f'FAILS x{q4_viol}'} "
          f"[valid={nval} invac={ninvac}]")
    return q3_viol == 0, q4_viol == 0


if __name__ == "__main__":
    q3all = q4all = True
    for (d, c, m, W) in [(4, (2, 1, 1), 2, 11), (4, (2, 1, 1), 3, 12),
                         (4, (0, 2, 2), 3, 12), (4, (4, 0, 0), 3, 12),
                         (4, (0, 3, 1), 3, 11), (5, (3, 1, 1), 3, 11),
                         (7, (3, 2, 2), 2, 10), (8, (3, 3, 2), 2, 10),
                         (2, (1, 1, 0), 3, 10), (2, (1, 1, 0), 4, 11),
                         (2, (2, 0, 0), 4, 11), (2, (0, 1, 1), 3, 10)]:
        a, b = test(d, c, m, W)
        q3all &= a; q4all &= b
    print(f"SUMMARY: Q3 {'ALL HOLD' if q3all else 'FAILS somewhere'}; "
          f"Q4 {'ALL HOLD' if q4all else 'FAILS somewhere'}")
