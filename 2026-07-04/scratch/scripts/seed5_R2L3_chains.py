#!/usr/bin/env python3
"""Seed 5 R2L3: chain model infrastructure + f_0^(m) tables + deficit analysis.

Chain model (Seed 8 L2, GREEN):
  CP of profile c=(c_0,c_1,c_2), max <= m  <->  chain a^(1) >= ... >= a^(m),
  a^(s) in S = {a in Z_{>=0}^3 : a_i <= a_{i-1} + c_i, i in Z/3}.
  weight = sum_s |a^(s)|;  max EXACTLY m <=> a^(m) != 0.

f_0^(m) = (1-q^m) g_m - q g_{m-1}  (want >= 0 coefficientwise).

Cross-check route: H-recursion (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}.
"""
from itertools import product
import sys

def padd(a, b):
    n = max(len(a), len(b))
    return [ (a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n) ]

def psub(a, b):
    n = max(len(a), len(b))
    return [ (a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0) for i in range(n) ]

def pmul(a, b, prec=None):
    if not a or not b: return [0]
    if prec is None: prec = len(a) + len(b) - 1
    out = [0]*min(prec, len(a)+len(b)-1)
    for i, ai in enumerate(a):
        if ai == 0: continue
        for j, bj in enumerate(b):
            if i+j >= len(out): break
            out[i+j] += ai*bj
    return out

def pshift(a, k):
    return [0]*k + list(a)

def pdivexact(a, b, prec):
    a = list(a) + [0]*max(0, prec-len(a)); a = a[:prec]
    out = [0]*prec
    inv0 = b[0]
    assert abs(inv0) == 1
    r = list(a)
    for i in range(prec):
        q = r[i]*inv0
        out[i] = q
        if q:
            for j, bj in enumerate(b):
                if i+j < prec:
                    r[i+j] -= q*bj
    return out

def in_S(a, c):
    return all(a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states_upto(c, W):
    out = []
    for a0 in range(W+1):
        for a1 in range(W+1-a0):
            for a2 in range(W+1-a0-a1):
                a = (a0,a1,a2)
                if in_S(a, c):
                    out.append(a)
    return out

def geq(a, b):
    return all(a[i] >= b[i] for i in range(3))

def chains(c, m, W):
    if m == 0:
        return [()]
    Svals = [a for a in states_upto(c, W) if sum(a) >= 1]
    result = []
    def extend(chain_rev, wt):
        depth = len(chain_rev)
        if depth == m:
            result.append(tuple(reversed(chain_rev)))
            return
        top = chain_rev[-1]
        for nxt in Svals:
            sn = sum(nxt)
            if sn < sum(top): continue
            if wt + sn > W: continue
            if not geq(nxt, top): continue
            extend(chain_rev + [nxt], wt + sn)
    for bot in Svals:
        if sum(bot)*m <= W:
            extend([bot], sum(bot))
    return result

def gf_g(c, m, W):
    out = [0]*(W+1)
    if m == 0:
        out[0] = 1
        return out
    for ch in chains(c, m, W):
        out[sum(sum(a) for a in ch)] += 1
    return out

def EMD(a, b):
    return 3*max(0, b[1]-a[1], a[0]-b[0]) + (b[0]-a[0]) - (b[1]-a[1])

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def H_tables(d, mmax, prec):
    profs = profiles(d)
    H = {(p, 0): [1] for p in profs}
    for m in range(1, mmax+1):
        div = [0]*(2*m+1); div[0] = 1; div[m] = 1; div[2*m] = 1
        for cprof in profs:
            rhs = [0]
            for cp in profs:
                e = EMD(cp, cprof)
                rhs = padd(rhs, pshift(H[(cp, m-1)], m*e))
            H[(cprof, m)] = pdivexact(rhs, div, prec)
    return H

def F_from_H(Hcm, m, prec):
    poch = [1]
    for i in range(1, m+1):
        poch = pmul(poch, psub([1], pshift([1], i)), prec)
    return pdivexact(Hcm, poch, prec)

def main():
    W = int(sys.argv[1]) if len(sys.argv) > 1 else 14
    MM = 4
    for d, cs in [(4, [(2,1,1), (4,0,0), (1,1,2), (0,2,2), (0,3,1)]),
                  (5, [(3,1,1), (2,2,1)]),
                  (7, [(3,2,2), (4,2,1)])]:
        H = H_tables(d, MM, W+2)
        for c in cs:
            print(f"=== d={d} c={c} ===")
            g = {mm: gf_g(c, mm, W) for mm in range(0, MM+1)}
            for m in range(1, MM+1):
                f0 = psub(psub(g[m], pshift(g[m], m)), pshift(g[m-1], 1))
                f0 = f0[:W+1]
                neg = [i for i, x in enumerate(f0) if x < 0]
                print(f" m={m}: g_m={g[m]}")
                print(f"        f0={f0}  neg@{neg}")
                Fm = F_from_H(H[(c, m)], m, W+1)
                Fm1 = F_from_H(H[(c, m-1)], m-1, W+1)
                gH = psub(Fm, Fm1)[:W+1]
                ok = all((g[m][i] if i < len(g[m]) else 0) == gH[i] for i in range(W+1))
                print(f"        H-route match: {ok}")
                if not ok:
                    print(f"        gH={gH}")
    print("done")

if __name__ == "__main__":
    main()
