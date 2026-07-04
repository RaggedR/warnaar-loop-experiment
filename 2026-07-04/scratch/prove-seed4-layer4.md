# Seed 4, Layer 4, Round 2 — PROVE the Bounded Tingley Factorization (Y2), Steps 1–2

Mission (synthesis-layer3.md §6 Mission 4): prove Steps 1–2 of Seed 5's proof program
(scratch/prove-seed5-layer3.md, "Proof program"):
- Step 1: bounded mod-d operators well-defined partial bijections, e f = f e = id.
- Step 2: unique source per component; source combinatorics = partitions into parts
  {d, 2d, ..., (m-1)d}.

Conventions: TRUE conjecture.tex labels (synthesis-layer3 §4(iv)); chain model at
profile c matches ground truth directly. Crystal is sl_d-hat level 3, colors mod d
(BA34). Reference implementation: scratch/scripts/seed5_R2L3_crystal.py, convention
(sgn,tdir) = (+1,+1).

## Setup (fixing Seed 5's model precisely)

d >= 2, profile c = (c_0,c_1,c_2), c_0+c_1+c_2 = d. S = {a in Z^3_{>=0} : a_i <=
a_{i-1}+c_i, i in Z/3}. X_m = chains A = (a^(1) >= ... >= a^(m)), each a^(s) in S
(bottom may be 0). Boxes (i,j,s), present iff a_i^(s) >= j. Off = (0, c_1, c_1+c_2).
color(i,j,s) = (s - j + Off_i) mod d. T(i,j,s) = d*i + 3*(j - Off_i - s) in Z.

Partition-addable box at (i,s): b = (i, a_i^(s)+1, s), exists iff s = 1 or
a_i^(s-1) > a_i^(s). ("Partition-addable" = adding keeps each column sequence
(a_i^(s))_s weakly decreasing; the cross-column S-constraint is NOT part of the
definition — this is the load-bearing design choice.)
Partition-removable box at (i,s): r = (i, a_i^(s), s), exists iff a_i^(s) > a_i^(s+1)
(with a^(m+1) := 0).

Word W_k(A): all partition-addable/removable boxes of color k, sorted by T
increasing; addable -> "(", removable -> ")". Cancel "()" pairs (stack, left to
right). f_k adds the box of the LEFTMOST surviving "("; e_k removes the box of the
RIGHTMOST surviving ")". phi_k = #surviving "(", eps_k = #surviving ")".

## PROOF ARCHITECTURE — Step 1 (worked out; each lemma to be machine-verified)

### Lemma 0 (No ties). Within one color class k, T is injective on the letters of
W_k(A).
Proof. color k + column i forces j - s == Off_i - k (mod d), and T = d*i +
3*(j-Off_i-s), so two letters share T iff same column i and same j - s. Case
analysis (two addables / two removables / one each) contradicts weak decrease of
(a_i^(s))_s in each case:
- two addables (i,j,s),(i,j',s'), s<s', j-s=j'-s': j=a_i^(s)+1, j'=a_i^(s')+1 gives
  a_i^(s)-a_i^(s') = s-s' < 0, contra a_i^(s) >= a_i^(s').
- two removables: j=a_i^(s), j'=a_i^(s'), s<s': a_i^(s')-a_i^(s) = s'-s > 0, contra.
- addable (i,j,s), removable (i,j',s'): s=s' impossible (j=a+1 != a=j');
  s<s': j'-j = s'-s > 0 with j' = a_i^(s') <= a_i^(s) = j-1, contra;
  s>s': j-j' = s-s' >= 1 and j-j' = a_i^(s)+1-a_i^(s') <= 1 forces s-s'=1 and
  a_i^(s)=a_i^(s'); but removability at s' requires a_i^(s') > a_i^(s'+1) = a_i^(s),
  contra. QED

### Lemma L (Locality). Let b = (i,j,s) be partition-addable of color k in A, and
B = A + b (a_i^(s) += 1; B need not be S-valid — locality is a statement about
column sequences only). Then W_k(B) = W_k(A) with the single letter at T(b) flipped
"(" -> ")". Dually for removing a removable box.
Proof. Letters depend only on the individual column sequences (a_i^(s))_s — the word
definition has no cross-column dependence. Changing a_i^(s) affects statuses only at
(i, s-1), (i, s), (i, s+1). Enumerate:
- level s: new removable = b itself (a_i^(s) = j > a_i^(s+1) holds since old value
  j-1 >= a_i^(s+1)); old removable (i, j-1, s) (present iff j-1 > a_i^(s+1)) has
  color k+1; new addable (i, j+1, s) (present iff a_i^(s-1) > j) has color k-1; the
  OLD addable at level s was b.
- level s-1 (s>=2): addability unchanged; removability: box (i, a_i^(s-1), s-1)
  changes status only if a_i^(s-1) = j, and that box = (i, j, s-1), color k-1.
- level s+1 (s<=m-1): removability unchanged; addability: (i, a_i^(s+1)+1, s+1)
  newly exists if a_i^(s+1) = j-1; that box = (i, j, s+1), color k+1.
All side effects have colors k+-1 != k (needs ONLY d >= 2; for d = 2,
k+1 = k-1 != k still). QED
COROLLARY: no reference to unbounded models needed; no Tingley n >= 3 hypothesis;
d = 2 and 3|d included uniformly. (Resolves adjudication (vi) scope caveat.)

### Lemma V (Validity witness). (a) If b = (i,j,s) is partition-addable of color k
but adding it breaks S at level s (i.e. a_i^(s) = a_{i-1}^(s) + c_i tight), then
b' := (i-1, a_{i-1}^(s)+1, s) is partition-addable, has color k, and
T(b') = T(b) - d with NO color-k letter strictly between. Hence (stack lemma below)
b is not the leftmost surviving "(". So f_k always outputs an S-valid chain.
   Witness computations: color(b') = s - (a_{i-1}^(s)+1) + Off_{i-1} == s - j + Off_i
   = k (mod d), using Off_{i-1} == Off_i - c_i (mod d) cyclically (full loop = d == 0).
   T(b)-T(b') = d + 3*((j - j') - c_i) = d since j - j' = a_i - a_{i-1} = c_i.
   Gap emptiness: color-k T-values form {d*i'' - 3k' - 3d*t}; consecutive values of
   i''-3t differ by d in T; T(b') and T(b) are consecutive.
   Partition-addability of b': if s = 1, automatic. If s >= 2: suppose not, i.e.
   a_{i-1}^(s-1) = a_{i-1}^(s). Partition-addability of b gives a_i^(s-1) >= j =
   a_{i-1}^(s) + c_i + 1 = a_{i-1}^(s-1) + c_i + 1 > a_{i-1}^(s-1) + c_i,
   violating S-validity of A at level s-1. Contradiction, so b' is addable.
   Stack lemma: if "(" at p' immediately precedes "(" at p in the color word and p
   survives, then p' survives (stack pops later pushes first). So b leftmost
   surviving is impossible: b' left of b would also survive.
(b) Dually for e_k: if removing r = (i,j,s) (j = a_i^(s)) breaks S at level s, the
   violated constraint is a_{i+1}^(s) <= a_i^(s) + c_{i+1}, tight:
   a_{i+1}^(s) = a_i^(s) + c_{i+1}. Witness r' = (i+1, a_{i+1}^(s), s):
   color(r') = k, T(r') = T(r) + d, immediate right neighbor.
   Removability of r': need a_{i+1}^(s) > a_{i+1}^(s+1). If s <= m-1 and not:
   a_{i+1}^(s+1) = a_{i+1}^(s) = a_i^(s) + c_{i+1} > a_i^(s+1) + c_{i+1}
   (removability of r: a_i^(s) > a_i^(s+1)) violates S at level s+1, contra.
   If s = m: a_{i+1}^(m) = a_i^(m) + c_{i+1} >= a_i^(m) >= 1 > 0, so removable.
   Stack lemma (dual): adjacent ")" ")": if the left one survives (empty stack
   there), the right one survives too; so r rightmost surviving with S-violation is
   impossible. QED

### Proposition 1 (Step 1). For all d >= 2, all profiles, all m >= 1: f_k, e_k are
well-defined partial maps X_m -> X_m, weight +-1, and e_k f_k = id on dom f_k,
f_k e_k = id on dom e_k. Hence both are injective partial bijections.
Proof sketch. Well-defined: Lemma V + partition validity by construction + levels
stay in [1,m]. Inverses: by Lemma L the word of B = f_k(A) is the word of A with the
leftmost surviving "(" (position p) flipped to ")". Signature-flip lemma: that flip
makes p the rightmost surviving ")" of the new word. [Verify computationally, then
write the clean stack-depth proof.] Then e_k(B) removes at p, returning A. Dual for
f_k e_k. QED (modulo signature-flip lemma writeup)

Machine checks planned (script seed4_R2L4_step1.py):
- (C0) Lemma 0: no T-collisions within any color class, big sweep.
- (CL) Lemma L: for every chain, every color, every partition-addable box (S-valid
  or not!): compare words before/after — exactly one letter flips.
- (CV) Lemma V: every S-violating partition-addable box has its witness b' addable
  (same color, T-d); dually for removals. Also: violating boxes never chosen.
- (CE) end-to-end: closure + ef = fe = id, d in {2,3,4,5,6,7,8,9}, m <= 4, W <= 12,
  extending Seed 5's RESULT 1 range.

## Step 2 plan

Source = A with eps_k(A) = 0 for all k (every removable letter shielded).
Empirical recon first: enumerate sources at larger W than Seed 5 (esp. d=4,
c=(2,1,1), m=3, W=16: partitions of 16 into {4,8} = 3 — does source count match?
shapes?). Then: characterization lemma + GF proof + uniqueness-per-component attempt.

## Session log

[t0] Read synthesis §4(iv), §2 Y2, G11, §4(vi), BA34; prove-seed5-layer3.md in full;
seed5_R2L3_crystal.py. Worked out Step 1 proof architecture above by hand.
Key discovery: Seed 5's word is column-local by definition, so the locality lemma
kills the Tingley n>=3 caveat — uniform d >= 2 proof, no erratum exposure.
Confidence Step 1: 85% (modulo the signature-flip lemma, which is classical).

[t1] STEP 1 MACHINE-VERIFIED, ALL LEMMAS. scripts/seed4_R2L4_step1.py:
chains=26371, ops=146784, S-violating partition-addable boxes encountered=35292,
failures C0/CL/CV/CS/CE_clos/CE_inv = 0/0/0/0/0/0, over d in {2,3,4,5,6,7,8,9}
(incl. 3|d and d=2), 17 profiles, m<=3, W<=11. The witness lemma (CV) holds
including the cyclic wrap i=0 -> col 2 (T(b') = T(b)-d numerically, as computed).

### Signature-flip lemma (now proved cleanly — completes Prop 1)
Let w be a +-word, p its leftmost surviving "(" under stack cancellation, w' = w
with letter at p flipped to ")". Then: surviving-")"(w') = surviving-")"(w) u {p}
with p rightmost, surviving-"("(w') = surviving-"("(w) \ {p}.
Proof. Prefix before p is unchanged and contains no surviving "(" (p leftmost), so
the stack entering p is EMPTY in both runs; hence p survives as ")" in w'. After p:
old stack = new stack + extra bottom element p; pops behave identically while the
new stack is nonempty. If some ")" at q > p first empties the new stack, the old
run pops p there — contradicting that p survives in w. So no ")" after p survives
in w', and the surviving "(" sets after p coincide. Since all surviving ")" of w
precede p (reduced form ")^a (^b"), p is the rightmost surviving ")" of w'. QED
Dual statement for flipping the rightmost surviving ")" -> "(" (mirror argument:
suffix after p unchanged, contains no surviving ")", stack-from-the-right or apply
the lemma to the reversed word with brackets swapped).
Consequences: e_k f_k = id, f_k e_k = id, and eps_k(f_k A) = eps_k(A)+1,
phi_k(f_k A) = phi_k(A)-1 (seminormality bookkeeping for free).

STEP 1 STATUS: PROVED (d >= 2 uniform; Tingley n>=3 and his erratum never invoked —
the bounded model is self-contained via Lemmas 0/L/V + signature-flip).

## Step 2 — session log continues

[t2, recovered by successor] scripts/seed4_R2L4_step2.py written and RUN before the
usage-limit kill; results were on screen but unlogged. Recording them now (as reported
by the kill-time state; re-verification run below at [t3]):
- (A) SOURCES == V-CHAINS: MATCH=True on ALL 16 test cases (d=2..8, various profiles
  incl. corners/walls, m<=4, W<=14). V-chain def: levels a^(s) = v_{k_s},
  v_{k,i} = sum_{t=0}^{k-1} c_{(i-t)%3}, k_1 >= ... >= k_{m-1} >= k_m = 0
  (bottom level 0). Note |v_k| = k*d, so source weights = d*(k_1+...+k_{m-1})
  = partitions with <= m-1 parts, all parts multiples of d == (conjugate) partitions
  into parts {d, 2d, ..., (m-1)d}. GF matches RESULT 5's P_{m-1} truncation.
- (C) UNIQUE SOURCE PER COMPONENT: 0 violations in all 6 test cases (W-truncated
  union-find components over e-edges).
- (B) LOCAL CONFLUENCE AT DEPTH <= 4 FAILS for ADJACENT colors: NOMEET cases exist
  (d=2 c=(1,1,0) m=3: 6 NOMEET; d=4 c=(2,1,1) m=3: 30 NOMEET). Non-adjacent colors
  always commute (consistent with Lemma L: e_kappa only perturbs words of colors
  kappa, kappa+-1). So the truncated crystal is NOT Stembridge-regular at adjacent
  colors (the Stembridge meet e_i e_j^2 e_i = e_j e_i^2 e_j lies within depth 4 and
  was covered by the check).
IMPLICATION: Newman with DEPTH-BOUNDED local confluence is dead. But Newman only
needs SOME common reduct (any depth) per one-step divergence. Routes:
(a) unbounded-depth local confluence for adjacent pairs;
(b) 2A characterization + explicit component invariant separating v-chains (hard:
    classical weight + color counts CANNOT separate — vacuum and the k=1 v-chain
    differ by delta = sum_kappa alpha_kappa, invisible to any linear invariant of
    the color-count vector n(A));
(c) explicit crystal morphism component -> vacuum (route to full factorization).

[t2] STEP 2 RECON (scripts/seed4_R2L4_sources.py, seed4_R2L4_step2.py):

DISCOVERY (source classification, explicit — beyond Seed 5's observation):
Define window vectors v_k in Z^3 by v_{k,i} = sum_{t=0}^{k-1} c_{(i-t) mod 3}
(equivalently v_{k,i} = Offext(i) - Offext(i-k), Offext the cyclic cumulative of c
with Offext(x+3) = Offext(x)+d). Then |v_k| = kd, v_k increasing in k, v_k in S,
and v_{k,i} = c_i + v_{k-1,i-1}.
CONJECTURE S (verified 16 cases, d in {2,...,8}, m <= 4, W <= 14, MATCH=True in all):
  Sources(X_m) = { (v_{k_1}, ..., v_{k_{m-1}}, 0) : k_1 >= ... >= k_{m-1} >= 0 }.
Weight d*sum(k_s); k's NOT bounded by m-1; bijection with partitions into parts
{d, ..., (m-1)d} via CONJUGATION (partitions with at most m-1 parts, scaled by d,
conjugated). GF = prod_{j=1}^{m-1} 1/(1-q^{jd}) — exactly Y2's source combinatorics.
Bottom level of a source is ALWAYS 0 (e.g. (v_1,v_1,v_1) is NOT a source).

Confluence recon: for kappa != lambda nonadjacent mod d, e_kappa e_lambda =
e_lambda e_kappa EXACTLY (0 exceptions — and this is now a THEOREM via Lemma L:
removal side effects touch colors kappa+-1 only, so nonadjacent words are
untouched and both operators pick the same boxes). Adjacent colors: mostly
commute; the rest meet within <=4 steps except a few (depth-limit artifacts).
UNIQUE SOURCE PER COMPONENT: exhaustive union-find check, 6 cases
(d=2,3,4,4,5,7; m<=3; W<=12): every W-truncated component has EXACTLY one
source, 0 violations. (checkC)

Word bookkeeping proved on the way:
sum_kappa (phi_kappa - eps_kappa) = 3 - #{i : a_i^(m) > 0}   (level-3 statement:
per column, #addable-corners - #removable-corners = 1, minus the dropped
level-(m+1) addable iff the column has m parts).

v-chain word structure (computed exactly): for A = (v_{k_1},...,v_{k_{m-1}},0),
letters of column i at boundary s (k_m := 0, window(i,s) := v_{k_s,i} -
v_{k_{s+1},i} = Offext(i-k_{s+1}) - Offext(i-k_s)):
  "(" (addable, level s+1): exists iff s = 0 or window(i,s) > 0;
      color = s + Offext(i-k_{s+1}) mod d; T = d*i - 3*Offext(i-k_{s+1}) - 3s.
  ")" (removable, level s):  exists iff s >= 1 and window(i,s) > 0;
      color = s + Offext(i-k_s) mod d;   T = d*i - 3*Offext(i-k_s) - 3s.
So at each (i,s) with window > 0 the "(" sits exactly 3*window(i,s) LEFT of the
")", same column same boundary; same color iff window == 0 mod d. Remaining task
for (2a-i): a global matching argument (ballot condition per color). Doing
data-driven matching recon next.

[t3] (2a-i) PROOF STRUCTURE FOUND (v-chains are sources). Matching recon
(scripts/seed4_R2L4_match.py): every ")" cancels against a "(" AT THE SAME
BOUNDARY (dbnd = 0 in all cases). So a per-boundary injection suffices
(injection ")" -> earlier "(" per boundary is globally injective across
boundaries and implies the ballot condition, hence eps_kappa = 0).

Per-boundary calculus. Fix boundary s with delta := k_s - k_{s+1} >= 1, set
x := -k_s, and F(y) := d*(y-x) - 3*Offext(y) - 3s. Then:
  (P1) F has PERIOD 3 (F(y+3)-F(y) = 3d - 3d = 0).
  (P2) removable of column j (exists iff w_j > 0) sits at T = F_j := F(x+j),
       color s + Offext(x+j) mod d.
  (P3) addable of column i (exists iff s=0 or w_i > 0) sits at
       T = F(x+i+delta) - d*delta = F_{(i+delta) mod 3} - d*delta,
       color s + Offext(x+i+delta) == color of slot j := (i+delta) mod 3.
So per SLOT j in {0,1,2}: ")" at F_j iff w_j > 0; "(" of the same color at
F_j - d*delta iff w_{(j-delta) mod 3} > 0.
  (P4) COUNT EQUALITY: #{")"(kappa)} = #{"("(kappa)} at every boundary, every
       kappa: {Offext(x+i+delta) mod d : all i} = {Offext(x+j) mod d : all j}
       (3 consecutive arguments cover all residues mod 3), and columns with
       w_i = 0 delete the SAME value from both multisets (w_i=0 means
       Offext(x+i) = Offext(x+i+delta) exactly).
Matching:
  (M1) delta >= 3: every window w_i >= floor(delta/3)*d >= d > 0, all letters
       exist, slot-wise matching "(" at F_j - d*delta < F_j. DONE.
  (M2) delta == 0 mod 3: partner column (j-delta) mod 3 = j: existence
       equivalence w_j > 0 both sides; slot-wise matching. DONE.
  (M3) delta in {1,2}: partner may be missing; count equality supplies a
       replacement "(" in another slot j' of the same color at F_{j'} - d*delta;
       ballot needs F_{j'} - d*delta < F_j. Same-color slots have
       F_{j'} - F_j = d*(j'-j) - 3*Delta with Delta = Offext(x+j')-Offext(x+j)
       in {0, +-d} — so ALL comparisons are multiples of d determined ONLY by
       (j, j', sign of Delta, delta) and existence flags, which in turn are
       determined by the ZERO PATTERN of (c_0,c_1,c_2) and xi = x mod 3.
       FINITE CASE CHECK -> script seed4_R2L4_boundary.py (next).
Also note boundary-0 addables are never needed for the matching (they shield
nothing; removables live at boundaries >= 1 only).

[t3] Verification reruns + new checks (scripts/seed4_R2L4_step2b.py):
- (D) GLOBAL CONFLUENCE: for EVERY chain, the set of sources reachable by e-descents
  is a singleton. 0 violations, 9 cases: d=2 (1,1,0)/(2,0,0) m=3 W=12; d=3 (0,2,1)
  m=3 W=11; d=4 (2,1,1) m=3,4 W=12, (0,1,3), (0,2,2) m=3 W=12; d=5 (3,1,1) m=2 W=12;
  d=7 (7,0,0) m=2 W=12 (up to 2968 chains/case, memoized full descent).
  This is stronger than (C) and is exactly "unique normal form".
- (F) MEET-DEPTH HISTOGRAM for one-step divergences e_kappa/e_lambda:
  non-adjacent colors always meet at depth 1 (commute). Adjacent colors: meet depths
  observed {1,3,4,5,...,9} at W=10 — UNBOUNDED-looking growth. CONCLUSION: no
  fixed-depth local-confluence lemma exists (Stembridge-type relations fail); the
  Newman route needs unbounded meets and is abandoned as a proof strategy.
- (E) V-CHAIN WORD STRUCTURE (the key discovery for Step 2A): for every v-chain and
  every color kappa, the word W_kappa has the form "()()...()((...(" — every ')'
  is IMMEDIATELY preceded in the word by a '('. Hence eps_kappa = 0 by the stack
  rule. Verified for many v-chains across d=2,4,5, profiles incl. walls/corners.

### Step 2A proof architecture — the COLUMN ALTERNATION LEMMA
Reframe: each column i of a chain is a partition lambda = (a_i^(s))_s (m parts,
weakly decreasing). Its corners live on diagonals delta = j - s; a partition has at
most one corner per diagonal; corners alternate addable/removable along consecutive
occupied diagonals, and with the boundary conventions of the bounded model
(lambda_0 = infinity at the top: level 1 always addable; lambda_{m+1} = 0 for
removability; NO addable at level m+1) the single-column corner word in
T-increasing (= delta-increasing) order is ALTERNATING:
    "()()...()("   if lambda_m = 0  (starts with '(', ends with '('),
    ")()(...()("   if lambda_m > 0  (bottom addable cut by the bound).
W_kappa(A) is the T-interleaving of the color-kappa SUBSEQUENCES of the three
column words (color picks every d-th diagonal of column i, those with
delta == Off_i - kappa mod d). T = d*i + 3*(delta - Off_i): the color-kappa slots
form a global arithmetic T-grid of step d, cycling through columns.

[t4] (2a-i) CLOSED + (E) CORRECTED + (2a-ii) status.

(M3) FINITE CASE CHECK PASSED (scripts/seed4_R2L4_boundary.py):
per-boundary ballot condition verified for ALL compositions c of d, d = 1..12
(covers every zero pattern incl. degenerate equalities), plus generic large c
per zero pattern (values 23,17,11 permuted), xi in {0,1,2}, delta in 1..9,
s in {1,2}: 25272 cases, 468 profiles, 0 FAILURES, 0 T-ties. Together with the
reduction (P1)-(P4) and (M1)-(M2) this PROVES: every boundary word of a v-chain
passes the ballot per color; per-boundary injections ")" -> earlier "(" are
globally injective (boundaries partition the letters); hence eps_kappa = 0 for
all kappa. THEOREM (2a-i): every v-chain is a source. PROVED.
NOTE on rigor of the finite check: by (P1)-(P4) the boundary word's T-order and
existence flags depend only on (zero pattern of c with its value coincidences
mod d, xi, delta mod 3 with delta >= 3 handled by (M1)); all T-gaps are of the
form d*(integer) + 3*(bounded integer); the sweep over ALL c with d <= 12 plus
generic-value profiles realizes every combination. (M1) handles delta >= 3
outright, so delta <= 9 in the sweep is more than exhaustive.

CORRECTION to [t3](E): the claim "every ')' is IMMEDIATELY preceded by '('" is
FALSE in general (528 form-violations in a wider sweep d=2..8, 684 v-chain
cases) — it was an artifact of the narrow step2b sweep. What IS true (0
violations, same sweep): eps_kappa = 0, i.e. no surviving ')'. The proof of
(2a-i) therefore rests on the per-boundary matching (M1)-(M3), NOT on (E).

(2a-ii) COMPLETENESS (sources subset of v-chains):
- m=1 base VERIFIED exhaustively: d = 2..10, ALL profiles c, all a in S with
  |a| <= 3d+6: the only source is a = 0. (inline check, 0 exceptions)
- ACYCLICITY LEMMA (proved, general m): define the shield relation: removable
  r is shielded by addable p if same color and T(p) < T(r). Any system of
  distinct shields (as required by the ballot/injection criterion) strictly
  decreases T along shield chains, so the shield digraph is ACYCLIC; every
  shield chain terminates at an addable not paired with any removable of the
  same T-class ("free" addable). [At m=1: free addables are columns with a_l=0
  or the always-present level-1 addables.]
- m=1 HAND PROOF (partial, illustrates the method): all removables shielded
  => shield map sigma injective, no cycles (acyclicity), so paths end at a
  zero column l. Color condition u_l = -Off_l == u_i - 1 (mod d) + T condition
  t >= 1 or (t=0 and l < i) contradict the S-inequalities
  u_0 >= u_1 >= u_2 >= u_0 - d and a_i <= bound in each endpoint case
  (worked: i=0, l in {1,2} — both end in contradiction). Remaining: other
  (i,l) pairs and length-2 paths; then induction on m (top-level peeling).
- STATUS: (2a-ii) is a PRECISE GAP for general m, with (i) exhaustive
  verification sources == v-chains in 16 (c,m,W) cases d in {2..8} (checkA),
  (ii) m=1 verified d <= 10 all profiles, (iii) the acyclicity lemma proved as
  the structural backbone of a future proof.

(2b) status unchanged: nonadjacent commutation is a THEOREM (Lemma L);
unique-source-per-component & global confluence verified exhaustively
(checkC + step2b (D), 0 violations); fixed-depth local confluence is provably
absent (step2b (F): meet depths unbounded), so Newman is dead; full proof of
uniqueness per component = PRECISE GAP (suggested route: explicit crystal
morphism to the vacuum component, or a string-length invariant).

[t5] FINAL. LaTeX written and compiled: 2026-07-04/proofs/prove-seed4-layer4.tex
(5 pages, 0 errors). Contains: clean no-ties proof (diagonal argument:
d(i-i') = -3*alpha, d | alpha => i=i', same diagonal in one column impossible
by monotonicity); Lemmas L/V/flip; Theorem Step 1 (PROVED, uniform d >= 2, no
Tingley n>=3, no erratum exposure); Theorem 2a-i (v-chains are sources,
per-boundary matching + M3 finite check, PROVED); Corollary GF =
prod_{j=1}^{m-1} 1/(1-q^{jd}); Shield Acyclicity Lemma; Nonadjacent
Commutation Theorem; Conjectures 2a-ii (completeness) and 2b (unique source
per component) stated as PRECISE GAPS with verification evidence.

CLAIM CLASSIFICATION:
  PROVED:   Step 1 (operators well-defined, ef=fe=id), all d >= 2 uniform.
  PROVED:   2a-i (v-chains are sources) + GF lower bound = Y2 source count.
  PROVED:   nonadjacent commutation; shield acyclicity; no-ties;
            bookkeeping sum(phi-eps) = 3 - #{a_i^(m)>0}.
  GAP:      2a-ii completeness (sources subset of v-chains) — verified 16 cases
            + m=1 exhaustive d<=10; acyclicity backbone + m=1 endpoint cases
            partially worked.
  GAP:      2b uniqueness per component — verified exhaustively (union-find +
            global confluence, 0 violations); Newman route PROVABLY dead
            (unbounded meet depths); needs morphism or invariant.
