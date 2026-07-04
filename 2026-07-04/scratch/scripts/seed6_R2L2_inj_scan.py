#!/usr/bin/env python3
"""Scan d = 4,6,7,10,11: for every zero-containing orbit, find an R-relation variant
satisfying INJ (with ell = gcd(d,3) prefactor). Report summary."""
import sys
from itertools import combinations
from math import gcd
sys.setrecursionlimit(10000)

PREC = 420
NMAX = 4

def padd(a, b, scale=1, shift=0):
    for i, x in enumerate(b):
        j = i + shift
        if j >= PREC: break
        if x: a[j] += scale * x
    return a

def pmul(a, b):
    res = [0]*PREC
    for i, x in enumerate(a):
        if x == 0: continue
        for j, y in enumerate(b):
            if i + j >= PREC: break
            if y: res[i+j] += x*y
    return res

def poch_ell(n, ell):
    res = [0]*PREC; res[0] = 1
    for i in range(1, n+1):
        f = [0]*PREC; f[0] = 1; f[ell*i] = -1
        res = pmul(res, f)
    return res

def canon(c): return max(tuple(c[i:] + c[:i]) for i in range(len(c)))
def Ic(c): return [i for i in range(3) if c[i] > 0]
def cJ(c, J):
    Js = set(J); out = []
    for i in range(3):
        prev = (i-1) % 3
        if i in Js and prev not in Js: out.append(c[i]-1)
        elif i not in Js and prev in Js: out.append(c[i]+1)
        else: out.append(c[i])
    return tuple(out)

def all_orbits(d):
    seen, reps = set(), []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c = (c0, c1, d-c0-c1); k = canon(c)
            if k not in seen: seen.add(k); reps.append(k)
    return reps

def enum_r(c):
    I = Ic(c)
    if len(I) == 1:
        return [(cJ(c, (I[0],)), ())]
    out = []
    for j2 in I:
        j1 = [j for j in I if j != j2][0]
        cj2 = cJ(c, (j2,))
        if len(Ic(cj2)) == 3: continue
        pair = cJ(c, tuple(sorted((j1, j2))))
        for h, t in enum_r(cj2):
            if canon(h) == canon(pair):
                out.append((cJ(c, (j1,)), (pair,) + t))
    seen, ded = set(), []
    for h, t in out:
        key = (canon(h), tuple(canon(x) for x in t))
        if key not in seen: seen.add(key); ded.append((h, t))
    return ded

CWCOEF = {1: {(0,0): 1}, 2: {(0,0): 1, (1,1): -1},
          3: {(0,0): 1, (1,1): -1, (1,2): -1, (2,3): 1}}

def compute_g(d, nmax):
    reps = all_orbits(d)
    g = {r: {0: [0]*PREC} for r in reps}
    for r in reps: g[r][0][0] = 1
    for n in range(1, nmax+1):
        cur = {r: [0]*PREC for r in reps}
        for _ in range(PREC//n + 2):
            new = {}
            for r in reps:
                acc = [0]*PREC
                I = Ic(r)
                for sz in range(1, len(I)+1):
                    for J in combinations(I, sz):
                        tgt = canon(cJ(r, J)); sgn = (-1)**(sz-1)
                        for (az, bq), s in CWCOEF[sz].items():
                            m = n - az
                            if m < 0: continue
                            src = cur[tgt] if m == n else g[tgt][m]
                            padd(acc, src, scale=sgn*s, shift=bq + sz*m)
                new[r] = acc
            if new == cur: break
            cur = new
        for r in reps: g[r][n] = cur[r]
    return reps, g

def main():
    for d in (4, 6, 7, 10, 11):
        ell = gcd(d, 3)
        reps, g = compute_g(d, NMAX)
        zc = [r for r in reps if 0 in r]
        qn = {n: poch_ell(n, ell) for n in range(NMAX+1)}
        Q = {}
        badpoly = []
        for r in reps:
            Q[r] = {}
            for n in range(NMAX+1):
                p = pmul(qn[n], g[r][n])
                last = max((i for i, x in enumerate(p) if x), default=-1)
                if last >= PREC - 50: badpoly.append((r, n)); continue
                Q[r][n] = p[:last+1]
                if any(x < 0 for x in p[:last+1]):
                    print(f"  d={d} WARNING: Q_{n}^{r} has negative coeffs (core positivity input!)")
        summary = []
        for r in zc:
            best = None
            for (h, t) in enum_r(r):
                hc, tc = canon(h), [canon(x) for x in t]
                # verify relation numerically
                ok = all(g[r][n] == (lambda: (lambda rhs: rhs)(
                    None))() is None for n in [])  # placeholder
                okv = True
                for n in range(NMAX+1):
                    rhs = [0]*PREC
                    padd(rhs, g[hc][n], shift=n)
                    if n >= 1:
                        for i, b in enumerate(tc, start=1):
                            padd(rhs, g[b][n-1], shift=(i+1)*n - 1)
                    if rhs != g[r][n]: okv = False
                if not okv: continue
                inj = True
                for n in range(1, NMAX+1):
                    if n not in Q[hc] or any(n-1 not in Q[b] for b in tc): inj = False; break
                    diff = [0]*PREC
                    padd(diff, Q[hc][n])
                    for i, b in enumerate(tc, start=1):
                        # ell-corrected: factor (1-q^{ell n}); INJ: Q^head_n >= sum q^{(i+1)n-1} Q^{b_i}_{n-1}
                        padd(diff, Q[b][n-1], scale=-1, shift=(i+1)*n - 1)
                    if any(x < 0 for x in diff): inj = False; break
                if inj: best = (hc, tc); break
            summary.append((r, best))
        nfail = [r for r, b in summary if b is None]
        print(f"d={d} (ell={ell}): {len(reps)} orbits, {len(zc)} zero-containing; "
              f"INJ-satisfying variant found for {len(zc)-len(nfail)}/{len(zc)}"
              + (f"; FAILING: {nfail}" if nfail else ""))
        if badpoly: print(f"   precision-limited (skipped): {badpoly}")

if __name__ == "__main__":
    main()
