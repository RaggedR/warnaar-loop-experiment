# Layer 4 Synthesis — Round 2 (2026-07-04)

Input for the next layer/round. Synthesizes 8 Layer-4 seeds + 4 independent verifier
reports (Seeds 1, 2, 3, 6) + the Seed-6 errata-repair pass + Seed 7's label audit.
Layer 4 was the DIVERSIFICATION layer (two literature-composition seeds, one
construction seed, three structure seeds, one verifier, one post-hoc adversary), run
from synthesis-layer3.md §6 Missions 1–8. Five step changes:

1. **d=10 balanced orbit (4,3,3) is a THEOREM** — the first proved case of Warnaar's
   Conjecture Con_cylindric-b with k ≥ 3 (k=4, modulus 13), via a 3-link chain that
   needed NO Kanade–Russell bridge relation (Seed 1; verifier SOLID; adversary
   independently reconfirmed to n=15). Files: proofs/prove-seed1-layer4.tex,
   scratch/verify-seed1-layer4.md.
2. **The ENTIRE d=8 core has an explicit two-term fermionic representation**
   G_c = Ferm_{c₂+1,c₃+1} − q·Ferm_{c₂,c₃} for the seven listed representatives —
   including (4,2,2), unreachable by any R-relation (Seed 2; verifier
   SOLID-WITH-ERRATA, errata applied). Warnaar positivity at d=8 is now SIX explicit
   finite two-term inequalities. Positivity itself remains OPEN (three genuine strikes,
   certificates verified). Files: proofs/prove-seed2-layer4.tex,
   scratch/verify-seed2-layer4.md.
3. **d=7 — the smallest level unproved anywhere — has its first positivity theorem**:
   a complete CW-style positive y-system (12 rows, exact substitution chains), hence
   G_c(y,q) ∈ ℕ[[y,q]] for ALL d=7 profiles (Seed 3; verifier SOLID). Template B works
   in fully novel territory. Q-positivity at d=7 not claimed. Files:
   proofs/prove-seed3-layer4.tex, scratch/verify-seed3-layer4.md.
4. **The N₂/Harnack route matured into a theorem factory** (Seed 6): rigorous sharp cap
   M_j = j−1; [q^j]N₂ ≥ 0 unconditional for j ≤ 48 (all d, gcd(d,3)=1); S2 fully
   proved; R1 (two large coordinates) proved for ALL j after the wall-enumeration
   repair; HM ⟹ S1 reduction with HM verified j ≤ 40. AND a boundary discovery:
   **S1 is FALSE at 3|d** — the gcd(d,3)=1 hypothesis is essential. Files:
   proofs/prove-seed6-layer4.tex (post-repair), scratch/verify-seed6-layer4.md,
   scratch/repair-seed6-layer4.md.
5. **Two things died honestly**: Y8/Conjecture A is FALSIFIED for d ≥ 5 (Seed 7 —
   nonneg (U−I) rows occur EXACTLY at balanced targets; §4(viii) of synthesis-layer3
   is retracted below), and the Newman/local-confluence route to Tingley gap 2b is
   provably dead (Seed 4 — unbounded meet depths).

**Standing notation**: unchanged from synthesis-layer3.md (target-first H-recursion,
TRUE conjecture.tex labels — §4(iv) is carried forward VERBATIM in §4 below), with one
ERRATUM (per Seed-6 verifier E5, = BA37): synthesis-layer3's G10 wrote
har(c) = Σ_{c'≠c} q^{2·EMD(c',c)} Q₁(c') − q(1+q+q²+q³+q⁴) Q₁(c) in the STALE
source-first orientation. The correct target-first statement is
  **har(c) = Σ_{c'≠c} q^{2·EMD(c,c')} Q₁(c') − q(1+q+q²+q³+q⁴) Q₁(c)**,
and N₂(c) = [B_c(q²) − 1 − q² − q⁴] + har(c) with B_c(q) = Σ_{c'} q^{EMD(c,c')}.
Machine-decided: T2 holds ONLY with this orientation on the target-first tower
(scratch/verify-seed6-layer4.md §0–1; scratch/scripts/audit6L4.py).

Formal writeups this layer: proofs/prove-seed{1,2,3,4,6}-layer4.tex (all compiled;
seed2 includes the post-verifier errata, seed6 includes the Lemma 7.3 repair).
Seeds 5, 7, 8 report via scratch logs only. Lean: lean/WarnaarGlue/TheoremD.lean
(sorry-free), pushed to the public mirror.

Item numbering continues synthesis-layer3: GREEN G13+, YELLOW Y11+, dead D12+,
bulletin BA36+.

---

## 1. Headline results

### GREEN — proved, referee-checkable

**G13. THEOREM (d=10, orbit (4,3,3) — first case of Warnaar's Con_cylindric-b at
k ≥ 3).** (Seed 1; verifier SOLID; adversary reconfirmed.) At k=4, modulus 3k+1 = 13:
G_{(4,3,3)} = FERM⁺₃, hence Q_{n,(4,3,3)} = Σ q^{n²+n₂²+n₃²−nm₁−n₂m₂−n₃m₃+m₁²+m₂²+m₃²}
[n,n₂][n−n₂+m₂,m₁][n₂,n₃][n₂−n₃+m₃,m₂][2n₃,m₃] ≥ 0 for all n — manifestly positive
quintuple sum. Proof = 3-link chain, every link proved:
(1) Warnaar Prop_finiteform a=+1, k=3 (source.tex 2672–2687, proof 2784–2819);
(2) coefficientwise limit n₀,m₀→∞; (3) Pochhammer split
1/(q)_{r₃+s₃} = (1−q^{r₃+s₃+1})/(q)_{r₃+s₃+1} landing VERBATIM on Uncu's proved
H_{(4,3,3)} = S₁₃(e₃|e₃) − q S₁₃(e₂|e₂) (thm:m13). **No KR contiguous relation
needed** — the m ≡ 1 mod 3 R₃-typo caution was moot. Pedigree: verifier rebuilt an
independent raw-CW engine (NOT the H/EMD kernel), exact match n ≤ 12 in ℤ[q]
(deg Q₁₂ = 1296), all links machine-guarded ([FF'],[A'],[S'],[D'], Q_n(1) = 21ⁿ);
adversary's own FERM3p transcription matched the engine to n=15. Chirality-safe
(rev(4,3,3) is a cyclic shift). Provenance caveat N1: Uncu's thm:m13 is a
computer-assisted proof (ideal-membership certificates) — external write-ups inherit
that dependency. Files: proofs/prove-seed1-layer4.tex, scratch/prove-seed1-layer4.md,
scratch/verify-seed1-layer4.md, scratch/scripts/seed1_R2L4_d10_chain.sage.
**Scaling law (structural remark, prove-seed1-layer4.tex "R₃ typo" remark):** at
moduli m = 3k+1 the a=+1 split lands directly on the KR pair (no bridge); at
m = 3k−1 (the d=8 case) one R₃ bridge is needed. Bridge relations are only needed at
moduli ≡ −1 mod 3.

**G14. THEOREM (two-term fermionic representation of the ENTIRE d=8 core).** (Seed 2;
verifier SOLID-WITH-ERRATA, errata E1/E2 applied in the tex; adversary reconfirmed
with an independent transcription.) For each of the SEVEN listed d=8 representatives
c ∈ {(6,1,1),(5,2,1),(5,1,2),(4,3,1),(4,1,3),(4,2,2),(3,3,2)}:
   G_c = Ferm_{c₂+1,c₃+1} − q·Ferm_{c₂,c₃},   Q_{n,c} = ferm_{c₂+1,c₃+1}(n) − q·ferm_{c₂,c₃}(n),
where Ferm_{s,t} are the manifestly positive fermionic 5-fold sums from Warnaar's
Prop_finiteform2 (Eq_mineen / Eq_mineen2, k=3, a=−1) in the limit n₀,m₀→∞ — the
denominator (q)_{n_k+m_k+1} of Eq_F2 matches S₁₁'s (q)_{r₃+s₃+1} VERBATIM, so the
limits ARE Uncu's S₁₁(e_{s−1}|e_{t−1}) with no relation, no merge, no word search.
This includes (4,2,2), which appears in NO R-relation. **Scope restriction (E1, =
BA39): the theorem holds for the seven listed cyclic representatives ONLY** —
(2,3,3) hits undefined (s,t) = (4,4) and (1,6,1) hits undefined Ferm_{7,2}; cyclic
normalization suffices to cover every d=8 profile with c₂,c₃ ≥ 1 at the G-level.
Pedigree: verifier read Eq_F2/Prop_finiteform2 and all seven eq:mod11list rows at
source, checked all 13 used (s,t) admissible, built an independent raw-CW engine —
exact ℤ[q] match all 7 orbits n ≤ 12, chirality machine-pinned (Q₃(5,2,1) ≠
Q₃(5,1,2)); adversary pushed the differences clean to n = 32 (deg 7200).
**Positivity of the six differences is NOT part of the theorem** (Y11; three strikes,
D15). Files: proofs/prove-seed2-layer4.tex, scratch/prove-seed2-layer4.md,
scratch/verify-seed2-layer4.md.

**G15. THEOREM (d=7 positive y-system — first positivity at the smallest unproved
level).** (Seed 3; verifier SOLID; adversary replayed + recomputed independently.)
There is a complete CW-style manifestly positive functional system at d=7 (mod 10):
7 zero-orbit R-rows (Families A/B coincide orbit-level) + 5 core rows, each an EXACT
substitution chain from CW Prop incex instances (depths 3,5,7,7,3; chains hardcoded in
scripts/seed3_R2L4_system.py PATHS). All rows have coefficients in ℕ[y,q], shifts ≥ 1,
unique unit y⁰ head; uniqueness by q-adic contraction (level-n matrix entries have
q-valuation ≥ n); the unique solution equals the raw conjecture.tex family.
COROLLARY: **G_c(y,q) ∈ ℕ[[y,q]] for ALL profiles at d=7** — bivariate G-positivity,
closing the d=7 core gap of the Propagation Theorem. New MECHANISM (beyond CW's d=4
depth-2): telescope raw rows down a chain of singles to zero orbits, then close with
the zero-orbit R-rows. Pedigree: verifier hand-transcribed all rows from the tex,
replayed all five chains symbolically in ℤ[y,q] (zero truncation), solved the positive
system from a junk starting point, and matched an independent brute-force enumeration
of the raw interlacing definition (q^20, all n ≤ 8) — TRUE labels confirmed on all
four reversal-asymmetric orbit pairs. Q-positivity at d=7 NOT claimed (Y19). Files:
proofs/prove-seed3-layer4.tex, scratch/prove-seed3-layer4.md,
scratch/verify-seed3-layer4.md.

**G16. THEOREM (Bounded Tingley — Step 1 complete, uniform d ≥ 2).** (Seed 4.)
The bounded mod-d crystal operators f_κ/e_κ on X_m are well-defined partial maps,
weight ±1, with e_κf_κ = id and f_κe_κ = id — injective partial bijections — for ALL
d ≥ 2 (including d=2 and 3|d), all profiles, all m. Proof is self-contained: Lemma 0
(no T-ties), Lemma L (locality: one box flip changes only colors k, k±1, and W_k by a
single letter), Lemma V (S-violating choices are never leftmost/rightmost surviving —
witness box at T∓d), signature-flip lemma. **Tingley's n ≥ 3 hypothesis and his §4.2
erratum are never invoked** — resolves adjudication (vi) of synthesis-layer3.
Also proved: nonadjacent commutation e_κe_λ = e_λe_κ (|κ−λ| ≥ 2 mod d), shield
acyclicity, Σ_κ(φ_κ−ε_κ) = 3 − #{i : a_i^(m) > 0}. Machine sweeps: 26371 chains,
146784 ops, 0 failures, d ≤ 9 (adversary extended to d ≤ 12 incl. corners). Files:
proofs/prove-seed4-layer4.tex, scratch/prove-seed4-layer4.md.

**G17. THEOREM (2a-i: v-chains are sources; source GF).** (Seed 4.) With window
vectors v_{k,i} = Σ_{t<k} c_{(i−t) mod 3}: every v-chain (v_{k₁},…,v_{k_{m−1}},0),
k₁ ≥ … ≥ k_{m−1} ≥ 0, is a source (ε_κ = 0 ∀κ). Proof: per-boundary matching calculus
(P1)–(P4) + cases (M1) δ ≥ 3, (M2) 3|δ, (M3) δ ∈ {1,2} closed by a finite case check
that is provably exhaustive (all c with d ≤ 12 + generic-value profiles per zero
pattern; 25272 cases, 0 failures). Corollary: source GF ≥ Π_{j=1}^{m−1} 1/(1−q^{jd}) —
Y2's source combinatorics realized. The two remaining Tingley gaps are now PRECISE:
2a-ii (completeness: every source is a v-chain — m=1 proved exhaustively d ≤ 10,
acyclicity backbone proved) and 2b (unique source per component — global confluence
verified exhaustively, Newman provably dead, D13). Adversary: no counterexample to
either gap at W ≤ 14, d ≤ 12. Files: proofs/prove-seed4-layer4.tex §§2a,
scratch/prove-seed4-layer4.md [t2]–[t4].

**G18. The N₂/Harnack theorem package (Seed 6; verifier verdicts per-theorem in
scratch/verify-seed6-layer4.md §4; Lemma 7.3 gap REPAIRED —
scratch/repair-seed6-layer4.md; all statements in the CORRECT target-first har
orientation, see standing-notation erratum):**
- **CAP-SHARP (Thm 2.1, SOLID)**: har_j(c) depends on c only through (min(c_i, j−1))_i
  — improves G10's cap M=2j and the empirical M=j. Realization (Cor 2.2, SOLID):
  checking the finite box {c_i ≤ j+1, 3∤d} decides S1@j/S2@j for ALL d at once.
- **R0 deep interior (Thm 3.1, SOLID)**: min_i c_i ≥ j−1 ⟹ har_j(c) = har_j^∞ with
  explicit closed forms; ≥ 0 for j ≠ 2 (j=2 gives −2, absorbed by the ball term).
- **Low band (Thm 4.1, SOLID)**: [q^j]N₂ ≥ 0 UNCONDITIONALLY for ALL profiles, ALL
  gcd(d,3)=1, j ≤ 48 (was j ≤ 5). Min margin 0 at c=(0,0,1) at every level.
- **S2 FULLY PROVED unconditionally** (b₂ and har₄ cap-determined; sweep covers all
  capped classes). Verifier: CORRECT AS STATED.
- **HM ⟹ S1 (Thm 6.3, SOLID)**: Harnack Monotonicity (residue-respecting one/two-box
  steps at d ≡ 1/2 mod 3, j ∉ {2,4}) implies S1 for all j, all c, gcd(d,3)=1, by
  walking down to the proved d=1 base (har ≡ 0). HM@j finitely decidable per j;
  verified complete for j ≤ 30 (Seed 6) + j ≤ 40 (adversary extension, 238518 steps
  at j=40, 0 failures).
- **R1 chamber theorem (Thm 7.5) — NOW UNCONDITIONAL**: har_j(c) ≥ 0 (> 0 for j ≥ 5)
  for all j ∉ {2,4} whenever at least two coordinates ≥ j−1 (any third coordinate, ANY
  d). The verifier's one real gap (E4: empirical wall enumeration in Lemma 7.3) was
  closed in the repair pass by exact switch-locus enumeration (walls: 2a=j+t |t|≤2,
  4a=j+t |t|≤2, a≤2, a=j−t 2≤t≤6; **4a=j is a genuine candidate wall and carries NO
  polynomial jump** — full-rank sub-chamber pinning, 178k+ points, 0 mismatches).
  PDF rebuilt, 8pp, 0 errors.
- **S1 is FALSE at 3|d** (see BA38): har₁₃((1,1,1)) = −1, har₁₅((0,1,2)) = −1
  (verifier-confirmed independently). Scope S1 to gcd(d,3)=1 everywhere; the
  hypothesis is essential and any proof must use it — HM's naive form fails exactly
  on steps touching 3|d, which is why HM "knows" where the hypothesis enters.
Remaining open: HM j ≥ 41; S1 on {j ≥ 49 AND ≥ two coords < j−1}; level-n lift (Y4).
Files: proofs/prove-seed6-layer4.tex, scratch/prove-seed6-layer4.md,
scratch/verify-seed6-layer4.md, scratch/repair-seed6-layer4.md.

**G19. Seed-5 β-map package (proved parts).** (Seed 5.) The SHARP-F0 inequality is
EXACTLY the three-term stratum injection inside the single connected crystal vac(X_m)
(RESULT 3, exact given H3'/Y13): #U(w) ≥ #U(w−m) + #Y(w−1) + #Z'(w−1−(m−1)d), where
U/Y/Z' = {max = m}/{max = m−1}/{max ≤ m−2}. PROVED: the set-level β-map
A ↦ A + e_i at level m is injective (unique bottom-level box) and always has an
S-valid choice (two-line lemma: a ∈ S, a ≠ 0 ⟹ ∃i with c_i ≥ 1, a_i ≥ 1). Hence,
MODULO the single lemma Q1 (vacuum closure, Y12): s_m ≥ q·w_{m−1} — the Y-term of
SHARP-F0 realized by an explicit injection. Proof architecture for Q1 written down
(Seed 4's Lemma L is the designated tool). Files: scratch/prove-seed5-layer4.md
RESULT 5 + LEMMA TARGET Q1.

**G20. Lean phase 3a: TheoremD.lean.** (Seed 7.) New module lean/WarnaarGlue/
TheoremD.lean, sorry-free, axioms [propext, Classical.choice, Quot.sound] only,
pushed to the public mirror (github.com/RaggedR/warnaar-glue). Machine-checked at
abstract (A,q): D-tower kernel identities (hm_eq, Dtower_eq, delta_eq, diagonal
recovery Q_n = D_n^n given Corollary I), ferm-monotonicity via CoeffNonneg
(Q-positivity ⟹ h_m ≥ 0, H-monotonicity, all D-tower rows ≥ 0 — the §4(ix)
reduction machine-checked), Lemma E in cleared-denominator form.
File: scratch/prove-seed7-layer4.md [T3].

**G21. Label audit complete (housekeeping GREEN).** (Seed 7;
scratch/label-audit-layer4.md.) Machine fingerprints over ALL Layer-≤2 artifacts +
Seed 3/4 L3: no new claim flips beyond §4(iv); two new precise corrections (Seed 3
L3's (1,1,2) U−I row is reversed — TRUE row [x³,x²,x,x,0]; Seed 3 L2's d=5 unmatched
list in TRUE labels is {(0,2,3),(0,3,2),(0,1,4)}). IMPORTANT REFINEMENT of §4(iv).6
(= BA42): Seed 3 L3 is MIXED, not uniformly reversed — its chain-model results (D3
ILP certificates, D4, Y5 HALL-RIBBON, Y7) are ALREADY in TRUE labels; only its
Scripts 1–4 (EMD-kernel) are reversed. Seed 4 L3 used a reversed engine but has ZERO
chirality-sensitive per-orbit claims — SAFE. Seed 5 L2's (4,3,1) formula does NOT flip.
Files: scratch/label-audit-layer4.md, scratch/prove-seed7-layer4.md.

### YELLOW — strong evidence, no proof

**Y11. The six d=8 core difference inequalities.** ferm_{c₂+1,c₃+1}(n) ≥ q·ferm_{c₂,c₃}(n)
coefficientwise, for the six non-(3,3,2) core representatives. By G14 this IS Warnaar
positivity at the d=8 core. Evidence: adversary-clean to n = 32 (deg 7200, all 7 orbits,
196 cells; min-in-hull = 0 — structural zeros near top degree, not a shrinking margin;
scratch/prove-seed8-layer4.md FINAL RESULTS). Structure known: L4.3/L4.4 absorption
skeleton — the subtrahend embeds summand-by-summand with penalty exponent
1 + n_{c₂} + m₁, and for (6,1,1) the wall shape Q_n = (1−q^{n+1})A_n + B_n with A_n, B_n
manifestly positive (scratch/prove-seed2-layer4.md). Difficulty ordering
(6,1,1) > (5,2,1) > (4,3,1); three failed attack routes with certificates (D15).

**Y12. Lemma Q1 (vacuum closure).** If A ∈ vac(X_m) and β(A) = A + e_i is the β-map
choice, then A + e_i ∈ vac(X_{m}) (stays in the vacuum component). The ONLY gap between
G19 and the Y-term s_m ≥ q·w_{m−1} of SHARP-F0. Verified: Seed 5's 30/30 Hall cases +
adversary's 14 more at d ∈ {10,11,13} incl. corners, m ≤ 5, W ≤ 14 (Q1 and Q2 ALL HOLD;
scratch/prove-seed8-layer4.md [A/Seed5]). Designated tool: Seed 4's Lemma L (locality).

**Y13. H1/H3′ stratification hypotheses** for SHARP-F0 (bottom-level box uniqueness /
stratum decomposition exactness): machine-true in all tested cases; the three-term
inequality (G19 RESULT 3) is exact GIVEN these. File: scratch/prove-seed5-layer4.md.

**Y14. HALL-VACUUM.** Hall's condition holds for the full vacuum-component bipartite
matching at every tested (d,m,W): Seed 5's 30/30 + adversary's extension (F5 fence:
set-level, not multiset-level). File: scratch/prove-seed5-layer4.md RESULT 4/5a.

**Y15. Tingley gap 2a-ii (source completeness).** Every source is a v-chain. Proved for
m=1 (exhaustive d ≤ 10) + acyclicity backbone; adversary hunt found ZERO non-v-chain
sources at W ≤ 14, d ≤ 12 (every source in every case was a v-chain,
scratch/prove-seed8-layer4.md [B4]). Open for m ≥ 2.

**Y16. Tingley gap 2b (unique source per component / global confluence).** Verified
exhaustively (26371 chains Seed 4; singleton reachable-source everywhere at W ≤ 14
adversary). Newman/local-confluence route provably DEAD (D13) — a new global argument
is required. File: scratch/prove-seed4-layer4.md.

**Y17. HM (Harnack Monotonicity).** Residue-respecting one/two-box monotonicity of
har_j, d ≡ 1/2 mod 3, j ∉ {2,4}. Verified COMPLETE (finite cap box) for j ≤ 40
(238518 steps at j=40, 0 failures; scratch/prove-seed8-layer4.md [B5]). HM ⟹ S1 (G18).
Naive HM fails precisely on steps into 3|d — the proof must consume gcd(d,3)=1.

**Y18. Raw residue-respecting monotonicity of [q^j]Q_{n,c} at level n ≥ 3.** NEW
(adversary probe, scratch/prove-seed8-layer4.md [B5] nprobe): for d ∈ {4,…,16},
j ≤ 60, 137250 comparisons/level: n=3 and n=4 have ZERO failures WITHOUT any
har-style correction, while n=2 fails 114 times (all at even j ≥ 16). **n=2 is the
uniquely hard level** (BA41); the level-n lift of the Harnack route may be EASIER
than the n=2 case it was modeled on.

**Y19. d=7 Q-positivity.** G15 gives G_c(y,q) ∈ ℕ[[y,q]]; Q_{n,c} = (q)_n[y^n]G_c ≥ 0
is NOT claimed — the (q)_n multiplication needs absorption lemmas / bounded forms
(the d=4 Template-B endgame). Verified: d=7 full MASTER grid clean to m ≤ 32
(adversary), Gauss a_n ≥ 0 to n ≤ 18 (layer 3). This is Mission 1 below.

---

## 2. Per-seed digests (with verification pedigree)

**Seed 1 (Template A, d=10 balanced) — GREEN.** 3-link chain to Uncu thm:m13, no KR
bridge (moot R₃-typo caution), FERM3p quintuple sum, machine guards on every link.
Verifier (scratch/verify-seed1-layer4.md): SOLID; independent raw-CW engine (not the
H/EMD kernel) matches n ≤ 12; notes N1 (Uncu's m=13 theorem is computer-assisted —
provenance inherited) and N2 (correct Uncu source path:
literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex).
Adversary: own FERM3p transcription == engine to n=15.

**Seed 2 (Template A, d=8 frontier) — GREEN as representation, positivity OPEN.**
Finding L4.1: all 7 core representatives get the two-term form verbatim from
Prop_finiteform2 limits — the planned R1/R2 word search was unnecessary; the
denominator (q)_{n_k+m_k+1} match to S₁₁ is exact. Three positivity strikes (D15)
with honest certificates. Verifier (scratch/verify-seed2-layer4.md):
SOLID-WITH-ERRATA — E1 scope overbreadth ("all d=8 profiles" → seven representatives
only; (2,3,3)→(4,4), (1,6,1)→Ferm_{7,2} undefined), E2 over-attribution, E3
provenance, E4 log bookkeeping; errata applied in proofs/prove-seed2-layer4.tex.
Adversary: independent transcription == engine n ≤ 12; differences clean n ≤ 32.

**Seed 3 (Template B, d=7 construction) — GREEN.** 12-row positive y-system; new
telescoping-chain mechanism (telescope raw rows down chains of singles to zero
orbits; head graph C1→C2→C4→C5←C3, C5 self-loop); depths 3,5,7,7,3. Verifier
(scratch/verify-seed3-layer4.md): SOLID, all 5 jobs pass, cosmetic errata only;
independent brute-force of the raw interlacing definition matched (q^20, n ≤ 8),
TRUE labels confirmed on all reversal-asymmetric pairs. Adversary: independent
g-recomputation by a DIFFERENT algorithm matched the pickle n ≤ 8; g ≥ 0 extended
to n ≤ 10 @ q^200; deterministic replay of seed3_R2L4_system.py PASS.
Recommendation on record: the mechanism should generalize to d=8.

**Seed 4 (Tingley) — YELLOW, sharply reduced.** Step 1 PROVED for all d ≥ 2 (G16);
2a-i PROVED (G17). Gaps now exactly two: 2a-ii (Y15), 2b (Y16). Newman route dead
(D13, NOMEET certificates, unbounded meet depths). No independent verifier this
layer; adversary stress-tested Step-1 lemmas (C0/CL/CV/CS/CE) at d ≤ 12 incl.
corners, clean. Files: proofs/prove-seed4-layer4.tex, scratch/prove-seed4-layer4.md.

**Seed 5 (SHARP-F0 / β-map) — YELLOW.** RESULTS 1–5: s_m = char{bottom ≠ 0 in vac};
w_k strata; three-term Hall injection; 30/30 Hall; set-level β-map existence +
injectivity PROVED (G19). Single gap: Q1 (Y12). Fences F1–F5 recorded (D16). No
independent verifier; adversary extended Q1/Q2 by 14 cases (all hold). File:
scratch/prove-seed5-layer4.md.

**Seed 6 (N₂/Harnack) — GREEN package + boundary discovery.** CAP-SHARP, R0, low band
j ≤ 48, S2 proved, HM ⟹ S1, R1 unconditional after repair (G18); S1 FALSE at 3|d.
Verifier (scratch/verify-seed6-layer4.md): per-theorem verdicts, all SOLID except
Thm 7.5 SOLID-WITH-ERRATA (E1–E4) + E5 = the G10 orientation erratum for THIS
synthesis. Repair pass (scratch/repair-seed6-layer4.md): all four errata fixed;
Lemma 7.3 now PROVED by exact switch-locus enumeration (no relabeling needed);
PDF rebuilt 8pp/0 errors.

**Seed 7 (audit + falsification + Lean) — GREEN.** Label audit (G21); Y7 clean to
d=14; Y8 FALSIFIED (D12) with the balanced-only characterization and the universal
polynomiality fact (EMD triples distinct mod 3 ⟹ (U−I) diagonal is a polynomial);
TheoremD.lean sorry-free (G20). Adversary B6: Y8 falsification spot-confirmed
EXACTLY at d=8 target (1,1,6) (EMD-triple {0,5,10}, diagonal x⁸−x⁷+x⁵−x⁴+x³−x,
neg-entry row counts 0/14/12). File: scratch/prove-seed7-layer4.md.

**Seed 8 (adversary) — NO COUNTEREXAMPLE ANYWHERE.** MASTER sweeps (= conjecture
verification per BA30, exact ℤ[q]): d=7 m ≤ 32, d=8 m ≤ 32 (45 profiles), d=10
m ≤ 22 (66 profiles, ALL orbits), d=11 m ≤ 18 (NEW d), d=13 m ≤ 14; six differences
n ≤ 32; sibling confirmations B1–B6 all CONFIRMED; new n=2-hard-level finding (Y18).
File: scratch/prove-seed8-layer4.md.

---

## 3. What died this layer

**D12. Y8 / "Conjecture A" (H-level nonneg rows) — FALSIFIED for d ≥ 5.** (Seed 7,
adversary-confirmed.) The nonneg rows of (U−I) occur EXACTLY at balanced targets
(c with all EMD-triple gaps equal); for d ≥ 5 unbalanced targets have negative
entries (e.g. d=8 (1,1,6): 14 negative entries). §4(viii) of synthesis-layer3 is
RETRACTED and restated in §4 below. BA36.

**D13. Newman / local-confluence route to Tingley 2b.** Provably dead: NOMEET
certificates exist and meet depths are UNBOUNDED in tested families — local
confluence at any fixed depth cannot imply global confluence here. Any proof of 2b
must be global (rank function, invariant, or direct source-counting). BA40.
File: scratch/prove-seed4-layer4.md.

**D14. The overbroad Seed-2 statement** ("two-term representation for ALL d=8
profiles"). Dead as stated: (2,3,3) and (1,6,1) hit undefined Ferm parameters.
Correct scope = the seven cyclic representatives (G14, BA39).

**D15. Three attack routes on the d=8 differences (Seed 2 strikes, certificates
verified REAL by the verifier):** (i) naive summand-domination fails (certificate
exponent mismatch), (ii) single-index injection fails, (iii) direct q-binomial
domination fails. Each certificate is a concrete (n, exponent) witness —
scratch/prove-seed2-layer4.md, scratch/verify-seed2-layer4.md. The absorption
skeleton L4.3/L4.4 survives as the live route (Y11, Mission 2).

**D16. Seed-5 fences F1–F5** (multiset-level Hall, level-mixing β variants, etc.) —
recorded dead ends bounding the β-map design space. scratch/prove-seed5-layer4.md.

**D17. Naive har monotonicity across ALL d (no residue condition), and S1 at 3|d.**
har₁₃((1,1,1)) = −1, har₁₅((0,1,2)) = −1. S1 and HM must carry gcd(d,3)=1. BA38.

---

## 4. Adjudications

### (i) THE DEFINITIVE CONVENTION STATEMENT — carried forward VERBATIM from synthesis-layer3.md §4(iv) (cite in every future brief)

1. **Ground truth** is the raw conjecture.tex interlacing definition of cylindric
   partitions of profile c. The chain model S = {a ∈ ℤ³_{≥0} : a_i ≤ a_{i−1} + c_i}
   at profile c matches it DIRECTLY (no relabeling).
2. **Target-first kernel is correct**: the H-recursion matching ground truth is
   (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c,c')} H_{c',m−1} with c the TARGET (level m).
   Validated three ways (CW truncated solve; brute-force enumeration; d=2 closed forms).
3. **The Layer-2 standing notation was source-first** (q^{m·EMD(c',c)}) and computes H of
   the REVERSED profile: H_src-first[c] = H_true[rev(c)], rev(c₀,c₁,c₂) = (c₂,c₁,c₀).
   **BA31.** All AGGREGATE Layer-≤2 positivity results remain valid (the profile set is
   reversal-closed); only per-orbit labels flip, and only on reversal-ASYMMETRIC orbits
   (at d=4: the orbits of (0,1,3)/(0,3,1); at d=5: perms of {0,1,4},{0,2,3}).
4. **d=4 orbit dictionary in TRUE labels — the IDENTITY map** (each CW label c ↔ the
   C₃-orbit containing c itself):
   CW(2,1,1) = {(1,1,2),(1,2,1),(2,1,1)} good; CW(4,0,0) = {(0,0,4),(0,4,0),(4,0,0)} good;
   CW(3,1,0) = {(0,3,1),(1,0,3),(3,1,0)} good (single sum, q^j);
   **CW(3,0,1) = {(0,1,3),(1,3,0),(3,0,1)} WALL**; CW(2,2,0) = {(0,2,2),(2,0,2),(2,2,0)} WALL.
5. **Retro-correction of the Layer-2 C2 verdict** (verify-layer2-disputes.md): its verdict
   "walls = (0,2,2),(0,3,1); Seed 3 correct, Seed 4 wrong" was computed on the source-first
   (reversed) engine. In TRUE labels the walls are the orbits of **(0,2,2) and (0,1,3)** —
   i.e. Seed 4's list was the correct one in raw labels; Seed 3's was correct in reversed
   labels; both had found the same orbits (C2 was purely notational, as Seed 1 Result 1
   also concluded). The "Seed 4 WRONG" line is retracted.
6. **Rule going forward**: all new artifacts use TRUE labels + target-first kernel.
   Seed 8's raw-validated engine (scripts/seed8_R2L3_engine.sage) is the reference
   implementation. Any statement mixing chain-model and EMD-recursion objects, or matching
   against Warnaar/Uncu/CW tables, must apply rev() when consuming source-first-era files
   (all Layer-2 files; Seed 3/4 L3 analysis files; scratch prove-seed6-layer3.md §8).
   Two convention bugs in two layers both arose at chirality-sensitive orbit pairs; an
   automated label audit of old artifacts is cheap insurance (Seed 8's recommendation).

**Layer-4 REFINEMENT of point 6 (= BA42, from G21):** the label audit is DONE
(scratch/label-audit-layer4.md). Seed 3 L3 is MIXED, not uniformly reversed — its
chain-model results (D3 ILP certificates, D4, Y5 HALL-RIBBON, Y7) are ALREADY in TRUE
labels; only its Scripts 1–4 (EMD-kernel) outputs are reversed. Seed 4 L3 used a
reversed engine but has ZERO chirality-sensitive per-orbit claims — SAFE. Two precise
corrections: Seed 3 L3's (1,1,2) (U−I) row in TRUE labels is [x³,x²,x,x,0]; Seed 3
L2's d=5 unmatched list in TRUE labels is {(0,2,3),(0,3,2),(0,1,4)}.

### (ii) RETRACTION of synthesis-layer3 §4(viii), restated correctly

The old statement ("at the H-level the all-positive core is easy and zero-containing
profiles are hard — polarity reversed vs G-level") leaned on Y8, now FALSIFIED (D12).
Correct statement: **"balanced is special" holds at BOTH levels, in different senses.**
At the H-level, the nonneg (U−I) rows are EXACTLY the balanced targets (Seed 7's
characterization — a theorem-shaped empirical fact, d ≤ 13). At the G-level, the
proved-positive core orbits so far are exactly the balanced ones: d=8 (3,3,2) via
S₁₁, d=10 (4,3,3) via S₁₃. "Hard orbit" remains level-relative; briefs must still say
which level — but the H-level easy set is balanced-only, NOT the whole core. BA36.

### (iii) G10 restated in the correct orientation (Seed-6 verifier E5, = BA37)

synthesis-layer3 G10 carried a stale source-first exponent. Correct target-first
statement (machine-decided: T2 holds ONLY this way on the target-first tower):
  N₂(c) = [B_c(q²) − 1 − q² − q⁴] + har(c),   B_c(q) = Σ_{c'} q^{EMD(c,c')},
  **har(c) = Σ_{c'≠c} q^{2·EMD(c,c')} Q₁(c') − q(1+q+q²+q³+q⁴) Q₁(c)**.
All of G18's theorems are stated and verified in this orientation
(scratch/verify-seed6-layer4.md §0–1; scratch/scripts/audit6L4.py).

### (iv) Seed-2 scope adjudication (= BA39)

The two-term representation is a theorem for the SEVEN cyclic representatives listed
in G14 and for nothing more. Cyclic normalization covers every d=8 profile with
c₂,c₃ ≥ 1 at the G-level, but reversal is NOT available (G_c ≠ G_rev(c) in general),
and the (s,t)-grid of Prop_finiteform2 is genuinely bounded. Any future write-up
quotes the seven-representative statement.

### (v) Seed-6 repair adjudication

The verifier's single substantive objection (Lemma 7.3's wall list was empirical) is
CLOSED: the repair pass derived the exact switch loci (breakpoints B1–B5, pairwise
collisions all at j ≤ 14), giving wall families {2a=j+t, |t|≤2} ∪ {4a=j+t, |t|≤2} ∪
{a≤2} ∪ {a=j−t, 2≤t≤6}, then re-pinned every sub-chamber at full rank (178k+ points,
0 mismatches). Notably **4a=j is a genuine candidate wall that carries no polynomial
jump** — the original fit was right for a subtle reason, now proved. Thm 7.5 / R1 is
UNCONDITIONAL; no downgrade to "computationally verified" was needed.
File: scratch/repair-seed6-layer4.md.

### (vi) The n=2 structural insight (from Y18)

The Harnack machinery (har correction, CAP-SHARP, HM) was built to fix failures of
naive monotonicity AT LEVEL n=2 — and Y18 shows those failures are SPECIFIC to n=2:
at n = 3, 4 the raw residue-respecting monotonicity of [q^j]Q_{n,c} holds with zero
failures (d ≤ 16, j ≤ 60). Consequence for strategy: (a) the level-n lift of the
Harnack route (old Y4) may need NO correction term for n ≥ 3; (b) any induction on n
should treat n=2 as the base-case anomaly, not the pattern. BA41.

### (vii) Template-A scaling law (from G13)

Bridge (KR contiguous) relations are needed exactly at moduli ≡ −1 mod 3 (m = 3k−1,
e.g. d=8/m=11); at m = 3k+1 (d=10/m=13, d=13-family/m=16, …) the Pochhammer split
lands directly on the Uncu/KR pair. The BINDING constraint for extending Template A
is therefore the supply of proved S_m sum-side theorems (Uncu has m=11, m=13 ONLY),
not bridge words. See Mission 6.

---

## 5. State of the conjecture

**Proved perimeter (project standards):**
- d=2, d=5: Warnaar/literature (moduli 5, 8 in his proved set {2,4,5}).
- d=4: ALL orbits — THEOREM (synthesis-layer3 §4(iii); CW keystone + absorption +
  inversion).
- d=8: orbit (3,3,2) — THEOREM (layer 3, Template A with one R₃ bridge).
- **d=10: orbit (4,3,3) — THEOREM (NEW, G13)** — first Con_cylindric-b case at k ≥ 3.
- d=7: G_c(y,q) ∈ ℕ[[y,q]] for ALL profiles — bivariate G-positivity THEOREM (NEW,
  G15). Q-positivity open (Y19).
- Propagation Theorem: zero-containing profiles reduce to the core (layer ≤ 2 GREEN).

**Verified-clean landscape (exact ℤ[q], no counterexample anywhere, updated depths —
keep the maximum over layers):** full MASTER grid at d=2,4,5 (deep); d=7 m ≤ 32;
d=8 m ≤ 32 (45 profiles); d=10 m ≤ 22 (66 profiles); d=11 m ≤ 18; d=13 m ≤ 16
(layer 3; L4 adversary re-ran m ≤ 14); d=16,17,19,20 m ≤ 12; d=22,23 m ≤ 10;
d=25 m ≤ 9; d=31 m ≤ 7. Gauss-inversion Q_n ≥ 0: d=4 n ≤ 25, d=5 n ≤ 22, d=7 n ≤ 18,
d=8 n ≤ 16, d=13 n ≤ 12. d=8 differences n ≤ 32. N₂ ≥ 0 unconditional j ≤ 48; HM
j ≤ 40. Margins show no degradation trend.

**Live proof routes** (in order of maturity): Template A at m ≡ 1 mod 3 given a
proved S_m (Mission 6); d=8 core = six explicit inequalities (Mission 2); Template B
d=7 endgame (Mission 1); N₂/Harnack via HM (Mission 5); SHARP-F0 via Q1 (Mission 3);
Tingley crystal (Mission 4).

---

## 6. Recommended Layer-5 missions (ranked by expected value)

**Mission 1 (TOP — d=7 Template-B endgame: from G-positivity to Q-positivity).**
Inputs: proofs/prove-seed3-layer4.tex, scripts/seed3_R2L4_system.py, the d=4 endgame
blueprint (synthesis-layer3 §4(iii): explicit G-forms → absorption lemmas for
(1−q^n) wall terms → Q_n ≥ 0 whole level). Task: extract explicit/bounded forms for
the 5 core d=7 orbits from the positive system (CW-note style uniqueness induction),
identify which orbits are walls, prove the absorption lemmas. Success = d=7 becomes
the first FULLY proved level outside Warnaar's set — the single highest-value target
on the board. Expected hard part: d=7 forms are depth-7 chains, not depth-2.

**Mission 2 (six d=8 difference inequalities, Y11).** Two coordinated attacks:
(a) import Seed 3's telescoping-chain mechanism to d=8 (mod 11) — construct a
positive y-system whose uniqueness forces the differences (Seed 3's own
recommendation); (b) push the L4.3/L4.4 absorption skeleton + the (6,1,1) wall split
Q_n = (1−q^{n+1})A_n + B_n to a proof for the easiest orbit (4,3,1) first
(difficulty ordering from scratch/prove-seed2-layer4.md). Respect D15 (three dead
routes with certificates — do not retry them). Use the n=2 insight (BA41) if an
n-induction appears.

**Mission 3 (prove Lemma Q1, Y12).** One lemma stands between G19 and the Y-term of
SHARP-F0. Designated tool: Seed 4's Lemma L (one box flip changes only colors
k, k±1 and one letter of W_k) — show the β-choice box never exits the vacuum
component. 44 verified cases incl. corners. Inputs: scratch/prove-seed5-layer4.md
(RESULT 5b + LEMMA TARGET Q1 architecture), proofs/prove-seed4-layer4.tex (Lemma L).

**Mission 4 (Tingley gaps 2a-ii + 2b, Y15/Y16).** 2a-ii: extend the m=1 proof by
induction on m using the acyclicity backbone + per-boundary calculus (P1)–(P4).
2b: Newman is dead (D13) — try a GLOBAL rank/potential function on components, or
count sources directly against the v-chain GF Π 1/(1−q^{jd}) (if #sources = #v-chains
weight-wise, 2a-ii + counting gives 2b for free). Payoff: bounded factorization X_m ≅
vac ⊗ B(3Λ) machinery, feeding SHARP-F0 and the crystal route simultaneously.

**Mission 5 (prove HM, Y17).** har_j is cap-determined (CAP-SHARP) and piecewise
quasi-polynomial in the capped coordinates (R1 machinery, chambers of period 12);
HM@j is a finite statement per j, verified j ≤ 40. Attack: prove the one/two-box step
inequality chamber-by-chamber using the repaired wall enumeration
(scratch/repair-seed6-layer4.md switch-locus method applied to har differences
rather than har itself). We now KNOW where gcd(d,3)=1 must enter (D17). Payoff:
S1 for all j, closing the N₂ program's main gap.

**Mission 6 (d=13-family Template A at m=16 — the scaling-law test).** By §4(vii),
m=16 ≡ 1 mod 3 needs NO bridge; the missing ingredient is a PROVED S₁₆ theorem
(Uncu stops at m=13). Task: check whether Kanade–Russell/Uncu-style ideal-membership
certificates can be GENERATED for the m=16 sum-side (the method of Uncu's
computer-assisted proofs, provenance note N1 in scratch/verify-seed1-layer4.md);
if yes, the balanced orbit of (4,4,5) at d=13 becomes the third Template-A theorem and
validates the scaling law as a production line (m = 19, 22, … to follow). This is a
literature+computation mission; budget the risk that certificate generation at m=16
is computationally out of reach.

**Mission 7 (Lean phase 3b).** Extend lean/WarnaarGlue/ beyond TheoremD.lean:
formalize the inversion pair (Theorem G / Corollary I) at concrete profiles, then
the d=4 absorption lemmas (half-page q-Pascal computations, ideal Lean targets).
Keep the public mirror in sync (HANDOVER rule). Inputs:
scratch/prove-seed7-layer4.md [T3], lean/WarnaarGlue/.

**Mission 8 (housekeeping + standing adversary).** (a) Re-verify Seeds 4/5 formal
claims (no independent verifier this layer — G16/G17/G19 carry seed-only pedigree;
a verifier pass on proofs/prove-seed4-layer4.tex and the Seed-5 RESULT 5b proofs is
due). (b) Standing adversary: extend sweeps (d=14,16,17 fresh; d=10 deeper; HM
j > 40; n=3/4 monotonicity to more d), always exact ℤ[q], always from the raw
engine. (c) Enforce §4(i) rule 6: any new file consuming Layer-≤2 or Seed 3/4 L3
EMD-kernel outputs must apply rev(). (d) Propagate the G10 orientation erratum:
grep old artifacts for q^{2·EMD(c',c)} and annotate.

---

## 7. Bulletin of broken assumptions (continuing BA35)

**BA36.** "Y8/Conjecture A: (U−I) rows are eventually nonneg at the H-level for all
core targets." FALSE for d ≥ 5 — nonneg rows occur EXACTLY at balanced targets
(Seed 7, adversary-confirmed). synthesis-layer3 §4(viii) is RETRACTED and restated
(§4(ii) above).
**BA37.** "G10's har formula as printed in synthesis-layer3." STALE orientation —
correct target-first form has q^{2·EMD(c,c')} (§4(iii) above; machine-decided).
**BA38.** "S1 (har ≥ 0) might hold for all d." FALSE at 3|d: har₁₃((1,1,1)) = −1,
har₁₅((0,1,2)) = −1. gcd(d,3)=1 is essential and any proof must consume it.
**BA39.** "The two-term fermionic representation covers ALL d=8 profiles." FALSE —
seven cyclic representatives only; (2,3,3) and (1,6,1) hit undefined Ferm parameters.
**BA40.** "Local confluence (Newman) can close Tingley 2b." FALSE — meet depths are
unbounded; NOMEET certificates on record. 2b needs a global argument.
**BA41.** "Level n=2 monotonicity behavior is typical of all levels." FALSE — n=2 is
the UNIQUELY hard level: raw residue-respecting monotonicity of [q^j]Q_n fails at
n=2 (even j ≥ 16) but holds with zero failures at n=3,4 (d ≤ 16, j ≤ 60).
**BA42.** "Seed 3 L3 outputs are uniformly reversed-label." FALSE — MIXED: its
chain-model results are already TRUE-label; only Scripts 1–4 (EMD-kernel) are
reversed. Seed 4 L3 is chirality-SAFE. (Refines §4(iv).6; scratch/label-audit-layer4.md.)

---

*Synthesizer, Round 2 Layer 4, 2026-07-04. Sole file: 2026-07-04/synthesis-layer4.md.*
