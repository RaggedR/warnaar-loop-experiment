# Prove — Seed 7 (Vertex Operators, D₄⁽³⁾, Tsuchioka), Layer 2

## Mission Recap

Layer 2 tasks from synthesis:
1. Identify the twisted affine algebra for d=7 (t=10)
2. Construct the level-3 standard module (or its character)
3. Make the mod-3 condition precise algebraically
4. Z-algebra bounded vacuum space

## Computational Evidence

### Q_{n,(3,2,2)}(q) for d=7, t=10 (COMPUTED)

Using the iterative Corteel-Welsh system (36 profiles at d=7, solved simultaneously):

- Q₀ = 1
- Q₁ = 2q + 3q² + 2q³ + 2q⁴ + q⁵ + q⁶  [sum = 11 ✓]
- Q₂ = q³ + 5q⁴ + 7q⁵ + 10q⁶ + 10q⁷ + 12q⁸ + 10q⁹ + 11q¹⁰ + 9q¹¹ + 9q¹² + 7q¹³ + 7q¹⁴ + 5q¹⁵ + 5q¹⁶ + 3q¹⁷ + 3q¹⁸ + 2q¹⁹ + 2q²⁰ + q²¹ + q²² + q²⁴  [sum = 121 ✓]

ALL NONNEGATIVE for n = 0, 1, 2. (n=3 needs higher truncation.)

### Q_{n,(4,2,1)}(q) for d=7, t=10

- Q₀ = 1
- Q₁ = 2q + 2q² + 2q³ + 2q⁴ + q⁵ + q⁶ + q⁸  [sum = 11 ✓]
- Q₂ verified nonneg, sum = 121 ✓

### h_m(q) for (3,2,2), d=7

- h₀ = 1
- h₁ = 3q + 3q² + 2q³ + 2q⁴ + q⁵ + q⁶  [sum = 12 = (d+1)(d+2)/6 ✓, ALL NONNEG]
- h₂ = 3q² + 6q³ + 10q⁴ + 11q⁵ + 13q⁶ + 12q⁷ + ... [sum = 144 = 12² ✓, ALL NONNEG]

### h_m(q) for (4,2,1), d=7

- h₀ = 1
- h₁ = 3q + 2q² + 2q³ + 2q⁴ + q⁵ + q⁶ + q⁸  [sum = 12 ✓, ALL NONNEG]
  Note the gap at q⁷ and the isolated q⁸ term!
- h₂: sum = 144, ALL NONNEG

### d ≡ 0 mod 3 cases (EXCLUDED FROM CONJECTURE)

Computed Q_{n,c}(q) for d = 3 (profiles (1,1,1), (2,1,0), (3,0,0)) and d = 6 ((2,2,2)):

**Surprise**: Q_{n,c}(q) is ALSO nonnegative in all computed cases!

- d=3, c=(1,1,1): Q₁(1) = 7, Q₂(1) = 49, Q₃(1) = 343 = 7³. All nonneg.
- d=3, c=(2,1,0): Same Q values. All nonneg.
- d=6, c=(2,2,2): Q₁(1) = 25, Q₂(1) = 625. All nonneg.

**The exclusion d ≢ 0 mod 3 is NOT about positivity failing.** It's about the evaluation formula:
(d+1)(d+2)/6 is NOT an integer when d ≡ 0 mod 3, so the stated formula Q(1) = ((d+1)(d+2)/6 - 1)^n is undefined. When d ≡ 0 mod 3, ell = gcd(d,3) = 3, and the evaluation at q=1 gives a different base (7ⁿ for d=3, 25ⁿ for d=6). The positivity itself appears to hold for ALL d.

**This is a significant observation**: the conjecture could potentially be strengthened to remove the d ≢ 0 mod 3 restriction (with a modified evaluation formula).


## 1. Identifying the Algebra for d=7 (t=10)

### Borodin Product Analysis

For c = (3,2,2), d=7, t=10, Borodin's product formula gives denominators at residues mod 10:
- Residue 4: multiplicity 2
- Residue 5: multiplicity 3
- Residue 6: multiplicity 2
- Residue 7: multiplicity 1
- Residue 8: multiplicity 1
- Residue 9: multiplicity 1

Missing residues (appear in F_c(q)·(q;q)_∞ numerator): {1, 2, 3}

The multiplicities exceed 1, so F_c(q) is NOT the principally specialized character of a level-1 affine module. This rules out the naive "A_{t-1}^(2) at level 1" identification.

### The Correct Framework

The Andrews-Schilling-Warnaar identity states:
- F_c(q) has a product formula (Borodin)
- Multiplying by appropriate eta-products gives a character

For k=3 parts, the relevant object is the character of a HIGHER-LEVEL module. Specifically:

The Borodin product for k=3, profile c = (c₀, c₁, c₂), has:
- Overall factor: 1/(q^t; q^t)_∞
- Additional factors: products of 1/(q^a; q^t)_∞ with specific residues and multiplicities

The total number of denominator factors (counting multiplicity) plus the (q^t;q^t) factor is:
- First product: Σ_{i<j} c_i = c₀(k-1) + c₁(k-2) + ... [depends on profile]
- Second product: similar

For c = (3,2,2): 8 + 2 + 1 = 11 factors total.

The rank of the denominator (number of independent (q^a; q^t) factors minus redundancies) determines the rank of the affine algebra.

### Candidate: ŝl₃ (= A₂⁽¹⁾) at level d

**Key observation**: For k = 3 cylindric partition components, the underlying symmetry is A₂ (= sl₃). The cylindric condition wraps around 3 partitions cyclically, which is the Weyl group action of Z₃ ⊂ S₃.

At level d = c₀ + c₁ + c₂, the standard modules of A₂⁽¹⁾ = ŝl₃ have characters that naturally produce products at modulus t = 3 + d.

**Why A₂⁽¹⁾ and not a twisted algebra?** The cylindric partition setup with k=3 parts inherently has A₂ symmetry (cyclic permutation of 3 objects). The twist would come from the specific profile c, which determines which highest weight module we're in.

The level-d standard modules of ŝl₃ have:
- Highest weights: Λ = a₀Λ₀ + a₁Λ₁ + a₂Λ₂ with a₀ + a₁ + a₂ = d
- The profile c = (c₀, c₁, c₂) should correspond to the weight (c₀, c₁, c₂).

If this is correct, then:
- Q_{n,c}(q) = graded dimension of the bounded vacuum space of the Z-algebra of the ŝl₃ level-d standard module V(c₀Λ₀ + c₁Λ₁ + c₂Λ₂), bounded at depth n.

### Evidence for ŝl₃ identification

1. The number (d+1)(d+2)/6 counts the lattice points in the fundamental domain of ŝl₃ weight lattice at level d modulo the Weyl group action. This is exactly dim(Sym^d(ℂ³))/S₃ ... no, it's the number of dominant integral weights at level d, which is the number of non-negative integer triples summing to d, i.e., the stars-and-bars count C(d+2,2) = (d+1)(d+2)/2. Then dividing by |W| = 6 gives (d+1)(d+2)/6, which is exactly our number!

Wait, that's not right either. The number of dominant integral weights of sl₃ at level d is C(d+2,2) = (d+1)(d+2)/2. The number of REGULAR dominant weights (all a_i ≥ 1) is C(d-1,2) = d(d-1)/2.

Actually, let me reconsider. The Weyl group of sl₃ has order 6 (= S₃). The weight lattice modulo the Weyl group at level d... hmm, this is getting confused.

Let me just note that (d+1)(d+2)/6 = C(d+2, 2)/3 = number of unordered triples from {0,1,...,d} summing to d, divided by... no.

Actually: (d+1)(d+2)/6 IS an integer when d ≢ 0 mod 3, because:
- If d ≡ 1 mod 3: (d+1) ≡ 2, (d+2) ≡ 0 mod 3, so (d+2)/3 is integer
- If d ≡ 2 mod 3: (d+1) ≡ 0 mod 3, so (d+1)/3 is integer

And when d ≡ 0 mod 3: neither (d+1) nor (d+2) is divisible by 3, so (d+1)(d+2)/6 is not an integer.

**Connection to sl₃ representation theory**: The number of dominant integral weights of sl₃ at level d is C(d+2, 2) = (d+1)(d+2)/2 (compositions of d into 3 non-negative parts = lattice points in the level-d simplex). The Weyl group S₃ acts on these, and the number of orbits is:
- By Burnside: (1/6)[C(d+2,2) + 3·(terms for order-2 elements) + 2·(terms for order-3 elements)]

For order-3 elements (cyclic): fixed points are triples (a,a,a) with 3a=d, so d/3 must be integer. Number = 1 if d ≡ 0 mod 3, else 0.

For order-2 elements (transpositions, 3 of them): fixed points of (12) are (a,a,c) with 2a+c=d. Number = floor(d/2)+1.

So by Burnside:
|orbits| = (1/6)[C(d+2,2) + 3·(floor(d/2)+1) + 2·(1 if d≡0 mod 3 else 0)]

For d=7: (1/6)[36 + 3·4 + 0] = (1/6)[48] = 8.
But (d+1)(d+2)/6 = 8·9/6 = 12. So orbits ≠ (d+1)(d+2)/6.

Hmm. So (d+1)(d+2)/6 is NOT the number of S₃-orbits. Let me reconsider.

(d+1)(d+2)/6: for d=7 this is 12. The number of non-negative integer triples summing to d with the cyclic interlacing conditions from the cylindric partition is what we computed in Layer 1 as the stable coefficient of g₁. Let me just verify directly.

For c = (3,2,2), the stable coefficient of g₁ is 12 (from h₁ sum). The formula (d+1)(d+2)/6 = 8·9/6 = 12 ✓.

And (d+1)(d+2)/6 - 1 = 11 is Q₁(1), which is the number of non-trivial triples (i.e., excluding the zero triple). This is also 11 = base for Q_n(1) = 11^n.


## 2. The Mod-3 Condition: Precise Algebraic Statement

### What Tsuchioka's commutation relations say

In the D₄⁽³⁾ Z-algebra (triple tensor product of basic representations):
- Relations 1-2 (unconditional): hold for all A, B ∈ ℤ
- Relations 3-4 (partial): hold only when A+B ∉ 3ℤ

The partial relations are needed to eliminate the Z′ operators (second root type β₂). Without them, the spanning set cannot be reduced to single-root-type monomials.

### Connection to the conjecture

The conjecture requires d ≢ 0 mod 3. In Tsuchioka's framework:
- d = 6 (≡ 0 mod 3) corresponds to D₄⁽³⁾ at modulus 9 = 3+6
- The partial commutation relations fail when A+B ∈ 3ℤ
- When they fail, the Z-algebra has a larger generating set, and the vacuum space basis is more complex

**Algebraic mechanism**: When d ≡ 0 mod 3, the Z-algebra commutation relations are INCOMPLETE — the partial relations that would allow reducing to a single root type don't hold for all pairs. This means:
1. The vacuum space Ω_V cannot be described by a simple "difference condition" basis
2. The character formula involves contributions from BOTH root types (β₁ and β₂)
3. The resulting generating function has a different structure

**However**: Our computation shows Q_{n,c}(q) IS still nonnegative for d ≡ 0 mod 3! So the algebraic complication affects the CHARACTER FORMULA but not the POSITIVITY.

The correct statement is: the mod-3 condition is about the FORM of the character formula (single-root vs multi-root Z-algebra basis), not about positivity. The conjecture's restriction d ≢ 0 mod 3 is for the evaluation Q(1) = ((d+1)(d+2)/6 - 1)^n to make sense, not for positivity.

### What goes wrong when d ≡ 0 mod 3

1. (d+1)(d+2)/6 is not an integer, so the evaluation formula is undefined
2. ℓ = gcd(d, 3) = 3 instead of 1, changing the (q^ℓ; q^ℓ)_n factor
3. The Z-algebra partial commutation relations break down
4. But the polynomial Q_{n,c}(q) is still well-defined and (computationally) nonneg!


## 3. The Bounded Vacuum Space

### Framework

For ŝl₃ at level d, the standard module V = V(Λ) with highest weight Λ = c₀Λ₀ + c₁Λ₁ + c₂Λ₂ (where c₀+c₁+c₂ = d) has:
- A vacuum space Ω_V spanned by Z-operator monomials acting on the vacuum
- The vacuum space decomposes by "depth" (related to the principal grading)
- The unrestricted generating function of Ω_V gives the sum-side of the ASW identity

**Conjecture (Seed 7)**: Q_{n,c}(q) = graded dimension of Ω_V^{≤n}, the subspace of Ω_V consisting of basis elements with depth at most n.

More precisely:
- Let Ω_V = ⊕_{m≥0} Ω_V^{(m)} be the decomposition by depth m
- The depth-m component has graded dimension g_m(q) = [z^m] F_c(z,q)
- The bounded vacuum space Ω_V^{≤n} has graded dimension F_{c,n}(q)
- Then Q_{n,c}(q) = (q;q)_n · [z^n]((zq;q)_∞ · Σ_m z^m · dim_q Ω_V^{(m)})

The positivity of Q_{n,c}(q) would follow from showing that (q;q)_n · [z^n]((zq;q)_∞ · Σ_m z^m · dim_q Ω_V^{(m)}) can be rewritten as a manifestly positive graded dimension.

### The key gap

The problem is that the extraction [z^n]((zq;q)_∞ · F(z,q)) involves alternating signs from (zq;q)_∞. Even if Ω_V^{(m)} has a positive basis for each m, the alternating sum mixing different depths destroys manifest positivity.

What we need is a DIFFERENT decomposition of the vacuum space — not by depth, but by some other grading — that makes Q_{n,c}(q) manifestly positive.


## 4. The ŝl₃ Crystal Base Connection

### Connection B from synthesis (Seeds 5 + 7 + 8)

Seed 5 found that Q_{n,c}(q) decomposes as a positive combination of GL₂ key polynomial specializations. Seed 8 noted that (d+1)(d+2)/6 - 1 counts nontrivial C₃-orbits of sl₃ level-d dominant weights.

### Demazure module interpretation

For ŝl₃ at level d, the Demazure module D(nΛ₀ + Λ) ⊂ V(Λ) is a finite-dimensional submodule whose character is given by the Demazure character formula.

**Key property**: Demazure characters are manifestly positive — they are sums of characters of Demazure crystals, which are subsets of the crystal B(Λ) with a natural poset structure.

If Q_{n,c}(q) equals (up to normalization) the principally specialized character of a Demazure module of ŝl₃, then:
1. Positivity is immediate (Demazure characters are positive)
2. The evaluation at q=1 gives the dimension of the Demazure module
3. The profile c determines which highest weight Λ

The challenge: which Demazure module? The parameter n should correspond to the Demazure truncation depth.

### Concrete test for d=7

For ŝl₃ at level 7, the dominant integral weights are triples (a₀, a₁, a₂) with a_i ≥ 0 and a₀+a₁+a₂ = 7. There are C(9,2) = 36 of them.

The Weyl group orbits: each orbit contains up to 6 weights. The number of orbits... this is the same 36 profiles we computed in the CW system!

Wait — the 36 profiles in the CW system for d=7, k=3 ARE the 36 compositions of 7 into 3 non-negative parts. And these are exactly the level-7 dominant integral weights of ŝl₃!

This is NOT a coincidence. The CW recurrence is a recurrence on THESE weights. The profile shift c → c(J) is an algebraic operation on sl₃ weight space.


## Strategy Assessment

### What we've established

1. **Computational verification** of positivity for d=7 (first unproved case) at n=0,1,2 ✓
2. **h_m non-negativity** verified for d=7 at m=0,1,2 ✓
3. **The mod-3 condition** is about the evaluation formula, not positivity ✓
4. **The algebra identification** points to ŝl₃ at level d (profiles = level-d weights)
5. **The CW profiles = sl₃ weights** connection is structural
6. **Positivity for d ≡ 0 mod 3** also holds computationally (NEW)

### Key Lemma (revised)

**The proof reduces to showing**: There exists a Demazure-type module D_{n,c} of ŝl₃ at level d = sum(c) such that:
- Q_{n,c}(q) = q^{shift} · ch_q(D_{n,c})
where ch_q is the principally specialized character.

If true, positivity follows from the Demazure character formula (Kumar-Mathieu theorem: Demazure characters are non-negative sums of weight space dimensions).

### What I cannot close

I cannot prove that Q_{n,c}(q) IS a Demazure character. The evidence is:
1. Q_{n,c}(1) = 11^n for d=7 should equal dim(D_{n,c}), and 11 = (d+1)(d+2)/6 - 1 has a natural sl₃ interpretation
2. Seed 5's key polynomial decomposition is exactly what one expects from Demazure crystal decomposition
3. The CW profiles match sl₃ weights

But constructing the explicit module D_{n,c} requires:
- Identifying the Weyl group element w such that D_w(Λ) has the right character
- Showing the principal specialization matches Q_{n,c}(q)
- This is essentially the problem Warnaar solved for d ≤ 5 using ad hoc methods


## Stuck: Layer 2

### What I'm trying to show
Q_{n,c}(q) equals the principally specialized character of a Demazure module of ŝl₃ at level d.

### Why I can't show it
The Demazure character formula involves a sum over the Weyl group coset, and matching this with the CW recurrence/Borodin product is technically difficult. The connection between cylindric partitions and affine crystal graphs is known for k=2 (Tingley, Schilling-Shimozono) but not for k=3.

### What would unstick me
1. An explicit construction of the crystal graph B_{n,c} whose character is Q_{n,c}(q). This might come from the combinatorics of cylindric Schur functions or from the crystal theory of ŝl₃ Demazure modules.
2. A proof that the CW recurrence on profiles is equivalent to the Demazure recursion on Weyl group elements.
3. A reference establishing the connection between cylindric partitions of profile c and ŝl₃ crystals.

### Partial results worth preserving

**Result 1 (NEW)**: Q_{n,c}(q) is nonnegative even when d ≡ 0 mod 3, in all computed cases. The conjecture could potentially be extended.

**Result 2**: The h_m conjecture (from Seed 1) is verified for d=7: h_m(q) = (q;q)_m · g_m(q) has nonneg coefficients for m = 0, 1, 2.

**Result 3**: h₁ for profile (3,2,2) = 3q + 3q² + 2q³ + 2q⁴ + q⁵ + q⁶ has a palindrome-like structure. For (4,2,1): 3q + 2q² + 2q³ + 2q⁴ + q⁵ + q⁶ + q⁸ has a gap. This profile-dependence in h₁ reflects the different sl₃ weight structures.

**Result 4**: The CW system at fixed d involves exactly C(d+2, 2) = (d+1)(d+2)/2 profiles, which equals the number of level-d dominant integral weights of sl₃. This is structural, not coincidental.

**Result 5**: The Borodin product for d=7 has higher-multiplicity residues (not all mult 1), ruling out level-1 identifications. The character is at level d (not level 1 or level 3).

**Result 6**: The missing residues {1, 2, 3} for c=(3,2,2) at t=10 correspond to the "initial segment" mod t. For a Demazure module at depth n, the character should involve products at residues n+1, ..., t-1 (the complementary set). This is consistent with Q_1 involving residues 1, ..., 6 < t.


## 5. Key Polynomial Decomposition for d=7 (NEW)

### Q₁ decompositions (GL₂ key polynomials K_{(a,b)}(q,q²))

For K_{(a,b)}(q,q²) with a ≥ b ≥ 0: this equals q^{a+2b} · [a-b+1]_q
For a < b: just the monomial q^{a+2b}

**Profile (3,2,2)**:
Q₁ = 2q + 3q² + 2q³ + 2q⁴ + q⁵ + q⁶
    = 2·K_{(1,0)} + K_{(2,0)} + K_{(3,0)}
    = 2·s₁(q,q²) + s₂(q,q²) + s₃(q,q²)

All components have b=0, so these are just q-analogues of integers:
K_{(a,0)}(q,q²) = q^a · [a+1]_q

Multiplicities: 2, 1, 1. Sum of dims at q=1: 2·2 + 3 + 4 = 11 ✓

**Profile (4,2,1)**:
Q₁ = 2q + 2q² + 2q³ + 2q⁴ + q⁵ + q⁶ + q⁸
    = 2·K_{(1,0)} + K_{(1,1)} + K_{(3,0)} + K_{(0,2)} + K_{(0,4)}

Here we see BOTH dominant and anti-dominant key polynomials.
Anti-dominant keys K_{(0,2)} = q⁴ and K_{(0,4)} = q⁸ are monomials.
The gap at q⁷ is explained by the absence of K_{(a,b)} at that degree.

Sum of dims at q=1: 2·2 + 1 + 4 + 1 + 1 = 11 ✓

### Significance

The key polynomial decomposition with non-negative integer multiplicities exists for Q₁ at d=7 (the first unproved case), confirming the pattern found by Seed 5 at d=4.

The decomposition is into GL₂ key polynomials at specialization (q, q²). In the sl₃ / ŝl₃ framework, these would arise from the restriction sl₃ → sl₂ of the Demazure crystal.

**Open**: Does the decomposition persist for Q_n with n ≥ 2? Does it exist for ALL d ≢ 0 mod 3?


## 6. Summary of Seed 7 Layer 2 Findings

### Established

1. **Q_{n,c}(q) is nonneg for d=7 at n=0,1,2** (first unproved case, verified computationally)
2. **h_m is nonneg for d=7 at m=0,1,2** (confirms Seed 1's sub-conjecture)
3. **Key polynomial decomposition works for Q₁ at d=7** (both profiles (3,2,2) and (4,2,1))
4. **Positivity holds for d ≡ 0 mod 3 too** (d=3,6 tested) — the conjecture's restriction is about the evaluation formula, not positivity
5. **CW profiles = sl₃ level-d weights** — the 36 profiles at d=7 are the 36 compositions of 7 into 3 non-negative parts, which are the level-7 weights of ŝl₃
6. **Borodin product has higher multiplicities** for d=7, ruling out level-1 algebra identification
7. **The mod-3 condition** reflects when (d+1)(d+2)/6 is an integer, and when the Z-algebra partial commutation relations hold

### Failed / Incomplete

1. **Explicit algebra identification**: could not definitively identify which affine algebra module has Q_{n,c}(q) as its character. The candidate is ŝl₃ at level d, but the precise module and Demazure truncation are not determined.
2. **Proof of positivity**: no proof — only computational verification.
3. **h_m → Q_n bootstrap**: h_m nonneg does NOT directly imply Q_n nonneg (confirmed from Layer 1).
4. **Z-algebra bounded vacuum space**: identified conceptually but cannot construct explicitly.

### Recommendations for Layer 3

1. **Priority 1**: Prove Q₁ positivity for ALL d ≢ 0 mod 3. The key polynomial decomposition of Q₁ = Σ c_{a,b} · K_{(a,b)}(q,q²) with c_{a,b} ≥ 0 should follow from the lattice point analysis of g₁ (the rational function structure from Layer 1). If g₁ = P(q)/(1-q) and P has nonneg coefficients, then Q₁ = P(q) - q, and the key polynomial decomposition of P(q) - q should be provable from the explicit form of P.

2. **Priority 2**: Extend the key polynomial decomposition to Q₂ at d=7. Check whether Q₂ also decomposes with nonneg coefficients in GL₂ (or GL₃) key polynomials. If so, find the pattern.

3. **Priority 3**: Investigate the ŝl₃ Demazure module connection rigorously. The recent work of Kouno, Naito, Sagaki on "Demazure modules and cylindric partitions" (if it exists) might provide the missing link.

4. **New direction**: The positivity at d ≡ 0 mod 3 suggests a UNIFIED conjecture for all d, with a modified evaluation formula. The bases 7 (d=3), 25 (d=6) should have representation-theoretic meaning. Can we find the formula?
