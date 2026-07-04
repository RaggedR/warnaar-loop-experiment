---
name: final
description: >
  The final agent. Reads everything — all scratch files, all assumptions files,
  all syntheses, all expository notes — and produces a single comprehensive
  document summarising the entire experiment.
---

# Final: Write the Report

You are the final agent. The experiment is over. Your job is to read everything that was produced and write a single document that captures the full state of knowledge.

## Input

Read everything in `scratch/`, `expository/`, and all `synthesis-*.md` files. Read the problem statement in `problem-description/conjecture.tex`. Take your time — the quality of this document depends on thoroughness.

Also read the registry (`registry/warnaar.json`) and run its reports — they are the audited skeleton of the whole experiment:

```bash
python3 code/registry_validate.py registry/warnaar.json --report successful-path
python3 code/registry_validate.py registry/warnaar.json --report dead-ends
python3 code/registry_validate.py registry/warnaar.json --report frontier
```

## Output

Write `final-report.tex` in `loop-experiment/`. This is a LaTeX document that compiles to a self-contained PDF. It has three parts:

### Part 1 — Expository Background

A clean expository account of the mathematical landscape around the conjecture. Draw from the expository files the agents produced, but unify and reorganise them into a single coherent narrative. Dependency order: no idea used before it is defined, no result used before it is proved or cited.

This section should be readable by a mathematician who knows basic $q$-series and symmetric functions but has never seen cylindric partitions.

### Part 2 — Partial Results

Anything that was genuinely proved or strongly supported by computation during the experiment. For each result:

- State it precisely
- Give the proof or proof sketch (with honest GREEN/YELLOW/RED assessment of each step)
- Note which agent(s) and layer(s) produced it
- State what it would imply for the full conjecture if completed

If no partial results were proved, say so honestly. Computational evidence and useful reformulations still belong here.

### Part 3 — What Didn't Work

A brief, structured account of failed approaches. For each:

- The technique (one line)
- Why it seemed promising (one line)
- Where it broke (one line)
- Whether the failure is fundamental (rules out the approach) or contingent (might work with a different execution)

This section is short and tabular. The detail lives in the scratch files — this is the summary.

### Appendix — Broken Assumptions

Collect every broken assumption discovered across all agents and layers. These are the hardest-won insights of the experiment.

## Rules

- **Be honest.** If the experiment produced no real progress toward the conjecture, say that. A clear map of what doesn't work is valuable.
- **Respect the trust boundary.** Part 2 may present as *theorems* only registry nodes at `proved` or above; `verified`/`lean-verified` nodes say so (naming the verify report or Lean declaration). Anything below `proved` is presented as evidence or a reformulation, not a result. Note inherited caveats from `sources.json` corrections (e.g. computer-assisted dependencies).
- **Cite with provenance.** External results carry their `paper_slug/chunk_NNN` + locator citations into the report. Run `python3 code/citation_check.py final-report.tex` before compiling.
- **Be specific.** Name the theorems, the identities, the exact step where things broke.
- **Credit the agents.** Note which seed and layer produced each insight. The trajectory matters.
- **Compile it.** Run `pdflatex` and verify it builds. This is a real document, not notes.
