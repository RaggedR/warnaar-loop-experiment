"""
Seed 2, Layer 1: Test q-log-concavity of F_{c,N}(q).

If F_{c,N}^2 - F_{c,N-1} * F_{c,N+1} has all nonneg coefficients,
the sequence is q-log-concave, which is a necessary condition for
total positivity and would support the proof strategy.
"""

from collections import defaultdict
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed2_d4d5 import QPoly, compute_FcN_transfer


def test_q_log_concavity(c, N_max, q_max):
    """Check if F_{c,N}^2 >= F_{c,N-1}*F_{c,N+1} coefficientwise."""
    d = sum(c)
    print(f"\nProfile c={c}, d={d}")
    
    FcN = []
    for N in range(N_max + 1):
        F = compute_FcN_transfer(c, N, q_max)
        FcN.append(F)
        print(f"  F_{{c,{N}}}(1) = {F.eval_at_1()}")
    
    print(f"\n  q-Log-concavity check: F_N^2 - F_{{N-1}} * F_{{N+1}} >= 0?")
    for N in range(1, N_max):
        F_sq = FcN[N] * FcN[N]
        F_prod = FcN[N-1] * FcN[N+1]
        
        diff = QPoly.zero(q_max)
        for k, v in F_sq.coeffs.items():
            diff.coeffs[k] += v
        for k, v in F_prod.coeffs.items():
            diff.coeffs[k] -= v
        
        nonneg = all(v >= 0 for v in diff.coeffs.values())
        diff_list = diff.to_list()
        
        # Find any negative coefficients
        neg = {k: v for k, v in diff.coeffs.items() if v < 0}
        
        print(f"  N={N}: F_{N}^2 - F_{{N-1}}*F_{{N+1}} nonneg? {nonneg}")
        if not nonneg:
            print(f"    Negative coefficients: {dict(sorted(neg.items())[:10])}")
        else:
            # Show first few coefficients of the difference
            print(f"    First 15 coeffs: {diff_list[:15]}")


def main():
    q_max = 80
    
    # d=2 case
    test_q_log_concavity((1, 1, 0), 4, q_max)
    
    # d=4 case
    test_q_log_concavity((2, 1, 1), 3, q_max)
    
    # d=5 case
    test_q_log_concavity((2, 2, 1), 3, q_max)


if __name__ == "__main__":
    main()
