"""Inspect P_m = (q;q)_m F_{c,m}: polynomial? degree? symmetric? positive?"""
from fractions import Fraction
exec(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed2_R2L2_abel.py').read().split('for d in [2, 4, 5, 7]:')[0])

for d in [2, 4, 5]:
    m_max = 3
    prec = 6*m_max**2 + 250
    Fs = compute_F(d, m_max, prec)
    reps = orbit_reps(d)
    print(f"=== d={d} ===")
    for m in range(1, m_max+1):
        poch = qpoch(m, prec)
        for c in reps:
            P = smul2(poch, Fs[m][c], prec)
            nz = [i for i in range(prec-40) if P[i] != 0]
            ispoly = (max(nz) < prec - 100) if nz else True
            degP = max(nz) if nz else -1
            coeffs = [int(P[i]) for i in range(degP+1)]
            pal = coeffs == coeffs[::-1]
            print(f" m={m} c={c}: poly={ispoly} deg={degP} palindromic={pal} P={coeffs if degP<40 else str(coeffs[:20])+'...'} P(1)={sum(coeffs)}")
    print()
