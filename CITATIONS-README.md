# Citations

This is a provenance convention for external facts in the loop experiment.
Your knowledge of the literature arrives through the RAG (`../rag_query.py`),
which returns chunks named `paper_slug/chunk_NNN.tex`. The problem is what
happens *after*: each synthesis layer compresses eight scratch files, and
citations are exactly the kind of detail compression eats. By layer 4,
"(uncu_proofs_modulo11_13_cylindric_kanade_russell/chunk_031, thm:m13)" has
degraded into "Uncu's proved identity" — and after one more layer there is no
way to check where that came from, or whether it was ever read correctly.

This system's motivating incidents come from its sibling deployments (Clio,
MacBeth): a browse agent extracted an "LGV determinant" from a paper that
contains no determinant at all; the phantom survived two consolidation cycles
and became load-bearing before a voluntary re-read caught it. The convention
makes that catch mechanical instead of lucky. The loop system has its own
standing example of a trust qualifier that must survive compression:
provenance caveat N1 — Uncu's thm:m13 is a computer-assisted proof, and every
result resting on it (G13, G14) inherits that dependency.

It is advisory tooling, not a mandate. Same spirit as the proof registry.

## The convention

**A citation is a chunk reference plus a locator, at the point of use.**

> ...the Pochhammer split lands verbatim on Uncu's H identity
> (uncu_proofs_modulo11_13_cylindric_kanade_russell/chunk_031, thm:m13)...

- Author names alone are not citations for claims. "Uncu's mod-13 theorem" is
  a memory aid; the chunk reference is a citation. Use both, but never only
  the first when the claim matters.
- The locator (Thm/Prop/Eq/label) is what makes a claim *checkable*. A bare
  slug says "somewhere in this paper"; after two syntheses that degrades into
  "somewhere in the literature."
- This applies wherever claims live: scratch files, synthesis files, proof
  `.tex` files. The chunk reference resolves on disk at
  `../literature/chunks/<slug>/chunk_NNN.tex` — checking a citation costs one
  Read, not a library trip. Use that.

## Extraction levels

Every source in `sources.json` carries one level — how the knowledge got to
you, which bounds how much you should trust it:

```
recalled < rag-summary < chunk-read < context-read < paper-read
```

- **recalled** — from your own training memory; no chunk behind it. You will
  do this constantly ("by Corteel–Welsh..."). It is fine for orientation, but
  it is the weakest level: unversioned, unlocatable, possibly conflated.
  If the paper is in the corpus, find the chunk and upgrade.
- **rag-summary** — you saw only the chunk's one-line summary
  (`--summaries-only`). Summaries are agent-generated; they hallucinate.
- **chunk-read** — you read the retrieved chunk verbatim. The text is real,
  but a chunk is a window: the theorem's hypotheses and notation may live in
  a chunk that was NOT retrieved. This is the characteristic RAG failure.
- **context-read** — you read the surrounding chunks and checked that the
  statement's hypotheses and notation are what you think they are.
- **paper-read** — you worked through the relevant section or paper
  (e.g. the layer-4 agents reading Warnaar's Prop_finiteform at line level).

The rule of thumb: **a fact below `context-read` may not be load-bearing.**
Cite it, explore with it, let it steer queries — but before a registry node
at `proved` or above rests on it, context-read the source. The specific
hazard is misapplying a theorem whose standing conventions (variable ranges,
normalizations, root-system conventions) were set two chunks earlier.

## sources.json

One index at `loop-experiment/sources.json`, keyed by paper slug (the
directory name under `../literature/chunks/`):

```json
{
  "format": "loop-sources-v1",
  "sources": {
    "uncu_proofs_modulo11_13_cylindric_kanade_russell": {
      "title": "Proofs of modulo 11 and 13 cylindric Kanade-Russell conjectures",
      "authors": "Uncu",
      "extraction": "paper-read",
      "read": ["2026-07-04/scratch/prove-seed1-layer4.md"],
      "locators": ["thm:m13", "S11(e_s|e_t)"],
      "corrections": [
        { "date": "2026-07-04",
          "note": "N1: thm:m13 is computer-assisted (ideal-membership certificates); results resting on it inherit that dependency." }
      ]
    }
  }
}
```

- `read` — files (relative to `loop-experiment/`) where you engaged with it.
  Append on re-reads.
- `extraction` — the *highest* level attained. A context-read upgrades a
  rag-summary entry.
- `locators` — the parts of the paper you have actually used.
- `corrections` — **never delete a wrong extraction; record it.** A deleted
  wrong claim can be re-hallucinated by the next synthesis; a recorded wrong
  claim cannot. Trust *qualifiers* (like N1 above) also live here — anything
  that must not be compressed away.
- Papers NOT in the corpus that you cite from memory: enter them at
  `recalled`. The validator skips the on-disk check for those.
- Maintenance is cheap: new paper in a RAG session → one entry, ten seconds.

## Backfilling

Do NOT sweep old run directories. Backfill by use: when a new scratch file,
synthesis, or proof cites a paper not yet in sources.json, add it at the
honest level (usually `chunk-read` if you read the retrieved chunk). Files
nothing cites stay unindexed — fine.

## Validator

```
python3 code/citation_check.py                              # validate index
python3 code/citation_check.py <files...>                   # + refs resolve in index AND on disk
python3 code/citation_check.py --report footprint <files>   # per-file provenance floor
python3 code/citation_check.py --report shallow <files>     # context-read worklist
```

Run from `loop-experiment/` (or pass `--root`). The on-disk check catches
hallucinated chunk references outright — a cited chunk that does not exist in
the corpus is an error, not a warning. Advisory: exit 0 = clean. Stdlib only.

- `--report footprint` — each source a file cites, its extraction level,
  correction flags, and the file's **provenance floor** (the lowest level
  among its citations — the trust ceiling the file inherits).
- `--report shallow` — every below-`context-read` source the given files lean
  on: your reading worklist, ordered by how many files lean on each.

## Composing with the proof registry

Registry nodes (`registry/warnaar.json`) take an optional `"sources"` field
listing paper slugs. `code/registry_validate.py` flags a node at `proved` or
above whose cited sources are all below `context-read` — the external
analogue of the boundary rule. An external paper is a subtree you cannot see
into; the extraction level is the trust of its root.

## Why this shape (the mathematical reading)

The pipeline scratch → synthesis → proof is a chain of container morphisms:
each stage maps shapes forward (claims get restated, files reorganized) and
positions **backward** — "where did this claim come from?" is precisely
pulling a position back along the chain. A citation is the cached value of
that pullback. A synthesis that drops citations is a shape map with no
position map: it tells you what is claimed but forgets the functor that
answers where. Keeping slug + chunk + locator through every rewrite is what
makes the whole chain a genuine morphism rather than a lossy summary.
