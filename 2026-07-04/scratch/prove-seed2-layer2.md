# Prove Seed 2 Layer 2 — h_m >= 0 via structure (crystal/Ehrhart mission)

Seed 2, Layer 2, Round 2. Mission: prove h_m = (q^ell;q^ell)_m * g_m >= 0 (the core bottleneck).

## Setup / immediate observation

From the GREEN results in synthesis-layer1.md:
- Adjugate Monomial Theorem (Seed 4, PROVED): adj(I - A(x))[c,c'] = x^{EMD(c,c')},
  det(I - A(x)) = -(x^3 - 1).
- Hence (bounded CW recursion, level m): (1 - q^{3m}) F_{c,m} = sum_{c'} q^{m*EMD(c,c')} F_{c',m-1}.
- P_m(c) := (q^ell;q^ell)_m F_{c,m} is manifestly positive (GREEN, EMD path formula).

Definition: g_m = F_{c,m} - F_{c,m-1}, h_m = (q^ell;q^ell)_m g_m.

### Derivation (case ell = 3, i.e. 3|d)

(q^3;q^3)_m = (q^3;q^3)_{m-1}(1-q^{3m}). Multiply the level-m recursion by (q^3;q^3)_{m-1}:

  P_m(c) = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c').        (*)

Then h_m = P_m(c) - (1-q^{3m}) P_{m-1}(c). Since EMD(c,c) = 0, the c'=c term of (*) contributes
P_{m-1}(c), and

  h_m(c) = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c).

Both terms manifestly >= 0 given P_{m-1} >= 0, which itself follows by induction from (*)
(P_0 = 1). **This proves h_m >= 0 for 3|d completely** (modulo numerical re-verification of (*)).

### Derivation (case ell = 1, gcd(d,3)=1) — the conjecture's case

P_m = (q;q)_m F_{c,m}; now (1-q^{3m}) = (1-q^m)(1+q^m+q^{2m}), so

  (1+q^m+q^{2m}) P_m(c) = sum_{c'} q^{m*EMD(c,c')} P_{m-1}(c'),     (**)
  (1+q^m+q^{2m}) h_m(c) = sum_{c' != c} q^{m*EMD(c,c')} P_{m-1}(c') + q^{3m} P_{m-1}(c).  (***)

(Consistent with Seed 8's observation that h_m*(1+q^m+q^{2m})/(q;q)_{m-1} >= 0.)
So the whole problem is: divide the manifestly positive RHS of (***) by (1+q^m+q^{2m})
and keep positivity.

### The Orbit Lemma idea

Let sigma = cyclic rotation of profiles. F is sigma-invariant (rotating the cylinder), so
P_{m-1}(sigma c') = P_{m-1}(c'). For d not divisible by 3, sigma acts freely: profiles fall into
orbits {c', sc', s2c'} of size 3, all with the same P. Group the RHS of (***) by orbits:

  RHS = sum_{orbits O} T_O(q^m) * P_{m-1}(O)

where T_O(x) = sum_{c' in O} x^{EMD(c,c')}.

**ORBIT LEMMA (to test):** for every c and every orbit O, the three values
{EMD(c,c'), EMD(c,sc'), EMD(c,s2c')} are CONSECUTIVE integers {e, e+1, e+2}.

If true: T_O(x) = x^e (1+x+x^2), so h_m(c) = sum_O q^{m e_O} P_{m-1}(O) with the orbit of c
contributing q^m P_{m-1}(c) (since EMD(c,c)=0 forces e_{O_c}=0 and the -(1-q^m)P_{m-1} correction
leaves exactly q^m P_{m-1}(c)). Manifest positivity of h_m AND of P_m simultaneously, by induction.

EMD formula (Seeds 4/7): EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1).

## Computational Evidence

(to be filled)

### Orbit Lemma test: FAILS in strict form (script seed2_R2L2_orbit_lemma.py)

For d=1 the three EMD values over an orbit ARE consecutive; for d >= 2 they are not.
BUT: sorted gap patterns are always ≡ (1,1) or (2,2) mod 3 for gcd(d,3)=1
(and ≡ (0,0) mod 3 for 3|d). I.e. **the three values are always DISTINCT mod 3**
(this is the pointwise, orbit-level form of Seed 7's equidistribution — stronger,
since it holds orbit by orbit, not just rank-class by rank-class).

### Relation to Seed 3's factorization

Seed 3 already had tilde_h_m = P_m - (1-q^{3m})P_{m-1} >= 0 manifestly (P = (q^3;q^3) normalization),
and h_m = tilde_h_m / prod_{j=1}^m (1+q^j+q^{2j}). So my (***) is the one-level version. The
content is: WHY does dividing by prod (1+q^j+q^{2j}) preserve positivity?

## NEW STRUCTURE: the (C_3)^m suffix-rotation action factorizes tilde_h_m

tilde_h_m(c) = sum over paths (c_m=c, c_{m-1}, ..., c_0) of q^{sum_j j*E_j},
E_j = EMD(c_j, c_{j-1}) (with the level-m diagonal modification 0 -> 3 when c_{m-1}=c).

Act on path space by rotating suffixes: for each j <= m-1, replace (c_j,...,c_0) by
(sigma c_j, ..., sigma c_0). Since EMD(sigma a, sigma b) = EMD(a,b) (to verify numerically),
the group (Z/3)^m acts and the relative rotations r_j at each level become independent.
Orbit sum = prod_{j=1}^m T^{(j)}(q^j) where T^{(j)}(x) = sum_{r in Z/3} x^{EMD(c_j, sigma^r c_{j-1})}.
By the mod-3 distinctness, each T^{(j)}(x) is divisible by 1+x+x^2 in Z[x]:
U^{(j)} := T^{(j)}/(1+x+x^2) in Z[x]. Hence

  h_m(c) = sum_{orbit sequences ([c_{m-1}],...,[c_0])} prod_{j=1}^m U^{(j)}(q^j).   (ORBIT-PRODUCT FORMULA)

This is an EXACT formula for h_m with no denominators. Positivity would follow if each orbit
product prod_j U^{(j)}(q^j) >= 0 — to test. U's can individually have negative coefficients
(e.g. (1+x^2+x^4)/(1+x+x^2) = 1-x+x^2), so this is not automatic.

---

## Verification Results (COMPUTE phase, all exact arithmetic)

### Orbit-product formula: VERIFIED
Script: scripts/seed2_R2L2_orbit_product.py (Fraction-exact power series, adjugate inversion for F).
- d=1,2,4: all profiles, m=1,2,3 — orbit formula == transfer-matrix h_m. MATCH.
- d=5: all profiles, m=1,2 (script seed2_R2L2_verify_d5.py) — MATCH, both h_m and P_m versions.
- Cross-check vs Seed 8's independent tables: d=4, c=(2,1,1): h_1=[0,3,1,1], h_2=[0,0,3,4,5,3,3,2,2,1,1,0,1]. MATCH.

### Corollary (NEW, proved): P_m := (q;q)_m F_{c,m} is a POLYNOMIAL in Z[q] with P_m(1) = K^m
where K = (d+1)(d+2)/6 = number of C_3-orbits of profiles (gcd(d,3)=1). Follows from the
orbit-product formula since each U(1) = T(1)/3 = 1. Analogously h_m(1) = K^m - K^{m-1} ... no:
h_m(1) counts orbit sequences with the top-diagonal modification; direct check: h_m(1) = K^{m-1}(K-1)+K^{m-1} adjustments — see .tex for the precise statement (h_m(1)=K^m with U^top(1)=1 as well since the 0->3 change preserves T(1)=3).
- Numerically confirmed: P_m nonneg with P_m(1)=K^m for d=2,4,5,7, m<=3 (seed2_R2L2_inspect_P.py).
- Degrees observed: deg P_m = 3m(m+1) for c=(0,0,4); 3m^2 for c=(1,1,2)-type balanced.

### U-polynomial structure (YELLOW, verified d<=14 exhaustively)
Every U = T/(1+x+x^2) has coefficients in {0,+1,-1}, with signs ALTERNATING among nonzero
coefficients, and first/last nonzero coefficient = +1. (seed2_R2L2_U_shapes.py: 12/20/46
distinct shapes for d=4/5/7.) This means each U(q^j) is a "fewnomial with alternating signs" —
the positivity of the total signed sum is the isolated remaining question.

### Theorem 1 (NEW GREEN): h_m >= 0 for 3|d — COMPLETE PROOF
h_m(c) = sum_{c' != c} q^{m*EMD(c,c')} Ptilde_{m-1}(c') + q^{3m} Ptilde_{m-1}(c),
where Ptilde_m = (q^3;q^3)_m F_{c,m} is manifestly nonneg by the adjugate recursion.
One line from the Adjugate Monomial Theorem. This settles HALF of the core bottleneck.

## Failed approaches (recorded so Layer 3 doesn't retry)
1. **Per-orbit positivity**: prod_j U^{(j)}(q^j) can have negative coefficients for individual
   orbit sequences (d=4 counterexamples at m=2). Only the TOTAL sum is nonneg.
2. **Abel summation / domination chains**: genuine failures at d=7, m=2 (partial sums of
   orbit-ordered P's are not monotone under any natural EMD-compatible order).
3. **Shifted domination** q^delta P(O) <= P(O'): no valid shift exists (P_m's have comparable
   degree and interlacing supports; seed2_R2L2_shift_dom.py all None).
4. **Strict Orbit Lemma** ({e,e+1,e+2} consecutive over orbits): FALSE for d>=2. The correct
   statement is distinctness mod 3, which suffices for exact divisibility by 1+x+x^2.

## Note on B^{d,1} column crystals (mission item, set aside deliberately)
For A_2^(1), B^{r,s} requires r in {1,2}; "B^{d,1}" does not exist for d>2. B^{2,s} is the
contragredient dual of B^{1,s} and gives the same profile structure. The EMD is now EXPLAINED
without crystals: it is the min-cost clockwise-flow transport distance on Z/3 arising directly
from the adjugate of I - A(x). The crystal route (Layer 1) is superseded by the flow/orbit model.

## Proof document
2026-07-04/proofs/prove-seed2-layer2.tex — compiled to prove-seed2-layer2.pdf (6 pages).
Contains: Lemma 1 (rotation invariance of F, relabeling bijection), Lemma 2 (EMD(sigma c, sigma c')
= EMD(c,c'), algebraic), Lemma 3 (EMD(c, sigma c') == EMD(c,c') + d mod 3), Lemma 4 (T divisible
by 1+x+x^2), Theorem 1 (3|d positivity, complete), Theorem 2 (orbit-product formula, proved by
one-level cancellation + induction in Z[[q]]), Corollary (polynomiality, K^m evaluations).

## Handoff

### State
Two GREEN results, one isolated open obstacle.

### Best results
1. **GREEN — Theorem 1: h_m >= 0 for all m when 3|d.** Complete one-line proof from the
   Adjugate Monomial Theorem. Half of the synthesis §6 core bottleneck is now PROVED.
2. **GREEN — Orbit-product formula (gcd(d,3)=1):**
   h_m(c) = sum over orbit sequences (O_{m-1},...,O_0) of U^top_{c,O_{m-1}}(q^m) *
   prod_{j=1}^{m-1} U_{O_j,O_{j-1}}(q^j), where U = T/(1+x+x^2), T_{c,O}(x) = sum_r x^{EMD(c,sigma^r c')}.
   Exact, denominator-free, proved (Theorem 2 in the .tex) and verified d=1,2,4,5.
   Corollary: (q;q)_m F_{c,m} is a polynomial with value K^m at q=1.
3. **YELLOW — U structure:** all U's have {0,±1} alternating coefficients, ends +1 (d<=14).

### The isolated obstacle
Positivity of the signed sum sum_{orbit seqs} prod_j U^{(j)}(q^j) for gcd(d,3)=1.
Since each U(1)=1, the sum has exactly K^m "surviving" monomials at q=1 — one per orbit
sequence. RECOMMENDED ATTACK: a sign-reversing involution on the monomial expansion whose
fixed points are one positive monomial per orbit sequence. The alternating {0,±1} structure
of each U is exactly the shape produced by inclusion-exclusion over an interval order —
look for a lattice-path / cycle-lemma interpretation of U's exponent set
{EMD(c,sigma^r c') mod grouping} / (1+x+x^2) division.

### What NOT to retry
Per-orbit positivity, Abel/domination chains, shifted domination, strict consecutive-orbit
lemma, KR row-crystal energy matching (BA19), Kyoto path truncation (BA18), B^{d,1} for d>2.

### Scripts (all exact arithmetic, reusable)
scripts/seed2_R2L2_{orbit_lemma,orbit_product,abel,shift_dom,inspect_P,U_shapes,verify_d5}.py
