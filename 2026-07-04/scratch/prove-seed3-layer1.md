# Scratch: Seed 3, Layer 1, Round 2

## Mission
Reconstruct Warnaar's k=1,2 proof mechanism, explore whether rank-3 bounded system can close directly, and check whether EMD/adjugate structure can substitute for level-rank duality.

## CRITICAL DISCOVERY: h_m >= 0 (Round 1 was wrong)

**Round 1 claimed (BA2):** h_m = (q;q)_m * g_m has negative coefficients for m >= 2, even when d is coprime to 3. This killed Path A (D_k^m tower with base case h_m >= 0). Agent A specifically cited d=4, c=(2,1,1).

**Our finding:** With sufficient precision (600-1000 terms, well above the threshold 6*m^2 + 50 from BA15), **h_m >= 0 for ALL tested cases:**
- d=4: all 15 profiles, m=0,...,6 -- ALL NONNEG
- d=5: all 21 profiles, m=0,...,6 -- ALL NONNEG
- d=7: all 36 profiles, m=0,...,5 -- ALL NONNEG
- d=8: all 45 profiles, m=0,...,4 -- ALL NONNEG
- d=10: all 66 profiles, m=0,...,3 -- ALL NONNEG
- d=11: all 78 profiles, m=0,...,3 -- ALL NONNEG

**Diagnosis:** Round 1's negative coefficients were TRUNCATION ARTIFACTS from insufficient precision, exactly as warned by BA15. The power series ring truncated the computation, introducing spurious negative coefficients.

**Status: YELLOW.** Computationally verified for d=4,...,11 and m up to 6, but no proof of h_m >= 0 for general d, m.

## Conjecture (NEW)

**Conjecture h_m:** For all d >= 1, all profiles c = (c_0, c_1, c_2) with c_0+c_1+c_2 = d, and all m >= 0:
h_m(c) = (q;q)_m * g_m(c) has nonneg coefficients, where g_m = F_{c,m} - F_{c,m-1}.

If true, this immediately implies D_k^m >= 0 for all k >= 0, m >= k, via induction using D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}. In particular Q_n = D_n^n >= 0, PROVING THE CONJECTURE.

## Computational Evidence

### Warnaar's proof mechanism for k=1

For k=1 (d=2), Warnaar proved:
1. Level-rank duality maps rank-3 level-2 to rank-2 level-3.
2. The rank-2 CW system closes with 3 types (functional equation has 2 independent functions).
3. The solution GK_{(L+b+1,L)/(1-a,0)/3}(z,q) = 1/(zq)_{2L+a+b} sum_n z^n q^{n(n+a)} [2L+b-n choose n] is manifestly positive.
4. Bounded Q_n = F_{c,n0}(q) is a sum of products of q-binomials with nonneg coefficients.

For d=2, Q_n(1) = 1 and Q_n is a single monomial (trivially nonneg).

### Rank-3 CW system analysis

For rank 3, the CW shifts have up to 7 types (J subsets of I_c):
- |J|=1: up to 3 types (J={0}, {1}, {2})
- |J|=2: up to 3 types (J={0,1}, {0,2}, {1,2})
- |J|=3: 1 type (J={0,1,2})

Profiles with all c_i > 0 (like (2,1,1)) have all 7 active.
The system visits all binom(d+2,2) profiles and does NOT close into a smaller subsystem.

### EMD/adjugate analysis

The EMD matrix has entries EMD(c,c') in {0,1,...,3d-max} for d=4.
Multiple profiles share the same EMD to a fixed c.
The adjugate identity adj(I-A(x))[c,c'] = x^{EMD(c,c')} means the transfer matrix is (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')}/(1-x^3).

The simple recurrence (1+q^n+q^{2n}) Q_n = sum q^{n*EMD} Q_{n-1} does NOT hold. The residual has negative coefficients. No clean 2-term recurrence in Q_n was found via EMD weights alone.

## Key Structural Results

### Recurrence: Q_n + q^n Q_{n-1} = D_{n-1}^n

VERIFIED for d=4, all profiles, n=1,...,5.

D_{n-1}^n = sum_{j=0}^{n-1} (-1)^j q^{binom(j+1,2)} [n-1 choose j]_q h_{n-j}

This gives Q_n = D_{n-1}^n - q^n Q_{n-1}, an inductive formula.

### D_k^m >= 0 for ALL k,m

VERIFIED for d=4, c=(2,1,1), k,m = 0,...,5. All nonneg.
This is STRONGER than Round 1's claim (which only verified k >= 1).
The base case D_0^m = h_m >= 0 is what makes this work.

### Evaluation: D_{n-1}^n(1) / Q_{n-1}(1) = d+1

For d=4: this ratio is 5 = d+1 consistently. This means:
D_{n-1}^n(1) = (d+1) * Q_{n-1}(1) = (d+1) * 4^{n-1}
and Q_n(1) = D_{n-1}^n(1) - Q_{n-1}(1) = (d+1-1) * Q_{n-1}(1) = d * Q_{n-1}(1) = 4 * 4^{n-1} = 4^n. Checks out.

### S_n = Q_n * (q^3;q^3)_n / (q;q)_n is nonneg

VERIFIED for d=4, n=1,...,4. But (q;q)_n / (q^3;q^3)_n has negative coefficients, so S_n nonneg does not directly imply Q_n nonneg.

## Approach

If we can prove h_m >= 0 for all d, profiles, m, the conjecture follows.

h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1}.
g_m counts CPs with max exactly m, weighted by q^{size}.

h_m = (q;q)_m * g_m. The (q;q)_m factor has alternating signs, so h_m >= 0 says:
the product (1-q)(1-q^2)...(1-q^m) * (number of CPs with max = m by size) has nonneg coefficients.

This is equivalent to: g_m is divisible by 1/(q;q)_m (as a power series) and the quotient has nonneg coefficients.

Or equivalently: the sequence of coefficients of g_m satisfies certain monotonicity conditions that ensure the product with (q;q)_m stays nonneg.

## What a Counterexample Looks Like

A counterexample to h_m >= 0 would be a specific d, profile c, and m such that some coefficient of (q;q)_m * (F_{c,m} - F_{c,m-1}) is negative.

## Strategy

**Path A (resurrected):** Prove h_m >= 0 directly.

1. Express h_m via the EMD path formula: h_m = beta_m * tilde_h_m where beta_m = (q;q)_m / (q^3;q^3)_m and tilde_h_m = P_m - (1-q^{3m}) P_{m-1} = sum_{c'!=c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c). VERIFIED.

2. Note tilde_h_m >= 0 (manifestly nonneg from EMD path formula).

3. The issue: beta_m = (q;q)_m / (q^3;q^3)_m has NEGATIVE coefficients (e.g., beta_1 = 1/(1+q+q^2) = 1-q+q^3-q^4+...).

4. So h_m = beta_m * tilde_h_m is a product of a series with mixed signs and a nonneg series. Yet the result is always nonneg (computationally).

5. This suggests tilde_h_m has enough structure (from the EMD weights) to force the product to be nonneg despite beta_m's mixed signs.

## Key Lemma

**The proof reduces to showing:** (q;q)_m / (q^3;q^3)_m * tilde_h_m(c) has nonneg coefficients for all d, c, m, where tilde_h_m(c) = sum_{c'!=c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c).

## Stuck: The beta_m * tilde_h_m nonnegativity

What I'm trying to show: beta_m * tilde_h_m >= 0 (coefficient-wise).
Why I can't show it: beta_m has negative coefficients, and tilde_h_m is a sum of terms with various q-weights. No clean factorization presents itself.
What would unstick me: Either (a) a different factorization of h_m that avoids mixed signs entirely, or (b) a direct combinatorial interpretation of h_m.

## Handoff

### State
- MAJOR DISCOVERY: h_m >= 0 for ALL tested d (4,5,7,8,10,11), ALL profiles, ALL m tested. Round 1's BA2 ("h_m < 0 for m >= 2") was a truncation artifact. Path A is ALIVE.
- If h_m >= 0 can be proved, the positivity conjecture follows immediately via D_k^m >= 0 by induction.
- The recurrence Q_n = D_{n-1}^n - q^n Q_{n-1} is verified and provides clean inductive structure.
- The Warnaar rank-2 bounded multisum approach was understood but does NOT generalize directly to rank 3 (7 types vs 3).
- The EMD/adjugate structure does not provide a clean recurrence for Q_n directly.

### Best Result
**h_m >= 0 for all d, profiles, m (YELLOW -- computationally verified, no proof).** This is the strongest result of this session. If proved, it immediately implies the full positivity conjecture.

### Top Recommendation for Next Layer
1. PROVE h_m >= 0. The key lemma is: (q;q)_m * g_m >= 0 where g_m = F_{c,m} - F_{c,m-1}.
   - Try: find a combinatorial interpretation of h_m (as a partition function with restricted parts).
   - Try: use the injection lemma (g_m >= q g_{m-1}) to derive h_m >= 0 from monotonicity properties of g_m.
   - Try: express h_m as a sum of q-binomials with nonneg coefficients.
2. Verify h_m >= 0 for d=3 (ell=3 case) and d=6 (ell=3).
3. The evaluation D_{n-1}^n(1) = (d+1) * Q_{n-1}(1) should be provable from the EMD path formula.

## UPDATE: h_m >= 0 holds ONLY when gcd(d,3) = 1

For d divisible by 3 (d=3, d=6), h_m has strongly negative coefficients for m >= 1.
The h_m >= 0 conjecture is REFINED to:

**Conjecture h_m (refined):** For d not divisible by 3 (i.e., gcd(d,3) = 1 = ell), h_m >= 0 for all profiles c and all m >= 0.

For d divisible by 3 (ell = 3), the proof route is different: Q_n = (q^3;q^3)_n/(q;q)_n * D_n^n, and the factor (q^3;q^3)_n/(q;q)_n = prod_{i=1}^n (1+q^i+q^{2i}) has NONNEG coefficients. So Q_n >= 0 follows from D_n^n >= 0 (which needs different arguments when h_m < 0).

### Summary of proof strategy by case:

**Case ell=1 (d not divisible by 3):**
- h_m >= 0 (conjectured, verified for d=4,5,7,8,10,11)
- => D_k^m >= 0 for all k >= 0
- => Q_n = D_n^n >= 0. DONE.

**Case ell=3 (d divisible by 3):**
- h_m < 0 for m >= 1 (verified for d=3,6)
- But D_k^m >= 0 for k >= 1 (from Round 1, 87+ entries verified)
- And (q^3;q^3)_n / (q;q)_n = prod(1+q^i+q^{2i}) >= 0
- Need: D_n^n >= 0 despite h_m < 0.
- This is a harder problem. The injection lemma + iterated q-difference might still work, but needs a different base case.
- Q_n nonneg still verified for d=3,6, n=1,...,4.

## Updated Handoff

### Best Result
**h_m >= 0 for d not divisible by 3 (YELLOW).** Verified for d=4,5,7,8,10,11 with sufficient precision. If proved, immediately gives the positivity conjecture for the original case (d not div by 3). This was declared dead in Round 1 due to truncation artifacts.

### Verification Status: YELLOW
Computationally verified but no proof. The key missing piece is a proof of h_m >= 0.

### Top Recommendation
1. PROVE h_m >= 0 for gcd(d,3) = 1. Key approaches:
   - Combinatorial: h_m = (q;q)_m * g_m could be interpreted as a restricted partition function.
   - The injection lemma gives g_m >= q * g_{m-1}. This is a FIRST-ORDER condition. h_m >= 0 requires ALL-ORDER conditions from the (q;q)_m factor. Can the injection be strengthened?
   - Express h_m as a sum over some combinatorial objects with nonneg weights.
2. For ell=3 case: explore D_k^m >= 0 for k >= 1 when h_m < 0.
3. Notify ALL agents that BA2 ("h_m < 0 for m >= 2") is WRONG for gcd(d,3)=1. Path A lives.

## Detailed Computational Evidence for h_m >= 0

### g_m structure (d=4, c=(2,1,1))

g_m is a POWER SERIES (not polynomial), but h_m = (q;q)_m * g_m IS a polynomial.
g_1 coefficients stabilize: [0, 3, 4, 5, 5, 5, 5, ...] (becomes constant at 5 = d+1).
g_m coefficients grow polynomially in the degree.

The injection lemma gives g_m - q*g_{m-1} >= 0 and even g_m - q^2 * g_{m-1} >= 0.
But g_m - q*g_{m-1} - q^2*g_{m-2} has negative coefficients, so the monotonicity is FIRST ORDER only.

### h_m coefficients (d=4, c=(2,1,1))

h_0 = 1
h_1 = 3q + q^2 + q^3  (nonneg, 3 terms)
h_2 = 3q^2 + 4q^3 + 5q^4 + 3q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12  (nonneg, 10 terms)
h_3 = 3q^3 + 4q^4 + 8q^5 + 8q^6 + 11q^7 + ... + q^27  (nonneg, 28 terms)

Pattern: h_m starts with 3q^m + 4q^{m+1} + ... and all coefficients are nonneg.
The leading coefficient 3 = #{c' : EMD(c,c') = 1} (for c=(2,1,1), there are 3 neighbors at distance 1).

### Why h_m >= 0 fails for d divisible by 3

For d=3, c=(1,1,1): g_1 coefficients show period-3 oscillation: [0, 3, 3, 4, 3, 3, 4, ...].
The oscillation pattern (3,3,4 repeating) interacts with (q;q)_m to create negative coefficients.
For d=4: g_1 coefficients stabilize monotonically: [0, 3, 4, 5, 5, 5, ...]. No oscillation.

### Implications for proof

The h_m >= 0 result for gcd(d,3)=1 is the SINGLE MOST IMPORTANT finding of this session.
It reduces the Warnaar positivity conjecture (for d not div by 3) to proving that:
(q;q)_m * (F_{c,m}(q) - F_{c,m-1}(q)) has nonneg coefficients for all d with gcd(d,3)=1, all profiles c, all m >= 0.

Scripts: all in 2026-07-04/scratch/scripts/seed3_R2L1_*.sage
