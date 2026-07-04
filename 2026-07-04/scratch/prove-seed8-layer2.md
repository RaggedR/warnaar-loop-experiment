# Seed 8, Round 2, Layer 2: The Bracket Tower f_k^{(m)}

Mission: (a) prove f_0^{(m)} >= 0, (b) prove (m-1)-fold q-monotonicity,
(c) define higher brackets f_k^{(m)} and check (m-k-1)-fold q-monotonicity;
map out the tower induction.

## Setup: the bracket tower, algebraically

Definitions (all per profile c, r=3, d = |c|, ell = gcd(d,3); below assume
gcd(d,3)=1 so ell=1 unless stated):

- g_m = GF of cylindric partitions of profile c with max part EXACTLY m.
- h_m = (q;q)_m * g_m = D_0^m.
- Tower: D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1};  Q_n = D_n^n (GREEN, Round 1).

**Bracket recursion (NEW, uniform).** Set f_{-1}^{(m)} := g_m and

    f_k^{(m)} := (1 - q^{m-k}) * f_{k-1}^{(m)} - q^{k+1} * f_{k-1}^{(m-1)},   k >= 0.

**Lemma T1 (factorization).** D_{k+1}^m = (q;q)_{m-k-1} * f_k^{(m)} for all
k >= -1, m >= k+1 (interpreting D_0^m = (q;q)_m * f_{-1}^{(m)} = h_m).

*Proof.* Induction on k. Base k=-1 is the definition of h_m. Step:
D_{k+1}^m = D_k^m - q^{k+1} D_k^{m-1}
          = (q;q)_{m-k} f_{k-1}^{(m)} - q^{k+1} (q;q)_{m-1-k} f_{k-1}^{(m-1)}
          = (q;q)_{m-k-1} [ (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)} ]
          = (q;q)_{m-k-1} f_k^{(m)}.   QED (pure algebra, GREEN)

**Corollary T2.** Q_n = D_n^n = (q;q)_0 * f_{n-1}^{(n)} = f_{n-1}^{(n)}.
So the conjecture IS the k = m-1 boundary of the bracket family.

**Closed form.** Unfolding via D_k^m = sum_i (-1)^i q^{binom(i+1,2)} [k choose i]_q h_{m-i}:

    f_k^{(m)} = sum_{i=0}^{k+1} (-1)^i q^{i(i+1)/2} [k+1 choose i]_q (q^{m-k};q)_{k+1-i} g_{m-i}.

Check k=0: (1-q^m) g_m - q g_{m-1}. Correct.

**MASTER CONJECTURE (the two-parameter statement).**
For all k >= -1, all m >= k+1, and all j with 0 <= j <= m-k-1:

    (q;q)_j * f_k^{(m)}  has nonnegative coefficients,

and this is EXACT: j = m-k fails in general.

Boundary cases:
- k = -1: range is j <= m; says g_m is m-fold q-monotone; top j = m is h_m >= 0
  (the core bottleneck). [TO VERIFY computationally that intermediate j work.]
- k = m-1, j = 0: Q_m >= 0 (the conjecture).
- Top j = m-k-1 for general k: D_{k+1}^m >= 0 (the tower).

## Tower induction: what level k+1 needs from level k

The recursion gives, for j <= m-k-2:

    (q;q)_j f_{k+1}^{(m)} = (q;q)_j (1-q^{m-k-1}) f_k^{(m)} - q^{k+2} (q;q)_j f_k^{(m-1)}.

Both terms are individually nonneg under MASTER at level k (the first, IF
monotonicity holds for the factor SET {1..j} u {m-k-1}, not just initial
segments) — but their DIFFERENCE being nonneg is precisely the level-(k+1)
statement. So:

**The induction does NOT close level-by-level from nonnegativity alone.**
What level k+1 needs from level k is a q-monotonized domination:

    (N_{k,j,m}):  (q;q)_j * [ (1-q^{m-k-1}) f_k^{(m)} - q^{k+2} f_k^{(m-1)} ] >= 0

which is literally MASTER(k+1, m, j). The family is self-similar: each level is
a NEW injection-type statement (domination of f_k^{(m-1)} by f_k^{(m)}, robust
under j-fold monotonization). A proof must therefore either:
  (i) find a combinatorial model for f_k^{(m)} itself (level-k objects) in which
      the domination is an injection — i.e., an induction constructing
      model_{k+1} from model_k, or
  (ii) find a single master positivity statement about g_m (k=-1 level) strong
      enough to imply all (k,j) simultaneously.

Route (i) at k=0 = mission task (a): second-order injection.

## Combinatorial model (column/conjugate picture)

A CP of profile c with max <= m is equivalent to a chain

    a^(1) >= a^(2) >= ... >= a^(m)   (componentwise),

with each a^(s) in the state set
S = { a in Z_{>=0}^3 : a_i <= a_{i-1} + c_i, i in Z/3 }
(a_i^(s) = number of parts of lambda^(i) that are >= s, i.e. conjugate columns).
Weight = sum_s |a^(s)|. Max EXACTLY m <=> a^(m) != 0 <=> all levels nonzero.

So g_m = sum over nonzero chains of length m in S of q^{total}.

Key facts about S:
- (Slack lemma) For a in S let T(a) = {i : a_i = a_{i-1} + c_i} (tight coords).
  T(a) != {1,2,3}: summing all three tight equations gives d = 0, contra d >= 1.
  So every state has a slack coordinate.
- (Switch lemma) If i is tight at a and slack at b, with a >= b componentwise
  (a,b in S), then a_i = a_{i-1} + c_i >= b_{i-1} + c_i > b_i, so a_i > b_i
  STRICTLY.

### The maps for f_0^{(m)} = g_m - q g_{m-1} - q^m g_m

Need injections into C_m (nonzero chains of length m), disjoint images:
- phi: C_{m-1} -> C_m, weight +1. This is the PROVEN injection lemma (Round 1):
  append bottom level a^(m) := e_i, i = canonical index with c_i > 0 and
  a^(m-1)_i >= 1. Image: chains with |a^(m)| = 1 (bottom level a single box)
  and the canonicity condition.
- psi: C_m -> C_m, weight +m: add e_{i_s} to level s for each s, where the
  coordinate sequence (i_s) is chosen greedily bottom-up:
  i_m := least slack coordinate of a^(m); for s < m: i_s := i_{s+1} if i_{s+1}
  is slack at a^(s), else i_s := least slack coordinate of a^(s).
  WELL-DEFINED: switching happens only when i_{s+1} is tight at a^(s) and slack
  at a^(s+1); by the Switch lemma a^(s)_{i_{s+1}} > a^(s+1)_{i_{s+1}}, which is
  exactly the condition needed for a^(s) + e_{i_s} >= a^(s+1) + e_{i_{s+1}}
  when i_s != i_{s+1}. Membership in S at each level: adding e_i at a slack
  coordinate stays in S. Total on C_m. Weight +m. All levels stay nonzero.

**DISJOINTNESS IS FREE:** psi image has |bottom level| = |a^(m)| + 1 >= 2,
phi image has |bottom level| = 1. Images disjoint.

**Remaining gap for (a): injectivity of psi.** Being tested computationally.

## Work log

(appended as I go)

### Computational results (task c: MASTER verification)

Scripts: `scripts/seed8_R2L2_tower.sage` (logs `tower_small.log`, `tower_d5.log`,
`tower_d7.log`). Precision per rule PREC >= 6*max(k,m)^2 + 200.

MASTER conjecture: (q;q)_j * f_k^{(m)} >= 0 for all k >= -1, m >= k+1,
0 <= j <= m-k-1, and FAILS (has a negative coefficient) at j = m-k ("exact").

Verified, all checks PASS with EXACT boundary at every (k,m):
- d=2, c=(1,1,0): m <= 8, k <= 4
- d=4, all 5 orbit representatives: m <= 7, k <= 4
- d=5, all 7 orbit representatives: m <= 6, k <= 4
- d=7, all 6 orbit representatives: m <= 5, k <= 3
- Sanity everywhere: D_{k+1}^m = (q;q)_{m-k-1} * f_k^{(m)} (Lemma T1) and
  Q_n = f_{n-1}^{(n)} (Corollary T2).
- NEW k=-1 row: g_m itself is EXACTLY m-fold q-monotone:
  (q;q)_j g_m >= 0 for j <= m (top is h_m >= 0 trivially? no -- h_m >= 0 is
  data, not trivial), fails at j = m+1. This unifies the whole picture:
  the entire tower is "g_m is exactly m-fold q-monotone, in a form stable
  under the bracket recursion."

So (c) is settled computationally: yes, f_k^{(m)} is exactly (m-k-1)-fold
q-monotone for every tested k, m, d, c. Tower induction mapping: level k+1
needs from level k not just nonnegativity but the full monotonized-domination
statement (q;q)_j (1-q^{m-k-1}) f_k^{(m)} >= q^{k+2} (q;q)_j f_k^{(m-1)};
the induction is self-similar and does not close from positivity alone.

### Subset monotonicity + Divisibility Transfer (scripts: subsets.sage, divmatch.sage)

Question: for which finite sets S of exponents does
prod_{a in S} (1-q^a) * f_k^{(m)} >= 0 hold?

- Divisibility Transfer Lemma (PROVED, trivial): (1-q^a)/(1-q^b) has nonneg
  coefficients iff b | a. Hence if F satisfies (q;q)_J F >= 0 and there is an
  injection sigma: S -> {1,...,J} with sigma(a) | a for all a in S, then
  prod_{a in S}(1-q^a) F >= 0.
- Empirics (subsets.log): all subsets S of {1..10}, |S| <= min(J+1,6), across
  d=4,2,5 cases at k=-1..2. Every S admitting a divisibility matching gives a
  nonneg product; failures like {1,3}, {1,3,5}, {1,3,5,7,9} have no matching.
  Cardinality alone is NOT the criterion.
- Systematic sufficiency test (divmatch.log): 29482 sets tested across cases
  (d,c,m,k) = (4,(2,1,1),6,3), (2,(1,1,0),7,3), (5,(3,1,1),5,2),
  (7,(4,2,1),4,1); 18413 had a divisibility matching; **0 violations**.
  Conjecture: divisibility matching into {1..(m-k-1)} is SUFFICIENT (it is
  provably so, by the Transfer Lemma) and empirically appears close to
  necessary, though not exactly (necessity unresolved, low priority).
- Why this does NOT close the tower induction: the induction step needs the
  set {1,...,j} u {m-k-1} to match into {1,...,j+1}; since 1 must map to 1
  and only m-k-1 can use slot j+1, a matching exists iff (j+1) | (m-k-1).
  So Transfer alone proves only the arithmetic-progression slices.

## Stuck: 2026-07-04 (task a, injection psi for f_0^{(m)} >= 0)

What I'm trying to show: an injection psi: C_m -> C_m of weight +m whose image
is disjoint from im(phi), where phi: C_{m-1} -> C_m is the Round-1 weight+1
injection. This gives f_0^{(m)} = (1-q^m) g_m - q g_{m-1} >= 0.

Why I can't show it: three genuinely different designs all failed.

## Escalation

I am stuck on: constructing the weight+m injection psi: C_m -> C_m
(equivalently proving MASTER at (k,j)=(0,0), i.e. f_0^{(m)} >= 0).

Attempt 1 (greedy least-slack ribbon, bottom-up with switch rule):
well-defined and total by the Slack/Switch lemmas, disjoint from im(phi) for
free (bottom level has >= 2 boxes), but NOT INJECTIVE. Concrete collision at
d=3, c=(1,1,1), m=2: chains ((0,1,0),(0,1,0)) and ((1,0,0),(1,0,0)) both map
to ((1,1,0),(1,1,0)). The greedy choice destroys the information of which
coordinate was originally occupied. Local repair attempts (tie-breaking by
occupancy) fail on other examples.

Attempt 2 (claim-based single-box alpha with canonical removal index j*):
designed so that psi is invertible by construction; but alpha is NOT TOTAL:
orphan states exist for every profile (e.g. c=(2,1,1): (2,0,0), (2,1,0),
(2,3,0), (3,0,1), ...). Verified exhaustively for all profiles d <= 8,
|u| <= 14 (script seed8_R2L2_alpha.py).

Attempt 3 (top-level add: add one box to level 1 only, then re-sort):
reduces to needing an injective weight+1 self-map on C_m, i.e. exactly
(1-q) g_m >= 0 = MASTER(-1, 1) -- circular, that is again an instance of the
same family. Diagonal translation a^(s) += (1,1,1) on selected levels gives
clean injective weight+3 moves (helps m == 0 mod 3) but disjointness from
phi-image and the m mod 3 != 0 cases remain unresolved.

What all three have in common: any "local box-adding" rule either loses
information (non-injective) or fails totality; the map seems to need a
GLOBAL canonical structure on chains.

What I think is needed: a crystal-operator structure. RAG hit
tingley/chunk_033: Tingley raises lifting U_q(sl_n-hat) crystal structures to
cylindric plane partitions as an open direction. A crystal raising operator
f_i would give exactly the canonical injective weight+1 partial map with
controlled domain/image -- the natural candidate for both phi-complements and
the psi tower. Recommend a dedicated seed on crystal structures for bounded
cylindric partitions / the chain model (chains in S = {a: a_i <= a_{i-1}+c_i
cyclically} are ready-made for a tensor-product-of-crystals analysis).

## Handoff

Status by task:
- (a) f_0^{(m)} >= 0: OPEN (RED). Three injection designs failed (see
  Escalation). Best lead: crystal operators on the chain model (Tingley).
- (b) exact (m-1)-fold q-monotonicity of f_0^{(m)}: verified computationally
  everywhere tested, exact boundary always (YELLOW). No proof; the
  Divisibility Transfer Lemma proves the "j | chain" slices only.
- (c) DONE computationally (GREEN as verification): f_k^{(m)} is exactly
  (m-k-1)-fold q-monotone for d=2 (m<=8), d=4 (m<=7, all orbits), d=5 (m<=6,
  all orbits), d=7 (m<=5, all orbits), k <= 4. Plus the unifying k=-1 row:
  g_m is exactly m-fold q-monotone. Tower induction mapped: level k+1 needs
  the FULL monotonized domination (q;q)_j(1-q^{m-k-1})f_k^{(m)} >=
  q^{k+2}(q;q)_j f_k^{(m-1)} from level k; positivity alone does not chain.

Proven this round (GREEN algebra, in proofs/prove-seed8-layer2.tex):
- Lemma T1: D_{k+1}^m = (q;q)_{m-k-1} f_k^{(m)} with the bracket recursion
  f_k^{(m)} = (1-q^{m-k}) f_{k-1}^{(m)} - q^{k+1} f_{k-1}^{(m-1)}, f_{-1}=g.
- Corollary T2: Q_n = f_{n-1}^{(n)}.
- Closed form: f_k^{(m)} = sum_{i=0}^{k+1} (-1)^i q^{i(i+1)/2}
  [k+1 choose i]_q (q^{m-k};q)_{k+1-i} g_{m-i}.
- Divisibility Transfer Lemma + Slack/Switch lemmas on the chain model.

Recommended next: (1) crystal structure on chains (weight+1 canonical
injections); (2) prove MASTER for the k=-1 row directly -- "g_m exactly
m-fold q-monotone" is the cleanest single statement implying the whole tower
IF the bracket recursion can be shown to preserve exact monotonicity (that
preservation is the real open lemma).

Scripts: scripts/seed8_R2L2_{tower.sage, psi.py, alpha.py, subsets.sage,
divmatch.sage}; logs alongside.
