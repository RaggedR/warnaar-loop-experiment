# Prove -- Seed 5 (Schubert Polynomials, Lascoux), Layer 1

## Problem Statement

Prove that Q_{n,c}(q) has non-negative coefficients, where c = (c_0, c_1, c_2) with d = c_0+c_1+c_2 not divisible by 3, and

Q_{n,c}(q) := (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

where F_c(z,q) = sum_Lambda q^{|Lambda|} z^{max(Lambda)} is the bivariate cylindric partition generating function.

## Seed Context: Schubert Polynomials and Lascoux

My seed covers Lascoux's work on:
1. Schubert polynomials Y_v(x,y) -- a basis for Pol(x_n) characterized by vanishing properties
2. Key polynomials K_u (Demazure characters) -- always have nonneg integer coefficients
3. Grothendieck polynomials G_sigma -- K-theoretic analogues with alternating signs from y-variables
4. The fundamental relation: K_u * x_1^k ... x_k = Y_{u+[k,...,1,0^{n-k}]}(x, 0)
5. Divided difference operators partial_i, pi_i, hat{pi}_i and their actions on these bases

## Computational Evidence

### Q_{n,c}(q) Data (verified via Corteel-Welsh iterative system)

**Profile c=(1,1,0), d=2, t=5:**
- Q_n = q^{n^2} for all n. Trivially positive.

**Profile c=(2,1,1), d=4, t=7, Q(1) = 4^n:**
- Q_0 = 1
- Q_1 = 2q + q^2 + q^3
- Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
- Q_3 = 2q^7 + 2q^8 + 5q^9 + 4q^10 + 6q^11 + 6q^12 + 6q^13 + 5q^14 + 6q^15 + 4q^16 + 4q^17 + 3q^18 + 3q^19 + 2q^20 + 2q^21 + q^22 + q^23 + q^24 + q^27
- Q_4: 33 nonzero coefficients, all nonneg, Q(1) = 256

**Profile c=(3,1,0), d=4, t=7:**
- Q_1 = q + q^2 + q^3 + q^5
- Q_2 = 2q^4 + q^5 + 2q^6 + 2q^7 + 2q^8 + q^9 + 2q^10 + q^11 + q^12 + q^13 + q^16

**Profile c=(2,2,1), d=5, t=8, Q(1) = 6^n:**
- Q_1 = 2q + 2q^2 + q^3 + q^4
- Q_2 = q^3 + 4q^4 + 4q^5 + 5q^6 + 4q^7 + 5q^8 + 3q^9 + 3q^10 + 2q^11 + 2q^12 + q^13 + q^14 + q^16

All nonneg for every case tested (n up to 4, d up to 5). Confirms the conjecture.

### Key Pattern: Degree Formula
- c=(2,1,1): deg(Q_n) = 3n^2 (degs: 0, 3, 12, 27, 48)
- c=(3,1,0): deg(Q_n) appears to be 3n^2 + 2n (degs: 0, 5, 16, 33, 56)
- c=(2,2,1): deg(Q_n) = 4n^2 (degs: 0, 4, 16, 36, 60 -- with truncation at 60)

### CRUCIAL FINDING: Key Polynomial Decomposition

**Theorem (computational):** For profile c=(2,1,1), Q_{n,c}(q) decomposes as a positive integer combination of key polynomial specializations K_{(a,b)}(q, q^2).

**Verified decompositions:**

Q_1 = K_{(1,0)} + K_{(0,1)} + K_{(3,0)} at (q, q^2)
    = q + (q + q^2) + q^3

Q_2 = K_{(0,5)} + K_{(0,4)} + K_{(3,0)} + 2*K_{(4,0)} + K_{(6,0)} + K_{(12,0)} at (q, q^2)
    = (q^5+q^6+...+q^10) + (q^4+...+q^8) + q^3 + 2q^4 + q^6 + q^12

Q_3: 14-term decomposition verified, all coefficients positive.

All decompositions verified at q=1: sums to 4^n correctly.

**Why this matters:** Key polynomials K_u(x_1,...,x_m) always have nonneg integer coefficients (they are characters of Demazure modules). Therefore, any specialization K_u(q^{a_1},...,q^{a_m}) with a_i > 0 gives a polynomial in q with nonneg coefficients. A positive combination of such specializations is manifestly positive.

**The catch:** The decomposition is not unique (it depends on the greedy algorithm). I have not identified a canonical or natural decomposition that generalizes to all n and c.

## Approach

### Angle of Attack: Key Polynomial Expansion of F_{c,n}(q)

If Q_{n,c}(q) can be written as sum_{u in S_n} a_u * K_u(q^{e_1},...,q^{e_m}) with all a_u >= 0, positivity follows. The question reduces to:

1. What is the set of compositions S_n?
2. What are the exponents (e_1,...,e_m)?
3. Why are all a_u nonneg?

From the data, the specialization appears to be at (q, q^2) for 2-variable key polynomials. This corresponds to the principal specialization of GL_2 characters.

### What a Counterexample Looks Like

A counterexample would be a profile c and integer n such that:
- Q_{n,c}(q) has a negative coefficient, OR
- Q_{n,c}(q) cannot be decomposed as a positive combination of key polynomial specializations

The first would disprove the conjecture. The second would only disprove this particular approach. Given the computational evidence, neither seems likely for small cases.

Confidence in conjecture: 99% (proved for d <= 5 by Warnaar, massive computational support).
Confidence in key polynomial approach: 40% (works computationally but the decomposition is not canonical, and I don't have a structural reason why it should work for general d).

## Strategy

### Candidate Strategies

1. **Direct key polynomial decomposition**
   - WHY IT MIGHT WORK: Computationally verified for d=4, n=1,2,3,4. Key polynomials have the right algebraic properties (nonneg coefficients, Demazure module interpretation).
   - WHY IT MIGHT NOT: The decomposition appears non-canonical. Different greedy orderings give different decompositions. Without a structural reason, this is an observation, not a proof technique.

2. **Grothendieck polynomial interpretation**
   - WHY IT MIGHT WORK: The (zq;q)_inf factor in the Q definition has alternating signs, resembling the y-dependence of Grothendieck polynomials G_sigma(x,y). If F_c(z,q) is a specialization of a Schubert kernel Theta_n^Y, then the product (zq;q)_inf * F_c(z,q) might be related to a Grothendieck kernel, and the [z^n] extraction might land in a positive cone.
   - WHY IT MIGHT NOT: The connection between cylindric partitions and Schubert calculus is not established. The Borodin product formula does not immediately relate to Schubert determinantal formulas.

3. **Demazure module filtration**
   - WHY IT MIGHT WORK: If the space of cylindric partitions bounded by n has a filtration by Demazure modules (crystal base decomposition), then Q_{n,c}(q) would be a positive sum of Demazure characters.
   - WHY IT MIGHT NOT: Cylindric partitions live in an affine setting, while Demazure modules are finite-dimensional. The connection would need to go through affine Demazure modules.

4. **Pieri formula connection**
   - WHY IT MIGHT WORK: Lascoux's Pieri formula (Lemma 3.7.1) gives positive expansions of products Y_rho * Y_{0^{k-1}r}. If Q_{n,c}(q) can be expressed as an iterated Pieri-type product, positivity would follow.
   - WHY IT MIGHT NOT: The iteration structure of Q (indexed by n) doesn't obviously match Pieri multiplication.

### Chosen Strategy: Grothendieck polynomial / divided difference approach

**Rationale:** The strongest connection between my seed context and the problem is through the (zq;q)_inf factor. In Lascoux's framework:

- The Schubert polynomial Y_v(x,y) vanishes at certain points and has positive coefficients.
- The Grothendieck polynomial G_sigma(x,y) introduces factors of (1 - y_j/x_i), which produce alternating signs.
- The factor (zq;q)_inf = prod_{i>=1} (1 - zq^i) is precisely a specialization of such Grothendieck-type factors.

If F_c(z,q) = specialization of sum_v Y_v(x,y) at geometric sequences, then
(zq;q)_inf * F_c(z,q) might equal a specialization of the Grothendieck kernel, and positivity of [z^n] would follow from the "positive position" of this kernel.

### Key Lemma

The proof reduces to showing:

"The extraction [z^n]((zq;q)_inf * F_c(z,q)) has nonneg coefficients as a polynomial in q, for all valid profiles c and all n >= 0."

More specifically, it reduces to finding a combinatorial or algebraic object O_{n,c} such that:
1. O_{n,c} is a finite set with a natural q-weighting
2. sum_{o in O_{n,c}} q^{wt(o)} = [z^n]((zq;q)_inf * F_c(z,q))

If such an object exists, positivity is manifest. The key polynomial decomposition suggests O_{n,c} might be a union of Demazure crystal components.

## Attempt 1: Connecting (zq;q)_inf to Grothendieck polynomials

### Setup

The Grothendieck polynomial for a dominant weight lambda in n variables is:
G_lambda(x,y) = prod_{i=1..n, j=1..lambda_i} (1 - y_j/x_i)

When y = 0, this is 1 (the unit). When y_j = 1 for all j:
G_lambda(x, 1) = prod_{i,j} (1 - 1/x_i) = prod_i (1 - 1/x_i)^{lambda_i}

The factor (zq;q)_inf = prod_{i>=1}(1 - zq^i) has a similar structure: it is a product of linear factors in z with coefficients that are powers of q.

If we set z = y_1/x_1 (a single ratio), then (zq;q)_inf = prod_{i>=1}(1 - q^i * y_1/x_1), which looks like a "Grothendieck factor" with infinitely many y-variables y_j = y_1 * q^j and a single x-variable x_1.

### The connection

Consider the identity:
F_c(z,q) * (zq;q)_inf = F_c(z,q) * prod_{i>=1}(1 - zq^i)

The product F_c(z,q) is manifestly positive (as a generating function for cylindric partitions). The factor (zq;q)_inf introduces alternation.

In Lascoux's framework (Theorem 2.14.1), the Schubert kernel times the Vandermonde:
X_omega(y,x^omega) * Delta(x) = sum_sigma (-1)^{ell(sigma)} partial_sigma(G_{sigma}(x,y) x^rho)

This is an identity that "factors out" the alternation through divided differences. 

### The obstacle

The key difficulty: F_c(z,q) is an infinite product (Borodin's formula), not a finite polynomial. Lascoux's machinery works with polynomials in finitely many variables. To apply it, I would need to:

1. Truncate F_c(z,q) to a finite polynomial (which the [z^n] extraction effectively does), or
2. Work with infinite-variable Schubert calculus (which exists but is much harder).

The truncation approach via [z^n] is what we're already doing. The question is whether the truncated object has a Schubert-theoretic interpretation.

### Gap

I cannot show that [z^n](F_c(z,q) * (zq;q)_inf) is a specialization of a Grothendieck polynomial or a positive combination thereof. The Borodin product formula for F_c(q) involves q-Pochhammer symbols at step t = k+d, while Grothendieck polynomials involve factors at step 1. The mismatch in the step size is a fundamental obstacle.

## Stuck: Key polynomial approach doesn't generalize

### What I'm trying to show
That Q_{n,c}(q) decomposes as a positive integer combination of key polynomial specializations K_u(q^{e_1},...,q^{e_m}) for all n and c.

### Why I can't show it
1. The decomposition I found computationally (for c=(2,1,1) at specialization (q,q^2)) is produced by a greedy algorithm and appears non-canonical.
2. The compositions u appearing in the decomposition don't follow an obvious pattern as n grows.
3. For different profiles c, the specialization exponents might change (e.g., (q, q^3) instead of (q, q^2)).
4. I have no structural argument for why such a decomposition should exist.

### What would unstick me
A connection between bounded cylindric partitions and Demazure crystals. Specifically: if there exists a crystal B_{n,c} such that the cylindric partitions bounded by n can be decomposed into Demazure crystal components, then the key polynomial expansion would be canonical and the positivity would follow from the crystal structure.

## Assumptions Check

- **About the objects:** I assume key polynomials K_u at (q, q^2) are the right building blocks. UNCERTAIN -- maybe Schur functions or Hall-Littlewood polynomials are more natural.
- **About the maps:** I assume the specialization is at (q, q^2). UNTESTED for other profiles -- need to check (2,2,1).
- **About definitions:** I'm using the Demazure character definition of key polynomials. TRUE for GL_n.
- **About prior results:** Lascoux's key polynomial positivity is a theorem, not a conjecture. TRUE.
- **About the problem:** I assume the positivity is "explained" by a positive basis expansion. UNCERTAIN -- maybe the positivity has a more analytic explanation.
- **The obvious one:** I'm only trying 2-variable key polynomials. UNTESTED -- maybe 3 or more variables are needed.

## Partial Result

**Observation (verified computationally):** For profile c = (2,1,1) and n = 0, 1, 2, 3, 4, the polynomial Q_{n,c}(q) admits a decomposition as a nonneg integer combination of evaluations of GL_2 key polynomials K_{(a,b)}(q, q^2). This immediately implies Q_{n,c}(q) has nonneg coefficients for these cases (since key polynomials have nonneg coefficients in the monomial basis).

**Significance:** This provides a new proof of positivity (for these specific cases) that is different from Warnaar's manifestly positive multisum formulas. It suggests that cylindric partition polynomials might have a representation-theoretic interpretation via Demazure modules.

**Limitation:** The decomposition is algorithmic (greedy), not structural. Without a canonical decomposition or a proof that one always exists, this cannot generalize to a proof for all n and c.

## Escalation

I am stuck on: establishing a structural connection between Q_{n,c}(q) and Demazure characters/key polynomials.

Attempt 1 (Grothendieck polynomial interpretation): Failed because the Borodin product formula has q-Pochhammer step t, while Grothendieck factors have step 1. The step mismatch prevents direct identification.

Attempt 2 (Key polynomial decomposition): Succeeds computationally but the decomposition is non-canonical. No structural reason found for why it should work in general.

Attempt 3 (Pieri formula): Not seriously attempted -- the iterated structure of Q doesn't obviously match Pieri multiplication.

What all three have in common: They all try to interpret Q_{n,c}(q) as a character of some algebraic object (Grothendieck class, Demazure module, Schubert intersection). The cylindric partition world doesn't naturally land in any of these, so the connection is forced rather than natural.

What I think is needed: A direct combinatorial or crystal-theoretic link between bounded cylindric partitions and type A Demazure crystals. This might exist through the connection between cylindric partitions and affine crystal bases (the work of Tingley, Tsuchioka, and others on crystals for affine Lie algebras).
