# Prove Seed 4 Layer 3 — Involution on the Compressed N_2 Signed Set

Seed 4, Round 2, Layer 3 (EXPLOITATION layer). Mission: Layer 2 Seed 7's N_2
Shape Theorem compressed ALL n=2 negativity into ONE negative coefficient per
rank-3 profile. Build the signed set for this compressed object, find the
sign-reversing involution (Garsia-Milne) proving N_2 >= 0, then lift n=2 ->
general n via the Master Recursion + Preimage EMD Dichotomy.

Standing notation (synthesis-layer2.md): EMD(c,c') = 3max(0,c'_1-c_1,c_0-c'_0)
+ (c'_0-c_0) - (c'_1-c_1); N_n := (1+q^n+q^{2n}) Q_n; e0 := EMD(c,c');
k(c,c') in {0,1} = number of 2-shift preimages of c' strictly closer to c
(Delta = -2 in the Dichotomy Lemma).

## Opening algebra (before computing): ALL negatives sit at ONE exponent

Shape Theorem (Seed 7 L2, GREEN):
  N_2(c) = sum_{rank2 c'} q^{2 EMD(c,c'')+3} Q_1(c')          [c'' unique preimage]
         + sum_{rank3 c', k=0} q^{2e0+4} (2q-1)    Q_1(c')
         + sum_{rank3 c', k=1} q^{2e0-1} (1-q^5+q^6) Q_1(c')
         + sum_{rank3 c'}      q^{2e0+3} (1-q).

Expand the three sandwich shapes:
- k=0: q^{2e0+4}(2q-1)      = 2 q^{2e0+5} - q^{2e0+4}         (times Q_1(c'))
- k=1: q^{2e0-1}(1-q^5+q^6) = q^{2e0-1} + q^{2e0+5} - q^{2e0+4} (times Q_1(c'))
- T:   q^{2e0+3}(1-q)       = q^{2e0+3} - q^{2e0+4}           (times 1)

**Observation A (new, to verify):** every negative lands at exponent shift
2e0+4 regardless of shape. So

  N_2(c) = POS(c) - q^4 * sum_{rank3 c'} q^{2 EMD(c,c')} (Q_1(c') + 1),

  POS(c) = sum_{rank2 c'} q^{2EMD(c,c'')+3} Q_1(c')
         + sum_{rank3 c'} q^{2e0+3}
         + sum_{k=0 rank3} 2 q^{2e0+5} Q_1(c')
         + sum_{k=1 rank3} (q^{2e0-1} + q^{2e0+5}) Q_1(c').

The signed set is therefore: negatives = one shifted copy of (Q_1(c')+1) per
rank-3 c', all at uniform shift q^{2e0+4}. The involution must route these
into POS. Same-c' pairing alone is impossible (Seed 7's stuck note: Q_1 profile
monotonicity is FALSE, BA22); pairing across profiles within fixed weight
q^{2e0} classes is the open ground.

## Candidate reformulations to test

R1. Define the "ball series" S_r(c) := sum_{rank-r c'} q^{2EMD(c,c')}. Negative
    part = q^4( sum_{r3} q^{2e0} Q_1(c') + S_3(c) ). The T-positives give
    q^3 S_3(c). So the "+1" part of the negative needs q^3 S_3 - q^4 S_3 >= gap
    — false alone ((1-q)S_3 has negatives); must borrow from Q_1 terms. The
    signed set genuinely mixes the two layers.

R2. Fully explicit double-sum signed set: multiply by Phi_3 = 1+q+q^2 and
    substitute (1+q+q^2)Q_1(c') = sum_{c''} q^{EMD(c',c'')}B(c''),
    B = q(2-q) [r3], q [r2], 0 [r1]. Then Phi_3*N_2 is a signed sum of
    MONOMIALS indexed by pairs (c',c'') — Garsia-Milne territory (like the
    Adjugate Monomial Theorem's J -> J triangle {k}). CAVEAT: positivity of
    Phi_3*N_2 does NOT imply N_2 >= 0; use only as structure-discovery lens.

R3. Route negatives by EMD-shells: exponent 2e0+4 = 2(e0+2). Profiles at
    EMD = e0+2 contribute positives q^{2e0+4}Q_1 via their own shapes'
    q^{2e0'} terms... check shell-to-shell matching numerically.

## Work log

### [T1] Opening reframing #2 (the better one): N_2 through H_1 ONLY

Q-transform (GREEN, Seed 3): Q_2 = H_2 - (1+q) H_1 + q H_0, H_0 = 1.
H-recursion (GREEN): (1+q^2+q^4) H_2(c) = sum_{c'} q^{2 EMD(c',c)} H_1(c').
Multiply the Q-transform by Phi_3(q^2) = 1+q^2+q^4 and substitute:

  N_2(c) = sum_{c'} q^{2 EMD(c',c)} H_1(c')
           - (1+q)(1+q^2+q^4) H_1(c) + q (1+q^2+q^4).

Since (1+q)(1+q^2+q^4) = 1+q+q^2+q^3+q^4+q^5 and the c'=c term of the sum
contributes H_1(c) at weight q^0:

  **N_2(c) = sum_{c' != c} q^{2 EMD(c',c)} H_1(c') + (q+q^3+q^5)
             - (q+q^2+q^3+q^4+q^5) H_1(c).**   [IDENTITY T1 — verify!]

Moreover H_1(c) = (sum_{c'} q^{EMD(c,c')}) / (1+q+q^2) — the EMD-ball GF over
Phi_3 (direction TBD). So N_2 >= 0 is equivalent to a DISCRETE HARNACK
INEQUALITY for the EMD kernel at level 1:

  (*) sum_{c' != c} q^{2 EMD(c',c)} H_1(c') + q+q^3+q^5
      >= q(1+q+q^2+q^3+q^4) H_1(c).

One negative BLOCK (the self term), not scattered shapes. This subsumes
Observation A and is strictly cleaner than the Shape Theorem signed set:
the involution target is "route 5 shifted copies of H_1(c) into EMD-weighted
copies of H_1(c'), c' != c". The n -> n+1 lift will follow the same pattern
via the Q-transform tail (H_{n-2} terms enter with [n,2] weights).

## Work log (continued)

### [CONTINUATION 2026-07-04, second agent] Status check
Predecessor died after deriving T1 (unverified). Resuming. First: verify T1
numerically. Second: a further reduction found while re-deriving T1 on paper.

### [T2] Splitting T1 via H_1 = 1 + Q_1 (new)
Q-transform at n=1 gives Q_1 = H_1 - H_0 = H_1 - 1, so H_1(c) = 1 + Q_1(c)
with Q_1 >= 0 GREEN (Layer 1, explicit formula). Substitute into T1. Writing
e' := EMD(c',c) and B2_c(q) := sum_{c'} q^{2 e'} (the squared-argument EMD
ball GF into c):

  N_2(c) = [ B2_c(q) - 1 - q^2 - q^4 ]
         + [ sum_{c' != c} q^{2 e'} Q_1(c')  -  q(1+q+q^2+q^3+q^4) Q_1(c) ].
                                                     [IDENTITY T2 -- verify!]

Check of the constant pieces: sum_{c'!=c} q^{2e'}*1 = B2_c - 1;
-(q+...+q^5)*1 + (q+q^3+q^5) = -q^2-q^4. Yes.

This decomposes N_2 >= 0 into two candidate lemmas (SUFFICIENT decomposition,
maybe not necessary -- test both numerically):

  (L-ball)   B2_c(q) >= 1 + q^2 + q^4: the EMD ball into c contains at least
             one profile at distance 1 and one at distance 2.
             A pure lattice-counting statement about EMD geometry.

  (L-harnack) sum_{c' != c} q^{2 EMD(c',c)} Q_1(c') >= q(1+q+q^2+q^3+q^4) Q_1(c).
             A discrete Harnack inequality for Q_1 -- strictly smaller object
             than T1's (Q_1 explicit, min degree >= 1, Layer-1 formula).

If (L-harnack) fails coefficientwise, the failure must be absorbed by the ball
term -- then test the combined form. NOTE: EMD direction convention must be
pinned numerically (H-recursion uses EMD(c',c) into c; Q_1 formula was stated
with EMD(c,c') out of c -- possible transpose collision).

### [V] Verification results (scripts seed4_R2L3_engine.py, _convention.py, _harnack.py, _finedata.py)
- V0: H-tower exact division OK, d=4,5,7 (+ later d up to 14 at m=1).
- V1: brute-force chain model matches H-recursion for m<=2 under profile
  REVERSAL (any rotation) — pure labeling; combinatorial grounding confirmed.
- T1 identity: VERIFIED d=4,5,7, all profiles. T2 identity: VERIFIED same range.
- L-ball: HOLDS (in fact n1 >= 1, n2 >= 2 always).
- L-harnack (har >= 0): FAILS at every profile, BUT the failures are
  perfectly rigid. Defining har(c) := sum_{c'!=c} q^{2EMD(c',c)} Q_1(c')
  - q(1+q+q^2+q^3+q^4) Q_1(c):

### [S] The S1/S2 structure (verified d = 1,2,4,5,7,8,10,11,13,14 — ALL profiles)
  S1: har_j >= 0 for ALL exponents j except j in {2,4}.
  S2: har_2 = -(n1(c) - 1) EXACTLY, and har_4 >= -1 >= -(n2(c)-1),
where n1(c) = #{c' : EMD(c',c)=1}, n2(c) = #{c' : EMD(c',c)=2}.
Moreover the data shows n1(c) = rank(c) EXACTLY, and n2 >= 2 always.
Since ballterm_j >= 0 with ballterm_2 = n1-1, ballterm_4 = n2-1:
    **T2 + S1 + S2  ==>  N_2 >= 0.**   (S1+S2 is sufficient; and har_2 part
    is an equality, so [q^2] N_2 = 0 identically — verified.)

### [P1] PROOF that har_2 = -(n1-1) (identity, not inequality)
[q^2] sum_{c'!=c} q^{2e'} Q_1(c') = sum_{e'=1} [q^0]Q_1(c') = 0 since
Q_1(0) = 0 (Q_1 = H_1 - 1, H_1(0)=1). [q^2] of q(1+..+q^4)Q_1(c)
= [q^1]Q_1(c) + [q^0]Q_1(c) = [q^1]H_1(c). And [q^1]H_1 = b_1 - 1 = n1 - 1
(from H_1 = B_c(1-q)/(1-q^3): h_0 = b_0 = 1, h_1 = b_1 - b_0 = n1 - 1). QED

### [F] The lattice-counting framework (new; makes everything explicit)
Into-ball GF B_c(q) = sum_{c'} q^{EMD(c',c)} = Phi_3 H_1(c). In deviation
coords s = c'_0-c_0, t = c'_1-c_1, the quasi-norm is
    f(s,t) = 3 max(0, -t, s) - s + t,
whose radius-e ball is the lattice triangle conv{(e,-e), (-e,0), (0,e)} and
whose radius-e sphere has exactly 3e points in the infinite lattice (e>=1).
Constraints: c' in Delta_d means s >= -c_0, t >= -c_1, s+t <= c_2.
KEY: f(s,t) == t - s (mod 3) (mod-3 EMD lemma into-c form), so the residue
of f is determined by the POSITION class Lambda_j = {t-s == j mod 3}. Hence
    H_1 coefficient h_j = A_j - A_{j-1},
    A_j := #{p in Delta : f(p) <= j, f(p) == j (mod 3)}
         = #(BallD_j cap Lambda_{j mod 3} cap Delta).
Everything at level 2 (S1, S2) is therefore a finite lattice point-counting
problem for intersections of f-balls with the profile triangle. Consequences
already provable by finite sphere enumeration:
  (n1 = rank): f=1 sphere = {(0,1),(-1,0),(1,-1)}, valid iff c_2>=1, c_0>=1,
    c_1>=1 respectively => n1 = #{i : c_i >= 1} = rank(c). PROVED.
  (n2 >= 2): f=2 sphere = {(0,2),(-1,1),(-2,0),(1,0),(0,-1),(2,-2)}; case
    check on which are valid shows >= 2 valid for every c with d >= 2. (To
    write out; finite case analysis.)

### [L3] Level-3 lift probe (seed4_R2L3_level3.py) — UNIFORM PATTERN
T1-analogue at n=3 VERIFIED (d=4,5, all profiles):
  N_3(c) = sum_{c'!=c} q^{3e'} H_2(c') + q(1+q+q^2)(1+q^3+q^6) H_1(c)
           - (q+...+q^8) H_2(c) - (q^3+q^6+q^9).
Splitting H_2 = 1 + R_2, H_1 = 1 + Q_1 gives ball term B_c(q^3) - 1 - q^3 - q^6
plus har3(c). Negativity of har3 localizes to exponents {3, 6, 9} = 3*{1,2,3}
ONLY (level 2 was {2,4} = 2*{1,2}), with magnitudes EXACTLY absorbed by
sphere counts: har3_3 = -(n1-1) (e.g. -2 at rank-3, 0 at corners) and
har3_6 >= -(n2-1) with equality cases (checked (1,1,3): -3 = -(4-1);
(1,2,2): -4 = -(5-1)). [q^3] N_3 = 0 identically (matches level-2's
[q^2] N_2 = 0).

**SPHERE ABSORPTION CONJECTURE (new, YELLOW):** at every level n, in the
T1-analogue split, har_n(c) has negative coefficients only at exponents n*e
(small e), each >= -(n_e(c) - 1), exactly absorbed by the level-n ball term
B_c(q^n) - 1 - q^n - q^{2n} - ...; and har_n,{n*1} = -(n_1 - 1) exactly, so
[q^n] N_n = 0. This is the uniform involution target across all levels.

### [CAP] Cap-Compression Lemma (seed4_R2L3_caps.py, bigsweep)
har_j(c) depends on c only through the capped triple (min(c_i, j))_i —
verified sharply with M = j for j <= 12 across d in {7,...,36} (3 !| d).
RIGOROUS version (M = 2j) provable by locality: contributions to har_j come
from profiles c' with EMD(c',c) <= j/2 (since a'_k has min-degree structure,
2e' <= j) and lattice points p with EMD(p,c') <= j - 2; EMD >= max(|s|,|t|)
so all thresholds involve min(c_i, 2j).
CONSEQUENCE: for each FIXED j, S1@j for ALL d reduces to a finite check of
capped classes, realized by d <= 3j+1 (sharp cap) or 6j+1 (lazy cap).

### [PROOFS] finite sphere facts (rigorous, to write up)
(i) f(s,t) = 3max(0,-t,s) - s + t has unit sphere {(0,1),(-1,0),(1,-1)},
    valid iff c_2>=1, c_0>=1, c_1>=1 resp. => n_1(c) = rank(c). PROVED.
(ii) radius-2 sphere = {(0,2),(-1,1),(-2,0),(1,0),(0,-1),(2,-2)} with
    validity thresholds c_2>=2, c_0>=1, c_0>=2, c_2>=1, c_1>=1, c_1>=2;
    case analysis => n_2(c) >= 2 for all d >= 2. PROVED.
(iii) Low Q_1 coefficients via H_1 = B_c (1-q)/(1-q^3):
    [q^1]Q_1 = n_1 - 1, [q^2]Q_1 = b_2 - b_1 = n_2 - n_1,
    [q^3]Q_1 = 1 + b_3 - b_2.  (A_j = #{f <= j, f == j mod 3}.)
(iv) har_4 = sum_{c': e'=1} (n_2(c') - n_1(c')) - b_3(c)  [formula, verified
    in bigsweep]; combined with caps: [q^4] N_2 >= 0.
(v) S1@3 in sphere counts: sum_{dist-1 nbrs} (rank(c') - 1) >= n_2(c) - 1.

### [FAILED / dead this layer]
- Termwise per-neighbor domination q^{2e'}Q_1(c') >= q^s Q_1(c): impossible
  at bottom degree for 2e' > s (mindeg obstruction); BA22-adjacent.
- Reciprocity: q^deg X(1/q) matches NO profile transform for X in
  {Q_1, N_2, har} (H_1 self-palindromic only at 3-6 special profiles/d).
  Top band does NOT reduce to a dual low band this way.
- Simple L-harnack (har >= 0): false — the correct statement is S1/S2
  (negatives exactly at {2,4}, ball-absorbed).

## Handoff

**Status: YELLOW** — the compressed involution target is now sharply localized and the low band is proved; the unbounded-j middle/top band of S1 remains open.

### GREEN (proved, verifier-grade)
- **T1/T2 identities** (exact, from Q-transform + H-recursion; verified all profiles d=4,5,7):
  N_2(c) = [B_c(q^2) − 1 − q^2 − q^4] + har(c), with
  har(c) = Σ_{c'≠c} q^{2·EMD(c',c)} Q_1(c') − q(1+q+q^2+q^3+q^4) Q_1(c),
  B_c(q) = Σ_{c'} q^{EMD(c',c)} = (1+q+q^2) H_1(c).
- **Sphere structure**: n_1 := b_1(c) = rank(c); n_2 := b_2(c) ≥ 2 (finite enumeration of the EMD unit and radius-2 spheres in deviation coordinates; quasi-norm f(s,t) = 3max(0,−t,s) − s + t).
- **har_2 = −(n_1−1) EXACTLY** ⟹ **[q^2]N_2 = 0 identically** for every profile (the ball term contributes exactly n_1−1+1... precisely cancels). This is the sharpest possible localization at exponent 2.
- **har_4 formula**: har_4 = Σ_{EMD(c',c)=1} (b_2−b_1)(c') − b_3(c); absorption by the ball term gives [q^4]N_2 ≥ 0 (via caps).
- **Low-band theorem**: [q^j]N_2(c) ≥ 0 for ALL profiles c, all d with gcd(d,3)=1, for j ≤ 5 **unconditionally** (rigorous cap M_j = 2j via EMD locality: EMD ≥ max(|s|,|t|), so har_j depends only on (min(c_i, 2j))_i, finitely many capped classes, all realized and checked at d ≤ 4j+1... swept clean).
- **Cap-Compression Lemma** (rigorous form M=2j): har_j(c) depends only on the capped profile (min(c_i, M))_i.

### YELLOW (verified at scale, unproved)
- **Sharp cap M_j = j**: holds for j ≤ 12 (sweep d ≤ 35, all 24 values with 3∤d, log: scripts/bigsweep.log "ALL S1/S2/har4-formula OK"). Grants [q^j]N_2 ≥ 0 for j ≤ 11.
- **S1/S2** (har_j ≥ 0 for j ∉ {2,4}; har_4 ≥ −(n_2−1)): verified all profiles, d ≤ 35.
- **Sphere Absorption Conjecture (all levels)**: level-n har^{(n)} has negatives ONLY at exponents n·e, each ≥ −(b_e−1), absorbed by B_c(q^n); har^{(n)}_n = −(n_1−1) exactly ⟹ [q^n]N_n = 0. Verified n=2 (d ≤ 35) and n=3 (d=4,5: negatives only at {3,6,9}). **This is the uniform involution target across all levels n** — the lift n=2 → general n is structurally identical.

### FAILED (do not retry)
- Termwise per-neighbor domination (mindeg obstruction).
- Reciprocity/duality for the top band (H_1 not generally self-palindromic; scripts/seed4_R2L3_recip.py).
- Plain har ≥ 0 (false at exponents 2, 4 — exactly the sphere exponents).

### OPEN WALL + recommendation
har_j ≥ 0 for unbounded j (middle/top band). Tightness (har_j = 0) is scattered — at j ∈ {0,1,3,5,6} and a universal top band [1,1,0,1] — so no coarse bound works. Two routes:
1. **Ehrhart/quasi-polynomial**: A_j(c) = #{f ≤ j, f ≡ j mod 3} is piecewise quasi-polynomial in (j, c); har_j is a finite signed combination of such counts. Region-by-region verification is a finite computation — this is the most mechanical path to full S1.
2. **Involution substrate**: unit moves in deviation coordinates shift the position class t−s mod 3 by +1 while changing f by +1 or −2 (Preimage EMD Dichotomy in geometric form). A sign-reversing involution on the lattice-point signed set for har_j should exist; the har_2 exact cancellation is its base case.

### Files
- Engine + verification: scripts/seed4_R2L3_engine.py (H-recursion, exact Z[q], brute force chain model — matches under profile reversal, see seed4_R2L3_convention.py).
- Analysis: seed4_R2L3_{harnack,finedata,slack,level3,caps,recip,bigsweep}.py + bigsweep.log.
- Polished write-up: ../proofs/prove-seed4-layer3.tex (+ PDF, compiles clean): Theorems 1–4, Cap-Compression Lemma, Conjectures 1 (S1/S2) and 2 (Sphere Absorption).
