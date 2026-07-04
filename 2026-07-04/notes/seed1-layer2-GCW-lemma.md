# The G-CW Lemma (Seed 1, Layer 2) — where the alternating signs go

**Status: GREEN (one-line proof from CW; machine-verified for all d=2 profiles,
n <= 10, PREC 900).** Proof + d=2 application in `../proofs/prove-seed1-layer2.tex`.

## Statement

For ANY rank r and ANY profile c, define

    G_c(y) := (yq;q)_inf * F_c(y,q).

Then the Corteel–Welsh system transforms into

    G_c(y) = sum_{∅≠J⊆I_c} (-1)^{|J|-1} * (yq;q)_{|J|-1} * G_{c(J)}(y q^{|J|}).

**Proof.** (yq;q)_inf / ((1-yq^s)(yq^{s+1};q)_inf) = (yq;q)_inf/(yq^s;q)_inf
= (yq;q)_{s-1}, with s = |J|. ∎

Note Q_{n,c} = (q^ell;q^ell)_n * [y^n] G_c(y). So the ENTIRE conjecture is a
positivity statement about the solution of this q-difference system, whose
coefficients are now FINITE POLYNOMIALS — the infinite alternating series
(yq;q)_inf has been fully absorbed. |J|=1 terms have coefficient +1;
|J|=2 terms have -(1-yq) = -1+yq; |J|=3 terms have +(1-yq)(1-yq^2).

## Why this matters (d=2 worked example)

For d=2 (orbits a=(1,1,0), b=(2,0,0)), eliminating G_b from the G-system gives

    G_a(y) = G_a(yq) + yq * G_a(yq^2)      (Rogers–Ramanujan equation!)

with MANIFESTLY NONNEGATIVE coefficients {1, yq}: the -1 from the |J|=2 term
cancels exactly against part of the |J|=1 contributions. Uniqueness of the
power-series solution with G(0)=1 gives [y^n]G_a = q^{n^2}/(q;q)_n, hence
**Q_n = q^{n^2}** (orbit a) and, via G_b(y) = G_a(yq), **Q_n = q^{n(n+1)}**
(orbit b). d=2 positivity PROVED.

## Suggested use by other seeds

1. **General-d program:** eliminate the orbit system at the G level for
   d=4,5 (Warnaar's proved cases) and look for a positive-coefficient
   q-difference system after sign recombination. If the eliminated system
   always recombines to nonneg polynomial coefficients (in y, q), positivity
   follows by induction on n exactly as in d=2. The open problem is the
   general-d analogue of the cancellation -1 + (|J|=1 terms).
2. **Seed 6 / Warnaar's Conjecture 2:** G_c IS the object FERM/(...)·—
   Conjecture 2 asserts G_c(y) = FERM_c(y,q) is a manifestly positive
   multisum. The G-CW system gives the recurrences any candidate FERM must
   satisfy — useful both for guessing multisums and for verifying them.
3. **Seeds 3/8 (h_m >= 0):** h_m = (q^ell;q^ell)_m * [y^m] G_c. The G-CW
   system gives level-m recurrences for h_m directly, with polynomial
   coefficients; the m=n diagonal is Q_n.
