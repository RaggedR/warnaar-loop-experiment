# INDEPENDENT VERIFIER script (Seed 1 Layer 4 audit): Q_{n,(4,3,3)}, d=10, mod 13.
# Written from scratch; does NOT reuse seed code or the seeds' H/EMD-kernel engine.
# Engine = raw Corteel-Welsh functional equation (Uncu 2024 th:CW / eq:Grec):
#   G_c(z,q) = Sum_{0 != J subset I_c} (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(z q^{|J|}, q),
#   G_c(0,q) = 1;  c(J) per Uncu eq:c(J) with cyclic convention c_0 = c_r.
# Solved per z-order by q-adic fixed-point iteration over ALL 66 profiles of d=10.
# Checks:
#  [E]  fixed-point convergence for every n (iterates stabilize exactly mod q^PREC)
#  [C'] Q_n := (q)_n [z^n] G_{(4,3,3)}  ==  fermionic sum F_n (Corollary 2 of the tex),
#       n = 0..NMAX, compared mod q^PREC with PREC > deg F_n = 9 n^2; plus F_n >= 0
#       coefficientwise and F_n(1) == 21^n.
#  [S'] Uncu row + normalization: [z^n]G == (q)_inf ([z^n]S13(e3|e3) - q [z^n]S13(e2|e2)),
#       n = 0..3, mod q^CHK   (independent replication of seed check [B])
#  [A'] Pochhammer split: [z^n]T == [z^n](S13(e3|e3) - q S13(e2|e2)), n = 0..3, mod q^CHK
#  [D'] limit: (q)_n (q)_inf [z^n]T == F_n, n = 0..3, mod q^CHK
#  [FF'] transcription guard on Warnaar Prop_finiteform a=+1, k=3, n0,m0 <= 2, mod q^CHK
import time, itertools
t0 = time.time()

NMAX = 12
PREC = 1320          # > 9*12^2 = 1296
CHK  = 120
d    = 10
target = (4, 3, 3)

Rq = PolynomialRing(ZZ, 'q'); q = Rq.gen()

def trunc(p, N=PREC):
    return p.truncate(N)

# ---------- profiles and the CW subset move ----------
profs = [(a, b, d - a - b) for a in range(d + 1) for b in range(d - a + 1)]
assert len(profs) == 66 and target in profs

def cJ(c, J):
    """Uncu eq:c(J); indices 1..3, cyclic: predecessor of 1 is 3."""
    out = []
    for i in (1, 2, 3):
        prev = 3 if i == 1 else i - 1
        ci = c[i - 1]
        if i in J and prev not in J:
            ci -= 1
        elif i not in J and prev in J:
            ci += 1
        out.append(ci)
    return tuple(out)

moves = {}   # c -> list of (sign, |J|, kappa list, c(J))
for c in profs:
    Ic = [i for i in (1, 2, 3) if c[i - 1] > 0]
    lst = []
    for r in range(1, len(Ic) + 1):
        for J in itertools.combinations(Ic, r):
            cp = cJ(c, set(J))
            assert sum(cp) == d and min(cp) >= 0, (c, J, cp)
            # (zq;q)_{|J|-1} = prod_{t=1}^{|J|-1} (1 - z q^t): kappa[a] = [z^a]
            kap = [Rq(1)]
            for t in range(1, r):
                kap = [(kap[a] if a < len(kap) else Rq(0))
                       - (q**t) * (kap[a - 1] if a >= 1 else Rq(0))
                       for a in range(len(kap) + 1)]
            lst.append(((-1)**(r - 1), r, kap, cp))
    moves[c] = lst

# sanity vs published display eq:recH730 (Uncu):
assert sorted((s, j, cp) for s, j, k, cp in moves[(7, 3, 0)]) == \
       sorted([(1, 1, (6, 4, 0)), (1, 1, (7, 2, 1)), (-1, 2, (6, 3, 1))])
print("profile/move table built, eq:recH730 shape reproduced  (%.0fs)" % (time.time()-t0), flush=True)

# ---------- solve G coefficientwise in z ----------
V = {0: {c: Rq(1) for c in profs}}   # [z^0] G_c = G_c(0,q) = 1
okE = True
for n in range(1, NMAX + 1):
    # w[c]: contributions with z-order from (zq;q)_{|J|-1} at a >= 1
    w = {}
    for c in profs:
        acc = Rq(0)
        for s, r, kap, cp in moves[c]:
            for a in range(1, min(n, len(kap) - 1) + 1):
                b = n - a
                acc += s * trunc(kap[a] * (q**(b * r)) * V[b][cp])
        w[c] = trunc(acc)
    v = dict(w)
    it = 0
    max_it = PREC // n + 3
    while True:
        it += 1
        vn = {}
        for c in profs:
            acc = w[c]
            for s, r, kap, cp in moves[c]:
                acc = acc + s * (q**(n * r)) * v[cp]
            vn[c] = trunc(acc)
        if vn == v:
            break
        v = vn
        if it > max_it:
            okE = False
            print("  NO CONVERGENCE n=%d" % n, flush=True)
            break
    V[n] = v
    print("  z-order %d solved in %d iterations (%.0fs)" % (n, it, time.time()-t0), flush=True)
print("[E] fixed points converged:", okE, flush=True)

# ---------- fermionic sum (Corollary 2 of prove-seed1-layer4.tex) ----------
qb_cache = {}
def qb(a, b):
    if b < 0 or b > a: return Rq(0)
    key = (a, b)
    if key not in qb_cache:
        qb_cache[key] = Rq(q_binomial(a, b, q))
    return qb_cache[key]

def F_ferm(n):
    tot = Rq(0)
    for n2 in range(n + 1):
        for n3 in range(n2 + 1):
            for m3 in range(2 * n3 + 1):
                A = qb(n, n2) * qb(n2, n3) * qb(2 * n3, m3)
                for m2 in range(n2 - n3 + m3 + 1):
                    B = A * qb(n2 - n3 + m3, m2)
                    for m1 in range(n - n2 + m2 + 1):
                        e = (n**2 - n*m1 + m1**2 + n2**2 - n2*m2 + m2**2
                             + n3**2 - n3*m3 + m3**2)
                        tot += q**e * B * qb(n - n2 + m2, m1)
    return tot

Pn = {0: Rq(1)}
for i in range(1, NMAX + 1):
    Pn[i] = Pn[i - 1] * (1 - q**i)

print("== [C'] engine Q_n vs fermionic F_n ==", flush=True)
okC = True
for n in range(NMAX + 1):
    Qe = trunc(Pn[n] * V[n][target])
    Fn = F_ferm(n)
    assert Fn.degree() < PREC, "PREC too small for n=%d" % n
    match  = (trunc(Fn) == Qe)
    nonneg = all(cf >= 0 for cf in Fn.list())
    val1   = (Fn(1) == 21**n)
    okC = okC and match and nonneg and val1
    print("  n=%2d: engine==ferm %s  nonneg %s  F_n(1)==21^n %s  deg=%d (%.0fs)"
          % (n, match, nonneg, val1, Fn.degree(), time.time()-t0), flush=True)
print("[C'] overall:", okC, flush=True)

# ---------- S13 / T low-order checks ----------
qinf = Rq(1)
for i in range(1, CHK + 1):
    qinf = (qinf * (1 - q**i)).truncate(CHK + 1)

pinv_cache = {}
def Pinv(m):   # 1/(q;q)_m mod q^CHK
    if m < 0: return Rq(0)
    if m not in pinv_cache:
        pw = PowerSeriesRing(ZZ, 'qq', default_prec=CHK)
        qq = pw.gen()
        p = pw(1)
        for i in range(1, m + 1):
            p *= (1 - qq**i)
        pinv_cache[m] = Rq((p**(-1)).polynomial())
    return pinv_cache[m]

def S13_zorder(n, rho, sig, shiftden):
    """[z^n] of the S13-shaped sum; shiftden=1 -> (q)_{r3+s3+1} (Uncu eq:Sp1),
       shiftden=0 -> (q)_{r3+s3} (the T-sum). NO 2r3s3 cross term."""
    r1 = n
    SM = n + 14   # block1 alone: s1^2 - n s1 + n^2 >= CHK for s1 >= n+12
    tot = Rq(0)
    for r2 in range(r1 + 1):
        for r3 in range(r2 + 1):
            for s1 in range(SM):
                for s2 in range(s1 + 1):
                    for s3 in range(s2 + 1):
                        e = (r1**2 - r1*s1 + s1**2 + rho[0]*r1 + sig[0]*s1
                           + r2**2 - r2*s2 + s2**2 + rho[1]*r2 + sig[1]*s2
                           + r3**2 - r3*s3 + s3**2 + rho[2]*r3 + sig[2]*s3)
                        if e > CHK: continue
                        tot += (q**e * Pinv(r1-r2) * Pinv(r2-r3) * Pinv(r3)
                                * Pinv(s1-s2) * Pinv(s2-s3) * Pinv(s3)
                                * Pinv(r3 + s3 + shiftden)).truncate(CHK + 1)
    return tot.truncate(CHK)

e3 = (0,0,0); e2 = (0,0,1)
print("== [S'],[A'],[D'] low-order checks (mod q^%d) ==" % CHK, flush=True)
okS = okA = okD = True
for n in range(4):
    Sa = S13_zorder(n, e3, e3, 1)
    Sb = S13_zorder(n, e2, e2, 1)
    Tn = S13_zorder(n, e3, e3, 0)
    D1 = (Sa - q * Sb).truncate(CHK)
    s_ok = ((qinf * D1).truncate(CHK) == V[n][target].truncate(CHK))
    a_ok = (Tn.truncate(CHK) == D1)
    d_ok = ((Pn[n] * qinf * Tn).truncate(CHK) == F_ferm(n).truncate(CHK))
    okS &= s_ok; okA &= a_ok; okD &= d_ok
    print("  n=%d: [S'] (q)inf*(S-qS)==[z^n]G %s   [A'] T==split %s   [D'] limit %s (%.0fs)"
          % (n, s_ok, a_ok, d_ok, time.time()-t0), flush=True)

# ---------- [FF'] Warnaar Prop_finiteform a=+1, k=3 transcription guard ----------
print("== [FF'] Prop_finiteform a=+1 k=3, n0,m0 <= 2 (mod q^%d) ==" % CHK, flush=True)
Rz = PolynomialRing(Rq, 'z'); z = Rz.gen()
def ff_lhs(n0, m0):
    tot = Rz(0)
    for n1 in range(n0+1):
     for n2 in range(n1+1):
      for n3 in range(n2+1):
       for m1 in range(m0+1):
        for m2 in range(m1+1):
         for m3 in range(m2+1):
            e = (n1**2-n1*m1+m1**2 + n2**2-n2*m2+m2**2 + n3**2-n3*m3+m3**2)
            co = (q**e * Pinv(n3+m3) * qb(n0,n1)*qb(n1,n2)*qb(n2,n3)
                  * qb(m0,m1)*qb(m1,m2)*qb(m2,m3)).truncate(CHK)
            tot += co * z**n1
    return tot
def ff_rhs(n0, m0):
    tot = Rz(0)
    for n1 in range(n0+1):
     for n2 in range(n1+1):
      for n3 in range(n2+1):
       for m3 in range(2*n3+1):
        for m2 in range(n2-n3+m3+1):
         for m1 in range(n1-n2+m2+1):
            if m0 - n1 + m1 < 0: continue
            e = (n1**2-n1*m1+m1**2 + n2**2-n2*m2+m2**2 + n3**2-n3*m3+m3**2)
            co = (q**e * Pinv(m0-n1+m1) * qb(n0,n1)*qb(2*n3,m3)
                  * qb(n1,n2)*qb(n1-n2+m2,m1)*qb(n2,n3)*qb(n2-n3+m3,m2)).truncate(CHK)
            tot += co * z**n1
    return tot
okFF = True
for n0 in range(3):
    for m0 in range(3):
        L = ff_lhs(n0, m0); Rr = ff_rhs(n0, m0)
        good = all(cc.truncate(CHK) == 0 for cc in (L - Rr).coefficients())
        okFF = okFF and good
        print("  n0=%d m0=%d: %s" % (n0, m0, good), flush=True)

print("VERIFIER OVERALL: E=%s C'=%s S'=%s A'=%s D'=%s FF'=%s   total %.0fs"
      % (okE, okC, okS, okA, okD, okFF, time.time()-t0), flush=True)
