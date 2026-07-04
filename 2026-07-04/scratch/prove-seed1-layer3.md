# Prove Seed 1 Layer 3 — Generalize the d=2 q-Pascal proof to the U-tower

Seed 1, Layer 3, Round 2. Mission: attack the Monotonicity Conjecture
H_{c,m} >= H_{c,m-1} (standing notation: H_{c,m} = (q;q)_m F_{c,m}) by
generalizing the d=2 q-Pascal/absorption proof to the orbit tower
H_m = U(q^m) H_{m-1}.

Attack lines:
(a) d=4/d=5 analogues of Seed 4's identities (i),(ii),(iii): compute U-matrices,
    find q-Pascal-type recurrences among orbit components.
(b) matrix-level q-Pascal: decompose U(x) = P + x^a R with P, R positivity-preserving,
    or find a U-invariant positivity cone (the "surplus vector" C of Seed 4's d=2 proof).
(c) RAG: bounded Rogers-Ramanujan finitizations and their recurrence proofs.

## Notation audit (FIRST, per the warning)

Standing notation (synthesis-layer2.md):
- H_{c,m} = (q;q)_m F_{c,m}; recursion (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}.
- Standing EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1).
- Seed 3's weight: q^{m*EMD(c',c)} (SOURCE first).
- Seed 4's engine (seed4_R2L2_orbit_system.py) uses emd(a,b) with a = TARGET row:
  weight EMD(target, source). CONFLICT: example c=(2,0,0), c'=(1,1,0):
  EMD(c,c') = 1 but EMD(c',c) = 2. At d=2 the U-matrix happens to be symmetric,
  so both seeds' d=2 results agree; for d>=4 the orientation MATTERS.
- RESOLUTION PLAN: brute-force enumerate cylindric partitions (d=4, m<=3, truncated
  q-series) to get ground-truth F_{c,m}; decide the orientation before anything else.

## Session log

(written as I go)
### Result 1 (orientation audit + C2 RESOLVED) — script seed1_R2L3_engine.py

Brute-force enumeration of cylindric partitions (directly from conjecture.tex's
interlacing definition, truncated series, d=2/4/5, m<=3, all orbits) against the
two tower orientations:

- **The paper-correct tower weight is q^{m*EMD(c, c')} with c = TARGET (level m),
  c' = source (level m-1)** — i.e. Seed 4's engine orientation.
- Seed 3's "source-first" tower agrees on reversal-symmetric orbits and computes
  the REVERSAL-relabeled H on the others ((0,1,3)<->(0,3,1) at d=4; the four
  asymmetric orbits at d=5). Since reversal permutes the profile set, ALL
  positivity/monotonicity statements are unaffected; only per-orbit labels move.
- **Conflict C2 is resolved and was purely notational:** Seed 3's missing d=4 orbits
  {(0,2,2),(0,3,1)} in its labels = {(0,2,2),(0,1,3)} in paper labels = exactly
  Seed 4's missing list. The two seeds AGREE. Paper-correct statement:
  d=4 orbits with fermionic H-forms: (1,1,2), (0,0,4), (0,3,1); missing: (0,1,3), (0,2,2).

All work below uses the brute-force-validated orientation (target-first).

### Result 2 (surplus / structure census) — script seed1_R2L3_surplus.py

d = 2,4,5,7, target-first tower, m <= 6 (5 for d=7), exact Z[q]:
- Monotonicity Delta_m = H_m - H_{m-1} >= 0 re-verified; moreover **val(Delta_m) = m
  exactly** for every orbit except the corner orbit (0,0,d), where val = m+1.
  (d=2 analogue: Delta(B-row) = q^m A_{m-1}, Delta(A-row) = q^{m+1} C_{m-1} — the
  corner orbit (0,0,d) generalizes the A = (2,0,0)-orbit's extra factor q.)
- **Cross-orbit dominations H_m(O_i) >= H_m(O_j) FAIL for every pair, every d
  (including d=2!).** So no static componentwise cone of pairwise dominations
  exists. The d=2 proof's key inequality is the SHIFT-MATCHED
  B_n - (1-q^{n+1}) A_n = qC_n >= 0 — i.e. rows of (U(q^{n+1}) - I) applied to H_n.
  This is monotonicity itself, one level up. => The natural induction is on the
  statement T_m := (U(q^{m+1}) - I) H_m >= 0 (= Delta_{m+1} >= 0).
- Structure of U - I (all d checked): every diagonal entry = -q + (alternating,
  ends +1); off-diagonals = alternating fewnomials, ends +1, val >= 1;
  **the balanced orbit's row is ALL MONOMIALS** (generalizes d=2's B-row [x, 1]).

### The inductive scheme (matrix-level q-Pascal, formulated)

T_m := (U(q^{m+1}) - I) H_m. Monotonicity <=> T_m >= 0 for all m >= 0.
T_m = (U(xq) - I) U(x) H_{m-1} with x = q^m, and T_{m-1} = (U(x) - I) H_{m-1}.

**Scheme A (depth 1):** find matrices A(x,q), B(x,q) with NONNEGATIVE coefficients
(as bivariate polynomials) such that
    (U(xq) - I) U(x) = A(x,q) (U(x) - I) + B(x,q).
Then T_m = A T_{m-1} + B H_{m-1} >= 0 by induction (H >= 0 follows from T >= 0
since H_m = H_0 + sum of T's). Base: T_0 = (U(q) - I) * 1-vector >= 0 (finite check).
This is a FINITE LP feasibility problem per d (treat x, q as independent —
sufficient since x = q^m specializes nonneg to nonneg).
**Scheme A_k (depth k):** enlarge the hypothesis cone with the next k-1 future
differences (U(xq^j) - I) U(xq^{j-1}) ... U(xq) U(x), j <= k.

Next: LP feasibility, d=2 calibration first, then d=4, d=5.
### Result 3 (Scheme A / matrix q-Pascal LP: NEGATIVE, and why) — seed1_R2L3_matrixpascal.py

LP feasibility of (U(xq^k)-I)U(xq^{k-1})...U(x) = sum_j A_j G_j + B with nonneg
A_j, B over the depth-k hypothesis cone {I, iterated future differences}:
- d=2: INFEASIBLE at depths 1, 2, 3 for the corner row (0,0,2); feasible for the
  balanced row. Since d=2 monotonicity is TRUE and PROVED, this shows the
  iterated-difference cone is NOT the right inductive invariant — treating
  (x, q) as independent loses the x = q^m specialization that the d=2 proof
  (identity (iii)) genuinely uses via the (1-q^{m+1}) coefficient.
- Attack (b) in its naive matrix form is therefore DEAD (recorded so Layer 4
  doesn't retry): no fixed-depth nonneg matrix decomposition U(xq)U(x)-type
  certificate exists even at d=2.

### Reframe: the d=2 proof is an infinite POSITIVE BANDED LADDER

Define E_{a,m} := sum_j q^{j^2+aj} [m,j]_q (so H(O_bal) = E_0, H(O_corner) = E_1).
Two one-line q-Pascal facts (both from Pascal-2 / absorption):
  (L1)  E_{a,m} - E_{a,m-1} = q^{m+a} E_{a+1,m-1}        [ladder monotonicity]
  (L2)  E_{a-1,m} - E_{a,m} = q^a (1-q^m) E_{a+1,m-1}    [rung relation]
With base E_{a,0} = 1 for all a, (L1) alone gives, by induction over the whole
ladder simultaneously: E_{a,m} >= 0 and E_{a,m} >= E_{a,m-1} for ALL a — i.e.
d=2 monotonicity, no identity (iii) needed. The d=2 tower (A,B) embeds in an
INFINITE family closed under the first-difference operator, with each row of
the extended recursion of the manifestly positive form
    E_lambda,m = E_lambda,m-1 + q^{m+shift(lambda)} * E_{lambda',m-1}.

**Generalization target (new formulation of the whole problem):** for each d with
gcd(d,3)=1, find a countable family {E_lambda} containing the K orbit components,
closed under first differences: (E_lambda,m - E_lambda,m-1)/q^{m+shift} = nonneg
combination of family members at level m-1. Existence of such a "positive
difference-closed extension" <=> monotonicity (forward direction trivial by
induction; backward: take the family of all iterated surpluses, IF they are all
nonneg and the divisions are exact).

Empirical program: compute the surplus family at d=4/d=5 by repeated
differencing from the orbit components; test (i) exact q^{m+s} divisibility,
(ii) nonnegativity, (iii) whether discovered surpluses match fermionic forms
ferm(m,a,b,eps) — for the MISSING orbits this would give both the closed form
(by telescoping) and the monotonicity proof.

---
(continuation agent, same mission, resumed after predecessor hit usage limit)

### Result 4 (ladder BFS at d=4,5) — seed1_R2L3_ladder.py

Implemented the predecessor's "positive difference-closed extension" program:
BFS on the surplus operator  f |-> S with f_m - f_{m-1} = q^{m+s} S_{m-1}.
- d=2 sanity: machinery recovers S(H_bal) = H_corner and the infinite chain
  E_a with shifts s = a = 1,2,3,... exactly as (L1) predicts.
- d=4, d=5 (m<=9, exact Z[q], 40 members deep, depth ~6-7): **every iterated
  surplus exists (exact q^{m+s} divisibility, member-constant s) and is
  coefficientwise nonneg. No family break anywhere.** But no member is a
  constant-rational combination of earlier members: the family does not close
  on itself and members were unrecognized... until Result 5.

### Result 5 (THE A2 PASCAL LADDER — proved) — seed1_R2L3_fermfit.py

With ferm(m,a,b,c) := sum_{n,j} q^{n^2-nj+j^2+an+bj} [m,n][2n+c,j]
(Layer 2 seed 4's shape), matched the d=4 surplus tree against a wide
(a,b,c) grid. Discovery: the surplus operator acts on ferm by a LATTICE RAY:
    d: (a,b,c) -> (a+1, b-1, c+2),   prefactor q^{m+a}.
Chains found in the tower data: (1,1,0)->(2,0,2)->(3,-1,4);
(0,1,0)->(1,0,2)->(2,-1,4); (0,0,0)->(1,-1,2).

**Theorem (proved, one line).** For ALL integers a,b,c and m>=1:
    ferm(m,a,b,c) - ferm(m-1,a,b,c) = q^{m+a} ferm(m-1, a+1, b-1, c+2).
Proof: q-Pascal [m,n]-[m-1,n] = q^{m-n}[m-1,n-1] on the only m-dependent
factor, then reindex n -> n+1; the j-binomial [2n+c,j] is inert and becomes
[2(n+1)+c, j] = [2n+(c+2), j]; exponent bookkeeping gives (a+1, b-1) and the
global q^{m+a}. QED. (Grid-verified a in [-2,3], b in [-4,3], c in [-1,3],
m<=7: 0 fails.) This IS the d=2 q-Pascal proof, verbatim, at A2 level — the
mission's "generalize the q-Pascal argument": DONE for the fermionic family.

Corollary: ferm(m,a,b,c) >= 0 always (monomial times Gaussian binomials), so
ferm is monotone in m with ALL iterated surpluses nonneg — exactly the
Result-4 phenomenology, now explained and proved for the ferm class.

Corollary (conditional monotonicity at d=4): H(1,1,2)=ferm(m,0,0,0),
H(0,0,4)=ferm(m,1,1,0), H(0,3,1)=ferm(m,0,1,0) — Layer 2's m<=5 checks
EXTENDED to m<=8 here. Given these forms (bounded A2 Andrews-Gordon,
conjectural), monotonicity for these three orbits is proved, with surplus
valuation m+a matching Result 2's census (corner (0,0,4): a=1 => val m+1).

### Result 6 (negative: shape exclusions) — seed1_R2L3_ansatz.py, _twoterm.py

- d=5: NO orbit matches ferm(m,a,b,c) for a,b in [-1,8], c in [-2,6] (m<=8).
- Generalized two-variable ansatz sum q^{An^2+Bnj+Cj^2+an+bj}[m,n][al*n+be*m+c, j]
  over 65856-point grid (A in {1,2}, B in [-2,1], C in [1,3], a,b in [-2,4],
  al in [0,3], be in {0,1}, c in [-2,4]): NO match for d=4 missing orbits
  (0,1,3),(0,2,2) nor for any d=5 orbit (filter m<=3, verify m<=7).
- No two-term decomposition H = ferm(p1) + q^t ferm(p2) for the missing
  orbits (grids in log). The missing orbits' surplus-shift patterns increment
  s by 0,1,1,0,... (not +1 each step), so their m-dependence cannot sit in a
  single [m,n] of the tested shapes; three-variable forms (Warnaar's
  modulus-8 Conjecture shape n1,n2,m1, m2=2n2) are the natural next ansatz.

### Result 7 (g-POSITIVITY: the m-free reformulation) — seed1_R2L3_qbt.py

Key structural move: any sequence (H_m) has a UNIQUE expansion
    H_m = sum_{n=0}^m g_n(q) [m,n]_q,  g_n m-independent
(inverse q-binomial transform; g_n = n-th q-difference of the sequence,
g_n = sum_k (-1)^{n-k} q^binom(n-k,2) [n,k] H_k). One-line lemma (q-Pascal):
    g_n >= 0 for all n  ==>  H_m - H_{m-1} = sum_n g_n q^{m-n}[m-1,n-1] >= 0.

**Empirical finding: g_{c,n} >= 0 for EVERY orbit at d=2,4,5 (n<=8) and d=7
(n<=6) — including the two d=4 "missing" orbits and all seven d=5 orbits.**
So the Monotonicity Conjecture is implied by (and plausibly equivalent in
strength to a level of the BFF conjecture):

  g-POSITIVITY CONJECTURE: the inverse q-binomial transform of (H_{c,m})_m
  is coefficientwise nonneg, for every orbit, every d with gcd(d,3)=1.

This removes m from the problem entirely: one polynomial sequence per orbit.
For the ferm-orbits it is PROVED: g_n = q^{n^2+an} sum_j q^{j^2-nj+bj}[2n+c,j].
At d=2 it is the classical fermionic form (g_n = q^{n^2}, q^{n^2+n}).
Bonus structure: val(g_{c,n}) stabilizes in d (e.g. orbit (0,0,d):
0,2,6,11,18,26,36,47,60 identically for d=4,5,7; d=2 differs), hinting at a
d-uniform fermionic description of g_{c,n}.

### Deliverables
- proofs/prove-seed1-layer3.tex/.pdf — ladder theorem + g-positivity
  reformulation + exclusions (compiled).
- notes/seed1-R2L3-g-transform.md — cross-pollination note for sibling seeds.
- scripts: seed1_R2L3_{ladder,fermfit,ansatz,twoterm,qbt}.py.

## Handoff

State: the q-Pascal generalization TARGET IS ACHIEVED for the fermionic-form
class (A2 Pascal ladder, proved unconditionally), and the whole bottleneck is
reformulated m-free (g-positivity, empirically clean everywhere tested).

Next moves, in order of leverage:
1. **Push the g-transform through the level tower.** The tower
   (1+q^m+q^{2m}) H_m = sum q^{m*EMD} H_{m-1} should induce a recursion for
   the vectors (g_{c,n})_c in n (finite per n, coupling levels n, n-1, ...).
   If the induced recursion preserves positivity, monotonicity is PROVED for
   all gcd(d,3)=1. This is the direct continuation; expect q^m [m,n]
   re-expansion identities (q^m [m,n] = q^n [m,n] - q^n(1-q^m)[m-1,n] etc.).
2. **Three-variable ansatz for g_{c,n} (not H!):** fit
   g_n = sum_j q^{Q(n,j)} [2n+c, j]-type or double-j forms for the missing
   orbits; the stabilized val(g_n) sequences (0,2,6,11,18,26,... etc.) are
   the fingerprint to match. Once g_n has ANY manifestly-nonneg closed form,
   that orbit's monotonicity is proved.
3. Identify g-positivity within the BFF conjecture hierarchy (g_n is an
   n-th q-difference; BFF level j should be the j-th difference — check
   whether g-positivity = BFF at level infinity, and cite accordingly).
4. Do NOT retry: fixed-depth nonneg matrix decompositions of U (Result 3);
   two-variable H-ansatz / two-term ferm decompositions for missing orbits
   (Result 6 grids).
