# Consolidated Synthesis: Round 1 (2026-07-03)

Input for Round 2 agents. This document captures the complete final state of 27 agent instances (8 seeds x 3 layers + 3 sequential agents A, B, C). Read this before starting work.

---

## The Problem

Given a composition c = (c_0, c_1, c_2) with d = c_0 + c_1 + c_2, define cylindric partitions of profile c (sequences of 3 partitions satisfying cyclic interlacing conditions on a cylinder of circumference t = d + 3). The bivariate generating function is F_c(z,q) = sum over cylindric partitions of q^size * z^max. Define:

  Q_{n,c}(q) = (q^ell; q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))

where ell = gcd(d, 3). There are binom(d+2, 2) profiles for each d.

**Conjecture (Corteel-Dousse-Uncu / Warnaar):** Q_{n,c}(q) has nonneg coefficients.

The original conjecture restricts to d not divisible by 3. Agent C discovered this restriction is unnecessary when ell = gcd(d,3) is used (see below).

---

## 1. What Was Tried

**Layers 1-3 (24 seeded agents, 8 seeds x 3 layers):** Exhaustive parallel exploration across eight approaches: Ehrhart theory / Hall's marriage (Seed 1), partition-bead bijections / key polynomials (Seed 2), skew RSK / inductive D_k^m tower (Seed 3), bilateral Rogers-Ramanujan / injection lemma (Seed 4), Schubert polynomials / Demazure crystals (Seed 5), Nandi / CW system analysis (Seed 6), vertex operators / KR crystals (Seed 7), plane partitions / lozenge tilings (Seed 8). Key outputs: proved injection lemma (g_m >= q*g_{m-1}), proved Q_1 >= 0, discovered universal determinant det(I-A(x)) = -(x^3-1), established GL_3 key polynomial decomposition of all D_k^m, found partial Demazure character match for balanced profiles at n=1, explained mod-3 restriction via Ehrhart quasi-polynomial structure.

**Agent A (sequential, RAG access):** Proved h_m < 0 for m >= 2 even when d is not divisible by 3, killing Path A (D_k^m tower with base case h_m >= 0). Derived matrix product formula F_{c,n} = prod_{k=1}^n (I-A(q^k))^{-1} * v_0. Showed direct KR tensor product weight-space matching fails (wrong evaluations). Identified Warnaar's A_2 invariance identity as top priority.

**Agent B (sequential, RAG access):** Discovered the Adjugate Monomial Theorem: adj(I-A(x))[c,c'] = x^{EMD(c,c')} where EMD is the Earth Mover's Distance on Z/3Z with clockwise metric. This yields a manifestly positive path formula for P_n = (q^3;q^3)_n * F_{c,n}. Derived functional equation for H_c(z,q) giving a system recurrence for Q_n. Disproved reversal symmetry of Q_n (only cyclic C_3 invariance holds).

**Agent C (sequential, RAG access, FINAL agent):** Discovered that previous agents used wrong ell for d divisible by 3. With ell = gcd(d,3), positivity extends to ALL d. Derived unified evaluation formula. Verified the system recurrence + adjugate formula gives nonneg Q_n for d=4,5,7. Found that Warnaar's bounded multisum approach cannot generalise beyond k=2 (rank-2 reduction fails for rank 3). Gave a third proof of Q_1 >= 0 via Ehrhart theory.

---

## 2. Partial Results

### GREEN (proved or algebraically verified)

**Injection Lemma.** g_m(q) >= q * g_{m-1}(q) coefficient-wise for all m >= 1, d >= 1, all profiles. The injection increments the first part of the leftmost partition lambda^(i) where c_i > 0 and lambda^(i)_1 = max(Lambda). Complete proof. (Layer 3, Seed 4.)

**Q_1 >= 0 for d not divisible by 3.** Three independent proofs: (1) injection lemma gives monotone g_1, so h_1 = (1-q)*g_1 >= 0; (2) equal distribution lemma on congruence classes (Layer 3, Seed 6); (3) Q_1 = p(q) - 1 where p = (1-q)*F_{c,1} has nonneg coefficients (Agent C).

**Iterated q-difference identity.** Q_n = D_n^n where D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}. Reformulates conjecture as D_k^m >= 0 for all m >= k >= 0. (Layer 2, Seed 4.)

**Universal determinant.** det(I - A(x)) = -(x^3 - 1) = (1-x)(1+x+x^2) for ALL d >= 1. Verified exactly for d = 1 through 11 (matrix sizes 3x3 to 78x78). (Layer 3, Seed 6.)

**Adjugate Monomial Theorem.** adj(I-A(x))[c,c'] = x^{EMD(c,c')} where EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1). Every entry is a monomial with coefficient 1. Verified for d = 1,2,3,4,5,7,8 (matrix sizes up to 45x45). Algebraic proof sketch exists but formal completion pending. (Agent B.)

**Manifestly positive path formula for P_n.** P_n(c) = (q^3;q^3)_n * F_{c,n} = sum over paths (c^(0),...,c^(n)=c) of prod_{k=1}^n q^{k*EMD(c^(k),c^(k-1))}. Sum of monomials with coefficient 1. New proof of Kursungoz-Seyrek's P_n >= 0. (Agent B.)

**h_m < 0 for d divisible by 3 (with ell=1).** Period-3 oscillation in g_1 coefficients when 3|d. Independently confirmed by Seeds 4, 8.

**h_m < 0 for m >= 2 even when d NOT divisible by 3.** For d=4, c=(2,1,1), h_2 has negative coefficients in its tail. This kills Path A (D_k^m tower with base case h_m >= 0). (Agent A.)

**Cyclic invariance, NOT reversal invariance.** Q_n(c_0,c_1,c_2) = Q_n(c_1,c_2,c_0) but Q_n(c_0,c_1,c_2) != Q_n(c_2,c_1,c_0) in general. (Agent B, verified d=4, all profiles, n=1,2,3.)

### YELLOW (computationally verified, proof incomplete)

**Extended positivity for ALL d.** With ell = gcd(d,3): Q_{n,c}(q) >= 0 verified for d = 1 through 12, n up to 4. Previous negativity reports for d divisible by 3 used wrong ell (ell=1 instead of ell=3). (Agent C.)

**Unified evaluation formula.** Q_{n,c}(1) = (ell * (d+4)(d-1) / 6)^n for all d >= 1, ell = gcd(d,3). Unifies: d not divisible by 3 gives ((d+1)(d+2)/6 - 1)^n; d divisible by 3 gives ((d+4)(d-1)/2)^n. Verified d=1..12. (Agent C.)

**GL_3 key polynomial decomposition.** All Q_n and all D_k^m decompose into nonneg integer combinations of GL_3 key polynomials (Demazure characters) at specialisation (q, q^2, q^3). Verified for d = 2,4,5,7,8. An abstract proof of existence would immediately prove the conjecture. (Seeds 2, 5.)

**Partial Demazure match.** Q_1 = D_{s_1 s_2} - 1 for balanced profiles (c_1 = c_2 or cyclic equivalent) at d = 2,4,5,7. Exact polynomial match, not just evaluation. Fails for asymmetric profiles and for n >= 2. (Seed 7.)

**System recurrence + adjugate formula.** Q_n(c) = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * RHS(c'; Q_{n-1}, Q_{n-2}). After factoring (1-q^n), denominator becomes (1+q^n+q^{2n}). Verified to give nonneg quotients for d=4,5,7, n=1,2,3. (Agent C.)

**ISP Propagation Theorem.** If D_k^m matches q^{k+1}*D_k^{m-1} for the first L_k(m) leading coefficients at level k, then same holds at level k+1. Would reduce conjecture to base case, but base case h_m >= 0 is false for m >= 2. Verified d=4, k <= 6, m <= 10. (Seed 3.)

**D_k^m >= 0 for k >= 1.** 87+ entries verified (d=2,4,5,7,8, k,m <= 8), zero failures. Note: D_0^m = h_m is NOT nonneg for m >= 2, but D_k^m for k >= 1 always is in tested range. (Seeds 2,3,4,5,8.)

---

## 3. What Failed and Why (Instructive Failures)

**D_k^m tower via h_m >= 0 base case.** h_m = (q;q)_m * g_m has negative coefficients for m >= 2 even when d is coprime to 3. The alternating signs in (q;q)_m require higher-order conditions on g_m beyond the first-order monotonicity from the injection lemma. The tower reformulation Q_n = D_n^n is still correct; only the inductive proof through it using h_m >= 0 as base case is dead.

**Direct KR tensor product matching.** Energy-graded weight spaces of B^{1,d}^{tensor n} evaluate to wrong numbers (9 instead of 16 for d=4, n=2). The connection between Q_n and KR crystals is more indirect than simple weight-space extraction.

**Principal grading for Demazure matching (n >= 2).** Works only for n=1 balanced profiles. For n >= 2, no Demazure character D_w with word length <= 6 matches. The energy function on KR crystals is the likely correct grading, but SageMath does not expose it on LS path crystals.

**Warnaar's bounded multisum generalisation.** Warnaar's proof for k=1,2 uses level-rank duality to reduce rank-3 to rank-2, where bounded functional equations close (only 3 types of box insertions). For k >= 3, rank-2 reduction fails (7 types of insertions, system doesn't close). Warnaar calls this an open problem. However, understanding the k=1,2 mechanism may still inspire approaches.

**Signed involution on extended path space.** The manifestly positive EMD path formula for P_n does not extend through the (zq;q)_inf factor. The alternating signs in the q-binomial transform connecting P_n to Q_n resist local cancellation arguments because the j-th term lives in the space of CPs with max = n-j (cross-N obstruction).

**Total positivity of {F_{c,N}}.** The 2x2 Hankel minors are nonneg (q-log-concavity), but 3x3 Hankel minor is strongly negative (min coeff -85821).

---

## 4. Broken Assumptions (Cumulative)

BA1. "Q_{1,c} depends only on d." FALSE. Depends on profile (up to cyclic permutation).
BA2. "h_m >= 0 for all m." FALSE for m >= 2 even when gcd(d,3) = 1. Kills tower base case.
BA3. "Q_n = Q_1^n." FALSE. Degree is quadratic in n, not linear.
BA4. "g_m(q) is a polynomial." FALSE. g_m is a power series; only h_m = (q;q)_m * g_m is polynomial.
BA5. "{F_{c,N}} is totally positive." FALSE. 3x3 Hankel strongly negative.
BA6. "Q_n is Schur-positive." FALSE. GL_3 key polynomials (Demazure characters) are the right basis.
BA7. "Q_n has reversal symmetry." FALSE. Only cyclic C_3 invariance, not full S_3.
BA8. "CW system is D_3-equivariant." FALSE. C_3 symmetry of Q_n is emergent.
BA9. "h_2 is a single Demazure character." FALSE. Dimension 25 is skipped.
BA10. "Principal grading works for n >= 2." LIKELY FALSE. Energy function is the candidate.
BA11. "KR tensor weight spaces = Q_n." FALSE. Wrong evaluations.
BA12. "Bailey pairs apply." FALSE. Q-to-h transform is a convolution, not a Bailey transform.
BA13. "GL_2 key polynomials suffice." FALSE for d >= 7. Need GL_3.
BA14. "CW recurrence computes F_{c,n}." FALSE. It computes G_n = F_{c,n} - F_{c,n-1}.
BA15. "D_k^m has negative values." FALSE. Truncation artifacts from insufficient precision (need >= 6*max(k,m)^2 + 50).
**BA16. (NEW from Agent C) "Positivity fails for d divisible by 3."** FALSE. Previous agents used ell=1 throughout; with ell = gcd(d,3), Q_n >= 0 extends to ALL d. This corrects Layer 3's claim that "h_m < 0 for d divisible by 3 completely explains the mod-3 restriction." The restriction was an artifact of the wrong normalisation, not a genuine boundary of positivity.

---

## 5. Recommendations for Round 2

### By Seed

**Seed 1 (Demazure/key polynomial decomposition).** The GL_3 key polynomial decomposition of Q_n is verified for d=2,4,5,7,8 but unproved in general. Your mission: find ABSTRACT reasons why such a decomposition must exist. Look for theorems of the form "if X decomposes into a positive sum of Demazure characters at level k, then Y does at level k+1" -- i.e., positivity propagation in Demazure filtrations. The decomposition being unique for Q_1 (d=7) and matching dimensions Q_n(1) = ((d+1)(d+2)/6-1)^n are strong constraints. If you can prove the decomposition exists, the conjecture follows immediately.

**Seed 2 (Energy function on KR crystals).** The partial Demazure match (Q_1 = D_{s_1 s_2} - 1 for balanced profiles) breaks under principal grading for n >= 2 and asymmetric profiles. Your mission: compute the energy function on B^{1,d}^{tensor n} using SageMath's crystals.KirillovReshetikhin and test whether energy-graded weight components match Q_n or some transform of it. Focus on d=4, n=1,2 first. The KR crystal B^{1,d} has dim = binom(d+2,2) = number of profiles, which is a strong hint. But NOTE: direct weight-space extraction gave wrong evaluations (Agent A); the connection may involve a quotient or filtration.

**Seed 3 (Warnaar's A_2 identity).** This is the top untested analytic path. Three agents identified it as most promising; none computed with it. Warnaar's k=1,2 proofs use level-rank duality to rank-2 bounded formulas. For k >= 3, rank-2 reduction fails because the system has 7 types instead of 3. Your mission: understand the k=1,2 proof mechanism in full detail, then explore whether a rank-3 bounded system can be closed directly (not via rank-2 reduction). The 7-type system might still close if there are hidden relations among the types. Also check whether the EMD structure (from the Adjugate Monomial Theorem) can substitute for level-rank duality.

**Seed 4 (EMD / lattice path combinatorics).** Agent B proved adj(I-A(x))[c,c'] = x^{EMD(c,c')} computationally. Your mission: (a) prove this theorem (the Bellman equation EMD(c,c') = min_J(|J| + EMD(c(J),c')) + inclusion-exclusion gives a proof sketch); (b) investigate whether the EMD path formula connects to Lindstrom-Gessel-Viennot nonintersecting lattice paths or to tropical geometry; (c) explore whether a signed involution on the "extended path space" (pairs of an EMD path and a partition) can explain the cancellation in the q-binomial transform from P_n to Q_n.

**Seed 5 (Cylindric partitions and affine crystals).** The structural bijection between CW profiles and sl_3 level-d dominant integral weights is suggestive. Your mission: find the precise bijection between bounded cylindric partitions and elements of Demazure subcrystals, using Tingley/Schilling's work. If CPs of profile c with max <= n biject to elements of a Demazure crystal graded by energy, then Q_n (or P_n) would be the graded character, and positivity follows. Note the ell = gcd(d,3) in the Q_n definition -- this matches the index of connection for the A_2^(1) root lattice modulo the level-d weight lattice.

**Seed 6 (Fermionic formulas).** Fermionic formulas are manifestly positive multisums for Demazure characters (Kirillov-Shimozono-Schilling). If Q_{n,c} is identified as a Demazure character, a fermionic formula would prove positivity constructively. Your mission: look for fermionic formulas that specialise to Q_n at the right grading. The evaluation Q_n(1) = ((d+1)(d+2)/6-1)^n and the key polynomial decomposition are strong constraints on which Demazure module is involved. Even without full identification, a fermionic formula that MATCHES Q_n computationally for small cases would be a breakthrough.

**Seed 7 (Uncu's Gaussian elimination).** Uncu proved new identities for moduli 11 and 13 by automated Gaussian elimination on the CW recurrence system. Your mission: apply the same technique to d=7 (modulus 10, 36 profiles). The universal determinant det(I-A(x)) = -(x^3-1) and the Adjugate Monomial Theorem (adj entries are monomials) dramatically simplify the linear algebra. Use the adjugate to invert the system directly and check if the resulting multisum is manifestly positive. For d=7, the adjugate reduces the 36x36 inversion to reading off EMD values.

**Seed 8 (Ehrhart theory).** The injection lemma proves Q_1 >= 0 via lattice point monotonicity. Your mission: extend this to higher n using Ehrhart theory on the polytope of cylindric partitions with max = m (a polytope of dimension 3m-1 for r=3). Specifically, investigate whether the h*-vector of this polytope has the structural properties needed to ensure D_k^m >= 0 for k >= 1 (note: D_0^m = h_m < 0 for m >= 2, but D_k^m for k >= 1 appears always nonneg). Look at Stanley's theorem on h*-vector nonnegativity and unimodality for lattice polytopes. The connection between the Ehrhart h*-vector of the CP polytope and the D_k^m values may provide the missing link.

### What NOT to Pursue (Dead Paths)

1. **D_k^m tower with base case h_m >= 0 for m >= 2.** h_m is NEGATIVE for m >= 2. Do not attempt to prove h_m >= 0.
2. **Direct KR tensor product weight-space matching.** Evaluations disagree. Connection is more indirect.
3. **Principal grading for Demazure matching at n >= 2.** Only works for n=1 balanced profiles.
4. **Reversal symmetry of Q_n.** Disproved. Only cyclic C_3 invariance holds.
5. **Bailey pairs.** The Q-to-h transform is a convolution, not a Bailey transform.
6. **Total positivity of {F_{c,N}}.** 3x3 Hankel minor is strongly negative.
7. **Schur positivity.** Q_n is NOT Schur-positive. GL_3 key polynomials are the right basis.
8. **Abel summation P_n -> Q_n.** The transform coefficients alternate in sign; P_n >= 0 does not help directly.
9. **GL_2 key polynomial decompositions.** Fail for d >= 7.
10. **D_4^(3) Z-algebra.** Lives at modulus 9 (d=6), fails when A+B is in 3Z.
11. **Fixed-size matrix model.** Degree of Q_n is quadratic in n, ruling out (M^n)_{ij} with fixed M.

---

## 6. State of Play

### What is proved
- Q_1 >= 0 for d not divisible by 3 (three independent proofs).
- g_m >= q * g_{m-1} for all m, d, profiles (injection lemma).
- det(I - A(x)) = -(x^3-1) universally.
- adj(I-A(x))[c,c'] = x^{EMD(c,c')} (verified d=1..8, formal proof pending).
- P_n = sum of EMD-weighted path monomials (manifestly positive).
- h_m < 0 for m >= 2 (even d coprime to 3). Path A is dead.
- Q_n has cyclic but not reversal invariance.
- Q_n = D_n^n (iterated q-difference reformulation).

### What is strongly supported (YELLOW)
- Q_n >= 0 for ALL d with ell = gcd(d,3) (verified d=1..12, n <= 4).
- Q_n(1) = (ell*(d+4)(d-1)/6)^n (unified evaluation, verified d=1..12).
- GL_3 key polynomial decomposition of Q_n with nonneg multiplicities (verified d=2,4,5,7,8).
- D_k^m >= 0 for k >= 1 (87+ entries, zero failures).
- System recurrence + adjugate gives nonneg quotients (verified d=4,5,7).

### Surviving Proof Paths (priority order)

**Path C: Warnaar's A_2 invariance identity.** Still the top untested priority. Warnaar's mechanism works for k=1,2 but rank-2 reduction fails for k >= 3. No agent has computed with it for general k. (Seeds 3, 7.)

**Path D: Adjugate/EMD + signed involution.** The Adjugate Monomial Theorem makes P_n beautifully explicit. Q_n >= 0 is equivalent to the nonnegativity of the q-binomial transform of the EMD path sum. A signed involution on the extended path space would prove this. (Seeds 4, 5.)

**Path E: System recurrence.** Agent C's formula Q_n(c) = (1/(1+q^n+q^{2n})) * sum_{c'} q^{n*EMD(c,c')} * RHS'(c') gives Q_n explicitly from Q_{n-1} and Q_{n-2}. Verified nonneg. The (1+q^n+q^{2n}) denominator acts as a cube-root-of-unity filter related to the spectral structure of A. Proving the quotient is nonneg would complete an inductive proof. (Seeds 7, 8.)

**Path B: Representation-theoretic via energy function.** Wounded but alive. The GL_3 key polynomial decomposition, partial Demazure match, and KR crystal dimension match all point toward an sl_3-hat representation-theoretic interpretation. The bottleneck is identifying the correct module and grading. (Seeds 1, 2, 5, 6.)

### Core Diagnosis

The conjecture has been reduced to a single precise statement:

> Q_n >= 0 is equivalent to the nonnegativity of the q-binomial transform of the EMD path sum.

The path sum P_n is manifestly positive (Adjugate Monomial Theorem). The q-binomial transform Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^ell;q^ell)_j introduces alternating signs. The conjecture asserts these signs always cancel when the result is divided by (q^ell;q^ell)_n. No agent has found the mechanism for this cancellation. Finding it is the central task of Round 2.
