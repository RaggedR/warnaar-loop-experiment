# INDEPENDENT VERIFIER script — Seed 2 Layer 4 audit (two-term fermionic rep, d=8, mod 11)
# Fresh code; engine = raw Corteel-Welsh functional equation (Uncu eq:Grec + eq:c(J)),
# NOT the seeds' H/EMD kernel. All arithmetic exact in ZZ[q] truncated mod q^PREC.
import sys, time
from sage.all import *
from sage.combinat.q_analogues import q_binomial

t0 = time.time()
NMAX = 3
PREC = 120
CHK  = 60
R = PolynomialRing(ZZ, 'q'); q = R.gen()

def log(msg):
    print(msg); sys.stdout.flush()

def tr(p, prec=PREC):
    return R(p).truncate(prec)

# ---------- q-Pochhammer / q-binomial helpers ----------
POCH = {0: R.one()}
def poch(j):
    j = int(j)
    if j < 0: return None      # (q)_{negative}: 1/(q)_j = 0
    if j not in POCH:
        POCH[j] = poch(j-1) * (1 - q**j)
    return POCH[j]

QB = {}
def qb(a, b):
    key = (int(a), int(b))
    if key not in QB:
        if a < 0 or b < 0 or b > a: QB[key] = R.zero()
        else: QB[key] = R(q_binomial(a, b))
    return QB[key]

def series_inv(p, prec):
    # inverse of poly with constant term 1, mod q^prec
    return tr(R(p).inverse_series_trunc(prec), prec)

def poch_inf(prec):
    out = R.one()
    for i in range(1, prec+1):
        out = tr(out * (1 - q**i), prec)
    return out

PINF_CHK = poch_inf(CHK)

# =====================================================================
# ENGINE [E]: raw CW recursion for G_c, all 45 profiles of d=8, TRUE labels
# G_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(z q^{|J|}, q)
# =====================================================================
d = 8
profiles = [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]
assert len(profiles) == 45

def cJ(c, J):
    # J subset of {0,1,2} (0-based positions), cyclic predecessor (i-1)%3
    out = []
    for i in range(3):
        if i in J and ((i-1) % 3) not in J: out.append(c[i]-1)
        elif i not in J and ((i-1) % 3) in J: out.append(c[i]+1)
        else: out.append(c[i])
    return tuple(out)

from itertools import combinations
SUBS = {}
for c in profiles:
    Ic = [i for i in range(3) if c[i] > 0]
    subs = []
    for r in range(1, len(Ic)+1):
        for J in combinations(Ic, r):
            subs.append((set(J), len(J), cJ(c, set(J))))
    SUBS[c] = subs

# (zq;q)_{j-1} z-coefficients: e[j-1][a] = [z^a](zq;q)_{j-1}
ZQPOCH = {0: [R.one()],
          1: [R.one(), -q],
          2: [R.one(), -(q + q**2), q**3]}

g = {c: {0: R.one()} for c in profiles}   # g[c][n] = [z^n] G_c mod q^PREC

log("[E] solving CW recursion, d=8, %d profiles, NMAX=%d, PREC=%d" % (len(profiles), NMAX, PREC))
for n in range(1, NMAX+1):
    known = {}
    for c in profiles:
        acc = R.zero()
        for J, j, cp in SUBS[c]:
            sgn = (-1)**(j-1)
            coeffs = ZQPOCH[j-1]
            for a in range(1, min(n, len(coeffs)-1)+1):
                acc += sgn * coeffs[a] * q**(j*(n-a)) * g[cp][n-a]
        known[c] = tr(acc)
    x = dict(known)
    it = 0
    while True:
        it += 1
        xn = {}
        for c in profiles:
            acc = known[c]
            for J, j, cp in SUBS[c]:
                acc += (-1)**(j-1) * q**(j*n) * x[cp]
            xn[c] = tr(acc)
        if all(xn[c] == x[c] for c in profiles):
            break
        x = xn
        if it > PREC + 5:
            raise RuntimeError("no convergence at n=%d" % n)
    for c in profiles:
        g[c][n] = x[c]
    log("  n=%d solved in %d iterations (%.1fs)" % (n, it, time.time()-t0))

Q = {c: {n: tr(poch(n) * g[c][n]) for n in range(NMAX+1)} for c in profiles}

# =====================================================================
# ferm_{s,t}(n): my own transcription of the tex's (Fermst)/(Fermst2)
# =====================================================================
def ferm(n, s, t):
    tot = R.zero()
    if 1 <= t <= 3:
        d3 = 1 if t == 3 else 0   # delta_{t,3} in [n2+n3+d3; m2]
        d2 = 1 if t == 2 else 0   # delta_{t,2} in [n1-n2+m2+d2; m1]
        for n2 in range(n+1):
            for n3 in range(n2+1):
                lin_n = sum(v for i, v in ((1, n), (2, n2), (3, n3)) if i >= s)
                for m2 in range(n2+n3+d3+1):
                    lin_m2 = m2 if t <= 2 else 0
                    base = qb(n, n2) * qb(n2, n3) * qb(n2+n3+d3, m2)
                    e0 = (n3**2 + lin_n + lin_m2
                          + n**2 + n2**2 - n2*m2 + m2**2)
                    top1 = n - n2 + m2 + d2
                    for m1 in range(top1+1):
                        lin_m1 = m1 if t <= 1 else 0
                        e = e0 + m1**2 - n*m1 + lin_m1
                        assert e >= 0
                        tot += base * qb(top1, m1) * q**e
    elif t == 4:
        assert 1 <= s <= 3
        for n2 in range(n+1):
            for n3 in range(n2+2):
                lin_n = sum(v for i, v in ((1, n), (2, n2), (3, n3)) if i >= s)
                for m2 in range(n2+n3+1):
                    base = qb(n, n2) * qb(n2+1, n3) * qb(n2+n3, m2)
                    e0 = (n3**2 - n3 + lin_n
                          + n**2 + n2**2 - n2*m2 + m2**2)
                    top1 = n - n2 + m2
                    for m1 in range(top1+1):
                        e = e0 + m1**2 - n*m1
                        assert e >= 0
                        tot += base * qb(top1, m1) * q**e
    else:
        raise ValueError
    return tot

CORE = [(6,1,1), (5,2,1), (5,1,2), (4,3,1), (4,1,3), (4,2,2), (3,3,2)]

# ---------- [W'] main check ----------
log("[W'] Q_{n,c} == ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n), exact, n<=%d" % NMAX)
FCACHE = {}
def fermc(n, s, t):
    if (n, s, t) not in FCACHE: FCACHE[(n, s, t)] = ferm(n, s, t)
    return FCACHE[(n, s, t)]

okW = True; maxdeg = 0
for c in CORE:
    c1, c2, c3 = c
    for n in range(NMAX+1):
        Dnc = fermc(n, c2+1, c3+1) - q * fermc(n, c2, c3)
        maxdeg = max(maxdeg, Dnc.degree())
        assert Dnc.degree() < PREC, "PREC too small!"
        match = (tr(Dnc) == Q[c][n])
        nonneg = all(cf >= 0 for cf in Dnc.coefficients())
        val1 = Dnc(1) == 14**n     # Q_n(1) = (K-1)^n, K=(d+1)(d+2)/6=15
        if not (match and val1):
            okW = False
            log("  FAIL c=%s n=%d match=%s val1=%s nonneg=%s" % (c, n, match, val1, nonneg))
    log("  c=%s: n=0..%d MATCH engine exactly; nonneg=%s; Q_n(1)=14^n OK (%.1fs)"
        % (c, NMAX, all(all(cf >= 0 for cf in (fermc(n, c2+1, c3+1) - q*fermc(n, c2, c3)).coefficients()) for n in range(NMAX+1)), time.time()-t0))
log("[W'] overall: %s (max deg of any Q = %d < PREC=%d)" % (okW, maxdeg, PREC))

# =====================================================================
# S11 truncated evaluator (my own, from Uncu eq:Sm1 at k=4)
# S11n(n; rho|sigma) = [z^n] S11 mod q^CHK
# =====================================================================
def S11n(n, rho, sig):
    tot = R.zero()
    r1 = n
    smax = n + 2 + isqrt(4*CHK)   # block1 = r1^2 - r1 s1 + s1^2 + lin >= s1(s1-n) > CHK beyond
    for r2 in range(r1+1):
        for r3 in range(r2+1):
            for s1 in range(smax+1):
                # cheap prune: total quadratic >= block1 (all blocks >= 0)
                b1 = r1*r1 - r1*s1 + s1*s1 + rho[0]*r1 + sig[0]*s1
                if b1 >= CHK: continue
                for s2 in range(s1+1):
                    b2 = r2*r2 - r2*s2 + s2*s2 + rho[1]*r2 + sig[1]*s2
                    if b1 + b2 >= CHK: continue
                    for s3 in range(s2+1):
                        e = (b1 + b2 + r3*r3 - r3*s3 + s3*s3
                             + rho[2]*r3 + sig[2]*s3 + 2*r3*s3)
                        if e >= CHK: continue
                        dens = [r1-r2, r2-r3, r3, s1-s2, s2-s3, s3]
                        den = R.one()
                        for j in dens: den = tr(den * poch(j), CHK)
                        den = tr(den * poch(r3+s3+1), CHK)
                        tot += tr(q**e * series_inv(den, CHK), CHK)
    return tr(tot, CHK)

E = {0: (1,1,1), 1: (0,1,1), 2: (0,0,1), 3: (0,0,0)}

# ---------- [S'] Uncu rows vs my engine (list + chirality + normalization) ----------
log("[S'] (q)_inf (S11(e_c2|e_c3) - q S11(e_{c2-1}|e_{c3-1})) == [z^n]G_c, n<=3, all 7")
okS = True
for c in CORE:
    c1, c2, c3 = c
    for n in range(4):
        lhs = tr(PINF_CHK * (S11n(n, E[c2], E[c3]) - q * S11n(n, E[c2-1], E[c3-1])), CHK)
        rhs = tr(Q[c][n] * series_inv(poch(n), CHK), CHK)
        if lhs != rhs:
            okS = False; log("  FAIL c=%s n=%d" % (c, n))
    log("  c=%s OK (%.1fs)" % (c, time.time()-t0))
log("[S'] overall: %s" % okS)

# ---------- [V'] verbatim limit: S11(e_{s-1}|e_{t-1}) == Ferm_{s,t}/(q)_inf ----------
log("[V'] verbatim limit, pairs (2,2),(4,3),(3,3),(2,4) [incl. t=4], n<=3")
okV = True
for (s, t) in [(2,2), (4,3), (3,3), (2,4)]:
    for n in range(4):
        lhs = S11n(n, E[s-1], E[t-1])
        rhs = tr(fermc(n, s, t) * series_inv(tr(poch(n)*PINF_CHK, CHK), CHK), CHK)
        if lhs != rhs:
            okV = False; log("  FAIL (s,t)=(%d,%d) n=%d" % (s, t, n))
    log("  (s,t)=(%d,%d) OK" % (s, t))
log("[V'] overall: %s" % okV)

# ---------- [FF'] transcription guard: Eq_F2 == Eq_mineen/mineen2 at finite n0,m0 ----------
# k=3, a=-1 (sigma=(1,1,-1)). Per z-order (z^{n1}), mod q^CHK.
def F2_lhs(n0, m0, s, t):
    # returns dict n1 -> poly mod q^CHK
    out = {}
    for n1 in range(n0+1):
        acc = R.zero()
        for n2 in range(n1+1):
            for n3 in range(n2+1):
                for m1 in range(m0+1):
                    for m2 in range(m1+1):
                        for m3 in range(m2+1):
                            lin = (sum(v for i, v in ((1,n1),(2,n2),(3,n3)) if i >= s)
                                 + sum(v for i, v in ((1,m1),(2,m2),(3,m3)) if i >= t))
                            quad = (n1*n1 - n1*m1 + m1*m1 + n2*n2 - n2*m2 + m2*m2
                                    + n3*n3 + n3*m3 + m3*m3)   # sigma_3 = -1
                            num = (qb(n0,n1)*qb(n1,n2)*qb(n2,n3)
                                 * qb(m0,m1)*qb(m1,m2)*qb(m2,m3))
                            acc += tr(q**(quad+lin) * num * series_inv(poch(n3+m3+1), CHK), CHK)
        out[n1] = tr(acc, CHK)
    return out

def mineen_rhs(n0, m0, s, t):
    out = {}
    for n1 in range(n0+1):
        acc = R.zero()
        if 1 <= t <= 3:
            d3 = 1 if t == 3 else 0; d2 = 1 if t == 2 else 0; d1 = 1 if t == 1 else 0
            for n2 in range(n1+1):
                for n3 in range(n2+1):
                    lin_n = sum(v for i, v in ((1,n1),(2,n2),(3,n3)) if i >= s)
                    for m2 in range(n2+n3+d3+1):
                        for m1 in range(n1-n2+m2+d2+1):
                            jj = m0 - n1 + m1 + d1
                            if jj < 0: continue
                            lin_m = (m1 if t <= 1 else 0) + (m2 if t <= 2 else 0)
                            e = (n3*n3 + lin_n + lin_m
                                 + n1*n1 - n1*m1 + m1*m1 + n2*n2 - n2*m2 + m2*m2)
                            num = (qb(n0,n1)*qb(n1,n2)*qb(n2,n3)
                                 * qb(n1-n2+m2+d2, m1)*qb(n2+n3+d3, m2))
                            acc += tr(q**e * num * series_inv(poch(jj), CHK), CHK)
        else:  # t = 4, Eq_mineen2
            for n2 in range(n1+1):
                for n3 in range(n2+2):
                    lin_n = sum(v for i, v in ((1,n1),(2,n2),(3,n3)) if i >= s)
                    for m2 in range(n2+n3+1):
                        for m1 in range(n1-n2+m2+1):
                            jj = m0 - n1 + m1
                            if jj < 0: continue
                            e = (n3*n3 - n3 + lin_n
                                 + n1*n1 - n1*m1 + m1*m1 + n2*n2 - n2*m2 + m2*m2)
                            num = (qb(n0,n1)*qb(n1,n2)*qb(n2+1,n3)
                                 * qb(n1-n2+m2, m1)*qb(n2+n3, m2))
                            acc += tr(q**e * num * series_inv(poch(jj), CHK), CHK)
        out[n1] = tr(acc, CHK)
    return out

log("[FF'] Eq_F2 == Eq_mineen/mineen2, k=3, a=-1, all 15 (s,t), n0,m0 in {0,1,2}")
okFF = True
pairs = [(s, t) for s in range(1,5) for t in range(1,4)] + [(s,4) for s in range(1,4)]
for (s, t) in pairs:
    for n0 in range(3):
        for m0 in range(3):
            L = F2_lhs(n0, m0, s, t); Rr = mineen_rhs(n0, m0, s, t)
            if L != Rr:
                okFF = False; log("  FAIL (s,t)=(%d,%d) n0=%d m0=%d" % (s,t,n0,m0))
    log("  (s,t)=(%d,%d) OK (%.1fs)" % (s, t, time.time()-t0))
log("[FF'] overall: %s" % okFF)

# =====================================================================
# [K] strike-certificate spot checks (Laurent ring; failures should be REAL)
# =====================================================================
L_ = LaurentPolynomialRing(ZZ, 'q'); ql = L_.gen()
def qbl(a, b): return L_(qb(a, b))

def Lslice(n, n2, n3):
    tot = L_.zero()
    for m2 in range(n2+n3+1):
        N = n - n2 + m2
        for m1 in range(N+2):
            tot += (ql**(m1*m1 - n*m1 + m2*m2 - n2*m2 + m2) * qbl(n2+n3, m2)
                    * (qbl(N+1, m1) - ql**(1+n3+m1) * qbl(N, m1)))
    return tot

def neg(p): return any(cf < 0 for cf in p.coefficients())

# K1: one-round absorption residual R = B - q^{1+n3} A fails for (4,3,1) slices
log("[K1] strike 1: residual B - q^{1+n3}A per (n,n2,n3) slice, (4,3,1)")
k1_fail_found = False; k1_L_nonneg = True
for n in range(6):
    for n2 in range(n+1):
        for n3 in range(n2+1):
            A = L_.zero(); B = L_.zero()
            for m2 in range(n2+n3+1):
                N = n - n2 + m2
                w = ql**(m2*m2 - n2*m2 + m2) * qbl(n2+n3, m2)
                for m1 in range(N+2):
                    A += w * ql**(m1*m1 - n*m1 + m1) * qbl(N, m1)
                    B += w * ql**(m1*m1 - n*m1) * qbl(N, m1-1)
            Rres = B - ql**(1+n3) * A
            if neg(Rres): k1_fail_found = True
            if neg(Lslice(n, n2, n3)): k1_L_nonneg = False
log("  residual has negative coefficients somewhere: %s (strike claims failure: consistent=%s)"
    % (k1_fail_found, k1_fail_found))
log("  Lemma-candidate-A slices L(n,n2,n3) all nonneg (n<=5): %s" % k1_L_nonneg)

# K2: elementary moves fail; only diagonal is nonneg
log("[K2] strike 2: Route I/II first brackets have negative coefficients")
k2 = {}
for c in [(4,2,2), (5,2,1)]:
    c1, c2, c3 = c; s, t = c2+1, c3+1
    negI = any(neg(L_(fermc(n, s, t) - fermc(n, s-1, t))) for n in range(6))
    negII = any(neg(L_(fermc(n, s, t) - q*fermc(n, s, t-1))) for n in range(6))
    k2[c] = (negI, negII)
    log("  c=%s: s-move bracket negative: %s ; t-move bracket negative: %s" % (c, negI, negII))

# K3: pure n-decrement of L fails at (2,1,1) with -q^6
log("[K3] strike 3: r = L(2,1,1) - L(1,1,1)")
r = Lslice(2,1,1) - Lslice(1,1,1)
log("  r = %s" % r)
log("  r has negative coefficient: %s (claimed -q^6: %s)" % (neg(r), r.coefficients()[r.exponents().index(6)] if 6 in r.exponents() else 'absent'))

log("")
log("VERIFIER OVERALL: W'=%s S'=%s V'=%s FF'=%s K1(consistent)=%s K3(neg)=%s  [%.1fs]"
    % (okW, okS, okV, okFF, k1_fail_found, neg(r), time.time()-t0))
