# Seed 8, Layer 3: Plane Partitions, Lozenge Tilings, Hopkins-Lai

## Computational Evidence

### Extended Positivity Verification

**d=7 (first unproved case):**
- Profile (3,2,2): Q_n nonneg for n=0,...,5. Q_n(1) = 11^n. Q_5 has 128 terms, deg=150.
- D_k^m nonneg for all k,m up to 5 (see tower table below).
- h_m nonneg for m=0,...,5. h_m(1) = 12^m.

**d=8 (d not equiv 0 mod 3):**
- Profile (3,3,2): Q_n nonneg for n=0,1,2,3. Q_n(1) = 14^n. deg(Q_3) = 63 = 7*9.
- Profile (4,3,1): Q_n nonneg for n=0,1,2,3. Q_n(1) = 14^n. deg(Q_3) = 69.
- h_m nonneg for m=0,...,3. h_m(1) = 15^m.
- D_k^m nonneg for all k,m up to 3.

**d=10 (d not equiv 0 mod 3):**
- Profile (4,3,3): Q_n nonneg for n=0,1,2. Q_n(1) = 21^n.
- Profile (5,3,2): Q_n nonneg for n=0,1,2. Q_n(1) = 21^n.
- h_m nonneg for m=0,1,2. h_m(1) = 22^m.
- D_k^m nonneg for all k,m up to 2.

### D_k^m Tower Extended (d=7, c=(3,2,2))

D_k^m(1) table -- ALL NONNEG as polynomials in q:

| k\m | 0 | 1 | 2 | 3 | 4 | 5 |
|-----|---|---|---|---|---|---|
| 0 | 1 | 12 | 144 | 1728 | 20736 | 248832 |
| 1 | - | 11 | 132 | 1584 | 19008 | 228096 |
| 2 | - | - | 121 | 1452 | 17424 | 209088 |
| 3 | - | - | - | 1331 | 15972 | 191664 |
| 4 | - | - | - | - | 14641 | 175692 |
| 5 | - | - | - | - | - | 161051 |

Evaluation: D_k^m(1) = 11^k * 12^{m-k} = base^k * (base+1)^{m-k}. Verified.

Explicit polynomials (d=7):
- h_1 = D_0^1 = 3q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
- D_1^1 = Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
- D_1^2 = 3q^3 + 8q^4 + 9q^5 + 12q^6 + 11q^7 + 13q^8 + ... + q^24

### MAJOR DISCOVERY: d equiv 0 mod 3

**d=9, ell=3:**
- Profile (3,3,3): Q_n nonneg for n=0,1,2,3. **Q_n(1) = 52^n.**
- Profile (4,3,2): Q_n nonneg for n=0,1,2,3. **Q_n(1) = 52^n.**
- **h_m has NEGATIVE coefficients!** Not a polynomial -- has terms out to degree ~200 (truncation limit).
- **D_k^m has NEGATIVE coefficients!** The entire D_k^m tower is negative for d=9.

**d=3, d=6 verification:**
- d=3, c=(1,1,1): Q_n(1) = 7^n. Q_1 = 2q + 2q^2 + 3q^3. Nonneg.
- d=6, c=(2,2,2): Q_n(1) = 25^n. Q_1 = 2q + 5q^2 + 6q^3 + 6q^4 + 3q^5 + 3q^6. Nonneg.

**Implication:** For d equiv 0 mod 3, ell = gcd(d,3) = 3, and h_m = (q^3;q^3)_m * g_m(q) is NOT a polynomial. The factor (q^3;q^3)_m does not cancel all the poles of g_m. Therefore:

1. **The D_k^m tower proof strategy ONLY works for d not equiv 0 mod 3.**
2. Positivity for d equiv 0 mod 3 requires a completely different approach.
3. The conjecture's restriction to d not equiv 0 mod 3 is STRUCTURALLY MEANINGFUL -- it is precisely the condition under which the D_k^m decomposition produces polynomials.

**Base values for d equiv 0 mod 3:**
- d=3: base = 7
- d=6: base = 25
- d=9: base = 52

Sequence: 7, 25, 52. Differences: 18, 27.

**Small d reference values:**
- d=2: Q_n = q^{n^2}. Q_n(1) = 1.
- d=4: Q_1 = 2q + q^2 + q^3. Q_n(1) = 4^n.
- d=5: Q_n(1) = 6^n.

### Binary CP Polytope (Ehrhart Analysis)

For profile c = (c_0, c_1, c_2), binary cylindric partitions (max=1) reduce to counting lattice points (L_0, L_1, L_2) in a cone:
- L_i >= 0
- L_1 <= L_0 + c_1
- L_2 <= L_1 + c_2
- L_0 <= L_2 + c_0

Weight = L_0 + L_1 + L_2.

**Verified exhaustively for d up to 10:** The lattice point counts {f_1(w)} are weakly monotonically increasing in w and stabilize to (d+1)(d+2)/6.

Examples:
- c=(3,2,2), d=7: counts = [1, 3, 6, 8, 10, 11, 12, 12]. Stable at 12 from w=6.
- c=(4,2,1), d=7: counts = [1, 3, 5, 7, 9, 10, 11, 11, 12, 12]. Stable at 12 from w=8.
- c=(4,3,3), d=10: counts = [1, 3, 6, 10, 13, 16, 18, 20, 21, 22, 22]. Stable at 22 from w=9.

This confirms Seed 6's reduction: Q_1 >= 0 iff f_1 is weakly increasing.

### Demazure Character Matching

From another agent's computation (same session):

**d=4, c=(2,1,1), hat{sl}_3 at level 4, weight 2*Lambda_0 + Lambda_1 + Lambda_2:**
- D_e = 1
- D_{s1s2} = q^3 + q^2 + 2q + 1, sum = 5 = h_1(1).
- **h_1(q) = D_{s1s2}(q)** (exact polynomial match!).
- **Q_1 = D_{s1s2} - D_e = h_1 - 1.**
- D_{s0s1} = q^4 + q^3 + 2q^2 + 2q + 1, sum = 7.
- D_{s0s1s2} = sum 22.
- D_{s0s1s2s0s1s2} = sum 1125.

None of these have sum 25 = h_2(1). So h_2 is NOT a single Demazure character.

**BFS cumulative counts from hw in crystal B(Lambda):**
- d=4: cum = [1, 4, 11, 25, 52, 100, 183, 320, 543, ...]
- cum[1] = 4 = Q_1(1), cum[3] = 25 = h_2(1).
- These coincidences with BFS cumulative counts merit further investigation but the BFS depth is NOT the principal specialization grading for affine types.

## Approach

### For d not equiv 0 mod 3 (the conjecture as stated):

1. **D_k^m tower approach (from Seed 4).** Main line. Need D_k^m >= 0 for all m >= k >= 0.
   - Base case k=0 (h_m >= 0): attacked via Demazure character theory. h_1 = D_{s1s2} proved for d=4. h_m for m >= 2 needs identification.
   - Inductive step: D_{k-1}^m >= q^k D_{k-1}^{m-1} coefficient-wise. No mechanism known.

2. **Q_1 positivity via Ehrhart.** Nearly complete. Needs formal proof of lattice point monotonicity for the binary CP cone.

3. **Direct Demazure identification of Q_n.** If Q_n = character of a specific representation, positivity follows from Kumar-Mathieu. Computationally out of reach with LS path crystals.

### For d equiv 0 mod 3:

The D_k^m tower FAILS (h_m not a polynomial). Completely different approach needed.

## What a Counterexample Looks Like

Q_{n,c}(q) would need a negative coefficient for some d not equiv 0 mod 3, n >= 1. Since Q_n = D_n^n, this means D_n^n < 0 coefficient-wise, which propagates from the tower.

## Strategy

### Strategy 1: Prove Q_1 >= 0 via Ehrhart monotonicity

**Key lemma:** For the cone C = {(L_0,L_1,L_2) >= 0 : L_{i+1} <= L_i + c_{i+1} (cyclic)}, the lattice point count f(w) = |{L in C : sum L_i = w}| is weakly increasing for all w >= 1.

**Why it might work:** The cone is a rational polyhedral cone. Lattice point counts in dilations of rational polytopes are eventually polynomial (Ehrhart theory). The cone's cross-sections are 2-dimensional lattice polytopes, and their lattice point counts are eventually polynomial of degree 1 (linear), hence eventually monotonic. The key is showing monotonicity from w=1, not just eventually.

**Why it might not work:** Need to show IMMEDIATE monotonicity (from w=1), not just eventual. The geometry of the specific cylindric partition cone must be analyzed.

### Strategy 2: Identify h_m as Demazure characters

**Status:** h_1 = D_{s1s2} for d=4. For h_m with m >= 2, no match found. Likely h_m is NOT a single Demazure character.

### Strategy 3: Induction on D_k^m tower

**Status:** The domination condition D_{k-1}^m >= q^k D_{k-1}^{m-1} is verified computationally but no proof mechanism exists. The q-analogue of the q=1 evaluation is too strong.

## Key Lemma

The proof reduces to:
1. f_1(w) >= f_1(w-1) for all w >= 1 (gives Q_1 >= 0), OR
2. D_k^m >= 0 for all valid k, m (gives Q_n >= 0), OR
3. Q_{n,c}(q) = char of a representation with known positivity.

## Stuck Points

### Stuck 1: Demazure Character for h_m (m >= 2)

h_m for m >= 2 does not match any single Demazure character at the given highest weight. The Demazure character sums grow too fast (5, 7, 9, 22, 27, 39, 75, 105, 135, ...) and skip 25 = h_2(1).

Possible resolution: h_m may be a Demazure character at a DIFFERENT highest weight (one that depends on m), or a tensor product character, or a graded component of the Fock space.

### Stuck 2: D_k^m tower for d equiv 0 mod 3

h_m has negative coefficients for d equiv 0 mod 3. The entire D_k^m framework is invalid. But Q_n is still nonneg! Need a different approach.

## THE BROKEN ASSUMPTION

**What I believed:** h_m is a polynomial with nonneg coefficients for ALL d and c.

**What is actually true:** h_m is a polynomial with nonneg coefficients ONLY when gcd(d, 3) = 1 (i.e., d not equiv 0 mod 3). When 3|d, h_m = (q^3;q^3)_m * g_m(q) is a formal power series with negative coefficients.

**What this means for the proof:** The D_k^m tower is valid precisely for the cases in the conjecture (d not equiv 0 mod 3). The conjecture's restriction is not arbitrary -- it reflects the structural boundary between polynomial and non-polynomial h_m.

## Summary of New Results

### GREEN (verified algebraically or computationally exhaustive)
- Extended positivity: d=7 (n<=5), d=8 (n<=3), d=10 (n<=2). All Q_n nonneg.
- D_k^m tower for d=7: all entries nonneg for k,m <= 5.
- D_k^m(1) = base^k * (base+1)^{m-k} verified for d=7.
- h_1 = D_{s1s2} for d=4, c=(2,1,1) (Demazure character of hat{sl}_3 at level 4).
- Binary CP lattice point monotonicity for all profiles with d <= 10.
- Q_n(1) = 52^n for d=9 (new base value for d equiv 0 mod 3).

### YELLOW (verified for small cases, not proved)
- Q_n >= 0 for d=9 (d equiv 0 mod 3), base = 52.
- D_k^m >= 0 for d=7, k,m <= 5 (equivalent to conjecture for d=7).

### RED (failed or incomplete)
- h_m NOT polynomial for d equiv 0 mod 3 -- D_k^m tower breaks.
- h_2 does not match any single Demazure character for d=4.
- Demazure crystal computation for d=7 too slow (LS path crystals).
- Level-rank dual check not completed.

### KEY DISCOVERY
For d equiv 0 mod 3: Q_n is nonneg but h_m and D_k^m have negative coefficients. The conjecture's restriction to d not equiv 0 mod 3 is the exact boundary between the polynomial regime (D_k^m tower works) and the non-polynomial regime (new methods needed).
