# Scratch: Seed 3, Layer 3, Round 2 — The Second-Order Injection

## Mission
Prove the Monotonicity Conjecture: H_{c,m} >= H_{c,m-1} coefficientwise (gcd(d,3)=1),
where H_{c,m} = (q;q)_m F_{c,m}. First-order injection (g_m >= q g_{m-1}) is GREEN.
Second-order = absorb the alternating (q;q)_m signs.

Attacks (from mission brief):
(a) signed-set reformulation; injection on positive part after partial cancellation
    (Andrews–Bressoud / Berkovich–Garvan style).
(b) H-recursion operator analysis: what does T_m do to differences D_{c,m} = H_{c,m}-H_{c,m-1}?
    Find the induction that closes.
(c) d=2 differences are q^m * (shifted RR polynomial). Compute exact difference structure
    at d=4, 5 and look for the pattern = the injection's combinatorial meaning.

## Standing notation (synthesis-layer2)
- EMD(c',c) = 2e_0 + e_1 + 3*max(0,-e_0,-e_0-e_1), e = c'-c (source c', target c).
- H-recursion: (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}, H_{c,0}=1.
  Division exact for gcd(d,3)=1 (GREEN, L2).
- h_m = H_m - (1-q^m)H_{m-1} = D_m + q^m H_{m-1}, D_m := H_m - H_{m-1}.
- Orbit form: H_m = U(q^m) H_{m-1}, U_{ij}(x) in Z[x], U_{ij}(1)=1, K = (d+1)(d+2)/6 orbits.
- Alternative bracket: D_m = (q;q)_{m-1} (g_m - q^m F_{c,m}).
- IMPORTANT (synthesis 5a): Monotonicity is NOT the same statement as Seed 8's f_0^{(m)} >= 0
  (f_0^{(m)} = (1-q^m)g_m - q g_{m-1}). My prompt calls them equivalent -- synthesis says
  the brackets differ (q^m F_{c,m} vs q g_{m-1}). MUST test cross-implications numerically
  before trusting either direction. (Assumption flagged.)

## Structural identities to test (derived on paper, to verify)

From D_m = (U(q^m) - I) H_{m-1} and H_{m-1} = H_{m-2} + D_{m-1}:

    (R1)  D_m = U(q^m) D_{m-1} + [U(q^m) - U(q^{m-1})] H_{m-2}

(check: U(q^m)D_{m-1} + U(q^m)H_{m-2} - U(q^{m-1})H_{m-2} = U(q^m)H_{m-1} - H_{m-1} = D_m. OK.)

Questions:
- Q1: is U(q^m) D_{m-1} >= 0 by itself? (U has mixed entries, but D_{m-1} is a "history vector")
- Q2: is [U(q^m) - U(q^{m-1})] H_{m-2} >= 0 by itself?
- Q3: raw bracket g_m - q^m F_{c,m} >= 0 as power series? (Mission-2(a) from synthesis.)
- Q4: smoothing form D_m = (I - A(q^m)^T)^{-1} (A(q^m)^T - q^m I) H_{m-1};
      is the raw vector (A^T - q^m I)H_{m-1} >= 0? (expected NO -- find the negative shape.)
- Q5: structure of D_{c,m}: at d=2, D_{B,m} = q^m A_{m-1} (ANOTHER orbit's H at m-1!).
      Does D_{c,m} = sum_{c'} (monomial or nonneg poly in q, q^m) * H_{c',m-1} hold at d=4,5
      with nonneg coefficients? Fit it.

## Work log

### Script 1 (seed3_R2L3_diff.sage) — computational evidence, exact Z[q]

Cases: d=2 (m<=8), d=4 (m<=7), d=5 (m<=6), d=7 (m<=4). Monotonicity D>=0: PASS everywhere (re-verified).

- **Q1: U(q^m) D_{m-1} >= 0 — PASSES for ALL profiles at d=4,5,7. Fails ONLY at d=2 corner
  orbit (2,0,0) (m=2,4: negative coefficients).** Differences propagate positively through the
  transfer operator (except the d=2 corner anomaly, where val(D)=m+1 not m).
- Q2: [U(q^m)-U(q^{m-1})] H_{m-2} >= 0 — FAILS everywhere (every d, most (m,c)). So the R1
  splitting D_m = U(q^m)D_{m-1} + W_m does NOT give a positive decomposition; W_m is genuinely
  mixed. (Operator-argument monotonicity is false.)
- Q4: raw (A^T - q^m I)H_{m-1} >= 0 — FAILS almost everywhere (expected; smoothing genuinely
  needed; confirms Seed 3 L2 finding at scale).
- Q5: valuations: val(D_{c,m}) = m for every non-corner orbit; = m+1 exactly for the corner
  orbit (d,0,0). So D_{c,m} = q^m * (polynomial with nonneg constant term), corner shifted by q.

Interpretation: the d=2 anomaly (corner) is exactly where Seed 4 needed the auxiliary vector
C_{m-1} (D_A,m = q^{m+1} C_{m-1}, C NOT an H). Lesson: the closing induction likely needs an
AUGMENTED positive system (H's + D's + auxiliary surplus vectors), as at d=2.

Next: orbit-level U(x) matrices symbolically; exact D data at d=4; cone-membership fit
D_m in cone{ q^i H_{O',m-1}, q^i D_{O',m-1} }.

### Script 2 (seed3_R2L3_orbitU.sage): U-matrix structure at orbit level

d=2 orbits [A=(0,0,2), B=(0,1,1)]: U-I = [[x^2-x, x],[x, 0]]. Row B nonneg (identity (i));
row A mixed (needs C-vector, matches Seed 4).

d=4 orbits [(0,0,4),(0,1,3),(0,2,2),(0,3,1),(1,1,2)]: **row (1,1,2) of U-I = [x^3,x,x,x^2,0]
is ENTIRELY NONNEG** — monotonicity for the all-positive orbit is manifest:
D_{(1,1,2),m} = q^{3m}H_{004} + q^m H_{013} + q^m H_{022} + q^{2m}H_{031} (at m-1). FREE.
Conjecture A: for every all-positive target c (c_i>=1 all i), all orbit EMD-triples are
consecutive, so the U-I row is nonneg and monotonicity at c is manifest.
NOTE the reversal vs Seed 6's G-level propagation: there zero-containing profiles were easy
and all-positive was the hard core; at the H-level it is the OPPOSITE. Hard targets here:
zero-containing orbits.

### Script 3 (seed3_R2L3_matrixM.sage): depth-k matrix positivity DEAD

M_m = U(q^m)U(q^{m-1}) - U(q^{m-1}) has negative entries for ALL d in {2,4,5,7,8}, all m
tested; depth-3 and depth-4 products likewise. Yet M_m * 1-vector = D_2 >= 0 (m=2 case).
Conclusion: positivity is NOT entrywise at any fixed smoothing depth; the cancellation is
against the aggregated history vector. Fixed-depth matrix-cone route: DEAD. (Not counted as
an injection strike; it was a reduction test.)

### The epsilon-inequality / invariant-cone plan (attack b, sharpened)

Write (U-I)_{c,O}(x) = sum_j x^j eps^{(c,j)}_O with eps in {-1,0,+1}. Then
D_{c,m} = sum_j q^{jm} * (eps^{(c,j)} . H_{m-1}). SUFFICIENT: eps^{(c,j)} . H_{m-1} >= 0
for each j — m-independent linear inequalities on the H-vector. Example d=4, target (0,3,1):
   G1: H_{112} + H_{004} - H_{031} >= 0   (coefficient of q^m)
   G2: H_{013} + H_{022} - H_{004} >= 0   (coefficient of q^{2m})
Plan: (A) harvest all eps-inequalities for d=4,5,7,8 and verify on exact H data;
(B) attempt cone closure: expand eps.H_m = eps.U(q^m)H_{m-1}, regroup by x-powers, check new
eps' vectors are implied (LP) or add and iterate. Worry: at d=2 the propagated grouping of
(e_B - e_A) produces -H_A at x^2 — naive closure fails at d=2; maybe better at d>=4, or
needs combined groups. COMPUTE.

## Session 2 (continuation agent) — eps-cone falsified; three injection strikes; ribbon-Hall reframe

### Script 4 (seed3_R2L3_epscone.sage): eps-cone / invariant-cone route FALSIFIED

Ran the predecessor's Step A on d=4,5,7,2. **ALL eps-inequalities fail at m=1** (e.g. d=2:
eps=(-1,1) i.e. H_B - H_A >= 0 already false at m=1; d=4: every mixed-sign eps fails at m=1).
The x-power grouping of U-I rows is too coarse: the coefficient-of-q^{jm} decomposition
D_m = sum_j q^{jm} (eps^{(j)} . H_{m-1}) does NOT split into termwise-nonneg pieces.
The cancellation is BETWEEN x-power groups. Attack (b)/eps-cone: **DEAD**. Log: seed3_R2L3_epscone.log.

### Injection Design #4 = STRIKE 1 (seed3_R2L3_fullcol.py): full-column insertion

Design: ψ(chain) = add one box at every level in the least COMMON-slack coordinate
("insert a full column of height m"). Weight +m, chain preserved when a common slack exists.
Failures (T2): (i) some chains have NO common-slack coordinate at all
(slack sets at different levels can be disjoint); (ii) collisions u+col_i = v+col_j (i≠j)
everywhere, e.g. d=4 c=(4,0,0). Worse, the WHOLE part-insertion move space is inadequate:

### Adjudication by Hall's condition (seed3_R2L3_matching.py, seed3_R2L3_ribbonhall.py)

Bipartite graphs per (d,c,m,weight-class); Kuhn max-matching decides whether ANY injection
exists within a given move-set. Results:
- **Column-insertion moves (single coordinate, all levels): Hall FAILS** for both targets —
  f_0 (C_m -> C_m, wt+m) and monotonicity (F_m -> C_m). Deadend chains exist, e.g. d=2
  c=(1,1,0) m=3 wt=6 (matched 7/11); d=4 c=(0,3,1): ((0,3,4),(0,3,0)); d=5 c=(5,0,0):
  ((5,0,0),(0,0,0)). Part-insertion family: **conclusively inadequate** (proof-grade: these
  are finite certificates).
- **Ribbon moves (one box per level, ANY coordinate per level, chain valid): Hall HOLDS in
  all 22 cases tested** (d=2 m<=4 wt<=11; d=4 m<=3 wt<=10; d=5 m<=3 wt<=9; d=7 m=2 wt<=9),
  max deficiency = 0 everywhere. Same for the rich move-set (any levelwise w>=u with wt+m).

**KEY REFRAME.** An injection C_m -> C_m of weight +m EXISTS inside Seed 8's own ribbon move
space at every weight class tested. The obstruction that killed greedy-ribbon/claim-alpha/
top-add (and my designs) is CANONICITY of the rule, not EXISTENCE of the matching. The
well-posed finite target is now:

    (HALL-RIBBON) For every antichain... rather: for every set B of weight-w chains in C_m,
    #N_ribbon(B) >= #B, where N_ribbon(B) = weight-(w+m) chains reachable by a ribbon move.

By LP duality a FRACTIONAL matching suffices for the coefficient inequality — no bijective
rule needed. This is strictly weaker than all four failed injection designs.

### STRIKE 2 (seed3_R2L3_fracmatch.py): uniform fractional matching

Natural candidate x(u,w) = 1/r_out(u): infeasible — inflow at some w up to 181/90 > 1
(e.g. d-small case w=((2,2,2),(1,1,1)) inflow 16/9). Local degree condition
r_out(u) >= r_in(w) fails badly (min margin -8). Uniform/local-rule fractional matchings: DEAD.
Hall must be proved via the deficiency version / structural counting, not a local weighting.

### STRIKE 3 (seed3_R2L3_monoiota*.sage): levelwise monotone reduction REFUTED

New reduction lemma (this session): if ι: S -> S is injective, weight+1, and MONOTONE
(a<=b => ι(a)<=ι(b)), then applying ι to every level maps C_m -> C_m injectively with
weight +m, giving f_0^(m) >= 0 for ALL m at once. (Monotonicity preserves the chain
condition; disjointness from im(φ) is automatic.) Tested existence of ι by ILP on rank
truncations S_{<=W} (infeasibility on a truncation => global nonexistence, since the
constraints are a subset).
- V1 (single-box moves + consistency (M)): **INFEASIBLE for ALL 10 profiles tested**,
  including d=2. This uniformly explains every local-rule failure of Seed 8: no consistent
  slack-selection rule exists even at d=2.
- V3 (fully general monotone injective weight+1 map): dichotomy —
  FEASIBLE (at tested W): (1,1,0)W8 (2,0,0)W8 (2,1,1)W7 (1,1,2)W7 (7,0,0)W6 (3,2,2)W6;
  INFEASIBLE => globally NONEXISTENT: (4,0,0)W6 (0,3,1)W6 (5,0,0)W6 (0,2,2)W7 (0,1,3)W7
  (3,1,1)W7 (4,2,1)W6 (2,2,0)W7 (3,1,0)W7 (0,4,1)W6.
  Caution: feasible-at-small-W is inconclusive ((4,0,0) flips FEASIBLE W=5 -> INFEASIBLE W=6).
  Sample d=2 solutions use non-cover moves, e.g. (1,0,0)->(0,1,1), (2,1,1)->(1,2,2).
Conclusion: the levelwise route is **closed for the hard (zero-containing/wall) orbits** —
exactly where monotonicity is non-manifest (matches Script 2's finding that all-positive
orbits are free). Any working ψ MUST couple levels.

### Positive numerical finding: raw bracket (synthesis Mission 2a)

g_m >= q^m F_{c,m} coefficientwise: **HOLDS in all 6 cases tested** (d=2,4,5,7; T4 in
seed3_R2L3_fullcol.py). Note D_m = (q;q)_{m-1}(g_m - q^m F_m), so this is necessary
evidence but not sufficient for D_m >= 0. Status: YELLOW, worth its own attack.

### Paper observations (for whoever formalizes)
- S = {a : a_i <= a_{i-1 mod 3} + c_i} is a DISTRIBUTIVE LATTICE (closed under componentwise
  min and max — direct check on the defining inequalities).
- If c_i >= 1 then any minimal coordinate of a is slack. argmin(a_i - mu_i) satisfies the
  consistency condition (M) but is not injective (collision type w=(1,1,5)).
- Corner orbit (d,0,0) is consistently the extreme case: val(D)=m+1, V3-infeasible, Hall
  deadends — the corner needs the auxiliary-vector treatment (cf. d=2 Seed 4 C-vector).

## Handoff

Status: NO proof of f_0^(m) >= 0; three design families conclusively fenced off with finite
certificates; one route falsified; one new well-posed target opened.

DO NOT RETRY: (1) eps-cone / x-power grouping of U-I (fails at m=1); (2) any part-insertion
(full-column) injection (Hall fails, certificates in seed3_R2L3_matching.log); (3) uniform or
local-degree fractional matchings; (4) any LEVELWISE rule ψ (V1/V3 ILP nonexistence on the
wall orbits — this subsumes greedy-ribbon/claim-alpha/top-add AND all single-level rules).

DO NEXT (recommended, in order):
1. **Prove HALL-RIBBON**: for every set B of C_m-chains at weight w, the ribbon-neighborhood
   at weight w+m is at least as large. Holds in all 22 tested cases with deficiency 0.
   Fractional matchings suffice (LP duality) — look for a non-uniform weighting with
   structure (e.g. proportional to #slack per level, or lattice-theoretic via S distributive
   + Dilworth/normalized matching property of products of chains/lattices).
2. The distributive-lattice structure of S suggests the NORMALIZED MATCHING PROPERTY /
   log-concavity machinery (Harper, Hsieh-Kleitman style) — chains in a normalized-matching
   poset product may inherit the property. RAG: "normalized matching property product posets
   LYM Peck" — this is the only structural route left that matches the data.
3. Raw bracket g_m >= q^m F_m: independent, numerically clean, may have its own injection
   (F_m-chains with zero levels map naturally into C_m by deleting zeros + reinserting).
4. Corner orbits need auxiliary vectors regardless (d=2 precedent).

Scripts this session: seed3_R2L3_epscone.sage(+.log), seed3_R2L3_fullcol.py,
seed3_R2L3_matching.py(+.log), seed3_R2L3_ribbonhall.py(+.log), seed3_R2L3_fracmatch.py,
seed3_R2L3_monoiota.sage, seed3_R2L3_monoiota_v3.sage, seed3_R2L3_v3map.sage.
