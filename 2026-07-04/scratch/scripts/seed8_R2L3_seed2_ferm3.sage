"""Seed 8 R2L3 ADVERSARY - independent stress of Seed 2's Theorem:
G_{(3,3,2)} = FERM_3  (Warnaar Conjecture 2, k=3, d=8).

Seed 2 verified numerically only n<=4 at PREC 300. Here: implement the
Corollary's manifestly positive quadruple sum for Q_{n,(3,3,2)} DIRECTLY
(exact Z[q], full polynomial) and compare to Q_n = D_n^n from the
raw-definition-validated H-recursion engine at d=8. This exercises the whole
4-step chain (finite-form limit, Pochhammer split, KR relation R3, Uncu m=11)
at once, independently of Seed 2's S_11 code.

Corollary (prove-seed2-layer3.tex):
Q_n = sum_{n>=n2>=n3>=0, m1,m2>=0}
      q^{n^2+n2^2+n3^2 - n*m1 - n2*m2 + m1^2 + m2^2}
      [n,n2] [n-n2+m2, m1] [n2,n3] [n2+n3, m2]

Convention: orbit of (3,3,2) contains its own reversal (2,3,3) up to C3,
so labeling-reversal ambiguity cannot bite; we also verify Q_n identical at
all three rotations.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")

NMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 10

def qbin(a, b):
    if b < 0 or b > a or a < 0: return Rq(0)
    return q_binomial(a, b, q)

def Q_ferm(n):
    res = Rq(0)
    for n2 in range(n+1):
        b1 = qbin(n, n2)
        for n3 in range(n2+1):
            b3 = qbin(n2, n3)
            for m2 in range(n2+n3+1):
                b4 = qbin(n2+n3, m2)
                for m1 in range(n-n2+m2+1):
                    e = n*n + n2*n2 + n3*n3 - n*m1 - n2*m2 + m1*m1 + m2*m2
                    res += q**e * b1 * qbin(n-n2+m2, m1) * b3 * b4
    return res

t0 = time.time()
H, viol = build_H(8, NMAX, verbose=False)
print("engine d=8 built to m=%d (%.1fs), violations=%d" % (NMAX, time.time()-t0, len(viol)), flush=True)

rots = [(3,3,2),(3,2,3),(2,3,3)]
D = {c: dtower(H, c, NMAX) for c in rots}

allok = True
for n in range(NMAX+1):
    t1 = time.time()
    Qf = Q_ferm(n)
    Qe = D[(3,3,2)][(n,n)]
    rot_ok = all(D[c][(n,n)] == Qe for c in rots)
    ok = (Qf == Qe)
    allok &= ok and rot_ok
    print("n=%2d: FERM==engine %s | rotations agree %s | deg=%d Q(1)=14^n? %s (%.1fs)"
          % (n, ok, rot_ok, Qe.degree(), Qe(1) == 14**n, time.time()-t1), flush=True)
    if not ok:
        dif = Qf - Qe
        print("   FIRST DIFF at deg %d: ferm-engine head %s" % (dif.valuation(), dif.list()[:10]))
print("SEED2 FERM_3 STRESS n<=%d: %s" % (NMAX, "ALL EXACT MATCH" if allok else "***MISMATCH***"))
