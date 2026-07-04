# Seed 6, Layer 3, Round 2 — Finish d=4 (modulus 7) completely

**Agent**: Seed 6 (Corteel-Welsh systems, R-relations, positivity propagation)
**Date**: 2026-07-04
**Mission**: (a) prove fermionic forms for 3 good d=4 orbits; (b) walls (0,2,2),(0,3,1)
via bounded R-relations; (c) assemble complete proof of Q_n >= 0 for d=4.

Predecessor launch died before writing anything. This is the survival log — writing
findings BEFORE verification scripts, since everything below was derived by hand and
would be lost otherwise.

---

## 1. KEYSTONE DISCOVERY (literature): the Corteel-Welsh note proves the bounded d=4 forms

File: `/Users/robin/git/experiments/waarnar/literature/tex/corteel_welsh_A2_RR/source.tex`

This short CW note (companion to CW19) is FULLY PROVED and gives manifestly positive
**bounded** fermionic forms for ALL FIVE d=4 profiles (their labels, level 4 = c0+c1+c2=4,
modulus 7). Warnaar's A2 Andrews-Gordon paper (line ~3106) calls the bounded analogue of
Con_cylindric-b for k=2 an **open problem** — but this note IS that solution (Warnaar cites
CW19 Thm 3.2 for the unbounded double sums; the note has the bounded versions).

**Theorem \ref{new}** (their line 193), bounded F_{c,n}(q) [their n = our m = max-part bound]:

Let S(n1,n2) = q^(n1^2+n2^2-n1*n2). Then

- F_{(4,0,0),n} = Sum_{n1=0}^n Sum_{n2=0}^{2n1} S*q^(n1+n2) / ((q)_{n-n1}(q)_{n1}) * [2n1, n2]
- F_{(3,1,0),n} = Sum S*q^(n2) / ((q)_{n-n1}(q)_{n1}) * [2n1, n2]
- F_{(2,1,1),n} = Sum S / ((q)_{n-n1}(q)_{n1}) * [2n1, n2]
- F_{(3,0,1),n} = Sum S*q^(n1)/((q)_{n-n1}(q)_{n1})*[2n1,n2]
               + Sum_{n1>=1} S*q^(2n2)/((q)_{n-n1}(q)_{n1-1})*[2n1-2, n2]
- F_{(2,2,0),n} = Sum S*q^(n1)/((q)_{n-n1}(q)_{n1})*[2n1,n2]
               + Sum_{n1>=1} S*q^(n2)*(1+q^(n1+n2))/((q)_{n-n1}(q)_{n1-1})*[2n1-2, n2]

**Theorem \ref{Thm:G}** (their line 430): the y-refined versions G_c(y,q) := (yq)_inf F_c(y,q)
have the SAME summands with y^(n1) replacing 1/(q)_{n-n1}. I.e. exactly our
A(z) = (zq)_inf F_c(z,q) = Sum_n A_n z^n with A_n the inner sum over n2. Proof method:
uniqueness induction on y-exponents via the manifestly positive functional system Eq:Fun:

- G_{(4,0,0)}(y) = G_{(3,1,0)}(yq)
- G_{(3,1,0)}(y) = G_{(2,2,0)}(yq) + yq^2 G_{(3,1,0)}(yq^3) + yq G_{(2,1,1)}(yq^2)
- G_{(3,0,1)}(y) = G_{(2,1,1)}(yq) + yq G_{(3,1,0)}(yq^2)
- G_{(2,2,0)}(y) = G_{(2,1,1)}(yq) + yq G_{(2,1,1)}(yq^2) + yq^2 G_{(3,1,0)}(yq^3)
- G_{(2,1,1)}(y) = G_{(2,1,1)}(yq) + yq G_{(2,2,0)}(yq) + yq G_{(2,2,0)}(yq^2)
                 + yq^3 G_{(3,1,0)}(yq^4) + yq^2 G_{(2,1,1)}(yq^3)

Note the last relation: a POSITIVE relation for the core profile (2,1,1) — beyond what my
Layer-2 R-relation families produced. Key coefficient identity used in their proof:
(1-q^n) g_{(2,1,1)}(n) = (q^n + q^(2n-1)) g_{(2,2,0)}(n-1) + q^(4n-1) g_{(3,1,0)}(n-1)
+ q^(3n-1) g_{(2,1,1)}(n-1), where g_c(n) = [y^n] G_c(y,q).

**Orbit-labeling hazard**: CW's profile labels differ from ours by reversal/rotation
(Conflict C2 history). Verifier says: our orbits with plain ASW fits are (0,0,4) [a=1,b=1],
(0,1,3) [a=0,b=1], (1,1,2) [a=0,b=0]; walls (0,2,2), (0,3,1). CW's (3,1,0) has the
a=0,b=1-type exponent (+n2), so CW(3,1,0) <-> ours (0,1,3)-orbit. CW(4,0,0) <-> ours
(0,0,4)-orbit, CW(2,1,1) <-> ours (1,1,2)-orbit, CW(3,0,1) <-> one wall orbit,
CW(2,2,0) <-> the other. MUST pin this mapping computationally (script below).

---

## 2. Inversion Lemma: H_{c,m} = Sum_{n<=m} [m,n]_q Q_{n,c}

The verified Q-transform (verify-layer2-disputes.md, d=2,4,5, all profiles) is

  Q_n = Sum_{m=0}^n (-1)^(n-m) q^binom(n-m,2) [n,m]_q H_{c,m}.

Gauss q-binomial inversion (standard; Andrews, "The Theory of Partitions", Ch. 3):
  b_n = Sum_m (-1)^(n-m) q^binom(n-m,2) [n,m] a_m  <=>  a_m = Sum_n [m,n] b_n.
Hence **H_{c,m} = Sum_{n=0}^m [m,n]_q Q_{n,c}**.

Cleaner still, a direct proof from definitions (no inversion needed):
If F_{c,m} = Sum_{n1<=m} A_{n1}/(q;q)_{m-n1} (Euler-type expansion, which the CW bounded
theorem exhibits explicitly for all 5 profiles), then letting m->inf coefficientwise,
(zq;q)_inf F_c(z,q) = Sum_n A_n z^n by the q-binomial theorem, so Q_n = (q;q)_n A_n. And

  H_{c,m} = (q;q)_m F_{c,m} = Sum_{n<=m} (q;q)_m/(q;q)_{m-n} * A_n
          = Sum_{n<=m} [m,n]_q (q;q)_n A_n = Sum_{n<=m} [m,n]_q Q_n.   QED

**Consequences** (settle the Layer-2 YELLOW items at d=4 given Q_n >= 0):
1. **BFF <=> Q-positivity**: the bounded fermionic-form coefficients are a_n = Q_n exactly.
2. **Monotonicity**: q-Pascal [m,n] - [m-1,n] = q^(m-n)[m-1,n-1] gives
   H_m - H_{m-1} = Sum_n q^(m-n) [m-1,n-1]_q Q_n >= 0 coefficientwise.
3. h_m = (H_m - H_{m-1}) + q^m H_{m-1} >= 0 immediately.
4. "Walls lack fermionic forms" just means Q_n^wall isn't a SINGLE plain ASW double sum —
   it's a positive combination of two (see section 3).

---

## 3. Q_n formulas for all five d=4 orbits (derived from CW Theorem Thm:G)

Q_n = (q;q)_n A_n where A_n = [y^n] G_c(y,q). From the CW forms (their labels):

**Good orbits** (manifestly positive single sums):
- CW(2,1,1):  Q_n = Sum_{n2=0}^{2n} q^(n^2 + n2^2 - n*n2) [2n, n2]_q
- CW(4,0,0):  Q_n = Sum_{n2} q^(n^2 + n2^2 - n*n2 + n + n2) [2n, n2]_q
- CW(3,1,0):  Q_n = Sum_{n2} q^(n^2 + n2^2 - n*n2 + n2) [2n, n2]_q
Sanity: Q_n(1) = Sum_{n2=0}^{2n} C(2n,n2) = 4^n. OK (matches Q_n(1)=4^n at d=4).

**Wall orbits** (two-term; note 1/(q)_{n1-1} = (1-q^(n1))/(q)_{n1}, so the second family
contributes a factor (1-q^n) at the Q-level):

- CW(3,0,1):  Q_n = X_n + (1-q^n) Xp_n, where
    X_n  = Sum_{n2} q^(n^2+n2^2-n*n2+n) [2n, n2]
    Xp_n = Sum_{n2} q^(n^2+n2^2-n*n2+2*n2) [2n-2, n2]     (Xp_0 := 0)
- CW(2,2,0):  Q_n = X_n + (1-q^n) Yp_n, where
    Yp_n = Sum_{n2} q^(n^2+n2^2-n*n2+n2) (1+q^(n+n2)) [2n-2, n2]  (Yp_0 := 0)

These have a -q^n*(sum) term, so positivity needs an **absorption lemma**: X_n >= q^n Xp_n
(resp. >= q^n Yp_n) coefficientwise.

---

## 4. Absorption Lemma A (wall CW(3,0,1)) — PROVED

**Claim**: X_n - q^n Xp_n >= 0 coefficientwise, hence
Q_n^{(3,0,1)} = (X_n - q^n Xp_n) + Xp_n >= 0.

**Proof**: Apply Pascal-1 ([N,j] = [N-1,j-1] + q^j [N-1,j]) twice to [2n,n2]:
  [2n, n2] = q^(2n2)[2n-2, n2] + (q^(n2-1) + q^(n2))[2n-2, n2-1] + [2n-2, n2-2].
Termwise in the n2-sum defining X_n, the first piece gives exactly
  q^(n^2+n2^2-n*n2+n) * q^(2n2) [2n-2,n2] = q^n * (Xp_n summand at n2).
The other two pieces are manifestly positive. So X_n - q^n Xp_n =
  Sum_{n2} q^(n^2+n2^2-n*n2+n) ( (q^(n2-1)+q^(n2))[2n-2,n2-1] + [2n-2,n2-2] ) >= 0. QED

## 5. Absorption Lemma B (wall CW(2,2,0)) — remaining gap at time of this entry

Need: X_n >= q^n Yp_n, i.e.
  Sum_{n2} q^(n2^2-n*n2) ( [2n,n2] - q^(n2)[2n-2,n2] - q^(n+2n2)[2n-2,n2] ) >= 0.

Partial progress: Pascal-1 then Pascal-2 gives
  [2n,n2] - q^(n2)[2n-2,n2] = [2n-1,n2-1] + q^(2n-1)[2n-2,n2-1]   (*)
[check: [2n,n2]=[2n-1,n2-1]+q^(n2)[2n-1,n2]; [2n-1,n2]=[2n-2,n2]+q^(2n-1-n2)[2n-2,n2-1].]
Remaining: absorb -q^(n+2n2)[2n-2,n2] into
Sum q^(n2^2-n*n2)([2n-1,n2-1]+q^(2n-1)[2n-2,n2-1]) — needs cross-n2 regrouping (shift
n2->n2+1 aligns exponents up to a factor). CW's own end-of-paper reduction ("left to the
reader") is essentially this identity; their (3,0,1) reduction used Pascal-2 with shift
(n1,n2)->(n1+1,n2-1) — that's the template. TO FINISH.

**Fallback if hand proof stalls**: verify numerically to large n and mark this one lemma
YELLOW; everything else GREEN.

---

## 6. Verification plan (script: scripts/seed6_R2L3_verify.sage)

1. Compute exact H_{c,m} (Z[q]) for all 15 d=4 profiles via H-recursion
   (1+q^m+q^(2m)) H_{c,m} = Sum_{c'} q^(m*EMD(c',c)) H_{c',m-1}, EMD verifier convention:
   emd(c,c') = 3*max(0,a,b)-a-b, a = c'[1]-c[1], b = c[0]-c'[0].
2. Q_n via Q-transform; check Q_n(1)=4^n.
3. Pin the CW<->ours label mapping: compare derived Q_n formulas (sec. 3) against computed
   Q_n for each of the 15 profiles.
4. Verify Inversion Lemma H_m = Sum [m,n] Q_n for all profiles, m<=8.
5. Verify Absorption A and B numerically (n<=10).
6. Spot-check H_m vs brute-force cylindric partition enumeration m<=3.

---

## 5'. Absorption Lemma B — PROVED (shift-cancellation; supersedes gap in §5)

**Claim (exact identity, stronger than the inequality)**:
  X_n - q^n Yp_n = Sum_{j=0}^{2n-1} q^(n^2 + j^2 - n*j + 2j + 1) [2n-1, j]_q.
Manifestly nonnegative, hence Q_n^{CW(2,2,0)} = (X_n - q^n Yp_n) + Yp_n >= 0.

**Proof.** Drop the global factor q^(n^2+n); set D_n := q^(-n^2-n)(X_n - q^n Yp_n)
 = Sum_{n2=0}^{2n} q^(n2^2-n*n2) [2n,n2]
 - Sum_{n2=0}^{2n-2} q^(n2^2-n*n2) (q^(n2) + q^(n+2*n2)) [2n-2,n2].

Step 1 (identity (*), two Pascals): [2n,n2] = [2n-1,n2-1] + q^(n2)[2n-1,n2] and
[2n-1,n2] = [2n-2,n2] + q^(2n-1-n2)[2n-2,n2-1] give
  [2n,n2] - q^(n2)[2n-2,n2] = [2n-1,n2-1] + q^(2n-1)[2n-2,n2-1].
(Valid for all 0 <= n2 <= 2n with the convention [N,k]=0 for k<0 or k>N; checked at the
boundary n2 = 2n-1, 2n where the q^(n2)[2n-2,n2] term vanishes.)

So D_n = Sum_{n2} q^(n2^2-n*n2) ( [2n-1,n2-1] + q^(2n-1)[2n-2,n2-1] )
       - Sum_{n2=0}^{2n-2} q^(n2^2-n*n2+n+2*n2) [2n-2,n2].

Step 2 (shift): substitute n2 = j-1 in the negative sum. Exponent:
  (j-1)^2 - n(j-1) + n + 2(j-1) = j^2 - n*j + 2n - 1.
So the negative sum = Sum_{j=1}^{2n-1} q^(j^2-n*j+2n-1) [2n-2,j-1]
— EXACTLY the second (q^(2n-1)) sum from Step 1. They cancel completely:

  D_n = Sum_{n2=1}^{2n} q^(n2^2-n*n2) [2n-1,n2-1].

Re-index n2 = j+1 and restore the global factor: exponent n^2 + (j+1)^2 - n(j+1) + n
= n^2 + j^2 - n*j + 2j + 1, giving the claimed identity.  QED

(Verified exactly in Z[q] for n <= 13, script V7b.)

---

## 7. Verification results (scripts/seed6_R2L3_verify.py — pure-python exact Z[q])

All PASS:
- (V0) H-recursion exact division, d=4, all 15 profiles, m<=8.
- (V1) Brute-force chain model matches, with the finding that the chain model's profile
  convention is the REVERSAL of the H-recursion convention: brute_F(c) = F_{rev(c)},
  rev(c0,c1,c2)=(c2,c1,c0). F is constant on C3-orbits, so reversal-symmetric orbits
  masked this in seed4-L3's sampled check. NOT a bug in either tower; flag for synthesis:
  any statement mixing the chain model and the EMD recursion must reverse the profile.
- (V2) Q_n >= 0 and Q_n(1) = 4^n, all 15 profiles, n<=8.
- (V3) **Orbit dictionary pinned** (Q_n equal exactly, n<=7):
    CW(2,1,1) = orbit {(1,1,2),(1,2,1),(2,1,1)}      [good]
    CW(4,0,0) = orbit {(0,0,4),(0,4,0),(4,0,0)}      [good]
    CW(3,1,0) = orbit {(0,1,3),(1,3,0),(3,0,1)}      [good]
    CW(3,0,1) = orbit {(0,3,1),(1,0,3),(3,1,0)}      [WALL]
    CW(2,2,0) = orbit {(0,2,2),(2,0,2),(2,2,0)}      [WALL]
  Consistent with the verifier's adjudication (walls = (0,2,2),(0,3,1) orbits).
- (V4) Inversion Lemma H_m = Sum [m,n] Q_n exact, all profiles, m<=8.
- (V5) Monotonicity identity H_m - H_{m-1} = Sum_n q^(m-n)[m-1,n-1] Q_n exact.
- (V6) Absorption A holds and its Pascal decomposition is exact, n<=12.
- (V7/V7b) Absorption B holds; the EXACT identity of §5' verified, n<=13.

---

## 8. MAIN THEOREM (d=4 complete)

**Theorem.** For d=4 (modulus 7, ell=1) and every profile c with c0+c1+c2=4:
 (i)  Q_{n,c}(q) has nonnegative coefficients for all n  [Warnaar's Conjecture 2.7 at d=4];
 (ii) explicitly, with T(n,j) := q^(n^2+j^2-n*j),
      orbit (1,1,2):  Q_n = Sum_j T(n,j) [2n,j]
      orbit (0,0,4):  Q_n = Sum_j T(n,j) q^(n+j) [2n,j]
      orbit (0,1,3):  Q_n = Sum_j T(n,j) q^(j) [2n,j]
      orbit (0,3,1):  Q_n = Sum_j T(n,j) q^n ((q^(j-1)+q^j)[2n-2,j-1] + [2n-2,j-2])
                          + Sum_j T(n,j) q^(2j) [2n-2,j]
      orbit (0,2,2):  Q_n = Sum_{j=0}^{2n-1} q^(n^2+j^2-n*j+2j+1) [2n-1,j]
                          + Sum_j T(n,j) q^j (1+q^(n+j)) [2n-2,j]
      — all manifestly nonnegative;
 (iii) H_{c,m} = Sum_{n<=m} [m,n]_q Q_{n,c} (BFF holds at d=4 with a_n = Q_n, ALL orbits,
      including the walls);
 (iv) H_{c,m} >= H_{c,m-1} coefficientwise (Monotonicity), hence h_m >= 0.

**Proof chain** (every link proved):
 1. CW note (fully proved, uniqueness induction on the positive system Eq:Fun) gives
    G_c(y,q) = (yq)_inf F_c(y,q) as explicit double sums for all five orbits.  [literature]
 2. Q_n = (q)_n [y^n] G_c  (definition) => the five Q_n expressions of §3.  [trivial]
 3. Walls: Absorption Lemmas A (§4) and B (§5') absorb the -q^n terms => (ii).  [proved]
 4. Euler expansion F_{c,m} = Sum_n A_n/(q)_{m-n} (CW bounded Thm \ref{new}) =>
    Inversion Lemma (§2) => (iii).  [proved]
 5. q-Pascal + (iii) => (iv).  [proved, §2 consequence 2]

Status: **GREEN** modulo one literature citation (the CW note's Theorem Thm:G, which is
proved in the source we hold). Everything else is self-contained q-Pascal manipulation.

---

## Handoff

**DONE — d=4 is finished.** Complete proof chain for Q_n >= 0, BFF (a_n = Q_n), and
Monotonicity at d=4, all 15 profiles. Key artifacts:
- This file: §§1–8 (Inversion Lemma, five Q_n formulas, Absorption Lemmas A and B with
  full q-Pascal proofs, orbit dictionary, main theorem).
- scripts/seed6_R2L3_verify.py: all checks V0–V7b PASS (exact Z[q]).
- proofs/prove-seed6-layer3.tex: polished write-up.

**Exportable beyond d=4**:
1. The Inversion Lemma H_m = Sum [m,n] Q_n is generic (any d with the verified
   Q-transform): it reduces Monotonicity AND BFF to Q-positivity, collapsing three
   YELLOW items into one. Monotonicity is NOT the bottleneck; Q-positivity is.
2. The wall phenomenon is now understood: walls have Q_n = (positive sum) + (1-q^n)(positive
   sum); positivity via absorption lemmas (double-Pascal, or shift-cancellation as in §5').
   Predict the same structure at d=7 walls, with 3-fold sums.
3. Chain-model vs EMD-recursion conventions differ by profile REVERSAL (V1 finding) —
   synthesis should propagate this warning.
4. Route to d=8/Seed 2: Uncu's S_11 + a CW-style positive y-system + absorption lemmas
   is plausibly the same template.

**Open**: nothing at d=4. Next targets: d=7 (mod 10) via the same CW-system template;
proving the Q-transform for general d (currently verified d=2,4,5 only — but note the
Inversion Lemma's direct Euler-expansion proof bypasses it whenever a CW-type bounded
form exists).
