# Synthesis: Agent A to Agent B

## 1. What Was Tried

**Agent A** had RAG access to 82 papers (7037 chunks) and SageMath computation. Agent A explored three main directions and performed seven RAG queries targeting KR crystals, Kursungoz's decomposition, Tingley's crystal-CPP bijection, Schilling-Shimozono fermionic formulas, and Warnaar's A_2 invariance identity.

**Direction 1 (KR crystal tensor products):** Agent A computed the energy-graded weight spaces of B^{1,d}^{tensor n} for A_2^(1) using SageMath's `crystals.KirillovReshetikhin`. For d=4, the weight space at classical weight (2,0) corresponding to profile (2,1,1) in B^{1,4} tensor B^{1,4} has energy-graded polynomial evaluating to 9 at q=1, but Q_2(1) = 16. The KR tensor product weight space does NOT directly equal Q_n. The mismatch is numerical, not a precision issue.

**Direction 2 (Abel summation from Kursungoz P_n to Q_n):** Kursungoz-Seyrek proved P_n >= 0 (where F_{c,m} = P_m / (q^3;q^3)_m). Agent A attempted Abel summation: Q_n = P_n/(q^3;q^3)_n + sum_{m=0}^{n-1} (a_m - a_{m+1}) P_m/(q^3;q^3)_m. The differences a_m - a_{m+1} have mixed signs, so this does not yield a positive expression. The q-binomial transform kernel alternates in sign, blocking this route.

**Direction 3 (Warnaar A_2 invariance identity):** Agent A found (via RAG) that Warnaar proved the identity:
sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n][n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
where Phi_{n,m} = [n,m] / ((zq)_{n-m} (wq)_n). This is a manifestly positive multisum for the bounded generating function, proved for ALL n_0. Warnaar used it to prove positivity for k=1 and k=2. The open problem is extending this to general k. Agent A identified this as the most promising direction but did not complete the algebraic work of extracting Q_n from it.

**Additional computation:** Agent A verified Q_n >= 0 for d=2 (all profiles), d=4 (all 5 profiles, n up to 2), d=7 (all 5 profiles, n up to 2). Confirmed Q_2(1) = 121 = 11^2 for d=7 c=(3,2,2), with all coefficients nonneg. Also confirmed the universal determinant det(I - M(x)) = -(x^3 - 1) for d=4 and d=7, and found the matrix product formula F_n = prod_{k=1}^n (I - M(q^k))^{-1} * v_0 where v_0 = (1,...,1).

---

## 2. Partial Results

### GREEN (proved or verified)

- **CONFIRMED: KR tensor product weight spaces do NOT equal Q_n.** For d=4, profile (2,1,1), n=2: KR energy-graded weight space evaluates to 9 at q=1, but Q_2(1) = 16. The relationship between KR crystals and cylindric partitions is more indirect than a simple weight space extraction. (Agent A.)

- **CONFIRMED: h_m has NEGATIVE coefficients for m >= 2, even when d not-equiv 0 mod 3.** Explicit computation for d=4, c=(2,1,1): h_2 = (1-q)(1-q^2)*g_2 has coefficients [..., 0, -3, -7, -12, -14, -9, -4, -1] and h_2(1) = -25 < 0. Also verified: h_3 for d=4 has negatives starting at degree 16; h_2 for d=7 c=(3,2,2) has negatives starting at degree 23. This is NOT a precision artifact -- these are exact polynomial computations. (Agent A.)

- **CONFIRMED: Q_2 for d=7, c=(3,2,2) is nonneg** with all 22 nonzero coefficients positive, Q_2(1) = 121. Earlier negative reports were truncation artifacts from insufficient enumeration bounds. (Agent A.)

- **CONFIRMED: Universal determinant det(I - M(x)) = -(x^3 - 1)** for d=4 (15x15 matrix) and d=7 (36x36 matrix). The kernel at x=1 is the all-ones vector. (Agent A, consistent with Seed 6.)

- **FOUND: Matrix product formula.** F_n = prod_{k=1}^n (I - M(q^k))^{-1} * v_0, so P_n = (q^3;q^3)_n * F_n comes from adjugate matrix products. Positivity of P_n (Kursungoz) corresponds to positivity of these adjugate products. (Agent A.)

- **FOUND: Warnaar's A_2 invariance identity** (from RAG). This is a manifestly positive multisum for the bounded GF, proved for all n_0. Used by Warnaar for k=1,2 positivity proofs. Extension to general k is the open problem. (Agent A, from RAG corpus.)

- **FOUND: d=2 trivial case.** Q_n = q^{n(n+a)} (a monomial) for profiles (a+1, 1-a, 0) at d=2. Positivity is immediate. (Agent A.)

### YELLOW (computationally verified, not proved)

- **P_n to Q_n relationship via Abel summation is algebraically correct** but has mixed-sign differences. The formula Q_n = P_n/(q^3;q^3)_n + sum (a_m - a_{m+1}) P_m/(q^3;q^3)_m is valid but does not directly prove positivity. (Agent A.)

---

## 3. What Failed and Why

### Failure 1: KR Crystal Tensor Products (Path B from Layer 3)

**What was attempted:** Compute B^{1,d}^{tensor n} for A_2^(1) with energy grading. Extract the weight-(c_0,c_1,c_2) component and compare to Q_n(q).

**Where it broke:** The energy-graded weight space has the wrong evaluation at q=1. For d=4, n=2, profile (2,1,1): KR gives 9, but Q_2(1) = 16.

**Why it broke:** The connection between KR crystals and cylindric partitions goes through Tingley's bijection between CPPs and crystal bases, but this bijection relates CPPs to V_Lambda tensor F (irreducible times Fock space), not directly to Q_n. The extraction of Q_n from F_c involves (zq;q)_inf which has no obvious crystal counterpart.

**Is this instructive?** YES, critically. It rules out the simplest version of Path B from Layer 3. The representation-theoretic connection exists (Tingley's work confirms it) but is more indirect: Q_n is NOT a single weight space of a KR tensor product. Any crystal-based approach must account for the (zq;q)_inf factor, which performs an alternating-sign extraction.

### Failure 2: Abel Summation from P_n to Q_n

**What was attempted:** Express Q_n as a positive combination of Kursungoz's P_m values (which are proved nonneg).

**Where it broke:** The Abel summation formula has coefficients a_m - a_{m+1} that alternate in sign.

**Why it broke:** The q-binomial transform that relates P_n to Q_n (via (zq;q)_inf = sum (-z)^k q^{k(k+1)/2} / (q;q)_k) has intrinsically alternating signs. No rearrangement of the Abel sum removes this alternation.

**Is this instructive?** PARTIALLY. It rules out a "reduction to Kursungoz" strategy via straightforward algebraic manipulation. However, a more sophisticated reduction (e.g., involving the A_2 invariance identity structure) might still work.

### Failure 3: h_m >= 0 Tower (Path A from Layer 3)

**What was attempted:** Verify h_m = (q;q)_m * g_m >= 0 as the base case for the D_k^m tower.

**Where it broke:** h_m has negative coefficients for ALL m >= 2, even when d not-equiv 0 mod 3.

**Why it broke:** The Layer 3 synthesis claimed "D_k^m >= 0 verified for 87+ entries" but those D_k^m values were power series truncated at finite precision, not the polynomial h_m = (q;q)_m * g_m. The D_k^m power series CAN have nonneg coefficients to any finite truncation order while the polynomial (q;q)_m * g_m has negative coefficients. The distinction is: g_m is a power series with eventually-periodic coefficients, and truncating it before the periodic tail stabilizes gives a false impression of nonnegativity.

**Is this instructive?** YES, CRITICALLY. **This invalidates Path A as described in Layer 3.** The "algebraic/inductive" proof path (prove h_m >= 0 then propagate via ISP) is dead for m >= 2 because the base case is FALSE. Any tower-based approach needs a fundamentally different decomposition -- either different base objects (not h_m) or a different tower structure.

---

## 4. Broken Assumptions

1. **"h_m >= 0 for m >= 2 when d not-equiv 0 mod 3" (from Layer 3 synthesis, Path A bottleneck).** FALSE. h_m = (q;q)_m * g_m has negative coefficients for m >= 2 for ALL profiles tested, including d=4 and d=7. h_2(1) = -25 for d=4 c=(2,1,1). The Layer 3 "87+ entries of D_k^m >= 0" were power series truncations, not polynomial evaluations. **Discovered by Agent A.**

2. **"KR crystal tensor product weight spaces equal Q_n under energy grading" (from Layer 3, Path B recommendation).** FALSE. For d=4, n=2: KR weight space evaluates to 9 at q=1, Q_2(1) = 16. The connection is more indirect. **Discovered by Agent A.**

3. **"The D_k^m tower approach with base case h_m gives a viable proof strategy" (from Layer 3, Connection C).** FALSE for m >= 2. The ISP propagation theorem is still valid as a formal statement, but it propagates from a base case that does not hold. The tower structure may still be useful with a DIFFERENT base case, but h_m is not it. **Discovered by Agent A.**

---

## 5. Recommendations for Agent B

### Pursue (Priority Order)

1. **PRIORITY 1: Warnaar's A_2 invariance identity.** This is the most promising direction Agent A identified but did not complete. The identity
   sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n][n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
   gives a manifestly positive multisum for the bounded GF. Warnaar used it to prove positivity for k=1 and k=2. The specific question: can you express [z^n]((zq;q)_inf * F_c(z,q)) as a positive combination using this identity? The two-variable structure (z, w) might absorb the alternating signs from (zq;q)_inf. Use the RAG corpus to find Warnaar's original proofs for k=1,2 and understand exactly how he extracted positivity from this identity.

2. **PRIORITY 2: Matrix product / adjugate combinatorics.** Agent A found F_n = prod_{k=1}^n (I - M(q^k))^{-1} * v_0, where det(I - M(q^k)) = 1 - q^{3k}. So P_n = (q^3;q^3)_n * F_n comes from products of adjugate matrices. If the adjugate matrices have a combinatorial interpretation (non-intersecting lattice paths, Lindstrom-Gessel-Viennot), this could yield a bijective proof of P_n >= 0 that might extend to Q_n. Check whether adj(I - M(q^k)) has nonneg entries.

3. **PRIORITY 3: Transfer matrix spectral decomposition.** Agent A noted that M has eigenvalues {1, omega, omega^2} and proposed decomposing g_m into eigencomponents, but did not attempt this computationally. For d not-equiv 0 mod 3, the omega-eigenspaces may cancel in Q_n. Compute the spectral projections P_1, P_omega, P_{omega^2} of M explicitly for small d and check how Q_n relates to the eigenvalue-1 component of g_m.

### What NOT to pursue

4. **Do NOT pursue h_m >= 0 for m >= 2.** This is FALSE. The D_k^m tower with base case h_m is dead.

5. **Do NOT pursue direct KR tensor product matching** (simple weight space extraction). The evaluations don't match. If pursuing a representation-theoretic angle, look instead at Tingley's V_Lambda tensor F decomposition or the Schilling-Tingley energy=Demazure grading result (found by Agent A in RAG query 6).

6. **Do NOT pursue Abel summation P_n -> Q_n** via straightforward algebraic rearrangement. The mixed-sign differences are structural.

### Specific Computations That Would Help

- Compute adj(I - M(q)) for d=4 (15x15 matrix) and check whether entries are polynomials in q with nonneg coefficients.
- For Warnaar's identity: compute Phi_{n,m} explicitly for small n_0, m_0 and check what [z^n] of the resulting multisum looks like. The RAG corpus has the Warnaar paper -- find the k=1 and k=2 proofs and trace the argument.
- Compute the spectral projections of M for d=4 and decompose g_m(q) = g_m^{(1)}(q) + g_m^{(omega)}(q) + g_m^{(omega^2)}(q). Check whether (q;q)_n * g_n^{(1)} has nonneg coefficients.

---

## Summary of the State of Play After Agent A

### What is proved (carried forward from Layer 3)
- Q_1 >= 0 for d not-equiv 0 mod 3 (injection lemma)
- g_m >= q * g_{m-1} for all m, d, profiles
- h_m < 0 for d equiv 0 mod 3 (mod-3 mechanism explained)
- det(I - A(x)) = -(x^3 - 1) universally

### What Agent A added
- h_m < 0 for m >= 2 even when d NOT equiv 0 mod 3 (kills Path A for m >= 2)
- KR tensor product weight spaces != Q_n (constrains Path B)
- Warnaar A_2 invariance identity identified as most promising new direction
- Matrix product formula F_n = prod (I - M(q^k))^{-1} * v_0 established
- d=2 trivial case: Q_n is a monomial

### The surviving proof paths
- **Path A is dead** for m >= 2 (base case h_m >= 0 is false).
- **Path B (representation-theoretic) is wounded** -- simple KR matching fails, but Tingley's work and the Schilling-Tingley energy=Demazure result suggest a more sophisticated connection exists.
- **Path C (NEW: Warnaar A_2 invariance identity)** is the most promising. This is a proved identity giving manifestly positive multisums. Warnaar himself used it for k=1,2. The challenge is extending to general k, which requires understanding how the (zq;q)_inf extraction interacts with the two-variable multisum structure.
- **Path D (NEW: spectral decomposition)** is untested. Decompose the transfer matrix into eigencomponents and analyze the eigenvalue-1 projection. Could give a structural explanation of why Q_n >= 0 when the cube-root-of-unity eigenspaces cancel.

### The core insight from Agent A
All three of Agent A's failed approaches share a common diagnosis: **the alternating signs from (zq;q)_inf are unavoidable in any local decomposition of Q_n**. The cancellation that produces nonnegativity is GLOBAL, not local. A successful proof must either (a) find a completely different combinatorial interpretation that avoids (zq;q)_inf, or (b) use a global identity (like the A_2 invariance identity) that handles the cancellation structurally.
