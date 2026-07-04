# Seed 5, Layer 4, Round 2 — SHARP-F0 inside the vacuum component (Mission 5)

Target (Y3, SHARP-F0): with s_m := g_m / P_{m-1}, P_k = prod_{j<=k} 1/(1-q^{jd}),
for gcd(d,3) = 1:

    (1-q^m) s_m  >=  q (1-q^{(m-1)d}) s_{m-1}     (coefficientwise).

Implies f_0^(m) >= 0 (a PROJECTION of the conjecture, per synthesis-layer3 §4(i);
funded as technology + dual-positivity payoff). Convention: §4(iv) — chain model at
profile c IS the conjecture.tex definition (TRUE labels, no reversal); the crystal
is the bounded mod-d Tingley structure of Seed 5 L3 RESULT 1 (sl_d-hat level 3, BA34).

Inherited (do NOT redo): RESULT 5 (Bounded Factorization G_m = b_m P_{m-1}, Y2);
RESULT 6 (s_m = r_m + q^{(m-1)d} b_{m-1}, T6 identity); RESULT 7 fences (I3, T5
two-term weakenings FALSE — keep both factors; double product FALSE; r_m is NOT
char{A in vac: bottom != 0}); D3/D4 injection fences; Y5 HALL-RIBBON deficiency-0
data; Y6 joint pair existence.

## Session plan

1. Route (c) FIRST — identify the object with character s_m. KEY OBSERVATION made
   on reading the L3 log: RESULT 7c only refuted r_m = char{A in vac : bottom != 0}.
   It never compared that character to s_m. Algebra says it SHOULD be s_m:
   if the graded isos between components of X_m preserve "bottom level nonzero",
   then char(C_m cap comp_lam) = q^{|lam|} t for a single t, and summing over lam
   gives g_m = t * P_{m-1}, i.e. t = s_m. And s_m = r_m + q^{(m-1)d} b_{m-1} > r_m
   is consistent with 7c's "that set is strictly bigger".
   HYPOTHESIS H1: char{A in vac(X_m) : bottom != 0} = s_m.
   HYPOTHESIS H1L (stronger): char{A in comp_lam : bottom != 0} = q^{|lam|} s_m, all lam.
2. Extend Y3 (T6_m >= 0) verification range — cheap insurance.
3. If H1 holds: SHARP-F0 becomes a self-similar statement between the sets
   V_m := {A in vac(X_m) : bottom != 0}:
       s_m + q^{(m-1)d+1} s_{m-1}  >=  q s_{m-1} + q^m s_m
   i.e. an injection/Hall target  q*V_{m-1} + q^m*V_m  ->  V_m + q^{(m-1)d+1}*V_{m-1}
   — run HALL machinery INSIDE the vacuum component (route b), and string/Demazure
   decomposition (route a) for structure.
4. RAG along the way; verify any cited theorem in ../literature/tex/.

## Log

### Session start
Scratch created. Scripts will be seed5_R2L4_*.py in scratch/scripts/.

### RESULT 1 (L4): the s_m combinatorial object FOUND (exhaustive, 28 cases, 0 fails)

    s_m = char{ A in vac(X_m) : bottom level != 0 }
        = char of vacuum-component bounded chains with max part EXACTLY m.

H1 and the stronger per-component H1L (char{A in comp_lam : bottom != 0} =
q^{|lam|} s_m for EVERY component lam) verified: d in {2,4,5,7,8}, profiles
(2,1,1),(0,2,2),(4,0,0),(0,3,1),(3,1,1),(3,2,2),(1,1,0),(2,0,0),(3,3,2),
m <= 4, W <= 12. Script seed5_R2L4_h1.py (+.log). 0 FAILs / 56 OKs.
Resolves RESULT 7c (L3): the naive difference r_m was the wrong comparison;
the SET {bottom != 0 in vac} was right all along, its char is s_m not r_m.
COROLLARY (given Y2 formalization + "component isos preserve bottom-support"):
g_m = s_m P_{m-1} with s_m >= 0 manifest AS A SET CHARACTER, and
char{A in vac(X_m): bottom = 0} = b_m - s_m = (1-q^{(m-1)d}) b_{m-1}.

### FENCE F1 (L4): stratification H2/H2' FAILS

char{A in vac(X_m): max = m-1} != (1-q^{(m-1)d}) s_{m-1} in EVERY tested case
(script seed5_R2L4_h2.py + log). Only the TOP stratum (k=m, =H1) matches the
product formula; all lower strata k < m fail the candidate
s_k prod_{j=k}^{m-1}(1-q^{jd}) (also provably inconsistent at k=0: sum != b_m).
So SHARP-F0 does NOT literally stratify as "f_0 >= 0 inside vac(X_m)". The
subtracted term q(1-q^{(m-1)d})s_{m-1} is NOT the char of the max=(m-1) stratum.

### RESULT 2 (L4): EXACT STRATIFICATION of the vacuum crystal (H3', exhaustive, 0 fails)

Define the STABILIZED strata w_k := s_k - q^{kd} b_k (w_0 = 1). Then for ALL tested
(d,c,m) [same 9 profiles, m <= 4, W <= 12; script seed5_R2L4_h3.py + log]:

    char{A in vac(X_m) : max(A) = k} = w_k   for every k <= m-1   (m-INDEPENDENT!)
    char{A in vac(X_m) : max(A) = m} = s_m   (= H1)

So w_k >= 0 manifestly (set character), and with bt_m := sum_{k<=m} w_k:
    bt_m = char{A in vac(X_{m'}): max <= m}  for any m' > m,
and the ALGEBRAIC identities (proved by telescoping the s-recursion, no conjecture):
    E1: bt_m = (1 - q^{md}) b_m
    E2: G_m = F_{c,m} = bt_m * P_m,  i.e.  (q^d;q^d)_m F_{c,m} = bt_m.
E1/E2 verified numerically too (seed5_R2L4_ft.py, all OK). GIVEN Y2 + H3' proved:
(q^d;q^d)_m F_{c,m} >= 0 — the dual positivity STRENGTHENED by one extra factor
(1-q^{md}) vs Y2's corollary. (Not in conflict with D6: no (q;q)_m factor here.)

### RESULT 3 (L4): SHARP-F0 == a three-term stratum inequality INSIDE vac(X_m)

Exact rewriting (algebra + H3', derivation in this file's history):
  (1-q^{(m-1)d}) s_{m-1} = (1-q^{(m-1)d}) w_{m-1} + q^{(m-1)d} bt_{m-1}
  T6_m = char(U) - q^m char(U) - q char(Y) - q^{1+(m-1)d} char(Z')
where INSIDE the single connected crystal vac(X_m):
  U  = {max = m}   (char s_m),
  Y  = {max = m-1} (char w_{m-1}),
  Z' = {max <= m-2} (char bt_{m-2}),   vac(X_m) = U u Y u Z' (disjoint).
So SHARP-F0  <=>  for all w:
    #U(w)  >=  #U(w-m) + #Y(w-1) + #Z'(w-1-(m-1)d).
"The whole crystal injects into its top stratum, with stratum-dependent shifts
(m for U, 1 for Y, 1+(m-1)d for Z')." Well-posed HALL-VACUUM target.

### FENCE F2 (L4): FT strengthening fails at m=2
FT_m := T6_m * (1-q^{md}) >= 0 HOLDS for all tested m >= 3 but FAILS at m=2 for
(2,1,1),(0,2,2) d=4 and both d=2 profiles (min coeff -4..-1). Same pattern for
FTa := (1-q^m)w_m - q(1-q^{md})w_{m-1}. FTb always mixed. So do not attack via
FT/finite-poly multiplication; use the exact three-term form (RESULT 3).
Script seed5_R2L4_ft.py (+.log).

## Session 2 (continuation agent, post usage-limit kill)

RECOVERY: predecessor died with TWO unlogged scripts on disk (timestamps after F2):
seed5_R2L4_strata.py (stratum-character inspection — consistent with RESULT 2,
nothing new) and seed5_R2L4_hallvac.py (+.log) — a MAJOR unlogged positive result,
logged now as RESULT 4.

### RESULT 4 (L4, recovered from disk): HALL-VACUUM holds with deficiency 0

The RESULT 3 three-term injection target is Hall-FEASIBLE with levelwise
CONTAINMENT edges, entirely inside the single connected crystal vac(X_m):
per weight w, a saturating matching
    U(w-m) u Y(w-1) u Z'(w-1-(m-1)d)  ->  U(w),   edges: B >= A levelwise,
EXISTS (Kuhn max-matching, deficiency 0 at EVERY weight) in ALL 17 tested cases:
d=4 all four orbit reps m=2,3 (W<=12); d=5 (3,1,1) m=2,3; d=7 (3,2,2) m=2;
d=8 (3,3,2) m=2; d=2 (1,1,0) m=2,3,4 and (2,0,0) m=3,4 (W<=11).
Script seed5_R2L4_hallvac.py, log seed5_R2L4_hallvac.log. This is the vacuum-
crystal analogue of Y5 (HALL-RIBBON) but for the SHARP inequality, and the
search space is much smaller (bosonic factor stripped). Analogy to Y6: the maps
must be co-designed (single-rule fences D3/D4 still apply), but Hall says the
joint design space is nonempty at every tested weight.

### Session-2 plan
Sibling news: Seed 4 L4 has PROVED Step 1 (bounded operators are well-defined
partial bijections, ef = fe = id, d >= 2 uniform, no Tingley hypothesis needed;
Lemmas 0/L/V + signature-flip in scratch/prove-seed4-layer4.md) — crystal-operator
injectivity is now a THEOREM, citable. Strategy: build the three injections from
crystal operators where possible (injectivity then comes for free).
1. beta-map (Y-part, weight +1): A in Y = {max = m-1} |-> f_kappa(A), choosing
   kappa so the added box lands at LEVEL m. If total, injectivity is automatic:
   the image B has a UNIQUE level-m box (i,1,m); its color recovers kappa;
   A = e_kappa(B) by Step 1. TEST totality: does such kappa always exist?
2. alpha-map (U-part, weight +m) and gamma-map (Z'-part, weight +1+(m-1)d):
   probe structures (per-stratum Hall, boson-mode candidates).
3. Incremental logging after each test.

### FENCE F3 (L4): the single-f_kappa beta-map is NOT total for m >= 3

Design: beta(A) = f_kappa(A) with the added box at level m, A in Y = {max = m-1}.
Injectivity would be automatic (unique level-m box in image recovers kappa; Step 1
proved ef = id). But TOTALITY FAILS at every tested (d,c) once m >= 3: e.g. d=4
(2,1,1) m=3: 47/265 chains in Y have NO color kappa whose f_kappa adds at level m
(leftmost-surviving-( lands at a lower level for every color); d=2 (2,0,0) m=4:
12/30; holds only at m=2 (all cases). First failure: A=((2,1,0),(0,1,0),(0,0,0)).
Script seed5_R2L4_beta.py (+.log). Consistent with the D3/D4 fence family:
no single-rule weight+1 map, even crystal-canonical, is total on a stratum.

### HYPOTHESIS H4 (structural, motivated by RESULT 2 algebra): profile translation
is the boson mode, and the top stratum contains a translated copy of everything.

Define T_k(A) := (a^(1)+c, ..., a^(k)+c, a^(k+1), ...) — add the profile vector c
to the first k levels (each a+c stays in S; chain order preserved; weight +kd).
Conjectured structure:
 (a) T_m(vac(X_m)) subseteq U = {max = m in vac(X_m)}  [image manifestly max = m
     since bottom >= c != 0; the CONTENT is vacuum-component preservation], and
     char(U \ T_m(vac(X_m))) = w_m — this EXPLAINS s_m = w_m + q^{md} b_m as sets;
 (b) under X_{m-1} -> X_m (append zero level),
     vac(X_m) cap {max <= m-1} = vac(X_{m-1}) \ T_{m-1}(vac(X_{m-1}))
     — explains bt_{m-1} = (1-q^{(m-1)d}) b_{m-1} as sets.
If true: the m-th boson mode of Y2 is literally T_m, and the whole stratification
becomes self-similar (candidate for an inductive proof of SHARP-F0, and gamma-map
candidate: A in Z' |-> T_{m-1}(A) + box at level m, weight +1+(m-1)d, injective).
Testing now (seed5_R2L4_h4.py).

### FENCE F4 (L4): H4 is FALSE — profile translation is NOT the boson mode

T_m(vac(X_m)) is NOT contained in vac(X_m): e.g. d=4 (2,1,1) m=2,
T(((2,0,0),(1,0,0))) = ((4,1,1),(3,1,1)) lands in a NON-vacuum component
(9/42 domain elements fail); failures at every (d,c) with a nontrivial domain
(d=2: 11/17). H4(b) fails correspondingly. Script seed5_R2L4_h4.py (+.log).
The weight-kd component isos of Y2 are NOT levelwise +c translation; the true
boson operator remains unidentified (Fock-space intuition: power-sum
multiplication, not monomial translation).

### OBSERVATION O1 (L4, one-sided, 17/17 cases, 0 counterexamples): restriction
lemma candidate. In the H4(b) test the inclusion
    {A in vac(X_m) : max(A) <= m-1}  subseteq  vac(X_{m-1})
(drop the zero bottom level) held in EVERY case (only-lhs always empty; the
reverse inclusion is what fails). I.e. the vacuum component only SHRINKS under
tightening the bound. Candidate lemma for the Y2/H3' formalization: bound-
restriction preserves vacuum membership. (Converse direction is quantified by
RESULT 2: the complement has char q^{(m-1)d} b_{m-1}.)

### RESULT 5 (L4): extended HALL-VACUUM + the SET-LEVEL beta-map, with Q1 as the
single remaining lemma for the Y-term

(a) HALL-VACUUM EXTENDED (seed5_R2L4_hallvac2.py + .log): the RESULT 3 target
holds with deficiency 0 in 13 NEW cases — m=4 at d=4 (all four reps) and d=5;
m=5 at d=2 (both reps); m=3 at d=7,8; plus reversal-asymmetric profiles
(1,1,3) d=5, (1,2,4) d=7, (0,1,1) d=2. TOTAL now 30 cases, 0 failures.
Structure stats: min left-degree per part U/Y/Z' — Y-part min degree = 1
EXACTLY (tight but never 0); U-part >= 2 (up to 20); Z'-part huge (>= 5..544).
Surplus #U(w) - #left(w) hits 0 only at the FIRST few weights (w in
[m, ~m+3]) — the injection is forced-bijective exactly at the bottom of the
crystal; comfortable slack above. The Y-part is the binding constraint.

(b) The RELAXED beta-map (set-level, replacing the fenced crystal-op version F3):
    beta: Y -> U,  A |-> A + e_i at level m  (any canonical valid choice of i).
  - INJECTIVE unconditionally: the image B has a UNIQUE bottom-level box; A = B
    minus that box. No crystal input needed.
  - EXISTENCE of an S-valid choice: PROVED (two lines). Claim: a in S, a != 0
    ==> exists i with c_i >= 1 and a_i >= 1 (then e_i <= a^(m-1) and e_i in S,
    since e_i in S iff c_i >= 1). Proof: suppose a_i = 0 for every i with
    c_i >= 1. Pick j with a_j >= 1; then c_j = 0, so S gives a_j <= a_{j-1},
    hence a_{j-1} >= 1, hence c_{j-1} = 0; walking the 3-cycle, all a_i >= 1
    and all c_i = 0, contradicting sum c_i = d >= 1. Applied to a = a^(m-1)
    (nonzero since max(A) = m-1), B = A + e_i^(m) is a valid chain. QED
  - Q1 (VACUUM CLOSURE — the one remaining gap): for A in vac(X_m) with
    max(A) = m-1, EVERY S-valid B = A + e_i^(m) lies in vac(X_m).
    VERIFIED EXHAUSTIVELY: 15 cases (d in {2,4,5,7,8}, m <= 4, incl. asymmetric
    profiles), ~5000 (A,i) pairs, S-valid count == in-vac count in every case
    (seed5_R2L4_betaset.py + .log). ZERO exceptions.
CONSEQUENCE (modulo Q1): #U(w) >= #Y(w-1) for all w, i.e.
    s_m >= q * w_{m-1}   — the Y-TERM of the three-term inequality is realized
by an explicit injection. The U-term (shift m) and Z'-term (shift 1+(m-1)d),
plus joint disjointness, remain. Disjointness note for future co-design:
im(beta) subseteq {B in U : |bottom level| = 1}; any alpha/gamma whose images
have |bottom| >= 2 is automatically disjoint from im(beta).

### LEMMA TARGET Q1 — proof architecture (for the next agent)

Q1 is a crystal-connectivity statement; Seed 4's PROVED Lemma L (locality:
adding a box of color k0 changes only the words of colors k0-1, k0, k0+1, and
W_{k0} by a single letter flip) is the designated tool. Sketch: induct on
weight(A) along an e-path in vac. For e_kappa with |kappa - k0| >= 2 (mod d):
W_kappa(B) = W_kappa(A), so e_kappa(B) = e_kappa(A) + b — the bottom box rides
along and induction applies. The work is the adjacent colors kappa in
{k0-1, k0, k0+1} (extra/removed letters at the three affected positions) and
small d (d=2,3 where all colors are adjacent — but note d=2 data above says Q1
still holds). Alternative route: show the SOURCE of B's component is empty by
Seed 4 Step 2 source combinatorics (sources = specific weight-multiple-of-d
chains; B has |bottom| = 1, sources have bottom 0 for weight < md... check).
If Q1 resists, note Hall min-degree-1 data says any proof MUST use the vac
constraint (the tight A's have exactly one valid i).

## Handoff (Session 2 end)

STATE. SHARP-F0 still unproved, but the reduction chain is now:
  SHARP-F0 <=> three-term stratum injection inside vac(X_m) (RESULT 3, exact
  given H3'), Hall-feasible with deficiency 0 in 30/30 cases (RESULT 4 + 5a);
  Y-term DONE modulo lemma Q1 (RESULT 5b, existence + injectivity PROVED);
  U-term and Z'-term open (need weight+m and weight+(1+(m-1)d) injections into
  {|bottom| >= 2} part of U, co-designed).
CLAIM CLASSIFICATION.
  PROVED (this session): beta existence lemma (two-line, above); beta
    injectivity; consequence chain modulo Q1.
  YELLOW (exhaustively verified, unproved): Q1 (15 cases, 0 fails); RESULT 4/5a
    Hall (30 cases); plus inherited H1/H3' (RESULT 1/2) and Y2.
  FENCES (certificates): F1-F4 (this file), esp. F3 (crystal-op beta not total,
    m >= 3) and F4 (profile translation is NOT the boson mode; H4 false).
  OBSERVATION: O1 (restriction preserves vac, 17/17 — lemma candidate for Y2).
NEXT (priority order):
  1. Prove Q1 (architecture above; small, well-posed, unlocks the Y-term).
     Then s_m >= q w_{m-1} is a THEOREM modulo H3'/Y2 (which Seed 4 is proving).
  2. Reverse-Q1 (removal of the unique bottom box preserves vac) — would give
     im(beta) = {B in U cap vac: |bottom| = 1} EXACTLY and char identity
     char{|bottom| = 1 in U} >= q w_{m-1}, sharpening the co-design interface.
  3. U-term: hunt a weight+m injection U -> {B in U: |bottom| >= 2}. The old
     "+e_i at every level" psi is the shape; its T/I failures might dissolve
     INSIDE vac with the Q1-style closure (test vac-closure of psi first —
     cheap, mirrors betaset.py).
  4. Z'-term: shift 1+(m-1)d suggests "(boson mode m-1) then beta"; but F4
     says the boson mode is not +c translation — identify the true component
     iso of Y2 Step 2 (Seed 4's source combinatorics) first, then conjugate.
  5. Extend Q1/Hall verification to d=10,13 (one case each) as insurance.
Scripts this session: seed5_R2L4_beta.py, _h4.py, _hallvac2.py, _betaset.py
(all + .log, in scratch/scripts/).

### FENCE F5 (L4): the "+e_i at every level" psi is dead for the U-term, even inside vac

Handoff item 3 resolved NEGATIVELY (seed5_R2L4_psiset.py + .log):
 - Q3 (existence of a globally addable column) FAILS: e.g. d=4 (2,1,1) m=3
   A=((3,2,1),(0,1,1),(0,0,1)) has NO valid i (3/323); also d=2, d=4 others.
 - Q4 (vac closure of valid psi_i) FAILS: e.g. d=4 (2,1,1) m=2
   psi_0(((2,2,3),(0,1,1))) leaves the vacuum component (27/331 valid pairs).
   (Held only at d=7,8 m=2 — large-d smallcase artifact, do not trust.)
So the Q1-closure phenomenon is SPECIAL to single bottom-level additions; the
U-term (weight +m) injection must be found elsewhere (crystal string structure,
or co-designed via Hall as in Y6). Certificates in the log. Contrast with
RESULT 5b: the Y-term map survives, the U-term shape does not.
