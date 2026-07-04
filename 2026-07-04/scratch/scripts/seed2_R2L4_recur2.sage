# Inspect residues of the sharpest passing recurrences; hunt for an exact identity.
from sage.all import *
Lq = LaurentPolynomialRing(ZZ, 'q'); ql = Lq.gen()
Rq = PolynomialRing(ZZ, 'q'); qp = Rq.gen()
def qbin(n, m):
    if m < 0 or n < 0 or m > n: return Rq(0)
    return q_binomial(n, m, qp)
memo = {}
def Ls(n, n2, n3):
    if n2 > n or n3 > n2 or min(n,n2,n3) < 0: return None
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

print("== L values, small cases ==")
for n in range(4):
  for n2 in range(n+1):
    for n3 in range(n2+1):
        print("L(%d,%d,%d) = %s" % (n,n2,n3, Ls(n,n2,n3)))
print()
print("== residues r2 = L - q^2 L(n2-1,n3-1) ==")
for n in range(1,5):
  for n2 in range(1,n+1):
    for n3 in range(1,n2+1):
        r = Ls(n,n2,n3) - ql**2*Ls(n,n2-1,n3-1)
        print("r2(%d,%d,%d) = %s" % (n,n2,n3, r))
print()
print("== residues rn = L - L(n-1,n2,n3) (n-decrement alone was NOT in pass list; check) ==")
for n in range(1,5):
  for n2 in range(min(n-1,3)+1):
    for n3 in range(n2+1):
        L0 = Ls(n-1,n2,n3)
        if L0 is None: continue
        r = Ls(n,n2,n3) - L0
        print("rn(%d,%d,%d) nonneg=%s  %s" % (n,n2,n3, all(c>=0 for c in r.coefficients()), r))
