"""
Seed 3, Layer 2: Understanding reversal symmetry at the CP level.

FINDING: F_{c,N} = F_{rev(c),N}. This means reversal is a bijection 
on cylindric partitions themselves, not just on Q_n.

Why? The reversal (c0,c1,c2) -> (c2,c1,c0) can be understood as
reversing the direction of traversal around the cylinder.

A cylindric partition of profile c = (c0,c1,c2):
  lam0_j >= lam1_{j+c1}   (0 -> 1 interlacing)
  lam1_j >= lam2_{j+c2}   (1 -> 2 interlacing)
  lam2_j >= lam0_{j+c0}   (2 -> 0 interlacing, wrap)

Under reversal with the map (lam0, lam1, lam2) -> (lam2, lam1, lam0):
  mu0 = lam2, mu1 = lam1, mu2 = lam0
  
  mu0_j >= mu1_{j+c1}: lam2_j >= lam1_{j+c1}   (A)
  mu1_j >= mu2_{j+c0}: lam1_j >= lam0_{j+c0}   (B)
  mu2_j >= mu0_{j+c2}: lam0_j >= lam2_{j+c2}   (C)

Original:
  lam0_j >= lam1_{j+c1}   (I)
  lam1_j >= lam2_{j+c2}   (II)
  lam2_j >= lam0_{j+c0}   (III)

(B) is: lam1_j >= lam0_{j+c0}. Compare with (I): lam0_j >= lam1_{j+c1}.
These are NOT the same.

Wait — but F_{c,N} = F_{rev(c),N} computationally. So there must be a 
bijection, but not the naive relabeling. Let me think more carefully.
"""

from collections import defaultdict
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, poly_to_list


def enum_cps(c, N, max_w):
    """Enumerate cylindric partitions of profile c with max <= N."""
    c0, c1, c2 = c
    results = []

    def valid_column(a, b, cv):
        if c0 == 0 and cv < a: return False
        if c1 == 0 and a < b: return False
        if c2 == 0 and b < cv: return False
        return True

    def gen(cols, w):
        if w > max_w:
            return
        results.append((tuple(tuple(col) for col in cols), w))
        prev = cols[-1] if cols else (N, N, N)
        for a in range(prev[0], -1, -1):
            for b in range(prev[1], -1, -1):
                for cv in range(prev[2], -1, -1):
                    if a == 0 and b == 0 and cv == 0:
                        continue
                    if not valid_column(a, b, cv):
                        continue
                    col = (a, b, cv)
                    # Decreasing columns
                    if a > prev[0] or b > prev[1] or cv > prev[2]:
                        continue
                    # Interlacing with shift: for adjacent columns
                    if len(cols) >= 1:
                        # Check c1 = 1 shift: prev a >= next b (at distance c1=1)
                        if c1 == 1 and cols[-1][0] < b:
                            continue
                        if c2 == 1 and cols[-1][1] < cv:
                            continue
                        if c0 == 1 and cols[-1][2] < a:
                            continue
                    if len(cols) >= 2:
                        if c1 == 2 and cols[-2][0] < b:
                            continue
                        if c2 == 2 and cols[-2][1] < cv:
                            continue
                        if c0 == 2 and cols[-2][2] < a:
                            continue
                    new_w = w + a + b + cv
                    if new_w > max_w:
                        continue
                    cols.append(col)
                    gen(cols, new_w)
                    cols.pop()

    gen([], 0)
    return results


def find_reversal_bijection():
    """
    Try to find the explicit bijection between CPs of profile c and rev(c).
    
    One natural candidate: column-reverse each partition.
    If Lambda = (lam0, lam1, lam2) with columns col_1, col_2, ..., col_L
    where col_j = (lam0_j, lam1_j, lam2_j), then the column-reversed CP
    has col_j' = col_{L+1-j}. But this doesn't preserve the profile.
    
    Another candidate: swap row ordering.
    Lambda = (lam0, lam1, lam2) -> (lam2, lam1, lam0), but we already
    showed this doesn't directly satisfy the reversed profile constraints.
    
    The RIGHT bijection likely involves a more subtle rearrangement.
    Let me look at it from the cylinder perspective.
    """
    
    c_orig = (1, 1, 0)  # Simple case first
    c_rev = (0, 1, 1)
    N = 2
    max_w = 6
    
    cps_orig = enum_cps(c_orig, N, max_w)
    cps_rev = enum_cps(c_rev, N, max_w)
    
    # Group by weight
    by_weight_orig = defaultdict(list)
    by_weight_rev = defaultdict(list)
    for cols, w in cps_orig:
        by_weight_orig[w].append(cols)
    for cols, w in cps_rev:
        by_weight_rev[w].append(cols)
    
    print(f"c = {c_orig}, rev = {c_rev}, N = {N}")
    
    for w in sorted(set(list(by_weight_orig.keys()) + list(by_weight_rev.keys()))):
        n_orig = len(by_weight_orig.get(w, []))
        n_rev = len(by_weight_rev.get(w, []))
        print(f"\n  Weight {w}: {n_orig} orig, {n_rev} rev")
        
        if n_orig > 0 and n_orig <= 8:
            for cols in sorted(by_weight_orig[w]):
                lam0 = tuple(col[0] for col in cols) if cols else ()
                lam1 = tuple(col[1] for col in cols) if cols else ()
                lam2 = tuple(col[2] for col in cols) if cols else ()
                print(f"    orig: ({lam0}, {lam1}, {lam2})")
        
        if n_rev > 0 and n_rev <= 8:
            for cols in sorted(by_weight_rev[w]):
                lam0 = tuple(col[0] for col in cols) if cols else ()
                lam1 = tuple(col[1] for col in cols) if cols else ()
                lam2 = tuple(col[2] for col in cols) if cols else ()
                print(f"    rev:  ({lam0}, {lam1}, {lam2})")


def find_reversal_bijection_2():
    """
    For c=(1,1,0) vs c=(0,1,1):
    
    Profile (1,1,0):
      lam0_j >= lam1_{j+1}  (shift by c1=1)
      lam1_j >= lam2_j       (shift by c2=0)
      lam2_j >= lam0_{j+1}  (shift by c0=1)
    
    Profile (0,1,1):
      mu0_j >= mu1_{j+1}    (shift by c1=1)
      mu1_j >= mu2_{j+1}    (shift by c2=1)
      mu2_j >= mu0_j        (shift by c0=0)
    
    Try the map: mu0 = lam0, mu1 = lam2, mu2 = lam1
    Then:
      mu0_j >= mu1_{j+1}: lam0_j >= lam2_{j+1}  (*)
      mu1_j >= mu2_{j+1}: lam2_j >= lam1_{j+1}  (**)
      mu2_j >= mu0_j:     lam1_j >= lam0_j       (***)
    
    From original:
      lam0_j >= lam1_{j+1}  implies lam0_j >= lam1_{j+1} >= lam2_{j+1} 
                              (using lam1_j >= lam2_j, so lam1_{j+1} >= lam2_{j+1})
    So (*) follows from (I) and lam1 >= lam2 (which is (II)).
    
    (**): lam2_j >= lam1_{j+1}? From (III): lam2_j >= lam0_{j+1}.
    And from (I): lam0_{j+1} >= lam1_{j+2}. So lam2_j >= lam1_{j+2}, not lam1_{j+1}.
    Hmm, not enough.
    
    Actually, the map can't just be a relabeling — it would need to
    also transform the partitions themselves (perhaps conjugation or some
    other operation).
    
    Let me try a completely different approach: numerical search.
    """
    
    c_orig = (1, 1, 0)
    c_rev = (0, 1, 1)
    N = 1
    max_w = 4
    
    cps_orig = enum_cps(c_orig, N, max_w)
    cps_rev = enum_cps(c_rev, N, max_w)
    
    print(f"\nc = {c_orig}, rev = {c_rev}, N = {N}")
    print(f"\nOriginal CPs:")
    for cols, w in sorted(cps_orig, key=lambda x: (x[1], x[0])):
        lam0 = tuple(col[0] for col in cols) if cols else ()
        lam1 = tuple(col[1] for col in cols) if cols else ()
        lam2 = tuple(col[2] for col in cols) if cols else ()
        print(f"  w={w}: ({lam0}, {lam1}, {lam2})")
    
    print(f"\nReversed CPs:")
    for cols, w in sorted(cps_rev, key=lambda x: (x[1], x[0])):
        lam0 = tuple(col[0] for col in cols) if cols else ()
        lam1 = tuple(col[1] for col in cols) if cols else ()
        lam2 = tuple(col[2] for col in cols) if cols else ()
        print(f"  w={w}: ({lam0}, {lam1}, {lam2})")


def test_conjugation_reversal():
    """
    Test whether the reversal bijection is:
    (lam0, lam1, lam2) of profile (c0,c1,c2) 
    -> (lam0', lam2', lam1') of profile (c0,c2,c1) = reversed
    
    Wait: rev(c0,c1,c2) = (c2,c1,c0), not (c0,c2,c1).
    
    Hmm. Let me think about this from the cylinder perspective.
    
    The cylinder has t = 3 + d circumference. The 3 partitions sit at
    positions 0, 1+c1, 1+c1+1+c2 = 2+c1+c2 on the cylinder (with wrap).
    
    Actually, the positions are:
      Track 0: position 0
      Track 1: position 1 + c1... no, let me re-read the definition.
    
    The definition says: profile (c0,...,c_{k-1}) with k partitions.
    Interlacing: lam^i_j >= lam^{i+1}_{j+c_{i+1}} for i = 0,...,k-2
    and lam^{k-1}_j >= lam^0_{j+c_0} (wrap).
    
    So the "staircase step" between track i and track i+1 is c_{i+1}.
    
    For c = (c0, c1, c2):
      0->1: step c1
      1->2: step c2  
      2->0: step c0 (wrap)
    
    Reversal c -> (c2, c1, c0):
      0->1: step c1
      1->2: step c0
      2->0: step c2
    
    So the steps going clockwise change from (c1, c2, c0) to (c1, c0, c2).
    This is (c1, c2, c0) -> (c1, c0, c2) = swap c0 and c2 in the step sequence.
    
    Interestingly, if we relabel 0->0, 1->1, 2->2 but "reverse" the 
    direction around the cylinder... going counterclockwise the steps are
    (c0, c2, c1) from track 0. Hmm.
    
    Actually, I think the key insight is simpler. Let me check:
    does F_{(c0,c1,c2),N} = F_{(c0,c2,c1),N}? That's reversal of c1,c2 only.
    """
    
    q_max = 30
    
    # Test various non-trivial rearrangements
    c = (2, 1, 1)
    perms = [
        (2, 1, 1),  # original
        (1, 1, 2),  # rev = (c2, c1, c0)
        (2, 1, 1),  # (c0, c1, c2) = original
        (1, 2, 1),  # cyclic
    ]
    
    print(f"\nF_{{c,2}} for all rearrangements of c = (2,1,1):")
    for c in sorted(set(perms)):
        F = compute_F_transfer(c, 2, q_max)
        f_list = poly_to_list(F)[:15]
        print(f"  c = {c}: F = {f_list}")
    
    # Add all 6 permutations
    from itertools import permutations
    all_perms = set(permutations([2, 1, 1]))
    print(f"\nAll permutations of (2,1,1):")
    for c in sorted(all_perms):
        F = compute_F_transfer(c, 2, q_max)
        f_list = poly_to_list(F)[:15]
        print(f"  c = {c}: F = {f_list}")


if __name__ == "__main__":
    find_reversal_bijection()
    find_reversal_bijection_2()
    test_conjugation_reversal()
