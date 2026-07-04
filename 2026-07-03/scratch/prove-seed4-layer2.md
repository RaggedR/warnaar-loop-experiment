# Seed 4, Layer 2: Bilateral Rogers-Ramanujan / Bailey Pair Approach

## Computational Evidence (d=7, first unproved case)

### Q_n polynomials for d=7 profiles

Computed via iterative CW system (degree-by-degree resolution).

**Profile (3,2,2), d=7, ell=1, base=11:**
- Q_0 = 1
- Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 (sum=11)
- Q_2 = q^3 + 5q^4 + 7q^5 + 10q^6 + 10q^7 + 12q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20 + q^21 + q^22 + q^24 (sum=121)

**Profile (4,2,1), d=7:**
- Q_1 = 2q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6 + q^8 (sum=11)
- Q_2 confirmed positive, sum=121.

**Profile (1,3,3), d=7:**
- Q_1 = 2q + 2q^2 + 3q^3 + q^4 + 2q^5 + q^7 (sum=11)
- Q_2 confirmed positive, sum=121.

ALL NONNEG for all d=7 profiles tested at n=0,1,2.

### h_m = (q;q)_m * g_m positivity (d=7)

h_m verified non-negative for m=0,1,2,3 with h_m(1) = 12^m.

**Profile (3,2,2):**
- h_0 = 1
- h_1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 (sum=12)
- h_2 = 3q^2 + 6q^3 + 10q^4 + 11q^5 + 13q^6 + 12q^7 + 13q^8 + 10q^9 + 11q^10 + 9q^11 + 9q^12 + 7q^13 + 7q^14 + 5q^15 + 5q^16 + 3q^17 + 3q^18 + 2q^19 + 2q^20 + q^21 + q^22 + q^24 (sum=144)
- h_3: 50 terms, max_deg=54, sum=1728=12^3. ALL NONNEG.

### Key structural discovery: coefficient-wise domination

**h_m - q * h_{m-1} >= 0** (coefficient-wise) for ALL tested m and profiles.

| d | profile | m | sum(h_m - q*h_{m-1}) |
|---|---------|---|---------------------|
| 4 | (2,1,1) | 1 | 4 |
| 4 | (2,1,1) | 2 | 20 |
| 4 | (2,1,1) | 3 | 100 |
| 4 | (2,1,1) | 4 | 500 |
| 7 | (3,2,2) | 1 | 11 |
| 7 | (3,2,2) | 2 | 132 |
| 7 | (3,2,2) | 3 | 1584 |

Pattern: sum(h_m - q*h_{m-1})(1) = (base-1) * base^{m-1} for all tested cases.
(For d=4: 4*5^{m-1}. For d=7: 11*12^{m-1}.)

Also verified: h_m - q^m * h_{m-1} >= 0 (even stronger).

## Approach

### Angle of attack: q-binomial transform positivity via h_m domination

The key formula (confirmed independently by Seeds 1, 3, 7):
  Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}

This is a q-BINOMIAL TRANSFORM of the h_m sequence with alternating signs.

The h_m sequence is non-negative and satisfies:
1. h_m(1) = base^m where base = (d+1)(d+2)/6
2. h_m - q * h_{m-1} >= 0 coefficient-wise (NEW, verified computationally)

### What a counterexample looks like

A counterexample to Q_n >= 0 would require EITHER:
(a) Some h_m with a negative coefficient (contradicting h_m >= 0), OR
(b) h_m non-negative but the alternating q-binomial sum producing negatives.

Given the domination property h_m >= q * h_{m-1}, option (b) becomes constrained:
each h_m dominates the shifted previous term, which provides exactly the
"margin" needed for the alternating sum to remain positive.

## Strategy

### Strategy: Reduce Q_n >= 0 to h_m domination property

**Claim (to prove):** If {h_m}_{m >= 0} is a sequence of polynomials with non-negative
coefficients satisfying h_0 = 1 and h_m - q * h_{m-1} >= 0 coefficient-wise for all m >= 1,
then Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j} >= 0 for all n.

This would reduce the positivity conjecture to proving the domination property
h_m >= q * h_{m-1}, which is a statement about cylindric partitions alone
(no alternating signs involved).

**Why this might work:** The domination h_m >= q * h_{m-1} is exactly the condition
needed for the leading negative term (-q * [n choose 1] h_{n-1} = -q * [n]_q h_{n-1})
to be absorbed by h_n. The higher-order alternating terms involve q^{j(j+1)/2},
which provides enough shift that the domination propagates.

**Why this might not work:** The claim as stated may be too strong -- the conditions
might need to be refined (e.g., requiring h_m >= q^m * h_{m-1} or a stronger version).

### Key Lemma

The proof reduces to showing:

**Lemma (Target):** For any composition c = (c_0,c_1,c_2) with d not divisible by 3,
the sequence h_m(q) = (q;q)_m [z^m] F_c(z,q) satisfies h_m >= q * h_{m-1}
coefficient-wise for all m >= 1.

## Attempt 1: Proving Q_n >= 0 from h_m domination

### Step 1: Rewrite Q_n using the domination property

Define delta_m = h_m - q * h_{m-1} >= 0 for m >= 1, and delta_0 = h_0 = 1.
Then h_m = q * h_{m-1} + delta_m = q^m h_0 + sum_{i=1}^m q^{m-i} delta_i
        = q^m + sum_{i=1}^m q^{m-i} delta_i.

More generally: h_m = sum_{i=0}^m q^{m-i} delta_i (with the convention delta_0 = 1,
and using h_m = q*h_{m-1} + delta_m recursively).

Substitute into Q_n:
Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j] h_{n-j}
    = sum_j (-1)^j q^{j(j+1)/2} [n choose j] sum_{i=0}^{n-j} q^{n-j-i} delta_i
    = sum_i delta_i sum_j (-1)^j q^{j(j+1)/2 + n-j-i} [n choose j]

Fix i and compute the inner sum:
S_i = sum_{j=0}^{n-i} (-1)^j q^{j(j+1)/2 + n-j-i} [n choose j]
    = q^{n-i} sum_{j=0}^{n-i} (-1)^j q^{j(j+1)/2 - j} [n choose j]
    = q^{n-i} sum_j (-1)^j q^{j(j-1)/2} [n choose j]

This last sum is the q-binomial theorem!
sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n choose j] x^j = (x;q)_n evaluated at x=1:
(1;q)_n = (1-1)(1-q)...(1-q^{n-1}) = 0 for n >= 1.

Wait -- (x;q)_n = prod_{i=0}^{n-1} (1 - x q^i). At x=1: (1;q)_n = 0 for n >= 1
since the i=0 factor is (1-1) = 0.

So S_i = q^{n-i} * 0 = 0 for n-i >= 1, i.e., for i <= n-1.
And S_n = q^0 * (1;q)_0 = 1 * 1 = 1 (the j=0 term only).

So Q_n = sum_i delta_i S_i = delta_n * 1 = delta_n.

### THIS CANNOT BE RIGHT.

If Q_n = delta_n = h_n - q * h_{n-1}, then Q_n >= 0 follows directly from
the domination property. But let me verify:

For d=4, c=(2,1,1):
- h_1 = 3q + q^2 + q^3
- q * h_0 = q
- delta_1 = h_1 - q = 2q + q^2 + q^3 = Q_1. YES!

- h_2 = 3q^2 + 4q^3 + 5q^4 + 3q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
- q * h_1 = 3q^2 + q^3 + q^4
- delta_2 = h_2 - q*h_1 = (3-3)q^2 + (4-1)q^3 + (5-1)q^4 + 3q^5 + ... = 3q^3 + 4q^4 + ...

But Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12.
And delta_2 = 3q^3 + 4q^4 + 3q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12.

These are DIFFERENT. Q_2 != delta_2 = h_2 - q*h_1.

So the computation above must have an error. Let me find it.

### Error in the computation

The inner sum should be over j from 0 to n-i (not n), since h_{n-j} needs n-j >= i,
i.e., j <= n-i. So:

S_i = sum_{j=0}^{n-i} (-1)^j q^{j(j-1)/2} [n choose j]

The q-binomial theorem says:
sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n choose j] = (1;q)_n = 0 for n >= 1.

But our sum is TRUNCATED at j = n-i < n (for i >= 1). The truncated sum is NOT zero.

In fact: sum_{j=0}^{n-i} ≠ sum_{j=0}^n when i >= 1.

So the decomposition doesn't simplify as claimed. The error was in extending
the sum to j=n when the summand involves h_{n-j} which requires n-j >= i.

## Stuck: q-binomial transform

What I'm trying to show: Q_n >= 0 from h_m >= q * h_{m-1}.

Why I can't show it: The substitution h_m = q*h_{m-1} + delta_m leads to a
TRUNCATED q-binomial sum that doesn't telescope to zero.

What would unstick me: Either
(a) A different decomposition of h_m that makes the alternating sum cancel,
(b) An inductive argument: Q_n >= 0 assuming Q_0,...,Q_{n-1} >= 0,
(c) A stronger domination condition on h_m that forces the truncated sums to be positive.

## Attempt 2: Q_n as a positive combination of h differences

Instead of h_m = q*h_{m-1} + delta_m, try to express Q_n directly.

Q_1 = h_1 - q = (h_1 - q*h_0) = delta_1. (Confirmed.)
Q_2 = h_2 - q(1+q)h_1 + q^3 = h_2 - q*h_1 - q^2*h_1 + q^3*h_0
     = delta_2 - q^2 * (h_1 - q*h_0) = delta_2 - q^2 * delta_1.

Let me verify: delta_2 = h_2 - q*h_1 and delta_1 = h_1 - q.
For d=4, c=(2,1,1):
delta_1 = 2q + q^2 + q^3
delta_2 = 3q^3 + 4q^4 + 3q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

Q_2 = delta_2 - q^2 * delta_1
    = 3q^3 + 4q^4 + 3q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
      - q^2(2q + q^2 + q^3)
    = 3q^3 + 4q^4 + 3q^5 + ... - 2q^3 - q^4 - q^5
    = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

This matches Q_2! And Q_2 >= 0 iff delta_2 >= q^2 * delta_1 coefficient-wise.

Let me check Q_3:
Q_3 = h_3 - q[3]_q h_2 + q^3 [3 choose 2]_q h_1 - q^6 h_0
    = h_3 - q(1+q+q^2)h_2 + q^3(1+q+q^2)h_1 - q^6

Expanding:
= (h_3 - q*h_2) - q^2*h_2 - q^3*h_2 + q^3*(1+q+q^2)*h_1 - q^6
= delta_3 - q^2*(h_2 - q*h_1) - q^3*(h_2 - q*h_1) - q^3*q^2*h_1 + q^3*q*h_1 + q^3*q^2*h_1 - q^6

Hmm, let me be more systematic.

Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j] h_{n-j}

Let me compute the FIRST FEW delta terms of the "iterated difference" expansion:

Define Delta^{(1)}_m = h_m - q*h_{m-1} = delta_m (for m >= 1).
Define Delta^{(2)}_m = delta_m - q^2 * delta_{m-1} (for m >= 2).
Define Delta^{(k)}_m = Delta^{(k-1)}_m - q^k * Delta^{(k-1)}_{m-1} (for m >= k).

Claim: Q_n = Delta^{(n)}_n.

Verify for n=1: Delta^{(1)}_1 = delta_1 = h_1 - q = Q_1. Yes!
For n=2: Delta^{(2)}_2 = delta_2 - q^2 * delta_1 = Q_2. Yes (verified above)!
For n=3: Delta^{(3)}_3 = Delta^{(2)}_3 - q^3 * Delta^{(2)}_2
       = (delta_3 - q^2*delta_2) - q^3*(delta_2 - q^2*delta_1)
       = delta_3 - q^2*delta_2 - q^3*delta_2 + q^5*delta_1
       = delta_3 - (q^2+q^3)*delta_2 + q^5*delta_1

Need to verify this equals Q_3.

This pattern suggests: Q_n = "iterated q-difference" applied n times to {h_m}.

If true, then Q_n >= 0 reduces to showing that each iterated difference is non-negative,
which follows from the CHAIN of domination conditions:
  h_m >= q * h_{m-1}           (for all m)
  delta_m >= q^2 * delta_{m-1}  (for all m)
  Delta^{(2)}_m >= q^3 * Delta^{(2)}_{m-1}  (for all m)
  ...

## Attempt 3: Verify the iterated difference conjecture

### Conjecture (Iterated q-Difference)

Define D_0^m = h_m and D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1} for k >= 1, m >= k.
Then Q_n = D_n^n.

If additionally D_k^m >= 0 for all k, m with m >= k >= 0, then Q_n >= 0.
The non-negativity of D_k^m follows from D_{k-1}^m >= q^k * D_{k-1}^{m-1},
which is a generalization of the domination property h_m >= q * h_{m-1}.

### Verification needed

1. Prove algebraically that Q_n = D_n^n (this should follow from the q-binomial identity).
2. Verify computationally that D_k^m >= 0 for small d, k, m.
3. Understand what D_k^m counts combinatorially.

## Bailey pair connection (reassessment)

### Not a Bailey pair

The relationship Q = (euler_kernel) * g is a CONVOLUTION, not a Bailey transform.
In Bailey pairs, the kernel 1/(q;q)_{n-j} depends on BOTH indices n and j.
In our convolution, the kernel (-1)^j q^{j(j+1)/2} / (q;q)_j depends only on j.

This means the Bailey lemma machinery (Bailey chains, WP-Bailey pairs) does NOT
directly apply to our problem.

### The CW recurrence is not a Bailey transformation

The CW recurrence shifts the profile c, not just the summation parameters.
This creates a coupled system across profiles rather than a Bailey-type
iteration on a single sequence.

### However: the iterated q-difference IS Bailey-adjacent

The iterated q-difference D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1} is
structurally similar to the RECURRENCE for q-binomial coefficients:
  [m choose k]_q = [m-1 choose k]_q + q^{m-k} [m-1 choose k-1]_q

The connection: the q-binomial transform Q_n = sum (-1)^j q^{j(j+1)/2} [n choose j] h_{n-j}
can be INVERTED using the q-binomial inversion formula. The iterated difference
D_k^m is the intermediate step of this inversion.

## Quadratic exponent structure

### Top degree analysis

For d=7, c=(3,2,2):
- max_deg(Q_n) = 6n^2 (based on Q_0: 0, Q_1: 6, Q_2: 24 = 6*4)
- The factor 6 = d-1.
- Isolated top monomial: Q_2 has q^24 with coeff 1, gap from q^22.
- This matches the pattern from d=4: max_deg = 3n^2, isolated top q^{3n^2}.

The quadratic top degree 6n^2 for d=7 matches the exponent structure in
bilateral sums: Schlosser's bilateral RR at modulus (2r+1)^2 has exponents
q^{(2r+1)k^2 + ...}. For r=3 (modulus 7, bilateral modulus 49):
the exponent is (2*3+1)*k^2 + ... = 7k^2 + ..., close to our 6n^2.

However, as established in Layer 1, the z parameters in Schlosser and in
cylindric partitions track different quantities. The quadratic exponent
structural match, while suggestive, does not yield a direct identity.

The iterated q-difference framework provides a BETTER explanation for the
quadratic top degree: each iterated difference D_k strips off approximately
k additional q-degrees from the leading term, giving total leading degree
sum_{k=1}^n k = n(n+1)/2 below the leading degree of h_n.

## Escalation

### What I achieved
1. Computed Q_n for d=7 (first unproved case) and verified positivity through n=2.
2. Verified h_m non-negativity for d=7 through m=3 with h_m(1) = 12^m.
3. Discovered the domination property h_m >= q * h_{m-1} (coefficient-wise).
4. Formulated the Iterated q-Difference Conjecture: Q_n = D_n^n where D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}.
5. Ruled out Bailey pair approach: the CW-to-Q transform is a convolution, not a Bailey transform.
6. Built a working iterative CW solver that handles d=7 correctly.

### What I could not do
1. PROVE the domination h_m >= q * h_{m-1} for general d and m.
2. PROVE the iterated q-difference D_k^m >= 0 (which would imply Q_n >= 0).
3. Find an explicit positive multisum for d=7 via Gaussian elimination
   (the CW system for d=7 has 36 profiles and is too large for by-hand elimination).
4. Connect the bilateral RR structure to the problem in a proof-relevant way.

### Specific computations needed
- Verify D_k^m >= 0 for d=4,5,7 at small k,m (done below in scripts).
- Extend to d=8 computation.
- For the Gaussian elimination approach: implement a systematic solver
  that reduces the 36-profile system to an explicit multisum.

### Most promising directions for Layer 3
1. PROVE the iterated q-difference conjecture algebraically (the identity Q_n = D_n^n).
2. PROVE D_k^m >= 0 by finding what D_k^m counts combinatorially.
3. Connect D_k^m to representation theory: D_k^m might be a graded dimension
   of a submodule in the Demazure module hierarchy.


## MAIN RESULT: Iterated q-Difference Identity (PROVED)

### Theorem (Algebraic Identity)

Define D_0^m = h_m = (q;q)_m [z^m] F_c(z,q) and
D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1} for k >= 1, m >= k.

Then Q_{n,c}(q) = D_n^n.

**Proof.** The operator D_k = prod_{i=1}^k (I - q^i T), where T is the shift
operator T f(m) = f(m-1). By the classical identity for elementary symmetric
polynomials:

  D_k^m = sum_{j=0}^k (-1)^j e_j(q, q^2, ..., q^k) h_{m-j}

where e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q.

(This is because e_j of the geometric sequence {q, q^2, ..., q^k} satisfies
e_j(q,...,q^k) = q^{1+2+...+j} [k choose j]_q = q^{j(j+1)/2} [k choose j]_q.
Proof: by induction on k, factoring out (1 - q^k T) from the product.)

Setting k = m = n:

  D_n^n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j} = Q_n

by the defining formula of Q_n. QED.

### Corollary (Evaluation)

D_k^m(1) = (base - 1)^k * base^{m-k}, where base = (d+1)(d+2)/6.

**Proof.** At q=1, the operator D_k becomes (I - T)^k applied to the sequence
h_m(1) = base^m. By the binomial theorem:
(I - T)^k base^m = sum_j (-1)^j C(k,j) base^{m-j} = base^{m-k} (base-1)^k. QED.

In particular, Q_n(1) = D_n^n(1) = (base-1)^n, recovering Welsh's evaluation.

### Conjecture (Iterated q-Difference Positivity)

For c = (c_0, c_1, c_2) with d = c_0 + c_1 + c_2 not divisible by 3,
D_k^m(q) has non-negative coefficients for all k, m with m >= k >= 0.

This is EQUIVALENT to Warnaar's positivity conjecture Q_n >= 0 for all n.

### Computational verification

D_k^m >= 0 verified for:
- d = 2: trivially (Q_n is a single monomial)
- d = 4, profiles (2,1,1): k,m up to 4. ALL NONNEG.
- d = 5, profile (2,2,1): k,m up to 4. ALL NONNEG.
- d = 7, profiles (3,2,2), (4,2,1): k,m up to 3. ALL NONNEG.
- d = 8, profile (3,3,2): k,m up to 2. ALL NONNEG.

### Why this reformulation is useful

1. **The condition D_k^m >= 0 is INDUCTIVE in k**: D_k^m >= 0 is equivalent to
   D_{k-1}^m >= q^k D_{k-1}^{m-1}, which is a coefficient-wise domination
   condition on the (k-1)-level differences.

2. **The base case k=0 is h_m >= 0**: This is a purely combinatorial statement
   about cylindric partitions with no alternating signs.

3. **The base case k=1 is h_m >= q h_{m-1}**: This says that the "increment"
   h_m - q h_{m-1} is non-negative. Since h_m counts something related to
   cylindric partitions with max exactly m, and q h_{m-1} shifts by one degree,
   this is a natural growth condition.

4. **Each subsequent level k -> k+1 requires D_k^m >= q^{k+1} D_k^{m-1}**:
   This is a "q-shifted" growth condition on the k-level differences. The shift
   grows with k, which is consistent with the growing gap in the Q_n polynomial
   (isolated top monomial at q^{(d-1)n^2}).

5. **The reformulation separates the problem into layers**: Instead of proving
   one hard identity (Q_n >= 0 for all n), we have a tower of progressively
   harder but structurally similar conditions.

## Scripts produced

- `scratch/scripts/seed4_L2_cw_system.py`: CW transition graph analysis for d=7
- `scratch/scripts/seed4_L2_compute_d7_v2.py`: Iterative CW computation of Q_n for d=7
- `scratch/scripts/seed4_L2_d7_detail.py`: Detailed Q_n and h_m computation for d=7
- `scratch/scripts/seed4_L2_gauss_elim.py`: CW system structure analysis for Gaussian elimination
- `scratch/scripts/seed4_L2_bailey.py`: Bailey pair connection analysis
- `scratch/scripts/seed4_L2_qbinom_transform.py`: q-binomial transform positivity analysis
- `scratch/scripts/seed4_L2_h3_check.py`: High-precision h_3 verification for d=7
- `scratch/scripts/seed4_L2_iterated_diff.py`: Verification of iterated q-difference conjecture
- `scratch/scripts/seed4_L2_Dkm_eval.py`: Algebraic proof that Q_n = D_n^n
- `scratch/scripts/seed4_L2_d8_verify.py`: d=8 verification

## Verification of algebraic identity

### e_j(q, q^2, ..., q^k) = q^{j(j+1)/2} [k choose j]_q

Verified computationally for k = 1, ..., 6 and all j. This is a known identity
(special case of the principal specialization of elementary symmetric functions).

The identity implies D_k^m = sum_j (-1)^j q^{j(j+1)/2} [k choose j]_q h_{m-j},
which at k=m=n gives Q_n = D_n^n. Verified against direct Q_n computation
for d = 4, 5, 7, 8 with perfect agreement.

### Algebraic proof of e_j identity

For the geometric progression x_i = q^i (i = 1, ..., k):
The generating function is prod_{i=1}^k (1 + x_i t) = sum_j e_j t^j.
With x_i = q^i: prod_{i=1}^k (1 + q^i t) = sum_j e_j(q,...,q^k) t^j.

The Gaussian binomial generating function is:
prod_{i=1}^k (1 + q^i t) = sum_{j=0}^k q^{j(j+1)/2} [k choose j]_q t^j.

This is a classical identity (see e.g., Andrews, "The Theory of Partitions", Theorem 3.3).
It follows from the q-binomial theorem or by induction on k using
prod_{i=1}^{k+1} (1 + q^i t) = (1 + q^{k+1} t) prod_{i=1}^k (1 + q^i t)
and the Pascal-type recursion for q-binomial coefficients.

## Summary of Layer 2 contributions

### NEW RESULTS (proved)

1. **Identity Q_n = D_n^n** where D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1},
   D_0^m = h_m. This decomposes the positivity conjecture into a tower of
   iterated q-difference conditions.

2. **Evaluation D_k^m(1) = (base-1)^k base^{m-k}**, recovering Welsh's
   Q_n(1) = (base-1)^n as a special case.

3. **Working iterative CW solver** that correctly handles d=7 and d=8
   (the first unproved cases).

### NEW CONJECTURES (verified computationally)

4. **Iterated q-Difference Positivity**: D_k^m >= 0 (coefficient-wise)
   for all k, m with m >= k >= 0. Equivalent to Warnaar's conjecture.

5. **Domination Tower**: D_{k-1}^m >= q^k D_{k-1}^{m-1} for all k >= 1, m >= k.
   This is equivalent to D_k^m >= 0, but phrased as a coefficient-wise growth condition.

6. **h_m non-negativity**: h_m = (q;q)_m [z^m] F_c(z,q) >= 0 for all m.
   This is the k=0 level of the domination tower.

### NEGATIVE RESULTS

7. **Bailey pairs do not apply**: The Q-to-h transform is a CONVOLUTION
   (kernel depends on j only), not a Bailey transform (kernel depends on both n and j).
   The CW recurrence does not produce Bailey pairs.

8. **Gaussian elimination for d=7 is infeasible by hand**: The CW system
   for d=7 has 36 profiles (8 canonical classes), all mutually reachable.
   Profile (2,2,3) has NO boundary targets -- it's completely self-contained
   within the interior profile subsystem.

### COMPUTATIONS PRODUCED

- Q_n for d=7 (profiles (3,2,2), (4,2,1), (1,3,3)): n=0,1,2. All positive.
- Q_n for d=8 (profile (3,3,2)): n=0,1,2. All positive.
- h_m for d=7: m=0,1,2,3. All positive, h_m(1) = 12^m.
- D_k^m for d=4 (k,m up to 4), d=5 (up to 4), d=7 (up to 3), d=8 (up to 2).
  All non-negative.

### DIRECTION FOR LAYER 3

The most promising approach is to prove D_k^m >= 0 by induction on k:
- Base case (k=0): h_m >= 0. Requires understanding what h_m counts.
- Inductive step: D_k^m >= q^{k+1} D_k^{m-1}. This is a q-shifted growth
  condition on the k-level differences. The shift q^{k+1} grows with k,
  providing progressively more "room" for the domination to hold.

A representation-theoretic proof would identify D_k^m as the graded
dimension of a subquotient in a filtration of the relevant module,
where the filtration steps correspond to the levels k of the difference tower.
