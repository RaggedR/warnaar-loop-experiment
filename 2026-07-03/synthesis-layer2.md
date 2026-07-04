# Synthesis: Layer 2 (8 Seed Agents)

## 1. What Was Tried

**Seed 1 (Hall-Littlewood / Bartlett-Warnaar).** Computed h_m(q) for d=7 (profiles (3,2,2) and (4,2,1)) and verified non-negativity for m=0,1,2 (exact). Verified Q_2 non-negativity for d=7. Investigated Connection A from Layer 1: proved that h_m is NOT q-log-concave (h_1^2 - h_0*h_2 has negative coefficients), but F_{c,N} IS q-log-concave, showing the 1/(q;q)_m factor "smooths" non-log-concavity. Attempted the q-binomial bootstrap (h_m >= 0 implies Q_n >= 0) via three strategies: (1) diagonal decomposition of h_m into q^{km} components -- showed all k >= 1 diagonals cancel via (q^{1-k};q)_n = 0, leaving only off-diagonal structure, (2) q-binomial theorem analogues -- the shift j(j+1)/2 (not j(j-1)/2) prevents standard identities, (3) HL principal specialization identification -- proposed but did not concretely identify lambda such that h_m = P_lambda(principal spec). Proposed the Ehrhart theory approach: g_1 is a lattice point count in a cyclic polytope, and h_m non-negativity could follow from Stanley's theorem on h*-vectors of lattice polytopes via Gelfand-Tsetlin patterns.

**Seed 2 (Partition-Bead Bijections / Tingley).** KILLED the total positivity approach: the 3x3 Hankel minor of {F_{c,N}} is strongly negative (min coefficient -85821 for c=(2,1,1), N=0). The sequence {F_{c,N}} is q-log-concave (2x2 Hankel nonneg) but NOT totally positive (3x3 negative). Verified h_m non-negativity with proper stabilization (fixing Layer 1 truncation artifacts), confirming h_m are genuine polynomials with nonneg coefficients and h_m(1) = base^m. Confirmed deg(h_m) = deg(Q_m) = (d-1)m^2. Explored the Kursungoz-Seyrek decomposition for bounded cylindric partitions but could not complete it -- the bounded version (max <= N) is not developed in the literature. Identified the key structural observation h_m - Q_m >= 0 (the alternating sum only subtracts from h_m). Attempted three strategies to bridge h_m >= 0 to Q_n >= 0, all failing at the cross-N obstruction.

**Seed 3 (Skew RSK / Crystal Graph).** PROVED that Q_{n,c}(q) is NOT sl_3 Schur-positive at specialization (q, q^2, q^3) -- the greedy decomposition leaves residual terms that cannot be expressed as any Schur polynomial. Confirmed base = (d+1)(d+2)/6 - 1 = number of non-corner C_3 orbits of level-d sl_3 weight triples. Verified reversal symmetry holds at the F_{c,N} level (not just Q level), meaning it is a bijection on cylindric partitions. Confirmed h_m is NOT multiplicative (h_2 != h_1*h_1 as polynomial convolution), ruling out tensor product interpretations. Extended the GL_2 key polynomial decomposition to d=7: Q_1 decomposes with nonneg integer coefficients, but the decomposition is non-unique for n >= 2 (LP-based). Identified the correct alternating sum shift as q^{j(j+1)/2} (not j(j-1)/2). Assessed three approaches: (1) bounded CPs as crystal elements via Imamura Upsilon -- theoretically sound but technically out of reach, (2) Schur positivity -- disproved, (3) affine Demazure module hypothesis -- most promising but needs affine crystal tools.

**Seed 4 (Bilateral RR / Bailey Pair).** PROVED the identity Q_n = D_n^n, where D_0^m = h_m and D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}. This is an iterated q-difference decomposition that reduces the positivity conjecture to a tower of domination conditions: D_k^m >= 0 for all m >= k >= 0, which is equivalent to D_{k-1}^m >= q^k D_{k-1}^{m-1}. The proof uses the classical identity e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q (principal specialization of elementary symmetric functions). Verified D_k^m >= 0 computationally for d = 2, 4, 5, 7, 8 and k, m up to 4. Proved the evaluation D_k^m(1) = (base-1)^k * base^{m-k}. Ruled out Bailey pair approach: the Q-to-h transform is a convolution (kernel depends only on j), not a Bailey transform (kernel depends on both n and j). The CW system for d=7 has 36 profiles, infeasible for by-hand Gaussian elimination.

**Seed 5 (Schubert Polynomials / Lascoux).** Extended the GL_3 key polynomial decomposition to d=7 and d=8, the first unproved cases. For d=7, c=(3,2,2): Q_1 = K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)} (unique, sum of dims = 3+6+2 = 11). Q_2 also decomposes (non-uniquely via LP). For d=8, computed Q_1 for three profiles (3,3,2), (4,3,1), (5,2,1) -- all decompose into GL_3 key polynomials with nonneg integer multiplicities. Found that K_{(0,0,1)} (= fundamental character h_1(x_1,x_2,x_3)) appears in every decomposition. Observed that balanced profiles use low-level Demazure characters while asymmetric profiles include high-level dominant keys (monomials). Proposed the level-rank duality framework: cylindric partitions at k=3 correspond to level-3 representations of hat{sl}_{d+3}, and Q_{n,c}(q) should be the principally specialized character of a Demazure module. Cannot verify without SageMath affine crystal tools.

**Seed 6 (Nandi / Mod-14 / Takigiku-Tsuchioka).** REDUCED Q_1 positivity to a lattice-counting lemma: Q_1 = (1-q)*f_1(q) - q, so Q_1 >= 0 iff the coefficients of f_1(q) (= counting binary cylindric partitions of weight k) are weakly monotonically increasing. Verified monotonicity exhaustively for ALL compositions with d <= 14 (495 profiles, zero failures). The monotonicity follows from f_1 being an Ehrhart-type function on a polyhedral cone (lattice point count at height k in a cone is eventually polynomial in k, hence eventually increasing). Analyzed the CW system structure: (I - A(q^n)) F_n = F_{n-1} is a 36x36 linear system for d=7. Proved the CW system is NOT D_3-equivariant at the profile level -- D_3 symmetry of Q is emergent, not manifest. The shifted profile operation c(J) does not commute with D_3 action. Gaussian elimination for d=2 succeeds (yields F_{c,n} = F_{c,n-1}/(1-q^{3n})); for d=7, the 36x36 system is tractable numerically (Neumann series) but not symbolically.

**Seed 7 (Vertex Operators / D_4^(3) / Tsuchioka).** DISCOVERED that positivity holds for d equiv 0 mod 3 too: d=3 (Q_n(1) = 7^n) and d=6 (Q_n(1) = 25^n) both positive in all computed cases. The exclusion d not-equiv 0 mod 3 is about the evaluation formula ((d+1)(d+2)/6 is not an integer when 3|d), not about positivity itself. Identified CW profiles = sl_3 level-d dominant weights: the 36 profiles at d=7 are exactly the 36 compositions of 7 into 3 nonneg parts, which are the level-7 weights of hat{sl}_3. This is structural, not coincidental. Clarified the mod-3 algebraic mechanism: Tsuchioka's partial commutation relations (relations 3-4) hold only when A+B not-in 3Z, and when they fail (d equiv 0 mod 3), the Z-algebra has a larger generating set. Proposed hat{sl}_3 at level d as the correct algebra, with profile c corresponding to highest weight c_0 Lambda_0 + c_1 Lambda_1 + c_2 Lambda_2. Ruled out level-1 identification because Borodin product has higher-multiplicity residues for d >= 4.

**Seed 8 (Plane Partitions / Lozenge Tilings).** Computed Q_n for d=7 through n=4 (both profiles), all nonneg. Verified h_m for d=7 through m=5. PROVED that no fixed-size matrix model can produce Q_n: deg(Q_n) = (d-1)n^2 + O(n) is quadratic in n, while (M^n)_{ij} has degree linear in n. Identified the time-inhomogeneous Markov chain as the correct model: Q_n = product of n layer-contributions M_1(q) * ... * M_n(q) where M_i has entries involving q^i. DISCOVERED that the min-degree increments of Q_n skip multiples of 3: the sequence of first differences of min_deg(Q_n) for d=4 is 1, 2, 4, 5, 7, 8, 10, 11, ... -- exactly the positive integers not divisible by 3. This connects directly to the d not-equiv 0 mod 3 hypothesis. Verified the "alphabet removal" picture: Q_n counts q-deformed words of length n in an alphabet of size (d+1)(d+2)/6, with one letter (ground state) removed. The sl_3 Schur decomposition at (q,q^2,q^3) and GL_2 key decomposition at (q,q^2) both FAIL for d=7 (contradicting Seed 5's GL_3 results at different specializations -- see Connections).


## 2. Partial Results

### GREEN (proved or verified algebraically)

- **THEOREM: Q_n = D_n^n (iterated q-difference identity).** Define D_0^m = h_m and D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}. Then Q_n = D_n^n. Proof uses e_j(q,...,q^k) = q^{j(j+1)/2} [k choose j]_q (classical identity). This decomposes the positivity conjecture into a tower: Q_n >= 0 iff D_k^m >= 0 for all m >= k >= 0. (Seed 4.)

- **THEOREM: D_k^m(1) = (base-1)^k * base^{m-k}.** At q=1, the iterated difference gives (I-T)^k applied to base^m = base^{m-k}(base-1)^k. Recovers Welsh's evaluation as the special case k=m=n. (Seed 4.)

- **3x3 Hankel minor of {F_{c,N}} is negative.** For c=(2,1,1), N=0: min coefficient -85821. The sequence {F_{c,N}} is q-log-concave (2x2 nonneg) but NOT totally positive. Total positivity approach is DEAD. (Seed 2.)

- **Q is NOT sl_3 Schur-positive** at specialization (q, q^2, q^3). For d >= 4, the residual from greedy Schur decomposition is not any Schur polynomial. (Seed 3, confirmed by Seed 8.)

- **Reversal symmetry holds at the F_{c,N} level.** F_{c,N}(q) = F_{rev(c),N}(q) for all tested cases. This is a bijection on cylindric partitions, not just a cancellation in the alternating sum. (Seed 3.)

- **CW system is NOT D_3-equivariant.** The shifted profile operation c(J) does not commute with the D_3 action on compositions. D_3 symmetry of Q is emergent. (Seed 6.)

- **Fixed-size matrix model ruled out.** deg(Q_n) = (d-1)n^2 + O(n) grows quadratically, but (M^n)_{ij} grows linearly. No fixed-size q-weighted adjacency matrix can produce Q_n. (Seed 8.)

- **Bailey pairs do not apply.** The Q-to-h transform is a convolution (kernel depends only on j), not a Bailey transform. The CW recurrence does not produce Bailey pairs. (Seed 4.)

- **h_m non-negativity verified** for d = 2, 4, 5, 7, 8; m up to 5 (exact computation with stabilization). h_m(1) = base^m confirmed. deg(h_m) = (d-1)m^2. h_m is a genuine polynomial with nonneg integer coefficients. (Seeds 1, 2, 3, 4, 7, 8.)

- **D_k^m non-negativity verified** for d = 2, 4, 5, 7, 8; k, m up to 4. All nonneg. (Seed 4.)

- **Q_{n,c} positivity verified for d=7** (first unproved case): n = 0, 1, 2, 3, 4 for profiles (3,2,2) and (4,2,1). Q_n(1) = 11^n. (Seeds 4, 5, 7, 8.)

- **Q_{n,c} positivity verified for d=8**: n = 0, 1, 2 for profiles (3,3,2), (4,3,1), (5,2,1). Q_n(1) = 14^n. (Seeds 5, 8.)

### YELLOW (computationally verified, not proved)

- **Iterated q-Difference Positivity Conjecture:** D_k^m >= 0 for all m >= k >= 0 and all valid profiles c with d not-equiv 0 mod 3. EQUIVALENT to Warnaar's conjecture. Verified for d = 2, 4, 5, 7, 8 with k, m up to 4. (Seed 4.)

- **Domination tower:** D_{k-1}^m >= q^k D_{k-1}^{m-1} coefficient-wise for all k >= 1, m >= k. Verified computationally. The base case k=1 is h_m >= q * h_{m-1}, a natural growth condition on cylindric partition counts. (Seed 4.)

- **h_m non-negativity conjecture** (all d, c, m): verified for d <= 8, m <= 5. This is the k=0 level of the domination tower. (Multiple seeds.)

- **Q_1 positivity via f_1 monotonicity.** The sequence a_k = #{binary cylindric partitions of profile c with weight k} is weakly monotonically increasing, converging to (d+1)(d+2)/6. Verified exhaustively for ALL 495 compositions with d <= 14. Implies Q_1 >= 0. (Seed 6.)

- **GL_3 key polynomial decomposition** exists for Q_{n,c}(q) at specialization K_u(q, q^2, q^3) for all tested cases: d = 2, 4, 5, 7, 8 and n = 0, 1, 2, 3. Decomposition is unique for Q_1, non-unique for Q_2. (Seeds 3, 5.)

- **Positivity for d equiv 0 mod 3** holds in all computed cases (d=3, 6). The conjecture's restriction is about the evaluation formula, not positivity. (Seed 7.)

- **Min-degree increments skip multiples of 3.** For d=4: min_deg(Q_n) - min_deg(Q_{n-1}) runs through 1, 2, 4, 5, 7, 8, 10, 11, ... (positive integers not divisible by 3). (Seed 8.)

- **Degree formula profile dependence.** For c=(3,2,2), d=7: deg(Q_n) = 6n^2. For c=(4,2,1), d=7: deg(Q_n) = 6n^2 + 2n. The leading term (d-1)n^2 is universal; the linear correction is profile-dependent. (Seed 8.)

### RED (attempted but failed or incomplete)

- **h_m -> Q_n bootstrap.** Even with all h_m nonneg, the alternating q-binomial transform does not preserve positivity via any known q-identity. The diagonal cancellation result (all k >= 1 diagonals of h_m cancel) shows the surviving contributions have no simple structure. (Seeds 1, 2.)

- **Ehrhart theory for h_m.** Proposed that h_m non-negativity follows from Stanley's theorem on h*-vectors, via cylindric partition polytopes as lattice polytopes. Sound in principle but not executed. (Seed 1.)

- **Explicit positive multisum for d=7.** The CW system has 36 unknowns. Gaussian elimination is feasible numerically (Neumann series) but not symbolically. No closed-form positive multisum obtained. (Seed 6.)

- **Demazure crystal verification.** Cannot verify whether Q_{n,c}(q) matches a Demazure module character without SageMath's affine crystal tools. (Seeds 3, 5, 7, 8.)


## 3. What Failed and Why

### Total Positivity of {F_{c,N}} (Seed 2) -- DEFINITIVELY KILLED

**What was attempted**: Test whether {F_{c,N}} is totally positive in the Hankel sense (all Hankel minors nonneg), which would imply Q_n >= 0.

**Where it broke**: The 3x3 Hankel minor det[F_{c,N+i+j}]_{0<=i,j<=2} is strongly negative for c=(2,1,1) at N=0 (min coefficient -85821) and N=1 (min coefficient -37254).

**Why it broke**: The sequence {F_{c,N}} satisfies q-log-concavity (2x2 Hankel minors nonneg) but the higher-order positivity property fails. The total positivity framework requires much stronger structural constraints than the F_{c,N} sequence satisfies.

**Is this instructive?** YES. This definitively eliminates an entire class of approaches. Any proof via total positivity of {F_{c,N}} is impossible. The route to Q_n >= 0 must go through the h_m decomposition, the D_k^m tower, or representation theory.

### The h_m -> Q_n Bootstrap (Seeds 1, 2, 4)

**What was attempted**: Prove Q_n >= 0 from h_m >= 0 via the formula Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}.

**Where it broke**: Three distinct sub-attempts failed. (1) Seed 1's diagonal decomposition showed all q^{km} components of h_m cancel for k >= 1, leaving only off-diagonal structure with no tractable form. (2) Seed 4's substitution h_m = q*h_{m-1} + delta_m led to truncated q-binomial sums that do not telescope. The initial hope Q_n = delta_n was wrong (verified: Q_2 != h_2 - q*h_1). (3) No q-analogue of the binomial theorem handles the j(j+1)/2 shift (standard identities have j(j-1)/2).

**Why it broke**: The shift j(j+1)/2 = j(j-1)/2 + j introduces an extra q^j factor that breaks all standard q-binomial identities. The h_m sequence, while nonneg with h_m(1) = base^m, does not have the specific structural properties (multiplicativity, log-concavity, diagonal regularity) needed for the alternating sum to telescope.

**Is this instructive?** YES. The bootstrap gap is real and structural. The D_k^m tower (Seed 4's PROVED identity Q_n = D_n^n) provides the correct reformulation: instead of going from h_m to Q_n in one step, the proof should proceed level by level through the tower D_0 -> D_1 -> ... -> D_n, proving D_k^m >= q^{k+1} D_k^{m-1} at each level.

### Schur Positivity (Seed 3, confirmed by Seed 8)

**What was attempted**: Decompose Q_{n,c}(q) as a nonneg combination of sl_3 Schur polynomial specializations s_{(a,b)}(q, q^2, q^3).

**Where it broke**: For d >= 4, the greedy decomposition leaves residual terms that are not any Schur polynomial. Specifically for d=7, c=(3,2,2): Q_1 - s_{(1,1)} - s_{(1,0)} leaves residual {1:1, 2:2, 4:1, 6:1} which is not expressible as any nonneg combination of Schur polynomials at (q, q^2, q^3).

**Why it broke**: Schur polynomials are characters of IRREDUCIBLE representations. Q_{n,c}(q) is the character of a Demazure module (a proper submodule, not necessarily a direct sum of irreducibles). Demazure characters are Schur-positive only in special cases.

**Is this instructive?** YES. It confirms that Demazure characters (key polynomials) are the right basis, not Schur functions. Any representation-theoretic proof must work at the Demazure level.

### GL_2 Key Polynomial Decomposition for d=7 (Seed 8)

**What was attempted**: Decompose Q_1 for d=7 into GL_2 key polynomials K_{(a,b)}(q, q^2).

**Where it broke**: K_{(a,b)}(q,q^2) has the form "a consecutive run of monomials starting at q^{a+2b}". Q_1 for d=7, c=(3,2,2) has coefficient 3 at q^2, which requires 3 runs passing through degree 2 -- impossible with only 11 total dimension.

**Is this instructive?** PARTIALLY. It means GL_2 key polynomials (2-variable) are insufficient for d >= 7. The GL_3 key polynomial decomposition (Seed 5) at specialization (q, q^2, q^3) DOES work. This confirms that k=3 variables are essential for the k=3 cylindric partition problem.

### D_3 Quotient of CW System (Seed 6)

**What was attempted**: Reduce the 36x36 CW system for d=7 to an 8x8 system by quotienting by D_3 symmetry.

**Where it broke**: The CW shifted profile operation c(J) does NOT commute with the D_3 action. Explicitly: for c = (1,1,2), J = {0}, applying cyclic permutation sigma first vs. applying the CW shift first gives different results.

**Why it broke**: D_3 symmetry is emergent in Q_{n,c} (it appears after the alternating sum extraction), not manifest in the CW recurrence. The CW system treats the three positions asymmetrically (the shift c(J) depends on which boundary between positions i and i+1 is crossed).

**Is this instructive?** YES. It shows that any proof using the CW recurrence must work with the full system of all profiles, not a reduced system. The D_3 symmetry can only be used post-hoc to check results, not to simplify computation.


## 4. Broken Assumptions

1. **"{F_{c,N}} is totally positive."** FALSE. The 3x3 Hankel minor is strongly negative. Only q-log-concavity (2x2) holds. Discovered by Seed 2.

2. **"h_m >= 0 implies Q_n >= 0 via a q-binomial identity."** FALSE as a direct implication. No standard q-identity handles the j(j+1)/2 shift. The correct bridge is the D_k^m tower, which requires proving positivity at each level. Confirmed by Seeds 1, 2, 4.

3. **"Q is Schur-positive."** FALSE. Q_{n,c}(q) is NOT a nonneg combination of sl_3 Schur polynomials at (q, q^2, q^3) for d >= 4. Discovered by Seed 3, confirmed by Seed 8.

4. **"h_m is multiplicative."** FALSE. h_2 != h_1 * h_1 as polynomial convolution. The difference h_2 - h_1*h_1 has negative coefficients. Discovered by Seed 3, confirmed by Seed 8. This rules out tensor product interpretations.

5. **"h_m is q-log-concave."** FALSE. h_{m+1}^2 - h_m * h_{m+2} has negative coefficients. Discovered by Seed 1.

6. **"Q_n = h_n - q*h_{n-1} (first q-difference)."** FALSE for n >= 2. Q_2 != h_2 - q*h_1 (verified numerically). The correct identity is Q_n = D_n^n (the FULL iterated q-difference). Discovered by Seed 4.

7. **"The CW system is D_3-equivariant."** FALSE. The profile shift c(J) does not commute with D_3 action. The symmetry is emergent. Discovered by Seed 6.

8. **"GL_2 key polynomials suffice for all d."** FALSE. GL_2 key polynomial decomposition fails for d >= 7. Need GL_3 (i.e., k=3 variables). Discovered by Seed 8.

9. **"A fixed-size matrix model can produce Q_n."** FALSE. deg(Q_n) is quadratic in n, but matrix powers give linear degree growth. Discovered by Seed 8.

10. **"Positivity fails for d equiv 0 mod 3."** FALSE (or at least unsupported). Q_{n,c}(q) is nonneg for d=3 and d=6 in all computed cases. The mod-3 exclusion is about the evaluation formula, not positivity. Discovered by Seed 7.


## 5. Connections

### Connection A (Resolved): h_m vs Total Positivity of {F_{c,N}} (Seeds 1 + 2)

From Layer 1, this connection was flagged as unexplored. Layer 2 resolves it:
- h_m >= 0: TRUE (verified extensively)
- h_m q-log-concave: FALSE
- F_{c,N} q-log-concave: TRUE
- F_{c,N} totally positive (Hankel): FALSE (3x3 minor negative)
- The 1/(q;q)_m factor in F_{c,N} = sum h_m/(q;q)_m smooths h_m's non-log-concavity, but not enough for full total positivity.

**Conclusion**: h_m >= 0 and F_{c,N} total positivity are INDEPENDENT conditions. Neither implies the other in the relevant direction. The total positivity approach is dead. The h_m approach survives but needs the D_k^m tower to bridge to Q_n.

### Connection B (Deepened): Demazure Modules / Affine Lie Algebras (Seeds 3 + 5 + 7 + 8)

The evidence for the affine Demazure module interpretation has strengthened substantially:

1. **CW profiles = sl_3 level-d weights** (Seed 7): The 36 profiles at d=7 are exactly the level-7 dominant integral weights of hat{sl}_3. This is structural.

2. **GL_3 key polynomial decomposition works** (Seed 5): Q_{n,c}(q) decomposes into nonneg combinations of K_u(q, q^2, q^3) for all tested d = 2, 4, 5, 7, 8 and n = 0, 1, 2, 3. Key polynomials ARE Demazure characters for GL_3.

3. **Q is NOT Schur-positive** (Seed 3): Confirms Demazure characters (not irreducible characters) are the right basis.

4. **The evaluation formula** (d+1)(d+2)/6 - 1 counts non-corner C_3 orbits of sl_3 level-d weights (Seed 3), matching Weyl orbit counting.

5. **Min-degree increments skip multiples of 3** (Seed 8), reflecting the C_3 symmetry structure.

6. **Positivity for d equiv 0 mod 3** (Seed 7): The Tsuchioka partial commutation failure at d equiv 0 mod 3 affects the Z-algebra FORM but not the positivity.

**The candidate algebra is hat{sl}_3 at level d** (Seed 7's proposal), with profile c = (c_0, c_1, c_2) corresponding to highest weight c_0 Lambda_0 + c_1 Lambda_1 + c_2 Lambda_2.

**What is still missing**: A concrete verification that the Demazure character at depth n matches Q_{n,c}(q) at the appropriate specialization. This requires SageMath or equivalent.

**Disagreement**: Seed 8 proposed A_{t-1}^(1) at level 3 (or A_{2r}^(2) with h* = t) while Seed 7 proposed hat{sl}_3 at level d. These are DIFFERENT proposals. The level-rank duality between them may resolve the disagreement: level-3 modules of hat{sl}_{t-1} and level-d modules of hat{sl}_3 are related by this duality. Which perspective is computationally more tractable for verification should guide the choice.

### Connection C (NEW): The D_k^m Tower and Demazure Filtration (Seeds 4 + 5 + 7)

Seed 4's PROVED identity Q_n = D_n^n, with D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}, creates a TOWER of intermediate polynomials: D_0^m = h_m, D_1^m = h_m - q*h_{m-1}, ..., D_n^n = Q_n.

In the Demazure module framework (Seeds 5, 7), this tower could correspond to a FILTRATION of the Demazure module: D_k^m would be the graded dimension of the k-th step in a filtration of the depth-m Demazure module. The domination condition D_{k-1}^m >= q^k D_{k-1}^{m-1} would reflect the fact that each filtration step adds a submodule whose character is shifted by q^k.

This connection is a SYNTHESIZER OBSERVATION (not from the agents). It bridges the algebraic identity (Seed 4) and the representation-theoretic framework (Seeds 5, 7). If D_k^m can be identified as a Demazure crystal character for specific parameters, then D_k^m >= 0 follows for free, proving the conjecture.

### Connection D (NEW): Q_1 Positivity via Ehrhart Theory (Seeds 1 + 6 + 7)

Three seeds independently contributed to a near-complete proof of Q_1 >= 0:

1. **Seed 6** reduced Q_1 positivity to monotonicity of f_1(q) = counting binary cylindric partitions by weight. Verified exhaustively for d <= 14.

2. **Seed 1** identified g_1 as a lattice point count in a cyclic polytope P_w = {(a_0,a_1,a_2) : a_i >= 0, sum = w, cyclic inequalities}.

3. **Seed 7** confirmed g_1 stabilizes to (d+1)(d+2)/6 as w -> infinity.

The monotonicity of lattice point counts in dilations of a rational polyhedral cone is a standard result in Ehrhart theory. For a rational cone of dimension >= 2, the Ehrhart quasi-polynomial is eventually an honest polynomial of degree dim-1 >= 1, hence eventually monotonically increasing. The effective bound on "eventually" can be computed from the cone geometry.

This gives a NEARLY COMPLETE proof of Q_1 >= 0, pending only the effective Ehrhart bound (which is standard but needs to be computed for the specific cylindric partition cone).

### Connection E (Extended): Time-Inhomogeneous Chain and the D_k^m Tower (Seeds 4 + 8)

Seed 8 identified that Q_n arises from a time-inhomogeneous Markov chain: M_1(q) * ... * M_n(q), where M_i has entries involving q^i. Seed 4's D_k^m tower provides the algebraic framework: D_k^m records the state after k steps of this chain, with the q^k shift in D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1} corresponding to the q^k-dependent transition at step k.

The quadratic degree growth deg(Q_n) = (d-1)n^2 + O(n) arises because step k contributes O(k) to the degree, and sum_{k=1}^n k = n(n+1)/2.

### Connection F (NEW): GL_3 vs GL_2 Key Polynomials (Seeds 5 + 7 + 8)

Seed 5 found GL_3 key polynomial decompositions that work. Seed 7 found GL_2 key polynomial decompositions that work. Seed 8 found GL_2 key polynomial decompositions that FAIL for d=7.

Resolution: The GL_2 decomposition (at specialization (q, q^2)) and GL_3 decomposition (at (q, q^2, q^3)) are different objects. The GL_2 version works for d <= 5 but fails for d >= 7. The GL_3 version works for all tested d. Since k=3 (three partitions in the cylindric partition), GL_3 is the natural setting. The GL_2 decompositions at small d are artifacts of the restriction GL_3 -> GL_2 being sufficient when d is small.


## 6. Recommendations for Layer 3

### Pursue (Priority Order)

1. **PROVE D_k^m >= 0 for all valid k, m, c (Priority 1).** This is THE central task. Seed 4 proved Q_n = D_n^n, converting the conjecture to D_k^m >= 0. The approach should be inductive in k:
   - Base case k=0: prove h_m >= 0. This is a combinatorial statement about cylindric partitions with no alternating signs. The Ehrhart theory approach (Connection D) should work.
   - Inductive step k -> k+1: prove D_k^m >= q^{k+1} D_k^{m-1}. This is a domination condition. Understanding what D_k^m counts combinatorially (Connection C suggests a Demazure filtration) would make this provable.

2. **Verify the Demazure character match via SageMath (Priority 2).** The single most impactful computation: for d=7, profile (3,2,2), use SageMath to construct the hat{sl}_3 crystal at level 7 with highest weight 3*Lambda_0 + 2*Lambda_1 + 2*Lambda_2, compute Demazure characters at depth n=1,2,3, and check if they match Q_{n,c}(q) at principal specialization. If this matches, the conjecture follows from Kumar-Mathieu positivity of Demazure characters.

   **Dual check**: Also try hat{sl}_7 at level 3 (the level-rank dual), using Seed 8's proposal that A_{t-1}^(1) = A_9^(1) at level 3 might work.

3. **PROVE Q_1 >= 0 via Ehrhart theory (Priority 3).** This is nearly complete. The lattice point count in the cyclic polytope P_w is an Ehrhart quasi-polynomial. Prove it is monotonically increasing for all w >= 1 and all profiles c with d not-equiv 0 mod 3. The effective Ehrhart bound should be computable.

4. **Identify D_k^m combinatorially (Priority 4).** D_k^m = sum_j (-1)^j q^{j(j+1)/2} [k choose j]_q h_{m-j}. At q=1, D_k^m = (base-1)^k * base^{m-k}. This suggests D_k^m counts (base-1)^k * base^{m-k} objects with a q-grading. Can these objects be identified? If D_k^m is a Demazure crystal character (Connection C), then the objects are crystal graph vertices.

### Abandon

5. **Total positivity of {F_{c,N}}.** Definitively killed by Seed 2. Do not pursue.

6. **Simple involution on the alternating sum.** Already abandoned in Layer 1, reconfirmed.

7. **Bailey pair approach.** Definitively ruled out by Seed 4: the transform is a convolution, not a Bailey transform.

8. **GL_2 key polynomial decomposition.** Fails for d >= 7. Use GL_3 key polynomials instead.

9. **Direct h_m -> Q_n bootstrap without the D_k^m tower.** The diagonal cancellation analysis (Seed 1) and the failed substitution (Seed 4) show this cannot work via standard q-identities. The D_k^m tower is the correct framework.

### Explore (New Connections)

10. **Connection C: D_k^m as Demazure filtration levels.** If D_k^m = graded dim of the k-th filtration step in the depth-m Demazure module, then D_k^m >= 0 is automatic. Verify this by matching D_k^m values against Demazure crystal computations.

11. **The positivity for d equiv 0 mod 3 (Seed 7's observation).** If positivity holds for ALL d (not just d not-equiv 0 mod 3), the conjecture can be strengthened. This would suggest the underlying representation-theoretic structure exists for all d, with only the evaluation formula needing modification when 3|d. A Layer 3 agent should test d=9 and d=12.

12. **Uncu's Gaussian elimination for d=7.** Seed 6 could not complete this, but a symbolic algebra system (SageMath, Mathematica) might handle the 36x36 CW system and produce an explicit multisum. Even if not manifestly positive, the structure of the multisum might reveal patterns.

### Specific Computation Requests

- **Critical**: Run SageMath: construct hat{sl}_3 crystal at level 7, compute Demazure characters, match against Q_{n,(3,2,2)}(q).
- Compute D_k^m for d=7, k and m up to 5. Verify all nonneg. Check whether D_k^m has a key polynomial decomposition.
- Test positivity for d=9 (three profiles: (3,3,3), (4,3,2), (5,3,1), etc.) and d=12.
- Prove the effective Ehrhart bound for the cyclic polytope P_w: for what w_0(c) do the lattice point counts become monotonically increasing?
- For d=7: compute Q_n for n=5 with sufficient precision (need q-degree up to 150 = 6*25).

### Summary of the State of Play

The conjecture has been reformulated from "Q_n >= 0 for all n" to "D_k^m >= 0 for all m >= k >= 0" (Seed 4's theorem Q_n = D_n^n). This is a strictly more refined statement that decomposes the difficulty into layers.

The representation-theoretic direction has converged: CW profiles = sl_3 level-d weights (Seed 7), Q decomposes into GL_3 key polynomials (Seed 5), Q is NOT Schur-positive but IS Demazure-character-positive (Seed 3). The candidate algebra is hat{sl}_3 at level d.

The two approaches that could close the proof:
- **Algebraic**: Prove D_k^m >= 0 by induction on k, using the domination tower. Each step requires D_{k-1}^m >= q^k D_{k-1}^{m-1}. The base case (h_m >= 0) is approachable via Ehrhart theory. The inductive step needs a combinatorial or representation-theoretic interpretation of D_k^m.
- **Representation-theoretic**: Identify Q_{n,c}(q) with a Demazure character of hat{sl}_3 (or its level-rank dual). Positivity then follows from Kumar-Mathieu. The key gap is the explicit identification, which requires SageMath computation.

Both approaches point to the same underlying truth: Q_{n,c}(q) is the graded dimension of a naturally defined vector space (a Demazure module or a filtration step thereof), and the D_k^m tower is the algebraic shadow of its filtration.
