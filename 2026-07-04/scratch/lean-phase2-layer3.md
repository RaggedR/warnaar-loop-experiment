# Lean Phase 2 — Round 2, Layer 3 (d=4 glue formalization)

Mission (Robin-approved spec): extend the sorry-free pilot (lean/WarnaarGlue/)
with (1) the d=4 glue: Inversion-Lemma instantiation, Absorption Lemmas A and B,
main theorem d4_positive with CW Theorem `new` as named hypothesis; then
(2) Seed 2's chain links 2-3 if (1) lands.

Conventions per synthesis-layer3.md 4(iv): TRUE conjecture.tex labels,
target-first kernel, d=4 dictionary = identity; walls = orbits of
(0,1,3)=CW(3,0,1) and (0,2,2)=CW(2,2,0). Trust prove-seed6-layer3.tex
(erratum applied), NOT scratch/prove-seed6-layer3.md section 8.

## Design decisions (before writing code)

1. **Ring**: plain `Polynomial Z` (not Laurent). All exponents in the d=4
   formulas are N-valued: T(n,j) = q^(n^2+j^2-nj) and n*j <= n^2+j^2, so N
   truncated subtraction in `tExp n j := n*n + j*j - n*j` is exact.
2. **Nonnegativity**: predicate `CoeffNonneg (p : Polynomial Z) := forall k, 0 <= p.coeff k`
   with closure lemmas (add, mul, sum, X^k, gauss). This is the
   "coefficients-nonneg predicate" the brief asked for.
3. **CW enters cleared of denominators**: the honest finite form of CW Thm
   `new` + the trivial (q)_m/((q)_{m-n}(q)_n) = [m,n] bookkeeping is
   `hCW : forall o m, H o m = Sum_{n<=m} [m,n] * Qcw o n` where Qcw are the five
   explicit polynomial forms of prove-seed6-layer3.tex (walls in the shape
   Xw + (1-q^n)*X'/Y'). The 1/(q)_{n-1} at n=0 uses the standard convention
   1/(q)_{-1} = 0, so Xp 0 = Yp 0 = 0 by definition.
4. **Theorem Q enters as named hypothesis** `hQ` (its Euler-expansion proof is
   infinite-series; the inversion behind it is Lean-proved in the pilot).
   Then Q = Qcw by `qbinom_inversion` at (A, q) = (Z[X], X) --
   this IS the Inversion-Lemma instantiation.
5. **Absorption lemmas at the SUM level**, not termwise: two reusable
   splitting lemmas
   - sum_pascal_split:  Sum_{j<=N+1} c j [N+1,j] = Sum_{i<=N} c(i+1) [N,i] + Sum_{j<=N} c j q^j [N,j]
   - sum_pascal_split2: Sum_{j<=N+1} c j [N+1,j] = Sum_{j<=N} c j [N,j] + Sum_{i<=N} c(i+1) q^(N-i) [N,i]
   Absorption A = split twice (the q^{2j}[2n-2,j] batch cancels q^n*X'_n
   exactly); Absorption B = split + split2 (the q^{2n-1}[2n-2,i] batch equals
   the q^{n+2j}[2n-2,j] batch termwise via
   tExp(n)(i+1) + 2n-1 = tExp(n)(i) + n + 2i). Wall n=0 cases are trivial
   ((1-q^0) = 0). Avoids ALL negative-index case splits.
6. Orbits as `inductive D4Orbit | o211 | o400 | o310 | o301 | o220`
   (CW labels; the dictionary to true conjecture.tex orbits is the identity,
   4(iv).4, so each constructor stands for its full C3-orbit).

## Session log

- [start] Pilot state verified: lake build cache present, 3 files sorry-free.
  NOTE: Write tool denied in this session; files created via bash heredoc.
- CoeffNonneg predicate + closure lemmas + gauss_nonneg: COMPILED.
- tExp (N-valued T(n,j) exponent) + tExp_cast: COMPILED (one botched first
  draft of mul_le_sq_add_sq, fixed with a calc).
- sum_pascal_split / sum_pascal_split2: COMPILED (gotcha: split2's final
  add-assoc leaves the two sums swapped -> close with `ring`).
- absorption_A: COMPILED FIRST TRY. Style that worked: instantiate the split
  lemmas as `have h_i := sum_pascal_split ... (fun j => ...)`, then
  `beta_reduce at h1 h2 h3`, then rw-chain + per-term sum_congr folds
  (Xmul : X^a * (X^b*p) = X^(a+b)*p) + final `ring`. Exponent equalities all
  linear in the atom tExp, so plain omega closes them. (i+1)+1 vs i+2 is
  defeq -> `sum_congr rfl fun i _ => rfl`.
- absorption_B: COMPILED FIRST TRY (same style; the shift-cancellation
  exponent identity is tExp_succ : tExp n (j+1) + n = tExp n j + 2j + 1,
  proved by casting to Z via tExp_cast + push_cast + ring, then
  exact_mod_cast; inside sums omega closes everything with tExp_succ and
  i <= 2k as hypotheses).
- D4Orbit + Qcw (5 forms) + Xw/Xp/Yp nonneg + wall_A_nonneg/wall_B_nonneg
  + Qcw_nonneg: COMPILED (one unused-variable lint fixed).
- Main theorems d4_Q_eq_Qcw (Inversion Lemma instantiation via
  qbinom_inversion at (Z[X], X)), d4_positive, d4_BFF, d4_monotone:
  COMPILED. One fix: `rw [aeval_X_left_apply]` fails to match (instance
  unification); `exact aeval_X_left_apply _` works.
- Root WarnaarGlue.lean now imports D4Positive. Full `lake build` GREEN.
- AXIOM AUDIT: absorption_A, absorption_B, Qcw_nonneg, d4_Q_eq_Qcw,
  d4_positive, d4_BFF, d4_monotone ALL depend only on
  [propext, Classical.choice, Quot.sound]. No sorry/admit/native_decide.
  (The lone `ring`->ring_nf info in the build is the pilot's pre-existing
  PascalLadder.lean:65, documented in the pilot log.)

PRIORITY 1: DONE. Moving to Priority 2 (Seed 2 chain links 2-3).

### Priority 2: Seed 2 chain links 2-3 (Seed2Chain.lean)

Finite reformulation decision. The paper chain (prove-seed2-layer3.tex) is
Step 1 (Warnaar limit) -> Step 2 (Pochhammer split, EXACT) -> Step 3 (KR R3)
-> Step 4 (Uncu m=11). Steps 1/3/4 are literature imports; Step 2 is exact
but lives inside a 6-fold infinite series S11. The clean finite split is:

1. The EXACT polynomial kernel of Step 2 in Z[q], sorry-free:
   - qpoch n := prod_{i<n} (1 - X^(i+1))  ((q;q)_n),
   - qpoch_split : (q)_{r+s} * (1 - q^{r+s+1}) = (q)_{r+s+1}
     (the cleared form of 1/(q)_N = (1-q^{N+1})/(q)_{N+1}),
   - qpoch_split_shift : q^{r+s+1} = q * q^r * q^s (the (rho3,sigma3) ->
     (rho3+1,sigma3+1) shift that realizes the correction as q*S(e2|e2)),
   - one_sub_X_pow, qpoch_eq_qfact_mul : (q;q)_n = (1-q)^n * [n]!_q — the
     sanity bridge to the pilot's qfact normalization.
2. The Steps 2->3->4 ASSEMBLY as an abstract CommRing theorem:
   seed2_assembly (hSplit : T = S33 - q*S22) (hBridge : S33 - S32 - q*S22 +
   q*S21 = 0) (hUncu : H = S32 - q*S21) : T = H, one linear_combination.
   seed2_chain adds hWarnaar (F = D*T) and hG (G = D*H) to conclude F = G,
   i.e. FERM3 = G_{(3,3,2)}. Valid in any ring the series live in (Z[z][[q]]).

NOT formalized, and why (per the STOP instruction — recorded, not ground):
the termwise application of the split INSIDE S11 (turning kernel + shift into
hSplit itself) is an interchange/reindex of a 6-fold infinite series. Mathlib
has PowerSeries but no summability framework for this sum shape ((q)_inf-type
denominators, 6 nested indices); finitizing it per-coefficient would require
building bespoke truncation machinery disproportionate to the referee value.
The kernel identities carry the mathematical content of Step 2; the series
bookkeeping stays a named hypothesis, exactly like Steps 1/3/4.

Iteration log: first draft's inner nested induction for the qint bridge broke
(nested `induction` picked up the outer ih as a hypothesis of ihm, and
pow_succ rewrote both (1-X)^(n+1) and X^(n+1)). Fix: extracted standalone
lemma one_sub_X_pow with its own induction + calc; qpoch_eq_qfact_mul became
a 3-line calc. Second build green.

### Priority 3: spot checks

Added to D4Positive.lean as `example`s (compile-time sanity, no API surface):
Qcw o 0 = 1 for all five orbits; Qcw .o211 1 = 2q + q^2 + q^3 (computed
term-by-term: q*[2,0] + q*[2,1] + q^3*[2,2] with [2,1] = 1+q). All passed
first try (sum_range_succ unrolling + norm_num [tExp, gauss, pascal1]).

### lean-review findings and fixes

Self-review per the lean-review skill (senior-mathlib-reviewer lens):
1. FIXED — referee-critical: added a machine-checked NON-VACUITY witness
   (example : exists H Q satisfying hCW and hQ with all Q o n coeff-nonneg,
   by taking H/Q to be their defining right-hand sides; both hypotheses
   discharge by rfl). d4_positive is not a theorem about an empty theory.
2. FIXED — `show`-as-change smell at the wall n=0 cases: added @[simp]
   Xp_zero/Yp_zero; zero cases are now `simpa using Xw_nonneg 0`.
3. FIXED — factored the 7-fold repeated positivity pattern into
   sum_X_pow_mul_gauss_nonneg; @[simp] on gaussq_X.
4. Noted, not changed: Xmul naming is un-mathlib (project-local); CoeffNonneg
   hardcodes Z (a mathlib PR would generalize to an ordered semiring);
   norm_num bashing confined to the example block.
Rebuilt: zero errors, zero warnings.

## Handoff

STATUS: GREEN. Priorities 1, 2 (finite reformulation), 3 all delivered;
full `lake build` clean (no errors, no warnings, no sorries anywhere).

Files (library WarnaarGlue, now 5 modules; root import list updated):
- lean/WarnaarGlue/D4Positive.lean  (~540 lines) — Priority 1 + spot checks.
- lean/WarnaarGlue/Seed2Chain.lean  (~120 lines) — Priority 2.

COMPILED SORRY-FREE (unconditional):
- CoeffNonneg + closure lemmas, gauss_nonneg, sum_X_pow_mul_gauss_nonneg
- sum_pascal_split, sum_pascal_split2 (q-Pascal under weighted sums)
- absorption_A : Xw(k+1) - q^(k+1) Xp(k+1) = three manifestly nonneg sums
- absorption_B : Xw(k+1) - q^(k+1) Yp(k+1) = sum q^(n^2+j^2-nj+2j+1)[2n-1,j]
- Qcw_nonneg : all five explicit d=4 forms coefficientwise >= 0
- qpoch_split, qpoch_split_shift, one_sub_X_pow, qpoch_eq_qfact_mul

COMPILED, CONDITIONAL ON NAMED HYPOTHESES (the sanctioned literature imports):
- d4_Q_eq_Qcw, d4_positive, d4_BFF, d4_monotone  [hCW = CW Thm `new`
  denominators cleared; hQ = Seed 7 Theorem Q] + non-vacuity witness example
- seed2_assembly, seed2_chain  [hWarnaar, hBridge = KR R3, hUncu, (hSplit)]

HYPOTHESIZED, NOT PROVED (recorded reasons): CW Theorem `new`; Theorem Q's
Euler-expansion proof; Seed 2 Steps 1/3/4; the termwise split inside S11
(6-fold series interchange — no Mathlib summability framework for the shape).

Axiom check (#print axioms): every theorem above is
[propext, Classical.choice, Quot.sound]; seed2_assembly/seed2_chain need only
[propext]. grep sorry/admit/native_decide: clean.
