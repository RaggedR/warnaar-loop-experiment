#!/usr/bin/env python3
"""Relaxed beta-map probe: for A in vac(X_m) with max = m-1, which level-m
single-box additions A + e_i^(m) are (a) S-valid chains, (b) stay in vac?
Question Q1: does S-valid  ==>  in-vac  hold (locality of the totality lemma)?
Question Q2 (weaker): is there always >= 1 in-vac choice (relaxed beta total)?
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


def test(d, c, m, W):
    vac = vac_component(c, m, W, d)
    Y = [A for A in vac if maxpart(A) == m - 1 and crys.weight(A) + 1 <= W]
    q1_viol = 0; q2_viol = 0; nY = 0; svalid_tot = 0; invac_tot = 0
    for A in Y:
        nY += 1
        sv, iv = [], []
        for i in range(3):
            bott = [0, 0, 0]; bott[i] = 1
            B = A[:-1] + (tuple(bott),)
            if crys.valid_chain(B, c, m):
                sv.append(i)
                if B in vac:
                    iv.append(i)
        svalid_tot += len(sv); invac_tot += len(iv)
        if set(sv) != set(iv):
            q1_viol += 1
            if q1_viol <= 3:
                print(f"  Q1 viol d={d} c={c} m={m}: A={A} S-valid={sv} in-vac={iv}")
        if not iv:
            q2_viol += 1
            print(f"  Q2 VIOLATION d={d} c={c} m={m}: A={A}")
    print(f"d={d} c={c} m={m} W={W}: |Y|={nY}; Q1 (S-valid==in-vac) "
          f"{'HOLDS' if q1_viol == 0 else f'FAILS x{q1_viol}'} "
          f"[svalid={svalid_tot} invac={invac_tot}]; Q2 (total) "
          f"{'HOLDS' if q2_viol == 0 else f'FAILS x{q2_viol}'}")
    return q1_viol == 0, q2_viol == 0


if __name__ == "__main__":
    q1all = q2all = True
    for (d, c, m, W) in [(4, (2, 1, 1), 2, 11), (4, (2, 1, 1), 3, 12),
                         (4, (0, 2, 2), 3, 12), (4, (4, 0, 0), 3, 12),
                         (4, (0, 3, 1), 3, 11), (5, (3, 1, 1), 3, 11),
                         (5, (1, 1, 3), 3, 11), (7, (3, 2, 2), 2, 10),
                         (8, (3, 3, 2), 2, 10), (2, (1, 1, 0), 3, 10),
                         (2, (1, 1, 0), 4, 11), (2, (2, 0, 0), 4, 11),
                         (2, (0, 1, 1), 3, 10), (4, (2, 1, 1), 4, 13),
                         (4, (4, 0, 0), 4, 13)]:
        a, b = test(d, c, m, W)
        q1all &= a; q2all &= b
    print(f"SUMMARY: Q1 {'ALL HOLD' if q1all else 'FAILS somewhere'}; "
          f"Q2 {'ALL HOLD' if q2all else 'FAILS somewhere'}")
