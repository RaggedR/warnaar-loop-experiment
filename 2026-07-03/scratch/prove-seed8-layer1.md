# Seed 8, Layer 1: Plane Partition / Lozenge Tiling Approach

## Computational Evidence

### Working computation established
Using the Corteel-Welsh functional equation iteratively (script: `scratch/scripts/seed8_iterative_CW.py`), I computed Q_{n,c}(q) correctly for multiple profiles and verified:

**Proved cases (matching known results):**
- d=2, c=(1,1,0): Q_n = q^{n^2} (monomial). Q(1) = 1^n. ALL POSITIVE.
- d=4, c=(2,1,1): Q_1 = 2q + q^2 + q^3, Q_2 = q^3 + 3q^4 + ... + q^{12}. Q(1) = 4^n. ALL POSITIVE.
- d=5, c=(2,2,1): Q_1 = 2q + 2q^2 + q^3 + q^4. Q(1) = 6^n. ALL POSITIVE.

**Unproved cases (new computational verification):**
- d=7, c=(3,2,2): Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6. Q(1) = 11^1 = 11. ALL POSITIVE for n=0,1,2.
- d=7, c=(4,2,1): Q_1 = 2q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6 + q^8. Q(1) = 11. ALL POSITIVE for n=0,1,2.
- d=8, c=(3,3,2): Q_1 = 2q + 3q^2 + 3q^3 + 2q^4 + 2q^5 + q^6 + q^7. Q(1) = 14. ALL POSITIVE for n=0,1,2.

**Key technical achievement:** The earlier direct enumeration approaches (used by seeds 1, 2, 5) all failed due to truncation of partition lengths. The Corteel-Welsh recurrence avoids this by computing F_{c,n}(q) exactly via a coupled system of equations over all profiles with the same total d. The crucial identity is:

  [y^n](F_{c(J)}(yq^s, q) / (1-yq^s)) = q^{ns} * F_{c(J),n}(q)

which converts the recurrence into a linear system for the cumulative GFs B_n(c) = F_{c,n}(q).

### Structural patterns in Q_n

| d | Q_1 coefficients | Q_1(1) | Min deg(Q_n) sequence | Leading coeff pattern |
|---|-----------------|--------|----------------------|---------------------|
| 2 | [1] at q^1 | 1 | 0, 1, 4, 9, 16 (= n^2) | 1, 1, 1, 1, 1 |
| 4 | [2, 1, 1] | 4 | 0, 1, 3, 7, 12 | 1, 2, 1, 2, 1 |
| 5 | [2, 2, 1, 1] | 6 | 0, 1, 3, 7, 12 | 1, 2, 1, 2, 1 |
| 7 | [2, 3, 2, 2, 1, 1] | 11 | 0, 1, 3 | 1, 2, 1 |
| 8 | [2, 3, 3, 2, 2, 1, 1] | 14 | 0, 1, 3 | 1, 2, 1 |

Key: Q_1 always starts with coefficient 2 (at q^1) and ends with coefficient 1 (at q^{d-1}).

**The min degree pattern 0, 1, 3, 7, 12 for d >= 4** does not match standard formulas like n^2 or T_n = n(n+1)/2. The differences are 1, 2, 4, 5 — possibly related to the structure of the cylinder.

## Approach

### Angle of attack: Nonintersecting lattice paths on the cylinder

The Hopkins-Lai paper (my seed context) establishes that:
1. Plane partitions of shape lambda <-> lozenge tilings of a hexagonal region
2. Shifted plane partitions <-> free-boundary lozenge tilings
3. Lozenge tilings <-> nonintersecting lattice paths (via Lindstrom-Gessel-Viennot)

**Cylindric partitions** are periodic plane partitions on a cylinder of circumference t = k + d. The boundedness constraint (max <= n) limits the "height" of the tiling. The profile c determines the shape of the fundamental domain.

The polynomial Q_{n,c}(q) is obtained by:
1. Taking F_c(z,q) = sum_Lambda q^|Lambda| z^max(Lambda) (cylindric partition GF)
2. Multiplying by (zq;q)_inf = prod_{j>=1} (1-zq^j)
3. Extracting [z^n] and multiplying by (q;q)_n

The (zq;q)_inf factor creates an inclusion-exclusion over the "top boundary" — it removes cylindric partitions whose top rows have certain sizes. The miracle of positivity is that this sieve always leaves a nonneg count.

### What a counterexample would look like
A counterexample would be a specific profile c = (c_0, c_1, c_2) with d not divisible by 3, and a specific n, such that Q_{n,c}(q) has a negative coefficient. The computational evidence strongly suggests no such counterexample exists.

## Strategy

### Candidate strategies

1. **Transfer matrix / nonintersecting paths (Hopkins-Lai style):**
   - Might work because: cylindric partitions have a natural transfer matrix description where states are cross-sections of the cylinder. The characteristic polynomial of this matrix should relate to Q_{n,c}(q).
   - Might not work because: the cylinder creates periodic boundary conditions that complicate the LGV lemma. The transfer matrix approach works for specific shapes (flashlight regions) but may not give manifestly positive formulas for general cylindric profiles.

2. **Involution principle on (zq;q)_inf cancellation:**
   - Might work because: the (-1)^m signs in the Euler expansion could be cancelled by a sign-reversing involution, leaving only positive contributions.
   - Might not work because: constructing such an involution seems to require understanding the global structure of cylindric partitions, not just local moves.

3. **Crystal base / representation theory (sl_3 modules):**
   - Might work because: the formula Q(1) = ((d+1)(d+2)/6 - 1)^n involves the number (d+1)(d+2)/6 which counts C_3-orbits of sl_3 dominant weights. The -1 removes a "trivial" representation.
   - Might not work because: connecting the q-series to crystal bases requires identifying the right module, which hasn't been done.

4. **Induction on n via the CW recurrence:**
   - Might work because: the iterative solution shows that B_n(c) is built from B_{n-1}(c) plus correction terms involving q-shifts. If positivity propagates through this recurrence, we'd be done.
   - Might not work because: the recurrence involves a system of equations across all profiles, and the coupling makes induction non-trivial.

### Chosen strategy: Hybrid (Strategy 1 + 4)

I'll pursue the **transfer matrix approach for the bounded cylindric partition**, combined with the iterative structure of the CW recurrence. The idea:

The CW recurrence gives:
  B_n(c) = B_{n-1}(c) + sum_{terms} sign * q^{ns} * B_n(c(J))

This shows that B_n(c) is obtained from B_{n-1}(c) plus "incremental" terms that encode the contribution of cylindric partitions whose maximum value is exactly n. The q^{ns} factor shifts by n*|J|, which is the area added by one more layer of the cylinder.

From the transfer matrix perspective, each "layer" added is a cross-section of the cylinder. The state space of the transfer matrix consists of all valid cross-sections (tuples of partition parts at each position around the cylinder). The eigenvalues/singular values of this matrix should relate to the roots of Q_1(q).

## Key Lemma

**The proof reduces to showing that the incremental contribution**
  delta_n(c) = B_n(c) - B_{n-1}(c)
**is "compatible" with the (q;q)_n * sum (-1)^m q^{T_m} / (q;q)_m convolution in the sense that the alternating signs cancel to leave nonneg coefficients.**

More precisely: the delta_n(c) terms satisfy a positivity condition when convolved with the Euler function, because they encode lattice paths on the cylinder that are "frozen at height n" — paths that touch the ceiling but can't go higher. The (zq;q)_inf factor removes the unfrozen paths, leaving exactly the frozen ones, which have manifestly positive weights.

## Stuck: 2026-07-03

### What I'm trying to show
That Q_{n,c}(q) has nonneg coefficients for all n and all c = (c_0,c_1,c_2) with d not div by 3.

### Why I can't show it
The convolution Q_{n,c} = (q;q)_n * sum_m (-1)^m q^{T_m} / (q;q)_m * b_{n-m} involves alternating signs. While each b_j is manifestly positive (it counts cylindric partitions), the (-1)^m creates cancellation. The key difficulty is that no involution or bijective cancellation has been identified.

### What would unstick me
One of the following:
1. A combinatorial interpretation of Q_{n,c}(q) as a SINGLE positive sum (not an alternating sum). This would require finding the right set of objects that Q counts.
2. A proof that the transfer matrix eigenvalue structure forces positivity. Specifically, if Q_n = sum_i lambda_i^n where lambda_i are polynomials in q with nonneg coefficients, then positivity follows from multiplicativity.
3. An explicit involution on cylindric partitions that cancels all the negative terms in the Euler convolution.

### Attempt 1: Transfer matrix eigenvalue decomposition

For d=2, Q_n = q^{n^2}. This is a SINGLE eigenvalue: lambda_1 = q (the only eigenvalue, raised to power n gives q^n, but n^2 not n... so lambda = q^n?). Actually Q_n = (q^n)^n -- no, Q_0 = 1, Q_1 = q, Q_2 = q^4, Q_3 = q^9. So Q_n = q^{n^2}. This is not lambda^n for any fixed lambda.

But maybe Q_n is a sum of terms like lambda_i(q)^n? For d=4:
- Q_0 = 1
- Q_1 = 2q + q^2 + q^3
- Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^{10} + q^{12}

If Q_n = sum_i alpha_i * (lambda_i)^n, then Q_0 = sum alpha_i = 1 and Q_1 = sum alpha_i * lambda_i.

But Q_0 = 1 is a single monomial while Q_1 has multiple terms. So either multiple eigenvalues contribute, or the "eigenvalues" are themselves polynomials in q.

Actually, Q_1(1) = 4 and Q_2(1) = 16 = 4^2, Q_3(1) = 64 = 4^3. So at q=1, it's a SINGLE eigenvalue 4 with multiplicity 1 (i.e., alpha = 1). This means at q=1, the transfer matrix (at the level of the Q extraction) has a single relevant eigenvalue.

**The question becomes**: Can we find a q-deformation where Q_n = sum_i alpha_i(q) * lambda_i(q)^n with all alpha_i and lambda_i having nonneg q-coefficients?

For d=4:
- We need Q_0 = sum alpha_i = 1
- Q_1 = sum alpha_i * lambda_i = 2q + q^2 + q^3 = 4 at q=1

If there were 4 "eigenvalues" lambda_1 = q, lambda_2 = q, lambda_3 = q^2, lambda_4 = q^3, each with alpha_i = 1, we'd need sum alpha_i = 4, not 1. So the alphas can't all be 1.

Alternatively, one eigenvalue with alpha = 1: Q_n = lambda^n where lambda = 2q + q^2 + q^3.
Then Q_2 should be lambda^2 = (2q + q^2 + q^3)^2 = 4q^2 + 4q^3 + 5q^4 + 2q^5 + 2q^6 + q^6.
But Q_2 = q^3 + 3q^4 + ... which starts at q^3, not q^2. So Q_n != Q_1^n.

This approach doesn't work directly. The transfer matrix doesn't have polynomial eigenvalues in the simple sense.

### Key insight from the computation

The iterative CW solution reveals that B_n(c) (the cumulative GF) satisfies:
  B_n(c) = B_{n-1}(c) + sum_J sign(J) * q^{n|J|} * B_n(c(J))

This is a fixed-point equation. The q^{n|J|} factor means that the coupling between profiles shifts by at least n. So for q-degrees below n, B_n(c) = B_{n-1}(c) — the new layer doesn't affect low degrees.

The iteration converges because each step shifts the q-degree by n, so after max_q/n steps we've captured all contributions.

**This iterative structure is the key to any proof.** The Q polynomial is built layer by layer, and each layer's contribution is positive if the previous layer's is.

### What I need to test next
1. Verify whether the "per-layer" contribution delta_n(c) = B_n(c) - B_{n-1}(c) has a manifestly positive structure.
2. Look at whether the (q;q)_n convolution can be absorbed into the CW recurrence to give a manifestly positive recursion for Q_n directly.

## Attempt 2: Direct recursion for Q_n

The quantity we want is:
  Q_{n,c} = (q;q)_n * sum_{m=0}^n (-1)^m q^{T_m} / (q;q)_m * b_{n-m}
           = sum_{m=0}^n (-1)^m q^{T_m} * [(q;q)_n / (q;q)_m] * b_{n-m}
           = sum_{m=0}^n (-1)^m q^{T_m} * (q^{m+1};q)_{n-m} * b_{n-m}

where T_m = m(m+1)/2 and (q^{m+1};q)_{n-m} = prod_{j=m+1}^n (1-q^j).

This is a finite alternating sum. Each term involves:
- The Euler factor (-1)^m * q^{T_m}
- The "tail" of (q;q)_n: (q^{m+1};q)_{n-m}
- The [z^{n-m}] coefficient of F_c

Can we find a recursion for Q_n in terms of Q_{n-1}?

Q_n - Q_{n-1}: the difference involves the new b_n term and the change in the tail factors.
This seems messy and not obviously positive.

## Attempt 3: Lozenge tiling interpretation of Q_{n,c}(q)

Coming back to my seed context: the key idea in Hopkins-Lai is that plane partitions correspond to lozenge tilings. For BOUNDED plane partitions (max <= n), the tiling fits in a finite region.

For cylindric partitions with max <= n:
- The cylindric partition wraps around a cylinder of circumference t = k+d
- The max bound n limits the "height" to n layers
- This gives a tiling of a finite cylindrical region

The polynomial F_{c,n}(q) = B_n(c) counts these tilings by total area.

The extraction [z^n]((zq;q)_inf * F_c(z,q)) = sum_m (-1)^m q^{T_m}/(q;q)_m * b_{n-m} is an alternating convolution. From the tiling perspective:

(zq;q)_inf = prod_{j>=1}(1-zq^j) is a "sieve" operator. It removes contributions that can be "peeled off" from the top.

**Tiling interpretation**: A cylindric partition with max = n has a "ceiling" at height n. The parts of size n form the top layer. The (1-zq^j) factors remove configurations where the top layer can be extended — i.e., where there's room to add a part of size j.

**The residue after the sieve**: Q_{n,c}(q) counts "rigid" cylindric tiling configurations — those where the top layer is frozen (can't be extended or reduced). These are configurations at "saturation" for the height-n constraint.

This is speculative. Testing it: for d=2, Q_n = q^{n^2} means exactly one frozen configuration for each n, with total area n^2. For d=4, Q_1 = 2q + q^2 + q^3 means 4 frozen configurations at height 1, with areas 1, 1, 2, 3.

**Can I identify these 4 frozen configurations?**

For c = (2,1,1) with max = 1, a cylindric partition is three partitions (lam^0, lam^1, lam^2) with parts in {0,1} satisfying:
- lam^0_j >= lam^1_{j+1} (c_1 = 1)
- lam^1_j >= lam^2_{j+1} (c_2 = 1)
- lam^2_j >= lam^0_{j+2} (c_0 = 2)

With parts in {0,1}, each partition is of the form (1,1,...,1,0,0,...) with some number of 1s.

Say lam^i has a_i ones: lam^i = (1^{a_i}).

The interlacing conditions with max 1:
- lam^0_j >= lam^1_{j+1}: a_0 >= a_1 + 1, i.e., a_0 > a_1 (or lam^0 has at least one more 1 than lam^1 shifted by 1)

Actually more carefully: lam^0 = (1,...,1,0,...) with a_0 ones.
lam^0_j = 1 if j <= a_0, 0 if j > a_0.
lam^1_{j+1} = 1 if j+1 <= a_1, 0 if j+1 > a_1, i.e., 1 if j <= a_1-1.
Condition: lam^0_j >= lam^1_{j+1} for all j >= 1.
This fails when lam^0_j = 0 and lam^1_{j+1} = 1, i.e., j > a_0 and j <= a_1 - 1.
So we need: a_0 >= a_1 - 1, i.e., a_1 <= a_0 + 1.

Similarly: lam^1_j >= lam^2_{j+1}, so a_2 <= a_1 + 1.
And: lam^2_j >= lam^0_{j+2}, so we need: for all j, lam^2_j >= lam^0_{j+2}.
lam^2_j = 1 if j <= a_2. lam^0_{j+2} = 1 if j+2 <= a_0, i.e., j <= a_0 - 2.
Condition: a_2 >= a_0 - 2, i.e., a_0 <= a_2 + 2.

Combining: a_1 <= a_0 + 1, a_2 <= a_1 + 1, a_0 <= a_2 + 2.
Also a_0, a_1, a_2 >= 0.

And max = max(lam^0_1, lam^1_1, lam^2_1) = 1 iff at least one of a_0, a_1, a_2 > 0.

Size = a_0 + a_1 + a_2.

Enumerating:
- a_0 = 0: a_1 <= 1, a_2 <= a_1+1, a_0 <= a_2+2 => a_2 >= -2 (ok).
  - a_1=0: a_2 <= 1. a_2=0: size=0, max=0 (this is the empty partition, contributes to b_0 not b_1).
    a_2=1: size=1, max=1. Valid!
  - a_1=1: a_2 <= 2. a_2=0: ok. size=1, max=1. Valid!
    a_2=1: size=2, max=1. Valid!
    a_2=2: size=3, max=1. Valid! (Check: a_0=0 <= a_2+2=4, yes)
- a_0 = 1: a_1 <= 2, a_2 <= a_1+1, a_0=1 <= a_2+2 => a_2 >= -1 (ok).
  - a_1=0: a_2 <= 1.
    a_2=0: size=1, max=1. Check a_0=1 <= a_2+2=2, yes. Valid!
    a_2=1: size=2, max=1. Valid!
  - a_1=1: a_2 <= 2.
    a_2=0: size=2, max=1. Valid!
    a_2=1: size=3, max=1. Valid!
    a_2=2: size=4, max=1. Valid!
  - a_1=2: a_2 <= 3.
    a_2=0: a_0=1 <= 2. size=3. Valid!
    a_2=1: size=4. Valid!
    a_2=2: size=5. Valid!
    a_2=3: size=6. Valid!
- a_0 = 2: a_1 <= 3, a_0=2 <= a_2+2 => a_2 >= 0.
  - a_1=0: a_2 <= 1. a_2=0: size=2. a_2=1: size=3.
  - ...this grows without bound as a_i increase!

Wait, but we said max = 1. With parts in {0,1}, we can have arbitrarily many parts. So there are infinitely many cylindric partitions with max = 1 for d=4. The GF b_1(q) = sum q^{size} over all such, which is an INFINITE sum (a power series, not a polynomial). The computation must be handling this correctly through the CW recurrence.

So b_1 is a power series, not a polynomial. But Q_{1,c}(q) = (q;q)_1 * (b_1 - q*inv(q;q)_1 * b_0) = (1-q) * (b_1 - ... ) turns out to be a polynomial. The cancellation of the infinite series to get a finite polynomial is the miracle.

This means the "frozen configuration" interpretation needs refinement. Q_n is not simply counting a finite set of tilings; it's the result of an infinite cancellation.

## Summary of findings

1. **Computation works.** The CW iterative approach gives exact Q_{n,c}(q) polynomials. All tested cases (including unproved d=7, d=8) show positivity.

2. **No simple q-binomial decomposition exists.** Q_1 is not a product or simple sum of q-binomials in general.

3. **The min degree pattern** (0, 1, 3, 7, 12 for d >= 4) and leading coefficient pattern (1, 2, 1, 2, 1) suggest some underlying structure, but I haven't identified it.

4. **The plane partition/lozenge tiling perspective** gives a geometric picture but doesn't directly yield a positivity proof, because:
   - The (zq;q)_inf sieve creates an infinite alternating sum
   - The result is finite (polynomial) due to cancellation
   - Making this cancellation manifest requires either an involution or a completely different combinatorial interpretation

5. **The iterative CW structure** is the most promising avenue: B_n(c) is built from B_{n-1}(c) plus q-shifted corrections. If Q_n could be shown to inherit positivity from Q_{n-1} through this recurrence, the conjecture would follow.

## Escalation

I am stuck on: finding a manifestly positive formula for Q_{n,c}(q) in the general case.

**Attempt 1** (Transfer matrix eigenvalues): Failed because Q_n is not lambda^n for any single eigenvalue lambda. The structure is more complex.

**Attempt 2** (Direct recursion for Q_n): The Q_n - Q_{n-1} difference is not manifestly positive in the simple recursion.

**Attempt 3** (Lozenge tiling interpretation): The b_j generating functions are infinite series (not polynomials), so the "frozen configuration" interpretation requires understanding an infinite cancellation, which is exactly the difficulty of the original problem.

**What all three have in common**: They all run into the fundamental difficulty that Q_{n,c}(q) is defined as an alternating sum of positive quantities. Making the positivity manifest requires either (a) a bijective cancellation of the negative terms, or (b) a completely different representation of Q that avoids the alternation.

**What I think is needed**: The most promising angle from the plane partition perspective is to find a SET of combinatorial objects (perhaps decorated lattice paths on the cylinder, or restricted lozenge tilings with specific boundary conditions) whose q-weighted count is exactly Q_{n,c}(q). Hopkins-Lai's work on flashlight regions and free-boundary tilings suggests that such regions exist for specific shapes. The challenge is to identify the right region for the general cylindric case.

An alternative: the representation-theoretic angle. The number (d+1)(d+2)/6 - 1 is the number of nontrivial C_3-orbits of sl_3 level-d dominant weights. If Q_{n,c}(q) is the character of an n-fold tensor product restricted to a specific weight space, positivity would follow from the representation theory. This connects to the crystal base approach.
