# Seed 8 L4 ADVERSARY — Mission A: exact Z[q] conjecture verification at scale.
# Per BA30 (synthesis-layer3 §4(i)): MASTER grids ARE the conjecture. Format:
#   1. build_H (exact Phi_3(q^m) division, h_m >= 0, monotonicity, all profiles)
#   2. Gauss inversion a_n for ALL profiles, n <= m_max: a_n >= 0 (= Q_n >= 0),
#      min-in-hull margin trend per n; corner orbit (d,0,0) tracked separately.
#   3. Full MASTER grid (poly cells, series cells j=0, boundary must-fail) for
#      all orbit reps.
#   4. a_n == D_n^n cross-check for orbit reps.
# Usage: sage seed8_L4_missionA.sage <d> <m_max>
import sys
load("2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")

d = int(sys.argv[1]); m_max = int(sys.argv[2])
print("=== Seed8 L4 Mission A: d=%d m_max=%d ===" % (d, m_max), flush=True)
t0 = time.time()
H, viol = build_H(d, m_max)
print("[H] build done, %d violations, %.1fs" % (len(viol), time.time()-t0), flush=True)

profs = profiles(d); reps = orbit_reps(d)
corner = (0, 0, d)  # min-rotation rep of the corner orbit
neg_total = 0
print("[GAUSS] a_n for ALL %d profiles, n<=%d" % (len(profs), m_max), flush=True)
margin_by_n = {}
for n in range(0, m_max+1):
    worst = None; worst_c = None
    for c in profs:
        a = gauss_a(H, c, n)
        r = neg_report(a)
        if r is not None:
            neg_total += 1
            print("*** NEGATIVE Q-COEFF d=%d n=%d c=%s first_neg deg=%d coeff=%d (min %d @ %d)"
                  % ((d, n, c) + r), flush=True)
        mn = min_coeff(a)
        if worst is None or mn < worst: worst, worst_c = mn, c
        if c == corner:
            cm = mn
    margin_by_n[n] = (worst, worst_c, cm)
    print("  n=%2d: min in-hull coeff %s @deg %s (c=%s); corner (0,0,%d): %s @ %s; %.1fs"
          % (n, worst[0], worst[1], worst_c, d, cm[0], cm[1], time.time()-t0), flush=True)

print("[MASTER] full grid, %d orbit reps" % len(reps), flush=True)
mviol = []
for c in reps:
    mviol += master_checks(H, c, m_max, all_j=False, label="d=%d" % d)
print("[MASTER] done, %d violations, %.1fs" % (len(mviol), time.time()-t0), flush=True)

print("[DIAG] a_n == D_n^n for orbit reps", flush=True)
bad = 0
for c in reps:
    D = dtower(H, c, m_max)
    for n in range(0, m_max+1):
        if gauss_a(H, c, n) != D[(n, n)]:
            bad += 1
            print("*** DIAG MISMATCH d=%d c=%s n=%d" % (d, c, n), flush=True)
# sanity: Q_n(1) = (K-1)^n at one rep
K = (d+1)*(d+2)//6
ok1 = all(gauss_a(H, reps[0], n)(1) == (K-1)**n for n in range(m_max+1))
print("[SANITY] Q_n(1)=(K-1)^n at %s: %s" % (reps[0], ok1), flush=True)
print("=== VERDICT d=%d m<=%d: H-viol=%d Qneg=%d MASTER-viol=%d diag-bad=%d ; %.1fs ==="
      % (d, m_max, len(viol), neg_total, len(mviol), bad, time.time()-t0), flush=True)
