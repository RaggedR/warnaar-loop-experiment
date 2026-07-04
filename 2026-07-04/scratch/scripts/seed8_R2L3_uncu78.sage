"""Seed 8 R2L3 attack (d): stress Uncu S_11 == CW at d=8 for n=7,8 (Layer 2 stopped at n<=6).
Uncu side: seed5's implementation (PROVED formulas, truncated series, PREC below).
CW side: EXACT Q_n = D_n^n from the validated H-recursion engine.
Comparison mod q^CHECKTO — a mismatch would be escalated to exact computation.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
import time, sys

PREC = 420
R = PowerSeriesRing(ZZ, 'q', default_prec=PREC)
qs = R.gen()

_qp = {0: R(1)}
def qpoch(n):
    if n not in _qp:
        _qp[n] = qpoch(n - 1) * (1 - qs**n)
    return _qp[n]
_qpi = {}
def qpoch_inv(n):
    if n not in _qpi:
        _qpi[n] = qpoch(n)**(-1)
    return _qpi[n]
qinf = R(1)
for i in range(1, PREC):
    qinf *= 1 - qs**i

SMAX = 45
def T(n, rho, sig):
    if n < 0: return R(0)
    res = R(0)
    r1 = n
    for r2 in range(r1 + 1):
        for r3 in range(r2 + 1):
            base_r = (r1*r1 + rho[0]*r1 + r2*r2 + rho[1]*r2 + r3*r3 + rho[2]*r3)
            for s1 in range(SMAX):
                if s1*s1 - r1*s1 + base_r + sig[0]*s1 >= PREC and s1 > r1:
                    break
                for s2 in range(s1 + 1):
                    for s3 in range(s2 + 1):
                        e = (base_r - r1*s1 + s1*s1 + sig[0]*s1
                             - r2*s2 + s2*s2 + sig[1]*s2
                             - r3*s3 + s3*s3 + sig[2]*s3 + 2*r3*s3)
                        if e >= PREC: continue
                        den = (qpoch_inv(r1-r2) * qpoch_inv(r2-r3) * qpoch_inv(r3)
                               * qpoch_inv(s1-s2) * qpoch_inv(s2-s3) * qpoch_inv(s3)
                               * qpoch_inv(r3+s3+1))
                        res += qs**e * den
    return res

FORM = {
 (8,0,0): [('1',(1,1,1),(1,1,1))],
 (7,1,0): [('1',(0,1,1),(1,1,1))],
 (7,0,1): [('1',(1,1,1),(0,1,1)), ('-q(1-z)',(2,1,1),(1,1,1))],
 (6,2,0): [('1',(0,0,1),(1,1,1))],
 (6,1,1): [('1',(0,1,1),(0,1,1)), ('-q',(1,1,1),(1,1,1))],
 (6,0,2): [('1',(1,1,1),(0,0,1)), ('-q(1-z)',(2,1,1),(0,1,1))],
 (5,3,0): [('1',(0,0,0),(1,1,1))],
 (5,2,1): [('1',(0,0,1),(0,1,1)), ('-q',(0,1,1),(1,1,1))],
 (5,1,2): [('1',(0,1,1),(0,0,1)), ('-q',(1,1,1),(0,1,1))],
 (5,0,3): [('1',(1,1,1),(0,0,0)), ('-q(1-z)',(2,1,1),(0,0,1))],
 (4,3,1): [('1',(0,0,0),(0,1,1)), ('-q',(0,0,1),(1,1,1))],
 (4,2,2): [('1',(0,0,1),(0,0,1)), ('-q',(0,1,1),(0,1,1))],
 (4,1,3): [('1',(0,1,1),(0,0,0)), ('-q',(1,1,1),(0,0,1))],
 (3,3,2): [('1',(0,0,0),(0,0,1)), ('-q',(0,0,1),(0,1,1))],
 (4,4,0): [('1',(1,0,0),(0,1,1)), ('-q',(1,0,1),(1,1,1)), ('+qz',(2,1,1),(0,0,0))],
}

def zn_H(c, n):
    res = R(0)
    for (typ, rho, sig) in FORM[c]:
        if typ == '1':      res += T(n, rho, sig)
        elif typ == '-q':   res += -qs * T(n, rho, sig)
        elif typ == '-q(1-z)': res += -qs * (T(n, rho, sig) - T(n - 1, rho, sig))
        elif typ == '+qz':  res += qs * T(n - 1, rho, sig)
    return res

NS = [int(a) for a in sys.argv[1:]] or [7, 8]
t0 = time.time()
Hd8, viol8 = build_H(8, max(NS), verbose=False)
print("engine H at d=8 built (%.1fs), violations=%d" % (time.time()-t0, len(viol8)), flush=True)
CHECKTO = PREC - 30
allok = True
for c in FORM:
    D = dtower(Hd8, c, max(NS))
    line = "c=%s:" % (c,)
    for n in NS:
        t1 = time.time()
        Qu = qpoch(n) * qinf * zn_H(c, n)
        Qe = D[(n, n)]
        ok = all(Qu[i] == Qe[i] for i in range(CHECKTO))
        allok &= ok
        posU = all(Qu[i] >= 0 for i in range(CHECKTO))
        line += "  n=%d match=%s Uncu-pos=%s (%.0fs)" % (n, ok, posU, time.time()-t1)
        if not ok:
            for i in range(CHECKTO):
                if Qu[i] != Qe[i]:
                    print("   FIRST DIFF c=%s n=%d at q^%d: uncu=%s exact=%s" % (c, n, i, Qu[i], Qe[i]))
                    break
    print(line, flush=True)
print("UNCU d=8 n=%s vs EXACT engine (mod q^%d): %s" % (NS, CHECKTO, "ALL MATCH" if allok else "***MISMATCH***"))
