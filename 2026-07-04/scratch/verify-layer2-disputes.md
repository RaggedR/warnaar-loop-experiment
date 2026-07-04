# Verifier Report: Layer 2 Disputes

**Agent**: VERIFIER (independent computation from definitions)
**Date**: 2026-07-04
**Script**: `2026-07-04/scratch/scripts/verify_R2L2_final.sage`

---

## Method

All computations are exact in ZZ[q]. No power-series truncation.

**H_{c,m}** computed via the proved H-recursion:
  (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m * EMD(c',c)} H_{c',m-1},  H_{c,0} = 1
with exact ZZ[q] division at every step (zero remainder confirmed for all c, m, d in {2,4,5}).

**EMD formula** (from seed4's implementation, verifiably gives exact division):
  emd(c,c') = 3*max(0, a, b) - a - b,  a = c'[1]-c[1], b = c[0]-c'[0].

**Q_{n,c} independently** computed via:
  Q_{n,c} = (q^ell;q^ell)_n [z^n] G_c(z),  G_c(z) = (zq;q)_inf F_c(z,q)
using [z^n] G_c = sum_{m=0}^n c_{n-m} g_{c,m} where c_k = (-1)^k q^{k(k+1)/2}/(q;q)_k
and g_{c,m} = F_{c,m} - F_{c,m-1} = H_{c,m}/(q;q)_m - H_{c,m-1}/(q;q)_{m-1}.
Computed in QQ(q) and verified to be a polynomial in ZZ[q] at each step.

---

## Verdict: ITEM 1 (Conflict C2)

**Question**: Which 2 of 5 d=4 C_3-orbit representatives lack a fermionic H-form?

**5 canonical orbit representatives** (lex-min over rotations):
  (0,0,4), (0,1,3), (0,2,2), (0,3,1), (1,1,2)

**Ansatz tested**: ASW double sum
  H_{c,m} = sum_{n1,n2} q^{n1^2+n2^2-n1*n2+a*n1+b*n2} [m,n1]_q [2*n1+eps, n2]_q
for integer parameters a in [-2,7], b in [-10,9], eps in {-4,...,4}.
Verified at m=0..6 (exact ZZ[q] comparison).

**Results**:
- Orbit (0,0,4): MATCH  a=1, b=1, eps=0  (verified m=0..6)
- Orbit (0,1,3): MATCH  a=0, b=1, eps=0  (verified m=0..6)
- Orbit (0,2,2): NO MATCH
- Orbit (0,3,1): NO MATCH
- Orbit (1,1,2): MATCH  a=0, b=0, eps=0  (verified m=0..6)

**Resolution of conflict**:
- Seed 3 claimed missing: (0,2,2) and (0,3,1) — **CORRECT**
- Seed 4 claimed missing: (0,1,3) and (0,2,2) — **WRONG**

Seed 4's error: it exhibited a fit for orbit (0,3,1) but found none for (0,1,3).
Independent computation confirms: (0,1,3) admits the fit a=0, b=1, eps=0.
The orbit (0,3,1) does NOT admit any double-sum fit in the tested parameter range.

**Note on orbit labeling**: (0,1,3) and (0,3,1) are distinct C_3-orbits
(their cyclic rotation classes have no overlap). The synthesizer's warning that
reversal is NOT a symmetry is confirmed here — one orbit has a fermionic form,
the other does not.

**Confidence**: HIGH. The positive matches are verified exactly. The negative
results hold over a wide parameter search (a*b*eps = 10*20*9 = 1800 candidates).

---

## Verdict: ITEM 2 (Gauss inversion check)

**Question**: Does a_n := sum_{m=0}^n (-1)^{n-m} q^{C(n-m,2)} [n,m]_q H_{c,m}
equal Q_{n,c} exactly, for d > 2?

**Results**:
- d=2 (ell=1), all 6 profiles, n=0..5: **ALL MATCH** (sanity check)
- d=4 (ell=1), all 15 profiles, n=0..5: **ALL MATCH**
- d=5 (ell=2), all 21 profiles, n=0..5: **ALL MATCH**

The Q-transform identity holds for d=2, 4, and 5. Both routes (Q-transform formula
and direct [z^n]G_c extraction) give identical polynomials in ZZ[q].

**Regarding Seed 3's claim status**: The synthesizer noted "the telescoping is not
exhibited in the scratch file, but the statement is standard Gauss q-binomial
inversion." This verifier computed both sides independently and confirmed the match.
The formula is correct beyond d=2. Recommended status upgrade: **YELLOW → VERIFIED
for d=2,4,5** (all profiles, n=0..5).

**Additional finding (positivity)**: All computed Q_{n,c} values for d=4 orbit
representatives at n=1,2,3 have non-negative coefficients. This is consistent
with the conjecture.

**Confidence**: HIGH. Exact polynomial arithmetic, no truncation.

---

## Summary Table

| Item | Claim | Result |
|------|-------|--------|
| C2: missing d=4 orbits | Seed 3: (0,2,2),(0,3,1) | **SEED 3 CORRECT** |
| C2: missing d=4 orbits | Seed 4: (0,1,3),(0,2,2) | **SEED 4 WRONG** |
| Gauss inversion d=4 | a_n == Q_{n,c} | **CONFIRMED** |
| Gauss inversion d=5 | a_n == Q_{n,c} | **CONFIRMED** |

---

## Implication for Layer 3

- The **two fermionic-form-missing orbits** at d=4 are **(0,2,2) and (0,3,1)**.
  These are the C_3-orbits containing (0,2,2) and (0,3,1) (lex-min reps).
  Layer 3's Mission 1 should target these two orbits.

- The **Q-transform** is confirmed as a computational identity (not just d=2),
  strengthening its use as the link between the Bounded Fermionic Form Conjecture
  and explicit positive Q_n formulas. The three fermionic-matched orbits
  (0,0,4), (0,1,3), (1,1,2) each give explicit positive Q_n formulas via this transform.
