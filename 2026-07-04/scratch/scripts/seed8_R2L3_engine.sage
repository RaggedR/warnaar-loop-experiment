"""
Seed 8 R2L3 (ADVERSARY): exact Z[q] engine for the H-recursion + D-tower + MASTER checks.
All arithmetic in ZZ[q] (polynomials) or exact power-series division with exact numerator
=> every reported coefficient is exact. NO truncation artifacts possible in poly checks;
series checks are exact up to the stated precision.

Standing notation (synthesis-layer2.md):
  H_{c,m} = (q;q)_m F_{c,m};  (1+q^m+q^{2m}) H_{c,m} = Sum_{c'} q^{m*EMD(c,c')} H_{c',m-1}  [NB: argument order validated against brute-force definition; the transposed kernel computes reversed profiles]
  h_m = H_m - (1-q^m) H_{m-1}
  D_{0,m} = h_m,  D_{k,m} = D_{k-1,m} - q^k D_{k-1,m-1};  Q_n = D_{n,n} (GREEN, L1/L2)
  Lemma T1: D_{k+1,m} = (q;q)_{m-k-1} f_k^{(m)}
  MASTER: (q;q)_j f_k^{(m)} >= 0  iff  j <= m-k-1   (k >= -1, m >= k+1)
"""
from sage.all import *
import time, sys

Rq = PolynomialRing(ZZ, 'q'); q = Rq.gen()

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def orbit_reps(d):
    seen = set(); reps = []
    for c in profiles(d):
        o = min(c, (c[1], c[2], c[0]), (c[2], c[0], c[1]))
        if o not in seen:
            seen.add(o); reps.append(o)
    return reps

def min_coeff(p):
    """min coefficient INSIDE the support hull [valuation, degree] (zeros in the hull count:
    they are the near-failures an adversary cares about)."""
    l = p.list()
    if not l: return (0, -1)
    v = 0
    while v < len(l) and l[v] == 0: v += 1
    hull = l[v:]
    if not hull: return (0, -1)
    mn = min(hull)
    return (mn, v + hull.index(mn))

def neg_report(p):
    """None if p >= 0 coefficientwise, else (first_neg_deg, coeff, min_coeff, min_deg)."""
    l = p.list()
    for i, v in enumerate(l):
        if v < 0:
            mn, mi = min_coeff(p)
            return (i, v, mn, mi)
    return None

def build_H(d, m_max, check_all_profiles=True, verbose=True):
    """Exact H-recursion. Returns dict m -> {c: H poly}. Checks along the way:
    exact Phi_3(q^m) division, h_m >= 0, monotonicity H_m >= H_{m-1} (all profiles).
    Records min positive margins. Any violation printed loudly and collected."""
    assert d % 3 != 0
    profs = profiles(d)
    E = {(cp, c): emd(cp, c) for cp in profs for c in profs}
    H = {0: {c: Rq(1) for c in profs}}
    violations = []
    t0 = time.time()
    for m in range(1, m_max+1):
        div = 1 + q**m + q**(2*m)
        Hm = {}
        for c in profs:
            rhs = sum(q**(m*E[(c, cp)]) * H[m-1][cp] for cp in profs)   # kernel EMD(target, source) — validated vs raw definition
            quo, rem = rhs.quo_rem(div)
            assert rem == 0, "DIV FAIL d=%d m=%d c=%s" % (d, m, c)
            Hm[c] = quo
        H[m] = Hm
        # checks
        worst_h = None; worst_mono = None
        for c in profs:
            hm = Hm[c] - (1 - q**m) * H[m-1][c]
            mono = Hm[c] - H[m-1][c]
            for name, p in (("h_m", hm), ("MONO", mono)):
                r = neg_report(p)
                if r is not None:
                    violations.append((name, d, m, c, r))
                    print("*** %s VIOLATION d=%d m=%d c=%s first_neg deg=%d coeff=%d (min %d @ %d)"
                          % ((name, d, m, c) + r), flush=True)
            mn_h = min_coeff(hm); mn_mo = min_coeff(mono)
            if worst_h is None or mn_h < worst_h[0]: worst_h = (mn_h, c)
            if worst_mono is None or mn_mo < worst_mono[0]: worst_mono = (mn_mo, c)
        if verbose:
            print("d=%d m=%d: %d profiles OK; deg(H)<=%d; min h-coeff %s @deg %s (c=%s); min mono-coeff %s @deg %s (c=%s); %.1fs"
                  % (d, m, len(profs), max(Hm[c].degree() for c in profs),
                     worst_h[0][0], worst_h[0][1], worst_h[1],
                     worst_mono[0][0], worst_mono[0][1], worst_mono[1], time.time()-t0), flush=True)
    return H, violations

def dtower(H, c, m_max):
    """D_{k,m} for fixed profile c: D[0][m] = h_m, D[k][m] = D[k-1][m] - q^k D[k-1][m-1]."""
    D = {}
    for m in range(0, m_max+1):
        D[(0, m)] = H[m][c] - (1 - q**m) * H[m-1][c] if m >= 1 else Rq(1)
    for k in range(1, m_max+1):
        for m in range(k, m_max+1):
            D[(k, m)] = D[(k-1, m)] - q**k * D[(k-1, m-1)]
    return D

def series_nonneg(num_poly, denom_exps, prec):
    """Exact coefficients of num_poly / prod (1-q^a), a in denom_exps, up to prec.
    Returns None if all >= 0, else (first_neg_deg, coeff)."""
    PS = PowerSeriesRing(ZZ, 'q', default_prec=prec)
    s = PS(num_poly)
    for a in denom_exps:
        s = s / PS(1 - PS.gen()**a)
    l = s.padded_list(prec)
    for i, v in enumerate(l):
        if v < 0:
            return (i, v)
    return None

def master_checks(H, c, m_max, all_j=False, prec=None, verbose=True, label=""):
    """Full MASTER grid for profile c. Polynomial cells D_{k,m} >= 0 (top j),
    series cells j=0 (and all j if all_j), boundary j=m-k must FAIL.
    Returns list of violations."""
    if prec is None:
        prec = 6*m_max*m_max + 200
    D = dtower(H, c, m_max)
    viol = []
    # 1. polynomial cells: D_{k,m} >= 0 for 0 <= k <= m  (k=m gives Q_m)
    for m in range(1, m_max+1):
        for k in range(0, m+1):
            r = neg_report(D[(k, m)])
            if r is not None:
                viol.append(("D-POLY", c, k, m, r))
                print("*** D-POLY VIOLATION %s c=%s D_{%d,%d} first_neg deg=%d coeff=%d (min %d @ %d)"
                      % ((label, c, k, m) + r), flush=True)
    # 2. series cells: f_k^{(m)} (bracket k from -1..m-1) = D_{k+1,m}/(q;q)_{m-k-1}
    #    with (q;q)_j prefactors: (q;q)_j f_k^{(m)} = D_{k+1,m} / prod_{i=j+1}^{m-k-1}(1-q^i)
    for m in range(1, m_max+1):
        for kb in range(-1, m):        # bracket index
            top = m - kb - 1           # j max (poly cell, already checked)
            js = range(0, top) if all_j else ([0] if top > 0 else [])
            for j in js:
                r = series_nonneg(D[(kb+1, m)], range(j+1, top+1), prec)
                if r is not None:
                    viol.append(("SERIES", c, kb, m, j, r))
                    print("*** SERIES VIOLATION %s c=%s f_%d^(%d) j=%d first_neg deg=%d coeff=%d [EXACT, prec=%d]"
                          % (label, c, kb, m, j, r[0], r[1], prec), flush=True)
            # 3. boundary: (q;q)_{m-kb} f_kb^{(m)} = (1-q^{m-kb}) D_{kb+1,m} must have a negative
            bnd = (1 - q**(m-kb)) * D[(kb+1, m)]
            if neg_report(bnd) is None:
                viol.append(("BOUNDARY-NOFAIL", c, kb, m))
                print("*** BOUNDARY DID NOT FAIL %s c=%s k=%d m=%d (breaks the 'iff')"
                      % (label, c, kb, m), flush=True)
    if verbose and not viol:
        print("  %s c=%s: MASTER grid m<=%d clean (poly+series j=%s+boundary)"
              % (label, c, m_max, "all" if all_j else "0"), flush=True)
    return viol

def gauss_a(H, c, n):
    """a_n = sum_{m=0}^n (-1)^{n-m} q^binom(n-m,2) [n,m]_q H_{c,m} (exact poly)."""
    return sum((-1)**(n-m) * q**binomial(n-m, 2) * q_binomial(n, m, q) * H[m][c]
               for m in range(0, n+1))
