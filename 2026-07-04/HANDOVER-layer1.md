# Handover — Round 2 Orchestrator, written after Layer 1 (2026-07-04)

You are the next orchestrator instance. Read this, then `synthesis.md` (root pointer),
then `2026-07-04/synthesis-layer1.md` in full. That synthesis is the input for Layer 2.

## Where we are

Round 2, Layer 1 is COMPLETE and synthesized. Layer 2 is NOT yet launched.

Pipeline: 8 seeded agents per layer → synthesis → next layer. Round 1 (2026-07-03/)
ran 3 layers + sequential agents A→B→C + final report. Round 2 Layer 1 ran today.

## Directory layout (reorganized today — old docs reference stale paths)

- Root `loop-experiment/`: shared skills (*-SKILL.md), problem-description/conjecture.tex,
  poetry/, graph.json, synthesis.md (pointer, kept current — update it after each synthesis).
- `2026-07-03/`: ALL Round 1 output (scratch/, syntheses, final-report.*). Read-only reference.
- `2026-07-04/`: Round 2. seeds/ (8 seed contexts + seeds.md), scratch/ (8 layer-1 scratch
  files + verify-hm-dispute.md + scripts/), synthesis-round1.md (Round 1 consolidation),
  synthesis-layer1.md (CURRENT STATE), notes/, expository/, proofs/, HANDOVER.md (this file).
- RAG tool: `python /Users/robin/git/experiments/waarnar/rag_query.py "query" --top-k 10`
- SageMath: `eval "$($HOME/miniforge3/bin/conda shell.zsh hook)" && conda activate sage && sage x.sage`
- Precision rule: q-series coefficients within deg of an alternating-sign multiplier of the
  truncation boundary are GARBAGE. Require PREC >= 6*max(k,m)^2 + 200. This bug caused
  Round 1's biggest false negative (see below).

## Layer 1 headline results (details + GREEN/YELLOW/RED in synthesis-layer1.md)

1. **BA2 REVERSED (the big one).** Round 1 claimed h_m < 0 for m >= 2 — killed Path A.
   FALSE: truncation artifact (Agent A, PREC=80). Seeds 3+8 refuted independently; a
   dedicated verifier agent confirmed by exact brute force (>95%). Unified statement:
   h_m = (q^ell;q^ell)_m * g_m >= 0 for ALL d, ell = gcd(d,3). **Path A REOPENED.**
2. **Adjugate Monomial Theorem PROVED** (Seed 4): adj(I-A(x))[c,c'] = x^{EMD(c,c')}.
   Proof via sign-reversing involution J -> J △ {k} on subgroup G_0 of (Z/2)^3.
3. **Positivity reduces to Warnaar's Conjecture 2** (Seed 6): (q;q)_n prefactor cancels
   1/(q;q)_{n_1} in the fermionic multisum. Exact polynomial match incl. unproved d=8, k=3.
4. **Explicit Q_1 formula + EMD equidistribution** (Seed 7): Q_1 = (1+q+q^2)^{-1} *
   sum_{c'} q^{EMD(c,c')} B(c'); EMD mod 3 is linear in profile => (1+q+q^2)-divisibility.
   Also full system inversion: g_{c,n} = (1-q^{3n})^{-1} sum_{c'} q^{n*EMD(c,c')} b_n(c').
5. **Key-decomposition strategy at (q,q^2,q^3) is VACUOUS** (Seed 1, upheld by synthesizer:
   kappa_{(k,0,0)} -> q^k, so any nonneg poly decomposes). Dead. Only a 3-variable lift
   would be contentful. Also: Q_n = q^{n^2} for d=2 (unproved, smells of Jacobi triple product).
6. **Crystal machinery computes F_{c,n}, not Q_n** (Seeds 2,5,6 convergent). Finite KR
   tensors overcount; naive Tingley truncation structurally fails (phi-map deterministic).
   The hard part lives entirely in the (zq;q)_inf extraction layer.

**Top-ranked path: prove h_m >= 0** — this single lemma implies Q_n >= 0 via the D_k^m
tower. Mechanism candidate: Seed 8's bracket f_0^{(m)} = (1-q^m)g_m - q*g_{m-1} is exactly
(m-1)-fold q-monotone. Second path: prove/import Warnaar's Conjecture 2.

## How to launch Layer 2 (the orchestrator playbook that worked)

Layer 2 missions per seed are in synthesis-layer1.md §5 — use those, they supersede
seeds.md rationales (several Layer-1 missions died).

Launch 8 background Agent calls IN ONE MESSAGE. Each prompt must contain (agents have
zero context):
1. First line: `First, read ~/.claude/AGENT.md for instructions.`
2. Working dir + inline config (`seed: N, layer: 2, round: 2, rag: true`) — do NOT use
   agent-config.md files (agents share a directory).
3. Read list: PROVE-SKILL.md (note: it references stale paths; give Round 2 paths),
   problem-description/conjecture.tex, **2026-07-04/synthesis-layer1.md** (the layer input),
   2026-07-04/seeds/seed_N_context.txt.
4. The specific mission from synthesis-layer1.md §5, verbatim-ish, plus relevant warnings.
5. Paths: scratch 2026-07-04/scratch/prove-seedN-layer2.md; scripts
   2026-07-04/scratch/scripts/seedN_R2L2_*; assumptions/expository/proofs paths; poetry/.
6. Tools block (RAG + SageMath commands above + precision rule).
7. Require a `## Handoff` section; report back <200 words with GREEN/YELLOW/RED.

After all 8 complete: launch synthesizer (opus) → 2026-07-04/synthesis-layer2.md,
update root synthesis.md pointer, use TaskCreate/TaskUpdate to track.

**Adjudication pattern (worked twice today):** when an agent contradicts an established
claim or another agent, immediately launch a small independent verifier agent (sonnet)
with instructions to recompute the SPECIFIC disputed instances by an INDEPENDENT method
(brute force, exact arithmetic) and cross-check all methods at low weight. Output to
2026-07-04/scratch/verify-*.md.

## Model provenance (record for experiment integrity)

- Round 1: orchestrator + all agents Opus.
- Round 2 Layer 1: orchestrator claude-fable-5; 8 seed agents + synthesizer explicitly
  `model: "opus"`; h_m verifier sonnet. Workers held constant vs Round 1 by design.
- **DECIDED (Robin, 2026-07-04):** Layer 2 workers INHERIT fable (claude-fable-5) — no
  `model` override. This intentionally breaks worker constancy with Round 1; record it in
  the session file. Still pending: write SESSION-2026-07-04.md at end of day (mirror
  2026-07-03/SESSION-2026-07-03.md format).

## Agent IDs from Layer 1 (all completed; SendMessage can resume them if needed)

S1 ad30a38260a50f42e, S2 a1b96dbf651356b4b, S3 a8fad0ced4e9601e4, S4 a2137a748d6b3cc9c,
S5 a33285383b5965a51, S6 a60e728833c63b807, S7 a0b7f4c12b2d9ff80, S8 a91604566596aa568,
verifier a62986f3c10d58d92, synthesizer a9ace08dd4265ae79.

## Orchestrator lessons (earned today)

- Generate the layer input by SYNTHESIZING the previous round's complete terminal output
  (including unsynthesized final agents!) — a pointer to stale syntheses propagates errors.
  Agent C's ell = gcd(d,3) fix nearly got lost this way yesterday.
- Tell computation-averse missions explicitly to COMPUTE (Round 1 flagged the A_2 identity
  three times without ever computing; Layer 1's Seed 3 brief fixed this and it paid off).
- Treat "established" negative results as adjudicable — Round 2's biggest win was
  overturning one.
- Robin's preferences: brief status updates as agents complete; tables for scoreboards;
  no LaTeX in terminal output (unicode math only); ask before big launches.
