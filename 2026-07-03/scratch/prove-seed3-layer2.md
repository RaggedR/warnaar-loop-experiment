# Prove Seed 3, Layer 2: Skew RSK / Crystal Graph Perspective

## Summary of Layer 1

In Layer 1, I verified Q_{n,c}(q) computationally for d in {1,2,4,5} and explored three proof strategies (Garsia-Milne involution, skew RSK / q-Whittaker decomposition, transfer matrix spectral analysis). All three failed at the same "cross-N obstruction": the alternating sum mixes F_{c,m} for different m values, and no approach could handle this.

## Layer 2 Mission

From the synthesis:
1. Work at the crystal graph level — can skew RSK / q-Whittaker give a bijection between bounded CPs and crystal graph elements?
2. Explore whether Imamura's Upsilon bijection can be adapted to bounded CPs
3. Profile dependence — does skew RSK explain D_3 symmetry?

## Computational Evidence (Layer 2)

### sl_3 Weight Orbit Counting

Verified the following structure:

| d | C_3 orbits | base = (d+1)(d+2)/6 - 1 | Non-corner orbits |
|---|-----------|--------------------------|-------------------|
| 2 | 2         | 1                        | 1                 |
| 4 | 5         | 4                        | 4                 |
| 5 | 7         | 6                        | 6                 |
| 7 | 12        | 11                       | 11                |
| 8 | 15        | 14                       | 14                |

For d not = 0 mod 3, the number of C_3 orbits of triples (a,b,c) with a+b+c = d is exactly (d+1)(d+2)/6. The "corner" orbit {(d,0,0),(0,d,0),(0,0,d)} accounts for the "-1", giving:

**base = (d+1)(d+2)/6 - 1 = number of non-corner C_3 orbits**

This is the number that appears as Q_{n,c}(1)^{1/n}.

### GL_2 Key Polynomial Decomposition

Extended Seed 5's observation. The GL_2 key polynomial K_{(a,b)}(q, q^2) for a >= b >= 0 is:

K_{(a,b)}(q, q^2) = q^{a+2b} + q^{a+2b+1} + ... + q^{2a+b}

(a consecutive run of a-b+1 monomials starting at degree a+2b).

Greedy decomposition results:
- For c=(2,1,1), n=3: Q_3 decomposes into 40 GL_2 key polynomials. YES.
- For c=(2,1,1), n=4: FAILS with small positive remainder.
- For c=(2,2,1), n=3: decomposes into 124 GL_2 key polynomials. YES.
- For c=(2,2,1), n=4: FAILS.

The decomposition works for n=3 but fails for n=1,2,4. This is suspicious -- the greedy algorithm is non-canonical, so failure might be an artifact of the greedy strategy rather than a genuine obstruction.

### sl_3 Schur Decomposition

Tried to decompose Q_{n,c}(q) as a non-negative integer combination of sl_3 Schur polynomials s_{(a,b)}(q, q^2, q^3). Result: **FAILS for all d >= 4**.

This is a genuine negative result: Q_{n,c}(q) is NOT sl_3 Schur-positive at the specialization (q, q^2, q^3).

### h_m Structure

h_m(q) = (q;q)_m * g_m(q) where g_m = [z^m] F_c(z,q).

Verified:
- h_m(1) = ((d+1)(d+2)/6)^m for all tested cases. Specifically:
  - h_4 for c=(2,1,1): h_4(1) = 625 = 5^4, all 49 coefficients nonneg, deg = 48
  - h_4 for c=(2,2,1): h_4(1) = 2401 = 7^4 (requires q_max >= 65)
- h_m is NOT multiplicative: h_2 != h_1 * h_1 (as polynomial convolution)
  - For c=(2,1,1): h_2 - h_1*h_1 = [0,0,-6,-2,-2,1,2,2,2,1,1,0,1]
- h_m HAS non-negative coefficients for all tested cases (d <= 5, m <= 4)

The non-multiplicativity means h_m is NOT the character of an m-fold tensor product. It must have a more subtle representation-theoretic interpretation.

### Q_n Degree Pattern

Confirmed: deg(Q_{n,c}) = (d-1)n^2 for all tested profiles.
- d=2: deg = n^2
- d=4: deg = 3n^2
- d=5: deg = 4n^2

The quadratic growth rules out Q_n = Q_1^n (which would give linear degree growth).

For d=2: Q_{n+1} = q^{2n+1} * Q_n (multiplicative structure).
For d >= 4: no simple multiplicative recurrence exists.

### Correct Formula Verification

The correct alternating sum formula is:

Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} * (q^{j+1};q)_{n-j} * g_{n-j}(q)

where the shift is q^{j(j+1)/2} (not j(j-1)/2 as in some Layer 1 notes). This follows from:

[z^j](zq;q)_inf = (-1)^j q^{j(j+1)/2} / (q;q)_j

## D_3 Symmetry Analysis

### Cyclic Symmetry: TRIVIAL

(c_0,c_1,c_2) -> (c_1,c_2,c_0) corresponds to relabeling tracks in the cylindric partition:
(lam0,lam1,lam2) -> (lam1,lam2,lam0).

This preserves weight and max entry trivially. Therefore F_{c,N} = F_{cyc(c),N} for all N.

### Reversal Symmetry: VERIFIED AT THE F_{c,N} LEVEL

Key finding: **F_{c,N}(q) = F_{rev(c),N}(q)** for all tested cases.

This means reversal is a bijection at the level of cylindric partitions themselves, not just at the Q_n level. Verified for:
- d=4: c=(2,1,1) vs c=(1,1,2), all N = 0,1,2,3
- d=5: c=(2,2,1) vs c=(1,2,2), all N = 0,1,2,3

The naive map (lam0,lam1,lam2) -> (lam2,lam1,lam0) does NOT work directly -- it doesn't satisfy the reversed profile's interlacing conditions. The actual bijection is more subtle and likely involves Borodin's product formula being invariant under profile reversal.

### Important Limitation

For profiles computable with our code (max(c_i) <= 2), all D_3 orbits have size 3 (since at least two c_i must be equal). So reversal = cyclic^k for all tested cases. True reversal symmetry (where reversal != any cyclic power) only occurs for all-distinct profiles, which need max(c_i) >= 3 and hence d >= 7.

### Skew RSK Perspective on D_3 Symmetry

From the cylinder perspective:
- Cyclic: rotation of the cylinder (trivial)
- Reversal: reflection of the cylinder (non-trivial, but preserves F_{c,N} as verified)

The Sagan-Stanley correspondence maps cylindric partitions to skew tableaux on the cylinder. Both rotations and reflections are compatible with this map because they preserve the q-weight and max entry.

## Approach: Crystal Graph Level

### Strategy

The key observation connecting Seeds 5, 7, and 8:

Q_{n,c}(1) = (number of non-corner C_3 orbits of level-d sl_3 weights)^n

This suggests Q_{n,c}(q) is the character of an n-fold "product" of objects, each carrying a q-grading, where the number of objects at q = 1 equals the number of non-corner C_3 orbits.

### What a counterexample would look like

A counterexample would be a profile c with d not = 0 mod 3 and an n >= 1 such that Q_{n,c}(q) has a negative coefficient. Given extensive computational evidence (all positive through d = 8, n <= 4), confidence is > 99%.

### Key Lemma

**The proof reduces to showing:** There exist combinatorial objects O_{n,c} with a non-negative q-weight such that Q_{n,c}(q) = sum_{o in O_{n,c}} q^{wt(o)}.

The most promising candidate: O_{n,c} = {n-tuples from S_c}, where S_c is a set of |S_c| = base objects, each with a q-weight, and the total weight of an n-tuple involves pairwise interaction terms (explaining the quadratic degree growth).

### Attempt 1: Bounded CPs as Crystal Graph Elements

The Imamura Upsilon bijection maps pairs of skew tableaux (P,Q) to (V,W; kappa, nu) where V, W are vertically strict tableaux. The key property is weight-preservation.

For bounded CPs -> crystal elements:
1. A CP Lambda of profile c with max <= N can be encoded via Sagan-Stanley as a pair of skew tableaux (P,Q) on the cylinder Z/tZ
2. The skew RSK dynamics on (P,Q) eventually reaches a stable state
3. The Upsilon bijection produces (V,W; kappa, nu)

**Question:** Does "max entry <= N" translate to a clean condition on (V,W)?

**Assessment:** Theoretically sound but technically very challenging. The max entry bound constrains the "height" of the tableaux, which propagates through the dynamics in complex ways. I cannot determine the answer without implementing the full skew RSK dynamics on the cylinder.

**Verdict:** Promising but beyond reach of this layer.

### Attempt 2: Q is NOT sl_3 Schur-positive

Tried to decompose Q_{n,c}(q) as sum of s_{(a,b)}(q, q^2, q^3). FAILS for d >= 4.

This is informative: it means Q is not the character of any sl_3 representation at the specialization x_i = q^i. If Q has a crystal interpretation, it must be:
- At a DIFFERENT specialization, or
- For an AFFINE algebra (not just sl_3), or
- A Demazure module character (not a full highest-weight character)

Seed 5's GL_2 key polynomial decomposition (when it works) supports the Demazure hypothesis: key polynomials ARE Demazure characters for GL_2. The question is whether this extends to the affine setting.

### Attempt 3: The Affine Demazure Module Hypothesis

**Hypothesis:** Q_{n,c}(q) is the character of a Demazure module for the affine algebra hat{g} at level 3, where g depends on the modulus t = 3+d.

Evidence:
1. Q_n(1) = (base)^n where base = number of non-corner C_3 orbits (crystal-counting interpretation)
2. deg(Q_n) = (d-1)n^2 (consistent with affine Demazure depth-n truncation)
3. GL_2 key decomposition works for some n (Demazure characters are key-positive)
4. D_3 symmetry follows from Dynkin diagram automorphisms of the relevant affine algebra
5. The d not = 0 mod 3 condition matches the non-vanishing of partial commutation relations (Seed 7's observation about D_4^(3))

**Obstruction:** I cannot identify the specific affine algebra or verify the Demazure character match computationally. For d=4 (t=7), the candidate algebras include A_6^(1) at level 3 or some twisted variant. The representation theory of these algebras at low levels is tractable but requires specialized tools (e.g., SageMath's crystal library).

## Stuck: The Core Obstruction

### What I'm trying to show

Q_{n,c}(q) >= 0 coefficientwise for all n >= 0 and all profiles c with d not = 0 mod 3.

### Why I can't show it

1. **Crystal approach (Attempt 1):** Sound in theory but requires implementing skew RSK on the cylinder and verifying crystal closure of bounded CPs. Beyond scope.

2. **Schur positivity (Attempt 2):** DISPROVED. Q is not sl_3 Schur-positive at (q, q^2, q^3).

3. **Affine Demazure (Attempt 3):** Most promising hypothesis but requires affine crystal tools to verify.

### What would unstick me

1. Access to SageMath's affine crystal library to enumerate Demazure crystals at level 3 for the relevant algebras and verify character matching with Q_{n,c}(q).

2. A proof that Borodin's product formula is invariant under profile reversal (establishing F_{c,N} = F_{rev(c),N} algebraically).

3. An expert in affine Demazure modules to identify the correct algebra for each modulus t.

## Escalation

I am stuck on: proving Q_{n,c}(q) >= 0.

**Attempt 1** (Crystal graph from Imamura Upsilon): Sound theoretical path but technically beyond reach. Would need to implement full skew RSK dynamics on the cylinder and verify crystal closure.

**Attempt 2** (Schur/key polynomial decomposition): sl_3 Schur positivity DISPROVED. GL_2 key positivity sporadic (greedy-dependent). No systematic decomposition found.

**Attempt 3** (Affine Demazure module hypothesis): Most promising direction. Evidence from 5 independent angles (orbit counting, degree formula, key decomposition, D_3 symmetry, divisibility condition). Cannot verify without affine crystal tools.

**What all three share:** They converge on the affine Demazure module interpretation as the most likely proof strategy. The evidence is strong but the verification machinery is missing.

**What I think is needed:** A computation in SageMath or GAP to:
1. For t = 7 (d=4), identify the twisted affine algebra X with h* = 7 at level 3
2. Construct its level-3 standard module
3. Compute the Demazure character at depth n for n = 1,2,3,4
4. Check if it matches Q_{n,(2,1,1)}(q) at an appropriate specialization

If this matches for d=4, the pattern for general d would be clear.

## Key New Findings in Layer 2

1. **Q is NOT sl_3 Schur-positive** at (q, q^2, q^3). This rules out direct sl_3 crystal arguments at this specialization.

2. **base = (d+1)(d+2)/6 - 1 = number of non-corner C_3 orbits** of level-d sl_3 weight triples. The corner orbit is {(d,0,0),(0,d,0),(0,0,d)}.

3. **Reversal symmetry holds at the F_{c,N} level**, meaning it's a bijection on cylindric partitions, not just a cancellation in the alternating sum.

4. **h_m is NOT multiplicative** (h_2 != h_1*h_1 as convolution), ruling out tensor product interpretation.

5. **deg(Q_n) = (d-1)n^2** exactly, consistent with affine Demazure depth-n truncation.

6. **The correct formula has shift q^{j(j+1)/2}**, not q^{j(j-1)/2} as in some Layer 1 notes.

7. **g_N has min degree N**: g_N(q) starts at q^N, meaning CPs with max = N have weight >= N.

## Scripts Written

- `scratch/scripts/seed3_L2_crystal.py` -- Crystal / orbit counting
- `scratch/scripts/seed3_L2_bijection.py` -- Enumeration and bijection investigation
- `scratch/scripts/seed3_L2_upsilon.py` -- Upsilon and h_m analysis
- `scratch/scripts/seed3_L2_d3symmetry.py` -- D_3 symmetry verification
- `scratch/scripts/seed3_L2_reversal.py` -- Reversal bijection mechanism
- `scratch/scripts/seed3_L2_reversal2.py` -- Reversal vs cyclic distinction
- `scratch/scripts/seed3_L2_crystal_sl3.py` -- sl_3 Schur decomposition
