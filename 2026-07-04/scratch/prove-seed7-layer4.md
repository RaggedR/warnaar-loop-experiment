# Seed 7 — Round 2 Layer 4 — VERIFIER/HOUSEKEEPING (Mission 7)

Convention: synthesis-layer3.md §4(iv). Ground truth = raw conjecture.tex interlacing
definition; TRUE labels; target-first kernel q^{m·EMD(c,c')}; H_src-first[c] = H_true[rev(c)],
rev(c0,c1,c2) = (c2,c1,c0). Reference engine: 2026-07-04/scratch/scripts/seed8_R2L3_engine.sage.
Sage: /Users/robin/miniforge3/envs/sage/bin/sage (10.9).

## Status log (incremental)

- [T0] Scratch created. Plan:
  (a) label audit -> 2026-07-04/scratch/label-audit-layer4.md.
      Method: fingerprint chirality-sensitive per-orbit H/Q data quoted in old artifacts
      against TRUE engine values and their rev-images. Scope: 2026-07-04 layer-1/2 scratch
      (prove-seed*-layer{1,2}.md), proofs/prove-seed*-layer2.tex, synthesis-layer{1,2}.md,
      seed3/seed4 layer-3 files (prove-seed{3,4}-layer3.md, prove-seed4-layer3.tex).
  (b) Y7: algebra: g_m - q^m F_m = [(1-q^m)(H_m - H_{m-1})]/(q;q)_m = Delta_m/(q;q)_{m-1}.
      So Y7 = series-nonneg of Delta_m/(q;q)_{m-1}, exact to stated precision.
      Y8 (Conjecture A, seed3 L3 Script 2): for all-positive target c the ORBIT-level
      (U-I)_c row is entrywise nonneg in x (claim: all orbit EMD-triples consecutive).
      Push both to d=8,10,11,13.
  (c) Lean: read lean/WarnaarGlue/*.lean; add Theorem D kernel identities + nonneg predicate;
      lake build sorry-free.

## (a) Label audit — fingerprints computed (scripts/seed7_R2L4_fingerprints.sage, seed7_R2L4_d5fit_true.sage)

- Sanity re-proved in code: H_source-first[c] == H_true[rev(c)], d=4,5, m<=5, all profiles. PASS.
- F3 (EMD orientation): emd(target=(0,0,4), source=(0,1,3)) = 2; emd((0,1,3),(0,0,4)) = 1.
- F1 (d=4 ferm fits H_m = Σ q^{n²−nj+j²+an+bj}[m,n][2n+eps,j], TRUE labels, m<=4..6):
  MATCH: (0,0,4)→(a,b,eps)=(1,1,0); (0,3,1)→(0,1,0); (1,1,2)→(0,0,0).
  NO MATCH (walls): (0,1,3), (0,2,2).  [= G1's TRUE walls ✓]
  ⇒ any file claiming "fit at (0,1,3) / missing (0,3,1)" is in REVERSED labels.
- F1' (d=5 quadruple CDU-shape fit, TRUE labels, m<=5):
  MATCH: (0,0,5)→(1,1,1,1); (0,4,1)→(0,1,1,1); (1,1,3)→(0,0,1,0); (1,2,2)→(0,0,0,0).
  NO MATCH: (0,1,4), (0,2,3), (0,3,2).
  ⇒ Seed 3 L2's "unmatched {(0,2,3),(0,3,2),(0,4,1)}" is the REVERSED-label image
    (rev flips (0,4,1)↔(0,1,4); the {0,2,3}-pair swaps within itself).
- F2 (d=4 orbit-level U−I rows, cols [(0,0,4),(0,1,3),(0,2,2),(0,3,1),(1,1,2)]):
  TRUE row target (1,1,2):     [x^3, x^2, x, x, 0]
  REVERSED row target (1,1,2): [x^3, x, x, x^2, 0]  ← exactly Seed 3 L3's quoted row
  ⇒ Seed 3 L3 Script 2 data is source-first (confirmed, not just presumed).
  TRUE row target (0,3,1) has entries with mixed signs at cols 1,2,3 pre-division; the
  eps-example "target (0,3,1): G1 = H112+H004−H031, G2 = H013+H022−H004" is REVERSED-label.
- Engine provenance greps: seed3_R2L2_fermionic_fit.sage and seed4_R2L3_engine.py both use
  kernel q^{m·emd(cp,c)} with cp=source ⇒ SOURCE-FIRST (reversed). Reference engine uses
  emd(c,cp), target-first.

Next: scanner script over in-scope artifacts; assemble label-audit-layer4.md.

- [T1, resumed after usage-limit kill] (a) DONE before the kill: scanner
  (scripts/seed7_R2L4_label_audit.py -> .out) ran over all in-scope artifacts; full audit
  table + bottom line written to label-audit-layer4.md. Headlines: Seed 3 L2 (+tex),
  verify-layer2-disputes.md REVERSED; Seed 3 L3 MIXED (EMD-kernel scripts reversed,
  chain-model TRUE); Seed 4 L3 reversed engine but ZERO chirality-sensitive per-orbit
  claims; Seeds 4/5/6/8 L2 TRUE. Two new precise corrections logged (U-I row (1,1,2);
  d=5 unmatched list). Proceeding to (b) Y7/Y8 at d=8,10,11,13.
- [T2] (b) plan: Y7 <=> Delta_m/(q;q)_{m-1} series-nonneg (exact identity:
  g_m - q^m F_m = (1-q^m)Delta_m/(q;q)_m = Delta_m/(q;q)_{m-1}); exact coefficients up to
  stated precision, per profile. Y8 (Conjecture A): for all-positive target c, each
  orbit's EMD-triple {EMD(c,c'), c' in orbit} must be consecutive {e,e+1,e+2} with
  diagonal e=0; then (U-I)_c row = monomials, coefficientwise nonneg, EXACT in ZZ[x]
  (no truncation). Script: scripts/seed7_R2L4_y7y8.sage (TRUE labels, target-first
  kernel, reference-engine emd()).

- [T3] (c) LEAN DONE. New module lean/WarnaarGlue/TheoremD.lean (root import updated);
  full `lake build` GREEN (only pre-existing PascalLadder.lean:65 ring_nf info remains).
  Machine-checked, at abstract (A, q), A CommRing, with Corollary I as the named
  hypothesis hI (H_m = Sum_{n<=m} [m,n]_q Q_n — its Euler-expansion proof stays in the
  paper, exactly like the phase-2 pattern):
  * Dtower def (D_0^m = h_m with h_0 = H_0; D_{k+1}^m = D_k^m - q^{k+1} D_k^{m-1}).
  * hm_eq      : h_m = Sum_{j<=m} q^{m-j} [m,j]_q Q_j.
  * Dtower_eq  : D_k^{k+M} = Sum_{i<=M} q^{(k+1)(M-i)} [M,i]_q Q_{k+i}
                 (= synthesis form D_k^m = Sum_j q^{(k+1)(m-j)}[m-k,j-k]Q_j at j=k+i;
                 induction on k, one q-Pascal (pascal_2) per step).
  * delta_eq   : Delta_{m+1} = Sum_{i<=m} q^{m-i} [m,i]_q Q_{i+1} (= Sum_j q^{m-j}[m-1,j-1]Q_j).
  * Dtower_diag: Q_n = D_n^n (diagonal recovery, unconditional given hI).
  * Ferm-monotonicity via the existing CoeffNonneg predicate at (Z[X], X):
    ferm_hm_nonneg, ferm_monotone, ferm_Dtower_nonneg — Q-positivity implies h_m >= 0,
    H_{m+1} >= H_m, and every D-tower row >= 0 (the section 4(ix) reduction, machine-checked).
  * Supporting sorry-free polynomial lemmas: qint_mul_gauss ([i]_q[m+1,j] = [m+1]_q[m,j],
    i = m+1-j), one_sub_pow_mul_gauss(q) ((1-q^{m+1-j})[m+1,j] = (1-q^{m+1})[m,j]),
    gaussq_pascal_2 (transported q-Pascal).
  * Lemma E (optional item), cleared of denominators: lemmaE :
    Sum_{k<=K} (-1)^k q^{C(k,2)} qpochRatio(k,K) = (-1)^K q^{C(K+1,2)}, with
    qpochRatio k K = prod_{i=k+1}^K (1-q^i) and qpochRatio_zero_left : qpochRatio 0 K = qpoch K.
  AXIOM AUDIT: hm_eq, Dtower_eq, Dtower_diag, delta_eq, ferm_* , lemmaE,
  one_sub_pow_mul_gauss, qint_mul_gauss all depend only on
  [propext, Classical.choice, Quot.sound]. grep sorry/admit/native_decide: clean.
  NOT pushed to the public mirror (per brief — flagging in report).
  Build gotchas (3 iterations): rw [<- pow_add] with non-adjacent powers -> explicit calc;
  k+0 vs k mismatch after rw chain -> simp only; simp-loop in qpochRatio_zero_left -> rw.
- [T4] (b) note: first background launch of seed7_R2L4_y7y8.sage silently ran nothing —
  under `sage file.sage` __name__ == "sage.all", NOT "__main__". Guard replaced by
  explicit main(). (LESSON for future seeds' scripts.)

## (b) Y7 / Y8 re-verification — RESULTS (scripts/seed7_R2L4_y7y8.sage -> .out, seed7_R2L4_y7_highm.out)

### Y7 (raw bracket g_m >= q^m F_{c,m}): PASSES EVERYWHERE TESTED.
Method: exact identity g_m - q^m F_m = Delta_m/(q;q)_{m-1}; numerators exact in ZZ[q]
via the raw-validated target-first engine; series division exact to prec = 3*d*m_max+100
(>= deg numerator + margin). ALL PROFILES (not just orbit reps):
  d=8  m<=16, d=10 m<=14, d=11 m<=13, d=13 m<=12, d=14 m<=12: zero failures.
(First run also: d=8 m<=10, d=10 m<=9, d=11 m<=8, d=13 m<=7 — same, zero failures.)
Consistent with G6 (Y7 is a nonneg-kernel consequence of Q-positivity: Delta-row of
Theorem D — now also Lean-checked as delta_eq/ferm_monotone).

### Y8 (Conjecture A, Seed 3 Script 2): **FALSIFIED for every d >= 5 tested. URGENT.**
Claim as recorded (synthesis-layer3.md Y8, from prove-seed3-layer3.md Script 2):
"for every all-positive target c (all c_i>=1), all orbit EMD-triples are consecutive,
so the (U-I)_c row is coefficientwise nonneg and H-monotonicity at c is manifest."
Checked EXACTLY in ZZ[x] (U_{c,O}(x) = (sum_{c' in O} x^{EMD(c,c')})/(1+x+x^2), TRUE
labels, target-first, engine emd(); construction fingerprint-validated against Seed 3's
quoted d=4 rows in the label audit F2):

  d  | all-pos targets | rows fully nonneg (= the balanced orbit only)   | rows w/ neg
  4  | 3               | (1,1,2),(1,2,1),(2,1,1)                         | 0
  5  | 6               | (1,2,2),(2,1,2),(2,2,1)                         | 3
  7  | 15              | (2,2,3),(2,3,2),(3,2,2)                         | 12
  8  | 21              | (2,3,3),(3,2,3),(3,3,2)                         | 18
  10 | 36              | (3,3,4),(3,4,3),(4,3,3)                         | 33
  11 | 45              | (3,4,4),(4,3,4),(4,4,3)                         | 42
  13 | 66              | (4,4,5),(4,5,4),(5,4,4)                         | 63

- Conjecture A is TRUE at d=4 only because there the all-positive set = the balanced
  orbit. Already at d=5 it fails (e.g. every all-positive non-balanced target).
  Hand-checked example, d=8, target (1,1,6), own orbit: EMD-triple {0,5,10} (spacing 5,
  NOT consecutive); (U-I) diagonal entry = x^8-x^7+x^5-x^4+x^3-x. Alternating, not nonneg.
- CORRECTED STATEMENT (verified d in {4,5,7,8,10,11,13}, exact): the (U-I)_c row is
  coefficientwise nonneg EXACTLY for the balanced targets (|c_i-c_j| <= 1 for all i,j;
  the unique all-positive orbit with pairwise gaps <= 1). Manifest H-level monotonicity
  holds at the balanced orbit ONLY.
- Structural fact that DOES hold universally (all (target, orbit) pairs, incl.
  zero-containing targets, all d tested; 0 exceptions): every orbit EMD-triple is
  distinct mod 3, so each numerator is divisible by 1+x+x^2 and U(x) is a genuine
  POLYNOMIAL matrix. (Consecutiveness is the part that fails.)
- Blast radius: NOTHING GREEN is touched. Monotonicity itself still holds (Y7 above;
  and it is a theorem-level consequence of Q-positivity by G6). Y8 was a
  sufficient-condition/manifestness claim. But synthesis section 4(viii)'s "polarity
  reversal" narrative (all-positive = free at H-level) must be RETRACTED/refined:
  the H-level free class is the BALANCED orbit, not all all-positive orbits.
  Curious alignment: at d=8 the H-level-free orbit is exactly (3,3,2) — the one
  G-level-proved core orbit (G2). "Balanced is special" is consistent across levels,
  not opposite.

## FINAL STATUS (Mission 7 complete)
(a) label audit: DONE (label-audit-layer4.md, full table; no new flips beyond section 4(iv),
    two new precise corrections, Seed 3 L3 refined to MIXED).
(b) Y7: PASS at d=8 m<=16, d=10 m<=14, d=11 m<=13, d=13 m<=12, d=14 m<=12, all profiles,
    exact. Y8/Conjecture A: FALSIFIED for d>=5; corrected statement: nonneg rows exactly
    at the balanced orbit (verified d=4..13). Universal: U(x) is polynomial (all EMD
    triples distinct mod 3). URGENT flag raised for the synthesizer: retract Y8 +
    refine section 4(viii).
(c) Lean: TheoremD.lean added (Theorem D kernel identities, diagonal recovery,
    ferm-monotonicity via CoeffNonneg, Lemma E cleared form). lake build GREEN,
    sorry-free, axioms [propext, Classical.choice, Quot.sound] only.
    PUBLIC MIRROR PUSH NEEDED (not done by me, per brief).
