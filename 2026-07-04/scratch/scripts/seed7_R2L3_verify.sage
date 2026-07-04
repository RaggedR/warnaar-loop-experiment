# Seed 7, Layer 3, Round 2: verify the foundation theorems (Q-transform, inversion,
# tower Q-expansions, MASTER<=>conjecture kernels) EXACTLY in ZZ[q], plus a
# brute-force cylindric-partition check of the pipeline for m<=3.
import itertools, sys

R.<q> = PolynomialRing(ZZ)
PREC = 500
S.<t> = PowerSeriesRing(ZZ, default_prec=PREC)

def qpoch(a_exp, n):  # (q^a_exp; q)_n as polynomial in q
    p = R(1)
    for i in range(n):
        p *= (1 - q^(a_exp + i))
    return p

def qq(n):  # (q;q)_n
    return qpoch(1, n)

def qbin(n, m):
    if m < 0 or m > n: return R(0)
    num = qq(n); den = qq(m) * qq(n - m)
    quo, rem = num.quo_rem(den)
    assert rem == 0
    return quo

def nonneg(p):
    return all(cc >= 0 for cc in R(p).coefficients())

# ---------------- Lemma E ----------------
print("== Lemma E (truncated Euler telescoping), K <= 12 ==")
ok = True
for K in range(13):
    lhs = sum((-1)^k * q^binomial(k, 2) * prod((1 - q^(i+1)) for i in range(K)) / qq(k)
              for k in range(K + 1))  # multiplied by (q;q)_K to stay polynomial
    # lhs computed as sum (-1)^k q^C(k,2) (q;q)_K/(q;q)_k
    lhs2 = sum((-1)^k * q^binomial(k, 2) * qq(K).quo_rem(qq(k))[0] for k in range(K+1))
    rhs = (-1)^K * q^binomial(K + 1, 2)
    if lhs2 != rhs: ok = False; print("  FAIL K=", K)
print("  PASS" if ok else "  FAIL")

# ---------------- Orthogonality ----------------
print("== Gauss orthogonality sum_m (-1)^(n-m) q^C(n-m,2) [n,m][m,k] = delta, n <= 8 ==")
ok = True
for n in range(9):
    for k in range(n + 1):
        ssum = sum((-1)^(n - m) * q^binomial(n - m, 2) * qbin(n, m) * qbin(m, k)
                   for m in range(k, n + 1))
        if ssum != (1 if n == k else 0): ok = False; print("  FAIL", n, k)
print("  PASS" if ok else "  FAIL")

# ---------------- H-recursion infrastructure ----------------
def profiles(d):
    return [(a, b, d - a - b) for a in range(d + 1) for b in range(d - a + 1)]

def emd(c, cp):
    a = cp[1] - c[1]; b = c[0] - cp[0]
    return 3 * max(0, a, b) - a - b

def H_table(d, mmax):
    ps = profiles(d)
    H = {c: {0: R(1)} for c in ps}
    for m in range(1, mmax + 1):
        div = 1 + q^m + q^(2*m)
        for c in ps:
            rhs = sum(q^(m * emd(cp, c)) * H[cp][m - 1] for cp in ps)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0, ("division failed", c, m)
            H[c][m] = quo
    return H

# ---------------- Brute force cylindric partitions ----------------
def partitions_bounded(maxpart, maxsize):
    out = []
    def rec(prefix, largest, rem):
        out.append(tuple(prefix))
        for p in range(min(largest, rem), 0, -1):
            prefix.append(p); rec(prefix, p, rem - p); prefix.pop()
    rec([], maxpart, maxsize)
    return out

def interlace_ok(lams, c):
    # pairs: (0->1, shift c[1]), (1->2, shift c[2]), (2->0, shift c[0])
    for (i, j, s) in [(0, 1, c[1]), (1, 2, c[2]), (2, 0, c[0])]:
        A, B = lams[i], lams[j]
        for jj in range(len(B) - s):
            a = A[jj] if jj < len(A) else 0
            if a < B[jj + s]: return False
    return True

def brute_F(c, m, N):
    parts = partitions_bounded(m, N)
    coeffs = [0] * (N + 1)
    bysize = {}
    for lam in parts: bysize.setdefault(sum(lam), []).append(lam)
    sizes = sorted(bysize)
    for s1 in sizes:
        for s2 in sizes:
            if s1 + s2 > N: break
            for s3 in sizes:
                tot = s1 + s2 + s3
                if tot > N: break
                for l1 in bysize[s1]:
                    for l2 in bysize[s2]:
                        for l3 in bysize[s3]:
                            if interlace_ok((l1, l2, l3), c):
                                coeffs[tot] += 1
    return coeffs

print("== Brute force F_{c,m} vs H-recursion (m<=3, up to q^10) ==")
NBF = 10
for d, reps in [(4, [(2,1,1), (4,0,0), (0,2,2), (0,3,1)]), (5, [(3,1,1), (0,2,3)]), (2, [(1,1,0), (2,0,0)])]:
    H = H_table(d, 3)
    for c in reps:
        for m in range(4):
            Fser = S(R(H[c][m])) / S(qq(m))
            hr = Fser.padded_list(NBF + 1)
            bf = brute_F(c, m, NBF)
            status = "PASS" if hr == bf else "FAIL"
            if status == "FAIL":
                print("  d=%d c=%s m=%d %s\n    Hrec=%s\n    brute=%s" % (d, str(c), m, status, hr, bf))
            else:
                print("  d=%d c=%s m=%d PASS" % (d, str(c), m))

# ---------------- Main theorem checks ----------------
def run_checks(d, nmax):
    print("== d=%d: Theorem Q, Cor I, Thm D, Delta, D1-link, M(a), exactness (n,m <= %d) ==" % (d, nmax))
    ps = profiles(d)
    H = H_table(d, nmax)
    allpass = True
    for c in ps:
        Hc = H[c]
        # g_m as power series, F_m = H_m/(q;q)_m
        F = [S(R(Hc[m])) / S(qq(m)) for m in range(nmax + 1)]
        g = [F[0]] + [F[m] - F[m - 1] for m in range(1, nmax + 1)]
        # Q_n two ways
        Qtrans = {}
        for n in range(nmax + 1):
            # (1) Euler convolution (definition route)
            conv = sum((-1)^(n - m) * S(R(q^binomial(n - m + 1, 2))) / S(qq(n - m)) * g[m]
                       for m in range(n + 1))
            Qdef = S(qq(n)) * conv
            # (2) transform (Theorem Q), exact polynomial
            Qt = sum((-1)^(n - m) * q^binomial(n - m, 2) * qbin(n, m) * Hc[m] for m in range(n + 1))
            Qtrans[n] = Qt
            if Qdef.padded_list(PREC - 50) != S(R(Qt)).padded_list(PREC - 50):
                allpass = False; print("  THM Q FAIL", c, n)
        # Corollary I: H_m = sum [m,n] Q_n  (exact)
        for m in range(nmax + 1):
            if Hc[m] != sum(qbin(m, n) * Qtrans[n] for n in range(m + 1)):
                allpass = False; print("  COR I FAIL", c, m)
        # h_m, D-tower from definitions
        h = {m: Hc[m] - (1 - q^m) * Hc[m - 1] if m >= 1 else R(0) for m in range(nmax + 1)}
        h[0] = Hc[0] - 0  # h_0 = (q;q)_0 g_0 = 1
        h[0] = R(1)
        D = {0: dict(h)}
        for k in range(1, nmax + 1):
            D[k] = {}
            for m in range(k, nmax + 1):
                D[k][m] = D[k - 1][m] - q^k * D[k - 1][m - 1]
        # Theorem D: D_k^m = sum_j q^{(k+1)(m-j)} [m-k, j-k] Q_j
        for k in range(0, nmax + 1):
            for m in range(k, nmax + 1):
                rhs = sum(q^((k + 1) * (m - j)) * qbin(m - k, j - k) * Qtrans[j]
                          for j in range(k, m + 1))
                if D[k][m] != rhs:
                    allpass = False; print("  THM D FAIL", c, k, m)
        # Delta formula
        for m in range(1, nmax + 1):
            rhs = sum(q^(m - j) * qbin(m - 1, j - 1) * Qtrans[j] for j in range(1, m + 1))
            if Hc[m] - Hc[m - 1] != rhs:
                allpass = False; print("  DELTA FAIL", c, m)
        # D1/Delta link: D_1^m = Delta_m - q(1-q^{m-1}) Delta_{m-1}
        for m in range(2, nmax + 1):
            Dl = Hc[m] - Hc[m-1]; Dlp = Hc[m-1] - Hc[m-2]
            if D[1][m] != Dl - q * (1 - q^(m - 1)) * Dlp:
                allpass = False; print("  D1-LINK FAIL", c, m)
        # M(a) sample cells: (q;q)_j f_k^{(m)} = D_{k+1}^m / (q^{j+1};q)_{m-k-1-j} nonneg,
        # given Q_i >= 0 (true in tested range). Check identity as series + nonneg.
        for k in range(-1, 3):
            for m in range(k + 2, nmax + 1):
                for j in range(0, m - k):  # j <= m-k-1
                    lhs = S(R(D[k + 1][m])) / S(qpoch(j + 1, m - k - 1 - j))
                    L = lhs.padded_list(80)
                    if any(x < 0 for x in L):
                        allpass = False; print("  M(a) NONNEG FAIL", c, k, m, j)
        # exactness: (1-q^{m-k}) D_{k+1}^m top coefficient negative when D nonzero
        for k in range(-1, 3):
            for m in range(k + 2, nmax + 1):
                Dk = D[k + 1][m]
                if Dk != 0:
                    p = (1 - q^(m - k)) * Dk
                    if p.leading_coefficient() >= 0:
                        allpass = False; print("  EXACTNESS FAIL", c, k, m)
    print("  ALL PASS" if allpass else "  SOME FAILED")

run_checks(4, 6)
run_checks(5, 5)
run_checks(7, 4)

# d=2 sanity: Q_n = q^{n^2} at (1,1,0), q^{n(n+1)} at (2,0,0)
print("== d=2 closed forms ==")
H = H_table(2, 6)
for c, expo in [((1,1,0), lambda n: n^2), ((2,0,0), lambda n: n*(n+1))]:
    ok = True
    for n in range(7):
        Qt = sum((-1)^(n - m) * q^binomial(n - m, 2) * qbin(n, m) * H[c][m] for m in range(n + 1))
        if Qt != q^expo(n): ok = False; print("  FAIL", c, n)
    print("  %s PASS" % (str(c),) if ok else "  FAIL")
print("DONE")
