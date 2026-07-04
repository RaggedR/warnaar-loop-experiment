# Seed 7 Layer 2 — Unfolding the n=2 Recursion (Round 2)

## Mission
Compose the adjugate inversion twice to write Q_2 as an explicit double sum.
Analyze for manifest positivity. Check whether EMD equidistribution generalizes
to level n=2 (denominator 1+q^n+q^{2n}). Goal: Q_2 >= 0 from Q_1 >= 0 +
structural properties (equidistribution + Bellman/triangle inequality).

## Setup: the master recursion (derivation)

CW system for G_c(z,q) = (zq;q)_inf * F_c(z,q):
  G_c(z,q) = sum_{0 != J subset I_c} (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(z q^{|J|}, q)

Extract [z^n]. Writing a_k^{(s)} = [z^k](zq;q)_s:
  (zq;q)_0 = 1;  (zq;q)_1 = 1 - zq;  (zq;q)_2 = 1 - z(q+q^2) + z^2 q^3.

Current-level (k=0) terms assemble the matrix A(q^n); past terms give b_n(c).
Note |J|=3 forces c(J) = c, and |J|=3 possible only when rank(c)=3.

  b_n(c) = q^{2n-1} * sum_{J subset I_c, |J|=2} g_{c(J),n-1}
           - [rank(c)=3] * (q^{3n-2}+q^{3n-1}) * g_{c,n-1}
           + [rank(c)=3] * q^{3n-3} * g_{c,n-2}.

Adjugate inversion (GREEN, Seed 4 + Seed 7 L1):
  g_{c,n} = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * b_n(c').

Substituting Q_m = (q^l;q^l)_m g_m  (l = gcd(d,3)), i.e.
g_{.,n-1} = Q_{n-1,.}/(q^l;q^l)_{n-1}, g_{.,n-2} = Q_{n-2,.}/(q^l;q^l)_{n-2}:

**MASTER RECURSION** (claim, to be verified):
  Q_{n,c} = (1-q^{l*n})/(1-q^{3n}) * sum_{c'} q^{n*EMD(c,c')} * BR_n(c')
where
  BR_n(c') = q^{2n-1} * sum_{J subset I_{c'}, |J|=2} Q_{n-1,c'(J)}
             + [rank(c')=3] * ( -(q^{3n-2}+q^{3n-1}) Q_{n-1,c'}
                                + q^{3n-3} (1-q^{l(n-1)}) Q_{n-2,c'} ).

For l=1 (gcd(d,3)=1): prefactor = 1/(1+q^n+q^{2n}).

For n=2, l=1, with Q_0 = 1:
  Q_{2,c} = 1/(1+q^2+q^4) * sum_{c'} q^{2*EMD(c,c')} *
            [ q^3 * sum_J Q_{1,c'(J)}
              + [r3(c')] * ( -(q^4+q^5) Q_{1,c'} + q^3 (1-q) ) ].

Explicit DOUBLE SUM by inserting the Q_1 closed form
Q_{1,c} = 1/(1+q+q^2) sum_{c''} q^{EMD(c,c'')} B(c''),
B = q(2-q) [rank3], q [rank2], 0 [rank1]:

  Q_{2,c} = 1/((1+q^2+q^4)(1+q+q^2)) * sum_{c',c''} q^{2*EMD(c,c')} *
              [ q^3 sum_{J} q^{EMD(c'(J),c'')} - [r3(c')](q^4+q^5) q^{EMD(c',c'')} ] * B(c'')
            + 1/(1+q^2+q^4) * sum_{c': rank 3} q^{2*EMD(c,c') + 3} (1-q).

Denominator = Phi_3^2 * Phi_6 since 1+q^2+q^4 = (1+q+q^2)(1-q+q^2).

## Plan
1. VERIFY master recursion at n=2 (d=4,5,7, all profiles) and n=3 (d=4)
   against independent iterative solve of the CW linear system (Neumann
   iteration, no adjugate used). [script: seed7_R2L2_verify.sage]
2. Positivity experiments E1-E5 [script: seed7_R2L2_analyze.sage]:
   - E1: is BR_2(c') >= 0 per profile c'?
   - E2: is the numerator N_2(c) = sum_{c'} q^{2EMD} BR_2(c') >= 0?
   - E3: partial divisions: N_2/(1+q+q^2), N_2/(1-q+q^2) nonneg?
   - E4: profile monotonicity Q_{1,c'(J)} >= q^a Q_{1,c'} (a=1,2)?
   - E5: equidistribution structure at roots of 1+q^2+q^4.
3. If mechanism found, formulate general-n inductive step.

## Work log

### Step 1: Master recursion VERIFIED (GREEN)
Script `seed7_R2L2_verify.sage`. Independent Neumann-iteration solve of the CW
linear system (no adjugate used), PREC=300:
- d=4: master recursion matches for n=1,2,3, all 15 profiles.
- d=5: n=1,2, all 21 profiles. d=7: n=1,2, all 36 profiles.
- Fully-unfolded n=2 double sum matches at d=4,5,7 (all profiles).
- Sanity: Q_2(1) = 16, 36, 121 = ((d+1)(d+2)/6-1)^2 for d=4,5,7. Degrees 18,24,36.
Status: **GREEN** (derivation is pure algebra from GREEN inputs + exact match).

### Step 2: Positivity experiments (seed7_R2L2_analyze.sage)
- **E2 (KEY): N_2(c) := (1+q^2+q^4) Q_2(c) = sum_{c'} q^{2EMD(c,c')} BR_2(c')
  has NONNEG coefficients for ALL profiles, d=4,5,7 (72 profiles).**
  The numerator of the level-2 inversion is itself nonneg — a new intermediate
  positivity target strictly between Q_1 >= 0 and Q_2 >= 0.
- E3: division ladder. N_2/(1-q+q^2) = (1+q+q^2)Q_2 >= 0 everywhere;
  but N_2/(1+q+q^2) = (1-q+q^2)Q_2 has NEGATIVE coefficients for every profile.
  So positivity survives dividing by Phi_6 first, then Phi_3. Order matters.
- E1: BR_2(c') per-profile is NOT nonneg (fails exactly at rank-3 profiles);
  positivity of N_2 is a global EMD-weighted phenomenon.
- E4: profile monotonicity Q_1(c'(J)) >= q^a Q_1(c') FAILS (0/18 etc). Dead.
- E9: n=3, d=4: N_3(c) = (1+q^3+q^6) Q_3(c) >= 0 for all 15 profiles.
  (1+q^3+q^6 = Phi_9 irreducible, so no division ladder at n=3 — numerator
  positivity persists anyway.) CONJECTURE: N_n >= 0 for all n ("numerator
  positivity"), YELLOW.

### Step 3: Level-2 equidistribution -> scalar identity (E6)
Since EMD(c,c') mod 3 = delta(c') - delta(c) with delta(c) = (c_0-c_1) mod 3
(proved L1), the c-dependence at any root zeta of 1+q^{2}+q^{4} factors out:
  N_2(c)(zeta) = (zeta^2)^{-delta(c)} * S(zeta),
  S(zeta) = sum_{c'} (zeta^2)^{delta(c')} BR_2(c')(zeta).
Divisibility of ALL |profiles| numerators by 1+q^2+q^4 reduces to the single
scalar identity S(zeta) = 0 per root. VERIFIED S(om) = S(-om) = 0 for d=4,5,7.
(Divisibility itself already follows from Welsh polynomiality; the point is the
mechanism localizes to one global "charge conservation" identity — the correct
generalization of the level-1 EMD Equidistribution Theorem. Same argument works
verbatim at every level n: zeta^{n*EMD} = om_zeta^{EMD} with om_zeta = zeta^n a
primitive cube root.)

### Step 4: Regrouping by Q_1-argument; the weights W(c,c')
N_2(c) = sum_{c'} W(c,c') Q_1(c') + T(c), where (2-shift preimages of c':
  J=(0,1): c'' = c'+e0-e2; J=(1,2): c'' = c'-e0+e1; J=(0,2): c'' = c'-e1+e2)
  W(c,c') = q^3 sum_{preimages c'' of c'} q^{2EMD(c,c'')}
            - [rank3(c')] (q^4+q^5) q^{2EMD(c,c')}
  T(c) = sum_{rank3 c'} q^{2EMD(c,c')+3} (1-q).
Findings (seed7_R2L2_structure/pairwise.sage):
- sum_{c'} W(c,c') Q_1(c') >= 0 alone for all c (d=4,5,7). T's negatives are
  absorbed by it, but T alone is NOT nonneg.
- W(c,c') >= 0 fails for ~1/4 of pairs, BUT the failures have exactly TWO
  normalized shapes across all d: (2q-1)*q^a and (1-q^5+q^6)*q^a.

### Step 5: PREIMAGE EMD DICHOTOMY LEMMA (proved) — explains the rigidity
**Lemma.** Fix c. For any profile c' and each existing 2-shift preimage c'' of
c', Delta := EMD(c,c'') - EMD(c,c') is in {-2, +1}; and at most ONE of the
three preimages has Delta = -2. Moreover rank-3 c' has exactly 3 preimages,
rank-2 exactly 1, rank-1 none.

*Proof sketch (full proof in proofs/prove-seed7-layer2.tex).* Write u=c'_0-c_0,
v=c'_1-c_1, f(u,v) = 3 max(0,v,-u) + u - v = EMD(c,c'). The three preimages
move (u,v) by a=(1,0), b=(-1,1), c=(0,-1). Moves a,c change the linear part by
+1 and can drop the max by at most 1 (Delta in {1,-2}); move b changes the
linear part by -2 and can raise the max by at most 1 (Delta in {-2,1}).
Delta_a=-2 forces -u >= max(0,v)+1 (so u <= -1); Delta_b=-2 forces u >= 1 and
v <= -1; Delta_c=-2 forces v >= max(0,-u)+1 (so v >= 1). Pairwise contradictory. QED
Verified computationally: 0 violations, d in {4,5,7,8,10}, all pairs (c,c').

### Step 6: N_2 SHAPE THEOREM (proved, given the above)
Let e0 = EMD(c,c') and k = k(c,c') in {0,1} the number of closer preimages.
  N_2(c) = sum_{rank2 c'} q^{2 EMD(c,c'')+3} Q_1(c')          [c'' = unique preimage]
         + sum_{rank3 c', k=0} q^{2e0+4} (2q-1)   Q_1(c')
         + sum_{rank3 c', k=1} q^{2e0-1} (1-q^5+q^6) Q_1(c')
         + sum_{rank3 c'}      q^{2e0+3} (1-q).
ALL negativity in the level-2 numerator is compressed into exactly one negative
coefficient per rank-3 profile pair, in one of three rigid sandwich shapes
(2q-1), (1-q^5+q^6), (1-q). Verified against direct computation (shapes match
the observed failure list exactly).
Data on k: k=1 requires e0 >= 2; k=0 requires e0 <= (roughly) 2(d-1)/... —
observed: k=0 only for e0 <= max EMD/2 + O(1) band, k=1 from e0 >= 2 up.

### Stuck: [2026-07-04]
What I'm trying to show: the three sandwich shapes, summed over rank-3 c' with
weights q^{2e0} Q_1(c'), give a nonneg total (=> N_2 >= 0 proved), and that
division by (1+q^2+q^4) preserves positivity.
Why I can't show it: (i) same-c' pairing cannot work alone (shapes have their
negative coefficient adjacent to positives of the same profile, but Q_1(c')
coefficient smoothness is needed and Q_1 profile-monotonicity is false (E4));
(ii) division positivity by Phi_3 is exactly the still-unexplained level-1
mechanism (why Q_1 = N_1/Phi_3 >= 0), now needed again at level n.
What would unstick me: a "smoothness" lemma for Q_1 of the form
q*Q_1(c') <= sum over neighbouring profiles with smaller EMD ... i.e. a
DISCRETE HARNACK / subsolution inequality on profile space, or an Ehrhart-type
statement for the EMD-ball generating function sum_{rank3} q^{2EMD}.

## Assumptions Check
- EMD formula EMD(c,cp)=3max(0,cp1-c1,c0-cp0)+(cp0-c0)-(cp1-c1): TRUE
  (inherited GREEN from L1/Seed4; re-verified via adjugate match d=4,5,7).
- Master recursion algebra: TRUE (independent Neumann verification).
- Q_0 = 1 for all profiles: TRUE (G_c(0,q)=1).
- n=1 case of master recursion has no Q_{n-2} term (g_{c,-1}=0): TRUE
  (verified: reproduces Q_1 closed form).
- "b_n only sees J of size 2,3": TRUE for r=3 (|J|<=3, k=0 terms go to matrix).
- Preimage counts (3/1/0 by rank): PROVED (support check in dichotomy analysis).
- PRECISION: PREC=300 >= 6*3^2+200=254 rule satisfied; Q_n are polynomials of
  degree <= 36 here, far below truncation. No boundary-garbage risk.

## Handoff

### Best Results (this layer)
1. **Master Recursion (GREEN, proved + verified d=4,5,7 / n<=3):**
   Q_{n,c} = (1-q^{ln})/(1-q^{3n}) sum_{c'} q^{n EMD(c,c')} BR_n(c'),
   BR_n(c') = q^{2n-1} sum_{|J|=2} Q_{n-1,c'(J)}
              + [r3](-(q^{3n-2}+q^{3n-1}) Q_{n-1,c'} + q^{3n-3}(1-q^{l(n-1)}) Q_{n-2,c'}).
   This is the exact level-n inductive skeleton; unfolded n=2 double sum GREEN.
2. **Numerator Positivity Conjecture (NEW, YELLOW):** N_n := (1+q^n+q^{2n}) Q_n
   = sum_{c'} q^{n EMD} BR_n >= 0. Verified n=2 (d=4,5,7, all 72 profiles) and
   n=3 (d=4). Strictly weaker than manifest positivity; strictly stronger than
   nothing — Q_n >= 0 iff N_n/(1+q^n+q^{2n}) >= 0.
3. **Preimage EMD Dichotomy Lemma (GREEN, proved):** Delta in {-2,1}, at most
   one -2. Consequence: **N_2 Shape Theorem (GREEN)** — all negativity in N_2
   compressed into three rigid sandwich shapes (2q-1), (1-q^5+q^6), (1-q),
   one negative coefficient per rank-3 c'.
4. **Level-n equidistribution reduction (GREEN mechanism):** divisibility of
   N_n by 1+q^n+q^{2n} factors through ONE scalar identity per root because
   EMD mod 3 = delta(c')-delta(c) splits. Verified S(om)=S(-om)=0, d=4,5,7.
5. Division ladder (YELLOW): (1+q+q^2)Q_2 >= 0 and N_2 >= 0, but
   (1-q+q^2)Q_2 is NOT >= 0: positivity enters through the Phi_6 division
   first, Phi_3 last. The Phi_3 step is the same mystery as at level 1.

### What failed
- Profile monotonicity Q_1(c'(J)) >= q^a Q_1(c') : FALSE (all pairs fail).
- Per-profile BR_2 >= 0: FALSE at rank-3 profiles.
- Per-pair W(c,c')*Q_1(c') >= 0: FALSE (same failures as W).
- Parity pairing of the -q^{2e0+4} negatives: impossible without using
  Q_1's own coefficient spread (weights alone have wrong parity).

### Recommendation for Layer 3 / synthesis
- Attack **N_n >= 0** via the Shape Theorem: needed is a smoothing inequality
  of the form  sum_{rank3 c'} q^{2e0}(q Q_1(c') + q) <=
  sum_{rank3 c'} q^{2e0}(2q^2 or 1+q^6-avoiding) Q_1(c') + rank2 terms —
  concretely, an injection on the level-1 EMD path model shifting one unit of
  q-weight. Seed 4's extended-path involution machinery is the right tool:
  the target now has only ONE negative coefficient per profile (vs Round-1's
  arbitrary alternating sums). Combine with Seed 8's bracket monotonicity.
- The division-positivity step (Phi_3 last) should be attacked at level 1
  first: find WHY N_1/Phi_3 >= 0 (e.g. via the (1-q)/(1-q^3) lattice
  partial-sum criterion: sum_k a_{m-3k} >= sum_k a_{m-1-3k} for N_1's
  coefficients a). If that argument is found, it likely applies verbatim at
  level n with q -> q^n residue classes.
- Check whether N_n >= 0 for n=4,5 (d=4) before investing in a proof.

Scripts: scratch/scripts/seed7_R2L2_{verify,analyze,structure,pairwise,dichotomy}.sage
Proof write-up: proofs/prove-seed7-layer2.tex (master recursion + dichotomy + shape thm)
