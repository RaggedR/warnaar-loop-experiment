/-
Seed 7, Layer 3 (Round 2): the Gauss q-binomial inversion, machine-checked.

This is the referee-critical step behind Seed 7's Theorem Q / Corollary I:
for ANY sequences `a b : ℕ → A` (A a commutative ring, q : A arbitrary),

  b n = ∑_{j≤n} [n,j]_q a j    (all n)
    ↔
  a n = ∑_{m≤n} (−1)^(n−m) q^(C(n−m,2)) [n,m]_q b m   (all n).

The project instantiation (`Q_transform_of_H`) takes Corollary I
(H_m = ∑ [m,n] Q_n, proved in the paper from Euler's expansion) as a named
hypothesis and outputs Theorem Q (the Q-transform), and conversely.
-/
import WarnaarGlue.GaussBinomial

open Polynomial Finset

namespace WarnaarGlue

variable {A : Type*} [CommRing A]

/-- The Gaussian binomial `[n, k]` evaluated at `q : A`. -/
noncomputable def gaussq (q : A) (n k : ℕ) : A := aeval q (gauss n k)

lemma gaussq_eq_zero_of_lt (q : A) {m n : ℕ} (h : m < n) : gaussq q m n = 0 := by
  rw [gaussq, gauss_eq_zero_of_lt h, map_zero]

@[simp] lemma gaussq_self (q : A) (n : ℕ) : gaussq q n n = 1 := by
  rw [gaussq, gauss_self, map_one]

@[simp] lemma gaussq_zero_right (q : A) (n : ℕ) : gaussq q n 0 = 1 := by
  rw [gaussq, gauss_zero_right, map_one]

/-- Orthogonality `M·L = I` transported from `ℤ[X]` to `(A, q)`. -/
lemma orthq_ML (q : A) (n k : ℕ) :
    ∑ m ∈ range (n + 1), (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
      (gaussq q n m * gaussq q m k) = if n = k then 1 else 0 := by
  have h := congrArg (aeval q (R := ℤ)) (orth_ML n k)
  simpa [map_sum, map_mul, map_pow, map_neg, map_one, aeval_X, apply_ite, gaussq] using h

/-- Orthogonality `L·M = I` transported from `ℤ[X]` to `(A, q)`. -/
lemma orthq_LM (q : A) (n k : ℕ) :
    ∑ j ∈ range (n + 1), gaussq q n j *
      ((-1 : A) ^ (j - k) * q ^ ((j - k).choose 2) * gaussq q j k) =
      if n = k then 1 else 0 := by
  have h := congrArg (aeval q (R := ℤ)) (orth_LM n k)
  simpa [map_sum, map_mul, map_pow, map_neg, map_one, aeval_X, apply_ite, gaussq] using h

/-- **Gauss q-binomial inversion.** For any sequences `a b : ℕ → A` over a
commutative ring `A` with a chosen `q : A`:
`b` is the q-binomial transform of `a` iff `a` is the signed inverse transform
of `b`. This is the self-contained inversion lemma behind Seed 7's Theorem Q. -/
theorem qbinom_inversion (q : A) (a b : ℕ → A) :
    (∀ n, b n = ∑ j ∈ range (n + 1), gaussq q n j * a j) ↔
    (∀ n, a n = ∑ m ∈ range (n + 1),
      (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * b m) := by
  constructor
  · intro h n
    symm
    have key : ∀ m ∈ range (n + 1),
        (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * b m =
        ∑ j ∈ range (n + 1),
          (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
            (gaussq q n m * gaussq q m j) * a j := by
      intro m hm
      have hmn : m + 1 ≤ n + 1 := by
        have := mem_range.mp hm
        omega
      have hz : ∀ j ∈ range (n + 1), j ∉ range (m + 1) → gaussq q m j * a j = 0 := by
        intro j hj hj'
        have hmj : m < j := by
          simp only [mem_range] at hj hj'
          omega
        rw [gaussq_eq_zero_of_lt q hmj, zero_mul]
      calc (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * b m
          = (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m *
              ∑ j ∈ range (m + 1), gaussq q m j * a j := by rw [h m]
        _ = (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m *
              ∑ j ∈ range (n + 1), gaussq q m j * a j := by
            rw [sum_subset (range_subset_range.mpr hmn) hz]
        _ = ∑ j ∈ range (n + 1),
              (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
                (gaussq q n m * gaussq q m j) * a j := by
            rw [mul_sum]
            exact sum_congr rfl fun j _ => by ring
    have inner : ∀ j ∈ range (n + 1),
        ∑ m ∈ range (n + 1),
          (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
            (gaussq q n m * gaussq q m j) * a j =
        (if n = j then (1 : A) else 0) * a j := by
      intro j _
      rw [← sum_mul, orthq_ML]
    calc ∑ m ∈ range (n + 1),
            (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * b m
        = ∑ m ∈ range (n + 1), ∑ j ∈ range (n + 1),
            (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
              (gaussq q n m * gaussq q m j) * a j := sum_congr rfl key
      _ = ∑ j ∈ range (n + 1), ∑ m ∈ range (n + 1),
            (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) *
              (gaussq q n m * gaussq q m j) * a j := sum_comm
      _ = ∑ j ∈ range (n + 1), (if n = j then (1 : A) else 0) * a j :=
            sum_congr rfl inner
      _ = a n := by simp [ite_mul]
  · intro h n
    symm
    have key : ∀ j ∈ range (n + 1),
        gaussq q n j * a j =
        ∑ m ∈ range (n + 1),
          gaussq q n j * ((-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) *
            gaussq q j m) * b m := by
      intro j hj
      have hjn : j + 1 ≤ n + 1 := by
        have := mem_range.mp hj
        omega
      have hz : ∀ m ∈ range (n + 1), m ∉ range (j + 1) →
          (-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) * gaussq q j m * b m = 0 := by
        intro m hm hm'
        have hjm : j < m := by
          simp only [mem_range] at hm hm'
          omega
        rw [gaussq_eq_zero_of_lt q hjm]
        ring
      calc gaussq q n j * a j
          = gaussq q n j * ∑ m ∈ range (j + 1),
              (-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) * gaussq q j m * b m := by
            rw [h j]
        _ = gaussq q n j * ∑ m ∈ range (n + 1),
              (-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) * gaussq q j m * b m := by
            rw [sum_subset (range_subset_range.mpr hjn) hz]
        _ = ∑ m ∈ range (n + 1),
              gaussq q n j * ((-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) *
                gaussq q j m) * b m := by
            rw [mul_sum]
            exact sum_congr rfl fun m _ => by ring
    have inner : ∀ m ∈ range (n + 1),
        ∑ j ∈ range (n + 1),
          gaussq q n j * ((-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) *
            gaussq q j m) * b m =
        (if n = m then (1 : A) else 0) * b m := by
      intro m _
      rw [← sum_mul, orthq_LM]
    calc ∑ j ∈ range (n + 1), gaussq q n j * a j
        = ∑ j ∈ range (n + 1), ∑ m ∈ range (n + 1),
            gaussq q n j * ((-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) *
              gaussq q j m) * b m := sum_congr rfl key
      _ = ∑ m ∈ range (n + 1), ∑ j ∈ range (n + 1),
            gaussq q n j * ((-1 : A) ^ (j - m) * q ^ ((j - m).choose 2) *
              gaussq q j m) * b m := sum_comm
      _ = ∑ m ∈ range (n + 1), (if n = m then (1 : A) else 0) * b m :=
            sum_congr rfl inner
      _ = b n := by simp [ite_mul]

/-- **Seed 7's Theorem Q from Corollary I.** If `H` is the q-binomial transform of
`Q` (Corollary I, `H_m = ∑_n [m,n]_q Q_n` — proved in the paper from Euler's
expansion; here a named hypothesis), then `Q` is recovered by Gauss inversion:
`Q_n = ∑_m (−1)^(n−m) q^(C(n−m,2)) [n,m]_q H_m` (the Q-transform). -/
theorem Q_transform_of_H (q : A) (H Q : ℕ → A)
    (corollary_I : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n) :
    ∀ n, Q n = ∑ m ∈ range (n + 1),
      (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * H m :=
  (qbinom_inversion q Q H).mp corollary_I

/-- Converse instantiation: the Q-transform implies Corollary I. -/
theorem H_of_Q_transform (q : A) (H Q : ℕ → A)
    (theorem_Q : ∀ n, Q n = ∑ m ∈ range (n + 1),
      (-1 : A) ^ (n - m) * q ^ ((n - m).choose 2) * gaussq q n m * H m) :
    ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n :=
  (qbinom_inversion q Q H).mpr theorem_Q

end WarnaarGlue
