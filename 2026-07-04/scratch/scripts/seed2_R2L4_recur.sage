# Attempt 3: positive-recurrence search for the (4,3,1) slice function
#   L(n,n2,n3) = sum_{m1,m2} q^{m1^2-n m1+m2^2-n2 m2+m2}[n2+n3;m2]
#                ([n-n2+m2+1;m1] - q^{1+n3+m1}[n-n2+m2;m1])
# Candidates: L(n,n2,n3) - q^a * L(n',n2',n3') >= 0 for parameter decrements and
# small shifts a in {0..6}; report which (move, a) give uniformly nonneg residues.
from sage.all import *
import itertools, time
Lq = LaurentPolynomialRing(ZZ, 'q'); ql = Lq.gen()
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()
def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)
memo = {}
def Ls(n, n2, n3):
    if n2 > n or n3 > n2 or n < 0 or n2 < 0 or n3 < 0: return None
    key = (n,n2,n3)
    if key in memo: return memo[key]
    M = n2 + n3; tot = Lq(0)
    for m2 in range(M+1):
        N = n - n2 + m2
        for m1 in range(N+2):
            inner = qbin(N+1, m1) - qp**(1+n3+m1)*qbin(N, m1)
            if inner == 0: continue
            tot += ql**(m1**2 - n*m1 + m2**2 - n2*m2 + m2) * Lq(qbin(M, m2)) * Lq(inner)
    memo[key] = tot
    return tot
def nn(p): return all(c >= 0 for c in p.coefficients())

NTOP = 7
moves = {"n-1": (-1,0,0), "n2-1": (0,-1,0), "n3-1": (0,0,-1),
         "n-1,n2-1": (-1,-1,0), "n2-1,n3-1": (0,-1,-1), "all-1": (-1,-1,-1)}
for mname, (dn, dn2, dn3) in moves.items():
    for a in range(0, 7):
        ok = True; tested = 0
        for n in range(NTOP+1):
          for n2 in range(n+1):
            for n3 in range(n2+1):
                L1 = Ls(n, n2, n3); L0 = Ls(n+dn, n2+dn2, n3+dn3)
                if L0 is None: continue
                tested += 1
                if not nn(L1 - ql**a * L0): ok = False; break
            if not ok: break
          if not ok: break
        if ok and tested > 10:
            print("PASS: L(n,n2,n3) - q^%d L(%s) >= 0  (all n<=%d, %d cases)" % (a, mname, NTOP, tested), flush=True)
print("done")
