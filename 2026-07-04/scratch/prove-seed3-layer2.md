# Scratch: Seed 3, Layer 2, Round 2

## Mission
Prove h_m >= 0 via the factorization h_m = beta_m * tilde_h_m (beta_m = (q;q)_m/(q^3;q^3)_m mixed
signs, tilde_h_m >= 0). Attack lines: (a) absorption, (b) q-series identity, (c) divisibility of
tilde_h_m by prod_{i=1}^m (1+q^i+q^{2i}). Extend verification to d=13,14 exactly.

## Setup and conventions

Profiles c=(c_0,c_1,c_2), sum d. Transfer weight from source c' (level m-1) to target c (level m)
is q^{m*EMD(c',c)} where (project-standard formula, e = c' - c):

    EMD(c',c) = 2e_0 + e_1 + 3*t_min,   t_min = max(0, -e_0, -e_0-e_1).

P_{c,0}=1, P_{c,m} = sum_{c'} q^{m*EMD(c',c)} P_{c',m-1}.
F_{c,m} = P_{c,m}/(q^3;q^3)_m,  g_m = F_{c,m}-F_{c,m-1},  h_m = (q;q)_m g_m (ell=1 case).

## FIRST STRUCTURAL MOVE: the H-recursion (new, this session)

Define **H_{c,m} := (q;q)_m F_{c,m}** (so H_{c,0} = 1). From the P-recursion, dividing by
(q^3;q^3)_{m-1} and multiplying by (q;q)_m, using (1-q^{3m})/(1-q^m) = 1+q^m+q^{2m}:

    (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}.        (**)

And h is recovered EXACTLY (no infinite series anywhere):

    h_{c,m} = H_{c,m} - (1-q^m) H_{c,m-1}.

Derivation check: H_m - (1-q^m)H_{m-1} = (q;q)_m F_m - (1-q^m)(q;q)_{m-1}F_{m-1}
= (q;q)_m (F_m - F_{m-1}) = (q;q)_m g_m = h_m. OK.

Consequences to be verified/proved:
1. (**) allows EXACT computation of h_m in ZZ[q] (no truncation, no precision issues at all),
   provided each division by (1+q^m+q^{2m}) is exact.
2. The division IS exact when gcd(d,3)=1, by the following two lemmas.

### Lemma R (rotation shift). Let rho(a) = (a_1,a_2,a_0). Then
EMD(rho(c'), c) == EMD(c',c) + d (mod 3).

Proof: EMD(c',c) == 2e_0+e_1 = (2c'_0+c'_1) - (2c_0+c_1) (mod 3). Replacing c' by rho(c')
changes 2c'_0+c'_1 to 2c'_1+c'_2; difference = c'_1+c'_2-2c'_0 == (c'_0+c'_1+c'_2)-3c'_0 == d (mod 3). QED

So for gcd(d,3)=1, the three rotations of any source profile c' hit all three residues mod 3.

### Lemma I (rotation invariance). H_{rho(c),m} = H_{c,m} (since F_c is invariant under cyclic
rotation of the profile: rotating a cylindric partition around the cylinder is a size- and
max-preserving bijection). Also EMD(rho(a),rho(b)) = EMD(a,b) (to be verified numerically,
provable from cyclic symmetry of the transport problem).

### Divisibility theorem (polynomiality of h_m, gcd(d,3)=1) -- PROOF SKETCH
Group the sum in (**) into C_3 rotation orbits O of source profiles. For gcd(d,3)=1 every orbit
is free (no fixed profile (t,t,t) exists). By Lemma I, H_{c',m-1} is constant = H_{O,m-1} on O.
By Lemma R, the three exponents {EMD(sigma^j c', c)} are distinct mod 3. Since
q^{3m} == 1 mod (1+q^m+q^{2m}), each orbit sum == H_O * (1+q^m+q^{2m}) == 0. So the RHS of (**)
is divisible by the monic polynomial 1+q^m+q^{2m} in ZZ[q], and by induction H_{c,m} in ZZ[q].
Hence h_m in ZZ[q]. (For 3|d the fixed orbit {(d/3,d/3,d/3)} breaks this -- consistent with h_m
failing for 3|d with the (q;q)_m normalization.)

### The positivity question in this language
Let the orbit-EMD triple be {a_0, a_1, a_2} with a_r == r (mod 3), a_r = r + 3k_r. Then

    s_{O,c}(x) := (x^{a_0}+x^{a_1}+x^{a_2})/(1+x+x^2) = 1 + (x-1) * V_O(x),
    V_O(x) = sum_r x^r * (1 + x^3 + ... + x^{3(k_r-1)})   (V_O >= 0).

and H_{c,m} = sum_O s_{O,c}(q^m) H_{O,m-1}.

**Dream scenario:** if every orbit triple is CONSECUTIVE, {a,a+1,a+2}, then s_{O,c}(x) = x^a >= 0
and H_{c,m} = sum_O q^{m*a(O,c)} H_{O,m-1} is manifestly a positive recursion; moreover the
diagonal orbit O_c has triple {0,1,2} (a=0), giving

    h_{c,m} = H_{c,m} - (1-q^m)H_{c,m-1} = q^m H_{c,m-1} + sum_{O != O_c} q^{m*a(O,c)} H_{O,m-1} >= 0.

**Reality check (hand computation):** c=(2,1,1), d=4: orbits of (4,0,0) -> triple {3,4,5} ok;
(3,1,0) -> {2,3,4} ok; (0,2,2) -> {1,2,3} ok; own orbit -> {0,1,2} ok. BUT c=(4,0,0):
own orbit triple {0,4,8} -> s = 1 - x + x^3 - x^5 + x^6 (MIXED); orbit of (3,1,0) -> {2,3,7},
s = x^2(1 - x^2 + x^3) (MIXED). So consecutiveness FAILS for corner-like profiles, yet
h_m(4,0,0) >= 0 holds. Compensation across orbits must occur. Need census + finer argument.

## Plan
1. Script 1: validate (**), Lemma R, Lemma I, exact division, against Layer-1 numbers. [exact ZZ[q]]
2. Script 2: census of orbit triples s_{O,c} for d=4,5,7,8,10,11,13,14 -- how often mixed, pattern.
3. Script 3: EXTEND VERIFICATION h_m >= 0 to d=13,14, all profiles, m<=6, EXACT (no truncation).
4. Analysis: compensation mechanism for mixed s; stronger inductive statement; RAG for known
   positivity-preserving transformations.
5. Write up what is proved (polynomiality theorem + reduction) in proofs/.

## Computational Evidence (session log)

### Script 1 (validate): ALL PASS
- EMD rotation equivariance and Lemma R verified for d=4,5,7 (all pairs).
- Exact division in (**) holds at every step for d=4 (m<=5), d=5 (m<=4); FAILS for d=3 at m=1
  exactly as the orbit argument predicts (fixed orbit (1,1,1) breaks equidistribution).
- h_m from the exact recursion REPRODUCES the power-series h_m (prec 800) for d=4, all 15
  profiles, m<=5; h_2(2,1,1) = [0,0,3,4,5,3,3,2,2,1,1,0,1] exactly as in Layer 1.
- => the H-recursion is a sound EXACT computational route: no truncation, precision rule moot.

### Script 2 (census): consecutive-triple dream is DEAD
Non-consecutive orbit triples are the NORM (e.g. d=8: 540/675 pairs; d=14: 4395/4800), and the
quotients s_{O,c}(x) have mixed signs in all non-consecutive cases. Mixed pairs occur for all
zero-patterns of (c, O) once d >= 5. Even d=2 has one: target (2,0,0), own orbit {0,2,4},
s = 1-x+x^2. Compensation across orbits is essential. Absorption line (a) in naive orbit form: DEAD.

### Script 4 (invariant hunt): THE KEY NEW INVARIANT
Testing coefficientwise inequalities for d=2,4,5, m<=6 (exact):
- (I1) H_{c,m} >= 0: TRUE everywhere.
- (I5) **H_{c,m} >= H_{c,m-1} (level monotonicity): TRUE everywhere.**
- Cross-profile dominations (H_a >= q^E H_b etc.): ALL FALSE.

**REDUCTION (proved, trivial algebra):** h_{c,m} = (H_{c,m} - H_{c,m-1}) + q^m H_{c,m-1}.
So  MONOTONICITY (I5) + H >= 0 (I1)  ==>  h_m >= 0.  And I1 follows from I5 by induction
(H_0 = 1). So the whole bottleneck is now:

    **Monotonicity Conjecture: H_{c,m} >= H_{c,m-1} coefficientwise, for gcd(d,3)=1.**

### Script 5 (A-matrix): exact cross-level identity, absorption attempts fail
With A(x)[c,c'] = sum_{J subset I_c, c(J)=c'} (-1)^{|J|-1} x^{|J|} (CW matrix, seed 4):
- Verified M(x) = adj(I-A(x))^T, det(I-A) = 1-x^3. Hence M/(1+x+x^2) = (1-x)(I-A^T)^{-1}, and
  since (I-A)^{-1}[a,b] = x^{EMD(a,b)}/(1-x^3) >= 0 as power series, we get
      Delta_{m} := H_m - H_{m-1} = (I-A(q^m)^T)^{-1} (A(q^m)^T - q^m I) H_{m-1}.
- Verified EXACT transposed cross-level identity (d=4, m<=6, all profiles):
      H_{c,m} = sum_{c',J: J subset I_{c'}, c'(J)=c} (-1)^{|J|-1} q^{m|J|} H_{c',m} + (1-q^m) H_{c,m-1}.
- Sufficient conditions tried and FALSIFIED: (C1) H_{c(J),m} >= H_{c,m-1} for |J|=1 (fails m>=2);
  (C1') all J; (C2) within-level q^m-shifted domination along CW edges. The smoothing by
  (I-A^T)^{-1} is genuinely needed; no local absorption scheme works.

## BREAKTHROUGH LEAD: H_{c,m} is a bounded Rogers-Ramanujan / ASW polynomial

d=2, orbit (1,1,0): H_{A,m} = 1, 1+q, 1+q+q^2+q^4, 1+q+q^2+q^3+q^4+q^5+q^6+q^9, ...
   MATCHES  H_{A,m} = sum_j q^{j^2} [m choose j]_q   (classical RR polynomial), m<=3 by hand.
d=2, orbit (2,0,0): MATCHES sum_j q^{j^2+j} [m choose j]_q, m<=2 by hand.
**For these forms, monotonicity is MANIFEST via q-Pascal:**
   sum_j q^{j^2}([m,j]-[m-1,j]) = sum_j q^{j^2+m-j}[m-1,j-1] >= 0.
So for d=2 the chain closes: fermionic form => monotonicity => h_m >= 0.

Evaluation check for d=4: H_{c,m}(1) = 5^m = sum_{n1} binom(m,n1) 4^{n1}: consistent with the
bounded ASW ansatz  H_{c,m} = sum_{n1,n2} q^{n1^2+n2^2-n1n2+a*n1+b*n2} [m,n1]_q [2n1+eps,n2]_q
(five ASW mod-7 identities <-> five C_3-orbits of d=4 profiles!). Hand check c=(2,1,1), m=1,
(a,b,eps)=(0,0,0): 1+2q+q^2+q^3 = H_1 EXACT MATCH.
d=5: H(1) = 7^m consistent with CDU mod-8 quadruple-sum shape [m,n1][n1,n2][n2,n3][n1,n4].

**This is the bounded A_2 Andrews-Gordon identity that Warnaar's paper explicitly lists as an
open problem** (RAG chunk warnaar_a2_andrews_gordon_cylindric_partitions/chunk_102: "it is an
open problem to find the bounded analogues... for k=2"). H_{c,m} = (q;q)_m F_{c,m} is the
natural candidate for its LHS. Any fermionic form whose only m-dependence is [m, n1]_q
gives monotonicity by q-Pascal, hence h_m >= 0.

### Bonus exact identity (proved by telescoping in the scratch algebra):
    Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m,2)} [n choose m]_q H_{c,m}.
Verified by hand for d=2 (gives Q_1 = q, Q_2 = q^4 at profile (1,1,0) correctly).
So H_m is the "positive core"; Q_n is its alternating q-binomial transform.

### Script 6 (fermionic fit, exact):
- d=2: H_{(1,1,0),m} = sum_j q^{j^2} [m,j]_q and H_{(2,0,0),m} = sum_j q^{j^2+j} [m,j]_q
  verified EXACTLY for m <= 8. Combined with the q-Pascal monotonicity argument and a hand
  proof that these polynomials satisfy the orbit-reduced H-recursion, this gives a COMPLETE
  PROOF of h_m >= 0 (hence, modulo the tower step, Q_n >= 0) for d=2.
- d=4 (5 orbits), ASW ansatz H = sum_{n1,n2} q^{n1^2+n2^2-n1n2+a n1+b n2}[m,n1]_q[2n1+eps,n2]_q:
  EXACT matches (m <= 6) for orbits of (2,1,1) [(a,b,eps)=(0,0,0)], (4,0,0) [(1,1,1)... see log],
  (1,1,2)-type. Orbits of (0,2,2) and (0,3,1): NO match in the (a,b,eps) grid.
- d=5 (7 orbits), CDU quadruple-sum ansatz: EXACT matches (m <= 5) for 4/7 orbits;
  (0,2,3), (0,3,2), (0,4,1) orbits unmatched.

### Script 7 (monotonicity extension + Q-transform):
- Monotonicity Conjecture H_{c,m} >= H_{c,m-1} verified EXACTLY (ZZ[q], no truncation) for
  d = 7, 8, 10, 11, all profiles, m <= 5 (in addition to d = 2, 4, 5 from Script 4).
- Q-transform identity Q_n = sum_m (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m} verified
  numerically against the D-tower Q_n. (Note: seed 4's recorded Q_2 for d=4,(2,1,1) differs
  from mine by (1+q)(1-q^4) -- likely a different normalization; mine matches the D-tower
  and the known d=2 values Q_n = q^{n^2}.)

### Script 8 (missing-orbit search): NEGATIVE
For the d=4 missing orbits (0,2,2), (0,3,1): searched (i) single fermionic forms with 6
prefactor families and shifted bounds [m+delta, n1][2n1+eps, n2], (ii) all two-term
combinations plain(a,b,eps) + q^w plain(a',b',eps'). Result: NONE match. These orbits
likely need Warnaar Thm-3-type shifted binomials [n_i - n_{i+1} + m_{i+1} + delta] or
theta-quotient corrections. Three ansatz families tried -> stopping per three-strike rule.

### Mission verification item: d=13, d=14 COMPLETE (exact)
seed3_R2L2_verify_d13_d14.sage: h_{c,m} >= 0 for ALL profiles of d=13 (105 profiles) and
d=14 (120 profiles), m <= 6, computed EXACTLY in ZZ[q] via the H-recursion (no truncation,
precision rule moot). Log: scratch/seed3_R2L2_verify_d13_d14.log.

## Handoff

**Status: YELLOW (major structural reduction + d=2 fully proved; general case open).**

What is PROVED (write-up in proofs/prove-seed3-layer2.tex):
1. **H-recursion**: H_{c,m} := (q;q)_m F_{c,m} satisfies
   (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m EMD(c',c)} H_{c',m-1}, H_{c,0} = 1, and
   h_{c,m} = H_{c,m} - (1-q^m) H_{c,m-1}. Enables EXACT ZZ[q] computation.
2. **Polynomiality theorem** (attack line (c) ANSWERED): for gcd(d,3)=1, H_{c,m} and h_{c,m}
   are polynomials. Proof via Lemma R (EMD(rho c', c) = EMD(c',c) + d mod 3) + free C_3-orbits
   => RHS of the recursion is divisible by 1+q^m+q^{2m}. Fails for 3|d (fixed orbit), matching
   the known h_m < 0 there.
3. **Reduction**: h_{c,m} = (H_{c,m} - H_{c,m-1}) + q^m H_{c,m-1}. So the entire bottleneck is
   **Monotonicity Conjecture: H_{c,m} >= H_{c,m-1} coefficientwise (gcd(d,3)=1)** -- verified
   exactly for d = 2,4,5,7,8,10,11, m <= 5-6, all profiles.
4. **d=2 THEOREM**: H's are the classical Rogers-Ramanujan polynomials sum_j q^{j^2+aj}[m,j]_q
   (a = 0, 1); monotonicity is manifest via q-Pascal; hence h_m >= 0 for d=2, all m.
5. **Q-transform**: Q_n = sum_{m<=n} (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m}.

Key conjecture for the next round: **Bounded Fermionic Form Conjecture** -- each H_{c,m} is a
bounded A_2 Andrews-Gordon polynomial (Warnaar explicitly lists finding these as OPEN,
chunk_102 of his paper) with all m-dependence in a single [m, n1]_q factor; any such form
gives monotonicity by q-Pascal instantly. Verified for d=2 (all orbits), 3/5 orbits at d=4,
4/7 at d=5. The unmatched orbits ((0,2,2),(0,3,1) at d=4; (0,2,3),(0,3,2),(0,4,1) at d=5)
resist simple ansaetze -- try Warnaar Thm-3 shifted binomials, or Foda-Welsh/Uncu bounded
analogues, or prove monotonicity directly from the (I-A(q^m)^T)^{-1} smoothing identity
Delta_m = (I-A^T)^{-1}(A^T - q^m I) H_{m-1}.

Dead ends (do NOT retry): consecutive-orbit absorption; local absorption C1/C1'/C2;
cross-profile dominations I3/I4; prefactor/two-term fermionic fits for missing orbits.

Mission verification: d=13, d=14 all profiles m<=6: h_m >= 0 EXACT. DONE.

Caveat for synthesizer: the tower step (h_m >= 0 => Q_n >= 0 via D_k^m) is itself only
YELLOW (Layer-1 status) and must be tracked separately.
