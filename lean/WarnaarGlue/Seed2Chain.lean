/-
Seed 2, Layer 3 (Phase 2): chain links 2-3, finitely reformulated.

The paper chain (prove-seed2-layer3.tex) is:
  Step 1 (Warnaar finite form, LIMIT):   FERM3/(q)_inf = T(z,q)      [hypothesis]
  Step 2 (Pochhammer split, EXACT):      T = S(e3|e3) - q S(e2|e2)
  Step 3 (KR contiguous relation R3):    S(e3|e3) - q S(e2|e2) = S(e3|e2) - q S(e2|e1)
  Step 4 (Uncu m=11, LITERATURE):        H_{(3,3,2)} = S(e3|e2) - q S(e2|e1)  [hypothesis]

Finite reformulation implemented here:
1. The EXACT polynomial kernel of Step 2 — the cleared-denominator form of
   1/(q)_{r3+s3} = (1 - q^{r3+s3+1})/(q)_{r3+s3+1} together with the exponent
   shift q^{r3+s3+1} = q * q^{r3} * q^{s3} — as sorry-free identities in Z[q]
   (`qpoch_split`, `qpoch_split_shift`). No division, no limits.
2. The Step 2→3→4 ASSEMBLY as an abstract commutative-ring theorem
   (`seed2_assembly`): with T, S33, S32, S22, S21, H opaque ring elements and
   the three equations as named hypotheses, conclude T = H. This is the exact
   logical content of the paper's chain, valid in any ring the series live in
   (e.g. Z[z][[q]] or Z[[z,q]]).
3. `seed2_chain`: the full chain including Step 1's limit statement as a
   named hypothesis (hWarnaar : F = D * T with D = (q)_inf as an opaque
   element), concluding F = D * H, i.e. FERM3 = (q)_inf H_{(3,3,2)} = G_{(3,3,2)}.

NOT formalized (recorded in the log): the termwise application of the split
inside the 6-fold sum S11 (an interchange/reindex of an infinite series —
needs a power-series-with-support framework Mathlib lacks for this shape),
and Steps 1, 3, 4 themselves (limits / KR / Uncu: literature imports).
-/
import WarnaarGlue.GaussBinomial

open Polynomial Finset

namespace WarnaarGlue

/-! ### The exact Pochhammer-split kernel in ℤ[q] -/

/-- The q-Pochhammer `(q; q)_n = ∏_{i=1}^{n} (1 − q^i)` as a polynomial in `ℤ[q]`. -/
noncomputable def qpoch (n : ℕ) : Polynomial ℤ := ∏ i ∈ range n, (1 - X ^ (i + 1))

@[simp] lemma qpoch_zero : qpoch 0 = 1 := by simp [qpoch]

lemma qpoch_succ (n : ℕ) : qpoch (n + 1) = qpoch n * (1 - X ^ (n + 1)) := by
  rw [qpoch, prod_range_succ, qpoch]

/-- **Step 2 kernel (cleared of denominators).** The identity
`1/(q)_N = (1 − q^{N+1})/(q)_{N+1}`, multiplied through:
`(q)_N · (1 − q^{N+1}) = (q)_{N+1}`. Applied with `N = r₃ + s₃`. -/
theorem qpoch_split (r s : ℕ) :
    qpoch (r + s) * (1 - X ^ (r + s + 1)) = qpoch (r + s + 1) :=
  (qpoch_succ (r + s)).symm

/-- **Step 2 shift bookkeeping.** `q^{r₃+s₃+1} = q · q^{r₃} · q^{s₃}` — the
exponent split that realizes the correction term as the shift
`(ρ₃, σ₃) ↦ (ρ₃ + 1, σ₃ + 1)` inside `S₁₁`, i.e. as `q · S(e₂|e₂)`. -/
theorem qpoch_split_shift (r s : ℕ) :
    (X : Polynomial ℤ) ^ (r + s + 1) = X * X ^ r * X ^ s := by
  rw [pow_add, pow_add, pow_one]; ring

/-- `1 − q^{n+1} = (1 − q)·[n+1]_q` — links the Pochhammer factors to `qint`. -/
lemma one_sub_X_pow (n : ℕ) :
    (1 : Polynomial ℤ) - X ^ (n + 1) = (1 - X) * qint (n + 1) := by
  induction n with
  | zero => simp [qint]
  | succ m ih =>
    have h : qint (m + 1 + 1) = qint (m + 1) + X ^ (m + 1) * qint 1 := qint_add (m + 1) 1
    have h1 : qint 1 = 1 := by simp [qint]
    calc (1 : Polynomial ℤ) - X ^ (m + 1 + 1)
        = (1 - X ^ (m + 1)) + X ^ (m + 1) * (1 - X) := by ring
      _ = (1 - X) * qint (m + 1) + X ^ (m + 1) * (1 - X) := by rw [ih]
      _ = (1 - X) * (qint (m + 1) + X ^ (m + 1) * 1) := by ring
      _ = (1 - X) * (qint (m + 1) + X ^ (m + 1) * qint 1) := by rw [h1]
      _ = (1 - X) * qint (m + 1 + 1) := by rw [← h]

/-- `(q)_n` relates to the balanced `[n]!` by `(q;q)_n = (1−q)^n · [n]!_q`.
Sanity link between the Pochhammer normalization used by Seed 2 and the
`qfact` normalization used by the rest of the library. -/
lemma qpoch_eq_qfact_mul (n : ℕ) :
    qpoch n = (1 - X) ^ n * qfact n := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc qpoch (n + 1) = qpoch n * (1 - X ^ (n + 1)) := qpoch_succ n
      _ = (1 - X) ^ n * qfact n * ((1 - X) * qint (n + 1)) := by
          rw [ih, one_sub_X_pow]
      _ = (1 - X) ^ (n + 1) * qfact (n + 1) := by rw [qfact_succ, pow_succ]; ring

/-! ### The chain assembly (links 2–3), abstract over the carrier ring -/

/-- **Seed 2 assembly (chain links 2–3).** In any commutative ring (e.g. the
formal power series ring where the sums `S(a|b)` of prove-seed2-layer3.tex
converge coefficientwise):
* `hSplit`  — Step 2: `T = S₃₃ − q·S₂₂` (Pochhammer split inside `S₁₁`;
  its polynomial kernel is `qpoch_split`/`qpoch_split_shift` above),
* `hBridge` — Step 3: the Kanade–Russell contiguous relation `R₃` at
  `ρ = σ = 0`: `S₃₃ − S₃₂ − q·S₂₂ + q·S₂₁ = 0`,
* `hUncu`   — Step 4: Uncu's theorem (m = 11): `H = S₃₂ − q·S₂₁`.

Conclusion: `T = H`. -/
theorem seed2_assembly {R : Type*} [CommRing R]
    (q T S33 S32 S22 S21 H : R)
    (hSplit : T = S33 - q * S22)
    (hBridge : S33 - S32 - q * S22 + q * S21 = 0)
    (hUncu : H = S32 - q * S21) :
    T = H := by
  linear_combination hSplit + hBridge - hUncu

/-- **The full Seed 2 chain**, with Step 1 (Warnaar's finite-form limit
`FERM₃ = (q;q)_∞ · T`) also as a named hypothesis, `D` playing `(q;q)_∞` and
`G` playing `G_{(3,3,2)} = (q;q)_∞ · H_{(3,3,2)}`. Conclusion:
`FERM₃ = G_{(3,3,2)}` — the A₃ ↔ Kanade–Russell correspondence. -/
theorem seed2_chain {R : Type*} [CommRing R]
    (q F D T S33 S32 S22 S21 H G : R)
    (hWarnaar : F = D * T)
    (hSplit : T = S33 - q * S22)
    (hBridge : S33 - S32 - q * S22 + q * S21 = 0)
    (hUncu : H = S32 - q * S21)
    (hG : G = D * H) :
    F = G := by
  rw [hWarnaar, seed2_assembly q T S33 S32 S22 S21 H hSplit hBridge hUncu, hG]

end WarnaarGlue
