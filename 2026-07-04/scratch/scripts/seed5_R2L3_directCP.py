#!/usr/bin/env python3
"""Direct CP enumeration from conjecture.tex definition, to adjudicate (0,3,1) mismatch.
c = (c_1,c_2,c_3); lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}}, lambda^(3)_j >= lambda^(1)_{j+c_1}.
max <= m, weight <= W. Compare with chain model conventions."""
import sys
from itertools import product

def partitions_max(m, W):
    """partitions with parts <= m and weight <= W, as tuples (weakly decr, no trailing 0)."""
    out = [()]
    def rec(prefix, last, rem):
        for p in range(min(last, rem), 0, -1):
            np = prefix + (p,)
            out.append(np)
            rec(np, p, rem - p)
    rec((), m, W)
    return out

def ok_pair(lam, mu, shift):
    # lam_j >= mu_{j+shift} for all j>=1
    for j in range(1, len(mu) - shift + 1):
        lamj = lam[j-1] if j-1 < len(lam) else 0
        if lamj < mu[j+shift-1]:
            return False
    return True

def gf_direct(c, m, W):
    c1, c2, c3 = c
    parts = partitions_max(m, W)
    out = [0]*(W+1)
    for l1 in parts:
        w1 = sum(l1)
        for l2 in parts:
            w2 = w1 + sum(l2)
            if w2 > W: continue
            if not ok_pair(l1, l2, c2): continue
            for l3 in parts:
                w = w2 + sum(l3)
                if w > W: continue
                if not ok_pair(l2, l3, c3): continue
                if not ok_pair(l3, l1, c1): continue
                out[w] += 1
    return out

W = 8
for c in [(0,3,1),(0,1,3),(1,3,0),(3,1,0),(2,1,1)]:
    for m in [1,2]:
        print(c, m, gf_direct(c, m, W))
