"""Seed 8 R2L3 attack (b): BFF first level via Gauss inversion, at scale.
a_n := sum_{m=0}^n (-1)^{n-m} q^binom(n-m,2) [n,m]_q H_{c,m}  (exact in ZZ[q]).
Tests:
  (i)  Q-transform: a_n == D_{n,n} (= Q_n) EXACTLY — stresses the unproved Q-transform.
  (ii) a_n >= 0 — the first-level BFF positivity content on wall orbits.
Usage: sage seed8_R2L3_gauss.sage d n_max [c0,c1,c2 ...]  (default: all orbit reps)
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
import sys, time

d = int(sys.argv[1]); n_max = int(sys.argv[2])
if len(sys.argv) > 3:
    targets = [tuple(int(x) for x in a.split(',')) for a in sys.argv[3:]]
else:
    targets = orbit_reps(d)
t0 = time.time()
H, viol = build_H(d, n_max, verbose=False)
print("build_H d=%d m<=%d: %.1fs, h/mono violations=%d" % (d, n_max, time.time()-t0, len(viol)), flush=True)
bad = 0
for c in targets:
    D = dtower(H, c, n_max)
    for n in range(1, n_max+1):
        a = gauss_a(H, c, n)
        qt = (a == D[(n, n)])
        r = neg_report(a)
        if not qt:
            bad += 1
            diff = a - D[(n, n)]
            print("*** Q-TRANSFORM FAIL c=%s n=%d: a_n - D_n^n = %s..." % (c, n, str(diff)[:120]), flush=True)
        if r is not None:
            bad += 1
            print("*** a_n NEGATIVE c=%s n=%d first_neg deg=%d coeff=%d (EXACT)" % ((c, n) + r[:2]), flush=True)
    mn, mi = min_coeff(gauss_a(H, c, n_max))
    print("c=%s: n<=%d Q-transform EXACT match + a_n>=0 all OK; hull-min coeff of a_%d = %d @ deg %d"
          % (c, n_max, n_max, mn, mi), flush=True)
print("DONE %.1fs: %s" % (time.time()-t0, "CLEAN" if bad == 0 else "%d PROBLEMS" % bad))
