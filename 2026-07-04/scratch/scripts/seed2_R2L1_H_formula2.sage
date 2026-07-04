# Find the correct formula for H
# Data for d=2:
# H((0,0,2), (0,0,2)) = 0
# H((0,0,2), (0,1,1)) = 1
# H((0,0,2), (0,2,0)) = 2
# H((0,0,2), (1,0,1)) = 1
# H((0,0,2), (1,1,0)) = 2
# H((0,0,2), (2,0,0)) = 2

# H((2,0,0), anything) = 0

# This looks like: H(c, c') = min(c_2, c'_0) + min(c_2, c'_0 + c'_1) ... no

# Let me just exhaustively check formulas of the form
# H = a*min(c_i, c'_j) + b*... etc.

# Actually, looking at the pattern more carefully:
# H((0,0,2), c') = min(2, c'_0 + c'_1) = min(c_2, c'_0 + c'_1)? 
# Check: c'=(0,0,2): min(2, 0) = 0 YES
# c'=(0,1,1): min(2, 1) = 1 YES
# c'=(0,2,0): min(2, 2) = 2 YES
# c'=(1,0,1): min(2, 1) = 1 YES
# c'=(1,1,0): min(2, 2) = 2 YES
# c'=(2,0,0): min(2, 2) = 2 YES
# PERFECT!

# H((1,0,1), c') = min(1, c'_0 + c'_1)?
# c'=(0,0,2): min(1, 0) = 0 YES
# c'=(0,1,1): min(1, 1) = 1 YES
# c'=(0,2,0): min(1, 2) = 1 YES
# c'=(1,0,1): min(1, 1) = 1 YES (H=1)
# c'=(1,1,0): min(1, 2) = 1 YES (H=1)
# c'=(2,0,0): min(1, 2) = 1 YES (H=1)
# PERFECT!

# H((0,1,1), c') = min(c_1+c_2, c'_0+c'_1) = min(2, c'_0+c'_1)?
# Same as (0,0,2)? No, let me check
# c'=(0,0,2): min(2, 0) = 0 YES
# c'=(0,1,1): min(2, 1) = 1 YES (H=1)
# c'=(0,2,0): min(2, 2) = 2, but H=1. FAIL!

# So it's not just min(c_1+c_2, c'_0+c'_1).

# Let me look at H((0,1,1), c'):
# [0, 1, 1, 1, 2, 2]
# c'=(0,0,2):0, (0,1,1):1, (0,2,0):1, (1,0,1):1, (1,1,0):2, (2,0,0):2

# Try: min(c_2, c'_0) + min(c_1+c_2, c'_0+c'_1) - min(c_2, c'_0+c'_1)?
# Hmm, this is getting complicated. Let me try a completely different angle.

# From the literature: for B^{1,s} tensor B^{1,s} of type A_{n-1}^(1),
# the energy function H is related to the Kostka number or 
# to the number of semistandard Young tableaux

# For two rows of length d with contents c, c', the energy is:
# H(c, c') = d - |nu| where nu is the "overlap" Young diagram
# obtained from RSK on the pair

# Actually, there's a classical result:
# For the R-matrix on B^{1,s1} tensor B^{1,s2}, 
# R(b1 tensor b2) = b2' tensor b1' and
# H = s1 - |content of b1'| ... no, that's not right either

# Let me try another approach: partial sums
# For content c = (c_0, c_1, c_2), define S_k = c_0 + ... + c_{k-1}
# S_0 = 0, S_1 = c_0, S_2 = c_0+c_1, S_3 = d

# For d=2, H((0,1,1), (0,2,0)):
# c = (0,1,1), S = (0, 0, 1, 2)
# c'= (0,2,0), S'= (0, 0, 2, 2)

# Try: H = sum_{k=1}^{n-1} max(0, S'_k - S_k)?
# = max(0, 0-0) + max(0, 2-1) = 0 + 1 = 1. H=1. YES!

# Check H((0,0,2), (0,2,0)):
# S=(0,0,0,2), S'=(0,0,2,2)
# sum max(0, S'_k-S_k) for k=1,2 = max(0,0) + max(0,2) = 2. H=2. YES!

# Check H((0,0,2), (0,1,1)):
# S=(0,0,0,2), S'=(0,0,1,2)
# sum = max(0,0) + max(0,1) = 1. H=1. YES!

# Check H((0,0,2), (1,0,1)):
# S=(0,0,0,2), S'=(0,1,1,2)
# sum = max(0,1) + max(0,1) = 2. But H=1. FAIL!

# Hmm, so that formula works for some but not all.

# Wait, I was wrong earlier when I checked. Let me re-check properly
from sage.all import *

# Recompute all H matrices
def compute_H(d):
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    T = crystals.TensorProduct(K, K)
    
    def prof(b):
        tab = list(b.to_tableau())[0]
        return (tab.count(1), tab.count(2), tab.count(3))
    
    H = {}
    for b in T:
        p1, p2 = prof(b[0]), prof(b[1])
        H[(p1, p2)] = b.energy_function()
    
    profiles = sorted(set(prof(b) for b in K))
    return H, profiles

for d in [2, 3, 4]:
    H, profs = compute_H(d)
    print(f"\nTesting formulas for d={d}:")
    
    # Formula candidates:
    # f1: sum_{k=1}^{1} max(0, S'_k - S_k) where S_k = c'_0+...+c'_{k-1}
    # f2: min(c_2, c'_0) + min(c_1+c_2, c'_0+c'_1) 
    # f3: some other combination
    
    # Try f1 with different interpretations of the partial sums
    # c = (c_0, c_1, c_2), elements have letters c_0 1's, c_1 2's, c_2 3's
    # Partial sum: A_k(c) = c_{n-1} + c_{n-2} + ... + c_{n-k} (suffix sum from the high end)
    # A_1(c) = c_2, A_2(c) = c_1+c_2
    
    all_f2 = True
    for c in profs:
        for cp in profs:
            # f2: sum_k min(suffix_k(c), prefix_k(c')) for k=1..n-1
            # where suffix_k(c) = c_{n-k} + ... + c_{n-1} and prefix_k(c') = c'_0 + ... + c'_{k-1}
            f2 = sum(min(sum(c[3-k:3]), sum(cp[:k])) for k in range(1, 3))
            h = H[(c, cp)]
            if f2 != h:
                all_f2 = False
                if d == 2:
                    print(f"  f2 FAIL: H({c},{cp})={h} but f2={f2}")
                break
        if not all_f2:
            break
    print(f"  f2 (sum min(suffix_k(c), prefix_k(c'))): {all_f2}")
    
    # Alternative: try min(c_{2}, c'_0) + min(c_{1}+c_{2}, c'_0+c'_1)
    # = min(suffix_1(c), prefix_1(c')) + min(suffix_2(c), prefix_2(c'))
    # This is the same as f2!
    
    # Hmm, let me check f2 more carefully for d=2
    if d == 2:
        for c in profs:
            for cp in profs:
                suf1 = c[2]
                suf2 = c[1]+c[2]
                pre1 = cp[0]
                pre2 = cp[0]+cp[1]
                f2 = min(suf1, pre1) + min(suf2, pre2)
                h = H[(c, cp)]
                match = "OK" if f2 == h else "FAIL"
                if f2 != h:
                    print(f"  H({c},{cp})={h}, f2={f2} [suf=({suf1},{suf2}), pre=({pre1},{pre2})] {match}")

    # Let me try yet another: the "dominance" formula
    # For B^{1,d} in type A_2^(1), with 3 letters:
    # H(c, c') = min(c[2], c'[0]) + min(c[1]+c[2], c'[0]+c'[1])
    # For d=2, c=(0,0,2), c'=(1,0,1):
    # min(2,1) + min(2,1) = 1+1 = 2, but H=1

    # OK so f2 doesn't work. Let me try the REVERSE:
    # H(c, c') = min(c[0], c'[2]) + min(c[0]+c[1], c'[1]+c'[2])?
    all_f3 = True
    for c in profs:
        for cp in profs:
            f3 = sum(min(sum(c[:k]), sum(cp[3-k:3])) for k in range(1, 3))
            h = H[(c, cp)]
            if f3 != h:
                all_f3 = False
                break
        if not all_f3:
            break
    print(f"  f3 (sum min(prefix_k(c), suffix_k(c'))): {all_f3}")

    # Try: min(c_2, c'_0+c'_1) (just the one term)?
    all_f4 = True
    for c in profs:
        for cp in profs:
            f4 = min(c[2], cp[0]+cp[1])
            h = H[(c, cp)]
            if f4 != h:
                all_f4 = False
                break
        if not all_f4:
            break
    print(f"  f4 (min(c_2, c'_0+c'_1)): {all_f4}")

    # What about: H = min over all permutations sigma of sum c_{sigma(i)} c'_i ?
    # No, that's for optimal transport
    
    # Let me try the actual Wasserstein/transport formula
    # H(c,c') = min over couplings T of sum T_{ij} * d(i,j) where d(i,j) = (j-i) mod 3
    # This is the Earth Mover's Distance with metric d(i,j) = j-i mod 3
    
    # Hmm but the EMD from Round 1 didn't match H
    
    # Let me try metric d(i,j) = max(0, i-j) (one-directional)
    # Transport from c to c': move mass from letter type i to letter type j
    # Cost = max(0, i-j) = how far you're moving "down"
    
    # H = optimal transport cost with this asymmetric metric?
    
    # For d=2, H((0,0,2), (1,0,1)):
    # Need to move 2 units of type-3 to 1 unit of type-1 and 1 unit of type-3
    # Move 1 unit from 3->1 (cost max(0,2)=2) and keep 1 unit at 3 (cost 0)
    # Total = 2. But H = 1.
    
    # What about cost = max(0, j-i)?
    # Move from 3 to 1: cost max(0, 1-3) = 0. Total 0. Nope.
    
    # OK what about: for each pair of entries, count (entry_b1 > entry_b2)?
    # H = number of pairs (position_i_in_b1, position_j_in_b2) where b1[i] > b2[j]?
    # For b1=[3,3] (c=(0,0,2)), b2=[1,3] (c'=(1,0,1)):
    # Pairs: (3,1)=yes, (3,3)=no, (3,1)=yes, (3,3)=no -> 2 pairs. H=1. No.
    
    # Division by d? 2/2 = 1? For d=4 need to check
    
    # Let me just print all data and stare at it
    if d == 2:
        print(f"\n  Full data for d=2 (label = letter 1 count, 2 count, 3 count):")
        for c in profs:
            row = [H[(c,cp)] for cp in profs]
            print(f"  {c}: {row}")

