# Proof Registry

This is a structured index for the Warnaar proof search. The loop system
already keeps this information informally: GREEN/YELLOW/dead item numbering
in the synthesis files (G13, Y11, D15...), verifier reports in
`*/scratch/verify-*.md`, sorry-free Lean declarations. The registry makes the
tree explicit so agents (and Robin) can query it instead of reconstructing it
from four layers of synthesis prose.

**One tree for the whole conjecture**: `registry/warnaar.json`. Each major
program (d=10 chain, d=8 fermionic, d=7 y-system, bounded Tingley,
N2/Harnack, beta-map, Lean glue) is a subtree under the root.

It is advisory tooling, not a mandate. The LaTeX proofs and scratch files
remain the primary artifacts; the registry is an index over them.

## Format

Each node of the search tree:

```json
{
  "id": "unique-within-the-tree",
  "approach": "one line: what this attempt is",
  "trust": "speculative | computed | proved | verified | lean-verified | dead-end | in-progress | unclassified",
  "file": "2026-07-04/proofs/prove-seed1-layer4.tex",
  "lean": "optional_sorry_free_declaration",
  "reason": "required iff trust is dead-end: why it died",
  "refutation": "optional, dead-end only: judgment | computed | proved | lean-verified",
  "review": "required iff trust is verified: verifier + path to the verify report",
  "sources": ["optional", "paper_slugs", "from", "sources.json"],
  "children": []
}
```

- `file` is relative to `loop-experiment/` and may be `null`.
- Top level: `conjecture`, `status` (mirrors the root's trust),
  `date_opened`, `date_closed`, `tree`.

## Trust levels and the boundary rule

Ordered: `speculative < computed < proved < verified < lean-verified`.
Outside the order: `dead-end` (must carry `reason`), `in-progress`, and
`unclassified` (a claim exists on disk; nobody has re-checked it).

- **speculative** — an idea; no evidence yet.
- **computed** — machine evidence, no proof (e.g. "verified for all n ≤ 12").
- **proved** — a written argument the author believes complete.
- **verified** — an INDEPENDENT verifier agent (or Robin) re-derived or
  hostile-reviewed the proof and endorsed it. Requires a `review` field
  naming the verifier and the report (e.g.
  `2026-07-04/scratch/verify-seed1-layer4.md`). A self-assigned label with
  no artifact is trust inflation; the validator rejects it. This maps the
  existing verifier-seed practice (SOLID / SOLID-WITH-ERRATA verdicts)
  directly onto a trust level.
- **lean-verified** — a sorry-free Lean declaration backs the node; name it
  in `lean`.

One caveat, preserved rather than resolved: verification and Lean check
*different things*. Lean verifies the formal statement as written; a verifier
checks that the statement means what you think it means. A `lean-verified`
node can still profit from review (the classic failure is a machine-checked
proof of the wrong statement). Treat the ordering as "strength of check on
what is on the page," not "nothing left to gain."

**Boundary rule:** a node may claim `proved` or above only if every
non-dead-end child is at least `proved`. Claims above the boundary are
justified by their subtrees; claims below it are exploratory. The G19
beta-map result is the canonical example: the injection is `proved`, but its
parent stays `in-progress` because lemma Q1 is an open child — the parent
cannot outrank the meet of its children.

## Backfilling by use: `unclassified`

The run directories (2026-07-03, 2026-07-04, ...) contain extensive
pre-registry results. Do NOT sweep through them; retroactive labels assigned
from synthesis prose are trust inflation. Backfill lazily:

- When a new attempt **cites an old result** not yet in the registry, add it
  as a child with `trust: "unclassified"` and `file` pointing at the old
  writeup. One node, ten seconds.
- `unclassified` ranks below `proved`, so the boundary rule does the rest:
  the new node cannot claim `proved` while it leans on an unchecked citation.
- To discharge, re-read the old proof and promote honestly: `computed`,
  `proved`, `dead-end` (with `reason`), or `lean-verified`.
- Before promoting, run
  `python3 code/citation_check.py --report footprint <old-file>`: register
  any unregistered papers in sources.json at their honest levels, lift the
  slugs into the node's `sources` field, then promote. The old file's
  literature debts transfer to the node instead of vanishing.

The seeded registry contains layer-4 standing results ONLY where artifacts
exist (verifier reports, proof .tex, Lean declarations) — no labels from
memory.

## Dead ends and the `refutation` field

Dead ends are first-class nodes, not embarrassments. A dead end with a good
`reason` carries information. But a `reason` is a claim too, and a wrong one
silently prunes a live branch — the most expensive error in a search. So
dead ends carry their own evidence level:

```
judgment < computed < proved < lean-verified
```

- **judgment** (default) — abandoned on taste/cost/three-strikes; no
  counterexample. Quietly revisitable when new tools arrive.
  Example: `d8-diff-positivity-direct` (D15) — three strikes, positivity
  still believed.
- **computed** — a checked counterexample exists; point `file` at it.
  Examples: `s1-at-3-divides-d` (har₁₃((1,1,1)) = −1),
  `y8-conjecture-a` (falsified by the label audit).
- **proved** — an impossibility argument; a theorem with a minus sign, safe
  to build on ("never retry this family").
  Example: `newman-local-confluence` (D13) — unbounded meet depths.
- **lean-verified** — the refutation is machine-checked.

When stuck, the frontier is not just the open nodes — it is the open nodes
*plus the judgment-level dead ends*. Re-check a judgment `reason` before
descending; never descend a `proved` one.

## External sources: the `sources` field

List the paper slugs a node leans on. They resolve against `sources.json`
(see CITATIONS-README.md), which records how deeply each paper was read:
`recalled < rag-summary < chunk-read < context-read < paper-read`.

External papers behave like `unclassified` children: cite freely, but they
carry a trust ceiling until checked. The validator flags a node at `proved`
or above whose cited sources are **all** below `context-read` — a RAG
chunk's summary line (or your training memory) is not a paper. The corpus is
on disk; context-reading costs one Read.

## Validator

```
python3 code/registry_validate.py registry/warnaar.json
python3 code/registry_validate.py registry/warnaar.json --report successful-path
python3 code/registry_validate.py registry/warnaar.json --report dead-ends
python3 code/registry_validate.py registry/warnaar.json --report frontier
```

Run from `loop-experiment/`. Checks: well-formed tree, valid trust values,
boundary rule, dead-end reasons, `verified` review artifacts, unique ids,
the sources ceiling, and that every `file` exists. Exit 0 = clean. Advisory:
fix what is real. Stdlib only.

- `--report successful-path` — the proved/verified/lean-verified skeleton
- `--report dead-ends` — every dead end with reason and refutation level
- `--report frontier` — open nodes: where work remains. **Synthesis agents:
  this report IS your mission list.**

## Why a tree with these operations (the mathematical reading)

The registry is a directed container (Ahman–Chapman–Uustalu). Shapes are
search trees, positions are paths: `root` is the conjecture, `sub(t, p)` the
sub-search at path p (dead ends included), `shift` is path composition. The
induced comonad: `extract` reads the root's trust ("is it proved?");
`duplicate` replaces every node with the full sub-search below it — the
complete history available at every depth, which is exactly what a fresh
layer-N agent needs. The three reports are coKleisli morphisms
W(Registry) → Report. Robin formalized this in Lean (`containers` repo,
`ProofSearchN.lean`: rose trees with arbitrary finite branching, all five
laws, no sorry).
