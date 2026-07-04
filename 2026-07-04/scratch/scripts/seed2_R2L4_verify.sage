# Seed 2, Layer 4, Round 2 — verify the VERBATIM finite-form route for the d=8 core.
#
# Claim chain (Finding L4.1, scratch/prove-seed2-layer4.md):
#   (V)  lim_{n0,m0->oo} F^{(-1)}_{n0,m0;3,s,t} = S_11(z; e_{s-1}|e_{t-1})   [Eq_F2 LHS]
#   (V') the same limit of the RHS (Eq_mineen / Eq_mineen2, PROVED) = Ferm_{s,t}/(q)_inf
#   (W)  G_c = Ferm_{c2+1,c3+1} - q Ferm_{c2,c3}   for all 6 core orbits (via Uncu thm:m11)
#   (Wn) Q_{n,c} = ferm(n; c2+1,c3+1) - q ferm(n; c2,c3)  EXACTLY in Z[q]
# Checks:
#   [FF2] Eq_F2 == Eq_mineen (t<=3) / Eq_mineen2 (t=4) at k=3, a=-1, n0,m0 in {0..3},
#         all (s,t) with 1<=s<=4,1<=t<=3 and (s,4) with s<=3.  (transcription guard)
#   [V]   S11_zorder(n, e_{s-1}, e_{t-1}) == [z^n] Ferm_{s,t} / (q)_inf, n<=3, spot (s,t).
#   [Wn]  ferm-difference == engine Q_n (seed8 engine, target-first kernel), n=0..NMAX,
#         exact Z[q], all 6 core orbits + (3,3,2) as a known-good control.
from sage.all import *
import time

t00 = time.time()
PREC = 200
CHK  = 150
NMAX = 8          # engine depth (Q_n exact for n<=NMAX)
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
q = R.gen()
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()

pc = {}
def P(n):
    if n not in pc:
        p = R(1)
        for i in range(1, n+1): p *= (1 - q**i)
        pc[n] = p
    return pc[n]
ic = {}
def Pinv(n):
    if n not in ic: ic[n] = P(n)**(-1)
    return ic[n]
qinf = R(1)
for i in range(1, PREC): qinf *= (1 - q**i)
qinf_inv = qinf**(-1)

def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)

# ---------------- Eq_F2 LHS (k=3, a=-1): finite n0,m0 ----------------
def F2_LHS(n0, m0, s, t):
    sig = (1, 1, -1)
    Rz = PolynomialRing(R, 'z'); z = Rz.gen()
    totz = Rz(0)
    for n1 in range(n0+1):
      for n2 in range(n1+1):
        for n3 in range(n2+1):
          for m1 in range(m0+1):
            for m2 in range(m1+1):
              for m3 in range(m2+1):
                nn = (n1, n2, n3); mm = (m1, m2, m3)
                e = sum(nn[i]**2 - sig[i]*nn[i]*mm[i] + mm[i]**2 for i in range(3))
                e += sum(nn[i] for i in range(s-1, 3)) + sum(mm[i] for i in range(t-1, 3))
                coef = (R(qbin(n0, n1)*qbin(n1, n2)*qbin(n2, n3)
                        *qbin(m0, m1)*qbin(m1, m2)*qbin(m2, m3))
                        * q**e * Pinv(n3+m3+1))
                totz += coef * z**n1
    return totz

# ---------------- Eq_mineen / Eq_mineen2 RHS (k=3, a=-1): finite n0,m0 --------
def F2_RHS(n0, m0, s, t):
    Rz = PolynomialRing(R, 'z'); z = Rz.gen()
    totz = Rz(0)
    if t <= 3:
        d1 = 1 if t == 1 else 0
        for n1 in range(n0+1):
          for n2 in range(n1+1):
            for n3 in range(n2+1):
              m3 = 2*n3
              for m2 in range(n2 - n3 + m3 + (1 if t == 3 else 0) + 1):
                for m1 in range(n1 - n2 + m2 + (1 if t == 2 else 0) + 1):
                  if m0 - n1 + m1 + d1 < 0: continue
                  e = (n3**2 + sum((n1, n2, n3)[i] for i in range(s-1, 3))
                       + sum((m1, m2)[i] for i in range(t-1, 2))
                       + n1**2 - n1*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                  b = (qbin(n0, n1)
                       * qbin(n1, n2) * qbin(n1 - n2 + m2 + (1 if t == 2 else 0), m1)
                       * qbin(n2, n3) * qbin(n2 - n3 + m3 + (1 if t == 3 else 0), m2))
                  if b == 0: continue
                  totz += R(b) * q**e * Pinv(m0 - n1 + m1 + d1) * z**n1
    else:  # t = 4: Eq_mineen2, needs s <= 3
        assert 1 <= s <= 3
        for n1 in range(n0+1):
          for n2 in range(n1+1):
            for n3 in range(n2+2):          # [n2+1, n3] allows n3 <= n2+1
              m3 = 2*n3
              for m2 in range(n2 - n3 + m3 + 1):
                for m1 in range(n1 - n2 + m2 + 1):
                  if m0 - n1 + m1 < 0: continue
                  e = (n3**2 - n3 + sum((n1, n2, n3)[i] for i in range(s-1, 3))
                       + n1**2 - n1*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                  b = (qbin(n0, n1)
                       * qbin(n1, n2) * qbin(n1 - n2 + m2, m1)
                       * qbin(n2 + 1, n3) * qbin(n2 - n3 + m3, m2))
                  if b == 0: continue
                  totz += R(b) * q**e * Pinv(m0 - n1 + m1) * z**n1
    return totz

# ---------------- ferm(n; s,t): Q-level limit of the RHS (exact Z[q]) ---------
def ferm_n(n, s, t):
    """(q)_n [z^n] Ferm_{s,t} — the (q)_{n1} denominator cancels at n1=n. Exact poly."""
    tot = Rq(0)
    if t <= 3:
        for n2 in range(n+1):
          for n3 in range(n2+1):
            m3 = 2*n3
            for m2 in range(n2 - n3 + m3 + (1 if t == 3 else 0) + 1):
              for m1 in range(n - n2 + m2 + (1 if t == 2 else 0) + 1):
                e = (n3**2 + sum((n, n2, n3)[i] for i in range(s-1, 3))
                     + sum((m1, m2)[i] for i in range(t-1, 2))
                     + n**2 - n*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                b = (qbin(n, n2) * qbin(n - n2 + m2 + (1 if t == 2 else 0), m1)
                     * qbin(n2, n3) * qbin(n2 - n3 + m3 + (1 if t == 3 else 0), m2))
                if b == 0: continue
                tot += b * qp**e
    else:
        assert 1 <= s <= 3
        for n2 in range(n+1):
          for n3 in range(n2+2):
            m3 = 2*n3
            for m2 in range(n2 - n3 + m3 + 1):
              for m1 in range(n - n2 + m2 + 1):
                e = (n3**2 - n3 + sum((n, n2, n3)[i] for i in range(s-1, 3))
                     + n**2 - n*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                b = (qbin(n, n2) * qbin(n - n2 + m2, m1)
                     * qbin(n2 + 1, n3) * qbin(n2 - n3 + m3, m2))
                if b == 0: continue
                tot += b * qp**e
    return tot

# ---------------- S11 with general rho,sigma (from seed2_R2L3_s11_chain) ------
SMAX = 24
def S11_zorder(n, rho, sigma):
    r1 = n
    total = R(0)
    for r2 in range(r1+1):
        for r3 in range(r2+1):
            for s1 in range(SMAX):
                for s2 in range(s1+1):
                    for s3 in range(s2+1):
                        e = (r1**2 - r1*s1 + s1**2 + rho[0]*r1 + sigma[0]*s1
                           + r2**2 - r2*s2 + s2**2 + rho[1]*r2 + sigma[1]*s2
                           + r3**2 - r3*s3 + s3**2 + rho[2]*r3 + sigma[2]*s3
                           + 2*r3*s3)
                        if e >= PREC: continue
                        total += q**e * (Pinv(r1-r2)*Pinv(r2-r3)*Pinv(s1-s2)*Pinv(s2-s3)
                                         *Pinv(r3)*Pinv(s3)*Pinv(r3+s3+1))
    return total

evec = {3: (0,0,0), 2: (0,0,1), 1: (0,1,1), 0: (1,1,1)}

# =============================== [FF2] ========================================
print("[FF2] Prop_finiteform2 transcription check, k=3, a=-1, n0,m0 in {0..3}")
pairs = [(s, t) for s in range(1, 5) for t in range(1, 4)] + [(s, 4) for s in range(1, 4)]
okFF = True
for (s, t) in pairs:
    bad = []
    for n0 in range(4):
        for m0 in range(4):
            L = F2_LHS(n0, m0, s, t); Rr = F2_RHS(n0, m0, s, t)
            Dz = L - Rr
            for cz in Dz.coefficients():
                if cz.truncate(CHK) != 0:
                    bad.append((n0, m0)); break
    ok = (len(bad) == 0)
    okFF = okFF and ok
    print("  (s,t)=(%d,%d): %s %s  [%.0fs]" % (s, t, "PASS" if ok else "FAIL", bad if bad else "", time.time()-t00), flush=True)
print("[FF2] overall:", okFF, flush=True)

# =============================== [V] ==========================================
print("[V] verbatim limit: S11(e_{s-1}|e_{t-1}) == [z^n] Ferm_{s,t}/(q)_inf, n<=3")
okV = True
for (s, t) in [(2,2), (1,1), (3,2), (3,3), (2,4), (4,2)]:
    ok = True
    for n in range(4):
        lhs = S11_zorder(n, evec[s-1], evec[t-1]).truncate(CHK)
        rhs = (R(ferm_n(n, s, t)) * Pinv(n) * qinf_inv).truncate(CHK)
        if lhs != rhs: ok = False
    okV = okV and ok
    print("  (s,t)=(%d,%d): %s  [%.0fs]" % (s, t, "PASS" if ok else "FAIL", time.time()-t00), flush=True)
print("[V] overall:", okV, flush=True)

# =============================== [Wn] =========================================
print("[Wn] ferm difference == engine Q_n (exact Z[q]), d=8, n<=%d" % NMAX)
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
H, viol = build_H(8, NMAX, verbose=False)
core = [(6,1,1), (5,2,1), (5,1,2), (4,3,1), (4,1,3), (4,2,2), (3,3,2)]
okW = True
for c in core:
    c1, c2, c3 = c
    s, t = c2 + 1, c3 + 1
    ok = True; firstneg = None
    for n in range(NMAX+1):
        lhs = ferm_n(n, s, t) - qp * ferm_n(n, s-1, t-1)
        rhs = gauss_a(H, c, n)
        if lhs != rhs: ok = False
        nr = neg_report(lhs)
        if nr is not None and firstneg is None: firstneg = (n, nr)
    okW = okW and ok
    print("  c=%s (s,t)=(%d,%d)-(%d,%d): match=%s  Q_n>=0 all n<=%d: %s  [%.0fs]"
          % (c, s, t, s-1, t-1, ok, NMAX, firstneg is None, time.time()-t00), flush=True)
print("[Wn] overall:", okW, flush=True)
print("TOTAL %.0fs  FF2=%s V=%s Wn=%s" % (time.time()-t00, okFF, okV, okW))
