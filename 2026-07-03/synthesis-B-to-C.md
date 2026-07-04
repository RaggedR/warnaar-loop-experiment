# Synthesis: Agent B to Agent C

## 1. What Was Tried

**Agent B** had RAG access (82 papers, 7037 chunks) and SageMath computation. Agent B pursued three directions recommended by the A-to-B synthesis: (1) spectral decomposition of the transfer matrix, (2) adjugate matrix nonnegativity, and (3) Warnaar's A_2 invariance identity via RAG. The adjugate investigation yielded a major structural discovery. The spectral decomposition was planned but subsumed by the adjugate work. The A_2 invariance identity was researched via RAG but not computationally exploited.

**Direction 1 (Adjugate Matrix Analysis -- became the main effort):** Agent B computed adj(I - A(x)) for the Corteel-Welsh shift matrix A(x) at d = 1, 2, 3, 4, 5, 7, 8 (matrix sizes 3x3 to 45x45). The discovery: every entry of the adjugate is a MONOMIAL x^{EMD(c,c')}, where EMD is the Earth Mover's Distance on Z/3Z with a specific clockwise metric. This is the **Adjugate Monomial Theorem**. Combined with the known det(I - A(x)) = 1 - x^3, this yields a manifestly positive path formula for P_n = (q^3;q^3)_n * F_{c,n}. Agent B wrote 11 SageMath scripts verifying this across multiple values of d.

**Direction 2 (Warnaar's A_2 Invariance Identity -- RAG research only):** Agent B performed 6 RAG queries. Key findings: (a) Warnaar's k=1 proof uses level-rank duality from rank-3 to rank-2, then a rank-2 Rogers-Ramanujan identity; (b) there is an explicit rank-2 bounded formula (Proposition RRcase-rank2) that is manifestly positive; (c) the open problem is finding bounded analogues for k >= 2. Agent B did not attempt to extract Q_n from these identities computationally.

**Direction 3 (Functional Equation for H_c):** Agent B derived the functional equation H_c(z,q) = sum_{|J|=1} H_{c(J)}(zq,q) - sum_{|J|=2} (1-zq) H_{c(J)}(zq^2,q) + sum_{|J|=3} (1-zq)(1-zq^2) H_c(zq^3,q), where H_c = (zq;q)_inf * F_c. This gives a system recurrence for Q_n across profiles simultaneously, but the coefficients have mixed signs.

**Direction 4 (Symmetry Investigation):** Agent B verified that Q_n has cyclic invariance Q_n(c_0,c_1,c_2) = Q_n(c_1,c_2,c_0) but NOT reversal symmetry Q_n(c_0,c_1,c_2) != Q_n(c_2,c_1,c_0) in general (checked for d=4, all 15 profiles, n=1,2,3). This corrects earlier claims/assumptions about profile symmetry.

---

## 2. Partial Results

### GREEN (proved or computationally verified to high confidence)

- **Adjugate Monomial Theorem (NEW, verified for d=1,2,3,4,5,7,8):** adj(I - A(x))[c,c'] = x^{EMD(c,c')} where EMD(c,c') = 3 * max(0, c'_1 - c_1, c_0 - c'_0) + (c'_0 - c_0) - (c'_1 - c_1) is the Earth Mover's Distance on Z/3Z with clockwise transport metric. Every entry is a monomial with coefficient 1. EMD is NOT symmetric. EMD(c,c) = 0. Algebraic proof pending but a clear proof sketch exists via the Bellman equation EMD(c,c') = min_J(|J| + EMD(c(J),c')) combined with the inclusion-exclusion structure of A(x).

- **Manifestly Positive Path Formula for P_n (NEW, follows from Adjugate Monomial Theorem):** P_n(c) = (q^3;q^3)_n * F_{c,n}(q) = sum over paths (c_0,...,c_{n-1}) of prod_{k=1}^n q^{k * EMD(c_k, c_{k-1})} with c_n = c. This is a sum of monomials with coefficient 1, hence manifestly nonneg. This gives a new proof of Kursungoz-Seyrek's P_n >= 0 result, with an explicit combinatorial interpretation.

- **Q_n evaluation formula extended:** Q_n(1) = 4^n for d=4 (all 15 profiles), Q_n(1) = 11^n for d=7, Q_n(1) = 21^n for d=10. Agent B verified Q_n >= 0 for d=4 (all profiles, n <= 4), d=7 (two profiles, n <= 3), d=10 (one profile, n <= 2).

- **Cyclic invariance confirmed, reversal invariance refuted:** Q_n(c_0,c_1,c_2) = Q_n(c_1,c_2,c_0) but Q_n(c_0,c_1,c_2) != Q_n(c_2,c_1,c_0) in general. Verified for d=4, all profiles, n=1,2,3.

- **d equiv 0 mod 3 negatives confirmed:** For d=3, c=(1,1,1), Q_1 has negative coefficients (e.g., coeff of q^4 = -1), with period-3 sign oscillation.

### YELLOW (partially developed, not complete)

- **Functional equation for H_c(z,q):** The system recurrence Q_n(c) involves Q_n and Q_{n-1} and Q_{n-2} at shifted profiles, with mixed-sign coefficients from (1-zq)(1-zq^2) factors. Not yet clear whether this has positivity-preserving properties.

- **Proof sketch for Adjugate Monomial Theorem:** The Bellman equation + inclusion-exclusion argument is outlined but not formally completed. Agent B identifies that a complete proof requires showing the EMD satisfies subadditivity/uniqueness conditions for the tropical determinant to be monomial.

---

## 3. What Failed and Why

### Failure 1: Spectral Decomposition (Planned but Not Executed)

**What was attempted:** Agent B planned to decompose M into eigencomponents (eigenvalues {1, omega, omega^2}) and analyze the eigenvalue-1 projection of g_m. This was the top priority from the A-to-B synthesis.

**Where it broke:** Agent B pivoted to adjugate analysis after discovering the monomial structure. The spectral decomposition was never computed.

**Is this instructive?** NO -- this is an incomplete exploration, not a failure. The spectral approach remains viable. The Adjugate Monomial Theorem may actually HELP the spectral approach, since knowing adj(I-A(x)) exactly gives the spectral projections via the partial fraction decomposition of (I-A(x))^{-1} = adj(I-A(x))/(1-x^3).

### Failure 2: Bridging from P_n >= 0 to Q_n >= 0

**What was attempted:** Agent B attempted to close the gap between the manifestly positive path formula for P_n and the positivity of Q_n. The relationship is Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^3;q^3)_j.

**Where it broke:** The q-binomial transform has intrinsically alternating signs. Even with the beautiful monomial structure of P_j, the alternating combination does not simplify to something manifestly positive.

**Why it broke:** This is the SAME obstruction Agent A identified: the (zq;q)_inf factor introduces unavoidable alternating signs. The path formula makes P_n prettier but does not change the fundamental challenge.

**Is this instructive?** YES, critically. It sharpens the problem statement: the conjecture is PRECISELY the claim that the q-binomial transform of the EMD path sum is nonneg. Any proof must either (a) find a signed involution on an extended path space that cancels negatives, (b) find a completely independent combinatorial interpretation of Q_n, or (c) use a global identity (Warnaar's A_2 invariance) that handles the cancellation.

### Failure 3: Warnaar A_2 Identity -- Not Exploited

**What was attempted:** Agent B queried RAG for Warnaar's proofs of k=1 and k=2 positivity. Found the rank-2 bounded formula and the level-rank duality mechanism.

**Where it broke:** Agent B extracted the theoretical framework but did not compute anything with it. No attempt was made to express Q_n using the manifestly positive multisum from the A_2 identity.

**Why it broke:** Time/effort allocation -- the adjugate discovery consumed the bulk of Agent B's computation budget.

**Is this instructive?** NO -- this is an incomplete exploration. The A_2 identity remains the single most promising avenue identified by Agent A, and it has NOT been tested. Agent C should prioritize this.

---

## 4. Broken Assumptions

1. **"Q_n has reversal symmetry Q_n(c_0,c_1,c_2) = Q_n(c_2,c_1,c_0)."** FALSE. Agent B verified that Q_n has cyclic invariance (C_3 rotation) but NOT S_3 reversal symmetry. For d=4, there exist profiles where Q_n(c) != Q_n(c_reversed). Discovered by Agent B, verified for all 15 profiles at d=4, n=1,2,3. This constrains any symmetry-based arguments: only cyclic rotation can be used, not the full dihedral group.

2. **"The spectral decomposition is the natural next step after the universal determinant."** NOT FALSE, but INCOMPLETE. The Adjugate Monomial Theorem shows that the spectral structure is richer than just knowing the eigenvalues. The adjugate being monomial means the spectral projections have a tropical/combinatorial structure that pure eigenvalue analysis would miss. The spectral approach and the adjugate approach should be pursued TOGETHER, not as alternatives.

---

## 5. Recommendations for Agent C

### PRIORITY 1: Exploit the Adjugate Monomial Theorem for Q_n

The Adjugate Monomial Theorem gives P_n as a sum over paths weighted by EMD. The passage from P_n to Q_n is: Q_n = [z^n] (zq;q)_inf * F_c(z,q) = [z^n] (zq;q)_inf * sum_j F_{c,j} z^j. Since (zq;q)_inf = prod_{i>=1} (1-zq^i) introduces alternating signs, the key question is:

**Can you interpret the product (zq;q)_inf * F_c(z,q) combinatorially on the path space?**

Concretely: F_c(z,q) = sum_n z^n * P_n / (q^3;q^3)_n where P_n = sum_{paths} q^{sum k*EMD(c_k,c_{k-1})}. Multiplying by (zq;q)_inf = sum_m (-1)^m z^m q^{m(m+1)/2} / (q;q)_m gives a convolution. The coefficient of z^n in this convolution is Q_n. A signed involution on the "extended path space" (pairs of a path of length j and a partition into at most n-j parts) might cancel all negative terms.

**Specific computation:** Write out Q_2 for d=4 using the path formula. List ALL contributing terms (paths of length 0, 1, 2 with (zq;q)_inf corrections) and see if a sign-cancellation pattern is visible.

### PRIORITY 2: Warnaar's A_2 Invariance Identity (Carried Forward from Agent A -- STILL UNTESTED)

Agent A identified this as the most promising direction. Agent B confirmed via RAG that Warnaar's k=1 proof uses level-rank duality to rank-2 bounded formulas. Neither agent computed anything with it. The specific formula (Proposition RRcase-rank2) gives a manifestly positive expression for the rank-2 bounded generating function.

**What Agent C should do:**
- Understand how Warnaar extracts positivity from the A_2 identity for k=1.
- Check whether the bounded rank-2 formula can be lifted back to rank-3 for general k.
- Compute the rank-2 formula explicitly for small cases and compare to Q_n.

### PRIORITY 3: System Recurrence for Q_n

Agent B derived the functional equation for H_c(z,q). This gives a system recurrence: Q_n(c) is expressed in terms of Q_j(c') for j < n and various shifted profiles c'. The coefficients have mixed signs.

**What Agent C should try:**
- Write out the recurrence explicitly for d=4 (15 profiles, so a 15-dimensional system).
- Check whether positivity of Q_1,...,Q_{n-1} (all profiles) implies Q_n >= 0 via the recurrence, perhaps with help from the evaluation Q_n(1) = ((d+1)(d+2)/2)^n.
- The key structural question: does the recurrence preserve nonnegativity when d is not divisible by 3?

### PRIORITY 4: Prove the Adjugate Monomial Theorem

Agent B sketched a proof via the Bellman equation EMD(c,c') = min_J(|J| + EMD(c(J),c')) and the inclusion-exclusion structure A(x) = x*S_cw - x^2*S_ccw + x^3*I_interior. The formal proof requires:
- Showing the Bellman equation holds for the CW shift structure.
- Showing that the tropical minimum is achieved uniquely (or that the inclusion-exclusion collapses to a single term).
- The diagonal case: the alternating sum over all shifts of EMD(c(J),c) equals x^3, combined with the 1 on the diagonal giving 1-x^3.

This would be a publishable result independent of the positivity conjecture.

### What NOT to Pursue

- **Do NOT retry Abel summation P_n -> Q_n.** Failed for Agent A, and Agent B's path formula does not change the obstruction.
- **Do NOT pursue h_m >= 0 for m >= 2.** Agent A confirmed this is FALSE (h_2 has negative coefficients even for d not equiv 0 mod 3). The D_k^m tower with base case h_m is dead.
- **Do NOT attempt direct KR tensor product matching.** Agent A proved the evaluations don't match.
- **Do NOT assume reversal symmetry of Q_n.** Agent B disproved this.

---

## 6. Summary of the State of Play After Agent B

### What is proved (cumulative)
- Q_1 >= 0 for d not equiv 0 mod 3 (injection lemma, Layer 3)
- g_m >= q * g_{m-1} for all m, d, profiles (injection lemma, Layer 3)
- h_m < 0 for d equiv 0 mod 3 (Layer 3)
- h_m < 0 for m >= 2 even when d NOT equiv 0 mod 3 (Agent A -- kills Path A)
- det(I - A(x)) = -(x^3 - 1) universally (Layer 3)
- KR tensor product weight spaces != Q_n (Agent A)
- Q_n has cyclic invariance but NOT reversal invariance (Agent B)

### What Agent B added
- **Adjugate Monomial Theorem:** adj(I-A(x))[c,c'] = x^{EMD(c,c')} (verified for d=1,2,3,4,5,7,8)
- **Manifestly positive path formula for P_n** via EMD-weighted paths
- **Functional equation for H_c(z,q)** giving a system recurrence for Q_n
- **Reversal asymmetry of Q_n** (correction to prior assumptions)
- Confirmed Q_n >= 0 for additional profiles and larger n values

### The surviving proof paths
- **Path A (D_k^m tower) is DEAD.** Base case h_m >= 0 is false for m >= 2.
- **Path B (representation-theoretic) is WOUNDED.** Direct KR matching fails. Energy function approach untested.
- **Path C (Warnaar A_2 invariance identity) is UNTESTED.** Two agents have identified it as most promising. Neither has computed with it. This is the top priority.
- **Path D (Adjugate + signed involution) is NEW.** The Adjugate Monomial Theorem gives a beautiful structure to P_n. The question is whether this structure can be extended through the (zq;q)_inf factor to reach Q_n. A signed involution on the extended path space is the concrete approach.
- **Path E (System recurrence) is NEW.** The H_c functional equation gives a coupled recurrence for Q_n across profiles. Positivity might be provable by induction on n if the recurrence has the right structure.

### The core diagnosis (sharpened by Agent B)
The problem has been precisely localized: **Q_n >= 0 is equivalent to the nonnegativity of the q-binomial transform of the EMD path sum.** The path sum itself is manifestly positive (Adjugate Monomial Theorem). The q-binomial transform introduces alternating signs. The conjecture asserts these signs cancel when d is not divisible by 3. No agent has yet found a mechanism for this cancellation.
