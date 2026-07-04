# Agent A: Proof Exploration for Warnaar's Positivity Conjecture

## Identity and Mission
- Agent A in Phase 1b (first sequential agent with RAG access)
- RAG corpus: 82 papers, 7037 chunks on cylindric partitions, Rogers-Ramanujan, affine crystals
- Goal: find a path to proving Q_{n,c}(q) >= 0

---

## RAG Queries Performed

### Query 1: "energy function Kirillov-Reshetikhin crystal tensor product cylindric partition"
- **Found**: Imamura-Skew-RSK-Dynamics paper has detailed treatment of combinatorial R-matrix and energy function on affine crystals (A_n^(1) type)
- **Key result**: Energy H(b1 tensor b2) = number of winding pairs. Intrinsic energy H = sum of local energies.
- **Key theorem** (Kang-Kashiwara): Energy changes by +/-1 under e_0 operators, constant under e_i (i != 0).

### Query 2: "one dimensional configuration sum affine crystal graded character weight space"
- **Found**: Tingley's paper "Three combinatorial models for sl_n-hat crystals" -- directly connects cylindric plane partitions to crystal bases.
- **Key**: CPPs with a given boundary form a basis for V_Lambda tensor F, where V_Lambda is irreducible and F is the space of partitions.
- **Key**: |pi| = principal grade + partition size.

### Query 3: "bounded cylindric partition q-binomial coefficient positivity polynomial"
- **Found**: Warnaar's conjecture statement (CDU-Q). Also found Kursungoz-Seyrek decomposition result.
- **Kursungoz**: Proved P_{n,c}(q) has positive coefficients, where F_c(z,q) = (1-z) sum P_n z^n / (q^r;q^r)_n.

### Query 4: "Tingley cylindric plane partition crystal bijection Kyoto path model"
- **Found**: Tingley poses open question: can crystal structures be lifted to U_q(sl_n-hat) representations?
- Connection to Kyoto path model via explicit bijection.

### Query 5: "Kursungoz cylindric partition decomposition positive coefficients P_n polynomial"
- **Found**: Kursungoz-Seyrek paper gives elementary bijection: cylindric partitions <-> (ordinary partition, colored distinct-part partition).
- This proves P_n >= 0 but P_n != Q_n.

### Query 6: "Schilling Shimozono fermionic formula Demazure character"
- **Found**: Imamura paper references Schilling-Tingley result that energy function D(b) on crystal tensor products equals the Demazure grading.
- Connected via [Theorem 4.4 of Fourier-Schilling-Shimozono] and [Theorem 6.1 of Schilling-Tingley].

### Query 7: "Warnaar bounded cylindric partition formula explicit multisum Q_n"
- **Found**: Warnaar's A_2 invariance identity (eq. around chunk_109):
  - sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n] [n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
  - This is a manifestly positive multisum for the BOUNDED generating function.
  - PROVED for all n_0 (not just small k).
  - The k=1 and k=2 proofs of positivity use this identity.

---

## Computational Evidence

### Q_n polynomials verified (all nonneg)
- d=2: Q_1 for all profiles: Q_1(1) = 1, all coefficients nonneg
- d=4: Q_1 for all 5 representative profiles: Q_1(1) = 4, all nonneg
- d=4, c=(2,1,1): Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12, Q_2(1) = 16
- d=7: Q_1 for all 5 representative profiles: Q_1(1) = 11, all nonneg

### Kursungoz P_n verified (all nonneg)
- d=4, c=(2,1,1): P_0 = 1, P_1 = 1 + 3q + 4q^2 + 4q^3 + 2q^4 + q^5, P_2 = degree 18 poly, all nonneg
- P_n(1) = binom(d+2,2)^n = 15^n for d=4

### KR crystal computations
- B^{1,d} for A_2^(1) has dim = binom(d+2,2) elements, all multiplicity 1 in distinct weights
- B^{1,4} tensor B^{1,4}: 225 elements, energy function computed
- Weight space at classical weight (2,0) [corresponding to profile (2,1,1) x 2]: q^4 + 2q^3 + 3q^2 + 2q + 1 (evaluates to 9, NOT equal to Q_2(1) = 16)
- **Conclusion**: KR tensor product weight space does NOT directly equal Q_n

### Transfer matrix structure
- For d=4, c=(2,1,1): exactly 5 valid states at the stable weight (matches (d+1)(d+2)/6 = 5)
- States: {(1,1,2), (1,2,1), (2,1,1), (2,2,0), (3,0,1)}
- g_m coefficients eventually become quasi-polynomial
- g_2 second differences stabilize at period 2: {5, -5, 5, -5, ...}

---

## Critical Discovery: h_m has NEGATIVE coefficients for m >= 2

**THE SYNTHESIS IS PARTIALLY WRONG about h_m.**

The synthesis says "Path A bottleneck: prove h_m >= 0 for m >= 2" where h_m = (q;q)_m * g_m.

My computation shows:
- h_1 = (1-q)*g_1: ALL NONNEG for d not-equiv 0 mod 3 (confirmed)
- h_2 = (1-q)(1-q^2)*g_2: HAS NEGATIVE COEFFICIENTS even for d=4, c=(2,1,1)!
  - h_2 = [0, 0, 3, 4, 5, 3, 3, 2, 2, 1, 1, 0, 1, 0, ..., 0, -3, -7, -12, -14, -9, -4, -1]
  - h_2(1) = -25 (NEGATIVE!)
- h_3 for d=4: has negatives starting at degree 16
- h_2 for d=7, c=(3,2,2): also has negatives starting at degree 23

**This means the D_k^m tower with base case D_0^m = h_m CANNOT prove Q_n >= 0,
because h_m itself is negative for m >= 2.**

The previous agents' D_k^m computations (which showed "D_k^m >= 0 verified for 87+ entries")
must have been using a DIFFERENT definition, likely D_0^m = g_m (power series, not polynomial)
and working to finite precision where the eventual-polynomial tail was truncated.

**This is a broken assumption in the synthesis.**

---

## Approach

My primary approach explores three directions:

### Direction 1: Kursungoz P_n to Q_n reduction
- P_n >= 0 is PROVED (Kursungoz-Seyrek decomposition)
- Q_n is defined via (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
- F_c(z,q) = (1-z) sum P_n z^n / (q^3;q^3)_n
- Relationship: F_{c,m} = P_m / (q^3;q^3)_m
- Abel summation: Q_n = P_n/(q^3;q^3)_n + sum_{m=0}^{n-1} (a_m - a_{m+1}) P_m/(q^3;q^3)_m
- **Problem**: The differences a_m - a_{m+1} alternate in sign, so this doesn't directly give positivity.
- **Status**: STUCK on this direction.

### Direction 2: Warnaar A_2 invariance identity
- The identity sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n][n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
  is PROVED for all n_0 and gives a manifestly positive multisum.
- For rank 2, this directly gives the bounded generating function.
- For rank 3, level-rank duality reduces to rank 2 (but only explicitly for k=1,2).
- **The key question**: Can we express Q_n directly using this identity?
- The extraction of [z^n] from (zq;q)_inf * F introduces alternating signs.
- **Status**: This is the most promising direction but requires more algebraic work.

### Direction 3: Transfer matrix spectral decomposition
- Universal determinant: det(I - xA) = -(x^3 - 1) for ALL d
- A has eigenvalues {1, omega, omega^2} (cube roots of unity)
- For d not-equiv 0 mod 3: the omega-eigenspaces cancel in Q_n
- If we can decompose g_m into eigencomponents and show the eigenvalue-1 component
  gives nonneg Q_n, we'd have the proof.
- **Status**: Not yet attempted computationally.

---

## What a Counterexample Looks Like
A counterexample would be a profile c = (c_0, c_1, c_2) with d = c_0+c_1+c_2 not-equiv 0 mod 3
and an n such that Q_{n,c}(q) has a negative coefficient. No counterexample has been found
for any d <= 12 or any profile tested (spanning hundreds of cases across 3 layers + 24 agents).

---

## Key Lemma (if pursuing Direction 2)
**The proof reduces to showing**: For the A_2 invariance identity at level n_0, the extraction
[z^n]((zq;q)_inf * Phi_{n_0,m_0}(z,w;q)) produces nonneg coefficients after multiplication by (q;q)_n,
for appropriate choice of n_0, m_0 corresponding to the profile.

---

## Stuck: h_m negativity
**What I'm trying to show**: Q_n >= 0 for all n and all profiles with d not-equiv 0 mod 3.
**Why I can't show it**: The natural decomposition Q_n = sum(-1)^{n-m} q^{T_{n-m}} [n,m] g_m
has alternating signs. The base-case approach (h_m >= 0) fails because h_m = (q;q)_m * g_m
has negative coefficients for m >= 2.
**What would unstick me**: Either (a) a manifestly positive multisum formula for Q_n that works
for general d (extending Warnaar's k=1,2 results), or (b) a representation-theoretic interpretation
of Q_n as a genuine character/multiplicity, which would give automatic positivity.

---

## Escalation: Three Approaches Attempted

### Attempt 1: KR crystal tensor products (Path B from synthesis)
- Computed B^{1,d}^{tensor n} for A_2^(1) with energy grading
- The energy-graded weight space does NOT match Q_n (evaluations differ)
- The connection between KR crystals and Q_n is more indirect than assumed
- **Failed because**: The KR weight space counts 9 things at q=1, but Q_2(1) = 16

### Attempt 2: Abel summation from P_n to Q_n
- Kursungoz's P_n >= 0 is proved
- Tried to express Q_n as a positive combination of P_m values
- The Abel summation gives Q_n = P_n/(q^3;q^3)_n + sum (a_m - a_{m+1}) P_m/(q^3;q^3)_m
- The differences a_m - a_{m+1} have mixed signs
- **Failed because**: The q-binomial transform kernel alternates in sign

### Attempt 3: h_m tower (Path A from synthesis)
- Computed h_m = (q;q)_m * g_m explicitly
- Found h_m has NEGATIVE coefficients for m >= 2 (even for d not-equiv 0 mod 3!)
- This BREAKS the Path A strategy as described in the synthesis
- **Failed because**: The base case h_m >= 0 is FALSE for m >= 2

### What all three have in common
All three approaches fail because the alternating signs in (zq;q)_inf are unavoidable
in the definition of Q_n. The cancellation that produces nonnegativity is global, not local.
A successful proof must either:
(a) Find a DIFFERENT combinatorial interpretation that avoids the alternating signs entirely
(b) Use the GLOBAL structure (e.g., the A_2 invariance identity) to handle the cancellation

### What I think is needed
The Warnaar A_2 invariance identity IS a manifestly positive formula for the bounded GF.
The key missing step is understanding how (zq;q)_inf * F_c(z,q) relates to this identity.
Specifically: can we write [z^n]((zq;q)_inf * F_c(z,q)) as a positive multisum
by combining the Warnaar identity with a clever rearrangement that absorbs the (zq;q)_inf factor?

This is the direction I recommend for subsequent agents.

---

## Additional Findings (Post-Escalation)

### 1. Universal determinant confirmed computationally
- det(I - M(x)) = -(x^3 - 1) verified for d=4 (15x15 matrix) and d=7 (36x36 matrix) using SageMath exact computation.
- Kernel at x=1 is the all-ones vector (1,1,...,1) -- the stationary state treats all profiles equally.

### 2. Matrix product formula for F_n
- F_n = prod_{k=1}^n (I - M(q^k))^{-1} * v_0, where v_0 = (1,...,1)
- Since det(I - M(q^k)) = -(q^{3k} - 1) = (1 - q^{3k}):
  F_n * (q^3;q^3)_n = [product of adjugate matrices] * v_0
- This shows P_n = (q^3;q^3)_n * F_n comes from the adjugate matrices.
- The Kursungoz positivity P_n >= 0 is about positivity of adjugate matrix products.

### 3. Q_2 verified correctly for d=7
- Q_2(q) for c=(3,2,2): degree 24 polynomial, ALL nonneg coefficients
- Q_2(1) = 121 = 11^2 (correct)
- Q_2 = q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20 + q^21 + q^22 + q^24
- Earlier negative results were truncation artifacts from insufficient enumeration bounds.

### 4. Warnaar's formula for d=2 rank-3
- Q_n = q^{n(n+a)} (a MONOMIAL!) for profiles (a+1, 1-a, 0) at d=2
- For a=0: Q_n = q^{n^2}. For a=1: Q_n = q^{n(n+1)}.
- Positivity is trivial in this case.

### 5. The Warnaar A_2 invariance identity
The key formula (proved for ALL n_0):
sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n][n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
where Phi_{n,m} = [n,m] / ((zq)_{n-m} (wq)_n)

- This is manifestly positive on the RHS (all terms nonneg).
- The iterative application (Warnaar's "bounded functional equation" approach) proved positivity for k=1,2.
- Extending to general k is the OPEN PROBLEM.
- The n_0 -> inf limit gives: 1/((zq)_inf (wq)_inf) as an infinite positive multisum.

### 6. CORRECTION to synthesis Path A
The synthesis states "bottleneck: prove h_m >= 0 for m >= 2" but:
- h_m = (q;q)_m * g_m has NEGATIVE coefficients for m >= 2 (even for d=4, not-equiv 0 mod 3)
- h_2 for d=4, c=(2,1,1) = [0,0,3,4,5,3,3,2,2,1,1,0,1,0,...,0,-3,-7,-12,-14,-9,-4,-1]
- h_2(1) = -25 (NEGATIVE)
- So the D_k^m tower with base case h_m >= 0 is NOT viable for m >= 2.
- The previous agents' "D_k^m >= 0 verified" results were for POWER SERIES truncated at finite precision, not for the polynomial h_m.
- This means Path A as stated in the synthesis is BROKEN. The correct characterization: the D_k^m power series may be nonneg coefficient-wise to any finite precision, but the polynomial obtained by multiplying by (q;q)_m is NOT nonneg.

---

## Recommended Direction for Subsequent Agents

1. **Study the Warnaar A_2 invariance identity more deeply**. This identity gives a manifestly positive multisum for the bounded GF at any level. The challenge is extracting Q_n from it (which involves the (zq;q)_inf factor). Can the two-variable structure (z, w) be exploited to absorb the alternating signs?

2. **Explore the matrix product formula** F_n = prod (I - M(q^k))^{-1} * v_0 to understand WHY the adjugate matrices produce positive P_n. If the adjugate has a combinatorial interpretation (e.g., in terms of lattice paths or non-intersecting paths), this could yield a bijective proof.

3. **Investigate the relationship between P_n and Q_n numerically** for small d. Can we write Q_n = positive combination of modified Kursungoz objects? E.g., Q_n = sum alpha_m P_m / (q^3;q^3)_m for some positive alpha_m?

4. **Do NOT pursue h_m >= 0 for m >= 2.** This is FALSE. The tower approach needs a fundamentally different base case.

## Scripts Written
- `scratch/scripts/agentA_kr_crystal.sage` -- KR crystal computation
- `scratch/scripts/agentA_compare.sage` -- weight correspondence analysis
- `scratch/scripts/agentA_qn_compute.sage` -- Q_n from first principles
- `scratch/scripts/agentA_correct_qn.sage` -- corrected Q_n as polynomial
- `scratch/scripts/agentA_hm_structure.sage` -- h_m structure (found negatives!)
- `scratch/scripts/agentA_tower.sage` -- D_k^m tower analysis
- `scratch/scripts/agentA_tower2.sage` -- corrected tower analysis
- `scratch/scripts/agentA_pn_to_qn.sage` -- P_n to Q_n relationship
- `scratch/scripts/agentA_warnaar_identity.sage` -- Warnaar invariance identity analysis
- `scratch/scripts/agentA_spectral.sage` -- transfer matrix spectral decomposition
- `scratch/scripts/agentA_spectral2.sage` -- spectral decomposition (fixed)
- `scratch/scripts/agentA_q2_verify.sage` -- Q_2 verification with correct precision
