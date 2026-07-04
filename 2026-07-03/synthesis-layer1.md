# Synthesis: Layer 1 (8 Seed Agents)

## 1. What Was Tried

**Seed 1 (Hall-Littlewood / Bartlett-Warnaar).** Computed Q_{n,c}(q) for d = 2, 4, 5, 7 and discovered a key structural decomposition: Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}(q), where h_m(q) = (q;q)_m * [z^m] GK_c(z,q). Proved algebraically that h_m(1) = ((d+1)(d+2)/6)^m, which immediately recovers Welsh's evaluation Q_n(1) = (base-1)^n via the binomial theorem. Conjectured h_m non-negativity (verified for d <= 7, m <= 5). Attempted to prove Q_n >= 0 from h_m >= 0 via q-Pascal telescoping and q-falling factorial expansion. Both attempts failed: the q^{j(j+1)/2} shift in the alternating sum prevents coefficient-by-coefficient domination arguments. Proposed but did not execute a Hall-Littlewood principal specialization strategy for h_m positivity via the Kirillov-Warnaar-Zudilin formula.

**Seed 2 (Partition-Bead Bijections / Tingley).** Built a transfer matrix computation that correctly produces F_{c,N}(q) and hence Q_{n,c}(q) for profiles with max(c_i) <= 2. Verified positivity for d in {2, 4, 5} and n up to 3. Identified the degree formula deg(Q_n) ~ (d-1)n^2 (profile-dependent lower-order terms). Reformulated Q_n >= 0 as a total positivity property of the sequence {F_{c,N}}_{N >= 0} and verified q-log-concavity (F_{c,N}^2 - F_{c,N-1}*F_{c,N+1} >= 0 coefficientwise) for all tested cases. Attempted three proof strategies: (1) direct involution on the alternating sum (failed: different max bounds prevent pairing), (2) direct combinatorial interpretation of Q_n (failed: alternating signs from (z;q)_inf obscure the object being counted), (3) Schur positivity / representation theory (promising but requires identifying the right module). Connected the bead model interpretation to FKG/correlation inequalities for lattice models but did not close the argument.

**Seed 3 (Skew RSK Dynamics / Imamura).** Independently derived the alternating sum formula Q_n = sum_j (-1)^j q^{j(j-1)/2} * (q;q)_n/(q;q)_j * F_{c,n-j}(q), verified Q_n computationally for d in {2, 4, 5}, and confirmed cyclic permutation invariance of Q_{n,c}. Attempted three proof strategies: (1) Garsia-Milne involution principle (failed: the double alternating sum over (j, S) with F_{c,n-j} for different n-j does not admit a uniform involution), (2) skew RSK / q-Whittaker decomposition (failed: connecting cylindric partition GFs to q-Whittaker polynomials is circular -- it requires the positivity we are trying to prove), (3) transfer matrix spectral analysis (failed: alternating sum mixes different transfer matrices T_N for different N, so spectral properties of individual matrices do not control the combination). Identified the fundamental obstruction: ALL approaches struggle with the "cross-N" nature of the alternating sum, where F_{c,m} for different m values are mixed.

**Seed 4 (Bilateral Rogers-Ramanujan / Schlosser).** Computed Q_n for d = 2, 4 up to n = 4 and discovered the isolated top-degree monomial q^{3n^2} (for c=(2,1,1)) with coefficient 1 and a gap below it. Connected this quadratic exponent to the bilateral RR structure (Schlosser's sums have exponents q^{k(5k-3)} etc.). Attempted to formalize the bilateral connection: Schlosser's bilateral parameter z tracks the summation index while F_c's z tracks max entry -- these are fundamentally different quantities, so no direct identification was established. Also attempted the involution principle on the alternating sum (failed due to intricate sign structure) and proposed Bailey pair / WP-Bailey chain approach without executing it. Confirmed that Q_n does NOT satisfy a simple 2-term recurrence with polynomial coefficients.

**Seed 5 (Schubert Polynomials / Lascoux).** Computed Q_n for d = 2, 4, 5 up to n = 4 via a Corteel-Welsh iterative system. Found a key computational result: for c = (2,1,1), Q_{n,c}(q) decomposes as a non-negative integer combination of GL_2 key polynomial (Demazure character) specializations K_{(a,b)}(q, q^2) for n = 0, 1, 2, 3, 4. This immediately implies positivity for those cases since key polynomials have non-negative coefficients. However, the decomposition is non-canonical (produced by a greedy algorithm) and no structural reason for its existence was found. Attempted to connect (zq;q)_inf to Grothendieck polynomial factors (failed: Borodin's product has q-Pochhammer step t while Grothendieck factors have step 1 -- fundamental mismatch). The Demazure module / crystal base interpretation remains the most promising but unfinished direction from this seed.

**Seed 6 (Nandi Conjecture / Mod-14 / Takigiku-Tsuchioka).** Verified Nandi identities (TT double sums = mod-14 products) up to q^20. Attempted to adapt the TT three-step strategy (find q-difference equation, solve to multisum, prove positivity) to the Warnaar conjecture. Failed at step 1: the Corteel-Welsh recurrence shifts the profile c, not just the z-variable, so it does not yield a self-contained q-difference equation for a single profile. Instead it produces a coupled system across all profiles with the same d, which is what Uncu (2024) automated via Gaussian elimination for specific moduli. Discovered (then corrected) the erroneous claim that Q_{1,c} depends only on d: it actually depends on the specific profile c, though Q_{1,c}(1) is profile-independent. Found that Q_1 always has coefficient 2 at q^1 and identified a reversal symmetry: c and (c_2, c_1, c_0) give the same Q_1.

**Seed 7 (Vertex Operators / D_4^(3) / Tsuchioka).** Identified a critical modulus mismatch: D_4^(3) lives naturally at modulus 9 (d=6), which is EXCLUDED from the conjecture by the d not-equiv 0 mod 3 condition. However, found a structural parallel: Tsuchioka's partial commutation relations (relations 3 and 4 in Theorem 2) hold only when A+B not-in 3Z, the same divisibility condition as the conjecture. Fixed an enumeration bug (cylindric partitions can have arbitrarily many parts; only total weight should be truncated, not part count). Proved a structural result for Q_1: g_1(q) = F_{c,1}(q) - 1 is a rational function P(q)/(1-q) with P a polynomial, making Q_1 = (1-q)*g_1 - q a polynomial. Showed the stable coefficient of g_1 equals (d+1)(d+2)/6 = number of valid binary cylindric partition triples, matching the lattice point count for the relevant polyhedral cone. Proposed that for each modulus t = 3+d with d not-equiv 0 mod 3, the relevant algebra is the twisted affine X_N^(r) with h* = t at level 3.

**Seed 8 (Plane Partitions / Lozenge Tilings / Hopkins-Lai).** Developed the Corteel-Welsh iterative computation approach (the most robust computation method across all seeds), computing Q_n for d = 2, 4, 5, 7, 8, all confirmed positive. Identified structural patterns: Q_1 always starts with coefficient 2 at q^1 and ends with coefficient 1, min degree sequence (0, 1, 3, 7, 12) for d >= 4, leading coefficient alternates 1, 2, 1, 2, 1. Attempted transfer matrix eigenvalue decomposition (failed: Q_n is not lambda^n for any fixed lambda), direct recursion for Q_n from Q_{n-1} (not manifestly positive), and lozenge tiling interpretation (b_j are infinite series, so "frozen configuration" counting requires understanding an infinite cancellation). Noted that (d+1)(d+2)/6 - 1 counts nontrivial C_3-orbits of sl_3 level-d dominant weights, connecting to crystal base theory.


## 2. Partial Results

### GREEN (verified algebraically and computationally)

- **Welsh's evaluation**: Q_{n,c}(1) = ((d+1)(d+2)/6 - 1)^n for r = 3, d not-equiv 0 mod 3. (Known theorem, re-derived by Seed 1 via h_m(1) = base^m.)

- **Alternating sum formula**: Q_{n,c}(q) = sum_{j=0}^n (-1)^j q^{j(j+1)/2} (q^{j+1};q)_{n-j} g_{n-j}(q), where g_m = [z^m] F_c(z,q) counts cylindric partitions with max exactly m. Equivalently, Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}(q), where h_m = (q;q)_m * g_m. (Derived independently by Seeds 1, 3, 7; all agree.)

- **h_m evaluation**: h_m(1) = ((d+1)(d+2)/6)^m. This recovers Q_n(1) = (base - 1)^n via the binomial theorem. (Seed 1.)

- **Q_1 structure**: Q_{1,c}(q) = (1-q)*g_1(q) - q, where g_1 is a rational function with a simple pole at q = 1, making Q_1 a polynomial. The stable coefficient of g_1 is (d+1)(d+2)/6. (Seeds 7, 2.)

- **Cyclic permutation invariance**: Q_{n,c}(q) is invariant under cyclic permutation of c. (Seed 3, verified computationally.)

- **Reversal symmetry**: Q_{n,(c_0,c_1,c_2)}(q) = Q_{n,(c_2,c_1,c_0)}(q). (Seed 6, computationally verified.)

- **Degree formula**: deg(Q_{n,c}) = (d-1)n^2 + lower-order profile-dependent terms. For c = (2,1,1), deg = 3n^2 exactly. Top monomial is always q^{deg} with coefficient 1, and there is a gap before it. (Seeds 2, 4.)

- **d = 2 closed form**: Q_{n,(1,1,0)}(q) = q^{n^2}, a single monomial. (All seeds.)

- **q-Log-concavity of {F_{c,N}}**: F_{c,N}^2 - F_{c,N-1}*F_{c,N+1} >= 0 coefficientwise for all tested cases (necessary condition for total positivity). (Seed 2.)


### YELLOW (computationally verified, not proved)

- **h_m non-negativity conjecture (Seed 1)**: For all profiles c with d not-equiv 0 mod 3 and all m >= 0, h_m(q) = (q;q)_m * g_m(q) has non-negative coefficients. Verified for d <= 7, m <= 5. This is a STRONGER conjecture than the main one (it does not directly imply Q_n >= 0 but is a necessary ingredient in the h_m approach).

- **Key polynomial decomposition (Seed 5)**: For c = (2,1,1), Q_{n,c}(q) decomposes as a non-negative integer combination of GL_2 key polynomial specializations K_{(a,b)}(q, q^2) for n = 0, 1, 2, 3, 4. The decomposition is non-canonical (greedy algorithm), and no structural reason for its existence is known.

- **Q_1 coefficient 2 at q^1**: The lowest-degree nonzero coefficient of Q_{1,c}(q) is always 2 (at degree 1) for profiles with all c_i > 0 with d >= 4. (Seeds 6, 7, 8.)

- **Positivity for d = 7, 8**: Q_{n,c}(q) has non-negative coefficients for d = 7 (profiles (3,2,2), (4,2,1)) and d = 8 (profile (3,3,2)) for n = 0, 1, 2. These are the first unproved cases. (Seeds 1, 7, 8.)


### RED (attempted but failed or incomplete)

- **Total positivity of {F_{c,N}}**: Seed 2 conjectured that the sequence {F_{c,N}} is q-totally-positive (all Hankel-type minors non-negative). Only q-log-concavity (2x2 case) was verified. Higher minors untested.

- **Bilateral RR identification**: Seed 4 attempted to identify Q_{n,c}(q) with a bounded bilateral Rogers-Ramanujan sum. The z parameters track different quantities, so no identity was found.


## 3. What Failed and Why

### The Cross-N Obstruction (Seeds 1, 2, 3, 4, 6, 7, 8 -- universal)

**What was attempted**: Every seed tried to prove positivity of the alternating sum Q_n = sum_j (-1)^j q^{j(j+1)/2} (q^{j+1};q)_{n-j} g_{n-j}(q).

**Where it broke**: The alternating sum involves g_m (or F_{c,m}) for DIFFERENT values of m. The generating function g_m changes fundamentally as m changes (it counts cylindric partitions with different max bounds). No approach found a way to "uniformize" across different m values.

**Why it broke**: The terms being alternately added and subtracted are not subsets of a common ground set. In a standard involution argument (e.g., Garsia-Milne), you need a signed set where positive and negative elements can be paired. Here, the j-th term lives in the space of cylindric partitions with max = n-j, and there is no natural map between these spaces that preserves weight while changing sign.

**Is this instructive?** YES. This is the central obstruction. Any successful proof must either (a) find a single combinatorial space containing all the Q_n information and define an involution on it, (b) find a manifestly positive formula that avoids the alternating sum entirely, or (c) use representation theory to identify Q_n as a graded dimension. Approach (a) seems blocked by the cross-N structure. Approaches (b) and (c) are more promising.

### Garsia-Milne Involution (Seeds 3, 4)

**What was attempted**: Construct a sign-reversing weight-preserving involution on the signed set S_n = union_j {(j, Lambda) : max(Lambda) = n-j} with sign (-1)^j.

**Where it broke**: The double alternating sum (from (-1)^j and from expanding (q^{j+1};q)_{n-j}) creates a two-level sign structure. The involution would need to map between cylindric partitions of different max values, which changes the underlying combinatorial objects.

**Is this instructive?** PARTIALLY. It rules out simple "local move" involutions but does not rule out more sophisticated bijective arguments that work at the level of the encoding (e.g., bead model or lattice path encoding rather than the cylindric partitions themselves).

### CW Recurrence as q-Difference Equation (Seed 6)

**What was attempted**: Adapt the Takigiku-Tsuchioka approach (find q-difference equation, solve to multisum, prove positivity).

**Where it broke**: Step 1 fails because the CW recurrence shifts the profile c, not just the variable z. The result is a coupled system across all profiles with the same d, not a single q-difference equation. This system grows exponentially in d.

**Why it broke**: The CW recurrence is inherently a multi-profile object. It relates F_c to F_{c(J)} for shifted profiles c(J), and these shifted profiles generate further shifts. The recursion tree terminates only at the trivial profile (0,0,0).

**Is this instructive?** YES. This shows that per-profile analysis is insufficient. Any proof via the CW recurrence must handle all profiles simultaneously (as Uncu's Gaussian elimination does for specific moduli, but not for general d).

### Bilateral RR Connection (Seed 4)

**What was attempted**: Identify Q_{n,c}(q) as a bounded bilateral Rogers-Ramanujan sum (a la Schlosser).

**Where it broke**: Schlosser's bilateral parameter z tracks the summation index k (appearing as z^{2k} in the bilateral sum), while F_c(z,q) has z^{max(Lambda)} tracking the maximum entry. These are fundamentally different quantities.

**Is this instructive?** PARTIALLY. The quadratic exponent structure (q^{3n^2} top degree for d=4) matches bilateral sum exponents, suggesting a deep but indirect connection. The bilateral direction is not ruled out but needs a different entry point.

### Grothendieck Polynomial / Schubert Connection (Seed 5)

**What was attempted**: Interpret (zq;q)_inf as a Grothendieck-type factor and F_c(z,q) as a Schubert-kernel specialization.

**Where it broke**: Borodin's product formula has q-Pochhammer factors with step t = k+d, while Grothendieck/Schubert factors have step 1. The step-size mismatch prevents direct identification.

**Is this instructive?** YES. It rules out naive Schubert calculus approaches but leaves open the possibility of affine Schubert calculus (where the step size t could appear naturally).

### D_4^(3) Z-Algebra (Seed 7)

**What was attempted**: Use Tsuchioka's Z-algebra framework for D_4^(3) to construct a positive basis for the vacuum space.

**Where it broke**: D_4^(3) lives at modulus 9 (d = 6), which is EXCLUDED from the conjecture. The natural home of the Tsuchioka machinery does not overlap with the conjecture's hypothesis.

**Is this instructive?** YES, and in two ways. First, it explains WHY d equiv 0 mod 3 is excluded: the mod-3 condition in Tsuchioka's partial commutation relations (A+B not-in 3Z) is the algebraic shadow of the conjecture's hypothesis. Second, it points toward using OTHER twisted affine algebras (X_N^(r) with h* = t = 3+d) at level 3 for each allowed modulus.


## 4. Broken Assumptions

1. **"Q_{1,c} depends only on d."** WRONG. Q_{1,c}(q) depends on the specific profile c (up to reversal symmetry and cyclic permutation), though Q_{1,c}(1) = (d+1)(d+2)/6 - 1 is profile-independent. Discovered by Seed 6, confirmed by all others.

2. **"h_m >= 0 implies Q_n >= 0."** NOT DIRECTLY TRUE. Even with all h_m having non-negative coefficients, the alternating q-binomial transform can produce negative coefficients in principle. The implication h_m >= 0 => Q_n >= 0 requires an additional argument (e.g., a q-analogue of the binomial theorem for sequences growing like base^m). Discovered by Seed 1.

3. **"Q_n = Q_1^n as a polynomial."** WRONG. Q_n(1) = Q_1(1)^n but deg(Q_n) grows quadratically in n, while deg(Q_1^n) grows linearly. (Seeds 2, 4, 8.)

4. **"g_m(q) is a polynomial."** WRONG. g_m(q) = [z^m] F_c(z,q) is an infinite power series (cylindric partitions with max = m can have arbitrarily long parts). Only h_m = (q;q)_m * g_m is a polynomial. (Seeds 1, 7, 8.)

5. **"The transfer matrix for different N values can be spectrally related."** NOT ESTABLISHED. The transfer matrices T_N for different max bounds N are different matrices with different state spaces. No spectral relationship between them has been found that would control the alternating sum. (Seeds 3, 4, 8.)

6. **"Parts can be truncated for computation."** WRONG. Several seeds (notably Seed 7) discovered bugs from truncating the number of parts. Cylindric partitions can have arbitrarily many parts; only total q-weight should be truncated.

7. **"Total positivity of {F_{c,N}} implies Q_n >= 0."** CIRCULAR. Defining q-complete monotonicity of {F_{c,N}} as "all q-differences non-negative" is equivalent to Q_n/(q;q)_n >= 0, which is exactly what we are trying to prove. (Seed 2.)


## 5. Connections

### Connection A: The h_m Conjecture and Total Positivity (Seeds 1 + 2)

Seed 1 discovered h_m(q) = (q;q)_m * g_m(q) and conjectured h_m >= 0. Seed 2 discovered q-log-concavity of {F_{c,N}} (a necessary condition for total positivity). These are related: h_m >= 0 is a statement about g_m = F_{c,m} - F_{c,m-1} after multiplying by (q;q)_m, while total positivity is about the Hankel-minor structure of the F_{c,N} sequence. If {F_{c,N}} is q-totally-positive AND h_m >= 0, the two conditions together may provide enough structure to prove Q_n >= 0. The precise relationship between these two positivity conditions has not been explored.

### Connection B: Demazure Modules / Affine Lie Algebras (Seeds 5 + 7 + 8)

Three seeds independently pointed toward affine Lie algebra / Demazure module interpretation:
- Seed 5 found that Q_{n,c}(q) decomposes as a positive combination of GL_2 Demazure character specializations (key polynomials).
- Seed 7 identified the Z-algebra framework and proposed that Q_n is the graded dimension of a bounded vacuum space of the relevant twisted affine algebra at level 3.
- Seed 8 noted that (d+1)(d+2)/6 - 1 counts nontrivial C_3-orbits of sl_3 level-d dominant weights, connecting Q_n(1) to representation-theoretic counting.

These three observations are facets of the same underlying structure: Q_{n,c}(q) should be the character of an n-fold Demazure-type truncation of a level-3 affine Lie algebra module. The algebra changes with the modulus t = 3+d (Seed 7's insight). The key polynomial decomposition (Seed 5) would then reflect the Demazure crystal decomposition. The specific challenge is making this uniform across all t.

### Connection C: The Q_1 Structure (Seeds 2 + 7)

Seeds 2 and 7 independently characterized Q_1 in the same way:
- Q_1 = (1-q)*g_1(q) - q
- g_1 is a rational function with a simple pole at q = 1
- The stable (large-degree) coefficient of g_1 is (d+1)(d+2)/6
- This stable coefficient counts lattice points in a polyhedral cone (the set of valid binary cylindric partition triples)

This means Q_1 positivity reduces to showing that (1-q)*g_1(q) - q has non-negative coefficients, which is equivalent to showing that g_1's coefficients are weakly increasing and start >= 2. Both seeds verified this computationally.

### Connection D: The Universal Obstruction (Seeds 1 + 2 + 3 + 4 + 6 + 7 + 8)

ALL seven seeds that attempted proof hit the same fundamental wall: the alternating sum mixes F_{c,m} (or g_m or h_m) across different values of m. This is the "cross-N interaction" problem. The consensus across seeds is that the right proof must either:
1. Bypass the alternating sum entirely (find a manifestly positive formula), or
2. Use representation theory to identify Q_n as a graded dimension.

No seed found a way to prove positivity from the alternating sum formula alone.

### Connection E: The (d+1)(d+2)/6 Number (Seeds 1 + 6 + 7 + 8)

Multiple seeds identified the significance of (d+1)(d+2)/6:
- Seed 1: h_m(1) = ((d+1)(d+2)/6)^m
- Seed 7: stable coefficient of g_1 equals (d+1)(d+2)/6, counting valid binary cylindric partition triples
- Seed 8: (d+1)(d+2)/6 - 1 counts nontrivial C_3-orbits of sl_3 level-d dominant weights
- Seed 6: (d+1)(d+2)/6 is NOT the number of partitions of d into at most 3 parts (which would be round(d^2/12 + ...))

**[Synthesizer observation]**: The number (d+1)(d+2)/6 is the number of non-negative integer triples (a,b,c) with a+b+c = d satisfying the cyclic interlacing constraints for max-1 cylindric partitions of a SPECIFIC profile (see Seed 7's lattice point analysis). That this same number appears as h_m(1)^{1/m} (Seed 1) and as the sl_3 weight orbit count (Seed 8) suggests a deep connection between the binary cylindric partition polytope, the Hall-Littlewood evaluation, and sl_3 representation theory. This triple connection is the most promising structural insight from Layer 1.

### Connection F: Profile Dependence (Seeds 3 + 6)

Seed 3 showed Q_{n,c} is invariant under cyclic permutation of c. Seed 6 showed Q_{n,c} is invariant under reversal of c, and that different profiles with the same d give different Q polynomials (though with the same evaluation at q = 1). Together: Q_{n,c} depends on c up to the dihedral symmetry of the triangle (cyclic + reversal = full D_3 action on (c_0, c_1, c_2)). This means any proof must handle profile dependence, not just total d.


## 6. Recommendations for Layer 2

### Pursue

1. **Demazure module / crystal base interpretation (Priority 1).** This is where three seeds (5, 7, 8) independently converge. The concrete task: for the first unproved case d = 7, t = 10, identify the twisted affine algebra X_N^(r) with h* = 10 (likely A_7^(2), rank 3, as Seed 7 suggests). Construct the level-3 standard module and its Demazure crystal truncation at depth n. Verify that the resulting graded character matches Q_{n,(3,2,2)}(q). If this works for d = 7, it provides the template for general d.

2. **h_m positivity via Hall-Littlewood specialization (Priority 2).** Seed 1's h_m conjecture (h_m(q) >= 0 with h_m(1) = base^m) is a clean, self-contained sub-problem. If h_m can be identified as a Hall-Littlewood principal specialization (via the Kirillov-Warnaar-Zudilin formula or the Bartlett-Warnaar limit procedure), its positivity follows. This does not immediately prove Q_n >= 0 (see Broken Assumption #2), but it eliminates one layer of difficulty.

3. **Manifestly positive multisum for d = 7 (Priority 3).** Warnaar found positive multisums for d = 2, 4, 5. Uncu found new identities for moduli 11 and 13 via Gaussian elimination on the CW recurrence. Extending Uncu's approach to d = 7 (modulus 10) would provide an explicit positive formula for the first unproved case. Even without proving the general case, this would reveal the pattern in the multisums.

4. **The Q_1 -> Q_n bootstrap (Priority 4).** Q_1 positivity is understood (Seed 7's lattice point argument). The gap is Q_1 -> Q_n. Seed 1's formula Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j} shows Q_n is a q-deformation of (base-1)^n. Investigate whether there is a q-analogue of the binomial theorem that, given h_m >= 0 and h_m(1) = base^m with base >= 2, implies positivity of the alternating q-binomial transform. This would reduce the conjecture to h_m >= 0.

### Abandon

5. **Direct bilateral RR identification (Seed 4).** The z parameters in Schlosser and in cylindric partitions track fundamentally different quantities. The quadratic exponent structural match is real but too indirect to build a proof on. Keep the Bailey pair direction as a long-shot but do not invest primary effort.

6. **Simple involution on the alternating sum.** Seven seeds attempted this and all failed at the cross-N obstruction. The failure is structural, not incidental. Do not attempt further involution arguments on the raw alternating sum formula. (A bijective argument at a higher level -- e.g., on crystal graphs or lattice paths -- could still work, but it would need to operate on different objects than the alternating sum terms.)

### Explore (New Connections)

7. **The h_m--total positivity bridge (Connection A).** The relationship between Seed 1's h_m conjecture and Seed 2's total positivity of {F_{c,N}} has not been explored. Are these equivalent? Does one imply the other? A Layer 2 agent should investigate this.

8. **Uncu's Gaussian elimination for general d.** Seed 6 identified that the CW recurrence produces a coupled system across profiles. Uncu automated this for specific moduli. Can the system be solved symbolically for general d? The structure of the solution (as a function of d) might reveal the manifestly positive multisum pattern.

### Specific Computation Requests

- Compute h_m(q) for d = 7, m = 1, 2, 3, 4 and verify non-negativity.
- For d = 7, compute Q_n for n = 3, 4 (requires handling max(c_i) = 3 in the transfer matrix).
- Check whether the key polynomial decomposition (Seed 5) works for d = 7 at specialization (q, q^2, q^3) (three variables for sl_3).
- Verify the Demazure crystal structure for Q_{1,(3,2,2)} by enumerating sl_3 crystals at level 7.
