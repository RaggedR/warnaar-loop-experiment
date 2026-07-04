# Independent verification: Seed 6, Layer 4 (N₂/Harnack route)

Verifier: independent auditor (did not write these proofs). Date: 2026-07-04.
Artifacts audited: proofs/prove-seed6-layer4.tex (6pp), scratch/prove-seed6-layer4.md,
scratch/scripts/seed6_R2L4_{engine,sweep,mono,mono2,mono_hi,r1,r1poly}.py (+logs).
My own code: scratch/scripts/audit6L4.py (written from the definitions in
synthesis-layer3.md §4(iv) + seed8_R2L3_engine.sage kernel orientation; NOT copied
from Seed 6's scripts).

## 0. Definition cross-check (setup)

- Ground truth taken as: H_{c,0} = 1; (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c,c')} H_{c',m−1},
  EMD(c,c') = 3max(0, c'₁−c₁, c₀−c'₀) + (c'₀−c₀) − (c'₁−c₁)  (target-first, §4(iv)).
  Confirmed identical (as a function) to seed8_R2L3_engine.sage's emd + kernel usage.
- Q₁ = H₁ − 1; Q₂ = D_{2,2} of the D-tower = H₂ − (1+q)H₁ + q (rederived myself from
  the h_m/D_{k,m} definitions in the seed8 engine header — matches Seed 6's engine).
- NOTE (minor): synthesis-layer3.md G10 writes har(c) with q^{2·EMD(c',c)}
  (source-first) while the Layer-4 tex uses q^{2·EMD(c,c')} (target-first).
  The engine test below decides which satisfies T2 in the true convention.

Findings appended incrementally below.

## 1. Independent recomputation (my code: audit6L4.py, audit6L4_r1.py)

All of the following ran clean (exact integer arithmetic throughout):

1. **Ground truth**: my own H-tower (dict-based polys, written from §4(iv)) at
   d ∈ {1,2,4,5,7,8,10,11,13,16}: T2 split N₂ = ball + har holds VERBATIM with the
   tex's target-first har (q^{2·EMD(c,c')}); ball ≥ 0; and my transcription of the
   local formula (eq. 1 of the tex) == har from the tower, all profiles, all j.
   (This also settles the G10-orientation note in §0: the tex orientation is the
   correct one for the target-first tower.)
2. **F1/sphere**: |S_e| = 3e and |u_i| ≤ e for e ≤ 59; Q1-cap ([q^k]Q₁ depends only
   on min(c_i,k)) on 300 random samples.
3. **CAP-SHARP numerically**: 200 random capped classes, coords up to 500, j ≤ 20:
   har_j(c) == har_j((min(c_i,j−1))_i) == har_j(random second representative). 0 fails.
4. **3|d counterexamples CONFIRMED**: har₁₃((1,1,1)) = −1, har₁₅((0,1,2)) = −1
   (my local-formula implementation; these are the pure-lattice extension, as the
   Remark correctly says).
5. **R0**: closed forms == defining sum for j ≤ 400 and ≥ 0 for j ≠ 2; free-lattice
   count u_k = k+1 for k ≤ 500; har_j(c) == har^∞_j at the boundary case
   min c_i = j−1 (j ≤ 25) via my engine.
6. **Low band (Thm 4.1)**: my own sweep (own har implementation, own box
   enumeration) at j ∈ {2, 4, 13, 20, 33, 47, 48}, full box c_i ≤ j+1, 3∤d:
   ALL PASS; rep counts match Seed 6's log exactly (e.g. 83334 at j=48); min margin
   0 at (0,0,1); har₂ = −(b₁−1) exact; S2@4 min margin 0. Seed 6's own log shows
   every level j ≤ 48 pass.
7. **HM**: independently re-verified with my own stepper for ALL j ≤ 30
   (box c_i ≤ j+2, M1/M2 residue-respecting steps): 0 failures; step counts match
   Seed 6's mono_hi log (98307 @ j=29, 107811 @ j=30).
8. **R1 ingredients (Lemma 7.1)**: μ_e(v) and the tail count for e ≤ 120 (all β),
   x(m) = ⌊(m+1)²/4⌋ for m ≤ 2000, w_k(β) closed form vs my raw Q₁ count for
   k ≤ 40 all β. All exact.
9. **Prop 7.2 (φ formula)**: my direct transcription of the tex double sum ==
   har_j((big,big,a)) via my engine for j ≤ 40, all 0 ≤ a ≤ j−2 (Seed 6 verified
   j ≤ 33).
10. **R1 head**: min_a φ_j over the stated domain 0 ≤ a ≤ j−2 matches ALL claimed
    values j = 0,1,3,5..22 exactly (3,4,12,17,...,504). See erratum E2 for j=2.
11. **R1 tail (direct, structure-free)**: φ_j(a) > 0 for ALL a, for all
    23 ≤ j ≤ 199 and sampled j (step 7) to 650; the slop bound
    |φ − j³ψ(a/j)| ≤ (5/8)j²+7j+4 holds pointwise on a ≤ j−4 at all those points
    (worst ratio 0.577 at (j,a)=(641,631)); strips a = j−2, j−3 positive for
    10 ≤ j ≤ 800. Threshold arithmetic: j³/24 > (5/8)j²+7j+4 iff j ≥ 23 CONFIRMED.
12. **One-command certificate**: `python3 seed6_R2L4_r1poly.py pipeline` runs clean
    in 5.8 s: 288 chamber polys + 24 strip polys fitted (exact Fractions), cubic
    parts == j³ψ(a/j), LOW==HIGH for odd j, 30,655 exact verification points with
    0 mismatches, K₂=5/8 K₁=7 K₀=4, J₁=23, head check pass.

## 2. Logic audit (line-by-line)

### Thm 2.1 (CAP-SHARP) — SOLID
The proof is complete and rigorous; it does NOT lean on the empirical M_j = j.
Chain: (F1) |u_i| ≤ e on S_e (provable by edge parametrization, given in the
scratch notes; machine-checked by me e ≤ 59, and needed only for e ≤ ⌊(j−1)/2⌋ —
for a fixed j finitely checkable, but the edge parametrization proves all e).
(F2) b_e probes only min(c_i,e), and A_k aggregates e ≤ k, so [q^k]Q₁ depends only
on (min(c_i,k))_i — rigorous. The three-case bookkeeping over eq. (1) is correct;
I re-derived every inequality: validity thresholds ≤ e ≤ (j−1)/2 ≤ j−1;
neighbor caps (c+u)_i ≥ j−1−e ≥ j−2e = k uses only e ≥ 1; self thresholds
j−i ≤ j−1. Dependence of eq. (1) itself on T1/T2 (Layer-3 G10) + the elementary
[q^k]Q₁ = A_k − A_{k−1} − [k=0] (immediate from the m=1 recursion
(1+q+q²)H₁ = B_c): both re-verified by my engine.

### Cor 2.2 (realization / finite decidability) — SOLID
If some coordinate ≥ j−1, choosing it in {j−1,j,j+1} spans all residues of d
mod 3, so some representative in the box has 3∤d; if all c_i ≤ j−2 the profile IS
its representative and already has 3∤d. Since har_j depends on c only through the
caps (no other d-dependence), checking the box {c_i ≤ j+1, 3∤d} covers every
(c,d) with gcd(d,3)=1. Airtight. (Checking extra classes not realizable at 3∤d
only strengthens.) Answer to Job 4: YES, the finite box really covers all d and
all profiles at fixed j.

### Thm 3.1 (R0) — SOLID
Constraint-inactivity: c_i ≥ j−1 ≥ E ≥ e kills validity constraints, and
(c+u)_i ≥ j−1−e ≥ j−2e = k makes every neighbor count free; self terms
c_i ≥ j−1 ≥ j−i. The free count u_k = k+1 (3-case on k mod 3; I verified the
even/odd/0 cases algebraically and k ≤ 500 numerically). Closed forms are
elementary summation (re-verified j ≤ 400). Positivity for j ≠ 2 checked; note
har^∞₄ = 0, so S2@4 in R0 needs b₂ ≥ 1 (true, G10 b₂ ≥ 2) — fine.

### Thm 4.1 (low band j ≤ 48) — SOLID (computational theorem)
Mechanism airtight by Thm 2.1 + Cor 2.2. Log complete to j = 48; I re-swept 7
levels including 47, 48 with independent code (identical counts, all pass).
The N₂-consequence additionally uses ball ≥ 0 (Layer-3 GREEN; re-verified by my
engine d ≤ 16) plus har₂ = −(b₁−1) at j=2 and S2 at j=4 — both in the sweep.

### "S2 fully proved" — CORRECT AS STATED
S2 concerns only j = 4 ≤ 48. b₂ probes thresholds ≤ 2 ≤ j−1 = 3, so both sides
are cap-determined and the j=4 sweep decides S2 for ALL d with 3∤d. My j=4 sweep
confirms (min margin 0).

### Thm 6.3 (HM ⟹ S1) + Prop 6.2 (base) — SOLID (the reduction; HM itself remains a conjecture)
Base case d=1: B_c = 1+q+q² computed directly (I confirmed), H₁ = 1, Q₁ = 0,
har ≡ 0. Walk: from any c with 3∤d, remove 1 box at d ≡ 2, 2 boxes at d ≡ 1
(d ≥ 4); every intermediate d avoids 3ℤ; boxes always removable (d ≥ 1). Reversed
walk uses exactly M1 at d ≡ 1 and M2 at d ≡ 2 (M2's i ≤ k covers both same- and
different-coordinate additions). Correct. Finite decidability of HM@j: needs a
representative matching BOTH caps and d mod 3 — available (free coordinate spans
residues), and steps in coordinates above the cap leave har unchanged (tight) by
Thm 2.1. Correct. HM@j complete verification j ≤ 30: reproduced independently,
0 failures. The tex is honest that HM for j ≥ 31 is open; Thm 6.3 is conditional.

### Thm 7.5 (R1) chain — SOLID-WITH-ERRATA
- Lemma 7.1(1),(2): stated for all e but only machine-verified (finite e). They
  are easily provable from the explicit edge parametrization of S_e (as in the
  scratch notes for F1); the tex omits the proof. MINOR GAP (E3), repairable in
  two lines. (3) has a genuine proof (shift identity + 6 base cases — arithmetic
  checked). (4) follows from (2)+(3).
- Prop 7.2: the decomposition φ = har^∞ − C1 − C2 + C3 is forced by the CAP-SHARP
  bookkeeping (each valid neighbor is effectively (∞,∞,a−v); each invalid one
  loses its full free count j−2e+1; self terms give C3). I re-derived it and
  re-verified numerically to j ≤ 40, all a. Sound given Lemma 7.1.
- Lemma 7.3 (chamber structure): **the weak point of the paper**. Degree ≤ 3 and
  period 12 are genuinely provable "by counting" as claimed. But the wall
  enumeration is partly EMPIRICAL by the tex's own admission ("empirically
  confirmed below"), and the safety-net claim that the pinning verification
  "covers all lines parallel to the three boundary directions" is literally false
  (slivers cover offsets |t| ≤ 30 only; the dense band pins any wall entering
  j < 150). What makes this nearly airtight anyway: (i) all switch loci in the
  explicit φ formula are lines with O(1) offsets (e = a vs e-range endpoints →
  2a−j = O(1) and a = O(1); the max(−e,1−n_e) switch → j−a = O(1) and
  4a−j = O(1); C3 → a = j−n, n ≤ 5), so offsets ≤ 30 is generous — but this
  enumeration is NOT carried out in the tex; (ii) notably, the 4a = j + O(1)
  candidate wall IS acknowledged in seed6_R2L4_r1poly.py's own docstring but is
  MISSING from the tex's Lemma 7.3 statement/proof (E4). It is implicitly refuted
  by the fit-consistency (overdetermined exact solves straddling 4a=j) and the
  dense band, but the tex text as written asserts a wall list its own script
  contradicts.
- Thm 7.4: exact rational interpolation + 30,655-point verification, rerun by me,
  0 mismatches; conditional on Lemma 7.3 this upgrades to a theorem — the
  conditional logic (a degree-≤3 polynomial on a residue class of a 2D chamber is
  pinned by the verified points) is sound.
- Thm 7.5 proof: tail arithmetic correct (threshold 23 re-derived); ψ' = (μ−1)²/4
  and ψ(0) = 1/24 correct; head check independently confirmed. My structure-free
  direct computation confirms φ > 0 for all 23 ≤ j ≤ 199 (every a) and sampled j
  to 650 — so any residual doubt about Lemma 7.3 affects only j > 650 through the
  quasi-polynomial extrapolation.

## 3. Errata

- **E1 (nano, tex §7 proof of Thm 7.5)**: "The strip cubics are positive for
  j ≥ 10 (same comparison)". With the stated global slop constants the comparison
  j³/8 > (5/8)j²+7j+4 gives j ≥ 11, not 10. (Strips are in fact positive from
  j = 10 — directly verified — and the head check covers j ≤ 22, so no
  consequence. The pipeline uses strip-specific slops; wording only.)
- **E2 (nano, tex §7 head check parenthetical)**: "min_a φ₂ = −2". Over the
  stated domain 0 ≤ a ≤ j−2 (= {0}), min = φ₂(0) = −1; the value −2 is φ₂(1) =
  har^∞₂, i.e. a = j−1, which belongs to R0. (φ₄ min = −1 is correct.) Excluded
  exponents anyway; no consequence.
- **E3 (minor, Lemma 7.1(1),(2))**: stated for all e, proof label is
  "machine-verified" (finite). Two-line proofs from the edge parametrization
  should be added for full rigor.
- **E4 (main erratum, Lemma 7.3)**: the wall enumeration ("only chamber wall is
  2a = j plus strips a = j−2, j−3") is observed, not proved: (a) the candidate
  direction 4a = j + O(1) appearing in the script's own structure comment is
  omitted from the tex; (b) no offset bound for candidate walls is proved, so the
  claim that the sliver verification "covers all lines parallel to the three
  boundary directions" is not justified as stated. Repair path (clear): enumerate
  the finitely many switch loci of the explicit C1/C2/C3 sums, show all offsets
  ≤ 6, then the existing dense band + slivers pin everything. Until then, Thm 7.4
  and hence Thm 7.5 for j > (verified range) carry this one under-justified step.
- **E5 (context, not this artifact)**: synthesis-layer3.md's G10 line writes
  har with q^{2·EMD(c',c)}; in the true target-first convention it must be
  q^{2·EMD(c,c')} (the tex has it right; my engine confirms T2 only holds with
  the tex's orientation). The synthesis line should be flagged as old-orientation.

## 4. Verdicts

| Claim | Verdict |
|---|---|
| Thm 2.1 CAP-SHARP + Cor 2.2 (realization) | **SOLID** |
| Thm 3.1 R0 deep interior (+ closed forms) | **SOLID** |
| Thm 4.1 low band j ≤ 48 (+ [q^j]N₂ ≥ 0) | **SOLID** (computational; mechanism airtight) |
| "S2 fully proved unconditionally" | **SOLID** (follows as stated) |
| Thm 6.3 HM ⟹ S1 + base + finite decidability; HM verified j ≤ 30 | **SOLID** (HM j ≥ 31 correctly labeled open) |
| Thm 7.5 R1 main (via Lem 7.1, Prop 7.2, Lem 7.3, Thm 7.4) | **SOLID-WITH-ERRATA** (E1–E4; the one real gap is Lemma 7.3's wall enumeration/offset bound — repairable, and empirically bulletproof to j ~ 650 by my structure-free check) |
| 3|d counterexample har₁₃((1,1,1)) = −1 | **CONFIRMED** |

Overall: the Layer-4 artifact is in excellent shape. Nothing false found. One
proof (R1's structure lemma) needs its acknowledged empirical step replaced by
the (routine) switch-locus enumeration before R1 can be called fully rigorous
for all j.

My audit code: scratch/scripts/audit6L4.py (base + sweep + hm subcommands),
scratch/scripts/audit6L4_r1.py.
