# Layer 2 Synthesis — Round 2 (2026-07-04)

Input for Layer 3 agents. Synthesizes 8 parallel Layer 2 agents (Seeds 1-8) working on Warnaar's positivity conjecture for Q_{n,c}(q). This layer produced HEAVY CONVERGENCE: Seeds 2, 3, 4 independently found the same reduction (the H-tower); Seeds 1 and 6 independently proved d=2; Seeds 3 and 4 independently found the Rogers-Ramanujan polynomials at d=2. Section 5 maps the convergences precisely. Section headers match synthesis-layer1.md.

**Standing notation** (fix this for Layer 3 — Layer 2 had a notational collision, see Conflict C1):
- F_{c,m} = GF of cylindric partitions of profile c with max part AT MOST m.
- g_m = F_{c,m} - F_{c,m-1} (max part EXACTLY m).
- h_m = (q^ell;q^ell)_m * g_m, ell = gcd(d,3). [Layer-1 core bottleneck object]
- **H_{c,m} := (q;q)_m * F_{c,m}** (Seed 3's H = Seed 4's tower vector = Seed 2's P in the ell=1 case). NOT equal to h_m. Exact relation: h_m = H_m - (1-q^m) H_{m-1} = (H_m - H_{m-1}) + q^m H_{m-1}.
- G_c(z) := (zq;q)_inf * F_c(z,q) (Seed 1's G = Seed 6's G = Warnaar's positive-form target; FERM in Conjecture 2). Q_{n,c} = (q^ell;q^ell)_n * [z^n] G_c(z).
- EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1).
- rho / sigma = cyclic rotation of profiles; K = (d+1)(d+2)/6 = number of C_3-orbits (gcd(d,3)=1).

Formal writeups exist in 2026-07-04/proofs/ for Seeds 1, 2, 3, 4, 6, 7, 8 (prove-seedN-layer2.tex, all compiled to PDF). No writeup for Seed 5 (its GREEN content is literature + verification).

---

## 1. What Was Tried

**Seed 1 (d=2 closed form).** Complete, referee-checked proof that Q_n = q^{n^2} for the C_3-orbit of (1,1,0) and Q_n = q^{n(n+1)} for the orbit of (2,0,0) (d=2, modulus 5 = Rogers-Ramanujan). Method: the **G-CW Lemma** — for ANY r, d, c, the substitution G_c(y) = (yq;q)_inf F_c(y,q) turns the Corteel-Welsh system into G_c(y) = sum_{J} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|}), absorbing the infinite alternating product into FINITE polynomial coefficients. For d=2, elimination yields the Rogers-Ramanujan q-difference equation G(y) = G(yq) + yq G(yq^2) with manifestly nonneg coefficients; uniqueness gives [y^n]G = q^{n^2}/(q;q)_n. Verified n <= 10 at PREC 900. Note in notes/seed1-layer2-GCW-lemma.md.

**Seed 2 (h_m via orbit structure).** Derived the one-level identity (1+q^m+q^{2m}) h_m(c) = sum_{c' != c} q^{m*EMD(c,c')} H_{m-1}(c') + q^{3m} H_{m-1}(c). Two theorems: (i) **h_m >= 0 for 3|d, COMPLETE PROOF** (one line from the Adjugate Monomial Theorem — the Phi_3 division never occurs for ell=3); (ii) the **orbit-product formula**: h_m(c) = sum over orbit sequences (O_{m-1},...,O_0) of U^top(q^m) * prod_{j=1}^{m-1} U^{(j)}(q^j), where U = T/(1+x+x^2), T_{c,O}(x) = sum_r x^{EMD(c, sigma^r c')} — an exact denominator-free formula. Found the U-polynomials have {0,+1,-1} alternating coefficients (d <= 14). Killed the strict Orbit Lemma (consecutive EMD triples), per-orbit positivity, Abel/domination chains.

**Seed 3 (H-recursion + Monotonicity Conjecture).** Introduced H_{c,m} = (q;q)_m F_{c,m} and proved the **H-recursion** (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}, with a **polynomiality theorem** (exact division by 1+q^m+q^{2m} via free C_3-orbits + EMD mod-3 rotation shift; fails for 3|d exactly as expected). Key reduction: h_m = (H_m - H_{m-1}) + q^m H_{m-1}, so h_m >= 0 follows from the **Monotonicity Conjecture H_{c,m} >= H_{c,m-1}** (verified exactly d = 2,4,5,7,8,10,11, m <= 5-6, all profiles). Discovered H_{c,m} at d=2 are the classical Rogers-Ramanujan polynomials sum_j q^{j^2+aj} [m,j]_q, and proposed the **Bounded Fermionic Form Conjecture**: every H_{c,m} is a bounded A_2 Andrews-Gordon polynomial with all m-dependence in a single [m,n_1]_q factor (matched: d=2 all orbits, 3/5 orbits at d=4, 4/7 at d=5). Also the **Q-transform**: Q_n = sum_{m<=n} (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m}. Extended h_m >= 0 verification to d=13,14 exactly (no truncation).

**Seed 4 (orbit tower + d=2 solved).** Independently built the same reduction as Seeds 2/3 in matrix form: the **Orbit-Tower Reduction Theorem** — for 3 not dividing d, H_m(O_i) = sum_j U_{ij}(q^m) H_{m-1}(O_j) with U_{ij}(x) = (x^{E_0}+x^{E_1}+x^{E_2})/(1+x+x^2) a genuine polynomial matrix (exact division from the two-line mod-3 EMD lemma). Solved d=2 completely: H_m = finite Rogers-Ramanujan polynomials A_m = sum_j q^{j^2+j}[m,j], B_m = sum_j q^{j^2}[m,j], with full hand q-Pascal proofs (identities (i),(ii),(iii)) and a hostile-referee pass. (Notational caveat: Seed 4 calls this object "h_m" — it is H_m; see Conflict C1.) d=4: fermionic forms fit 3 of 5 orbits; 2 orbits resist.

**Seed 5 (d=8 / Uncu S_11).** Major literature strike: **Uncu 2024 PROVED explicit S_11 (Kanade-Russell) series representations for all 15 canonical orbits at d=8** (modulus 11). Implemented them; verified Q_n^{Uncu} == Q_n^{CW} exactly for all 15 orbits, n = 0..6, O(q^430). Extended d=8 positivity verification from n <= 2 to n <= 6 (all 45 profiles, Q_n(1) = 14^n). Warnaar's Conjecture 2 for k=3 is now an EXPLICIT identity FERM_c = (q;q)_inf * S_11(e_{c_2}|e_{c_3}) between two known multisums (verified to z^6). Found a new CDU-style bivariate-positive formula for uncovered orbit (4,3,1). Ansatz scans for the other 9 uncovered orbits: zero hits (3 families, stopped per three-strike rule).

**Seed 6 (CW propagation / R-relations).** Reconstructed the CDU/Warnaar d=5 propagation mechanism and generalized it: the **Substitution Lemma** cancels the negative (1-zq) term in the |I_c|=2 CW equation whenever the substituted profile's R-relation has the right head. Two-family closed-form construction gives the **Propagation Theorem (G-level, all d, r=3)**: EVERY zero-containing profile admits a manifestly positive functional equation G_c(z) = G_{head}(zq) + sum_i zq^i G_{b_i}(zq^{i+1}); hence bivariate G-positivity for all profiles reduces to the ALL-POSITIVE core (c_i >= 1 for all i): 2 orbits at d=5 (exactly Warnaar's hard profiles), 7 at d=8. Q-level inheritance is blocked by a (1-q^{ell*n}) factor; sufficient condition **INJ_c** (Q_n^{head} >= sum_i q^{(i+1)n-1} Q_{n-1}^{b_i}) has a satisfying variant for every zero-containing orbit at every tested d (4,5,6,7,8,10,11) but is unproved. Also independently solved d=2 (R-relations close into a 2-cycle).

**Seed 7 (master recursion / N_n).** Derived and verified the **Master Recursion** Q_{n,c} = (1-q^{ln})/(1-q^{3n}) sum_{c'} q^{n*EMD(c,c')} BR_n(c'), the exact level-n inductive skeleton (BR_n built from Q_{n-1}, Q_{n-2}). Discovered **Numerator Positivity**: N_n := (1+q^n+q^{2n}) Q_n >= 0 (verified n=2 at d=4,5,7 all 72 profiles; n=3 at d=4) — a new intermediate target. Proved the **Preimage EMD Dichotomy Lemma** (Delta in {-2,+1}, at most one -2) and hence the **N_2 Shape Theorem**: ALL negativity in the level-2 numerator is compressed into one negative coefficient per rank-3 profile, in exactly three rigid sandwich shapes (2q-1), (1-q^5+q^6), (1-q). Localized divisibility to one scalar "charge conservation" identity per root. Stuck on the final smoothing inequality and on WHY division by Phi_3 preserves positivity (the same mystery at every level).

**Seed 8 (bracket tower / MASTER).** Built the full two-parameter tower: f_k^{(m)} = (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)} with f_{-1}^{(m)} = g_m; proved **Lemma T1**: D_{k+1}^m = (q;q)_{m-k-1} f_k^{(m)} and **Corollary T2**: Q_n = f_{n-1}^{(n)} — the conjecture IS the k = m-1 boundary of the bracket family. **MASTER conjecture**: (q;q)_j f_k^{(m)} >= 0 for exactly 0 <= j <= m-k-1 (fails at j = m-k) — verified across d=2,4,5,7, k <= 4. Critical structural finding: **the tower induction does NOT close from positivity alone** — level k+1 needs the full monotonized domination from level k. Three injection designs for f_0^{(m)} >= 0 all failed (non-injectivity or non-totality); escalated with the diagnosis that a GLOBAL canonical structure (crystal operators on the chain model, cf. Tingley) is needed. Proved the Divisibility Transfer Lemma and the Slack/Switch lemmas on the chain model.

---

## 2. Partial Results

### GREEN (proved; written up and referee-checkable)

**UPGRADE — Q_n = q^{n^2} (orbit of (1,1,0)) and Q_n = q^{n(n+1)} (orbit of (2,0,0)) for d=2, ALL n.** Layer 1 YELLOW (verified n <= 3) -> GREEN. Two independent proofs: Seed 1 (G-CW + RR functional equation + uniqueness, hostile-referee-passed, proofs/prove-seed1-layer2.tex) and Seed 6 (R-relation 2-cycle, proofs/prove-seed6-layer2.tex Cor 5.1). d=2 of the conjecture is SOLVED outright.

**UPGRADE — h_m >= 0 for 3|d (half the Layer-1 core bottleneck).** Layer 1 YELLOW -> GREEN. Seed 2 Theorem 1: for ell=3, P_m = (q^3;q^3)_m F_{c,m} satisfies the sign-free recursion P_m(c) = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c') (no Phi_3 division ever occurs), so h_m(c) = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c) >= 0 by induction from P_0 = 1. One line from the Adjugate Monomial Theorem (GREEN, Layer 1). Referee note: checked, the algebra is exactly right.

**UPGRADE — h_m >= 0 for d=2, all m (first gcd(d,3)=1 case of the core bottleneck).** Seeds 3 + 4 jointly: H_m at d=2 equals the finite Rogers-Ramanujan polynomials (B_m = sum_j q^{j^2}[m,j]_q for orbit (1,1,0), A_m = sum_j q^{j^2+j}[m,j]_q for orbit (2,0,0)); Seed 4 gave complete hand q-Pascal proofs that (A_m, B_m) solve the orbit tower (identities (i) B_m - B_{m-1} = q^m A_{m-1}, (ii)+(iii) A_m - A_{m-1} = q^{m+1} C_{m-1} with qC_n = B_n - (1-q^{n+1})A_n), plus uniqueness of the tower solution. Monotonicity H_m >= H_{m-1} is manifest from (i),(ii); hence h_m = (H_m - H_{m-1}) + q^m H_{m-1} >= 0. IMPORTANT CORRECTION: Seed 4's theorem statement "h_m = B_m" is wrong as literally written — the object proved equal to B_m is H_m = (q;q)_m F_{c,m} (synthesizer verified numerically: h_1 = 2q, B_1 = 1+q, H_1 = 1+q). The corrected conclusion h_m >= 0 survives via the monotonicity route above. See Conflict C1.

**G-CW Lemma (general r, general d).** (Seed 1.) G_c(y) := (yq;q)_inf F_c(y,q) satisfies G_c(y) = sum over nonempty J subseteq I_c of (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|}). One-line proof: (yq;q)_inf / ((1-yq^s)(yq^{s+1};q)_inf) = (yq;q)_{s-1}. The infinite alternating product is absorbed into finite polynomial coefficients. The entire conjecture is a positivity statement about this system.

**H-recursion + polynomiality theorem (gcd(d,3)=1).** (Seed 3; same content as Seed 4's Orbit-Tower Reduction and the divisibility step of Seed 2's Theorem 2.) (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}, H_{c,0} = 1; the RHS is exactly divisible by 1+q^m+q^{2m} in Z[q] (proof: Lemma R: EMD(rho c', c) == EMD(c',c) + d mod 3; free C_3 orbits; q^{3m} == 1 mod Phi_3(q^m)); hence H_{c,m}, h_{c,m} in Z[q] and computable EXACTLY (no truncation — the Layer-1 precision rule is moot on this route). Fails for 3|d (fixed orbit), consistent with h_m < 0 there under (q;q)_m.

**Orbit-Tower Reduction Theorem (3 not dividing d).** (Seed 4; matrix form of the above.) H_m(O_i) = sum_j U_{ij}(q^m) H_{m-1}(O_j) on orbit space, U_{ij}(x) = (x^{E_0}+x^{E_1}+x^{E_2})/(1+x+x^2) in Z[x], N = K orbits, H_0 = all-ones. h_m >= 0 (and more) is a question about a FIXED K x K polynomial matrix tower with varying x = q^m. Exact division from the mod-3 EMD lemma: EMD(a,b) == b_0 - a_0 + a_1 - b_1 (mod 3).

**Orbit-product formula for h_m (gcd(d,3)=1).** (Seed 2, Theorem 2 in its .tex.) h_m(c) = sum over orbit sequences (O_{m-1},...,O_0) of U^top(q^m) * prod_{j=1}^{m-1} U^{(j)}(q^j) — the unrolled form of the tower with the top-level diagonal modification (diagonal exponent 0 replaced by 3; equivalently U^top = U_diag(x) - (1-x)). Exact, denominator-free. Verified d=1,2,4,5 and against Seed 8's tables. Corollary: H_m ( = (q;q)_m F_{c,m}) is a polynomial with H_m(1) = K^m.

**Reduction: Monotonicity ==> h_m >= 0.** (Seed 3, trivial algebra.) h_{c,m} = (H_{c,m} - H_{c,m-1}) + q^m H_{c,m-1}, and H >= 0 follows from monotonicity by induction (H_0 = 1). Equivalent form of the monotonicity bracket (synthesizer, checked): H_m - H_{m-1} = (q;q)_{m-1} * (g_m - q^m F_{c,m}).

**Q-transform.** (Seed 3.) Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m} — Q_n is the inverse q-binomial transform of the H-sequence. (Standard Gauss inversion applied to H_m; verified numerically against the D-tower.)

**Propagation Theorem (G-level, all d, r=3).** (Seed 6.) Every zero-containing profile admits an explicit manifestly positive R-relation G_c(z) = G_{head(c)}(zq) + sum_{i=1}^L z q^i G_{b_i(c)}(zq^{i+1}), built by the Substitution Lemma + two-family closed forms (Family A: (a,0,b); Family B: (a,b,0)); heads terminate, tails are (x,1,y)-type profiles. Hence bivariate positivity of G_c for ALL profiles reduces to the all-positive core (c_0,c_1,c_2 >= 1). Reproduces CDU eqs 3.17-3.19 at d=5 exactly; core at d=5 = {(3,1,1),(2,2,1)} = precisely Warnaar's computer-algebra profiles; core at d=8 = 7 orbits. Well-foundedness formalized in the .tex.

**Exact Q-level R-identity.** (Seed 6.) For every zero-containing c: Q_n^c = q^n Q_n^{head(c)} + (1 - q^{ell*n}) * sum_i q^{(i+1)n-1} Q_{n-1}^{b_i}. (Positivity inheritance NOT automatic — see YELLOW INJ.)

**Master Recursion.** (Seed 7.) Q_{n,c} = (1-q^{ln})/(1-q^{3n}) * sum_{c'} q^{n*EMD(c,c')} * BR_n(c') with BR_n(c') = q^{2n-1} sum_{|J|=2} Q_{n-1,c'(J)} + [rank3(c')] * ( -(q^{3n-2}+q^{3n-1}) Q_{n-1,c'} + q^{3n-3}(1-q^{l(n-1)}) Q_{n-2,c'} ). Pure algebra from GREEN inputs; independently verified (Neumann iteration, no adjugate) d=4,5,7, n <= 3. The exact level-n inductive skeleton, with fully unfolded n=2 double sum.

**Preimage EMD Dichotomy Lemma + N_2 Shape Theorem.** (Seed 7, proofs in prove-seed7-layer2.tex.) For each 2-shift preimage c'' of c': Delta = EMD(c,c'') - EMD(c,c') in {-2,+1}, and at most ONE of the three preimages has Delta = -2; rank-3 profiles have exactly 3 preimages, rank-2 exactly 1, rank-1 none. Consequence: N_2(c) decomposes with ALL negativity compressed into one negative coefficient per rank-3 c', in three rigid shapes (2q-1), (1-q^5+q^6), (1-q), weighted by q^{2*EMD} Q_1(c').

**Level-n equidistribution reduction.** (Seed 7.) Divisibility of N_n by 1+q^n+q^{2n} factors through ONE scalar identity per root, because EMD(c,c') mod 3 = delta(c') - delta(c) splits the c-dependence (delta(c) = (c_0-c_1) mod 3). Generalizes the Layer-1 EMD Equidistribution Theorem to every level.

**Bracket tower algebra.** (Seed 8, prove-seed8-layer2.tex.) Lemma T1: D_{k+1}^m = (q;q)_{m-k-1} f_k^{(m)} with f_k^{(m)} = (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)}, f_{-1}^{(m)} = g_m. Corollary T2: Q_n = f_{n-1}^{(n)}. Closed form: f_k^{(m)} = sum_{i=0}^{k+1} (-1)^i q^{i(i+1)/2} [k+1,i]_q (q^{m-k};q)_{k+1-i} g_{m-i}. Divisibility Transfer Lemma: (1-q^a)/(1-q^b) >= 0 iff b | a, with the matching-criterion corollary. Slack/Switch lemmas on the chain model S = {a in Z_{>=0}^3 : a_i <= a_{i-1} + c_i cyclically}.

**Uncu 2024 S_11 representations at d=8 (literature GREEN).** (Seed 5.) Uncu proved H_c(z,q) = (zq;q)_inf F_c(z,q)/(q;q)_inf equals explicit Z[q,z]-combinations of Kanade-Russell S_11(z; rho|sigma) 6-fold sums for ALL 15 canonical orbits at d=8. Seed 5's implementation reproduces Q_n^CW exactly for all 15 orbits, n = 0..6. Every Q_{n,c} at d=8 is now (q;q)_n (q;q)_inf [z^n] of a PROVED explicit series — no unknown functions remain at d=8. (The combinations are SIGNED, so positivity is not manifest.)

**Carried forward from earlier layers (still GREEN and load-bearing):** Adjugate Monomial Theorem adj(I-A(x))[c,c'] = x^{EMD(c,c')} (Seed 4 L1); det(I-A(x)) = -(x^3-1); adjugate inversion; explicit Q_1 formula + Q_1 >= 0; EMD Equidistribution Theorem; injection lemma g_m >= q g_{m-1}; Q_n = D_n^n; P_n EMD path formula; vacuity of specialized key decomposition; cyclic invariance of F_c.

### YELLOW (computationally verified, no proof)

**Monotonicity Conjecture: H_{c,m} >= H_{c,m-1} coefficientwise, gcd(d,3)=1.** (Seed 3; the renamed successor to "h_m >= 0" as the minimal bottleneck for h-positivity.) Verified EXACTLY (Z[q], no truncation) for d = 2,4,5,7,8,10,11, all profiles, m <= 5-6. Implies h_m >= 0 via the GREEN reduction. Equivalent bracket form: (q;q)_{m-1} (g_m - q^m F_{c,m}) >= 0.

**Bounded Fermionic Form Conjecture.** (Seeds 3, 4 independently.) Each H_{c,m} is a bounded A_2 Andrews-Gordon polynomial with all m-dependence in a single [m, n_1]_q factor. Warnaar explicitly lists finding these bounded analogues as an OPEN problem (his paper, chunk_102). Status of fits: d=2 both orbits PROVED (GREEN above); d=4: 3 of 5 orbits match exactly (m <= 5-6); d=5: 4 of 7 orbits (m <= 5). Missing orbits resist single- and two-term ansaetze (see Conflict C2 for which orbits). Consequences if true: monotonicity by q-Pascal (hence h_m >= 0), AND — via the Q-transform + Gauss inversion — Q_n = a_n directly (see Connections, item (g)): the single strongest conjecture on the board.

**MASTER conjecture (two-parameter exact monotonicity).** (Seed 8.) (q;q)_j * f_k^{(m)} >= 0 for all k >= -1, m >= k+1, 0 <= j <= m-k-1, EXACT (fails at j = m-k). Verified d=2 (m<=8, k<=4), d=4 (m<=7, all orbits, k<=4), d=5 (m<=6, k<=4), d=7 (m<=5, k<=3). Contains: h_m >= 0 (k=-1, j=m), f_0^{(m)} >= 0 (k=0, j=0), D_{k+1}^m >= 0 (top j), Q_m >= 0 (k=m-1, j=0). Unifying form: g_m is exactly m-fold q-monotone, stably under the bracket recursion.

**Numerator Positivity: N_n := (1+q^n+q^{2n}) Q_n >= 0.** (Seed 7.) Verified n=2 (d=4,5,7, all 72 profiles), n=3 (d=4; note Phi_9 is irreducible so no division ladder — positivity persists anyway). Division-order finding: N_2/(1-q+q^2) = (1+q+q^2)Q_2 >= 0 everywhere, but N_2/(1+q+q^2) has negatives for EVERY profile — positivity enters through Phi_6 first, Phi_3 last.

**INJ (Q-level cross-profile injection).** (Seed 6.) For every zero-containing orbit at d = 4,5,6,7,8,10,11 there EXISTS an R-relation variant with Q_n^{head} >= sum_i q^{(i+1)n-1} Q_{n-1}^{b_i} (n <= 4-5). The long-tail variant at (d-1,1,0)-type profiles always fails at the d-INDEPENDENT exponents q^4, q^8, q^14, q^21; the short-tail variant always repairs it. INJ + G-level propagation would give Q-positivity for all zero-containing profiles from the core.

**h_m >= 0 for gcd(d,3)=1, extended.** Now verified EXACTLY (no truncation) up to d=13 (105 profiles) and d=14 (120 profiles), m <= 6 (Seed 3), on top of the Layer-1 range.

**U-polynomial structure.** (Seed 2.) Every U = T/(1+x+x^2) has coefficients in {0,+1,-1}, alternating signs among nonzero entries, first/last = +1 (exhaustive d <= 14). Each U(1) = 1, so the orbit-product sum has exactly K^m surviving monomials at q=1.

**Warnaar Conjecture 2 for k=3 == explicit S_11 identity.** (Seed 5.) FERM_c(z,q) = (q;q)_inf * S_11(e_{c_2}|e_{c_3}) for the 5 covered orbits at d=8; verified at z-orders 0..6 to O(q^430). Fermionic Q_n matches Q_n^CW for all 5 covered orbits, n = 1..6 (extends Seed 6 L1's n <= 2).

**Q_n >= 0 at d=8 extended to n <= 6** (all 45 profiles, Q_n(1) = 14^n). (Seed 5.)

**CDU-style formula for uncovered orbit (4,3,1) at d=8.** (Seed 5.) Q_n = F(b_1=1; n) + q^n (1-q^n) F(b_1=1,b_2=1; n-1) in the Warnaar k=3 basis, verified n <= 4; bivariate-positive at the G-level (numerator 1 + zq^{...}).

**Divisibility-matching sufficiency.** (Seed 8.) prod_{a in S}(1-q^a) f_k^{(m)} >= 0 whenever S admits a divisibility matching into {1,...,m-k-1} (provable by Transfer Lemma); 29482 sets tested, 0 violations; matching appears close to (but not exactly) necessary.

### Downgrades / referee notes on claimed GREENs

- **Seed 4's "THEOREM (d=2): h_m(c) = B_m resp. A_m"** — DOWNGRADED AS STATED, corrected and re-admitted as GREEN in the fixed form "H_m = B_m resp. A_m, hence h_m = (H_m - H_{m-1}) + q^m H_{m-1} >= 0" (see Conflict C1). The proof content (q-Pascal identities, uniqueness of the tower solution) is sound and referee-passed.
- **Seed 5's "GREEN" labels** are verification-GREENs (exact polynomial matches), not proofs of positivity. Under the strict rubric: Uncu's formulas = literature GREEN; Seed 5's matches = high-confidence verification (kept YELLOW where they assert positivity or identity of series).
- **Seed 3's Q-transform** "proved by telescoping in the scratch algebra" — the telescoping is not exhibited in the scratch file, but the statement is standard Gauss q-binomial inversion applied to the (GREEN) definition of the D-tower, and it is verified numerically; kept GREEN with this note.
- **Seed 6's Propagation Theorem** relies on well-foundedness of the self-referential tails; the .tex formalizes it (z-shifts strictly increase, prefactors z q^{i+1} strictly decrease n). Accepted GREEN.

---

## 3. What Failed and Why

**Consecutive-orbit-triple positivity ("dream scenario").** (Seeds 2, 3, 4 — all three found the same counterexamples independently.) The rotation-orbit EMD triples {EMD(c, sigma^r c')} are NOT consecutive {e,e+1,e+2} in general (d=2 diagonal already gives {0,2,4}; non-consecutive is the NORM for d >= 5: 540/675 pairs at d=8). The truth is distinctness mod 3 — enough for exact Phi_3 division, not for per-orbit positivity.

**Per-orbit positivity of orbit products.** (Seed 2.) prod_j U^{(j)}(q^j) has negative coefficients for individual orbit sequences (d=4, m=2 counterexamples). Only the TOTAL sum over orbit sequences is nonneg.

**Local absorption / domination schemes for monotonicity.** (Seed 3.) C1 (H_{c(J),m} >= H_{c,m-1} for |J|=1), C1' (all J), C2 (within-level q^m-shifted domination along CW edges): all falsified at m >= 2. The smoothing by (I - A(q^m)^T)^{-1} is genuinely needed; no local scheme works.

**Abel summation / shifted domination on orbit chains.** (Seed 2.) Genuine failures at d=7, m=2; no valid shift exists (interlacing supports).

**Cross-profile Q_1 monotonicity.** (Seed 7, E4.) Q_1(c'(J)) >= q^a Q_1(c') fails for ALL pairs. Dead.

**Per-profile BR_2 >= 0 and per-pair W(c,c') Q_1(c') >= 0.** (Seed 7.) Both fail exactly at rank-3 profiles; N_2-positivity is a global EMD-weighted phenomenon.

**Three injection designs for f_0^{(m)} >= 0.** (Seed 8, escalated.) (1) Greedy least-slack ribbon: total but NOT injective (explicit collision at c=(1,1,1), m=2); (2) claim-based alpha: invertible but NOT total (orphan states for every profile, exhaustive d <= 8); (3) top-level add: circular (reduces to (1-q)g_m >= 0, an instance of the same family). Diagnosis: local box-adding rules lose information or totality; a GLOBAL canonical structure (crystal operators) seems required.

**Tower induction from positivity alone.** (Seed 8.) (q;q)_j f_{k+1}^{(m)} is a DIFFERENCE of two level-k-nonneg terms; its nonnegativity is precisely the level-(k+1) statement. The induction is self-similar and does not close. h_m >= 0 alone does NOT imply Q_n >= 0 (see BA24 — this corrects Layer 1's Path A framing).

**Naive Q-level positivity inheritance through R-relations.** (Seed 6.) The (1-q^{ell n}) factor blocks it; also the long-tail INJ variant genuinely fails (d-independent failure exponents q^4, q^8, q^14, q^21 — unexplained, potentially meaningful).

**Fermionic ansatz scans for missing orbits.** (Seeds 3, 4, 5 — three-strike-stopped in each case.) d=4 missing orbits: single forms with 6 prefactor families, shifted bounds, all two-term combinations, 1000+-candidate pair boxes: NONE. d=8 uncovered orbits: single-term, two-term z-free, CDU z-shift families: only (4,3,1) hit. Structural (not scan) methods needed: Warnaar Thm-3 shifted binomials, S_11 recurrence telescoping, or bounded R-relations.

**Triple-sum mod-8 template at d=4.** (Seed 4.) Matches no d=4 orbit (that template belongs to d=5).

**B^{d,1} column crystals.** (Seed 2.) For A_2^(1), B^{r,s} requires r in {1,2}; "B^{d,1}" does not exist for d > 2. The EMD is now explained without crystals (adjugate/transport). Layer-1 crystal route superseded.

---

## 4. Broken Assumptions

(Continuing from BA19. No reversals of BA1-BA19 this layer; BA2's reversal stands.)

**BA20. "Rotation-orbit EMD triples are consecutive {e, e+1, e+2}."** FALSE (Seeds 2, 3, 4 independently). Correct statement: the three values are distinct mod 3 (equivalently EMD(a, rho b) == EMD(a,b) + d mod 3). Distinctness, not consecutiveness, is what makes the Phi_3 division exact.

**BA21. "Orbit products are individually nonneg (per-orbit positivity)."** FALSE (Seed 2, d=4 m=2). Only the total over orbit sequences is nonneg; compensation across orbits is essential.

**BA22. "Q_1 is profile-monotone along CW edges (Q_1(c'(J)) >= q^a Q_1(c'))."** FALSE for all pairs (Seed 7).

**BA23. "Positivity propagates through R-relations at the Q-level automatically."** FALSE (Seed 6): the (1-q^{ell n}) factor blocks it; needs INJ, and the obvious (long-tail) variant of INJ is genuinely false with d-independent failure pattern.

**BA24. "h_m >= 0 implies Q_n >= 0 via the D_k^m tower" (Layer 1 Path A framing).** OVERSOLD/FALSE as an implication (Seed 8): the tower induction does not close from positivity alone; each level needs the full monotonized domination (MASTER). h_m >= 0 is necessary-flavored, not sufficient. Similarly, the Monotonicity Conjecture alone gives h_m >= 0 but NOT Q_n >= 0.

**BA25. "A local box-adding injection proves f_0^{(m)} >= 0."** FALSE in three incarnations (Seed 8). A global canonical structure (crystal-type operators on the chain model) appears necessary.

**BA26 (notational hazard, functioned as a broken assumption). "The tower object H_m = (q;q)_m F_{c,m} is h_m."** FALSE (Seed 4's conflation; caught in synthesis). h_1 = 2q vs H_1 = 1+q at d=2. All Layer-3 agents must use the Standing Notation above.

**BA27. "Division by Phi_3(q^n) and Phi_6(q^n) preserve positivity symmetrically."** FALSE (Seed 7): N_2/Phi_6 >= 0 everywhere but N_2/Phi_3 fails for every profile; order matters, and the Phi_3-last step is the recurring unexplained mechanism.

**BA28. "Warnaar's proved d=5 case propagates positivity through the raw alternating CW system."** FALSE as reconstruction (Seed 6): Warnaar/CDU used uniqueness + explicit guessed formulas for a hard core; the raw system never transmits positivity. The honest general mechanism is the R-relation recombination, which reaches only zero-containing profiles.

---

## 5. Connections (convergence map)

### (a) Seeds 2, 3, 4: the SAME reduction — adjudicated: YES, literally identical up to notation

All three seeds independently derived one object, the **H-tower**:
- Seed 3 (scalar form): (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}, exact division by Phi_3(q^m) via Lemma R + free orbits.
- Seed 4 (matrix form): H_m = U(q^m) H_{m-1} on orbit space, U_{ij}(x) = (x^{E_0}+x^{E_1}+x^{E_2})/(1+x+x^2); exact division via the mod-3 EMD lemma. Seed 4's H (which it mislabels h) = (q;q)_m F_{c,m} = Seed 3's H exactly (synthesizer verified: both equal the RR polynomials at d=2).
- Seed 2 (unrolled form): the orbit-product formula is the m-fold iteration of Seed 4's tower from H_0 = 1, with the top level modified (U^top = U_diag - (1-x)) to convert H_m into h_m; the modification is precisely h_m = H_m - (1-q^m) H_{m-1}.
- Seed 2's Lemma 3 = Seed 3's Lemma R = Seed 4's mod-3 EMD lemma (proved three times).
Layer 3 should treat this as ONE framework with three lenses: recursion (proofs by induction), matrix (spectral/cone arguments), product (involution/combinatorial arguments).

**Seed 8's MASTER vs Seed 3's Monotonicity — adjudicated: NOT the same statement.** The conjectured equivalence fails on the algebra. H_m - H_{m-1} = (q;q)_{m-1} * [(1-q^m) g_m - q^m F_{c,m-1}] = (q;q)_{m-1} * (g_m - q^m F_{c,m}), whereas f_0^{(m)} = (1-q^m) g_m - q g_{m-1}. The brackets differ in the subtracted term: q^m * F_{c,m-1} (CUMULATIVE, all lower levels, weight m) vs q * g_{m-1} (one level below, weight 1). Neither statement obviously implies the other; both are verified YELLOW; both target h_m >= 0-adjacent cells but sit in different families (Monotonicity is not a cell of MASTER). ORCHESTRATOR: a verifier should test the cross-implications numerically (does MASTER imply Monotonicity? does Monotonicity plus injection lemma imply f_0 >= 0?) before Layer 3 assumes independence.

### (b) Seeds 3 and 4 at d=2: SAME discovery, jointly GREEN

Both independently found H_m(d=2) = finite Rogers-Ramanujan polynomials sum_j q^{j^2}[m,j]_q and sum_j q^{j^2+j}[m,j]_q. Seed 3 found them by fitting + q-Pascal monotonicity; Seed 4 proved they solve the tower (identities (i)-(iii)) with a referee pass. Combined: the d=2 case of the core bottleneck is doubly proved. This also confirms the tower has genuinely fermionic solutions — the template for general d.

### (c) Seeds 1 and 6 at d=2: SAME theorem, two proofs

Q_n = q^{n^2} / q^{n(n+1)} at d=2 proved via G-CW + RR functional equation (Seed 1) and via R-relation 2-cycle closure (Seed 6). These are essentially the same computation: Seed 6's R-relations ARE the sign-recombined G-CW system (see (d)); the 2-cycle is Seed 1's eliminated equation pair (CW-a)/(CW-b). Fully consistent; GREEN.

### (d) Seed 1's G-CW Lemma vs Seed 6's R-relations — adjudicated: same object, complementary layers

Same object: both work with G_c(z) = (zq;q)_inf F_c(z,q). The G-CW Lemma is the GENERAL transform (all profiles, all r, d; signed, with finite polynomial coefficients (zq;q)_{|J|-1}). Seed 6's R-relations are the manifestly POSITIVE recombinations of that system, which the Substitution Lemma produces for every zero-containing profile. G-CW = the frame; Propagation Theorem = the theorem inside the frame; the all-positive core = where recombination has no leverage (the |J|=3 self-term (1-zq)(1-zq^2) G_c(zq^3) cannot be cancelled by substitution). The d=2 collapse (Seed 1) is the degenerate case where the core is empty.

### (e) Seed 5 (Uncu S_11) x Seed 6 (core reduction) at d=8 — intersected

Seed 6's core (7 all-positive orbits): (6,1,1), (5,1,2), (4,1,3), (4,3,1), (5,2,1), (4,2,2), (3,3,2).
Warnaar-Conjecture-2-covered orbits (5): (8,0,0), (7,1,0), (6,2,0), (5,3,0) — all zero-containing — and (3,3,2) (balanced, IN the core).
Status per core orbit:
- (3,3,2): conjectural manifestly positive FERM (Conjecture 2), verified n <= 6; Uncu-proved SIGNED S_11 form.
- (4,3,1): Seed 5's new CDU-style bivariate-positive candidate (YELLOW, n <= 4); Uncu-proved signed form.
- (6,1,1), (5,1,2), (4,1,3), (5,2,1), (4,2,2): Uncu-proved SIGNED S_11 forms only; NO positive form known. These 5 orbits are the exact d=8 frontier. (Seed 6 notes Kanade-Russell Conjecture 5.1 may cover the (x,1,y)-types (6,1,1),(5,1,2),(4,1,3) — unchecked.)
What exactly remains for d=8 positivity: (1) manifestly positive G-forms for the 5 frontier core orbits (+ prove the (4,3,1) and (3,3,2) candidates); then G-positivity for ALL 15 orbits follows from the Propagation Theorem (GREEN); (2) the Q-level extraction step: even proved positive G-forms with z-monomial numerators give Q_n = A_n + (1-q^n) q^{...} B_{n-1} (not manifestly positive) — so either z-free-numerator forms or INJ (YELLOW) is additionally needed. Note the four zero-containing covered orbits are redundant given propagation — the marginal value of Conjecture 2 at d=8 is exactly its balanced case (3,3,2).

### (f) The recurring wall — adjudicated: overlapping but NOT one obstruction

Three walls were hit: (i) missing bounded fermionic H-forms (Seed 3/4: orbits of type (0,2,2) etc. at d=4; three orbits at d=5); (ii) uncovered/unformed G-level orbits at d=8 (Seed 5: the core); (iii) Seed 6's all-positive core. Walls (ii) and (iii) coincide (modulo the extraction caveat). Wall (i) does NOT coincide with them: the d=4 H-form-missing orbits CONTAIN zeros (so they are propagation-reachable at the G-level), while d=4's only all-positive orbit (1,1,2) HAS a fermionic H-form. Common thread: everything outside the Warnaar-Conjecture-2 family (c_2 = 0 up to rotation, plus balanced) lacks closed positive forms at every level — but the bounded (H) and unbounded (G) hardness patterns differ. ACTIONABLE consequence: the two mechanisms are complementary — a bounded analogue of the R-relations (extract the H-level consequence of R_c) might manufacture the missing H-forms at d=4/d=5 from the ones already found, exactly as R-relations manufacture G-positivity for zero-containing profiles. No seed has tried this.

### (g) NEW synthesis-level observation: Bounded Fermionic Form ==> Q_n >= 0 DIRECTLY (bypassing the tower)

Combining Seed 3's Q-transform with Gauss q-binomial inversion: if H_{c,m} = sum_{n_1} [m, n_1]_q * a_{n_1}(q) with a_{n_1} independent of m (exactly the Bounded Fermionic Form shape, a_{n_1} = manifestly positive inner multisum), then by the inversion pair (b_n = sum_m [n,m] a_m <=> a_n = sum_m (-1)^{n-m} q^{binom(n-m,2)} [n,m] b_m):

    Q_n = sum_m (-1)^{n-m} q^{binom(n-m,2)} [n,m]_q H_{c,m} = a_n(q)  — manifestly nonneg.

Sanity check at d=2: a_j = q^{j^2} gives Q_n = q^{n^2}. Correct (GREEN). This means the Bounded Fermionic Form Conjecture implies BOTH h_m >= 0 (via q-Pascal monotonicity) AND Q_n >= 0 with an explicit positive multisum (recovering exactly Warnaar's n_1 = n multisum shape, i.e. the bounded conjecture implies Conjecture 2's consequence at the Q-level). It is the single conjecture from which everything follows, and it is finitely checkable orbit by orbit. STATUS: the inversion step is standard algebra but was not written by any seed — a Layer 3 agent must verify and write it (half a page). Also note: for the d=4 orbits already matched, this instantly predicts explicit positive Q_n formulas — testable against Seed 5/7 data TODAY.

### (h) The Phi_3-division mystery is one mystery

Seed 7's "why is N_n/(1+q^n+q^{2n}) >= 0" (Q-level) and Seeds 2/3/4's "why does dividing the positive EMD-weighted sum by Phi_3(q^m) preserve positivity" (H-level) are the same phenomenon at different levels of the same adjugate inversion. Seed 7's division-ladder finding (Phi_6 first, Phi_3 last; Phi_9 at n=3 needs no ladder) and Seed 2's alternating {0,+1,-1} U-structure are the two sharpest structural facts about it.

### Conflicts requiring adjudication (for the orchestrator's verifier)

**C1 (RESOLVED IN SYNTHESIS, verify formally).** Seed 4's d=2 theorem statement "h_m = B_m / A_m" conflicts with the standing definition of h_m. Synthesizer's numerical check: at d=2, (1,1,0): h_1 = 2q, but B_1 = 1+q = H_1; h_2 = [0,0,2,1,1] vs B_2 = [1,1,1,0,1] = H_2. Resolution: Seed 4 proved H_m = B_m/A_m; the corrected h_m >= 0 conclusion follows via h_m = (H_m - H_{m-1}) + q^m H_{m-1} and manifest monotonicity. Seed 4's .tex should be checked/amended before citing. Related: Seed 3 already flagged (L2 Script 7) that Seed 4's Layer-1 recorded Q_2 at d=4,(2,1,1) differs from the D-tower value by (1+q)(1-q^4) — likely the same normalization slip. A verifier should sweep Seed 4's numerology once.

**C2 (OPEN).** Seeds 3 and 4 disagree on WHICH two d=4 orbits lack fermionic H-forms. Seed 3: matched (2,1,1), (4,0,0), (1,1,2)-type; missing (0,2,2), (0,3,1). Seed 4: matched (1,1,2), (0,0,4), (0,3,1); missing (0,1,3), (0,2,2). Note (0,3,1) and (0,1,3) are DIFFERENT C_3-orbits (reversal-related, not rotation-related), and Q_n is known NOT reversal-invariant. Both agree (0,2,2) is missing and that 3/5 match. Possible causes: different orbit-labeling conventions (Seed 3 uses EMD(c',c) source->target; Seed 4 EMD(a,b)), or Seed 4's grid contained a fit Seed 3's missed. Since Seed 4 exhibits a concrete fit for (0,3,1), existence wins IF the labels agree — verifier should recompute H_m for all 5 orbits under the standing notation and re-run both fit lists. This matters: it determines which 2 orbits Layer 3's d=4 mission must crack.

**C3 (MINOR).** Seed 2 states the d=4 missing orbits "are exactly the profiles outside Warnaar's Conjecture 2 family" and Seed 4 says the same of its pair — under C2's uncertainty, this claim inherits the ambiguity. Do not build on it until C2 is settled.

---

## 6. Recommendations for Layer 3

### Orchestrator recommendation: CONSOLIDATE

Layer 2's convergence means 8 independent seeds would now waste effort re-deriving one another. The board has ONE central conjecture (Bounded Fermionic Form), one mechanical literature-anchored strike (S_11/d=8), one verification debt (C1/C2, cross-implications), and a small number of independent flanks. Recommend **6 agents** (missions 1-6 below); missions 7-8 are listed in case the orchestrator keeps 8. Missions 1 and 2 are the priority pair: either one alone, completed for d=4, would make d=4 the first case proved by this project beyond Warnaar's own (note Warnaar proved d in {2,4,5}; our independent d=2 proof is a method validation — the project's genuinely new territory starts at d=7/8, but the d=4 fermionic program is the uniform-method test bed).

**Mission 1 (TOP: bounded fermionic forms — prove the mechanism, finish d=4/d=5).** (a) Write the half-page Gauss-inversion proof of "Bounded Fermionic Form => Q_n = a_n >= 0" (Connections (g)) — load-bearing for everything. (b) Resolve C2: recompute H_m for all 5 d=4 orbits in standing notation; confirm which forms fit. (c) For the matched orbits, prove the forms satisfy the U-tower by q-Pascal (Seed 4's d=2 template: find the surplus vector C and the identity-(iii) analogue on the 5x5 system). (d) For the missing orbits: derive the H-level consequence of Seed 6's G-level R-relations for those profiles (bounded R-relations, Connections (f)) and solve for their H-forms from the known ones; also try Warnaar Thm-3 shifted binomials [n_i - n_{i+1} + m_{i+1} + delta]. Deliverable: complete uniform-method proof of Q_n >= 0 for d=4 (and the d=5 template), or a precise statement of what blocks the last orbits.

**Mission 2 (Monotonicity Conjecture, direct).** Target: H_{c,m} >= H_{c,m-1}, equivalently (q;q)_{m-1}(g_m - q^m F_{c,m}) >= 0. (a) First test the RAW injection statement g_m >= q^m F_{c,m} coefficientwise (if true, it asks for a weight+m injection "chains of length m, max <= m" -> "chains with max exactly m" — closely related to Seed 8's psi but with a DIFFERENT domain that may fix the totality/injectivity dilemma). (b) If raw fails, characterize how much (q;q)_{m-1}-smoothing is needed. (c) Pursue Seed 8's crystal-operator lead (Tingley) on the chain model S — a crystal raising operator is the canonical global injection all three of Seed 8's designs were missing. (d) Test the cross-implications flagged in Connections (a): MASTER vs Monotonicity, numerically, before assuming independence. Deliverable: proof of Monotonicity (=> h_m >= 0 for all gcd(d,3)=1, closing the Layer-1 bottleneck), or the precise counter-shape.

**Mission 3 (S_11 strike: prove Conjecture 2 for k=3 covered profiles).** Both sides of FERM_c = (q;q)_inf * S_11(e_{c_2}|e_{c_3}) are explicit. Uncu's relation ideal (R1-R4) characterizes the S_11 family; show FERM_c/(q;q)_inf satisfies the same recurrences + initial conditions (q-Zeilberger / Sister Celine, finite and mechanical). Success makes covered-profile positivity at d=8 a THEOREM and proves the first k=3 case of Warnaar's Conjecture 2 — publishable standalone. Extension: Uncu also proved modulus 13 (d=10); the pipeline transfers.

**Mission 4 (d=8 core: positive forms for the 5 frontier orbits).** Per Connections (e): the frontier is (6,1,1), (5,1,2), (4,1,3), (5,2,1), (4,2,2). (a) Check Kanade-Russell Conjecture 5.1 against the (x,1,y)-types. (b) Telescope Uncu's signed differences S_11(rho|sigma) - q S_11(rho'|sigma') using relations R1/R2, starting from Seed 5's (4,3,1) success as template. (c) Drive numerator shapes from the CW equations linking core to covered profiles (not blind scans — three families already exhausted). Also prove Seed 5's (4,3,1) candidate. Deliverable: any new core orbit with a proved positive G-form shrinks the d=8 frontier; all 5 + Mission 3 = bivariate positivity for all of d=8.

**Mission 5 (INJ + Q-level propagation).** Prove INJ for the short-tail variants (Seed 6): Q_n^{head} >= sum_i q^{(i+1)n-1} Q_{n-1}^{b_i}. (a) Decode the d-independent failure exponents q^4, q^8, q^14, q^21 of the long-tail variant (gaps 4,6,7 — find the combinatorial meaning; a clean statistic likely identifies the correcting term). (b) Try interlocking with the h-machinery: the R-identity is a cross-profile recursion in n; the injection lemma g_m >= q g_{m-1} and the Master Recursion (Seed 7) constrain both sides. Success + Mission 4 = full Q-positivity at d=8 for zero-containing profiles from the core.

**Mission 6 (verifier/adjudicator).** (a) Formally settle C1: audit Seed 4's .tex statements and the Layer-1 Q_2 normalization; publish corrected statements. (b) Settle C2 (which d=4 orbits lack forms) — blocking input for Mission 1. (c) Verify the Gauss-inversion observation (Connections (g)) independently. (d) Build the implication DAG of all live YELLOW conjectures (MASTER, Monotonicity, f_0 >= 0, N_n >= 0, INJ, Bounded Fermionic Form, Conjecture 2) with numerical witnesses for each non-implication. (e) Extend N_n >= 0 verification to n = 4,5 at d=4 (Seed 7's precondition for investing in a proof).

**Mission 7 (if staffed: the Phi_3-division mechanism).** Attack at level 1 first: find WHY N_1/Phi_3 >= 0 via the lattice partial-sum criterion (sum_k a_{m-3k} >= sum_k a_{m-1-3k}); Seed 7 conjectures the argument transfers verbatim to level n (residue classes of q^n). Combine with Seed 2's alternating-{0,+1,-1} U-structure and Seed 7's Shape Theorem (only ONE negative coefficient per rank-3 profile now — a far easier involution target than Round 1's).

**Mission 8 (if staffed: involution on the orbit-product expansion).** Seed 2's recommended attack: sign-reversing involution on the monomial expansion of sum_{orbit seqs} prod_j U^{(j)}(q^j) with K^m fixed points (one positive monomial per orbit sequence, since each U(1) = 1). The alternating fewnomial structure of U is inclusion-exclusion-shaped; look for a lattice-path/cycle-lemma model of the exponent sets. Overlaps Mission 7; merge if both are cut.

### What NOT to Pursue (dead list, updated)

1. All Layer-1 dead items (specialized key decomposition, Kyoto truncation, B^{1,d} energy matching, rank-2 closure). Still dead.
2. Consecutive-orbit-triple positivity; per-orbit positivity; Abel/domination chains; shifted domination (BA20, BA21).
3. Local absorption schemes for monotonicity (C1/C1'/C2) and cross-profile H or Q_1 dominations (BA22).
4. Local box-adding injections for f_0^{(m)} (three designs failed — BA25). Go global/crystal or go home.
5. Blind fermionic ansatz scans (single, two-term, 1000+-candidate boxes exhausted at d=4, d=5, d=8). Structural derivations only.
6. B^{d,1} column crystals for d > 2 (nonexistent for A_2^(1)).
7. Treating h_m >= 0 (or Monotonicity alone) as sufficient for Q_n >= 0 (BA24).

---

## 7. State of Play

### Proved perimeter (cumulative)

d=2: FULLY SOLVED (Q_n = q^{n^2}, q^{n(n+1)}; two independent proofs; h_m = RR-polynomial identities). 3|d: h_m >= 0 proved (note: the conjecture itself concerns d not divisible by 3, so this settles the bottleneck's easy half, not a case of the conjecture). d=8: everything reduced to proved explicit series (Uncu) + a 5-orbit frontier; positivity verified to n=6. Q_1 >= 0 all d (Layer 1). The exact computational infrastructure (H-recursion) removes all truncation risk permanently.

### Re-ranked Proof Paths

**Path A'' (TOP): Bounded Fermionic Form Conjecture -> everything.**
H_{c,m} = fermionic with m-dependence only in [m,n_1]_q. Implies h_m >= 0 (q-Pascal) AND Q_n = a_n >= 0 (Gauss inversion — new this layer) with explicit positive multisums, per orbit, uniformly in d. Proved for d=2; 3/5 orbits at d=4; 4/7 at d=5. Subsumes Layer 1's Paths A and F and is finitely checkable orbit by orbit. Bottleneck: forms for the missing orbits (C2 pair at d=4 first).

**Path F' (HIGH): S_11 / Uncu route at d=8, d=10.**
Prove FERM = (q)_inf * S_11 (mechanical, both sides explicit) + positive forms for the 5 frontier core orbits + INJ. Modular (each piece publishable), literature-anchored, but d-by-d rather than uniform.

**Path A' (HIGH, minimal): Monotonicity Conjecture H_m >= H_{m-1}.**
Cleanest single inequality; closes the Layer-1 bottleneck (h_m >= 0) but — post-BA24 — does NOT alone give Q_n. Value: the injection/crystal technology it needs is exactly what MASTER's tower induction needs at every level.

**Path E' (MEDIUM): Master recursion + N_n >= 0 + Shape Theorem.**
The negativity is now compressed to one coefficient per rank-3 profile in three rigid shapes; needs a smoothing/Harnack-type inequality for Q_{n-1} on profile space plus the Phi_3-division mechanism. Independent of fermionic forms — the best hedge if closed forms stay elusive.

**Path G (MEDIUM): G-level propagation + INJ + core formulas.**
Propagation Theorem is GREEN and permanent; everything funnels into the all-positive core and the Q-extraction step.

**Path D (LOW, absorbed): involutions.** No longer standalone; the live involution targets are inside Missions 2, 7, 8 (chain-model injection, Phi_3 partial sums, orbit-product expansion).

### Core Bottleneck (renamed)

Layer 1's bottleneck ("h_m >= 0") is half-proved (3|d; d=2) and — critically — known to be INSUFFICIENT for the conjecture (BA24). The conjecture now reduces, along the strongest path, to ONE statement:

> **Bounded Fermionic Form Conjecture: for gcd(d,3)=1, each H_{c,m} = (q;q)_m F_{c,m} is a manifestly positive multisum whose only m-dependence is a single factor [m, n_1]_q.**

Given the form: monotonicity, h_m >= 0, and Q_n = a_n >= 0 all follow by half a page of standard algebra (q-Pascal + Gauss inversion). It is Warnaar's explicitly-open bounded A_2 Andrews-Gordon problem, now identified with the solution of the H-tower. The fallback bottleneck (if closed forms fail): the **Phi_3-division positivity mechanism** — why dividing the positive EMD-weighted recursion by 1+q^x+q^{2x} preserves positivity — which recurs identically at the H-level (Seeds 2/3/4) and the Q-level (Seed 7).
