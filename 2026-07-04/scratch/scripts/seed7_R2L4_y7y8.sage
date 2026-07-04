"""
Seed 7 R2L4 (verifier): re-verify Y7 and Y8 at d = 8, 10, 11, 13 in TRUE labels.

Convention: synthesis-layer3.md section 4(iv). Target-first kernel
(1+q^m+q^{2m}) H_{c,m} = Sum_{c'} q^{m*EMD(c,c')} H_{c',m-1}, c = target.
emd() copied verbatim from the raw-validated reference engine seed8_R2L3_engine.sage.

Y7 (raw bracket, Seed 3): g_m >= q^m F_{c,m} coefficientwise.
  Exact identity: g_m - q^m F_m = (h_m - q^m H_m)/(q;q)_m
                = (1-q^m)(H_m - H_{m-1})/(q;q)_m = Delta_m/(q;q)_{m-1}.
  So Y7 at (c,m) <=> Delta_m/(q;q)_{m-1} series-nonneg. Numerator exact in ZZ[q];
  series division exact up to stated precision PREC.

Y8 (Conjecture A, Seed 3 Script 2): for every ALL-POSITIVE target c (all c_i >= 1)
  the orbit-level row (U-I)_c is coefficientwise nonneg in x.
  U_{c,O}(x) = (Sum_{c' in O} x^{EMD(c,c')}) / (1+x+x^2).
  We check EXACTLY in ZZ[x]: for each orbit O the numerator must be divisible by
  1+x+x^2 (<=> EMD triple over O consecutive {e,e+1,e+2}, orbits have size 3 when
  gcd(d,3)=1), quotient = x^e; diagonal orbit must give e=0. Then the (U-I) row is
  [x^{e_O}] with diagonal 0: manifestly nonneg -- no truncation anywhere.
"""
from sage.all import *
import time, sys

Rq = PolynomialRing(ZZ, 'q'); q = Rq.gen()
Rx = PolynomialRing(ZZ, 'x'); x = Rx.gen()

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):   # verbatim from seed8_R2L3_engine.sage
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def orbits(d):
    seen = set(); out = []
    for c in profiles(d):
        rots = [c, (c[1], c[2], c[0]), (c[2], c[0], c[1])]
        o = min(rots)
        if o not in seen:
            seen.add(o)
            out.append((o, [o, (o[1], o[2], o[0]), (o[2], o[0], o[1])]))
    return out

def build_H(d, m_max):
    profs = profiles(d)
    E = {(c, cp): emd(c, cp) for c in profs for cp in profs}  # E[(target, source)]
    H = {0: {c: Rq(1) for c in profs}}
    t0 = time.time()
    for m in range(1, m_max+1):
        div = 1 + q**m + q**(2*m)
        Hm = {}
        for c in profs:
            rhs = sum(q**(m*E[(c, cp)]) * H[m-1][cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0, "DIV FAIL d=%d m=%d c=%s" % (d, m, c)
            Hm[c] = quo
        H[m] = Hm
        print("  built H d=%d m=%d (deg<=%d, %.1fs)" % (
            d, m, max(Hm[c].degree() for c in profs), time.time()-t0), flush=True)
    return H

def series_first_neg(num_poly, denom_exps, prec):
    PS = PowerSeriesRing(ZZ, 'q', default_prec=prec)
    s = PS(num_poly)
    for a in denom_exps:
        s = s / PS(1 - PS.gen()**a)
    for i, v in enumerate(s.padded_list(prec)):
        if v < 0:
            return (i, v)
    return None

def check_Y7(d, m_max, prec):
    print("== Y7 d=%d m<=%d prec=%d (exact ZZ[q] numerators; series exact to prec)" % (d, m_max, prec), flush=True)
    H = build_H(d, m_max)
    bad = []
    for m in range(1, m_max+1):
        nb = 0
        for c in profiles(d):
            Dm = H[m][c] - H[m-1][c]
            r = series_first_neg(Dm, range(1, m), prec)  # /(q;q)_{m-1}
            if r is not None:
                bad.append((d, m, c, r)); nb += 1
                print("*** Y7 FAIL d=%d m=%d c=%s first_neg deg=%d coeff=%d" % ((d, m, c) + r), flush=True)
        print("  Y7 d=%d m=%d: %s (%d profiles)" % (d, m, "all PASS" if nb == 0 else "%d FAILURES" % nb, len(profiles(d))), flush=True)
    return bad

def check_Y8(d):
    print("== Y8 d=%d (exact in ZZ[x])" % d, flush=True)
    orbs = orbits(d)
    onep = 1 + x + x**2
    allpos = [c for c in profiles(d) if all(ci >= 1 for ci in c)]
    bad = []
    for c in allpos:
        my_orbit = min([c, (c[1], c[2], c[0]), (c[2], c[0], c[1])])
        for rep, members in orbs:
            numer = sum(x**emd(c, cp) for cp in members)
            quo, rem = numer.quo_rem(onep)
            if rem != 0:
                bad.append(("NONCONSEC", d, c, rep, sorted(emd(c, cp) for cp in members)))
                print("*** Y8 FAIL d=%d target=%s orbit=%s EMD-triple %s NOT consecutive" % (
                    d, c, rep, sorted(emd(c, cp) for cp in members)), flush=True)
                continue
            entry = quo - (1 if rep == my_orbit else 0)
            if any(cf < 0 for cf in entry.list()):
                bad.append(("NEG", d, c, rep, entry))
                print("*** Y8 FAIL d=%d target=%s orbit=%s (U-I) entry %s has neg coeff" % (
                    d, c, rep, entry), flush=True)
    nonconsec_zero = 0
    for c in profiles(d):
        if all(ci >= 1 for ci in c):
            continue
        for rep, members in orbs:
            numer = sum(x**emd(c, cp) for cp in members)
            if numer.quo_rem(onep)[1] != 0:
                nonconsec_zero += 1
    print("  Y8 d=%d: %d all-positive targets x %d orbits: %s" % (
        d, len(allpos), len(orbs), "ALL PASS" if not bad else "%d FAILURES" % len(bad)), flush=True)
    print("  (context: zero-containing targets: %d non-consecutive (target,orbit) pairs)" % nonconsec_zero, flush=True)
    return bad

def main():
    plan = [(8, 10), (10, 9), (11, 8), (13, 7)]
    allbad = []
    for d, m_max in plan:
        t0 = time.time()
        allbad += check_Y8(d)
        prec = 3*d*m_max + 100
        allbad += check_Y7(d, m_max, prec)
        print("== d=%d done in %.1fs" % (d, time.time()-t0), flush=True)
    print("== TOTAL FAILURES: %d" % len(allbad), flush=True)

main()
