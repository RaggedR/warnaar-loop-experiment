"""
Seed 8: Nonintersecting lattice paths perspective.

Key insight from the seed context: plane partitions <-> lozenge tilings <-> 
nonintersecting lattice paths (Lindstrom-Gessel-Viennot).

For cylindric partitions of profile c = (c_0, c_1, c_2) with k=3:
- The cylinder has circumference t = 3 + d where d = c_0 + c_1 + c_2.
- A cylindric partition is a periodic plane partition on the cylinder.
- Bounded cylindric partitions (max <= n) correspond to tilings of a
  finite region of the cylinder.

The Gessel-Viennot lemma says:
  # of nonintersecting lattice path families = det(path count matrix)

For cylindric partitions, this becomes a CYLINDRIC version of GV,
which involves not a determinant but a sum over permutations with
signs — leading to the inclusion-exclusion in the Corteel-Welsh recurrence.

The positivity question: why does the alternating sum
  Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
produce nonneg coefficients?

From the lattice path perspective, this is asking:
- F_c(z,q) counts cylindric lattice paths (with cylindric boundary conditions)
- (zq;q)_inf is a "sieve" removing some paths
- The product extracts certain path configurations
- The claim is that the net count is always nonneg

The (zq;q)_inf factor is the key to positivity. It equals
  prod_{j>=1} (1 - zq^j) = sum_m (-z)^m q^{m(m+1)/2} / (q;q)_m

This is related to Euler's pentagonal number theorem:
  prod_{j>=1} (1-q^j) = sum_{k} (-1)^k q^{k(3k-1)/2}

The connection: (zq;q)_inf at z=1 gives (q;q)_inf (Euler's function).

From the plane partition perspective: (1-zq^j) removes one row of
height j from the boundary. The product over j removes all possible
top rows. This is an involution/cancellation principle!

IDEA: Maybe Q_{n,c}(q) counts lattice paths that avoid the top boundary
of the cylinder? Or plane partitions in a specific region that are
"frozen" at the top?

Let me think about this differently. The formula is:
  [z^n]((zq;q)_inf * F_c(z,q)) 
  = sum_{m+j=n} (-1)^m q^{m(m+1)/2}/(q;q)_m * [z^j] F_c(z,q)
  = sum_{m+j=n} (-1)^m q^{m(m+1)/2}/(q;q)_m * b_j(q)

where b_j(q) = [z^j] F_c(z,q) = sum_{Lambda: max=j} q^{|Lambda|}.

This is an "Euler convolution" of the b_j sequence. The question is
why (q;q)_n times this Euler convolution is nonneg.

OBSERVATION from data:
  For d=2: Q_n = q^{n^2}. This is a SINGLE monomial.
  For d=4: Q_1 = 2q + q^2 + q^3. Not a monomial.
  For d=5: Q_1 = 2q + 2q^2 + q^3 + q^4.

The minimum degree of Q_n grows roughly like n * (something).
For d=4: Q_0 has degree 0, Q_1 has min degree 1, Q_2 has min degree 3, Q_3 has min degree 7.
Differences: 1, 2, 4. Hmm: 1, 2, 4 = 2^0, 2^1, 2^2? Or: 1, 1+1, 1+1+2?

For d=5: Q_0 has degree 0, Q_1 min degree 1, Q_2 min degree 3, Q_3 min degree 7.
Same pattern? Let me check.

For d=7: Q_0 has degree 0, Q_1 min degree 1, Q_2 min degree 3.
Same start.

So the minimum degree of Q_n seems to follow a pattern independent of d.
This suggests a structural formula for the leading term.

Let me compute: what is the minimum degree of Q_n?
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed8_iterative_CW import solve_CW_system, compute_Q
from math import gcd

profiles = [
    ((1, 1, 0), 2),
    ((2, 1, 1), 4),
    ((2, 2, 1), 5),
    ((3, 2, 2), 7),
    ((3, 3, 2), 8),
]

print("Minimum and maximum degrees of Q_n:")
print("=" * 70)

for profile, d in profiles:
    if d % 3 == 0: continue
    k = 3
    max_n = 4 if d <= 5 else 2
    max_q = 60

    b, B = solve_CW_system(profile, k, max_n, max_q)
    Q = compute_Q(b, profile, max_n, max_q)

    print(f"\nc = {profile}, d = {d}:")
    min_degs = []
    max_degs = []
    for n in range(max_n + 1):
        Qn = Q.get(n, {})
        if Qn:
            mn = min(Qn.keys())
            mx = max(Qn.keys())
            min_degs.append(mn)
            max_degs.append(mx)
            print(f"  Q_{n}: degree [{mn}, {mx}], width = {mx - mn + 1}, #terms = {len(Qn)}")
        else:
            min_degs.append(0)
            max_degs.append(0)
            print(f"  Q_{n}: 0")

    # Check if min_deg(Q_n) = T_n = n(n+1)/2 or n^2 or similar
    print(f"  Min degrees: {min_degs}")
    print(f"  Max degrees: {max_degs}")
    for formula_name, formula in [
        ("n^2", lambda n: n*n),
        ("n(n+1)/2", lambda n: n*(n+1)//2),
        ("n(2n-1)/3", lambda n: n*(2*n-1)//3 if n*(2*n-1) % 3 == 0 else -1),
        (f"n*(d-1)/2 + n*(n-1)/2", lambda n: n*(d-1)//2 + n*(n-1)//2 if n*(d-1) % 2 == 0 else -1),
    ]:
        predicted = [formula(n) for n in range(max_n+1)]
        if predicted[:len(min_degs)] == min_degs[:len(predicted)]:
            print(f"  Min degree matches: {formula_name}")

    # Leading coefficient (coefficient of q^{min_deg})
    print(f"  Leading coefficients: {[Q[n].get(min_degs[n], 0) for n in range(max_n+1)]}")

    # Check multiplicativity: is Q_n related to Q_1 in a nice way?
    if max_n >= 2 and 1 in Q and Q[1]:
        Q1 = Q[1]
        Q1_at_1 = sum(Q1.values())
        print(f"\n  Q_1(1) = {Q1_at_1}")
        print(f"  Q_1 coeffs: {sorted(Q1.items())}")

        # Is Q_n related to symmetric functions of "eigenvalues" of Q_1?
        # If Q_n = h_n(x_1,...,x_m) where x_i are q-powers,
        # then Q_1 = e_1 = sum x_i and Q_n = h_n or e_n or p_n.

