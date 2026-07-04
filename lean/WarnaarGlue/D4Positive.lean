/-
Seed 6, Layer 3 (Round 2): the d=4 glue, machine-checked.

Warnaar's Conjecture 2.7 at d=4 (modulus 7), following
proofs/prove-seed6-layer3.tex (erratum applied; TRUE conjecture.tex labels,
synthesis-layer3.md §4(iv) — the CW dictionary is the identity map).

What is PROVED here (sorry-free, no hypotheses):
* `CoeffNonneg`        : the coefficientwise-nonneg predicate on ℤ[X] with
                         closure lemmas, and `gauss_nonneg`.
* `sum_pascal_split`,
  `sum_pascal_split₂`  : q-Pascal at the level of weighted sums ∑ c j·[N+1,j].
* `absorption_A_eq`    : Xw(n) − qⁿ·X′(n) = (three manifestly nonneg sums)
                         — the exact identity behind Lemma A (wall CW(3,0,1),
                         true orbit of (0,1,3)).
* `absorption_B_eq`    : Xw(n) − qⁿ·Y′(n) = ∑_{j≤2n−1} q^(n²+j²−nj+2j+1)·[2n−1,j]
                         — the exact identity of Lemma B (wall CW(2,2,0),
                         true orbit of (0,2,2)).
* `Qcw_nonneg`         : all five explicit d=4 forms are coefficientwise ≥ 0.

What enters as NAMED HYPOTHESES (sanctioned imports of literature/paper
results, not formalized here):
* `hCW` — Corteel–Welsh Theorem `new` (companion note to [CW19]): the five
  bounded fermionic forms, stated with denominators cleared:
  H_{c,m} = ∑_{n≤m} [m,n]_q · Qcw(c,n).  (The clearing
  (q)_m/((q)_{m−n}(q)_n) = [m,n] is definitional bookkeeping; the convention
  1/(q)_{−1} = 0 makes the wall n=0 terms vanish, matching Xp 0 = Yp 0 = 0.)
* `hQ` — Theorem Q (Seed 7, proved in the paper via Euler expansion): the
  project's Q_{n,c} is the signed Gauss inverse transform of (H_{c,m})_m.

Main results (conditional only on hCW/hQ):
* `d4_Q_eq_Qcw`   : Q = Qcw — the Inversion Lemma instantiation, via the
                    pilot's `qbinom_inversion` at (A,q) = (ℤ[X], X).
* `d4_positive`   : ∀ orbit, ∀ n, CoeffNonneg (Q o n)   — Conjecture 2.7 at d=4.
* `d4_BFF`        : H o m = ∑_{n≤m} [m,n]·Q o n (bounded fermionic form, a_n = Q_n).
* `d4_monotone`   : CoeffNonneg (H o (m+1) − H o m)     — Monotonicity.
-/
import WarnaarGlue.Inversion

open Polynomial Finset

namespace WarnaarGlue

/-! ### The coefficientwise-nonnegativity predicate -/

/-- A polynomial in `ℤ[X]` has all coefficients nonnegative. -/
def CoeffNonneg (p : Polynomial ℤ) : Prop := ∀ k, 0 ≤ p.coeff k

lemma CoeffNonneg.zero : CoeffNonneg 0 := fun k => by simp

lemma CoeffNonneg.one : CoeffNonneg 1 := fun k => by
  rw [coeff_one]
  split <;> norm_num

lemma CoeffNonneg.add {p q : Polynomial ℤ} (hp : CoeffNonneg p) (hq : CoeffNonneg q) :
    CoeffNonneg (p + q) := fun k => by
  rw [coeff_add]; exact add_nonneg (hp k) (hq k)

lemma CoeffNonneg.mul {p q : Polynomial ℤ} (hp : CoeffNonneg p) (hq : CoeffNonneg q) :
    CoeffNonneg (p * q) := fun k => by
  rw [coeff_mul]
  exact sum_nonneg fun x _ => mul_nonneg (hp x.1) (hq x.2)

lemma CoeffNonneg.sum {ι : Type*} (s : Finset ι) (f : ι → Polynomial ℤ)
    (h : ∀ i ∈ s, CoeffNonneg (f i)) : CoeffNonneg (∑ i ∈ s, f i) := fun k => by
  rw [finsetSum_coeff]
  exact sum_nonneg fun i hi => h i hi k

lemma CoeffNonneg.X_pow (e : ℕ) : CoeffNonneg ((X : Polynomial ℤ) ^ e) := fun k => by
  rw [coeff_X_pow]
  split <;> norm_num

/-- Gaussian binomials have nonnegative coefficients (induction on the
q-Pascal recursion). -/
lemma gauss_nonneg : ∀ m n : ℕ, CoeffNonneg (gauss m n)
  | _, 0 => by rw [gauss_zero_right]; exact CoeffNonneg.one
  | 0, _ + 1 => by rw [gauss_zero_succ]; exact CoeffNonneg.zero
  | m + 1, n + 1 => by
    rw [pascal₁]
    exact (gauss_nonneg m n).add ((CoeffNonneg.X_pow (n + 1)).mul (gauss_nonneg m (n + 1)))

/-- The workhorse positivity fact: any sum of monomial multiples of Gaussian
binomials is coefficientwise nonnegative. -/
lemma sum_X_pow_mul_gauss_nonneg (s : Finset ℕ) (e : ℕ → ℕ) (M N : ℕ → ℕ) :
    CoeffNonneg (∑ j ∈ s, X ^ e j * gauss (M j) (N j)) :=
  CoeffNonneg.sum _ _ fun _ _ => (CoeffNonneg.X_pow _).mul (gauss_nonneg _ _)

/-! ### The quadratic exponent T(n,j) = q^(n²+j²−nj) -/

/-- `n·j ≤ n² + j²`, so the ℕ-subtraction in `tExp` is exact. -/
lemma mul_le_sq_add_sq (n j : ℕ) : n * j ≤ n * n + j * j := by
  rcases Nat.le_total n j with h | h
  · calc n * j ≤ j * j := Nat.mul_le_mul_right j h
      _ ≤ n * n + j * j := Nat.le_add_left _ _
  · calc n * j ≤ n * n := Nat.mul_le_mul_left n h
      _ ≤ n * n + j * j := Nat.le_add_right _ _

/-- The exponent of `T(n,j) = q^(n²+j²−nj)`. -/
def tExp (n j : ℕ) : ℕ := n * n + j * j - n * j

/-- `tExp` cast to ℤ is the honest value (no truncation). -/
lemma tExp_cast (n j : ℕ) :
    ((tExp n j : ℕ) : ℤ) = (n : ℤ) * n + (j : ℤ) * j - (n : ℤ) * j := by
  rw [tExp, Nat.cast_sub (mul_le_sq_add_sq n j)]
  push_cast
  ring

/-! ### q-Pascal at the level of weighted sums

Both absorption lemmas are two applications of q-Pascal under a `∑ c j·[·,j]`.
We prove the two splitting moves once, for an arbitrary coefficient stream
`c : ℕ → ℤ[X]`; all negative-index bookkeeping disappears because the top
binomial `[N, N+1] = 0` and the peeled `j = 0` terms cancel exactly. -/

/-- Split along `[N+1,j] = [N,j−1] + q^j [N,j]` (pascal₁ form):
`∑_{j≤N+1} c j·[N+1,j] = ∑_{i≤N} c(i+1)·[N,i] + ∑_{j≤N} c j·q^j·[N,j]`. -/
lemma sum_pascal_split (N : ℕ) (c : ℕ → Polynomial ℤ) :
    ∑ j ∈ range (N + 2), c j * gauss (N + 1) j =
      ∑ i ∈ range (N + 1), c (i + 1) * gauss N i +
      ∑ j ∈ range (N + 1), c j * (X ^ j * gauss N j) := by
  have hshift : ∑ i ∈ range (N + 1), c (i + 1) * (X ^ (i + 1) * gauss N (i + 1)) + c 0 =
      ∑ j ∈ range (N + 1), c j * (X ^ j * gauss N j) := by
    have h := sum_range_succ' (fun j => c j * (X ^ j * gauss N j)) (N + 1)
    have htop : ∑ j ∈ range (N + 2), c j * (X ^ j * gauss N j) =
        ∑ j ∈ range (N + 1), c j * (X ^ j * gauss N j) := by
      rw [sum_range_succ, gauss_eq_zero_of_lt (Nat.lt_succ_self N)]
      ring
    have h0 : c 0 * (X ^ 0 * gauss N 0) = c 0 := by simp
    simp only [h0] at h
    rw [htop] at h
    exact h.symm
  rw [sum_range_succ' _ (N + 1)]
  have hterm : ∀ i ∈ range (N + 1),
      c (i + 1) * gauss (N + 1) (i + 1) =
      c (i + 1) * gauss N i + c (i + 1) * (X ^ (i + 1) * gauss N (i + 1)) := by
    intro i _
    rw [pascal₁]
    ring
  rw [sum_congr rfl hterm, sum_add_distrib, gauss_zero_right, mul_one, add_assoc, hshift]

/-- Split along `[N+1,j] = [N,j] + q^(N+1−j) [N,j−1]` (pascal₂ form):
`∑_{j≤N+1} c j·[N+1,j] = ∑_{j≤N} c j·[N,j] + ∑_{i≤N} c(i+1)·q^(N−i)·[N,i]`. -/
lemma sum_pascal_split₂ (N : ℕ) (c : ℕ → Polynomial ℤ) :
    ∑ j ∈ range (N + 2), c j * gauss (N + 1) j =
      ∑ j ∈ range (N + 1), c j * gauss N j +
      ∑ i ∈ range (N + 1), c (i + 1) * (X ^ (N - i) * gauss N i) := by
  have hshift : ∑ i ∈ range (N + 1), c (i + 1) * gauss N (i + 1) + c 0 =
      ∑ j ∈ range (N + 1), c j * gauss N j := by
    have h := sum_range_succ' (fun j => c j * gauss N j) (N + 1)
    have htop : ∑ j ∈ range (N + 2), c j * gauss N j =
        ∑ j ∈ range (N + 1), c j * gauss N j := by
      rw [sum_range_succ, gauss_eq_zero_of_lt (Nat.lt_succ_self N)]
      ring
    have h0 : c 0 * gauss N 0 = c 0 := by simp
    simp only [h0] at h
    rw [htop] at h
    exact h.symm
  rw [sum_range_succ' _ (N + 1)]
  have hterm : ∀ i ∈ range (N + 1),
      c (i + 1) * gauss (N + 1) (i + 1) =
      c (i + 1) * (X ^ (N - i) * gauss N i) + c (i + 1) * gauss N (i + 1) := by
    intro i hi
    rw [pascal₂ (Nat.lt_succ_iff.mp (mem_range.mp hi))]
    ring
  rw [sum_congr rfl hterm, sum_add_distrib, gauss_zero_right, mul_one, add_assoc, hshift]
  ring

/-! ### The five d=4 forms (prove-seed6-layer3.tex, TRUE labels)

`Xw n` is the shared wall piece `X_n = ∑_j T(n,j) qⁿ [2n,j]`;
`Xp n` is `X′_n = ∑_j T(n,j) q^(2j) [2n−2,j]` and `Yp n` is
`Y′_n = ∑_j T(n,j) q^j (1+q^(n+j)) [2n−2,j]`, both `0` at `n = 0`
(the CW convention `1/(q;q)_{−1} = 0`; immaterial anyway, since they enter
only through the factor `(1 − qⁿ)`, which vanishes at `n = 0`). -/

/-- `X_n = ∑_{j≤2n} q^(n²+j²−nj+n) [2n,j]` (shared piece of both walls). -/
noncomputable def Xw (n : ℕ) : Polynomial ℤ :=
  ∑ j ∈ range (2 * n + 1), X ^ (tExp n j + n) * gauss (2 * n) j

/-- `X′_n = ∑_{j≤2n−2} q^(n²+j²−nj+2j) [2n−2,j]` (wall CW(3,0,1)); `X′_0 = 0`. -/
noncomputable def Xp : ℕ → Polynomial ℤ
  | 0 => 0
  | k + 1 => ∑ j ∈ range (2 * k + 1), X ^ (tExp (k + 1) j + 2 * j) * gauss (2 * k) j

/-- `Y′_n = ∑_{j≤2n−2} q^(n²+j²−nj+j) (1+q^(n+j)) [2n−2,j]` (wall CW(2,2,0)); `Y′_0 = 0`. -/
noncomputable def Yp : ℕ → Polynomial ℤ
  | 0 => 0
  | k + 1 => ∑ j ∈ range (2 * k + 1),
      X ^ (tExp (k + 1) j + j) * ((1 + X ^ (k + 1 + j)) * gauss (2 * k) j)

@[simp] lemma Xp_zero : Xp 0 = 0 := rfl

@[simp] lemma Yp_zero : Yp 0 = 0 := rfl

/-- Exponent shift `T(n,j+1)·qⁿ = T(n,j)·q^(2j+1)`: the ℕ-level identity
`tExp n (j+1) + n = tExp n j + 2j + 1` (exact, no truncation). -/
lemma tExp_succ (n j : ℕ) : tExp n (j + 1) + n = tExp n j + 2 * j + 1 := by
  have h : ((tExp n (j + 1) + n : ℕ) : ℤ) = ((tExp n j + 2 * j + 1 : ℕ) : ℤ) := by
    push_cast [tExp_cast]
    ring
  exact_mod_cast h

/-- Combine adjacent q-powers. -/
lemma Xmul (a b : ℕ) (p : Polynomial ℤ) :
    (X : Polynomial ℤ) ^ a * (X ^ b * p) = X ^ (a + b) * p := by
  rw [← mul_assoc, ← pow_add]

/-- **Absorption Lemma A** (exact identity; prove-seed6-layer3.tex Lemma "Absorption A").
For the wall CW(3,0,1) (true orbit of (0,1,3)), with `n = k+1 ≥ 1`:
`X_n − qⁿ X′_n = ∑_j T(n,j) qⁿ ((q^(j−1)+q^j)[2n−2,j−1] + [2n−2,j−2])`,
stated with the `j−1`, `j−2` sums reindexed to be truncation-free
(`j = i+1` resp. `j = i+2`).  Proof: double q-Pascal on `[2n,j]`; the
`q^(2j)[2n−2,j]` batch cancels `qⁿ X′_n` exactly. -/
lemma absorption_A (k : ℕ) :
    Xw (k + 1) - X ^ (k + 1) * Xp (k + 1) =
      ∑ i ∈ range (2 * k + 1), X ^ (tExp (k + 1) (i + 2) + (k + 1)) * gauss (2 * k) i +
      ∑ i ∈ range (2 * k + 1), X ^ (tExp (k + 1) (i + 1) + (k + 1) + i) * gauss (2 * k) i +
      ∑ i ∈ range (2 * k + 1),
        X ^ (tExp (k + 1) (i + 1) + (k + 1) + (i + 1)) * gauss (2 * k) i := by
  -- The three Pascal splits, instantiated and beta-reduced.
  have h1 := sum_pascal_split (2 * k + 1) (fun j => X ^ (tExp (k + 1) j + (k + 1)))
  have h2 := sum_pascal_split (2 * k) (fun i => X ^ (tExp (k + 1) (i + 1) + (k + 1)))
  have h3 := sum_pascal_split (2 * k) (fun j => X ^ (tExp (k + 1) j + (k + 1) + j))
  beta_reduce at h1 h2 h3
  -- Step 0: put `Xw (k+1)` in the shape of h1's left side.
  have hXw : Xw (k + 1) =
      ∑ j ∈ range (2 * k + 1 + 2),
        X ^ (tExp (k + 1) j + (k + 1)) * gauss (2 * k + 1 + 1) j := by
    rw [Xw]
    have hr : 2 * (k + 1) + 1 = 2 * k + 1 + 2 := by omega
    have hg : 2 * (k + 1) = 2 * k + 1 + 1 := by omega
    rw [hr, hg]
  -- Step 1+2: split, align ranges, split both halves again.
  rw [hXw, h1, show 2 * k + 1 + 1 = 2 * k + 2 from by omega, h2]
  have hshape : ∑ j ∈ range (2 * k + 2),
      X ^ (tExp (k + 1) j + (k + 1)) * (X ^ j * gauss (2 * k + 1) j) =
      ∑ j ∈ range (2 * k + 2),
        X ^ (tExp (k + 1) j + (k + 1) + j) * gauss (2 * k + 1) j := by
    refine sum_congr rfl fun j _ => ?_
    rw [Xmul]
  rw [hshape, h3]
  -- Step 3: the `q^(2j)` batch is exactly `q^(k+1) · X′_(k+1)`.
  have hcancel : ∑ j ∈ range (2 * k + 1),
      X ^ (tExp (k + 1) j + (k + 1) + j) * (X ^ j * gauss (2 * k) j) =
      X ^ (k + 1) * Xp (k + 1) := by
    rw [Xp, mul_sum]
    refine sum_congr rfl fun j _ => ?_
    rw [Xmul, Xmul]
    congr 2
    omega
  rw [← hcancel]
  -- Step 4: fold loose q-powers / indices into the stated form, then cancel.
  have hfold₁ : ∑ i ∈ range (2 * k + 1),
      X ^ (tExp (k + 1) (i + 1 + 1) + (k + 1)) * gauss (2 * k) i =
      ∑ i ∈ range (2 * k + 1),
        X ^ (tExp (k + 1) (i + 2) + (k + 1)) * gauss (2 * k) i :=
    sum_congr rfl fun i _ => rfl
  have hfold₂ : ∑ i ∈ range (2 * k + 1),
      X ^ (tExp (k + 1) (i + 1) + (k + 1)) * (X ^ i * gauss (2 * k) i) =
      ∑ i ∈ range (2 * k + 1),
        X ^ (tExp (k + 1) (i + 1) + (k + 1) + i) * gauss (2 * k) i := by
    refine sum_congr rfl fun i _ => ?_
    rw [Xmul]
  rw [hfold₁, hfold₂]
  ring

/-- **Absorption Lemma B** (exact identity; prove-seed6-layer3.tex Lemma
"Absorption B"). For the wall CW(2,2,0) (true orbit of (0,2,2)), with
`n = k+1 ≥ 1`:
`X_n − qⁿ Y′_n = ∑_{j=0}^{2n−1} q^(n²+j²−nj+2j+1) [2n−1,j]`.
Proof: one Pascal split of `[2n,j]`, one pascal₂-split of the `q^j` batch;
the `q^(2n−1)[2n−2,i]` batch equals the `q^(n+2j)[2n−2,j]` batch termwise
(shift-cancellation, via `tExp_succ`), and what survives is the stated
single positive sum. -/
lemma absorption_B (k : ℕ) :
    Xw (k + 1) - X ^ (k + 1) * Yp (k + 1) =
      ∑ j ∈ range (2 * k + 2), X ^ (tExp (k + 1) j + 2 * j + 1) * gauss (2 * k + 1) j := by
  have h1 := sum_pascal_split (2 * k + 1) (fun j => X ^ (tExp (k + 1) j + (k + 1)))
  have h3 := sum_pascal_split₂ (2 * k) (fun j => X ^ (tExp (k + 1) j + (k + 1) + j))
  beta_reduce at h1 h3
  have hXw : Xw (k + 1) =
      ∑ j ∈ range (2 * k + 1 + 2),
        X ^ (tExp (k + 1) j + (k + 1)) * gauss (2 * k + 1 + 1) j := by
    rw [Xw]
    have hr : 2 * (k + 1) + 1 = 2 * k + 1 + 2 := by omega
    have hg : 2 * (k + 1) = 2 * k + 1 + 1 := by omega
    rw [hr, hg]
  rw [hXw, h1, show 2 * k + 1 + 1 = 2 * k + 2 from by omega]
  have hshape : ∑ j ∈ range (2 * k + 2),
      X ^ (tExp (k + 1) j + (k + 1)) * (X ^ j * gauss (2 * k + 1) j) =
      ∑ j ∈ range (2 * k + 2),
        X ^ (tExp (k + 1) j + (k + 1) + j) * gauss (2 * k + 1) j := by
    refine sum_congr rfl fun j _ => ?_
    rw [Xmul]
  rw [hshape, h3]
  -- Expand `q^(k+1) · Y′_(k+1)` into its two batches.
  have hYp : X ^ (k + 1) * Yp (k + 1) =
      (∑ j ∈ range (2 * k + 1), X ^ (tExp (k + 1) j + (k + 1) + j) * gauss (2 * k) j) +
      ∑ j ∈ range (2 * k + 1),
        X ^ (tExp (k + 1) j + 2 * j + (2 * k + 2)) * gauss (2 * k) j := by
    rw [Yp, mul_sum, ← sum_add_distrib]
    refine sum_congr rfl fun j _ => ?_
    rw [Xmul, add_mul, one_mul, mul_add, Xmul]
    have e2 : k + 1 + (tExp (k + 1) j + j) + (k + 1 + j) =
        tExp (k + 1) j + 2 * j + (2 * k + 2) := by omega
    have e1 : k + 1 + (tExp (k + 1) j + j) = tExp (k + 1) j + (k + 1) + j := by omega
    rw [e2, e1]
  rw [hYp]
  -- The pascal₂ residue batch equals the second Y′ batch termwise.
  have hB2 : ∑ i ∈ range (2 * k + 1),
      X ^ (tExp (k + 1) (i + 1) + (k + 1) + (i + 1)) * (X ^ (2 * k - i) * gauss (2 * k) i) =
      ∑ j ∈ range (2 * k + 1),
        X ^ (tExp (k + 1) j + 2 * j + (2 * k + 2)) * gauss (2 * k) j := by
    refine sum_congr rfl fun i hi => ?_
    rw [Xmul]
    congr 2
    have ht := tExp_succ (k + 1) i
    have hik : i ≤ 2 * k := by
      have := mem_range.mp hi
      omega
    omega
  rw [hB2]
  -- What survives is the shifted single sum; rewrite it via tExp_succ.
  have hS1 : ∑ i ∈ range (2 * k + 2),
      X ^ (tExp (k + 1) (i + 1) + (k + 1)) * gauss (2 * k + 1) i =
      ∑ j ∈ range (2 * k + 2), X ^ (tExp (k + 1) j + 2 * j + 1) * gauss (2 * k + 1) j := by
    refine sum_congr rfl fun i _ => ?_
    congr 2
    exact tExp_succ (k + 1) i
  rw [hS1]
  ring

/-! ### The five d=4 orbits and their Q-forms -/

/-- The five C₃-orbits of d=4 profiles, named by their CW representative.
Per synthesis-layer3.md §4(iv).4 the CW dictionary is the IDENTITY map: each
label stands for the true conjecture.tex orbit containing it.
`o211` = {(1,1,2),(1,2,1),(2,1,1)}, `o400` = {(0,0,4),(0,4,0),(4,0,0)},
`o310` = {(0,3,1),(1,0,3),(3,1,0)} (good orbits), and the two walls
`o301` = {(0,1,3),(1,3,0),(3,0,1)}, `o220` = {(0,2,2),(2,0,2),(2,2,0)}. -/
inductive D4Orbit : Type
  | o211 | o400 | o310 | o301 | o220
  deriving DecidableEq

/-- The explicit `Q_{n,c}` forms at d=4 (prove-seed6-layer3.tex, "Explicit Q_n
and the wall absorption lemmas"): three manifestly positive single sums and
the two wall shapes `X_n + (1 − qⁿ)·X′_n / Y′_n`. -/
noncomputable def Qcw : D4Orbit → ℕ → Polynomial ℤ
  | .o211, n => ∑ j ∈ range (2 * n + 1), X ^ (tExp n j) * gauss (2 * n) j
  | .o400, n => ∑ j ∈ range (2 * n + 1), X ^ (tExp n j + n + j) * gauss (2 * n) j
  | .o310, n => ∑ j ∈ range (2 * n + 1), X ^ (tExp n j + j) * gauss (2 * n) j
  | .o301, n => Xw n + (1 - X ^ n) * Xp n
  | .o220, n => Xw n + (1 - X ^ n) * Yp n

lemma Xw_nonneg (n : ℕ) : CoeffNonneg (Xw n) :=
  sum_X_pow_mul_gauss_nonneg _ _ _ _

lemma Xp_nonneg (n : ℕ) : CoeffNonneg (Xp n) := by
  cases n with
  | zero => exact CoeffNonneg.zero
  | succ k => exact sum_X_pow_mul_gauss_nonneg _ _ _ _

lemma Yp_nonneg (n : ℕ) : CoeffNonneg (Yp n) := by
  cases n with
  | zero => exact CoeffNonneg.zero
  | succ k =>
    exact CoeffNonneg.sum _ _ fun _ _ => (CoeffNonneg.X_pow _).mul
      ((CoeffNonneg.one.add (CoeffNonneg.X_pow _)).mul (gauss_nonneg _ _))

/-- Wall A absorption, in inequality form: `X_n − qⁿ X′_n ≥ 0` for all `n`. -/
lemma wall_A_nonneg (n : ℕ) : CoeffNonneg (Xw n - X ^ n * Xp n) := by
  cases n with
  | zero => simpa using Xw_nonneg 0
  | succ k =>
    rw [absorption_A k]
    exact ((sum_X_pow_mul_gauss_nonneg _ _ _ _).add
      (sum_X_pow_mul_gauss_nonneg _ _ _ _)).add (sum_X_pow_mul_gauss_nonneg _ _ _ _)

/-- Wall B absorption, in inequality form: `X_n − qⁿ Y′_n ≥ 0` for all `n`. -/
lemma wall_B_nonneg (n : ℕ) : CoeffNonneg (Xw n - X ^ n * Yp n) := by
  cases n with
  | zero => simpa using Xw_nonneg 0
  | succ k =>
    rw [absorption_B k]
    exact sum_X_pow_mul_gauss_nonneg _ _ _ _

/-- **All five explicit d=4 forms are coefficientwise nonnegative**
(unconditional; the wall cases are the absorption lemmas). -/
theorem Qcw_nonneg (o : D4Orbit) (n : ℕ) : CoeffNonneg (Qcw o n) := by
  cases o with
  | o211 => exact sum_X_pow_mul_gauss_nonneg _ _ _ _
  | o400 => exact sum_X_pow_mul_gauss_nonneg _ _ _ _
  | o310 => exact sum_X_pow_mul_gauss_nonneg _ _ _ _
  | o301 =>
    have h : Qcw .o301 n = (Xw n - X ^ n * Xp n) + Xp n := by
      show Xw n + (1 - X ^ n) * Xp n = (Xw n - X ^ n * Xp n) + Xp n
      ring
    rw [h]
    exact (wall_A_nonneg n).add (Xp_nonneg n)
  | o220 =>
    have h : Qcw .o220 n = (Xw n - X ^ n * Yp n) + Yp n := by
      show Xw n + (1 - X ^ n) * Yp n = (Xw n - X ^ n * Yp n) + Yp n
      ring
    rw [h]
    exact (wall_B_nonneg n).add (Yp_nonneg n)

/-! ### Main theorems (conditional on the named literature hypotheses)

`hCW` is Corteel–Welsh Theorem `new` (the five bounded fermionic forms,
denominators cleared): `H_{c,m} = ∑_{n≤m} [m,n]_q · Qcw(c,n)`.
`hQ` is Seed 7's Theorem Q (proved in the paper via Euler expansion):
the project's `Q_{n,c}` is the signed Gauss inverse transform of `(H_{c,m})_m`.
Everything else below is machine-checked. -/

/-- `gaussq` at `(A, q) = (ℤ[X], X)` is `gauss` itself. -/
@[simp] lemma gaussq_X (n k : ℕ) : gaussq (X : Polynomial ℤ) n k = gauss n k := by
  rw [gaussq]
  exact aeval_X_left_apply _

/-- **The Inversion Lemma instantiation** (prove-seed6-layer3.tex, Lemma
"Inversion"): given the CW bounded forms (`hCW`) and the Q-transform (`hQ`),
the project's `Q` coincides with the five explicit forms `Qcw`. -/
theorem d4_Q_eq_Qcw (H Q : D4Orbit → ℕ → Polynomial ℤ)
    (hCW : ∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Qcw o n)
    (hQ : ∀ o n, Q o n = ∑ m ∈ range (n + 1),
        (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) * gauss n m * H o m) :
    ∀ o n, Q o n = Qcw o n := by
  intro o n
  have hb : ∀ m, H o m = ∑ j ∈ range (m + 1), gaussq (X : Polynomial ℤ) m j * Qcw o j := by
    intro m
    rw [hCW o m]
    exact sum_congr rfl fun j _ => by rw [gaussq_X]
  have hinv := (qbinom_inversion (X : Polynomial ℤ) (Qcw o) (H o)).mp hb n
  rw [hQ o n, hinv]
  exact sum_congr rfl fun m _ => by rw [gaussq_X]

/-- **Warnaar's Conjecture 2.7 at d=4** (Theorem "d=4 complete" (i) of
prove-seed6-layer3.tex): for every d=4 orbit `o` and every `n`, the
coefficients of `Q_{n,o}` are nonnegative — given the CW bounded forms and
the Q-transform as named hypotheses. -/
theorem d4_positive (H Q : D4Orbit → ℕ → Polynomial ℤ)
    (hCW : ∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Qcw o n)
    (hQ : ∀ o n, Q o n = ∑ m ∈ range (n + 1),
        (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) * gauss n m * H o m) :
    ∀ o n, CoeffNonneg (Q o n) := by
  intro o n
  rw [d4_Q_eq_Qcw H Q hCW hQ o n]
  exact Qcw_nonneg o n

/-- **Non-vacuity of the hypotheses**: `hCW` and `hQ` are jointly satisfiable
(take `H`, `Q` to be defined by their right-hand sides), so `d4_positive` is
not conditional on an empty theory. Unconditional corollary: the inverse
transform of the CW bounded forms is coefficientwise nonnegative. -/
example : ∃ H Q : D4Orbit → ℕ → Polynomial ℤ,
    (∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Qcw o n) ∧
    (∀ o n, Q o n = ∑ m ∈ range (n + 1),
        (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) * gauss n m * H o m) ∧
    (∀ o n, CoeffNonneg (Q o n)) := by
  refine ⟨fun o m => ∑ n ∈ range (m + 1), gauss m n * Qcw o n,
    fun o n => ∑ m ∈ range (n + 1), (-1 : Polynomial ℤ) ^ (n - m) *
      X ^ ((n - m).choose 2) * gauss n m *
      ∑ j ∈ range (m + 1), gauss m j * Qcw o j,
    fun _ _ => rfl, fun _ _ => rfl, ?_⟩
  exact d4_positive _ _ (fun _ _ => rfl) (fun _ _ => rfl)

/-- **BFF at d=4** (Theorem (ii)): the bounded fermionic-form coefficients
are `a_n = Q_n` for all orbits, including the walls:
`H_{c,m} = ∑_{n≤m} [m,n]_q Q_{n,c}`. -/
theorem d4_BFF (H Q : D4Orbit → ℕ → Polynomial ℤ)
    (hCW : ∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Qcw o n)
    (hQ : ∀ o n, Q o n = ∑ m ∈ range (n + 1),
        (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) * gauss n m * H o m) :
    ∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Q o n := by
  intro o m
  rw [hCW o m]
  exact sum_congr rfl fun n _ => by rw [d4_Q_eq_Qcw H Q hCW hQ o n]

/-- **Monotonicity at d=4** (Theorem (iii)): `H_{c,m} − H_{c,m−1} ≥ 0`
coefficientwise, via the q-Pascal rule applied termwise to the BFF —
here `H_{m+1} − H_m = ∑_i q^(m−i) [m,i] Q_{i+1} ≥ 0`. Needs only `hCW`. -/
theorem d4_monotone (H : D4Orbit → ℕ → Polynomial ℤ)
    (hCW : ∀ o m, H o m = ∑ n ∈ range (m + 1), gauss m n * Qcw o n) :
    ∀ o m, CoeffNonneg (H o (m + 1) - H o m) := by
  intro o m
  have hsplit := sum_pascal_split₂ m (fun n => Qcw o n)
  beta_reduce at hsplit
  have h1 : H o (m + 1) = ∑ n ∈ range (m + 2), Qcw o n * gauss (m + 1) n := by
    rw [hCW o (m + 1)]
    exact sum_congr rfl fun n _ => mul_comm _ _
  have h2 : H o m = ∑ n ∈ range (m + 1), Qcw o n * gauss m n := by
    rw [hCW o m]
    exact sum_congr rfl fun n _ => mul_comm _ _
  have key : H o (m + 1) - H o m =
      ∑ i ∈ range (m + 1), Qcw o (i + 1) * (X ^ (m - i) * gauss m i) := by
    rw [h1, h2, hsplit]
    ring
  rw [key]
  exact CoeffNonneg.sum _ _ fun i _ =>
    (Qcw_nonneg o (i + 1)).mul ((CoeffNonneg.X_pow _).mul (gauss_nonneg _ _))

/-! ### Spot checks (Priority 3): small-`n` values of the explicit forms.
All five orbits have `Q_0 = 1`; the good orbit `(2,1,1)` has
`Q_1 = 2q + q² + q³`, evaluated term-by-term from the explicit form. -/

example : Qcw .o211 0 = 1 := by simp [Qcw, tExp]
example : Qcw .o400 0 = 1 := by simp [Qcw, tExp]
example : Qcw .o310 0 = 1 := by simp [Qcw, tExp]
example : Qcw .o301 0 = 1 := by simp [Qcw, Xw, Xp, tExp]
example : Qcw .o220 0 = 1 := by simp [Qcw, Xw, Yp, tExp]

example : Qcw .o211 1 = 2 * X + X ^ 2 + X ^ 3 := by
  show ∑ j ∈ range 3, X ^ tExp 1 j * gauss 2 j = 2 * X + X ^ 2 + X ^ 3
  rw [sum_range_succ, sum_range_succ, sum_range_succ]
  norm_num [tExp, gauss, pascal₁]
  ring

end WarnaarGlue
