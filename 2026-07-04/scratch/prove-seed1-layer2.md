# Seed 1, Layer 2, Round 2 — Prove Q_n = q^{n^2} for d=2

## Mission
Prove Q_{n,c}(q) = q^{n^2} for c in the C_3-orbit of (1,1,0) (d=2), and
Q_{n,c}(q) = q^{n(n+1)} for c in the C_3-orbit of (2,0,0). Extract WHY the
alternating signs from (zq;q)_inf collapse to a single monomial.

## Setup / Notation
r = 3, d = 2, ell = gcd(2,3) = 1, t = 3 + 2 = 5 (modulus 5 — the classical
Rogers–Ramanujan modulus!). Two C_3 orbits of profiles:
- orbit a: (1,1,0), (0,1,1), (1,0,1)
- orbit b: (2,0,0), (0,2,0), (0,0,2)

Write A(y) = F_{(1,1,0)}(y,q) and B(y) = F_{(2,0,0)}(y,q)
(F_c is invariant under cyclic rotation of c — the cylinder just rotates).

Q_{n,c} = (q;q)_n * [y^n]( (yq;q)_inf * F_c(y,q) ).

## Plan (derived by hand BEFORE computing; every step verified numerically below)

### Step 1: CW system for d=2
CW: F_c(y) = sum_{emptyset != J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}) / (1 - yq^{|J|}).

For c = (1,1,0): I_c = {1,2}.
- J={1}:   c(J) = (0,2,0)  [orbit b]
- J={2}:   c(J) = (1,0,1)  [orbit a]
- J={1,2}: c(J) = (0,1,1)  [orbit a]
So  A(y) = B(yq)/(1-yq) + A(yq)/(1-yq) - A(yq^2)/(1-yq^2).   (CW-a)

For c = (2,0,0): I_c = {1}.
- J={1}: c(J) = (1,1,0)  [orbit a]
So  B(y) = A(yq)/(1-yq).                                      (CW-b)

### Step 2: eliminate B
Substitute (CW-b) into (CW-a):
A(y) = A(yq^2)/((1-yq)(1-yq^2)) + A(yq)/(1-yq) - A(yq^2)/(1-yq^2)
     = A(yq)/(1-yq) + A(yq^2) * [1 - (1-yq)] / ((1-yq)(1-yq^2))
     = A(yq)/(1-yq) + yq * A(yq^2)/((1-yq)(1-yq^2)).
i.e.
(1-yq) A(y) = A(yq) + yq/(1-yq^2) * A(yq^2).                  (*)

### Step 3: the G-transform kills all denominators
Define G(y) = (yq;q)_inf * A(y). Substitute A(y) = G(y)/(yq;q)_inf into (*),
using (yq;q)_inf = (1-yq)(yq^2;q)_inf = (1-yq)(1-yq^2)(yq^3;q)_inf.
Multiply through by (yq;q)_inf:
(1-yq) G(y) = (1-yq) G(yq) + yq(1-yq) G(yq^2).
Divide by the unit (1-yq) of Z[[q]][[y]]:

    G(y) = G(yq) + yq G(yq^2).                                 (RR)

This is EXACTLY the Rogers–Ramanujan q-difference equation.

### Step 4: uniqueness and solution
Write G(y) = sum_n g_n(q) y^n. (RR) coefficient-wise:
g_n = q^n g_n + q^{2(n-1)+1} g_{n-1}  =>  (1-q^n) g_n = q^{2n-1} g_{n-1}.
1-q^n has constant term 1, hence is a unit of Z[[q]] — g_n is DETERMINED.
g_0 = G(0) = F_c(0,q) = 1 (empty CP). Induction, sum(2j-1) = n^2:
g_n = q^{n^2}/(q;q)_n.
Hence Q_{n,(1,1,0)} = (q;q)_n g_n = q^{n^2}.

### Step 5: orbit b
G_B(y) := (yq;q)_inf B(y) = (yq;q)_inf A(yq)/(1-yq) = (yq^2;q)_inf A(yq)
        = G_A(yq).
So [y^n] G_B = q^n * q^{n^2}/(q;q)_n = q^{n(n+1)}/(q;q)_n, and
Q_{n,(2,0,0)} = (q;q)_n * q^{n(n+1)}/(q;q)_n = q^{n(n+1)}.

### The mechanism (why alternating signs collapse) — GENERAL LEMMA
Define G_c(y) = (yq;q)_inf F_c(y,q) for ANY profile c. Then CW becomes

    G_c(y) = sum_{emptyset != J subseteq I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|})   (G-CW)

because (yq;q)_inf / ((1-yq^{|J|}) * (yq^{|J|+1};q)_inf) = (yq;q)_{|J|-1}.
The infinite alternating series (yq;q)_inf is absorbed: the transformed
system has FINITE polynomial coefficients (yq;q)_{|J|-1}. For d=2 the
|J|=2 term's sign -(1-yq) recombines with the |J|=1 terms to give the
manifestly positive RR form. This is the collapse.

## Computational verification plan
1. Brute-force enumerate CPs of all 6 profiles (d=2), total size <= W=25,
   build F_c(y,q) coefficients exactly for q-degree <= W. Cross-check CW.
2. Solve the CW system for all 6 profiles to n=10 at PREC = 900
   (rule: 6*10^2 + 200 = 800 <= 900).
3. Compute Q_n for both orbits, n = 0..10; check the monomials.
4. Verify (*), (RR), (G-CW) coefficients numerically.

(Results filled in below after running scripts.)

## Computational Evidence (script: scripts/seed1_R2L2_d2_verify.sage)

ALL CHECKS PASSED, first run. PREC = 900 (rule requires >= 6*10^2+200 = 800).

1. **CHECK 1**: brute-force enumeration of CPs (9296 partitions of size <= 25,
   all triples with cyclic interlacing) — F_c invariant under cyclic rotation
   for both orbits. Exact, no truncation issues (all CPs of size <= 25 counted).
2. **CHECK 2**: the CW-system solution (6x6 Gaussian elimination over Z[[q]]
   per level n) matches brute force for ALL 6 profiles, n <= 10, q-deg <= 25.
   This independently validates both my CW-index conventions (the c(J) rule
   with cyclic c_0 = c_k) and the enumeration.
3. **CHECK 3/3b**: Q_n - q^{n^2} == 0 (orbit a) and Q_n - q^{n(n+1)} == 0
   (orbit b) EXACTLY, mod q^899, for n = 0..10, all 6 profiles.
4. **CHECK 4**: equation (*) (1-yq)A(y) = A(yq) + yq/(1-yq^2) A(yq^2). PASSED.
5. **CHECK 5**: (CW-b) B(y) = A(yq)/(1-yq). PASSED.
6. **CHECK 6**: (RR) G(y) = G(yq) + yq G(yq^2). PASSED.
7. **CHECK 7**: G_B(y) = G_A(yq). PASSED.
8. **CHECK 8**: [y^n] G = q^{n^2}/(q;q)_n. PASSED.
9. **CHECK 9**: the general G-CW lemma for all 6 profiles. PASSED.

## Verify phase — hostile referee pass

Step-by-step audit of the proof:

- **CW system (Step 1).** GREEN. Corteel–Welsh 2019, Prop. in
  problem-description/conjecture.tex, valid for any composition. My c(J)
  computations for J = {1},{2},{1,2} on (1,1,0) and J = {1} on (2,0,0)
  double-checked by hand AND validated by CHECK 2 (the CW solution built from
  these very c(J) values reproduces the brute-force enumeration exactly).
  Cyclic invariance of F_c (used to identify orbit members): rotating the
  profile rotates the cylinder, a size- and max-preserving bijection; also
  verified exactly (CHECK 1). GREEN.
- **Formal setting.** F_c(y,q) = sum_n f_{c,n} y^n with f_{c,n} in Z[[q]]:
  for fixed max n and size w the number of CPs is finite (parts <= n forces
  length <= w), so each f_{c,n} is a well-defined power series. All
  manipulations are in the ring Z[[q]][[y]], where 1-yq, 1-yq^2, (yq;q)_inf
  are units (constant term 1). GREEN.
- **Elimination (Step 2).** Pure algebra in Z[[q]][[y]]; CHECK 4 confirms. GREEN.
- **G-transform (Step 3).** Uses (yq;q)_inf = (1-yq)(yq^2;q)_inf =
  (1-yq)(1-yq^2)(yq^3;q)_inf — definitional. Division by unit 1-yq. CHECK 6
  confirms. GREEN.
- **Uniqueness + solution (Step 4).** (1-q^n) has constant term 1, unit in
  Z[[q]]; recursion determines g_n uniquely from g_0 = 1; exponent sum
  1+3+...+(2n-1) = n^2. CHECK 8 confirms. GREEN.
- **Orbit b (Step 5).** One-line consequence of (CW-b); CHECKs 5,7 confirm. GREEN.
- **Boundary cases.** n=0: Q_0 = (q;q)_0 * [y^0]G = g_0 = 1 = q^0. ✓ both
  orbits. Empty CP handled: f_{c,0} = 1. ✓

No RED, no YELLOW. The proof is complete.

## Why the alternating signs collapse — the extracted mechanism

Three layers:

1. **(G-CW).** For ANY profile c (any r, d), setting G_c(y) = (yq;q)_inf F_c(y,q)
   turns the CW system into
       G_c(y) = sum_{∅≠J⊆I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|}).
   The INFINITE alternating product is absorbed into FINITE polynomial
   coefficients (yq;q)_{|J|-1}. Verified for all 6 profiles (CHECK 9); the
   one-line proof is (yq;q)_inf / ((1-yq^s)(yq^{s+1};q)_inf) = (yq;q)_{s-1}.
   This is where (zq;q)_inf "goes": it is the unique cofactor making the CW
   denominators disappear.
2. **Sign recombination (d=2 specific).** In the eliminated single equation,
   the |J|=2 term -(1-yq)G(yq^2)·(shift) combines with the |J|=1 terms so that
   the -1 part cancels against part of the |J|=1 contribution, leaving
   G(y) = G(yq) + yq·G(yq^2) — nonneg coefficients 1 and yq. Positivity of
   G (hence of Q_n = (q;q)_n g_n, given g_n = q^{n^2}/(q;q)_n) is then manifest
   by induction. For general d the analogous recombination is exactly what is
   NOT yet understood; the G-CW lemma is the right starting object.
3. **Single-monomial degeneration.** The recursion (1-q^n)g_n = q^{2n-1}g_{n-1}
   is FIRST-ORDER with monomial coefficient — so g_n is a monomial over (q;q)_n
   and Q_n is a single monomial. Cause: d=2 has only 2 orbits and orbit b
   eliminates in one step. For d>2 the system is genuinely higher-order, so
   Q_n is a real polynomial.

Known-result caveat: Q_n = q^{n^2} at t=5 is the Rogers–Ramanujan case;
Warnaar (2023) proved d=2 positivity via multisums, and the RR functional
equation is classical (MacMahon/Schur/Rogers). What is (modestly) new here is
the explicit statement and proof in the Q_{n,c} normalization, plus the
general G-CW lemma isolating where the alternating signs go.

## Write-up
Clean proof: ../proofs/prove-seed1-layer2.tex (compiled OK).
Note for other seeds on the G-CW lemma: ../notes/seed1-layer2-GCW-lemma.md.

## Handoff

### Status: GREEN
**PROVED** (complete, referee-checked, computationally verified n <= 10 at
PREC 900):
1. Q_{n,c}(q) = q^{n^2} for all c in the C_3-orbit of (1,1,0)  (d=2).
2. Q_{n,c}(q) = q^{n(n+1)} for all c in the C_3-orbit of (2,0,0)  (d=2).
3. **G-CW Lemma (general d, general r):** G_c(y) := (yq;q)_inf F_c(y,q)
   satisfies G_c(y) = sum_{∅≠J⊆I_c} (-1)^{|J|-1} (yq;q)_{|J|-1} G_{c(J)}(yq^{|J|}).
   Proof is one line from CW. Q_{n,c} = (q^ell;q^ell)_n [y^n] G_c.
   The whole conjecture is a positivity statement about this polynomial-
   coefficient q-difference system.

### Proof mechanism (for the general case)
d=2: G-CW system + elimination = Rogers–Ramanujan functional equation
G = G(yq) + yq G(yq^2); unique solution q^{n^2}/(q;q)_n. The alternating signs
collapse because (yq;q)_inf is exactly the cofactor turning CW denominators
1/(1-yq^{|J|}) into polynomials (yq;q)_{|J|-1}, and for d=2 the leftover signs
recombine into nonneg coefficients {1, yq}.

### Suggested next steps for Layer 3 / synthesis
- Use the G-CW lemma as the standard frame. For d=4,5 (Warnaar's proved
  cases) eliminate the orbit system at the G level and see what
  positive-coefficient q-difference system emerges; conjecture its general-d
  form. If the eliminated G-system always has nonneg polynomial coefficients
  after recombination, positivity follows by induction on n exactly as in d=2.
- The G-CW lemma should connect to Seed 6's Conjecture-2 frame:
  FERM = G_c is the same object; the G-CW system gives recurrences the
  fermionic multisum must satisfy.
- d=1 (orbits of (1,0,0)): same method should give Q_n = q^{n(n+?)}...
  (t=4, Euler case) — quick win if anyone wants it.
