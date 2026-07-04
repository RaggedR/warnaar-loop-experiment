# Label Audit — Round 2, Layer 4, Seed 7 (verifier)

**Reference**: synthesis-layer3.md §4(iv). Ground truth = raw conjecture.tex interlacing
definition. TRUE labels; target-first kernel q^{m·EMD(c,c')} (c = target, level m).
H_source-first[c] = H_true[rev(c)], rev(c0,c1,c2) = (c2,c1,c0). Reference engine:
scratch/scripts/seed8_R2L3_engine.sage (raw-validated).

**Method** (scripts: seed7_R2L4_fingerprints.sage, seed7_R2L4_d5fit_true.sage,
seed7_R2L4_fingerprints2.sage, scanner seed7_R2L4_label_audit.py → seed7_R2L4_label_audit.out):
1. Automated scan of every in-scope artifact for CHIRALITY-SENSITIVE profile tuples
   (orbit(c) ≠ orbit(rev(c)); d ∈ {4,5,7,8,10,11,13,14}; d=2 orbits all symmetric).
2. Per-file convention determined by MACHINE FINGERPRINTS against the reference engine
   (not by provenance alone):
   - F1 (d=4 ferm fits, TRUE): MATCH (0,0,4)→(1,1,0), (0,3,1)→(0,1,0), (1,1,2)→(0,0,0);
     NO MATCH (walls): (0,1,3), (0,2,2).
   - F1' (d=5 quadruple CDU fit, TRUE): MATCH (0,0,5),(0,4,1),(1,1,3),(1,2,2);
     NO MATCH (0,1,4),(0,2,3),(0,3,2).
   - F2 (d=4 orbit U−I rows, cols [(0,0,4),(0,1,3),(0,2,2),(0,3,1),(1,1,2)]):
     TRUE row (1,1,2) = [x³,x²,x,x,0]; REVERSED row = [x³,x,x,x²,0].
   - F4 (d=4 EMD triples from target (4,0,0)): TRUE: orbit(3,1,0)→{1,5,6}, orbit(0,1,3)→{2,3,7};
     REVERSED swaps them.
   - F5 (seed5 d=8 JSON Q_n at (4,1,3),(4,3,1),(5,1,2),(5,2,1), n≤3): == TRUE engine exactly;
     and seed5's emd == engine emd on all d=8 pairs (target-first).
   - F6 (seed6 L2 G-relations at d=5 ((4,0,1),(3,0,2),(3,2,0)) and d=8 ((6,0,2)) verified
     against TRUE-engine F-series, z-coeffs, exact to prec 60): ALL PASS as stated.
   - Kernel greps: seed3 L2/L3 EMD scripts and seed4 L3 engine use q^{m·emd(c',c)}
     (source-first); seed4 L2, seed5 L2 use q^{m·emd(c,c')} (target-first); seed3 L3
     combinatorial scripts use the raw chain model a_i ≤ a_{i−1}+c_i (= TRUE directly).
   - Sanity re-proved in code: H_source-first[c] == H_true[rev(c)], d=4,5, m≤5, all profiles.

**Reversal-closure principle**: aggregate claims (all profiles / all orbits / reversal-closed
sets) are convention-independent. Only claims naming a specific reversal-ASYMMETRIC orbit flip.

## Audit table

| File | Convention | Affected per-orbit claims (TRUE-label correction) |
|---|---|---|
| scratch/prove-seed1-layer1.md | n/a | no chirality-sensitive per-orbit claims |
| scratch/prove-seed2-layer1.md | TRUE-orientation EMD | L45 "EMD((0,0,4),(0,1,3))=2": numerically the TARGET-first value emd(target=(0,0,4),src=(0,1,3)); fine as stated; no H/Q claims affected |
| scratch/prove-seed3-layer1.md | n/a | none |
| scratch/prove-seed4-layer1.md | n/a | none |
| scratch/prove-seed5-layer1.md | n/a | none |
| scratch/prove-seed6-layer1.md | TRUE (raw-def engine, seed6_R2L1_verify_def.sage) | L44–45 Warnaar-match at (7,1,0),(6,2,0),(5,3,0) etc.: literature labels, stand as written; L105 Q₂≥0 spot-checks incl. (1,3,4): stand |
| scratch/prove-seed7-layer1.md | n/a | none |
| scratch/prove-seed8-layer1.md | n/a | none |
| scratch/prove-seed1-layer2.md | n/a | none |
| scratch/prove-seed2-layer2.md | n/a | none |
| scratch/prove-seed3-layer2.md | **REVERSED** (kernel grep + F1/F1'/F4) | L74–75 EMD triples for target (4,0,0): quoted "orbit(3,1,0)→{2,3,7}" is TRUE orbit(0,1,3)→{2,3,7} (and quoted "(3,1,0)→{2,3,4}, (0,2,2)→{1,2,3}" for target (2,1,1): TRUE labels are orbit(0,1,3)→{2,3,4} — cf. F4). L159/172/206 "d=4 missing (0,2,2),(0,3,1)": TRUE missing = (0,2,2),(0,1,3). L161/206 "d=5 unmatched (0,2,3),(0,3,2),(0,4,1)": TRUE unmatched = (0,2,3),(0,3,2),(0,1,4) (the {0,2,3}-pair swaps within itself; (0,4,1)→(0,1,4) flips) |
| proofs/prove-seed3-layer2.tex | **REVERSED** | L213: same correction as md L206 |
| scratch/prove-seed4-layer2.md | TRUE (target-first kernel; F1 confirms) | L209 fit at (0,3,1)=ferm(m,0,1,0): CORRECT as written. L210/240 misses (0,1,3),(0,2,2): CORRECT (these ARE the TRUE walls) |
| proofs/prove-seed4-layer2.tex | TRUE | L246–247 stand as written |
| scratch/prove-seed5-layer2.md | TRUE (F5: emd target-first; JSON Q_n == TRUE engine) | L97–98/124/138 CDU-style formula at orbit (4,3,1): stands in TRUE labels (no flip to (4,1,3)). L6–7/67 Warnaar/Uncu orbit lists: literature labels, stand |
| scratch/prove-seed6-layer2.md | TRUE (F6: G-relations pass vs TRUE engine as stated) | d=5 and d=8 R-relation heads/tails, INJ results ((4,1,0) v0 fail etc.), d=8 core list: all stand as written |
| proofs/prove-seed6-layer2.tex | TRUE | L153/191/275–301 stand as written |
| scratch/prove-seed7-layer2.md, proofs/prove-seed7-layer2.tex | n/a | none |
| scratch/prove-seed8-layer2.md, proofs/prove-seed8-layer2.tex | TRUE (raw CW inclusion-exclusion solve, no EMD kernel) | L167/L200 are aggregate ("all profiles d≤8") — safe |
| proofs/prove-seed1-layer2.tex, proofs/prove-seed2-layer2.tex | n/a | none |
| synthesis-layer1.md | n/a | none |
| synthesis-layer2.md | **MIXED** | Standing-notation kernel block is source-first (= BA31, known). L129 propagates Seed 3's reversed d=4/d=5 missing-orbit lists (correct TRUE lists per this audit: d=4 {(0,1,3),(0,2,2)}; d=5 unmatched {(0,2,3),(0,3,2),(0,1,4)}). L216 C2 adjudication: superseded by BA35 (both seeds right in own labels). L28/96/188–194/234 (Seed 5/6 d=8 material): TRUE, stand |
| scratch/verify-layer2-disputes.md | **REVERSED** (computed on source-first engine; F1 re-confirms) | L42–53/96–97/105–106: verdict retracted per §4(iv).5 + BA35. In TRUE labels the fit sits at (0,3,1) and the missing pair is {(0,1,3),(0,2,2)}; "Seed 4 WRONG" is itself wrong — Seed 4 L2 was in TRUE labels and correct |
| scratch/verify-hm-dispute.md | n/a | none |
| scratch/prove-seed3-layer3.md | **MIXED** (EMD-kernel scripts 1–4 REVERSED; chain-model scripts TRUE) | REVERSED parts: L75 U−I row (1,1,2)=[x³,x,x,x²,0] → TRUE row = [x³,x²,x,x,0] (i.e. TRUE: coefficient of orbit (0,1,3) is x², orbits (0,2,2),(0,3,1) get x — F2); L96–98 eps-example "target (0,3,1)" → TRUE target = orbit (0,1,3) with columns relabelled by rev. TRUE parts (chain model a_i ≤ a_{i−1}+c_i, verified in code): L129 Hall deadend at c=(0,3,1); L167–168 ILP-infeasible list ((0,3,1),(0,1,3),(3,1,0),(0,4,1),(4,2,1),…) — these are TRUE labels as written; Y5 HALL-RIBBON and Y7 raw-bracket cases likewise TRUE |
| scratch/prove-seed4-layer3.md | REVERSED engine (kernel grep: q^{m·EMD(cp,c)}, cp=source) | scanner: ZERO chirality-sensitive per-orbit claims — all G10/Y4 claims are aggregate (all profiles, d≤35) or depend on c only through rank/caps, which are rev-invariant. SAFE |
| proofs/prove-seed4-layer3.tex | REVERSED engine | ZERO sensitive per-orbit claims. SAFE |

## Bottom line

- **No new claim flips beyond those already recorded in §4(iv)**. The audit machine-confirms:
  Seed 3 L2 + its tex + verify-layer2-disputes.md + Seed 3 L3's EMD-kernel sections are
  REVERSED; Seed 4 L2, Seed 5 L2, Seed 6 L1/L2, Seed 8 L2 are TRUE.
- **Two genuinely new precise corrections** (not spelled out anywhere before):
  1. Seed 3 L3's quoted U−I row for target (1,1,2) is the reversed row; TRUE row is
     [x³,x²,x,x,0] (Conjecture A/Y8 itself unaffected — the row is nonneg either way,
     and the all-positive orbit set is reversal-closed).
  2. Seed 3 L2's d=5 unmatched list in TRUE labels is {(0,2,3),(0,3,2),(0,1,4)}
     (not {…,(0,4,1)}); machine-verified by rerunning the quadruple fit on the TRUE engine.
- **Important nuance for consumers of Seed 3 L3**: it is MIXED, not uniformly reversed —
  the chain-model results (D3 ILP certificates, D4, Y5 HALL-RIBBON, Y7) are already in TRUE
  labels because the chain model matches the raw definition directly (§4(iv).1). Only its
  Scripts 1–4 (U/eps/matrix, EMD-kernel) are reversed. This REFINES §4(iv).6's blanket
  statement "Seed 3/4 L3 analysis files are source-first".
- Seed 5 L2's (4,3,1) CDU-style formula (Y-item in synthesis-layer2 §"(4,3,1)") does NOT
  flip: Seed 5's engine was target-first and its Q_n data matches the TRUE engine exactly.
- Aggregate results everywhere remain valid (profile set is reversal-closed).
- Scope note: Round-1 artifacts (2026-07-03/) were not audited (different experiment round;
  nothing in the current dependency chain cites them per-orbit).
