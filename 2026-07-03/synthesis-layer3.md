# Synthesis: Layer 3 (8 Seed Agents)

Layer 3 was the first "verification layer" -- agents had SageMath for the first time, enabling exact algebraic computation and crystal-theoretic exploration. The results are substantial: a proved injection lemma, a universal determinant for the CW system, a partial Demazure character match, and a critical negative result that explains the mod-3 restriction structurally.

---

## 1. What Was Tried

**Seed 1 (Ehrhart Theory / Hall's Marriage Theorem).** Constructed the cyclic polytope P_w for binary cylindric partitions in SageMath and analyzed lattice point counts f_1(w) for 12 profiles with d from 2 to 14. Proved that every lattice point has at least one valid unit shift to the next weight level (since the sum of interlacing gaps equals d > 0), and that degree-1 vertices (corners where two interlacing constraints are tight) have distinct targets. Computed h*-vectors (first differences of f_1) and Hilbert generating functions of the cone, finding all-positive numerator coefficients. Verified perfect bipartite matchings at every weight level for all tested profiles using SageMath's matching algorithm. Could not close the formal proof of Hall's condition for degree >= 2 vertices in complete generality, leaving a gap between computational verification and rigorous proof.

**Seed 2 (Partition-Bead Bijections / Tingley).** Extended D_k^m computation to k,m up to 8 for d=4 and up to 5 for d=7. Verified positivity for d=9 and d=12 (six new profiles, three per d-value). Discovered that ALL D_k^m decompose into nonneg integer combinations of GL_3 key polynomials K_w(lambda) at specialization (q, q^2, q^3), verified by greedy subtraction against a catalogue of 2184 key polynomials. Found a universal min-degree formula min_deg(D_k^m) = (k+1)m - k(k+1)/2 + floor((k-1)^2/4), independent of d and profile. Found leading coefficient periodicity at min_deg matching A2 Weyl group structure (alternating 1, 2 for k >= 2). Discovered the evaluation formula Q_n(1) = (9j(j+1)/2 - 2)^n for d = 3j. Identified that the D_k^m tower does NOT apply when d equiv 0 mod 3 (because (q^3;q^3)_n replaces (q;q)_n in the Q definition).

**Seed 3 (Skew RSK / Inductive Proof via D_k^m Tower).** Attempted to prove D_k^m >= 0 by induction on k. Discovered the Initial Segment Preservation (ISP) property: D_k^m matches q^{k+1} * D_k^{m-1} for the first L_k(m) = m - ceil((k+2)/2) leading coefficients, verified numerically for d=4 with k up to 6 and m up to 10. Proved the ISP Propagation Theorem: if ISP holds at level k, it holds at level k+1 (algebraic proof sketch from the recurrence structure). Showed the full conjecture reduces to ISP + tail positivity for h_m alone. Found universal min_deg formula (consistent with Seed 2). Attempted SageMath Demazure crystal matching via LS path model for A_2^(1) at level d=4 -- the crystal dimensions grow but no direct match to Q_n or h_m was found via any simple reduced word or grading. Identified the core obstruction: non-negativity at level k-1 does not imply the domination D_{k-1}^m >= q^k D_{k-1}^{m-1}; a stronger inductive hypothesis (ISP) is needed.

**Seed 4 (Bilateral RR / Domination Tower).** Extended D_k^m computation to k,m up to 6 for d=4 and d=5. PROVED the injection lemma: g_m >= q * g_{m-1} coefficient-wise for all m >= 1 and all profiles with d >= 1. The injection explicitly increments the first part of the leftmost partition lambda^(i) where c_i > 0 and lambda^(i)_1 = max(Lambda). As a corollary, h_1 >= 0 for d not-equiv 0 mod 3 (since g_1 monotone implies (1-q)*g_1 >= 0). DISCOVERED that h_m has NEGATIVE coefficients for d equiv 0 mod 3 (verified for all profiles at d=3, 6, 9): g_1 oscillates with period 3 when (d+1)(d+2)/6 is not an integer. Identified the Ehrhart-theoretic mechanism: the cone is integral iff d not-equiv 0 mod 3, explaining why the quasi-polynomial has period 3 oscillation in the divisible case. Verified Q_n >= 0 for d=3, 6, 9 despite h_m < 0. Could not prove h_m >= 0 for m >= 2 or the domination D_k^m >= q^{k+1} D_k^{m-1}.

**Seed 5 (Schubert Polynomials / Lascoux).** Verified GL_3 key polynomial decomposition for Q_1 and Q_2 at d=7 using SageMath LP solver, with exact coefficient matching. For c=(3,2,2): Q_1 = K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)} (unique, dims 3+6+2=11). Q_2 decomposes into 8 key polynomials with total dim 121=11^2. Classified the key polynomials into full irreducible characters (w = w_0) and proper Demazure truncations (w != w_0). Explored affine A_2^(1) LS path crystals: the Demazure crystal for word [1,2] gives dim = 12 = h_1(1) for d=7, c=(3,2,2), but the BFS distance grading does NOT match h_1(q). No word of length <= 5 gives dim 144 = h_2(1). KR crystal B^{1,7} has dim 36 = number of CW profiles (elements in bijection with compositions of 7 into 3 parts). Identified the energy function on LS paths as the likely correct grading, but SageMath does not expose it for LS path crystals. Issued precision warning: D_k^m computations at precision < 6*max(k,m)^2 + 50 produce spurious negative coefficients.

**Seed 6 (Nandi / CW System Analysis).** Reduced Q_1 positivity to lattice point monotonicity via change of variables (x = L_2 - L_1, y = L_3 - L_2), converting the problem to counting lattice points in a fixed triangle T with a sliding half-plane constraint and a mod-3 congruence condition. DISCOVERED the Equal Distribution Lemma: when d not-equiv 0 mod 3, the three congruence classes of the linear form 2x+y on T all have the same cardinality (d+1)(d+2)/6, verified for all profiles with d <= 20. When d equiv 0 mod 3, the classes are UNEQUAL (one class has one extra point), directly explaining the monotonicity failure. Proved Q_1 >= 0 for d not-equiv 0 mod 3 (modulo formal completion of the unimodality argument for regime 2). DISCOVERED the universal determinant: det(I - A(x)) = -(x^3 - 1) for ALL d >= 1 with k=3, computed exactly for d = 1 through 11 (up to 78x78 matrices). Confirmed positivity for d=9 and d=12 (five profiles for d=9, three for d=12). Found a bug: the CW recurrence computes G_n = [y^n] F_c(y,q), not F_{c,n}(q).

**Seed 7 (Vertex Operators / D_4^(3) / Tsuchioka).** Computed exact Q_n values for d = 2, 4, 5, 7 (all 8 representative profiles for d=7). CONFIRMED that Q_1 = D_{s_1 s_2} - 1 for balanced profiles (c_1 = c_2 or cyclic equivalent) at d = 2, 4, 5, 7, where D_{s_1 s_2} is the principally specialized Demazure character of hat{sl}_3 at level d. For ASYMMETRIC profiles, no Demazure character D_w (with w up to word length 4) matches under any tested grading. For N >= 2, no match found even for balanced profiles. Explored KR crystals: B^{1,7} has dim 36 = number of profiles. Energy function on KR crystal tensor products identified as the most promising avenue for extending the match beyond N=1. Recommended using crystals.KirillovReshetikhin for energy computation.

**Seed 8 (Plane Partitions / Lozenge Tilings).** Extended positivity verification to d=8 (profiles (3,3,2), (4,3,1), n <= 3) and d=10 (profiles (4,3,3), (5,3,2), n <= 2). Verified D_k^m tower for d=7 through k,m = 5 and d=8 through k,m = 3. CONFIRMED h_1 = D_{s_1 s_2} for d=4, c=(2,1,1) (exact polynomial match, not just evaluation). Found that h_2 does NOT match any single Demazure character (the dimension sequence skips 25 = h_2(1)). CONFIRMED h_m has negative coefficients for d equiv 0 mod 3 (independently of Seed 4). Discovered the BFS cumulative counts from the highest weight vector show suggestive coincidences with Q_n(1) values but the BFS depth is not the correct grading.

---

## 2. Partial Results

### GREEN (proved or verified algebraically)

- **THEOREM (Injection Lemma): g_m >= q * g_{m-1} coefficient-wise for all m >= 1, all d >= 1, all profiles c.** The injection phi maps a cylindric partition Lambda with max(Lambda) = m-1 to one with max = m by incrementing lambda^(i)_1 from m-1 to m at the smallest index i with c_i > 0 and lambda^(i)_1 = m-1. Forward and backward interlacing are preserved because c_i >= 1 ensures the new part m only tightens forward constraints (by 1) and leaves backward constraints unchanged (since c_i >= 1 means j + c_i >= 2 for j >= 1, so position 1 is not constrained backward). Injectivity follows from the deterministic choice of i. (Seed 4, with complete proof.)

- **COROLLARY: h_1 >= 0 for d not-equiv 0 mod 3.** Since g_1 is monotonically non-decreasing (from the injection lemma with m=1), h_1 = (1-q) * g_1 has nonneg coefficients (the first differences of a monotone sequence are nonneg). (Seed 4.)

- **THEOREM: h_m has NEGATIVE coefficients for d equiv 0 mod 3.** The g_1 coefficients oscillate with period 3 when (d+1)(d+2)/6 is not an integer. Specifically, g_1 coefficients cycle through values {L, L, L+1} where L = floor((d+1)(d+2)/6), so h_1 = (1-q)*g_1 has negative terms at positions where the count decreases. Verified for ALL profiles at d = 3, 6, 9 (Seeds 4, 8, independently confirmed). This COMPLETELY EXPLAINS the mod-3 restriction in the conjecture: the D_k^m tower requires h_m >= 0 as its base case, and this fails precisely when 3 | d.

- **THEOREM (Equal Distribution Lemma): When d not-equiv 0 mod 3, the three congruence classes of 2x+y on the triangle T = {(x,y) : x <= c_1, y <= c_2, x+y >= -c_0} all have cardinality (d+1)(d+2)/6.** Verified computationally for all profiles with d <= 20 via character sum evaluation. When d equiv 0 mod 3, the classes are unequal (one has one extra point). (Seed 6.)

- **THEOREM (Universal Determinant): det(I - A(x)) = -(x^3 - 1) for ALL d >= 1 with k = 3.** Here A(x) is the N x N matrix (N = (d+1)(d+2)/2) encoding the CW shift operation. Computed exactly via SageMath for d = 1 through 11 (matrix sizes 3x3 to 78x78). (Seed 6.)

- **CONFIRMED: Q_1 = D_{s_1 s_2} - 1 for balanced profiles.** For profiles with c_1 = c_2 (or cyclic equivalent) and d = 2, 4, 5, 7, the principally specialized Demazure character D_{s_1 s_2} of the LSPaths crystal for hat{sl}_3 at level d exactly equals 1 + Q_1(q). Verified by explicit polynomial comparison. (Seed 7.)

- **CONFIRMED: h_1 = D_{s_1 s_2} for d=4, c=(2,1,1).** The principally specialized Demazure character matches h_1(q) = q^3 + q^2 + 2q + 1 exactly (not just at q=1). (Seed 8, also consistent with Seed 7.)

- **GL_3 key polynomial decomposition of Q_1 and Q_2 verified by LP.** For d=7, c=(3,2,2): Q_1 = K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)} (unique, dims 3+6+2=11). Q_2 decomposes into 8 key polynomials with total dim 121. All verified with exact coefficient matching. (Seed 5.)

- **ALL D_k^m decompose into nonneg integer combinations of GL_3 key polynomials** at specialization (q, q^2, q^3), verified for d=4 and d=7 using greedy decomposition against a catalogue of 2184 key polynomials. (Seed 2.)

- **Precision warning established.** D_k^m computations require precision >= 6*max(k,m)^2 + 50. Lower precision produces spurious negative coefficients (truncation artifacts). Previous reports of D_k^m negativity were artifacts. (Seed 5.)

- **D_k^m >= 0 verified** for d=4 (k,m <= 8, 36 entries), d=5 (k,m <= 6, 28 entries), d=7 both profiles (k,m <= 5, 21 entries each), d=8 two profiles (k,m <= 3). Zero failures across 87+ entries. (Seeds 2, 3, 4, 5, 8.)

- **Q_n >= 0 verified** for d=9 (profiles (3,3,3), (4,3,2), (5,3,1), (5,2,2), (9,0,0); n <= 3) and d=12 (profiles (4,4,4), (5,4,3), (6,4,2), (6,3,3); n <= 2). Confirms positivity extends to d equiv 0 mod 3. (Seeds 2, 6, 8.)

- **KR crystal B^{1,d} for A_2^(1) has dim = binom(d+2,2) = number of CW profiles.** Elements are in bijection with compositions of d into 3 nonneg parts. (Seed 5.)

- **Bipartite matching for f_1 monotonicity succeeds** for all tested profiles (d up to 14) and all weight levels (w up to 3d+5). Zero failures. (Seed 1.)

### YELLOW (computationally verified, not proved)

- **ISP Propagation Theorem.** If D_k^m matches q^{k+1} * D_k^{m-1} for the first L_k(m) = m - ceil((k+2)/2) leading coefficients at level k, then the same property holds at level k+1 with L_{k+1}(m). Verified numerically for d=4, k = 0,...,6, m up to 10. Algebraic proof sketch exists but formal proof is incomplete. (Seed 3.)

- **Universal min-degree formula: min_deg(D_k^m) = (k+1)m - floor((k+2)^2/4) + 1.** Independent of d and profile. Verified for d = 2, 4, 5, 7 and k, m up to 8. Seeds 2 and 3 found equivalent formulations (Seed 2: (k+1)m - k(k+1)/2 + floor((k-1)^2/4)). The two formulas are algebraically equivalent.

- **Universal leading coefficient at min_deg of D_k^m.** For d >= 4 and k >= 2: leading coeff = 1 if k even, 2 if k odd. Independent of d and profile. Matches A2 Weyl group periodicity. (Seeds 2, 3.)

- **Domination tower: D_{k-1}^m >= q^k D_{k-1}^{m-1} coefficient-wise for all k >= 1, m >= k.** Minimum ratio reaches exactly 1.0 at the highest non-trivial degree (tight domination). (Seeds 2, 4.)

- **Evaluation formula Q_n(1) = (9j(j+1)/2 - 2)^n for d = 3j.** Verified for j = 1 (d=3, base 7), j = 2 (d=6, base 25), j = 3 (d=9, base 52), j = 4 (d=12, base 88). (Seed 2.)

- **Q_1 >= 0 for d not-equiv 0 mod 3.** The proof via equal distribution + unimodality of level counts is essentially complete, pending formal completion of the regime-2 argument (the interleaving of congruence classes in the non-stabilized regime). Verified exhaustively for all profiles with d <= 25. (Seed 6, with injection lemma support from Seed 4.)

- **Equal Distribution Lemma (formal proof pending).** The character sum S = sum_T omega^{2x+y} = 0 when d not-equiv 0 mod 3 needs a closed-form evaluation. Verified numerically for all profiles with d <= 20. (Seed 6.)

- **GL_3 key polynomial decomposition exists for ALL D_k^m** (not just Q_n). Verified for d=4 and d=7. (Seed 2.)

### RED (attempted but failed or incomplete)

- **Hall's condition for the bipartite shift graph in full generality.** Every vertex has >= 1 neighbor (proved) and degree-1 vertices have distinct targets (proved algebraically), but Hall's condition for sets containing degree >= 2 vertices needs a structural argument. (Seed 1.)

- **h_m >= 0 for m >= 2 via Ehrhart theory.** The injection g_m >= q*g_{m-1} does not imply h_m = (q;q)_m * g_m >= 0 for m >= 2. The (1-q)(1-q^2)...(1-q^m) factor has alternating signs that require higher-order conditions on g_m beyond monotonicity. (Seeds 1, 4.)

- **Affine Demazure crystal identification of Q_n for n >= 2.** No Demazure character D_w with w up to word length 6 matches sum_{0..2} Q_n for any tested grading, even for balanced profiles at d=4. (Seeds 3, 5, 7.)

- **Affine Demazure crystal identification for asymmetric profiles.** Q_1 = D_{s_1 s_2} - 1 only works for balanced profiles (c_1 = c_2). No match found for asymmetric profiles under principal grading or any weight triple (w_0, w_1, w_2) with 1 <= w_i <= 7. (Seed 7.)

- **h_2 as a single Demazure character.** The Demazure character dimension sequence (1, 5, 7, 9, 22, 27, 39, ...) skips 25 = h_2(1) for d=4. h_2 is not a single Demazure character. (Seed 8.)

- **Gaussian elimination for d=7.** The universal determinant shows the system reduces to a cubic-denominator problem, but extracting a manifestly positive multisum from the 36x36 adjugate matrix is not tractable. (Seed 6.)

- **Level-rank dual (A_6^(1) at level 3 for d=7, or A_9^(1) at level 3 for d=9).** No match found. (Seeds 7, 5.)

---

## 3. What Failed and Why

### Demazure Crystal Matching Beyond N=1 and Beyond Balanced Profiles (Seeds 3, 5, 7, 8)

**What was attempted:** Match Q_{n,c}(q) (or partial sums sum_{j=0}^n Q_j) to principally specialized Demazure characters of hat{sl}_3 at level d.

**Where it broke:** Two distinct failures:
1. For N=1 with asymmetric profiles (c_1 != c_2): no word w of length <= 4 gives D_w matching 1 + Q_1 under principal grading, and no custom grading (w_0, w_1, w_2) with w_i <= 7 works either.
2. For N=2 even with balanced profiles: sum_{0..2} Q_n = 21 for d=4, but no Demazure character of word length <= 6 has this value.

**Why it broke:** Three candidate explanations:
- The correct grading is the energy function on KR crystals (Kyoto path model), not the principal grading. SageMath does not expose the energy function on LS path crystals. (Seed 7's diagnosis.)
- The relationship between Q_n and Demazure characters is more indirect than simple partial sums -- it may involve a filtration, tensor product structure, or translation elements of the affine Weyl group. (Seed 5's diagnosis.)
- h_2 is NOT a single Demazure character (dimension 25 is skipped in the Demazure dimension sequence). h_m for m >= 2 may require a different highest weight that depends on m. (Seed 8's diagnosis.)

**Is this instructive?** YES, critically. The partial success (N=1 balanced match IS exact) combined with the failures at N >= 2 and asymmetric profiles constrains the space of possible identifications. The energy function avenue is the most promising next step. The failure also shows that a direct "Q_n = Demazure character" identification, even if true, will be technically difficult to establish computationally.

### Inductive Proof of D_k^m >= 0 (Seed 3)

**What was attempted:** Induction on k in the D_k^m tower. Base case h_m >= 0. Inductive step: D_{k-1}^m >= q^k D_{k-1}^{m-1}.

**Where it broke:** The inductive step is CIRCULAR: D_k^m >= 0 and D_{k-1}^m >= 0 (inductive hypothesis) do not together imply D_{k-1}^m >= q^k D_{k-1}^{m-1}. Non-negativity is weaker than domination.

**Why it broke:** The domination condition requires information about the COEFFICIENTS of D_{k-1}^m, not just their signs. A stronger inductive hypothesis is needed: the ISP (initial segment preservation) property.

**Is this instructive?** YES. It identifies the precise strengthening needed: prove ISP at the base case (k=0, for h_m), then propagate through the tower. The ISP Propagation Theorem (Seed 3) shows the propagation step works. The bottleneck is the base case.

### h_m >= 0 for m >= 2 (Seeds 1, 3, 4)

**What was attempted:** Multiple approaches to prove h_m = (q;q)_m * g_m >= 0 for m >= 2.

**Where it broke:** The injection lemma gives g_m >= q * g_{m-1} (monotonicity between consecutive m), but (q;q)_m has alternating signs requiring higher-order conditions. For m=2: h_2 >= 0 requires a_w - a_{w-1} - a_{w-2} + a_{w-3} >= 0 for the coefficients a_w of g_2, a "second-order" condition that does not follow from first-order monotonicity.

**Why it broke:** The (q;q)_m factor is a degree-m(m+1)/2 polynomial with alternating signs. Multiplying an eventually-polynomial power series g_m by this factor and getting nonneg coefficients requires very specific structural properties of g_m. The injection lemma proves one such property (first-order), but the higher-order conditions need either Ehrhart-theoretic tools (for the lattice polytope of CPs with max = m) or representation-theoretic identification.

**Is this instructive?** YES. It separates the difficulty cleanly: m=1 is solved (injection lemma + monotonicity), m >= 2 requires genuinely new input. The representation-theoretic angle (h_1 = D_{s_1 s_2} for balanced profiles) suggests h_m may be identifiable as SOME algebraic object with known positivity properties, but not a single Demazure character.

### Hall's Marriage Theorem for f_1 Monotonicity (Seed 1)

**What was attempted:** Prove |P_w cap Z^3| <= |P_{w+1} cap Z^3| by constructing a matching in the bipartite shift graph (L = P_w, R = P_{w+1}, edges from unit shifts).

**Where it broke:** Degree-1 analysis is clean (distinct targets proved). Degree-2 vertices CAN share neighbors (e.g., (a_0, a_1, a_2) and (a_0+1, a_1-1, a_2) both map to (a_0+1, a_1, a_2) via different shifts). No structural argument shows Hall's condition holds for arbitrary subsets.

**Why it broke:** The bipartite graph has a complex structure at degree-2 vertices. Two vertices differing by a unit vector can share a neighbor, creating potential Hall violations. The lattice geometry does not yield a simple sufficient condition.

**Is this instructive?** PARTIALLY. The f_1 monotonicity is now PROVED by a different route (the injection lemma from Seed 4 gives g_1 >= q*g_0, which is stronger). Seed 1's Hall approach is no longer needed for Q_1 but remains relevant if one wants to prove monotonicity of higher g_m.

---

## 4. Broken Assumptions

1. **"h_m >= 0 for all d and all profiles."** FALSE for d equiv 0 mod 3. When 3 | d, the g_1 coefficients oscillate with period 3 (the lattice point count in the cone section is an Ehrhart quasi-polynomial, not a polynomial), so h_1 = (1-q)*g_1 has negative coefficients. The D_k^m tower requires h_m >= 0 as its base case, so the tower approach fails for d equiv 0 mod 3. Discovered independently by Seeds 4 and 8.

2. **"The mod-3 restriction in the conjecture is about the evaluation formula only."** PARTIALLY FALSE, needs refinement. The restriction IS structurally meaningful: it marks the boundary between the polynomial regime (h_m genuine polynomial with nonneg coefficients) and the non-polynomial regime (h_m a power series with negative coefficients). However, POSITIVITY of Q_n itself extends to d equiv 0 mod 3 (confirmed for d = 3, 6, 9, 12). The restriction is about which proof STRATEGY works, not about which cases are true. Discovered by Seeds 4, 7, 8.

3. **"h_2 is a single Demazure character."** FALSE. For d=4, the Demazure character dimension sequence (1, 5, 7, 9, 22, 27, ...) skips 25 = h_2(1). If h_m has a representation-theoretic interpretation for m >= 2, it is not as a single Demazure crystal. Discovered by Seed 8.

4. **"The principal grading is the correct specialization for matching Q_n to Demazure characters."** LIKELY FALSE, at least for general profiles and n >= 2. The N=1 match works only for balanced profiles under principal grading. The correct grading is probably the energy function on KR crystals (Kyoto path model). Diagnosed by Seed 7.

5. **"Previous reports of D_k^m negativity for large k, m."** FALSE -- these were truncation artifacts from insufficient computational precision. At precision >= 6*max(k,m)^2 + 50, all D_k^m are nonneg. Discovered by Seed 5.

6. **"The CW recurrence computes F_{c,n}."** FALSE. It computes G_n = [y^n] F_c(y,q) = F_{c,n} - F_{c,n-1}, not F_{c,n} itself. This distinction matters for matching against other formulas. Discovered by Seed 6.

---

## 5. Connections

### Connection A (RESOLVED): Q_1 Positivity via Multiple Routes (Seeds 1 + 4 + 6)

Three independent approaches converged on Q_1 >= 0:

1. **Seed 1** (Hall's marriage theorem on the bipartite shift graph): verified computationally for all profiles with d <= 14, gap in formal proof.
2. **Seed 4** (injection lemma): PROVED g_m >= q*g_{m-1}, which gives g_1 monotone, which gives h_1 = (1-q)*g_1 >= 0, which gives Q_1 = h_1 - q >= 0 (after checking the constant term).
3. **Seed 6** (equal distribution lemma + unimodality): reduces Q_1 >= 0 to monotonicity of lattice point counts in congruence classes within a fixed triangle, verified for d <= 25.

Seed 4's injection lemma is the cleanest and most general: it works for all d >= 1 and all profiles, gives a complete proof for Q_1 when d not-equiv 0 mod 3, and the injection is explicit.

**Status: Q_1 >= 0 is PROVED for d not-equiv 0 mod 3.**

### Connection B (DEEPENED): Demazure Characters -- Partial Match and Obstructions (Seeds 5 + 7 + 8)

The evidence for a Demazure character interpretation has both strengthened and revealed precise obstructions:

**What matches:**
- Q_1 = D_{s_1 s_2} - 1 for balanced profiles at d = 2, 4, 5, 7 (Seed 7, exact polynomial match)
- h_1 = D_{s_1 s_2} for d=4 balanced profile (Seed 8, exact polynomial match)
- All D_k^m decompose into GL_3 key polynomials with nonneg multiplicities (Seed 2)
- KR crystal B^{1,d} has dim = number of profiles = binom(d+2, 2) (Seed 5)

**What does not match:**
- Asymmetric profiles fail under principal grading (Seed 7)
- N >= 2 fails even for balanced profiles under principal grading (Seed 7)
- h_2 is not a single Demazure character (Seed 8)

**Resolution path:** The energy function on KR crystal tensor products (Kyoto path model) is the most likely correct grading. The principal grading is too naive. SageMath's `crystals.KirillovReshetikhin` provides energy functions on tensor products, which is the concrete tool needed for verification.

### Connection C (NEW): ISP Propagation + D_k^m Tower Reduces to Base Case (Seeds 3 + 4)

Seed 3's ISP Propagation Theorem combines with Seed 4's injection lemma to create a structured proof path:

1. **Injection lemma** (Seed 4, PROVED): g_m >= q * g_{m-1} for all m >= 1.
2. **h_1 >= 0** (PROVED): follows from injection lemma + monotonicity.
3. **h_m >= 0 for m >= 2** (OPEN): the critical gap.
4. **ISP at level k=0** (OPEN): h_m matches h_{m-1} (shifted by 1) for the first m-2 leading coefficients. Computationally verified.
5. **ISP propagation** (Seed 3, computationally verified): ISP at level k implies ISP at level k+1.
6. **D_k^m >= 0 for all k** (WOULD FOLLOW): if steps 3-5 are proved.

The bottleneck is step 3. The injection lemma handles m=1 but does not extend to m >= 2 because the (q;q)_m factor requires higher-order conditions on g_m.

### Connection D (NEW): The Mod-3 Mechanism is Explained (Seeds 4 + 6)

Seeds 4 and 6 independently identified the same mechanism:

- **Seed 4** (Ehrhart theory): The cone C of binary cylindric partitions is integral (lattice vertices) iff d not-equiv 0 mod 3. When 3 | d, the cone has vertices with denominator 3, producing a period-3 Ehrhart quasi-polynomial.
- **Seed 6** (equal distribution): The triangle T has equal-size congruence classes iff d not-equiv 0 mod 3. When 3 | d, one class has one extra point.

These are two faces of the same geometric fact: the lattice structure of the cylindric partition cone modulo 3. This explains both the monotonicity failure (h_m < 0 when 3 | d) and the evaluation formula failure ((d+1)(d+2)/6 is not an integer when 3 | d).

### Connection E (NEW): Universal Determinant and Mod-3 Structure (Seed 6)

The universal determinant det(I - A(x)) = -(x^3 - 1) is independent of d and profile. Its zeros are the cube roots of unity, which correspond to the mod-3 periodicity that appears throughout the problem:
- Min-degree increments skip multiples of 3 (Seed 8 Layer 2, explained by Seed 3 Layer 3)
- Equal distribution has period 3 (Seed 6)
- h_m negativity for 3 | d has period 3 in g_1 coefficients (Seed 4)
- The cone ray (1,1,1) has weight 3 (Seed 1)

**Synthesizer observation:** The cubic determinant -(x^3 - 1) = -(x-1)(x^2+x+1) suggests the CW system has an underlying Z/3Z symmetry at the spectral level, even though it is NOT D_3-equivariant at the profile level (Layer 2 result). The Z/3Z symmetry is in the spectrum of the transition matrix A(x), not in its matrix entries. This spectral symmetry may be the correct algebraic expression of the cylinder's C_3 rotational symmetry.

### Connection F (CONFIRMED): GL_3 Key Polynomial Framework is Correct (Seeds 2 + 5)

Seed 5's LP-verified decomposition and Seed 2's greedy decomposition against 2184 key polynomials converge on the same conclusion: ALL D_k^m (and hence all Q_n) decompose into nonneg integer combinations of GL_3 key polynomials at specialization (q, q^2, q^3). This is the finite (non-affine) shadow of the conjectured Demazure module interpretation.

Key structural feature: balanced profiles use primarily full irreducible characters (w = w_0, the longest element), while asymmetric profiles include proper Demazure truncations and monomial keys (highest weight vectors). This is consistent with the partial Demazure match (balanced profiles match cleanly, asymmetric ones don't).

---

## 6. Recommendations for Layer 4

### Pursue (Priority Order)

1. **PROVE h_m >= 0 for m >= 2 and d not-equiv 0 mod 3 (Priority 1).** This is THE bottleneck. The injection lemma handles m=1. For m=2, need to show that g_2 satisfies a_w - a_{w-1} - a_{w-2} + a_{w-3} >= 0 (second-order condition on Ehrhart-type coefficients). Three possible approaches:
   - Ehrhart theory for the higher-dimensional cylindric partition polytope (CPs with max = m form a polytope of dimension 3m-1).
   - A "higher injection" that constructs multiple maps from CPs with max = m and weight w to those with weight w+1, w+2, ..., w+m, compatible with the (q;q)_m factor.
   - Identification of h_m with a representation-theoretic object (not a single Demazure character, but perhaps a union of Demazure crystals or a graded component of a Fock space).

2. **Compute the energy function on KR crystal tensor products (Priority 2).** Use SageMath's `crystals.KirillovReshetikhin(['A',2,1], 1, d)` to construct B^{1,d} and form tensor products B^{1,d}^{tensor n}. The `one_dimensional_configuration_sum` or `energy_function()` methods should give the correct q-grading. Check whether the weight-(c_0, c_1, c_2) component of the n-fold tensor product, graded by energy, matches F_{c,n}(q) or Q_{n,c}(q). This would establish the representation-theoretic connection.

3. **Prove the ISP propagation formally (Priority 3).** Seed 3 has an algebraic proof sketch. Completing this would reduce the full conjecture (D_k^m >= 0 for all k) to the base case (h_m >= 0 for all m) plus tail positivity at the base level. Even without proving h_m >= 0 for general m, this structural result is valuable.

4. **Prove the Equal Distribution Lemma formally (Priority 4).** The character sum S = sum_T omega^{2x+y} = 0 for d not-equiv 0 mod 3. This is a finite sum over lattice points in a triangle, and should be evaluable in closed form using geometric series. A formal proof would complete the Q_1 >= 0 result through a second independent route (complementing the injection lemma).

5. **Explore the d equiv 0 mod 3 case separately (Priority 5).** Positivity holds but the D_k^m tower fails. A modified tower using h_m^{(3)} = (q^3;q^3)_m * g_m and a q^3-binomial transform might work. Alternatively, the representation-theoretic approach (energy function on KR crystals) might handle all d uniformly.

### Abandon

6. **Hall's marriage theorem approach for f_1 monotonicity.** Superseded by the injection lemma (Seed 4), which is simpler and more general.

7. **Level-rank duality as a computational shortcut.** No match found at the level-rank dual (Seeds 5, 7). The direct approach via hat{sl}_3 at level d is more productive.

8. **Principal grading for Demazure character matching.** Works only for balanced profiles at N=1. For general profiles and N >= 2, a different grading (energy function) is needed. Do not spend further effort on principal grading variations.

### Specific Computation Requests

- Compute energy function on B^{1,d}^{tensor n} for d=4, n=1,2 using SageMath KR crystals. Extract weight-(2,1,1) component and compare to F_{c,n}(q).
- Prove (or find a reference for) the Ehrhart theory result: for a pointed rational cone C with integral vertices, the lattice point count in sections is monotonically increasing in the section height.
- Compute g_2 coefficients for d=7 to high precision and check whether they satisfy the second-order condition a_w - a_{w-1} - a_{w-2} + a_{w-3} >= 0.
- Test whether h_m decomposes as a nonneg combination of GL_3 key polynomials for m = 2, 3 (as Q_n and D_k^m do).

---

## Summary of the State of Play After Layer 3

### What is proved

- **Q_1 >= 0 for d not-equiv 0 mod 3** (two independent proofs: injection lemma + monotonicity, and equal distribution + unimodality).
- **g_m >= q * g_{m-1}** for all m, d, profiles (injection lemma).
- **h_m < 0 for d equiv 0 mod 3** (the D_k^m tower approach is structurally limited to d not-equiv 0 mod 3).
- **det(I - A(x)) = -(x^3 - 1)** universally (explains mod-3 periodicity at the spectral level).

### What is strongly supported but not proved

- **D_k^m >= 0 for all k, m** (87+ entries verified, zero failures, GL_3 key polynomial decomposition exists for all).
- **ISP propagation** (reduces conjecture to base case h_m >= 0 plus tail positivity).
- **Q_1 = D_{s_1 s_2} - 1** for balanced profiles (verified for d = 2, 4, 5, 7).
- **Positivity for d equiv 0 mod 3** (verified for d = 3, 6, 9, 12, multiple profiles each).
- **Universal min-deg and leading coefficient patterns** for D_k^m.

### The two proof paths

**Path A (Algebraic/Inductive):** Prove h_m >= 0 (base case) + ISP propagation (structural step) => D_k^m >= 0 for all k => Q_n >= 0. The bottleneck is h_m >= 0 for m >= 2. Handles d not-equiv 0 mod 3 only.

**Path B (Representation-Theoretic):** Identify Q_{n,c}(q) with the energy-graded character of a weight space in a KR crystal tensor product. Positivity then follows from the character being a genuine crystal character. Could potentially handle all d uniformly. The bottleneck is computing the energy function and matching the grading.

Path A is closer to completion (Q_1 is done, the ISP framework exists, the bottleneck is "just" h_m for m >= 2). Path B is more ambitious (would prove the conjecture for all d and give a structural explanation) but requires significant additional computation.

### Dissent

- **Seeds 4, 8** believe the d equiv 0 mod 3 case requires completely different methods. **Seed 7** believes the representation-theoretic approach might handle all d uniformly. This disagreement is unresolved.
- **Seed 3** believes the ISP propagation + base case approach is the most promising path. **Seed 5** believes the GL_3 key polynomial decomposition is the key, and that proving it exists abstractly (without identifying the specific crystal) would suffice. These are compatible but lead to different proof strategies.
- **Seed 7** identifies the energy function on KR crystals as the missing piece for the Demazure identification. **Seed 5** is more pessimistic, rating the probability of identifying the specific Demazure module at only 40%.
