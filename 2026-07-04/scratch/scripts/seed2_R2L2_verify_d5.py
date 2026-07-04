"""Verify orbit-product formula for d=5 (m=1,2) and P_m version; check alternating-sign property of U."""
from fractions import Fraction
from itertools import product as iproduct
exec(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed2_R2L2_abel.py').read().split('for d in [2, 4, 5, 7]:')[0])

def pmul(a, b):
    r = [0]*(len(a)+len(b)-1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if y: r[i+j] += x*y
    return r
def padd(a, b):
    n = max(len(a), len(b))
    return [(a[i] if i < len(a) else 0)+(b[i] if i < len(b) else 0) for i in range(n)]
def subq(p, j):
    r = [0]*((len(p)-1)*j+1)
    for i, x in enumerate(p):
        if x: r[i*j] += x
    return r

# alternating-sign check for all d up to 14
for d in range(1, 15):
    if d % 3 == 0: continue
    reps = orbit_reps(d)
    ok = True
    for c in reps:
        for O in reps:
            for top in (False, True):
                U = U_pair(c, O, top_diag=top)
                nz = [x for x in U if x != 0]
                if any(abs(x) != 1 for x in nz) or nz[0] != 1 or nz[-1] != 1: ok = False
                for i in range(len(nz)-1):
                    if nz[i]*nz[i+1] != -1: ok = False
    print(f"d={d}: U alternating {{0,+-1}} start/end +1: {'OK' if ok else 'FAIL'}")

# d=5 formula verification
d = 5; m_max = 2
prec = 6*m_max**2 + 200
Fs = compute_F(d, m_max, prec)
reps = orbit_reps(d)
for m in range(1, m_max+1):
    poch = qpoch(m, prec)
    for c in reps:
        # h_m reference
        g = [Fs[m][c][i]-Fs[m-1][c][i] for i in range(prec)]
        href = smul2(poch, g, prec)
        Pref = smul2(poch, Fs[m][c], prec)
        # formula
        totalH = [0]; totalP = [0]
        for seq in iproduct(reps, repeat=m):
            chain = [c]+list(seq)
            prodH = [1]; prodP = [1]
            for jidx in range(m):
                j = m - jidx
                UH = U_pair(chain[jidx], chain[jidx+1], top_diag=(jidx == 0))
                UP = U_pair(chain[jidx], chain[jidx+1], top_diag=False)
                prodH = pmul(prodH, subq(UH, j))
                prodP = pmul(prodP, subq(UP, j))
            totalH = padd(totalH, prodH)
            totalP = padd(totalP, prodP)
        okH = all(Fraction(totalH[i] if i < len(totalH) else 0) == href[i] for i in range(prec-40))
        okP = all(Fraction(totalP[i] if i < len(totalP) else 0) == Pref[i] for i in range(prec-40))
        print(f"d=5 m={m} c={c}: h formula {'MATCH' if okH else 'FAIL'}, P formula {'MATCH' if okP else 'FAIL'}")
