# Prove Seed 2 Layer 1 — Energy Function on KR Crystals

Seed 2, Layer 1, Round 2. Agent exploring connection between Q_{n,c}(q) and energy-graded KR crystals.

## Mission

Round 1 found Q_1 = D_{s_1 s_2} - 1 for balanced profiles under principal grading, but this breaks for n >= 2 and asymmetric profiles. The energy function on tensor products of KR crystals is conjectured to be the correct grading. Compute energy function on B^{1,d}^{tensor n} and test against Q_n.

Key hint from Round 1: dim B^{1,d} = binom(d+2,2) = number of profiles.

## Phase 1: Compute

### Step 1: Understand KR crystals in SageMath

B^{1,d} for type A_2^{(1)} is crystals.KirillovReshetikhin(['A',2,1], 1, d).
- This has dimension binom(d+2,2).
- For d=4: dim = 15 = number of compositions (c_0,c_1,c_2) with c_0+c_1+c_2=4.

### Plan:
1. Enumerate B^{1,d} for d=4, extract elements and weights
2. Compute one_dimensional_configuration_sum for B^{1,d}^{tensor n} (n=1,2)
3. Compare with Q_{n,c}(q) for all profiles c with |c|=4
4. If direct match fails, look for quotients, filtrations, or weight-component decomposition

---


## Computational Evidence

### Key Finding 1: Energy function is constant on profile pairs

For B^{1,d} of type A_2^(1), the energy function H(b_1 tensor b_2) depends ONLY on the profiles (contents) of b_1 and b_2, not on the specific elements.

Verified for d = 2, 3, 4 (all computed).

This means H defines a function H: Prof_d x Prof_d -> Z_>=0, where Prof_d = {(c_0,c_1,c_2): c_0+c_1+c_2=d}.

### Key Finding 2: H is NOT the EMD

The energy matrix H[c,c'] is different from the Earth Mover's Distance EMD(c,c') discovered by Agent B in Round 1. H is also not symmetric, while EMD(c,c') != EMD(c',c) in general (both are asymmetric but differently).

For d=4, examples:
- H((0,0,4), (4,0,0)) = 4, EMD((0,0,4),(4,0,0)) = 4
- H((4,0,0), (0,0,4)) = 0, EMD((4,0,0),(0,0,4)) = 8
- H((0,0,4), (0,1,3)) = 1, EMD((0,0,4),(0,1,3)) = 2

### Key Finding 3: H matrix structure

For d=4:
- H((d,0,0), c') = 0 for all c' (element [1,1,...,1] has zero energy with anything)
- H((0,0,d), c') = d - c'_2 = c'_0 + c'_1 (element [3,3,...,3] gives max energy)
- H is NOT symmetric

### Finding 4: Direct comparison fails

Neither H-graded path sums nor EMD-graded path sums (n=2) match Q_2:
- H-paths for c=(2,1,1): 7q^3+5q^2+2q+1 [eval 15]
- Q_2 for c=(2,1,1): q^3+3q^4+2q^5+3q^6+2q^7+2q^8+q^9+q^10+q^12 [eval 16]

The evaluations differ (15 vs 16), confirming BA11 from Round 1.

### Q_n polynomials computed (d=4)

Q_1 for all 15 profiles: all have Q_1(1) = 4, all nonneg.
Q_2 for c=(2,1,1): Q_2(1) = 16, nonneg: q^3+3q^4+2q^5+3q^6+2q^7+2q^8+q^9+q^10+q^12.

## Approach

The energy function being constant on profiles is a structural property that could be exploited. Even though H != EMD, the fact that both functions exist (H from crystal theory, EMD from the adjugate theorem) suggests a deeper connection. The next step is to understand whether a quotient, filtration, or modification of the KR crystal gives the correct q-grading for Q_n.

## What a Counterexample Looks Like

If a specific profile c and bound n gives Q_{n,c}(q) with a negative coefficient, the conjecture fails. No such case has been found.

---


## Strategy

### Approach
Use energy function on KR crystals B^{1,d} to find representation-theoretic interpretation of Q_{n,c}(q).

### What we found
1. **H is constant on profiles (NOVEL):** For B^{1,d} of type A_2^(1), the energy function H(b_1 tensor b_2) depends only on profile(b_1) and profile(b_2). This holds for d=2,3,4. This means the 2-point energy defines a matrix H: Profiles x Profiles -> Z_>=0.

2. **ODCS structure:** B^{1,4}^{tensor 2} decomposes into 5 classical irreducible components with energies 0,1,2,3,4 and sizes 45,63,60,42,15.

3. **H != EMD:** The crystal energy function H(c,c') differs from the Earth Mover's Distance EMD(c,c') from the Adjugate Monomial Theorem.

4. **Direct matching fails:** The H-graded path sum does not match Q_n (evaluations differ: 15 per profile vs 16 = Q_2(1)).

### Key obstacle
The dimensional mismatch: B^{1,d}^{tensor n} has dim = C(d+2,2)^n, while sum of Q_n(1) over all profiles gives C(d+2,2) * ((d+1)(d+2)/6-1)^n. For d=4, this is 15 * 16 = 240 for n=2, but the crystal has 225 = 15^2 elements. The 240 vs 225 gap means Q_n CANNOT be directly read off from the tensor product crystal as a weight decomposition.

The connection must involve the (KMN)^2 character formula, which relates the crystal to the character of the integrable highest weight module L(d*Lambda_0). The module character gives the UNBOUNDED generating function F_c(q), and Q_n is extracted from it via the z-coefficient and (zq;q)_inf transform.

## Stuck: 2026-07-04

What I'm trying to show: Q_{n,c}(q) = (some crystal-theoretic object with manifest positivity)

Why I can't show it: The energy function on finite tensor products of KR crystals gives path sums that evaluate to 15^n (= C(d+2,2)^n) per profile, while Q_n(1) = ((d+1)(d+2)/6-1)^n = 4^n per profile for d=4. The crystal is too big by the wrong factor. The connection must go through the infinite crystal / path model, not finite tensor products.

What would unstick me: Understanding the (KMN)^2 path model applied to A_2^(1) at level d, and how the infinite path energy function relates to the cylindric partition weight. This is the content of the Schilling-Tingley bijection (Seed 5's territory).

## Assumptions Check

- About the objects: ASSUMING B^{1,d} is the right crystal to consider. It might be B^{d,1} or some other KR crystal. UNCERTAIN -- dim B^{1,d} = C(d+2,2) = #{profiles} is suggestive but not conclusive.
- About the maps: ASSUMING elements of B^{1,d} biject to profiles via content. VERIFIED computationally.
- About the energy: ASSUMING the SageMath energy function is the standard one. The "winding pairs" algorithm from Nakayashiki-Yamada applies to B^{r,1} (columns), not B^{1,s} (rows). SageMath may use a different algorithm for rows. UNCERTAIN but computations are consistent.
- About the problem: The connection might be INDIRECT -- through the character formula, not through direct identification of Q_n with a crystal weight component. LIKELY TRUE given the dimensional mismatch.

## Handoff

### State
Explored the energy function on KR crystals B^{1,d} of type A_2^(1) for d=2,3,4. 

### Best result (YELLOW)
**H is constant on profile pairs.** The energy function H(b_1 tensor b_2) on B^{1,d} tensor B^{1,d} depends only on the content/profile of b_1 and b_2, not on the specific elements. Verified for d=2,3,4. This is a new structural result not in the Round 1 synthesis.

This implies the energy-graded ODCS is governed by a single N x N matrix (where N = number of profiles) rather than the full N x N crystal tensor product. It also means the energy function can be computed purely combinatorially from profiles.

### What didn't work
- Direct identification of Q_n with H-graded path sums: fails due to dimensional mismatch (15^n vs sum_c Q_n(1) = 15*4^n for d=4).
- Identifying H with EMD: they are different functions on the same domain.
- Finding a closed-form formula for H: not a simple function of inversions, partial sums, or transport distances (the winding pair algorithm for B^{r,1} columns does NOT apply to B^{1,s} rows).

### What the next layer should do
1. **Compute H for B^{r,1} (column) crystals instead of B^{1,s} (row) crystals.** The winding pair formula is KNOWN for columns. For A_2^(1), B^{2,1} has dimension 3 (the anti-symmetric square). Check whether the COLUMN energy matches EMD.

2. **Explore the (KMN)^2 path model.** The connection to cylindric partitions is through INFINITE paths in the crystal, not finite tensor products. The character formula ch L(d*Lambda_0) = sum_{paths} q^{energy} is the master identity. If this character, restricted appropriately, gives F_c(z,q), then Q_n can be extracted. The next layer should implement the path model computation in SageMath.

3. **Check whether the H matrix has the RIGHT SPECTRUM.** At q=1, M_H has eigenvalue N=C(d+2,2) with multiplicity 1 (all-ones eigenvector). The remaining eigenvalues are 0. This means M_H(q) might factorize in a way that connects to the CW recurrence. Compute the q-eigenvalues of M_H for d=2.

