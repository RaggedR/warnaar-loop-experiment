/-
Seed 1, Layer 3 (Round 2): the A2 Pascal ladder, machine-checked.

With  ferm(m, a, b, c) = ∑_{n≤m} ∑_{j≤2n+c} q^(n²−nj+j²+an+bj) [m,n]_q [2n+c,j]_q
(Seed 4's two-variable fermionic shape), the surplus operator acts by a lattice
ray:   ferm(m,a,b,c) − ferm(m−1,a,b,c) = q^(m+a) · ferm(m−1, a+1, b−1, c+2).

Proof (Seed 1's one-liner): q-Pascal [m,n] − [m−1,n] = q^(m−n) [m−1,n−1] on the
only m-dependent factor, reindex n → n+1; the j-binomial is inert and becomes
[2(n+1)+c, j] = [2n+(c+2), j]; exponent bookkeeping gives (a+1, b−1) and q^(m+a).

Since a, b range over ℤ, exponents live in ℤ and we work in the Laurent
polynomial ring ℤ[q, q⁻¹] with q^z = LaurentPolynomial.T z.
(Restriction vs the scratch statement: c : ℕ, not ℤ — the ladder ray c ↦ c+2
preserves ℕ and every orbit instantiation has c ≥ 0.)
-/
import WarnaarGlue.GaussBinomial

open Polynomial Finset LaurentPolynomial

namespace WarnaarGlue

/-- Seed 1 / Seed 4's fermionic double sum, as a Laurent polynomial in `q`:
`ferm m a b c = ∑_{n≤m} ∑_{j≤2n+c} q^(n²−nj+j²+an+bj) [m,n]_q [2n+c,j]_q`. -/
noncomputable def ferm (m : ℕ) (a b : ℤ) (c : ℕ) : LaurentPolynomial ℤ :=
  ∑ n ∈ range (m + 1), ∑ j ∈ range (2 * n + c + 1),
    T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + a * (n : ℤ) + b * (j : ℤ)) *
      ((gauss m n).toLaurent * (gauss (2 * n + c) j).toLaurent)

/-- q-Pascal in difference form: `[m+1, n+1] − [m, n+1] = q^(m−n) [m, n]`. -/
lemma pascal_diff {m n : ℕ} (h : n ≤ m) :
    gauss (m + 1) (n + 1) - gauss m (n + 1) = X ^ (m - n) * gauss m n := by
  rw [pascal₂ h]
  ring

/-- Per-term identity for the ladder: the (n+1, j) term of the difference equals
`q^(m+1+a)` times the (n, j) term of `ferm m (a+1) (b−1) (c+2)`. -/
lemma ladder_term {m n : ℕ} (hnm : n ≤ m) (j : ℕ) (a b : ℤ) (c : ℕ) :
    T (((n + 1 : ℕ) : ℤ) ^ 2 - ((n + 1 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
        a * ((n + 1 : ℕ) : ℤ) + b * (j : ℤ)) *
      ((X ^ (m - n) * gauss m n).toLaurent * (gauss (2 * (n + 1) + c) j).toLaurent) =
    T ((m : ℤ) + 1 + a) *
      (T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + (a + 1) * (n : ℤ) +
          (b - 1) * (j : ℤ)) *
        ((gauss m n).toLaurent * (gauss (2 * n + (c + 2)) j).toLaurent)) := by
  have h2 : 2 * (n + 1) + c = 2 * n + (c + 2) := by omega
  have hcast : ((m - n : ℕ) : ℤ) = (m : ℤ) - (n : ℤ) := by omega
  calc T (((n + 1 : ℕ) : ℤ) ^ 2 - ((n + 1 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
          a * ((n + 1 : ℕ) : ℤ) + b * (j : ℤ)) *
        ((X ^ (m - n) * gauss m n).toLaurent * (gauss (2 * (n + 1) + c) j).toLaurent)
      = (T (((n + 1 : ℕ) : ℤ) ^ 2 - ((n + 1 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
            a * ((n + 1 : ℕ) : ℤ) + b * (j : ℤ)) * T (((m - n : ℕ) : ℤ))) *
          ((gauss m n).toLaurent * (gauss (2 * n + (c + 2)) j).toLaurent) := by
        rw [h2, map_mul, Polynomial.toLaurent_X_pow]
        ring
    _ = T ((((n + 1 : ℕ) : ℤ) ^ 2 - ((n + 1 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
            a * ((n + 1 : ℕ) : ℤ) + b * (j : ℤ)) + ((m : ℤ) - (n : ℤ))) *
          ((gauss m n).toLaurent * (gauss (2 * n + (c + 2)) j).toLaurent) := by
        rw [← T_add, hcast]
    _ = T (((m : ℤ) + 1 + a) + ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
            (a + 1) * (n : ℤ) + (b - 1) * (j : ℤ))) *
          ((gauss m n).toLaurent * (gauss (2 * n + (c + 2)) j).toLaurent) := by
        congr 1
        push_cast
        ring
    _ = T ((m : ℤ) + 1 + a) *
          (T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + (a + 1) * (n : ℤ) +
              (b - 1) * (j : ℤ)) *
            ((gauss m n).toLaurent * (gauss (2 * n + (c + 2)) j).toLaurent)) := by
        rw [T_add]
        ring

/-- **Seed 1's A2 Pascal ladder** (Result 5, Layer 3, Round 2):
`ferm(m+1, a, b, c) − ferm(m, a, b, c) = q^(m+1+a) · ferm(m, a+1, b−1, c+2)`. -/
theorem pascal_ladder (m : ℕ) (a b : ℤ) (c : ℕ) :
    ferm (m + 1) a b c - ferm m a b c =
      T ((m : ℤ) + 1 + a) * ferm m (a + 1) (b - 1) (c + 2) := by
  -- Extend the smaller sum to the same outer range: the added n = m+1 term dies.
  have hext : ferm m a b c =
      ∑ n ∈ range (m + 1 + 1), ∑ j ∈ range (2 * n + c + 1),
        T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + a * (n : ℤ) + b * (j : ℤ)) *
          ((gauss m n).toLaurent * (gauss (2 * n + c) j).toLaurent) := by
    rw [ferm, sum_range_succ (n := m + 1)]
    have hzero : ∑ j ∈ range (2 * (m + 1) + c + 1),
        T (((m + 1 : ℕ) : ℤ) ^ 2 - ((m + 1 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
            a * ((m + 1 : ℕ) : ℤ) + b * (j : ℤ)) *
          ((gauss m (m + 1)).toLaurent * (gauss (2 * (m + 1) + c) j).toLaurent) = 0 := by
      simp [gauss_eq_zero_of_lt (Nat.lt_succ_self m)]
    rw [hzero, add_zero]
  rw [hext, ferm]
  -- Combine into a single double sum of differences.
  rw [← sum_sub_distrib]
  have hcombine : ∀ n ∈ range (m + 1 + 1),
      ((∑ j ∈ range (2 * n + c + 1),
        T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + a * (n : ℤ) + b * (j : ℤ)) *
          ((gauss (m + 1) n).toLaurent * (gauss (2 * n + c) j).toLaurent)) -
       (∑ j ∈ range (2 * n + c + 1),
        T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + a * (n : ℤ) + b * (j : ℤ)) *
          ((gauss m n).toLaurent * (gauss (2 * n + c) j).toLaurent))) =
      ∑ j ∈ range (2 * n + c + 1),
        T ((n : ℤ) ^ 2 - (n : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 + a * (n : ℤ) + b * (j : ℤ)) *
          ((gauss (m + 1) n - gauss m n).toLaurent * (gauss (2 * n + c) j).toLaurent) := by
    intro n _
    rw [← sum_sub_distrib]
    refine sum_congr rfl fun j _ => ?_
    rw [map_sub]
    ring
  rw [sum_congr rfl hcombine]
  -- Peel off the n = 0 term (it vanishes since [m+1,0] − [m,0] = 0).
  rw [sum_range_succ']
  have h0 : ∑ j ∈ range (2 * 0 + c + 1),
      T (((0 : ℕ) : ℤ) ^ 2 - ((0 : ℕ) : ℤ) * (j : ℤ) + (j : ℤ) ^ 2 +
          a * ((0 : ℕ) : ℤ) + b * (j : ℤ)) *
        ((gauss (m + 1) 0 - gauss m 0).toLaurent * (gauss (2 * 0 + c) j).toLaurent) = 0 := by
    simp
  rw [h0, add_zero]
  -- Right-hand side: distribute the prefactor through the double sum.
  rw [ferm, mul_sum]
  -- Match the two double sums term by term.
  refine sum_congr rfl fun n hn => ?_
  have hnm : n ≤ m := Nat.lt_succ_iff.mp (mem_range.mp hn)
  rw [pascal_diff hnm, mul_sum]
  have hrange : 2 * (n + 1) + c + 1 = 2 * n + (c + 2) + 1 := by omega
  rw [hrange]
  exact sum_congr rfl fun j _ => ladder_term hnm j a b c
