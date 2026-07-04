/-
Seed 7, Layer 4 (Round 2): Theorem D — the kernel identities of the D-tower —
machine-checked, plus the ferm-monotonicity statements and Lemma E.

Theorem D (synthesis-layer3.md G6, prove-seed7-layer3.tex): from Corollary I
(H_m = ∑_{n≤m} [m,n]_q Q_n, here the named hypothesis `hI`), every object of
the bounded tower is a componentwise-nonneg unitriangular kernel applied to
(Q_j):

  h_m  = H_m − (1−q^m) H_{m−1}          = ∑_j q^(m−j) [m,j]_q Q_j
  Δ_m  = H_m − H_{m−1}                  = ∑_j q^(m−j) [m−1,j−1]_q Q_j
  D_k^m (D-tower, D_0 = h,
         D_{k+1}^m = D_k^m − q^(k+1) D_k^(m−1))
                                        = ∑_j q^((k+1)(m−j)) [m−k, j−k]_q Q_j
  Q_n = D_n^n  (diagonal recovery).

Index conventions here (all ℕ-subtraction-safe):
* `Dtower q H k m` is D_k^m; theorems are stated at m = k + M, and the general
  identity reads  D_k^(k+M) = ∑_{i≤M} q^((k+1)(M−i)) [M,i]_q Q_(k+i)
  (substitute j = k + i in the synthesis form).
* Δ is stated at m+1:  H_(m+1) − H_m = ∑_{i≤m} q^(m−i) [m,i]_q Q_(i+1)
  (substitute j = i + 1 in the synthesis form).

Ferm-monotonicity (the "nonneg-coefficients predicate" statement, at
(A,q) = (ℤ[X], X) with the existing `CoeffNonneg`): if all Q_n are
coefficientwise nonneg then all h_m and all Δ_m are — i.e. Monotonicity and
h-positivity are nonneg-kernel consequences of Q-positivity (§4(ix)).

Lemma E (prove-seed7-layer3.tex, the truncated-Euler telescoping behind
Theorem Q), cleared of denominators: with (q;q)_K/(q;q)_k = ∏_{i=k+1}^K (1−q^i)
(`qpochRatio k K`),
  ∑_{k≤K} (−1)^k q^C(k,2) · qpochRatio k K = (−1)^K q^C(K+1,2).
Dividing by (q;q)_K recovers the series form
  ∑_{k≤K} (−1)^k q^C(k,2)/(q;q)_k = (−1)^K q^C(K+1,2)/(q;q)_K.
-/
import WarnaarGlue.D4Positive
import WarnaarGlue.Seed2Chain

open Polynomial Finset

namespace WarnaarGlue

variable {A : Type*} [CommRing A]

/-! ### Transported q-Pascal and the smoothing-factor identity -/

/-- q-Pascal `[m+1,n+1] = q^(m−n)[m,n] + [m,n+1]` transported to `(A, q)`. -/
lemma gaussq_pascal₂ (q : A) {m n : ℕ} (h : n ≤ m) :
    gaussq q (m + 1) (n + 1) = q ^ (m - n) * gaussq q m n + gaussq q m (n + 1) := by
  have hh := congrArg (aeval q (R := ℤ)) (pascal₂ h)
  simpa [gaussq, map_add, map_mul, map_pow, aeval_X] using hh

/-- The smoothing-factor cancellation, `qint` form:
`[i]_q·[m+1,j] = [m+1]_q·[m,j]` with `i = m+1−j`, for `j ≤ m`. -/
lemma qint_mul_gauss {m j : ℕ} (h : j ≤ m) :
    qint (m + 1 - j) * gauss (m + 1) j = qint (m + 1) * gauss m j := by
  have hC : qfact j * qfact (m - j) ≠ 0 :=
    mul_ne_zero (qfact_ne_zero _) (qfact_ne_zero _)
  apply mul_right_cancel₀ hC
  have hs : m + 1 - j = (m - j) + 1 := by omega
  have e1 : qint (m + 1 - j) * gauss (m + 1) j * (qfact j * qfact (m - j)) =
      qfact (m + 1) := by
    have e := gauss_mul_qfact (show j ≤ m + 1 by omega)
    calc qint (m + 1 - j) * gauss (m + 1) j * (qfact j * qfact (m - j))
        = gauss (m + 1) j * qfact j * (qfact (m - j) * qint ((m - j) + 1)) := by
          rw [hs]; ring
      _ = gauss (m + 1) j * qfact j * qfact ((m - j) + 1) := by rw [← qfact_succ]
      _ = gauss (m + 1) j * qfact j * qfact (m + 1 - j) := by rw [← hs]
      _ = qfact (m + 1) := e
  have e2 : qint (m + 1) * gauss m j * (qfact j * qfact (m - j)) = qfact (m + 1) := by
    calc qint (m + 1) * gauss m j * (qfact j * qfact (m - j))
        = gauss m j * qfact j * qfact (m - j) * qint (m + 1) := by ring
      _ = qfact m * qint (m + 1) := by rw [gauss_mul_qfact h]
      _ = qfact (m + 1) := (qfact_succ m).symm
  rw [e1, e2]

/-- `(1 − q^(m+1−j))·[m+1,j] = (1 − q^(m+1))·[m,j]` in `ℤ[X]`, all `j ≤ m+1`
(at `j = m+1` both sides vanish). The exact content of
`h_m = ∑ q^(m−j)[m,j]Q_j` given Corollary I. -/
lemma one_sub_pow_mul_gauss {m j : ℕ} (h : j ≤ m + 1) :
    (1 - X ^ (m + 1 - j)) * gauss (m + 1) j =
      ((1 : Polynomial ℤ) - X ^ (m + 1)) * gauss m j := by
  rcases Nat.lt_or_ge j (m + 1) with hj | hj
  · have hjm : j ≤ m := by omega
    have hs : m + 1 - j = (m - j) + 1 := by omega
    calc (1 - X ^ (m + 1 - j)) * gauss (m + 1) j
        = (1 - X) * (qint (m + 1 - j) * gauss (m + 1) j) := by
          rw [hs, one_sub_X_pow]; ring
      _ = (1 - X) * (qint (m + 1) * gauss m j) := by rw [qint_mul_gauss hjm]
      _ = (1 - X ^ (m + 1)) * gauss m j := by rw [one_sub_X_pow m]; ring
  · have hje : j = m + 1 := by omega
    subst hje
    rw [gauss_eq_zero_of_lt (Nat.lt_succ_self m), Nat.sub_self]
    simp

/-- The smoothing-factor identity transported to `(A, q)`. -/
lemma one_sub_pow_mul_gaussq (q : A) {m j : ℕ} (h : j ≤ m + 1) :
    (1 - q ^ (m + 1 - j)) * gaussq q (m + 1) j =
      (1 - q ^ (m + 1)) * gaussq q m j := by
  have hh := congrArg (aeval q (R := ℤ)) (one_sub_pow_mul_gauss h)
  simpa [gaussq, map_mul, map_sub, map_pow, map_one, aeval_X] using hh

/-! ### The D-tower -/

/-- The D-tower on a sequence `H` (per profile): `D_0^m = h_m`
(with the empty convention `h_0 = H_0`), and
`D_{k+1}^m = D_k^m − q^(k+1)·D_k^(m−1)`. `Q_n = D_n^n` is recovered below. -/
noncomputable def Dtower (q : A) (H : ℕ → A) : ℕ → ℕ → A
  | 0, 0 => H 0
  | 0, m + 1 => H (m + 1) - (1 - q ^ (m + 1)) * H m
  | k + 1, m => Dtower q H k m - q ^ (k + 1) * Dtower q H k (m - 1)

variable (q : A) (H Q : ℕ → A)

@[simp] lemma Dtower_zero_zero : Dtower q H 0 0 = H 0 := rfl

lemma Dtower_zero_succ (m : ℕ) :
    Dtower q H 0 (m + 1) = H (m + 1) - (1 - q ^ (m + 1)) * H m := rfl

lemma Dtower_succ (k m : ℕ) :
    Dtower q H (k + 1) m = Dtower q H k m - q ^ (k + 1) * Dtower q H k (m - 1) := rfl

/-! ### Theorem D -/

/-- **Theorem D, base row**: `h_m = ∑_{j≤m} q^(m−j) [m,j]_q Q_j`. -/
theorem hm_eq (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n) :
    ∀ m, Dtower q H 0 m = ∑ j ∈ range (m + 1), q ^ (m - j) * gaussq q m j * Q j := by
  intro m
  cases m with
  | zero => simpa using hI 0
  | succ m =>
    have hext : ∑ j ∈ range (m + 2), gaussq q m j * Q j
        = ∑ j ∈ range (m + 1), gaussq q m j * Q j := by
      rw [sum_range_succ, gaussq_eq_zero_of_lt q (Nat.lt_succ_self m), zero_mul, add_zero]
    have key : ∀ j ∈ range (m + 2),
        (1 - q ^ (m + 1 - j)) * gaussq q (m + 1) j * Q j
          = (1 - q ^ (m + 1)) * (gaussq q m j * Q j) := by
      intro j hj
      have hjle : j ≤ m + 1 := Nat.lt_succ_iff.mp (mem_range.mp hj)
      rw [one_sub_pow_mul_gaussq q hjle]
      ring
    calc Dtower q H 0 (m + 1)
        = H (m + 1) - (1 - q ^ (m + 1)) * H m := rfl
      _ = ∑ j ∈ range (m + 2), gaussq q (m + 1) j * Q j
            - ∑ j ∈ range (m + 2), (1 - q ^ (m + 1)) * (gaussq q m j * Q j) := by
          rw [hI (m + 1), hI m, ← hext, mul_sum]
      _ = ∑ j ∈ range (m + 2),
            (gaussq q (m + 1) j * Q j - (1 - q ^ (m + 1)) * (gaussq q m j * Q j)) := by
          rw [sum_sub_distrib]
      _ = ∑ j ∈ range (m + 2), q ^ (m + 1 - j) * gaussq q (m + 1) j * Q j := by
          refine sum_congr rfl fun j hj => ?_
          linear_combination key j hj

/-- **Theorem D, general row** (induction on `k`, q-Pascal at each step):
`D_k^(k+M) = ∑_{i≤M} q^((k+1)(M−i)) [M,i]_q Q_(k+i)` — the synthesis form
`D_k^m = ∑_j q^((k+1)(m−j)) [m−k,j−k]_q Q_j` at `m = k+M`, `j = k+i`. -/
theorem Dtower_eq (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n) :
    ∀ k M, Dtower q H k (k + M)
      = ∑ i ∈ range (M + 1), q ^ ((k + 1) * (M - i)) * gaussq q M i * Q (k + i) := by
  intro k
  induction k with
  | zero =>
    intro M
    simpa using hm_eq q H Q hI M
  | succ k ih =>
    intro M
    have hrec : Dtower q H (k + 1) (k + 1 + M)
        = Dtower q H k (k + (M + 1)) - q ^ (k + 1) * Dtower q H k (k + M) := by
      have e1 : k + 1 + M - 1 = k + M := by omega
      have e2 : k + 1 + M = k + (M + 1) := by omega
      rw [Dtower_succ, e1, e2]
    rw [hrec, ih (M + 1), ih M]
    have hS : (∑ i ∈ range (M + 2),
          q ^ ((k + 1) * (M + 1 - i)) * gaussq q (M + 1) i * Q (k + i))
        = (∑ i ∈ range (M + 1), q ^ ((k + 2) * (M - i)) * gaussq q M i * Q (k + 1 + i))
          + ((∑ i ∈ range (M + 1),
              q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i))
            + q ^ ((k + 1) * (M + 1)) * Q k) := by
      rw [sum_range_succ']
      have hterm : ∀ i ∈ range (M + 1),
          q ^ ((k + 1) * (M + 1 - (i + 1))) * gaussq q (M + 1) (i + 1) * Q (k + (i + 1))
            = q ^ ((k + 2) * (M - i)) * gaussq q M i * Q (k + 1 + i)
              + q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by
        intro i hi
        have hiM : i ≤ M := Nat.lt_succ_iff.mp (mem_range.mp hi)
        have e1 : M + 1 - (i + 1) = M - i := by omega
        have e2 : (k + 1) * (M - i) + (M - i) = (k + 2) * (M - i) := by ring
        have e3 : k + (i + 1) = k + 1 + i := by omega
        rw [e1, e3, gaussq_pascal₂ q hiM]
        calc q ^ ((k + 1) * (M - i)) * (q ^ (M - i) * gaussq q M i + gaussq q M (i + 1))
              * Q (k + 1 + i)
            = q ^ ((k + 1) * (M - i) + (M - i)) * gaussq q M i * Q (k + 1 + i)
              + q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by
              rw [pow_add]; ring
          _ = q ^ ((k + 2) * (M - i)) * gaussq q M i * Q (k + 1 + i)
              + q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by
              rw [e2]
      rw [sum_congr rfl hterm, sum_add_distrib]
      have htail : q ^ ((k + 1) * (M + 1 - 0)) * gaussq q (M + 1) 0 * Q (k + 0)
          = q ^ ((k + 1) * (M + 1)) * Q k := by
        simp only [gaussq_zero_right, Nat.sub_zero, Nat.add_zero, mul_one]
      rw [htail]
      ring
    have hT : q ^ (k + 1)
          * (∑ i ∈ range (M + 1), q ^ ((k + 1) * (M - i)) * gaussq q M i * Q (k + i))
        = (∑ i ∈ range (M + 1),
            q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i))
          + q ^ ((k + 1) * (M + 1)) * Q k := by
      rw [mul_sum, sum_range_succ']
      have hterm : ∀ i ∈ range M,
          q ^ (k + 1) * (q ^ ((k + 1) * (M - (i + 1))) * gaussq q M (i + 1) * Q (k + (i + 1)))
            = q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by
        intro i hi
        have hiM : i < M := mem_range.mp hi
        have e1 : (k + 1) + (k + 1) * (M - (i + 1)) = (k + 1) * (M - i) := by
          have h2 : M - i = (M - (i + 1)) + 1 := by omega
          rw [h2, Nat.mul_add, Nat.mul_one]
          omega
        have e3 : k + (i + 1) = k + 1 + i := by omega
        rw [e3]
        calc q ^ (k + 1)
              * (q ^ ((k + 1) * (M - (i + 1))) * gaussq q M (i + 1) * Q (k + 1 + i))
            = q ^ ((k + 1) + (k + 1) * (M - (i + 1))) * gaussq q M (i + 1)
              * Q (k + 1 + i) := by rw [pow_add]; ring
          _ = q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by rw [e1]
      have htop : ∑ i ∈ range (M + 1),
            q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i)
          = ∑ i ∈ range M,
            q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i) := by
        rw [sum_range_succ, gaussq_eq_zero_of_lt q (Nat.lt_succ_self M)]
        simp
      have htail : q ^ (k + 1) * (q ^ ((k + 1) * (M - 0)) * gaussq q M 0 * Q (k + 0))
          = q ^ ((k + 1) * (M + 1)) * Q k := by
        have e : (k + 1) + (k + 1) * M = (k + 1) * (M + 1) := by ring
        simp only [gaussq_zero_right, Nat.sub_zero, Nat.add_zero, mul_one]
        calc q ^ (k + 1) * (q ^ ((k + 1) * M) * Q k)
            = q ^ ((k + 1) + (k + 1) * M) * Q k := by rw [pow_add]; ring
          _ = q ^ ((k + 1) * (M + 1)) * Q k := by rw [e]
      calc ∑ i ∈ range M,
              q ^ (k + 1) * (q ^ ((k + 1) * (M - (i + 1))) * gaussq q M (i + 1)
                * Q (k + (i + 1)))
            + q ^ (k + 1) * (q ^ ((k + 1) * (M - 0)) * gaussq q M 0 * Q (k + 0))
          = ∑ i ∈ range M, q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i)
            + q ^ ((k + 1) * (M + 1)) * Q k := by
            rw [sum_congr rfl hterm, htail]
        _ = ∑ i ∈ range (M + 1), q ^ ((k + 1) * (M - i)) * gaussq q M (i + 1) * Q (k + 1 + i)
            + q ^ ((k + 1) * (M + 1)) * Q k := by rw [htop]
    have egoal : k + 1 + M = k + (M + 1) := by omega
    rw [hS, hT]
    ring

/-- **Diagonal recovery**: `Q_n = D_n^n` — the tower's diagonal returns the
conjecture's objects (Layer-1/2 GREEN `Q_n = D_n^n`, now from Corollary I). -/
theorem Dtower_diag (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n) (n : ℕ) :
    Dtower q H n n = Q n := by
  simpa using Dtower_eq q H Q hI n 0

/-- **Theorem D, Δ row**: `Δ_(m+1) = H_(m+1) − H_m = ∑_{i≤m} q^(m−i) [m,i]_q Q_(i+1)`
(the synthesis form `Δ_m = ∑_j q^(m−j) [m−1,j−1]_q Q_j` at `j = i+1`). -/
theorem delta_eq (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq q m n * Q n) (m : ℕ) :
    H (m + 1) - H m = ∑ i ∈ range (m + 1), q ^ (m - i) * gaussq q m i * Q (i + 1) := by
  have hext : ∑ j ∈ range (m + 2), gaussq q m j * Q j
      = ∑ j ∈ range (m + 1), gaussq q m j * Q j := by
    rw [sum_range_succ, gaussq_eq_zero_of_lt q (Nat.lt_succ_self m), zero_mul, add_zero]
  calc H (m + 1) - H m
      = ∑ j ∈ range (m + 2), gaussq q (m + 1) j * Q j
        - ∑ j ∈ range (m + 2), gaussq q m j * Q j := by rw [hI (m + 1), hI m, ← hext]
    _ = ∑ j ∈ range (m + 2), (gaussq q (m + 1) j * Q j - gaussq q m j * Q j) := by
        rw [sum_sub_distrib]
    _ = ∑ i ∈ range (m + 1),
          (gaussq q (m + 1) (i + 1) * Q (i + 1) - gaussq q m (i + 1) * Q (i + 1)) := by
        rw [sum_range_succ']
        simp
    _ = ∑ i ∈ range (m + 1), q ^ (m - i) * gaussq q m i * Q (i + 1) := by
        refine sum_congr rfl fun i hi => ?_
        have hiM : i ≤ m := Nat.lt_succ_iff.mp (mem_range.mp hi)
        rw [gaussq_pascal₂ q hiM]
        ring

/-! ### Ferm-monotonicity: the nonneg-kernel consequences at (ℤ[X], X)

Per synthesis-layer3.md §4(ix): Monotonicity and h-positivity are NOT
independent conjectures — they follow from Q-positivity through the
manifestly-nonneg kernels above. Machine-checked form of that reduction. -/

/-- If all `Q_n` are coefficientwise nonneg then all `h_m` are
(h-positivity is a nonneg-kernel consequence of Q-positivity). -/
theorem ferm_hm_nonneg (H Q : ℕ → Polynomial ℤ)
    (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq (X : Polynomial ℤ) m n * Q n)
    (hQ : ∀ n, CoeffNonneg (Q n)) (m : ℕ) :
    CoeffNonneg (Dtower (X : Polynomial ℤ) H 0 m) := by
  rw [hm_eq (X : Polynomial ℤ) H Q hI m]
  refine CoeffNonneg.sum _ _ fun j _ => ?_
  rw [gaussq_X]
  exact ((CoeffNonneg.X_pow _).mul (gauss_nonneg _ _)).mul (hQ j)

/-- If all `Q_n` are coefficientwise nonneg then `H` is monotone,
`H_(m+1) ≥ H_m` coefficientwise (ferm-monotonicity). -/
theorem ferm_monotone (H Q : ℕ → Polynomial ℤ)
    (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq (X : Polynomial ℤ) m n * Q n)
    (hQ : ∀ n, CoeffNonneg (Q n)) (m : ℕ) :
    CoeffNonneg (H (m + 1) - H m) := by
  rw [delta_eq (X : Polynomial ℤ) H Q hI m]
  refine CoeffNonneg.sum _ _ fun i _ => ?_
  rw [gaussq_X]
  exact ((CoeffNonneg.X_pow _).mul (gauss_nonneg _ _)).mul (hQ (i + 1))

/-- Every full D-tower row is coefficientwise nonneg under Q-positivity:
the tower kernel `q^((k+1)(M−i)) [M,i]` is manifestly nonneg. -/
theorem ferm_Dtower_nonneg (H Q : ℕ → Polynomial ℤ)
    (hI : ∀ m, H m = ∑ n ∈ range (m + 1), gaussq (X : Polynomial ℤ) m n * Q n)
    (hQ : ∀ n, CoeffNonneg (Q n)) (k M : ℕ) :
    CoeffNonneg (Dtower (X : Polynomial ℤ) H k (k + M)) := by
  rw [Dtower_eq (X : Polynomial ℤ) H Q hI k M]
  refine CoeffNonneg.sum _ _ fun i _ => ?_
  rw [gaussq_X]
  exact ((CoeffNonneg.X_pow _).mul (gauss_nonneg _ _)).mul (hQ (k + i))

/-! ### Lemma E: the truncated-Euler telescoping, cleared of denominators -/

/-- `(q;q)_K / (q;q)_k` as the honest polynomial `∏_{i=k+1}^{K} (1 − q^i)`. -/
noncomputable def qpochRatio (k K : ℕ) : Polynomial ℤ := ∏ i ∈ Ico k K, (1 - X ^ (i + 1))

@[simp] lemma qpochRatio_self (k : ℕ) : qpochRatio k k = 1 := by simp [qpochRatio]

lemma qpochRatio_succ_right {k K : ℕ} (h : k ≤ K) :
    qpochRatio k (K + 1) = qpochRatio k K * (1 - X ^ (K + 1)) := by
  rw [qpochRatio, Finset.prod_Ico_succ_top h, qpochRatio]

/-- At `k = 0` the ratio is the full Pochhammer `(q;q)_K` of Seed2Chain. -/
lemma qpochRatio_zero_left (K : ℕ) : qpochRatio 0 K = qpoch K := by
  rw [qpochRatio, qpoch, range_eq_Ico]

/-- **Lemma E** (prove-seed7-layer3.tex), cleared of denominators:
`∑_{k≤K} (−1)^k q^C(k,2) (q;q)_K/(q;q)_k = (−1)^K q^C(K+1,2)`.
This is the finite telescoping behind Theorem Q; dividing by `(q;q)_K`
recovers the series form. -/
theorem lemmaE : ∀ K : ℕ,
    ∑ k ∈ range (K + 1), (-1 : Polynomial ℤ) ^ k * X ^ (k.choose 2) * qpochRatio k K
      = (-1 : Polynomial ℤ) ^ K * X ^ ((K + 1).choose 2)
  | 0 => by simp
  | K + 1 => by
    rw [sum_range_succ]
    have hstep : ∀ k ∈ range (K + 1),
        (-1 : Polynomial ℤ) ^ k * X ^ (k.choose 2) * qpochRatio k (K + 1)
          = ((-1 : Polynomial ℤ) ^ k * X ^ (k.choose 2) * qpochRatio k K)
            * (1 - X ^ (K + 1)) := by
      intro k hk
      rw [qpochRatio_succ_right (Nat.lt_succ_iff.mp (mem_range.mp hk))]
      ring
    rw [sum_congr rfl hstep, ← sum_mul, lemmaE K, qpochRatio_self]
    have hc : (K + 2).choose 2 = (K + 1).choose 2 + (K + 1) := by
      have hcs : (K + 2).choose 2 = (K + 1).choose 1 + (K + 1).choose 2 :=
        Nat.choose_succ_succ (K + 1) 1
      rw [Nat.choose_one_right] at hcs
      omega
    rw [hc, pow_add, pow_succ]
    ring

end WarnaarGlue
