#!/usr/bin/env python3
"""Exhaustive check: for ALL v-chains (all d<=8, all profiles, m<=5, k_1<=6),
every color word W_kappa: (i) first letter '(' ; (ii) never two consecutive ')'.
This implies eps_kappa = 0 (v-chains are sources). Also collect the finer slot
data: for each removable letter, the T-gap to its predecessor letter and the
predecessor's identity (which column/level), to guide the hand proof."""
import sys
from itertools import combinations_with_replacement
sys.path.insert(0, '.')
from seed5_R2L3_crystal import boxes_add_remove

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def profiles(d):
    out = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            out.append((c0, c1, d-c0-c1))
    return out

def ksequences(m, kmax):
    # k_1 >= ... >= k_{m-1} >= 0, k_m = 0
    def rec(prefix, hi):
        if len(prefix) == m-1:
            yield tuple(prefix) + (0,)
            return
        for k in range(hi, -1, -1):
            yield from rec(prefix + [k], k)
    if m == 1:
        yield (0,)
    else:
        yield from rec([], kmax)

def main():
    bad = 0; checked = 0
    predinfo = {}
    for d in range(2, 9):
        for c in profiles(d):
            for m in range(1, 6):
                for ks in ksequences(m, 6):
                    A = tuple(vvec(c, k) for k in ks)
                    for kappa in range(d):
                        br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
                        checked += 1
                        prev = None
                        for (T, typ, pos) in br:
                            if typ == 0:
                                if prev is None or prev[1] == 0:
                                    bad += 1
                                    if bad <= 10:
                                        print("BAD:", d, c, m, ks, kappa,
                                              "rem", pos, "prev", prev)
                                else:
                                    gap = (T - prev[0]) // d
                                    key = min(gap, 9)
                                    predinfo[key] = predinfo.get(key, 0) + 1
                            prev = (T, typ, pos)
    print(f"checked color-words: {checked}, violations: {bad}")
    print("T-gap (in units of d) from removable to preceding addable letter:", predinfo)

main()
