# Orchestration Plan

## Goal

Attack Warnaar's positivity conjecture for bounded cylindric partition polynomials Q_{n,c}(q) using a multi-agent proof exploration system. The conjecture is stated in `problem-description/conjecture.tex`.

## Root directory

All paths below are relative to `~/git/experiments/waarnar/` (the parent of `loop-experiment/`).

## Infrastructure (already built)

### Corpus
- **82 papers** chunked into **7,037 chunks** (after filtering 349 bibliography chunks) at `literature/chunks/`
- **Embeddings**: fine-tuned SPECTER2 model at `waarnar-embed/final/`, cached embeddings at `chunk_embeddings.npz`
- **RAG query tool**: `rag_query.py` in the root directory — takes a natural language query, returns top-k relevant chunks from the corpus

### Seeds
- **8 seed chunks** selected by k-medoids clustering on the embeddings (see `seeds.txt` in root)
- Each seed represents a different region of the literature:
  1. Hall-Littlewood specialisations (Bartlett-Warnaar) — cluster 2461
  2. Partition-bead bijections (Tingley) — cluster 747
  3. Skew RSK dynamics (Imamura) — cluster 504
  4. Bilateral Rogers-Ramanujan (Schlosser) — cluster 252
  5. Schubert polynomials (Lascoux) — cluster 260
  6. Nandi conjecture, mod-14 identities (Takigiku-Tsuchioka) — cluster 1658
  7. Vertex operators, D₄⁽³⁾ (Tsuchioka) — cluster 405
  8. Plane partitions, lozenge tilings (Hopkins-Lai) — cluster 750

### Initial RAG synthesis
- `rag-output/seed_explorations.pdf` — 25-page document with 8 research notes, one per seed, exploring proof strategies. Each section was written by a separate agent reading 20 retrieved chunks + the conjecture.
- Individual sections at `rag-output/seed_{1..8}_section.tex`
- Retrieved context at `rag-output/seed_{1..8}_context.txt`

### Skills (all in `loop-experiment/`)
- **PROVE-SKILL.md** — main proof protocol. Phases: Compute → Conjecture → Strategy → Attempt → Stuck Protocol → Verify → Write Up. Reads `agent-config.md` for identity, `synthesis.md` for prior knowledge. Can spawn sub-agents with write permission. If `rag: true` in config, can query the RAG.
- **ASSUMPTIONS-SKILL.md** — enumerate all assumptions when stuck. Writes to separate `scratch/assumptions-seed{N}-layer{L}.md` file, appends not overwrites.
- **EXPOSITORY-SKILL.md** — write pedagogical documents at `expository/expository-seed{N}-layer{L}.tex`. The retreat when stuck.
- **DRAFT-SKILL.md** — iterative thinking through files. Dump → Structure → Correctness → Clarity passes.
- **SYNTHESIZE-SKILL.md** — two modes: (1) layer synthesis: reads 8 scratch files, writes `synthesis-layer{L}.md`; (2) sequential synthesis: reads 1 scratch file, writes e.g. `synthesis-A-to-B.md`. Can spawn read-only sub-agents.
- **FINAL-SKILL.md** — reads everything, writes `final-report.tex` with expository background, partial results, failed approaches, and broken assumptions.

### Other files
- `poetry/` — Byron and Wilde texts. Agents read random excerpts when stuck.
- `scratch/scripts/` — directory for reusable Python computation scripts

## Architecture

### Phase 1 — Seeded exploration (3 layers)

**Layer 1**: 8 agents run in parallel. Each gets:
- `agent-config.md` with seed number (1-8), layer (1), `rag: false`
- The seed from `seeds.txt` (or the corresponding `rag-output/seed_{N}_context.txt`)
- PROVE-SKILL.md
- `problem-description/conjecture.tex`

Each writes to `scratch/prove-seed{N}-layer1.md`.

**Synthesis 1**: Synthesizer reads all 8 scratch files → writes `synthesis-layer1.md`.

**Layer 2**: Same 8 agents. Each reads `synthesis-layer1.md` + their original seed. Writes to `scratch/prove-seed{N}-layer2.md`.

**Synthesis 2**: → `synthesis-layer2.md`

**Layer 3**: Same pattern. → `synthesis-layer3.md`

### Phase 1b — Sequential autonomous agents (A → B → C)

Run in parallel with Phase 1 or after it. Three agents run sequentially, each generating their own RAG queries:

- **Agent A**: `agent-config.md` has `rag: true`, agent name `A`. Reads all available syntheses. Generates own queries via `rag_query.py`. Writes to `scratch/prove-agentA.md`.
- **Synthesizer**: reads A's output + all previous syntheses → writes `synthesis-A-to-B.md`
- **Agent B**: reads `synthesis-A-to-B.md` + all previous syntheses. `rag: true`. Writes to `scratch/prove-agentB.md`.
- **Synthesizer**: → `synthesis-B-to-C.md`
- **Agent C**: reads `synthesis-B-to-C.md` + all previous syntheses. `rag: true`. Writes to `scratch/prove-agentC.md`.

### Phase 2 — Autonomous querying (3 more layers)

Layers 4-6: Same 8 agents, but now with `rag: true`. They generate their own queries to the RAG based on where their proof attempts are heading. Each layer has a synthesis step.

### Phase 3 — Final report

The final agent reads ALL scratch files, ALL synthesis files, ALL assumptions files, ALL expository files. Writes `final-report.tex` — a LaTeX document with:
1. Expository background
2. Partial results (with GREEN/YELLOW/RED verification)
3. What didn't work and why
4. Appendix of broken assumptions

## How to run

Each agent needs an `agent-config.md` in its working directory. Example for seed 3, layer 1:

```markdown
seed: 3
layer: 1
rag: false
```

Example for agent A:

```markdown
agent: A
rag: true
input: []
output: scratch/prove-agentA.md
```

Example for the layer synthesizer:

```markdown
mode: layer
layer: 1
input: scratch/prove-seed{1..8}-layer1.md
output: synthesis-layer1.md
```

Example for the sequential synthesizer:

```markdown
mode: sequential
input: scratch/prove-agentA.md
output: synthesis-A-to-B.md
```

## Key scripts (all in root `~/git/experiments/waarnar/`, NOT in `loop-experiment/`)

- `seed_chunks.py` — embed chunks + k-medoids clustering → `seeds.txt`
- `retrieve_seeds.py` — retrieve top-k chunks per seed → `rag-output/seed_{N}_context.txt`
- `rag_query.py` — standalone RAG query tool. Agents call it as `python ../rag_query.py "query" --top-k 10`
- `chunker.py` — LaTeX chunker that produces the corpus

## What we're hoping to learn

We don't expect to prove the conjecture. We expect to:
- Map which proof strategies fail and why
- Discover broken assumptions about the objects
- Find connections between different regions of the literature
- Identify the real obstruction to positivity
- Produce a readable document summarising the state of the art
