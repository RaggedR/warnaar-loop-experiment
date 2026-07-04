# Attempt 2: factor the diagonal move ferm(s,t) - q ferm(s-1,t-1) through elementary moves.
#  Route I : [ferm(s,t) - ferm(s-1,t)]           + [ferm(s-1,t) - q ferm(s-1,t-1)]
#  Route II: [ferm(s,t) - q ferm(s,t-1)]         + q[ferm(s,t-1) - ferm(s-1,t-1)]
# If both brackets of either route are coefficientwise >= 0 for all n, the orbit's
# positivity splits into two (hopefully provable) monotonicity lemmas.
from sage.all import *
import time
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()
def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)

def ferm_n(n, s, t):
    tot = Rq(0)
    if t <= 3:
        for n2 in range(n+1):
          for n3 in range(n2+1):
            m3 = 2*n3
            for m2 in range(n2 - n3 + m3 + (1 if t == 3 else 0) + 1):
              for m1 in range(n - n2 + m2 + (1 if t == 2 else 0) + 1):
                e = (n3**2 + sum((n, n2, n3)[i] for i in range(s-1, 3))
                     + sum((m1, m2)[i] for i in range(t-1, 2))
                     + n**2 - n*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                b = (qbin(n, n2) * qbin(n - n2 + m2 + (1 if t == 2 else 0), m1)
                     * qbin(n2, n3) * qbin(n2 - n3 + m3 + (1 if t == 3 else 0), m2))
                if b == 0: continue
                tot += b * qp**e
    else:
        assert 1 <= s <= 3
        for n2 in range(n+1):
          for n3 in range(n2+2):
            m3 = 2*n3
            for m2 in range(n2 - n3 + m3 + 1):
              for m1 in range(n - n2 + m2 + 1):
                e = (n3**2 - n3 + sum((n, n2, n3)[i] for i in range(s-1, 3))
                     + n**2 - n*m1 + m1**2 + n2**2 - n2*m2 + m2**2)
                b = (qbin(n, n2) * qbin(n - n2 + m2, m1)
                     * qbin(n2 + 1, n3) * qbin(n2 - n3 + m3, m2))
                if b == 0: continue
                tot += b * qp**e
    return tot

def nn(p): return all(c >= 0 for c in p.list())

core = [((6,1,1),(2,2)), ((5,2,1),(3,2)), ((5,1,2),(2,3)), ((4,3,1),(4,2)),
        ((4,1,3),(2,4)), ((4,2,2),(3,3)), ((3,3,2),(4,3))]
NTOP = 7
t0 = time.time()
for c, (s, t) in core:
    rI1 = rI2 = rII1 = rII2 = True
    for n in range(NTOP+1):
        f_st   = ferm_n(n, s, t)
        f_s1t  = ferm_n(n, s-1, t)
        f_st1  = ferm_n(n, s, t-1)
        f_s1t1 = ferm_n(n, s-1, t-1)
        rI1  = rI1  and nn(f_st - f_s1t)
        rI2  = rI2  and nn(f_s1t - qp*f_s1t1)
        rII1 = rII1 and nn(f_st - qp*f_st1)
        rII2 = rII2 and nn(f_st1 - f_s1t1)
    print("c=%s (s,t)=(%d,%d): Route I: s-move>=0:%s  t-move(q)>=0:%s | Route II: t-move(q)>=0:%s  s-move>=0:%s  [%.0fs]"
          % (c, s, t, rI1, rI2, rII1, rII2, time.time()-t0), flush=True)
