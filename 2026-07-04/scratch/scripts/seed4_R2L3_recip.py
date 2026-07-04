#!/usr/bin/env python3
"""Reciprocity probes: for Q_1, H_1, N_2, har: is the reciprocal polynomial
q^deg P(1/q) equal (or simply related) to the same object at a transformed
profile (reversal, rotations, complement)?"""
from seed4_R2L3_engine import *

def recip(p):
    r = list(reversed(p)); return ptrim(r)

def transforms(c, d):
    yield 'id', c
    yield 'rev', (c[2], c[1], c[0])
    yield 'rev01', (c[1], c[0], c[2])
    yield 'rev12', (c[0], c[2], c[1])
    yield 'rot1', (c[1], c[2], c[0])
    yield 'rot2', (c[2], c[0], c[1])

for d in (4, 5, 7):
    ps, H = H_tower(d, 2)
    Q1 = {c: padd(H[1][c], [1], 1, -1) for c in ps}
    N2 = {}
    har = {}
    for c in ps:
        Q2 = padd(padd(H[2][c], pmul([1, 1], H[1][c]), 1, -1), [0, 1])
        N2[c] = pmul([1, 0, 1, 0, 1], Q2)
        h = []
        for cp in ps:
            if cp == c: continue
            h = padd(h, pshift(Q1[cp], 2*EMD(cp, c)))
        har[c] = padd(h, pmul([0, 1, 1, 1, 1, 1], Q1[c]), 1, -1)
    for name, obj in (('Q1', Q1), ('H1', {c: H[1][c] for c in ps}), ('N2', N2), ('har', har)):
        hits = {}
        for c in ps:
            r = recip(obj[c])
            found = None
            for tn, tc in transforms(c, d):
                if obj.get(tc) == r:
                    found = tn; break
            hits.setdefault(found, 0)
            hits[found] += 1
        print(f"d={d} {name}: reciprocal matches: {hits}")
