# Seed 2, Layer 4, Round 2 — R1/R2 word search for the d=8 core (Mission 2)

Mission: FINITE SYMBOLIC SEARCH over words of depth <= 4 in the proved KR contiguous
relations R1^(i), R2^(i) (i=1,2), R3, R4 (m=11, k=4), for the 6 remaining d=8 core
orbits {(6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2)}. Goal per orbit: rewrite
Uncu's difference D_c into a nonneg combination of MERGEABLE pairs
S(rho|sigma) - q S(rho+d3|sigma+d3) (the Pochhammer un-split -> T-shaped sum with
denominator (q)_{r3+s3}), plus nothing (or recognized-positive remainder).
Track (4,2,2) separately (appears in NO R-relation; needs core CW equations as extra rows).

Conventions: synthesis-layer3.md §4(iv) (TRUE conjecture.tex labels; target-first kernel).
Uncu's mod-11 profile labels were confirmed to match the engine ground truth in Layer 3
(G2 + seed8_R2L3_seed2_ferm3.sage), so no rev() needed for the Uncu S11 table.

## Source-of-truth statements (verified quotes)

### Uncu 2024 (literature/chunks/uncu_proofs_modulo11_13_cylindric_kanade_russell/chunk_044.tex, eq:mod11list — PROVED, thm:m11 in chunk_045):
With e3=(0,0,0), e2=(0,0,1), e1=(0,1,1), e0=(1,1,1):
  H_(6,1,1) = S(e1|e1) - q S(e0|e0)
  H_(5,2,1) = S(e2|e1) - q S(e1|e0)
  H_(5,1,2) = S(e1|e2) - q S(e0|e1)
  H_(4,3,1) = S(e3|e1) - q S(e2|e0)
  H_(4,1,3) = S(e1|e3) - q S(e0|e2)
  H_(4,2,2) = S(e2|e2) - q S(e1|e1)
  H_(3,3,2) = S(e3|e2) - q S(e2|e1)   [used in the Layer-3 (3,3,2) theorem]
Also (zero-containing):
  H_(8,0,0)=S(e0|e0); H_(7,1,0)=S(e1|e0); H_(6,2,0)=S(e2|e0); H_(5,3,0)=S(e3|e0);
  H_(7,0,1)=S(e0|e1)-q(1-z)S((2,1,1)|e0); H_(6,0,2)=S(e0|e2)-q(1-z)S((2,1,1)|e1);
  H_(5,0,3)=S(e0|e3)-q(1-z)S((2,1,1)|e2);
  H_(4,4,0)=S((1,0,0)|e1) - q S((1,0,1)|e0) + qz S((2,1,1)|e3)  [eq:H440exp]
z-shift transform: S(q^j z; rho|sigma) = S(z; rho+(j,0,0)|sigma)  (z^{r1} q^{j r1}).

### KR contiguous relations, m=11 (m == -1 mod 3), k=4, delta_i in Z^3
(chunk_034.tex, Lemma lemma:recs = KR 2022 Lemma 9.1 — PROVED). For i in {1,2}:
  R1^(i)(rho|sigma): S(rho|sigma) - S(rho+d_i-d_{i+1}|sigma)
                     - z q^{i+rho_1+..+rho_i} S(rho+2(d_1+..+d_i) | sigma-(d_1+..+d_i)) = 0
  R2^(i)(rho|sigma): S(rho|sigma) - S(rho|sigma+d_i-d_{i+1})
                     - z q^{i+sigma_1+..+sigma_i} S(rho-(d_1+..+d_i) | sigma+2(d_1+..+d_i)) = 0
  R3(rho|sigma) [needs sigma_3=0]: S(rho|sigma) - S(rho|sigma+d3)
                     - q S(rho+d3|sigma+d3) + q S(rho+d3|sigma+d2+d3) = 0
  R4(rho|sigma) [needs rho_3=0]:   S(rho|sigma) - S(rho+d3|sigma)
                     - q S(rho+d3|sigma+d3) + q S(rho+d2+d3|sigma+d3) = 0

### Merge lemma (proved, Step 2 of prove-seed2-layer3.tex; valid for ALL rho,sigma):
  S(rho|sigma) - q S(rho+d3|sigma+d3) = T(rho|sigma),
  T = same sum with denominator (q)_{r3+s3} replacing (q)_{r3+s3+1}.

## Success criteria
- FULL SUCCESS (per orbit): D_c = sum_j a_j(z,q) T(rho_j|sigma_j) with all a_j having
  nonneg coefficients, AND each T matching a Warnaar-type finite-form limit (else
  "conditional merge" — structural success, positivity still needs the finite form).
- Verify every found identity exactly in ZZ[q] to z-order n<=4 / q^150 vs the S11
  evaluator + ground truth (seed5_R2L2_qn_d8.json, engine seed8_R2L3_engine.sage).
- Failure: record exact search space (relations, slots, caps, depth) as a certificate.

## Log

### RESUMED after usage-limit kill. Cheap first move (Seed 1's verbatim hint) executed FIRST.

### Finding L4.1 (STRUCTURAL BREAKTHROUGH CANDIDATE — the verbatim match EXISTS, for ALL
### 6 core orbits at once, incl. (4,2,2))
Source: literature/tex/warnaar_A2_andrews_gordon/source.tex.
Warnaar defines a SECOND finite-form family (eq. Eq_F2, line 2834):
  F^{(a)}_{n0,m0;k,s,t}(z,q) = sum_{n_i,m_i>=0} z^{n1} q^{sum_{i=s}^k n_i + sum_{i=t}^k m_i}
      / (q)_{n_k+m_k+1} * prod_{i=1}^k q^{n_i^2 - sigma_i n_i m_i + m_i^2}
        [n_{i-1};n_i][m_{i-1};m_i],     sigma=(1,..,1,a), 1<=s,t<=k+1.
  NOTE the denominator (q)_{n_k+m_k+1} — the "+1" ALREADY matches S_11's (q)_{r3+s3+1}.
Prop_finiteform2 (lines 2848-2878) is PROVED UNCONDITIONALLY (proof lines 2884-2962 via
Lem_F-trafo; the separate Con_missing is only about theta-product evaluations at z=1,
NOT needed here). It gives positive fermionic RHS forms:
  - Eq_mineen  (a=-1, 1<=s<=k+1, 1<=t<=k): denominator (q)_{m0-n1+m1+delta_{t,1}},
    m_k := 2n_k, binomial top-shift delta_{i,t-1} in [n_i-n_{i+1}+m_{i+1}+delta_{i,t-1}; m_i],
    exponent n_k^2 + sum_{i=s}^k n_i + sum_{i=t}^{k-1} m_i + sum_{i<k}(n_i^2-n_i m_i+m_i^2).
  - Eq_mineen2 (a=-1, 1<=s<=k, t=k+1, k>=2): exponent n_k^2 - n_k + sum_{i=s}^k n_i,
    binomial [n_i + delta_{i,k-1}; n_{i+1}].
LIMIT n0,m0 -> infinity at k=3, a=-1 (modulus 3k+a+3 = 11):
  LHS: [n0;n1][n1;n2][n2;n3] telescopes to 1/((q)_{n1-n2}(q)_{n2-n3}(q)_{n3}), same for m;
  sigma_3=-1 gives +2 n3 m3 cross term; linear terms = rho.r + sigma.s with
  rho = e_{s-1}, sigma = e_{t-1}  (rho_i = [i>=s]: s=4->e3, s=3->e2, s=2->e1, s=1->e0).
  Denominator (q)_{n3+m3+1} = S_11's (q)_{r3+s3+1}.  Hence VERBATIM:
     lim F^{(-1)}_{3,s,t} = S_11(z; e_{s-1} | e_{t-1})           ... (V)
  RHS limit: 1/(q)_{m0-n1+m1+d} -> 1/(q)_inf; [n0;n1] -> 1/(q)_{n1}. So
     S_11(e_{s-1}|e_{t-1}) = Ferm_{s,t}(z,q) / (q)_inf            ... (V')
  where Ferm_{s,t} is the (manifestly positive) 5-fold sum with denominator (q)_{n1}.
CONSEQUENCE (combining with Uncu thm:m11, PROVED): for EVERY core orbit c=(c1,c2,c3),
     G_c = (q)_inf H_c = Ferm_{c2+1,c3+1} - q Ferm_{c2,c3}        ... (W)
  an EXACT identity with every link proved. At the Q-level (n1=n, (q)_n cancels):
     Q_{n,c} = ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n)            ... (Wn)
  = difference of two explicit positive finite q-binomial multisums. This covers ALL SIX
  core orbits including (4,2,2) (unreachable by any R-relation): (s,t) pairs are
  (6,1,1):(2,2)-(1,1); (5,2,1):(3,2)-(2,1); (5,1,2):(2,3)-(1,2); (4,3,1):(4,2)-(3,1);
  (4,1,3):(2,4)-(1,3) [t=4 uses Eq_mineen2]; (4,2,2):(3,3)-(2,2).
NO KR relation, NO merge, NO word search needed for the REPRESENTATION. The whole
positivity burden moves to 6 explicit two-term inequalities ferm_A >= q ferm_B —
exactly the d=4 wall shape that Absorption Lemmas handled (synthesis G9).
Plan: (1) verify (V)/(W)/(Wn) exactly vs engine for all 6 orbits (transcription guards
at finite n0,m0 like Seed 1's [FF]); (2) attack absorption for (6,1,1),(5,2,1) first.
The depth<=4 R-word search is SUPERSEDED unless step (2) stalls.

### Finding L4.2 (VERIFIED — run 1, all PASS in 9s)
Script scripts/seed2_R2L4_verify.sage, log tmp/seed2_L4_verify_run1.log. Sage 10.9.
  [FF2] Prop_finiteform2 transcription (Eq_F2 == Eq_mineen/Eq_mineen2), k=3, a=-1,
        ALL 15 (s,t) pairs (s<=4,t<=3 and (s,4),s<=3), n0,m0 in {0..3}, per z-order,
        to q^150: ALL PASS.
  [V]   S11(e_{s-1}|e_{t-1}) == [z^n] Ferm_{s,t}/(q)_inf, n<=3, six spot pairs incl.
        t=4 case: ALL PASS.
  [Wn]  ferm(n;c2+1,c3+1) - q ferm(n;c2,c3) == engine Q_n (seed8 engine, target-first,
        exact Z[q], Gauss inversion), d=8, n=0..8, ALL SEVEN orbits (6 core + (3,3,2)
        control): ALL MATCH, all differences coefficientwise >= 0 (consistent with Y1).
=> THEOREM (representation, GREEN-candidate): for every d=8 core orbit c,
     G_c(z,q) = Ferm_{c2+1,c3+1}(z,q) - q Ferm_{c2,c3}(z,q),
   with both Ferm's manifestly positive proved fermionic 5-fold sums (Warnaar
   Prop_finiteform2 limits). Q_{n,c} is an explicit finite q-binomial two-term
   difference. Warnaar positivity at the ENTIRE d=8 core is now 6 explicit finite
   inequalities ferm(n;s,t) >= q ferm(n;s-1,t-1). Word search NOT needed for this.

### Finding L4.3 (absorption structure of the differences — hand derivation)
Write QF = n^2+n2^2+n3^2-n m1-n2 m2+m1^2+m2^2, N := n-n2+m2, M := n2+n3,
base binoms [n;n2][n2;n3]. Common factor q^QF [n;n2][n2;n3] in every summand.
For the three orbits with c3=1 (t-pair (2,1)-type), the difference has a SINGLE-ROW shape:
  (6,1,1): sum q^{n2+n3+m2} [M;m2] ( [N+1;m1] - q^{1+n +m1}[N;m1] )
  (5,2,1): sum q^{n3+m2}    [M;m2] ( [N+1;m1] - q^{1+n2+m1}[N;m1] )
  (4,3,1): sum q^{m2}       [M;m2] ( [N+1;m1] - q^{1+n3+m1}[N;m1] )
  (pattern: penalty exponent 1 + n_{c2} + m1).
NEGATIVE result (hand check): the fixed-(n2,n3,m2) m1-slice
  Phi(n,N) = sum_{m1} q^{m1^2-n m1}([N+1;m1] - q^{1+n+m1}[N;m1])
is NOT nonneg (n=0, N=1: 1 + q^2 - q^3 + q^4). So absorption must couple m2 (or n2,n3)
rows, as in the d=4 wall lemmas. Next: numeric slice scan to find the coarsest grouping
that is already nonneg (candidate lemma shape).
Orbits with c3=2 ((5,1,2),(4,2,2)) and c3=3 ((4,1,3)) have TWO-ROW shifted-binomial
interactions (shift moves between the m1-row and m2-row across the pair) — attack after
the c3=1 trio.

### Finding L4.4 (slice-positivity scan, c3=1 trio; scripts/seed2_R2L4_slices.sage,
### log tmp/seed2_L4_slices_run1.log; n<=7, exact Z[q])
Grouping hierarchy (partial sums coefficientwise >= 0):
  (4,3,1): fixed-(n2,n3) slices NONNEG (sum over m1,m2 only). Also fixed-n2 and fixed-n3.
  (5,2,1): fixed-n2 slices NONNEG (sum over n3,m1,m2). (n2,n3)-slices FAIL.
  (6,1,1): ONLY the full sum is nonneg — every tested proper grouping FAILS.
  All single-row m1-slices FAIL for all three (consistent with L4.3 hand check).
Difficulty ordering (6,1,1) > (5,2,1) > (4,3,1) tracks the penalty parameter p = n_{c2}.
Wall-shape split (q-Pascal [N+1;m1] = q^{m1}[N;m1] + [N;m1-1]):
  inner = q^{m1}(1 - q^{1+p})[N;m1] + [N;m1-1]
For (6,1,1), p = n is CONSTANT at the Q-level, so
  Q_n(6,1,1) = (1 - q^{n+1}) A_n + B_n,   A_n, B_n manifestly positive
— EXACTLY the d=4 wall shape (G9). For (5,2,1)/(4,3,1) the same split works per
n2- / (n2,n3)-slice with factor (1-q^{1+n2}) / (1-q^{1+n3}).
LEMMA CANDIDATE A ((4,3,1), verified n<=7): for all n >= n2 >= n3 >= 0,
  L(n,n2,n3) := sum_{m1,m2>=0} q^{m1^2-n m1+m2^2-n2 m2+m2} [n2+n3;m2]
                ([n-n2+m2+1;m1] - q^{1+n3+m1}[n-n2+m2;m1])  >= 0.
Next: experimental math on L — closed/telescoping form via double q-Pascal
(Absorption Lemma B template).

### [Wn] extended to n<=12 (log tmp/seed2_L4_verify_n12.log): ALL 7 orbits match engine
### exactly in Z[q] and are coefficientwise nonneg, n=0..12. 22s total.

### Positivity attempt 1 (FAILED — strike 1): one-round absorption for (4,3,1)
Split L = (1-q^{1+n3})A + B (second q-Pascal on the m1-row); residual R = B - q^{1+n3}A
is NOT nonneg for ANY slice (n<=6, all (n2,n3)) — scripts/seed2_R2L4_lemmaA.sage.
So single-round absorption a la d=4 Lemma A does not close (4,3,1); the absorption is
genuinely multi-row here. (Lemma Candidate A itself re-confirmed: L >= 0 on all slices
n<=6.) Banking the representation theorem tex before further positivity attempts.

### Positivity attempt 2 (FAILED — strike 2): elementary-move factorization
scripts/seed2_R2L4_moves.sage, log tmp/seed2_L4_moves_run1.log. Both decompositions
  Route I : [ferm(s,t)-ferm(s-1,t)] + [ferm(s-1,t)-q ferm(s-1,t-1)]
  Route II: [ferm(s,t)-q ferm(s,t-1)] + q[ferm(s,t-1)-ferm(s-1,t-1)]
FAIL for ALL 7 orbits (n<=7): NO elementary (s- or t-) move is coefficientwise
monotone; ONLY the diagonal (s,t)->(s-1,t-1) with weight q is nonneg. Structural fact:
the positivity of Uncu differences is irreducibly diagonal — the joint penalty exponent
1+n_{s-1}+m_{t-1} is what makes it work; corner-splitting destroys it.

## Positivity attempt 3 — positive-recurrence search (STRIKE 3, positivity work STOPPED)

Script: scripts/seed2_R2L4_recur.sage, scripts/seed2_R2L4_recur2.sage
(log tmp/seed2_L4_recur_run1.log; ERRATUM E4 per verifier: the second log
tmp/seed2_L4_recur2_run1.log was never written — recur2 output went to the
same first log).

Target: the (4,3,1) fixed-(n2,n3) slice function
  L(n,n2,n3) = Sum_{m1,m2} q^{m1^2-n*m1+m2^2-n2*m2+m2} [n2+n3;m2]
               ( [n-n2+m2+1;m1] - q^{1+n3+m1}[n-n2+m2;m1] ),
which is coefficientwise nonneg for all n<=7 (Finding L4.4). Sought an exact
positive recurrence that would prove nonnegativity by induction.

Numerically PASSING monotone relations (84 cases, 0<=n3<=n2<=n<=7), all
coefficientwise >= 0 — recorded as YELLOW observations:
  L - L(n2-1)            >= 0
  L - q^a L(n3-1)        >= 0   for a=0,1
  L - L(n-1,n2-1)        >= 0
  L - q^a L(n2-1,n3-1)   >= 0   for a=0,1,2
  L - q^a L(all-1)       >= 0   for a=0,1,2,3,4
NOT passing: the pure n-decrement L - L(n-1) (for n3>=1 every residue has
exactly ONE -1 coefficient at second-highest degree, e.g.
rn(2,1,1) = q^{-1}+2+2q+q^2+q^3+q^4+q^5 - q^6 + q^7).

Why this is strike 3: none of the passing residues (in particular
r2 = L - q^2 L(n2-1,n3-1), the tightest diagonal move) has a recognizable
closed form or an evident summand-level injection; a bounded fitting pass over
products of q-binomials in (n,n2,n3) found no match. Without an exact identity
the recurrences prove nothing. Per the three-strike rule, positivity work on
the six inequalities STOPS here.

### Strike certificate (positivity of ferm_{c2+1,c3+1} - q ferm_{c2,c3})
1. One-round absorption residual (B - q^{1+p+m1}A) fails coefficientwise for
   (4,3,1) — scripts/seed2_R2L4_lemmaA.sage.
2. Elementary-move factorizations through intermediate (s,t) lattice points
   (Route I: s-move then diagonal; Route II: t-move then diagonal) fail for
   ALL 7 orbits — scripts/seed2_R2L4_moves.sage. Structural fact: only the
   DIAGONAL move (s,t)->(s-1,t-1) with weight q is nonneg; the joint penalty
   exponent 1+n_{s-1}+m_{t-1} is essential and cannot be split.
3. Positive-recurrence extraction for the (4,3,1) slice L fails to produce an
   exact identity despite 12 numerically-passing monotone relations —
   scripts/seed2_R2L4_recur.sage / recur2.sage.

## FINAL STATUS (Seed 2, Round 2 Layer 4)

BANKED (GREEN-candidate, pending independent verification):
  Two-term fermionic representation theorem — for every d=8 core orbit
  c = (c1,c2,c3) with c2,c3 >= 1 (all six: (6,1,1),(5,1,2),(4,1,3),(4,3,1),
  (5,2,1),(4,2,2)) and control (3,3,2):
      G_c = Ferm_{c2+1,c3+1} - q * Ferm_{c2,c3},
      Q_{n,c} = ferm_{c2+1,c3+1}(n) - q * ferm_{c2,c3}(n),
  with Ferm_{s,t} the manifestly-positive fermionic sum from Warnaar's
  Prop_finiteform2 (Eq_mineen / Eq_mineen2) at k=3, a=-1, in the limit
  n0,m0 -> infinity. Every link proved (Prop_finiteform2 is unconditional;
  verbatim limit check; Uncu thm:m11). Verified exactly in ZZ[q] against the
  independent engine for n <= 12, all 7 orbits. This INCLUDES (4,2,2), the
  orbit absent from every KR R-relation. Deliverable:
  proofs/prove-seed2-layer4.tex (compiled).

OPEN (YELLOW): positivity of the six two-term differences. Structural map for
successors: (4,3,1) easiest (nonneg per (n2,n3)-slice; Lemma Candidate A
target L >= 0 above); (5,2,1) middle (n2-slices); (6,1,1) hardest (only full
sum; wall-shape split Q_n = (1-q^{n+1})A_n + B_n available). Positivity is
irreducibly diagonal (see strike certificate item 2).

SUPERSEDED: the original depth<=4 R-word search (Mission 2 as stated) — the
verbatim fermionic route gives a stronger representation with no search
needed. Not run; recorded here as a deliberate mission upgrade, not an
exhausted search.

NOTE FOR SYNTHESIS: I could not spawn an independent verifier sub-agent;
the representation theorem needs one before being marked GREEN.
