# Seed 8, Layer 4, Round 2 — ADVERSARY (launched after Seeds 1–7 reported)

Conventions: synthesis-layer3.md §4(iv) (TRUE labels, target-first kernel).
Reference engine: scripts/seed8_R2L3_engine.sage (mine, raw-validated in L3).
Sage 10.9 at /Users/robin/miniforge3/envs/sage/bin/sage. Everything exact Z[q];
NO truncation shortcuts on positivity claims. Logs: scratch/tmp/seed8_L4_*.log.

## Twin missions
A. Counterexample hunt at scale: d=8 core n>16; d=7 n>18; d=10 all orbits
   (non-(4,3,3)); corner orbits; the six d=8 core DIFFERENCES
   ferm_{c2+1,c3+1}(n) - q*ferm_{c2,c3}(n) at high n; Seed 5's Q1 + SHARP-F0
   at higher (d,m,W).
B. Recompute siblings' L4 claims: S1 (d=10 ferm at n=13..15), S2 (7 forms n<=12 +
   differences high n), S3 (d=7 G_c >= 0 from raw defn + chain replay), S4 (Step 1 /
   2a-i stress at larger (d,m,W) + gap counterexample hunt), S6 (HM j<=40 + n=3
   analogue), S7 (Y8 falsification spot-confirm at (1,1,6)).

## Plan of scripts
- seed8_L4_missionA.sage — engine sweeps: d=8 (m<=18+), d=7 (m<=20+), d=10 (m<=13),
  Gauss-inversion a_n == D_n^n, a_n >= 0, min-margin trends. [BA30: this IS
  conjecture verification.]
- seed8_L4_fermdiff.sage — MY OWN transcription of Warnaar Eq_mineen/Eq_mineen2
  limits; check vs engine n<=12, then push the 7 differences to largest feasible n.
- seed8_L4_seed1_d10.sage — FERM3p (a=+1) at d=10 (4,3,3) vs engine n=13..15.
- seed8_L4_seed3_d7 — d=7 g-positivity from engine + raw brute-force; replay one
  substitution chain of seed3_R2L4_system.py.
- seed8_L4_seed4_stress.py — Step1/2a-i/2b stress at larger (d,m,W); hunt
  non-v-chain sources and two-source components.
- seed8_L4_seed6_hm.py — HM j=31..40 (CAP-SHARP box); har^(3) n=3 analogue probe.
- seed8_L4_y8_check.sage — (U-I) row at d=8 target (1,1,6).

## Log (incremental)

### [B6] Seed 7 Y8 spot-confirmation — CONFIRMED (done first, inline sage -c)
At d=8: EMD-triple of orbit(1,1,6) at target (1,1,6) = {0,5,10} (non-consecutive, spacing 5).
(U−I) diagonal entry = x^8 − x^7 + x^5 − x^4 + x^3 − x — EXACT match with Seed 7's table.
Neg-entry counts per target row: (3,3,2): 0; (1,1,6): 14; (2,2,4): 12.
Seed 7's Y8 falsification + corrected balanced-only statement: CONFIRMED.
Bonus: engine emd() ≡ synthesis §4(iv) EMD formula verified on all d=8 profile pairs.

### Background launches (running)
1. missionA d=8 m_max=20 -> tmp/seed8_L4_missionA_d8_m20.log
2. missionA d=7 m_max=22 -> tmp/seed8_L4_missionA_d7_m22.log
3. missionA d=10 m_max=14 -> tmp/seed8_L4_missionA_d10_m14.log
4. fermdiff NMAX=24 NCMP=12 (Seed 2 recompute + Mission A differences) -> tmp/seed8_L4_fermdiff_n24.log
5. seed1 d=10 FERM3p n<=15 -> tmp/seed8_L4_seed1_d10_n15.log

### [A] Mission A wave 1 — ALL CLEAN
- d=8 m<=20 (45 profiles, MASTER grid, Gauss a_n>=0 all n, diag, Q_n(1)=15^n): 0 violations (18s).
- d=7 m<=22 (36 profiles): 0 violations (23s). Extends Y1 range n<=18 -> 22.
- d=10 m<=14 (66 profiles): 0 violations (5s).
Wave 2 launched (running): d=8 m<=32, d=7 m<=32, d=10 m<=22, d=11 m<=18, d=13 m<=14,
fermdiff NMAX=32.

### [B2 + A] fermdiff n<=24 — Seed 2 recomputation + difference positivity: CLEAN
- [CMP]: my independent ferm transcription (from Warnaar Eq_mineen/mineen2 at source)
  differences ferm_{c2+1,c3+1}(n) - q*ferm_{c2,c3}(n) == engine gauss_a for ALL 7 orbits,
  n<=12, 0 mismatches. Independently confirms Seed 2's [Wn].
- [POS]: all 7 differences coefficientwise >= 0 up to n=24 (deg up to 4080).
  min-in-hull = 0 (zeros occur inside the hull near the top; no negatives anywhere).
  Extends Seed 2's positivity check n<=16 -> 24.

### [B1] Seed 1 d=10 (4,3,3) fermionic spot-check n<=15 — CLEAN
My own FERM3p transcription == engine Q_n for n=0..15, all coeffs >= 0, Q_n(1)=21^n.
Extends Seed 1's verified range n<=12 -> 15. VERDICT: Seed 1 chain numerically solid.

### [B3] Seed 3 d=7 recomputation — CLEAN
- Independent path (MY H-recursion + Gauss inversion -> Q_{n,c}/(q)_n) vs their pickle
  (raw-CW z-recursion): all 12 orbit reps match at every pickle level n<=8, PREC=200
  (coverage confirmed 12/12 reps present). g-positivity extended to n<=10, q^200: clean.
- Deterministic replay of seed3_R2L4_system.py launched (running).

### [B6 addendum recorded above; B5] Seed 6 HM + n=3 probe
- HM extension j=31..40 launched (seed8_L4_seed6_hm_ext.py, CAP-SHARP box M=j+2, cached).
- NEW FINDING (n=3 analogue probe, seed8_L4_seed6_nprobe.sage): direct residue-respecting
  monotonicity of RAW coefficients [q^j]Q_{n,c} (d=1 mod 3: steps e_i; d=2 mod 3:
  weight-2 steps), d in {4,5,7,8,10,11,13,14,16}, j<=60, 137250 comparisons each level:
    n=2: 114 FAILURES (all at even j>=16) — consistent with Seed 6's dead-end note
         (har-style correction needed at n=2).
    n=3: 0 failures.  n=4: 0 failures.
  i.e. the n=2 level appears to be the HARD case; at n>=3 the raw residue-respecting
  monotonicity holds empirically without any correction. Suggests the level-n lift may
  be EASIER than n=2, not harder. Worth a synthesis note.

### [B4 / A-remainder] launched (running)
- seed8_L4_seed4_stress.py: Step-1 lemmas at d in {8,10,11,12} incl. corners (12,0,0),
  W<=13; 2b checkD singleton-source at W<=14; 2a-ii non-v-chain source hunt at W<=14.
- seed8_L4_seed5_q1ext.py: Q1/Q2 at d in {10,11,13} + corners + m=5, W<=14.

### Results wave 2 (as they land)
- [B3] seed3_R2L4_system.py deterministic replay: PASS ("positive-system solution ==
  raw-CW engine solution (all 12 orbits, n<=8, q^200): PASS"; nonneg sanity PASS).
- [B4] seed8_L4_seed4_stress.py: ALL PASS. Step-1 lemmas (C0/CL/CV/CS/CE) clean at
  d in {8,10,11,12} incl. corners (10,0,0),(12,0,0),(13,0,0 in q1ext), W<=13.
  2b checkD: singleton reachable-source everywhere (incl. d=10 (4,3,3) m=3 W=13,
  d=12 (12,0,0) m=2 W=14, m=4 cases). 2a-ii hunt: sources found in every case are
  ALL v-chains (e.g. d=2 (1,1,0) m=4 W=14: 31 sources, 0 non-v-chain;
  d=5 (3,1,1) m=3 W=14: 4 sources, 0 non-v-chain). No counterexample to either gap.
- [A/Seed5] seed8_L4_seed5_q1ext.py: Q1 ALL HOLD, Q2 ALL HOLD at d in {10,11,13}
  (incl. (10,0,0),(13,0,0),(0,1,7)), m up to 5, W<=14. Extends Seed 5's 15 cases by 14 more.
- [B5] HM extension: j=31..36 clean so far (0 failures each, ~150k steps/level), running to 40.
- Wave-2 sweeps relaunched from repo root (first launch died on relative load path).

### FINAL RESULTS — all waves complete, NO COUNTEREXAMPLE FOUND ANYWHERE
Mission A (per BA30, MASTER sweeps = conjecture verification; all exact Z[q], full
MASTER grid incl. boundary must-fail, diag a_n==D_n^n, Q_n(1)=(K-1)^n):
- d=7  m<=32: 0 violations (259s). Y1 range n<=18 -> 32.
- d=8  m<=32: 0 violations (314s). Y1 range n<=16 -> 32 (all 45 profiles).
- d=10 m<=22: 0 violations (102s). Prior n<=9 -> 22 (all 66 profiles, all orbits,
  not just (4,3,3)).
- d=11 m<=18: 0 violations (51s). NEW d.
- d=13 m<=14: 0 violations (24s). NEW d.
- d=8 core DIFFERENCES ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n): coefficientwise >= 0
  for ALL 7 orbits up to n=32 (deg 7200; 196 clean cells n=5..32). No negative
  coefficient anywhere. Corner orbits (0,0,d) and d=1 mod 3 asymmetries all covered
  by the all-profile sweeps.
Margin note: min-in-hull of the differences is 0 (zeros inside the hull near top
degree — structural, present at all n; not a shrinking margin).

Mission B verdicts:
- B1 Seed 1 (d=10 theorem): CONFIRMED, extended n<=15 via my own FERM3p transcription.
- B2 Seed 2 (7 two-term reps): CONFIRMED n<=12 exact vs engine; positivity of the
  differences extended n<=32. (Verifier's GAP E1 overbreadth erratum stands —
  my checks cover exactly the 7 listed representatives.)
- B3 Seed 3 (d=7 positive system): CONFIRMED — independent g recomputation (different
  algorithm) matches pickle n<=8 exactly, g>=0 extended to n<=10 @ q^200; system.py
  deterministic replay PASS.
- B4 Seed 4 (Tingley Step 1, 2a-i, gaps): Step-1 lemmas clean at d<=12 incl. corners;
  NO counterexample to 2a-ii (all sources are v-chains) or 2b (singleton
  reachable-source) at W<=14, d<=12. Gaps remain open but robust.
- B5 Seed 6 (HM): EXTENDED j=31..40, 0 failures (238518 steps at j=40). HM now holds
  j<=40. NEW: n=3/n=4 raw residue-respecting monotonicity of [q^j]Q_n holds with ZERO
  failures (d<=16, j<=60), while n=2 raw fails at even j>=16 — n=2 is the hard level;
  the level-n lift may be easier than expected.
- B6 Seed 7 (Y8 falsification): CONFIRMED exactly (diagonal entry, neg-entry counts).

Scripts: seed8_L4_missionA.sage, seed8_L4_fermdiff.sage, seed8_L4_seed1_d10.sage,
seed8_L4_seed3_gcheck.sage, seed8_L4_seed4_stress.py, seed8_L4_seed5_q1ext.py (+shim),
seed8_L4_seed6_hm_ext.py, seed8_L4_seed6_nprobe.sage. Logs: tmp/seed8_L4_*.log.
ADVERSARY VERDICT: the conjecture and all sibling claims SURVIVED every attack.
