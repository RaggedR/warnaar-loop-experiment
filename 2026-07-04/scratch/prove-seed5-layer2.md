# Seed 5, Layer 2, Round 2 — Warnaar's Conjecture 2 for k=3 (d=8): all 45 profiles

## Mission
Use the proved adjugate inversion (Adjugate Monomial Theorem, Seed 4 GREEN) to compute Q_{n,c}
for ALL 45 profiles at d=8 (15 canonical C_3 orbits) and check fermionic formulas for every orbit.
Warnaar's Conjecture 2 covers 5 of 15 orbits: (8,0,0), (7,1,0), (6,2,0), (5,3,0), (3,3,2).
Uncovered 10: (7,0,1), (6,0,2), (6,1,1), (5,0,3), (5,2,1), (5,1,2), (4,4,0), (4,3,1), (4,1,3), (4,2,2).

## LITERATURE FINDINGS (major)

### 1. Uncu 2024 (uncu_proofs_modulo11_13_cylindric_kanade_russell) — modulus 11 = d=8 IS PROVED
Uncu PROVED (Theorem thm:m11, via Gaussian elimination on the ideal of S_11 recurrences,
N=6) explicit representations of H_c(z,q) := (zq;q)_inf F_c(z,q)/(q;q)_inf for ALL 15 canonical
profiles at |c|=8, as Z[q,z]-combinations of Kanade-Russell S_11(z; rho|sigma) functions:

S_11(z; rho|sigma) = sum_{r1>=r2>=r3>=0, s1>=s2>=s3>=0} z^{r1}
  q^{sum_i (r_i^2 - r_i s_i + s_i^2 + rho_i r_i + sigma_i s_i) + 2 r3 s3}
  / [(q)_{r1-r2}(q)_{r2-r3}(q)_{r3}(q)_{s1-s2}(q)_{s2-s3}(q)_{s3}(q)_{r3+s3+1}]

The 15 formulas (eq:mod11list + eq:H440exp), with e_i = (0^i,1,...,1):
- c_3=0 profiles (Warnaar-covered): single positive S_11 term.
- c_2=0, c_3!=0: S_11(e_0|e_{c_3}) - q(1-z) S_11(e_0+delta_1|e_{c_3-1})  [SIGNED]
- c_2,c_3>0: S_11(e_{c_2}|e_{c_3}) - q S_11(e_{c_2-1}|e_{c_3-1})  [SIGNED]
- (4,4,0): S_11((1,0,0)|(0,1,1)) - q S_11((1,0,1)|(1,1,1)) + qz S_11((2,1,1)|(0,0,0))

CONSEQUENCE: Q_{n,c}(q) = (q;q)_n (q;q)_inf [z^n] H_c(z,q) has a PROVED explicit formula for
every profile at d=8. NOT manifestly positive (signs from the -q terms and from (q;q)_inf).

### 2. Warnaar Conjecture 2 for k=3 becomes an identity between EXPLICIT objects
Since H_c is proved equal to the S_11-combination, Conjecture 2 for k=3 (covered profiles) is
EQUIVALENT to:  FERM_c(z,q) = (q;q)_inf * [S_11-combination for c]   (5 identities, both sides
explicit multisums). No unknown functions remain. High-precision bivariate verification of these
= computational proof-modulo-identity of Conjecture 2 for k=3.

### 3. CDU 2020 (proved, d=5, modulus 8) — template for positive forms of UNCOVERED profiles
CDU Theorem gives manifestly positive G_c(z,q) = (zq;q)_inf F_c for ALL 7 orbits at d=5, e.g.
G_{(4,0,1)}(z,q) = sum z^{n1} q^{QF + n1+n3} (1 + z q^{n1+n2+n4+1}) / (q)_{n1} * binoms.
KEY STRUCTURAL POINT: for uncovered profiles the positive numerator polynomial contains
z-MONOMIALS (z q^{...}). Then Q_n = A_n + (1-q^n) q^{...} B_{n-1} with A,B positive multisums
— the clean (q)_n/(q)_{n1} cancellation gives manifest positivity ONLY for z-free numerators.
So even in the PROVED d=5 case, uncovered profiles do not get manifest Q_n-positivity from the
known fermionic G-forms. Expect the same wall at d=8. The ansatz for d=8 uncovered profiles
should be: positive numerator polynomial in {1, z} x q^{linear form + const}.

## Plan
A. Exact Q_n for all 45 profiles at d=8, n=0..4, PREC=400 (rule: 6*max(3,4)^2+200=296),
   via bounded-CW F-system + adjugate inversion F_{c,m} = (1-q^{3m})^{-1} sum_{c'} q^{m EMD(c,c')} F_{c',m-1}.
   Verify (I-A(x)) * q^{EMD} = (1-x^3) I first; verify F_{c,1} against direct CP enumeration;
   check polynomiality and Q_n(1) = 14^n.
B. Verify Warnaar k=3 fermionic Q_n for the 5 covered orbits, n=1,2,3(,4). (Extends Seed 6's n<=2.)
C. Implement S_11 + Uncu's 15 proved formulas; check Q_n^{Uncu} == Q_n^{CW} for all orbits n<=3.
   This validates using Uncu = proved ground truth, and verifies Conjecture-2-for-k=3 as
   FERM = (q)_inf * S_11-combo on covered orbits.
D. Fit CDU-style positive numerators for the 10 uncovered orbits in the Warnaar k=3 basis.

## Log

### Result 1 (GREEN): CW/adjugate ground truth, d=8, all 45 profiles, n=0..6
Script: seed5_R2L2_qn_data.sage (n<=4, PREC=400, JSON dump seed5_R2L2_qn_d8.json), seed5_R2L2_n56.sage (n=5,6, PREC=450).
- Adjugate identity (I-A(x))·x^EMD = x^EMD·(I-A(x)) = (1-x^3)I re-verified for all 45x45 entries.
- Q_n is a polynomial, has ALL nonneg coefficients, and Q_n(1)=14^n for every profile and every n=0..6.
- This extends the d=8 positivity verification from n<=2 (Round 1) to n<=6.

### Result 2 (GREEN): Warnaar Conjecture 2 fermionic formula verified for k=3, n=1..6
Script: seed5_R2L2_warnaar_ferm.sage (n<=4), seed5_R2L2_n56.sage part (b).
Exact polynomial match Q_n^ferm == Q_n^CW for all 5 covered orbits
(8,0,0),(7,1,0),(6,2,0),(5,3,0) [s=1..4] and balanced (3,3,2), n=1..6.
Balanced case uses chunk_021 exactly: NO '+m_i' and NO linear n_i terms.
Extends Seed 6's verification (n<=2) to n<=6.

### Result 3 (GREEN, MAJOR): Uncu's PROVED S_11 formulas reproduce Q_n for ALL 15 orbits
Script: seed5_R2L2_uncu_s11.sage (n<=4), seed5_R2L2_n56.sage part (c) (n=5,6).
Uncu 2024 (literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell,
Theorem thm:m11) PROVED H_c(z,q) = explicit S_11(rho|sigma) combinations for all 15
canonical orbits at d=8 (eq:mod11list + eq:H440exp). Implemented S_11 (eq:Sm1, k=4,
6-fold sum) and all 15 formulas; verified
  Q_n = (q)_n (q)_inf [z^n] H_c^{S11}  ==  Q_n^CW   EXACTLY
for all 15 orbits, n=0..6 (n=0 initial condition (q)_inf·[z^0]H = 1 also checked), O(q^430).

Consequences:
A. POSITIVITY AT d=8 IS NOW A STATEMENT ABOUT PROVED EXPLICIT SERIES. Every Q_{n,c} at
   d=8 equals (q)_n(q)_inf[z^n] of a proved 6-fold-sum expression. No unknown functions.
B. WARNAAR'S CONJECTURE 2 FOR k=3 IS EQUIVALENT TO AN EXPLICIT q-SERIES IDENTITY:
     FERM_c(z,q) = (q)_inf * S_11(e_{c_2} | e_{c_3})   for the covered profiles,
   (e_i = i zeros then ones), since Uncu proved the right side equals (zq)_inf GK_c/(q)_inf·(q)_inf.
   Verified here at z-orders 0..6 to O(q^430). This is a concrete Bailey-type target:
   Warnaar's 5-fold (n_2,n_3,m_1,m_2)-sum with q-binomials == (q)_inf x Uncu's 6-fold sum.

### Result 4 (YELLOW): fermionic ansatz search for the 10 uncovered orbits
Scripts: seed5_R2L2_ansatz_scan.sage, seed5_R2L2_ansatz2.sage, seed5_R2L2_ansatz3.sage,
seed5_R2L2_431_verify.sage. Basis: Warnaar k=3 quadratic form
QF = n_1^2+n_2^2+n_3^2 - n_1 m_1 - n_2 m_2 + m_1^2+m_2^2 (+2 n_3 m_3 folded via m_3=2n_3)
with binomials [n_1;n_2][n_1-n_2+m_2;m_1][n_2;n_3][n_2-n_3+m_3;m_2], n_1=n.
1. Single-term ansatz (linear terms a·(n,m)+c0, all in {0..2/3}^6): ZERO hits for all 10.
2. Two-term z-free numerator (hash-paired over {0..3}^6 x {0..3}^6): ZERO hits for all 10.
3. CDU-style z-shift two-term: Q_n = F(L1,n) + q^{un+v}(1-q^n)F(L2,n-1):
   EXACTLY ONE orbit fits: (4,3,1), verified n=1..4 (PREC 300):
     Q_n^{(4,3,1)} = F(b_1=1; n) + q^n (1-q^n) F(b_1=1,b_2=1; n-1)
   (equivalently u=0,v=1,L2=(1,0,0,1,1,0), or u=0,v=0,L2=(1,0,0,1,1,1)).
   This is bivariate-positive (numerator 1 + zq^{...} at G-level), mirroring CDU d=5.
   The other 9 orbits need richer numerators (CDU d=5 needed up to 4 z-monomials).
Stopped ansatz enumeration after 3 families (three-strike rule); the right route for the
remaining orbits is structural (S_11 recurrences), not blind scanning.

### Where the difficulty now lives
- Covered profiles: manifest positivity = clean cancellation (q)_n / (q)_{n_1}. DONE
  (conditional on Conjecture 2, which is now an explicit identity vs proved S_11 series).
- Uncovered profiles: proved formulas are DIFFERENCES S_11(...) - q·S_11(...)
  (or with -q(1-z), +qz terms). Positivity holds numerically (n<=6) but no manifestly
  positive form is known — same phenomenon as CDU d=5, where proved positive G-forms
  have z-monomial numerators forcing (1-q^n) factors at the Q_n level.
- Uncu's relation ideal I_11 (recurrences R1,R2,R3,R4 in main.tex) is a finite toolkit:
  a next layer could try to rewrite (q)_inf·(S(rho|sigma) - q S(rho'|sigma')) as a
  positive multisum by applying R1/R2 to telescope the difference.

## Handoff

### Best Result
1. (GREEN) Q_{n,c} >= 0 verified for ALL 45 profiles at d=8, n=0..6, O(q^430), with Q_n(1)=14^n.
2. (GREEN) Uncu 2024's PROVED S_11 formulas for all 15 orbits at d=8 reproduce Q_n exactly
   (n<=6). d=8 positivity is now about explicit proved series — no unknown functions remain.
3. (GREEN) Warnaar's Conjecture 2 for k=3 == explicit identity FERM_c = (q)_inf·S_11(e_{c_2}|e_{c_3}),
   verified to z^6, O(q^430). Fermionic Q_n matches for all 5 covered orbits, n=1..6.
4. (YELLOW) New CDU-style bivariate-positive formula found for uncovered orbit (4,3,1), n<=4.

### Verification Status
- All exact polynomial matches, PREC 300-450 (rule 6·max(k,m)^2+200 respected for n<=6 windows).
- Nothing here is a formal proof of positivity; but the reduction targets are all proved or explicit.

### Top Recommendations for Next Layer
1. PROVE FERM_c = (q)_inf · S_11(e_{c_2}|e_{c_3}) for k=3 covered profiles. Both sides explicit;
   Uncu's R1/R2/R3/R4 recurrences (main.tex eq. R1-R41) characterize S_11; showing FERM/(q)_inf
   satisfies the same recurrences + initial conditions would PROVE Conjecture 2 for k=3.
   This is finite, mechanical (q-Zeilberger/Sister-Celine style), and the single most
   valuable step: it makes covered-profile positivity at d=8 a THEOREM.
2. For uncovered orbits: apply Uncu's relations R1^{(i)}, R2^{(i)} to the differences
   S(rho|sigma) - q S(rho'|sigma') appearing in eq:mod11list to seek telescoping into
   positive combinations, starting from the (4,3,1) success (Result 4.3) as a template.
3. Generalize Result 4.3's ansatz with 3-4 z-monomial numerators (CDU d=5 pattern) for the
   remaining 9 orbits — but drive the numerator shapes from the CW equations relating
   uncovered to covered profiles rather than blind scans.
4. Uncu also proved modulus 13 (d=10). The same pipeline (this file's scripts) transfers:
   d=10 would test whether the structure is uniform in k.

Scripts: scratch/scripts/seed5_R2L2_qn_data.sage, seed5_R2L2_warnaar_ferm.sage,
seed5_R2L2_uncu_s11.sage, seed5_R2L2_n56.sage, seed5_R2L2_ansatz_scan.sage,
seed5_R2L2_ansatz2.sage, seed5_R2L2_ansatz3.sage, seed5_R2L2_431_verify.sage.
Data: scratch/scripts/seed5_R2L2_qn_d8.json (Q_n, all 45 profiles, n=0..4).
