# Experimental math on LEMMA CANDIDATE A: the (4,3,1) slice
#  L(n,n2,n3) = sum_{m1,m2} q^{m1^2-n m1 + m2^2-n2 m2 + m2} [M;m2] ([N+1;m1]-q^{1+n3+m1}[N;m1])
#  M=n2+n3, N=n-n2+m2.  (Laurent in q; multiply by q^big to inspect.)
# Goals: (1) print normalized L for small args, factor; (2) test iterated-absorption:
#  after the split inner = q^{m1}(1-q^{1+n3})[N;m1] + [N;m1-1], is the residual
#  R = B-part - q^{1+n3} A-part nonneg per slice? (i.e. one absorption round enough?)
from sage.all import *
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()
Lq = LaurentPolynomialRing(ZZ, 'q'); ql = Lq.gen()
def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)

def Lslice(n, n2, n3):
    M = n2 + n3
    tot = Lq(0)
    for m2 in range(M+1):
        N = n - n2 + m2
        for m1 in range(N+2):
            inner = qbin(N+1, m1) - qp**(1+n3+m1)*qbin(N, m1)
            if inner == 0: continue
            tot += ql**(m1**2 - n*m1 + m2**2 - n2*m2 + m2) * Lq(qbin(M, m2)) * Lq(inner)
    return tot

def Apart(n, n2, n3):
    # sum q^{...+m1} [N;m1] [M;m2]  (the (1-q^{1+n3}) companion)
    M = n2 + n3; tot = Lq(0)
    for m2 in range(M+1):
        N = n - n2 + m2
        for m1 in range(N+1):
            tot += ql**(m1**2 - n*m1 + m2**2 - n2*m2 + m2 + m1) * Lq(qbin(M, m2)*qbin(N, m1))
    return tot

def Bpart(n, n2, n3):
    # sum q^{...} [N;m1-1] [M;m2]
    M = n2 + n3; tot = Lq(0)
    for m2 in range(M+1):
        N = n - n2 + m2
        for m1 in range(1, N+2):
            tot += ql**(m1**2 - n*m1 + m2**2 - n2*m2 + m2) * Lq(qbin(M, m2)*qbin(N, m1-1))
    return tot

def nonneg(p):
    return all(c >= 0 for c in p.coefficients())

print("== check split L == (1-q^(1+n3)) A + B, and residual R = B - q^(1+n3) A >= 0 ? ==")
for n in range(7):
  for n2 in range(n+1):
    for n3 in range(n2+1):
        L = Lslice(n,n2,n3); A = Apart(n,n2,n3); B = Bpart(n,n2,n3)
        assert L == (1 - ql**(1+n3))*A + B
        R = B - ql**(1+n3)*A
        print("n=%d n2=%d n3=%d: L>=0:%s  R>=0:%s" % (n,n2,n3, nonneg(L), nonneg(R)))
