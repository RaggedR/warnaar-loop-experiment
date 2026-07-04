# Handover — Round 2 Orchestrator, written after Layer 2 (2026-07-04)

You are the next orchestrator instance. Read this, then root `synthesis.md` (pointer,
kept current), then `2026-07-04/synthesis-layer2.md` IN FULL. That synthesis is the
input for Layer 3. This file supersedes HANDOVER-layer1.md (still worth skimming for
the launch playbook, which worked again unchanged).

## Where we are

Round 2, Layer 2 is COMPLETE and synthesized. Disputes verifier COMPLETE (verdicts
below). Layer 3 architecture: RE-SEEDED 8-agent design (Robin-approved) — see
ARCHITECTURE_CHANGE_LEVEL3.md and seeds-layer3/seeds.md.

**LIVE Layer 3 state (launches, results, pipeline) is in HANDOVER-layer3.md —
this file is the frozen post-Layer-2 record. Do not append Layer 3 state here.**

The Layer 3 launch spec below is kept for the record (it was executed as written):
1. First line: `First, read ~/.claude/AGENT.md for instructions.`
2. Config: `seed: N, layer: 3, round: 2, rag: true`; working dir; state the core
   bottleneck (H_{c,m} = (q;q)_m F_{c,m} monotone in m; (q^3;q^3)_m for 3|d).
3. Read list: PROVE-SKILL.md (stale-path warning), problem-description/conjecture.tex,
   2026-07-04/synthesis-layer2.md, 2026-07-04/seeds-layer3/seed_N_context.txt,
   plus inherited Layer 2 scratch per seed:
   - Seed 4 (involutions on compressed target): prove-seed7-layer2.md (N_2 Shape
     Theorem, Master Recursion, warning: termwise pairing across profiles impossible)
     + prove-seed4-layer2.md (Adjugate Monomial Theorem involution J -> J triangle {k}).
   - Seed 5 (crystal operators/Tingley for f_0^(m)): prove-seed8-layer2.md (three
     injection failure post-mortems — do NOT retry greedy-ribbon/claim-alpha/top-add)
     + prove-seed2-layer2.md (dead ends: per-orbit positivity, Abel chains, shifted
     domination; BA18/BA19 warnings).
   - Seed 6 (finish d=4 via R-relations): prove-seed6-layer2.md (Propagation Theorem)
     + prove-seed3-layer2.md + prove-seed4-layer2.md (fermionic sections) +
     scratch/verify-layer2-disputes.md (MANDATORY: wall orbits are (0,2,2) and
     (0,3,1); (0,1,3) HAS a form a=0,b=1,eps=0 — Seed 4's grid missed it).
   - Seed 7 (Gauss inversion / BFF foundation): prove-seed3-layer2.md (Q-transform)
     + prove-seed8-layer2.md (bracket tower Q_n = f_{n-1}^(n)) +
     scratch/verify-layer2-disputes.md (Q-transform CONFIRMED d=2,4,5 exactly —
     needs proof; check whether Seed 3 proved or only stated it).
   - Seed 8 (ADVERSARY): synthesis-layer2.md §2 YELLOW list; mission = try to
     DISPROVE MASTER conjecture / BFF on wall orbits / N_n >= 0 at large d,m,n
     (d=13,16,17, m to 12+), exact Z[q] via H-recursion; also stress Uncu match
     at n=7,8. Counterexample redirects everything; confirmation hardens YELLOW.
4. Missions: rationale in seeds-layer3/seeds.md §Seed N + attack lines from the
   superseded mission briefs below (mapping S4→M5, S5→M6, S6→M3, S7→M1, S8→M7).
5. Paths: scratch 2026-07-04/scratch/prove-seedN-layer3.md; scripts
   2026-07-04/scratch/scripts/seedN_R2L3_*; proofs/expository/notes/poetry.
6. Tools block: RAG (python /Users/robin/git/experiments/waarnar/rag_query.py
   "query" --top-k 10); SageMath (eval "$($HOME/miniforge3/bin/conda shell.zsh
   hook)" && conda activate sage && sage x.sage); ARITHMETIC: exact Z[q] via
   H-recursion (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c',c)} H_{c',m-1}
   (spot-check vs brute force m<=3); fallback precision rule PREC >= 6*max(k,m)^2+200.
7. Require `## Handoff`; report <200 words GREEN/YELLOW/RED.

After all 8 complete: synthesizer (FABLE-INHERIT, per Robin — NOT opus) →
2026-07-04/synthesis-layer3.md with explicit adjudication questions; update root
synthesis.md pointer; write HANDOVER-layer3.md; SESSION-2026-07-04.md at day end.
Monitoring policy: agent dies mid-run → fresh agent continuing from its scratch;
surprising/conflicting claim → sonnet verifier on the specific instances.

## Model policy (Robin's decisions, 2026-07-04 — record for experiment integrity)

- Round 1: orchestrator + workers all Opus. Round 2 Layer 1: orchestrator fable-5,
  workers + synthesizer explicitly opus.
- **Layer 2 workers: INHERIT fable-5** (no `model` param) — Robin's decision,
  intentionally breaking worker constancy with Round 1.
- **ALL FUTURE SYNTHESIZERS: fable-5** (inherit, no `model` override) — Robin's
  explicit instruction after Layer 2. This supersedes HANDOVER-layer1.md's
  "launch synthesizer (opus)".
- Small mechanical verifier agents: sonnet (unchanged).

## Layer 2 headline results (full detail + BA20–BA28 in synthesis-layer2.md)

1. **d=2 SOLVED**: Q_n^{(1,1,0)} = q^{n^2}, Q_n^{(2,0,0)} = q^{n(n+1)}. Proved twice
   independently (Seed 1: G-CW Lemma / Rogers-Ramanujan functional equation; Seed 6:
   R-relation 2-cycle).
2. **h_m >= 0 PROVED for 3|d** (Seed 2, one line from Adjugate Monomial Theorem) and
   **for d=2** (Seeds 3+4 independently: h_m are finite Rogers-Ramanujan polynomials
   A_m = Σ q^{j^2+j} [m,j]_q, B_m = Σ q^{j^2} [m,j]_q, q-Pascal proof).
3. **Triple convergence (Seeds 2/3/4)**: one object, three notations — the H-tower
   H_m = U(q^m) H_{m-1}, H_{c,m} = (q;q)_m F_{c,m}, exact in Z[q] (precision problem
   permanently dead). Divisibility by 1+x+x^2 proved via EMD(a,ρb) ≡ EMD(a,b)+d mod 3.
4. **Uncu 2024 (Seed 5 via RAG)**: proved S_11/Kanade-Russell formulas for ALL 15
   canonical orbits at d=8; exact match with CW ground truth to O(q^430), n<=6.
   d=8 positivity is now about explicit already-proved series. Warnaar's Conjecture 2
   for k=3 is EQUIVALENT to the finite identity FERM_c = (q)_inf * S_11(...).
5. **Seed 6 Propagation Theorem**: manifestly positive R-relations reduce all-profile
   positivity to the all-positive core (all c_i >= 1): 2 orbits at d=5, 7 at d=8.
6. **Seed 7 Master Recursion + N_2 Shape Theorem**: all negativity in
   N_2 = (1+q^2+q^4)Q_2 compresses to one negative coefficient per rank-3 profile.
   New YELLOW conjecture N_n := (1+q^n+q^{2n})... see synthesis for the exact
   definition and the division-ladder caveat (Φ_6 first, Φ_3 last).
7. **Seed 8 bracket tower formalized**: Q_n = f_{n-1}^{(n)} exactly; MASTER conjecture
   (q;q)_j f_k^{(m)} >= 0 iff j <= m-k-1 (29,482 checks, 0 violations). But f_0^{(m)} >= 0
   still unproved (3 injection designs failed; escalated per three-strike rule).
8. **BA24 (important)**: h_m >= 0 ALONE no longer suffices for Q_n >= 0 — Seed 8's
   tower does not close by Transfer alone. The bottleneck moved.

**RENAMED CORE BOTTLENECK — Bounded Fermionic Form program**: conjecture
H_{c,m} = Σ_{n1} [m,n1]_q a_{n1}(q) with a_n >= 0; Gauss q-binomial inversion then
gives Q_n = a_n >= 0 DIRECTLY (verified d=2; verifier checking d=4,5 now). Equivalent
faces: Seed 3's Monotonicity Conjecture H_{c,m} >= H_{c,m-1} and Seed 8's f_0^{(m)} >= 0
(synthesizer adjudicated these as the same statement — see synthesis §5).

**The recurring wall (one obstruction, three sightings)**: non-Warnaar orbits —
(0,1,3)-type and (0,2,2) at d=4 (Seeds 3/4), the 10 uncovered orbits at d=8 (Seed 5),
Seed 6's all-positive core. Fermionic ansätze fail exactly there.

## Open items when this was written

1. **Verifier COMPLETE** (sonnet, agent aee71e801febf0bef; verdicts in
   2026-07-04/scratch/verify-layer2-disputes.md, exact ZZ[q], high confidence):
   - **C2 RESOLVED — Seed 3 correct.** d=4 fermionic-resistant orbits are (0,2,2)
     and (0,3,1). Seed 4 was WRONG about (0,1,3): it admits the form a=0,b=1,eps=0
     (Seed 4's parameter grid missed it). M3's wall targets: (0,2,2), (0,3,1).
   - **Gauss inversion CONFIRMED d=2,4,5** (all profiles, n<=5, two independent
     routes): Q_n = Σ_m (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m} holds exactly.
     M1 can treat the transform as computationally solid; still needs a proof.
   - Still to fix: Seed 4's .tex mislabel (C1): H_m = B_m is the correct statement
     (synthesizer verified); M2 should correct it when building on that file.
2. **Layer 3 redesign APPROVED in principle by Robin (2026-07-04)** — see the
   "Layer 3 redesign" section below. Final launch still gated on the verifier
   verdicts (fold into Missions 1 and 3) and a final go from Robin.
3. **SESSION-2026-07-04.md** still to be written at end of day (mirror
   2026-07-03/SESSION-2026-07-03.md). Include the model-policy section above.

## Layer 3 redesign — SUPERSEDED (see ARCHITECTURE_CHANGE_LEVEL3.md)

**The mission-brief design below was REPLACED by Robin's re-seeding design before
launch**: the 8-seed architecture is KEPT, but with 8 NEW seeds (RAG query +
rationale + top-20 context) all targeting the zeroed-in path. See
`ARCHITECTURE_CHANGE_LEVEL3.md` for the adopted design and
`seeds-layer3/seeds.md` + `seeds-layer3/seed_N_context.txt` for the new seeds.
Launch mechanics: as in HANDOVER-layer1.md's playbook, with config
`seed: N, layer: 3, round: 2`, seed contexts from `seeds-layer3/`, scratch
`2026-07-04/scratch/prove-seedN-layer3.md`, scripts `seedN_R2L3_*`, exact Z[q]
arithmetic via the H-recursion preferred, missions = the rationales in
seeds-layer3/seeds.md enriched with the attack lines below. Approved by Robin.

The mission content below REMAINS VALID as attack-line detail — the new seeds
map onto it: S1→M2, S2→M4, S3→(new: direct injection), S4→M5, S5→M6, S6→M3,
S7→M1, S8→M7. Read the missions for warnings and read lists.

### ORIGINAL (superseded) mission-brief design, kept for the record:

Rationale: Layer 2 collapsed the search space. Three of five proof paths merged into
one object (the H-tower), two died. The 8 divergent seed personas have done their
exploration job; keeping them would re-till dead soil. Layer 3 switches from
EXPLORATION (8 divergent seeds) to EXPLOITATION (6 focused missions + 1 contrarian
wildcard). The seed_N_context.txt files are RETIRED — lineage flows through the
scratch files each mission is told to read.

### The 7 missions

**M1 — Gauss-inversion foundation (lineage S3+S8).**
Prove rigorously: if H_{c,m} = Σ_{n1=0}^m [m,n1]_q a_{n1}(q) (Bounded Fermionic
Form), then Q_n = a_n, hence a_n >= 0 iff conjecture. Formalize Seed 3's Q-transform
Q_n = Σ_m (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m} (check whether Seed 3 proved or
only stated it — verifier verdict Item 2 settles the computational side d=4,5).
Then prove the equivalence chain: Monotonicity Conjecture (H_{c,m} >= H_{c,m-1})
≡ f_0^{(m)} >= 0 ≡ BFF-positivity at the first level. Deliverable: a single
referee-checked document making the bottleneck statement exact and unique.
Read: prove-seed3-layer2.md, prove-seed8-layer2.md, verify-layer2-disputes.md.

**M2 — Prove H-monotonicity via the U-tower (lineage S2+S4).**
The core strike. H_m = U(q^m) H_{m-1} with U's entries {0,±1}-alternating ending +1
(Seed 2), and at d=2 monotonicity follows from q-Pascal on Rogers-Ramanujan
polynomials (Seeds 3/4). Task: generalize the q-Pascal argument to the U-tower for
gcd(d,3)=1. Attack lines: (a) the sign-reversing involution fixing one monomial per
orbit sequence (Seed 2's recommendation); (b) columnwise induction on U's alternating
structure; (c) RAG-search bounded A_2 Andrews-Gordon (Warnaar lists it open —
find who else has tried and what broke).
Read: prove-seed2-layer2.md, prove-seed4-layer2.md, prove-seed3-layer2.md §H-recursion.

**M3 — Finish d=4 completely (lineage S3+S6).**
d=4 is the smallest UNSOLVED case and has everything in miniature: 3 orbits with
fermionic forms, 2 wall orbits. Task: (a) prove the fermionic forms for the 3 good
orbits via q-Pascal/U-tower template; (b) for the 2 wall orbits (identity per
verifier verdict Item 1 — C2 dispute), use Seed 6's bounded R-relations to inherit
positivity from the good orbits; (c) assemble into a complete proof of Q_n >= 0 for
d=4. A solved d=4 would be the first unproved-by-Warnaar case and likely contains
the general mechanism.
Read: prove-seed3-layer2.md, prove-seed6-layer2.md, prove-seed4-layer2.md
(fermionic sections), verify-layer2-disputes.md (MANDATORY — orbit identity).

**M4 — d=8 endgame via Uncu (lineage S5).**
Warnaar's Conjecture 2 for k=3 is now the FINITE identity FERM_c = (q)_inf *
S_11(e_{c2}|e_{c3}) (Uncu 2024 proved the S_11 side for all 15 canonical orbits).
Task: prove the identity for the 5 covered orbits (Bailey pair / q-recurrence
machinery — both sides are explicit); then check whether Seed 6's R-relations +
Uncu's series settle positivity for the 7 core orbits at d=8 outright. Success =
Q_n >= 0 for d=8, the largest tested case, WITHOUT solving the general bottleneck.
Read: prove-seed5-layer2.md, prove-seed6-layer2.md, seed5_R2L2_qn_d8.json.

**M5 — Wall orbits by involution on the compressed target (lineage S4+S7).**
Seed 7's N_2 Shape Theorem: after multiplying by (1+q^2+q^4), ALL negativity at n=2
is ONE negative coefficient per rank-3 profile, in three rigid sandwich factors.
Task: build the signed set for THIS compressed object (not the raw 4822-element
path space that defeated Seed 4) and find the involution killing the single bad
coefficient. Then lift n=2 -> general n via Seed 7's Master Recursion + Preimage
EMD Dichotomy. Warning from Seed 7: termwise pairing across profiles is impossible
(profile monotonicity false) — the involution must be within-profile or global.
Read: prove-seed7-layer2.md, prove-seed4-layer2.md.

**M6 — f_0^{(m)} >= 0 by crystal operators (lineage S8+S2).**
Seed 8's escalated lead after three failed injection designs (greedy ribbon,
claim-alpha, top-add — do NOT retry these, read why each failed). Task: realize the
chain model as a crystal (Tingley's affine crystal operators on chains), and look
for an operator whose image realizes the injection g_m-side into (1-q^m)g_m-side.
Seed 2's dead ends (per-orbit positivity, Abel chains, shifted domination) also
apply. This mission hedges M2: same statement, disjoint toolbox.
Read: prove-seed8-layer2.md (esp. the three failure post-mortems),
prove-seed2-layer2.md.

**M7 — WILDCARD: try to BREAK it (contrarian brief).**
Attempt to DISPROVE: (a) the MASTER conjecture at large m,k and large d (push
exact computation far beyond the verified range: d=13,16,17, m to 12+, using the
H-recursion in exact Z[q]); (b) the BFF conjecture on wall orbits (maybe a_n has a
negative coefficient somewhere — find it); (c) N_n >= 0 at larger n,d. Also stress
Uncu-match at n=7,8. Any counterexample immediately redirects the whole program;
confirmation at scale hardens YELLOW toward GREEN. This is the BA2 insurance:
Round 2's biggest win was overturning an "established" result, and consolidation
increases groupthink risk.
Read: synthesis-layer2.md §2 YELLOW list; pick the sharpest claims.

### Launch mechanics (delta from HANDOVER-layer1.md playbook)

- 7 background Agent calls in ONE message, all fable-inherit (no model param).
- Config line: `mission: MN, layer: 3, round: 2, rag: true` (seed field retired).
- Read list per mission as above, PLUS always: PROVE-SKILL.md (stale-path warning),
  problem-description/conjecture.tex, 2026-07-04/synthesis-layer2.md (layer input).
- Paths: scratch 2026-07-04/scratch/prove-m{N}-layer3.md; scripts
  2026-07-04/scratch/scripts/m{N}_R2L3_*; proofs/expository/notes/poetry as before.
- Arithmetic: PREFER exact Z[q] via the H-recursion (spot-check vs brute force at
  m<=3). Precision rule (PREC >= 6*max(k,m)^2 + 200) applies only where truncated
  series are unavoidable.
- Tell EVERY mission: RAG-search your exact target identity BEFORE computing
  (Uncu lesson). Require ## Handoff; report <200 words GREEN/YELLOW/RED.
- Missions 1 and 3 MUST receive the verifier verdicts (verify-layer2-disputes.md)
  in their brief — do not launch them before the verifier completes.
- After all 7: synthesizer (FABLE-INHERIT per Robin) -> 2026-07-04/synthesis-layer3.md;
  give it explicit adjudication questions; update root synthesis.md pointer.

## Agent IDs from Layer 2 (all completed; SendMessage can resume)

S1 a4102eaf472d1d4ed, S2 a110aefd8c3942801, S3 acc24c9e7b21fa8de, S4 a5074c8ea07c1fa3b,
S5 a0328a08475bb9797, S6 a20a39e97b7ceabf8, S7 aa2309dc9b2065179, S8 a7733062e933b1c2c,
synthesizer af77ef12793bf62f4, disputes verifier aee71e801febf0bef.

## Orchestrator lessons (added this layer)

- Cross-pollination notes between concurrently-running seeds (Seed 1's G-CW note
  recommending the frame to Seeds 3/6/7/8) cost nothing and paid off — encourage
  agents to write notes/ files addressed to sibling seeds.
- RAG-first remains the highest-ROI instruction: Uncu 2024 (Seed 5) did more for d=8
  than all computation combined. Tell every Layer 3 agent to RAG-search their exact
  target identity BEFORE computing.
- Give the synthesizer explicit convergence questions to adjudicate (six were given
  this layer; all six got answered). A bare "summarize" brief would have missed the
  Monotonicity ≡ f_0 equivalence.
- Robin's preferences: brief status updates as agents complete; tables for
  scoreboards; unicode math only, never LaTeX in terminal; ask before big launches;
  decisions about models go in the NEXT handover, not retro-edited into old ones.
