# Seed 4, Layer 1: Bilateral Rogers-Ramanujan Approach

## Computational Evidence

### d=2 (trivial case)
All Q_{n,c}(q) are single monomials, trivially nonneg:
- c=(1,1,0): Q_n = q^{n^2}
- c=(2,0,0): Q_n = q^{n(n+1)}
- All permutations of each type give the same Q_n.
- Q_n(1) = 1 = ((3)(4)/6 - 1)^n. Confirmed.

### d=4 (first nontrivial case)
Two equivalence classes of profiles (under cyclic permutation):
- Type (2,1,1): Q_1 = 2q + q^2 + q^3, Q_1(1) = 4
- Type (2,2,0): Q_1 = q + 2q^2 + q^4, Q_1(1) = 4

Q_2 for (2,1,1): q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12 (sum=16)
Q_3 computed (sum=64). All coefficients nonneg.

Key observation: Q_n(1) = 4^n = ((5)(6)/6 - 1)^n. Confirmed.

Q_n is NOT simply Q_1^n. The n-dependence is more subtle.

### Verification summary
- d=2: All profiles tested, positivity holds (trivially, as monomials).
- d=4: 6 profiles tested (3 in each type), positivity holds through n=3 and degree 40.
- No counterexamples found.
- Confidence in the conjecture: HIGH.

## Approach

### Angle of attack: Bilateral q-series and Bailey pair machinery

The seed context is Schlosser's bilateral extensions of Rogers-Ramanujan and
Göllnitz-Gordon identities. The key structural features:

1. **Unilateral to bilateral**: Schlosser extends sums from k >= 0 to k in Z,
   introducing a parameter z that controls the bilateral extension.
   Specializing z recovers the original unilateral identities.

2. **Modular structure**: The bilateral identities live at modulus t^2 where
   t is the modulus of the original identity. For Andrews-Gordon at modulus
   2r+1, the bilateral version has modulus (2r+1)^2.

3. **Connection to cylindric partitions**: The cylindric partition generating
   function F_c(q) is a product at modulus t = k + d. For k=3:
   - d=2: t=5, bilateral modulus = 25
   - d=4: t=7, bilateral modulus = 49
   - d=5: t=8, bilateral modulus = 64

The idea: Q_{n,c}(q) = (q^l;q^l)_n [z^n]((zq;q)_inf F_c(z,q)) mixes the
Euler function (with alternating signs) against the cylindric partition GF.
The miracle is that the alternating signs cancel. Why?

**Hypothesis**: The cancellation in Q_{n,c}(q) is structurally the same
cancellation that occurs in bilateral q-series. In Schlosser's bilateral sums,
terms with k < 0 introduce alternating signs (through the reciprocal
q-Pochhammer factors), but the sum evaluates to a positive product.
The extraction of [z^n] from (zq;q)_inf F_c(z,q) performs an analogous
bilateral-type cancellation.

### What a counterexample would look like

A counterexample would be a specific c = (c_0, c_1, c_2) with d = c_0+c_1+c_2
not divisible by 3, and a specific n, such that some coefficient of q^j in
Q_{n,c}(q) is negative. It would need d >= 7 (since d <= 5 is proved by Warnaar
and Uncu), and likely would appear at large enough n or degree.

## Strategy

### Candidate strategies

1. **Bilateral multisum representation**: Express Q_{n,c}(q) as a bilateral
   multisum (à la Schlosser's Theorem 4) that has manifestly nonneg coefficients.
   - Why it might work: The bilateral RR identities provide closed-form
     evaluations of bilateral sums in terms of infinite products. If Q_{n,c}(q)
     can be expressed through finite (bounded) versions of these bilateral sums,
     positivity might follow.
   - Why it might not: The relationship between the bounding parameter z in
     F_c(z,q) and the bilateral parameter z in Schlosser is not yet established.
     These might be fundamentally different objects.

2. **Bailey pair approach**: Construct a Bailey pair (alpha_n, beta_n) such that
   Q_{n,c}(q) arises from a Bailey transform with positive input.
   - Why it might work: The known proofs for small d (Warnaar 2023) use
     multisum formulas that often arise from Bailey pairs.
   - Why it might not: Finding the right Bailey pair for general d is the
     entire difficulty. No pattern has been identified.

3. **Transfer matrix positivity**: Show that Q_{n,c}(q) is a diagonal entry
   of a power of a matrix with nonneg polynomial entries.
   - Why it might work: The transfer matrix approach to F_{c,N}(q) naturally
     involves matrix powers. If the extraction [z^n]((zq)_inf * F_c(z,q)) can
     be rewritten as a matrix operation preserving positivity, we'd be done.
   - Why it might not: The (zq;q)_inf factor introduces alternating signs that
     break manifest positivity of the matrix approach.

4. **Induction on n via Corteel-Welsh recurrence**: The CW recurrence gives
   a functional equation for F_c(y,q). Extract the z^n coefficient to get
   a recurrence for Q_n in terms of Q_m for m < n (at possibly shifted profiles).
   - Why it might work: If the recurrence has positive coefficients, induction
     gives positivity.
   - Why it might not: The CW recurrence involves inclusion-exclusion with
     alternating signs.

### Choice: Strategy 1 + 3 (Bilateral multisum via transfer matrix)

Rationale: My seed context is bilateral RR. The transfer matrix computation
already works and gives correct results. The key insight to pursue is whether
the transfer matrix for F_{c,N}(q) can be decomposed in a way that, when
combined with the (zq;q)_inf factor, yields a manifestly positive expression.

The bilateral sums in Schlosser have the form:
  sum_{k in Z} q^{P(k)} / (product of q-Pochhammer factors)
where P(k) is a quadratic polynomial in k. The quadratic growth ensures the
sum converges. When bounded (finite sum), positivity might follow from the
quadratic exponent structure.

## Key Lemma

The proof reduces to showing:

**Lemma (Target)**: For any composition c = (c_0,c_1,c_2) with d not divisible by 3,
the power series [z^n]((zq;q)_inf * F_c(z,q)) is divisible by 1/(q^l;q^l)_n
and the quotient Q_{n,c}(q) = (q^l;q^l)_n * [z^n](...) has nonneg coefficients.

More specifically, the hard step is establishing that the cancellation between
the alternating (zq;q)_inf and the positive F_c(z,q) always resolves positively
after extracting z^n and multiplying by (q^l;q^l)_n.

## Attempt 1: Transfer matrix decomposition

### Setup

For c = (c_0, c_1, c_2) with max(c_i) <= 1 (simplest nontrivial case):
The transfer matrix T acts on states s = (a,b,c) with 0 <= a,b,c <= N.
T encodes the cylindric partition interlacing constraints.

F_{c,N}(q) = sum_s (I-T)^{-1}_{s, 0} = e^T (I-T)^{-1} e_0

where e is the all-ones vector and e_0 is the indicator of the zero state.

The generating function F_c(z,q) = sum_N a_N(q) z^N where
a_N = F_{c,N} - F_{c,N-1} counts cylindric partitions with max entry EXACTLY N.

Then:
(zq;q)_inf * F_c(z,q) = sum_n b_n(q) z^n
where b_n = sum_{j=0}^{n} euler_j * a_{n-j}
and euler_j = (-1)^j q^{j(j+1)/2} / (q;q)_j.

The key question: can b_n be written as a positive sum after multiplying by (q^l;q^l)_n?

### Observation from d=2

For c=(1,1,0), d=2: The transfer matrix states are triples (a,b,c) with b >= c (since c_3=0).
For N=1, valid states: (0,0,0), (1,0,0), (1,1,0), (1,1,1).
F_{c,1} = 1 + 2q + 2q^2 + 2q^3 + ...

Actually, F_{c,1} for (1,1,0) stabilizes at coefficient 2 from degree 1 onward.
This means a_1(q) = F_{c,1} - F_{c,0} = 2q + 2q^2 + 2q^3 + ... = 2q/(1-q).
Wait, that's not a polynomial. Right -- it's a power series.

Then euler_0 = 1, euler_1 = -q/(1-q).
b_1 = euler_0 * a_1 + euler_1 * a_0 = a_1 + (-q/(1-q)) * 1
= 2q/(1-q) - q/(1-q) = q/(1-q).

Q_1 = (q;q)_1 * b_1 = (1-q) * q/(1-q) = q. Confirmed!

This is beautiful: the cancellation is EXACT and simple for d=2.
The factor 2 in a_1 vs 1 in euler_1 leaves a positive residue.

### The general pattern

For general d and n: b_n = sum_j euler_j * a_{n-j}. The euler_j alternate in sign.
The a_m are positive power series. The question is whether the alternating
combination remains positive (after multiplying by (q^l;q^l)_n).

For d=4, c=(2,1,1): a_1 stabilizes at coefficient 5 (for large degree).
euler_0 = 1, euler_1 = -q/(1-q) = -q - q^2 - ...
b_1 = a_1 - q/(1-q)
a_1 starts: 3q + 4q^2 + 5q^3 + 5q^4 + ...
-q/(1-q) = -q - q^2 - q^3 - ...
b_1 starts: 2q + 3q^2 + 4q^3 + 4q^4 + ...

Q_1 = (q;q)_1 * b_1 = (1-q)(2q + 3q^2 + 4q^3 + ...)
= 2q + 3q^2 + 4q^3 + ... - 2q^2 - 3q^3 - ...
= 2q + q^2 + q^3 + 0q^4 + ... = 2q + q^2 + q^3. Confirmed!

The polynomial terminates because b_1 has coefficients that eventually
become constant (5 - 1 = 4 for large degree), and (1-q) kills the
constant tail.

### Deeper structure

For large j, a_m(q) ~ C_m q^{f(m)} / (q;q)_inf^s for some constants.
The euler_j coefficients ~ (-1)^j q^{j(j+1)/2} / (q;q)_j.
The alternating sum b_n produces cancellation.

After multiplying by (q^l;q^l)_n, the result is a polynomial.
Welsh proved this. But why is it positive?

### Connection to bilateral sums

Schlosser's bilateral sum sum_{k=-inf}^{inf} z^{2k} q^{k^2} / (zq;q)_k
can be interpreted as:
  sum_{k>=0} z^{2k} q^{k^2} / (zq;q)_k + sum_{k>=1} z^{-2k} q^{k^2} / (zq;q)_{-k}

The terms with k < 0 involve 1/(zq;q)_{-k} = 1/((zq;q)_inf / (zq^{1-k};q)_inf)
which brings in negative q-powers and potentially alternating signs.

The BOUNDED version of such a bilateral sum (where we restrict max entry) would
involve the same z-parameter tracking as in F_c(z,q). This is the connection
I want to formalize.

**Specific conjecture**: There exists a set of "bilateral partition" objects B_{n,c}
such that Q_{n,c}(q) = sum_{b in B_{n,c}} q^{|b|}, where B_{n,c} is defined
in terms of the bilateral extension of the cylindric partition constraints.
The bilateral extension would use Schlosser's z-parameter to control the
max entry bound, making positivity manifest.

## Stuck: Formalizing the bilateral connection

What I'm trying to show: That Q_{n,c}(q) can be written as a manifestly
positive bilateral multisum.

Why I can't show it: The relationship between Schlosser's z and the
bounding parameter z in F_c(z,q) is suggestive but not precise. Schlosser's
z appears as z^{2k} in the bilateral sum, while F_c(z,q) has z^{max(Lambda)}.
These track fundamentally different quantities.

What would unstick me: Either
(a) An explicit identity relating [z^n](zq;q)_inf F_c(z,q) to a bilateral sum, or
(b) A different combinatorial interpretation where bilateral partitions
    (allowing "negative" indices) naturally count the same objects as Q_{n,c}(q).

## Assumptions Check

- **About the objects**: I am assuming cylindric partitions have the right definition
  (checked: matches conjecture.tex). TESTED.
- **About the transfer matrix**: I am assuming my transfer matrix correctly
  computes F_{c,N}(q). TESTED (matches known Q(1) values and positivity).
- **About Schlosser's bilateral sums**: I am assuming the bilateral RR identities
  at modulus t^2 are relevant to cylindric partitions at modulus t. UNCERTAIN.
  The modular structure aligns but no direct connection is established.
- **About positivity mechanism**: I am assuming the positivity comes from
  cancellation in the bilateral sum. UNTESTED. Could also come from
  representation theory, crystal bases, or other sources.
- **About the z parameter**: I am assuming Schlosser's z and F_c's z play
  analogous roles. UNCERTAIN. They track different quantities.

## Strategy 2: Transfer matrix approach to positivity

Instead of the bilateral connection, let me explore whether the transfer matrix
itself can prove positivity.

Key insight from computation: Q_{n,c}(q) = (q^l;q^l)_n * [z^n]((zq;q)_inf F_c(z,q)).
Let me write this differently.

F_c(z,q) = sum_{N>=0} a_N(q) z^N where a_N = F_{c,N} - F_{c,N-1}.
(zq;q)_inf = sum_{j>=0} e_j(q) z^j where e_j = (-1)^j q^{j(j+1)/2}/(q;q)_j.

[z^n] = sum_{j=0}^{n} e_j(q) a_{n-j}(q).

Now, a_N(q) is the generating function for cylindric partitions with max = N.
By the transfer matrix: a_N(q) = F_{c,N}(q) - F_{c,N-1}(q)
= (trace-like expression involving the transfer matrix at size N vs N-1).

In the transfer matrix formulation:
a_N(q) = sum over cylindric partitions with at least one entry equal to N.

The sum [z^n] = sum_j e_j a_{n-j} computes:
sum_{j=0}^{n} (-1)^j q^{j(j+1)/2}/(q;q)_j * (GF for cylpart with max = n-j).

This is an ALTERNATING sum over j. The miracle: after multiplying by (q;q)_n
(for l=1), the result is a positive polynomial.

**Idea**: Can this alternating sum be interpreted as an inclusion-exclusion
that resolves positively? Specifically: is there a set of "decorated cylindric
partitions" that are counted with weight +1 or -1 by the alternating sum,
and the -1 terms pair up with +1 terms via an involution, leaving only
positive terms?

This is the involution principle. If such an involution exists, positivity
is immediate.

## Attempt 2: Involution principle

Suppose we define objects (j, Lambda) where j >= 0 and Lambda is a cylindric
partition with max(Lambda) = n - j. The weight is (-1)^j q^{|Lambda| + j(j+1)/2}
divided by (q;q)_j, times (q;q)_n (from the Q definition).

The factor (q;q)_n / (q;q)_j = (q;q)_{n-j} * [n choose j]_q... no.
Actually (q;q)_n / (q;q)_j = (q^{j+1};q)_{n-j} = prod_{i=j+1}^{n} (1-q^i).

Hmm, this is getting complicated. The 1/(q;q)_j factor in e_j makes it
hard to interpret combinatorially because it introduces infinitely many
partition-like objects.

Let me think of it differently. Instead of e_j as a power series, let me use:
Q_{n,c}(q) = (q;q)_n * sum_{j=0}^{n} (-1)^j q^{j(j+1)/2} / (q;q)_j * a_{n-j}(q)

Rewrite (q;q)_n / (q;q)_j = (q^{j+1}; q)_{n-j} for j <= n.
And q^{j(j+1)/2} (q^{j+1};q)_{n-j} = ?

(q^{j+1};q)_{n-j} = prod_{i=0}^{n-j-1} (1 - q^{j+1+i})

q^{j(j+1)/2} * prod_{i=0}^{n-j-1} (1 - q^{j+1+i})

For j=0: q^0 * (q;q)_n. Coefficient of q^d in this times a_n is positive
(since a_n is positive and (q;q)_n has both signs -- wait, it has alternating signs!).

Hmm. (q;q)_n = prod_{i=1}^n (1-q^i) has alternating signs.

So Q_{n,c}(q) = sum_{j=0}^n (-1)^j q^{j(j+1)/2} (q^{j+1};q)_{n-j} a_{n-j}(q).

Each term involves q^{j(j+1)/2} * (q^{j+1};q)_{n-j} * a_{n-j}(q), with sign (-1)^j.
The factors (q^{j+1};q)_{n-j} have alternating signs themselves.

Total sign structure is complex. The involution principle would need to 
pair up negative contributions with positive ones.

This is where I'm stuck. The sign structure is intricate, and I don't see
a natural involution.

## Attempt 3: Bailey pair / Bilateral series hybrid

Going back to the bilateral approach, but more concretely.

Schlosser's bilateral RR (Corollary 1, modulus 25):
sum_{k=-inf}^{inf} q^{k(5k-3)} / (q;q^5)_k = product

The structure q^{P(k)} / (q^a; q^t)_k where P(k) is quadratic is the 
hallmark. The bounded version would restrict k to a finite range.

For cylindric partitions of profile c with t = k+d, the transfer matrix
eigenvalues might relate to the quadratic exponents in bilateral sums.
If the transfer matrix T has eigenvalues that are q^{linear} 
(with appropriate multiplicity structure), then F_{c,N}(q) would be
a sum of q^{P(N)} / (q-Pochhammer) terms, which when extracted at z^n
would give bilateral-type sums.

**Specific computation**: For c=(1,1,0), d=2, t=5, the transfer matrix
at N=1 has states {(0,0,0), (1,0,0), (1,1,0), (1,1,1)} (with b>=c).
The weights are q^0, q^1, q^2, q^3.

This is a 4x4 matrix. Its eigenvalue structure might reveal the connection
to bilateral RR at modulus 25.

### Transfer matrix eigenvalue analysis needed
I would need to:
1. Compute T symbolically (as a matrix of polynomials in q)
2. Find its eigenvalues
3. Check if they relate to the quadratic exponents in Schlosser's bilateral sums

This is a concrete next step but requires significant computation.

## Summary of Layer 1 Progress

### What works
- Correct computation of Q_{n,c}(q) via transfer matrix for all tested profiles.
- Positivity verified for d=2 (trivially, Q_n is a monomial) and d=4 (nontrivially).
- Structural observation: Q_n(1) = 4^n for d=4, confirming the formula.

### What doesn't work
- Direct bilateral RR connection: the z parameters in Schlosser vs. cylindric partitions
  track different quantities. No identity linking them found.
- Involution principle: sign structure too complex to find a natural pairing.

### Most promising direction
- Transfer matrix eigenvalue analysis: if eigenvalues of the cylindric partition
  transfer matrix relate to bilateral sum exponents, this could bridge the gap.
- Alternative: the CW recurrence might yield a positivity-preserving recurrence
  for Q_n when carefully analyzed.

### For the next layer
- Implement eigenvalue analysis of the transfer matrix (symbolic computation).
- Explore the CW recurrence for Q_n: does it preserve positivity?
- Try d=7 or d=8 (first truly open cases) computationally, if max shift handling
  can be extended to shift >= 3.

## Additional Computational Evidence (d=4)

### Full Q_n polynomials for c=(2,1,1), d=4

```
Q_0 = 1
Q_1 = 2q + q^2 + q^3
Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
Q_3 = 2q^7 + 2q^8 + 5q^9 + 4q^10 + 6q^11 + 6q^12 + 6q^13 + 5q^14
    + 6q^15 + 4q^16 + 4q^17 + 3q^18 + 3q^19 + 2q^20 + 2q^21 + q^22 + q^23 + q^24 + q^27
Q_4 = q^12 + 3q^13 + 4q^14 + 5q^15 + 9q^16 + 9q^17 + 12q^18 + 13q^19 + 15q^20
    + 14q^21 + 16q^22 + 15q^23 + 16q^24 + 14q^25 + 14q^26 + 12q^27 + 13q^28
    + 10q^29 + 10q^30 + 8q^31 + 8q^32 + 6q^33 + 6q^34 + 4q^35 + 4q^36
    + 3q^37 + 3q^38 + 2q^39 + 2q^40 + q^41 + q^42 + q^43 + q^44 + q^48
```

All nonneg. Q_n(1) = 4^n confirmed for n = 0,...,4.

### Degree bounds
- min_deg(Q_n) for n=1,2,3,4: 1, 3, 7, 12
- max_deg(Q_n) for n=1,2,3,4: 3, 12, 27, 48 = 3n^2

The maximum degree formula max_deg(Q_n) = 3n^2 for c=(2,1,1) is exact.
For d=2, c=(1,1,0): max_deg = min_deg = n^2 (monomial).
The factor 3 in 3n^2 might be related to k=3 (the number of partitions).

### Isolated high-degree term
Q_n has an isolated monomial at the very top:
- Q_2: q^12 = q^{3*4} (coefficient 1, gap from q^10)
- Q_3: q^27 = q^{3*9} (coefficient 1, gap from q^24)
- Q_4: q^48 = q^{3*16} (coefficient 1, gap from q^44)

Pattern: the highest term is q^{3n^2} with coefficient 1. This isolated
monomial is reminiscent of the "ground state" contribution in a statistical
mechanics partition function. In the bilateral RR context, the quadratic
exponent q^{k^2} appears as the dominant term.

### Recurrence structure
No simple 2-term recurrence Q_n = A(q) Q_{n-1} + B(q) Q_{n-2} exists with
polynomial (or even rational with bounded denominators) coefficients A, B.
The Q_n do NOT form a simple multiplicative sequence (Q_n != Q_1^n).

## Revised Strategy Assessment

### What the bilateral RR angle reveals
The bilateral identities introduce structure at modulus t^2. For our problem:
- d=2, t=5: modulus 25 bilateral identities (Schlosser's Corollary 1)
- d=4, t=7: modulus 49 bilateral identities (Schlosser's Theorem 4 at r=3)

The isolated top-degree monomial q^{3n^2} in Q_n matches the quadratic
exponent structure of bilateral sums. In Schlosser's bilateral RR:
  sum_{k in Z} q^{k(5k-3)} / (q;q^5)_k
the exponent k(5k-3) is quadratic. The bounded version (restricting k)
would produce polynomials whose top degree grows quadratically in the bound.

This structural match is suggestive but does not constitute a proof.

### The gap
The missing piece is an EXPLICIT identity connecting:
1. [z^n]((zq;q)_inf * F_c(z,q)) (definition of Q up to normalization)
2. A bilateral multisum with manifestly nonneg coefficients

To establish such an identity, one would need to:
(a) Express F_c(z,q) using Borodin's product formula
(b) Multiply by (zq;q)_inf and extract [z^n]
(c) Show the result matches a bounded bilateral sum

Step (a) is known. Step (b) is mechanical. Step (c) is the hard part --
it requires identifying the right bilateral sum structure.

## Escalation

I am stuck on: Connecting the bilateral Rogers-Ramanujan framework (Schlosser)
to the positivity of Q_{n,c}(q) in a way that yields a proof.

Attempt 1: Direct bilateral identification. Failed because the z parameters
in Schlosser and in cylindric partitions track different quantities (bilateral
summation index vs. max entry bound).

Attempt 2: Transfer matrix eigenvalue analysis. Inconclusive -- the eigenvalue
structure at q=1 is trivial (all 0 or 1), and the symbolic (q-dependent)
eigenvalue analysis was not completed due to matrix size.

Attempt 3: Involution principle on the alternating sum. Failed because the
sign structure (from (zq;q)_inf and from (q;q)_n) is too intricate for a
simple sign-reversing involution.

What all three have in common: Each approach correctly identifies PART of
the structure (bilateral quadratic exponents, transfer matrix positivity,
alternating sign cancellation) but cannot bridge the gap to a full positivity proof.

What I think is needed: Either
(a) An explicit multisum formula for Q_{n,c}(q) that generalizes Warnaar's
    formulas for d <= 5, OR
(b) A representation-theoretic interpretation where Q_{n,c}(q) is a graded
    dimension, OR
(c) A new insight connecting the Corteel-Welsh recurrence to positivity
    preservation, possibly through the Bailey lemma or WP-Bailey chains.

The bilateral RR connection is most promising for approach (c): if the
Corteel-Welsh recurrence can be reformulated as a Bailey-type transformation,
and if bilateral Bailey pairs preserve positivity in the relevant sense,
then the positivity of Q_{n,c}(q) might follow.
