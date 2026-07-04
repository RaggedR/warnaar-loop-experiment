# Seed 5, Layer 3, Round 2 — Crystal operators on chains: f_0^(m) >= 0 structurally

Mission: prove f_0^(m) = (1-q^m) g_m - q g_{m-1} >= 0 (first level of the Bounded
Fermionic Form conjecture / Monotonicity-adjacent bottleneck) via crystal theory on
the chain model, per Layer-2 Seed 8's escalation. Toolbox: Tingley-style affine
crystal operators, Demazure/string decompositions, signature rule. DISJOINT from
Seed 1 (q-Pascal/U-tower) and Seed 3 (direct injection/difference analysis).

## What is already known (inherited, do NOT redo)

- Chain model (Seed 8 L2, GREEN): CP of profile c, max <= m <=> chain
  a^(1) >= ... >= a^(m) componentwise, a^(s) in
  S = { a in Z_{>=0}^3 : a_i <= a_{i-1} + c_i, i in Z/3 }.
  Weight = sum_s |a^(s)|. Max EXACTLY m <=> a^(m) != 0.
  Slack lemma: every a in S has a slack coordinate (tight set never all of Z/3, d>=1).
  Switch lemma: i tight at a, slack at b, a >= b ==> a_i > b_i strictly.
- phi: C_{m-1} -> C_m weight +1 injective (GREEN, Round 1): append bottom level
  a^(m) := e_i at canonical index; image = chains with |a^(m)| = 1 + canonicity.
- f_0^(m) >= 0 <=> exists injective TOTAL weight+m map psi: C_m -> C_m with image
  disjoint from im(phi). Disjointness is free if im(psi) has |bottom| >= 2.
- THREE FAILED DESIGNS (Seed 8 L2 — do not retry): greedy least-slack ribbon
  (total, not injective; collision at c=(1,1,1), m=2); claim-based alpha (injective,
  not total; orphans for every profile); top-level add (circular). Diagnosis: local
  box-adding rules lose information or totality; need GLOBAL canonical structure.
- Dead: Kyoto truncation (BA18), B^{d,1} column crystals for d>2 (nonexistent,
  Seed 2 L2), KR row-crystal energy matching (BA19).
- Monotonicity (H_m >= H_{m-1}) is NOT the same statement as f_0^(m) >= 0
  (synthesis 5(a)): subtracted terms differ (q^m F_{c,m} vs q g_{m-1}).

## Angle of attack

"Add a part of size m to component i" = add e_i to ALL m levels of the chain = the
natural weight+m candidate psi. Well-defined iff coordinate i is SLACK AT EVERY
LEVEL (call i globally slack). Two failure modes to overcome:
  (T) totality: a chain may have no globally slack coordinate;
  (I) injectivity: choice of i must be recoverable from the image.
The crystal-theoretic resolution of exactly this dilemma is the signature rule:
bracketing/matching makes the choice global-canonical and reversible (e~ f~ = id).
Plan: realize the ribbon/column moves as (compositions of) affine crystal operators
on the cylindric partition (Tingley), where injectivity is structural.

## Session log

### [continuation agent, same mission] Session start

Predecessor died right after writing the plan. Continuing.

RAG recon done:
- tingley/chunk_028: Tingley DOES define crystal operators directly on cylindric
  plane partitions: A_i(pi) = addable i-colored boxes, R_i(pi) = removable,
  brackets ordered by t(x,y,z) = nx/l + y - z, f_i adds at first uncancelled "(".
  Erratum note (chunk_007): Section 4.2 (CPP crystal) was CORRECTED post-publication
  — treat conventions with care, verify axioms computationally.
- KEY ORIENTATION FACT worked out from chunk_028's periodicity (x,y,z) ~ (x+l, y-n, z):
  x = slice index, l = # slices per period = 3 for us, n = total profile shift per
  period = d. So Tingley's crystal on OUR rank-3 CPs is sl_d-hat, LEVEL 3, colors =
  content mod d (the rank-level DUAL of the sl_3-hat level-d structure everyone else
  used). Colors mod d are consistent around the cylinder precisely because the total
  j-shift per period is d == 0 mod d. The sl_3-hat coloring (mod 3) is NOT consistent
  on the cylinder for gcd(d,3)=1 — this may be WHY B^{d,1} column crystals died
  (Seed 2 L2): the natural crystal on the CP itself is the dual one.
  Caveat: Tingley requires n >= 3, i.e. d >= 3. (d=2 solved anyway.)

Plan for this session:
1. Chain-model enumeration + exact f_0^(m) tables (verify vs H-recursion).
2. Deficit analysis: how tight is the required injection psi (coefficientwise
   slack of f_0^(m))? Where are the forced-bijective weights?
3. Implement Tingley color-(mod d) operators on BOUNDED chains (z <= m), test
   e_i f_i = id and totality (some f_i defined) on C_m.
4. Design psi from the operators; test injectivity/totality exhaustively.

## Computational Evidence (session 2)

Script seed5_R2L3_chains.py (chain enumeration, exact) + seed5_R2L3_directCP.py
(direct CP defn from conjecture.tex):
- f_0^(m) >= 0 verified for d=4 (all 5 orbit reps), d=5, d=7 samples, m <= 4, W <= 12.
- Convention finding (settles a piece of C2): the chain model at profile c
  (constraints a_i <= a_{i-1} + c_i) EXACTLY matches the direct CP definition at
  c = (c_1,c_2,c_3). The synthesis EMD-formula H-recursion at profile c matches the
  chain model at the REVERSED profile (checked: gH[(0,3,1)] = direct[(0,1,3)] =
  direct[(1,3,0)]; chain[(0,3,1)] = direct[(0,3,1)] = direct[(3,1,0)]).
  All other tested profiles are reversal-symmetric orbits, which is why only
  (0,3,1) exposed the flip. Layer-3 Missions using the EMD formula must reverse.
- Tightness data (how much room psi has): f_0 at d=4,(0,2,2), m=2: [0,0,0,1,5,7,11,...];
  at (4,0,0) m=1: [0,0,1,1,1,0,1,0,...] — ZERO coefficients at arbitrarily high weight
  for m=1 (f_0^(1) is eventually 0 since (1-q)g_1 -> finitely supported... indeed
  g_1 coefficients stabilize at K_1 = #states, so (1-q)g_1 - q g_0 is a POLYNOMIAL).
  The injection is forced to be EXACTLY bijective at all large weights for m=1.
  => any valid psi/Theta pair is very rigid at m=1. Good stress test for designs.

Next: Tingley operators (colors mod d, t-order) on bounded chains.

## RESULT 1 (verified, exhaustive small cases): bounded Tingley operators exist

Script seed5_R2L3_crystal.py. Define on bounded chains (max <= m, i.e. length-m
chains incl. bottom-zero) colored operators, colors kappa in Z/d:
- boxes (i,j,s), present iff a_i^(s) >= j; color(i,j,s) = (s - j + Off_i) mod d,
  Off_i = c_1 + ... + c_i (per-component partial sums of profile, Off_0 = 0);
- t-order T(i,j,s) = d*i + 3*(j - Off_i - s)  [= 3*(Tingley's t), global row coord
  y_glob = j - Off_i is ESSENTIAL — with naive per-component rows closure fails];
- addable boxes of color kappa -> "(", removable -> ")", sorted by T increasing,
  cancel "()", f_kappa adds at leftmost surviving "(", e_kappa removes at rightmost
  surviving ")".  BOUNDED: only boxes with s <= m enter (no s = m+1 addables).
Findings (exhaustive, d=4 c=(2,1,1) m=2 W=9 / m=3 W=10, c=(0,2,2) m=2 W=9,
d=5 c=(3,1,1) m=2 W=9):
- closure: f_kappa(A) and e_kappa(A) are always valid bounded chains (interlacing
  preserved) — 0 failures in ~5000 operator applications. Convention sensitive:
  the other 3 (sgn,tdir) conventions FAIL closure; this one is Tingley's.
- e_kappa f_kappa = id and f_kappa e_kappa = id where defined — 0 failures.
So: each f_kappa is a canonical injective weight+1 partial self-map of the bounded
set. The max <= m truncation is CRYSTAL-CLOSED for these mod-d operators (unlike
the mod-3 route). This is the global canonical structure Seed 8 L2 asked for.

Next: component structure, phi/eps stats, totality, and psi design.

## RESULT 2 (exhaustive small cases): totality + unique sources

Script seed5_R2L3_explore.py:
- EVERY bounded chain (incl. zero chain) has some f_kappa applicable (0 exceptions,
  d=4 m=2,3, d=5 m=2). "Level > 0" survives the bound.
- Sources (no e_kappa) are rare and structured: weights are multiples of d;
  e.g. c=(2,1,1) m=3: empty; ((2,1,1),0,0); ((3,3,2),0,0); ((2,1,1),(2,1,1),0).
  One source per (W-truncated) component.

## Approach (proof architecture) — REDUCTION TO A SINGLE MAP

Let X = all length-m bounded chains (max <= m; bottom may be zero);
X_k = {max <= k} inside X; C_m = X \ X_{m-1}. Suppose J: X -> X satisfies:
 (J1) total on X, weight +1, INJECTIVE;
 (J2) J adds boxes only (so J(C_m) subseteq C_m);   [true for any f_kappa-built J]
 (P)  for A in X_{m-1} \ X_{m-2}: J(A) in C_m (a box gets added at level m).
Then:
 - J^m|_{C_m}: C_m -> C_m injective, weight +m, image inside J(C_m).
 - Theta := J|_{X_{m-1}\X_{m-2}}: (C_{m-1} embedded) -> C_m weight +1, image inside
   J(X \ C_m), hence DISJOINT from J(C_m) >= J^m(C_m) by injectivity of J. Wait:
   J^m(C_m) = J(J^{m-1}(C_m)) subseteq J(C_m), and Theta-image subseteq J(X\C_m);
   J injective => J(C_m) cap J(X\C_m) = empty. DISJOINT. OK.
 - Hence g_m >= q g_{m-1} + q^m g_m, i.e. f_0^(m) >= 0. QED modulo J.
So THE WHOLE BOTTLENECK reduces to: one canonical total injective weight+1
self-map J of the bounded chain set, with the bottom-filling property (P).
Candidate J's: f_kappa at canonical kappa (least color; or globally t-extreme
addable box). Note (P) heuristic: boxes at bottom level have the most negative
T, so a t-extreme rule should prefer them.

## RESULT 3 (NEGATIVE, exhaustive): the single-J reduction is IMPOSSIBLE

Scripts seed5_R2L3_Jtest.py, seed5_R2L3_Jfix.py, seed5_R2L3_hall.py.
(a) Source-side rules (least color / t-min / s-max f_kappa): all fail INJECTIVITY
    (the color used is not recoverable from the image). Dozens of collisions each.
(b) Image-side fixed-point rules (J(A)=f_k(A) where k = K(f_k(A)) for canonical K;
    injectivity STRUCTURAL since A = e_{K(B)}(B)): all fail TOTALITY (FP empty for
    8-116 chains per case, three K rules tried).
(c) DECISIVE: Hopcroft-Karp Hall test. A J satisfying (J1)(J2)(P) requires a
    saturating (P)-constrained matching X_w -> X_{w+1} in the one-box graph.
    FAILS: crystal-f edges fail at many weights (d=4 (2,1,1) m=3: 12/15 at w=3);
    even ARBITRARY single-box edges fail (any-box 12/15 at w=3, m=3; also m=2 for
    (0,2,2),(4,0,0),(0,3,1)). So NO single total injective weight+1 box-adding map
    with bottom-fill property (P) exists, crystal or not. The J-reduction (previous
    section) is a dead architecture. This EXPLAINS structurally why Seed 8 L2's
    local one-box designs kept failing: they were instances of an impossible spec
    whenever iterated/uniform.

## RESULT 4 (POSITIVE, exhaustive): the JOINT containment pair EXISTS

Script seed5_R2L3_hall2.py. Correct architecture: co-designed pair
  Theta: C_{m-1} -> C_m weight+1, psi: C_m -> C_m weight+m, JOINTLY injective,
  both CONTAINMENT maps (image contains source as box sets).
Joint Hall test (left = C_{m-1,w-1} + C_{m,w-m}, right = C_{m,w}, edges = levelwise
containment with right box count): saturating matching EXISTS at every weight for
ALL tested cases: d=4 all 5 orbit reps m<=3 (m=4 for (2,1,1)) W<=10; d=5 both
orientations m=2; d=7 (3,2,2) m=2. So the design space is nonempty, but the maps
MUST be co-designed (psi adds m boxes at once, not m iterated single-box steps,
and Theta/psi negotiate images jointly). Any future injection design should target
this spec, not the single-J spec.

## Session 3 (second continuation agent)

Predecessor #2 died with UNLOGGED work on disk: scripts seed5_R2L3_comp.py,
_factor.py, _beta.py, _beta2.py (timestamps after RESULT 4). Reconstructed, fixed
two bugs (m=0 recursion in beta2; m=1 edge case in the s-telescoping), ran all,
extended to new d's and higher m/W. Everything below is verified output, logs in
scripts/seed5_R2L3_*.log.

Notation. X_m = bounded chains (max <= m, bottom may be 0), G_m = GF(X_m) = F_{c,m}
(chain-model convention = direct conjecture.tex profile c, NOT the EMD-reversed
one — see Session-2 convention note). C_m = X_m \ X_{m-1}, g_m = G_m - G_{m-1}.
P_k := prod_{j=1}^{k} 1/(1-q^{jd}) (P_0 = 1). b_m := beta_{c,m} := character
(weight GF) of the crystal component of the EMPTY chain in X_m under the bounded
mod-d Tingley operators of RESULT 1.

## RESULT 5 (exhaustive, 36 cases): BOUNDED FACTORIZATION

    G_m = b_m * P_{m-1},   equivalently   b_m = (q^d;q^d)_{m-1} * F_{c,m}.

Holds in ALL tested cases: d in {2,3,4,5,6,7,8} (including 3|d: d=3,6, and d=2
where Tingley's n>=3 hypothesis fails!), m <= 5, W <= 13, wall/corner/all-positive
profiles (scripts seed5_R2L3_factor.py, _factor2.py, logs saved).
Component structure (seed5_R2L3_comp.py, H1 violations = 0 in all cases):
 - every crystal component of X_m has a UNIQUE source (all e_kappa undefined);
 - all components of X_m are isomorphic as graded sets to the vacuum component
   (identical truncated characters, identical phi-vector = level-3 weight; e.g.
   phi=(1,1,1,0) for c=(2,1,1), (3,0,0,0) for (4,0,0) — sum = 3 = level);
 - source weights with multiplicity = partitions into parts {d, 2d, ..., (m-1)d}
   (e.g. d=4, m=3: sources at 0, 4, 8, 8 = {}, (4), (8), (4,4)).
Interpretation: X_m is (as graded crystal) B_vac tensor a truncated bosonic factor;
the entry bound m truncates the Heisenberg modes to jd, j <= m-1. The m=infinity
statement (GF of CPs = principal character times (q^d;q^d)_inf^{-1}-type factor,
crystal disconnected) is KNOWN (Tingley "Three combinatorial models";
Kanade-Russell tight-CP chunk_004: "undesirable factor ... crystal graph not
connected"). The BOUNDED truncated version appears to be NEW (RAG: no match).
COROLLARY (modulo a proof of RESULT 5): (q^d;q^d)_{m-1} F_{c,m} >= 0
unconditionally — the rank-level DUAL of the conjecture's H_{c,m} = (q;q)_m F_{c,m}
>= 0, manifestly positive because it IS a crystal character. This is the
structural payoff of the mod-d (dual) crystal.

## RESULT 6 (reduction of f_0): the SHARP-F0 / BETA-TARGET

Define r_m := b_m - b_{m-1} and (m >= 2) s_m := r_m + q^{(m-1)d} b_{m-1},
s_1 := b_1 - 1, s_0 := 1. Then s_m = g_m / P_{m-1} exactly (identity via RESULT 5;
verified). Facts (I1, exhaustive): r_m >= 0 with valuation exactly m; hence
s_m >= 0 manifestly. The target transforms:

    f_0^(m) * (q^d;q^d)_{m-1}  =  (1-q^m) s_m - q (1-q^{(m-1)d}) s_{m-1}  =: T6_m.

T6_m >= 0 IMPLIES f_0^(m) >= 0 (multiply by P_{m-1} >= 0); it is STRICTLY SHARPER
(division by P does not preserve positivity in general). VERIFIED T6_m >= 0 in
~60 cases: d in {2,4,5,7,8} (all gcd(d,3)=1), all orbit reps tried, m <= 5,
W <= 13 (seed5_R2L3_svec.py, _t6scale.py + log). Empirical shape: val(T6_m) =
2m-1 generically, 2m for corner orbits (d,0,0); leading coefficient small (1-3).
NOTE the self-similar form: T6 is the ORIGINAL f_0-shape in the s-variables but
with the crucial extra factor (1-q^{(m-1)d}) on the subtracted term. New
well-posed target, purely in crystal characters:

    (SHARP-F0)   (1-q^m) s_m  >=  q (1-q^{(m-1)d}) s_{m-1}   (gcd(d,3)=1).

3|d note: chain-level f_0^(m) itself FAILS at d=3, c=(0,2,1), m=1 (coefficient -1
at q^6) — consistent with the conjecture using (q^3;q^3)_m for 3|d; SHARP-F0 is a
gcd(d,3)=1 statement. The factorization (RESULT 5) holds for 3|d regardless.

## RESULT 7 (negative fences, all exhaustive)

 (a) I3: (1-q^m)b_m >= (1-q^{(m-1)d})(1+q-q^m) b_{m-1} FAILS everywhere (m>=2) —
     the +q(1-q^{(m-1)d})(1-q^{(m-2)d}) b_{m-2} term in the 3-term beta expansion
     of T6 is essential; no 2-term beta-only sufficient inequality of this shape.
 (b) T5: (1-q^m)s_m >= q s_{m-1} (dropping the (1-q^{(m-1)d})) FAILS (d=2 m=2,3;
     d=3). The dual factor is doing real work — do not sharpen further.
 (c) C1: r_m is NOT the character of {A in vacuum component: bottom nonzero}
     (that set is strictly bigger). The s-decomposition is algebraic, not the
     naive set difference; a combinatorial model for s_m is OPEN.
 (d) DOUBLE-PRODUCT: (q;q)_m (q^d;q^d)_{m-1} F_{c,m} = (q;q)_m b_m has NEGATIVE
     coefficients (most cases incl. d=2,4,5) — no self-dual strengthening of the
     conjecture. (Apparent OKs at m=3,4 are truncation artifacts, W too small.)
 (e) I2: (1-q^m) b_m >= q b_{m-1} holds for m >= 2 in all cases, fails at m=1
     corner (4,0,0). True but not obviously useful alone.

## Proof program (for the formalizer / next agent)

Step 1 (crystal axioms, routine): bounded mod-d operators are well-defined partial
bijections with e f = id (RESULT 1; adapt Tingley's bracket argument; the bound
only DELETES addable boxes at s = m+1, and deletions at the far end of the
t-order should not disturb the matching — check this is where the argument
localizes).
Step 2 (component classification): unique source per component; explicit source
combinatorics = partitions into parts {d..(m-1)d}; all components isomorphic via
weight-shifting isos (Heisenberg/energy-translation candidate; sources observed:
((2,1,1),0,0), ((3,3,2),0,0), ((2,1,1),(2,1,1),0) for c=(2,1,1)). This yields
RESULT 5 and the COROLLARY (q^d;q^d)_{m-1} F_{c,m} >= 0.
Step 3 (the remaining inequality): SHARP-F0 in the s-characters. Candidate routes:
 (i) find the combinatorial object with character s_m (RESULT 7c says it is not
     the naive one) — likely a relative/quotient object "C_m mod bosons"; then
     SHARP-F0 may again be a crystal-embedding statement one level up (note its
     f_0-like self-similar shape);
 (ii) string/Demazure decomposition of the vacuum component: connect s_m to
     Demazure characters of B(Lambda_c) for hat-sl_d (bound m <-> Demazure depth);
 (iii) Seed 3's normalized-matching machinery now only needs to run INSIDE the
     vacuum component (bosonic factor stripped) — a much smaller connected object.

Scripts this session: seed5_R2L3_factor2.py(+.log), seed5_R2L3_svec.py,
seed5_R2L3_t6scale.py(+.log), seed5_R2L3_double.py; patched seed5_R2L3_beta2.py.

## Handoff

STATE: f_0^(m) >= 0 still UNPROVED, but reduced (modulo proving RESULT 5, which
has overwhelming exhaustive evidence and a clear crystal proof program) to
SHARP-F0: (1-q^m)s_m >= q(1-q^{(m-1)d})s_{m-1}, an inequality between connected-
crystal characters with the bosonic factor stripped. Headline structural find:
BOUNDED FACTORIZATION F_{c,m}(q^d;q^d)_{m-1} = vacuum-component character (all
d=2..8, incl. 3|d), giving the dual-H positivity (q^d;q^d)_{m-1}F_{c,m} >= 0 for
free once formalized — appears NEW and publishable independently.
DO NOT RETRY: single-J reduction (RESULT 3 Hall certificates), 2-term beta
inequalities (I3, T5), double-product positivity (7d), naive set model for r_m
(7c), plus all Session-1/2 and Seed-3 fences.
NEXT: (1) formalize RESULT 5 (Steps 1-2 — highest-value tractable item);
(2) attack SHARP-F0 via Demazure/string structure of the vacuum component or
normalized matching inside it; (3) convention reminder: chain model = conjecture.tex
profile c directly; EMD-formula H-recursion lives at the REVERSED profile.
