# Prove — Seed 3 Layer 4 (Round 2): Construct the positive y-system at d=7 (Template B)

Mission (synthesis-layer3.md §6 Mission 3): d=7 (modulus 10), smallest level with NO proof
anywhere. Build the CW-style Eq:Fun analogue: manifestly positive y-functional system,
uniqueness induction, exact verification vs engine.

Convention: synthesis-layer3.md §4(iv) — TRUE conjecture.tex labels, target-first kernel
q^{m·EMD(c,c')}. Reference engine scripts/seed8_R2L3_engine.sage (Sage not installed on this
machine — I port it faithfully to exact-ℤ[q] Python and cross-validate against brute-force
enumeration of cylindric partitions, the raw ground truth, before using it).

## 0. Setup and structural map (before any code)

d=7, k=3, modulus t=10. K = (8·9)/6 = 12 orbits: 7 zero-containing + 5 core (all-positive).

Core orbit reps (rotation orbits): (5,1,1), (4,2,1), (4,1,2), (3,3,1), (3,2,2).
Zero-containing: (7,0,0), (6,1,0), (6,0,1), (5,2,0), (5,0,2), (4,3,0), (4,0,3).

CW raw system (Prop incex of corteel_welsh_A2_RR/source.tex, Eq:INEX / Gb):
  G_c(y) = Sum_{0!=J subset I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(y q^{|J|}),  G_c(0)=G_c(y,0)=1.
For |I_c|=3 (core c), with e_i cyclic (indices mod 3, c=(c1,c2,c3)):
  singles  c({i})     = c - e_i + e_{i+1}   (3 terms, +, shift yq)
  pairs    c({i,i+1}) = c - e_i + e_{i-1}   (3 terms, -(1-yq), shift yq^2)
  triple   c({1,2,3}) = c                   (+(1-yq)(1-yq^2), shift yq^3)

### Key structural observation (re-derivation of the CW manipulation, by hand)

Positive core row at d=4 derived from the raw system by three substitutions:
substitute positive rows for the singles; each single s_i = c-e_i+e_{i+1}, if its positive
row has head in direction i+1 (head = s_i - e_{i+1} + e_{i+2}), then the substituted head
lands at yq^2 exactly on pair c({i,i+1}) = c - e_i + e_{i-1}  [since -e_i+e_{i+1}-e_{i+1}+e_{i+2}
= -e_i+e_{i-1}], cancelling -(1-yq)*pair to +yq*pair. The remaining pair, substituted by its
own row, puts its head at yq^3 against the triple term. At d=4 this yields
  G_A(y) = G_A(yq) + yq G_A(yq^2) + yq G_B(yq^2) + (yq^3+y^2 q^4) G_C(yq^4) + (yq^2+y^2 q^3) G_A(yq^3)
(A=(2,1,1), B=(2,2,0), C=(3,1,0)) — positive, all shifts >= 1; a VARIANT of CW's Eq:Fun row
(rows are non-unique). Mechanism generalizes; head-DIRECTION matching is the constraint.
[TO BE MACHINE-VERIFIED in Phase 1.]

### Uniqueness + positivity for free (important simplification)

If every orbit has a row G_c(y) = Sum_i m_i(y,q) G_{c_i}(y q^{s_i}) with m_i in N[y,q] and
all shifts s_i >= 1, then extracting [y^n]: g_c(n) = Sum (y^0-terms) q^{s n} g_{c'}(n) + (lower y-degree).
The fixed-n system has matrix M with entries in q^{>=n} N[q]; (I-M)^{-1} = Sum M^k is q-adically
convergent and NONNEG. So the system uniquely determines all g's from g(0)=1 AND transmits
bivariate positivity automatically. CW's (1-q^n) division is the special case of a self-head.
Uniqueness induction = q-adic contraction (Thm:G's induction, repackaged).

### d=7 core single/pair table (orbit reps after rotation-reduction)

c=(5,1,1): singles (4,2,1),(5,0,2),(6,1,0); pairs (4,1,2),(6,0,1),(5,2,0).
c=(4,2,1): singles (3,3,1),(4,1,2),(5,2,0); pairs (3,2,2),(5,1,1),(4,3,0).
c=(4,1,2): singles (3,2,2),(4,0,3),(5,1,1); pairs (3,3,1),(5,0,2),(4,2,1).
c=(3,3,1): singles (4,1,2)~(2,4,1),(3,2,2),(4,3,0); pairs (3,2,2)~(2,3,2),(4,2,1),(4,0,3)~(3,4,0).
c=(3,2,2): singles (3,2,2)~(2,3,2) SELF,(3,3,1)~(3,1,3),(4,2,1); pairs (3,2,2)~(2,2,3) SELF,(4,1,2),(3,3,1).

## Plan

1. [code] Exact engine (pure Python, Z[q] dicts): g_c(n) at d=7 for all 36 profiles from the
   raw CW system (q-adic fixed point per y-level), truncated series prec ~ 150-200.
   Cross-checks: (a) brute-force cylindric enumeration (F_{c,m} ground truth, small);
   (b) port of seed8 engine H-recursion + gauss_a: Q_n = (q;q)_n g_c(n), pin label map.
2. [code] Verify Seed 6 L2 R-relations (Family A/B) at d=7, all 7 zero-containing orbits +
   enumerate head-direction VARIANTS (needed for direction matching in step 3).
3. [code] Substitution engine on expressions {(profile, shift) -> Z[y,q]-coeff}: derive
   positive rows for the 5 cores. Every derivation step is exact algebra on valid identities
   -> resulting rows are PROVED, not fitted. Numeric verification vs engine at each step.
4. Uniqueness induction (automatic by the contraction remark) + writeup; consequence:
   bivariate g-positivity for ALL orbits at d=7.
5. Stretch: explicit 3-fold-sum solutions of the system (Thm:G analogue) -> bounded forms ->
   Q-positivity. Record partial fits if not finished.

## Log

(incremental below)

### Phase 1 (engine) — DONE, all checks PASS

scripts/seed3_R2L4_engine.py (pure Python, exact ints; PREC=200, NMAX=8):
- g_c(n) for all 36 profiles at d=7 from the raw CW system (Gb form), q-adic fixed point
  per y-level. Rotation invariance: PASS.
- Brute-force cylindric enumeration (conjecture.tex interlacing) vs
  F_{c,m} = Sum_{n<=m} g_c(n)/(q;q)_{m-n} (Euler): PASS, all 12 orbits, m<=2, T=14.
  (First attempt used F=Sum g — wrong relation, mine not the engine's; fixed.)
- seed8 engine port (target-first kernel, exact division by 1+q^m+q^2m): H to m=8;
  gauss_a(H,c,n) == (q;q)_n g_c(n) for all 12 orbits, n<=8, IDENTITY label map: PASS.
  So CW-note profile labels = conjecture.tex labels directly at d=7 (consistent with
  synthesis-layer3 §4(iv).4).
- Q_n(1) = 11^n (K-1 = 11): PASS.

Conclusion: g and Q at d=7 are pinned, exact to q^200, n<=8. Q_{n,c} >= 0 observed for all
12 orbits n<=8 (consistent with Y1's d=7 n<=18).

### Phase 2 (construction machinery) — RESUMED session; CW d=4 move set re-derived

Re-derivation of CW's Eq:Fun (2,1,1) manipulation shows the COMPLETE move set (my earlier
"Key structural observation" had only half):
  (M-a) HEAD CANCELLATION: substitute a positive row (unit y^0 head at shift 1) into a
        single term G_s(yq); the head +G_{head(s)}(yq^2) cancels a pair -G_p(yq^2) iff
        orbit(head(s)) = orbit(p).
  (M-b) PAIR-TRICK (previously missing): substitute a row into the FULL negative pair
        term -(1-yq)G_p(yq^2). If the substituted head is c (the target itself), the new
        -G_c(yq^3) merges with the triple +(1-yq)(1-yq^2)G_c(yq^3):
        (1-yq)(1-yq^2) - (1-yq) = -yq^2(1-yq) — the y^0 negativity dies; residual
        -yq^2-type negatives must be absorbed by positive tails from (M-a) subs.
Every substitution is exact algebra on proved identities => any all-positive endpoint is
a PROVED row. y=0 budget: a positive row has exactly one unit y^0 term ("head").
Positive-class condition for uniqueness+positivity (contraction remark, §0): coeffs in
N[y,q], shifts >= 1 — nothing else needed (y^0 parts give matrix entries q^{a+sn}, val>=n).

Orbit-level head map of the zero rows (Family A/B give the SAME head orbit; to be
machine-checked): Z1(7,0,0)->Z2(6,1,0)->Z3(6,0,1)->C1(5,1,1); Z4(5,2,0)->C1;
Z5(5,0,2)->C3(4,1,2); Z6(4,3,0)->C2(4,2,1); Z7(4,0,3)->C4(3,3,1).

Paper analysis of C1=(5,1,1) (singles C2,Z5,Z2; pairs C3,Z3,Z4): Z5-head=C3 cancels p_0;
Z2-head=Z3 cancels p_1; p_2=Z4 needs C2's row with shift-1 head Z4 (=C2's single (5,2,0));
triple negatives -yq,-yq^2 G_C1(yq^3) cancelled by Z3-row head=C1 (subbed into surviving
+yq G_Z3(yq^2)) and Z2's first tail entry (5,1,1)=C1. So C1 reachable GIVEN C2-with-head-Z4:
a dependency DAG among core derivations exists on paper; machine search settles it.

Plan: scripts/seed3_R2L4_construct.py — exact Expr algebra {(orbit-rep, shift) ->
{(ypow,qpow): int}}, substitution move (exact), numeric verification of EVERY derived row
vs cached engine g (n<=8, q^200), mechanical Family A/B derivations for the 7 zero orbits,
then guided/beam search for the 5 core rows. If all 5 land: full positive system at d=7
=> uniqueness by q-adic contraction => bivariate positivity of G_c(y,q) for ALL d=7
orbits (G-level). Q-positivity remains the stretch (explicit forms + absorption).

### Phase 2 results (zero rows) — ALL PASS

scripts/seed3_R2L4_construct.py. Orbit-rep naming = min-rotation: C1=(1,1,5)~(5,1,1),
C2=(1,4,2)~(4,2,1), C3=(1,2,4)~(4,1,2), C4=(1,3,3)~(3,3,1), C5=(2,2,3)~(3,2,2);
Z1=(0,0,7), Z2=(0,6,1)~(6,1,0), Z3=(0,1,6)~(6,0,1), Z4=(0,5,2)~(5,2,0),
Z5=(0,2,5)~(5,0,2), Z6=(0,4,3)~(4,3,0), Z7=(0,3,4)~(4,0,3).

All 7 zero orbits: Family A and B derivations give the IDENTICAL orbit-level row (one
canonical R-row per zero orbit). All verified vs engine (n<=8, q^200) and manifestly
positive. Head map (as predicted): Z1->Z2->Z3->C1; Z4->C1; Z5->C3; Z6->C2; Z7->C4.
Rows are pure R-form: head at shift 1 + tail terms yq^i G_b(yq^{i+1}). Tail first-entries:
Z2 tail starts with C1; Z4 tail = [C2rot...] (see script output). These rows are PROVED
(mechanical Substitution-Lemma chains from raw CW rows, every step exact).

### Phase 3 (core rows) — beam search over exact substitution sequences

Library = 7 zero rows + raw rows (all 12 orbits) + previously-derived core rows.
Move = substitute a library row into a full term (always exact). Goal = all coeffs in
N[y,q], shifts >= 1. Iterate rounds: derive any core, add to library, repeat.
Paper dependency sketch: C2-with-head-Z4 suffices for C1; C2 needs C3-head-C1 and
C4-head-C5 + pair-trick on Z6-pair (Z6's head = C2 merges with triple); C3 needs C5;
C5,C4 mutually tangled -> search will settle (raw-row substitutions allowed).

### Phase 3 results (core rows) — ALL 5 FOUND, system COMPLETE

scripts/seed3_R2L4_search.py (beam search, log seed3_R2L4_search.log) +
scripts/seed3_R2L4_system.py (deterministic replay, log seed3_R2L4_system.log).

Positive rows for ALL 5 core orbits found as exact substitution chains:
  C1=(1,1,5): depth 3, head C2=(1,4,2)@1.  Path: sub raw[Z2=(0,6,1)] into (Z2,1);
     sub R[Z5=(0,2,5)] into (Z5,1); sub R[Z3=(0,1,6)] into (Z3,2).  5 terms.
  C3=(1,2,4): depth 5, head C5=(2,2,3)@1.  raw[C1]@(C1,1); raw[Z2]@(Z2,2);
     R[Z7]@(Z7,1); R[Z5]@(Z5,2); R[Z3]@(Z3,3).
  C4=(1,3,3): depth 7, head C5@1.  raw[C3]; raw[C1]; raw[Z2]; then R[Z6],R[Z7],R[Z5],R[Z3].
  C2=(1,4,2): depth 7, head C4=(1,3,3)@1.  raw[Z4]@(Z4,1); raw[C3]; raw[C1]; raw[Z2];
     then R[Z7],R[Z5],R[Z3].
  C5=(2,2,3): depth 3, head SELF@1 (CW (2,1,1) shape).  C4-row@(C4,1); C3-row@(C3,2);
     C2-row@(C2,1).
Exact paths hardcoded in seed3_R2L4_system.py PATHS (the proof object).

MECHANISM (new, different from CW d=4 depth-2): substitute RAW rows down a chain of
singles (core -> ... -> zero orbits) — negativity telescopes down the chain — then close
with the R-rows of the accumulated zero-orbit terms, which absorb all residual negatives.
Derivation DAG: zero rows -> {C1,C2,C3,C4} independently (raw+zero rows only) -> C5.

SYSTEM CHECKS (all PASS):
 (i)  all 12 rows manifestly positive: coeffs in N[y,q], shifts >= 1, unique unit y^0 head;
 (ii) uniqueness: standalone q-adic fixed-point solve of the positive system alone
      converges and is the contraction of §0 (level-n matrix entries have q-val >= n);
 (iii) exactness: standalone solution == raw-CW engine solution, ALL 12 orbits, n<=8,
      to q^200; every individual row verified vs engine likewise.
System saved: scripts/seed3_R2L4_system_d7.pkl.

CONSEQUENCE (Theorem): G_c(y,q) has nonnegative coefficients for ALL profiles at d=7 —
bivariate G-positivity, the d=7 core gap of Seed 6 L2's Propagation Theorem CLOSED.
This is Template B requirement (i)-(iii) fulfilled: the first CW-style positive system
at a level with no proof anywhere. Q-positivity (absorption/bounded forms) = stretch,
not reached. Next: proofs/prove-seed3-layer4.tex.

### Phase 4 — writeup + final status

proofs/prove-seed3-layer4.tex COMPILED (prove-seed3-layer4.pdf). Contents: conventions
(§4(iv) TRUE labels, identity map at d=7 pinned in Phase 1); raw CW system; Lemma 1
(7 zero R-rows, Family A/B mechanical); Lemma 2 (5 core rows with explicit substitution
chains as proofs); Theorem (system properties (i)-(iii)); uniqueness by q-adic
contraction (level-n matrix entries have q-valuation >= n); Corollary: bivariate
positivity G_c(y,q) in N[[y,q]] for ALL profiles at d=7.

## Handoff

### State: FULL SYSTEM CONSTRUCTED (mission requirements (i),(ii),(iii) all met)

### Claim classification
- 12 positive rows: GREEN-pending-verifier. Each is DERIVED (finite exact substitution
  chain from CW Prop incex instances; chains hardcoded in seed3_R2L4_system.py PATHS,
  deterministic replay) AND verified numerically vs the Phase-1-validated engine
  (all 12 orbits, n<=8, exact to q^200). Not fitted anywhere.
- Uniqueness + positivity transmission (Theorem/Corollary): GREEN-pending-verifier
  (half-page contraction argument, hand-checkable; standalone fixed-point solve of the
  positive system reproduces engine exactly — computational witness of uniqueness).
- Corollary G-positivity at d=7 (bivariate, all orbits): NEW — first positivity result
  of any kind at the smallest unproved level; d=7 core gap of the Propagation Theorem
  closed at the G-level.
- Q-positivity at d=7: NOT claimed. Needs Thm:G-style closed forms solving the system
  + absorption lemmas ((1-q^n) walls). C5's self-head at shift 1 reproduces exactly the
  CW (1-q^n)-division shape — the expected entry point for the bounded-form step.

### Gaps / recommendations for next layer
1. VERIFY: independent replay of seed3_R2L4_system.py + referee pass on the tex.
2. STRETCH (the remaining half of Template B at d=7): solve the system in closed form.
   The zero rows + head graph (C1->C2->C4->C5<-C3, C5 self) suggest trying 3-fold-sum
   ansatz for C5 first (self-head = the (2,1,1) analogue), then propagating through
   heads. Then absorption lemmas (G9 mechanism) for Q_n >= 0.
3. GENERALIZE: the telescoping-chain mechanism (raw rows down a single-chain, close with
   R-rows) looks d-uniform — worth attempting at d=8 for the 6 remaining core orbits
   (Y9/Mission 2 complement) and at general d.
4. Search hygiene: beam search found all 5 cores in <15 min total (depths 3,5,7,7,3);
   beam 400, SMAX 12, YMAX 4 sufficed. seed3_R2L4_search.log has full traces.

### Files
scripts/seed3_R2L4_engine.py (+ gcache), seed3_R2L4_construct.py, seed3_R2L4_search.py
(+log), seed3_R2L4_system.py (+log, +seed3_R2L4_system_d7.pkl);
proofs/prove-seed3-layer4.tex/.pdf.
