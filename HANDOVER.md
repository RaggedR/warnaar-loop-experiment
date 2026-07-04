# HANDOVER — Theorem 3: consolidation preservation

Date: 2026-07-04. Session: drafted the general theory of trust systems,
Lean-verified Lemmas 1–2, deep-read the two load-bearing prior-art sources,
then **proved and Lean-verified Theorem 3 itself** (same session, commit
`ded8ddc`). This file is for the next instance. State first, then what
remains: the composition/duplicate question and the paper.

## State: what is done and where

Containers repo, commits `a25156f` + `ded8ddc`, RaggedR/ghani-containers, main:

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
- **Theorem 3** — `lean-verified` (`tau_consolidate` + the `Consolidation`
  structure + shape-only counterexample `ground`/`layer4`, all in
  Trust.lean; note §4 rewritten with Definition 4.1 / Theorem 4.2).

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

## Theorem 3: what was proved

Definition 4.1 / Theorem 4.2 in the note, `Consolidation`/`tau_consolidate`
in Trust.lean. A consolidation over the same check-chain is:

- **shapes forward**: claim map + step map, premises corresponding, grades
  not dropping (= the forward data of a Mor at φ = id);
- **positions backward**: a map ρ sending every target step into a
  consolidated claim back to a source step *per preimage*, premises
  corresponding, target grade **cached**: s′(f′) ≤ s(ρ(f′)). A citation is
  the cached value of ρ at one step.

Theorem: τ′(onClaim x) = τ(x). Forward = `tau_transport` at φ = id;
backward = well-founded induction on the SOURCE only (attainment picks the
target's best step, ρ pulls it back, premise correspondence re-indexes the
IH). The trivialization trap was avoided by making Definition 4.1 never
mention τ: it is bisimulation-style and node-local, so validators can check
it, and preservation is a theorem about it.

Empirical anchors, both directions:

- `synthesis-layer4.md` in THIS repo: shape-only map, zero
  machine-resolvable citations, τ degrades to `recalled`. Formal shadow:
  `ground`/`layer4` in Trust.lean (τ falls `hi` → ⊥; no Consolidation
  between them can exist, by the theorem itself).
- SYNTHESIZE-SKILL.md's backfill-by-use duty = "carry ρ". Not hygiene;
  the preservation hypothesis.

### The preserved disagreement: honest outcome (note §6)

The Lean proof of Theorem 3 does NOT use `duplicate` — plain trees and
well-founded induction. The containers supplied the *definition* (ρ is
genuinely a position map; "shapes forward, positions backward" guided
Definition 4.1) but not the *lemma*. Burden still unmet. One live
candidate remains: **composition of consolidations** — provenance of
provenance, citation chains through multiple layers, where composing the
ρ's ought to be duplicate-shaped. If you prove a composition theorem that
genuinely needs duplicate, the framing earns its keep; otherwise the paper
says "language, not lemmas" (§6 already says this — don't soften it).

## What remains

1. **Composition**: `Consolidation` composes (check it — should be easy:
   ρ's compose contravariantly, caches compose by transitivity of ≤).
   Then the pipeline scratch → … → proof is one consolidation iff each
   layer is; the four-layer degradation is the failure of one factor.
   This is where the duplicate question gets decided.
2. **Generic validator** parametrized over (T, φ): checks node-local
   soundness (Lemma 2.2), acyclicity (Remark 2.3 — load-bearing!), and now
   the Consolidation conditions per layer. Reference implementation =
   strongest evidence the abstraction is right.
3. **The paper**: definitions + Lemmas 2.2/3.2 + Theorem 4.2, the three
   deployments as experiments, field report as data, prior art §7
   (deep-read level, corrections already folded in).

## Traps and known facts (save yourself the time)

- **`Deriv` in Trust.lean uses membership-indexed premise functions**
  (`sub : ∀ y, y ∈ S.prems f → Deriv S y`), so derivation *extensionality*
  is not developed. Theorem 3 avoided the issue by working with τ values
  only (this worked; keep doing it). If the composition theorem forces
  Deriv-to-Deriv maps, that is the moment extensionality bites.
- Another instance is active in the containers repo: it added
  `TrustBoundary.lean` (Phase 4, cross-registry shared nodes, commits
  `64ac9d1`/`111b264` — Lean duplicate-stability + a DCont ≅ Cof plan).
  **Read those before doing the composition work** — the duplicate
  question may already be half-answered there. Coordinate, don't collide.
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

1. Read note §4 + §6 (`~/git/containers/notes/TRUST_SYSTEMS_THEORY.md`) and
   the `Consolidation` section of Trust.lean — the composition theorem must
   build on these, not replace them.
2. Read the other instance's `TrustBoundary.lean` + the M4 plan (`111b264`)
   — its duplicate-stability work is adjacent to the composition question.
3. Prove `Consolidation.comp` in Lean (expected easy), then ask whether
   iterated composition is duplicate-shaped (expected hard, and the paper's
   §6 verdict hangs on it).
4. Test against the concrete pipeline in this repo: pick one claim in
   `synthesis-layer4.md`, trace it back through the layers by hand, and ask
   which layer fails Definition 4.1.
5. When done, update the note + PDF, push to ghani-containers, and update
   the bulletin note
   (`~/.claude/tmp/notes/trust-system-third-deployment-loop-experiment.md`).
