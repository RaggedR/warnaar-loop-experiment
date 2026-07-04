"""Catalogue U_{c,O}(x) polynomials; verify algebraic lemmas; verify orbit formula for d=5.
Lemma checks:
  L1: EMD(sigma c, sigma c') = EMD(c,c')  [algebraic proof exists; numeric double-check]
  L2: EMD(c, sigma c') == EMD(c,c') + d (mod 3)
"""
from fractions import Fraction
exec(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed2_R2L2_abel.py').read().split('for d in [2, 4, 5, 7]:')[0])

# L2 check
bad = 0
for d in range(1, 21):
    for c in profiles(d):
        for cp in profiles(d):
            if (emd(c, rot(cp)) - emd(c, cp) - d) % 3 != 0:
                bad += 1
print("Lemma 2 (EMD(c,sc') = EMD(c,c') + d mod 3):", "OK" if bad == 0 else f"FAIL {bad}")

# U shapes
for d in [4, 5, 7, 8]:
    reps = orbit_reps(d)
    shapes = {}
    for c in reps:
        for O in reps:
            U = tuple(U_pair(c, O))
            shapes.setdefault(U, []).append((c, O))
    print(f"\nd={d}: {len(shapes)} distinct U shapes:")
    for U, pairs in sorted(shapes.items(), key=lambda kv: len(kv[0])):
        neg = any(x < 0 for x in U)
        print(f"  {list(U)}  (count {len(pairs)}){'  <-- has negatives' if neg else ''}")

# verify orbit formula matches h_m for d=5, m=1,2  (transfer vs formula)
import importlib
exec(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed2_R2L2_orbit_product.py').read().split('# ---------- run comparison ----------')[0].split('EMD rotation invariance')[0].replace('bad = 0','bad_unused = 0'), globals())
