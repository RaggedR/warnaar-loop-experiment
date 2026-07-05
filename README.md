# Warnaar Loop Experiment

Multi-agent iterative proof search for **Warnaar's Conjecture 2.7** — positivity of the coefficients of Q_{n,c}(q), the bounded generating function of cylindric partitions.

## Idea

Karpathy-style loop engineering applied to mathematical research. Each iteration is a fresh Claude agent that:

1. Reads `conjecture.tex` (definitions, Borodin's product formula, Corteel–Welsh q-difference equations) and the previous iteration's notes
2. Queries a RAG corpus of the surrounding literature from a new angle
3. Attempts a proof using a structured PROVE skill
4. Writes structured notes — what worked, what's stuck, what to query next — for the next iteration

Context is cleared between iterations; the notes files are the only memory. The experiment tests whether a chain of amnesiac agents with good note discipline can make cumulative progress on a hard open problem.

## Layout

- `problem-description/` — the conjecture and background
- `registry/`, `graph.json`, `sources.json` — literature registry and knowledge graph
- `code/`, `lean/` — computational checks and formalization attempts
- `2026-07-03/`, `2026-07-04/` — daily iteration runs
- `*-SKILL.md` — the agent skills (PROVE, DRAFT, EXPOSITORY, PEER-REVIEW, SYNTHESIZE, …)
- `synthesis.md`, `HANDOVER.md` — cross-iteration synthesis and session handovers

## License

MIT — see [LICENSE](LICENSE).
