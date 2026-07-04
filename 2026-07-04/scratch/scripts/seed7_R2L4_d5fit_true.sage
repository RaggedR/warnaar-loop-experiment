"""Seed 7 R2L4: rerun Seed 3 L2's d=5 quadruple fermionic fit against the TRUE engine."""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
from itertools import product as iproduct

def qbin(n, k):
    if k < 0 or k > n: return Rq(0)
    return Rq(q_binomial(n, k, q))

Ht, _ = build_H(5, 5, verbose=False)
M = 5
for c in orbit_reps(5):
    found = []
    for a in iproduct(range(2), range(2), range(2), range(2)):
        ok = True
        for m in range(M+1):
            s = Rq(0)
            for n1 in range(m+1):
                for n2 in range(n1+1):
                    for n3 in range(n2+1):
                        for n4 in range(n1+1):
                            s += q**(n1**2+n2**2+n3**2+n4**2 - n1*n2 + n2*n4
                                     + a[0]*n1 + a[1]*n2 + a[2]*n3 + a[3]*n4) \
                                 * qbin(m, n1) * qbin(n1, n2) * qbin(n2, n3) * qbin(n1, n4)
            if s != Ht[m][c]:
                ok = False; break
        if ok: found.append(a)
    print("TRUE d=5 orbit %s: %s" % (c, found if found else "NO MATCH"), flush=True)
