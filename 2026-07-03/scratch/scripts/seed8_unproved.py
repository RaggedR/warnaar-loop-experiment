"""
Seed 8: Focus on unproved cases d=7, d=8 and structure analysis.
"""
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed8_iterative_CW import (
    solve_CW_system, compute_Q, poly_str, poly_add, poly_sub,
    poly_mul, poly_shift, poly_scale
)
from math import gcd

def analyze(profile, max_n=3, max_q=60):
    d = sum(profile)
    k = len(profile)
    ell = gcd(d, k)
    expected_base = (d+1)*(d+2)//6 - 1

    print(f"\n{'='*70}")
    print(f"Profile c = {profile}, d = {d}, ell = {ell}")
    print(f"Expected Q(1) = {expected_base}^n")
    print(f"{'='*70}")

    b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)
    Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)

    for n in range(max_n + 1):
        Q = Q_polys.get(n, {})
        q1 = sum(Q.values())
        neg = [(p, v) for p, v in sorted(Q.items()) if v < 0]
        all_pos = len(neg) == 0

        terms = sorted(Q.items())
        coeffs = [v for _, v in terms]
        min_d = min(Q.keys()) if Q else 0
        max_d = max(Q.keys()) if Q else 0

        print(f"\n  Q_{{{n}}}(q):")
        print(f"    Coefficients: {coeffs}")
        print(f"    Degrees: [{min_d}, {max_d}]")
        print(f"    Q(1) = {q1}, expected = {expected_base**n}, match = {q1 == expected_base**n}")
        print(f"    Nonneg: {all_pos}")
        if not all_pos:
            print(f"    NEGATIVE: {neg}")

        # Properties
        if len(coeffs) > 1:
            shifted = [Q.get(i, 0) for i in range(min_d, max_d + 1)]
            is_palindrome = shifted == shifted[::-1]
            print(f"    Palindromic: {is_palindrome}")

    return Q_polys


# d=4
print("PROVED CASE d=4")
Q4 = analyze((2, 1, 1), max_n=3, max_q=50)

# d=5
print("\nPROVED CASE d=5")
Q5 = analyze((2, 2, 1), max_n=3, max_q=60)

# d=7
print("\nUNPROVED CASE d=7")
Q7 = analyze((3, 2, 2), max_n=2, max_q=60)

# d=8
print("\nUNPROVED CASE d=8")
Q8 = analyze((3, 3, 2), max_n=2, max_q=60)

# Try another d=7 profile
print("\nUNPROVED CASE d=7, different profile")
Q7b = analyze((4, 2, 1), max_n=2, max_q=60)

# Structural analysis
print("\n\n" + "="*70)
print("STRUCTURAL ANALYSIS")
print("="*70)

print("\nQ_1 polynomials comparison:")
for label, d_val, Q in [("d=4", 4, Q4), ("d=5", 5, Q5), ("d=7 (3,2,2)", 7, Q7), ("d=7 (4,2,1)", 7, Q7b), ("d=8", 8, Q8)]:
    Q1 = Q.get(1, {})
    terms = sorted(Q1.items())
    coeffs = [v for _, v in terms]
    min_d = min(Q1.keys()) if Q1 else 0
    max_d = max(Q1.keys()) if Q1 else 0
    q1 = sum(Q1.values())
    shifted = [Q1.get(i, 0) for i in range(min_d, max_d + 1)]
    print(f"  {label}: Q_1 = {poly_str(Q1)}")
    print(f"    coeffs = {shifted}, sum = {q1}")

