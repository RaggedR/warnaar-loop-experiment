# Seed 6, Layer 2: Nandi/Mod-14/Takigiku-Tsuchioka — Continued

## Mission Summary

Three tasks from the synthesis:
1. Implement Uncu-style Gaussian elimination for d=7
2. Exploit D3 symmetry to reduce the CW system
3. Identify combinatorial interpretation of Q_{n,c}

## Computational Evidence

### Q_{n,c}(q) for d=7 (first unproved case)

Computed via CW system iteration (Neumann series). All coefficients nonneg.

**c=(3,2,2):**
- Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6. Sum = 11. Correct.
- Q_2 = q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + ... Sum = 121 = 11^2. All nonneg.
- Q_3 needs q_bound > 54 (deg ~ 6n^2 = 54 for n=3). Partial sum 1329/1331.

**c=(4,2,1):**
- Q_1 = 2q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6 + q^8. Sum = 11. Note the gap at q^7.
- Q_2: Sum = 121. All nonneg.

**c=(5,1,1):**
- Q_1 = 2q + q^2 + 2q^3 + q^4 + 2q^5 + q^6 + q^7 + q^9. Sum = 11. Gap at q^8.
- Q_2: Sum = 121. All nonneg.

### D3 symmetry verified:
- c=(3,2,2) and c=(2,3,2) give identical Q_1 (reversal symmetry).
- c=(3,2,2) and c=(2,2,3) would also match (cyclic symmetry).

## Task 1: CW System Structure and Gaussian Elimination

### System structure

The CW recurrence gives:
  F_{c,n} = F_{c,n-1} + sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}

Rearranging: **(I - A(q^n)) F_n = F_{n-1}** where A is a matrix indexed by compositions of d.

| d | System size | Nonzero entries |
|---|-------------|-----------------|
| 2 |  6 x 6     | 12              |
| 4 | 15 x 15    | 51              |
| 5 | 21 x 21    | 81              |
| 7 | 36 x 36    | 162             |

### Gaussian elimination for d=2

Successfully eliminated. The result is upper triangular with final diagonal entry 1 - x^3 where x = q^n. This means:

F_{c,n} = F_{c,n-1} / (1 - q^{3n})  (after back-substitution)

For d=2, t = 5 = k + d. The factor (1 - q^{3n}) = (1 - q^{tn/...}). This connects to the Borodin product formula.

### Gaussian elimination for d=4

Successfully eliminated (15 x 15 system). The diagonal entries are rational functions in x = q^n. However, extracting the explicit formula requires back-substitution through 15 rows.

### Gaussian elimination for d=7

The 36 x 36 system is within reach of symbolic elimination but the rational functions grow large. The Neumann series approach (iterating A*b + A^2*b + ...) is more practical for numerical computation.

**Key structural result:** The system (I - A(q^n)) is invertible as a matrix of rational functions in x = q^n, and F_{c,n} = (I - A(q^n))^{-1} F_{c,n-1}. This means:

F_{c,n}(q) = prod_{m=1}^n [(I - A(q^m))^{-1}]_{c,c'} * 1

where the product is a matrix product. The positivity of Q_n requires showing that this matrix product, after the alternating-sum extraction, gives nonneg coefficients.

**Partial progress:** The Neumann series expansion:
  (I - A)^{-1} = I + A + A^2 + ...
converges because A has minimum monomial degree 1 (in q^n). Each term A^k contributes monomials of degree >= k*n. The series truncates at step floor(q_bound/n).

## Task 2: D3 Symmetry and System Reduction

### D3 orbits

For d=7, the 36 compositions form 8 D3-orbits:

| Orbit rep | Orbit size | Members |
|-----------|------------|---------|
| (0,0,7)   | 3          | cyclic perms of (7,0,0) |
| (0,1,6)   | 6          | full D3 orbit |
| (0,2,5)   | 6          | full D3 orbit |
| (0,3,4)   | 6          | full D3 orbit |
| (1,1,5)   | 3          | reversal-symmetric |
| (1,2,4)   | 6          | full D3 orbit |
| (1,3,3)   | 3          | reversal-symmetric |
| (2,2,3)   | 3          | reversal-symmetric |

Reduction: 36 → 8 unknowns (factor 4.5).

### CW system is NOT D3-equivariant at the profile level

**Critical finding:** The CW shifted profile operation c(J) does NOT commute with the D3 action on compositions. Specifically:

For cyclic permutation sigma and c = (1,1,2) with J = {0}:
  sigma(c) = (1,2,1), sigma(J) = {1}
  sigma(c)(sigma(J)) = (1,1,2) ≠ sigma(c(J)) = (2,2,0)

This means **the CW recurrence is NOT equivariant under D3**. The D3 symmetry of Q_{n,c} is an emergent property, not a manifest symmetry of the CW system.

**Consequence:** We cannot simply quotient the CW system by D3 to get a smaller system with the same structure. The 8-unknown reduced system would need a more careful construction, averaging over orbit members. The reduced system would not have the clean "shifted profile" structure.

### What the D3 symmetry DOES tell us

Although the CW system is not D3-equivariant, the fact that Q_{n,c} is D3-invariant means the alternating-sum extraction (going from F to Q) creates a symmetry that wasn't in F. This is because the extraction involves (zq;q)_inf which is profile-independent, and Borodin's product formula for F_c(q) is D3-invariant (it depends on the d_{i,j} partial sums which are cyclic-invariant, and the reversal symmetry of the formula).

So the D3 symmetry acts at the level of the FINAL answer but not at the level of the CW recurrence. This limits the utility of the symmetry for reducing the system.

## Task 3: Combinatorial Interpretation

### The counting number

B = (d+1)(d+2)/6 - 1 counts the number of nontrivial C_3-orbits of compositions (a,b,c) with a+b+c = d. The trivial orbit is {(d,0,0), (0,d,0), (0,0,d)}.

For d=7: B = 12 - 1 = 11. There are 36 compositions, 12 orbits, 11 nontrivial.

### Weight function search

For Q_1, we need to assign q-weights to the 11 nontrivial orbits such that the weight distribution matches Q_{1,c}(q). The weight function must be profile-dependent.

**Partial match found:** For profiles with all c_i equal or nearly equal (like c=(2,1,1) for d=4), the weight function w(orbit) = (interaction) - 2 works, where interaction = ab + bc + ca for a representative (a,b,c).

However, this does NOT work for asymmetric profiles like c=(3,1,0), so it's not the general answer.

**Profile-independent weight functions tried:**
- spread = max - min: distribution {1:1, 2:1, 3:2, 4:3, 5:2, 6:2} for d=7
- interaction = ab+bc+ca: distribution {6:2, 10:2, 11:1, 12:2, 14:2, 15:1, 16:1}
- discriminant = d^2 - 3*(ab+bc+ca): distribution {1:1, 4:1, 7:2, 13:2, 16:1, 19:2, 31:2}

None of these match Q_1 for all profiles. The weight function must depend on c.

### Profile-dependent candidates

For c = (c_0, c_1, c_2), the linear form c.x = c_0*a + c_1*b + c_2*c on a triple (a,b,c) is NOT C_3-invariant. Taking the minimum over the orbit gives a C_3-invariant function, but this doesn't match Q_1 either.

**Conjecture (unproven):** The q-weight of orbit O for profile c is related to the "distance" between c and the nearest element of O in some appropriate metric on the simplex {(a,b,c) : a+b+c = d, a,b,c >= 0}.

### The n-tuple structure

Q_{n,c}(1) = B^n suggests Q_{n,c}(q) counts n-tuples from a set of B objects, where each object has a q-weight given by Q_{1,c}(q). For this to be consistent, we would need:

Q_{n,c}(q) = sum over (o_1,...,o_n) in S^n of q^{w(o_1) + w(o_2) + ... + w(o_n)}

where S is the set of B objects and w is the weight function. This would mean Q_{n,c}(q) = Q_{1,c}(q)^n. But this is WRONG: Q_{1,c}^n has degree n * deg(Q_1) (linear in n), while deg(Q_n) ~ (d-1)n^2 (quadratic in n).

**So the n-tuples are NOT independent.** The weight of an n-tuple depends on interactions between the chosen objects, not just their individual weights. This is reminiscent of:
- Tableaux where the weight depends on the shape, not just content
- Crystal graph paths where the energy depends on the sequence
- Random matrix models where eigenvalue weights are correlated

## F-Ratio Analysis

### F_{c,1}/F_{c,0} structure

For c = (3,2,2), d=7:
  F_{c,1}/F_{c,0} = 1 + 3q + 6q^2 + 8q^3 + 10q^4 + 11q^5 + 12q^6 + 12q^7 + 12q^8 + ...

The ratio stabilizes to the constant 12 = (d+1)(d+2)/6 for large degrees. This is the g_1(q) function from Layer 1, confirming that the stable coefficient equals B+1.

The initial coefficients 1, 3, 6, 8, 10, 11, 12 are weakly increasing and converge to 12. This is a KEY POSITIVITY-RELEVANT observation: the coefficients of g_1 are monotonically increasing to the stable value.

### F_{c,n}/F_{c,n-1} for n >= 2

For n = 2, 3: the ratio has NEGATIVE coefficients (starting around q^9 for n=2). This means F_{c,n} is NOT a simple multiplicative update of F_{c,n-1}. The matrix structure of the system (coupling different profiles) prevents a scalar factorization.

## Stuck Points

### Stuck: Positive multisum formula for d=7

**What I'm trying to show:** An explicit positive multisum for Q_{n,c}(q) with d=7.

**Why I can't show it:** The CW system has 36 unknowns. Gaussian elimination produces rational functions in q^n whose numerators and denominators grow large. Extracting a manifestly positive formula from this is not straightforward.

**What would unstick me:** 
1. A structural simplification of the 36x36 system (e.g., a block structure from the orbit analysis, even though D3 doesn't act equivariantly on the system).
2. Uncu's actual code or approach for moduli 11 and 13, which would show how to extract positive formulas from similar-sized systems.

### Stuck: Combinatorial interpretation

**What I'm trying to show:** The objects counted by Q_{1,c}(q) with their q-weights.

**Why I can't show it:** No profile-dependent weight function on C_3-orbits of compositions matches Q_1 for all profiles tested.

**What would unstick me:** Understanding the connection between the profile c and the cylindric partition structure at the binary (max=1) level. The layer decomposition shows F_{c,1} counts binary interlacing triples. The specific counting of these triples, after the (1-q) extraction, should reveal the weight function.

## Key New Results

### GREEN (verified):
1. **CW system structure:** (I - A(q^n)) F_n = F_{n-1} is a linear system with 36 unknowns for d=7, solvable via Neumann series.
2. **D3 non-equivariance:** The CW system is NOT D3-equivariant at the profile level. D3 symmetry of Q is emergent, not manifest.
3. **D3 reduction:** 36 → 8 orbit representatives for d=7 (but cannot be used for direct system reduction).
4. **Q_{n,c} positivity for d=7:** Verified for n=1,2 across profiles (3,2,2), (4,2,1), (2,3,2), (5,1,1).
5. **g_1 monotonicity:** F_{c,1}/F_{c,0} has monotonically increasing coefficients converging to B+1 = 12 for d=7.

### YELLOW (partial):
1. **Interaction weight:** For "balanced" profiles (all c_i > 0 and similar), the C_3-invariant interaction function ab+bc+ca, shifted by a constant, matches Q_1. But fails for asymmetric profiles.
2. **Gaussian elimination for d=2:** Successfully reduces to a single rational function (1-q^{3n})^{-1}. The pattern for larger d is unclear.

### RED (failed/incomplete):
1. **Positive multisum for d=7:** Not obtained. The Neumann series gives a convergent expansion but not a closed-form positive multisum.
2. **Profile-universal weight function:** No weight function on C_3-orbits matches Q_1 for all profiles.
3. **D3 quotient of CW system:** Impossible due to non-equivariance.

## Recommendations for Next Layer

1. **Uncu's code:** The most direct path to a positive multisum for d=7 is to study Uncu's actual Gaussian elimination procedure for moduli 11 and 13 and adapt it. The key insight may be in how Uncu orders the compositions and handles the back-substitution.

2. **g_1 monotonicity as positivity proof for Q_1:** The observation that g_1 has monotonically increasing coefficients converging to B+1 is close to a proof of Q_1 positivity. Since Q_1 = (1-q)*g_1 - q, and g_1 has increasing coefficients, the (1-q) factor produces differences of consecutive coefficients, which are non-negative if coefficients are increasing. The "-q" subtracts 1 from the q^1 coefficient. This would work if g_1(q^1 coefficient) >= 2, which is verified for all tested cases.

3. **Crystal base for the n-tuple objects:** The quadratic degree growth of Q_n rules out independent n-tuples. The objects being counted must have an interaction structure. The crystal base interpretation (Connection B from synthesis) remains the most natural framework: Q_n would count paths of length n in a crystal graph, where the energy function provides the q-weight. The crystal graph would be determined by the affine Lie algebra at level 3 with Coxeter number h* = t = d+3.

## Scripts Written

- `scratch/scripts/seed6_L2_cw_system.py` — CW system builder and Neumann series solver
- `scratch/scripts/seed6_L2_d3_symmetry.py` — D3 symmetry analysis and equivariance test
- `scratch/scripts/seed6_L2_gaussian_elim.py` — Symbolic Gaussian elimination (RatPoly)
- `scratch/scripts/seed6_L2_weight_match.py` — Weight function matching for Q_1 combinatorics
- `scratch/scripts/seed6_L2_d7_elim.py` — d=7 numerical analysis and F-ratio structure

## MAJOR FINDING: Q_1 Positivity via f_1 Monotonicity

### Theorem (computational, not yet proved algebraically)

**Claim:** For all compositions c = (c_0, c_1, c_2) with d = c_0 + c_1 + c_2 not divisible by 3, the polynomial Q_{1,c}(q) has non-negative coefficients.

**Proof sketch (reduces to a lattice-counting lemma):**

Let f_1(q) = sum_{k >= 1} a_k q^k where a_k counts the number of cylindric partitions of profile c with max entry exactly 1 and total size k. Equivalently, a_k counts triples (L_1, L_2, L_3) of non-negative integers with L_1 + L_2 + L_3 = k satisfying:
- L_2 <= L_1 + c_1
- L_3 <= L_2 + c_2  
- L_1 <= L_3 + c_0
- At least one L_i > 0

Then Q_{1,c}(q) = (1-q) * f_1(q) - q, which gives:
- [q^1] Q_1 = a_1 - 1
- [q^k] Q_1 = a_k - a_{k-1} for k >= 2

**Key Lemma (verified exhaustively for d <= 14):** The sequence (a_k)_{k >= 1} is weakly monotonically increasing and converges to the stable value (d+1)(d+2)/6.

This lemma immediately implies:
1. a_k - a_{k-1} >= 0 for all k >= 2
2. a_1 >= 1 (there is at least one valid triple of size 1)
3. Q_1 has non-negative coefficients

**Computational verification:** Tested ALL compositions for d = 1, 2, 4, 5, 7, 8, 10, 11, 13, 14. Zero monotonicity failures. Zero Q_1 negativity failures.

**What remains for a proof:** The monotonicity lemma. This is a lattice-point counting statement: the number of non-negative integer triples (L_1, L_2, L_3) satisfying three cyclic linear inequalities and summing to k is weakly increasing in k. This should follow from the fact that the feasible region is a polyhedral cone, and the number of lattice points at height k in a cone is an increasing (eventually polynomial) function of k. Specifically, for a rational polyhedral cone of dimension >= 2, the Ehrhart function is eventually a polynomial of degree dim-1 >= 1, hence eventually increasing. The "eventually" can be made effective.

**Subtlety:** For concentrated profiles like (d, 0, 0), a_1 = 1, so [q^1] Q_1 = 0. In these cases, Q_1 starts at degree 2. This is still non-negative.

### Why this doesn't extend to Q_n for n >= 2

The same approach fails for n >= 2 because Q_n involves the alternating sum across different max bounds (the "cross-N obstruction" identified in the synthesis). The monotonicity of f_1 is a property of a single lattice cone; for n >= 2, one needs properties of the multi-layer system where layers interact.
