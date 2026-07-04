# Loop Experiment: Iterative Proof Search for Warnaar's Positivity Conjecture

## Goal

Use Karpathy-style loop engineering to search for a proof of Warnaar's Conjecture 2.7 (positivity of Q_{n,c}(q) from cylindric partitions). Each iteration is a fresh agent that reads the previous iteration's notes, queries the RAG corpus from a new angle, attempts a proof, and writes structured notes for the next iteration.

## The Conjecture

Every agent receives a shared LaTeX file (`conjecture.tex`) containing:
- Definition of cylindric partitions of profile c
- Borodin's product formula for the generating function F_c(z,q)
- The Corteel-Welsh q-difference equations
- Definition of Q_{n,c}(q) as the bounded generating function
- The positivity conjecture: all coefficients of Q_{n,c}(q) are non-negative

## Architecture

### Single Loop (Baseline)

```
                    +------------------+
                    |                  |
                    v                  |
conjecture.tex --> [Agent] --> notes/iteration_NNN.md
                    |                  ^
                    v                  |
                  [RAG] -----> seed context
```

Each iteration:
1. Agent reads `conjecture.tex` + `notes/iteration_{N-1}.md` (the most recent notes)
2. Agent extracts the "next query" field from the previous notes
3. Agent queries the RAG corpus with that query, retrieves relevant chunks
4. Agent attempts a proof using the PROOF skill (from Clio)
5. Agent evaluates: what worked, what's stuck, what's promising
6. Agent writes `notes/iteration_{N}.md` with structured output (see format below)
7. Context is cleared. Next iteration begins.

### Wrapper Script

A bash/python script (`loop.sh` or `loop.py`) that:
- Maintains an iteration counter
- Spawns a fresh Claude instance per iteration
- Passes: `conjecture.tex` + latest notes file + RAG access
- Monitors for the "done" signal (notes file written)
- Logs token usage per iteration
- Stops after N iterations or on termination signal (see below)

### Termination

The loop ends when any of:
1. **Max iterations reached** (configurable, default 20)
2. **Agent claims proof found** — writes `notes/SOLVED.md` instead of `notes/iteration_NNN.md`
3. **Agent gives up** — writes `notes/STUCK.md` after exhausting approaches

When the agent believes it has a proof, it must:
1. Write the proof as LaTeX in `notes/proof_attempt_NNN.tex`
2. Run the Verify phase from the PROVE skill (RED/YELLOW/GREEN audit, reconcile with computation)
3. Only if ALL steps are GREEN, write `notes/SOLVED.md` containing:
   - The one-line claim
   - Which iteration found it
   - Which RAG seed led to the breakthrough
   - A self-assessed confidence level (1-10)
   - Any steps that feel "close to YELLOW"

The wrapper script, on seeing `SOLVED.md`, does NOT stop immediately. It spawns **one final verification iteration** — a fresh agent that reads ONLY `SOLVED.md` + `proof_attempt_NNN.tex` + `conjecture.tex` (no previous iteration notes) and acts as a hostile referee using the peer-review skill (see `PEER-REVIEW-SKILL.md`, adapted from The Claude Journal's peer review protocol). The referee scores Correctness on a 1-5 scale and must identify every gap with a specific location and suggested fix. If Correctness < 4, it writes `notes/REFUTED.md` explaining the gaps, and the loop resumes from where it left off with the refutation as context for the next iteration. The refuted proof attempt and the referee's critique become the "previous notes" — the next agent inherits both the partial proof and the specific gaps to address.

A maximum of **3 referee rejections** is allowed per run. If a fourth SOLVED claim is made, it is **automatically accepted** without review — the assumption being that three rounds of refutation-and-revision have hardened the proof sufficiently, and further refereeing risks an infinite reject loop between two agents that disagree on what constitutes a gap.

### Heartbeat

The wrapper checks for output every 60 seconds. If the agent hasn't written anything in 10 minutes, it kills and restarts. The agent should write a partial notes file early (within the first 2 minutes) to signal it's alive, then update it as it progresses.

## Notes File Format (Progressive Disclosure)

Each iteration produces `notes/iteration_NNN.md`:

```markdown
# Iteration NNN

## One-Line Summary
<!-- 1 sentence: what this iteration tried and what happened -->

## Executive Summary
<!-- 3-5 sentences: the approach, key insight or failure mode, 
     what the next agent should know -->

## Previous Query
<!-- The RAG query that seeded THIS iteration -->

## Next Query
<!-- The RAG query the NEXT iteration should use.
     This is the most important creative decision each agent makes. -->

## Approach Taken
<!-- Which proof strategy was attempted.
     Tag it: bijective | analytic | algebraic | crystal-base | 
     generating-function | representation-theoretic | other -->

## Detailed Notes
<!-- Full working: what was tried, partial results, 
     where it got stuck, relevant lemmas discovered.
     An agent only reads this section if the executive summary 
     suggests it's relevant to their current approach. -->

## Retrieved Context
<!-- Which RAG chunks were retrieved and used.
     Paper name + chunk number + 1-line description. -->

## KG Exploration (optional)
<!-- Only filled if the agent consulted the concept index.
     Lists which topic clusters were visited vs unvisited. -->
```

### Progressive Disclosure Rule

A new agent reads the notes from the previous iteration in order:
1. Always read: One-Line Summary, Executive Summary, Next Query
2. Read if relevant: Approach Taken, Retrieved Context  
3. Read only if pursuing the same thread: Detailed Notes

An agent MAY also read older iterations' One-Line Summaries (just `head` the files) to avoid repeating approaches. It should NOT read all detailed notes from all iterations -- that defeats the purpose of context clearing.

## RAG Corpus

The vector database is built from the chunked + summarized LaTeX corpus at:
```
waarnar/literature/chunks/
```

~81 papers, ~7,000 chunks, each with a contextual summary. Embedded using a custom BERT model. The same model is used for:
- Retrieval (cosine similarity for seed queries)
- Diversity measurement (cosine distance between iteration outputs)

## Knowledge Graph

When the loop agent is stuck on what query to make next, it can consult the **knowledge graph** — built from the corpus using the `/knowledge-graph` skill. The KG maps papers, theorems, techniques, and definitions as nodes with edges for citations, shared methods, and logical dependencies.

**Usage rule**: The agent should choose its next query from its own reasoning by default. If it doesn't have a clear next direction, it MAY consult the knowledge graph to find unexplored areas of the literature.

**Status**: Not yet built. Will be generated after summarization is complete.

**Text representation**: The `/knowledge-graph` skill produces an interactive D3.js visualization, but the loop agent runs in a terminal and can't browse a web page. After building the KG, we export a text-based adjacency list that the agent can grep/read:

```
# node: paper or concept
# edges: related nodes with edge type

warnaar_A2_andrews_gordon:
  - corteel_welsh_A2_RR [cites, shared_recurrence]
  - bartlett_warnaar [cites, Hall-Littlewood]
  - kanade_russell_tsuchioka [cites, CMPP_conjectures]
  - technique:q-difference_equations
  - technique:cylindric_partitions
  - concept:positivity

technique:Hall-Littlewood:
  - bartlett_warnaar [primary]
  - griffin_ono [character_formulas]
  - cuenca [interpolation]
  - hoshino_shiraishi [branching]
```

This file lives at `knowledge-graph/graph.txt` and is passed to the loop agent alongside `conjecture.tex`.

The notes format includes an optional field:

```markdown
## KG Exploration (optional)
<!-- Only filled if the agent consulted the knowledge graph.
     Lists which areas were visited vs unvisited. -->
```

## Seed Selection

The first iteration's query is hand-picked (e.g., "cylindric partition bijective proof positivity"). Subsequent queries are chosen by the agent based on what it learned. This is the key creative act -- the agent decides where to look next.

## Evaluation

After N iterations, we measure:
1. **Depth**: Did any iteration get closer to a proof than iteration 1?
2. **Diversity**: Pairwise cosine distance between iteration outputs (using the same BERT model as RAG)
3. **Convergence**: Do the approaches converge to a fixed point or keep exploring?
4. **Serendipity**: Did any iteration discover a connection not present in its seed?

## Clio's PROOF Skill

Each agent uses Clio's structured proof skill, which provides:
- Formal hypothesis statement
- Strategy selection (with justification)
- Step-by-step argument construction
- Gap identification (where the proof breaks down)
- Confidence assessment

The proof skill is invoked as a subroutine within the iteration, not as the outer loop controller.

## Relationship to the Topology Experiment

This loop experiment is the **depth-first** complement to the topology experiment (breadth-first):

| | Loop Experiment | Topology Experiment |
|---|---|---|
| Agents | 1 (serial) | k (parallel) |
| Seeds | Adaptive (agent chooses next) | Fixed (k-medoids) |
| Measures | Depth, convergence | Diversity across agents |
| Topology | Trivial (self-loop) | Chain / Star / Loop baseline |
| Context | Cleared each iteration | Fresh per agent per sweep |

A natural follow-up combines both: k agents in a topology, each running an inner loop. But that's a later experiment.

## Files

```
loop-experiment/
  PLAN.md              # This file
  conjecture.tex       # Shared problem statement (to be written)
  knowledge-graph/     # KG of the corpus (built via /knowledge-graph)
    index.html         # Interactive D3.js visualization
    graph.txt          # Text adjacency list for the loop agent
  loop.sh              # Wrapper script (to be written)
  notes/               # Output directory
    iteration_001.md
    iteration_002.md
    ...
  analysis/            # Post-hoc analysis scripts
```

## Open Questions

1. How many iterations before diminishing returns? (Guess: 10-20)
2. Should the agent have access to SageMath for computational verification?
3. Should we constrain the agent to one proof strategy per iteration, or let it mix?
4. How to handle the case where an agent "thinks" it proved it but the proof has a gap?
5. Should older iterations' One-Line Summaries be concatenated into a running log, or should the agent grep them on demand?
6. What granularity for KG nodes? Paper-level is easy to generate but coarse. Theorem-level captures more structure but needs careful extraction from the chunks.
