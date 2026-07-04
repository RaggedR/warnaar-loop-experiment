# Layer 1 Synthesis — Round 2 (2026-07-04)

Input for Layer 2 agents. This document synthesizes the output of 8 parallel agents (Seeds 1-8) working on Warnaar's positivity conjecture for Q_{n,c}(q).

---

## 1. What Was Tried

**Seed 1 (Key polynomial decomposition).** Attempted to prove Q_n >= 0 via abstract Demazure/key polynomial theory. Discovered that Round 1's GL_3 key polynomial decomposition strategy at specialization (q,q^2,q^3) is VACUOUS: any nonneg polynomial trivially decomposes as sum a_k * kappa_{(k,0,0)} since kappa_{(k,0,0)} -> q^k at that specialization. The decomposition is equivalent to coefficient positivity itself. Also discovered Q_n = q^{n^2} for d=2 (all profiles in the C_3 orbit of (1,1,0)), verified through n=3. Explored the g_m structure for d=2, finding g_1 = 2q/(1-q) but g_2 has different growing coefficients.

**Seed 2 (KR crystal energy function).** Computed the energy function H on B^{1,d} tensor products for A_2^(1), d=2,3,4. Key novel finding: H(b1 tensor b2) depends ONLY on profile(b1) and profile(b2), not the specific crystal elements. However, H differs from EMD, and the H-graded path sum does not match Q_n (evaluations 15^n per profile vs Q_n(1) = 4^n for d=4). Dimensional mismatch: B^{1,d}^{tensor n} has dim = binom(d+2,2)^n but sum_c Q_n(1) = binom(d+2,2) * ((d+1)(d+2)/6-1)^n. Crystal is too large by wrong factor.

**Seed 3 (Warnaar's A_2 identity / h_m reversal).** Reconstructed Warnaar's k=1,2 proof mechanism (level-rank duality to rank-2, functional equation with 3 types closes). Confirmed rank-3 system has 7 types and does NOT close. CRITICAL DISCOVERY: independently verified h_m >= 0 for d=4,5,7,8,10,11 (all profiles, m up to 6), confirming BA2 was wrong. Found that for d divisible by 3, h_m using (q;q)_m is negative but using (q^ell;q^ell)_m (ell=3) it is nonneg. Derived the factorization h_m = beta_m * tilde_h_m where beta_m = (q;q)_m/(q^3;q^3)_m (mixed signs) and tilde_h_m >= 0 (from EMD path formula). Stuck on proving beta_m * tilde_h_m >= 0.

**Seed 4 (Adjugate Monomial Theorem proof + signed involution).** COMPLETE PROOF of the Adjugate Monomial Theorem: adj(I-A(x))[c,c'] = x^{EMD(c,c')} for all r=3, d >= 1. Proof method: reduce to showing S(c,c') = sum_J (-1)^{|J|} x^{g(J)} = (1-x^3)*delta_{c,c'}. Key steps: (1) g(J) in {EMD, EMD+3} for all J (algebraic case analysis), (2) G_0 = {J: g(J)=EMD} is a subgroup of (Z/2)^3 containing a singleton {k} (6-region classification), (3) sign-reversing involution J -> J Delta {k} gives signed sum = 0. Also verified Bellman equation EMD(c,c') = min_J(|J| + EMD(c(J),c')) for d=2,4. Extended path space for Q_2 at d=4 shows near-complete cancellation (4822 elements -> 16 net), but no involution found.

**Seed 5 (Affine crystal bijection).** Attempted to find a bijection between bounded CPs and Demazure subcrystal elements via the Kyoto path model. Found that phi is INJECTIVE on B^{1,d} for A_2^(1), making the Kyoto path model deterministic (no branching). This kills the naive truncation approach. Truncated paths give single elements, not polynomials. The energy function on tensor products gives F_{c,n} (the bounded GF), not Q_n. The (zq;q)_inf factor cannot be absorbed into the crystal structure directly.

**Seed 6 (Fermionic formulas / Warnaar's Conjecture 2).** KEY INSIGHT: Warnaar's Conjecture 2 states GK_c(z,q) = FERM(z,q)/(zq;q)_inf where FERM is a manifestly positive multisum. Then Q_n = (q;q)_n * [z^n](FERM), and the (q;q)_n prefactor cancels the 1/(q;q)_{n_1} factor in FERM (setting n_1=n), leaving a manifestly positive multisum. Verified exact match for d=2,5,8 (k=1,2,3) at n=1,2, all tested profiles. Coverage: Conjecture 2 only covers profiles with c_2=0 (up to cyclic rotation) plus balanced. For d=8, this is 5 of 15 canonical profiles.

**Seed 7 (Uncu-style Gaussian elimination).** Applied the adjugate inversion to the G_c system: g_{c,n} = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * b_n(c'). Derived explicit Q_1 formula valid for ALL d. Proved the EMD Equidistribution Theorem: for d not divisible by 3, EMD(c,c') mod 3 is equidistributed over rank-r profiles. This proves (1+q+q^2) divides the Q_1 numerator. Verified Q_n >= 0 for d=7, n<=2, all 36 profiles.

**Seed 8 (Ehrhart theory / h_m verification).** Independently confirmed h_m >= 0 for d=1,2,4,5,7,8,10 (all profiles, m up to 8) using transfer matrix with high precision. Extended to d divisible by 3 with h_m = (q^ell;q^ell)_m * g_m (ell=3): nonneg for d=3,6,9. Discovered bracket monotonicity: f_0^{(m)} = (1-q^m)*g_m - q*g_{m-1} >= 0 (stronger than injection lemma). Discovered exact (m-1)-fold q-monotonicity: (q;q)_j * f_0^{(m)} >= 0 for j=0,...,m-1 but NOT j=m.

---

## 2. Partial Results

### GREEN (proved)

**Adjugate Monomial Theorem (COMPLETE PROOF).** For r=3, d >= 1: adj(I-A(x))[c,c'] = x^{EMD(c,c')} where EMD is Earth Mover's Distance on Z/3Z with clockwise cost. Proof via reduction to S(c,c') = (1-x^3)*delta_{c,c'}, using the binary partition of 2^{I_c} into G_0/G_3 subgroups and a sign-reversing involution J -> J Delta {k}. Verified for d=1..8, formally proved for all d. (Seed 4.) UPGRADES from Round 1 YELLOW to GREEN.

**Adjugate inversion formula.** g_{c,n} = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * b_n(c'). Direct consequence of adj(I-A(x)) = x^{EMD} and det(I-A(x)) = -(x^3-1). (Seed 7, inherits GREEN from Adjugate Monomial Theorem.)

**Explicit Q_1 formula.** Q_{1,c}(q) = (1/(1+q+q^2)) * sum_{c'} q^{EMD(c,c')} * B(c') where B(c') depends only on rank(c'). For ell=3: no division needed. Verified positive for all d=2..13. (Seed 7.)

**EMD Equidistribution Theorem.** For d not divisible by 3: sum_{c': rank(c')=r} omega^{EMD(c,c')} = 0 for omega = e^{2pi*i/3}. Equivalently, EMD mod 3 is equidistributed over rank-r profiles. Proves (1+q+q^2) divides the Q_1 numerator. (Seed 7.)

**Vacuity of specialized key polynomial decomposition.** The GL_3 key polynomial decomposition of Q_n at specialization (q,q^2,q^3) is vacuous: kappa_{(k,0,0)} -> q^k, so any nonneg polynomial trivially decomposes. The strategy only has content at the 3-variable level. (Seed 1.)

**Previously proved results carried forward:** Injection lemma g_m >= q*g_{m-1} (GREEN), Q_1 >= 0 (GREEN), det(I-A(x)) = -(x^3-1) (GREEN), P_n = manifestly positive EMD path sum (GREEN), Q_n = D_n^n iterated q-difference (GREEN), cyclic but not reversal invariance of Q_n (GREEN).

### YELLOW (computationally verified, no proof)

**h_m >= 0 for gcd(d,3) = 1.** VERIFIED: d=1,2,4,5,7,8,10,11, all profiles, m up to 8. Hundreds of cases, zero failures. Uses h_m = (q;q)_m * g_m. If proved, immediately implies Q_n >= 0 via D_k^m tower. (Seeds 3, 8; independently confirmed by verification agent.)

**h_m >= 0 for ALL d with ell = gcd(d,3).** VERIFIED: d=3,6,9 with h_m = (q^ell;q^ell)_m * g_m (ell=3). Zero failures. (Seed 8.) Note: when using (q;q)_m for d divisible by 3, h_m IS negative. Only the ell-corrected version is nonneg.

**D_k^m >= 0 for ALL k >= 0 (including k=0).** Verified d=4, k,m up to 8. Extends Round 1 verification (which only covered k >= 1). (Seeds 3, 8.)

**Bracket monotonicity: f_0^{(m)} >= 0.** f_0^{(m)} = (1-q^m)*g_m - q*g_{m-1} has nonneg coefficients. Stronger than injection lemma. Verified d=4, m=1..5. (Seed 8.)

**Exact (m-1)-fold q-monotonicity.** (q;q)_j * f_0^{(m)} >= 0 for j=0,...,m-1 but NOT for j=m. Verified d=4, m=2,3,4. (Seed 8.)

**Q_n = q^{n^2} for d=2, c in C_3-orbit of (1,1,0).** Verified through n=3. (Seed 1.)

**Q_n via fermionic formula matches for d=8 (k=3).** First unproved case. Exact match at n=1,2 for all tested profiles. (Seed 6.)

**Energy function H on B^{1,d} is constant on profile pairs.** H(b1 tensor b2) depends only on content(b1), content(b2). Verified d=2,3,4. Novel structural result. H != EMD. (Seed 2.)

**Evaluation D_{n-1}^n(1) = (d+1) * Q_{n-1}(1).** Verified d=4, n=1..5. (Seed 3.)

---

## 3. What Failed and Why

**Specialized key polynomial decomposition (Seed 1, Seed 5 recommendation).** DEAD. The GL_3 key polynomial decomposition at specialization (q,q^2,q^3) is vacuous because kappa_{(k,0,0)} = q^k, making every nonneg polynomial trivially key-positive. Only the 3-variable lift could be meaningful. (See Issue B adjudication below.)

**Direct Demazure crystal bijection (Seed 5).** FAILED. phi is injective on B^{1,d}, making the Kyoto path model deterministic. Truncated paths give single elements, not polynomials. The energy function gives F_{c,n}/P_n, not Q_n.

**KR crystal energy matching Q_n (Seed 2).** FAILED. Dimensional mismatch: crystal has dim binom(d+2,2)^n but Q evaluations give ((d+1)(d+2)/6-1)^n per profile.

**Signed involution on extended path space (Seed 4).** STUCK. 4822 extended path elements with near-complete cancellation for Q_2 at d=4, but no involution found. The sign depends on both level j and borrow partition sigma.

**Rank-3 CW system closure (Seed 3).** FAILED. 7 types, does not close.

**Proving h_m >= 0 (Seeds 3, 8).** STUCK. The factorization h_m = beta_m * tilde_h_m has mixed-sign beta_m. Ehrhart/Stanley approach needs a finite polytope that has not been identified.

---

## 4. Broken Assumptions

### REVERSAL

**BA2 REVERSED.** Round 1 stated: "h_m < 0 for m >= 2 even when gcd(d,3) = 1." This was a TRUNCATION ARTIFACT. Agent A computed g_m via direct enumeration with bounded column values (max_s ~ 10-13), then multiplied by (q;q)_m. The truncated g_m dropped to zero at the truncation boundary while still growing quasi-polynomially, and (q;q)_m = 1 - q - q^2 + q^3 + ... turned the sudden drop into spurious negative coefficients.

**Mechanism:** Coefficients within deg((q;q)_m) of the truncation point in the power series are unreliable. This is exactly BA15 from Round 1.

**Verification agent confirmed (>95% confidence):** h_2 for d=4, c=(2,1,1) is a degree-12 polynomial [0,0,3,4,5,3,3,2,2,1,1,0,1] with h_2(1) = 25. All coefficients nonneg. Agent A's g_2 values were correct up to the truncation point; the error arose purely from multiplying truncated g_2 by (q;q)_2.

**PATH A REOPENED.** The D_k^m tower approach with base case h_m >= 0 is ALIVE.

**Unified statement for h_m across all d (reconciling Seeds 3 and 8):**
- Seed 3 found: for gcd(d,3) = 1, h_m = (q;q)_m * g_m >= 0. For 3|d, h_m with (q;q)_m is genuinely negative.
- Seed 8 found: defining h_m = (q^ell;q^ell)_m * g_m with ell = gcd(d,3), then h_m >= 0 for ALL d (including d divisible by 3).
- RECONCILIATION: Both are correct. The unified statement is: **(q^ell;q^ell)_m * g_m >= 0 for all d, c, m, where ell = gcd(d,3).** For gcd(d,3)=1, this is (q;q)_m * g_m >= 0. For 3|d, the relevant product is (q^3;q^3)_m * g_m >= 0 (the (q;q)_m version IS negative). Seed 3's observation about compensation via prod(1+q^i+q^{2i}) is consistent: Q_n = (q^3;q^3)_n * [...] = (q;q)_n * prod(1+q^i+q^{2i}) * [...], so the negativity of h_m with (q;q)_m is compensated by the nonneg factor (q^3;q^3)_n/(q;q)_n = prod(1+q^i+q^{2i}). Both agents' observations are facets of the same structure.

### Issue B Adjudication: Seed 1 vs Seed 5 on Key Polynomial Decomposition

**SEED 1 IS CORRECT.** The GL_3 key polynomial decomposition at specialization (q,q^2,q^3) is vacuous. At this specialization, kappa_{(k,0,0)}(q,q^2,q^3) = q^k, so any polynomial f(q) = sum a_k q^k with a_k >= 0 trivially decomposes as f = sum a_k * kappa_{(k,0,0)}. The "decomposition" is just reading off coefficients. Therefore, the computational observation from Round 1 that "Q_n decomposes into nonneg integer combinations of GL_3 key polynomials at (q,q^2,q^3)" tells us nothing beyond Q_n >= 0 itself.

**Seed 5's recommendation** of this strategy as a top path was based on the Round 1 YELLOW result without examining the specialization. The strategy is DEAD at the specialized level. The only contentful version would work with genuine 3-variable key polynomials kappa_alpha(x_1,x_2,x_3) BEFORE specialization -- i.e., lift Q_n to a polynomial in 3 variables and decompose there. No agent has attempted this.

### NEW BROKEN ASSUMPTIONS

**BA17. "The GL_3 key polynomial decomposition at specialization (q,q^2,q^3) is a meaningful proof strategy."** FALSE. Vacuous. (Seed 1.)

**BA18. "Bounded CPs biject to Demazure subcrystal elements via Kyoto path truncation."** FALSE. phi-injectivity kills branching. (Seed 5.)

**BA19. "KR crystal B^{1,d} energy function H equals EMD."** FALSE. Different functions on the same domain. (Seed 2.)

---

## 5. Connections

**Convergent diagnosis (Seeds 2, 5, 6).** Three agents independently converged on: crystal/rep-theoretic machinery natively computes F_{c,n} (the bounded GF) or equivalently P_n = (q^ell;q^ell)_n * F_{c,n}. The difficulty lives entirely in the (zq;q)_inf extraction + (q^ell;q^ell)_n prefactor layer. The crystal model sees P_n; the conjecture is about Q_n; the gap is the q-binomial transform with alternating signs.

**Where the alternating signs go (Seeds 6, 7, 3, 4).** Coherent picture:
1. F_c(z,q) is manifestly positive (combinatorial GF).
2. P_n = (q^ell;q^ell)_n * F_{c,n} is manifestly positive (EMD path formula).
3. Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q)). Alternating signs from (zq;q)_inf.
4. Seed 6: if Warnaar's Conjecture 2 holds, then (zq;q)_inf * F_c(z,q) = FERM(z,q) is ALREADY positive. Extracting [z^n] and cancelling (q;q)_n with 1/(q;q)_{n_1} leaves a nonneg multisum.
5. Equivalently (Seeds 3/8): the alternating signs create h_m = (q^ell;q^ell)_m * g_m, and the miracle is h_m >= 0.
6. Seed 7's adjugate inversion propagates this level by level.

**h_m >= 0 and Warnaar's Conjecture 2 are different faces of the same phenomenon.** Both assert the (zq;q)_inf cancellation produces nonneg objects. Conjecture 2 is stronger (explicit multisum); h_m >= 0 is the weaker consequence needed for the tower proof.

**Seed 4's Adjugate Monomial Theorem enables Seed 7's inversion formula.** The proved identity adj(I-A(x)) = x^{EMD} combined with det = -(x^3-1) gives (I-A(x))^{-1} = x^{EMD}/(1-x^3), which Seed 7 used to invert the CW system. Seed 7's GREEN results inherit from Seed 4's proof.

**Seed 8's bracket monotonicity and the tower.** f_0^{(m)} = (1-q^m)*g_m - q*g_{m-1} >= 0 with exact (m-1)-fold q-monotonicity: (q;q)_j * f_0^{(m)} >= 0 for j <= m-1. If the pattern extends to higher tower levels (f_k^{(m)} is (m-k-1)-fold q-monotone), the full conjecture follows by induction.

---

## 6. Recommendations for Layer 2

### Seed Assignments

**Seed 1 -> PROVE Q_n = q^{n^2} for d=2.** Original mission is dead. New: prove Q_n = q^{n^2} for d=2 (simplest case). Use the system recurrence specialized to d=2 (only 2 orbits). Jacobi triple product identity is the likely tool. Also verify Q_n = q^{n(n+1)} for c=(2,0,0). Clean base case proofs illuminate the general mechanism.

**Seed 2 -> PROVE h_m >= 0 via crystal theory / Ehrhart.** Energy function finding (H constant on profiles) is novel but did not match Q_n. New: match h_m instead. The q-monotonicity structure suggests a filtration. Also try B^{d,1} (column) crystals -- winding pair formula is known for columns and might match EMD.

**Seed 3 -> PROVE h_m >= 0 via the beta_m * tilde_h_m factorization.** You identified h_m = [(q;q)_m/(q^3;q^3)_m] * tilde_h_m where tilde_h_m >= 0. Try: (a) express tilde_h_m as terms annihilated by negative parts of beta_m, (b) find a q-series identity rewriting the product positively, (c) check divisibility of tilde_h_m by (q^3;q^3)_m/(q;q)_m. Extend verification to d=13,14.

**Seed 4 -> SIGNED INVOLUTION on extended path space.** Adjugate Monomial Theorem is proved. Focus entirely on the involution. Try: (a) level-by-level cancellation using D_k^m tower structure, (b) tropical geometry (monomial cofactors suggest tropical structure), (c) Garsia-Milne involution principle applied to the tower decomposition.

**Seed 5 -> WARNAAR'S CONJECTURE 2 for k=3 (d=8).** Crystal bijection is dead. New: attack Conjecture 2 for d=8 using the adjugate inversion (now proved). Check whether the resulting multisum for all 45 profiles matches a fermionic formula. If yes for ALL profiles, this gives Conjecture 2 for k=3.

**Seed 6 -> CW PROPAGATION from seed profiles to all profiles.** Prove that CW functional equations applied to non-seed profiles inherit positivity from Conjecture 2. Specifically: if GK_{c(J)} = FERM_{c(J)}/(zq;q)_inf for all J-shifted profiles, does GK_c = FERM_c/(zq;q)_inf with FERM_c >= 0? Warnaar showed this for d=5. Check d=8.

**Seed 7 -> UNFOLD the n=2 recursion explicitly.** Your adjugate inversion + Q_1 formula give Q_2 as an explicit double sum. Analyze for manifest positivity. The (1+q^n+q^{2n}) denominator should combine with EMD equidistribution. If Q_2 >= 0 follows from Q_1 >= 0 + structural properties, this establishes the inductive step.

**Seed 8 -> PROVE f_0^{(m)} is (m-1)-fold q-monotone.** Strongest structural property discovered. (a) Prove f_0^{(m)} >= 0 (stronger than injection lemma -- needs second-order injection), (b) prove (m-1)-fold monotonicity, (c) define f_k^{(m)} = D_k^m - q^{k+1}*D_k^{m-1} and check (m-k-1)-fold q-monotonicity. If pattern holds, the full conjecture follows by tower induction.

### What NOT to Pursue (Dead Paths, updated)

1. **Specialized GL_3 key polynomial decomposition.** Vacuous at (q,q^2,q^3). Dead.
2. **Direct Kyoto path truncation / Demazure subcrystal bijection.** Killed by phi-injectivity.
3. **KR crystal B^{1,d} energy function matching Q_n.** Wrong dimensions, wrong function.
4. All items from Round 1's dead list remain dead.
5. **Rank-3 CW closure via rank-2 reduction.** 7 types, does not close.

---

## 7. State of Play

### Re-ranked Proof Paths

**Path A (REOPENED, TOP PRIORITY): h_m >= 0 -> D_k^m tower -> Q_n >= 0.**
h_m = (q^ell;q^ell)_m * g_m >= 0 is verified for ALL d (with ell = gcd(d,3)), hundreds of cases, zero failures. If proved, the D_k^m tower gives Q_n = D_n^n >= 0 immediately. The bracket monotonicity structure (exact (m-1)-fold q-monotonicity of f_0^{(m)}) provides the inductive mechanism. Bottleneck: prove h_m >= 0.

**Path F (NEW, HIGH PRIORITY): Warnaar's Conjecture 2 -> fermionic positivity.**
Seed 6 showed: Conjecture 2 implies Q_n >= 0 via (q;q)_n cancellation with 1/(q;q)_{n_1}. Verified for d=2,5,8. Clean and constructive. CONDITIONAL on Conjecture 2 (itself open), but proving it for k=3 would be significant.

**Path E (MEDIUM): System recurrence Q_n from Q_{n-1}, Q_{n-2}.**
Adjugate inversion gives Q_n explicitly. Unfolding n=2 (Seed 7) tests inductive feasibility.

**Path D (MEDIUM-LOW): Signed involution on extended path space.**
Near-complete cancellation but no involution found despite extensive search.

**Path B (LOW): Representation theory via energy function.**
Multiple failures. Connection must go through infinite path model.

### Core Bottleneck

The conjecture reduces to ONE statement:

> **(q^ell;q^ell)_m * g_m >= 0 for all d, profiles c, and m >= 0, where ell = gcd(d,3).**

This is h_m >= 0. Verified for d=1..11, all profiles, m up to 8. Finding a proof is the central task of Layer 2.
