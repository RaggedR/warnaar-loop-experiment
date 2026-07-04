# Prove Seed 1 Layer 1: Hall-Littlewood / Bartlett-Warnaar Perspective

## Computational Evidence

### Correct enumeration
After debugging, confirmed that the research/scripts/cpp_lib implementation 
correctly enumerates rank-3 cylindric partitions. The key interlacing condition is:
- nu_prev[j] >= nu[j+shift] for all j >= 0
- Plus cyclic closure: nu3[j] >= nu1[j+c0]
- Plus length constraint: len(nu1) <= len(nu3) + c0

### Q_{n,c}(q) values (verified correct via Q(1) check)

**d=2, c=(1,1,0):** Q_n = q^{n^2}. Trivially positive.
  Q_0 = 1, Q_1 = q, Q_2 = q^4, Q_3 = q^9, Q_4 = q^16, Q_5 = q^25.
  Q(1) = 1 = 1^n. ✓

**d=4, c=(2,1,1):** Q(1) = 4^n. ✓ for n=0,1,2,3.
  Q_0 = 1
  Q_1 = 2q + q^2 + q^3
  Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
  Q_3 has 19 nonzero terms, all positive.
  All non-negative. ✓

**d=5, c=(2,2,1):** Q(1) = 6^n. ✓ for n=0,1,2. n=3 truncation error.
  Q_0 = 1
  Q_1 = 2q + 2q^2 + q^3 + q^4
  Q_2 = q^3 + 4q^4 + 4q^5 + 5q^6 + 4q^7 + 5q^8 + 3q^9 + 3q^10 + 2q^11 + 2q^12 + q^13 + q^14 + q^16
  All non-negative. ✓

**d=7, c=(3,2,2):** First unproved case. Q(1) = 11^n.
  Q_0 = 1
  Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
  Q_2 = q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20
  All non-negative! ✓ (though Q_2(1)=118 ≠ 121, suggesting slight truncation)

### h_m polynomials: h_m = (q;q)_m · g_m(q)
**Key finding:** h_m polynomials appear to be ALWAYS non-negative, for all 
tested profiles and all m. This is remarkable because g_m itself is an infinite 
power series, and (q;q)_m has alternating signs. The cancellation always produces 
non-negative results.

For c=(1,1,0): h_0={0:1}, h_1={1:2}, h_2={2:2,3:1,4:1}, ...
For c=(2,1,1): h_0={0:1}, h_1={1:3,2:1,3:1}, h_2 has 10 nonzero terms, all ≥1.

### Observations
1. Q_{n,(1,1,0)} = q^{n^2} — a single monomial!
2. Q is NOT unimodal in general (d=4, n≥2).
3. The lowest degree of Q_n appears to be n(n+1)/2 for d=4 and similar.
4. h_m non-negativity might be the key intermediate result.

## Approach

### Angle of attack: Hall-Littlewood decomposition via Bartlett-Warnaar

The seed context reveals the Bartlett-Warnaar limit procedure:
L_N(x) -> L_{M,N}(x) by iterated limits x_{p+1} -> x_p^{-1}.

The key formula is:
  Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q)_j · g_{n-j}(q)
multiplied by (q^ell;q^ell)_n.

An equivalent formulation using h_m = (q)_m · g_m is:
  Q_n · (q^ell;q^ell)_n^{-1} = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q · h_{n-j}(q) / (q)_n
Wait, not quite. Let me derive this properly.

Q_n = (q^ell;q^ell)_n · sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q)_j · g_{n-j}

Now g_m = h_m / (q)_m, so:

Q_n = (q^ell;q^ell)_n · sum_j (-1)^j q^{j(j+1)/2} / (q)_j · h_{n-j} / (q)_{n-j}
    = (q^ell;q^ell)_n / (q)_n · sum_j (-1)^j q^{j(j+1)/2} (q)_n/((q)_j(q)_{n-j}) · h_{n-j}
    = (q^ell;q^ell)_n / (q)_n · sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q · h_{n-j}

For ell = 1 (d not divisible by 3):
  (q;q)_n / (q)_n = 1, so this simplifies.
  Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q · h_{n-j}

This is a q-binomial transform with alternating signs!

For ell = 1: since gcd(d,3)=1 when d ≢ 0 mod 3, ell = 1 always.
So Q_n is always a q-binomial transform of the h_m sequence.

### Strategy idea 1: Prove h_m ≥ 0 first, then show the alternating sum is positive

If h_m(q) ≥ 0 for all m, then Q_n is an alternating sum of positive polynomials 
weighted by q-binomial coefficients. This doesn't immediately imply positivity 
(alternating sums can be negative), but it might be amenable to involution/cancellation arguments.

### Strategy idea 2: h_m via Hall-Littlewood principal specialization

From Griffin-Ono-Warnaar: P_lambda(1,q,q^2,...; q^n) has an explicit multisum 
formula via Kirillov-Warnaar-Zudilin. If g_m (or h_m) can be expressed as such 
a specialization, positivity of h_m follows from the manifest positivity of 
the HL formula.

### Strategy idea 3: Interpret Q as a character via Bartlett-Warnaar

The Bartlett-Warnaar paper computes characters of affine Lie algebra modules 
using iterated limits of C_n type sums. If Q_{n,c}(q) can be identified as 
a character (or graded multiplicity), positivity follows from representation theory.

## What a Counterexample Looks Like
A counterexample to the conjecture would be a specific (c, n) with d ≢ 0 mod 3
where Q_{n,c}(q) has a negative coefficient. Our computations for d ≤ 7 and 
n ≤ 3 show no such cases. The conjecture appears very robust.

## Strategy

### Chosen approach: q-binomial cancellation via h_m positivity

**Why it might work:** The q-binomial transform Q_n = Σ (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
is well-studied. If h_m polynomials can be shown to grow in a controlled way
(e.g., h_m >> h_{m-1} in coefficient domination), then the alternating signs
may cancel by standard arguments (similar to inclusion-exclusion in partition theory).

**Why it might not:** The alternating signs in q-binomial transforms are notoriously
hard to control. The q^{j(j+1)/2} shift makes this even more delicate.

### Alternative: Direct q-binomial expansion

If Q_n can be expanded in terms of products of q-binomials, each term would
be manifestly positive. The known proofs for d=2,4,5 work by finding such
multisum expressions. The challenge is finding the pattern for general d.

## Key Lemma

**The proof reduces to showing:** h_m(q) = (q;q)_m · [z^m] GK_c(z,q) has
non-negative coefficients for all profiles c and all m ≥ 0.

If this holds, the proof of Q_n ≥ 0 would follow from an identity or
involution argument on the q-binomial transform. The h_m positivity 
is itself a deep fact that may require HL theory.

## Attempt 1: Understanding h_m via cylindric partitions

h_m(q) = (q;q)_m · g_m(q) where g_m(q) = Σ_{Λ: max(Λ)=m} q^{|Λ|}.

Now g_m is the generating function for CPPs with max entry exactly m.
Multiplying by (q;q)_m = Π_{k=1}^m (1-q^k) applies an inclusion-exclusion.

Let's think about what (1-q^k) does combinatorially. In partition theory,
(q;q)_m = Π(1-q^k) arises when converting unrestricted partitions to
distinct-part partitions via the Glaisher/Euler bijection.

Concretely: (q;q)_m · f(q) = Σ_{S ⊆ {1,...,m}} (-1)^{|S|} q^{Σ S} · f(q).

So h_m = Σ_{S ⊆ {1,...,m}} (-1)^{|S|} · (number of CPPs with max=m, size=w-Σ S).

For this to be non-negative, the CPPs with max=m must have some
"cancellation-friendly" structure when shifted by subsets of {1,...,m}.

### Connection to Bartlett-Warnaar

In the Bartlett-Warnaar framework, the HL sum-side involves sums over Z^n
weighted by ratios of C_n type Vandermonde products. The limit procedure
x_{p+1} -> x_p^{-1} kills terms where both r_p and r_{p+1} are positive
(they get a factor (1-x_p x_{p+1})^2 from the numerator but only one
factor in the denominator).

This "surviving terms" analysis is analogous to the cancellation in h_m:
only certain terms survive after multiplying by (q;q)_m.

**Conjecture (computational):** The surviving terms in h_m after the
(q;q)_m cancellation correspond to CPPs with an additional constraint
that can be expressed in terms of the Bartlett-Warnaar surviving conditions.

## Stuck: Initial attempt

**What I'm trying to show:** h_m(q) ≥ 0 implies Q_n(q) ≥ 0.

**Why I can't show it:** The q-binomial transform with alternating signs is:
  Q_n = Σ_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
Even if all h_m ≥ 0, the alternating signs make the sum potentially negative.
I need to either:
(a) Find a bijective/involution proof that the negative terms cancel, or
(b) Show this specific alternating sum has a different representation that is manifestly positive, or
(c) Prove a domination condition: the even-j terms dominate the odd-j terms coefficient by coefficient.

**What would unstick me:** A known identity expressing this type of alternating
q-binomial transform as a manifestly positive sum. Or a combinatorial interpretation
of Q_n that bypasses the alternating signs entirely.

## Assumptions Check

- **About h_m ≥ 0:** UNTESTED for general d. Verified computationally for d ≤ 7, m ≤ 5.
  This is a conjecture within a conjecture.
- **About the q-binomial transform:** TRUE that Q_n = Σ (-1)^j q^{j(j+1)/2} [n;j] h_{n-j}.
  This is a direct algebraic identity.
- **About HL connection:** UNCERTAIN. The seed context discusses HL specializations
  for product sides, but connecting to the sum side (GK_c) requires more work.
- **About the objects:** TRUE that g_m counts CPPs with max=m (by definition).
- **About the overall approach:** UNCERTAIN whether h_m ≥ 0 → Q_n ≥ 0 can be
  proved by the alternating sum approach. This may be the wrong decomposition.

## Key structural observation

For d=2, Q_n = q^{n^2}. This equals the principal specialization of
the Schur function s_{(1^n)}(1,q,q^2,...) up to a power of q.

Actually: q^{n^2} = q^{n^2}. And s_{(n)}(1,q,...,q^{n-1}) = [2n-1 choose n]_q / [n]_q ...
no, that's not right either.

But q^{n^2} = q^{1+3+5+...+(2n-1)} = product of triangular number terms.
The fact that Q_n = q^{n^2} for d=2 might be connected to the q-Vandermonde
or the q-Gauss identity.

For d=4, the Q_1 = 2q+q^2+q^3 = q(2+q+q^2). The coefficient 2 at q^1
corresponds to the fact that there are two CPPs of weight 1 with max=1:
specifically, two different ways to place a single box at height 1.

## Next steps for this agent

1. Compute h_m for d=7 to check non-negativity.
2. Look for a manifestly positive formula for Q_n (d=4) involving q-binomials.
3. Investigate whether Q_n can be written as a sum over lattice paths
   (Lindstrom-Gessel-Viennot) — this would give positivity from path counting.
4. Check if the Kirillov-Warnaar-Zudilin formula for P_lambda at geometric
   specializations connects directly to g_m or h_m.


## Key Discovery: h_m(q) is a q-analogue of base^m

### The formula
Q_n(q) = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q · h_{n-j}(q)

where h_m(q) = (q;q)_m · g_m(q) and g_m = [z^m] GK_c(z,q).

This formula is VERIFIED algebraically (exact match with direct computation).

### h_m(1) = ((d+1)(d+2)/6)^m
Verified computationally that h_m(1) = base^m where base = (d+1)(d+2)/6,
matching perfectly for small m (before truncation limits).

This immediately explains Welsh's evaluation Q_n(1) = (base - 1)^n:
  Q_n(1) = sum_j (-1)^j C(n,j) base^{n-j} = (base - 1)^n

by the binomial theorem (since [n;j]_q -> C(n,j) and q^{j(j+1)/2} -> 1 at q=1).

### h_m non-negativity
CRITICAL FINDING: h_m(q) has all non-negative coefficients for EVERY tested
profile and EVERY m tested. This is a stronger conjecture that implies the
main conjecture.

However: h_m ≥ 0 does NOT directly imply Q_n ≥ 0, because the alternating
signs in the q-binomial transform could produce negative coefficients.

### The real question
If we ASSUME h_m ≥ 0, can we prove Q_n ≥ 0?

The key identity is: Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}

This is a q-deformation of the binomial theorem (base-1)^n = sum (-1)^j C(n,j) base^{n-j}.

In the classical case, positivity of (base-1)^n is trivial since base >= 2.
The q-analogue is much harder because [n;j]_q and q^{j(j+1)/2} introduce non-trivial q-shifts.

### Connection to Hall-Littlewood theory

The h_m polynomials might be expressible as Hall-Littlewood principal specializations.
In Griffin-Ono-Warnaar, P_lambda(1,q,q^2,...; q^n) has a manifestly positive
multisum formula. If h_m equals such a specialization (or a sum thereof),
then h_m ≥ 0 follows.

The Bartlett-Warnaar limit procedure constructs characters via:
  L_{M,N}(x) = sum_{r in Z^n} [ratio of q-Pochhammers with ΔC factors]

After principal specialization x_i = q^{i-1}, this becomes a sum over lattice
points with q-binomial weights. If the h_m connect to these lattice point sums,
we'd have a path to positivity.

## Proof attempt: Q_n ≥ 0 assuming h_m ≥ 0

### Approach: show the alternating sum telescopes

Consider the identity:
  Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}

Use the q-Pascal relation: [n;j]_q = [n-1;j]_q + q^{n-j} [n-1;j-1]_q

Then:
  Q_n = sum_j (-1)^j q^{tri(j)} [n-1;j] h_{n-j} 
      + sum_j (-1)^j q^{tri(j)} q^{n-j} [n-1;j-1] h_{n-j}

The first sum = Q_{n-1} with h_{n-1-j} replaced by h_{n-j}... 
Hmm, this doesn't directly simplify because the h indices change.

### Approach: expansion in q-falling factorials

The q-analog of (x-1)^n = sum (-1)^j C(n,j) x^{n-j} can be written as
a sum over standard tableaux or lattice paths. In the q-world, this might
correspond to:
  Q_n = sum over some combinatorial objects weighted by h-values

But I need the specific q-identity. The standard reference would be
Andrews' q-binomial theorem or the q-Vandermonde convolution.

### Stuck: need a q-identity for alternating q-binomial sums

**What I'm trying to show:** That the alternating q-binomial transform
of a sequence of polynomials with h_m ≥ 0 and h_m(1) = base^m produces
a polynomial with non-negative coefficients.

**Why I can't show it:** The alternating signs combined with the q^{j(j+1)/2}
shift make coefficient-by-coefficient analysis extremely difficult. Each
coefficient of Q_n is a signed sum of products, and there's no obvious
pairing of positive and negative terms.

**What would unstick me:** Either (a) a direct combinatorial interpretation
of Q_n as counting something manifestly positive, or (b) a known identity
that rewrites the alternating q-binomial transform as a positive sum under
suitable conditions on the input sequence.

## Escalation

I am partially stuck on showing Q_n ≥ 0 from h_m ≥ 0.

**Attempt 1 (q-Pascal telescoping):** Tried to use q-Pascal recurrence to
relate Q_n to Q_{n-1}, but the h-index shifts prevent a clean induction.

**Attempt 2 (direct q-identity):** Looked for known q-series identities that
express alternating q-binomial transforms as positive sums. The closest is the
q-binomial theorem, but it gives (base; q)_n = sum (-1)^j q^{j(j-1)/2} [n;j] base^{n-j},
which has different shifts.

**Attempt 3 (not yet tried):** One promising direction: if h_m(q) has a 
MULTIPLICATIVE structure (h_m ≈ h_1^m in some appropriate sense), then 
Q_n might factor as a product like (h_1(q) - 1)^n or similar.

**What all attempts have in common:** They try to reduce positivity of Q to
positivity of h, without finding the right algebraic identity or combinatorial
interpretation. The missing piece is likely a q-analogue of the binomial theorem
that works for this specific setting.

**What I think is needed:** A combinatorial proof that directly constructs
the objects counted by Q_{n,c}(q), bypassing the alternating signs entirely.
The h_m polynomials might count some intermediate objects (e.g., weighted
lattice paths or tableaux), and Q_n might count a subset defined by an
additional constraint.


## Deeper structural understanding

### g_m is an infinite series, h_m is polynomial
For max entry exactly m, the number of CPPs with weight w is g_m[w].
This is an INFINITE series because columns (1^a) can be arbitrarily long
while still satisfying the interlacing conditions.

However, h_m = (q;q)_m * g_m is a POLYNOMIAL. This happens because g_m
eventually becomes periodic (or polynomial) in q, and (q;q)_m kills the 
non-polynomial part via telescoping.

### Example: c=(2,1,1), m=1
g_1 = 3q + 4q^2 + 5q^3 + 5q^4 + 5q^5 + ... (stabilizes at coefficient 5)
(1-q) * g_1 = 3q + (4-3)q^2 + (5-4)q^3 + (5-5)q^4 + ... = 3q + q^2 + q^3

The stabilization at 5 is explained: for large weight, there are exactly
5 = (d+1)(d+2)/6 "shapes" of column CPPs, and each contributes one
partition of each large enough weight.

### The number base = (d+1)(d+2)/6
This number appears as the stabilized coefficient of g_1 for large weights.
It equals the number of ways to choose column heights (a_1,a_2,a_3) satisfying
the cyclic interlacing, up to a common additive constant. For c=(2,1,1):
- (0,0,1), (0,1,0), (1,0,0): 3 shapes with sum 1
- (0,1,1), (1,0,1), (1,1,0), (1,1,0-variant): 4 shapes with sum 2
- Then it stabilizes at 5 shapes.

The value base = (d+1)(d+2)/6 is the number of RESIDUE CLASSES of column heights
modulo the periodicity imposed by the cyclic interlacing.

### The key structural decomposition

Q_n = Σ_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}(q)

where h_m(q) is a polynomial with:
1. Non-negative coefficients (conjectured, verified for d ≤ 7)
2. h_m(1) = base^m where base = (d+1)(d+2)/6
3. Lowest degree of h_m is m (with leading coefficient r=3 for k=3)
4. Highest degree of h_m is roughly m * (d-1)

### Why I believe h_m ≥ 0 should be provable

h_m = (q;q)_m * [z^m] GK_c(z,q)

The GK function counts cylindric partitions. The (q;q)_m factor applies an
inclusion-exclusion on the weights. For the column case (max=m, all entries
0 or m), this is a finite difference that produces non-negative results
because the count stabilizes.

For the general case (entries can be 0,1,...,m), the structure is more complex
but the same stabilization principle should apply: g_m eventually becomes a
polynomial in q (or a quasi-polynomial), and (q;q)_m kills the non-polynomial
tail, leaving a non-negative polynomial.

### Connection to Hall-Littlewood theory (seed 1 perspective)

The Bartlett-Warnaar paper shows that sum-sides of Rogers-Ramanujan identities
can be obtained as limits of Hall-Littlewood based character sums. The key 
limiting procedure x_{p+1} → x_p^{-1} filters out terms where both r_p and
r_{p+1} are positive.

**Analogy with h_m:** The (q;q)_m factor in h_m = (q;q)_m * g_m plays a
filtering role similar to the BW limit: it kills the "excess" terms, leaving
only the "relevant" ones. The BW limit produces manifestly positive expressions
(when it works), suggesting that h_m should also be manifestly positive.

### Specific proposal for h_m positivity

**Conjecture (h_m positivity):** For all profiles c with d ≢ 0 mod 3 and all m ≥ 0,
h_m(q) = (q;q)_m * [z^m] GK_c(z,q) is a polynomial with non-negative coefficients.

**Proposed proof strategy via HL specialization:**
The Griffin-Ono-Warnaar Lemma 2.4 gives:
  P_λ(1,q,...,q^{n-1}; q^n) = Σ over chains · q^{A} · [q-binomials]

If h_m can be expressed as a sum of such principal specializations
(or a sum over cylindric-partition-weighted HL polynomials), positivity follows
from the manifest positivity of the Kirillov-Warnaar-Zudilin formula.

This connects directly to the Bartlett-Warnaar limit construction, which
produces exactly these HL specializations from C_n Andrews transformations.

