# Seed 1 R2 L4: verify the (4,3,3) chain at d=10 (modulus 13).
#   Chain: Warnaar Prop_finiteform a=+1 k=3  --limit-->  T  --Poch split-->
#          S13(e3|e3) - q S13(e2|e2)  ==  H_{(4,3,3)}  (Uncu thm:m13, PROVED)
#   => G_{(4,3,3)} = FERM3p, Q_n manifestly nonneg.
# Checks:
#   [FF] finite form a=+1, k=3, exact at n0,m0 <= 3   (transcription guard)
#   [A]  T == S13(e3|e3) - q S13(e2|e2)  at z-orders n=0..4  (Pochhammer split)
#   [B]  (q)_n (q)_inf [z^n] D1 == Q_n engine (d=10, c=(4,3,3)), n=0..4
#   [C]  FERM3p Q_n (finite qbinomial sum) == engine Q_n, n=0..NMAXC; Q_n(1)==21^n
#   [D]  FERM3p/(q)_inf == T at z-orders n=0..4
import time
t00 = time.time()

PREC = 300
CHK  = 150
R.<q> = PowerSeriesRing(ZZ, default_prec=PREC)
Rq = PolynomialRing(ZZ, 'qq'); qq = Rq.gen()

pc = {}
def P(n):
    if n not in pc:
        p = R(1)
        for i in range(1, n+1): p *= (1 - q**i)
        pc[n] = p
    return pc[n]
def Pinv(n):
    key = ('i', n)
    if key not in pc: pc[key] = P(n)**(-1)
    return pc[key]

qinf = R(1)
for i in range(1, PREC):
    qinf *= (1 - q**i)

SMAX = 26

def S13_zorder(n, rho, sigma):
    """[z^n] S_13(z; rho|sigma): r1=n. NO 2 r3 s3 cross term (eq:Sp1, m=3k+1, k=4).
       denom (q)_{r1-r2}(q)_{r2-r3}(q)_{s1-s2}(q)_{s2-s3}(q)_{r3}(q)_{s3}(q)_{r3+s3+1}."""
    r1 = n
    total = R(0)
    for r2 in range(r1+1):
        for r3 in range(r2+1):
            for s1 in range(SMAX):
                for s2 in range(s1+1):
                    for s3 in range(s2+1):
                        e = (r1^2 - r1*s1 + s1^2 + rho[0]*r1 + sigma[0]*s1
                           + r2^2 - r2*s2 + s2^2 + rho[1]*r2 + sigma[1]*s2
                           + r3^2 - r3*s3 + s3^2 + rho[2]*r3 + sigma[2]*s3)
                        if e >= PREC: continue
                        total += q**e * (Pinv(r1-r2)*Pinv(r2-r3)*Pinv(s1-s2)
                                 *Pinv(s2-s3)*Pinv(r3)*Pinv(s3)*Pinv(r3+s3+1))
    return total

def T_zorder(n):
    """[z^n] T: same as S13 at rho=sigma=(0,0,0) but denominator (q)_{r3+s3} (no +1)."""
    r1 = n
    total = R(0)
    for r2 in range(r1+1):
        for r3 in range(r2+1):
            for s1 in range(SMAX):
                for s2 in range(s1+1):
                    for s3 in range(s2+1):
                        e = (r1^2 - r1*s1 + s1^2 + r2^2 - r2*s2 + s2^2
                           + r3^2 - r3*s3 + s3^2)
                        if e >= PREC: continue
                        total += q**e * (Pinv(r1-r2)*Pinv(r2-r3)*Pinv(s1-s2)
                                 *Pinv(s2-s3)*Pinv(r3)*Pinv(s3)*Pinv(r3+s3))
    return total

e3 = (0,0,0); e2 = (0,0,1)

# ---------- [FF] finite form a=+1, k=3, exact at small n0,m0 ----------
def qb(a, b):  # q-binomial as power series
    return R(q_binomial(a, b, qq)) if 0 <= b <= a else R(0)

def FF_lhs(n0, m0, z):
    tot = R(0)
    for n1 in range(n0+1):
     for n2 in range(n1+1):
      for n3 in range(n2+1):
       for m1 in range(m0+1):
        for m2 in range(m1+1):
         for m3 in range(m2+1):
            e = (n1^2-n1*m1+m1^2 + n2^2-n2*m2+m2^2 + n3^2-n3*m3+m3^2)
            tot += z**n1 * q**e * Pinv(n3+m3) * qb(n0,n1)*qb(n1,n2)*qb(n2,n3) \
                   * qb(m0,m1)*qb(m1,m2)*qb(m2,m3)
    return tot

def FF_rhs(n0, m0, z):
    tot = R(0)
    for n1 in range(n0+1):
     for n2 in range(n1+1):
      for n3 in range(n2+1):
       for m3 in range(2*n3+1):
        for m2 in range(n2-n3+m3+1):
         for m1 in range(n1-n2+m2+1):
            if m0 - n1 + m1 < 0: continue
            e = (n1^2-n1*m1+m1^2 + n2^2-n2*m2+m2^2 + n3^2-n3*m3+m3^2)
            tot += z**n1 * q**e * Pinv(m0-n1+m1) * qb(n0,n1)*qb(2*n3,m3) \
                   * qb(n1,n2)*qb(n1-n2+m2,m1)*qb(n2,n3)*qb(n2-n3+m3,m2)
    return tot

print("== [FF] Warnaar Prop_finiteform a=+1, k=3 ==", flush=True)
okFF = True
Rz.<z> = PolynomialRing(R)
for n0 in range(4):
    for m0 in range(4):
        L = FF_lhs(n0, m0, z); Rr = FF_rhs(n0, m0, z)
        d = L - Rr
        good = all(c.truncate(CHK) == 0 for c in d.coefficients())
        okFF = okFF and good
        print("  n0=%d m0=%d: %s" % (n0, m0, good), flush=True)
print("[FF] overall:", okFF, " (%.0fs)" % (time.time()-t00), flush=True)

# ---------- engine ground truth: d=10, c=(4,3,3) ----------
print("== engine: building H at d=10 ==", flush=True)
def profiles(d): return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]
def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

NMAXC = 12
d = 10
profs = profiles(d)
E = {(c, cp): emd(c, cp) for c in profs for cp in profs}
H = {0: {c: Rq(1) for c in profs}}
for m in range(1, NMAXC+1):
    div = 1 + qq**m + qq**(2*m)
    Hm = {}
    for c in profs:
        rhs = sum(qq**(m*E[(c, cp)]) * H[m-1][cp] for cp in profs)  # target-first
        quo, rem = rhs.quo_rem(div)
        assert rem == 0, "DIV FAIL m=%d c=%s" % (m, c)
        Hm[c] = quo
    H[m] = Hm
    print("  m=%d done (%.0fs)" % (m, time.time()-t00), flush=True)

c433 = (4, 3, 3)
def gauss_a(n):
    return sum((-1)**(n-m) * qq**binomial(n-m, 2) * q_binomial(n, m, qq) * H[m][c433]
               for m in range(0, n+1))
Qn_engine = {n: gauss_a(n) for n in range(NMAXC+1)}
print("engine Q_n ready; Q_n(1) vs 21^n:",
      all(Qn_engine[n](1) == 21**n for n in range(NMAXC+1)), flush=True)

# ---------- [C] FERM3p Q_n formula vs engine ----------
def Q_ferm(n):
    tot = Rq(0)
    for n2 in range(n+1):
        for n3 in range(n2+1):
            for m3 in range(2*n3+1):
                for m2 in range(n2-n3+m3+1):
                    for m1 in range(n-n2+m2+1):
                        e = (n^2-n*m1+m1^2 + n2^2-n2*m2+m2^2 + n3^2-n3*m3+m3^2)
                        tot += qq**e * q_binomial(n,n2,qq) * q_binomial(n-n2+m2,m1,qq) \
                               * q_binomial(n2,n3,qq) * q_binomial(n2-n3+m3,m2,qq) \
                               * q_binomial(2*n3,m3,qq)
    return tot

print("== [C] FERM3p Q_n vs engine (exact Z[q]) ==", flush=True)
okC = True
for n in range(NMAXC+1):
    qf = Q_ferm(n)
    match = (qf == Qn_engine[n])
    nonneg = all(cf >= 0 for cf in qf.list())
    okC = okC and match and nonneg
    print("  n=%d: match=%s nonneg=%s deg=%d (%.0fs)"
          % (n, match, nonneg, qf.degree(), time.time()-t00), flush=True)
print("[C] overall:", okC, flush=True)

# ---------- [A],[B],[D] series checks ----------
print("== [A],[B],[D] series checks n=0..4 ==", flush=True)
okA = okB = okD = True
for n in range(5):
    Se3 = S13_zorder(n, e3, e3)
    Se2 = S13_zorder(n, e2, e2)
    Tn  = T_zorder(n)
    D1  = Se3 - q*Se2
    a_ok = ((Tn - D1).truncate(CHK) == 0)
    Qs = (P(n) * qinf * D1).truncate(CHK)
    eng = R(Qn_engine[n](q)).truncate(CHK)
    b_ok = ((Qs - eng).truncate(CHK) == 0)
    # [D]: (q)_n [z^n] FERM3p / (q)_inf == T  <=>  (q)_n qinf T == Q_ferm(n) (same as B via C)
    d_ok = ((P(n) * qinf * Tn).truncate(CHK) == R(Q_ferm(n)(q)).truncate(CHK))
    okA &= a_ok; okB &= b_ok; okD &= d_ok
    print("  n=%d: [A] T==D1: %s  [B] (q)_n(q)_inf[z^n]D1==Q_n: %s  [D] limit: %s (%.0fs)"
          % (n, a_ok, b_ok, d_ok, time.time()-t00), flush=True)

print("OVERALL: FF=%s A=%s B=%s C=%s D=%s  total %.0fs"
      % (okFF, okA, okB, okC, okD, time.time()-t00), flush=True)
