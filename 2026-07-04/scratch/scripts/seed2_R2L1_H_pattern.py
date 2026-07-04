# For d=2, d=3, d=4, the H matrix data
# Let me look for a min-based formula

# For A_2 with 3 letters {1,2,3}, contents c=(c_0,c_1,c_2) and c'=(c'_0,c'_1,c'_2)
# Element b has sorted word 1^{c_0} 2^{c_1} 3^{c_2}

# The R-matrix for single-row tableaux B^{1,s} tensor B^{1,s} for sl_3:
# is related to the crystal commutor

# Key insight: for B^{1,s} (symmetric power), the R-matrix
# exchanges the two rows. The energy counts "inversions modulo wrapping"

# For sl_3 with letters {1,2,3}:
# A "winding pair" occurs when a letter from b1 that is LOWER than a letter from b2
# gets matched across the periodic boundary

# Wait, the answer might be much simpler. Let me look at the data again:

# d=2 H matrix:
# Rows: (0,0,2) (0,1,1) (0,2,0) (1,0,1) (1,1,0) (2,0,0)
# Cols: same order
#
# [[0,1,2, 1,2,2],
#  [0,1,1, 1,2,2],
#  [0,0,0, 1,1,2],
#  [0,1,1, 1,1,1],
#  [0,0,0, 1,1,1],
#  [0,0,0, 0,0,0]]

# The key observation: if I define phi(c) = c_2 (position 3 count),
# then H(c, c') increases with phi(c) and with phi'(c') in some sense

# Actually: H(c, c') seems to be related to 
# how many letters in c are > corresponding letters in c' when
# we pair them optimally

# For rows of length d, if we pair positions 1..d:
# The "greedy matching" would pair the largest entry of c with 
# the smallest of c' to maximize inversions... but that gives 
# too many

# Let me try: H = floor(inversions(c, c') / 3)?
# inversions = #{(i,j): c[i] > c'[j]}
# For c=(0,0,2)=[3,3], c'=(0,1,1)=[2,3]:
# inv = (3>2)+(3>nothing for 3) + (3>2) = 2 inversions? 
# Wait I need to count ALL pairs (i,j) for i in range(d), j in range(d):
# c = [3,3], c' = [2,3]
# (3,2): 3>2 yes, (3,3): no, (3,2): yes, (3,3): no -> 2 inversions
# 2/2 = 1 = H. CHECK!

# c=(0,0,2)=[3,3], c'=(0,2,0)=[2,2]:
# (3,2): yes x4 -> 4 inversions. 4/2 = 2 = H. CHECK!

# c=(0,0,2)=[3,3], c'=(1,0,1)=[1,3]:
# (3,1): yes, (3,3): no, (3,1): yes, (3,3): no -> 2 inversions
# 2/2 = 1 = H. CHECK!

# c=(0,1,1)=[2,3], c'=(0,2,0)=[2,2]:
# (2,2): no, (2,2): no, (3,2): yes, (3,2): yes -> 2 inversions
# 2/2 = 1 = H. CHECK!

# c=(0,1,1)=[2,3], c'=(0,1,1)=[2,3]:
# (2,2): no, (2,3): no, (3,2): yes, (3,3): no -> 1 inversion
# But H = 1, and 1/2 = 0.5 != 1. FAIL!

# Hmm, so floor(inv/d) doesn't work. Let me recount.
# c=(0,1,1) means content = (0 ones, 1 two, 1 three) -> word = [2,3]
# c'=(0,1,1) -> word = [2,3]
# Pairs: (2,2)=no, (2,3)=no, (3,2)=yes, (3,3)=no -> 1 inversion
# H = 1. So the formula isn't inv/d.

# Maybe: ceil(inv/d)? 1/2 = 0.5, ceil = 1. That works for this case.
# Check c=(0,0,2)=[3,3], c'=(0,1,1)=[2,3]:
# inv = 2, ceil(2/2) = 1 = H. OK.
# Check c=(0,0,2)=[3,3], c'=(0,2,0)=[2,2]:
# inv = 4, ceil(4/2) = 2 = H. OK.
# Check c=(0,2,0)=[2,2], c'=(1,0,1)=[1,3]:
# (2,1)=yes, (2,3)=no, (2,1)=yes, (2,3)=no -> 2 inv, ceil(2/2) = 1 = H. OK!
# Check c=(0,2,0)=[2,2], c'=(0,0,2)=[3,3]:
# (2,3)=no x4 -> 0 inv. H=0. OK!

# Let me check all d=2:
d = 2
profs = [(c0,c1,d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
data = {
    ((0,0,2), (0,0,2)): 0, ((0,0,2), (0,1,1)): 1, ((0,0,2), (0,2,0)): 2,
    ((0,0,2), (1,0,1)): 1, ((0,0,2), (1,1,0)): 2, ((0,0,2), (2,0,0)): 2,
    ((0,1,1), (0,0,2)): 0, ((0,1,1), (0,1,1)): 1, ((0,1,1), (0,2,0)): 1,
    ((0,1,1), (1,0,1)): 1, ((0,1,1), (1,1,0)): 2, ((0,1,1), (2,0,0)): 2,
    ((0,2,0), (0,0,2)): 0, ((0,2,0), (0,1,1)): 0, ((0,2,0), (0,2,0)): 0,
    ((0,2,0), (1,0,1)): 1, ((0,2,0), (1,1,0)): 1, ((0,2,0), (2,0,0)): 2,
    ((1,0,1), (0,0,2)): 0, ((1,0,1), (0,1,1)): 1, ((1,0,1), (0,2,0)): 1,
    ((1,0,1), (1,0,1)): 1, ((1,0,1), (1,1,0)): 1, ((1,0,1), (2,0,0)): 1,
    ((1,1,0), (0,0,2)): 0, ((1,1,0), (0,1,1)): 0, ((1,1,0), (0,2,0)): 0,
    ((1,1,0), (1,0,1)): 1, ((1,1,0), (1,1,0)): 1, ((1,1,0), (2,0,0)): 1,
    ((2,0,0), (0,0,2)): 0, ((2,0,0), (0,1,1)): 0, ((2,0,0), (0,2,0)): 0,
    ((2,0,0), (1,0,1)): 0, ((2,0,0), (1,1,0)): 0, ((2,0,0), (2,0,0)): 0,
}

import math

def inversions(c, cp, d):
    """Count pairs (i,j) in [d]x[d] where word_c[i] > word_cp[j]"""
    # word_c has c[0] 1's, c[1] 2's, c[2] 3's
    inv = 0
    for a in range(1, 4):
        for b in range(1, 4):
            if a > b:
                inv += c[a-1] * cp[b-1]
    return inv

print("Testing ceil(inv/d) for d=2:")
all_ok = True
for (c, cp), h in data.items():
    inv = inversions(c, cp, 2)
    pred = math.ceil(inv / 2) if inv > 0 else 0
    if pred != h:
        print(f"  FAIL: H({c},{cp})={h}, inv={inv}, ceil(inv/2)={pred}")
        all_ok = False
print(f"  Result: {all_ok}")

# Also try floor((inv + d - 1) / d):
print("\nTesting round(inv/d) for d=2:")
all_ok = True
for (c, cp), h in data.items():
    inv = inversions(c, cp, 2)
    pred = round(inv / 2)
    if pred != h:
        print(f"  FAIL: H({c},{cp})={h}, inv={inv}, round(inv/2)={pred}")
        all_ok = False
print(f"  Result: {all_ok}")

# inv formula: inv = c_1*c'_0 + c_2*c'_0 + c_2*c'_1
# = c_2*(c'_0 + c'_1) + c_1*c'_0

print("\n\nChecking inv values and H for d=2:")
for (c, cp), h in sorted(data.items()):
    inv = inversions(c, cp, 2)
    print(f"  H({c},{cp})={h}, inv={inv}")

# I see: H = inv/d doesn't work because inversions aren't always divisible by d
# For (0,1,1),(0,1,1): inv = 1*0 + 1*0 + 1*1 = 1. H=1. 1/2 = 0.5 ≠ 1

# Let me reconsider. Maybe inv/n where n=3 (number of letters)?
# inv=1, 1/3 no. 

# What if H counts something else entirely?
# For (0,1,1),(0,1,1): b1=[2,3], b2=[2,3]
# These are the same! H=1 means the R-matrix has energy 1 for identical elements?

# That's the "diagonal" energy. For KR crystals, H(b,b) = some function of b.

# Actually, for B^{1,s} of type A_2^(1), each element b with content (c_0,c_1,c_2)
# corresponds to a highest weight element of the classical crystal decomposition
# The "level" of b is related to the number of boxes that need to be promoted

# The energy H(b,b) for the identical pair counts the "charge" or 
# "cocharge" of the element

# For type A_2^(1), H(b,b) should be related to the 2-core of the 
# corresponding partition

# OK let me try a completely different approach. Let me define:
# sigma(c) = sum_{0<=i<j<=2} c_i * c_j * (j - i)
# This is a weighted count of "pairs of different letters"

# For (0,1,1): sigma = 0*1*1 + 0*1*2 + 1*1*1 = 1
# For (0,0,2): sigma = 0 + 0 + 0 = 0
# For (2,0,0): sigma = 0

# H((0,1,1),(0,1,1)) = 1. sigma(0,1,1) = 1. Hmm.

# What about H(c,c') = floor((sigma(c) + sigma(c') + cross_term) / d)?

# This is getting nowhere with guessing. Let me look up the actual formula.

# From Shimozono-Zabrocki or Schilling's work:
# For B = B^{1,s} (single row of length s) of type A_{n-1}^(1):
# The energy function H(b1, b2) on B tensor B equals
# the "charge" of the pair, which for single-row tableaux reduces to:
# H(b1, b2) = s - max(0, ...) formula involving Schensted insertion

# For single-row B^{1,s} of type A_{n-1}^(1):
# The energy is the number of applications of the promotion operator
# needed to "straighten" b1 tensor b2

# Actually, the formula is known to be:
# H(c, c') = sum_{1<=a<b<=n} min(c_a, c'_{b-1}) where we index
# letters 1..n and the ordering wraps around

# Wait, let me try: for A_2 with letters {0,1,2} (re-indexing):
# H = min(c_1+c_2, c'_0) + min(c_2, c'_0+c'_1)
# where we use (c_0,c_1,c_2) for letters (1,2,3)

# Check for (0,1,1),(0,1,1): min(2,0) + min(1,1) = 0+1 = 1 = H. YES!
# Check for (0,0,2),(0,1,1): min(2,0) + min(2,1) = 0+1 = 1 = H. YES!
# Check for (0,0,2),(0,2,0): min(2,0) + min(2,2) = 0+2 = 2 = H. YES!
# Check for (0,0,2),(1,0,1): min(2,1) + min(2,1) = 1+1 = 2 ≠ H=1. FAIL!

# Hmm. Let me try: min(c_2, c'_0) + min(c_1+c_2, c'_0+c'_1)?
# (0,0,2),(1,0,1): min(2,1)+min(2,1) = 1+1 = 2 ≠ 1. Same fail.

# What about the formula from Dousse-Konan that appears in the RAG context?
# From chunk 11 (Theorem 1.4): H((v_l' tensor v_k^vee) tensor (v_l tensor v_k^vee)) = Delta(a_k b_l; a_k' b_l')
# This is for a DIFFERENT crystal (B tensor B^vee), not B^{1,d}

# Let me try yet another formula:
# H(c, c') = min(c[2], c'[0]) + min(c[1], c'[0] - min(c[2],c'[0]) + c'[1])
# This is like a greedy matching of "high letters in c" with "low letters in c'"

# (0,0,2),(1,0,1): 
# step 1: match min(c[2]=2, c'[0]=1) = 1 pair of (3 from c, 1 from c')
# step 2: remaining c'[0] = 0. Match min(c[1]=0, 0+c'[1]=0) = 0
# Total = 1 = H. YES!

# (0,1,1),(0,1,1):
# step 1: min(1, 0) = 0
# step 2: min(1, 0+1) = 1
# Total = 1 = H. YES!

# (0,1,1),(1,1,0):
# step 1: min(1, 1) = 1
# step 2: remaining c'[0] = 0. min(1, 0+1) = 1
# Total = 2 = H. YES!

# Let me verify this formula for all d=2 data:
print("\n\nTesting greedy matching formula:")
all_ok = True
for (c, cp), h in sorted(data.items()):
    # Match 3's from c with 1's from c' first
    m1 = min(c[2], cp[0])
    rem_cp0 = cp[0] - m1
    # Match 2's from c with remaining 1's from c', then with 2's from c'
    m2 = min(c[1], rem_cp0 + cp[1])
    # Also match remaining 3's from c with 2's from c'
    rem_c2 = c[2] - m1
    m3 = min(rem_c2, cp[1] - max(0, m2 - rem_cp0))
    
    total = m1 + m2 + m3
    if total != h:
        print(f"  FAIL: H({c},{cp})={h}, formula={total} (m1={m1},m2={m2},m3={m3})")
        all_ok = False
print(f"  Result: {all_ok}")

# OK that's too complicated. Let me think again about what the energy 
# function actually computes for single-row B^{1,s}.

# For B^{1,s} of type A_{n-1}^(1), the promotion operator sigma acts by:
# 1. Remove all n's from the row
# 2. Subtract 1 from all remaining entries
# 3. Add n's back to fill up to length s

# The R-matrix is computed by sliding the two rows past each other
# using jeu de taquin on a 2xs rectangle

# For two rows b1, b2 of length s=d:
# Form the 2xd tableau with b1 on top, b2 on bottom
# Compute R using crystal isomorphism

# H = s - (length of common prefix of R(b1 tensor b2))
# Wait, that's not right either

# Let me just check a simpler formula:
# For A_2, H(c, c') = d - max(min(c[0],c'[0]) + min(c[0]+c[1],c'[0]+c'[1]), 
#                              min(c[0],c'[0]+c'[1]+c'[2]) + ...) ?

# Actually, from the RSK perspective:
# Given two rows b1 = [a_1,...,a_d] and b2 = [b_1,...,b_d] (sorted)
# The energy H = d - (longest weakly-increasing common subsequence)?

# For b1=[3,3], b2=[1,3]: LIS between them... 
# Hmm, that doesn't make sense for sorted sequences

# OK final try. The energy for B^{1,s} tensor B^{1,s} of type A_{n-1}^(1):
# b1 = [a_1 <= ... <= a_d] and b2 = [b_1 <= ... <= b_d]
# H = #{i : a_i > b_i}

# Check for d=2:
# (0,0,2)=[3,3], (0,1,1)=[2,3]: a_1=3>b_1=2, a_2=3=b_2=3 -> 1. H=1 YES!
# (0,0,2)=[3,3], (0,2,0)=[2,2]: 3>2, 3>2 -> 2. H=2 YES!
# (0,0,2)=[3,3], (1,0,1)=[1,3]: 3>1, 3=3 -> 1. H=1 YES!
# (0,1,1)=[2,3], (0,1,1)=[2,3]: 2=2, 3=3 -> 0. But H=1 FAIL!

# So that's wrong too. H((0,1,1),(0,1,1)) = 1 but the pointwise 
# comparison gives 0.

# Let me try: H = #{i : a_i > b_{d+1-i}} (anti-diagonal comparison)?
# (0,1,1)=[2,3], (0,1,1)=[2,3]: a_1=2 vs b_2=3: no. a_2=3 vs b_1=2: yes -> 1. H=1 YES!
# (0,0,2)=[3,3], (0,1,1)=[2,3]: a_1=3 vs b_2=3: no. a_2=3 vs b_1=2: yes -> 1. H=1 YES!
# (0,0,2)=[3,3], (0,2,0)=[2,2]: a_1=3 vs b_2=2: yes. a_2=3 vs b_1=2: yes -> 2. H=2 YES!
# (0,0,2)=[3,3], (1,0,1)=[1,3]: a_1=3 vs b_2=3: no. a_2=3 vs b_1=1: yes -> 1. H=1 YES!
# (0,2,0)=[2,2], (1,0,1)=[1,3]: a_1=2 vs b_2=3: no. a_2=2 vs b_1=1: yes -> 1. H=1 YES!
# (0,2,0)=[2,2], (0,1,1)=[2,3]: a_1=2 vs b_2=3: no. a_2=2 vs b_1=2: no -> 0. H=0 YES!
# (1,0,1)=[1,3], (0,1,1)=[2,3]: a_1=1 vs b_2=3: no. a_2=3 vs b_1=2: yes -> 1. H=1 YES!
# (1,0,1)=[1,3], (1,0,1)=[1,3]: a_1=1 vs b_2=3: no. a_2=3 vs b_1=1: yes -> 1. H=1 YES!
# (1,1,0)=[1,2], (1,0,1)=[1,3]: a_1=1 vs b_2=3: no. a_2=2 vs b_1=1: yes -> 1. H=1 YES!

# CHECKING ALL:
print("\n\nTesting H = #{i : a_i > b_{d+1-i}} for d=2:")
all_ok = True
for (c, cp), h in sorted(data.items()):
    # Build sorted words
    word_c = [1]*c[0] + [2]*c[1] + [3]*c[2]
    word_cp = [1]*cp[0] + [2]*cp[1] + [3]*cp[2]
    d = len(word_c)
    count = sum(1 for i in range(d) if word_c[i] > word_cp[d-1-i])
    if count != h:
        print(f"  FAIL: H({c},{cp})={h}, count={count}")
        all_ok = False
print(f"  Result: {all_ok}")

