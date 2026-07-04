/-
Gaussian (q-)binomial coefficients as polynomials in ℤ[q], self-contained.

Mathlib (as of this pin) has no Gaussian binomials, so we define them by the
q-Pascal recursion and develop exactly what the Warnaar-glue results need:

* `gauss`            : [m, n]_q ∈ ℤ[X]  (X plays the role of q)
* `pascal₁`          : [m+1, n+1] = [m, n] + q^(n+1) [m, n+1]        (definitional)
* `pascal₂`          : n ≤ m → [m+1, n+1] = q^(m−n) [m, n] + [m, n+1]
* `gauss_mul_qfact`  : k ≤ n → [n, k] · [k]!_q · [n−k]!_q = [n]!_q
* `gauss_symm`       : k ≤ n → [n, k] = [n, n−k]
* `trinomial_rev`    : [n, m][m, k] = [n, k][n−k, m−k]  (k ≤ m ≤ n)
* `alt_sum`          : ∑_{i≤J} (−1)^i q^(C(i,2)) [J, i] = δ_{J,0}
* `orth_ML`, `orth_LM` : the two Gauss-inversion orthogonality relations
-/
import Mathlib

open Polynomial Finset

namespace WarnaarGlue

/-- The Gaussian binomial coefficient `[m, n]_q` as a polynomial in `ℤ[X]`,
defined by the q-Pascal recursion `[m+1, n+1] = [m, n] + q^(n+1) [m, n+1]`. -/
noncomputable def gauss : ℕ → ℕ → Polynomial ℤ
  | _, 0 => 1
  | 0, _ + 1 => 0
  | m + 1, n + 1 => gauss m n + X ^ (n + 1) * gauss m (n + 1)

@[simp] lemma gauss_zero_right (m : ℕ) : gauss m 0 = 1 := by cases m <;> rfl

@[simp] lemma gauss_zero_succ (n : ℕ) : gauss 0 (n + 1) = 0 := rfl

/-- First q-Pascal recurrence (definitional). -/
lemma pascal₁ (m n : ℕ) :
    gauss (m + 1) (n + 1) = gauss m n + X ^ (n + 1) * gauss m (n + 1) := rfl

lemma gauss_eq_zero_of_lt : ∀ {m n : ℕ}, m < n → gauss m n = 0
  | _, 0, h => absurd h (Nat.not_lt_zero _)
  | 0, _ + 1, _ => rfl
  | m + 1, n + 1, h => by
    rw [pascal₁, gauss_eq_zero_of_lt (Nat.lt_of_succ_lt_succ h),
      gauss_eq_zero_of_lt (Nat.lt_of_succ_lt_succ (Nat.lt_succ_of_lt h))]
    ring

@[simp] lemma gauss_self : ∀ n : ℕ, gauss n n = 1
  | 0 => rfl
  | n + 1 => by
    rw [pascal₁, gauss_self n, gauss_eq_zero_of_lt (Nat.lt_succ_self n)]
    ring

/-- The q-integer `[i]_q = 1 + q + ⋯ + q^(i−1)`. -/
noncomputable def qint (i : ℕ) : Polynomial ℤ := ∑ t ∈ range i, X ^ t

/-- The q-factorial `[n]!_q = [1]_q [2]_q ⋯ [n]_q`. -/
noncomputable def qfact (n : ℕ) : Polynomial ℤ := ∏ i ∈ range n, qint (i + 1)

@[simp] lemma qint_zero : qint 0 = 0 := by simp [qint]

@[simp] lemma qfact_zero : qfact 0 = 1 := by simp [qfact]

lemma qfact_succ (n : ℕ) : qfact (n + 1) = qfact n * qint (n + 1) := by
  rw [qfact, prod_range_succ, qfact]

lemma qint_add (i j : ℕ) : qint (i + j) = qint i + X ^ i * qint j := by
  rw [qint, sum_range_add, qint, qint, mul_sum]
  simp [pow_add]

lemma qint_ne_zero (i : ℕ) : qint (i + 1) ≠ 0 := by
  intro h
  have h1 : (qint (i + 1)).eval 1 = ((i : ℤ) + 1) := by
    simp [qint, eval_finsetSum]
  rw [h] at h1
  simp at h1
  omega

lemma qfact_ne_zero (n : ℕ) : qfact n ≠ 0 := by
  induction n with
  | zero => simp
  | succ n ih => rw [qfact_succ]; exact mul_ne_zero ih (qint_ne_zero n)

/-- Product form: `[n, k]_q · [k]!_q · [n−k]!_q = [n]!_q` for `k ≤ n`. -/
lemma gauss_mul_qfact : ∀ {n k : ℕ}, k ≤ n →
    gauss n k * qfact k * qfact (n - k) = qfact n
  | n, 0, _ => by simp
  | 0, k + 1, h => absurd h (by omega)
  | n + 1, k + 1, h => by
    have hk : k ≤ n := Nat.lt_succ_iff.mp h
    rw [pascal₁, add_mul, add_mul]
    have e1 : gauss n k * qfact (k + 1) * qfact (n + 1 - (k + 1)) =
        qfact n * qint (k + 1) := by
      rw [qfact_succ]
      have hs : n + 1 - (k + 1) = n - k := by omega
      rw [hs]
      calc gauss n k * (qfact k * qint (k + 1)) * qfact (n - k)
          = gauss n k * qfact k * qfact (n - k) * qint (k + 1) := by ring
        _ = qfact n * qint (k + 1) := by rw [gauss_mul_qfact hk]
    have e2 : X ^ (k + 1) * gauss n (k + 1) * qfact (k + 1) * qfact (n + 1 - (k + 1)) =
        qfact n * (X ^ (k + 1) * qint (n - k)) := by
      rcases Nat.lt_or_ge k n with hlt | hge
      · have hk1 : k + 1 ≤ n := hlt
        have hnk : n + 1 - (k + 1) = (n - (k + 1)) + 1 := by omega
        rw [hnk, qfact_succ, qfact_succ]
        have hq : qint (n - (k + 1) + 1) = qint (n - k) := by congr 1; omega
        calc X ^ (k + 1) * gauss n (k + 1) * (qfact k * qint (k + 1)) *
              (qfact (n - (k + 1)) * qint (n - (k + 1) + 1))
            = gauss n (k + 1) * (qfact k * qint (k + 1)) * qfact (n - (k + 1)) *
              (X ^ (k + 1) * qint (n - (k + 1) + 1)) := by ring
          _ = gauss n (k + 1) * qfact (k + 1) * qfact (n - (k + 1)) *
              (X ^ (k + 1) * qint (n - (k + 1) + 1)) := by rw [qfact_succ]
          _ = qfact n * (X ^ (k + 1) * qint (n - (k + 1) + 1)) := by
              rw [gauss_mul_qfact hk1]
          _ = qfact n * (X ^ (k + 1) * qint (n - k)) := by rw [hq]
      · have hkn : k = n := le_antisymm hk hge
        subst hkn
        rw [gauss_eq_zero_of_lt (Nat.lt_succ_self k)]
        simp
    rw [e1, e2, qfact_succ, ← mul_add]
    congr 1
    have hadd := qint_add (k + 1) (n - k)
    have hsplit : (k + 1) + (n - k) = n + 1 := by omega
    rw [hsplit] at hadd
    exact hadd.symm

/-- Symmetry `[n, k] = [n, n−k]` for `k ≤ n`. -/
lemma gauss_symm {n k : ℕ} (h : k ≤ n) : gauss n k = gauss n (n - k) := by
  have h' : n - k ≤ n := Nat.sub_le n k
  have e1 := gauss_mul_qfact h
  have e2 := gauss_mul_qfact h'
  rw [Nat.sub_sub_self h] at e2
  have key : gauss n k * (qfact k * qfact (n - k)) =
      gauss n (n - k) * (qfact k * qfact (n - k)) := by
    calc gauss n k * (qfact k * qfact (n - k))
        = gauss n k * qfact k * qfact (n - k) := by ring
      _ = qfact n := e1
      _ = gauss n (n - k) * qfact (n - k) * qfact k := e2.symm
      _ = gauss n (n - k) * (qfact k * qfact (n - k)) := by ring
  exact mul_right_cancel₀ (mul_ne_zero (qfact_ne_zero k) (qfact_ne_zero (n - k))) key

/-- Second q-Pascal recurrence: `[m+1, n+1] = q^(m−n) [m, n] + [m, n+1]` for `n ≤ m`. -/
lemma pascal₂ {m n : ℕ} (h : n ≤ m) :
    gauss (m + 1) (n + 1) = X ^ (m - n) * gauss m n + gauss m (n + 1) := by
  have hC : qfact (n + 1) * qfact (m - n) ≠ 0 :=
    mul_ne_zero (qfact_ne_zero _) (qfact_ne_zero _)
  apply mul_right_cancel₀ hC
  have eL : gauss (m + 1) (n + 1) * (qfact (n + 1) * qfact (m - n)) = qfact (m + 1) := by
    have e := gauss_mul_qfact (show n + 1 ≤ m + 1 by omega)
    have hs : m + 1 - (n + 1) = m - n := by omega
    rw [hs] at e
    calc gauss (m + 1) (n + 1) * (qfact (n + 1) * qfact (m - n))
        = gauss (m + 1) (n + 1) * qfact (n + 1) * qfact (m - n) := by ring
      _ = qfact (m + 1) := e
  rw [eL, add_mul]
  have e1 : X ^ (m - n) * gauss m n * (qfact (n + 1) * qfact (m - n)) =
      qfact m * (X ^ (m - n) * qint (n + 1)) := by
    rw [qfact_succ]
    calc X ^ (m - n) * gauss m n * (qfact n * qint (n + 1) * qfact (m - n))
        = gauss m n * qfact n * qfact (m - n) * (X ^ (m - n) * qint (n + 1)) := by ring
      _ = qfact m * (X ^ (m - n) * qint (n + 1)) := by rw [gauss_mul_qfact h]
  have e2 : gauss m (n + 1) * (qfact (n + 1) * qfact (m - n)) = qfact m * qint (m - n) := by
    rcases Nat.lt_or_ge n m with hlt | hge
    · have hn1 : n + 1 ≤ m := hlt
      have hm : m - n = (m - (n + 1)) + 1 := by omega
      rw [hm, show qfact (m - (n + 1) + 1) = qfact (m - (n + 1)) * qint (m - (n + 1) + 1)
        from qfact_succ _]
      calc gauss m (n + 1) * (qfact (n + 1) * (qfact (m - (n + 1)) * qint (m - (n + 1) + 1)))
          = gauss m (n + 1) * qfact (n + 1) * qfact (m - (n + 1)) *
              qint (m - (n + 1) + 1) := by ring
        _ = qfact m * qint (m - (n + 1) + 1) := by rw [gauss_mul_qfact hn1]
    · have hnm : n = m := le_antisymm h hge
      subst hnm
      rw [gauss_eq_zero_of_lt (Nat.lt_succ_self n)]
      simp
  rw [e1, e2, ← mul_add, qfact_succ]
  have hsum : qint (m + 1) = X ^ (m - n) * qint (n + 1) + qint (m - n) := by
    have hrw : (m + 1 : ℕ) = (m - n) + (n + 1) := by omega
    calc qint (m + 1) = qint ((m - n) + (n + 1)) := by rw [← hrw]
      _ = qint (m - n) + X ^ (m - n) * qint (n + 1) := qint_add _ _
      _ = X ^ (m - n) * qint (n + 1) + qint (m - n) := by ring
  rw [hsum]

/-- Reversed trinomial identity: `[n, m][m, k] = [n, k][n−k, m−k]` for `k ≤ m ≤ n`. -/
lemma trinomial_rev {n m k : ℕ} (hkm : k ≤ m) (hmn : m ≤ n) :
    gauss n m * gauss m k = gauss n k * gauss (n - k) (m - k) := by
  have hkn : k ≤ n := hkm.trans hmn
  have hC : qfact k * qfact (m - k) * qfact (n - m) ≠ 0 :=
    mul_ne_zero (mul_ne_zero (qfact_ne_zero _) (qfact_ne_zero _)) (qfact_ne_zero _)
  apply mul_right_cancel₀ hC
  have eL : gauss n m * gauss m k * (qfact k * qfact (m - k) * qfact (n - m)) = qfact n := by
    calc gauss n m * gauss m k * (qfact k * qfact (m - k) * qfact (n - m))
        = gauss n m * (gauss m k * qfact k * qfact (m - k)) * qfact (n - m) := by ring
      _ = gauss n m * qfact m * qfact (n - m) := by rw [gauss_mul_qfact hkm]
      _ = qfact n := gauss_mul_qfact hmn
  have eR : gauss n k * gauss (n - k) (m - k) *
      (qfact k * qfact (m - k) * qfact (n - m)) = qfact n := by
    have h1 : m - k ≤ n - k := by omega
    have h2 : (n - k) - (m - k) = n - m := by omega
    have e3 := gauss_mul_qfact h1
    rw [h2] at e3
    calc gauss n k * gauss (n - k) (m - k) * (qfact k * qfact (m - k) * qfact (n - m))
        = gauss n k * qfact k *
            (gauss (n - k) (m - k) * qfact (m - k) * qfact (n - m)) := by ring
      _ = gauss n k * qfact k * qfact (n - k) := by rw [e3]
      _ = qfact n := gauss_mul_qfact hkn
  rw [eL, eR]

/-- Truncated Euler / finite q-binomial theorem at `x = 1`:
`∑_{i=0}^{J} (−1)^i q^(C(i,2)) [J, i] = δ_{J,0}`. -/
lemma alt_sum : ∀ J : ℕ,
    ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ i * X ^ (i.choose 2) * gauss J i =
      if J = 0 then 1 else 0
  | 0 => by simp
  | J + 1 => by
    have hif : (if J + 1 = 0 then (1 : Polynomial ℤ) else 0) = 0 := by simp
    rw [hif, sum_range_succ']
    have h0 : (-1 : Polynomial ℤ) ^ 0 * X ^ (Nat.choose 0 2) * gauss (J + 1) 0 = 1 := by simp
    rw [h0]
    have hterm : ∀ i ∈ range (J + 1),
        (-1 : Polynomial ℤ) ^ (i + 1) * X ^ ((i + 1).choose 2) * gauss (J + 1) (i + 1) =
          (-((-1) ^ i * X ^ ((i + 1).choose 2) * gauss J i)) +
          (-((-1) ^ i * X ^ ((i + 2).choose 2) * gauss J (i + 1))) := by
      intro i _
      have hc : (i + 2).choose 2 = (i + 1).choose 2 + (i + 1) := by
        have hcs : (i + 2).choose 2 = (i + 1).choose 1 + (i + 1).choose 2 :=
          Nat.choose_succ_succ (i + 1) 1
        rw [Nat.choose_one_right] at hcs
        omega
      rw [pascal₁, hc, pow_succ, pow_add]
      ring
    rw [sum_congr rfl hterm, sum_add_distrib]
    -- Let A := ∑ (−1)^i X^(C(i+1,2)) [J,i],  Bv := ∑ (−1)^i X^(C(i+2,2)) [J,i+1].
    set A := ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ i * X ^ ((i + 1).choose 2) * gauss J i
      with hA
    set Bv := ∑ i ∈ range (J + 1),
        (-1 : Polynomial ℤ) ^ i * X ^ ((i + 2).choose 2) * gauss J (i + 1) with hBv
    have hsumA : ∑ i ∈ range (J + 1), -((-1 : Polynomial ℤ) ^ i * X ^ ((i + 1).choose 2) *
        gauss J i) = -A := by rw [hA, ← sum_neg_distrib]
    have hsumB : ∑ i ∈ range (J + 1), -((-1 : Polynomial ℤ) ^ i * X ^ ((i + 2).choose 2) *
        gauss J (i + 1)) = -Bv := by rw [hBv, ← sum_neg_distrib]
    rw [hsumA, hsumB]
    -- The full sum W over range (J+2) computes to A (top term dies) and to 1 − Bv (peel i=0).
    have h1 : ∑ s ∈ range (J + 2), (-1 : Polynomial ℤ) ^ s * X ^ ((s + 1).choose 2) *
        gauss J s = A := by
      rw [sum_range_succ, gauss_eq_zero_of_lt (Nat.lt_succ_self J), hA]
      ring
    have h2 : ∑ s ∈ range (J + 2), (-1 : Polynomial ℤ) ^ s * X ^ ((s + 1).choose 2) *
        gauss J s = -Bv + 1 := by
      rw [sum_range_succ']
      have hw0 : (-1 : Polynomial ℤ) ^ 0 * X ^ (Nat.choose 1 2) * gauss J 0 = 1 := by
        simp
      rw [hw0]
      congr 1
      rw [hBv, ← sum_neg_distrib]
      refine sum_congr rfl fun i _ => ?_
      rw [pow_succ]
      ring
    linear_combination h1 - h2

/-- Orthogonality (inverse-then-forward, `M·L = I`):
`∑_{m=0}^{n} (−1)^(n−m) q^(C(n−m,2)) [n,m][m,k] = δ_{n,k}`. -/
lemma orth_ML (n k : ℕ) :
    ∑ m ∈ range (n + 1), (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) *
      (gauss n m * gauss m k) = if n = k then 1 else 0 := by
  rcases Nat.lt_or_ge n k with hnk | hkn
  · -- k > n : every term has [m, k] = 0
    have hz : ∀ m ∈ range (n + 1), (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) *
        (gauss n m * gauss m k) = 0 := by
      intro m hm
      rw [gauss_eq_zero_of_lt (lt_of_le_of_lt (Nat.lt_succ_iff.mp (mem_range.mp hm)) hnk)]
      ring
    rw [sum_congr rfl hz]
    simp [Nat.ne_of_lt hnk]
  · -- k ≤ n
    set J := n - k with hJ
    -- Drop the vanishing terms m < k.
    have hsub : ∑ m ∈ range (n + 1), (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) *
        (gauss n m * gauss m k) =
        ∑ m ∈ Ico k (n + 1), (-1 : Polynomial ℤ) ^ (n - m) * X ^ ((n - m).choose 2) *
        (gauss n m * gauss m k) := by
      rw [range_eq_Ico]
      refine (sum_subset (Ico_subset_Ico (Nat.zero_le k) le_rfl) ?_).symm
      intro m hm hnotm
      have hmk : m < k := by
        simp only [mem_Ico] at hm hnotm
        omega
      rw [gauss_eq_zero_of_lt hmk]
      ring
    rw [hsub, sum_Ico_eq_sum_range]
    have hcard : n + 1 - k = J + 1 := by omega
    rw [hcard]
    -- Rewrite each term via the trinomial identity.
    have hterm : ∀ i ∈ range (J + 1),
        (-1 : Polynomial ℤ) ^ (n - (k + i)) * X ^ ((n - (k + i)).choose 2) *
          (gauss n (k + i) * gauss (k + i) k) =
        gauss n k * ((-1 : Polynomial ℤ) ^ (J - i) * X ^ ((J - i).choose 2) *
          gauss J i) := by
      intro i hi
      have hik : k ≤ k + i := Nat.le_add_right k i
      have hin : k + i ≤ n := by
        have := mem_range.mp hi
        omega
      have htri := trinomial_rev hik hin
      have hJi : n - (k + i) = J - i := by omega
      have hki : (k + i) - k = i := by omega
      rw [htri, hJi, hki, hJ]
      ring
    rw [sum_congr rfl hterm, ← mul_sum]
    -- Reflect the sum and use symmetry [J, J−i] = [J, i], then alt_sum.
    have hrefl : ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ (J - i) * X ^ ((J - i).choose 2) *
        gauss J i = ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ i * X ^ (i.choose 2) *
        gauss J i := by
      have := sum_range_reflect
        (fun i => (-1 : Polynomial ℤ) ^ i * X ^ (i.choose 2) * gauss J (J - i)) (J + 1)
      -- this : ∑ j ∈ range (J+1), f (J+1−1−j) = ∑ j ∈ range (J+1), f j
      -- f (J − j) = (−1)^(J−j) X^(C(J−j,2)) gauss J (J − (J − j)) and J−(J−j) = j inside range
      calc ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ (J - i) * X ^ ((J - i).choose 2) *
              gauss J i
          = ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ (J + 1 - 1 - i) *
              X ^ ((J + 1 - 1 - i).choose 2) * gauss J (J - (J + 1 - 1 - i)) := by
            refine sum_congr rfl fun i hi => ?_
            have hiJ : i ≤ J := Nat.lt_succ_iff.mp (mem_range.mp hi)
            have e1 : J + 1 - 1 - i = J - i := by omega
            have e2 : J - (J - i) = i := Nat.sub_sub_self hiJ
            rw [e1, e2]
        _ = ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ i * X ^ (i.choose 2) *
              gauss J (J - i) := this
        _ = ∑ i ∈ range (J + 1), (-1 : Polynomial ℤ) ^ i * X ^ (i.choose 2) * gauss J i := by
            refine sum_congr rfl fun i hi => ?_
            have hiJ : i ≤ J := Nat.lt_succ_iff.mp (mem_range.mp hi)
            rw [← gauss_symm hiJ]
    rw [hrefl, alt_sum]
    by_cases hnk' : n = k
    · have : J = 0 := by omega
      simp [hnk', this]
    · have : J ≠ 0 := by omega
      simp [hnk', this]

/-- Orthogonality (forward-then-inverse, `L·M = I`):
`∑_{j=0}^{n} [n,j] (−1)^(j−k) q^(C(j−k,2)) [j,k] = δ_{n,k}`. -/
lemma orth_LM (n k : ℕ) :
    ∑ j ∈ range (n + 1), gauss n j *
      ((-1 : Polynomial ℤ) ^ (j - k) * X ^ ((j - k).choose 2) * gauss j k) =
      if n = k then 1 else 0 := by
  rcases Nat.lt_or_ge n k with hnk | hkn
  · have hz : ∀ j ∈ range (n + 1), gauss n j *
        ((-1 : Polynomial ℤ) ^ (j - k) * X ^ ((j - k).choose 2) * gauss j k) = 0 := by
      intro j hj
      rw [gauss_eq_zero_of_lt (lt_of_le_of_lt (Nat.lt_succ_iff.mp (mem_range.mp hj)) hnk)]
      ring
    rw [sum_congr rfl hz]
    simp [Nat.ne_of_lt hnk]
  · set J := n - k with hJ
    have hsub : ∑ j ∈ range (n + 1), gauss n j *
        ((-1 : Polynomial ℤ) ^ (j - k) * X ^ ((j - k).choose 2) * gauss j k) =
        ∑ j ∈ Ico k (n + 1), gauss n j *
        ((-1 : Polynomial ℤ) ^ (j - k) * X ^ ((j - k).choose 2) * gauss j k) := by
      rw [range_eq_Ico]
      refine (sum_subset (Ico_subset_Ico (Nat.zero_le k) le_rfl) ?_).symm
      intro j hj hnotj
      have hjk : j < k := by
        simp only [mem_Ico] at hj hnotj
        omega
      rw [gauss_eq_zero_of_lt hjk]
      ring
    rw [hsub, sum_Ico_eq_sum_range]
    have hcard : n + 1 - k = J + 1 := by omega
    rw [hcard]
    have hterm : ∀ t ∈ range (J + 1),
        gauss n (k + t) * ((-1 : Polynomial ℤ) ^ ((k + t) - k) * X ^ (((k + t) - k).choose 2) *
          gauss (k + t) k) =
        gauss n k * ((-1 : Polynomial ℤ) ^ t * X ^ (t.choose 2) * gauss J t) := by
      intro t ht
      have hik : k ≤ k + t := Nat.le_add_right k t
      have hin : k + t ≤ n := by
        have := mem_range.mp ht
        omega
      have hkt : (k + t) - k = t := by omega
      calc gauss n (k + t) * ((-1 : Polynomial ℤ) ^ ((k + t) - k) *
              X ^ (((k + t) - k).choose 2) * gauss (k + t) k)
          = (-1 : Polynomial ℤ) ^ t * X ^ (t.choose 2) *
              (gauss n (k + t) * gauss (k + t) k) := by rw [hkt]; ring
        _ = (-1 : Polynomial ℤ) ^ t * X ^ (t.choose 2) *
              (gauss n k * gauss (n - k) ((k + t) - k)) := by
            rw [trinomial_rev hik hin]
        _ = gauss n k * ((-1 : Polynomial ℤ) ^ t * X ^ (t.choose 2) * gauss J t) := by
            rw [hkt, ← hJ]
            ring
    rw [sum_congr rfl hterm, ← mul_sum, alt_sum]
    by_cases hnk' : n = k
    · have : J = 0 := by omega
      simp [hnk', this]
    · have : J ≠ 0 := by omega
      simp [hnk', this]

end WarnaarGlue
