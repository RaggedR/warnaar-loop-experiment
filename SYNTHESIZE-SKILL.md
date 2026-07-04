---
name: synthesize
description: >
  Read all 8 agents' scratch files from a given layer, synthesize into a
  single document that the next layer's agents will read before starting.
  Identifies what worked, what failed, broken assumptions, and cross-agent
  connections.
---

# Synthesize: Cross-Pollination Between Agents

Read `agent-config.md` for your input and output configuration. There are two modes:

### Mode 1 — Layer synthesis (8 agents → 1 document)
- **Input**: `scratch/prove-seed{1..8}-layer{L}.md` and `scratch/assumptions-seed{1..8}-layer{L}.md` (if they exist)
- **Also read**: previous synthesis if it exists
- **Output**: `synthesis-layer{L}.md`

### Mode 2 — Sequential synthesis (1 agent → 1 document)
- **Input**: the single scratch file specified in `agent-config.md` (e.g. `scratch/prove-agentA.md`)
- **Also read**: all previous synthesis files (layer syntheses and any prior sequential syntheses). The full history is available to you — use it.
- **Output**: the file specified in `agent-config.md` (e.g. `synthesis-A-to-B.md`)

The structure below applies to both modes. For single-agent synthesis, skip the Connections section and focus on distilling the one agent's progress into clear next steps.

## Structure

### 1. What Was Tried
One paragraph per agent. State the seed, the approach, and how far they got. Be precise — name the techniques, the lemmas they attempted, the specific identities they invoked.

### 2. Partial Results
Anything that is genuinely proved or strongly supported by computation, even if it doesn't solve the full conjecture. These are building blocks for the next layer. Include:
- Lemmas that were proved (with verification status: GREEN/YELLOW/RED)
- Computational evidence (specific values, patterns discovered)
- Useful reformulations of the problem

### 3. What Failed and Why
For each failed approach, state:
- What was attempted
- The specific step where it broke
- Why it broke (broken assumption, missing lemma, wrong framework)
- Whether the failure is instructive (rules out a class of approaches) or incidental (bad execution of a viable idea)

**This section is critical.** The next layer must not repeat these failures.

### 4. Broken Assumptions
Collect all broken assumptions from the assumptions files. These are hard-won truths. List each one with:
- What was believed
- What is actually true
- Which agent discovered it

### 5. Connections
The most valuable part. Where did two or more agents independently touch the same structure? For example:
- Agent 2 (abacus model) and Agent 8 (transfer matrix) both needed a finite version of the same identity
- Agent 1 (Hall-Littlewood) and Agent 5 (Schubert) both reduced to q-binomial positivity

These intersections are where breakthroughs hide. Name them explicitly.

### 6. Recommendations for Layer {L+1}
Based on everything above:
- Which approaches should be pursued further?
- Which should be abandoned?
- Which connections should be explored?
- What specific computation or lemma would unblock the most agents?

## Sub-agents

You may spawn read-only sub-agents to help process the input files in parallel. Use them for:
- Summarising individual scratch files
- Extracting broken assumptions across multiple files
- Spotting connections between agents' approaches

Sub-agents report back to you — they do not write to `scratch/` or `synthesis-*.md`.

## Provenance (trust boundaries + citations)

You are the compression step, and compression is exactly where provenance
dies. Two mechanical duties (see `CITATIONS-README.md`, `REGISTRY-README.md`):

1. **Preserve citations verbatim.** When a scratch file cites
   `paper_slug/chunk_NNN` with a locator, your synthesis carries the full
   reference through — never compress it to an author name or "the identity
   in the literature." Trust qualifiers in `corrections` entries (e.g.
   "computer-assisted proof") must also survive into the synthesis.
2. **Update the registry.** `registry/warnaar.json` is the durable form of
   your sections 2-4: promote/demote nodes per the verifier reports (a node
   becomes `verified` ONLY with a `review` field pointing at the verify
   report), record new dead ends with `reason` + `refutation` level, and add
   `unclassified` children for old results the agents leaned on. The
   GREEN/YELLOW/dead items you write in prose should each correspond to a
   registry node.
3. **Backfill citations by use.** You are reading the scratch files at the
   cheapest possible moment to recover provenance — before it is another
   layer deeper. When a scratch file leans on an external result WITHOUT a
   `paper_slug/chunk_NNN` citation ("by Uncu's theorem...", "the CW
   recursion..."), spend the ten seconds: find the chunk
   (`python3 ../rag_query.py "..." --summaries-only`, or grep
   `../literature/chunks/<slug>/`), put the full reference into your
   synthesis, and register the paper in `sources.json` at its honest level.
   If you cannot find a chunk behind the claim, register the paper at
   `recalled` — that records, honestly, that nothing in the corpus backs it
   yet. Do NOT sweep old run directories; backfill only what this layer's
   files actually lean on.

Before writing the synthesis file, run and fix what is real:
```bash
python3 code/registry_validate.py registry/warnaar.json
python3 code/citation_check.py <the scratch files you read>
```
The frontier report (`--report frontier`) should agree with your
Recommendations section — if it doesn't, one of them is wrong.

## Rules

- **Be honest about failure.** A synthesis that hides failed approaches is worse than useless.
- **Be specific.** "Agent 3 tried a bijective approach" is useless. "Agent 3 tried to extend the Kursungoz-Seyrek decomposition to bounded cylindric partitions by restricting the abacus to n runners, but the bijection breaks when the cyclic interlacing condition forces beads across runner boundaries" is useful.
- **Preserve dissent.** If two agents reached contradictory conclusions about a technique's viability, report both views. Do not force consensus.
- **Do not invent.** You are synthesizing what the agents wrote, not doing new mathematics. If you notice a connection the agents missed, flag it in the Connections section, but clearly mark it as your observation, not theirs.
