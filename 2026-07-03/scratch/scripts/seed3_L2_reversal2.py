"""
Check reversal vs cyclic more carefully.
Use profiles where D_3 orbit has size 6 (not just 3).
"""

from collections import defaultdict
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, poly_to_list


def main():
    q_max = 30
    
    # For d=5, profile (0,2,3) has 6 distinct permutations:
    # cyc: (0,2,3), (2,3,0), (3,0,2)
    # rev: (3,2,0), (0,3,2), (2,0,3)
    # These should give 2 distinct D_3 orbits if reversal doesn't preserve F.
    # Or all the same if full S_3 = D_3 preserves F.
    
    print("Testing whether F is invariant under ALL permutations or just D_3:")
    
    for d in [5, 7]:
        if d % 3 == 0:
            continue
        print(f"\nd = {d}")
        
        # Find a profile where the D_3 orbit has size 6
        # (i.e., all 3 components are distinct)
        profiles = [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
        
        for c in profiles:
            c0, c1, c2 = c
            if len(set([c0,c1,c2])) < 3:
                continue  # need all distinct
            if max(c) > 2:
                continue  # need to be computable
            
            # All 6 permutations
            from itertools import permutations
            all_perms = sorted(set(permutations(c)))
            
            print(f"\n  Profile {c}, all permutations:")
            results = {}
            for p in all_perms:
                F = compute_F_transfer(p, 2, q_max)
                f_list = poly_to_list(F)[:12]
                results[p] = tuple(f_list)
                print(f"    {p}: F = {f_list}")
            
            unique_vals = set(results.values())
            if len(unique_vals) == 1:
                print(f"    ALL SAME (full S_3 symmetry)")
            else:
                print(f"    {len(unique_vals)} distinct values")
                # Group
                for v in unique_vals:
                    members = [p for p in all_perms if results[p] == v]
                    print(f"      {v[:8]}...: {members}")
            
            break  # one example per d
    
    # For d=7, we can use (2,2,3) which has all distinct if we consider
    # that (2,2,3) has c0=c1. Let me find one with all distinct.
    # d=7: try (1,2,4) — all distinct but c2=4 > 2, can't compute.
    # d=7: can't do all-distinct with max(c) <= 2.
    
    print("\n\nNow checking with larger profiles (via transfer matrix v4):")
    from seed3_transfer_v4 import compute_F_transfer as compute_F_v4
    
    # Use (0,2,3) for d=5 — has a zero
    c = (0, 2, 3)
    d = 5
    print(f"\nd={d}, c={c}")
    
    # Can only compute max(c) <= 2 profiles with current code.
    # (0,2,3) has max=3. Need the v4 code for window=2 at most.
    # Actually v4 supports window=2, and max(0,2,3) = 3 needs window=3.
    # So we can't compute this.
    
    # Let's check d=8 with c=(0,2,6) — nope, too big.
    
    # Actually for (1,1,0) vs (0,1,1): these are NOT related by cyclic permutation.
    # cyc of (1,1,0) = (1,0,1) and (0,1,1).
    # rev of (1,1,0) = (0,1,1).
    # So (1,1,0) and (0,1,1) ARE related by BOTH cyclic AND reversal.
    
    # For D_3 to be "more" than cyclic, we need a profile where 
    # reversal gives something NOT in the cyclic orbit.
    # That happens when the D_3 orbit has size 6.
    # Which needs all c_i distinct.
    
    # For d=5: (0,1,4), (1,4,0), (4,0,1) are the cyclic orbit.
    # (4,1,0), (0,4,1), (1,0,4) are the reversal orbit.
    # Are these the same? (0,4,1) is in the cyclic orbit of (4,1,0).
    # cyc(4,1,0) = (1,0,4), cyc^2(4,1,0) = (0,4,1).
    # So the full D_3 orbit is {(0,1,4),(1,4,0),(4,0,1),(4,1,0),(1,0,4),(0,4,1)}.
    # This has size 6. And (0,1,4) and (4,1,0) are NOT cyclically equivalent.
    
    # Can we test F_{(0,1,4),N} vs F_{(4,1,0),N}?
    # max(0,1,4) = 4, needs window = 4. Can't compute.
    
    # For the smallest all-distinct profiles with max <= 2:
    # d=5: none (need c0+c1+c2=5 with all distinct and all <= 2: impossible since max sum = 0+1+2=3 < 5)
    # d=4: 0+1+3 has max=3. 0+1+2=3 not 4.
    # So there are NO all-distinct profiles with max <= 2 for the conjecture's range.
    # All computable profiles have at least two equal c_i values.
    # Therefore D_3 = cyclic x reversal, but for profiles with 2+ equal entries,
    # cyclic already gives all of D_3 (since (a,a,b) has D_3 orbit of size 3).
    
    print("\nConclusion: For profiles computable with window <= 2,")
    print("all D_3 orbits have size 3 (since at least two c_i are equal).")
    print("Cyclic symmetry alone accounts for the observed invariance.")
    print("Reversal symmetry is non-trivial only for profiles with all c_i distinct,")
    print("which requires max(c_i) >= 3 (not computable with current code).")
    
    # But earlier we verified F_{(2,1,1),N} = F_{(1,1,2),N}.
    # (2,1,1) and (1,1,2) are cyclically related: cyc(2,1,1) = (1,1,2).
    # So that test was just cyclic symmetry!
    
    # Let me check: is (0,1,1) cyclic equiv to (1,1,0)?
    # cyc(1,1,0) = (1,0,1), cyc^2(1,1,0) = (0,1,1). YES.
    # And rev(1,1,0) = (0,1,1) = cyc^2(1,1,0). Same thing.
    
    print("\n\nSo for profiles with two equal entries, reversal = cyclic^k.")
    print("The true test of reversal symmetry requires all-distinct profiles.")
    print("The SMALLEST such profile for k=3 has d >= 3+2+1 = 6, but d=6 is")
    print("excluded (d equiv 0 mod 3). Next: d=7, e.g. c=(1,2,4).")
    print("This has max(c) = 4, needs window=4. Not currently computable.")
    
    # Can we extend the transfer matrix to handle window=3 or 4?
    # That's a significant engineering effort. Let me instead check
    # if we can prove reversal symmetry algebraically.
    
    print("\n\n" + "=" * 70)
    print("Algebraic reversal symmetry via Borodin's formula")
    print("=" * 70)
    print("\nBorodin's product formula for F_c(q) expresses the unrestricted")
    print("GF as a product of q-Pochhammer factors.")
    print("If this product is invariant under c -> rev(c), then")
    print("F_c(z,q) = F_{rev(c)}(z,q) and hence Q_{n,c} = Q_{n,rev(c)}.")
    print("")
    print("Borodin's formula involves d_{i,j} = c_i + ... + c_j.")
    print("Under reversal (c0,c1,c2) -> (c2,c1,c0):")
    print("  d_{i,j} -> d'_{i,j} where d'_{i,j} uses the reversed sequence.")
    print("The product has terms indexed by pairs (i,j) with i < j and")
    print("m = 1,...,c_i. Under reversal, this becomes a relabeled product.")
    print("Need to verify the relabeling gives the same product.")


if __name__ == "__main__":
    main()
