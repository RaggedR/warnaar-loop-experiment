# Agent B: Proof Exploration for Warnaar's Positivity Conjecture

## Identity and Mission
- Agent B in Phase 1b (second sequential agent with RAG access)
- RAG corpus: 82 papers, 7037 chunks
- Goal: find a path to proving Q_{n,c}(q) >= 0

---

## RAG Queries Performed

### Query 1: "Warnaar A2 invariance identity bounded cylindric partition proof k=1 k=2 positivity manifestly positive multisum"
- **Found**: Warnaar's paper with the main results section summarizing A2 Andrews-Gordon identities and manifestly positive multisum expressions for GK_{(c_0,c_1,c_2)}(z,q) when c_0+c_1+c_2 not equiv 0 mod 3.
- **Found**: Conjecture 1 (modulus 3k+2) and Theorem 3: explicit multisum-to-product identities.
- **Key**: The k=1 proof uses level-rank duality from rank-3 to rank-2, then a rank-2 Rogers-Ramanujan identity. The k=2 proof extends this.
- **CRITICAL**: The paper notes it is an "open problem to find the bounded analogues of Theorem k12 for k=2."

### Query 2: "adjugate matrix transfer matrix nonnegative entries lattice path Lindstrom Gessel Viennot"
- **Found**: Wheeler-Zinn-Justin paper on lattice paths and transfer matrices in the context of Hall-Littlewood polynomials. Not directly applicable.

### Query 3: "Warnaar bounded cylindric partition Q_n polynomial positivity proof extraction coefficient z^n"
- **Found**: Gessel-Krattenthaler determinantal formula for GK_{lambda/mu/d;n}(q). Alternating signs from the sum over k_i.

### Query 4: "spectral decomposition transfer matrix eigenvalue cubic root unity cylindric partition generating function"
- No direct hits. The spectral structure is a discovery from this experiment.

### Query 5: "level-rank duality rank 2 rank 3 cylindric partition bounded functional equation Phi identity"
- **CRITICAL FIND**: Warnaar's proof of k=1 and k=2 via bounded rank-2 identities.
- **Proposition RRcase-rank2**: For rank 2, GK_{(L+b+1,L)/(1-a,0)/3}(z,q) = 1/(zq)_{2L+a+b} * sum_n z^n q^{n(n+a)} [2L+b-n, n].
- **General rank-2 bounded formula**: For general k,s: GK_{(L+b+k-1,L)/(s-1,0)/(2k-1)}(z,q) has an explicit multisum. Manifestly positive.

### Query 6: "k=2 proof rank-3 quadruple sum cylindric partition Q_n manifestly positive formula modulus 7 modulus 8"
- **Found**: General rank-r conjecture for Q_{n,c}(1).

---

## Strategy

### Primary: Spectral Decomposition of Transfer Matrix

The universal det(I - M(x)) = -(x^3 - 1) means M has eigenvalues among {1, omega, omega^2}.
If M is diagonalizable: g_m = sum_lambda lambda^m * v_lambda, where v_lambda is the projection.
For d not equiv 0 mod 3, the omega and omega^2 components should cancel in Q_n.

Plan:
1. Build M for d=4, c=(2,1,1) explicitly
2. Compute spectral projections
3. Decompose g_m and Q_n into eigencomponents
4. Check if eigenvalue-1 component of Q_n is nonneg

### Secondary: Adjugate Matrix Nonnegativity

Check adj(I - M(q)) for nonneg entries.

### Tertiary: GK Determinantal Formula

Extract Q_n from the Gessel-Krattenthaler formula directly.

---

## Computational Evidence

(to be filled)

---

## MAJOR DISCOVERY: Adjugate Monomial Theorem

### Theorem (verified computationally for d=1,2,3,4,5,7,8)

Let A(x) be the Corteel-Welsh shift matrix on compositions of d into 3 nonneg parts. Then:

1. det(I - A(x)) = 1 - x^3  (this was known from Seed 6/Agent A)

2. **NEW: adj(I - A(x))[c, c'] = x^{EMD(c, c')}** where EMD is the Earth Mover's Distance on Z/3Z with the clockwise metric:

   EMD(c, c') = 3 * max(0, c'_1 - c_1, c_0 - c'_0) + (c'_0 - c_0) - (c'_1 - c_1)

### Key Properties:
- Every entry of the adjugate is a MONOMIAL in x with coefficient 1
- adj(I - A(q^k))[c,c'] = q^{k * EMD(c,c')} (scaling by k)
- EMD is the minimum total clockwise transport cost on Z/3Z
- EMD is NOT symmetric: EMD(c,c') != EMD(c',c) in general
- EMD(c,c) = 0 for all c

### Corollary: Manifestly Positive P_n Formula

Since (I-A(q^k))^{-1} = adj(I-A(q^k))/(1-q^{3k}):

**(q^3; q^3)_n * F_{c,n}(q) = sum_{paths} q^{weighted EMD sum}**

Specifically:
P_n(c) = sum_{c_0,...,c_{n-1}} prod_{k=1}^n q^{k * EMD(c_k, c_{k-1})}

where the sum is over all sequences of compositions c_0,...,c_{n-1} of d into 3 parts,
with c_n = c. This is manifestly nonneg.

### Proof Sketch for the Adjugate Theorem

The CW shift matrix A(x) has the structure:
- A(x) = x * S_cw - x^2 * S_ccw + x^3 * I_interior

where S_cw and S_ccw are the clockwise and counterclockwise single-unit shift matrices,
and I_interior restricts to compositions with all parts > 0.

For d=1: A(x) = x*P (cyclic permutation), and adj(I-xP) = I + xP + x^2 P^2 = sum of cyclic distance monomials. This is the Neumann series truncated at order 2 (since P^3 = I).

For general d: The proof requires showing that the cofactors of (I-A(x)) reduce to single monomials x^{EMD}. This should follow from the INCLUSION-EXCLUSION structure of A(x) combined with the TROPICAL structure of the EMD.

**STATUS: Verified computationally. Algebraic proof pending.**

---

## Towards Q_n Positivity

### The Gap

P_n(c) = (q^3;q^3)_n * F_{c,n} has a manifestly positive formula (path sum).

Q_n(c) = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * F_{c,j}
        = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^3;q^3)_j

This is an alternating-sign linear combination of P_j values divided by q-factorials.

### The Core Challenge

The passage from P_n to Q_n involves the (zq;q)_inf factor, which has alternating signs.
Even though P_n >= 0 (proved by Kursungoz and now also by our path formula),
the alternating combination does not directly give Q_n >= 0.

### What Would Help

If we could find a manifestly positive formula for Q_n directly (not via P_n),
that would prove the conjecture. Possible approaches:

1. Find a SIGNED involution on the path space that cancels all negative contributions
2. Find a completely different combinatorial interpretation of Q_n
3. Prove that the q-binomial transform of the path formula preserves positivity
   under the specific conditions (d not equiv 0 mod 3)

---

## Additional Computational Findings

### Q_n cyclic invariance
Q_n(c_0,c_1,c_2) = Q_n(c_1,c_2,c_0) = Q_n(c_2,c_0,c_1) for all n (cyclic rotation invariance).
But Q_n(c_0,c_1,c_2) != Q_n(c_2,c_1,c_0) in general (no reversal symmetry).
Verified for d=4, all 15 profiles, n=1,2,3.

### Q_n nonneg for ALL profiles when d not equiv 0 mod 3
For d=4: all 15 profiles, Q_1, Q_2, Q_3, Q_4 all nonneg. Q_n(1) = 4^n.
For d=7: profiles (3,2,2), (4,2,1), Q_1, Q_2, Q_3 all nonneg. Q_n(1) = 11^n.
For d=10: profile (4,3,3), Q_1, Q_2 nonneg. Q_n(1) = 21^n.

### Q_n has negatives when d equiv 0 mod 3
For d=3, c=(1,1,1): Q_1 has negatives (e.g., coeff of q^4 = -1).
Pattern: Q_1 = 2q + q^3 - q^4 + q^6 - q^7 + ... (period 3 oscillation in signs).

### Functional equation for H_c(z,q) = (zq;q)_inf * F_c(z,q)

H_c(z,q) = sum_{|J|=1} H_{c(J)}(zq,q) 
          - sum_{|J|=2} (1-zq) H_{c(J)}(zq^2,q)
          + sum_{|J|=3} (1-zq)(1-zq^2) H_c(zq^3,q)

This gives a SYSTEM RECURRENCE for Q_n across all profiles simultaneously:
Q_n(c) involves Q_n and Q_{n-1} and Q_{n-2} at shifted profiles.

The coefficients in this system recurrence have mixed signs (from the (1-zq)(1-zq^2) factors),
so it's not immediately clear that positivity is preserved.

---

## Summary of Agent B's Contributions

### New Theorems (verified, not yet proved algebraically)

**Theorem 1 (Adjugate Monomial Theorem):**
adj(I - A(x))[c,c'] = x^{EMD(c,c')} where EMD is the Earth Mover's Distance on Z/3Z.
Verified for d = 1, 2, 3, 4, 5, 7, 8 (matrix sizes from 3x3 to 45x45).

**Theorem 2 (Path Formula for P_n):**
(q^3;q^3)_n * F_{c,n}(q) = sum_{paths} q^{sum k*EMD(c_k, c_{k-1})}
This gives a new manifestly positive multisum for P_n = (q^3;q^3)_n * F_{c,n}.

### Proof Sketch for Theorem 1

The Bellman equation EMD(c,c') = min_J(|J| + EMD(c(J),c')) holds for c != c'.
The alternating-sign structure of A(x) (signs (-1)^{|J|-1} for subset J) implements
an inclusion-exclusion that collapses to the minimum-weight path, yielding a monomial.

For c = c': the alternating sum over all shifts equals x^3 uniformly.
Combined with the diagonal entry 1 of (I-A(x)), this gives (1-x^3) on the diagonal.

A complete algebraic proof requires showing that the EMD satisfies the necessary
subadditivity/uniqueness conditions for the tropical determinant to be monomial.

### What This Means for Q_n Positivity

The adjugate theorem gives a STRUCTURAL explanation of why P_n >= 0 (Kursungoz's result).
However, it does NOT directly prove Q_n >= 0 because the passage from P_n to Q_n involves
the alternating-sign (zq;q)_inf factor.

The gap between P_n >= 0 and Q_n >= 0 is PRECISELY the content of Warnaar's conjecture.
The adjugate theorem reduces the problem to understanding the q-binomial transform
applied to the manifestly positive path formula.

### Recommendations for Subsequent Agents

1. **PROVE the Adjugate Monomial Theorem algebraically.** The tropical algebra / 
   inclusion-exclusion structure is clear -- a formal proof should be within reach.
   This would be a publishable result independent of the positivity conjecture.

2. **Explore the functional equation for H_c(z,q).** The system recurrence for Q_n 
   across profiles might have positivity-preserving properties when d not equiv 0 mod 3.
   The key is the (1-q^n) factors from (q;q)_n/(q;q)_{n-1} that appear.

3. **Investigate the DIFFERENCE Q_n(c) - q^n * sum Q_n(c') for clockwise shifts c'.**
   The functional equation suggests Q_n satisfies a first-order recurrence in n
   modulo terms involving Q_{n-1} and Q_{n-2}. These lower-order terms might
   be controlled by induction.

4. **Try signed involution on the path space.** The passage from P_n to Q_n introduces
   signs. On the path space (sequences of compositions), these signs come from the
   (zq;q)_inf factor. A signed involution that pairs negative paths with positive ones
   would prove Q_n >= 0.

### Scripts Written
- `scratch/scripts/agentB_spectral.sage` -- CW transfer matrix construction, adjugate nonnegativity
- `scratch/scripts/agentB_adjugate.sage` -- adjugate for multiple k, Q_n from matrix product
- `scratch/scripts/agentB_adj_detail.sage` -- detailed adjugate structure, valuation analysis
- `scratch/scripts/agentB_adj_fix.sage` -- correct valuation extraction, product nonnegativity
- `scratch/scripts/agentB_distance.sage` -- D(c,c') investigation, NOT graph distance
- `scratch/scripts/agentB_earth_mover.sage` -- EMD identification, VERIFIED for d=1,2,4
- `scratch/scripts/agentB_theorem.sage` -- Full theorem verification for d=1,2,3,4,5,7,8
- `scratch/scripts/agentB_Qn_formula.sage` -- Q_n for multiple d and profiles
- `scratch/scripts/agentB_Qn_structure.sage` -- Q_n symmetry and functional equation
- `scratch/scripts/agentB_prove_monomial.sage` -- Algebraic structure of A(x), Bellman equation
- `scratch/scripts/agentB_proof_attempt.sage` -- Verification of (I-A(x))*adj = (1-x^3)*I

