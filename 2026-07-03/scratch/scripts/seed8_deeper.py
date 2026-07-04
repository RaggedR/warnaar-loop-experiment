"""
Seed 8: Deeper analysis of Q_{n,c}(q).
1. Test d=7 (unproved case)
2. Look at Q as sum of q-binomials or other manifestly positive objects
3. Examine the connection to plane partitions / lozenge tilings
"""

# Import the working computation from seed8_iterative_CW
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed8_iterative_CW import (
    solve_CW_system, compute_Q, poly_str, poly_add, poly_sub,
    poly_mul, poly_shift, poly_scale, enumerate_profiles
)
from math import gcd


def analyze_profile(profile, max_n=3, max_q=50):
    d = sum(profile)
    k = len(profile)
    ell = gcd(d, k)
    expected_base = (d+1)*(d+2)//6 - 1

    print(f"\n{'='*70}")
    print(f"Profile c = {profile}, d = {d}, ell = {ell}")
    print(f"Expected Q(1) = {expected_base}^n")
    print(f"t = k + d = {k + d}")
    print(f"{'='*70}")

    b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)
    Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)

    for n in range(max_n + 1):
        Q = Q_polys.get(n, {})
        q1 = sum(Q.values())
        neg = [(k, v) for k, v in sorted(Q.items()) if v < 0]
        all_pos = len(neg) == 0

        print(f"\n  Q_{{{n}}}(q):")
        # Print full polynomial
        terms = sorted(Q.items())
        coeffs_list = [v for _, v in terms]
        print(f"    Coefficients: {coeffs_list}")
        print(f"    Degree range: {min(Q.keys()) if Q else 0} to {max(Q.keys()) if Q else 0}")
        print(f"    Q(1) = {q1}, expected = {expected_base**n}, match = {q1 == expected_base**n}")
        print(f"    Nonneg: {all_pos}")
        if not all_pos:
            print(f"    NEGATIVE: {neg}")

        # Check if Q is a single q-power (i.e., monomial)
        nonzero = [(k,v) for k,v in Q.items() if v != 0]
        if len(nonzero) == 1:
            e, c = nonzero[0]
            print(f"    MONOMIAL: {c}*q^{e}")

        # Check if Q_n = Q_1^n in some sense
        if n >= 2 and 1 in Q_polys and Q_polys[1]:
            Q1 = Q_polys[1]
            # Compute Q1^n
            power = {0: 1}
            for _ in range(n):
                power = poly_mul(power, Q1, max_q)
            if power == Q:
                print(f"    Q_{n} = Q_1^{n}  !!!")
            else:
                print(f"    Q_{n} != Q_1^{n}")

    return Q_polys


def check_qbinomial_expansion(Q, n, expected_base, max_q):
    """
    Try to express Q_{n,c}(q) as a sum of q-binomial coefficients or
    products of q-numbers.

    Key idea from plane partitions: MacMahon's formula for plane partitions
    in a box gives products of q-numbers. If Q_{n,c} counts some kind of
    bounded plane partition, it should have such a form.
    """
    # For d=4, Q_1 = 2q + q^2 + q^3. Let's see if this is [3]_q + q^3 or similar.
    # [m]_q = 1 + q + ... + q^{m-1} = (1-q^m)/(1-q)
    # [3]_q = 1 + q + q^2
    # 2q + q^2 + q^3 = q(2 + q + q^2) ... not a standard q-number.
    # q(1 + q + q^2) + q = q[3]_q + q
    # Hmm.

    # Actually for d=4, Q_1 = 2q + q^2 + q^3
    # At q=1: 2+1+1 = 4 = expected_base. Good.

    # Let me try: Q_1 = q * (q^2 + q + 2) = q * (q^2 + q + 1 + 1) = q([3]_q + 1)
    # [3]_q + 1 = [3]_q + [1]_q ... but that's 1+q+q^2+1 = 2+q+q^2. Close but coefficients don't match.

    # Actually 2q + q^2 + q^3 = q + q + q^2 + q^3 = q + q(1 + q + q^2) = q + q[3]_q
    # = q(1 + [3]_q). At q=1: 1*(1+3) = 4. Yes!

    # Hmm but 1 + [3]_q = 1 + 1 + q + q^2 = 2 + q + q^2.
    # q(2 + q + q^2) = 2q + q^2 + q^3. Yes!

    pass


def plane_partition_connection(profile, Q_polys, max_n):
    """
    Explore whether Q_{n,c}(q) can be interpreted as a plane partition count.

    For a box of size a x b x m, the GF is prod_{i,j} (1-q^{i+j+m-1})/(1-q^{i+j-1}).

    For the shifted staircase, it's prod_{1<=i<=j<=n} (m+i+j-1)/(i+j-1).

    Can Q_{n,c}(q) be a q-analogue of any such count?
    """
    d = sum(profile)
    expected_base = (d+1)*(d+2)//6 - 1

    print(f"\n--- Plane Partition Connection Analysis ---")
    print(f"Q(1) = {expected_base}^n")

    # For d=4: expected_base = 4.
    # 4 = number of something. What?
    # MacMahon: PP^m(a x b) at m=1 is just (a+b choose a) = # of binary sequences.
    # PP^1(2x2) = (4 choose 2) = 6. No.
    # 4 = PP^1(1x3) = (4 choose 1) = 4? No, (4 choose 1) = 4. Yes!
    # So Q_{1,(2,1,1)}(1) = 4 = number of plane partitions in 1x3 box with max 1.
    # These are just {0,1}^3 weakly decreasing: (0,0,0), (1,0,0), (1,1,0), (1,1,1).
    # That's 4. So Q_1(1) = 4 = PP^1(1x3).

    # For d=5: expected_base = 6.
    # 6 = PP^1(2x2) = (4 choose 2) = 6. Interesting!
    # Or PP^1(1x5) = 6. Hmm, PP^1(1x5) = (6 choose 1) = 6.

    # General: (d+1)(d+2)/6 - 1.
    # For d=2: (3)(4)/6 - 1 = 2 - 1 = 1.
    # For d=4: (5)(6)/6 - 1 = 5 - 1 = 4.
    # For d=5: (6)(7)/6 - 1 = 7 - 1 = 6.
    # For d=7: (8)(9)/6 - 1 = 12 - 1 = 11.
    # For d=8: (9)(10)/6 - 1 = 15 - 1 = 14.

    # (d+1)(d+2)/6 = C(d+2, 2)/3 for d+2 choose 2. This is the number of
    # triangular partitions or something...

    # Actually (d+1)(d+2)/6 = binomial(d+2, 2)/3. Hmm.
    # For d=2: 6/6 = 1.
    # For d=4: 15/3 = 5.
    # Wait, (d+1)(d+2)/6 = (d+1)(d+2)/6.
    # d=2: 12/6 = 2. Then 2-1 = 1.
    # d=4: 30/6 = 5. Then 5-1 = 4.
    # d=5: 42/6 = 7. Then 7-1 = 6.
    # d=7: 72/6 = 12. Then 12-1 = 11.

    # The base (d+1)(d+2)/6 - 1 counts something related to A_2 representation theory.
    # (d+1)(d+2)/6 is the number of partitions fitting in a "d/2" shaped region...
    # Actually (d+1)(d+2)/2 = C(d+2,2) = triangular number = # of monomials x^a y^b with a+b <= d+1.
    # And /3 gives... hmm.

    # More relevantly: for the A_2 Andrews-Gordon identity with modulus t = d+3,
    # there are (d+1)(d+2)/6 terms (for d not div by 3). The -1 might subtract the
    # trivial contribution.

    # Let me focus on the q-analogue structure instead.

    print(f"\n  Expected base = (d+1)(d+2)/6 - 1 = {expected_base}")
    print(f"  (d+1)(d+2)/6 = {(d+1)*(d+2)//6}")

    # Check: is Q_{1,c}(q) a single q-binomial?
    if 1 in Q_polys:
        Q1 = Q_polys[1]
        print(f"\n  Q_1 = {poly_str(Q1)}")
        print(f"  Q_1 coefficients: {sorted(Q1.items())}")

        # Is Q_1 unimodal? symmetric?
        if Q1:
            min_deg = min(Q1.keys())
            max_deg = max(Q1.keys())
            coeffs = [Q1.get(i, 0) for i in range(min_deg, max_deg + 1)]
            is_unimodal = all(coeffs[i] <= coeffs[i+1] for i in range(len(coeffs)//2))
            print(f"  Degree range: [{min_deg}, {max_deg}]")
            print(f"  Shifted coefficients: {coeffs}")

            # Check palindrome (symmetric)
            is_palindrome = coeffs == coeffs[::-1]
            print(f"  Palindromic: {is_palindrome}")
            print(f"  Unimodal: {is_unimodal}")

    if 2 in Q_polys and 1 in Q_polys:
        Q1 = Q_polys[1]
        Q2 = Q_polys[2]
        Q1_sq = poly_mul(Q1, Q1, max_q)
        diff = poly_sub(Q2, Q1_sq)
        print(f"\n  Q_2 - Q_1^2 = {poly_str(diff)}")


# Main analysis
print("SEED 8 ANALYSIS: Plane Partition / Lozenge Tiling Perspective")
print("=" * 70)

# d=2 (trivial: Q_n = q^{n^2})
Q2 = analyze_profile((1, 1, 0), max_n=4, max_q=40)

# d=4 (proved by Warnaar)
Q4 = analyze_profile((2, 1, 1), max_n=3, max_q=50)
plane_partition_connection((2, 1, 1), Q4, 3)

# d=5 (proved by Warnaar)
Q5 = analyze_profile((2, 2, 1), max_n=3, max_q=60)
plane_partition_connection((2, 2, 1), Q5, 3)

# d=7 (UNPROVED!)
print("\n\n" + "!"*70)
print("TESTING UNPROVED CASE: d = 7")
print("!"*70)
Q7 = analyze_profile((3, 2, 2), max_n=2, max_q=60)
plane_partition_connection((3, 2, 2), Q7, 2)

# d=8 (UNPROVED!)
print("\n\n" + "!"*70)
print("TESTING UNPROVED CASE: d = 8")
print("!"*70)
Q8 = analyze_profile((3, 3, 2), max_n=2, max_q=60)
plane_partition_connection((3, 3, 2), Q8, 2)

