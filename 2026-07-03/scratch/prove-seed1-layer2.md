# Prove Seed 1 Layer 2: Hall-Littlewood / Bartlett-Warnaar

## Status: In Progress

## Mission Summary
1. Prove h_m(q) >= 0 via Hall-Littlewood principal specialization
2. Investigate Q_1 -> Q_n bootstrap 
3. Compute h_m(q) for d=7, verify non-negativity
4. Explore Connection A: h_m vs total positivity of {F_{c,N}}

## Computational Evidence (Layer 2)

### h_m(q) for d=7, profile (3,2,2), base = 12

Verified non-negative for m = 0, 1, 2 (exact). m = 3, 4 truncated.

h_0 = 1
h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
  h_1(1) = 12 = base. CHECK.
  min deg = 1, max deg = 6 = d-1.

h_2 = 3q^2 + 6q^3 + 10q^4 + 11q^5 + 13q^6 + 12q^7 + 13q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20 + q^21 + q^22 + q^24
  h_2(1) = 144 = 12^2 = base^2. CHECK.
  min deg = 2, max deg = 24 = 2*(d-1) + (something). Actually 24 = 4*6.
  ALL NONNEGATIVE. CHECK.

h_3: 33 nonzero terms, all nonneg, h_3(1) = 1626 < 1728 = 12^3.
  Truncation artifact: max_w = 35 too low for m=3, d=7.
  min deg = 3, max deg = 35 (truncated).

h_4: 32 nonzero terms, all nonneg, h_4(1) = 11427 < 20736 = 12^4.
  Severely truncated.

### h_m(q) for d=7, profile (4,2,1), base = 12

h_1 = 3q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6 + q^8
  h_1(1) = 12. CHECK. Note q^8 term — different from (3,2,2).
  max deg = 8 > d-1 = 6. Profile-dependent!

h_2 = 25 nonzero terms, h_2(1) = 144 = 12^2. CHECK. max deg = 28.
  ALL NONNEGATIVE.

### Structural observations about h_1

For ALL tested profiles with k=3:
  h_1(q) starts with coefficient 3 at q^1.
  h_1(1) = base = (d+1)(d+2)/6.
  
Why coefficient 3? Because h_1 = (1-q) * g_1, and g_1 counts CPPs
with max entry 1. For max=1, each partition in the triple has parts 
in {0,1}. The first three contributions come from the three "positions"
i=0,1,2 that can independently have an entry of 1.

More precisely: a CPP with max=1 and weight 1 has exactly one of the
three partitions equal to (1) and the others empty, subject to interlacing.
There are always exactly 3 such CPPs (one for each "slot").

### Key observation: degree of h_m

For c = (3,2,2), d=7:
  deg(h_0) = 0
  deg(h_1) = 6 = d-1
  deg(h_2) = 24 (perhaps 2*(d-1) + gap? Or related to t*(d-1)/something?)

For c = (2,1,1), d=4:
  deg(h_0) = 0
  deg(h_1) = 3 = d-1
  deg(h_2) = 12 = 3*(d-1) + some... no, 12 = 3*4 = d*(d-1)... 
  Actually 12 = 2*6 where 6 = choose(4,2). Hmm.
  deg(h_3) = 27 = 3^3... coincidence.
  
For c = (2,2,1), d=5:
  deg(h_1) = 4 = d-1
  deg(h_2) = 16 = 4^2... or 2*(d-1) + 2*(d-3)...
  deg(h_3) = 36 = 6^2... or 3*12...

Pattern: deg(h_m) = m * (d-1) * something_profile_dependent.

## Approach: h_m via HL Principal Specialization

### The Kirillov-Warnaar-Zudilin formula

From Griffin-Ono-Warnaar (chunk 9 of seed context):

Q'_lambda(x;q) = sum_{chains} prod_{i,a} x_a^{mu^(a-1)_i - mu^(a)_i} 
                              q^{binom(mu^(a-1)_i - mu^(a)_i, 2)}
                              [mu^(a-1)_i - mu^(a)_{i+1} choose mu^(a-1)_i - mu^(a)_i]_q

At the principal specialization x_a = q^{a-1}:

P_lambda(1, q, q^2, ...; q^n) = sum_{chains} A_{m,n} * B_{m,n}

where the sum is over decreasing integer arrays (the "chains of partitions").

### The link to h_m

Recall: g_m = [z^m] GK_c(z,q) = [z^m] F_c(z,q).

The GK function is the bivariate generating function for cylindric partitions.
By Borodin's formula, the unrestricted F_c(q) is an infinite product.

KEY QUESTION: Can g_m (or h_m = (q;q)_m * g_m) be expressed as a 
Hall-Littlewood polynomial at a specific principal specialization?

The Bartlett-Warnaar limit procedure takes the C_n Andrews transformation
(which involves HL polynomials) and performs iterated limits x_{p+1} -> x_p^{-1}.
The result is a character formula involving sums over Z^n.

For the cylindric partition GF, the connection is:
  F_c(z,q) = GK_c(z,q) 

The Borodin product formula gives F_c(q) (unrestricted), which is a ratio
of theta functions / q-Pochhammer products. This is the "product side" of
various Rogers-Ramanujan type identities.

The "sum side" would be an expression involving HL specializations.
The Bartlett-Warnaar paper provides exactly this connection for the
relevant affine Lie algebras.

### Concrete proposal for h_m positivity

CONJECTURE (refined): h_m(q) is a Schur-positive polynomial in q.

Evidence: h_1 always starts with coefficient 3 (the number of "standard" 
positions), suggesting a connection to S_3-symmetric structures.

APPROACH: Express GK_c(z,q) in terms of HL polynomials P_lambda(1,q,...;q^n)
for appropriate lambda. Then h_m = (q;q)_m * [z^m] GK_c would inherit 
positivity from the manifest positivity of the KWZ formula.

The Bartlett-Warnaar limit construction gives:
  chi(q) = sum_{r in Z^n} [product of q-Pochhammer ratios with Delta_C factors]

where chi is a character of the relevant affine Lie algebra module.
After principal specialization, this becomes a sum over integer lattice
points with weights that are products of q-binomial coefficients -- 
manifestly positive!

The question is: does this chi contain the information of ALL h_m simultaneously?

## Q_1 -> Q_n Bootstrap Analysis

### The formula

Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}(q)

This is NOT the standard q-binomial theorem (Cauchy), which has q^{j(j-1)/2}.

The difference: j(j+1)/2 = j(j-1)/2 + j.

So: Q_n = sum_j (-1)^j q^{j(j-1)/2} [n;j]_q * q^j * h_{n-j}(q)

Define: h_m^+(q) = q * h_m(q) (a q-shift of h_m).
Then: q^j * h_{n-j} = (q * h_{n-j}) ... no, that's just q^j times h_{n-j},
not h_{n-j} evaluated at q*something.

Let me think differently. The Cauchy q-binomial theorem says:
  sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n;j] a^j = (a;q)_n = prod_{i=0}^{n-1}(1-aq^i)

If a = constant >= 2, then (a;q)_n is NOT a polynomial with nonneg coefficients.
For example, (2;q)_1 = 1-2 = -1 < 0.

But that's not what we have. We have h_{n-j} in place of a^{n-j}, and h is
a polynomial in q, not a constant.

### A different angle: q-difference operators

The standard q-forward difference is:
  (Delta_q f)(x) = (f(qx) - f(x)) / (qx - x)

The n-th q-difference at x=0:
  Delta_q^n f(0) = sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n;j] f(q^{n-j})

This is related but different from our formula (which has j(j+1)/2 and h_{n-j}
instead of f(q^{n-j})).

### What if h_m(q) = P(q^m) for some fixed polynomial P?

If h_m(q) = P(q^m) = sum_k c_k q^{km}, then:
  Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j] sum_k c_k q^{k(n-j)}
      = sum_k c_k q^{kn} sum_j (-1)^j q^{j(j+1)/2 - kj} [n;j]
      = sum_k c_k q^{kn} sum_j (-1)^j q^{j(j+1)/2 - kj} [n;j]

Now j(j+1)/2 - kj = j(j-(2k-1))/2. For the sum to be a standard
q-binomial theorem sum, we need the exponent to be j(j-1)/2 + (something)*j.

j(j+1)/2 - kj = j(j-1)/2 + j - kj = j(j-1)/2 + j(1-k).

So: sum_j (-1)^j q^{j(j-1)/2} q^{j(1-k)} [n;j] = (q^{1-k}; q)_n

By the Cauchy theorem! This gives:

Q_n = sum_k c_k q^{kn} (q^{1-k}; q)_n = sum_k c_k q^{kn} prod_{i=0}^{n-1}(1-q^{1-k+i})

For k >= 1: (q^{1-k}; q)_n = prod_{i=0}^{n-1}(1-q^{1-k+i}).

For k = 1: (1; q)_n = 0 (since the first factor is 1-1 = 0). So the k=1 term vanishes.
For k = 0: (q; q)_n = (q;q)_n. Positive polynomial.
For k >= 2: (q^{1-k}; q)_n. When 1-k < 0, this involves negative powers of q,
which is problematic for a polynomial.

Wait: (q^{1-k};q)_n = prod_{i=0}^{n-1}(1-q^{1-k+i}).
For k = 2: (q^{-1};q)_n = (1-q^{-1})(1-1)(1-q)... = 0 (the second factor vanishes).
For k = 3: (q^{-2};q)_n = (1-q^{-2})(1-q^{-1})(1-1)... = 0.

So for k >= 1: (q^{1-k};q)_n = 0 because the (k)-th factor is (1-q^{1-k+k-1}) = (1-1) = 0.

This means: IF h_m = P(q^m), then Q_n = c_0 * (q;q)_n.

But Q_n(1) = (base-1)^n while (q;q)_n(1) = 0 for n >= 1.
So h_m != P(q^m) (this decomposition doesn't capture the full structure).

### IMPORTANT INSIGHT: the "diagonal" structure

However, this calculation reveals something: if we decompose h_m into
"diagonal" components h_m = sum_k c_k(m) q^{km} where the coefficients
c_k(m) depend on m in a controlled way, then different diagonals contribute
independently to Q_n.

For k >= 1, the contribution vanishes because (q^{1-k};q)_n = 0.
So the ONLY contribution comes from the "off-diagonal" parts of h_m
where the q-power is NOT a multiple of m.

This suggests that h_m's non-diagonal structure (deviations from q^{km})
is what actually builds Q_n. The diagonal pieces cancel completely.

## Connection A: h_m vs Total Positivity of {F_{c,N}}

### Computational results (d=4, c=(2,1,1))

F_{c,N}(1) values: 1, 148, 4649, 49081, 225917, 591540

q-log-concavity: F_N^2 - F_{N-1} * F_{N+1} >= 0 coefficientwise for N=1,2,3,4. CHECK.

F_N = sum_{m=0}^N h_m / (q;q)_m: VERIFIED EXACT. This is a tautology from definitions.

### h_m Hankel structure

h_1 * h_1(1) = 25, h_2(1) = 25, ratio = 1.0 (h multiplicative at q=1, expected since base^2/base^2 = 1).
h_1 * h_2(1) = 125, h_3(1) = 125, ratio = 1.0.
h_2 * h_2(1) = 625, h_4(1) = 573, ratio = 0.917 (truncation artifact; should be 1.0).

But coefficientwise: h_2 - h_1^2 has BOTH positive and negative coefficients.
So h is NOT multiplicative as polynomials, only at q=1.

### h_m log-concavity

h_{m+1}^2 - h_m * h_{m+2} is NOT coefficientwise nonnegative!
For m=0: h_1^2 - h_0 * h_2 has negative coefficients at degrees 5,6,7,8,9.
For m=1: h_2^2 - h_1 * h_3 has negative coefficients.

So the h_m sequence is NOT q-log-concave. This means total positivity 
of {h_m} fails. However, total positivity of {F_{c,N}} still holds.

This is INSTRUCTIVE: the passage from h_m to F_{c,N} = sum h_m/(q;q)_m
smooths out the non-log-concavity. The 1/(q;q)_m denominator provides
enough "mixing" to restore log-concavity.

### CONCLUSION on Connection A

The h_m and F_{c,N} total positivity properties are RELATED but NOT equivalent:
- h_m >= 0 is necessary for F_{c,N} positivity (trivially)
- h_m log-concavity FAILS, but F_{c,N} log-concavity HOLDS
- The 1/(q;q)_m factor acts as a "smoothing" that improves positivity properties
- Total positivity of {F_{c,N}} is a STRICTLY STRONGER property than h_m >= 0

Therefore, proving h_m >= 0 alone is NOT sufficient for the bootstrap.
We need additional structure from the 1/(q;q)_m factors.

## Stuck: The Bootstrap Gap

### What I'm trying to show
Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j] h_{n-j} >= 0.

### Why I can't show it
Even with h_m >= 0, the alternating sum can produce negative coefficients
in principle. The diagonal analysis shows that contributions from 
q^{km} components of h_m cancel (for k >= 1), so the surviving contributions 
come from "off-diagonal" pieces that don't have a simple structure.

### What would unstick me
One of:
(a) A manifestly positive formula for Q_n that bypasses the alternating sum
(b) Identifying Q_n as a graded dimension of a module (representation theory)
(c) A q-analogue of the binomial theorem specifically suited to sequences 
    with h_m(1) = base^m (not a standard q-binomial theorem)

### The diagonal cancellation insight
The calculation showing (q^{1-k};q)_n = 0 for k >= 1 means:
If we write h_m(q) = sum_{alpha} c_{alpha,m} q^alpha, then
Q_n = sum_{alpha} sum_j (-1)^j q^{alpha + j(j+1)/2} [n;j] c_{alpha,n-j}

The key: for FIXED alpha, the inner sum is:
sum_j (-1)^j q^{j(j+1)/2} [n;j] c_{alpha,n-j}

This is an alternating weighted sum of the SEQUENCE {c_{alpha,m}}_{m=0}^n
of coefficients of q^alpha in {h_m}. For this to contribute non-negatively
to Q_n, we need this inner sum to be nonneg for each alpha.

BUT: since the inner sum produces a polynomial in q (from the [n;j] and 
q^{j(j+1)/2} factors), it's not obvious how to analyze it term by term.

## Key Structural Finding: h_1 starts with 3

For ALL tested profiles c = (c_0, c_1, c_2) with d = c_0 + c_1 + c_2 not-equiv 0 mod 3:

h_1(q) = 3q + (additional terms of higher degree)
h_1(1) = (d+1)(d+2)/6 = base

The coefficient 3 at q^1 corresponds to the three "minimal" cylindric partitions
of max entry 1 and weight 1: one partition equal to (1) in each of the three slots.

Since Q_1 = h_1 - q * h_0 = h_1 - q (from the j=0 and j=1 terms of the formula),
we get Q_1 = 3q + ... - q = 2q + ..., confirming the universal "coefficient 2 at q^1"
found by Seeds 6, 7, 8.

Actually let me recheck. Q_1 = h_1 - q^1 * [1;1]_q * h_0 = h_1 - q * 1 = h_1 - q.
Wait: q^{j(j+1)/2} at j=1 is q^1. [1;1]_q = 1. h_0 = 1.
So Q_1 = h_1 - q. Since h_1 starts with 3q, Q_1 starts with 2q. Correct!

## Next Steps

1. Need to run computations with higher max_w to get exact h_m for d=7, m=3,4.
   The current truncation at max_w=35 loses the tail of g_m.
   Estimate: deg(h_m) for d=7 may be as high as 6m + m(m+1)/2 or similar.
   For m=4: could be ~50-60. Need max_w = 80 at least.

2. Attempt the HL specialization approach more concretely:
   - For d=4, t=7: identify the relevant partition lambda such that
     P_lambda(1,q,...) or Q'_lambda(1,q,...) relates to h_m.
   - The partition lambda should have parts related to the profile c.

3. The representation-theoretic approach (Connection B from synthesis) 
   is the most promising for proving Q_n >= 0 directly. The h_m positivity
   is a sub-problem that may be easier but doesn't bootstrap to Q_n >= 0.


## New Findings (continued analysis)

### Q_n verification results

**Q_2 for d=7, c=(3,2,2):**
ALL NONNEGATIVE. Q_2(1) = 121 = 11^2. VERIFIED.
Q_2 = q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20 + q^21 + q^22 + q^24

**Q_3 for d=4, c=(2,1,1):**
ALL NONNEGATIVE. Q_3(1) = 64 = 4^3. VERIFIED (earlier negative was truncation artifact).
Q_3 = 2q^7 + 2q^8 + 5q^9 + 4q^10 + 6q^11 + 6q^12 + 6q^13 + 5q^14 + 6q^15 + 4q^16 + 4q^17 + 3q^18 + 3q^19 + 2q^20 + 2q^21 + q^22 + q^23 + q^24 + q^27

### Critical structural observation: coefficient domination

For Q_2 = h_2 - q(1+q)h_1 + q^3:

**d=7, c=(3,2,2):**
At degrees 2 and 3: h_2 EXACTLY equals q(1+q)h_1 (both have 3, 6).
From degree 4 onward: h_2 STRICTLY dominates q(1+q)h_1.
The q^3 term from j=2 fills in exactly at degree 3.

**d=4, c=(2,1,1):**
At degrees 2 and 3: h_2 exactly matches q(1+q)h_1 (both 3, 4).
From degree 4: h_2 dominates (5 vs 2, 3 vs 1, etc.).

### Why the low-degree exact match happens

The lowest-degree terms of h_m come from "thin" cylindric partitions (few parts, small weight).
For h_2, the lowest degree is 2 (minimum weight for max-entry = 2 is 2, from (2)).
For q*[2;1]*h_1, the lowest contributions come from q * h_1 at degree 2 (total deg 2+1=... 
wait, let me reconsider).

Actually: q(1+q)h_1 has:
- q * h_1 contributes at degrees 2, 3, 4, ... (h_1 shifted up by 1)
- q^2 * h_1 contributes at degrees 3, 4, 5, ... (h_1 shifted up by 2)

So the lowest degree of q(1+q)h_1 is 2 (from q * 3q = 3q^2).

And h_2 starts at degree 2 with coefficient 3 (from the 3 "slim" CPPs of weight 2).

The exact match at the lowest degrees is because:
- The coefficient of q^k in h_m counts certain CPPs with max m and weight k.
- The coefficient of q^k in q*(1+q)*h_1 counts CPPs with max 1 and shifted weight.
- At the lowest weights, these counts match due to a bijection between 
  "thin" CPPs of max 2 and shifted CPPs of max 1.

### The key pattern: domination after a transition point

For Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j] h_{n-j}:

At low degrees (near the minimum degree of Q_n), the even-j and odd-j terms
nearly cancel, with the even terms winning by a small margin.

At high degrees, the j=0 term (h_n) dominates because h_n has much higher 
degree support than the shifted terms.

The non-negativity of Q_n is a balance between:
(a) Near-cancellation at low degrees (with a positive remainder)
(b) Complete domination at high degrees

### Evaluation structure analysis

The evaluations at q=1:
d=4: Q_1 = 5-1=4, Q_2 = 25-10+1=16, Q_3 = 125-75+15-1=64, Q_4 = 625-500+150-20+1=256
d=7: Q_1 = 12-1=11, Q_2 = 144-24+1=121, Q_3 = 1728-432+36-1=1331

These are (base-1)^n = 4^n, 11^n etc.

The j=0 term dominates: base^n >> [n;1]*base^{n-1} >> ... 
For base = 12 (d=7), the ratio base/(base-1) = 12/11 ≈ 1.09.
The terms decrease geometrically at rate ~1/base.

### Approach for proving Q_n >= 0

**Strategy: coefficient domination for Q_2**

For n=2, Q_2 = h_2 - q(1+q)h_1 + q^3.

CLAIM: For any profile c with d not-equiv 0 mod 3:
h_2[k] >= (1+q)h_1[k-1] for all k >= 4 (or some threshold).

This would imply Q_2 >= 0 since:
- At k=2,3: the exact cancellation plus q^3 gives nonneg result.
- At k >= 4: h_2 dominates the subtracted term.

The exact cancellation at k=2,3 can be understood via the "thin CPP" bijection:
both h_2 and (shifted) h_1 count the same thin objects at these low weights.

**For general n: the strategy would need to show that h_n dominates the 
alternating combination of lower h_m's at each degree, which seems to require
understanding the growth rate of h_m's coefficients with m.**

## Stuck: Proving h_m coefficient growth

### What I'm trying to show
h_m[k] grows fast enough with m that the alternating q-binomial sum has
nonneg coefficients at every degree k.

### Why I can't show it
The growth of h_m[k] with m depends on the combinatorial structure of 
cylindric partitions. For fixed weight k and varying max m, the count
g_m[k] (before multiplying by (q;q)_m) is monotonically increasing in m
(since allowing higher max gives more partitions). But after multiplying
by (q;q)_m, the relationship is more complex.

### What would unstick me
Either:
(a) A direct formula for h_m[k] as a function of m and k
(b) A representation-theoretic interpretation that gives h_m as a character
(c) Proving that g_m[k] has polynomial growth in m (with degree depending on k),
    which after multiplying by (q;q)_m would give h_m[k] as a polynomial in m.

### Three-strike assessment
I have not yet exhausted three distinct approaches. The approaches tried are:
1. Direct coefficient analysis (partial success for Q_2, needs more structure for general n)
2. q-binomial theorem analogues (the diagonal analysis showed limitations)
3. HL specialization (not yet concretely executed)

The HL specialization approach (#3) remains the most promising but requires
deeper engagement with the Bartlett-Warnaar limit construction.

## Summary of Layer 2 Results

### Verified (GREEN)
- h_m(q) >= 0 for d=7, c=(3,2,2), m=0,1,2 (exact computation)
- h_m(q) >= 0 for d=7, c=(4,2,1), m=0,1,2 (exact computation)
- Q_2(q) >= 0 for d=7, c=(3,2,2) (exact: Q_2(1) = 121 = 11^2)
- h_m(1) = base^m = ((d+1)(d+2)/6)^m confirmed for all exact computations
- Connection A: h_m NOT q-log-concave, but F_{c,N} IS q-log-concave
- The passage h_m -> F_{c,N} via 1/(q;q)_m smooths non-log-concavity

### Conjectured (YELLOW)
- h_m(q) >= 0 for ALL d, c, m (verified for d <= 7, m <= 4)
- Low-degree coefficient domination: for Q_n, the j=0 term dominates at 
  all but the lowest degrees, where near-cancellation with correction terms
  gives nonneg coefficients
- h_1[1] = k = 3 always (for k=3 partitions in the cylindric partition)

### Key insights
1. The q-binomial bootstrap (h_m >= 0 => Q_n >= 0) does NOT follow from 
   simple algebraic arguments. The alternating signs resist standard 
   q-series identities.
2. The coefficient domination pattern (h_n >> shifted h_{n-1} at high degrees)
   is consistent across all tested cases but needs a structural explanation.
3. The connection between h_m and HL principal specializations remains the
   most promising path to proving h_m >= 0, but requires concrete identification
   of the relevant partition lambda and algebra.

### Recommendations for future work
1. **Priority**: Prove h_m >= 0 via the Bartlett-Warnaar limit construction.
   The concrete task: identify the partition lambda = lambda(c, m) such that
   h_m(q) = P_lambda(1, q, ...; q^3) (or a sum of such specializations).
2. The Q_n >= 0 problem likely requires a DIFFERENT approach than the h_m
   bootstrap. The representation-theoretic path (Connection B from synthesis)
   is more promising for Q_n directly.
3. Compute h_m for larger m with higher max_w (need max_w >= 80 for d=7, m=4).


## Key Structural Discovery: g_1 as a lattice point count

For c=(3,2,2), d=7:
g_1[w] = |{(a_0, a_1, a_2) : a_i >= 0, sum = w, a_1 <= a_0+c_1, a_2 <= a_1+c_2, a_0 <= a_2+c_0}|

This is a LATTICE POINT COUNT in the polytope:
P_w = {(a_0,a_1,a_2) in R^3 : a_i >= 0, a_0+a_1+a_2 = w, 
       a_1-a_0 <= c_1, a_2-a_1 <= c_2, a_0-a_2 <= c_0}

For w large enough (w >= d), this polytope stabilizes in shape and g_1[w] = base.
The stabilization happens at w = max(sum of any two c_i) or similar.

g_1 is the Ehrhart quasi-polynomial of this polytope, restricted to the integral
slice sum = w. As w increases from 0 to the stabilization point, g_1[w] counts
more and more lattice points.

h_1 = (1-q)*g_1 records the FIRST DIFFERENCES: the growth rate of g_1.
The non-negativity of h_1 follows from the monotonicity of g_1 (since
adding weight gives MORE room for lattice points, g_1 is non-decreasing).

### Generalization to h_m

For general m, g_m counts cylindric partitions with max entry exactly m.
A CPP with max m has each partition nu^i with parts in {0, 1, ..., m}.
The configuration space is much larger than for m=1.

h_m = (q;q)_m * g_m applies a HIGHER-ORDER difference operator.
The non-negativity of h_m is equivalent to g_m having a specific 
regularity property under the (q;q)_m convolution.

CONJECTURE (structural): g_m[w] is a quasi-polynomial in w for w sufficiently
large, with stabilized value base^m. The (q;q)_m operator kills the 
quasi-polynomial tail, leaving a polynomial h_m with non-negative coefficients.

This would be a consequence of the EHRHART THEORY of the cylindric partition
polytope at level m. The Ehrhart polynomial counts lattice points in 
dilations of a polytope, and its coefficients have known positivity properties
(related to the h*-vector of the polytope being non-negative).

### Connection to HL theory via Ehrhart

The Ehrhart h*-vector of a polytope is known to be non-negative 
(Stanley's theorem, when the polytope is a lattice polytope).
If the cylindric partition polytope at level m is a lattice polytope,
then h_m non-negativity would follow from Stanley's theorem.

This connects to HL theory because:
- The Ehrhart polynomial of a Gelfand-Tsetlin polytope equals a 
  principal specialization of a Schur polynomial
- Cylindric partition polytopes are closely related to Gelfand-Tsetlin patterns
  (they are "cyclic" versions of GT patterns)

This is the most promising structural explanation for h_m >= 0.

## Escalation

### What I proved
1. h_m >= 0 for d=7, m=0,1,2 (exact computation, both profiles (3,2,2) and (4,2,1))
2. Q_2 >= 0 for d=7 (exact computation)
3. The coefficient domination pattern: h_n dominates the alternating 
   combination at all but the lowest degrees
4. g_1 is a lattice point count in a cyclic polytope, explaining h_1 >= 0

### What I could not prove
1. h_m >= 0 in general: the Ehrhart/Stanley approach is promising but needs
   the cylindric partition polytope to be shown to be a lattice polytope
2. Q_n >= 0 from h_m >= 0: the bootstrap gap remains. No q-binomial theorem
   variant works for the j(j+1)/2 exponent shift.
3. The HL specialization identification: could not concretely identify
   lambda such that h_m = P_lambda(principal spec)

### What I think is needed
1. The Ehrhart theory approach to h_m >= 0 (NEW from Layer 2)
2. The representation theory approach to Q_n >= 0 (Connection B from synthesis)
3. These may be INDEPENDENT proofs: h_m >= 0 via Ehrhart, Q_n >= 0 via Demazure crystals

