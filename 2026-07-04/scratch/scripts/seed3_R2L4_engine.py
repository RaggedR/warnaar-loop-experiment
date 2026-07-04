"""
Seed 3 R2L4: exact engine for d=7 (modulus 10) positive y-system construction.

Ground truth: raw CW alternating system (Prop incex, corteel_welsh_A2_RR/source.tex)
  G_c(y) = sum_{0!=J subset I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(y q^{|J|})
solved as q-adic fixed point per y-level.  g_c(n) = [y^n] G_c(y,q), truncated series.

Cross-checks:
  (1) brute-force cylindric partition enumeration (conjecture.tex/CW interlacing) vs
      F_{c,m} = sum_{n<=m} g_c(n);
  (2) faithful port of scripts/seed8_R2L3_engine.sage (target-first H-recursion, exact
      Z[q]) + gauss_a inversion:  Q_{n,c} = (q;q)_n g_c(n) == a_n  (pins the label map);
  (3) Q_n(1) = (K-1)^n = 11^n.

Series = dense list of ints, length PREC.  Polys (H, Q) = dicts {exp: coeff}, exact.
"""
from collections import defaultdict
import sys

PREC = 200

# ---------------- series (dense lists, truncated at PREC) ----------------
def snew(): return [0]*PREC
def sadd(a, b, mult=1, shift=0):
    # a += mult * q^shift * b   (in place)
    for i in range(0, PREC-shift):
        v = b[i]
        if v: a[i+shift] += mult*v
    return a
def sfromdict(p):
    s = snew()
    for k, v in p.items():
        if k < PREC: s[k] += v
    return s
def smul_poly(s, p):
    r = snew()
    for k, v in p.items():
        if v and k < PREC: sadd(r, s, v, k)
    return r
def seq(a, b): return a == b

# ---------------- polynomials (sparse dicts) ----------------
def padd(p1, p2):
    r = defaultdict(int, p1)
    for k, v in p2.items(): r[k] += v
    return {k: v for k, v in r.items() if v}
def pmul(p1, p2):
    r = defaultdict(int)
    for k1, v1 in p1.items():
        for k2, v2 in p2.items(): r[k1+k2] += v1*v2
    return {k: v for k, v in r.items() if v}
def pscale(p, c, sh=0):
    return {k+sh: v*c for k, v in p.items() if v*c}
def qpoch(m):
    r = {0: 1}
    for k in range(1, m+1): r = pmul(r, {0: 1, k: -1})
    return r
_QB = {}
def qbin(n, k):
    # Gaussian binomial [n,k]_q, exact poly, via q-Pascal
    if k < 0 or k > n: return {}
    if (n, k) in _QB: return _QB[(n, k)]
    if k == 0 or k == n: r = {0: 1}
    else: r = padd(qbin(n-1, k-1), pscale(qbin(n-1, k), 1, k))
    _QB[(n, k)] = r
    return r
def pdivexact(num, den):
    num = dict(num); q = {}
    if not num: return {}
    dmax = max(den); dc = den[dmax]
    while num:
        nmax = max(num)
        assert num[nmax] % dc == 0, "nonexact coeff"
        c = num[nmax]//dc; e = nmax - dmax
        assert e >= 0, "nonexact deg"
        q[e] = c
        for k, v in den.items():
            num[k+e] = num.get(k+e, 0) - c*v
            if num[k+e] == 0: del num[k+e]
    return q


def smul_series(a, b):
    r = snew()
    for i in range(PREC):
        v = a[i]
        if v:
            for j in range(PREC-i):
                w = b[j]
                if w: r[i+j] += v*w
    return r

_IPS = {}
def inv_poch_series(j):
    # 1/(q;q)_j as truncated series
    if j in _IPS: return _IPS[j]
    r = sfromdict({0: 1})
    for k in range(1, j+1):
        # multiply by 1/(1-q^k): prefix-sum with stride k
        for i in range(k, PREC): r[i] += r[i-k]
    _IPS[j] = r
    return r

# ---------------- profiles ----------------
def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d-a+1)]
def rot(c):  # cyclic rotation (c1,c2,c3) -> (c3,c1,c2)? use consistent: rotate left
    return (c[1], c[2], c[0])
def orbit_rep(c):
    return min(c, rot(c), rot(rot(c)))
def orbit_reps(d):
    seen = set(); reps = []
    for c in profiles(d):
        r = orbit_rep(c)
        if r not in seen:
            seen.add(r); reps.append(r)
    return reps

# ---------------- raw CW system ----------------
# (yq;q)_{|J|-1} expansions as {(ypow, qpow): coeff}
POCHY = {1: {(0, 0): 1},
         2: {(0, 0): 1, (1, 1): -1},
         3: {(0, 0): 1, (1, 1): -1, (1, 2): -1, (2, 3): 1}}

def cJ(c, J):
    # CW rule, 0-indexed cyclic: c_i - 1 if i in J and (i-1) not in J;
    # c_i + 1 if i not in J and (i-1) in J; else c_i.
    out = []
    for i in range(3):
        prev = (i-1) % 3
        v = c[i]
        if i in J and prev not in J: v -= 1
        elif i not in J and prev in J: v += 1
        out.append(v)
    return tuple(out)

def raw_row(c):
    """Terms of the raw CW row for G_c(y): list of (profile, shift, {(ypow,qpow):coeff})."""
    I = [i for i in range(3) if c[i] > 0]
    terms = []
    from itertools import combinations
    for sz in range(1, len(I)+1):
        for J in combinations(I, sz):
            sgn = (-1)**(sz-1)
            coeff = {k: sgn*v for k, v in POCHY[sz].items()}
            terms.append((cJ(c, set(J)), sz, coeff))
    return terms

def solve_g(d, nmax, verbose=True):
    """g[n][c] as truncated series, from the raw CW system."""
    profs = profiles(d)
    rows = {c: raw_row(c) for c in profs}
    g = [{c: sfromdict({0: 1}) for c in profs}]  # n=0: g=1
    for n in range(1, nmax+1):
        cur = {c: snew() for c in profs}
        iters = PREC//max(n, 1) + 3
        for it in range(iters):
            changed = False
            for c in profs:
                acc = snew()
                for (cp, s, coeff) in rows[c]:
                    for (j, a), cf in coeff.items():
                        if n-j < 0: continue
                        src = cur[cp] if j == 0 else g[n-j][cp]
                        sh = a + s*(n-j)
                        if sh < PREC: sadd(acc, src, cf, sh)
                if acc != cur[c]:
                    cur[c] = acc; changed = True
            if not changed: break
        g.append(cur)
        if verbose: print(f"  g level n={n} solved ({it+1} sweeps)", flush=True)
    return g

# ---------------- brute force (from seed1 engine, conjecture.tex convention) ----------------
def parts_leq(maxpart, maxsize):
    out = [()]
    def rec(prefix, last, rem):
        for p in range(1, min(last, rem)+1):
            newp = prefix + (p,)
            out.append(newp)
            rec(newp, p, rem-p)
    rec((), maxpart, maxsize)
    return out

def interlace_ok(lam, mu, shift):
    for j in range(1, len(mu)+1):
        muj = mu[j-1]
        idx = j - shift
        if idx >= 1:
            lamv = lam[idx-1] if idx <= len(lam) else 0
            if lamv < muj: return False
    return True

def brute_F(c, m, T):
    c1, c2, c3 = c
    plist = parts_leq(m, T)
    F = defaultdict(int)
    for l1 in plist:
        s1 = sum(l1)
        if s1 > T: continue
        for l2 in plist:
            s2 = s1 + sum(l2)
            if s2 > T: continue
            if not interlace_ok(l1, l2, c2): continue
            for l3 in plist:
                s3 = s2 + sum(l3)
                if s3 > T: continue
                if not interlace_ok(l2, l3, c3): continue
                if not interlace_ok(l3, l1, c1): continue
                F[s3] += 1
    return dict(F)

# ---------------- seed8 engine port (H-recursion, target-first) ----------------
def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def build_H(d, m_max, verbose=True):
    assert d % 3 != 0
    profs = profiles(d)
    E = {(cp, c): emd(cp, c) for cp in profs for c in profs}
    H = {0: {c: {0: 1} for c in profs}}
    for m in range(1, m_max+1):
        div = {0: 1, m: 1, 2*m: 1}
        Hm = {}
        for c in profs:
            rhs = defaultdict(int)
            for cp in profs:
                sh = m*E[(c, cp)]
                for k, v in H[m-1][cp].items(): rhs[sh+k] += v
            Hm[c] = pdivexact({k: v for k, v in rhs.items() if v}, div)
        H[m] = Hm
        if verbose: print(f"  H level m={m} done", flush=True)
    return H

def binom2(x): return x*(x-1)//2

def gauss_a(H, c, n):
    r = {}
    for m in range(0, n+1):
        t = pmul(qbin(n, m), H[m][c])
        r = padd(r, pscale(t, (-1)**((n-m) % 2), binom2(n-m)))
    return r

# ---------------- main verification ----------------
if __name__ == "__main__":
    d = 7; NMAX = 8
    print(f"=== Seed3 R2L4 engine, d={d}, PREC={PREC}, NMAX={NMAX} ===", flush=True)
    profs = profiles(d)
    print(f"{len(profs)} profiles, {len(orbit_reps(d))} orbits")

    print("Solving raw CW system for g ...", flush=True)
    g = solve_g(d, NMAX)

    # check rotation invariance of g
    ok = all(g[n][c] == g[n][rot(c)] for n in range(NMAX+1) for c in profs)
    print(f"rotation invariance of g: {'PASS' if ok else 'FAIL'}")

    # (1) brute force check: F_{c,m} = sum_{n<=m} g_c(n), m<=2, T=14
    print("Brute-force check (m<=2, T=14) ...", flush=True)
    T = 14
    allok = True
    for c in orbit_reps(d):
        for m in (1, 2):
            B = brute_F(c, m, T)
            S = snew()
            for n in range(0, m+1):
                t = smul_series(g[n][c], inv_poch_series(m-n))
                sadd(S, t)
            got = [S[i] for i in range(T+1)]
            want = [B.get(i, 0) for i in range(T+1)]
            if got != want:
                allok = False
                print(f"  MISMATCH c={c} m={m}\n   got {got}\n   want {want}")
    print(f"brute vs CW-system g: {'PASS' if allok else 'FAIL'}")

    # (2) H-recursion port + gauss_a: Q_n = (q;q)_n g_c(n) == a_n, label map = identity?
    print("Building H (seed8 port, target-first) ...", flush=True)
    H = build_H(d, NMAX)
    print("Checking Q_n = (q;q)_n g_c(n) == gauss_a(H,c,n) ...", flush=True)
    allok = True; Q = {}
    for c in orbit_reps(d):
        for n in range(0, NMAX+1):
            a = gauss_a(H, c, n)
            # exactness: a must be a poly with deg < PREC for series comparison
            dega = max(a) if a else 0
            Qs = smul_poly(g[n][c], qpoch(n))
            acmp = sfromdict(a)
            lim = min(PREC, PREC)  # compare full series window; poly beyond PREC untestable
            if dega >= PREC:
                lim = PREC
            if Qs[:lim] != acmp[:lim]:
                allok = False
                print(f"  Q MISMATCH c={c} n={n}")
            else:
                Q[(c, n)] = a
            # positivity of exact a_n (only meaningful where poly fully known)
            if any(v < 0 for v in a.values()):
                print(f"  NOTE: a_n has negative coeffs c={c} n={n} (conjecture would fail!)")
        # Q_n(1) check
        for n in range(0, NMAX+1):
            if (c, n) in Q:
                val1 = sum(Q[(c, n)].values())
                if val1 != 11**n:
                    allok = False
                    print(f"  Q_n(1) FAIL c={c} n={n}: {val1} != {11**n}")
    print(f"Q == gauss_a (identity label map) and Q_n(1)=11^n: {'PASS' if allok else 'FAIL'}")
    print("done")
