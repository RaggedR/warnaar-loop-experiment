# Analyze the energy matrix H for d=4
# Pattern visible: H(c, c') = min(c_0, c'_2) + min(c_0+c_1, c'_1+c'_2) 
# or something like that. Let me check.

from sage.all import *

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
T2 = crystals.TensorProduct(K, K)

def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

energy_mat = {}
for b in T2:
    prof1 = element_to_profile(b[0])
    prof2 = element_to_profile(b[1])
    e = b.energy_function()
    energy_mat[(prof1, prof2)] = e

profiles = sorted(set(element_to_profile(b) for b in K))

# Looking at the H values:
# H((4,0,0), anything) = 0  -- the "all 1's" element
# H((3,1,0), c') = 0 if c' has no 2's or 3's beyond... 
# H((0,0,4), c') = 0,1,2,3,4,1,2,3,4,2,3,4,3,4,4

# Let me check: for KR crystals of type A_n^(1), the energy function
# H(b1 tensor b2) counts "winding pairs" in the combinatorial R-matrix
# For B^{1,s} elements are single-row tableaux of length s with entries in {1,...,n+1}
# For A_2^(1), entries in {1,2,3}

# The winding pair count formula:
# Write entries of b1 and b2 in increasing order
# Mark b1 entries with ( and b2 entries with )
# Match consecutive pairs, then match winding pairs
# H = number of winding pairs

# For single-row tableaux of content c=(c_0,c_1,c_2) and c'=(c_0',c_1',c_2'):
# Letters are: c_0 copies of 1, c_1 copies of 2, c_2 copies of 3
# vs c_0' copies of 1, c_1' copies of 2, c_2' copies of 3

# Writing in order with ( for b1 and ) for b2:
# 1: c_0 copies of (, c_0' copies of )
# 2: c_1 copies of (, c_1' copies of )  
# 3: c_2 copies of (, c_2' copies of )

# Matching consecutive () pairs:
# After each letter group, unmatched ( and ) accumulate
# Let me work out the formula

# After letter 1: matched = min(c_0, c_0'), excess ( = max(0, c_0-c_0'), excess ) = max(0, c_0'-c_0)
# But actually we first read all 1's then all 2's etc.
# The word is: 1^{c_0} 1^{c_0'} 2^{c_1} 2^{c_1'} 3^{c_2} 3^{c_2'}
# With ( for b1 entries and ) for b2 entries
# Within letter 1: first c_0 ('s, then c_0' )'s
# Matching consecutive: min(c_0, c_0') pairs, 
#   remaining ( : max(0, c_0-c_0')
#   remaining ) : max(0, c_0'-c_0)
# Then letter 2: c_1 ('s, c_1' )'s
# First c_1 ('s arrive: they stack on top of existing ('s
# Then c_1' )'s arrive: first match with the c_1 ('s just added,
#   then match with remaining ('s from letter 1
# Actually, it's sequential matching of consecutive () only

# Let me think more carefully. The unmatched from letter 1 is:
# ) ) ... ) ( ( ... ( 
# with r1 = max(0, c_0'-c_0) )'s and l1 = max(0, c_0-c_0') ('s

# Then letter 2 adds c_1 ('s and c_1' )'s:
# The new ('s go to the right of existing ('s
# The new )'s go to the right of existing )'s
# Wait no, the matching is sequential within the word

# Actually, let me just compute it directly
# The word is: (^{c_0} )^{c_0'} (^{c_1} )^{c_1'} (^{c_2} )^{c_2'}
# We match consecutive () pairs left to right

# This is equivalent to: compute the unmatched sequence after each letter group

def compute_H_formula(c, cp):
    """Compute energy H(b_c tensor b_{c'}) using winding pair formula."""
    n = 3  # A_2
    # Build the word of ( and )
    word = []
    for i in range(n):
        word.extend(['('] * c[i])
        word.extend([')'] * cp[i])
    
    # Match consecutive () pairs
    stack = []
    for ch in word:
        if ch == '(' :
            stack.append('(')
        else:  # ')'
            if stack and stack[-1] == '(':
                stack.pop()
            else:
                stack.append(')')
    
    # After matching, stack has form ))...)((...(
    # Count unmatched ( and )
    num_close = sum(1 for x in stack if x == ')')
    num_open = sum(1 for x in stack if x == '(')
    
    # Winding pairs: match rightmost unmatched ( with leftmost unmatched )
    # under periodic boundary conditions
    winding = min(num_close, num_open)
    
    return winding

# Verify against SageMath's computation
print("Verifying H formula:")
all_match = True
for c in profiles:
    for cp in profiles:
        h_formula = compute_H_formula(c, cp)
        h_sage = energy_mat[(c, cp)]
        if h_formula != h_sage:
            print(f"  MISMATCH: H({c},{cp}) formula={h_formula} sage={h_sage}")
            all_match = False

print(f"All match: {all_match}")

if all_match:
    print("\nH(c,c') = number of winding pairs in the sequence (^{c_0})^{c_0'}(^{c_1})^{c_1'}(^{c_2})^{c_2'}")
    
    # Now I can derive a closed-form
    # After matching sequential pairs:
    # After group 1: excess_close_1 = max(0, c_0'-c_0), excess_open_1 = max(0, c_0-c_0')
    # After group 2: we add c_1 ('s then c_1' )'s
    #   The c_1' )'s match first with the c_1 ('s, then with excess_open_1
    #   Let matched_2 = min(c_1 + excess_open_1, c_1')
    #   ... this gets complicated. Let me just derive the formula differently.
    
    # Alternative: define partial sums
    # S_i(c) = c_0 + c_1 + ... + c_{i-1} (number of ('s read so far)
    # S_i(c') = c_0' + c_1' + ... + c_{i-1}' (number of )'s read so far)
    # The number of unmatched ('s after reading up to letter i is:
    # max over j<=i of (S_j(c) - S_j(c'))... actually it's more subtle
    
    # The unmatched ('s at the end = S_3(c) - (matched pairs) = d - matched
    # and unmatched )'s at the end = S_3(c') - (matched pairs) = d - matched
    # Since S_3(c) = S_3(c') = d, unmatched ( = unmatched ) = d - matched
    # So winding pairs = d - matched (sequential matching of all d+d symbols)
    
    # Wait: total ( = total ) = d. After sequential matching, 
    # matched = total - unmatched = d - num_unmatched_open = d - num_unmatched_close
    # (they're equal since total open = total close)
    # So winding = num_unmatched_open = num_unmatched_close
    
    # The number of matched pairs after sequential left-to-right matching of
    # (^{c_0})^{c_0'}(^{c_1})^{c_1'}(^{c_2})^{c_2'} is:
    # Let me compute it step by step
    
    def matched_formula(c, cp):
        """Count matched pairs in (^{c_0})^{c_0'}(^{c_1})^{c_1'}(^{c_2})^{c_2'}"""
        excess_open = 0  # unmatched ('s
        matched = 0
        for i in range(3):
            excess_open += c[i]
            # Now c_i' )'s arrive
            m = min(excess_open, cp[i])
            matched += m
            excess_open -= m
        return matched
    
    print("\nVerifying matched formula:")
    for c in profiles:
        for cp in profiles:
            m = matched_formula(c, cp)
            h = 4 - m  # d - matched = winding pairs = H
            if h != energy_mat[(c, cp)]:
                print(f"  MISMATCH at ({c},{cp})")
    
    # So H(c,c') = d - sum_i min(cum_open_i, cum_close_i) where
    # cum_open after step i = c_0+...+c_i - (matched so far)
    
    # Simpler formula: H = d - matched = d - sum_i min(excess_after_{i-1} + c_i, c_i')
    # where excess_after_0 = 0
    
    # Even simpler: the matched count equals 
    # min(c_0, c_0') + min(max(0,c_0-c_0')+c_1, c_1') + min(max(0,max(0,c_0-c_0')+c_1-c_1')+c_2, c_2')
    # But the last term simplifies since total = d, so this always works out
    
    # H(c,c') = d - matched(c, c')
    
    # KEY INSIGHT: this is related to the RSK matching / jeu de taquin
    # It's a transport / matching distance
    
    # Now: the Adjugate Monomial Theorem says adj(I-A(x))[c,c'] = x^{EMD(c,c')}
    # And we've found H(c,c') = winding pairs formula
    # These are DIFFERENT functions!
    
    # But both appear in the connection between KR crystals and cylindric partitions
    # H appears in the crystal energy function
    # EMD appears in the transfer matrix adjugate
    
    # The question is: can we connect them?
    
    # Let's print both side by side for a few pairs
    print("\n\nComparison of H and EMD:")
    print(f"{'c':>12} {'cp':>12} {'H':>4} {'EMD':>4} {'H+EMD(rev)':>10}")
    for c in profiles[:5]:
        for cp in profiles[:5]:
            h = energy_mat[(c, cp)]
            e = 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])
            e_rev = 3*max(0, c[1]-cp[1], cp[0]-c[0]) + (c[0]-cp[0]) - (c[1]-cp[1])
            print(f"{str(c):>12} {str(cp):>12} {h:>4} {e:>4} {h+e_rev:>10}")

# Now the crucial test: compute energy on tensor products for d=2 and d=5
# to see if the pattern (H constant on profile pairs) holds

print("\n" + "=" * 60)
print("Testing H constant on profile pairs for d=2")
print("=" * 60)

K2 = crystals.KirillovReshetikhin(['A',2,1], 1, 2)
T2_d2 = crystals.TensorProduct(K2, K2)

def prof(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

H_d2 = {}
for b in T2_d2:
    p1, p2 = prof(b[0]), prof(b[1])
    e = b.energy_function()
    if (p1,p2) not in H_d2:
        H_d2[(p1,p2)] = set()
    H_d2[(p1,p2)].add(e)

constant_d2 = all(len(v)==1 for v in H_d2.values())
print(f"H constant on profile pairs for d=2? {constant_d2}")

if constant_d2:
    profs2 = sorted(set(prof(b) for b in K2))
    print("H matrix for d=2:")
    for c in profs2:
        vals = [list(H_d2[(c,cp)])[0] for cp in profs2]
        formula_vals = [compute_H_formula(c, cp) for cp in profs2]
        match = vals == formula_vals
        print(f"  {c}: H={vals}, formula={formula_vals}, match={match}")

