# Seed 8 L4 — Mission B1: spot-check Seed 1's d=10 theorem beyond their n<=12.
# FERM3p Q-level formula transcribed BY ME from Warnaar Prop_finiteform a=+1
# (source.tex lines 2672-2687), k=3, limit, n1=n:
#   Q_n = sum_{n>=n2>=n3>=0; m1,m2,m3>=0} q^{n^2+n2^2+n3^2 - n*m1 - n2*m2 - n3*m3
#         + m1^2+m2^2+m3^2} [n,n2][n-n2+m2; m1][n2,n3][n2-n3+m3; m2][2n3; m3]
# vs engine (target-first) at d=10 c=(4,3,3), n = 0..NMAX (extends Seed 1's n<=12).
import sys, time
from sage.all import *
load("2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
NMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 15
QB = {}
def qbin(a, b):
    if b < 0 or b > a: return Rq(0)
    if (a, b) not in QB: QB[(a, b)] = q_binomial(a, b, q)
    return QB[(a, b)]

def ferm3p(n):
    tot = Rq(0)
    U = {}
    def inner(Np):  # sum over m1: q^{n^2 - n m1 + m1^2} [Np, m1]
        if Np not in U:
            U[Np] = sum(q**(n*n - n*m1 + m1*m1) * qbin(Np, m1) for m1 in range(Np+1))
        return U[Np]
    for n2 in range(n+1):
        for n3 in range(n2+1):
            b0 = qbin(n, n2) * qbin(n2, n3)
            for m3 in range(2*n3 + 1):
                b1 = b0 * qbin(2*n3, m3)
                e3 = n3*n3 - n3*m3 + m3*m3
                for m2 in range(n2 - n3 + m3 + 1):
                    e = e3 + n2*n2 - n2*m2 + m2*m2
                    tot += b1 * qbin(n2 - n3 + m3, m2) * q**e * inner(n - n2 + m2)
    return tot

t0 = time.time()
print("=== Seed8 L4 B1: d=10 (4,3,3) ferm vs engine, n<=%d ===" % NMAX, flush=True)
H, viol = build_H(10, NMAX, verbose=True)
assert not viol
c = (4, 3, 3)
bad = 0
for n in range(NMAX+1):
    f = ferm3p(n)
    a = gauss_a(H, c, n)
    ok = (f == a)
    nn = neg_report(f)
    if not ok or nn is not None:
        bad += 1
        print("*** n=%d match=%s neg=%s" % (n, ok, nn), flush=True)
    else:
        print("  n=%2d MATCH deg=%d, all coeffs >= 0, Q_n(1)=%s (21^n=%s) (%.1fs)"
              % (n, f.degree(), f(1) == 21**n, True, time.time()-t0), flush=True)
print("=== B1 VERDICT: %d failures, n<=%d ===" % (bad, NMAX), flush=True)
