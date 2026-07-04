#!/usr/bin/env python3
"""Exhaustive: every v-chain has eps_kappa = 0 for all kappa (IS A SOURCE),
all d<=8, all profiles, m<=5, k_1<=6. Also record word shapes (reduced form)."""
import sys
from collections import Counter
sys.path.insert(0, '.')
from seed5_R2L3_crystal import boxes_add_remove, reduce_brackets

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

def ksequences(m, kmax):
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

bad = 0; checked = 0
shapes = Counter()
for d in range(2, 9):
    for c in profiles(d):
        for m in range(1, 6):
            for ks in ksequences(m, 6):
                A = tuple(vvec(c, k) for k in ks)
                for kappa in range(d):
                    br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
                    adds, rems = reduce_brackets(br)
                    checked += 1
                    w = ''.join('(' if t==1 else ')' for (_,t,_) in br)
                    shapes[w[:14]] += 0  # placeholder
                    if len(rems) != 0:
                        bad += 1
                        if bad <= 10:
                            print("NOT SOURCE:", d, c, m, ks, "kappa", kappa,
                                  "eps", len(rems), "word", w)
print(f"checked: {checked} color-word eps-values; nonzero eps: {bad}")
