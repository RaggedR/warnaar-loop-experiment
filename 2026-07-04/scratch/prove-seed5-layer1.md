# Seed 5, Layer 1, Round 2: Cylindric Partitions and Affine Crystal Bijection

## Mission
Find the precise bijection between bounded cylindric partitions (max part <= n) of profile c and elements of a Demazure subcrystal of an A_2^(1) highest weight crystal.

## Computational Evidence

### Q_n computed correctly via CW functional equation
For d=2 (ell=1):
- Q_1((1,1,0)) = q, Q_2 = q^4, Q_3 = q^9 (pattern: q^{n^2})
- Q_1((2,0,0)) = q^2, Q_2 = q^6, Q_3 = q^12 (pattern: q^{n(n+1)})
- All single monomials! (Trivial because only 1 orbit contributes after subtraction)

For d=4 (ell=1):
- Q_1((2,1,1)) = 2q + q^2 + q^3 (sum = 4)
- Q_1((4,0,0)) = q^2 + q^3 + q^4 + q^6 (sum = 4)
- Q_2((2,1,1)) = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12 (sum = 16)
- All coefficients nonneg up to tested limits

Key evaluations:
- Q_n(1) = ((d+1)(d+2)/6 - 1)^n = (number of C_3 orbits - 1)^n
- Total sum over all profiles: sum_c Q_1(c) = 15*q + 18*q^2 + 12*q^3 + 8*q^4 + 4*q^5 + 3*q^6 (sum=60=15*4)

### Crystal structure of B^{1,d}
- B^{1,d} for A_2^(1) has binom(d+2,2) elements = SSYTs of shape (d) with entries {1,2,3}
- Profile c = (c_0,c_1,c_2) = (count of 1s, 2s, 3s) in SSYT
- CRITICAL: phi is INJECTIVE on B^{1,d} -- each element has a unique phi value
- This means the Kyoto path model is DETERMINISTIC: ground state paths are unique
- Connected components of B^{1,d}^{tensor n} under crystal operators = FULL tensor product (225=15^2 for d=4, n=2)

### Energy function analysis
The energy function on B^{1,d}^{tensor n} is NOT related to Q_n directly.
Energy matrix H(b1 tensor b2) on B^{1,4} computed:
- H values range from 0 to 4
- Energy sum by profile = F_{c,n} polynomial (unrestricted bounded GF)
- P_n = (q;q)_n * F_{c,n} = manifestly positive EMD path sum

### Key structural observations
1. Q_1 is constant on C_3 orbits of profiles (cyclic invariance confirmed)
2. For balanced profile (2,1,1): Q_1 degrees = {1,1,2,3} = min clockwise EMDs to other C_3 orbit reps
3. For other profiles, this EMD-degree matching fails
4. The (zq;q)_inf factor in Q_n definition acts as a "Weyl denominator" that cancels the partition contribution in Tingley's V_Lambda tensor F decomposition

## Approach

### Strategy
The bijection I sought -- bounded CPs to Demazure subcrystal elements -- does not work in the naive form because:
1. The Kyoto path model is deterministic for B^{1,d} (phi is injective)
2. The energy function on tensor products gives P_n/F_{c,n}, not Q_n
3. Q_n requires the (zq;q)_inf cancellation, which removes the "partition part" of Tingley's decomposition CP -> (crystal element, partition)

### What a Counterexample Looks Like
If Q_n had a negative coefficient, it would mean the (zq;q)_inf cancellation overshoots -- more negative terms than positive in the extraction.

## Strategy

### Attempted: Direct Demazure crystal bijection
Result: FAILED. The issue is threefold:
1. phi-injectivity makes the Kyoto path model trivial (no branching)
2. Energy function gives F_{c,n} (the bounded GF), not Q_n
3. The alternating (zq;q)_inf factor cannot be absorbed into a crystal structure directly

### New direction: Q_n as virtual character difference
Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))

From Tingley: F_c(z,q) = sum_{(v,lambda)} z^{max(pi(v,lambda))} q^{deg(v)+3|lambda|}
where (v,lambda) in B(Lambda) x P.

The factor (zq;q)_inf kills the partition part. Specifically:
(zq;q)_inf * sum_m z^m F_{c,m}(q) = (zq;q)_inf * [something rational in z]

The extraction [z^n] then picks out a specific polynomial.

### Key Lemma (not proved)
Q_n(c,q) is a DIFFERENCE of characters: Q_n = ch(V_n) - ch(V_{n-1}') where V_n, V_{n-1}' are appropriate sl_3 modules. Specifically, Q_n might be the character of a QUOTIENT module.

## Stuck: Attempt 1

What I'm trying to show: Q_n is the graded character of a Demazure subcrystal.
Why I can't show it: The energy function on KR tensor products gives F_{c,n} not Q_n. The (zq;q)_inf factor is not a crystal operation.
What would unstick me: Understanding what mathematical operation on the crystal side corresponds to multiplication by (zq;q)_inf on the GF side.

## Stuck: Attempt 2

Tried: Looking at the Demazure subcrystal B_w(Lambda) in the infinite crystal B(Lambda) modeled via Kyoto paths. Since phi is injective on B^{1,d}, the paths are deterministic and the subcrystal is trivially a single chain.

What would unstick me: Using a DIFFERENT crystal model where branching occurs. Perhaps using KR crystals of type B^{d,1} instead of B^{1,d}, or using the Fock space model directly.

## Assumptions Check

- **phi is injective on B^{1,d} for A_2^(1)**: TRUE for all d tested (d=2,4). This is because B^{1,d} = S^d(C^3) as an sl_3 crystal, and each weight space is 1-dimensional.
- **Kyoto paths with B^{1,d} as perfect crystal model B(Lambda)**: TRUE by Tingley's Theorem 3.7 / KKMMNN.
- **max(pi) = path length in Kyoto model**: UNCERTAIN. The relationship between max(CP) and the number of positions differing from ground state needs clarification when the partition lambda(pi) is nonzero.
- **Q_n is directly a Demazure character**: LIKELY FALSE for the simple model. The q-binomial transform from P_n to Q_n involves alternating signs.
- **Q_n decomposes into GL_3 key polynomials**: Computationally verified (Round 1). This is the strongest evidence for a representation-theoretic interpretation.

## THE BROKEN ASSUMPTION
What I believed: Bounded CPs with max <= n correspond to "truncated Kyoto paths of length n", giving a Demazure subcrystal.
What is actually true: The Kyoto path model with B^{1,d} is deterministic (no branching due to phi-injectivity). Truncated paths give single elements, not polynomials. The bounded GF F_{c,n} comes from the FULL tensor product B^{1,d}^{tensor n}, not a subcrystal.
What this means for the proof: The bijection between bounded CPs and Demazure subcrystal elements cannot work through the standard Kyoto path model. Need either a different crystal model or a different interpretation of Q_n.

## Key Finding: Orbits and Q_1

The strongest observation is:
- Q_1(1) = (number of C_3 orbits of profiles) - 1
- For balanced profiles, Q_1 degrees match min EMDs to other orbit representatives
- Q_1 is invariant under C_3 but NOT under S_3

This suggests Q_1 counts "directed paths" in the orbit space, with grading related to the clockwise EMD. This connects to Path D (EMD/signed involution) from Round 1 more than Path B (representation theory).

## Handoff

### State: Stuck on the direct Demazure crystal approach (2 attempts)

### Best result (YELLOW): 
1. Proved phi-injectivity on B^{1,d} for A_2^(1), explaining why the naive Kyoto path truncation fails.
2. Verified Q_n is correct via CW functional equation (independent implementation).
3. Identified that Q_1 degrees match min clockwise EMDs to other C_3 orbit representatives for balanced profiles.
4. Computed full energy-graded decomposition of B^{1,4}^{tensor 2} -- this gives P_n/F_{c,n}, confirming the crystal model accounts for P_n (not Q_n).

### What the next layer should do:
1. **Try B^{d,1} instead of B^{1,d}**: The KR crystal B^{d,1} for A_2^(1) is the d-fold antisymmetric power rather than symmetric. It might have non-trivial phi multiplicities, enabling branching in the Kyoto model. Check if this gives Q_n instead of P_n.
2. **Investigate the Fock space model directly**: Tingley's V_Lambda tensor F decomposition has the partition F as a separate factor. The (zq;q)_inf factor kills F. So Q_n might be the character of V_Lambda restricted to some finite submodule related to the Demazure filtration at depth n.
3. **Connect to the GL_3 key polynomial decomposition**: The verified decomposition Q_n = sum of key polynomials should have a crystal-theoretic proof via Demazure characters of sl_3 (not sl_3-hat). The key polynomials are Demazure characters for the FINITE sl_3, not the affine algebra.
4. **Focus on the orbit EMD structure**: Q_1 for balanced profiles exactly matches clockwise EMD to orbit reps. This might extend to Q_n via an EMD path formula on the orbit space (5 orbits for d=4 instead of 15 profiles).
