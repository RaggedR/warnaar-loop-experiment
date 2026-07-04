# Seeds for Round 2, Layer 3 — 2026-07-04 (RE-SEEDED)

Generated from the findings of Layer 2 (synthesis-layer2.md). Unlike the Round 2
opening seeds (../seeds/seeds.md), which spread across five proof paths, ALL EIGHT
of these seeds target the single path Layer 2 zeroed in on:

> **Core bottleneck:** H_{c,m} := (q;q)_m F_{c,m} is coefficientwise monotone in m
> (H_{c,m} >= H_{c,m-1}), equivalently f_0^(m) >= 0, equivalently the first level of
> the Bounded Fermionic Form conjecture. Plus two concrete endgames: d=4 (smallest
> unsolved) and d=8 (Uncu's proved S_11 series).

Each seed is a RAG query + rationale. Context files: seed_N_context.txt (top-20).
Old seeds retired but kept at ../seeds/ for the record.

## Seed 1 — Finite Rogers-Ramanujan polynomials and q-Pascal recurrences
**Query:** `"finite Rogers-Ramanujan polynomial q-binomial Schur polynomial recurrence q-Pascal bounded Andrews-Gordon positivity"`
**Rationale:** At d=2 the bottleneck objects H_{c,m} ARE the classical RR polynomials
Σ q^{j²+aj} [m,j]_q, and monotonicity follows from q-Pascal (Seeds 3+4, Layer 2,
independent proofs). Mission: generalize the q-Pascal argument to the U-tower
H_m = U(q^m)H_{m-1} for gcd(d,3)=1. Need everything known about Schur/MacMahon/
Andrews finite RR analogues and their recurrence structure.

## Seed 2 — A2 Bailey machinery and the Kanade-Russell mod-11 identities
**Query:** `"Bailey pair A2 Bailey lemma Kanade-Russell mod 11 conjecture Rogers-Ramanujan type identity proof Uncu"`
**Rationale:** Uncu 2024 proved the S_11 formulas for all 15 canonical orbits at d=8
(Layer 2, Seed 5). Warnaar's Conjecture 2 for k=3 is now the FINITE identity
FERM_c = (q)_inf * S_11(e_{c2}|e_{c3}) — both sides explicit. Mission: prove it with
Bailey-pair / q-hypergeometric transformation machinery. Need the ASW A2 Bailey
lemma and how Uncu/Kanade-Russell proofs are structured.

## Seed 3 — Injections and coefficientwise inequalities between partition GFs
**Query:** `"injective proof partition inequality generating function coefficientwise dominance monotonicity difference nonnegative combinatorial injection"`
**Rationale:** The bottleneck in one sentence: adding one more allowed row never
decreases the (q;q)_m-weighted count of bounded cylindric partitions. The injection
lemma (g_m >= q g_{m-1}) is proved; the second-order version f_0^(m) >= 0 defeated
three injection designs (Layer 2 Seed 8 — read the post-mortems, do NOT retry
greedy-ribbon/claim-alpha/top-add). Need the literature of partition injections for
q-series inequalities (subtler than plain containment).

## Seed 4 — Sign-reversing involutions and the Garsia-Milne principle
**Query:** `"sign-reversing involution Garsia-Milne involution principle alternating sum cancellation weight preserving bijection partition identity"`
**Rationale:** Layer 2 Seed 7 compressed ALL n=2 negativity into ONE negative
coefficient per rank-3 profile (N_2 Shape Theorem) — a vastly smaller signed set
than the 4822-element space that defeated Layer 1's involution hunt. Mission: build
the involution on the compressed target; lift via the Master Recursion. The Adjugate
Monomial Theorem's own proof (J -> J triangle {k}) shows involutions work here.

## Seed 5 — Crystal operators on chains and weight-monotonicity
**Query:** `"crystal operator affine sl3 Demazure crystal string decomposition weight space monotonicity branching graded dimension"`
**Rationale:** Seed 8's escalated lead for f_0^(m) >= 0: realize the chain/transfer-
matrix model as a crystal and use operators to build the injection structurally.
Also Layer 2 Seed 2's finding that the energy function is constant on profile pairs
suggests hidden crystal symmetry at the right level. Need string/Demazure operator
technology, NOT the dead Kyoto-truncation route (BA18).

## Seed 6 — Corteel-Welsh systems, R-relations, and positivity propagation
**Query:** `"cylindric partition functional equation system profile positivity propagation Corteel Welsh recurrence level 4 modulus 7"`
**Rationale:** Layer 2 Seed 6's Propagation Theorem reduces all-profile positivity
to the all-positive core via manifestly positive R-relations. d=4 (modulus 7) is the
smallest unsolved case: 3 orbits have proved-shape fermionic forms, walls are
(0,2,2) and (0,3,1) (verifier-adjudicated). Mission: finish d=4 completely.

## Seed 7 — q-binomial inversion and bounded-to-unbounded transforms
**Query:** `"Gauss inversion q-binomial transform bounded analogue finitization polynomial identity limit q-series Andrews"`
**Rationale:** The Q-transform Q_n = Σ_m (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m} is
verifier-confirmed for d=2,4,5 but unproved. If H_{c,m} = Σ [m,j]_q a_j (BFF), Gauss
inversion gives Q_n = a_n >= 0 DIRECTLY. Mission: make the foundation rigorous and
characterize when a bounded family admits a nonneg q-binomial expansion. Warnaar
explicitly lists bounded A2 AG identities as open — this seed is that problem.

## Seed 8 — ADVERSARY: asymptotics, sign patterns, and stress-testing positivity
**Query:** `"coefficient asymptotics q-series sign pattern positivity conjecture counterexample theta quotient modular cylindric partition character"`
**Rationale:** Consolidating 8 seeds onto one path maximizes groupthink risk, and
Round 2's biggest win was overturning an "established" result (BA2). This seed's
mission is to BREAK the consensus: hunt counterexamples to the MASTER conjecture
((q;q)_j f_k^(m) >= 0 iff j <= m-k-1), BFF on wall orbits, and N_n >= 0, at large
d, m, n with exact Z[q] arithmetic via the H-recursion. Confirmation at scale
hardens YELLOW; a single counterexample redirects the entire program.
