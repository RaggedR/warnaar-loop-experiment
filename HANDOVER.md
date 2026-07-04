# HANDOVER — trust boundaries, citations, and the general theory

Date: 2026-07-04. Session: installed trust boundaries + citation provenance
into the loop experiment (third deployment of the Clio/MacBeth conventions),
then sketched the general theory. This file is for the next instance: state
first, then the theory sketch — which is the proposed next piece of work.

## State: what is installed and where

All committed and pushed (`f11b5c9`, RaggedR/warnaar-loop-experiment, main).

```
code/citation_check.py       # RAG-citation validator; checks chunks EXIST on disk
code/registry_validate.py    # trust-boundary validator
sources.json                 # 5 seeded sources; loop-sources-v1 format
registry/warnaar.json        # ONE tree for the whole conjecture, 22 nodes
CITATIONS-README.md          # convention: slug/chunk_NNN + locator at point of use
REGISTRY-README.md           # trust levels, boundary rule, refutation levels
PROVE-SKILL.md               # + Provenance section (6 duties, validators wired)
SYNTHESIZE-SKILL.md          # + preserve citations, update registry, BACKFILL BY USE
FINAL-SKILL.md               # + Part 2 gated on registry trust levels
```

Design decisions already made (do not relitigate without new evidence):

- **One big tree** (Robin's explicit choice), programs as subtrees under root.
- **Extraction ladder**: `recalled < rag-summary < chunk-read < context-read
  < paper-read`. `recalled` = from training memory, no chunk behind it — new
  level, did not exist in Clio/MacBeth. Load-bearing floor: `context-read`,
  because the characteristic RAG failure is a true theorem whose hypotheses
  live in an unretrieved chunk.
- **Registry trust**: `speculative < computed < proved < verified <
  lean-verified`. `verified` = MacBeth's `peer-reviewed`, mapped onto the
  loop's EXISTING verifier-seed practice (SOLID verdicts); `review` field
  points at `*/scratch/verify-seedN-layerL.md`.
- **Seeding was artifact-only**: layer-4 G-items with verifier reports /
  proof .tex / Lean declarations. No labels from synthesis prose alone.
  Everything else backfills by use as `unclassified`.
- Uncu's thm:m13 is computer-assisted (caveat N1) — recorded as a
  `corrections` entry in sources.json. Corrections carry trust *qualifiers*,
  not just wrong readings; they must survive compression.

Known facts that save you time:

- `synthesis-layer4.md` has ZERO machine-resolvable citations — four
  consolidation layers erased all provenance. This is the motivating
  evidence; cite it when explaining the system.
- G19 (β-map) is the live boundary-rule example: proved child under an
  in-progress parent (open lemma Q1). "PROVED... MODULO Q1" is now structure.
- The sibling deployments live in `~/git/containers/scratch/`
  ({clio,macbeth}-{registry,citations}); field report to Neil:
  `scratch/report-ghani-trust-citations.md`. Robin's Lean formalization of
  the registry comonad: containers repo, `ProofSearchN.lean` (no sorry).
- Validators were adversarially tested (boundary violation, missing review,
  shallow sources, hallucinated chunk refs — all caught). Do the same for
  anything you add.
- Bulletin note comparing all three deployments:
  `~/.claude/tmp/notes/trust-system-third-deployment-loop-experiment.md`.

## Next work: the general theory

Three deployments of one idea is enough to abstract. Proposed shape — a
Kodamai-flavoured ACT paper: definitions + two lemmas + one real theorem,
with the three running systems as the experiments section and the field
report as data. Robin has seen and engaged with this sketch.

### The data of a trust system

- **Dependency structure 𝒟**: a multicategory. Objects = claims; a multimap
  f: y₁,…,yₙ → x is a checking step (a derivation with premises).
- **Check-poset T**: the environment's available checks, ordered by
  strength. This is the deployment parameter, indexed by *how knowledge
  arrives*: browse-agent summaries (Clio), identity-fragile feeds (MacBeth),
  windowed verbatim chunks (loop).
- **Grading** s: multimaps → T: the strength of the check that step received.

Canonical trust: τ(x) = max over derivations of x of (min of all step- and
leaf-grades in the derivation tree) — widest-bottleneck value in the
max-min semiring ⟨T, max, min⟩. Weakest link along a chain; best derivation
among alternatives.

### The results, in expected order of difficulty

1. **Certificate lemma** (afternoon): an assignment t is *sound* iff each
   claim has a derivation with t(x) ≤ ⋀ᵢ t(yᵢ) ∧ s(f). The boundary rule is
   exactly node-local soundness; the validators are certificate checkers;
   τ is the greatest sound assignment (fixpoint of the max-min operator).
   Trust inflation = claiming above τ. `unclassified` = leaf graded near ⊥,
   capping everything above it — no extra mechanism needed.
2. **Opaque-restriction lemma** (afternoon): a morphism of trust systems is
   a functor of dependency structures + a monotone map of check-posets,
   laxly compatible with grading. An external paper is the image of an
   opaque restriction — you see only the root, graded in the extraction
   poset; the "all sources below context-read blocks proved" rule is the
   interface map T_extraction → T_registry. Corollary: the citation
   convention and the registry are ONE construction. Cross-agent citation
   (Clio ↔ MacBeth) = composition along such a morphism — Phase 4 of the
   trust-boundary design, done properly.
3. **Consolidation preservation theorem** (the real content, the real
   risk): the memory pipeline scratch → synthesis → proof is a chain of
   container morphisms — shapes forward (claims restated), positions
   backward ("where did this come from?"). A citation is the cached value
   of the position pullback. Theorem to aim for: if consolidation C carries
   a genuine position map (not just a shape map), then τ∘C = τ.
   synthesis-layer4 is the counterexample for the converse: shape-only map,
   τ degrades to `recalled` everywhere. The hard part is formalizing "what
   consolidation preserves" without trivializing it.
4. **Negative provenance**: dead ends with `refutation` grades are the same
   construction applied inside the order — positive claims justified above
   it, negative claims within it. Possibly bi-Heyting flavour; possibly
   just a remark. Wrong reasons silently prune live branches, so refutation
   grades matter operationally (the frontier includes judgment-level dead
   ends).

### Prior art — cite, don't reinvent

Green–Karvounarakis–Tannen, *Provenance semirings* (PODS 2007), and the
why/how-provenance literature: max-min trust propagation is a known semiring
instance there. Our additions, honestly scoped: (a) the check-poset as
deployment parameter — the epistemics of how knowledge arrives; (b)
consolidation as a lossy endofunctor and the container-morphism preservation
condition (databases don't dream); (c) graded negative provenance.

**Preserved disagreement** (do not force consensus): whether the
directed-container framing yields theorems or only language over "labelled
rose trees with path lookup". Evidence for: ProofSearchN.lean's comonad laws
hold with content (duplicate = full sub-search at every node = exactly what
a resumed session reads). Burden of proof: a theorem that USES duplicate
non-trivially. If you find one, the framing earns its keep; if not, say so
in the paper.

### Practical payoff (mai nafka minah)

A fourth deployment becomes an instantiation: choose T, point at the
dependency structure, one generic validator parametrized over T replaces
the per-agent Python ports. If you start the paper, also consider writing
that generic validator — it is simultaneously the reference implementation
and the strongest argument that the abstraction is right.

### Where to start

1. Read the field report (`~/git/containers/scratch/report-ghani-trust-citations.md`)
   — its "structural reading" section is the seed of lemma 2.
2. Draft definitions + lemmas 1-2 in a note (containers repo `notes/` is the
   natural home; this repo is for the Warnaar experiment itself).
3. Before writing anything long, search for existing work on trust/provenance
   in multi-agent LLM systems — the semiring part is old; the agent-memory
   part may have recent neighbours.
