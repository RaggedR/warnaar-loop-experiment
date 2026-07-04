# Seed 2 L4: slice-positivity scan for the c3=1 trio (6,1,1),(5,2,1),(4,3,1).
# Q_n = sum_{n2,n3,m1,m2} q^{QF + w} [n;n2][n2;n3][M;m2] ([N+1;m1] - q^{1+p+m1}[N;m1])
#   QF = n^2+n2^2+n3^2 - n m1 - n2 m2 + m1^2 + m2^2, N = n-n2+m2, M = n2+n3
#   (6,1,1): p=n,  w=n2+n3+m2 ; (5,2,1): p=n2, w=n3+m2 ; (4,3,1): p=n3, w=m2
# For each grouping key, check whether every partial sum is coefficientwise >= 0.
from sage.all import *
import time
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()
def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)

def summand(orbit, n, n2, n3, m1, m2):
    N = n - n2 + m2; M = n2 + n3
    if orbit == (6,1,1): p, w = n,  n2+n3+m2
    elif orbit == (5,2,1): p, w = n2, n3+m2
    elif orbit == (4,3,1): p, w = n3, m2
    QF = n**2+n2**2+n3**2 - n*m1 - n2*m2 + m1**2 + m2**2
    inner = qbin(N+1, m1) - qp**(1+p+m1)*qbin(N, m1)
    if inner == 0: return Rq(0)
    return qp**(QF+w) * qbin(n,n2)*qbin(n2,n3)*qbin(M,m2) * inner

GROUPINGS = {
 "n2,n3,m2": lambda n2,n3,m1,m2: (n2,n3,m2),
 "n2,n3":    lambda n2,n3,m1,m2: (n2,n3),
 "n2,m2":    lambda n2,n3,m1,m2: (n2,m2),
 "n3,m2":    lambda n2,n3,m1,m2: (n3,m2),
 "n2":       lambda n2,n3,m1,m2: (n2,),
 "n3":       lambda n2,n3,m1,m2: (n3,),
 "m2":       lambda n2,n3,m1,m2: (m2,),
 "m1":       lambda n2,n3,m1,m2: (m1,),
 "m1,m2":    lambda n2,n3,m1,m2: (m1,m2),
 "FULL":     lambda n2,n3,m1,m2: (),
}
NTOP = 7
t0 = time.time()
for orbit in [(6,1,1),(5,2,1),(4,3,1)]:
    results = {g: True for g in GROUPINGS}
    firstfail = {g: None for g in GROUPINGS}
    for n in range(NTOP+1):
        acc = {g: {} for g in GROUPINGS}
        for n2 in range(n+1):
          for n3 in range(n2+1):
            M = n2+n3
            for m2 in range(M+1):
              N = n - n2 + m2
              for m1 in range(N+2):
                sm = summand(orbit, n, n2, n3, m1, m2)
                if sm == 0: continue
                for g, key in GROUPINGS.items():
                    k = key(n2,n3,m1,m2)
                    acc[g][k] = acc[g].get(k, Rq(0)) + sm
        for g in GROUPINGS:
            for k, poly in acc[g].items():
                if any(c < 0 for c in poly.list()):
                    if results[g]: firstfail[g] = (n, k)
                    results[g] = False
    print("orbit %s  [%.0fs]:" % (orbit, time.time()-t0))
    for g in GROUPINGS:
        print("   %-9s : %s %s" % (g, "NONNEG(all n<=%d)" % NTOP if results[g] else "FAIL",
                                   "" if results[g] else "first at n=%d key=%s" % firstfail[g]), flush=True)
