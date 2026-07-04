"""
d=2: conjecture H_m(orbit (1,1,0)) = sum_j q^{j^2} [m j]_q  (Schur/RR polynomial)
     H_m(orbit (2,0,0)) = sum_j q^{j^2+j} [m j]_q
Verify against orbit tower up to m=10.
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed4_R2L2_orbit_system import H_tower, padd, pmul, pstr

def qbinom(m, j):
    # [m j]_q as dict poly via q-Pascal
    if j < 0 or j > m: return {}
    B = {0: {0:1}}
    for mm in range(1, m+1):
        newB = {}
        for jj in range(0, mm+1):
            a = B.get(jj, {})            # [mm-1, jj]
            b = B.get(jj-1, {})          # [mm-1, jj-1]
            # [mm jj] = [mm-1 jj-1] + q^jj [mm-1 jj]
            newB[jj] = padd(b, {k+jj: v for k, v in a.items()})
        B = newB
    return B.get(j, {})

def RR(m, shift):
    # sum_j q^{j^2 + shift*j} [m j]
    s = {}
    j = 0
    while j <= m:
        s = padd(s, {k + j*j + shift*j: v for k, v in qbinom(m, j).items()})
        j += 1
    return s

orbits, U, hist = H_tower(2, 10)
print("orbits:", [o[0] for o in orbits])  # expect [(0,0,2),(0,1,1)]
ok = True
for m in range(11):
    a_pred = RR(m, 1)   # orbit (0,0,2)/(2,0,0): q^{j^2+j}
    b_pred = RR(m, 0)   # orbit (0,1,1)/(1,1,0): q^{j^2}
    if hist[m][0] != a_pred or hist[m][1] != b_pred:
        ok = False
        print(f"m={m} MISMATCH")
        print("  A actual:", pstr(hist[m][0])); print("  A pred:  ", pstr(a_pred))
        print("  B actual:", pstr(hist[m][1])); print("  B pred:  ", pstr(b_pred))
print("ALL MATCH up to m=10" if ok else "FAILED")
