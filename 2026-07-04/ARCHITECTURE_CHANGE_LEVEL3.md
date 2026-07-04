# Architecture Change — Layer 3, Round 2 (2026-07-04)

Records the change between Layers 1–2 and Layer 3 of Round 2, its reasoning, and its
decision trail. Written by the Round 2 Layer 2 orchestrator (claude-fable-5).
Companions: HANDOVER-layer2.md (launch mechanics), seeds-layer3/seeds.md (the new
seeds), synthesis-layer2.md (the mathematical state that motivated the change).

## 1. The architecture (unchanged)

A **seed** is a RAG query + rationale. Running the query against the literature
corpus produces `seed_N_context.txt` (top-20 chunks), which becomes the agent's
opening literature context alongside its mission brief. 8 seeded agents run in
parallel per layer → scratch files with `## Handoff` → synthesizer → next layer.

This mechanism is UNCHANGED in Layer 3. Same agent count (8), same file
conventions, same pipeline. What changed is the CONTENT of the seeds.

## 2. What changed: seed targeting

**Layers 1–2 seeds** (`seeds/seeds.md`, generated from Round 1): spread across five
distinct proof paths — key polynomials, KR crystals, A2 functional equations, EMD/
adjugate structure, crystal bijections, fermionic formulas, Gaussian elimination,
Ehrhart theory. Design intent: EXPLORATION — no one knew where the proof lived.

**Layer 3 seeds** (`seeds-layer3/seeds.md`, generated from Layer 2): all eight
target the SINGLE path Layer 2 zeroed in on —

> H_{c,m} := (q;q)_m F_{c,m} is coefficientwise monotone in m
> (≡ f_0^(m) >= 0 ≡ first level of the Bounded Fermionic Form conjecture),
> plus its two concrete endgames: d=4 (smallest unsolved) and d=8 (Uncu's series).

Design intent: EXPLOITATION — diversity of *toolbox* within one path, rather than
diversity of *path*:

| Seed | Toolbox on the path |
|------|--------------------|
| 1 | Finite Rogers-Ramanujan polynomials, q-Pascal recurrences (U-tower strike) |
| 2 | A2 Bailey machinery, Kanade-Russell mod-11 (d=8 endgame via Uncu) |
| 3 | Combinatorial injections for coefficientwise q-series inequalities |
| 4 | Sign-reversing involutions on Seed 7's compressed one-bad-coefficient target |
| 5 | Crystal operators on chains (Tingley) for f_0^(m) >= 0 |
| 6 | CW R-relations and positivity propagation (finish d=4) |
| 7 | Gauss q-binomial inversion, bounded-to-unbounded foundations (BFF rigor) |
| 8 | ADVERSARY: stress-test/disprove MASTER, BFF, N_n at scale |

Seed 8 is a structural novelty: an agent whose success condition is BREAKING the
consensus. Insurance against groupthink now that all agents share one target.

## 3. Why re-seed rather than keep the old seeds

1. **Convergence.** Layer 2's Seeds 2/3/4 independently reached the same object
   (the H-tower) from different viewpoints. The convergence is banked; keeping
   three viewpoint-seeds aimed at territory that has merged wastes agents.
2. **Dead territory.** Key polynomials (BA17) and crystal bijections (BA18) are
   proved dead. Their seeds' Layer 2 missions were already re-assignments.
3. **A named bottleneck.** The problem is now one statement plus two endgames.
   Literature context should be retrieved FOR that statement, not for the old map.

## 4. The alternative considered and rejected

The orchestrator first proposed replacing the 8-seed scheme with 6+1 mission briefs
(no seed files, missions carrying inline context, lineages merged). Robin proposed
the better design adopted here: keep the 8-seed architecture, regenerate seed
content aimed at the fruitful path. Advantages of Robin's version:
- The experiment's architecture stays constant across layers (seeds were always
  regenerable content — they were regenerated between Round 1 and Round 2 too).
- Fresh RAG contexts re-ground every agent in literature relevant to the NEW
  target (the mission redesign would have reused stale literature contexts or none).
- Retains capacity for viewpoint surprise, which produced Round 2's biggest wins
  (BA2 reversal; the Uncu discovery).

The rejected design is preserved in git history / earlier versions of this file
for the experiment record.

## 5. What did NOT change

- 8 parallel background agents, zero shared context, full read lists in prompts.
- Scratch discipline: write-as-you-go, `## Handoff`, <200-word GREEN/YELLOW/RED.
- Synthesis with explicit adjudication questions; root synthesis.md pointer;
  handover at each orchestrator boundary.
- Adjudication: independent sonnet verifier recomputing disputed instances from
  definitions by independent methods.
- Model policy (Robin, 2026-07-04): workers + synthesizers fable-5 (inherit),
  verifiers sonnet.
- Old seeds retired but preserved at `seeds/` for the record.

## 6. Cost of the change (recorded honestly)

- Layer-3-vs-Layer-2 comparisons now confound seed-targeting strategy with
  mathematical progress (in addition to the worker-model change at Layer 2).
  Accepted trade-off: this is a proof effort first, an experiment second.
- Narrower retrieval: if the proof lives outside the H-tower path after all,
  Layer 3's literature contexts won't see it. Seed 8 (adversary) partially
  compensates — a counterexample would force re-broadening at Layer 4.

## 7. Decision trail

1. Layer 2 synthesizer recommended consolidating to ~6 focused agents.
2. Orchestrator proposed 6 missions + 1 wildcard, wrote briefs into
   HANDOVER-layer2.md.
3. Robin proposed re-seeding instead: "generate 8 new seeds specifically related
   to that path." Orchestrator agreed it dominates the mission design (§4).
4. New seeds written (seeds-layer3/seeds.md), contexts generated via RAG
   (top-20 per query), this document rewritten to record the adopted design.
5. Launch approved by Robin ("yes", 2026-07-04).
