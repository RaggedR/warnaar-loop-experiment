# Seed 1, Round 2, Layer 2: full numerical verification of the d=2 proof.
#
# 1. Brute-force enumerate cylindric partitions of all 6 profiles with d=2,
#    total size <= W, build F_c(y,q) exactly up to q^W.
# 2. Solve the Corteel-Welsh system for all 6 profiles to n_max at PREC,
#    cross-check against the brute force.
# 3. Compute Q_n = (q;q)_n [y^n]((yq;q)_inf F_c) for n=0..n_max;
#    check Q_n = q^{n^2} (orbit a) and q^{n(n+1)} (orbit b).
# 4. Verify the intermediate functional equations (*), (RR), (G-CW).

from itertools import count

PREC = 900          # >= 6*max(n)^2 + 200 = 800 for n_max = 10
NMAX = 10
W = 25              # brute-force size bound

R.<q> = PowerSeriesRing(ZZ, default_prec=PREC)

profiles = [(1,1,0),(0,1,1),(1,0,1),(2,0,0),(0,2,0),(0,0,2)]
orbit_a = [(1,1,0),(0,1,1),(1,0,1)]
orbit_b = [(2,0,0),(0,2,0),(0,0,2)]

# ---------- CW shifted profile ----------
def shifted(c, J):
    k = len(c)
    out = []
    for i in range(1, k+1):          # 1-indexed
        im1 = i-1 if i > 1 else k    # cyclic: c_0 = c_k
        ci = c[i-1]
        if i in J and im1 not in J:
            out.append(ci - 1)
        elif i not in J and im1 in J:
            out.append(ci + 1)
        else:
            out.append(ci)
    return tuple(out)

def subsets_nonempty(I):
    I = list(I)
    for mask in range(1, 2^len(I)):
        yield frozenset(I[j] for j in range(len(I)) if (mask >> j) & 1)

# ---------- Part 1: brute force ----------
# partitions as weakly decreasing tuples; enumerate all with |la| <= W
def all_partitions_upto(W):
    parts = [[] for _ in range(W+1)]
    def rec(rem, maxpart, cur):
        parts[W - rem].append(tuple(cur))
        for p in range(min(rem, maxpart), 0, -1):
            cur.append(p)
            rec(rem - p, p, cur)
            cur.pop()
    # enumerate by total size
    result = []
    def rec2(total, maxpart, cur):
        result.append(tuple(cur))
        for p in range(1, maxpart+1):
            if total + p > W: break
            cur.append(p)
            rec2(total + p, p, cur)
            cur.pop()
    # build partitions with parts weakly decreasing: append parts <= last
    result = []
    def rec3(total, last, cur):
        result.append(tuple(cur))
        for p in range(min(last, W-total), 0, -1):
            cur.append(p)
            rec3(total+p, p, cur)
            cur.pop()
    rec3(0, W, [])
    return result

PARTS = all_partitions_upto(W)
print("partitions with size <= %d: %d" % (W, len(PARTS)))

def interlace_ok(lam, mu, c):
    # lam_j >= mu_{j + c} for all j >= 1  (1-indexed)
    # mu longer than lam+... check all j where mu_{j+c} defined
    for j in range(1, len(mu) - c + 1):
        lam_j = lam[j-1] if j <= len(lam) else 0
        if lam_j < mu[j + c - 1]:
            return False
    return True

def brute_F(c):
    # F_c(y,q) coefficients: dict (n, w) -> count, exact for w <= W
    c1, c2, c3 = c
    # group partitions by size for pruning
    by_size = {}
    for lam in PARTS:
        by_size.setdefault(sum(lam), []).append(lam)
    coeffs = {}
    for s1 in range(W+1):
        for lam1 in by_size.get(s1, []):
            for s2 in range(W - s1 + 1):
                for lam2 in by_size.get(s2, []):
                    # condition: lam1_j >= lam2_{j+c2}
                    if not interlace_ok(lam1, lam2, c2): continue
                    for s3 in range(W - s1 - s2 + 1):
                        for lam3 in by_size.get(s3, []):
                            if not interlace_ok(lam2, lam3, c3): continue
                            if not interlace_ok(lam3, lam1, c1): continue
                            mx = max([lam1[0] if lam1 else 0,
                                      lam2[0] if lam2 else 0,
                                      lam3[0] if lam3 else 0])
                            w = s1 + s2 + s3
                            coeffs[(mx, w)] = coeffs.get((mx, w), 0) + 1
    return coeffs

print("brute-forcing all 6 profiles (W=%d)..." % W)
brute = {c: brute_F(c) for c in profiles}
print("done.")

# cyclic invariance check on brute-force data
for c in [(1,1,0),(2,0,0)]:
    rot1 = (c[2], c[0], c[1])
    rot2 = (c[1], c[2], c[0])
    assert brute[c] == brute[rot1] == brute[rot2], "cyclic invariance FAILS for %s" % (c,)
print("CHECK 1 PASSED: brute-force F_c invariant under cyclic rotation (both orbits)")

# ---------- Part 2: solve CW system ----------
# f[c][n] = [y^n] F_c(y,q) as power series in q.
# CW coefficientwise: f_{c,n} = sum_J (-1)^{|J|-1} q^{|J| n} sum_{m<=n} f_{c(J),m}
# Unknowns at level n appear on RHS (m=n term). 6x6 linear system per n.
# Solve by Gaussian elimination over Z[[q]] (diagonal entries are units).

f = {c: [R(1)] for c in profiles}   # f_{c,0} = 1
S = {c: R(1) for c in profiles}     # running sums sum_{m<n} f_{c,m}

idx = {c: i for i, c in enumerate(profiles)}

for n in range(1, NMAX+1):
    # build M x = rhs where x_i = f_{c_i, n}
    M = [[R(0) for _ in profiles] for _ in profiles]
    rhs = [R(0) for _ in profiles]
    for c in profiles:
        i = idx[c]
        M[i][i] += R(1)
        I_c = [j+1 for j in range(3) if c[j] > 0]
        for J in subsets_nonempty(I_c):
            cJ = shifted(c, tuple(J))
            sgn = (-1)^(len(J)-1)
            coef = sgn * q^(len(J)*n)
            rhs[i] += coef * S[cJ]          # m <= n-1 part
            M[i][idx[cJ]] -= coef           # m = n part moved to LHS
    # Gaussian elimination (pivots are units: M[i][i] = 1 - O(q^n))
    Mm = [row[:] for row in M]; bb = rhs[:]
    nvar = len(profiles)
    for i in range(nvar):
        piv = Mm[i][i]
        assert piv.valuation() == 0 and piv[0] == 1
        inv = piv^(-1)
        Mm[i] = [e*inv for e in Mm[i]]; bb[i] = bb[i]*inv
        for r in range(nvar):
            if r != i and not Mm[r][i].is_zero():
                fac = Mm[r][i]
                Mm[r] = [Mm[r][t] - fac*Mm[i][t] for t in range(nvar)]
                bb[r] = bb[r] - fac*bb[i]
    for c in profiles:
        f[c].append(bb[idx[c]])
    for c in profiles:
        S[c] += f[c][n]
    print("  solved CW level n=%d" % n)

# cross-check CW solution vs brute force (exact for q-degree <= W)
ok = True
for c in profiles:
    for n in range(0, NMAX+1):
        bf = [0]*(W+1)
        for (mx, w), cnt in brute[c].items():
            if mx == n: bf[w] += cnt
        cw = f[c][n]
        for w in range(W+1):
            if cw[w] != bf[w]:
                print("MISMATCH c=%s n=%d w=%d: CW=%s brute=%s" % (c, n, w, cw[w], bf[w]))
                ok = False
assert ok
print("CHECK 2 PASSED: CW solution matches brute force for all 6 profiles, n<=%d, q-deg<=%d" % (NMAX, W))

# ---------- Part 3: Q_n ----------
# [y^m](yq;q)_inf = (-1)^m q^{m(m+1)/2} / (q;q)_m
def poch(k):  # (q;q)_k
    return prod(R(1) - q^i for i in range(1, k+1)) if k > 0 else R(1)

euler = [(-1)^m * q^(m*(m+1)//2) / poch(m) for m in range(NMAX+1)]

def Q(c, n):
    coeff = sum(euler[m] * f[c][n-m] for m in range(n+1))
    return poch(n) * coeff

print("\nQ_n values (checked to precision q^%d):" % (PREC-1))
allok = True
for n in range(NMAX+1):
    qa = Q((1,1,0), n)
    qb = Q((2,0,0), n)
    ta = qa - q^(n^2)
    tb = qb - q^(n*(n+1))
    oka = ta.truncate(PREC-1).is_zero() if hasattr(ta,'truncate') else (ta == 0)
    okb = tb.truncate(PREC-1).is_zero() if hasattr(tb,'truncate') else (tb == 0)
    print("  n=%2d: Q_a - q^{n^2} == 0: %s ; Q_b - q^{n(n+1)} == 0: %s" % (n, oka, okb))
    allok = allok and oka and okb
assert allok
print("CHECK 3 PASSED: Q_n = q^{n^2} (orbit a) and q^{n(n+1)} (orbit b) for n <= %d" % NMAX)

# also check the other orbit members give identical Q
for n in range(NMAX+1):
    for c in orbit_a:
        assert (Q(c,n) - q^(n^2)).truncate(PREC-1).is_zero()
    for c in orbit_b:
        assert (Q(c,n) - q^(n*(n+1))).truncate(PREC-1).is_zero()
print("CHECK 3b PASSED: identical for all members of each orbit")

# ---------- Part 4: functional equations ----------
# work with truncated y-polynomials: represent F as list of q-series f[c][0..NMAX]
# (*): (1-yq) A(y) = A(yq) + yq/(1-yq^2) A(yq^2)
# coefficientwise at y^n:  a_n - q a_{n-1} = q^n a_n + sum_{j>=1, n-j>=0} ... let's
# just verify:  RHS_n = q^n a_n + q * sum_{m} a_m q^{2m} [y^{n-1-m}] 1/(1-yq^2)
#             = q^n a_n + q * sum_{m=0}^{n-1} a_m q^{2m} q^{2(n-1-m)}
A_ = f[(1,1,0)]; B_ = f[(2,0,0)]
for n in range(NMAX+1):
    lhs = A_[n] - (q*A_[n-1] if n >= 1 else 0)
    rhs = q^n * A_[n] + (q * sum(A_[m] * q^(2*m) * q^(2*(n-1-m)) for m in range(n)) if n >= 1 else 0)
    assert (lhs - rhs).truncate(PREC-2).is_zero(), "eq (*) fails at n=%d" % n
print("CHECK 4 PASSED: (1-yq)A(y) = A(yq) + yq/(1-yq^2) A(yq^2) for n <= %d" % NMAX)

# (CW-b): B(y) = A(yq)/(1-yq)  <=>  b_n = sum_{m<=n} a_m q^m q^{n-m} = q^n sum a_m ... wait
# [y^n] A(yq)/(1-yq) = sum_{m=0}^n (a_m q^m) * q^{n-m} = q^n * sum_{m=0}^n a_m
for n in range(NMAX+1):
    rhs = q^n * sum(A_[m] for m in range(n+1))
    assert (B_[n] - rhs).truncate(PREC-2).is_zero()
print("CHECK 5 PASSED: B(y) = A(yq)/(1-yq) for n <= %d" % NMAX)

# (RR): G(y) = G(yq) + yq G(yq^2), with G = (yq;q)_inf * A
G_ = [sum(euler[m] * A_[n-m] for m in range(n+1)) for n in range(NMAX+1)]
GB = [sum(euler[m] * B_[n-m] for m in range(n+1)) for n in range(NMAX+1)]
for n in range(NMAX+1):
    rhs = q^n * G_[n] + (q * q^(2*(n-1)) * G_[n-1] if n >= 1 else 0)
    assert (G_[n] - rhs).truncate(PREC-2).is_zero(), "RR fails at n=%d" % n
print("CHECK 6 PASSED: G(y) = G(yq) + yq G(yq^2) for n <= %d" % NMAX)

# G_B(y) = G_A(yq)
for n in range(NMAX+1):
    assert (GB[n] - q^n * G_[n]).truncate(PREC-2).is_zero()
print("CHECK 7 PASSED: G_B(y) = G_A(yq)")

# explicit solution g_n = q^{n^2}/(q;q)_n
for n in range(NMAX+1):
    assert (G_[n] - q^(n^2)/poch(n)).truncate(PREC-2).is_zero()
print("CHECK 8 PASSED: [y^n] G = q^{n^2}/(q;q)_n")

# (G-CW) general lemma, verified on all 6 profiles:
# G_c(y) = sum_J (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|})
Gs = {c: [sum(euler[m] * f[c][n-m] for m in range(n+1)) for n in range(NMAX+1)] for c in profiles}
def ypoch_coeffs(k):
    # (yq;q)_k = prod_{i=1}^{k}(1 - y q^i) as list of y-coeffs (q-series)
    co = [R(1)]
    for i in range(1, k+1):
        new = [R(0)]*(len(co)+1)
        for a in range(len(co)):
            new[a] += co[a]
            new[a+1] -= co[a]*q^i
        co = new
    return co
for c in profiles:
    I_c = [j+1 for j in range(3) if c[j] > 0]
    for n in range(NMAX+1):
        rhs = R(0)
        for J in subsets_nonempty(I_c):
            cJ = shifted(c, tuple(J)); s = len(J)
            pc = ypoch_coeffs(s-1)
            for a in range(min(len(pc), n+1)):
                rhs += (-1)^(s-1) * pc[a] * Gs[cJ][n-a] * q^(s*(n-a))
        assert (Gs[c][n] - rhs).truncate(PREC-2).is_zero(), "G-CW fails c=%s n=%d" % (c, n)
print("CHECK 9 PASSED: G-CW lemma  G_c(y) = sum_J (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|})  for all 6 profiles, n <= %d" % NMAX)

print("\nALL CHECKS PASSED")
