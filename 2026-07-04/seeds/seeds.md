# Seeds for Round 2 — 2026-07-04

Generated from the findings of Round 1 (2026-07-03).
Each seed is a RAG query + rationale based on what we learned.

## Seed 1 — Demazure character positivity and key polynomial decomposition
**Query:** `"Demazure character key polynomial positive decomposition affine crystal graded character manifestly nonneg"`
**Rationale:** The strongest conjecture from Round 1. Q_{n,c}(q) decomposes into GL₃ key polynomials with nonneg multiplicities. Need literature on when/why such decompositions exist abstractly.

## Seed 2 — Energy function on Kirillov-Reshetikhin crystals
**Query:** `"energy function Kirillov-Reshetikhin crystal tensor product one-dimensional configuration sum grading"`
**Rationale:** Seed 7 identified the energy function as the correct q-grading (principal grading fails for n≥2). Need the precise definition and how it relates to cylindric partition weight.

## Seed 3 — Warnaar's A₂ invariance identity and bounded multisum
**Query:** `"Warnaar A2 invariance identity manifestly positive multisum bounded cylindric partition Phi functional equation"`
**Rationale:** The most promising analytic path. Warnaar proved positivity for k=1,2 using this identity. Need the exact proof mechanism to attempt generalisation to k≥3.

## Seed 4 — Earth Mover's Distance and lattice path combinatorics
**Query:** `"transportation distance optimal coupling lattice path Lindstrom Gessel Viennot nonintersecting transfer matrix adjugate"`
**Rationale:** Agent B discovered adj(I-A(x))[c,c'] = x^{EMD(c,c')}. Need literature on EMD in algebraic combinatorics and whether the LGV lemma applies to the adjugate path formula.

## Seed 5 — Cylindric partitions and affine crystal bases (Tingley-Schilling)
**Query:** `"Tingley cylindric partition crystal base affine type A bijection Fock space level rank duality"`
**Rationale:** The bridge between cylindric partitions and representation theory. Need the precise bijection and how bounded CPs map to Demazure subcrystals.

## Seed 6 — Fermionic formulas for Demazure characters
**Query:** `"fermionic formula Demazure character affine Lie algebra Schilling Shimozono Kirillov positive sum"`
**Rationale:** Fermionic formulas are manifestly positive multisums for Demazure characters. If Q_{n,c}(q) is a Demazure character, a fermionic formula would prove positivity.

## Seed 7 — Gaussian elimination and Uncu's approach to explicit multisums
**Query:** `"Uncu Gaussian elimination cylindric partition recurrence explicit multisum modulus identity rank 3"`
**Rationale:** Uncu proved new identities for moduli 11,13 via automated elimination on the CW system. Need the technique details to attempt d=7 (modulus 10) or to find the pattern for general d.

## Seed 8 — Ehrhart theory and lattice polytope positivity
**Query:** `"Ehrhart polynomial lattice polytope h-star vector nonneg Stanley theorem monotonicity lattice point count"`
**Rationale:** The injection lemma proves Q₁ ≥ 0 via lattice point monotonicity. Higher h_m may require Ehrhart theory on higher-dimensional cylindric partition polytopes. Need tools for proving h*-vector nonnegativity.
