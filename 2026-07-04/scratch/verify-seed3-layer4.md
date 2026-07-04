# Verification — Seed 3 Layer 4 (independent adversarial audit)

**Claim under audit**: complete CW-style positive y-functional system at d=7 (modulus 10);
7 zero rows + 5 core rows, exact substitution chains; uniqueness by q-adic contraction;
solution = raw CW/conjecture.tex solution; hence G_c(y,q) in N[[y,q]] for all 12 orbits.
Q-positivity NOT claimed.

**Verifier stance**: nothing trusted from Seed 3's scripts or pickle. System rows
transcribed BY HAND from proofs/prove-seed3-layer4.tex; my own raw-row implementation,
my own substitution engine, my own brute-force enumeration from the conjecture.tex
interlacing definition, plus the raw-validated reference engine
scripts/seed8_R2L3_engine.sage (Sage) as high-order cross-check.

Verifier scripts: scratch/scripts/verify3L4_system.py, verify3L4_ground.py,
verify3L4_seed8ref.sage (+ logs verify3L4_*.log).

## Paper-level checks (before any code)

1. **Raw Gb form**: confirmed against literature source
   (corteel_welsh_A2_RR/source.tex, Eq:INEX + Def:G => Gb):
   G_c(y) = Sum_{J nonempty subset I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|}),
   G_c(0,q)=G_c(y,0)=1. The (yq;q)_inf cancellation
   ((yq;q)_inf/(1-yq^{|J|}) = (yq;q)_{|J|-1}(yq^{|J|+1};q)_inf) checks out;
   c(J) rule in the tex matches CW and conjecture.tex verbatim.
2. **Contraction argument (tex Thm proof)**: [y^n] extraction formula re-derived by hand —
   correct. Level-n matrix entries (M_n)_{t,r} = Sum_s m_{r,s}[0,a] q^{a+sn}: since every
   shift s >= 1 and a >= 0, q-valuation >= n >= 1, so I-M_n invertible over Z[[q]] and
   (I-M_n)^{-1} = Sum M_n^k q-adically convergent. Argument is proved FOR THIS system
   (only uses s >= 1, which is checked row-by-row in (i)). Base case g(0)=1 imposed by
   G_c(0,q)=1 — consistent with raw system. SOUND (machine check of (i) below).
3. **Corollary logic**: nonneg induction (M_n, b_n nonneg from row positivity + lower
   levels; Sum M_n^k preserves nonneg; each q-coefficient a finite nonneg sum) — SOUND,
   CW Thm:G-style, with base case stated. Extension from 12 orbit reps to all 36
   profiles uses rotation invariance G_{rot c}=G_c, cited to prove-seed2-layer2 Lemma 1.
4. **Hand-replay of two zero rows** (Family A at Z2~(1,0,6) and Z4~(2,0,5)): raw rows
   computed by hand; head-cancellation gives EXACTLY the tex Z2 and Z4 rows. PASS.

## Machine checks

(incremental below)

### JOB 1 — System positivity + exact derivations (verify3L4_system.py) — PASS

Rows hand-transcribed from the tex (Lemmas 1, 2) into an independent exact
Z[y,q]-representation (no truncation anywhere in this job).

- **1a positivity**: all 12 rows: coefficients in N[y,q] (no negative monomial), all
  shifts >= 1, exactly one unit y^0 q^0 head per row (total y^0 part = 1). PASS.
- **1b zero rows**: my own raw-row implementation (conjecture.tex c(J) rule; orbit-level
  well-definedness ASSERTED via rotation-equivariance of the raw row) + my own exact
  substitution operator. Family A replayed mechanically ((7,0,0) base = raw row,
  then (a,0,b) descending): all 7 endpoints EXACTLY equal the tex Z-rows. Family B
  replayed too ((0,7,0) base; (a,b,0) substituting the Family-A row): also all equal —
  confirming the tex claim that A and B coincide orbit-level. PASS (exact identities).
- **1c core chains**: all FIVE chains replayed symbolically in Z[y,q] (not just the
  required two): C1 (depth 3), C3 (5), C4 (7), C2 (7), C5 (3, uses C2/C3/C4). Every
  endpoint EXACTLY equals the tex core row; derivation order acyclic as claimed
  (C1,C3,C4,C2 use only raw + Z rows; only C5 consumes earlier core rows). PASS.
- Chains are therefore PROVED identities conditional only on (a) CW Prop incex/Gb
  (literature, proof read and confirmed) and (b) rotation invariance of G
  (prove-seed2-layer2 lem:Finv, explicit bijection — checked it exists and proves it).
- Head graph of the tex Remark (C1->C2->C4->C5 self, C3->C5) matches the rows. Depths
  (3,5,7,7,3) as claimed.
- Pickle audit: seed3_R2L4_system_d7.pkl rows == my hand transcription of the tex,
  all 12; pickled PATHS == the tex chains. No artifact/paper divergence.

### JOB 2 — Uniqueness / contraction (paper + verify3L4_ground.py) — PASS

- Paper: the [y^n]-extraction and the valuation bound are correct FOR THIS system;
  the only row-specific inputs are shifts >= 1 and m in N[y,q]+unit head, which are
  machine-checked in 1a (the bound only needs s >= 1). I - M_n invertible over Z[[q]]
  for n >= 1 since all entries have q-valuation >= n >= 1. Base case g(0)=1 stated.
- Computation: solved the positive tex system ALONE by q-adic per-level iteration
  starting from a JUNK point (all coefficients 1 at every level) — converged, and the
  fixed point equals my independent raw-CW-system solution EXACTLY, all 12 orbits,
  n <= 8, to q^200. PASS.

### JOB 3 — Ground truth (verify3L4_ground.py + verify3L4_seed8ref.sage) — PASS

- **My own brute force** from the raw conjecture.tex interlacing definition (independent
  implementation: pair-compatibility tables over all 2714 partitions of size <= 20):
  bivariate F_c(y,q) exact to q^20; g_c(n) = sum_m eps_{n-m}[y^m]F. Equals the
  positive-system solution for ALL 12 orbits, ALL n <= 8, to q^20. PASS.
  (Exceeds the n<=6 brute-force target.)
- **Reference engine** (scripts/seed8_R2L3_engine.sage run under Sage, d=7, m<=8):
  gauss_a(H,c,n) == (q;q)_n * g_pos_c(n) with the IDENTITY label map, all 12 orbits,
  n <= 8, compared to q^200 (a_n exact polys; degrees up to 432, comparison window
  q^200 where deg >= 200 — full poly equality where deg < 200, i.e. n <= 5).
  Q_n(1) = 11^n exact for all orbits, n <= 8. No negative Q-coefficients observed
  (not part of the claim). PASS.

### JOB 4 — Convention / TRUE labels — PASS

- Brute force is the raw definition = TRUE labels by construction; the per-orbit match
  (Job 3) covers all four reversal-asymmetric orbit pairs at d=7:
  (Z2,Z3), (Z4,Z5), (Z6,Z7), (C2,C3).
- Power of the check confirmed: in the brute data g[Z2] != g[Z3], g[Z4] != g[Z5],
  g[Z6] != g[Z7], g[C2] != g[C3] (a reversed labeling WOULD have been detected).
- Reference-engine identity label map (target-first kernel, synthesis-layer3 §4(iv))
  confirms independently. Seed 3's Phase-1 claim "identity label map at d=7" is correct.
  No reversed/mixed-convention contamination found in this artifact.

### JOB 5 — Theorem scope — SOUND

- (1)+(2)+(3) => corollary chain is spelled out correctly, CW Thm:G style:
  level-n subsystem g(n) = M_n g(n) + b_n; M_n, b_n nonneg by row positivity +
  induction hypothesis; (I-M_n)^{-1} = sum M_n^k q-adically convergent and
  nonneg-preserving (each q-coefficient a finite sum of nonneg terms); base g(0)=1.
- Uniqueness gives = raw solution; raw solution = cylindric family by CW Prop incex
  (literature, proved; independently re-confirmed by my brute force).
- Extension from 12 orbit reps to all 36 profiles via rotation invariance: cited and
  valid. "G_c in N[[y,q]] for all profiles at d=7" FOLLOWS. Q-positivity correctly
  NOT claimed, and the final remark states the remaining gap accurately.

## Errata (cosmetic only — no mathematical impact)

1. **Tex, proof of Theorem 3**: "(M_n)_{t,r} = \sum_{s} m_{r,s}[0,a] q^{a+sn}" has a
   free index a; should read \sum_{s,a} m_{r,s}[0,a] q^{a+sn}. (The argument as used
   is the correct double sum.)
2. **Tex, abstract**: "the smallest level at which no positivity result of any kind was
   previously known" is accurate w.r.t. the literature (Warnaar's set {2,4,5}) but
   sits oddly next to the same sentence's acknowledgment that the Layer-2 Propagation
   Theorem already gave G-positivity for the zero-containing d=7 orbits; suggest
   "no positivity result of any kind in the literature".
3. **Scratch log** (prove-seed3-layer4.md, Phase 3): "Derivation DAG: zero rows ->
   {C1,C2,C3,C4} independently (raw+zero rows only) -> C5" — fine; tex Remark head
   graph and Lemma 2 order agree. No correction needed (recorded as checked).

## VERDICT: **SOLID**

All five jobs pass. The 12 rows are exact, machine-replayed consequences of the raw
CW system (both zero-row families and all five core chains verified symbolically in
Z[y,q], zero truncation); the system is manifestly positive; the contraction/uniqueness
argument is proved for this system and witnessed computationally from an independent
starting point; the unique solution equals my independent ground truth (raw-definition
brute force to q^20 all n<=8, reference Sage engine to q^200/exact polys n<=8) with
identity (TRUE) labels verified on all reversal-asymmetric orbits. The claimed theorem
G_c(y,q) in N[[y,q]] for all d=7 profiles follows as argued. Recommend GREEN.

Verifier artifacts: scratch/scripts/verify3L4_system.py (+ verify3L4_system.log),
verify3L4_ground.py (+ verify3L4_ground.log, verify3L4_ground_T20.log,
verify3L4_gpos.pkl), verify3L4_seed8ref.sage (+ verify3L4_seed8ref.log).
