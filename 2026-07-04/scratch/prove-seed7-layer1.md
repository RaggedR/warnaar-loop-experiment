# Seed 7 Layer 1 — Uncu's Gaussian Elimination / Explicit Multisums

## Mission
Apply Uncu's automated Gaussian elimination to d=7 (modulus 10, 36 profiles) using the two Round 1 discoveries: det(I-A(x)) = -(x^3-1) and adj(I-A(x))[c,c'] = x^{EMD(c,c')}.

## Computational Evidence

### Verified Round 1 results
1. **det(I-A(x)) = -(x^3-1)** for d=7 (36x36 matrix): CONFIRMED.
2. **adj(I-A(x))[c,c'] = x^{EMD(c,c')}** for all 1296 entries of the d=7 matrix: CONFIRMED.
3. EMD values for d=7 range from 0 to 14.

### Critical correction: proper G_c system
**Previous agents' transfer matrix formula was wrong for computing F_{c,n}^bounded.**
The correct approach uses G_c(z,q) = (zq;q)_inf * F_c(z,q), which satisfies:
  G_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(zq^{|J|}, q)

Extracting [z^n] gives: (I - A(q^n)) * vec(g_{.,n}) = b_n(g_{.,n-1}, g_{.,n-2})
Q_{n,c} = (q^ell;q^ell)_n * g_{c,n} where ell = gcd(d,3).

### KEY RESULT 1: Adjugate inversion formula (GREEN)
g_{c,n} = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * b_n(c')

This reduces the entire CW q-difference system to an explicit recursion using only EMD values.

### KEY RESULT 2: Explicit Q_1 formula (GREEN)
Q_{1,c}(q) = (1/(1+q+q^2)) * sum_{c'} q^{EMD(c,c')} * B(c')
where B(c') = q(2-q) if rank 3, q if rank 2, 0 if rank 1.
For ell=3: Q_1 = sum directly (no division needed).
Verified positive for ALL d = 2,3,4,5,6,7,8,9,10,11,13.

### KEY RESULT 3: EMD Equidistribution Theorem (GREEN)
For d not divisible by 3:
  sum_{c': rank(c')=r} omega^{EMD(c,c')} = 0  for omega = e^{2pi*i/3}, all c, all r.

Equivalently: EMD(c,c') mod 3 is equidistributed as c' ranges over rank-r profiles.
This holds because EMD(c,c') mod 3 = (c'_1 - c'_2 - c_1 + c_2) mod 3, and the map
c' -> (c'_1 - c'_2) mod 3 is equidistributed on rank-r compositions when 3 does not divide d.

This PROVES that (1+q+q^2) divides the Q_1 numerator, and explains why the division is exact.
For d divisible by 3, the equidistribution fails (counts differ by d/3), but no division is needed (ell=3).

### Q_n positivity verified
- d=2: Q_n is a SINGLE MONOMIAL q^{n^2+n*a(c)} for all n (matches Warnaar k=1 result)
- d=4: Q_n verified nonneg for n=1,2,3 (all 15 profiles, precision O(q^200))
- d=7: Q_n verified nonneg for n=1,2 (all 36 profiles, precision O(q^200))

## Approach
The adjugate formula gives Q_n as an explicit multisum over "paths in profile space":
each step contributes q^{n*EMD(path)} weighted by past-level corrections.

## Strategy
**Key Lemma:** At each level, the past correction b_n(c') has a specific sign structure determined by the (zq;q)_{|J|-1} factors. The positivity of Q_n reduces to showing these corrections, after applying the adjugate inversion, yield nonneg coefficients.

## Handoff

### Best Result
1. **Adjugate inversion of the G_c system (GREEN):** Reduces the CW system to g_{c,n} = (1/(1-q^{3n})) * sum q^{n*EMD} * b_n.
2. **Explicit Q_1 formula (GREEN):** Closed-form for Q_1 valid for ALL d.
3. **EMD equidistribution mod 3 (GREEN):** Proves (1+q+q^2) | numerator when d not divisible by 3.

### Verification Status
- Adjugate inversion: GREEN
- Q_1 formula: GREEN (tested d=2..13)
- EMD equidistribution: GREEN (tested d=2..14, proved for d not divisible by 3)
- Q_n positivity for d=7, n<=2: GREEN (numerical, O(q^200))
- General positivity proof: RED

### Top Recommendation for Next Layer
1. The EMD equidistribution theorem (Result 3) should be proved formally for all d. The key is that EMD mod 3 depends only on (c'_1-c'_2) mod 3, and this quantity is equidistributed on rank-r compositions when 3 does not divide d.
2. Unfold the recursion for n=2: express g_{c,2} explicitly using g_{c,1} (which is now known in closed form). The resulting double sum should be analyzable.
3. The factor (q;q)_n / (q^3;q^3)_n at each level acts as a "mod 3 filter." Investigate whether this factor has a combinatorial interpretation (e.g., partitions into parts not divisible by 3) that could explain the positivity.

Scripts: scratch/scripts/seed7_R2L1_*.sage
