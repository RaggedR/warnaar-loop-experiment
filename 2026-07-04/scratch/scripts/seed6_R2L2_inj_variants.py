#!/usr/bin/env python3
"""Enumerate ALL R-relation variants per zero-containing profile (both j2 branch
choices in the Substitution Lemma, head-condition checked up to rotation), verify
each numerically, and test the injection inequality INJ for each variant.
For profiles where every variant fails INJ, test the ITERATED relation
(substitute the head's own R-relation once) and its modified INJ'.
"""
import sys
from itertools import combinations
sys.setrecursionlimit(10000)

PREC = 520
NMAX = 5

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

def poch(n):
    res = [0]*PREC; res[0] = 1
    for i in range(1, n+1):
        f = [0]*PREC; f[0] = 1; f[i] = -1
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

def enum_r(c, depth=0):
    """Enumerate R-relations (head, tail) for zero-containing composition c.
    Returns list of (head, tuple(tail)). Uses Substitution Lemma recursively."""
    I = Ic(c)
    if len(I) == 1:
        return [(cJ(c, (I[0],)), ())]
    assert len(I) == 2
    out = []
    for j2 in I:
        j1 = [j for j in I if j != j2][0]
        cj2 = cJ(c, (j2,))
        if len(Ic(cj2)) == 3: continue   # cannot recurse into core
        pair = cJ(c, tuple(sorted((j1, j2))))
        for h, t in enum_r(cj2, depth+1):
            if canon(h) == canon(pair):
                out.append((cJ(c, (j1,)), (pair,) + t))
    # dedupe by canonical form
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

def negs(p): return [i for i, x in enumerate(p) if x < 0]

def main():
    for d in (5, 8):
        print(f"\n================ d = {d} ================")
        reps, g = compute_g(d, NMAX)
        zc = [r for r in reps if 0 in r]
        qn = {n: poch(n) for n in range(NMAX+1)}
        # exact Q polynomials
        Q = {}
        for r in reps:
            Q[r] = {}
            for n in range(NMAX+1):
                p = pmul(qn[n], g[r][n])
                last = max((i for i, x in enumerate(p) if x), default=-1)
                assert last < PREC - 60, (r, n, "precision")
                Q[r][n] = p[:last+1]

        for r in zc:
            variants = enum_r(r)
            print(f"\n{r}: {len(variants)} R-relation variant(s)")
            any_inj = False
            for vi, (h, t) in enumerate(variants):
                hc, tc = canon(h), [canon(x) for x in t]
                # numeric verification
                ok = True
                for n in range(NMAX+1):
                    rhs = [0]*PREC
                    padd(rhs, g[hc][n], shift=n)
                    if n >= 1:
                        for i, b in enumerate(tc, start=1):
                            padd(rhs, g[b][n-1], shift=(i+1)*n - 1)
                    if rhs != g[r][n]: ok = False
                # INJ test
                inj_ok = True; firstfail = None
                for n in range(1, NMAX+1):
                    diff = [0]*PREC
                    padd(diff, Q[hc][n])
                    for i, b in enumerate(tc, start=1):
                        padd(diff, Q[b][n-1], scale=-1, shift=(i+1)*n - 1)
                    ng = negs(diff)
                    if ng:
                        inj_ok = False
                        if firstfail is None: firstfail = (n, ng[0], diff[ng[0]])
                print(f"  v{vi}: head {hc} tail {tc}  verified={ok}  INJ={'OK' if inj_ok else 'FAIL '+str(firstfail)}")
                if inj_ok and ok: any_inj = True
            if not any_inj:
                # try iterated relation: substitute head's R-relation once
                print(f"  -> no variant satisfies INJ; trying iterated relations for {r}")
                for vi, (h, t) in enumerate(variants):
                    hc, tc = canon(h), [canon(x) for x in t]
                    if 0 not in hc:
                        continue
                    for wi, (h2, t2) in enumerate(enum_r(hc)):
                        h2c, t2c = canon(h2), [canon(x) for x in t2]
                        # composed: G_r(z) = G_{h2}(zq^2) + sum_j zq^{j+1} G_{t2_j}(zq^{j+2})
                        #                    + sum_i zq^i G_{t_i}(zq^{i+1})
                        # Q-level: Q_n^r = q^{2n} Q_n^{h2} + (1-q^n)[ sum_j q^{(j+2)n-1} Q_{n-1}^{t2_j}
                        #                    + sum_i q^{(i+1)n-1} Q_{n-1}^{t_i} ]
                        # INJ': q^{2n} Q_n^{h2} >= q^n * [ same brackets ]
                        inj_ok = True; firstfail = None
                        for n in range(1, NMAX+1):
                            diff = [0]*PREC
                            padd(diff, Q[h2c][n], shift=n)   # q^{2n}/q^n
                            for j, b in enumerate(t2c, start=1):
                                padd(diff, Q[b][n-1], scale=-1, shift=(j+2)*n - 1 - n + n)  # q^{(j+2)n-1}
                            for i, b in enumerate(tc, start=1):
                                padd(diff, Q[b][n-1], scale=-1, shift=(i+1)*n - 1)
                            # NOTE: factored q^n out of everything consistently:
                            # actual condition: q^{2n}Q_n^{h2} >= q^n*sum(...) <=>
                            # q^n Q_n^{h2} >= sum q^{(j+2)n-1-?}... let's be careful:
                            # condition: q^{2n} Q^{h2}_n - q^n [sum_j q^{(j+2)n-1} Q^{t2_j}_{n-1}
                            #            + sum_i q^{(i+1)n-1} Q^{t_i}_{n-1}] >= 0; divide by q^n:
                            # q^n Q^{h2}_n - sum_j q^{(j+2)n-1} Q - sum_i q^{(i+1)n-1} Q >= 0
                            ng = negs(diff)
                            if ng:
                                inj_ok = False
                                if firstfail is None: firstfail = (n, ng[0], diff[ng[0]])
                        print(f"    iter v{vi}.w{wi}: head2 {h2c} tail2 {t2c}  INJ'={'OK' if inj_ok else 'FAIL '+str(firstfail)}")

if __name__ == "__main__":
    main()
