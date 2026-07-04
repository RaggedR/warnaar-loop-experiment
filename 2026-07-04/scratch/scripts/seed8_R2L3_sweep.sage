"""Seed 8 R2L3: adversarial sweep. Usage: sage seed8_R2L3_sweep.sage d m_max [reps|all] [allj|j0]
Checks (all EXACT):
  - h_m >= 0, H_m >= H_{m-1} for ALL profiles at every level (inside build_H)
  - MASTER grid per orbit rep (or all profiles): D_{k,m} >= 0 (0<=k<=m; D_{m,m} = Q_m),
    series f_k^(m) with (q;q)_j prefactors, boundary must-fail
  - N_m = (1+q^m+q^{2m}) Q_m >= 0 (reported; implied by Q_m >= 0)
Margins: prints per-orbit min coefficient of Q_m and of the tightest D-cell, to aim deep runs.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
import sys, time

d = int(sys.argv[1]); m_max = int(sys.argv[2])
scope = sys.argv[3] if len(sys.argv) > 3 else "reps"
allj = (len(sys.argv) > 4 and sys.argv[4] == "allj")

t0 = time.time()
print("=== SWEEP d=%d m_max=%d scope=%s allj=%s ===" % (d, m_max, scope, allj), flush=True)
H, viol = build_H(d, m_max, verbose=True)
print("build_H done: %.1fs, violations=%d" % (time.time()-t0, len(viol)), flush=True)

targets = orbit_reps(d) if scope == "reps" else profiles(d)
prec = 6*m_max*m_max + 200
all_viol = list(viol)
for c in targets:
    v = master_checks(H, c, m_max, all_j=allj, prec=prec, verbose=False, label="d=%d" % d)
    all_viol += v
    # margins on Q_m and worst D-cell
    D = dtower(H, c, m_max)
    qm = D[(m_max, m_max)]
    mn, mi = min_coeff(qm)
    worst = None
    for m in range(1, m_max+1):
        for k in range(0, m+1):
            w = min_coeff(D[(k, m)])
            if worst is None or w < worst[0]: worst = (w, k, m)
    print("  c=%s: grid clean=%s | minQ_%d-coeff=%d@%d Q(1)=%d | worst D-cell min=%d@deg%d (k=%d,m=%d)"
          % (c, len(v) == 0, m_max, mn, mi, qm(1), worst[0][0], worst[0][1], worst[1], worst[2]), flush=True)

print("=== d=%d DONE in %.1fs: %s ===" % (d, time.time()-t0,
      "ALL CLEAN (no counterexample)" if not all_viol else "*** %d VIOLATIONS ***" % len(all_viol)))
for v in all_viol[:50]: print(v)
