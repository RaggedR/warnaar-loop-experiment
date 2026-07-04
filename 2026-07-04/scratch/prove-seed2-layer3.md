# Seed 2, Layer 3, Round 2 — the d=8 endgame via Bailey/S_11 machinery

Mission (a) prove FERM_c = (q)_inf * S_11-combo for covered orbits (Conjecture 2 at k=3);
(b) does R-relations + Uncu's proved series settle positivity for the 7 core orbits OUTRIGHT?
(c) extend the (4,3,1) CDU-style bivariate-positive formula to other uncovered orbits.

Inherits: seed5-L2 (Uncu S_11 exact matches, seed5_R2L2_qn_d8.json ground truth),
seed6-L2 (Propagation Theorem, R-relations, core = 7 all-positive orbits at d=8).

Standing facts (from synthesis-layer2.md):
- G_c(z) = (zq;q)_inf F_c(z,q); H_c = G_c/(q;q)_inf; Q_n = (q)_n [z^n] G_c.
- Core at d=8: (6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2),(3,3,2).
- Covered by Warnaar Conj 2: (8,0,0),(7,1,0),(6,2,0),(5,3,0) [zero-containing] + (3,3,2).
- Frontier (core, no positive form): (6,1,1),(5,1,2),(4,1,3),(5,2,1),(4,2,2).
- Uncu m=11 (k=4, proved): H_c = S(e_{c2}|e_{c3}) - q S(e_{c2-1}|e_{c3-1}) for c2,c3>0;
  single S-term for c3=0 covered; -q(1-z) variants for c2=0; triple for (4,4,0).
- KR contiguous relations R1^{(i)}, R2^{(i)} (i=1,2), R3, R4 (m=11 = 3k-1 case)
  generate the ideal I_11; Uncu proved CW system for all 15 profiles lies in I_11 (N=6).

## Initial analysis (before computing)

### Direction-of-implication check for mission (b)
H_c positivity is the WRONG direction for us: G_c = (q)_inf H_c, so a positive
rewriting of H_c in S-terms does NOT give G-positivity (the (q)_inf reintroduces signs).
What would settle core positivity outright:
  (i) a manifestly positive R-relation for a core orbit (core shrinks), or
  (ii) a positive form for (q)_inf * (S-difference) with manifest (q)_inf-cancellation
      (FERM-shaped), which is mission (a)/(c) territory.

### Depth-1 counting obstruction for core R-relations (to formalize)
For core c (all c_i >= 1), CW has 3 singleton (+), 3 pair (-(1-zq).), 1 triple
(+(1-zq)(1-zq^2).G_c(zq^3)) terms. The Substitution Lemma cancels one pair term per
ZERO-CONTAINING singleton c({i}); c({i}) is zero-containing iff c_i = 1.
  (6,1,1): #{c_i=1} = 2 -> at most 2 of 3 pair terms cancellable at depth 1.
  (5,2,1),(4,3,1),(5,1,2),(4,1,3): counts 1 or 2.
  (3,3,2),(4,2,2): (3,3,2) has no c_i=1 -> NO substitution possible at depth 1.
So depth-1 substitution can never fully positivize a core CW equation. Deeper
substitution could still work (tail terms have zq^i prefactors matching the
-z(q+q^2)G_c(zq^3) part of the triple term) -> bounded-depth search needed (D1).

## Plan
- D1: bounded-depth substitution search for positive relations for the 7 core orbits
      (settles mission (b)(i); Seed 6 planned this, never ran it).
- D2: implement KR relations R1/R2/R3/R4 at m=11; verify numerically vs S_11;
      telescoping experiments on the frontier differences S(rho|sigma) - qS(rho'|sigma')
      (mission (b)(ii)/(c) bridge; Seed 5's recommendation 2).
- D3: structure-driven extension of the (4,3,1) formula to the 5 frontier orbits.
- D4: write the Uncu-style proof plan for mission (a); verify what's verifiable.

## Log

### Finding 1 (literature, structural — the d=5 template decoded)
Read warnaar_a2_andrews_gordon_cylindric_partitions/source.tex lines 2190-2620 in full.
Warnaar's mod-8 (d=5) proof of positivity for the core was:
  (1) Thm_GK-mod8: positive triple-sum FERM forms for (2,2,1),(3,2,0),(4,1,0),(5,0,0)
      [proved via transformations Eq_ksum/Eq_ksum2 from ASW Bailey-machinery seeds].
  (2) Prop_remainingcases: GUESSED positive forms for (3,1,1),(4,0,1),(3,0,2) with
      richer numerators, then VERIFIED by substituting into CDU eqs (3.17)-(3.19)
      == exactly Seed 6's R-relations R_(4,0,1), R_(3,0,2), R_(3,2,0) — which uniquely
      determine the three unknowns (triangular in z-shift/n).
  So Warnaar's core mechanism at d=5 IS Seed 6's Propagation-Theorem system, run in
  "determine the core from a known zero-containing LHS" mode: R_(3,2,0) has KNOWN LHS
  and its only unknown is (3,1,1) (appearing at two z-shifts -> triangular in n).

The positive-numerator DISTORTION MOVES in Prop_remainingcases (the template for d=8):
  (i)   additive constant: 1 or zq;
  (ii)  bottom-shifted binomial [n1+n2-1; m1] (top reduced by 1);
  (iii) factor (1 + q^{m1-n1+n2+1});
  (iv)  term with 1/(q)_{n1-1} and shifted binomials [n1-1;n2][n1+n2-1;m1-1].

### Finding 2 (structural obstruction at d=8 — why d=8 is harder than d=5)
At d=5: knowns {(5,0,0),(4,1,0),(3,2,0),(2,2,1)}; the R-system with known LHS
R_(3,2,0) contains exactly ONE unknown (3,1,1). Triangular.
At d=8: knowns (Conj 2) {(8,0,0),(7,1,0),(6,2,0),(5,3,0),(3,3,2)}. R-relations with
known LHS: R_(7,1,0), R_(6,2,0), R_(5,3,0) — but their RHS unknowns are
{(7,0,1),(6,1,1),(5,2,1),(4,3,1),(4,1,3),(5,1,2)}: 3 equations, 6 unknowns.
Moreover (4,2,2) appears in NO R-relation (head or tail) at d=8 — it is reachable
only through core CW equations (or (3,3,2)'s CW equation). The R-system alone is
UNDERDETERMINED for the core at d=8; extra equations must come from |I_c|=3 CW
equations of core profiles. This is the precise sense in which d=8 core is the frontier.

---
## RESUMED (continuation agent, same mission) — predecessor died after Finding 2

### Finding 3 (literature, the complete d=5 distortion catalogue)
Read Prop_remainingcases in full (source.tex 2190-2420). Relative to the covered-orbit basis
(triple sum, QF = n1^2-n1m1+m1^2+n2^2, binoms [n1;n2][n1+n2;m1], denom (q)_{n1}, z^{n1}),
Warnaar's manifestly positive forms for the d=5 hard orbits use exactly four DISTORTION MOVES:
  M0: additive monomial 1 (or zq);
  M1: binomial-top shift [t;m1] -> [t-1;m1] WITH factor (1+q^{m1-(t-1)+m2}), t=n1+n2, m2=2n2
      (exponent simplifies to m1-n1+n2+1); the shifted binomial [n1+n2-1;m1] VANISHES at n1=0,
      which is what the additive 1 restores (Q_0 = 1).
  M2: extra term with denom (q)_{n1-1}, binoms [n1-1;n2][n1+n2-1;m1-1], its own linear term;
  M3: extra term with denom (q)_{n1-1}, binoms [n1-1;n2][n1+n2-2;m1-1] and the M1 factor.
Catalogue:
  (3,1,1) = 1 + M1-distortion of the (3,2,0) form (lin m1).      [(3,1,1) = head of R_(3,2,0)]
  (4,0,1) = 1 + M1(lin n1+m1) + M2(lin n1+n2-1).                 [(4,0,1) = head of R_(4,1,0)]
  (3,0,2) = zq + base(lin n1) + M3(lin n1-1) + M2(lin 2n1+n2-1).
KEY: M1 does NOT change the denominator (q)_{n1}, so an M1-only form gives Q_n = delta_{n,0} +
(manifestly positive finite sum) — positivity at the Q-level for free. M2/M3 have (q)_{n1-1}
denominators, giving (1-q^n) factors at the Q-level (the CDU wall).

### Finding 4 (k=3 lift of the moves — exponent rule is uniform)
In the Warnaar k=3 basis (5-fold sum n1,n2,n3,m1,m2; m3:=2n3;
QF = n1^2+n2^2+n3^2-n1m1-n2m2+m1^2+m2^2; binoms [n1;n2][t1;m1][n2;n3][t2;m2],
t1 = n1-n2+m2, t2 = n2-n3+m3), the M1 move lifts with the SAME cancellation:
  M1(i=1): [t1-1;m1], factor 1+q^{m1-(t1-1)+m2} = 1+q^{m1-n1+n2+1}   (m2 cancels!)
  M1(i=2): [t2-1;m2], factor 1+q^{m2-(t2-1)+m3} = 1+q^{m2-n2+n3+1}   (m3 cancels!)
Both shifted binomials vanish at n1=0, so "1 + M1" keeps Q_0 = 1.
Covered-orbit lin vectors (a1,a2,a3,b1,b2): (8,0,0)=(1,1,1,1,1), (7,1,0)=(0,1,1,1,1),
(6,2,0)=(0,0,1,1,1), (5,3,0)=(0,0,0,1,1), (3,3,2)=(0,0,0,0,0).
R-head pairing predicts: (5,2,1) ~ 1+M1 distortion of (5,3,0); (6,1,1) ~ 1+M1 of (6,2,0).

### D3 plan (now running): scan Q_n^{cand} = delta_{n,0} + ferm_M1(n; lin, i) over
lin in {0,1}^5, i in {1,2}, for the 5 frontier orbits, n=1..3 (PREC 200), verify hits at n=4 (PREC 300).

### Finding 5 (negative: the naive M1 lift fails at k=3)
Ran seed2_R2L3_frontier_fit.sage: scan Q_n^cand = delta_{n,0} + ferm_M1(n; lin, i) over all
lin in {0,1}^5, i in {1,2}, for the 5 frontier orbits, n=1..3, PREC 200. Covered-orbit
sanity (5 orbits, lin vectors of Finding 4) ALL PASS — the basis and conventions are right.
Frontier hits: ZERO. The d=5 "(3,1,1) = 1 + M1(3,2,0)" template does NOT lift naively.
Frontier forms need richer distortions (M2/M3 lifts, or two-term (4,3,1)-style shapes).

### Finding 6 (THEOREM — Conjecture 2 at k=3 for the balanced orbit (3,3,2), d=8)
The chain, every link proved in the literature:
  (1) Warnaar Prop_finiteform, a=-1, k=3 (PROVED, source.tex Sec 7): polynomial identity
      for F^{(-1)}_{n0,m0;3}. Take n0,m0 -> infinity (coefficientwise stabilization):
        FERM_{(3,3,2)}(z,q)/(q;q)_inf = T(z,q),
      where T is the 6-fold ASW-type sum over r1>=r2>=r3>=0, s1>=s2>=s3>=0 with
      z^{r1}, exponent sum(r_i^2 - r_i s_i + s_i^2) + 2 r3 s3, denominator
      (q)_{r1-r2}(q)_{r2-r3}(q)_{s1-s2}(q)_{s2-s3}(q)_{r3}(q)_{s3}(q)_{r3+s3}.
      (The +n3m3 from sigma_3 = -1 is exactly Uncu's 2 r3 s3 folding.)
  (2) Pochhammer split (exact algebra): 1/(q)_{r3+s3} = (1 - q^{r3+s3+1})/(q)_{r3+s3+1},
      and q^{r3+s3+1} = q * q^{r3} * q^{s3} shifts (rho_3, sigma_3) by (1,1):
        T = S_11(e_3|e_3) - q S_11(e_2|e_2)  =: D1.
  (3) KR relation R3(rho|sigma) for m == -1 mod 3, sigma_{k-1}=0 (PROVED, KR Lemma 9.1;
      Uncu Lemma lemma:recs) at rho = sigma = (0,0,0):
        S(e_3|e_3) - S(e_3|e_2) - q S(e_2|e_2) + q S(e_2|e_1) = 0
      i.e. D1 = S_11(e_3|e_2) - q S_11(e_2|e_1) =: D2, EXACTLY (bridging identity is
      a single instance of a proved contiguous relation — no ideal search needed).
  (4) Uncu 2024 thm:m11 (PROVED): D2 = H_{(3,3,2)}(z,q).
  => FERM_{(3,3,2)} = (q)_inf H_{(3,3,2)} = G_{(3,3,2)}, hence
     Q_{n,(3,3,2)}(q) = (q)_n [z^n] FERM_{(3,3,2)} = manifestly positive finite sum
     (the (q)_{n1} denominator cancels at n1 = n).  Q_{n,(3,3,2)} >= 0 for all n: THEOREM.
This is (i) the first proved case of Warnaar's Conjecture 2 at k=3, and (ii) the first
proved-positive CORE orbit at d=8. Core shrinks 7 -> 6:
remaining {(6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2)}.

Numerical verification (seed2_R2L3_s11_chain.sage, PREC 300, compare to q^150):
  [A] D1 == D2 at z-orders n=0..4: PASS (independent of step (3)'s algebra).
  [B] (q)_n (q)_inf [z^n] D1 == Q_n^{(3,3,2)} ground truth (seed5_R2L2_qn_d8.json),
      n = 0..4: PASS. Combined with frontier_fit's covered sanity (FERM == Q_n for
      (3,3,2)), this confirms step (1)'s limit end-to-end at z-orders 0..4.

### Finding 7 (extensions and the template for the frontier)
(a) a=+1: Warnaar's F^{(1)} finite form (also PROVED) should give the SAME chain at
    m=13 (d=10) for the balanced orbit (4,3,3) via Uncu thm:m13. Caveat: m=13 == 1 mod 3,
    so the bridging relation is the m==1 R3/R4 variant (note: Uncu's displayed R31 has
    two identical terms with opposite signs — likely a typo; re-derive from KR Lemma 9.2
    before relying on it). Also k>=4 versions of Prop_finiteform reduce the balanced case
    of Con_cylindric at EVERY level to the KR/Uncu conjecture (proved for m=11,13 only).
(b) Why (3,3,2) was the lucky orbit: the Pochhammer merge (un-split) requires the two
    S-terms of Uncu's difference to differ by exactly (+delta_3|+delta_3) with weight q.
    Uncu's raw differences never have this shape; for (3,3,2) ONE application of R3
    produces it. For the frontier orbits the shift pairs are:
      (4,2,2): S(e2|e2) - qS(e1|e1), e1 = e2 + delta_2  (delta_2 shift, not delta_3);
      (6,1,1): S(e1|e1) - qS(e0|e0), e0 = e1 + delta_1;
      (5,2,1): S(e2|e1) - qS(e1|e0); (5,1,2): S(e1|e2) - qS(e0|e1);
      (4,1,3): S(e1|e3) - qS(e0|e2); (4,3,1): S(e3|e1) - qS(e2|e0).
    Template attack (handoff): use R1/R2 (proved) to move the delta_2/delta_1 shifts down
    to delta_3 (each R1/R2 application costs one extra z q^{...} S-term), reach a
    mergeable pair + controlled remainder, un-split to a T-shaped single sum, and match
    against a Warnaar-type finite-form/Bailey transformation to eat (q)_inf. The a=-1
    vs a=+1 dichotomy suggests looking for F^{(a)}-variants with other sigma patterns
    (Warnaar has F^{(a)}_{k,s,t} variants near source.tex line 3001 for the
    (3k-s,s-1,0) family — those cover the c2=0 orbits; frontier needs new seeds).

## Handoff

### PROVED this layer (see proofs/prove-seed2-layer3.tex, compiled)
THEOREM: G_{(3,3,2)} = FERM_3 (Warnaar Conjecture 2, k=3), hence Q_{n,(3,3,2)} >= 0
for all n as a manifestly positive fermionic polynomial. Proof = 4-link chain of
PROVED results: Warnaar Prop_finiteform(a=-1,k=3) limit -> Pochhammer split ->
KR relation R3((0,0,0)|(0,0,0)) -> Uncu thm:m11. Numerically verified n=0..4,
PREC 300 (seed2_R2L3_s11_chain.sage: checks [A],[B] all PASS).
CONSEQUENCE: d=8 core shrinks 7 -> 6: {(6,1,1),(5,1,2),(4,1,3),(4,3,1),(5,2,1),(4,2,2)}.

### For the next agent (in priority order)
1. d=10 balanced orbit (4,3,3): same chain with a=+1 / S_13 / Uncu thm:m13.
   CAUTION: Uncu's displayed R3 for m==1 mod 3 has a typo (two cancelling identical
   terms); re-derive the correct relation from KR arXiv 2022 Lemma 9.2 first.
   Expected outcome: second proved case of Conjecture 2, first proved core orbit at d=10.
2. Frontier template (Finding 7b): for each remaining core orbit, search SHORT words in
   the proved relations R1^{(i)}, R2^{(i)}, R3, R4 that turn Uncu's difference
   S(e_a|e_b) - qS(e_{a-1}|e_{b-1}) into [mergeable (+delta_3|+delta_3) pair] + remainder,
   where the remainder is itself (q)_inf-compatible. This is a small symbolic search
   (relations are explicit, depth <= 3-4 should be exhaustable). The merged T-shaped sum
   then needs a Warnaar-type finite form; his F^{(a)}_{k,s,t} variants (source.tex ~line
   3001) are the seed catalogue — they cover the (3k-s,s-1,0) family; frontier orbits
   likely need sigma patterns beyond (1,...,1,a).
3. Do NOT retry: naive M1-only fermionic fits for frontier orbits (Finding 5, exhausted
   over lin in {0,1}^5 x i in {1,2}); depth-1 CW substitution positivization (predecessor's
   counting obstruction); H-level positivity as a route to Q-positivity (wrong direction).
4. Ground truth: seed5_R2L2_qn_d8.json (n<=4). If deeper n needed, regenerate via the CW
   recursion (seed5 layer-2 scripts).

### Scripts
- scripts/seed2_R2L3_frontier_fit.sage — ferm basis + M1 scan (covered sanity harness).
- scripts/seed2_R2L3_s11_chain.sage — S_11 implementation + chain verification.
