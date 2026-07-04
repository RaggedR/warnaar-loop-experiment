"""Seed 8 R2L3 ADVERSARY - independent stress of Seed 6's d=4 closed forms
(proofs/prove-seed6-layer3.tex) at n far beyond their n<=13 checks.

For each n <= NMAX (exact Z[q]):
  1. Five CW formulas (T(n,j)=q^{n^2+j^2-nj}):
     Q(2,1,1)=sum T [2n,j];  Q(4,0,0)=sum T q^{n+j} [2n,j];  Q(3,1,0)=sum T q^j [2n,j]
     X = sum T q^n [2n,j];  X' = sum T q^{2j} [2n-2,j];  Y' = sum T q^j(1+q^{n+j}) [2n-2,j]
     Q(3,0,1)=X+(1-q^n)X';  Q(2,2,0)=X+(1-q^n)Y'
  2. Absorption A: X - q^n X' == sum_j T q^n ((q^{j-1}+q^j)[2n-2,j-1] + [2n-2,j-2]) >= 0
  3. Absorption B: X - q^n Y' == sum_{j=0}^{2n-1} q^{n^2+j^2-nj+2j+1} [2n-1,j] >= 0
  4. All five == engine Q_n = D_n^n at d=4 (Seed 6 orbit dictionary, EMD profiles),
     plus Q_n >= 0 and Q_n(1)=4^n.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")

NMAX = int(sys.argv[1]) if len(sys.argv) > 1 else 28

def qbin(a, b):
    if b < 0 or b > a or a < 0: return Rq(0)
    return q_binomial(a, b, q)

def T(n, j): return q**(n*n + j*j - n*j)

# CORRECTED dictionary (raw conjecture.tex convention = target-first engine):
# identity map — each CW label lies in its own engine orbit. Seed 6's tex dictionary
# is stated in the OLD reversed (source-first) convention.
DICT = {
    (2,1,1): (2,1,1),
    (4,0,0): (4,0,0),
    (3,1,0): (3,1,0),
    (3,0,1): (3,0,1),
    (2,2,0): (2,2,0),
}

t0 = time.time()
H, viol = build_H(4, NMAX, verbose=False)
print("engine d=4 built to m=%d (%.1fs), violations=%d" % (NMAX, time.time()-t0, len(viol)), flush=True)
D = {c: dtower(H, c, NMAX) for c in DICT.values()}

allok = True
for n in range(NMAX+1):
    t1 = time.time()
    Xn  = sum(T(n,j) * q**n * qbin(2*n, j) for j in range(2*n+1))
    Xp  = sum(T(n,j) * q**(2*j) * qbin(2*n-2, j) for j in range(max(1,2*n-1)))
    Yp  = sum(T(n,j) * q**j * (1 + q**(n+j)) * qbin(2*n-2, j) for j in range(max(1,2*n-1)))
    F = {
        (2,1,1): sum(T(n,j) * qbin(2*n, j) for j in range(2*n+1)),
        (4,0,0): sum(T(n,j) * q**(n+j) * qbin(2*n, j) for j in range(2*n+1)),
        (3,1,0): sum(T(n,j) * q**j * qbin(2*n, j) for j in range(2*n+1)),
        (3,0,1): Xn + (1 - q**n) * Xp,
        (2,2,0): Xn + (1 - q**n) * Yp,
    }
    absA_rhs = sum(T(n,j) * q**n * ((q**(j-1) + q**j) * qbin(2*n-2, j-1) + qbin(2*n-2, j-2))
                   for j in range(1, 2*n+1)) if n >= 1 else Xn - Xp
    absB_rhs = sum(q**(n*n + j*j - n*j + 2*j + 1) * qbin(2*n-1, j) for j in range(2*n)) if n >= 1 else Xn - Yp
    okA_id = (Xn - q**n * Xp == absA_rhs); okA_pos = neg_report(absA_rhs) is None
    okB_id = (Xn - q**n * Yp == absB_rhs); okB_pos = neg_report(absB_rhs) is None
    line = "n=%2d absA(id,pos)=(%s,%s) absB(id,pos)=(%s,%s)" % (n, okA_id, okA_pos, okB_id, okB_pos)
    allok &= okA_id and okA_pos and okB_id and okB_pos
    for cw, prof in DICT.items():
        Qe = D[prof][(n, n)]
        okm = (F[cw] == Qe)
        okp = neg_report(F[cw]) is None
        oks = F[cw](1) == 4**n
        allok &= okm and okp and oks
        line += " | %s %s%s%s" % (cw, "M" if okm else "!M", "P" if okp else "!P", "S" if oks else "!S")
        if not okm:
            dif = F[cw] - Qe
            print("*** MISMATCH cw=%s prof=%s n=%d val=%d head=%s" % (cw, prof, n, dif.valuation(), dif.list()[:8]))
    print(line + "  (%.1fs)" % (time.time()-t1), flush=True)
print("SEED6 WALL/FORMULA STRESS n<=%d: %s" % (NMAX, "ALL EXACT MATCH+POSITIVE" if allok else "***FAILURE***"))
