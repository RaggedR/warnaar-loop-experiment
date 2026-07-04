"""
Seed 3, Layer 2: Investigating bijection between bounded cylindric 
partitions and crystal/tableaux objects.

Key questions:
1. Can bounded CPs be mapped to pairs of skew tableaux?
2. Does the Upsilon bijection (skew RSK dynamics) help?
3. What does the z^n extraction look like in the bijected world?
"""

from collections import defaultdict
from math import gcd
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, compute_Q, poly_to_list


def enumerate_cylindric_partitions(c, N, max_weight):
    """
    Enumerate all cylindric partitions of profile c with max entry <= N
    and total weight <= max_weight.
    
    A cylindric partition of profile c=(c0,c1,c2) is a triple of partitions
    (lam0, lam1, lam2) satisfying:
      lam0_j >= lam1_{j+c1} for all j >= 1
      lam1_j >= lam2_{j+c2} for all j >= 1
      lam2_j >= lam0_{j+c0} for all j >= 1 (wrap-around)
    with max entry <= N and all lam^i are ordinary partitions (weakly decreasing).
    
    Returns list of (lam0, lam1, lam2, weight).
    """
    results = []
    
    # We enumerate column by column, building up the partition
    # A partition with max entry N can have at most max_weight/1 = max_weight columns
    # but practically far fewer
    
    # For simplicity, use a recursive approach
    # A column (a, b, cv) at position j must satisfy:
    #   a, b, cv in {0, ..., N}
    #   a >= a_{j+1}, b >= b_{j+1}, cv >= cv_{j+1} (weakly decreasing)
    #   Interlacing: depends on c and position
    
    # For profiles with small c_i, this is manageable.
    # Let's do it for small cases.
    
    def valid_column(a, b, cv, c):
        """Check within-column constraints from zero c_i."""
        c0, c1, c2 = c
        if c0 == 0 and cv < a: return False
        if c1 == 0 and a < b: return False  
        if c2 == 0 and b < cv: return False
        return True
    
    def check_interlacing(cols, c):
        """Check all interlacing constraints for a list of columns."""
        c0, c1, c2 = c
        L = len(cols)
        for j in range(L):
            a_j, b_j, cv_j = cols[j]
            # lam0_j >= lam1_{j+c1}: a at col j >= b at col j+c1
            if j + c1 < L:
                if a_j < cols[j + c1][1]:
                    return False
            # lam1_j >= lam2_{j+c2}: b at col j >= cv at col j+c2
            if j + c2 < L:
                if b_j < cols[j + c2][2]:
                    return False
            # lam2_j >= lam0_{j+c0}: cv at col j >= a at col j+c0
            if j + c0 < L:
                if cv_j < cols[j + c0][0]:
                    return False
        return True
    
    def gen_columns(cols, weight_so_far, c, N, max_w):
        """Recursively generate valid column sequences."""
        # Check interlacing of current columns
        if not check_interlacing(cols, c):
            return
        
        if weight_so_far > max_w:
            return
        
        # Record this partition (cols may be complete)
        results.append((list(cols), weight_so_far))
        
        # Try to add another column
        if cols:
            prev = cols[-1]
            pa, pb, pcv = prev
        else:
            pa, pb, pcv = N, N, N
        
        # Next column must be componentwise <= prev and nonzero
        for a in range(pa, -1, -1):
            for b in range(pb, -1, -1):
                for cv in range(pcv, -1, -1):
                    if a == 0 and b == 0 and cv == 0:
                        continue  # skip zero column (end of partition)
                    if not valid_column(a, b, cv, c):
                        continue
                    w = a + b + cv
                    if weight_so_far + w > max_w:
                        continue
                    cols.append((a, b, cv))
                    gen_columns(cols, weight_so_far + w, c, N, max_w)
                    cols.pop()
    
    # Start with empty partition
    results = []
    gen_columns([], 0, c, N, max_weight)
    
    return results


def count_by_weight(partitions, max_w):
    """Count partitions by weight."""
    counts = defaultdict(int)
    for cols, w in partitions:
        counts[w] += 1
    return counts


def main():
    print("=" * 70)
    print("Enumerating cylindric partitions for small cases")
    print("=" * 70)
    
    c = (1, 1, 0)
    max_w = 15
    
    for N in range(0, 4):
        parts = enumerate_cylindric_partitions(c, N, max_w)
        counts = count_by_weight(parts, max_w)
        F_computed = compute_F_transfer(c, N, max_w)
        
        print(f"\nc = {c}, N = {N}")
        print(f"  Enumerated: {dict(sorted(counts.items()))}")
        print(f"  Transfer:   {dict(sorted(F_computed.items()))}")
        
        # Check agreement
        ok = True
        for k in range(max_w + 1):
            if counts.get(k, 0) != F_computed.get(k, 0):
                print(f"  MISMATCH at q^{k}: enum={counts.get(k,0)}, transfer={F_computed.get(k,0)}")
                ok = False
        if ok:
            print(f"  MATCH up to q^{max_w}")
    
    print("\n" + "=" * 70)
    print("Examining structure of small cylindric partitions")
    print("=" * 70)
    
    c = (1, 1, 0)
    N = 2
    max_w = 10
    parts = enumerate_cylindric_partitions(c, N, max_w)
    
    print(f"\nc = {c}, N = {N}, max_weight = {max_w}")
    print(f"Total partitions: {len(parts)}")
    
    # Show them grouped by weight
    by_weight = defaultdict(list)
    for cols, w in parts:
        by_weight[w].append(cols)
    
    for w in sorted(by_weight.keys())[:8]:
        print(f"\n  Weight {w} ({len(by_weight[w])} partitions):")
        for cols in sorted(by_weight[w])[:5]:
            # Display as triples of partitions
            if cols:
                max_len = max(len(cols), 1)
                lam0 = tuple(col[0] for col in cols)
                lam1 = tuple(col[1] for col in cols)
                lam2 = tuple(col[2] for col in cols)
                print(f"    ({lam0}, {lam1}, {lam2})")
            else:
                print(f"    (empty)")
    
    print("\n" + "=" * 70)
    print("Q_n as signed sum: what cancels?")
    print("=" * 70)
    
    c = (1, 1, 0)
    max_w = 15
    n = 2
    
    print(f"\nc = {c}, n = {n}")
    print(f"Q_n = sum_j (-1)^j q^(j(j-1)/2) * R_j * F_{{c,n-j}}")
    
    for j in range(n + 1):
        N = n - j
        F = compute_F_transfer(c, N, max_w)
        shift = j * (j - 1) // 2
        
        # R_j = (q;q)_n / (q;q)_j = prod_{i=j+1}^n (1-q^i)
        R = {0: 1}
        for i in range(j + 1, n + 1):
            new_R = {}
            for deg, coeff in R.items():
                new_R[deg] = new_R.get(deg, 0) + coeff
                if deg + i <= max_w:
                    new_R[deg + i] = new_R.get(deg + i, 0) - coeff
            R = {k: v for k, v in new_R.items() if v != 0}
        
        # Compute term = (-1)^j * q^shift * R * F
        term = defaultdict(int)
        for d1, c1 in R.items():
            for d2, c2 in F.items():
                dt = d1 + d2 + shift
                if dt <= max_w:
                    term[dt] += ((-1)**j) * c1 * c2
        
        term_list = [term.get(i, 0) for i in range(max_w + 1)]
        F_list = poly_to_list(F)
        R_list = [R.get(i, 0) for i in range(max(R.keys()) + 1)] if R else [0]
        
        print(f"\n  j={j}: sign=(-1)^{j}, shift=q^{shift}")
        print(f"    R_{j} = {R_list}")
        print(f"    F_{{c,{N}}} first terms = {F_list[:10]}")
        print(f"    Contribution = {term_list[:max_w+1]}")
    
    Q = compute_Q(c, n, max_w)
    Q_list = poly_to_list(Q)
    print(f"\n  Q_{n} = {Q_list}")


    print("\n" + "=" * 70)
    print("Cylindric partitions as skew tableaux: exploring the map")
    print("=" * 70)
    
    # A cylindric partition Lambda = (lam0, lam1, lam2) of profile (c0, c1, c2)
    # can be viewed as a periodic skew plane partition on a cylinder.
    # 
    # The cylinder has circumference t = 3 + d where d = c0 + c1 + c2.
    # Each "row" of the cylinder corresponds to one of the 3 partitions.
    # 
    # The skew shape between consecutive partitions is determined by the
    # interlacing: lam^i >= shift(lam^{i+1}).
    # 
    # For c = (1,1,0), d = 2, t = 5:
    # Row 0: lam0 (shift c1 = 1 to get interlacing with lam1)
    # Row 1: lam1 (shift c2 = 0 to get interlacing with lam2)
    # Row 2: lam2 (shift c0 = 1 to get interlacing with lam0)
    #
    # The interlacing lam0_j >= lam1_{j+1} means lam0 dominates shift(lam1).
    # So lam0/shift(lam1) is a horizontal strip.
    # Similarly lam1 >= lam2 (c2=0 means same positions).
    # And lam2_j >= lam0_{j+1} (wrap-around).
    
    print("\nFor c=(1,1,0), the interlacing pattern is:")
    print("  lam0_j >= lam1_{j+1} (horizontal strip lam0/shift(lam1))")
    print("  lam1_j >= lam2_j     (lam1 dominates lam2)")
    print("  lam2_j >= lam0_{j+1} (horizontal strip lam2/shift(lam0))")
    
    print("\nKey observation: lam2 >= shift(lam0) and lam0 >= shift(lam1)")
    print("Together: lam2 >= shift(lam0) >= shift^2(lam1) >= shift^2(lam2)")
    print("So lam2_j >= lam2_{j+2} for all j (lam2 dominates its own 2-shift)")
    
    # For max entry N: each lam^i has parts at most N.
    # The total weight is |lam0| + |lam1| + |lam2|.
    
    # Can we encode (lam0, lam1, lam2) with max <= N as a pair of
    # semi-standard skew tableaux?
    
    # The Sagan-Stanley correspondence maps a weighted permutation
    # on the cylinder to a pair of skew tableaux. Cylindric partitions
    # are essentially "periodic skew plane partitions" — a special case.
    
    # For a cylindric partition with k=3 parts and profile (c0,c1,c2),
    # the cylinder has t = 3 + d "rows" (or columns, depending on convention).
    # Each entry of the cylindric partition contributes to the q-weight.
    
    # The Imamura Upsilon bijection maps:
    #   (P, Q) in SST(lambda/rho, n) x SST(lambda/rho, n)
    #     -> (V, W; kappa, nu)
    # where V, W are vertically strict tableaux.
    
    # The question is: can we construct (P, Q) from a cylindric partition
    # such that the weight is preserved and the z^n extraction corresponds
    # to restricting to a particular set of (V, W)?
    
    print("\n\nConsider the Sagan-Stanley map for cylindric partitions:")
    print("A cylindric partition Lambda with max entry N determines a")
    print("weighted biword on the cylinder Z/tZ.")
    print("")
    print("The key insight from Imamura: the skew RSK dynamics on this")
    print("biword eventually reaches a stable state, producing (V, W).")
    print("The q-weight is preserved throughout the dynamics.")
    print("")
    print("QUESTION: Does 'max entry <= N' translate to a clean condition")
    print("on (V, W)? If so, [z^N] F_c(z,q) counts (V,W) pairs in a")
    print("specific subset, and Q_n might decompose as a sum over crystal")
    print("components of this subset.")
    

if __name__ == "__main__":
    main()
