# Seed 8 L4 ADVERSARY — independent transcription of Warnaar Eq_mineen/Eq_mineen2
# (source.tex lines 2833-2875, read at source by me) at k=3, a=-1, limit n0,m0->oo,
# Q-level (n1 = n, (q)_n cancelled):
#   ferm_{s,t}(n) = sum_{n>=n2>=0, n3, m1, m2} q^E * B  with m3 := 2n3,
#   t<=3: n3<=n2; E = n3^2 + sum_{i>=s}(n,n2,n3)_i + sum_{2>=i>=t}(m1,m2)_i
#         + n^2-n*m1+m1^2 + n2^2-n2*m2+m2^2;
#         B = [n,n2][n-n2+m2+d(t,2); m1][n2,n3][n2+n3+d(t,3); m2]
#   t=4 (s<=3): n3<=n2+1; E = n3^2-n3 + sum_{i>=s}(n,n2,n3)_i + quadratics;
#         B = [n,n2][n-n2+m2; m1][n2+1,n3][n2+n3; m2]
# Fast: inner m1-sum cached by (N', t-flag).
# Checks:
#   [CMP] d=8: ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n) == engine Q_n, n<=12, 7 orbits.
#   [POS] differences nonneg for n up to NMAX (counterexample hunt; exact Z[q]).
# Usage: sage seed8_L4_fermdiff.sage <NMAX> <NCMP>
import sys, time
from sage.all import *
Rq = PolynomialRing(ZZ, 'q'); q = Rq.gen()
NMAX = int(sys.argv[1]); NCMP = int(sys.argv[2])

QB = {}
def qbin(a, b):
    if b < 0 or b > a: return Rq(0)
    key = (a, b)
    if key not in QB: QB[key] = q_binomial(a, b, q)
    return QB[key]

def ferm(n, s, t):
    """My transcription. Exact Z[q]."""
    tot = Rq(0)
    U = {}  # inner m1-sum cache: key (Np, lin1) -> sum_{m1<=Np} q^{m1^2-n*m1+lin1*m1} [Np,m1]
    def inner(Np, lin1):
        key = (Np, lin1)
        if key not in U:
            U[key] = sum(q**(n*n + m1*m1 - n*m1 + lin1*m1) * qbin(Np, m1) for m1 in range(Np+1))
        return U[key]
    lin1 = 1 if t == 1 else 0   # m1 linear term iff t <= 1
    lin2 = 1 if t <= 2 else 0   # m2 linear term iff t <= 2
    if t <= 3:
        d2 = 1 if t == 2 else 0   # delta_{1,t-1}: top shift on the m1-binomial
        d3 = 1 if t == 3 else 0   # delta_{2,t-1}: top shift on the m2-binomial
        for n2 in range(n+1):
            for n3 in range(n2+1):
                linN = sum(v for i, v in enumerate((n, n2, n3)) if i >= s-1)
                base = n3*n3 + linN + n2*n2
                b0 = qbin(n, n2) * qbin(n2, n3)
                for m2 in range(n2 + n3 + d3 + 1):
                    e = base - n2*m2 + m2*m2 + lin2*m2
                    tot += b0 * qbin(n2 + n3 + d3, m2) * q**e * inner(n - n2 + m2 + d2, lin1)
    else:
        assert 1 <= s <= 3
        for n2 in range(n+1):
            for n3 in range(n2+2):
                linN = sum(v for i, v in enumerate((n, n2, n3)) if i >= s-1)
                base = n3*n3 - n3 + linN + n2*n2
                b0 = qbin(n, n2) * qbin(n2 + 1, n3)
                for m2 in range(n2 + n3 + 1):
                    e = base - n2*m2 + m2*m2
                    tot += b0 * qbin(n2 + n3, m2) * q**e * inner(n - n2 + m2, 0)
    return tot

ORBITS = [(6,1,1),(5,2,1),(5,1,2),(4,3,1),(4,1,3),(4,2,2),(3,3,2)]

def neg_report(p):
    l = p.list()
    for i, v in enumerate(l):
        if v < 0: return (i, v)
    return None

def min_in_hull(p):
    l = p.list()
    if not l: return (0, -1)
    v = 0
    while v < len(l) and l[v] == 0: v += 1
    hull = l[v:]
    mn = min(hull)
    return (mn, v + hull.index(mn))

t0 = time.time()
# [CMP] engine comparison n <= NCMP
load("2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
print("[CMP] building d=8 engine to m=%d" % NCMP, flush=True)
H, viol = build_H(8, NCMP, verbose=False)
assert not viol
bad = 0
for c in ORBITS:
    c1, c2, c3 = c
    for n in range(NCMP+1):
        diff = ferm(n, c2+1, c3+1) - q * ferm(n, c2, c3)
        if diff != gauss_a(H, c, n):
            bad += 1
            print("*** CMP MISMATCH c=%s n=%d" % (c, n), flush=True)
print("[CMP] done: %d mismatches over 7 orbits, n<=%d (%.1fs)" % (bad, NCMP, time.time()-t0), flush=True)

# [POS] high-n difference positivity (counterexample hunt)
for n in range(NCMP+1, NMAX+1):
    for c in ORBITS:
        c1, c2, c3 = c
        diff = ferm(n, c2+1, c3+1) - q * ferm(n, c2, c3)
        r = neg_report(diff)
        if r is not None:
            print("*** NEGATIVE COEFF (COUNTEREXAMPLE CANDIDATE) c=%s n=%d deg=%d coeff=%d"
                  % (c, n, r[0], r[1]), flush=True)
        else:
            mn = min_in_hull(diff)
            print("  [POS] c=%s n=%2d OK deg=%d min-in-hull %d @ %d (%.1fs)"
                  % (c, n, diff.degree(), mn[0], mn[1], time.time()-t0), flush=True)
print("[POS] DONE to n=%d (%.1fs)" % (NMAX, time.time()-t0), flush=True)
