# CLAUDE.md — Warnaar Loop Experiment

## What this is

A multi-agent iterative proof search for Warnaar's A2 Andrews-Gordon
positivity conjecture: all coefficients of Q_{n,c}(q) are non-negative.
The search runs in layers (scratch -> synthesis -> proof .tex), with a
RAG pipeline (`../rag_query.py`) providing literature access via chunk
retrieval from `../literature/chunks/`.

## Trust system

The experiment uses the trust-boundary system (Ahman-Chapman-Uustalu
directed containers). The registry at `registry/warnaar.json` is a
directed container whose boundary rule is stable under duplicate
(Lean: `ok_sub` in `TrustBoundary.lean`).

### Trust chain

```
speculative < computed < proved < verified < lean-verified
```

Boundary at `proved`. `verified` means an independent verifier agent (or
Robin) hostile-reviewed the proof — requires a `review` field.

### Role fields (the tree pair)

Every non-root registry node carries `"role": "premise"` or
`"role": "attempt"`:
- **premise** — the parent's proof depends on this. Boundary rule checks
  premises.
- **attempt** — an approach that was tried. Dead ends are always attempts.
  Boundary rule skips attempts.

### Extraction chain (RAG-specific)

```
recalled < rag-summary < chunk-read < context-read < paper-read
```

Blocking: below `context-read` blocks `proved`. A fact from a chunk
summary or training memory may not be load-bearing — the theorem's
hypotheses may live in an unretrieved chunk.

## Validators

### Generic validator (directed container ops)

```bash
# Validate the registry
python3 code/trustcheck.py --deployment code/loop.json validate registry/warnaar.json

# Directed container operations
python3 code/trustcheck.py --deployment code/loop.json ops extract registry/warnaar.json
python3 code/trustcheck.py --deployment code/loop.json ops sub registry/warnaar.json 0
python3 code/trustcheck.py --deployment code/loop.json ops duplicate registry/warnaar.json
python3 code/trustcheck.py --deployment code/loop.json ops tau registry/warnaar.json
python3 code/trustcheck.py --deployment code/loop.json ops strength registry/warnaar.json

# Reports
python3 code/trustcheck.py --deployment code/loop.json report successful-path registry/warnaar.json
python3 code/trustcheck.py --deployment code/loop.json report dead-ends registry/warnaar.json
python3 code/trustcheck.py --deployment code/loop.json report frontier registry/warnaar.json
```

### Per-experiment validators (legacy, still work)

```bash
python3 code/citation_check.py                              # validate sources.json
python3 code/citation_check.py <files...>                   # + resolve chunk refs
python3 code/registry_validate.py registry/warnaar.json     # validate registry
```

## Key files

- `code/trustcheck.py` — generic trust-system validator with ops
- `code/loop.json` — deployment descriptor (T, extraction chain, blocking)
- `code/citation_check.py` — per-experiment citation checker
- `code/registry_validate.py` — per-experiment registry validator
- `registry/warnaar.json` — the proof search tree (directed container)
- `sources.json` — citation provenance index (loop-sources-v1)
- `CITATIONS-README.md` — citation convention (RAG extraction chain)
- `REGISTRY-README.md` — registry convention (trust levels, dead ends)

## Mathematical structure

The registry is a directed container (shapes = rose trees, positions =
paths). The comonad operations:
- `extract` — read the root's trust (is the conjecture proved?)
- `duplicate` — at every node, the full sub-search is available
- `extend f` — apply a strategy f at every position
- `tau` — canonical trust: the greatest sound assignment

The boundary rule is stable under `duplicate` (Lean: `ok_sub`): validating
the whole tree validates every subtree. The seven reports (successful-path,
dead-ends, frontier, cross-refs, certificate-gap, shallow, footprint) are
coKleisli morphisms W(Registry) -> Report.

See `~/git/trust-boundaries/` for the theory, Lean formalization (9 files,
0 sorry), and the reference paper.
