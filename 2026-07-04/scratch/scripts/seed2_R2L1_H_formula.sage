# Find the correct formula for H(c, c') on KR crystals B^{1,d}
# H(c, c') is constant on profile pairs (verified for d=2 and d=4)

from sage.all import *
from collections import defaultdict

# Compute H for d=2 and d=4
def compute_H_matrix(d):
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    T2 = crystals.TensorProduct(K, K)
    
    def prof(b):
        tab = list(b.to_tableau())[0]
        return (tab.count(1), tab.count(2), tab.count(3))
    
    H = {}
    for b in T2:
        p1, p2 = prof(b[0]), prof(b[1])
        e = b.energy_function()
        H[(p1, p2)] = e
    
    profiles = sorted(set(prof(b) for b in K))
    return H, profiles

# d=2
H2, profs2 = compute_H_matrix(2)
print("H matrix for d=2:")
for c in profs2:
    print(f"  {c}: {[H2[(c,cp)] for cp in profs2]}")

# d=4
H4, profs4 = compute_H_matrix(4)

# Look at H values and try to find the formula
# For d=2:
# (0,0,2) -> [0,1,2,1,2,2]
# (0,1,1) -> [0,1,1,1,2,2]
# (0,2,0) -> [0,0,0,1,1,2]
# (1,0,1) -> [0,1,1,1,1,1]
# (1,1,0) -> [0,0,0,1,1,1]
# (2,0,0) -> [0,0,0,0,0,0]

# Pattern: H(c, c') seems to be min(c_2', c_0 + c_1 + c_2') + ... ?
# No. Let me try another approach.

# For elements with content c = (c_0, c_1, c_2), the entry in B^{1,d} is
# [1^{c_0} 2^{c_1} 3^{c_2}] (sorted word of length d)

# The energy H on B^{r,1} tensor B^{s,1} for type A counts winding pairs
# But B^{1,d} is NOT the same as B^{d,1}!
# B^{1,d} = d-fold symmetric power of the vector rep (rows of length d)
# B^{d,1} = d-th antisymmetric power (columns of height d)

# For B^{1,d}, the combinatorial R-matrix and energy can be computed
# using the promotion operator / Schutzenberger involution

# But since I verified H is constant on profile pairs, let me just 
# try to guess the formula from data

# Hypothesis: H(c, c') = min over i of (c_{i+1} + c_{i+2} + ... + c_{n-1} + c'_0 + ... + c'_i)
# where indices are taken cyclically mod 3

# For A_2, this would be:
# H(c, c') = min(c_1+c_2+c'_0, c_2+c'_0+c'_1, c'_0+c'_1+c'_2) - ???
# No, that doesn't make sense dimensionally

# Let me try: H = max(0, c'_0 + c'_1 - c_0 - c_1, ... ) type formula

# Actually, from the Nakayashiki-Yamada algorithm for R-matrix on
# B^{1,s1} tensor B^{1,s2} for gl_n:
# The elements are rows (weakly increasing sequences)
# For equal column lengths s1=s2=d, the algorithm is:
# Write all entries of b1 and b2 in increasing order
# Mark b1 entries ( and b2 entries )
# When same letter appears in both: leftmost belongs to b1 (convention)
# Match consecutive () pairs
# Then match winding pairs (periodic boundary)
# H = number of winding pairs

# But this is what I tried before and it didn't match!
# Let me re-examine for d=2

# b1 = [[1,1]], b2 = [[1,2]]
# Word: 1(1(2) -> 1 1 2 with marks ( ( )
# Actually entries are: 1,1 from b1 (marks () and 1,2 from b2 (marks ))
# Sorted: 1(1(1)2) -> order is 1 1 1 2
# b1 contributes 1,1 marked (( and b2 contributes 1,2 marked ))
# In sorted order: 1( 1( 1) 2) -- but convention says when same letter,
# b1 is leftmost
# So: 1( 1( 1) 2)
# Sequential match: pos 2 and 3 are () -> match
# Remaining: 1( 2) -> match
# No winding pairs -> H = 0

# But H((1,1,0), (1,0,1)) should be... let me check
print(f"\nH((1,1,0), (1,0,1)) for d=2 = {H2[((1,1,0),(1,0,1))]}")
# Should be 1 from the table

# Let me redo: b1 = [[1,2]] (content (1,1,0)), b2 = [[1,3]] (content (1,0,1))
# Entries: b1: 1,2  b2: 1,3
# Word sorted: 1( 1) 2( 3)
# Match: pos 1,2 are () -> match. pos 3,4 are () -> match. 
# No remaining -> H=0
# But SageMath says H=1!

# Something is wrong with my understanding. Let me check the actual
# R-matrix computation in SageMath

K2 = crystals.KirillovReshetikhin(['A',2,1], 1, 2)
b1 = None
b2 = None
for b in K2:
    tab = list(b.to_tableau())[0]
    if tab == [1,2]:
        b1 = b
    if tab == [1,3]:
        b2 = b

T = crystals.TensorProduct(K2, K2)
for b in T:
    if str(b[0]) == '[[1, 2]]' and str(b[1]) == '[[1, 3]]':
        print(f"b1={b[0]}, b2={b[1]}, energy={b.energy_function()}")
    if str(b[0]) == '[[1, 1]]' and str(b[1]) == '[[1, 2]]':
        print(f"b1={b[0]}, b2={b[1]}, energy={b.energy_function()}")

# Let me also check: is the energy function computed differently for B^{1,s}?
# Maybe it's not the "winding pairs" formula for single-row tableaux
# but involves the promotion operator

# Actually for type A_n^(1), B^{1,s} elements are ROWS of length s
# The R-matrix acts via the column-by-column algorithm
# B^{1,s} is the s-th symmetric power representation

# For B^{r,1} (single COLUMN), the R-matrix is the Nakayashiki-Yamada algorithm
# For B^{1,s} (single ROW), there's a different algorithm using promotion

# Key reference: Shimozono "Affine type A crystal structure on tensor products 
# of rectangles, Demazure characters, and nilpotent varieties"

# For now, let me just use the data and look for a formula
# Let me compute the H matrix for a larger case to see the pattern

print("\nH matrix for d=3:")
H3, profs3 = compute_H_matrix(3)
for c in profs3:
    print(f"  {c}: {[H3[(c,cp)] for cp in profs3]}")

# Looking at d=2 data again:
# Row (2,0,0): all zeros
# Row (1,1,0): [0,0,0,1,1,1]
# Row (1,0,1): [0,1,1,1,1,1]
# Row (0,2,0): [0,0,0,1,1,2]
# Row (0,1,1): [0,1,1,1,2,2]
# Row (0,0,2): [0,1,2,1,2,2]

# H((c_0,c_1,c_2), c') seems to be related to
# how many "3"s and "2"s are in the left factor
# vs how many "1"s and "2"s are in the right factor

# Actually, let me try: H = number of pairs (i,j) where letter i in b1 > letter j in b2
# ... wait, that's like counting inversions

# For (2,0,0) vs (0,0,2): b1=[1,1], b2=[3,3] -> H=0
# For (0,0,2) vs (2,0,0): b1=[3,3], b2=[1,1] -> H=2
# Hmm, that's like counting pairs where b1 entry > b2 entry = 4, not 2

# Let me think about it differently
# H((c_0,c_1,c_2), c') where profiles are ordered as
# (2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2) for d=2

# Row sums for d=2: 0, 3, 5, 4, 6, 7
# Column sums: 0, 3, 4, 5, 7, 8 (these are just sum of energies)

# Let me try the hypothesis that H = number of "winding pairs" but with 
# a DIFFERENT algorithm for B^{1,s}

# For B^{1,s}, elements are single rows. The R-matrix is computed by:
# sliding rows past each other using jeu de taquin / Bender-Knuth involutions
# The energy comes from the affine structure (promotion)

# Let me try: H(c,c') = floor(sum_{i<j}(c_i * c'_j) / d) or something

# Actually, let me just try to fit a simple formula
# For d=2, n=3 (A_2):
for c in profs2:
    for cp in profs2:
        h = H2[(c,cp)]
        # Try: sum of min(c_i, c'_{i+1}) cyclically
        guess1 = min(c[0],cp[1]) + min(c[1],cp[2]) + min(c[2],cp[0])
        # Try: min of (c_{i+1}+...+c_{n-1}+c'_0+...+c'_i) for i=0..n-1
        # minus something
        if h != guess1:
            pass

# Let me be more systematic. Print H and various candidate formulas
print("\n\nSystematic formula search for d=2:")
for c in profs2:
    for cp in profs2:
        h = H2[(c,cp)]
        g1 = min(c[0],cp[1]) + min(c[1],cp[2]) + min(c[2],cp[0])
        g2 = min(c[0]+c[1], cp[1]+cp[2]) + min(c[1]+c[2], cp[0]+cp[2]) 
        g3 = max(0, c[2]-cp[2]) + max(0, c[1]+c[2]-cp[1]-cp[2])
        # g3 = max(0, c[2]-cp[2]) + max(0, c[1]-cp[1]+c[2]-cp[2])... 
        # Actually rearranging: partial sums
        # Let s_i = c_0+...+c_i, s'_i = c'_0+...+c'_i
        s = [c[0], c[0]+c[1], c[0]+c[1]+c[2]]
        sp = [cp[0], cp[0]+cp[1], cp[0]+cp[1]+cp[2]]
        g4 = max(0, sp[0]-s[0]) + max(0, sp[1]-s[1])  # s[2]=sp[2]=d so contributes 0
        g5 = sum(max(0, sp[i]-s[i]) for i in range(2))
        if h == g5:
            pass
        #print(f"  H({c},{cp})={h}, g5={g5}")

# Check g5 = sum_{i=0}^{n-2} max(0, s'_i - s_i) where s_i = c'_0+...+c'_i, s_i = c_0+...+c_i
# This is the "Wasserstein distance" / "partial sum dominance" measure

all_g5 = True
for c in profs2:
    for cp in profs2:
        s = [sum(c[:i+1]) for i in range(3)]
        sp = [sum(cp[:i+1]) for i in range(3)]
        g5 = sum(max(0, sp[i]-s[i]) for i in range(2))
        h = H2[(c,cp)]
        if h != g5:
            all_g5 = False
            break

print(f"\nH = sum_{{i=0}}^{{n-2}} max(0, s'_i - s_i)? For d=2: {all_g5}")

# Check for d=4
all_g5_d4 = True
for c in profs4:
    for cp in profs4:
        s = [sum(c[:i+1]) for i in range(3)]
        sp = [sum(cp[:i+1]) for i in range(3)]
        g5 = sum(max(0, sp[i]-s[i]) for i in range(2))
        h = H4[(c,cp)]
        if h != g5:
            all_g5_d4 = False
            break

print(f"H = sum_{{i=0}}^{{n-2}} max(0, s'_i - s_i)? For d=4: {all_g5_d4}")

# Check for d=3
all_g5_d3 = True
for c in profs3:
    for cp in profs3:
        s = [sum(c[:i+1]) for i in range(3)]
        sp = [sum(cp[:i+1]) for i in range(3)]
        g5 = sum(max(0, sp[i]-s[i]) for i in range(2))
        h = H3[(c,cp)]
        if h != g5:
            all_g5_d3 = False
            break

print(f"H = sum_{{i=0}}^{{n-2}} max(0, s'_i - s_i)? For d=3: {all_g5_d3}")

