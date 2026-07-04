"""Seed 2 R2 L2: shifted domination among orbit P-values.
For each ordered pair of orbits (O, O'), find minimal delta >= 0 such that
P_m(O') >= q^delta * P_m(O) coefficientwise. Compare across m and with EMD.
"""
from fractions import Fraction
exec(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed2_R2L2_abel.py').read().split('for d in [2, 4, 5, 7]:')[0])

def min_shift(target, source, upto, maxdelta=40):
    # minimal delta with target >= q^delta * source; None if none <= maxdelta
    for delta in range(maxdelta+1):
        ok = True
        for i in range(upto - delta):
            if target[i+delta] < source[i]:
                ok = False; break
        if ok: return delta
    return None

for d in [4, 5, 7]:
    m_max = 3 if d <= 5 else 3
    prec = 6*m_max**2 + 200
    Fs = compute_F(d, m_max, prec)
    reps = orbit_reps(d)
    print(f"\n=== d={d} ===")
    check_upto = prec - 40
    for m in range(1, m_max+1):
        poch = qpoch(m, prec)
        P = {c: smul2(poch, Fs[m][c], prec) for c in reps}
        print(f" m={m}:")
        for O in reps:
            row = []
            for Op in reps:
                delt = min_shift(P[Op], P[O], check_upto)
                row.append(delt)
            print(f"   from {O}: {row}")
        # also EMD between reps for reference
    print(" EMD(O',O) matrix (row=O source, col=O' target):")
    for O in reps:
        print(f"   {O}: {[min(emd(Op, r) for r in (O, rot(O), rot(rot(O)))) for Op in reps]}")
