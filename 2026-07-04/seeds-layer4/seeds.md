# Seeds for Round 2, Layer 4 — 2026-07-04 (FRESH, from synthesis-layer3.md §6)

Generated from Missions 1–8 of synthesis-layer3.md. Layer 3 rebuilt the logical
map: **Q-positivity (Q_{n,c} ≥ 0) is the ONLY terminal target** (Monotonicity/f_0
are strictly weaker projections — BA29/BA32); d=4 is a THEOREM; the first k=3 case
of Conjecture 2 is proved at (3,3,2), d=8. This layer diversifies again: two
literature-composition seeds (the proved pipeline), one construction seed, three
structure seeds, one housekeeping/verifier seed, one adversary.

**MANDATORY for every brief:** cite synthesis-layer3.md §4(iv) — TRUE conjecture.tex
labels, target-first kernel q^{m·EMD(c,c')}; the reference implementation is
scripts/seed8_R2L3_engine.sage; apply rev() when consuming any source-first-era file
(all Layer-2 files; Seed 3/4 L3 analyses; scratch prove-seed6-layer3.md §8).
Layer 4 runs with `rag: true` — seeds below give the OPENING query; agents generate
their own follow-ups.

## Seed 1 — MISSION 1 (TOP): d=10 balanced orbit (4,3,3) via Template A
**Query:** `"Kanade-Russell contiguous relation modulus 13 Uncu cylindric partitions level 3 A2 identities finite form"`
**Rationale:** Rerun Seed 2 L3's proved 4-link chain with a=+1 / S₁₃ / Uncu thm:m13.
CAUTION FIRST STEP: Uncu's displayed R₃ for m ≡ 1 mod 3 has a typo (two identical
terms, opposite signs) — re-derive from Kanade–Russell arXiv 2022 Lemma 9.2 before
anything else. Deliverable: second proved case of Conjecture 2 at k=3, first proved
core orbit at d=10. Inputs: prove-seed2-layer3.tex ("chain" section),
scripts/seed2_R2L3_s11_chain.sage (adapt), synthesis §4(v) Template A.

## Seed 2 — MISSION 2: R1/R2 word search on the d=8 core
**Query:** `"contiguous relations q-hypergeometric series shift operator algebra relations between series Rogers-Ramanujan type"`
**Rationale:** The 6 remaining d=8 core orbits have Uncu-difference shift pairs at
δ₁/δ₂, not the mergeable δ₃ (Y9 table). Finite symbolic search, depth ≤ 4, in the
proved relations R1^(i), R2^(i), R3, R4: walk each pair to a mergeable (+δ₃|+δ₃)
form with (q;q)_∞-compatible remainder. Start with (6,1,1) and (5,2,1) (closest to
δ₃). Track (4,2,2) separately — it appears in NO R-relation; needs the |I_c|=3 core
CW equations. Never yet run (Seed 2 L3 handoff #2). Success on any orbit shrinks
the core; all 6 + propagation + absorption = d=8 solved.

## Seed 3 — MISSION 3: construct the positive y-system at d=7 (Template B)
**Query:** `"Corteel Welsh cylindric partitions functional equations modulus 10 level 4 positive recurrence uniqueness"`
**Rationale:** d=7 (mod 10) is the smallest level with NO proof anywhere (Warnaar's
set is {2,4,5}; we added 4's bounded refinement). Build the CW-style Eq:Fun analogue:
R-relations give zero-containing rows (Seed 6 L2 GREEN); search for positive CORE
rows guided by the CW note's (2,1,1) row shape and Seed 2 L2's distortion moves
M0–M3. Then uniqueness induction → bounded forms → absorption lemmas (expect the
same (1−q^n) wall shape, 3-fold sums). First fully-novel level if it lands.

## Seed 4 — MISSION 4: prove the Bounded Tingley Factorization (Y2)
**Query:** `"Tingley crystal partitions bead model affine sl_n level truncation vacuum component character"`
**Rationale:** (q^d;q^d)_{m−1} F_{c,m} = character of the vacuum crystal component —
verified d=2..8 incl. 3|d, apparently NEW, publishable standalone. Execute Steps 1–2
of Seed 5 L3's proof program (scratch/prove-seed5-layer3.md): bounded operators
well-defined via Tingley's bracket argument (the m-bound only deletes far-end
addables); unique source per component; sources counted by partitions into
{d, 2d, …, (m−1)d}. Scope d ≥ 3 via Tingley (MIND the post-publication erratum to
his §4.2 — verify axioms computationally); d=2 separately (adjudication vi).
The crystal is ŝl_d level 3, colors mod d (BA34 — NOT ŝl₃).

## Seed 5 — MISSION 5: SHARP-F0 inside the vacuum component
**Query:** `"Demazure crystal string decomposition normalized matching rank symmetric poset character inequality"`
**Rationale:** With the bosonic factor stripped (Y2), attack
(1−q^m)s_m ≥ q(1−q^{(m−1)d})s_{m−1} via string/Demazure decomposition of B(Λ_c) for
ŝl_d, or run HALL-RIBBON/normalized-matching (Y5, S distributive) INSIDE the vacuum
component (smaller, connected). Also identify the combinatorial object with
character s_m (NOT the naive set difference — Seed 5 L3 RESULT 7c). NOTE: this
proves a projection, not the conjecture (§4(i)) — funded as technology + the
dual-positivity payoff. Two-term weakenings are FALSE (D5) — keep both factors.

## Seed 6 — MISSION 6: finish Sphere Absorption S1 via Ehrhart
**Query:** `"Ehrhart quasi-polynomial lattice points polytope piecewise quasipolynomial short rational generating function Barvinok"`
**Rationale:** Cap-Compression (G10) makes each [q^j]N₂ a FINITE problem uniformly
in d. A_j(c) = #{f ≤ j, f ≡ j mod 3} is piecewise quasi-polynomial in (j,c); har_j
is a finite signed combination — verify region-by-region, then lift by the Sphere
Absorption pattern (Y4, verified n=3). The only route attacking all d uniformly at
fixed n; independent hedge if closed forms stall. Low band j ≤ 5 already proved
unconditionally; sharp cap M_j = j verified j ≤ 12.

## Seed 7 — MISSION 7: verifier + housekeeping (no RAG needed; rag: false)
**Query:** (none — this seed audits, it does not explore)
**Rationale:** (a) Automated label audit of ALL Layer-≤2 artifacts against
scripts/seed8_R2L3_engine.sage (two convention bugs in two layers — cheap
insurance). (b) Re-verify Y7 (raw bracket g_m ≥ q^m F_{c,m}) and Y8 (Conjecture A
rows) at more d. (c) Lean additions per Mission 7(c): Theorem D kernel identities,
ferm-monotonicity statement; optionally Lemma E + Theorem Q. NOTE: Lean phase 2 is
DONE (D4Positive.lean, Seed2Chain.lean — see HANDOVER-layer4.md); build on it, and
keep the public mirror github.com/RaggedR/warnaar-glue in sync if files change.

## Seed 8 — MISSION 8: ADVERSARY (launch AFTER Seeds 1–7 report — deliberate sequencing)
**Query:** `"q-series coefficient asymptotics sign changes positivity counterexample large degree cylindric partition character"`
**Rationale:** Target Q_n directly at large n where a counterexample would redirect
everything: d=8 core at n > 16, d=7 at n > 18; stress d ≡ ±1 mod 3 asymmetries and
corner orbits ((d,0,0) is consistently extremal — adjudication vii). Per BA30,
MASTER-grid sweeps ARE conjecture verification — use that format. Additionally:
independently recompute whatever Seeds 1–3 claim to have proved this layer (the
sibling-informed relaunch of L3 showed post-hoc adversaries are sharper).
