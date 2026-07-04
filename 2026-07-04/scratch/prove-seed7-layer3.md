# Scratch: Seed 7, Layer 3, Round 2 — Rigorous foundation of the BFF bottleneck

Mission: (a) PROVE the Q-transform; (b) prove BFF => Q_n = a_n via Gauss inversion;
(c) make the equivalence chain around Monotonicity / f_0^(m) / BFF-first-level rigorous;
(d) characterize when a bounded family admits a nonneg q-binomial expansion.

## Audit of inputs (mission item: did Seed 3 PROVE the Q-transform?)

- Seed 3 L2 scratch, line 147: "Bonus exact identity (proved by telescoping in the scratch
  algebra)" — **no telescoping is exhibited anywhere in the file**. Verified by hand only for
  d=2 (Q_1, Q_2 at (1,1,0)).
- Synthesis-layer2 (Downgrades): "the telescoping is not exhibited in the scratch file ...
  kept GREEN with this note." So the status was GREEN-by-courtesy.
- verify-layer2-disputes.md: CONFIRMED numerically, exactly, d=2,4,5, all profiles, n<=5,
  two routes. Computational, not a proof.

**Conclusion: the Q-transform was never proved. This file supplies the first proof.**

(Notational note: verifier report says "d=5 (ell=2)" — impossible, ell = gcd(d,3) in {1,3};
typo for ell=1. All of the below is for ell=1, i.e. d not divisible by 3 — exactly the
regime of the conjecture.)

## Standing setup

Fix r=3 and a profile c with d = c_0+c_1+c_2, d not == 0 mod 3. In Z[[q]]:
- g_m = GF of cylindric partitions of profile c with max part EXACTLY m (g_0 = 1).
- F_{c,m} = sum_{j=0}^m g_j (max part AT MOST m);  F_c(z,q) = sum_{m>=0} g_m z^m.
- H_m = (q;q)_m F_{c,m}  (H_0 = 1);   h_m = (q;q)_m g_m = H_m - (1-q^m) H_{m-1}.
- Q_n = (q;q)_n [z^n] ( (zq;q)_inf F_c(z,q) ).
- D-tower: D_0^m = h_m, D_{k+1}^m = D_k^m - q^{k+1} D_k^{m-1}; brackets
  f_{-1}^{(m)} = g_m, f_k^{(m)} = (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)}.
  Lemma T1 (Seed 8, GREEN pure algebra): D_{k+1}^m = (q;q)_{m-k-1} f_k^{(m)}.

Everything below is power-series algebra in Z[[q]] — polynomiality of H_m (Seed 3's
theorem) is NOT needed anywhere except the "exactness" remark.

## RAG check before computing

Queries run: "telescoping partial sum Euler series (-1)^k q^binom(k,2)/(q;q)_k";
"Gauss q-binomial inversion pair orthogonality". Hits: Euler's expansion
(z;q)_inf = sum (-1)^k q^binom(k,2) z^k/(q;q)_k (imamura chunk_067, standard);
Warnaar's basic binomial relation 1/(zq)_n = sum_j z^j q^{j^2} [n,j] 1/(zq)_j
(kanade_russell chunk_022) — that is literally a nonneg q-binomial expansion of the
family Phi_n = 1/(zq)_n, the unbounded-AG prototype of BFF. No source states our exact
Q-transform; the ingredients (Lemma E below, Gauss inversion) are classical
(Gasper–Rahman / Andrews). Fine to prove from scratch and cite as classical.

## Proofs (worked out, to be verified numerically then TeX'd)

### Lemma E (truncated Euler telescoping)
For K >= 0:  sum_{k=0}^K (-1)^k q^{binom(k,2)}/(q;q)_k = (-1)^K q^{binom(K+1,2)}/(q;q)_K.
Induction: K=0 trivial. Step: add (-1)^{K+1} q^{binom(K+1,2)}/(q;q)_{K+1} to RHS(K):
(-1)^K q^{binom(K+1,2)} [1/(q;q)_K - 1/(q;q)_{K+1}]; inside bracket
(1-q^{K+1}) - 1 = -q^{K+1}, giving
(-1)^{K+1} q^{binom(K+1,2)+K+1}/(q;q)_{K+1} = (-1)^{K+1} q^{binom(K+2,2)}/(q;q)_{K+1}. QED
(Sanity: partial sums of Euler's series for (x;q)_inf at x=1.)

### Theorem Q (the Q-transform)
Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_m.

Proof. Euler: (zq;q)_inf = sum_k (-1)^k q^{binom(k+1,2)} z^k/(q;q)_k. Convolving with
F_c(z,q) = sum g_m z^m:
   (*)  Q_n = (q;q)_n sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} g_m/(q;q)_{n-m}.
Now expand the target RHS: H_m = (q;q)_m sum_{j<=m} g_j and [n,m](q;q)_m = (q;q)_n/(q;q)_{n-m}:
   RHS = (q;q)_n sum_{j=0}^n g_j sum_{m=j}^n (-1)^{n-m} q^{binom(n-m,2)}/(q;q)_{n-m}
       = (q;q)_n sum_j g_j sum_{k=0}^{n-j} (-1)^k q^{binom(k,2)}/(q;q)_k        [k=n-m]
       = (q;q)_n sum_j g_j (-1)^{n-j} q^{binom(n-j+1,2)}/(q;q)_{n-j}            [Lemma E]
       = Q_n by (*). QED
All sums finite; valid in Z[[q]]. No polynomiality needed.

Remark (3|d): the same convolution gives (*) with (q^3;q^3)_n in front; since Euler's
denominators are (q;q)_{n-m}, no single-base q^3-binomial transform results; the ell=3
analogue of Theorem Q is genuinely different (not pursued; outside the conjecture).

### Theorem G (Gauss inversion; classical)
For sequences a, b in Z[[q]]: b_n = sum_{j<=n} [n,j] a_j (all n)  <=>
a_n = sum_{m<=n} (-1)^{n-m} q^{binom(n-m,2)} [n,m] b_m (all n).
Key orthogonality: sum_{m=k}^n (-1)^{n-m} q^{binom(n-m,2)} [n,m][m,k] = delta_{nk}.
Proof: [n,m][m,k] = [n,k][n-k,m-k]; put i = n-m, J = n-k:
sum = [n,k] sum_{i=0}^{J} (-1)^i q^{binom(i,2)} [J,i] = [n,k] (x;q)_J |_{x=1}
    = [n,k] delta_{J,0}
by Gauss's finite binomial theorem sum_i (-1)^i q^{binom(i,2)} [J,i] x^i = (x;q)_J.
Both directions by substitute-and-swap; uniqueness since the transform is unitriangular. QED

### Corollary I (inverse Q-transform — UNCONDITIONAL)
H_m = sum_{n=0}^m [m,n]_q Q_n  for all m.  (Thm Q + Thm G.)
Sanity: q=1: H_m(1) = sum binom(m,n) (K-1)^n = K^m with K = (d+1)(d+2)/6 — matches
Seed 2's H_m(1) = K^m and Welsh's Q_n(1) = (K-1)^n. Consistent.
GF form (kernel sum_{m>=j}[m,j] z^m = z^j/(z;q)_{j+1}):
   sum_m H_m z^m = sum_n Q_n z^n/(z;q)_{n+1}.

### Corollary B (BFF => conjecture; uniqueness; the bottleneck is EXACT)
(i) If H_m = sum_j [m,j] a_j with a_j independent of m, then a_j = Q_j (uniqueness in Thm G).
(ii) Hence {H_m} admits a coefficientwise-NONNEG q-binomial expansion  <=>  Q_n >= 0 all n
     <=> Warnaar's conjecture at profile c.
So "BFF first level" (existence of a nonneg expansion, forgetting multisum structure) is
EQUIVALENT to the conjecture — not merely sufficient. Mission item (d) answered: a bounded
family admits a nonneg q-binomial expansion iff its (unique) inverse transform is nonneg;
for the H-family the inverse transform IS (Q_n).

### Theorem D (Q-expansion of the whole tower — unconditional identities)
For 0 <= k <= m:      D_k^m = sum_j q^{(k+1)(m-j)} [m-k, j-k]_q Q_j.
Proof by induction on k from Corollary I:
 k=0: h_m = H_m - (1-q^m)H_{m-1} = sum_j Q_j([m,j] - (1-q^m)[m-1,j]);
      [m,j]-[m-1,j]+q^m[m-1,j] = q^{m-j}[m-1,j-1] + q^m[m-1,j]
      = q^{m-j}([m-1,j-1]+q^j[m-1,j]) = q^{m-j}[m,j]   (both q-Pascals). So
      h_m = sum_j q^{m-j} [m,j] Q_j.
 step: D_{k+1}^m = sum_j Q_j q^{(k+1)(m-j)}([m-k,j-k] - [m-k-1,j-k])
      = sum_j Q_j q^{(k+1)(m-j)} q^{(m-k)-(j-k)} [m-k-1,j-k-1]
      = sum_j Q_j q^{(k+2)(m-j)} [m-k-1,j-k-1]. QED
Boundary k=m: D_m^m = Q_m — an independent re-derivation of Round 1's Q_n = D_n^n.
Also (first difference of Cor I, same q-Pascal):
      Delta_m := H_m - H_{m-1} = sum_j q^{m-j} [m-1,j-1] Q_j.
And the Delta/D_1 link: D_1^m = Delta_m - q(1-q^{m-1}) Delta_{m-1}   [check numerically].

### Theorem M (MASTER <=> Conjecture, per profile, d not == 0 mod 3)
(a) If Q_i >= 0 for all i <= m then for all -1 <= k <= m-1 and 0 <= j <= m-k-1:
    (q;q)_j f_k^{(m)} >= 0.
    Proof: by Lemma T1 and invertibility of (q;q)_{m-k-1} in Z[[q]],
    (q;q)_j f_k^{(m)} = D_{k+1}^m / (q^{j+1};q)_{m-k-1-j}.
    D_{k+1}^m >= 0 by Theorem D (nonneg kernel applied to nonneg Q_i, i >= k+1);
    1/(q^{j+1};q)_{m-k-1-j} is a nonneg power series. Product of nonnegs. QED
    (k=-1 row included: (q;q)_j g_m = h_m/(q^{j+1};q)_{m-j} >= 0.)
(b) Conversely MASTER's cell (k,j) = (m-1,0) IS Q_m >= 0 (Corollary T2).
Hence: MASTER (positivity part) <=> {Q_n >= 0 for all n} — the two-parameter tower is
EQUIVALENT to the conjecture, level by level: {Q_i >= 0 : i <= M} <=> {all cells m <= M}.
This EXPLAINS Seed 8's "the tower induction does not close from positivity alone" (BA24):
of course not — the tower is the conjecture.
(c) Exactness remark: at j = m-k, (q;q)_{m-k} f_k^{(m)} = (1-q^{m-k}) D_{k+1}^m; if
    D_{k+1}^m is a nonzero nonneg POLYNOMIAL (polynomiality: Seed 3 GREEN for ell=1),
    its leading coefficient is > 0, so the product's leading coefficient is < 0.
    So exactness holds automatically wherever f_k^{(m)} != 0, GIVEN the conjecture.

### Corollary C (the corrected equivalence chain — mission item (c))
The brief's chain "Monotonicity ≡ f_0^(m) >= 0 ≡ BFF first level" is NOT correct as stated.
The true, now-proved DAG (per profile, d not == 0 mod 3):

  BFF-first-level (nonneg q-binomial expansion of H)
      <=> Conjecture (Q_n >= 0 all n)          [Cor B]
      <=> MASTER (all cells)                    [Thm M]
      ==> Monotonicity (H_m >= H_{m-1})         [Delta_m = sum q^{m-j}[m-1,j-1]Q_j >= 0]
      ==> h_m >= 0                              [Seed 3 reduction; or directly Thm D k=0]
      ==> f_0^{(m)} >= 0 and all single cells   [Thm M(a)]

  Monotonicity and f_0^{(m)} >= 0 are DISTINCT statements (synthesis (a) adjudication
  stands): D_1^m = Delta_m - q(1-q^{m-1})Delta_{m-1}, and (q;q)_{m-1} has mixed signs so
  positivity does not transfer through Lemma T1 in either direction. Both are
  nonneg-kernel projections of the Q-vector; neither is known to imply the conjecture
  (BA24: treating them as sufficient was the Layer-1 error).

Structural moral (mission (d), the characterization): EVERY bounded object on the board
(h_m, D_k^m, Delta_m, (q;q)_j f_k^{(m)}) is the image of the single vector (Q_j) under an
explicit componentwise-NONNEG unitriangular kernel; the conjecture says the source vector
itself is nonneg, and it is the unique maximal element of this poset of positivity
statements. Kernels:
   h:      K_{m,j} = q^{m-j} [m,j]
   Delta:  K_{m,j} = q^{m-j} [m-1,j-1]
   D_k:    K_{m,j} = q^{(k+1)(m-j)} [m-k,j-k]
   (q;q)_j f_k: D_{k+1}-kernel followed by the nonneg series 1/(q^{j+1};q)_{m-k-1-j}.

## Computational verification plan
Script scripts/seed7_R2L3_verify.sage, exact Z[q] via H-recursion
((1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}, EMD(c,c') =
3*max(0,a,b)-a-b, a=c'_1-c_1, b=c_0-c'_0), PLUS brute-force cylindric partition
enumeration for m<=3 to validate the pipeline end-to-end (not just internally).
Checks: Lemma E (K<=12), orthogonality (n<=8), Theorem Q, Corollary I, Theorem D
(k<=m<=6), Delta formula, D_1/Delta link, Thm M(a) sample cells, exactness, GF identity.
d=4 (15 profiles), d=5 (21 profiles), spot d=7.

## Log

(running)

### Run 1: scripts/seed7_R2L3_verify.sage (log scripts/seed7_R2L3_verify.log)
ALL exact ZZ[q], no truncation except the two series-division checks (prec 500/80):
- Lemma E: PASS K <= 12 (polynomial form, exact).
- Gauss orthogonality: PASS n <= 8, all k (exact).
- Theorem Q (definition route vs transform route): PASS d=4 (15 profiles, n<=6),
  d=5 (21 profiles, n<=5), d=7 (36 profiles, n<=4).
- Corollary I (H_m = sum [m,n] Q_n): PASS same ranges (exact ZZ[q]).
- Theorem D (D_k^m = sum_j q^{(k+1)(m-j)}[m-k,j-k] Q_j), all 0<=k<=m: PASS (exact).
- Delta formula + D1/Delta link: PASS (exact).
- Thm M(a) cells k=-1..2, all j (series to q^80): all nonneg. PASS.
- Exactness remark (leading coeff of (1-q^{m-k})D_{k+1}^m < 0 when D != 0): PASS.
- d=2 closed forms via the transform: Q_n = q^{n^2} at (1,1,0), q^{n(n+1)} at (2,0,0),
  n <= 6: PASS.

### Run 2: brute-force convention audit (/tmp/conv.sage)
Brute-force cylindric partitions (conjecture.tex interlacing: pairs (0->1 shift c_1),
(1->2 shift c_2), (2->0 shift c_0)), m <= 3, coefficients to q^10:
- All reversal-symmetric orbits match the H-recursion EXACTLY: d=4 (2,1,1),(4,0,0),(0,2,2);
  d=5 (3,1,1); d=2 both orbits. End-to-end validation of the EMD/H-recursion pipeline.
- Asymmetric orbits match after REVERSAL relabeling:
  brute(0,3,1) = Hrec on orbit {(0,1,3),(1,3,0),(3,0,1)};
  brute(0,2,3) = Hrec on orbit {(0,3,2),(2,0,3),(3,2,0)}.
**Finding (document for C2-adjacent bookkeeping): the project-standard EMD/H-recursion
labels profiles in the convention REVERSED relative to conjecture.tex's interlacing
definition.** This is a global bijection on profiles (orbit of c <-> orbit of reversed c),
so every per-profile theorem is unaffected; but anyone matching fermionic forms to
Warnaar's paper must apply the reversal map when translating profile labels. This may be
the root of the Seed 3 / Seed 4 orbit-label confusion in C2.

## Verify phase (hostile referee pass on my own proofs)
- Lemma E: GREEN (induction shown, base shown, verified K<=12).
- Theorem Q: GREEN. Each step: Euler expansion (classical, also verified numerically via
  route (1)); swap of finite double sum (finite, no issue); Lemma E. Boundary n=0: Q_0 =
  H_0 = 1 ok. Works in Z[[q]]; no polynomiality assumption.
- Theorem G: GREEN. Orthogonality from the finite q-binomial theorem at x=1; the
  subtlety [n,m][m,k]=[n,k][n-k,m-k] is the standard "trinomial" identity, verified
  numerically inside the orthogonality check. Uniqueness: unitriangular with 1's on the
  diagonal over Z[[q]] (a commutative ring), invertible. GREEN.
- Cor I / Cor B: immediate. GREEN.
- Thm D: induction verified twice (algebra + numerics d=4,5,7 exact). Boundary k=m
  reproduces Q_m = D_m^m independently of Round-1's proof. GREEN.
- Thm M: (a) uses Lemma T1 (Seed 8 GREEN pure algebra, re-verified numerically here via
  D-tower construction), invertibility of (q;q)_N in Z[[q]] (constant term 1: GREEN),
  nonnegativity of 1/(q^{j+1};q)_N (geometric-series product: GREEN), and Thm D. The only
  hypothesis is Q_i >= 0 for k+1 <= i <= m. (b) is Cor T2. GREEN as an equivalence of
  conjectures. (c) exactness: needs D a polynomial (Seed 3 polynomiality GREEN, ell=1)
  and D != 0; stated conditionally. GREEN as stated.
- Cor C: assembles the above; the two "==>" arrows to Monotonicity/h_m are one-line
  kernel positivity. GREEN.
No RED, no YELLOW steps remain in the foundation. The conditional inputs from other
seeds used: Lemma T1 + Cor T2 (Seed 8, pure algebra), polynomiality (Seed 3, only for
the exactness remark). Everything else is self-contained classical q-algebra.

## Handoff

**Status: GREEN.** Write-up: proofs/prove-seed7-layer3.tex (compiled, 5pp).
Script + log: scratch/scripts/seed7_R2L3_verify.{sage,log}.

PROVED (referee-passed, self-contained classical q-algebra; only external inputs are
Seed 8's Lemma T1/Cor T2 (pure algebra) and, for one remark, Seed 3's polynomiality):

1. **Theorem Q (Q-transform)** — first actual proof (Seed 3 had only stated it; verifier
   only confirmed numerically). Proof = Euler expansion + truncated-Euler telescoping
   (Lemma E). Valid in Z[[q]], all profiles, d not == 0 mod 3.
2. **Gauss inversion + Corollary I (unconditional)**: H_m = sum_n [m,n]_q Q_n; GF form
   sum H_m z^m = sum Q_n z^n/(z;q)_{n+1}. Reconciles H_m(1)=K^m with Q_n(1)=(K-1)^n.
3. **Corollary B**: BFF => Q_n = a_n >= 0 (mission (b)); and SHARPER: existence of a
   nonneg q-binomial expansion of (H_m) <=> Warnaar's conjecture at c (mission (d):
   the characterization is uniqueness — nonneg expansion exists iff inverse transform
   nonneg; for H, existence IS the conjecture).
4. **Theorem D (unconditional Q-expansions of the towers)**:
   D_k^m = sum_j q^{(k+1)(m-j)} [m-k,j-k]_q Q_j; h_m = sum q^{m-j}[m,j]Q_j;
   Delta_m = sum q^{m-j}[m-1,j-1]Q_j; D_1^m = Delta_m - q(1-q^{m-1})Delta_{m-1}.
   Independent re-derivation of Q_n = D_n^n.
5. **Theorem M: MASTER <=> Conjecture**, per profile, level by level
   ({Q_i>=0, i<=M} <=> all MASTER cells m<=M). Seed 8's MASTER (positivity part) is
   not a strengthening — it IS the conjecture. Explains why the tower induction cannot
   close from positivity alone. Exactness clause ("fails at j=m-k") is automatic
   wherever f_k^(m) != 0, given the conjecture + polynomiality (leading-coeff argument).
6. **Corollary C (corrected chain)**: the brief's "Monotonicity ≡ f_0^(m)>=0 ≡ BFF first
   level" is WRONG as stated. Truth: BFF-first-level <=> Conjecture <=> MASTER ==>
   {Monotonicity, h_m>=0, f_0^(m)>=0, D_k^m>=0} — all the weaker statements are
   nonneg-unitriangular-kernel images of (Q_n); the conjecture is the unique maximal
   element. Monotonicity and f_0>=0 remain mutually independent-looking projections.

STRATEGIC consequences for synthesis:
- Monotonicity (Mission 2) can no longer be the terminal target: proving it does NOT
  give the conjecture (now a theorem-level fact, not just BA24 caution), though its
  techniques may still transfer.
- The BFF route is now fully rigorous end-to-end: producing a nonneg expansion for the
  missing orbits ((0,2,2),(0,3,1) at d=4 in EMD labels) FINISHES d=4.
- MASTER verification (Seed 8's tables) is now literally verification of the conjecture
  in disguise; adversary seeds should target Q_n at large n directly.

NEW BOOKKEEPING FINDING (affects C2-adjacent label matching): brute-force enumeration
against conjecture.tex's interlacing definition shows the project-standard EMD/H-recursion
convention labels profiles REVERSED relative to conjecture.tex (brute (0,3,1) = Hrec orbit
of (0,1,3); brute (0,2,3) = Hrec orbit of (0,3,2); reversal-symmetric orbits unaffected).
Harmless per-profile; must be applied when matching against Warnaar/Uncu tables. Possibly
the root cause of the original Seed3/Seed4 C2 confusion. First end-to-end validation of
the H-recursion pipeline against actual cylindric partitions.

Open (not attempted here, correctly out of scope): producing the positive expansions
themselves (missing orbits), and any 3|d analogue of the transform (shown to require a
genuinely different identity — no single-base q^3 transform exists via Euler).
