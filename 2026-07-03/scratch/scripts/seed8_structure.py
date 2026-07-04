"""
Seed 8: Structural analysis of Q_1 and connections to plane partitions.

Key observations so far:
1. Q_n is positive for all computed cases (d=2,4,5,7,8)
2. Q_1 coefficients start with 2 and end with 1
3. Q_1 depends on the profile c, not just d
4. For d=2, Q_n = q^{n^2} (monomial!)

Let me explore:
- Whether Q_1 can be written as a sum over lattice paths or nonintersecting lattice paths
- The connection to lozenge tilings of a specific region
- Whether Q_n has a product/determinantal formula
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed8_iterative_CW import (
    solve_CW_system, compute_Q, poly_str, poly_add, poly_sub,
    poly_mul, poly_shift, poly_scale
)
from math import gcd

def q_binom(n, k, max_q=60):
    """Compute q-binomial coefficient [n choose k]_q."""
    if k < 0 or k > n:
        return {}
    if k == 0 or k == n:
        return {0: 1}
    # [n choose k] = [n-1 choose k-1] + q^k [n-1 choose k]
    # Or use: [n choose k] = prod_{i=0}^{k-1} (1 - q^{n-i}) / prod_{i=1}^k (1 - q^i)
    # As polynomial: (q;q)_n / ((q;q)_k * (q;q)_{n-k})
    num = {0: 1}
    for i in range(1, n+1):
        new = {}
        for p, c in num.items():
            if p <= max_q:
                new[p] = new.get(p, 0) + c
            if p+i <= max_q:
                new[p+i] = new.get(p+i, 0) - c
        num = {p: c for p, c in new.items() if c != 0}

    den = {0: 1}
    for i in range(1, k+1):
        new = {}
        for p, c in den.items():
            if p <= max_q:
                new[p] = new.get(p, 0) + c
            if p+i <= max_q:
                new[p+i] = new.get(p+i, 0) - c
        den = {p: c for p, c in new.items() if c != 0}
    for i in range(1, n-k+1):
        new = {}
        for p, c in den.items():
            if p <= max_q:
                new[p] = new.get(p, 0) + c
            if p+i <= max_q:
                new[p+i] = new.get(p+i, 0) - c
        den = {p: c for p, c in new.items() if c != 0}

    # Divide num by den (polynomial division)
    # Actually, let's just compute directly
    result = {0: 1}
    for i in range(k):
        # multiply by (1 - q^{n-i}) / (1 - q^{i+1})
        # = sum_{j>=0} q^{j(i+1)} - q^{n-i} * sum_{j>=0} q^{j(i+1)}
        step_val = i + 1
        new = {}
        for p, c in result.items():
            j = 0
            while p + j * step_val <= max_q:
                new[p + j * step_val] = new.get(p + j * step_val, 0) + c
                j += 1
        # Subtract q^{n-i} * new
        shifted = {p + (n-i): c for p, c in new.items() if p + (n-i) <= max_q}
        result = poly_sub(new, shifted)

    # Actually this is getting complicated. Let me use the recurrence.
    # [n choose k]_q = [n-1 choose k-1]_q + q^k * [n-1 choose k]_q
    # Build up iteratively.
    dp = {}
    for nn in range(n+1):
        for kk in range(min(nn, k)+1):
            if kk == 0 or kk == nn:
                dp[(nn, kk)] = {0: 1}
            else:
                # [nn choose kk] = [nn-1 choose kk-1] + q^kk * [nn-1 choose kk]
                a = dp.get((nn-1, kk-1), {})
                b = dp.get((nn-1, kk), {})
                b_shifted = poly_shift(b, kk, max_q)
                dp[(nn, kk)] = poly_add(a, b_shifted)

    return dp.get((n, k), {})


def try_qbinom_decomposition(Q1, d, profile):
    """Try to express Q_1 as a sum of q-binomial coefficients."""
    print(f"\n  Trying q-binomial decomposition of Q_1 for c={profile}, d={d}:")
    print(f"    Q_1 = {poly_str(Q1)}")

    max_q = 60

    # Try: Q_1 = sum of q^{a_i} * [n_i choose k_i]_q ?
    # First, list some q-binomials
    for n in range(1, 10):
        for k in range(1, n):
            qb = q_binom(n, k, max_q)
            if qb == Q1:
                print(f"    Q_1 = [{n} choose {k}]_q !")
                return

    # Try shifted q-binomials: Q_1 = q^s * [n choose k]_q
    for s in range(0, 10):
        remaining = {p-s: v for p, v in Q1.items() if p >= s}
        if not remaining:
            continue
        for n in range(1, 10):
            for k in range(1, n):
                qb = q_binom(n, k, max_q)
                if qb == remaining:
                    print(f"    Q_1 = q^{s} * [{n} choose {k}]_q !")
                    return

    # Try sum of two shifted q-binomials
    for s1 in range(0, 5):
        for n1 in range(1, 8):
            for k1 in range(1, n1):
                qb1 = q_binom(n1, k1, max_q)
                qb1_shifted = poly_shift(qb1, s1, max_q)
                rem = poly_sub(Q1, qb1_shifted)
                if not rem:
                    print(f"    Q_1 = q^{s1} * [{n1} choose {k1}]_q !")
                    return
                # Check if rem is a shifted q-binomial
                if all(v >= 0 for v in rem.values()):
                    min_r = min(rem.keys())
                    rem_shifted = {p - min_r: v for p, v in rem.items()}
                    for n2 in range(1, 8):
                        for k2 in range(1, n2):
                            qb2 = q_binom(n2, k2, max_q)
                            if qb2 == rem_shifted:
                                print(f"    Q_1 = q^{s1}*[{n1} choose {k1}]_q + q^{min_r}*[{n2} choose {k2}]_q !")
                                return

    print(f"    No simple q-binomial decomposition found")


def explore_lattice_paths(profile, Q_polys):
    """
    Key idea from seed context: plane partitions <-> lozenge tilings <-> nonintersecting lattice paths.

    For cylindric partitions, the cylinder has circumference t = k + d.
    A bounded cylindric partition (max <= n) corresponds to a periodic tiling
    of a cylinder with n layers.

    The Lindstrom-Gessel-Viennot lemma says:
    # of nonintersecting lattice paths = determinant of a path-count matrix.

    If Q_{n,c}(q) counts lattice paths, then it should be expressible as
    a determinant of q-binomials, which are manifestly positive.

    But... a determinant of positive things is not necessarily positive.
    Unless the lattice paths interpretation gives a SINGLE determinant
    that is manifestly positive (e.g., a product of q-binomials).
    """
    d = sum(profile)

    print(f"\n  Lattice path analysis for c={profile}, d={d}:")

    # For the simplest case d=2, Q_n = q^{n^2}.
    # n^2 = (sum_{i=1}^n (2i-1)) -- sum of first n odd numbers.
    # This is the area under a staircase lattice path.

    # For d=4:
    # Q_1 = 2q + q^2 + q^3.
    # These 4 objects have weights 1, 1, 2, 3.
    # Could they be lattice paths from (0,0) to some endpoint,
    # with weight = area under path?

    # In a 1x3 grid, paths from (0,0) to (3,1) with unit steps right/up:
    # RRRU (area 3), RRUR (area 2), RURR (area 1), URRR (area 0).
    # GF = 1 + q + q^2 + q^3 = [4 choose 1]_q. Sum = 4. But Q_1 = 2q + q^2 + q^3.

    # Paths from (0,0) to (2,2) in a 2x2 grid:
    # RRUU (area 4), RURU (area 3), RUUR (area 2), URRU (area 2), URUR (area 1), UURR (area 0).
    # GF = 1 + q + 2q^2 + q^3 + q^4 = [4 choose 2]_q. Sum = 6. No match.

    # What about weighted paths on the cylinder of circumference t = k+d = 7?
    # The periodicity of the cylinder suggests paths wrapping around with period t.

    if 1 in Q_polys:
        Q1 = Q_polys[1]
        expected = (d+1)*(d+2)//6 - 1
        print(f"    Q_1(1) = {expected}")
        print(f"    Observation: (d+1)(d+2)/6 = C(d+2,2)/3")
        print(f"    For d not div by 3, C(d+2,2)/3 = {(d+1)*(d+2)//6}")
        print(f"    This equals the number of orbits of C_3 acting on")
        print(f"    pairs {{i,j}} from {{1,...,d+2}} by rotation mod 3.")
        print(f"    Minus 1 for the 'trivial' orbit?")

    # The -1 in (d+1)(d+2)/6 - 1 is interesting.
    # It removes exactly one state. Which one?
    # For the Andrews-Gordon identity context, there are (d+1)(d+2)/6 terms,
    # and the -1 might correspond to the (zq)_inf factor removing the
    # "unrestricted" contribution.


# Run analysis for several profiles
profiles = [
    ((2, 1, 1), 4, 3, 50),
    ((2, 2, 1), 5, 3, 60),
    ((3, 2, 2), 7, 2, 60),
    ((3, 3, 2), 8, 2, 60),
]

for profile, d, max_n, max_q in profiles:
    if d % 3 == 0:
        continue
    k = 3
    b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)
    Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)

    try_qbinom_decomposition(Q_polys.get(1, {}), d, profile)
    explore_lattice_paths(profile, Q_polys)


# Key structural insight to explore:
# For d=2: Q_n = q^{n^2}. This is the GF for a single "object" of weight n^2.
# The weight n^2 = n * (n+1)/2 + n*(n-1)/2 = T_n + T_{n-1} where T_n = n(n+1)/2.
# Or n^2 = sum_{i=0}^{n-1} (2i+1).
#
# For d=4: Q_1 = 2q + q^2 + q^3. Let's see if Q_n factors.
# Q_1 = q(2 + q + q^2) = q(1 + 1 + q + q^2) = q(1 + [3]_q)
# [3]_q = 1 + q + q^2, so Q_1 = q + q*[3]_q = q + q*(q^3-1)/(q-1)
# Hmm, let me think differently.
#
# Q_1 at q=1 gives 4 = expected_base.
# (d+1)(d+2)/6 - 1 = 5 - 1 = 4 for d=4.
# 5 = C(4+2,2)/3 = C(6,2)/3 = 15/3 = 5. So there are 5 "orbits" of some kind.
#
# The formula (d+1)(d+2)/6 is exactly the number of partitions lambda = (a, b)
# with a >= b >= 0 and a + b <= d. Let's verify:
# d=2: (a,b) with a+b <= 2: (0,0), (1,0), (1,1), (2,0). That's 4, not 2.
# Hmm, (d+1)(d+2)/6 for d=2 is 2, not 4.

print("\n\n--- Partition counting ---")
for d in [2, 4, 5, 7, 8]:
    # Count partitions (a,b) with a >= b >= 0 and a + b <= d
    count = sum(1 for a in range(d+1) for b in range(a+1) if a + b <= d)
    formula = (d+1)*(d+2)//6
    print(f"  d={d}: partitions with a>=b>=0, a+b<=d: {count}, formula gives {formula}")
    # Count partitions (a,b,c) with a >= b >= c >= 0 and a+b+c <= d ... no

    # The number of dominant weights for sl_3 at level d:
    # These are (a,b) with a,b >= 0 and a+b <= d.
    count2 = sum(1 for a in range(d+1) for b in range(d-a+1))
    print(f"  d={d}: sl_3 dom weights at level d: {count2} = C(d+2,2) = {(d+1)*(d+2)//2}")

    # So (d+1)(d+2)/6 = C(d+2,2)/3 = |dominant weights| / 3.
    # The /3 suggests a Z/3Z symmetry.
    # For sl_3, the Weyl group is S_3, but the relevant symmetry for cylindric
    # partitions with k=3 is C_3 (cyclic shift of the profile).

    # The A_2 Weyl group S_3 has order 6, and the /6 in the formula
    # = /(2*3) might be C(d+2,2) / |S_3|.

    # At level d, the dominant weights for sl_3 form a triangle of size d.
    # C(d+2,2) / 6 = T_{d+1} / 6 where T_n = n(n+1)/2.
    # For d not div by 3: no weight is fixed by C_3, so all C_3-orbits
    # have size 3. Hence |orbits| = C(d+2,2)/3.
    # But (d+1)(d+2)/6 = C(d+2,2)/3 only when (d+1)(d+2)/6 is integer,
    # which requires 6 | (d+1)(d+2). Since two consecutive integers,
    # one is even, so 2 | (d+1)(d+2). We need 3 | (d+1)(d+2), which
    # means d != 1 mod 3. For d not div by 3, d in {1,2,4,5,7,8,...}.
    # d=1: 2*3/6 = 1. d=2: 3*4/6 = 2. OK.
    # But d=1 mod 3: 3 | (d+1)? d=1: d+1=2, no. d=4: d+1=5, no but d+2=6 yes.
    # d=7: d+1=8, d+2=9, 9/3=3 yes.
    # Actually for d not div by 3: either d ≡ 1 or d ≡ 2 mod 3.
    # d ≡ 1: d+2 ≡ 0 mod 3. d ≡ 2: d+1 ≡ 0 mod 3. Either way 3 | (d+1)(d+2).

