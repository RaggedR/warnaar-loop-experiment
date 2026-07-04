# Layer 3 Synthesis — Round 2 (2026-07-04)

Input for the next layer/round. Synthesizes 8 Layer-3 seeds + verifier (keystone check) +
Lean pilot. Layer 3 was the CONSOLIDATION layer (all 8 seeds aimed at the single Layer-2
bottleneck) and it delivered three step changes:

1. **d=4 is a THEOREM** (Q_n ≥ 0, all 15 profiles, explicit positive forms, plus BFF and
   Monotonicity) — Seed 6 + literature keystone + adversarial recomputation to n=40.
2. **The first proved case of Warnaar's Conjecture 2 at k=3**: the balanced orbit (3,3,2)
   at d=8 — Seed 2; adversarially reconfirmed to n=12. The d=8 core shrinks 7 → 6.
3. **The logical map was rebuilt** (Seed 7, referee-passed, partially Lean-checked): the
   Q-transform is now actually PROVED; MASTER ⟺ Conjecture; "BFF first level" ⟺
   Conjecture; Monotonicity and f_0 ≥ 0 are strictly-weaker projections. The Layer-2/3
   framing "Monotonicity is the bottleneck" is dead: **Q-positivity is the only terminal
   target**, and every bounded object on the board is a nonneg-kernel image of (Q_n).

Also: a project-wide convention error was found and fixed (three seeds independently);
see §4(iv) — every future brief must cite that subsection.

**Standing notation** (updated — supersedes the Layer-2 block):
- F_{c,m} = GF of cylindric partitions of profile c, max part ≤ m (raw conjecture.tex
  interlacing definition). g_m = F_{c,m} − F_{c,m−1}. H_{c,m} = (q;q)_m F_{c,m}.
  h_m = (q;q)_m g_m = H_m − (1−q^m)H_{m−1}. Δ_m = H_m − H_{m−1}.
- G_c(z) = (zq;q)_∞ F_c(z,q); Q_{n,c} = (q;q)_n [z^n] G_c(z). Conjecture: Q_{n,c} ≥ 0.
- EMD(c,c') = 3·max(0, c'₁−c₁, c₀−c'₀) + (c'₀−c₀) − (c'₁−c₁).
- **H-recursion, CORRECT orientation (target-first)**:
  (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c,c')} H_{c',m−1}, c = target (level m),
  c' = source (level m−1). The Layer-2 standing notation had it source-first — see BA31.
- Brackets: f₋₁^(m) = g_m, f_k^(m) = (1−q^{m−k}) f_{k−1}^(m) − q^{k+1} f_{k−1}^(m−1);
  D-tower D_{k+1}^m = (q;q)_{m−k−1} f_k^(m); Q_n = D_n^n.
- K = (d+1)(d+2)/6 orbits (gcd(d,3)=1); Q_n(1) = (K−1)^n; H_m(1) = K^m.

Formal writeups: proofs/prove-seed{1,2,4,6,7}-layer3.tex (all compiled). Lean project:
lean/WarnaarGlue/ (3 files, sorry-free). Seeds 3, 5, 8 report via scratch logs only.

---

## 1. Headline results (GREEN — proved, referee-checkable)

**BA-numbered new claims continue from BA28 (broken assumptions are in §4/§5).**

**G1. THEOREM (d=4 complete — Warnaar's Conjecture 2.7 at d=4, plus BFF and Monotonicity).**
(Seed 6; keystone verified; adversarially recomputed by Seed 8.) For every profile c with
c₀+c₁+c₂ = 4 (modulus 7): Q_{n,c} ≥ 0 for all n, with explicit manifestly positive forms
(T(n,j) := q^{n²+j²−nj}; orbit labels in TRUE conjecture.tex convention, see §4(iv)):
- orbit (1,1,2) = CW(2,1,1):  Q_n = Σ_j T(n,j) [2n,j]
- orbit (0,0,4) = CW(4,0,0):  Q_n = Σ_j T(n,j) q^{n+j} [2n,j]
- orbit (0,3,1) = CW(3,1,0):  Q_n = Σ_j T(n,j) q^j [2n,j]
- WALL orbit (0,1,3) = CW(3,0,1):  Q_n = Σ_j T(n,j) q^n ((q^{j−1}+q^j)[2n−2,j−1] + [2n−2,j−2]) + Σ_j T(n,j) q^{2j} [2n−2,j]
- WALL orbit (0,2,2) = CW(2,2,0):  Q_n = Σ_{j≤2n−1} q^{n²+j²−nj+2j+1} [2n−1,j] + Σ_j T(n,j) q^j (1+q^{n+j}) [2n−2,j]
Moreover H_{c,m} = Σ_{n≤m} [m,n]_q Q_{n,c} (BFF holds at d=4 with a_n = Q_n, ALL orbits
including walls), hence Monotonicity H_m ≥ H_{m−1} and h_m ≥ 0 at d=4.
Proof chain and verdict: §4(iii). Files: prove-seed6-layer3.tex (erratum applied),
scratch/prove-seed6-layer3.md §§1–8, scripts/seed6_R2L3_verify.py.
NOTE: Q-positivity at d=4 itself was in Warnaar's proved set {2,4,5}; the new-to-the-world
content is the two wall Absorption Lemmas, the BFF identification a_n = Q_n (Warnaar lists
bounded analogues as open; the CW note supplies the bounded forms), and Monotonicity/h_m.

**G2. THEOREM (Warnaar Conjecture 2 at k=3, balanced orbit (3,3,2), d=8).** (Seed 2.)
G_{(3,3,2)} = FERM₃, hence Q_{n,(3,3,2)} is a manifestly positive finite (quadruple) sum;
Q_{n,(3,3,2)} ≥ 0 for all n. Proof = 4-link chain of PROVED results:
(1) Warnaar Prop_finiteform (a=−1, k=3) + coefficientwise limit; (2) exact Pochhammer
split 1/(q)_{r₃+s₃} = (1 − q^{r₃+s₃+1})/(q)_{r₃+s₃+1} giving T = S₁₁(e₃|e₃) − q S₁₁(e₂|e₂);
(3) one instance of Kanade–Russell contiguous relation R₃ at ρ=σ=(0,0,0);
(4) Uncu 2024 thm:m11. First proved case of Conjecture 2 at k=3; first proved-positive
core orbit at d=8. Core shrinks 7 → 6: {(6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2)}.
Files: prove-seed2-layer3.tex; scripts/seed2_R2L3_s11_chain.sage (checks [A],[B] PASS,
n≤4); Seed 8 independent reimplementation: exact match to engine Q_n for n ≤ 12
(scripts/seed8_R2L3_seed2_ferm3.sage).

**G3. Theorem Q (the Q-transform — FIRST ACTUAL PROOF).** (Seed 7.)
Q_n = Σ_{m≤n} (−1)^{n−m} q^{C(n−m,2)} [n,m]_q H_{c,m}, valid in ℤ[[q]] for all profiles,
d ≢ 0 mod 3. Proof: Euler expansion of (zq;q)_∞ + truncated-Euler telescoping (Lemma E:
Σ_{k≤K} (−1)^k q^{C(k,2)}/(q;q)_k = (−1)^K q^{C(K+1,2)}/(q;q)_K). Layer 2's GREEN was
courtesy-GREEN (Seed 3 never exhibited the telescoping); now honest. No polynomiality
needed. prove-seed7-layer3.tex; seed7_R2L3_verify.sage (exact, d=4,5,7).

**G4. Corollary I (inverse Q-transform, unconditional).** (Seeds 7 and 6 independently.)
H_{c,m} = Σ_{n≤m} [m,n]_q Q_{n,c}. GF form: Σ_m H_m z^m = Σ_n Q_n z^n/(z;q)_{n+1}.
Seed 6's route bypasses even Theorem Q whenever a CW-type Euler expansion
F_{c,m} = Σ_n A_n/(q;q)_{m−n} exists. Reconciles H_m(1) = K^m with Q_n(1) = (K−1)^n.
**Lean-checked**: WarnaarGlue.qbinom_inversion, Q_transform_of_H, H_of_Q_transform
(lean/WarnaarGlue/Inversion.lean, sorry-free).

**G5. Corollary B (the bottleneck is EXACT).** (Seed 7.) The family (H_{c,m})_m admits a
coefficientwise-nonneg q-binomial expansion ⟺ Q_{n,c} ≥ 0 for all n ⟺ Warnaar's
conjecture at c. If H_m = Σ_j [m,j] a_j with a_j m-independent, then a_j = Q_j (uniqueness).
So "BFF first level" IS the conjecture, not a stepping stone.

**G6. Theorem D (unconditional Q-expansions of every tower object).** (Seed 7.)
D_k^m = Σ_j q^{(k+1)(m−j)} [m−k, j−k]_q Q_j;  h_m = Σ_j q^{m−j} [m,j] Q_j;
Δ_m = Σ_j q^{m−j} [m−1,j−1] Q_j;  D₁^m = Δ_m − q(1−q^{m−1}) Δ_{m−1}.
Every bounded object is a componentwise-nonneg unitriangular kernel applied to (Q_j).

**G7. Theorem M (MASTER ⟺ Conjecture).** (Seed 7.) {Q_i ≥ 0 for i ≤ M} ⟺ all MASTER
cells (q;q)_j f_k^(m) ≥ 0 for m ≤ M — level by level, per profile. Seed 8's MASTER is not
a strengthening; it IS the conjecture. The exactness clause (failure at j = m−k) is
automatic given the conjecture + polynomiality (leading-coefficient argument). This
explains BA24 structurally: the tower induction could never close because closing it is
proving the conjecture.

**G8. THE A₂ PASCAL LADDER.** (Seed 1; Lean-checked.) With
ferm(m,a,b,c) := Σ_{n,j} q^{n²−nj+j²+an+bj} [m,n][2n+c,j]:
   ferm(m,a,b,c) − ferm(m−1,a,b,c) = q^{m+a} ferm(m−1, a+1, b−1, c+2)  for ALL a,b,c ∈ ℤ, m ≥ 1.
One-line q-Pascal proof; the d=2 RR-polynomial proof verbatim at A₂ level. Corollaries:
ferm ≥ 0 always; any H of ferm shape is monotone with all iterated surpluses nonneg.
Lean: WarnaarGlue.pascal_ladder (PascalLadder.lean, sorry-free; c restricted to ℕ there).

**G9. Absorption Lemmas A and B (the d=4 wall mechanism).** (Seed 6.)
A: X_n − q^n Xp_n ≥ 0 by double q-Pascal on [2n,n₂]. B (exact identity, stronger):
X_n − q^n Yp_n = Σ_{j=0}^{2n−1} q^{n²+j²−nj+2j+1} [2n−1,j] by Pascal + shift-cancellation.
Verified as exact ℤ[q] identities to n=40 (Seed 8). These convert the wall shape
Q_n = (positive) + (1−q^n)(positive) into manifest positivity — the template predicted
to recur at d=7 and d=8.

**G10. Level-2 Harnack reduction + low band of N₂.** (Seed 4, prove-seed4-layer3.tex.)
Exact identities T1/T2: N₂(c) = [B_c(q²) − 1 − q² − q⁴] + har(c), where
har(c) = Σ_{c'≠c} q^{2·EMD(c',c)} Q₁(c') − q(1+q+q²+q³+q⁴) Q₁(c) and B_c(q) = Σ_{c'} q^{EMD(c',c)}
= (1+q+q²) H₁(c). Proved sphere facts for the quasi-norm f(s,t) = 3max(0,−t,s) − s + t:
b₁(c) = rank(c); b₂(c) ≥ 2; har₂ = −(b₁−1) exactly, so **[q²]N₂ = 0 identically**;
har₄ = Σ_{EMD=1}(b₂−b₁)(c') − b₃(c). **Cap-Compression Lemma** (rigorous, M=2j): har_j
depends on c only through (min(c_i, 2j))_i — each fixed coefficient of N₂ is a FINITE
problem, all d at once. **Low-band theorem: [q^j]N₂ ≥ 0 unconditionally for j ≤ 5**, and
for j ≤ 11 modulo the sharp cap M_j = j (verified j ≤ 12, d ≤ 35).

**G11. Bounded mod-d Tingley crystal operators exist on the truncated chain model.**
(Seed 5, RESULT 1 — exhaustive verification, proof program written but not executed;
GREEN as computational structure, proof pending.) Colors κ ∈ ℤ/d, boxes (i,j,s) with
color (s − j + Off_i) mod d, t-order with the global row coordinate: f_κ/e_κ are partial
weight±1 bijections with ef = fe = id, and the max ≤ m truncation is crystal-closed
(0 failures in ~5000 applications; the mod-3 route provably cannot be, cf. BA34).
The crystal on rank-3 CPs is ŝl_d level 3 (rank-level dual), colors mod d.

**G12. Lean pilot.** lean/ at repo root builds end-to-end; WarnaarGlue.pascal_ladder,
qbinom_inversion, Q_transform_of_H, H_of_Q_transform + supporting library (pascal₁,
pascal₂, gauss_mul_qfact, trinomial_rev, alt_sum, orth_ML, orth_LM) all sorry-free,
axioms = [propext, Classical.choice, Quot.sound]. Mathlib has NO Gaussian binomials —
the library defines them. Not formalized: Theorem Q's Euler-convolution step (H/Q link
enters as hypothesis corollary_I).

**Carried forward GREEN (Layer ≤2, still load-bearing):** G-CW Lemma; H-recursion +
polynomiality; Orbit-Tower/orbit-product; Propagation Theorem (G-level); exact Q-level
R-identity; Master Recursion; Preimage EMD Dichotomy + N₂ Shape Theorem (now subsumed by
G10's sharper T1/T2); bracket-tower algebra T1/T2 (Seed 8 L2); Uncu S₁₁ at d=8; d=2
solved; h_m ≥ 0 for 3|d; Adjugate Monomial Theorem. All labels in old statements must be
run through §4(iv) when chirality-sensitive.

---

## 2. YELLOW (verified, unproved — exact statements and ranges)

**Y1. The conjecture itself, at scale (Seed 8 adversary — no counterexample anywhere).**
Via Theorem M, Seed 8's clean MASTER grids ARE exact verification of Q_n ≥ 0:
- Full MASTER grid (all poly cells D_{k,m} ≥ 0 incl. Q_m = D_{m,m}; all series cells;
  boundary must-fail verified) + h_m ≥ 0 + Monotonicity, exact ℤ[q]:
  d=7 m≤6; d=13 m≤16; d=16, 17, 19, 20 m≤12; d=22, 23 m≤10; d=25 m≤9; d=31 m≤7 —
  every orbit, every cell. Logs scratch/tmp/seed8_d*.log.
- Gauss-inversion a_n: a_n == D_n^n exactly AND a_n ≥ 0 at d=4 (n≤25), d=5 (n≤22),
  d=7 (n≤18), d=8 (n≤16), d=13 (n≤12), including all wall orbits.
- Uncu S₁₁ vs exact engine, d=8, all 15 orbits, n=7,8: all match, all positive.
- Margins: min in-hull coefficients often 0 but never negative; NO shrinking-margin
  trend as d grows.

**Y2. Bounded Tingley Factorization (Seed 5 RESULT 5 — headline structural YELLOW).**
G_m := F_{c,m} satisfies (q^d;q^d)_{m−1} F_{c,m} = b_m, the character of the vacuum
crystal component of the bounded chain set; equivalently every component is isomorphic
to the vacuum one and sources are counted by partitions into parts {d, 2d, …, (m−1)d}.
Verified d ∈ {2,…,8} (including 3|d and d=2 where Tingley's n≥3 hypothesis fails!),
m ≤ 5, W ≤ 13, all tested profiles. COROLLARY once proved: (q^d;q^d)_{m−1} F_{c,m} ≥ 0 —
the rank-level DUAL of H-positivity, manifestly a crystal character. Appears NEW
(RAG: no literature match); publishable standalone. Proof program in
scratch/prove-seed5-layer3.md ("Proof program" section, Steps 1–2).

**Y3. SHARP-F0 (Seed 5 RESULT 6).** With s_m := g_m/P_{m−1} (P_k = Π_{j≤k} 1/(1−q^{jd});
s_m ≥ 0 manifest given Y2):  (1−q^m) s_m ≥ q (1−q^{(m−1)d}) s_{m−1}  (gcd(d,3)=1).
Implies f_0^(m) ≥ 0 and is strictly sharper. Verified ~60 cases: d ∈ {2,4,5,7,8}, m ≤ 5,
W ≤ 13. val(T6_m) = 2m−1 generically, 2m for corner orbits. The two-term weakenings
(dropping either factor) are FALSE (§3).

**Y4. Sphere Absorption Conjecture (Seed 4 — all levels).** At every level n, in the
T1-analogue split N_n = [B_c(q^n) − Σ_{e≤...} q^{ne}] + har^(n), the negatives of har^(n)
occur ONLY at exponents n·e (small e), each ≥ −(b_e(c)−1), exactly absorbed by the ball
term; har^(n)_{n·1} = −(b₁−1) exactly, so [q^n]N_n = 0. Verified n=2 (all profiles, d≤35)
and n=3 (d=4,5; negatives only at {3,6,9}). Sub-conjectures: S1 (har_j ≥ 0 for j ∉ {2,4}),
S2 (har₄ ≥ −(b₂−1)) — verified d ≤ 35; sharp cap M_j = j verified j ≤ 12.

**Y5. HALL-RIBBON (Seed 3).** For every set B of weight-w chains in C_m, the ribbon
neighborhood (one box per level, any coordinate per level, chain valid) at weight w+m
satisfies #N(B) ≥ #B. Hall's condition verified with deficiency 0 in all 22 cases
(d=2 m≤4 w≤11; d=4 m≤3 w≤10; d=5 m≤3 w≤9; d=7 m=2 w≤9). By LP duality a fractional
matching suffices — strictly weaker than all failed injection designs. Would give
f_0^(m) ≥ 0 (a projection, per §4(i) — no longer terminal, but the technology target).

**Y6. Joint containment pair (Seed 5 RESULT 4).** A co-designed pair Θ: C_{m−1}→C_m
(wt+1) and ψ: C_m→C_m (wt+m), jointly injective, both containment maps, EXISTS by Hall
at every weight in all tested cases (d=4 all orbits m≤3–4, d=5, d=7). The single-map
version is impossible (§3). Correct design space for any future injection work.

**Y7. Raw bracket (Seed 3).** g_m ≥ q^m F_{c,m} coefficientwise — holds in all 6 tested
cases (d=2,4,5,7). Equivalent to Δ_m ≥ 0 up to (q;q)_{m−1}-smoothing; independent target.

**Y8. Conjecture A (Seed 3 Script 2).** For every all-positive target c (all c_i ≥ 1) the
row (U−I)_c is coefficientwise nonneg (checked d=4: row (1,1,2) = [x³,x,x,x²,0]), so
H-level monotonicity is MANIFEST at all-positive orbits. NOTE the polarity reversal vs
the G-level: Seed 6 L2's hard core = all-positive profiles; at the H-level the all-positive
orbits are the FREE ones and zero-containing orbits are hard.

**Y9. Frontier shift-pair table at d=8 (Seed 2 Finding 7b).** Uncu's differences for the
6 remaining core orbits have shift pairs (δ₂ or δ₁, not the mergeable δ₃): e.g.
(4,2,2): S(e₂|e₂) − qS(e₁|e₁); (6,1,1): S(e₁|e₁) − qS(e₀|e₀); etc. Template: use proved
R1/R2 to walk shifts down to δ₃, merge via the Pochhammer un-split, match a Warnaar-type
finite form. Structural fact (Seed 2 Finding 2): the R-relation system at d=8 is
UNDERDETERMINED for the core (3 equations, 6 unknowns) and (4,2,2) appears in NO
R-relation — extra equations must come from |I_c|=3 CW equations.

**Y10. d-stabilization of val(Q_n) (Seed 1 Result 7).** val(Q_{c,n}) sequences stabilize
in d for fixed orbit type (e.g. corner orbit (0,0,d): 0,2,6,11,18,26,36,47,60 identically
for d=4,5,7) — a fingerprint for hunting closed forms d-uniformly.

---

## 3. Dead ends with certificates (do not re-till)

**D1. Fixed-depth nonneg matrix decompositions of the U-tower.** (Seed 1 Result 3.)
LP-INFEASIBLE at depths 1–3 already at d=2 (corner row) for
(U(xq^k)−I)U(xq^{k−1})⋯U(x) = Σ A_j G_j + B with nonneg A,B over the iterated-difference
cone. Treating (x,q) as independent loses the x = q^m specialization the d=2 proof uses.
Also (Seed 3 Script 3): M_m = U(q^m)U(q^{m−1}) − U(q^{m−1}) has negative entries for all
d ∈ {2,4,5,7,8}, all depths ≤ 4. Positivity is never entrywise at fixed smoothing depth.

**D2. eps-cone / x-power grouping of U−I rows.** (Seed 3 Script 4.) Every mixed-sign
eps-inequality already fails at m=1 (e.g. H_B − H_A ≥ 0 false at d=2). The cancellation
in D_m = Σ_j q^{jm}(eps^(j)·H_{m−1}) is BETWEEN x-power groups. Log seed3_R2L3_epscone.log.

**D3. Levelwise injection rules — closed for wall orbits, with certificates.** (Seed 3.)
(a) Part-insertion/full-column moves: Hall FAILS (finite certificates, e.g. d=4 c=(0,3,1)
deadend ((0,3,4),(0,3,0)); log seed3_R2L3_matching.log). (b) Uniform/local-degree
fractional matchings: infeasible (inflow up to 181/90). (c) ANY levelwise monotone
injective weight+1 map ι: ILP-INFEASIBLE on rank truncations (hence globally nonexistent)
for (4,0,0), (0,3,1), (5,0,0), (0,2,2), (0,1,3), (3,1,1), (4,2,1), (2,2,0), (3,1,0),
(0,4,1); V1 (single-box + consistency) infeasible for ALL 10 profiles incl. d=2. This
subsumes Seed 8 L2's three failed designs AND all single-level rules. Any working ψ must
couple levels.

**D4. Single-J reduction (crystal or not).** (Seed 5 RESULT 3.) No total injective
weight+1 box-adding self-map J with the bottom-fill property exists — Hopcroft–Karp Hall
failures even for arbitrary single-box edges (d=4 (2,1,1) m=3: 12/15 at w=3; also m=2 for
(0,2,2),(4,0,0),(0,3,1)). All source-side and image-side canonical rules fail. The pair
(Θ,ψ) must be co-designed (Y6).

**D5. Two-term beta/s inequalities.** (Seed 5 RESULT 7.) I3 ((1−q^m)b_m ≥
(1−q^{(m−1)d})(1+q−q^m)b_{m−1}) fails everywhere m≥2; T5 (dropping (1−q^{(m−1)d}) from
SHARP-F0) fails at d=2 m=2,3. The dual factor does real work.

**D6. Double-product positivity is FALSE.** (Seed 5 RESULT 7d.) (q;q)_m (q^d;q^d)_{m−1}
F_{c,m} has negative coefficients (d=2,4,5). No self-dual strengthening.

**D7. Naive M1 lift at k=3.** (Seed 2 Finding 5.) Q_n^cand = δ_{n,0} + ferm_M1(n; lin, i)
over all lin ∈ {0,1}⁵, i ∈ {1,2}: covered-orbit sanity passes, frontier hits ZERO. The
d=5 "(3,1,1) = 1 + M1(3,2,0)" template does not lift naively to d=8.

**D8. Depth-1 CW substitution for the d=8 core.** (Seed 2, counting obstruction.) The
Substitution Lemma cancels one pair term per c_i = 1; core profiles have ≤ 2 of 3
cancellable ((3,3,2): zero). Depth-1 can never fully positivize a core CW equation.

**D9. Two-variable H-ansatz / two-term ferm decompositions for the d=4 walls.** (Seed 1
Result 6.) 65856-point grid over Σ q^{An²+Bnj+Cj²+an+bj}[m,n][αn+βm+c, j]: no match for
walls (true labels (0,1,3), (0,2,2)) nor any d=5 orbit. Moot for d=4 (G1 gives the forms —
two-TERM, not single) but the certificate stands for d=5 single-sum shapes.

**D10. Termwise per-neighbor domination and reciprocity for N₂.** (Seed 4.)
q^{2e'}Q₁(c') ≥ q^s Q₁(c) impossible at bottom degree; q^deg X(1/q) matches no profile
transform for X ∈ {Q₁, N₂, har}. Plain har ≥ 0 false (exactly at exponents {2,4}).

**D11. H-level positivity as a route to G/Q-positivity.** (Seed 2 opening.) G_c =
(q;q)_∞ H_c reintroduces signs; the direction is wrong. Positive H-rewritings prove
nothing about Q.

Layer-≤2 dead list remains in force (BA20–BA28, synthesis-layer2 §6 "What NOT to Pursue").

---

## 4. Adjudications

### (i) The equivalence chain "Monotonicity ≡ f_0 ≥ 0 ≡ BFF first level" is FALSE — corrected hierarchy

What went wrong, precisely: Layer 2's synthesizer itself adjudicated correctly that
Monotonicity ≠ MASTER's f_0-cell (synthesis-layer2 §5(a)) and asked for cross-implication
tests. The error entered in the **Layer-3 re-seeding brief** (seeds-layer3/seeds.md,
"Core bottleneck" header), which flattened three distinct statements into one equivalence.
Layer 2's genuine error was subtler: framing "BFF first level" as a WEAKER waypoint below
the full conjecture, and framing Monotonicity as "the minimal bottleneck." Both framings
are now refuted by Seed 7's theorems (all GREEN):

    BFF-level-1 (∃ nonneg q-binomial expansion of (H_m))
        ⟺  Conjecture (Q_n ≥ 0 ∀n)      [Cor B; the expansion coefficients ARE Q_n]
        ⟺  MASTER (all cells)            [Thm M]
        ⟹  Monotonicity (Δ_m ≥ 0)        [Δ_m = Σ q^{m−j}[m−1,j−1] Q_j, nonneg kernel]
        ⟹  h_m ≥ 0                       [h_m = Σ q^{m−j}[m,j] Q_j; or Seed 3's reduction]
        ⟹  (q;q)_j g_m ≥ 0 cells
    Conjecture ⟹ f_0^(m) ≥ 0 and every single MASTER cell   [Thm M(a)]

Monotonicity and f_0^(m) ≥ 0 are DISTINCT projections (D₁^m = Δ_m − q(1−q^{m−1})Δ_{m−1};
(q;q)_{m−1} has mixed signs, positivity transfers in neither direction); neither is known
to imply the other, and neither implies the conjecture. **BA29**: the brief's chain is a
broken assumption on record. **BA30**: "MASTER strengthens the conjecture" — false, it is
the conjecture; all MASTER verification is conjecture verification (this upgraded Seed 8's
sweeps into Y1). Strategic consequence: Monotonicity/f_0 are no longer terminal targets;
their value is purely as technology transfer.

### (ii) Seed 1's g-transform vs Seed 7's inversion: CIRCULAR, confirmed — with residual value

Confirmed: Seed 1's g_{c,n} (the unique m-independent expansion H_m = Σ_n g_n [m,n]_q,
i.e. the inverse q-binomial transform) equals Q_{n,c} EXACTLY, by uniqueness in Seed 7's
Theorem G + Corollary I. Seed 1's "g-POSITIVITY CONJECTURE" is therefore verbatim
Warnaar's conjecture — a genuine reformulation discovery made independently and
simultaneously by Seeds 1, 6, 7 (three routes to Corollary I), but with zero new logical
content as a conjecture. What retains value from Seed 1's Results 2–7:
- The empirical g ≥ 0 checks ARE Q_n ≥ 0 checks; Seed 1's ranges (d=2,4,5 n≤8, d=7 n≤6)
  are SUBSUMED by Seed 8's (d=4 n≤25, d=7 n≤18, etc.). They do not extend known ranges.
- The A₂ Pascal ladder (G8) is unconditional and permanent: it proves monotonicity-with-
  all-iterated-surpluses for the entire ferm class, explains the ladder-BFS phenomenology,
  and is Lean-checked. This was the mission's actual deliverable.
- The val stabilization fingerprint (Y10) and the exclusion certificates (D1, D9).
- Result 5's ferm fits for the three good d=4 orbits are now THEOREMS via G1 + G5
  uniqueness (a_n = Q_n and Q_n has exactly the fitted single-sum form).

### (iii) d=4 verdict: THEOREM by project standards

Verdict chain, assembled: (1) Keystone: the Corteel–Welsh companion note
(literature/tex/corteel_welsh_A2_RR/source.tex) is a complete PEER-REVIEWED paper;
Theorems \ref{new} and \ref{Thm:G} cover ALL FIVE d=4 orbits with full proofs (uniqueness
induction on the manifestly positive system Eq:Fun) — verifier report
scratch/verify-layer3-keystone.md, JOB 1: **KEYSTONE SOLID**. (2) Seed 6's derivation:
Q_n = (q;q)_n [y^n]G_c from Thm:G, wall positivity via Absorption Lemmas A and B (both
fully hand-proved, §G9), BFF/Monotonicity via the Inversion Lemma (direct Euler-expansion
proof — does not even need Theorem Q). (3) Adversarial recomputation (Seed 8): all five
formulas == exact raw-definition-validated engine for n ≤ 40 (deg Q₄₀ = 4800), absorption
identities exact, Q_n(1) = 4ⁿ. (4) Erratum: the orbit dictionary in prove-seed6-layer3.tex
had the two chirality-sensitive rows swapped (Seed 8 FINDING 2, verifier-confirmed n≤28);
**the erratum is now APPLIED in the tex** (identity dictionary + convention note,
prove-seed6-layer3.tex lines ~57–66). The scratch file's §8 orbit labels remain in the OLD
convention — read the tex, not the md, for labels.

**VERDICT: d=4 is a THEOREM by project standards.** What a referee must still check by
hand: (a) the CW note's Thm:G uniqueness induction (peer-reviewed literature, ~2 pages);
(b) the two absorption-lemma q-Pascal computations (half page each; machine-verified to
n=40 but the hand proofs are the referee object); (c) the half-page Euler-expansion
inversion argument (the inversion identity itself is Lean-checked, G12); (d) the orbit
dictionary bookkeeping (§4(iv)). Nothing else.

### (iv) THE DEFINITIVE CONVENTION STATEMENT (cite this subsection in every future brief)

Discovered independently by Seeds 6 (V1), 7 (Run 2), 8 (FINDING 1); verifier-confirmed.

1. **Ground truth** is the raw conjecture.tex interlacing definition of cylindric
   partitions of profile c. The chain model S = {a ∈ ℤ³_{≥0} : a_i ≤ a_{i−1} + c_i}
   at profile c matches it DIRECTLY (no relabeling).
2. **Target-first kernel is correct**: the H-recursion matching ground truth is
   (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c,c')} H_{c',m−1} with c the TARGET (level m).
   Validated three ways (CW truncated solve; brute-force enumeration; d=2 closed forms).
3. **The Layer-2 standing notation was source-first** (q^{m·EMD(c',c)}) and computes H of
   the REVERSED profile: H_src-first[c] = H_true[rev(c)], rev(c₀,c₁,c₂) = (c₂,c₁,c₀).
   **BA31.** All AGGREGATE Layer-≤2 positivity results remain valid (the profile set is
   reversal-closed); only per-orbit labels flip, and only on reversal-ASYMMETRIC orbits
   (at d=4: the orbits of (0,1,3)/(0,3,1); at d=5: perms of {0,1,4},{0,2,3}).
4. **d=4 orbit dictionary in TRUE labels — the IDENTITY map** (each CW label c ↔ the
   C₃-orbit containing c itself):
   CW(2,1,1) = {(1,1,2),(1,2,1),(2,1,1)} good; CW(4,0,0) = {(0,0,4),(0,4,0),(4,0,0)} good;
   CW(3,1,0) = {(0,3,1),(1,0,3),(3,1,0)} good (single sum, q^j);
   **CW(3,0,1) = {(0,1,3),(1,3,0),(3,0,1)} WALL**; CW(2,2,0) = {(0,2,2),(2,0,2),(2,2,0)} WALL.
5. **Retro-correction of the Layer-2 C2 verdict** (verify-layer2-disputes.md): its verdict
   "walls = (0,2,2),(0,3,1); Seed 3 correct, Seed 4 wrong" was computed on the source-first
   (reversed) engine. In TRUE labels the walls are the orbits of **(0,2,2) and (0,1,3)** —
   i.e. Seed 4's list was the correct one in raw labels; Seed 3's was correct in reversed
   labels; both had found the same orbits (C2 was purely notational, as Seed 1 Result 1
   also concluded). The "Seed 4 WRONG" line is retracted.
6. **Rule going forward**: all new artifacts use TRUE labels + target-first kernel.
   Seed 8's raw-validated engine (scripts/seed8_R2L3_engine.sage) is the reference
   implementation. Any statement mixing chain-model and EMD-recursion objects, or matching
   against Warnaar/Uncu/CW tables, must apply rev() when consuming source-first-era files
   (all Layer-2 files; Seed 3/4 L3 analysis files; scratch prove-seed6-layer3.md §8).
   Two convention bugs in two layers both arose at chirality-sensitive orbit pairs; an
   automated label audit of old artifacts is cheap insurance (Seed 8's recommendation).

### (v) Composition: does S2's chain + S6's keystone method make a general program?

Partially — the two templates compose into a pipeline, but each has an unfilled slot.

Template A (Seed 2, balanced orbits): proved finite form F^(a) → coefficientwise limit →
Pochhammer split → proved KR contiguous relation(s) → proved Uncu S_m theorem. Inputs
that exist TODAY: Warnaar's F^(±1) finite forms (proved, all k); Uncu's theorems at
m=11 (d=8) and m=13 (d=10) ONLY; KR relations R1,R2,R3,R4 (proved). So **d=10 balanced
(4,3,3) is the highest-probability next theorem**: same chain with a=+1 / S₁₃ / Uncu
thm:m13; the single caution is that Uncu's DISPLAYED R₃ for m ≡ 1 mod 3 contains a typo
(two identical terms with opposite signs) — re-derive from KR arXiv 2022 Lemma 9.2 first.
Beyond balanced: Warnaar's F^(a)_{k,s,t} variants (source.tex ~line 3001) seed the
(3k−s, s−1, 0) family — but those are zero-containing (propagation-reachable anyway).

Template B (Seed 6, whole-level): a fully proved manifestly positive y-functional system
(CW-style Eq:Fun) + uniqueness induction → explicit G-forms for ALL orbits → absorption
lemmas for the (1−q^n) wall terms → Q_n ≥ 0, BFF, Monotonicity for the whole level.
The keystone exists in the literature only for d=4. For d=7 (mod 10 — the smallest level
with NO proof anywhere, since Warnaar's set is {2,4,5}) the system would have to be
CONSTRUCTED: Seed 6 L2's R-relations give the zero-containing rows; the CW note's positive
relation for the core profile (their (2,1,1)) shows positive core rows can exist beyond
the Substitution-Lemma families — finding them is an ansatz-plus-uniqueness search, not
blind scanning.

For the 6 remaining d=8 core orbits, what exactly is missing:
(1) mergeable shift pairs: Uncu's differences for the frontier have δ₁/δ₂ shifts; a SHORT
WORD in R1/R2 (each application costs one extra zq^{...} S-term) must walk them to a
mergeable (+δ₃|+δ₃) pair with (q;q)_∞-compatible remainder — a finite symbolic search,
depth ≤ 3–4, never yet run (Seed 2's #2 handoff);
(2) finite-form seeds with NEW sigma patterns: the merged T-shaped sums need Warnaar-type
finite forms beyond F^(a)_{k,s,t} (frontier orbits have sigma patterns not of the
(1,…,1,a) shape) — this is the genuinely open ingredient;
(3) (4,2,2) is special: it appears in NO R-relation at d=8; only core CW equations reach
it (Seed 2 Finding 2);
(4) the Q-extraction/INJ worry from Layer 2 is DISSOLVED, not solved: Seed 6 showed wall
(1−q^n)-terms are handled by absorption lemmas, no INJ needed — expect the same for any
core forms obtained.
So: a general program exists on paper (A for balanced at Uncu-proved moduli; B per-level
given a positive system; absorption as the universal Q-extraction step); the two concrete
missing pieces are the R1/R2 word search (mechanical) and new finite-form seeds (creative).

### Additional adjudications (conflicts found among the eight logs)

**(vi) Seed 5 RESULT 5 vs Tingley's hypothesis.** The Bounded Factorization holds
empirically at d=2 where Tingley's construction (n ≥ 3) does not apply, and at 3|d. So Y2
is stated for all d ≥ 2 but any proof via Tingley Section 4.2 (which has a POST-PUBLICATION
erratum — verify axioms computationally, per chunk_007) covers d ≥ 3 only; d=2 needs a
separate (easy, d=2-solved) argument. Flagged so the formalizer scopes correctly.

**(vii) Seed 3's "Q1 passes" vs corner anomaly.** U(q^m) D_{m−1} ≥ 0 holds at d=4,5,7 but
FAILS at the d=2 corner orbit — so it is not a usable induction hypothesis despite the
clean d≥4 data; the corner orbit ((d,0,0)) is consistently extremal (val(Δ)=m+1,
V3-infeasible, Hall deadends, m=1 corner failure of Seed 5's I2). Any future injection or
kernel argument must budget an auxiliary-vector treatment for corners (d=2 precedent:
Seed 4 L2's C-vector).

**(viii) Polarity reversal H-level vs G-level (Seed 3 vs Seed 6 L2) — both right.** At the
G-level, zero-containing profiles are easy (propagation) and the all-positive core is hard.
At the H-level it is the opposite (Y8). Not a contradiction: different objects. But it
means "hard orbit" is level-relative; briefs must say which level.

**(ix) Status of Layer-2 YELLOW items after G1–G7.** Monotonicity, h_m ≥ 0, f_0 ≥ 0,
N_n ≥ 0, MASTER, INJ: all are now nonneg-kernel consequences of Q-positivity (G6/G7) —
they are no longer independent conjectures to verify, only techniques. BFF (full fermionic
shape) remains a genuine strengthening of the conjecture (adds the explicit multisum form);
BFF-level-1 is the conjecture itself (G5). INJ is bypassed by absorption (adjudication v).

---

## 5. The corrected map of the problem

**BA29** (Layer-3 brief). "Monotonicity ≡ f_0 ≥ 0 ≡ BFF-level-1." FALSE — see §4(i).
**BA30.** "MASTER strengthens the conjecture." FALSE — equivalent (Thm M).
**BA31.** "The Layer-2 standing kernel orientation matches the raw definition." FALSE —
source-first computes reversed profiles; target-first is correct (§4(iv)).
**BA32.** "Monotonicity is the bottleneck / a stepping stone to the conjecture." DEAD as
strategy: it is a strict projection; proving it proves nothing about Q_n (theorem-level
now, upgrading BA24 from caution to fact).
**BA33.** "A single canonical total weight+1 box-adding map can exist (crystal or
otherwise)." FALSE — Hall certificates (D4); only co-designed pairs remain (Y6).
**BA34.** "The natural crystal on rank-3 CPs is ŝl₃ level d (colors mod 3)." FALSE — the
mod-3 coloring is inconsistent on the cylinder for gcd(d,3)=1; the consistent structure is
the rank-level DUAL, ŝl_d level 3, colors mod d (Seed 5 RESULT 1). Retro-explains BA18/
BA19 and the death of B^{d,1} column crystals.
**BA35.** "The Layer-2 C2 verdict (Seed 3 correct, Seed 4 wrong) stands." RETRACTED —
artifact of the reversed engine; both seeds were right in their own labels (§4(iv).5).

**The problem now**: ONE target, Q_{n,c} ≥ 0, with the complete lattice of reformulations
proved. Everything bounded (h, Δ, D_k, f_k-cells, N_n) sits BELOW it under nonneg kernels;
full BFF (fermionic shape) sits ABOVE it; BFF-level-1, MASTER, and g-positivity ARE it.
Proved perimeter: d=2 (fully, two proofs); d=4 (fully — G1); 3|d bottleneck half; at d=8:
Conjecture 2 for (3,3,2) + all zero-containing orbits reduced to the 6-orbit core
(propagation GREEN); exact verification through d=31 (Y1). The live proof routes:
- **Route L (literature-composition)**: Template A + Template B of §4(v). Nearest fruit:
  d=10 balanced; then d=8 frontier via R1/R2 words + new finite forms; d=7 via a
  constructed CW-style positive system.
- **Route S (structure)**: the three reframes of §7 (HALL-RIBBON, Sphere Absorption,
  SHARP-F0/Bounded Factorization) — d-uniform, but each still needs its key lemma.
- The Phi₃-division mystery (Layer 2 §5(h)) is largely DISSOLVED at the Q-level by G6/G7
  (the division is encoded in the proved nonneg kernels); it survives only inside Route S
  as the H-level tower mechanism.

---

## 6. Recommended next-layer missions

**Mission 1 (TOP, mechanical+creative): d=10 balanced orbit (4,3,3).** Run Template A with
a=+1 / S₁₃ / Uncu thm:m13. FIRST re-derive the m ≡ 1 mod 3 contiguous relation from KR
arXiv 2022 Lemma 9.2 (Uncu's displayed R₃ there has a typo — two identical terms with
opposite signs). Deliverable: second proved case of Conjecture 2, first proved core orbit
at d=10. Inputs: prove-seed2-layer3.tex §"chain", seed2_R2L3_s11_chain.sage.

**Mission 2 (d=8 frontier, finite search): R1/R2 word search.** For each of the 6 core
orbits (start with (6,1,1) and (5,2,1), whose shift pairs are closest to δ₃), exhaust
words of depth ≤ 4 in the proved relations R1^(i), R2^(i), R3, R4 turning Uncu's
difference into mergeable pair + (q;q)_∞-compatible remainder (Y9 table). Track (4,2,2)
separately (needs core CW equations). Success on ANY orbit shrinks the core; success on
all 6 + propagation + absorption = d=8 solved.

**Mission 3 (d=7, the smallest unproved-anywhere level): construct the positive y-system.**
Build the CW-style Eq:Fun analogue at d=7 (mod 10): R-relations give zero-containing rows
(Seed 6 L2 GREEN); search for positive core rows guided by the CW note's core relation
shape (their (2,1,1) row) and Seed 2's distortion-move catalogue (Finding 3: M0–M3).
Then uniqueness induction + q-binomial theorem → bounded forms → absorption lemmas
(expect 3-fold sums, same (1−q^n) wall shape). This is Template B in new territory and
would be the project's first fully-novel level.

**Mission 4 (structure, publishable standalone): formalize the Bounded Tingley
Factorization (Y2).** Steps 1–2 of Seed 5's proof program (bounded operators well-defined
via Tingley's bracket argument — the m-bound only deletes far-end addables; unique source
per component; source combinatorics = partitions into {d,…,(m−1)d}). Payoff:
(q^d;q^d)_{m−1} F_{c,m} ≥ 0 unconditionally (dual-H positivity), apparently new. Scope
d ≥ 3 via Tingley (mind the published erratum to his §4.2), d=2 separately.

**Mission 5 (structure): SHARP-F0 (Y3) inside the vacuum component.** Now that the
bosonic factor is stripped, attack (1−q^m)s_m ≥ q(1−q^{(m−1)d})s_{m−1} via string/Demazure
decomposition of B(Λ_c) for ŝl_d, or run Seed 3's normalized-matching/HALL-RIBBON
machinery INSIDE the vacuum component (much smaller, connected). Also find the
combinatorial object with character s_m (RESULT 7c says not the naive set difference).
NOTE post-§4(i): this proves a projection, not the conjecture — fund it as technology
and for the dual-positivity payoff, not as the terminal target.

**Mission 6 (N_n route): finish S1 via Ehrhart.** Seed 4's reduction makes each [q^j]N₂ a
finite lattice-point problem (Cap-Compression, G10). A_j(c) = #{f ≤ j, f ≡ j mod 3} is
piecewise quasi-polynomial in (j,c); har_j is a finite signed combination — region-by-
region verification is a finite computation. Then lift by the Sphere Absorption pattern
(Y4, verified at n=3). Independent hedge if closed forms stall; also the only route
attacking all d uniformly at fixed n.

**Mission 7 (verifier/housekeeping).** (a) Automated label audit of ALL Layer-≤2 artifacts
against the raw-validated engine (Seed 8's recommendation; two convention bugs in two
layers). (b) Confirm the erratum in prove-seed6-layer3.tex compiles and the PDF is
regenerated. (c) Lean: add Theorem D's kernel identities (cheap per pilot handoff) and a
nonneg-coefficients predicate to state ferm-monotonicity; optionally Lemma E + Theorem Q.
(d) Re-verify Y7 (raw bracket) and Y8 (Conjecture A rows for all-positive orbits) at more d.

**Mission 8 (adversary, keep one).** Target Q_n directly at large n on the d=8 core
(n > 16) and d=7 (n > 18) — the two places a counterexample would redirect everything;
plus stress d ≡ ±1 mod 3 asymmetries and the corner orbits. Per BA30, MASTER-grid sweeps
are the efficient format.

**What NOT to pursue** (adds to the standing dead list): D1–D11 of §3; any proof effort
whose terminal statement is Monotonicity/f_0/N_n alone WITHOUT a stated path to Q_n
(BA32) — exception: Mission 6 explicitly targets N_n as a hedge, and Mission 5 for its
dual payoff.

---

## 7. State of the general conjecture

**The exact reformulation (Seed 7, GREEN).** For each profile c with gcd(d,3)=1:
Warnaar's conjecture at c ⟺ the sequence (H_{c,m})_m admits a coefficientwise-nonneg
q-binomial expansion H_m = Σ_n [m,n]_q a_n — and then a_n = Q_{n,c} necessarily. One
sequence per profile; m eliminated; the conjecture is a statement about the inverse
q-binomial transform of a crystal-character-adjacent family being nonneg.

**Three structural reframes now open** (each d-uniform, each with a sharp verified target):
1. **HALL-RIBBON** (Seed 3, Y5): matching-theoretic — ribbon neighborhoods never contract
   (deficiency 0 in all 22 tests); distributive-lattice S + normalized-matching machinery
   is the designated tool. Proves the f_0-projection.
2. **Sphere Absorption** (Seed 4, Y4): geometric — all N_n negativity sits at exponents
   n·e and is absorbed exactly by EMD-sphere counts; [qⁿ]N_n = 0 identically; low band
   proved, Ehrhart route to the rest is finite region-by-region.
3. **SHARP-F0 + Bounded Tingley Factorization** (Seed 5, Y2+Y3): representation-theoretic —
   F_{c,m}·(q^d;q^d)_{m−1} is a connected ŝl_d level-3 crystal character; the conjecture's
   hard content survives as one self-similar inequality between de-bosonized characters.

**Confirmation landscape (Seed 8).** The conjecture stands exact-verified (ℤ[q], no
truncation, via MASTER grids = the conjecture per Thm M) at
d ∈ {2,4,5,7,8,13,16,17,19,20,22,23,25,31}: d=13 to m=16, d=16/17/19/20 to m=12,
d=22/23 to m=10, d=25 to m=9, d=31 to m=7; plus Gauss-inversion Q_n ≥ 0 at d=4 n≤25,
d=5 n≤22, d=7 n≤18, d=8 n≤16, d=13 n≤12 (all wall orbits included); Uncu S₁₁ matched to
n=8. Margins show no degradation trend. Clean to d=31. Combined with G1/G2: proved at
d ∈ {2,4} fully (+ Warnaar's d=5), one orbit at d=8, and no cracks anywhere in sight —
the program's task is now manufacturing proofs, not doubting the statement.
