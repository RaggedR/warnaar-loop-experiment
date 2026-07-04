"""Sanity-check the three q-binomial identities used in the d=2 proof, n,m <= 25."""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed4_R2L2_orbit_system import padd, pmul, psub
from seed4_R2L2_d2_closed_form import qbinom, RR

def fam(n, shift):
    s = {}
    for j in range(n+1):
        s = padd(s, {k + j*j + shift*j: v for k, v in qbinom(n, j).items()})
    return s

ok = True
for n in range(0, 26):
    A = fam(n,1); B = fam(n,0); C = fam(n,2)
    # (iii) qC_n = B_n - (1-q^{n+1})A_n
    lhs = {k+1: v for k, v in C.items()}
    rhs = psub(B, psub(A, {k+n+1: v for k, v in A.items()}))
    if lhs != rhs: ok=False; print("iii FAIL", n)
    if n >= 1:
        Am1 = fam(n-1,1); Bm1 = fam(n-1,0); Cm1 = fam(n-1,2)
        # (i)
        if psub(B, Bm1) != {k+n: v for k, v in Am1.items()}: ok=False; print("i FAIL", n)
        # (ii)
        if psub(A, Am1) != {k+n+1: v for k, v in Cm1.items()}: ok=False; print("ii FAIL", n)
print("ALL IDENTITIES OK n<=25" if ok else "FAILURE")
