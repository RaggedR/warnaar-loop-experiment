# Lean pilot — Round 2, Layer 3 (machine-checking OUR glue results)

Mission: Lean-check (1) Seed 1's A2 Pascal ladder, (2) Seed 7's Gauss inversion /
Q-transform converse, as self-contained q-algebra. Literature + project objects
(H, Q, F) enter as hypotheses only.

## Setup decisions

- Mathlib audit: searched a full local Mathlib checkout
  (~/git/mathlib4-fork-primitive, v4.30.0-rc2 era) for
  gaussBinomial / qBinomial / q-binomial / qPochhammer: **Mathlib has NO Gaussian
  binomial coefficients** (only unrelated hits: UnitTrinomial.lean,
  Pochhammer.lean = rising factorials). So we define gauss : N -> N -> Polynomial Z
  ourselves by the q-Pascal recursion and prove the second Pascal recurrence.
- Toolchain: leanprover/lean4:v4.30.0-rc2 + mathlib rev c4dcaea34b (same pin as
  ~/git/lean, maximizing overlap with ~/.cache/mathlib for lake exe cache get).
- Project: lean/ at repo root (did not exist before; created fresh).
- Negative q-exponents in ferm (a,b : Z): work in LaurentPolynomial Z,
  q^z := LaurentPolynomial.T z, with T_add for exponent bookkeeping.
  The q-binomials are mapped in via Polynomial.toLaurent.
- Restriction taken: ferm's parameter c : N (not Z). The ladder ray
  c -> c+2 preserves N, and all orbit instantiations have c >= 0; c < 0 would
  need a junk convention for [2n+c, j] at n = 0. Flagged as an assumption.

## Proof plan

Target 1 (A2 Pascal ladder): ferm(m,a,b,c) = sum_{n<=m} sum_{j<=2n+c}
q^{n^2-nj+j^2+an+bj} [m,n][2n+c,j]. Proof: extend ferm(m-1) to the same outer
range (top term has [m-1,m] = 0), combine, use Pascal-2
[m,n] - [m-1,n] = q^{m-n}[m-1,n-1] (n >= 1; the n = 0 term dies), reindex
n -> n+1; inner ranges match exactly (2(n+1)+c = 2n+(c+2)); exponent bookkeeping.

Target 2 (inversion): all in Z[q] then transported to any CommRing A with chosen
q : A via aeval:
1. qfact n = prod [i]_q; gauss n k * [k]! * [n-k]! = [n]! (induction, no division).
2. Trinomial [n,m][m,k] = [n,k][n-k,m-k] by cancellation in the domain Z[q]
   (both sides x [k]![m-k]![n-m]! equal [n]!).
3. Alternating sum sum_i (-1)^i q^{C(i,2)} [J,i] = delta_{J,0} (Pascal + reindex).
4. Both orthogonalities (M.L = I and L.M = I) from 2 + 3.
5. Inversion iff by substitute-swap (rectangularize triangular double sums using
   gauss n k = 0 for k > n) + orthogonality.
6. H/Q instantiation as a corollary with the forward transform a hypothesis.

## Session log

### Build environment
- Fresh Lake project created at lean/ (repo root): lakefile.toml pins mathlib
  rev c4dcaea34b, toolchain leanprover/lean4:v4.30.0-rc2. `lake exe cache get`
  hit ~/.cache/mathlib fully (no download); Mathlib built from cache in seconds.

### Iteration log (errors found and fixed)
1. First build of GaussBinomial.lean: (a) gauss/qint/qfact need `noncomputable`
   (Polynomial arithmetic is noncomputable); (b) `eval_finset_sum` deprecated
   -> `eval_finsetSum`; (c) two calc blocks needed a second `qfact_succ`
   rewrite / an instantiated `show ... from qfact_succ _` because rw only hits
   the leftmost match; (d) `Nat.choose_succ_succ (i+1) 1` leaves a
   `Nat.succ 1` atom that omega treats as distinct from `2` — fixed by giving
   the have an explicit expected type (defeq handles the literals).
2. Inversion.lean: this Mathlib's `range_subset` is the ∀-form;
   `range_subset_range.mpr` is the monotonicity form we need.
3. PascalLadder.lean: compiled first try (one `ring` fell back to ring_nf,
   info only). Note: the theorem is stated with outer range (m + 1 + 1), not
   (m + 2), to match the syntactic unfolding of ferm (m+1).

### Definitions faithfulness (hostile-referee notes)
- `gauss` is pinned to THE Gaussian binomial, not merely some unitriangular
  array: `gauss_mul_qfact : [n,k]·[k]!·[n−k]! = [n]!` is proved, which
  determines gauss uniquely in the domain ℤ[q].
- ferm's truncated ranges (n ≤ m, j ≤ 2n+c) equal the unrestricted Σ_{n,j}
  because gauss vanishes above the top index.
- The inversion is stated for arbitrary sequences over any commutative ring A
  with any q : A (gaussq q n k := aeval q (gauss n k)), so it covers ℤ[q],
  power series, etc. H/Q enter only as a named hypothesis (corollary_I).

### Results — all sorry-free, axioms = [propext, Classical.choice, Quot.sound]
(verified via #print axioms; grep for sorry/admit/native_decide: clean)

Target 1 (Seed 1's A2 Pascal ladder) — lean/WarnaarGlue/PascalLadder.lean:
- `WarnaarGlue.ferm (m : ℕ) (a b : ℤ) (c : ℕ) : LaurentPolynomial ℤ`
- `WarnaarGlue.pascal_ladder : ferm (m+1) a b c − ferm m a b c
     = T (m+1+a) * ferm m (a+1) (b−1) (c+2)`   [T z = q^z]
- helper `WarnaarGlue.pascal_diff : [m+1,n+1] − [m,n+1] = q^(m−n)[m,n]`

Target 2 (Seed 7's inversion) — lean/WarnaarGlue/Inversion.lean:
- `WarnaarGlue.qbinom_inversion (q : A) (a b : ℕ → A) :
     (∀ n, b n = Σ_{j≤n} [n,j]_q a j) ↔
     (∀ n, a n = Σ_{m≤n} (−1)^(n−m) q^(C(n−m,2)) [n,m]_q b m)`
- `WarnaarGlue.Q_transform_of_H` (Cor I as hypothesis => Theorem Q) and
  `WarnaarGlue.H_of_Q_transform` (converse).

Supporting library — lean/WarnaarGlue/GaussBinomial.lean:
- `gauss`, `pascal₁`, `pascal₂`, `gauss_mul_qfact`, `gauss_symm`,
  `trinomial_rev`, `alt_sum` (truncated-Euler/q-binomial theorem at x=1),
  `orth_ML`, `orth_LM` (both Gauss-orthogonality relations).

### Assumptions / deviations flagged
- ferm's c is ℕ, not ℤ (scratch grid-tested c ≥ −1; all orbit instantiations
  and the ladder ray c ↦ c+2 live in ℕ). A c < 0 version would need a junk
  convention for [2n+c, j] at n = 0.
- Seed 7's Theorem Q itself (the Euler-expansion proof that Q_n as defined
  from cylindric partitions satisfies the transform) is NOT formalized — per
  the brief, the inversion is the self-contained referee-critical step and
  the H/Q link enters as the named hypothesis `corollary_I`.
- Mathlib's `Nat.choose (n−m) 2` is used for binom(n−m,2); ℕ-subtraction is
  safe since m ≤ n inside all ranges.

## Handoff

STATUS: GREEN. Both targets machine-checked, zero sorries anywhere in the
project, main theorems depend only on [propext, Classical.choice, Quot.sound].

Project: /Users/robin/git/experiments/waarnar/loop-experiment/lean/
(lake build succeeds end-to-end; library WarnaarGlue, 3 files).

Compiled sorry-free theorems (exact names):
- WarnaarGlue.pascal_ladder            — lean/WarnaarGlue/PascalLadder.lean
- WarnaarGlue.qbinom_inversion         — lean/WarnaarGlue/Inversion.lean
- WarnaarGlue.Q_transform_of_H         — lean/WarnaarGlue/Inversion.lean
- WarnaarGlue.H_of_Q_transform         — lean/WarnaarGlue/Inversion.lean
- WarnaarGlue.{pascal₁, pascal₂, gauss_mul_qfact, gauss_symm, trinomial_rev,
  alt_sum, orth_ML, orth_LM}           — lean/WarnaarGlue/GaussBinomial.lean

For the Warnaar email: "the two new glue steps (the A2 Pascal ladder and the
Gauss q-binomial inversion behind the Q-transform) are Lean 4 + Mathlib
machine-checked, sorry-free" is now a true sentence.

Next-step options for a future pilot (not attempted, out of scope):
- Formalize Lemma E + Theorem Q's Euler-convolution proof (needs q-Pochhammer
  power series; Mathlib has PowerSeries but no (q;q)_inf machinery).
- Corollary from pascal_ladder: monotonicity ferm(m) ≥ ferm(m−1) needs a
  coefficientwise order on LaurentPolynomial — no Mathlib order instance;
  would need a small nonneg-coefficients predicate closed under +/*.
- Seed 7's Theorem D kernel identities are the same q-Pascal moves; cheap to
  add on top of GaussBinomial.lean if wanted.
