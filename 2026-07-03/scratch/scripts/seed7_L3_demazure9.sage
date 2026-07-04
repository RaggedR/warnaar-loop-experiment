"""
Seed 7 Layer 3: Extended search for sum Q_n = D_w pattern.

CONFIRMED:
- sum_{0..0} Q_n = D_e for all tested d
- sum_{0..1} Q_n = D_{w_1} for d=2,4,5

Now search for sum_{0..2} Q_n = D_{w_2}.
For d=2: target = q^4 + q + 1 (sum=3)
For d=4: target has sum=21

Try longer words and also the LEVEL-RANK DUAL approach.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()

R = PolynomialRing(ZZ, 'q')
q = R.gen()

def extract_grade(wt, hw_wt):
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    d0 = coeffs.get(0, 0)
    d1 = coeffs.get(1, 0)
    d2 = coeffs.get(2, 0)
    d_delta = coeffs.get('delta', 0)
    n0 = d_delta
    n1 = (d1 - d0 + 3*d_delta) // 3
    n2 = (d2 - d0 + 3*d_delta) // 3
    return n0 + n1 + n2

def demazure_set(crystal, word):
    hw = crystal.module_generators[0]
    current = set([hw])
    for i in reversed(word):
        new_set = set()
        for b in current:
            x = b
            while x is not None:
                new_set.add(x)
                x = x.f(i)
        current = new_set
    return current

def demazure_char(crystal, word, hw_wt):
    D = demazure_set(crystal, word)
    char = R(0)
    for b in D:
        grade = extract_grade(b.weight(), hw_wt)
        char += q**grade
    return char


# ======================================================================
# d=2: Search for sum_{0..2} Q_n
# ======================================================================
print("="*70)
print("d=2, c=(1,1,0): sum_{0..2} Q_n = q^4 + q + 1 (sum=3)")
print("="*70)

hw2 = Lambda[0] + Lambda[1]
C2 = crystals.LSPaths(ct, hw2)
target_d2_N2 = 1 + q + q**4

# Search systematically
from itertools import product as iprod

found = False
for length in range(1, 10):
    if found:
        break
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        try:
            char = demazure_char(C2, word, hw2)
            if char == target_d2_N2:
                print(f"  MATCH: word={word}")
                found = True
                break
        except:
            pass
    if not found:
        print(f"  No match at length {length}")

# Also check N=3 for d=2
target_d2_N3 = 1 + q + q**4 + q**9
print(f"\nd=2: sum_{{0..3}} Q_n = {target_d2_N3} (sum=4)")

found = False
for length in range(1, 10):
    if found:
        break
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        try:
            char = demazure_char(C2, word, hw2)
            if char == target_d2_N3:
                print(f"  MATCH: word={word}")
                found = True
                break
        except:
            pass
    if not found:
        print(f"  No match at length {length}")

# ======================================================================
# d=4: Search for sum_{0..2} Q_n
# ======================================================================
print("\n" + "="*70)
print("d=4, c=(2,1,1): sum_{0..2} Q_n (sum=21)")
print("="*70)

hw4 = 2*Lambda[0] + Lambda[1] + Lambda[2]
C4 = crystals.LSPaths(ct, hw4)

target_d4_N2 = (1) + (2*q + q**2 + q**3) + (q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12)
print(f"Target = {target_d4_N2}  [sum={target_d4_N2(1)}]")

found = False
for length in range(1, 9):
    if found:
        break
    count = 0
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        count += 1
        if count > 50000:  # Safety limit
            break
        try:
            char = demazure_char(C4, word, hw4)
            if char(1) == target_d4_N2(1):  # First check sum
                if char == target_d4_N2:
                    print(f"  MATCH: word={word}")
                    found = True
                    break
                # else:
                #     print(f"  Sum matches but poly differs: word={word}")
        except:
            pass
    if not found:
        if count > 50000:
            print(f"  Stopped at length {length} (too many)")
        else:
            print(f"  No match at length {length}")


# ======================================================================
# The issue might be the GRADING. Let me try a different grading.
# ======================================================================
print("\n" + "="*70)
print("Trying DIFFERENT GRADINGS for d=2")
print("="*70)

# For d=2: Q_1 = q, Q_2 = q^4, Q_3 = q^9.
# sum_{0..2} Q_n = 1 + q + q^4.
# This does NOT look like a standard Demazure character with principal grading.

# What if the grading is NOT the principal grading?
# What if each alpha_i has a different grade?

# For A_2^(1), the Kac labels are a_0=a_1=a_2=1.
# The principal grading gives deg(alpha_i) = 1 for all i.
# But we could use a different grading:
# deg(alpha_0) = d (or t = d+3, or ...)
# deg(alpha_1) = 1
# deg(alpha_2) = 1

# For the "level-d" grading: the cylindric partition of profile c
# on a cylinder of width t = d+k has weight equal to the
# number of boxes. Each box corresponds to a root alpha_i,
# and different roots might have different "sizes" in terms of boxes.

# Actually, let me try the WEYL VECTOR grading:
# deg(alpha_i) = <rho, alpha_i^vee> = 1 for all i (for A_2^(1), rho_fin)
# That's the same as principal.

# Or the HOMOGENEOUS grading:
# deg(alpha_0) = 1, deg(alpha_1) = 0, deg(alpha_2) = 0.
# Already checked - too coarse.

# Let me try a CUSTOM grading motivated by the cylindric partition structure.
# For a cylindric partition of profile c = (c_0, c_1, c_2) on a cylinder
# of width t = d + 3, each "strip" i has width c_i.
# The natural grading from the cylinder might be:
# deg(alpha_i) = ??? related to the position on the cylinder.

# Actually, the STRING function might give the right answer.
# For LS paths, there's a "string parametrization" that's related
# to the Littelmann path model.

# Let me try: for each crystal element, compute the weight components
# and try to find a linear combination that matches the cylindric partition weight.

# For d=2, the cylindric partitions with max=1 are counted by g_1.
# g_1 = F_{c,1} - 1 = 2q + 2q^2 + 2q^3 + ... (coefficient stabilizes at 2)
# These are triples (a_0, a_1, a_2) with constraints from profile (1,1,0):
# a_0 >= a_1, a_1 >= a_2 + 0 = a_2, a_2 >= a_0 - 1
# i.e., a_0 >= a_1 >= a_2 >= a_0 - 1.
# Weight = a_0 + a_1 + a_2.

# For a_0 = 1: (1,1,0), (1,1,1) -> weights 2, 3
# For a_0 = 2: (2,1,1), (2,2,1), (2,2,2) -> weights 4, 5, 6 -> wait, need a_2 >= 1
#   Actually a_2 >= a_0-1 = 1, a_2 <= a_1 <= a_0 = 2
#   (2,2,1), (2,2,2), (2,1,1) - check a_1 >= a_2: (2,1,1) ✓, (2,2,1) ✓, (2,2,2) ✓
#   weights: 4, 5, 6
# For a_0 = n: a_2 >= n-1, a_2 <= a_1 <= n
#   Options: (n, n-1, n-1), (n, n, n-1), (n, n, n) -> weights 3n-2, 3n-1, 3n
#   But actually a_1 can range from a_2 to n, and a_2 from n-1 to a_1.
#   For a_2 = n-1: a_1 from n-1 to n: (n, n-1, n-1) wt=3n-2, (n, n, n-1) wt=3n-1
#   For a_2 = n: a_1 = n: (n, n, n) wt=3n
#   3 options for each a_0 = n >= 1, but only 2 for n=1 since a_2=0 or 1.
# Wait for n=1: a_2 >= 0, a_2 <= a_1 <= 1
#   (1,0,0), (1,1,0), (1,1,1) -> weights 1, 2, 3
# But check_interlace requires a_0 >= a_1: ✓, a_1 >= a_2: ✓, a_2 >= a_0 - c_0 = a_0 - 1.
# For (1,0,0): a_2=0 >= 1-1=0 ✓. Weight=1.
# So g_1 has coefficient 1 at q^1, not 0! Let me recount.

# Actually I'm confused. Let me just re-run the enumeration for g_1 with d=2.
# From the output: F_{c,1} for d=2, c=(1,1,0) starts: 1, 2, 2, 2, 2, ...
# So g_1 = F_{c,1} - 1 starts: 0, 1, 1, 1, 1, 1, ...
# No wait, the output said: F_{c,1} = {0: 1, 1: 2, 2: 2, 3: 2, ...}
# This means F_{c,1}(q) = 1 + 2q + 2q^2 + 2q^3 + ...
# g_1 = F_{c,1} - 1 = 2q + 2q^2 + ...? NO: F_{c,0} = 1, g_1 = F_{c,1} - F_{c,0}
# The coefficient of q^0 in F_{c,1} is 1, and in F_{c,0} is 1, so g_1(q=0)=0.
# g_1 = (2-1)q + (2-0)q^2 + ... = q + 2q^2 + 2q^3 + ...
# Wait no. F_{c,0} = sum over CPs with max=0 = just the empty partition = 1.
# F_{c,1} = sum over CPs with max<=1. At q^0: just the empty CP = 1.
# At q^1: CPs with weight 1 and max<=1.

# For c=(1,1,0), max<=1: parts of each lambda^i are at most 1.
# Weight 1: one of the a_i = 1, others 0.
# (1,0,0): check a_0 >= a_1: 1>=0 ✓, a_1 >= a_2: 0>=0 ✓, 
#           a_2 >= a_0 - c_0 = 1-1 = 0: 0>=0 ✓. Valid!
# (0,1,0): a_0 >= a_1: 0>=1? NO. Invalid.
# (0,0,1): a_1 >= a_2: 0>=1? NO. Invalid.
# So at weight 1: only (1,0,0). But F_{c,1} has coefficient 2 at q^1.
# Hmm, that's odd. Let me recheck the interlacing.

# Wait, I might have the interlacing backwards.
# From the tex: lambda^i_j >= lambda^{i+1}_{j + c_{i+1}}
# So for c = (c_0, c_1, c_2) = (1, 1, 0):
# i=0: lambda^0_j >= lambda^1_{j + c_1} = lambda^1_{j+1}
# i=1: lambda^1_j >= lambda^2_{j + c_2} = lambda^2_{j+0} = lambda^2_j
# i=2 (cyclic): lambda^2_j >= lambda^0_{j + c_0} = lambda^0_{j+1}

# For one-row partitions: lambda^i = (1^{a_i}) means lambda^i_j = 1 if j<=a_i, 0 else.
# Condition i=0: lambda^0_j >= lambda^1_{j+1}: for j=1: a_0>=1 implies 1>=lambda^1_2.
#   If a_1 >= 2: lambda^1_2 = 1, need lambda^0_1 = 1, i.e., a_0 >= 1. OK for a_0>=1.
#   More precisely: a_0 >= a_1 - 1? No: lambda^0_j >= lambda^1_{j+1}
#   This means for all j: if lambda^1_{j+1} = 1 (i.e., j+1 <= a_1), then lambda^0_j = 1.
#   So a_0 >= a_1 - 1... wait: if a_1 = 2, then lambda^1_2 = 1, need lambda^0_1 = 1 (a_0>=1),
#   and lambda^1_1 = 1, need lambda^0_0 = 1... but j starts at 1.
#   For j=1: lambda^0_1 >= lambda^1_2. If a_1>=2, need a_0>=1.
#   For j=a_1-1: lambda^0_{a_1-1} >= lambda^1_{a_1}=1. Need a_0 >= a_1-1.
#   Wait, lambda^1_{a_1} = 1, and we need lambda^0_{a_1-1} >= 1, so a_0 >= a_1-1.
#   Hmm, actually the shift is different. Let me be very precise.

# The condition is: for FIXED (i, j), lambda^i_j >= lambda^{(i+1) mod 3}_{j + c_{(i+1) mod 3}}
# c = (c_0, c_1, c_2) = (1, 1, 0). Using 0-indexing for the composition.

# For i=0: shift by c_1=1. lambda^0_j >= lambda^1_{j+1} for all j>=1.
#   This means: if a_1 >= j+1, then lambda^1_{j+1}=1, need lambda^0_j=1, i.e., a_0 >= j.
#   The binding constraint is j = a_1: need a_0 >= a_1 (since shift is 1, lambda^0_j >= lambda^1_{j+1}).
#   Wait no: the condition is for ALL j >= 1. The tightest is the largest j where lambda^1_{j+1}=1.
#   lambda^1_{j+1}=1 when j+1 <= a_1, i.e., j <= a_1-1.
#   For j = a_1-1: lambda^0_{a_1-1} >= lambda^1_{a_1} = 1. Need a_0 >= a_1-1.
#   Hmm wait, lambda^1_{a_1} = 1 (last part), and j = a_1-1, so we need lambda^0_{a_1-1} >= 1.
#   This requires a_0 >= a_1-1.
#   Actually this isn't right. lambda^1 = (1^{a_1}) means lambda^1_j = 1 for j=1,...,a_1 and 0 for j>a_1.
#   lambda^0_j >= lambda^1_{j+1}.
#   For j such that j+1 <= a_1 (i.e., j <= a_1-1): lambda^1_{j+1} = 1, need lambda^0_j >= 1, need a_0 >= j.
#   Tightest: j = a_1-1, need a_0 >= a_1-1.
#   Also for j = a_1: lambda^1_{a_1+1} = 0, no constraint.

# So the constraint from i=0 is: a_0 >= a_1 - 1.

# For i=1: shift by c_2=0. lambda^1_j >= lambda^2_{j+0} = lambda^2_j for all j.
#   This gives a_1 >= a_2.

# For i=2: shift by c_0=1. lambda^2_j >= lambda^0_{j+1} for all j.
#   Tightest: j = a_0-1, need a_2 >= a_0-1.

# Summary: a_0 >= a_1-1, a_1 >= a_2, a_2 >= a_0-1.
# This is different from what I had before!

# Valid weight-1 CPs: (a_0, a_1, a_2) with sum=1 and constraints.
# (1,0,0): a_0>=0-1=-1 ✓, 0>=0 ✓, 0>=1-1=0 ✓. Valid.
# (0,1,0): a_0>=1-1=0 ✓, 1>=0 ✓, 0>=0-1=-1 ✓. Valid!
# (0,0,1): 0>=0-1=-1 ✓, 0>=1? NO. Invalid.

# So g_1[q^1] = 2. Matches F_{c,1} coeff at q^1 being 2 (minus F_{c,0} coeff at q^1 being 0).
# Great, this is consistent.

# So the CORRECT interlacing is:
# For profile c = (c_0, c_1, ..., c_{k-1}):
#   lambda^i_j >= lambda^{(i+1) mod k}_{j + c_{(i+1) mod k}}
# The shift c_{i+1} (NOT c_i!) goes with the NEXT partition.

# Now back to the main computation. Let me check if the interlacing
# in my enumeration code was correct.

# In the compute_Q_direct function:
# check_interlace(l0, l1, c[1]) checks l0_j >= l1_{j+c[1]}
# check_interlace(l1, l2, c[2]) checks l1_j >= l2_{j+c[2]}
# check_interlace(l2, l0, c[0]) checks l2_j >= l0_{j+c[0]}
# This matches the definition. Good.

# The Q values are correct. Now let me focus on the search.
# For d=2: sum_{0..2} Q_n = 1 + q + q^4.
# This has GAPS (no q^2, q^3 terms). This pattern is unusual for a Demazure character.

# Key observation: For d=2, Q_n = q^{n^2}. So sum_{0..N} Q_n = sum_{n=0}^N q^{n^2}.
# This is a THETA FUNCTION partial sum!
# It's 1 + q + q^4 + q^9 + q^16 + ...
# For N -> infinity, this approaches theta_3(0, q) / 2 (or similar).

# Demazure characters are characters of finite-dimensional modules.
# They are polynomials with contiguous support (mostly).
# The partial sum 1 + q + q^4 has gaps -- it's NOT contiguous.
# This means it is NOT a Demazure character with the principal grading.

# But it IS a Demazure character with a DIFFERENT grading!
# If we grade alpha_0 with weight 1, alpha_1 with weight 0, alpha_2 with weight 0,
# then D_{s2s0} has size 3 with homogeneous grades {0,0,1} -> 1 + 1 + q.
# Not what we want.

# What if we use a DIFFERENT crystal? Not B(Lambda), but B(Lambda) tensor B(Lambda)?
# Or maybe the tensor product crystal?

# Actually, let me reconsider. The issue is that Q_n for d=2 is extremely simple:
# Q_n = q^{n^2}. The base is 1, so Q_n(1) = 1.
# This is a degenerate case. The non-trivial cases are d >= 4.

# For d=4, the match works at N=1. Let me search harder for N=2.
# The target polynomial is:
# 1 + 2q + q^2 + 2q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

# Sum = 21. Which Demazure characters have sum 21?
# From the d=4 output, none of the listed ones have sum exactly 21.
# D_{s0s1s2} = 22, D_{s0s2s1} = 22, D_{s1s0s2} = 27, D_{s2s0s1} = 27.

# The closest sum is 22. And 22 - 1 = 21. Maybe:
# sum_{0..2} Q_n = D_{w_2} - D_{w_?}  for some pair?
# But that breaks the nice pattern.

# OR: maybe the matching word w_1 was wrong. Let me re-examine.
# For d=4: sum_{0..1} Q_n = 1 + 2q + q^2 + q^3.
# D_{s1s2} = 1 + 2q + q^2 + q^3. MATCHES.
# D_{s2s1} = 1 + 2q + q^2 + q^3. Also matches! (Same polynomial.)

# Interesting: D_{s1s2} = D_{s2s1} for this highest weight.
# That's because the highest weight 2L0+L1+L2 is symmetric under s_1 <-> s_2
# (since the coefficients of L1 and L2 are equal).

# The word [1,2] has the OPPOSITE COXETER ORDERING from what I expected.
# In the Coxeter element c = s_0 s_1 s_2, the word [1,2] is a subword.
# But for translation elements, we typically use powers of the Coxeter element.

# Let me think about this differently.
# For the Weyl group of A_2^(1):
# The translation element t_alpha takes Lambda to Lambda - <Lambda, alpha^vee> delta.
# The relevant translation for "depth n" Demazure modules is t_{-n*omega}
# where omega is a specific finite Weyl vector.

# For A_2^(1) with highest weight Lambda:
# The depth-n Demazure module is D_{w_0 t_n}(Lambda) where w_0 is the longest
# element of the finite Weyl group and t_n is a translation.

# For A_2: w_0 = s_1 s_2 s_1 = s_2 s_1 s_2 (length 3).
# Translation: t_{omega_1} in A_2^(1) has reduced word...

# Actually, the translation element in A_2^(1) is:
# t_1 = s_0 s_1 s_2 s_1  (translation by omega_1, the first fundamental coweight)
# t_2 = s_0 s_2 s_1 s_2  (translation by omega_2)

# For the Demazure module at depth n of V(Lambda):
# D_w = D_{t_n}(Lambda) where t_n is a specific translation.

# But in A_2^(1), translation by the null root is:
# t_0 = (s_0 s_1 s_2)^2 s_0 or something like that.

# Let me try: the Demazure module that gives the "first n columns"
# of a cylindric partition might use the word:
# w_n = (s_{i_1} s_{i_2} ... s_{i_l})^n
# where the product is a Coxeter-type element.

# For d=4, the match at N=1 used word [1,2] (= s_1 s_2).
# So w_1 = s_1 s_2.
# Then w_2 might be (s_1 s_2)^2 = [1,2,1,2].
# Or it might involve s_0: w_2 = s_1 s_2 s_0 = [1,2,0].

# Let me check these:
print("="*70)
print("d=4: Testing specific word patterns for N=2")
print("="*70)

hw4 = 2*Lambda[0] + Lambda[1] + Lambda[2]
C4 = crystals.LSPaths(ct, hw4)

target_d4_N2 = (1) + (2*q + q**2 + q**3) + (q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12)
print(f"Target = {target_d4_N2}  [sum={target_d4_N2(1)}]")

candidate_words = [
    ([1,2,1,2], "(s1s2)^2"),
    ([1,2,0], "s1s2s0"),
    ([0,1,2], "s0s1s2"),
    ([2,1,0], "s2s1s0"),
    ([1,2,0,1], "s1s2s0s1"),
    ([1,2,0,2], "s1s2s0s2"),
    ([1,2,1,0], "s1s2s1s0"),
    ([0,1,2,1], "s0s1s2s1"),
    ([0,2,1,2], "s0s2s1s2"),
    ([2,1,2,0], "s2s1s2s0"),
    ([1,0,2,1], "s1s0s2s1"),
    ([2,0,1,2], "s2s0s1s2"),
    ([1,2,0,1,2], "s1s2s0s1s2"),
    ([0,1,2,0,1], "s0s1s2s0s1"),
    ([2,1,0,2,1], "s2s1s0s2s1"),
    ([0,2,1,0,2], "s0s2s1s0s2"),
    ([1,2,1,0,2], "s1s2s1s0s2"),
    ([1,2,0,2,1], "s1s2s0s2s1"),
    ([2,1,2,0,1], "s2s1s2s0s1"),
]

for word, name in candidate_words:
    try:
        char = demazure_char(C4, word, hw4)
        marker = " <-- SUM MATCH!" if char(1) == target_d4_N2(1) else ""
        if char == target_d4_N2:
            marker = " <== EXACT MATCH!!"
        print(f"  D_{name} = sum={char(1)}{marker}")
        if char(1) == target_d4_N2(1):
            print(f"    char = {char}")
            print(f"    target = {target_d4_N2}")
            print(f"    equal = {char == target_d4_N2}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# Maybe the grading is wrong. Let me try: instead of principal grading
# (each alpha_i has grade 1), try a grading where alpha_0 has grade d
# and alpha_1, alpha_2 have grade 1.
# ======================================================================
print("\n" + "="*70)
print("Trying WEIGHTED grading: deg(alpha_0) = t, deg(alpha_1,2) = 1")
print("where t = d + k = 4 + 3 = 7")
print("="*70)

d = 4
t = 7

def weighted_grade(wt, hw_wt, w0=1, w1=1, w2=1):
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    d0 = coeffs.get(0, 0)
    d1 = coeffs.get(1, 0)
    d2 = coeffs.get(2, 0)
    d_delta = coeffs.get('delta', 0)
    n0 = d_delta
    n1 = (d1 - d0 + 3*d_delta) // 3
    n2 = (d2 - d0 + 3*d_delta) // 3
    return w0*n0 + w1*n1 + w2*n2

def demazure_char_weighted(crystal, word, hw_wt, w0, w1, w2):
    D = demazure_set(crystal, word)
    char = R(0)
    for b in D:
        grade = weighted_grade(b.weight(), hw_wt, w0, w1, w2)
        if grade >= 0:
            char += q**grade
        else:
            return None
    return char

# Try various weight combinations
for w0 in [1, 2, 3, 4, 5, 7]:
    for w1 in [1, 2]:
        for w2 in [1, 2]:
            char = demazure_char_weighted(C4, [1,2], hw4, w0, w1, w2)
            if char is not None and char(1) == 5:  # D_{s1s2} should still have 5 elements
                char_minus_1 = char - 1
                Q1 = 2*q + q**2 + q**3
                if char_minus_1 == Q1:
                    print(f"  w=({w0},{w1},{w2}): D_{{s1s2}}-1 = {char_minus_1} == Q_1? True")
                    # Now check if N=2 works with this grading
                    for word2, name2 in candidate_words:
                        char2 = demazure_char_weighted(C4, word2, hw4, w0, w1, w2)
                        if char2 is not None and char2(1) == target_d4_N2(1):
                            if char2 == target_d4_N2:
                                print(f"    AND D_{name2} = target_N2 with w=({w0},{w1},{w2})!!")
                            else:
                                pass  # print(f"    D_{name2}: sum matches but poly differs")


