#!/usr/bin/env python3
"""Seed 6, Layer 2, Round 2: CW propagation via R-relations.

R-relation for profile c (r=3, indices mod 3):
    G_c(z) = G_{head}(zq) + sum_{i=1}^{L} z q^i G_{b_i}(z q^{i+1})
where G_c(z,q) = (zq;q)_inf F_c(z,q).

1. Derive R-relations for all zero-containing profiles (two-family construction).
2. Numerically verify against the raw Corteel-Welsh system at high precision.
3. Check Q_n = (q;q)_n [z^n] G_c is a nonneg polynomial for all orbits.
4. Test the cross-profile injection inequality
   (INJ_c): Q_n^{head} - sum_i q^{(i+1)n-1} Q_{n-1}^{b_i} >= 0.
"""
import sys
from itertools import combinations

PREC = 520   # >= 6*max(n)^2 + 200 with n<=6 (416); relations checked are exact g-identities
NMAX = 5

# ---------- polynomial helpers (dense lists mod q^PREC) ----------
def padd(a, b, scale=1, shift=0):
    """a += scale * q^shift * b  (in place, truncated)"""
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
    """(q;q)_n as truncated list"""
    res = [0]*PREC; res[0] = 1
    for i in range(1, n+1):
        f = [0]*PREC; f[0] = 1
        if i < PREC: f[i] = -1
        res = pmul(res, f)
    return res

# ---------- profile ops ----------
def canon(c):
    return max(tuple(c[i:] + c[:i]) for i in range(len(c)))  # fixed representative (max lexicographic)

def Ic(c):
    return [i for i in range(3) if c[i] > 0]

def cJ(c, J):
    Js = set(J)
    out = []
    for i in range(3):
        prev = (i - 1) % 3
        if i in Js and prev not in Js: out.append(c[i]-1)
        elif i not in Js and prev in Js: out.append(c[i]+1)
        else: out.append(c[i])
    return tuple(out)

def all_orbits(d):
    seen, reps = set(), []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c = (c0, c1, d-c0-c1)
            k = canon(c)
            if k not in seen:
                seen.add(k); reps.append(k)
    return reps

# ---------- R-relation derivation (two-family construction) ----------
def r_relation(c):
    """c: composition (tuple) with at least one zero. Returns (head, [b_1..b_L]) as
    compositions (not canonicalized). Raises if head condition would fail."""
    I = Ic(c)
    if len(I) == 1:
        j = I[0]
        return cJ(c, (j,)), []
    assert len(I) == 2, "R-relations only for zero-containing profiles"
    # rotate c so it is (a,0,b) or (a,b,0) with a,b>=1
    for rshift in range(3):
        cr = tuple(c[rshift:] + c[:rshift])
        if cr[1] == 0 and cr[0] > 0 and cr[2] > 0:      # Family A: (a,0,b)
            a, b = cr[0], cr[2]
            head = (a-1, 1, b)
            tail = [(a+i, 1, b-1-i) for i in range(b)]  # (a,1,b-1),...,(a+b-1,1,0)
            return head, tail
        if cr[2] == 0 and cr[0] > 0 and cr[1] > 0:      # Family B: (a,b,0)
            a, b = cr[0], cr[1]
            head = (a, b-1, 1)
            tailA = [(b+1+i, 1, a-2-i) for i in range(a-1)]  # tail of (b+1,0,a-1)
            tail = [(a-1, b, 1)] + tailA
            return head, tail
    raise ValueError(f"no family match for {c}")

def verify_head_conditions(d):
    """Independently re-derive R-relations by the Substitution Lemma recursion and
    confirm the closed forms + head conditions, for every zero-containing composition."""
    ok = True
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c = (c0, c1, d-c0-c1)
            I = Ic(c)
            if len(I) != 2: continue
            j1, j2map = None, {}
            # try both choices of j2; check head(c({j2})) == c({j1,j2}) up to rotation
            found = False
            for j2 in I:
                j1 = [j for j in I if j != j2][0]
                cj2 = cJ(c, (j2,))
                if len(Ic(cj2)) == 3: continue
                h, t = r_relation(cj2)
                if canon(h) == canon(cJ(c, tuple(sorted((j1, j2))))):
                    # rebuild R_c from lemma and compare with closed form
                    head_l, tail_l = cJ(c, (j1,)), [cJ(c, tuple(sorted((j1, j2))))] + t
                    head_f, tail_f = r_relation(c)
                    if canon(head_l) != canon(head_f) or \
                       [canon(x) for x in tail_l] != [canon(x) for x in tail_f]:
                        print(f"  MISMATCH lemma vs closed form at {c}")
                        ok = False
                    found = True
                    break
            if not found:
                print(f"  HEAD CONDITION FAILS for {c}")
                ok = False
    return ok

# ---------- numeric G-series via raw CW ----------
# coefficient monomials of (zq;q)_{|J|-1} as {(a_z, b_q): sign}
CWCOEF = {1: {(0,0): 1},
          2: {(0,0): 1, (1,1): -1},
          3: {(0,0): 1, (1,1): -1, (1,2): -1, (2,3): 1}}

def compute_g(d, nmax):
    """g[rep][n] = [z^n] G_rep(z,q) as truncated q-series, via fixed-point on raw CW."""
    reps = all_orbits(d)
    g = {r: {0: [0]*PREC} for r in reps}
    for r in reps: g[r][0][0] = 1   # g_c(0) = 1
    for n in range(1, nmax+1):
        cur = {r: [0]*PREC for r in reps}
        for _ in range(PREC//n + 2):
            new = {}
            for r in reps:
                acc = [0]*PREC
                I = Ic(r)
                for sz in range(1, len(I)+1):
                    for J in combinations(I, sz):
                        tgt = canon(cJ(r, J))
                        sgn = (-1)**(sz-1)
                        for (az, bq), s in CWCOEF[sz].items():
                            m = n - az
                            if m < 0: continue
                            src = cur[tgt][:] if m == n else g[tgt][m]
                            padd(acc, src, scale=sgn*s, shift=bq + sz*m)
                        # note: q^{sz*m} shift from G(zq^{sz}) plus q^{bq} from coeff
                acc = [x for x in acc]
                new[r] = acc
            if new == cur:
                break
            cur = new
        for r in reps: g[r][n] = cur[r]
    return reps, g

def poly_trim(p, margin=60):
    """Return (poly_list, deg) if p is a polynomial (zero tail of length >= margin), else None."""
    last = max((i for i, x in enumerate(p) if x != 0), default=-1)
    if last >= PREC - margin: return None
    return p[:last+1], last

def main():
    for d in (5, 8):
        print(f"\n================ d = {d} (modulus {d+3}) ================")
        reps = all_orbits(d)
        zc = [r for r in reps if 0 in r]
        core = [r for r in reps if 0 not in r]
        print(f"{len(reps)} orbits; zero-containing: {len(zc)}; all-positive core: {len(core)}")
        print("core:", core)
        print("\n-- head-condition / lemma-vs-closed-form check over ALL compositions --")
        print("   OK" if verify_head_conditions(d) else "   FAILURE")

        print("\n-- computing g_c(n) via raw CW, PREC", PREC, "nmax", NMAX, "--")
        reps, g = compute_g(d, NMAX)

        qn = {n: poch(n) for n in range(NMAX+1)}
        # R-relation numeric verification + reachability
        print("\n-- R-relations and numeric verification --")
        allok = True
        for r in zc:
            head, tail = r_relation(r)
            hc, tc = canon(head), [canon(t) for t in tail]
            for n in range(0, NMAX+1):
                lhs = g[r][n]
                rhs = [0]*PREC
                padd(rhs, g[hc][n], shift=n)               # q^n g_head(n)
                if n >= 1:
                    for i, b in enumerate(tc, start=1):
                        padd(rhs, g[b][n-1], shift=(i+1)*n - 1)
                if lhs != rhs:
                    allok = False
                    print(f"  FAIL R_{r} at n={n}")
            print(f"  R_{r}: head {hc}, tail {tc}  -- verified n<=NMAX" )
        print("  ALL R-RELATIONS VERIFIED" if allok else "  SOME FAILED")

        # Q_n positivity for all orbits
        print("\n-- Q_n = (q;q)_n g_c(n): polynomial + nonneg check --")
        Q = {}
        for r in reps:
            Q[r] = {}
            for n in range(NMAX+1):
                p = pmul(qn[n], g[r][n])
                pt = poly_trim(p)
                if pt is None:
                    print(f"  {r} n={n}: NOT polynomial within margin (precision issue?)")
                    continue
                poly, deg = pt
                neg = [i for i, x in enumerate(poly) if x < 0]
                Q[r][n] = poly
                if neg:
                    print(f"  {r} n={n}: NEGATIVE coeffs at {neg[:5]}")
        print("  (silence above = all polynomial and nonneg)")

        # INJ test
        print("\n-- cross-profile injection inequality (INJ_c) --")
        for r in zc:
            head, tail = r_relation(r)
            hc, tc = canon(head), [canon(t) for t in tail]
            for n in range(1, NMAX+1):
                if n not in Q[hc] or any(n-1 not in Q[b] for b in tc): continue
                diff = [0]*PREC
                padd(diff, Q[hc][n])
                for i, b in enumerate(tc, start=1):
                    padd(diff, Q[b][n-1], scale=-1, shift=(i+1)*n - 1)
                neg = [i for i, x in enumerate(diff) if x < 0]
                status = "OK " if not neg else f"FAILS at q^{neg[0]} (coef {diff[neg[0]]})"
                if neg or n == NMAX:
                    print(f"  INJ_{r} n={n}: {status}")

if __name__ == "__main__":
    main()
