# Seed 8, Layer 3, Round 2 — ADVERSARY

Mission: BREAK the consensus (H_{c,m} monotone in m / MASTER / BFF / N_n >= 0 / Uncu d=8).
Posture: prosecution. A verified counterexample redirects the program; a clean large-scale
confirmation hardens YELLOW. All counterexample claims must be EXACT Z[q].

## Plan

1. Exact engine: H-recursion (1+q^m+q^{2m}) H_{c,m} = Sum_{c'} q^{m*EMD(c',c)} H_{c',m-1} in ZZ[q].
   Reuse the verified EMD from seed3_R2L2_verify_d13_d14.sage.
2. Validate: (i) d=2 closed forms Q_n = q^{n^2}, q^{n(n+1)} via D-tower (Q_n = D_n^n);
   (ii) cross-check H_m against the INDEPENDENT truncated CW power-series solve (seed8 L2
   method) for d=4,5 all profiles m<=4.
3. Attack (a) MASTER at scale: d=13,16,17 (also deep d=7), m to 8-12.
   - polynomial cells: D_{k+1}^m = (q;q)_{m-k-1} f_k^(m) >= 0 for all 0<=k+1<=m (top j).
     Note D_m^m = Q_m — this tests Q-positivity itself far beyond any prior check.
   - series cells: f_k^(m) = D_{k+1}^m/(q;q)_{m-k-1} >= 0 (j=0; exact numerator => every
     computed coefficient exact; PREC >= 6*max(k,m)^2+200).
   - boundary: (1-q^{m-k})*D_{k+1}^m must have a negative (MASTER is an "iff").
   - Monotonicity H_m >= H_{m-1} and h_m >= 0 checked at every level, every profile.
4. Attack (b): BFF first level on wall orbits = a_n from Gauss inversion of H. NOTE
   (adversary's observation): Gauss inversion is a biorthogonality — ANY sequence H_m
   satisfies H_m = Sum_j [m,j] a_j with a_j the inversion. So the testable content of BFF's
   first level on wall orbits is exactly a_n >= 0, and IF the Q-transform is right, a_n = Q_n.
   Two tests: (i) a_n == D_n^n exactly at scale (stresses the unproved Q-transform),
   (ii) a_n >= 0 at wall orbits (0,2,2),(0,3,1) d=4 for n much larger than Layer 2 reached,
   plus d=7 (nothing proved at d=7).
5. Attack (c): N_n = (1+q^n+q^{2n})Q_n. Adversary note: Q_n >= 0 IMPLIES N_n >= 0
   (multiplication by a nonneg polynomial), so (c) only bites if Q_n itself fails; the deep
   D_n^n sweep covers it. Will report N_n explicitly where Q_n is computed.
6. Attack (d): Uncu S_11 match at d=8, n=7 (n=8 if affordable) — reuse Seed 5's scripts.

## Targeting heuristic (asymptotics / where would failure hide?)

- Track minimum coefficient margins of the tightest cells as (d,m) grow. If the consensus
  is false, margins should shrink to 0 before crossing; aim the deep runs at the orbits
  with smallest margins.
- Wall-type orbits (zero-containing, reversal-asymmetric, fermionic-resistant) are the
  predicted failure sites — they are where closed positive forms don't exist.
- Failure at small q-degree is ruled out by low-m checks; new negativity at level m first
  appears at high degree; scan full polynomial, report degree of any violation.

## Log

### FINDING 1 (methodological catch, not a counterexample) — EMD kernel orientation

The H-recursion kernel as implemented in seed3_R2L2_verify_d13_d14.sage (and stated in
synthesis-layer2.md standing notation as q^{m*EMD(c',c)} with emd(cp,c) source-first) computes
H for the REVERSED profile relative to the Corteel-Welsh machinery. Verified three ways:

1. Exact H-recursion (source-first kernel) vs truncated CW power-series solve: mismatches at
   d=4 exactly on the 6 permutations of {0,1,3}; at d=5 exactly on perms of {0,1,4},{0,2,3} —
   precisely the reversal-asymmetric multisets. H_src-first[c] == H_CW[reverse(c)] (up to C3).
2. Transposed kernel q^{m*EMD(c,c')} (target-first): matches CW solve for ALL profiles, d=4,5, m<=4.
3. Brute-force enumeration from the RAW cylindric-partition definition (conjecture.tex), d=4,
   c=(0,1,3) and (3,1,0), m=1,2, sizes<=12: matches CW solve per-profile exactly, NOT reversed.

Consequences:
- All aggregate positivity sweeps (seed3 d=13,14) remain VALID (profile set is reversal-closed);
  only labels flip.
- Dispute C2 (Seed 3 vs Seed 4 on which d=4 orbits lack fermionic forms: (0,3,1) vs (0,1,3))
  differs by EXACTLY this reversal — strong evidence both seeds found the same orbits under
  flipped conventions. Layer 3 Mission 1/6 should re-check with the target-first kernel.
- My engine (seed8_R2L3_engine.sage) now uses the target-first kernel, validated against the
  raw definition; d=2 closed forms Q_n = q^{n^2}/q^{n(n+1)} reproduced for n<=9 via Q_n = D_n^n.

### Validation status
- d=2: Q_n = D_n^n = q^{n^2} (orbit (1,1,0)), q^{n(n+1)} (orbit (2,0,0)), n<=9. PASS.
- d=4,5: H_m == (q;q)_m F_{c,m} vs independent CW truncated solve, all profiles, m<=4, mod q^50. PASS.
- Engine checks h_m >= 0, monotonicity H_m >= H_{m-1} at every level for every profile;
  MASTER grid (poly cells D_{k,m} >= 0 incl. Q_m = D_{m,m}; series cells f_k^(m), all j;
  boundary must-fail) per orbit rep.

## Computational Evidence (running tally — all EXACT Z[q] unless stated)

### Attack (a): MASTER + Monotonicity + h_m at scale — ALL CLEAN so far
Full MASTER grid = polynomial cells D_{k,m} >= 0 for all 0<=k<=m (top cell = Q_m),
series cells (q;q)_j f_k^(m) >= 0 for ALL 0 <= j <= m-k-1 (exact numerator, prec 6m^2+200),
boundary cells j = m-k VERIFIED TO FAIL (the "iff" holds), plus h_m >= 0 and H_m >= H_{m-1}
for ALL profiles at every level:
- d=7  m<=6  (12 orbit reps; 36 profiles h/mono): CLEAN, 0.1s
- d=13 m<=10 (35 reps; 105 profiles):             CLEAN, 4.3s   [log tmp/seed8_d13_m10.log]
- d=13 m<=14 (35 reps):                           CLEAN, 26.1s  [tmp/seed8_d13_m14.log]
- d=16 m<=12 (51 reps; 153 profiles):             CLEAN, 18.4s; Q_12(1)=50^12 ✓
- d=17 m<=12 (57 reps; 171 profiles):             CLEAN, 21.8s; Q_12(1)=56^12 ✓
Sanity anchors: Q_m(1) = (K-1)^m verified at every d; d=2 closed forms n<=9.

### Attack (b): BFF first level / Gauss inversion a_n — ALL CLEAN
a_n := Gauss inversion of {H_m}; tested (i) a_n == D_n^n EXACTLY (the unproved Q-transform),
(ii) a_n >= 0 (first-level BFF content; on wall orbits this IS Q_n >= 0):
- d=4  all 5 orbits incl walls (0,2,2),(0,3,1): n <= 25. CLEAN (Q-transform exact + a_n>=0)
- d=5  all 7 orbits: n <= 22. CLEAN
- d=7  all 12 orbits: n <= 18. CLEAN  (largest prior check at d=7 was n<=3!)
- d=8  all 15 orbits: n <= 16. CLEAN  (prior: n<=6)
- d=13 all 35 orbits: n <= 12. CLEAN
Adversary note: on wall orbits the only testable content of BFF-level-1 is a_n >= 0 —
Gauss inversion makes H_m = sum_j [m,j] a_j automatic for ANY H-sequence. The
m-independence-of-a_j part of BFF is not falsifiable from H data alone (it is exactly
the statement that the inversion has positive entries + fermionic shape).

### Attack (c): N_n
Q_n = D_n^n >= 0 verified at the scales above; N_n = (1+q^n+q^{2n})Q_n >= 0 follows
coefficientwise (product of nonneg polynomials). No independent content unless Q_n
fails — it did not.

### [CONTINUATION AGENT — predecessor killed mid-run; results below recovered from logs + new work]

### Attack (a) addendum — deeper sweeps the predecessor ran but never logged
Full MASTER grid + h_m + monotonicity, ALL CLEAN (exact Z[q]; logs in tmp/seed8_d*.log):
- d=13 m<=16 (35 reps): CLEAN, 62s. Q_16(1)=34^16 ✓
- d=19 m<=12 (70 reps): CLEAN; d=20 m<=12 (77 reps): CLEAN
- d=22 m<=10 (92 reps): CLEAN; d=23 m<=10 (100 reps): CLEAN
- d=25 m<=9 (117 reps): CLEAN; d=31 m<=7 (176 reps): CLEAN
(Sanity Q_m(1)=(K-1)^m with K = #C3-orbits holds at every d.)

### Attack (d1): Uncu S_11 vs exact engine at d=8, n=7,8 — ALL MATCH
seed8_R2L3_uncu78.sage: Uncu's proved S_11 forms (seed5 FORM table, PREC 420) vs EXACT
Q_n = D_n^n from the raw-definition-validated engine, mod q^390, all 15 orbits, n=7,8:
every cell match=True and Uncu-pos=True (predecessor run killed during last orbit (4,4,0);
rerun completed: tmp/seed8_uncu78_rerun.log). Prior frontier was n<=6.
Adversary note: this doubles as a 15-orbit LABELING test at d=8 — chirality-paired orbits
(e.g. (7,1,0)/(7,0,1)) both match under the identity labeling, no reversal swap.

### Attack (d2): Seed 2's FERM_3 theorem — INDEPENDENT CONFIRMATION n<=12 (they had n<=4)
seed8_R2L3_seed2_ferm3.sage: implemented the Corollary's manifestly positive quadruple sum
for Q_{n,(3,3,2)} directly (NOT their S_11 code) and compared to exact engine D_n^n at d=8:
EXACT polynomial match for n<=12 (deg Q_12 = 1008; full Z[q], no truncation), Q_n(1)=14^n,
identical at all three C3 rotations. Convention-safe: orbit of (3,3,2) contains its own
reversal. This exercises their whole 4-step chain (finite-form limit, Pochhammer split,
KR R3, Uncu m=11) end-to-end. VERDICT: Seed 2's theorem survives prosecution.

### Attack (d3): Seed 6's d=4 formulas — MATH CONFIRMED n<=40, but DICTIONARY ERRATUM FOUND
seed8_R2L3_seed6_walls.sage + seed8_R2L3_swapcheck.sage:

FINDING 2 (the adversary catch of this run — a convention bug, not a math hole):
The orbit dictionary printed in proofs/prove-seed6-layer3.tex ("In the project's (EMD
H-recursion) convention") is REVERSED for the two chirality-sensitive orbits. Against the
raw-definition-validated engine, their claimed CW(3,1,0)<->orbit{(0,1,3),(1,3,0),(3,0,1)}
FAILS already at n=1 (difference at q^4), and their CW(3,0,1) line fails symmetrically.
Root cause: Seed 6's H-tower uses the OLD source-first kernel (their own V1 notes
brute_F(c)=F_{rev(c)}), so their dictionary is stated in the reversed convention.
CORRECTED dictionary in raw conjecture.tex labels is the IDENTITY map:
  CW(c) <-> the C3-orbit containing c itself, for all five CW labels.
Consequences:
- Seed 6's THEOREM (d=4 complete: Q_n>=0, BFF, monotonicity, all 15 profiles) STANDS —
  the five formulas cover all five orbits regardless of labels; each is positive.
- In TRUE (conjecture.tex) labels the chirality-sensitive WALL orbit at d=4 is
  {(0,1,3),(1,3,0),(3,0,1)} (not (0,3,1)'s orbit); (0,2,2)-orbit wall is reversal-invariant.
  This settles dispute C2 in Seed 4's favor under raw labels, consistent with Seed 7's
  bookkeeping finding. ERRATUM should be attached to prove-seed6-layer3.tex.
- Anyone consuming Seed 6's dictionary together with the corrected engine would attach
  the wrong closed form to (0,1,3) vs (0,3,1) — exactly the false-verification vector the
  mission warned about.

Hardening sweep with corrected dictionary (tmp/seed8_seed6walls_n40.log): for n<=40,
all five CW formulas == exact engine Q_n (deg Q_40 = 4800), manifestly positive,
Q_n(1)=4^n, AND both Absorption Lemma identities A and B verified as EXACT polynomial
identities (Seed 6 had n<=13). VERDICT: Seed 6's mathematics survives prosecution at 3x
their range; only the dictionary transcription is wrong.

## Handoff

STATUS: YELLOW (no counterexample found; one convention bug caught; consensus HARDENED).

### What the adversary proved/disproved this run
1. NO COUNTEREXAMPLE anywhere, despite exact Z[q] sweeps far beyond all prior frontiers:
   - MASTER grid (= the full conjecture, per Seed 7's Theorem M) + h_m>=0 + monotonicity:
     CLEAN at d=7,13(m<=16),16,17,19,20,22,23,25,31 — every orbit, every cell, exact.
   - BFF/a_n (Gauss inversion): a_n == D_n^n exactly and a_n >= 0 at d=4 (n<=25), d=5 (22),
     d=7 (18), d=8 (16), d=13 (12), incl. all wall orbits.
   - N_n >= 0: implied by Q_n >= 0 wherever computed (no independent content).
   - Uncu S_11 vs exact engine, d=8, ALL 15 orbits + (4,4,0), n=7,8: ALL MATCH, all positive.
   - Seed 2's FERM_3 = G_{(3,3,2)}: independently reconfirmed EXACTLY to n=12 (was n<=4).
   - Seed 6's five d=4 formulas + Absorption A/B: exact identities to n=40 (was n<=13).
2. FINDING 1 (predecessor): H-recursion kernel orientation — target-first kernel
   q^{m*EMD(c,c')} is the one matching the raw conjecture.tex definition; source-first
   computes reversed profiles. Engine validated 3 ways.
3. FINDING 2 (this run): orbit dictionary in proofs/prove-seed6-layer3.tex is stated in
   the OLD reversed convention; fails at n=1 against raw labels. Corrected dictionary =
   IDENTITY (CW label c <-> orbit of c). Seed 6's theorem itself unaffected. In raw labels
   the d=4 chirality-sensitive wall orbit is {(0,1,3),(1,3,0),(3,0,1)}; settles C2
   consistent with Seed 7's finding. ERRATUM needed on prove-seed6-layer3.tex.

### For synthesis
- Both major Layer-3 positive claims (Seed 2 d=8 (3,3,2); Seed 6 d=4 complete) SURVIVE
  independent adversarial recomputation at 3-10x their verified ranges. Treat as GREEN
  modulo the Seed 6 dictionary erratum.
- Per Seed 7's Theorem M, all my clean MASTER grids ARE verification of the conjecture
  itself up to the stated (d,m): the conjecture now stands exact-verified at
  d in {2,4,5,7,8,13,16,17,19,20,22,23,25,31} to the depths above. Margins: min in-hull
  coefficients frequently hit 0 (support gaps at k=0,m=1,2 cells) but NEVER negative —
  no "shrinking margin" trend toward failure was observed as d grows.
- RECOMMENDATION: standardize ALL project artifacts on the raw conjecture.tex labeling
  (target-first kernel). Two convention bugs in two layers both arose at the
  chirality-sensitive orbit pairs; an automated label-audit of older layer files vs the
  raw-validated engine would be cheap insurance.
- Scripts (all under scratch/scripts/): seed8_R2L3_engine.sage (validated exact engine),
  _sweep.sage (MASTER at scale), _gauss.sage (BFF), _uncu78.sage (d=8 Uncu),
  _seed2_ferm3.sage, _seed6_walls.sage, _swapcheck.sage. Logs under scratch/tmp/seed8_*.
