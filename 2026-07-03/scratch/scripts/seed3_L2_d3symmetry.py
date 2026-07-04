"""
Seed 3, Layer 2: D_3 symmetry from the skew RSK perspective.

The synthesis established Q_{n,c} has D_3 symmetry (invariant under
cyclic permutation AND reversal of profile c).

Can the skew RSK perspective explain this naturally?

A cylindric partition of profile c = (c0, c1, c2) lives on a cylinder
of circumference t = 3 + d. The profile c determines the "staircase"
of the skew shape on the cylinder.

Cyclic permutation: (c0, c1, c2) -> (c1, c2, c0) rotates the cylinder
by (1 + c1) positions. This is a symmetry of the cylinder.

Reversal: (c0, c1, c2) -> (c2, c1, c0) reflects the cylinder.
In the skew RSK picture, this corresponds to transposing the skew tableaux.

The key question: does the [z^n] extraction commute with these symmetries?
If so, D_3 symmetry of Q_{n,c} follows immediately.
"""

from collections import defaultdict
from math import gcd
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, compute_Q, poly_to_list


def verify_d3_symmetry_extensive():
    """Verify D_3 symmetry for many profiles and multiple n values."""
    q_max = 80
    
    for d in [2, 4, 5, 7, 8]:
        if d % 3 == 0:
            continue
        
        print(f"\nd = {d}")
        
        # Generate all D_3 orbits of profiles
        profiles = [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
        
        seen = set()
        orbit_data = []
        for c in profiles:
            c0, c1, c2 = c
            perms = {(c0,c1,c2),(c1,c2,c0),(c2,c0,c1),
                     (c2,c1,c0),(c0,c2,c1),(c1,c0,c2)}
            canon = min(perms)
            if canon not in seen:
                seen.add(canon)
                orbit = sorted(perms & set(profiles))
                orbit_data.append((canon, orbit))
        
        for canon, orbit in orbit_data:
            # Only check profiles we can compute (max entry <= 2)
            computable = [c for c in orbit if max(c) <= 2]
            if len(computable) < 2:
                continue
            
            results = {}
            for c in computable:
                try:
                    for n in [1, 2]:
                        Q = compute_Q(c, n, q_max)
                        coeffs = poly_to_list(Q)
                        while coeffs and coeffs[-1] == 0:
                            coeffs.pop()
                        results[(c, n)] = tuple(coeffs)
                except:
                    pass
            
            # Check all pairs agree
            for n in [1, 2]:
                vals = set()
                for c in computable:
                    if (c, n) in results:
                        vals.add(results[(c, n)])
                
                if len(vals) > 1:
                    print(f"  BROKEN D_3 for orbit of {canon}, n={n}!")
                    for c in computable:
                        if (c, n) in results:
                            print(f"    {c}: {results[(c,n)][:10]}")
                elif len(vals) == 1:
                    pass  # OK
            
            # Report
            q1_vals = set(results.get((c, 1)) for c in computable if (c, 1) in results)
            if len(q1_vals) == 1:
                v = list(q1_vals)[0]
                print(f"  D_3 orbit of {canon} (size {len(orbit)}): "
                      f"Q_1 = {v[:10]}... OK")


def investigate_cyclic_mechanism():
    """
    Understand WHY cyclic permutation preserves Q_{n,c}.
    
    Cyclic: (c0, c1, c2) -> (c1, c2, c0).
    
    In terms of cylindric partitions:
    Lambda = (lam0, lam1, lam2) with interlacing from profile (c0, c1, c2)
    maps to Lambda' = (lam1, lam2, lam0) with interlacing from (c1, c2, c0).
    
    The interlacing conditions are:
    Original: lam0_j >= lam1_{j+c1}, lam1_j >= lam2_{j+c2}, lam2_j >= lam0_{j+c0}
    Cycled:   lam1_j >= lam2_{j+c2}, lam2_j >= lam0_{j+c0}, lam0_j >= lam1_{j+c1}
    
    These are IDENTICAL conditions! Just reordered.
    
    Weight: |lam0| + |lam1| + |lam2| = |lam1| + |lam2| + |lam0|. Same.
    Max entry: max of all parts = same.
    
    So cyclic permutation is trivially a bijection that preserves weight AND max.
    Therefore F_{c,N}(q) = F_{cyc(c),N}(q), and hence Q_{n,c} = Q_{n,cyc(c)}.
    
    This is completely trivial from the cylindric partition perspective.
    """
    print("=" * 70)
    print("Cyclic symmetry mechanism")
    print("=" * 70)
    print("\nCyclic permutation (c0,c1,c2) -> (c1,c2,c0) corresponds to")
    print("relabeling tracks: (lam0,lam1,lam2) -> (lam1,lam2,lam0).")
    print("This is a bijection preserving weight and max entry.")
    print("Therefore F_{c,N} = F_{cyc(c),N} for all N, hence Q_{n,c} = Q_{n,cyc(c)}.")
    print("\nThis is TRIVIAL. No deep structure needed.")


def investigate_reversal_mechanism():
    """
    Understand WHY reversal (c0,c1,c2) -> (c2,c1,c0) preserves Q_{n,c}.
    
    This is LESS obvious. Under reversal:
    
    Original profile (c0, c1, c2):
      lam0_j >= lam1_{j+c1}
      lam1_j >= lam2_{j+c2}
      lam2_j >= lam0_{j+c0}
    
    Reversed profile (c2, c1, c0):
      mu0_j >= mu1_{j+c1}
      mu1_j >= mu2_{j+c0}
      mu2_j >= mu0_{j+c2}
    
    Can we define mu0, mu1, mu2 from lam0, lam1, lam2?
    
    Try: mu0 = lam0, mu1 = lam2, mu2 = lam1
    Then:
      mu0_j >= mu1_{j+c1}: lam0_j >= lam2_{j+c1}
      mu1_j >= mu2_{j+c0}: lam2_j >= lam1_{j+c0}
      mu2_j >= mu0_{j+c2}: lam1_j >= lam0_{j+c2}
    
    But original says:
      lam0_j >= lam1_{j+c1}
      lam1_j >= lam2_{j+c2}
      lam2_j >= lam0_{j+c0}
    
    With our substitution we need:
      lam0_j >= lam2_{j+c1}  (need this)
      lam2_j >= lam1_{j+c0}  (need this)
      lam1_j >= lam0_{j+c2}  (need this)
    
    These are NOT the same conditions. So simple relabeling doesn't work.
    
    Alternative: conjugation/transposition of all partitions.
    If lam^i has parts lam^i_1 >= lam^i_2 >= ..., its conjugate (lam^i)'
    has (lam^i)'_j = #{k : lam^i_k >= j}.
    
    Under conjugation, the interlacing conditions transform in a specific way.
    
    For the cylindric partition:
      lam0_j >= lam1_{j+c1} for all j
    
    In terms of conjugates: (lam0)'_a >= j iff lam0_j >= a.
    The condition lam0_j >= lam1_{j+c1} means: for all a, 
    if lam1_{j+c1} >= a then lam0_j >= a, i.e.,
    (lam0)'_a >= j whenever (lam1)'_a >= j + c1, i.e.,
    (lam0)'_a >= (lam1)'_a - c1.
    
    So: (lam0)'_a - (lam1)'_a >= -c1, i.e., (lam0)'_a + c1 >= (lam1)'_a.
    
    This gives: (lam1)'_a <= (lam0)'_a + c1 for all a.
    
    The original conditions in conjugate form:
      (lam1)' <= (lam0)' + c1  (componentwise)
      (lam2)' <= (lam1)' + c2
      (lam0)' <= (lam2)' + c0  (wrap-around)
    
    Hmm, these are "reverse interlacing" — the conjugate partitions satisfy
    UPPER bound conditions instead of LOWER bound conditions.
    
    Now define mu_i = (lam_{k-1-i})' (reverse order AND conjugate).
    For k=3: mu0 = (lam2)', mu1 = (lam1)', mu2 = (lam0)'.
    
    Then:
      mu0 = (lam2)', mu1 = (lam1)', mu2 = (lam0)'
    
    We need: mu0_j >= mu1_{j+c1} for the reversed profile (c2,c1,c0):
    Actually, reversed profile is (c2, c1, c0), so the conditions are:
      mu0_j >= mu1_{j+c1}  : (lam2)'_j >= (lam1)'_{j+c1}
      mu1_j >= mu2_{j+c0}  : (lam1)'_j >= (lam0)'_{j+c0}
      mu2_j >= mu0_{j+c2}  : (lam0)'_j >= (lam2)'_{j+c2}
    
    From the conjugate conditions above:
      (lam1)'_a <= (lam0)'_a + c1  =>  (lam1)'_{j+c1} <= (lam0)'_{j+c1} + c1
    
    Hmm, this doesn't directly give what we need. The relationship is more subtle.
    
    Let me think about this differently. Maybe reversal symmetry is a 
    CONSEQUENCE of the specific form of Q_{n,c}, not of F_{c,N}.
    """
    
    print("\n" + "=" * 70)
    print("Reversal symmetry mechanism")
    print("=" * 70)
    
    # Check: is F_{c,N}(q) invariant under reversal?
    # Or only Q_{n,c}(q)?
    q_max = 40
    
    for d in [4, 5]:
        if d % 3 == 0:
            continue
        
        # Find a non-palindromic profile
        c_orig = (2, 1, 1) if d == 4 else (2, 2, 1)
        c_rev = (c_orig[2], c_orig[1], c_orig[0])
        
        print(f"\nd = {d}: c = {c_orig}, rev(c) = {c_rev}")
        
        for N in range(4):
            F_orig = compute_F_transfer(c_orig, N, q_max)
            F_rev = compute_F_transfer(c_rev, N, q_max)
            
            f_orig = poly_to_list(F_orig)
            f_rev = poly_to_list(F_rev)
            
            while f_orig and f_orig[-1] == 0: f_orig.pop()
            while f_rev and f_rev[-1] == 0: f_rev.pop()
            
            match = f_orig == f_rev
            print(f"  N={N}: F match? {match}")
            if not match and len(f_orig) < 20:
                print(f"    F_orig = {f_orig}")
                print(f"    F_rev  = {f_rev}")
        
        # Check Q_n
        for n in range(1, 4):
            Q_orig = compute_Q(c_orig, n, q_max)
            Q_rev = compute_Q(c_rev, n, q_max)
            
            q_orig = poly_to_list(Q_orig)
            q_rev = poly_to_list(Q_rev)
            
            while q_orig and q_orig[-1] == 0: q_orig.pop()
            while q_rev and q_rev[-1] == 0: q_rev.pop()
            
            match = q_orig == q_rev
            print(f"  Q_{n}: match? {match}")
            if not match:
                print(f"    Q_orig = {q_orig[:15]}")
                print(f"    Q_rev  = {q_rev[:15]}")


def investigate_conjugation_bijection():
    """
    Test whether conjugation provides the reversal bijection.
    
    For cylindric partitions with max entry <= N:
    Lambda = (lam0, lam1, lam2) has max entry N means max(lam^i_1) <= N.
    Each lam^i has at most N parts in the conjugate.
    
    If we conjugate all partitions: lam^i -> (lam^i)'
    The max entry N becomes: max part length <= N
    But max((lam^i)') = number of parts of lam^i, not max entry.
    
    Actually: if lam has max entry N, then lam' has at most N parts (rows).
    And if lam has L parts, then lam' has max entry L.
    
    So conjugation swaps "max entry" and "number of parts" — but cylindric 
    partitions can have arbitrarily many parts, so this is tricky.
    """
    print("\n" + "=" * 70)
    print("Conjugation and reversal: detailed analysis")
    print("=" * 70)
    
    # Enumerate CPs with max <= N for both c and rev(c)
    # and check if conjugation provides a bijection
    
    c_orig = (2, 1, 1)
    c_rev = (1, 1, 2)
    N = 1
    max_w = 8
    
    def enum_cps(c, N, max_w):
        """Simple enumerator for cylindric partitions with max <= N."""
        c0, c1, c2 = c
        results = []
        
        def valid_column(a, b, cv):
            if c0 == 0 and cv < a: return False
            if c1 == 0 and a < b: return False
            if c2 == 0 and b < cv: return False
            return True
        
        def check_adjacent(prev, next_col, c):
            pa, pb, pcv = prev
            na, nb, ncv = next_col
            if na > pa or nb > pb or ncv > pcv: return False
            if c[1] >= 1 and pa < nb: return False
            if c[2] >= 1 and pb < ncv: return False
            if c[0] >= 1 and pcv < na: return False
            return True
        
        def gen(cols, w):
            if w > max_w:
                return
            results.append((tuple(cols), w))
            if cols:
                prev = cols[-1]
            else:
                prev = (N, N, N)
            
            for a in range(prev[0], -1, -1):
                for b in range(prev[1], -1, -1):
                    for cv in range(prev[2], -1, -1):
                        if a == 0 and b == 0 and cv == 0:
                            continue
                        if not valid_column(a, b, cv):
                            continue
                        col = (a, b, cv)
                        if cols and not check_adjacent(cols[-1], col, c):
                            continue
                        new_w = w + a + b + cv
                        if new_w > max_w:
                            continue
                        cols.append(col)
                        gen(cols, new_w)
                        cols.pop()
        
        gen([], 0)
        return results
    
    cps_orig = enum_cps(c_orig, N, max_w)
    cps_rev = enum_cps(c_rev, N, max_w)
    
    # Count by weight
    from collections import Counter
    count_orig = Counter(w for _, w in cps_orig)
    count_rev = Counter(w for _, w in cps_rev)
    
    print(f"\nc = {c_orig}, rev = {c_rev}, N = {N}")
    print(f"  F_{{c,{N}}} by weight: {dict(sorted(count_orig.items()))}")
    print(f"  F_{{rev,{N}}} by weight: {dict(sorted(count_rev.items()))}")
    
    match = True
    for w in range(max_w + 1):
        if count_orig.get(w, 0) != count_rev.get(w, 0):
            print(f"  DIFFER at weight {w}: {count_orig.get(w,0)} vs {count_rev.get(w,0)}")
            match = False
    
    if match:
        print(f"  F_{{{c_orig},{N}}} = F_{{{c_rev},{N}}} — reversal preserves F!")
    else:
        print(f"  F_{{{c_orig},{N}}} != F_{{{c_rev},{N}}} — reversal does NOT preserve F")
        print("  This means reversal symmetry of Q is NON-TRIVIAL")
        print("  It arises from the alternating sum, not from F individually!")


if __name__ == "__main__":
    investigate_cyclic_mechanism()
    investigate_reversal_mechanism()
    investigate_conjugation_bijection()
    verify_d3_symmetry_extensive()
