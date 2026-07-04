# Prove Seed 4 Layer 2 — Signed Involution on Extended Path Space

Seed 4, Round 2, Layer 2. Mission: find the signed involution proving h_m >= 0
(or Q_n >= 0 directly), via (a) level-by-level D_k^m tower cancellation,
(b) tropical structure, (c) Garsia-Milne.

## Opening reframing (before any computation)

h_m = (q;q)_m * g_m with g_m = P_m/(q^3;q^3)_m. Since
(1-q^{3k}) = (1-q^k)(1+q^k+q^{2k}), we get the clean form

    h_m(c) = P_m(c) / prod_{k=1}^m (1 + q^k + q^{2k}).

So h_m >= 0 says: the EMD path polynomial P_m factors positively through a
tower of factors (1+q^k+q^{2k}), one per level k. This SCREAMS a free
Z/3-action per level (cyclic-sieving flavor).

### The rotation action

Let rho be the cyclic rotation of profiles: rho(c)_i = c_{i-1 mod 3}
(mass moves one step clockwise). Facts (to verify):
- EMD(rho a, rho b) = EMD(a, b) (rotation invariance of the clockwise cost).
- rho is FREE on profiles iff 3 does not divide d (fixed point needs c_0=c_1=c_2).
- EMD(a, rho b) == EMD(a, b) + d (mod 3). So for gcd(d,3)=1 the orbit
  {b, rho b, rho^2 b} hits all three residues of EMD(a, -) mod 3.
  (This is the mechanism behind Seed 7's EMD Equidistribution.)

### The level-by-level (Z/3)^m action on paths

Path space: (c^0, ..., c^m = c), weight sum_k k*EMD(c^k, c^{k-1}).
Group (Z/3)^m acts: generator T_k rotates the prefix c^0..c^{k-1} by rho.
- T_k changes ONLY the step-k weight: k*EMD(c^k, rho c^{k-1}) vs k*EMD(c^k, c^{k-1})
  (steps < k are rotation-invariant, steps > k untouched).
- Action is free (no profile is rho-fixed when 3 does not divide d).
- Reparametrizing by u_k = relative twist at step k, the orbit weight GF factors:
  orbit GF = prod_k (x_k^{E_0(k)} + x_k^{E_1(k)} + x_k^{E_2(k)}), x_k = q^k,
  where {E_j(k)} = {EMD(c^k, rho^j c^{k-1})}, distinct mod 3.

**IF the rotation triple {EMD(a,b), EMD(a,rho b), EMD(a,rho^2 b)} were always
consecutive {e,e+1,e+2}, then every orbit GF = q^{w_0} prod_k (1+q^k+q^{2k}) and
h_m = sum over orbit representatives q^{min weight} — manifestly nonneg. DONE.**

Hand check d=2, a=b=(2,0,0): triples EMD = {0, 2, 4}. NOT consecutive. So the
naive claim FAILS, but the orbit GF (1+q^{2k}+q^{4k}) = (1+q^k+q^{2k})(1-q^k+q^{2k})
is still divisible; positivity needs cross-orbit compensation. In the d=2, m=1,
a=(2,0,0) case: orbit1 {0,2,4} + orbit2 {1,2,3} = (1+q+q^2)(1+q^2) >= 0. The
consecutive orbit at offset e+1 repairs the spread orbit at e.

### Reduction achieved (to be verified/proved)

Define H_m(c) := P_m(c)/prod_{k<=m}(1+q^k+q^{2k}) (= h_m for profile c). Then:
1. H_m(rho c) = H_m(c) (rotate whole path — weight-preserving bijection).
2. Recursion: (1+q^m+q^{2m}) H_m(a) = sum_b q^{m*EMD(a,b)} H_{m-1}(b).
3. Grouping the RHS over rho-orbits O = {b, rho b, rho^2 b} (H constant on O):
   H_m(a) = sum_O H_{m-1}(b_O) * u_O(q^m), where
   u_O(x) = (x^{E_0}+x^{E_1}+x^{E_2})/(1+x+x^2), exact division since E_j
   distinct mod 3.
So the WHOLE problem reduces to:

**Level Lemma (target):** for rotation-invariant H_{m-1} >= 0 arising from the
tower, sum_O H_{m-1}(b_O) u_O(q^m) >= 0.

Plan:
- COMPUTE: census of rotation-triple patterns (E_1-E_0, E_2-E_0 normalized)
  for d = 1,2,4,5,7,8. Which u_O(x) occur? Conjecture: only a few shapes.
- COMPUTE: for d=2 (where Q_n = q^{n^2}, near-total cancellation) build the
  orbit decomposition explicitly and find the compensation pairing.
- Then d=4. Then attempt Garsia-Milne to convert paired cancellations into
  an explicit involution.

## Computational Evidence 1: rotation-triple census

Script: scripts/seed4_R2L2_rotation_orbits.py. For d = 1,2,4,5,7,8,10,11:
- EMD(rho a, rho b) = EMD(a,b): VERIFIED (assertion, all pairs).
- rho free on profiles (3 not dividing d): VERIFIED.
- {EMD(a, rho^j b)} distinct mod 3: VERIFIED for ALL pairs (this re-proves
  divisibility at every level, cf. Seed 7 equidistribution).
- Normalized patterns (0,u,v): NOT only (0,1,2). Census grows with d:
  d=2: (0,1,2), (0,2,4). d=4: (0,1,2),(0,1,5),(0,2,4),(0,4,5),(0,4,8).
  All u,v (and v-u) are nonmultiples of 3. Patterns look like the possible
  values of EMD changes under single-unit rotation; count of shapes ~ grows
  linearly in d. So a per-orbit positivity proof is impossible; cross-orbit
  compensation is essential.

## The orbit-space system (KEY REDUCTION)

Since H_m is rho-invariant, pass to orbit space. Let O_1..O_N (N = #profiles/3)
be the rho-orbits. Then

    H_m(O_i) = sum_j U_{ij}(q^m) H_{m-1}(O_j),
    U_{ij}(x) = (x^{E_0} + x^{E_1} + x^{E_2})/(1 + x + x^2),

where {E_t} = {EMD(a_i, rho^t b_j)} for representatives. H_0 = all-ones.
h_m >= 0 iff the vector H_m is coefficientwise nonneg; this is now a
QUESTION ABOUT A FIXED N x N MATRIX OF LAURENT-LIKE POLYNOMIALS acting on a
tower with varying x = q^m.

d=2 (N=2, O1 = orbit of (2,0,0), O2 = orbit of (1,1,0)):
    U(x) = [ 1-x+x^2   x ]
           [    x      1 ]
Only negative entry: -x in the (O1,O1) slot. Positivity of level m needs
    H_{m-1}(O2) >= (1-x) H_{m-1}(O1)  coefficientwise, x = q^m.
This is an injection-lemma-type CROSS-ORBIT inequality. Conjecture: it holds
with room to spare; find the invariant cone and induct.

## BREAKTHROUGH: d=2 tower solves in Rogers-Ramanujan polynomials

Script seed4_R2L2_d2_closed_form.py verified (m <= 10, exact):

    H_m(orbit of (1,1,0)) = B_m := sum_{j>=0} q^{j^2}   [m j]_q
    H_m(orbit of (2,0,0)) = A_m := sum_{j>=0} q^{j^2+j} [m j]_q

These are the FINITE ROGERS-RAMANUJAN (Schur/MacMahon) POLYNOMIALS —
manifestly nonneg. So for d=2 the level tower has an explicit fermionic
solution. Proof that these satisfy the orbit system (x = q^m):

    A_m = (1-x+x^2) A_{m-1} + x B_{m-1}
    B_m = x A_{m-1} + B_{m-1}

### Proof of the two identities (elementary q-Pascal; DONE BY HAND)

Notation: [n j] Gaussian; Pascal-1: [n j] = [n-1 j-1] + q^j [n-1 j];
Pascal-2: [n j] = [n-1 j] + q^{n-j} [n-1 j-1];
absorption: (1-q^j)[n j] = (1-q^n)[n-1 j-1]; (1-q^{n-j})[n j] = (1-q^n)[n-1 j].

(i) B_m - B_{m-1} = sum_j q^{j^2} q^{m-j} [m-1 j-1]      (Pascal-2)
              = q^m sum_i q^{i^2+i} [m-1 i] = q^m A_{m-1}.   QED (i)

(ii) A_m - A_{m-1} = sum_j q^{j^2+j} q^{m-j} [m-1 j-1]    (Pascal-2)
               = q^m sum_i q^{(i+1)^2} [m-1 i] = q^{m+1} C_{m-1},
    where C_n := sum_i q^{i^2+2i} [n i].

(iii) KEY LEMMA:  q C_n = B_n - (1-q^{n+1}) A_n  for all n >= 0.
    Proof: B_n - A_n + q^{n+1} A_n - q C_n
      = sum_j [n j] q^{j^2} ( (1-q^j) - q^{2j+1}(1-q^{n-j}) )
      = (1-q^n) ( sum_j q^{j^2}[n-1 j-1] - sum_j q^{j^2+2j+1}[n-1 j] )
        (using both absorption identities)
      = (1-q^n) ( sum_i q^{i^2+2i+1}[n-1 i] - sum_j q^{j^2+2j+1}[n-1 j] ) = 0. QED (iii)

Now the system: B-identity is (i). A-identity: (1-x+x^2)A_{m-1} + xB_{m-1}
= A_{m-1} + q^m ( B_{m-1} - (1-q^m) A_{m-1} ) = A_{m-1} + q^m * q C_{m-1}
  (by (iii) with n = m-1)
= A_{m-1} + q^{m+1} C_{m-1} = A_m  (by (ii)).  QED.

### Consequence (THEOREM, pending final hostile-referee pass)

For d=2 define Ahat_m, Bhat_m by the closed forms. Then
prod_{k<=m}(1+q^k+q^{2k}) * (Ahat, Bhat) satisfies the P_m recursion
P_m(a) = sum_b q^{m EMD(a,b)} P_{m-1}(b) (by the orbit system identities and
rho-invariance) and the base case P_0 = 1. Hence P_m = prod * Hhat, so

    h_m = (q;q)_m P_m/(q^3;q^3)_m = Hhat_m >= 0  for d=2, all profiles, all m.

This PROVES the core bottleneck h_m >= 0 for d=2 — and more importantly gives
the TEMPLATE: the rho-orbit tower converts h_m-positivity into finding a
fermionic polynomial solution of an N x N q-difference system, provable by
q-binomial Pascal identities. Next: d=4 (N=5), guess double-sum fermionic
forms (Warnaar k=2 / A_2 mod-7 Andrews-Gordon style).

## Hostile-referee pass on the d=2 theorem (PASSED -> GREEN)

Checked items:
1. E-triples (load-bearing constants). Hand + machine agree:
   {E_t(1,1)}={0,2,4}, {E(1,2)}={E(2,1)}={1,2,3}, {E(2,2)}={0,1,2}.
   So (1+x+x^2) U = [[1+x^2+x^4, x+x^2+x^3],[x+x^2+x^3, 1+x+x^2]], i.e.
   U = [[1-x+x^2, x],[x,1]] exactly. GREEN.
2. Identities (i),(ii),(iii): hand proofs above use only Pascal-2 and the two
   absorption identities; machine-verified n <= 25. GREEN.
3. Base cases: A_0=B_0=1=H_0; m=1: A_1=1+q^2, B_1=1+q from both sides. GREEN.
4. Reconstruction direction: define Phat_m := prod_{k<=m}(1+q^k+q^{2k}) * Hhat_m
   extended rho-invariantly. The (undivided) identities
   (1+x+x^2)A_m = (1+x^2+x^4)A_{m-1} + (x+x^2+x^3)B_{m-1}, x=q^m (& B analog)
   say exactly Phat_m(a) = sum_b q^{m EMD(a,b)} Phat_{m-1}(b) (group the sum
   over b by rho-orbit; rho-invariance of Phat_{m-1} + the triple table).
   Phat_0 = P_0 = 1. The recursion determines P uniquely, so Phat = P. GREEN.
5. h_m = (q;q)_m P_m/(q^3;q^3)_m with ell = gcd(2,3)=1: from Layer-1 GREEN
   definitions. (q^3;q^3)_m/(q;q)_m = prod(1+q^k+q^{2k}). GREEN.

THEOREM (d=2). For d=2 and all m >= 0:
  h_m(c) = B_m = sum_j q^{j^2} [m j]      if c is in the orbit of (1,1,0),
  h_m(c) = A_m = sum_j q^{j^2+j} [m j]    if c is in the orbit of (2,0,0).
In particular h_m >= 0 coefficientwise. These are the finite Rogers-Ramanujan
(MacMahon-Schur) polynomials.

## GENERAL exact-division lemma (upgrades the orbit tower to a THEOREM)

Lemma (mod-3 EMD). EMD(a,b) == b_0 - a_0 + a_1 - b_1 (mod 3), and
EMD(a, rho b) - EMD(a,b) == d (mod 3).
Proof. EMD = 3max(0,alpha,beta) - alpha - beta == -alpha-beta
= c_1 - c'_1 + c'_0 - c_0 (mod 3). With rho b = (b_2, b_0, b_1):
difference = (b_2 - b_0) - (b_0 - b_1) = b_0+b_1+b_2 - 3b_0 == d (mod 3). QED
(Machine-verified all profiles, d <= 12: seed4_R2L2 inline check.)

Corollary (Orbit-Tower Reduction, all 3∤d). {EMD(a, rho^t b)}_{t=0,1,2} hits
each residue class mod 3 exactly once, so x^{E_0}+x^{E_1}+x^{E_2} is divisible
by 1+x+x^2 in Z[x], U_{ij}(x) is a genuine polynomial matrix, and
    H_m(O_i) = sum_j U_{ij}(q^m) H_{m-1}(O_j),  H_0 = 1-vector,
with h_m(c) = H_m(orbit of c). The bottleneck h_m >= 0 becomes: the tower of
this N x N polynomial system (N = (d+1)(d+2)/6) stays coefficientwise nonneg.
This is GREEN for all d with 3∤d.

## d=4 status: fermionic forms for 3 of 5 orbits, 2 open

Orbit reps (normalized): (0,0,4),(0,1,3),(0,2,2),(1,1,2),(0,3,1)... (see
seed4_R2L2_orbit_system.py for the canonical list of 5 orbits).
With ferm(m,a,b,c) := sum_{n,j} q^{n^2-nj+j^2+an+bj} [m n][2n+c j]:
  H_m(orbit (1,1,2)) = ferm(m,0,0,0)   (Warnaar Cyl-b k=2 shape)  m<=5 OK
  H_m(orbit (0,0,4)) = ferm(m,1,1,0)                              m<=5 OK
  H_m(orbit (0,3,1)) = ferm(m,0,1,0)... (see seed4_R2L2_d4_fermionic.py) OK
MISSES: orbits (0,1,3) and (0,2,2): no single double-sum of this shape
(degree/coefficient obstructions), and pair search
seed4_R2L2_d4_pairsearch.py over (a,b,c) in [-2..3]^2 x [-2..2], second
summand with n>=1, found NONE. These are exactly the profiles outside
Warnaar's Conjecture 2 family — a genuinely open fermionic-form question.
NOTE: H_m >= 0 itself verified computationally for d=4 (and d=5,7) to
moderate m; only the CLOSED FORMS are missing.

## What did NOT work (information for the next layer)

- Naive "consecutive triple" claim {e,e+1,e+2}: FALSE (d=2 diagonal gives
  {0,2,4}). The division still works because residues are distinct mod 3 —
  distinctness, not consecutiveness, is the truth.
- Triple-sum ansatz [m n][n n2][n+n2 m1] (A_2 mod-8 template): matches NO d=4
  orbit; that template belongs to d=5.
- Pairs of Warnaar double-sums for the 2 missing d=4 orbits: exhausted a
  1000+-candidate box, none.

## Handoff

DONE (GREEN):
1. Orbit-Tower Reduction Theorem for all 3∤d: h_m >= 0 <=> the explicit N x N
   polynomial-matrix tower H_m = U(q^m) H_{m-1}, H_0 = 1, stays nonneg.
   Exact division proved by the two-line mod-3 EMD lemma (Seed 7's mechanism,
   now a proof, not an observation).
2. d=2 SOLVED: h_m = finite Rogers-Ramanujan polynomials A_m, B_m; full
   q-Pascal proof (identities (i),(ii),(iii) above). First complete proof of
   the h_m bottleneck for any d.

OPEN (ranked for next layer):
1. d=4 orbits (0,1,3),(0,2,2): find fermionic forms. Try Bartlett-Warnaar /
   Corteel-Welsh functional-equation guessing, or a THREE-term sum with
   different binomial shape [m n][n+c j]. Once all 5 orbits have forms, the
   d=2 proof template (Pascal identities on the 5x5 system) should finish d=4.
2. Alternative: prove tower positivity WITHOUT closed forms. For d=2 the
   needed cross-orbit inequality was B_{m-1} >= (1-q^m)A_{m-1}; identity (iii)
   says the surplus is exactly q C_{m-1} >= 0. Guess: for general d there is a
   "surplus vector" C with its own tower — a positivity cone invariant under
   U(x). Compute the surpluses for d=4 numerically and look for structure.
3. Then attack Q_n = sum_j (-1)^{n-j} q^{C(n-j+1,2)} [n j] h_j via the closed
   forms (for d=2: should collapse to q^{n^2} by a finite Durfee/RR argument —
   a good warm-up that the h-forms are strong enough for Q-positivity).

Scripts: seed4_R2L2_{rotation_orbits, orbit_system, d2_closed_form,
identity_check, d4_fermionic, d4_triple, d4_pairsearch}.py — orbit_system.py
is the reusable engine (exact poly arithmetic + tower builder).
