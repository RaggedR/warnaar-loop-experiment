# HANDOVER — Theorem 3: consolidation preservation

Date: 2026-07-04. Session: drafted the general theory of trust systems,
Lean-verified Lemmas 1–2, deep-read the two load-bearing prior-art sources,
pushed everything. This file is for the next instance. State first, then the
one remaining piece of real content: **Theorem 3**. It is the hard part, the
real risk, and the thing that decides whether the paper is a paper.

## State: what is done and where

All in the containers repo, commit `a25156f`, RaggedR/ghani-containers, main:

```
notes/TRUST_SYSTEMS_THEORY.md    # the theory note: §1 defs, §2 Lemma 2.2,
                                 # §3 Lemma 3.2 + Cor 3.4/3.5, §4 Theorem 3
                                 # target, §5 negative provenance, §6 preserved
                                 # disagreement, §7 prior art (deep-read level)
notes/TRUST_SYSTEMS_THEORY.pdf   # compiled, 0 missing glyphs (pipeline below)
lean/Containers/Containers/Trust.lean   # 478 lines, sorry-free, Lean 4 core
                                        # (v4.30.0), NO Mathlib
```

Trust status of the note itself (it obeys its own rules):

- **Lemma 2.2** (certificate lemma: τ = greatest sound assignment) —
  `lean-verified` (`sound_le_tau`, `tau_sound`, `derivGrade_le_tau`,
  `tau_le_derivGrade` in Trust.lean).
- **Lemma 3.2** (trust transport along morphisms) — `lean-verified`
  (`tau_transport`).
- **Prior art** — `paper-read` for the two load-bearing sources
  (arXiv:2605.10829 Brinke et al.; arXiv:2604.00034 Bloomfield–Rushby).
- **Theorem 3** — `speculative`. That is your job.

Corrections the formalization forced on the prose (already folded into the
note; do not un-fix them):

1. **T must be a bounded chain**, not an arbitrary lattice — sup-attainment
   in the max-min recursion fails otherwise. Corroborated independently:
   Brinke et al. need a total order for their min-max results too, and for
   them min-max is an *application* semiring, NOT one of their provenance
   semirings (my earlier citation said otherwise; fixed).
2. **Morphisms need strictness at bottom**: φ(⊥) = ⊥′. Without it,
   trust transport is false (unclassified leaves must stay unclassified).
3. **Well-foundedness of the premise relation is load-bearing.** The Lean
   counterexample `cyc` (Trust.lean, end of file): a 2-cycle where the
   everywhere-`hi` assignment is Sound but no derivation exists — circular
   citation inflates trust past every local check. Deployed validators are
   safe only because the JSON registries are trees; **a generic validator
   must check acyclicity explicitly**.

## Theorem 3: what to actually prove

Target statement (note §4): the memory pipeline
`scratch → synthesis-1 → … → synthesis-4 → proof` is a chain of container
morphisms — **shapes forward** (claims get restated), **positions backward**
("where did this come from?"). A citation is the *cached value of the
position pullback*. Conjecture:

> If a consolidation step C carries a genuine position map (not just a shape
> map), then τ∘C = τ — trust is preserved through consolidation.

The empirical anchor, both directions:

- **Counterexample for the converse**: `synthesis-layer4.md` in THIS repo has
  zero machine-resolvable citations after four consolidation layers. That is
  a shape-only container morphism: claims restated, positions dropped, τ
  degrades to `recalled` everywhere. Run `code/citation_check.py` on it to
  reproduce.
- **Positive case**: the post-installation convention (SYNTHESIZE-SKILL.md's
  backfill-by-use duty) is exactly "carry the position map". If the theorem
  holds, that duty is not hygiene, it is the preservation hypothesis.

### The structural insight to chase first

Consolidation-with-citations may **factor through opaque restriction**
(note Def 3.3) with φ = id: a synthesis document that cites its scratch
sources is, trust-theoretically, an external paper whose interface map is
the identity. If that factoring works, Theorem 3 is a corollary of Lemma 3.2
applied twice (once in each direction along the position map) and the whole
paper is ONE construction instantiated three ways. Check this before
inventing new machinery — it might be an afternoon, not a month.

### The trivialization risk (why this is the hard part)

Both failure modes kill the theorem:

- **Too weak**: define "genuine position map" as "preserves τ" — circular,
  content-free.
- **Too strong**: demand the position map be a section of the shape map on
  the nose — then no real consolidation qualifies (synthesis genuinely
  merges and rephrases; the map is many-to-one on shapes).

The correct middle is probably: position map = for every claim in the image,
a chosen derivation in the source whose grade the citation caches; the
theorem then says the max-min value is stable under this choice. Formalizing
"what consolidation preserves" without trivializing it is the entire
difficulty. If you cannot find the middle, SAY SO in the note — a scoped
negative ("here are two natural definitions and each fails, here is why")
is publishable content for this kind of paper.

### Connection to the preserved disagreement

Note §6 / previous handover: does the directed-container framing yield
theorems or only language? Burden of proof: **a theorem that USES
`duplicate` non-trivially**. Theorem 3 is the candidate. In
`ProofSearchN.lean` (containers repo), duplicate = full sub-search at every
node = exactly what a resumed session reads. If the position-pullback story
needs duplicate (positions of positions = provenance of provenance = the
citation chain through multiple consolidation layers), the framing earns its
keep. If Theorem 3 goes through with plain trees and path lookup, be honest:
the containers add nothing and the paper should say so.

## Traps and known facts (save yourself the time)

- **`Deriv` in Trust.lean uses membership-indexed premise functions**
  (`sub : ∀ y, y ∈ S.prems f → Deriv S y`), so derivation *extensionality*
  is not developed. Theorem 3 compares derivations across systems — you
  will likely need a proper equality/isomorphism on Deriv, or to work with
  derivGrade values only (recommended: values only, avoid Deriv equality).
- `derivGrade` and `tau` are `noncomputable` (Deriv.rec + Classical.dite).
  Fine for proofs; do not try to #eval them.
- Lean core only, no Mathlib. `Chain` is a hand-rolled class in Trust.lean
  with `cmin`/`cmax` and a small lemma library — extend that, don't import.
- `by decide` does NOT work for ∀ over small inductive types in core —
  use explicit case analysis (see the `Two` lemmas at the end of Trust.lean).
- PDF pipeline (unicode math in markdown, zero missing glyphs):
  ```
  pandoc TRUST_SYSTEMS_THEORY.md -o TRUST_SYSTEMS_THEORY.pdf \
    --pdf-engine=lualatex -V mainfont="STIX Two Text" \
    -V mainfontfallback="STIX Two Math:mode=harf" \
    -V mainfontfallback="DejaVuSans:mode=harf" -V monofont="Menlo" \
    -V monofontfallback="STIX Two Math:mode=harf" \
    -V monofontfallback="DejaVuSans:mode=harf" \
    -V geometry:margin=2.5cm -V fontsize=11pt
  ```
- In the containers repo, `scratch/clio-registry/` and
  `scratch/macbeth-registry/` have uncommitted changes from ANOTHER
  instance. Leave them alone.
- The previous handover's installed-state summary (validators, registry,
  extraction ladder, design decisions) is in git history: `260bc50`. The
  design decisions there still stand — do not relitigate without evidence.

## Where to start

1. Read note §3–§4 (`~/git/containers/notes/TRUST_SYSTEMS_THEORY.md`) and
   the `Mor`/`tau_transport` section of Trust.lean — Theorem 3 must
   compose with these, not replace them.
2. Try the opaque-restriction factoring on paper FIRST (an afternoon).
   Test it against the concrete pipeline in this repo: pick one claim in
   `synthesis-layer4.md`, trace it back through the layers by hand, and ask
   whether the trace is a position map in your candidate definition.
3. Only then formalize. Extend Trust.lean with a `Consolidation` structure
   (shape map on claims + position data) and aim at `tau_consolidate`.
   The formalization has already caught three real errors in the prose —
   expect it to catch more; that is the point.
4. When done (or scoped-negative), update the note + PDF, push to
   ghani-containers, and update the bulletin note
   (`~/.claude/tmp/notes/trust-system-third-deployment-loop-experiment.md`).
