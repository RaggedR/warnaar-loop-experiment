# Prove — Seed 6 Layer 2 (Round 2): CW Propagation from Seed Profiles to All Profiles

Mission: prove that CW functional equations propagate positivity from Conjecture-2-covered
("seed") profiles to all profiles. Reconstruct Warnaar's d=5 argument, extend to d=8.

## 1. Reconstruction of the d=5 (modulus 8) propagation argument

Sources: warnaar_A2_andrews_gordon chunks 073, 074, 082, 083; corteel_dousse_uncu chunks 024, 031, 032, 034.

Notation: G_c(z,q) = (zq;q)_inf * F_c(z,q)  (Warnaar's gk_c). CW system in G-form:

    G_c(z) = sum_{empty != J subset I_c} (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(z q^{|J|}).

Alternating signs for |I_c| >= 2. CDU20's key move (reconstructed from their proof of
Theorem th:sum_side): SUBSTITUTE the CW equation of a singleton-term profile back into the
equation of c; the (1 - zq)-type negative prefactors partially cancel, leaving
ALL-POSITIVE functional equations (their eqs 3.17-3.19 = qdiff401bis, qdiff302bis, qdiff320bis):

    G_(4,0,1)(z) = G_(3,1,1)(zq) + zq G_(4,1,0)(zq^2)
    G_(3,0,2)(z) = G_(2,2,1)(zq) + zq G_(3,1,1)(zq^2) + zq^2 G_(4,1,0)(zq^3)
    G_(3,2,0)(z) = G_(3,1,1)(zq) + zq G_(2,2,1)(zq^2) + zq^2 G_(3,1,1)(zq^3) + zq^3 G_(4,1,0)(zq^4)

**Crucial honest point.** Warnaar's Prop 2 proof does NOT propagate positivity through the
raw alternating-sign CW system. Two distinct mechanisms are at play:
  (a) UNIQUENESS: the system + initial conditions determine the non-seed G's from the seed
      G's; substituting the explicit (guessed) positive formulas verifies them.
  (b) The positive-form equations above transmit *bivariate* coefficient positivity of
      G_c(z,q) automatically — but Warnaar still needed the explicit formula for the
      hard profile (3,1,1) (and (2,2,1), (4,1,0)) via holonomic uncoupling; those three
      formed the "core" that could not be positively reached.

## 2. NEW: the R-relation recursion (general-d propagation engine)

Define: profile c admits an **R-relation** if

    G_c(z) = G_{head(c)}(zq) + sum_{i=1}^{L} z q^i G_{b_i(c)}(z q^{i+1})        (R_c)

a finite, manifestly-positive-coefficient functional equation.

**Substitution Lemma.** Let |I_c| = 2, I_c = {j1, j2}. CW gives
G_c(z) = G_{c({j1})}(zq) + G_{c({j2})}(zq) - (1-zq) G_{c({j1,j2})}(zq^2).
If R_{c({j2})} holds with head(c({j2})) = c({j1,j2}) (up to rotation), then substituting
w = zq into R_{c({j2})} cancels the negative term:
    G_c(z) = G_{c({j1})}(zq) + zq G_{c({j1,j2})}(zq^2) + sum_i zq^{i+1} G_{b_i(c({j2}))}(zq^{i+2}).
So R_c holds with head(c) = c({j1}), tail = [c({j1,j2})] ++ tail(c({j2})).
Proof: pure algebra; the +G_{c({j1,j2})}(zq^2) from the substituted head meets
-(1-zq) G_{c({j1,j2})}(zq^2), leaving +zq G_{c({j1,j2})}(zq^2). QED.

**Two-family construction (r = 3, ALL d).** Work with compositions; G is rotation-invariant.

Family A: c = (a,0,b), a,b >= 1. I_c = {0,2}.
  c({0}) = (a-1,1,b), c({2}) = (a+1,0,b-1), c({0,2}) = (a,1,b-1).
  Choose j2 = 2: the chain (a,0,b) -> (a+1,0,b-1) -> ... -> (a+b,0,0) stays in Family A
  and terminates at the |I|=1 base case G_(a+b,0,0)(z) = G_(a+b-1,1,0)(zq).
  Head condition: head((a+1,0,b-1)) = (a,1,b-1) = c({0,2}). Holds by induction.
  Result:  head((a,0,b)) = (a-1,1,b);  tail = [(a,1,b-1), (a+1,1,b-2), ..., (a+b-1,1,0)].

Family B: c = (a,b,0), a,b >= 1. I_c = {0,1}.
  c({0}) = (a-1,b+1,0) ~rot~ (b+1,0,a-1) in Family A;  c({1}) = (a,b-1,1);
  c({0,1}) = (a-1,b,1) ~rot~ (b,1,a-1) = head((b+1,0,a-1)). Head condition HOLDS ALWAYS.
  Result:  head((a,b,0)) = (a,b-1,1);
           tail = [(a-1,b,1)] ++ tail((b+1,0,a-1)) = [(a-1,b,1),(b+1,1,a-2),...,(a+b-1,1,0)].
  Edge a = 1: c({0}) = (0,b+1,0), |I|=1 base, head = (0,b,1) = c({0,1}) exactly. Holds.

Sanity check against CDU d=5: Family A (3,0,2): head (2,1,2)~(2,2,1), tail [(3,1,1),(4,1,0)] —
matches CDU eq. qdiff302bis EXACTLY. Family B (3,2,0): head (3,1,1),
tail [(2,2,1),(3,1,1),(4,1,0)] — matches qdiff320bis EXACTLY. (4,1,0): head (4,0,1),
tail [(3,1,1),(2,2,1),(3,1,1),(4,1,0)] — a positive relation CDU did not state but which
follows from the same lemma (self-reference in tails is fine: the system is well-founded
in the z-shift / triangular in n).

**Consequence (Propagation Theorem, G-level, all d, r=3).** Every profile containing a zero
part admits an explicit R-relation whose head chain terminates and whose tail entries are
profiles of the form (x,1,y) up to rotation. Hence: if G_c(z,q) has nonneg coefficients
for all ALL-POSITIVE profiles (c_0,c_1,c_2 >= 1), then G_c >= 0 for all profiles, with
explicit positive expressions. The "hard core" = all-positive profiles.

At d=5 the core is {(3,1,1),(2,2,1)} — exactly the two profiles Warnaar/CDU had to treat by
computer algebra. This explains the d=5 proof structure. Nothing d=5-specific so far;
the d=5-specific part of Warnaar's argument was only the EXPLICIT positive formulas for the core.

## 3. Q_n-level propagation (where it gets subtle)

Extract [z^n] from R_c and multiply by (q;q)_n  (d not divisible by 3):

    Q_n^c = q^n Q_n^{head(c)} + (1 - q^n) * sum_{i>=1} q^{(i+1)n - 1} Q_{n-1}^{b_i}.

The (1-q^n) is NOT manifestly positive (this is where naive positivity inheritance FAILS —
same reason Warnaar's (4,0,1) formula carries a z-dependent numerator (1 + zq^{n1+n2+n4+1})).

Sufficient extra ingredient — **cross-profile injection inequality**:

    (INJ_c):   Q_n^{head(c)}  >=  sum_{i>=1} q^{(i+1)n - 1} Q_{n-1}^{b_i}     (coefficientwise)

If (INJ_c) holds then Q_n^c = q^n [Q_n^{head} - sum_i q^{(i+1)n-1} Q_{n-1}^{b_i}] +
sum_i q^{(i+1)n-1} Q_{n-1}^{b_i} >= 0. This is the profile-changing analogue of the proved
injection lemma g_m >= q g_{m-1}. TO TEST computationally at d=5, d=8.

## 4. Plan

1. [code] Implement CW system, R-relation derivation (general d), verify vs CDU d=5.
2. [code] d=8: derive R-relations for all 8 zero-containing orbits; verify numerically at
   high precision; compute reachability graph; confirm core = 7 all-positive orbits.
3. [code] Test (INJ_c) at d=5, d=8 for all derived relations, n <= 5.
4. [code] Bounded-depth substitution search for positive relations for |I_c| = 3 profiles
   (can the core shrink?). Expect: no, but the failure mode is informative (the triple-J
   self-term (1-zq)(1-zq^2) G_c(zq^3)).
5. Write up the Propagation Theorem as a clean proof.

## Computational Evidence

Scripts: `scripts/seed6_R2L2_rrelations.py` (main engine, PREC=520, NMAX=5),
`scripts/seed6_R2L2_inj_variants.py` (variant enumeration), `scripts/seed6_R2L2_inj_scan.py`
(d=4,6,7,10,11 scan, PREC=420, NMAX=4), `scripts/seed6_R2L2_d2_solution.py`.
Outputs saved as `scripts/seed6_R2L2_*.out`.

### (a) R-relations verified exactly (d=5 and d=8)

All verified as exact identities g_c(n) = q^n g_head(n) + sum_i q^{(i+1)n-1} g_{b_i}(n-1)
against the raw alternating-sign CW fixed-point solution, n <= 5, PREC 520.

d=5: reproduces CDU eqs 3.17-3.19 EXACTLY (see sanity check in section 2).

d=8 (modulus 11, first unproved case), all 8 zero-containing orbits:

    R_(8,0,0): head (7,1,0), tail []
    R_(7,0,1): head (6,1,1), tail [(7,1,0)]
    R_(6,0,2): head (5,1,2), tail [(6,1,1),(7,1,0)]
    R_(5,0,3): head (4,1,3), tail [(5,1,2),(6,1,1),(7,1,0)]
    R_(4,4,0): head (4,3,1), tail [(4,1,3),(5,1,2),(6,1,1),(7,1,0)]
    R_(5,3,0): head (5,2,1), tail [(4,3,1),(4,1,3),(5,1,2),(6,1,1),(7,1,0)]
    R_(6,2,0): head (6,1,1), tail [(5,2,1),(4,3,1),(4,1,3),(5,1,2),(6,1,1),(7,1,0)]
    R_(7,1,0): head (7,0,1), tail [(6,1,1),(5,2,1),(4,3,1),(4,1,3),(5,1,2),(6,1,1),(7,1,0)]

ALL VERIFIED. Core = 7 all-positive orbits {(6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2),(3,3,2)}.
Q_n = (q;q)_n g_c(n) polynomial + nonneg for all 15 orbits, n <= 5 (consistency).

Note: the script's "MISMATCH lemma vs closed form at (1,0,7)" is NOT an error -- profiles
(1,0,y) admit a SECOND valid R-relation because the head condition holds up to rotation
for both j2 choices. R-relations are non-unique; both variants verify numerically.

### (b) INJ: naive termwise inheritance genuinely fails, but a good variant always exists

Variant enumeration (both j2 choices at each step, dedupe up to rotation):

d=5: (5,0,0),(4,0,1),(3,0,2),(3,2,0): unique variant, INJ OK for n <= 5.
     (4,1,0): 2 variants. v0 (head (4,0,1), tail len 4): INJ FAILS at n=2 q^4 coef -1
     (also n=3 q^8, n=4 q^14 coef -2, n=5 q^21). v1 (head (3,2,0), tail [(3,1,1),(4,1,0)]):
     INJ OK for all n <= 5.

d=8: identical pattern. 7 orbits unique-variant INJ OK; (7,1,0) v0 fails at the SAME
     exponents q^4, q^8, q^14, q^21 with coefs -1,-1,-2,-1; but v1 (head (6,2,0), tail
     [(6,1,1),(7,1,0)]) INJ OK for all n <= 5.

The failing variant is always the (d-1,1,0)-type profile with the long tail; the short-tail
variant repairs it. Failure exponents are d-independent -- suggests a uniform mechanism.

### (c) Scan across d (ell = gcd(d,3) handled)

    d=4  (ell=1):  4/4 zero-containing orbits have an INJ-satisfying variant
    d=6  (ell=3):  6/6
    d=7  (ell=1):  7/7
    d=10 (ell=1): 10/10
    d=11 (ell=1): 11/11

Clean sweep including d divisible by 3 (with (q^3;q^3)_n prefactor). Zero failures.

### (d) Bonus: d=2 solved exactly

At d=2 the R-relations close into a 2-cycle; solving gives g_(1,1,0)(n) = q^{n^2}/(q;q)_n, so

    Q_n^{(1,1,0)} = q^{n^2},   Q_n^{(2,0,0)} = q^{n(n+1)}.

Verified against raw CW for n <= 6 (seed6_R2L2_d2_solution.py, ALL OK). This proves the
d=2 case of the conjecture outright and gives Seed 1's Layer-2 target.

## Verify (hostile referee pass)

- Substitution Lemma: GREEN (pure algebra, checked numerically).
- Two-family closed forms + head-condition induction: GREEN (verified over ALL compositions
  at d=5,8; the only flagged case is the benign non-uniqueness at (1,0,y)).
- G-level Propagation Theorem: GREEN modulo well-foundedness: tails/heads shift
  z -> zq^{>=1}, so coefficient extraction at fixed (n, q-degree) only references strictly
  smaller data; self-references like (7,1,0) in its own tail carry z q^{i+1} prefactors,
  strictly decreasing n. Formalized in the .tex.
- Q-level: conditional on INJ (empirical, no proof) -- YELLOW.
- d=2 solution: GREEN.

## Handoff

### Best result (GREEN):
**Propagation Theorem (G-level, all d, r=3).** Every zero-containing profile admits an
explicit manifestly-positive functional equation (R-relation): G_c(z) = G_head(zq) +
sum_i z q^i G_{b_i}(zq^{i+1}), constructed by the Substitution Lemma + two-family closed
forms. Hence bivariate positivity of G_c for ALL profiles reduces to the ALL-POSITIVE core
(c_0,c_1,c_2 >= 1): 2 orbits at d=5 (exactly Warnaar's hard profiles), 7 at d=8.
Verified exactly at d=5,8 (n<=5) and d=4,6,7,10,11 (n<=4). Answer to the mission question:
CW propagation works at the G-level unconditionally, and the mechanism is NOT d=5-specific
-- only Warnaar's explicit core formulas were.

### Second result (GREEN): d=2 solved outright: Q_n^{(1,1,0)} = q^{n^2}, Q_n^{(2,0,0)} = q^{n(n+1)}.

### Q-level status (YELLOW):
Exact identity Q_n^c = q^n Q_n^{head} + (1-q^{ell n}) sum_i q^{(i+1)n-1} Q_{n-1}^{b_i}.
The (1-q^{ell n}) factor blocks naive inheritance. Sufficient condition INJ_c
(Q_n^head >= sum_i q^{(i+1)n-1} Q_{n-1}^{b_i} coefficientwise) has a satisfying variant
for EVERY zero-containing orbit at every tested d (4,5,6,7,8,10,11) -- but INJ is unproved.

### Gaps / recommendations for next layer:
1. PROVE INJ for the short-tail variants. The failure pattern of the bad variant is
   d-independent (q^4, q^8, q^14, q^21) -- find its combinatorial meaning.
2. The core remains: need positive formulas (or another mechanism) for all-positive
   profiles. Warnaar's Conjecture 2 covers the balanced one; KR Conjecture 5.1 may cover
   (x,1,y)-types. Core profiles (4,2,2),(3,3,2),(5,2,1),(4,3,1) at d=8 are the true frontier.
3. Combine with Seed 3/8's h_m machinery: the exact recursive identity above is a
   cross-profile recursion in n -- it may interlock with the g_m >= q g_{m-1} injection
   lemma to prove INJ.

