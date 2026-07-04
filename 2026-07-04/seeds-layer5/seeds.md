# Seeds for Round 2, Layer 5 — 2026-07-04 (FRESH, from synthesis-layer4.md §6)

Generated from Missions 1–8 of synthesis-layer4.md. Layer 4 delivered the second
proved conjecture case (d=10 (4,3,3), Conjecture 2.11 k=4), reduced d=8 to six
explicit inequalities, built the full d=7 positive y-system, and repaired the N₂
theorem stack. **The Warnaar email is SENT** — Layer 5 is about converting reductions
into full levels: d=7 Q-positivity is the single highest-value target.

**MANDATORY for every brief:** cite synthesis-layer3.md §4(iv) (carried verbatim in
synthesis-layer4.md §4) — TRUE conjecture.tex labels, target-first kernel
q^{m·EMD(c,c')}; reference implementation scripts/seed8_R2L3_engine.sage; apply rev()
when consuming source-first-era files (all Layer-2 files; Seed 3 L3 Scripts 1–4 —
BUT Seed 3 L3 chain-model results are TRUE-label and Seed 4 L3 is safe, per BA42 /
scratch/label-audit-layer4.md). New standing errata: G10 har orientation is
q^{2·EMD(c,c')} (BA37); S1 requires gcd(d,3)=1 (BA38); Y8 is dead (BA36).
Layer 5 runs with `rag: true` except Seed 8 — seeds give the OPENING query; agents
generate their own follow-ups.

## Seed 1 — MISSION 1 (TOP): d=7 Template-B endgame — G-positivity → Q-positivity
**Query:** `"Corteel Welsh cylindric partitions explicit generating function absorption positive q-series modulus 10 bounded form"`
**Rationale:** The d=7 positive y-system is GREEN (all 12 orbits, verifier SOLID:
proofs/prove-seed3-layer4.tex, scripts/seed3_R2L4_system.py). Run the d=4 endgame
blueprint (synthesis-layer3 §4(iii)): extract explicit/bounded forms for the 5 core
orbits via the uniqueness induction, identify the wall orbits, prove the absorption
lemmas for the (1−q^n) wall terms. Success = d=7 is the first FULLY proved level
outside Warnaar's set {2,4,5}. Expected hard part: d=7 core forms come from
depth-3..7 substitution chains, not d=4's depth-2 — the bounded forms will be
3-fold sums. Budget for partial success: even 2–3 orbits proved at the Q-level is a
step change.

## Seed 2 — MISSION 2: the six d=8 difference inequalities (Y11)
**Query:** `"positive q-binomial sum difference telescoping recurrence positivity fermionic form Rogers-Ramanujan"`
**Rationale:** Q-positivity at the entire d=8 core ⟺ ferm_{c₂+1,c₃+1}(n) ≥
q·ferm_{c₂,c₃}(n) for six orbits (proofs/prove-seed2-layer4.tex, adversary-clean to
n=32, min-in-hull structurally 0). Two coordinated attacks: (a) import Seed 3's
telescoping-chain mechanism to mod 11 — build a positive y-system whose uniqueness
forces the differences; (b) push the absorption skeleton + the (6,1,1) wall split
Q_n = (1−q^{n+1})A_n + B_n on the easiest orbit (4,3,1) first (difficulty ordering
in scratch/prove-seed2-layer4.md). HARD CONSTRAINT: D15 — three dead routes with
verified strike certificates; do NOT retry K1/K2/K3. If an n-induction appears, use
BA41 (n=2 is the uniquely hard level; n=3,4 are clean).

## Seed 3 — MISSION 3: prove Lemma Q1 (Y12) — the last gap in SHARP-F0's Y-term
**Query:** `"crystal operator box flip color change locality vacuum component connected weight preserving bijection"`
**Rationale:** One lemma stands between G19 (β-map machinery) and the Y-term of
SHARP-F0. Designated tool: Seed 4's Lemma L (a single box flip changes only colors
k, k±1 and one letter of W_k — proofs/prove-seed4-layer4.tex) — show the β-choice
box never exits the vacuum component. 44 verified cases incl. corners (adversary
extended to d ∈ {10,11,13}, all hold). Architecture: scratch/prove-seed5-layer4.md
(RESULT 5b + LEMMA TARGET Q1). Fences F3–F5 (D16) mark dead simplifications.

## Seed 4 — MISSION 4: Tingley gaps 2a-ii and 2b (Y15/Y16)
**Query:** `"crystal graph unique source component counting generating function acyclic rank function global potential argument"`
**Rationale:** Step 1 + 2a-i are PROVED (proofs/prove-seed4-layer4.tex). 2a-ii
(every source is a v-chain): extend the m=1 proof by induction on m via the
acyclicity backbone + per-boundary calculus (P1)–(P4). 2b (unique source): Newman
is DEAD (BA40, NOMEET certificates) — go global: a rank/potential function on
components, or count sources against the v-chain GF ∏ 1/(1−q^{jd}) (if #sources
= #v-chains weight-wise, 2a-ii + counting yields 2b free). Adversary found no
counterexample to either gap at W≤14, d≤12 — both are believed true. Payoff:
X_m ≅ vac ⊗ B(3Λ), feeding SHARP-F0 and the crystal route at once.

## Seed 5 — MISSION 5: prove HM (Y17) — close the N₂ program
**Query:** `"quasi-polynomial chamber decomposition inequality between lattice point counts monotone walk piecewise proof"`
**Rationale:** har_j is cap-determined (CAP-SHARP, proved) and piecewise
quasi-polynomial with period-12 chambers (R1, now unconditional). HM verified j≤40
(adversary). Attack: prove the one/two-box step inequality chamber-by-chamber using
the repaired switch-locus method (scratch/repair-seed6-layer4.md) applied to har
DIFFERENCES rather than har itself. D17 tells you where gcd(d,3)=1 must enter —
S1 is false at 3|d, so the proof must consume the hypothesis explicitly. Payoff:
S1 for all j at gcd(d,3)=1, closing the N₂ program's main gap.

## Seed 6 — MISSION 6: d=13 Template A at m=16 — the scaling-law production test
**Query:** `"cylindric partitions modulus 16 level 13 A2 Rogers-Ramanujan identities q-difference operator ideal membership certificate holonomic proof"`
**Rationale:** §4(vii) scaling law: m=16 ≡ 1 mod 3 needs NO contiguous-relation
bridge — the only missing ingredient is a PROVED S₁₆ theorem (Uncu stops at m=13).
Task: determine whether Uncu-style ideal-membership certificates (Gaussian
elimination over q-difference operators — provenance note N1 in
scratch/verify-seed1-layer4.md, ancillary files of arXiv:2301.01359) can be
GENERATED for the m=16 sum side. If yes, the balanced orbit of (4,4,5) at d=13
becomes the third Template-A theorem and the method becomes a production line
(m = 19, 22, …). Literature + computation mission; budget the real risk that
certificate generation at m=16 is computationally out of reach — report the wall
honestly if so.

## Seed 7 — MISSION 7: Lean phase 3b (rag: false)
**Query:** (none — formalization, not exploration)
**Rationale:** Extend lean/WarnaarGlue/ beyond TheoremD.lean: formalize the
inversion pair (Theorem G / Corollary I) at concrete profiles, then the d=4
absorption lemmas (half-page q-Pascal computations — ideal Lean targets). Inputs:
scratch/prove-seed7-layer4.md [T3], lean/WarnaarGlue/. Build must stay sorry-free
(lake build). MANDATORY: keep the public mirror github.com/RaggedR/warnaar-glue in
sync — commit and push any lean/ change (Claude authorship approved for this repo).

## Seed 8 — MISSION 8: housekeeping + STANDING ADVERSARY (launch AFTER Seeds 1–7 report)
**Query:** `"q-series positivity counterexample search large modulus cylindric partitions asymptotics"`
**Rationale:** (a) Verifier duty FIRST: Seeds 4/5 of Layer 4 carry seed-only
pedigree (G16/G17/G19 — no independent verifier ran). Independently verify
proofs/prove-seed4-layer4.tex (Step 1, 2a-i) and Seed 5's RESULT 5b proofs with own
code. (b) Independently recompute whatever Layer-5 Seeds 1–6 claim to have proved
(sibling-informed, per the L3 lesson). (c) Standing sweeps, always exact ℤ[q] from
the raw engine: d=14,16,17 fresh; d=10 deeper; HM j>40; n=3/4 monotonicity at more
d; MASTER-grid format (BA30: sweeps ARE conjecture verification). (d) Enforce
§4(iv) rule 6 (rev() on legacy consumers) and propagate the G10 orientation
erratum: grep old artifacts for q^{2·EMD(c',c)} and annotate.
