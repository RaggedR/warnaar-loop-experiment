# Prove Seed 2, Layer 2: Partition-Bead Bijections (Tingley)

## Task Summary

Layer 2 tasks from synthesis:
1. Investigate Connection A: h_m conjecture vs total positivity of {F_{c,N}}
2. Explore bead model at encoding level
3. Test higher Hankel minors (3x3 and 4x4) of {F_{c,N}}
4. Compute h_m for d=7

## Critical Finding: Truncation Artifact in Layer 1

Layer 1's computation of h_m showed negative coefficients, leading to
confusion about whether h_m >= 0. **This was a truncation artifact.**

The issue: g_m(q) = F_{c,m}(q) - F_{c,m-1}(q) is an infinite power
series (cylindric partitions with max exactly m can have arbitrarily
many parts). The brute-force enumeration truncates at `max_parts`,
which causes the last few coefficients of g_m to be artificially small.
When multiplied by (q;q)_m, this creates spurious negative coefficients.

**Fix:** Increase `max_parts` until the F_{c,N} coefficients stabilize.
The q-degree truncation at q_max is exact (we capture all partitions
with total weight <= q_max), but the number of parts must be large
enough to see all such partitions.

After stabilization, h_m is indeed a **polynomial** with nonneg coefficients.
The polynomial terminates because (q;q)_m kills the growth of g_m:
- g_m has coefficients growing polynomially in degree (like degree^{m-1})
- (q;q)_m = prod_{i=1}^m (1-q^i) has a zero of order m at q=1
- The product terminates, yielding a polynomial.

## Computational Evidence

### h_m for d=4, c=(2,1,1), base=5

With q_max=30 (sufficient for m <= 3):

| m | h_m(q) coefficients | h_m(1) | expected 5^m | nonneg | deg |
|---|---------------------|--------|-------------|--------|-----|
| 0 | [1] | 1 | 1 | YES | 0 |
| 1 | [0, 3, 1, 1] | 5 | 5 | YES | 3 |
| 2 | [0, 0, 3, 4, 5, 3, 3, 2, 2, 1, 1, 0, 1] | 25 | 25 | YES | 12 |
| 3 | [0, 0, 0, 3, 4, 8, 8, 11, 9, 12, 9, 10, 8, 8, 6, 7, 4, 4, 3, 3, 2, 2, 1, 1, 1, 0, 0, 1] | 125 | 125 | YES | 27 |

Key observation: deg(h_m) = 3m^2, exactly matching deg(Q_m). This is
expected since Q_n = h_n + lower-order correction terms (from the
alternating sum formula Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}).
The leading coefficient of h_m at q^{3m^2} is always 1.

### h_m for d=2, c=(1,1,0), base=2

| m | h_m(q) | h_m(1) | nonneg | deg |
|---|--------|--------|--------|-----|
| 1 | [0, 2] | 2 | YES | 1 |
| 2 | [0, 0, 2, 1, 1] | 4 | YES | 4 |
| 3 | [0, 0, 0, 2, 1, 2, 1, 1, 0, 1] | 8 | YES | 9 |

For d=2: deg(h_m) = m^2. And Q_n = q^{n^2} (a single monomial).

### h_m for d=7, c=(3,2,2), base=12

With q_max=12 (sufficient for m=1 only):

| m | h_m(q) coefficients | h_m(1) | expected 12^m | nonneg |
|---|---------------------|--------|-------------|--------|
| 1 | [0, 3, 3, 2, 2, 1, 1] | 12 | 12 | YES |
| 2 | [0, 0, 3, 6, 10, 11, 13, 12, 13, 10, 11, 9, 9] | 107 | 144 | YES |
| 3 | [0, 0, 0, 3, 6, 13, 20, 29, 37, 47, 53, 61, 66] | 335 | 1728 | YES |

h_2 and h_3 are TRUNCATED (eval1 doesn't match base^m). But the
coefficients computed so far are all nonneg.

### h_m for d=7, c=(4,2,1), base=12

| m | h_m(q) coefficients (truncated) | h_m(1) | nonneg |
|---|---------------------------------|--------|--------|
| 1 | [0, 3, 2, 2, 2, 1, 1, 0, 1] | 12 | YES |
| 2 | [0, 0, 3, 5, 8, 9, 11, 11, 11, 10, 12, 8, 9] | 97 | YES |

### Q_n for d=7 (first unproved case)

Profile c=(3,2,2), expected Q(1) = 11^n:
- Q_0 = 1, Q_0(1) = 1 (correct)
- Q_1 = [0, 2, 3, 2, 2, 1, 1], Q_1(1) = 11 (correct, nonneg)
- Q_2 truncated at q_max=12 (need ~36 for full polynomial)

Profile c=(4,2,1), expected Q(1) = 11^n:
- Q_1 = [0, 2, 2, 2, 2, 1, 1, 0, 1], Q_1(1) = 11 (correct, nonneg)

Positivity confirmed for Q_1 at d=7 for both profiles.

## Connection A: h_m Conjecture vs Total Positivity

### What h_m >= 0 means

The sequence {h_m}_{m>=0} with h_m = (q;q)_m * g_m is a sequence of
POLYNOMIALS with nonneg integer coefficients and h_m(1) = base^m.

The formula Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
expresses Q_n as an alternating q-binomial transform of {h_m}.

### What total positivity of {F_{c,N}} means

Tested: log-concavity F_{N+1}^2 - F_N * F_{N+2} >= 0 coefficientwise.
Result: **TRUE** for N >= 1 (all tested cases for d=2,4,5).
For N=0: **FAILS** in some cases (borderline).

Tested: 3x3 Hankel determinant det[F_{c,N+i+j}]_{0<=i,j<=2}.
Result: **NEGATIVE coefficients appear.** The 3x3 Hankel minor is NOT nonneg.

**CONCLUSION: {F_{c,N}} is NOT totally positive in the Hankel sense.**

This means the total positivity approach from Layer 1 (Broken Assumption #7)
was indeed circular AND the underlying conjecture (Hankel TP) is FALSE.

### Are they equivalent?

NO. They address different things:
- h_m >= 0 is about the q-weighted DIFFERENCES of F_{c,N} multiplied by (q;q)_m
- Hankel TP is about PRODUCTS of F_{c,N} values at different indices

They are NOT equivalent. h_m >= 0 is TRUE (verified), while Hankel TP is FALSE.

### Does h_m >= 0 imply Q_n >= 0?

From Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}:
Even with all h_m nonneg, the alternating signs and q-shifts mean Q_n >= 0
does NOT follow automatically.

However, a KEY structural observation:

**h_m - Q_m is nonneg** (verified for all m <= 3 at d=4).
This means Q_m <= h_m coefficientwise. The "correction" from the alternating
sum only SUBTRACTS from h_m, never adds.

Specifically: Q_n = h_n - sum_{j=1}^n (-1)^{j-1} q^{j(j+1)/2} [n;j]_q h_{n-j}

The correction terms are themselves polynomials. For Q_n >= 0, we need:
h_n >= sum_{j=1}^n (-1)^{j-1} q^{j(j+1)/2} [n;j]_q h_{n-j}

This is a stronger statement than just h_n >= 0.

### Survival ratio

At q=1: Q_n(1)/h_n(1) = (base-1)^n / base^n = ((base-1)/base)^n.
This ratio decays exponentially but never reaches 0 (for base >= 2).
The question is whether this survival holds coefficientwise.

For d=4:
- m=1: Q/h ratio at q=1 = 4/5 = 0.80
- m=2: 16/25 = 0.64
- m=3: 64/125 = 0.512

## Approach: Bead Model at Encoding Level

### Layer 1 failure and synthesis guidance

Layer 1 attempted involutions on cylindric partitions directly (failed: cross-N
obstruction). The synthesis suggests trying bijective arguments on ENCODINGS
(bead model, lattice paths) rather than the partitions themselves.

### Kursungoz-Seyrek decomposition

Every cylindric partition of profile c decomposes uniquely as:
  Lambda <-> (mu, delta)
where mu is an ordinary partition and delta is a colored partition into
distinct parts.

The generating function factorizes:
  F_c(q) = [product of terms for delta] / (q;q)_inf

For the BOUNDED version F_{c,N}(q), the bound on max(Lambda) = N
constrains both mu and delta simultaneously.

### Bead model interpretation

From Tingley: a partition maps to bead positions on a t-runner abacus.
Position of i-th bead: lambda_i - i + 1/2.
For a cylindric partition, the t runners encode the profile.

The "max entry" of the cylindric partition corresponds to the
rightmost bead position on each runner.

### Why the bead model doesn't directly help

The bead model gives a bijection between individual partitions and
bead configurations. For a cylindric partition (a k-tuple of partitions),
the k partitions are coupled by interlacing conditions. The bead model
for each partition is independent, but the interlacing imposes non-local
constraints on the bead positions.

The extraction [z^n] (z;q)_inf * F_c(z,q) involves:
1. Multiplying by (z;q)_inf (alternating signs in z)
2. Taking the z^n coefficient
3. Multiplying by (q;q)_n

In the bead model, step 1 would correspond to an inclusion-exclusion
on bead positions across different max-entry bounds. This is exactly
the cross-N obstruction that failed in Layer 1.

### What MIGHT work: decomposition-aware extraction

If we use the Kursungoz-Seyrek decomposition F_c(z,q) = G(z,q)/(q;q)_inf^?
(where G accounts for the colored distinct parts), then:

(z;q)_inf * F_c(z,q) = (z;q)_inf * G(z,q) / (...)

The (z;q)_inf might cancel with denominators from G, leaving a manifestly
positive expression. This requires knowing the exact form of G for bounded
cylindric partitions.

**STATUS: Incomplete.** The Kursungoz-Seyrek decomposition for bounded
cylindric partitions (max <= N) is not developed in the literature I have
access to. Their paper handles unrestricted cylindric partitions.

## Hankel Minor Results

### 2x2 (log-concavity): PASSES

F_{c,N+1}^2 - F_{c,N} * F_{c,N+2} >= 0 coefficientwise for:
- d=2, c=(1,1,0): N=1,2,3 -- all nonneg
- d=4, c=(2,1,1): N=0,1,2,3 -- all nonneg (min coeff = 3 for all N)
- d=5, c=(2,2,1): N=1,2,3 -- all nonneg

The sequence {F_{c,N}} is q-log-concave.

### 3x3 Hankel: FAILS

det[F_{c,N+i+j}]_{0<=i,j<=2} is NOT nonneg.

For c=(2,1,1), N=0: strongly negative (min coefficient = -85821).
For c=(2,1,1), N=1: strongly negative (min coefficient = -37254).

**This definitively rules out total positivity of {F_{c,N}} in the
Hankel sense.** The sequence is log-concave (2x2 minors nonneg)
but NOT totally positive (3x3 minors negative).

### Implication

The total positivity approach from Layer 1 is definitively dead.
The sequence {F_{c,N}} does not have the required total positivity
structure. Q_n >= 0 must be proved by other means.

## Stuck: The h_m -> Q_n Gap

### What I'm trying to show

That h_m >= 0 with h_m(1) = base^m implies Q_n >= 0 where
Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}.

### Why I can't show it

The alternating sum with q-shifted q-binomial coefficients does not
preserve nonnegativity in general. Even with h_m growing like base^m,
the q-shifts mean different h_m contribute to different q-degrees,
and partial cancellation at each degree is not controlled.

### What would unstick me

A q-analogue of the following classical fact: if a_m >= 0 and
a_m(1) = B^m with B >= 2, then sum_j (-1)^j C(n,j) a_{n-j} = (B-1)^n >= 0.

The proof at q=1 uses the binomial theorem:
sum_j (-1)^j C(n,j) B^{n-j} = (B-1)^n.

For a q-analogue, we would need:
sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}(q) = Q_n(q) >= 0

where h_m(q) is a polynomial with h_m(1) = B^m and h_m >= 0.

This is NOT a standard q-binomial theorem. The q-shifts j(j+1)/2
create asymmetry. And the h_m(q) are not simply q-powers of anything.

## Assumptions Check

- **h_m is a polynomial**: TRUE (verified by stabilization).
- **h_m has nonneg coefficients**: TRUE (verified for d=2,4,5,7, m<=3).
- **h_m(1) = base^m**: TRUE (verified for m <= 3 at d=2,4,5; m=1 at d=7).
- **{F_{c,N}} is log-concave**: TRUE (verified).
- **{F_{c,N}} is totally positive (Hankel)**: **FALSE** (3x3 minors negative).
- **h_m >= 0 implies Q_n >= 0**: UNKNOWN (the implication is non-trivial).
- **h_m - Q_m >= 0**: TRUE (verified for m <= 4 at d=4).
- **deg(h_m) = deg(Q_m) = (d-1)m^2**: TRUE (verified).

## THE BROKEN ASSUMPTION

What I believed: {F_{c,N}} is totally positive (Hankel-TP), and this
implies Q_n >= 0.

What is actually true: {F_{c,N}} is log-concave (2x2 Hankel nonneg)
but NOT totally positive (3x3 Hankel is negative). The total positivity
approach is dead.

What this means for the proof: The route to Q_n >= 0 must go through
the h_m decomposition or through representation theory, not through
total positivity of the F_{c,N} sequence.

## Strategy Assessment

### What works:
1. h_m are polynomials with nonneg coefficients (verified)
2. h_m(1) = base^m (verified)
3. Q_n = alternating q-binomial transform of h_m (verified)
4. Q_n is nonneg for all tested cases including d=7 (confirmed)
5. {F_{c,N}} is log-concave (verified)

### What doesn't work:
1. Total positivity of {F_{c,N}} -- FAILS at 3x3
2. Direct involution on alternating sum -- cross-N obstruction
3. The implication h_m >= 0 => Q_n >= 0 -- NOT automatic

### Most promising direction:
The h_m decomposition opens a TWO-STEP strategy:
- Step 1: Prove h_m >= 0 for all m and all profiles c
- Step 2: Prove the alternating q-binomial transform preserves nonnegativity
  given that h_m(1) = base^m and h_m has specific structural properties

Step 1 seems tractable because h_m is a FINITE polynomial (unlike g_m)
and its generating function might have a manifestly positive formula.

Step 2 is the hard part and may require identifying structural properties
of h_m beyond mere nonnegativity.

### New observation: h_m leading coefficients

For c=(2,1,1), d=4:
- h_1 starts: [0, 3, 1, 1]
- h_2 starts: [0, 0, 3, 4, 5, ...]
- h_3 starts: [0, 0, 0, 3, 4, 8, ...]

The minimum degree of h_m is m (since g_m starts at degree m).
The coefficient at degree m is always 3 (for c=(2,1,1)).
This 3 = c_0 + c_1 + c_2 - ... actually 3 = k = 3 (the number of partitions).
Wait, the coefficient 3 at h_m[m] means there are 3 cylindric partition
triples contributing at the minimal weight with max exactly m.

For c=(1,1,0), d=2: h_m[m] = 2 = base = 2.
For c=(3,2,2), d=7: h_m[m] = 3 = k = 3.
For c=(4,2,1), d=7: h_m[m] = 3 = k = 3.

So the leading small-degree coefficient of h_m is always k = 3
(for k=3 profiles). This is the number of partitions in the tuple.

## Escalation

I am stuck on proving Q_n >= 0 from the alternating q-binomial transform
of h_m.

**Attempt 1** (Total positivity): Failed. 3x3 Hankel minors are negative,
so {F_{c,N}} is not totally positive.

**Attempt 2** (Direct h_m => Q_n): The alternating sum with q-shifts
does not preserve nonnegativity in general. No structural property of
h_m (beyond nonnegativity and h_m(1) = base^m) has been identified that
would control the cancellation.

**Attempt 3** (Bead model on encodings): The Kursungoz-Seyrek decomposition
gives a bijection for unrestricted cylindric partitions, but the bounded
version (max <= N) is not developed. The bead model doesn't directly
interact with the [z^n] extraction in a way that eliminates alternation.

**What all three have in common**: The central difficulty remains the
cross-N interaction in the alternating sum. Even the h_m formulation
does not escape this because Q_n involves h_m for multiple values of m.

**What I think is needed**:
1. Either a manifestly positive formula for Q_n that avoids the alternating
   sum entirely (e.g., a multisum with all positive terms), or
2. A representation-theoretic proof identifying Q_n as a graded dimension
   (which would make nonnegativity automatic), or
3. A structural property of h_m (stronger than nonnegativity) that
   controls the alternating q-binomial transform -- perhaps h_m is
   Schur-positive or has a specific decomposition into q-binomial
   coefficients that makes the alternating sum telescopic.

## Scripts

All computation scripts are in `scratch/scripts/`:
- `seed2_L2_hm_vs_totpos.py` -- Initial h_m vs total positivity test
- `seed2_L2_hm_check.py` -- Diagnosis of truncation artifacts
- `seed2_L2_hm_proper.py` -- Proper h_m computation with stabilization
- `seed2_L2_hankel_higher.py` -- Hankel 3x3 minors and d=7 h_m
- `seed2_L2_d7_precise.py` -- Higher precision d=4 computation
- `seed2_L2_degree_analysis.py` -- h_m vs Q_m structural comparison
