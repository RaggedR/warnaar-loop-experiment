"""
Direct proof of the Adjugate Monomial Theorem.

Instead of using the Neumann series, prove directly that
  (I - A(x)) * D(x) = -(x^3 - 1) * I
where D(x)[c,c'] = x^{EMD(c,c')}.

This is equivalent to:
  D(x) - A(x) * D(x) = (1 - x^3) * I

i.e., for all c, c':
  x^{EMD(c,c')} - sum_{c''} A(x)[c,c''] * x^{EMD(c'',c')} = (1-x^3) * delta_{c,c'}

The LHS is:
  x^{EMD(c,c')} - sum_{J nonempty subset I_c} (-1)^{|J|-1} x^{|J|} * x^{EMD(c(J),c')}
= x^{EMD(c,c')} - sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}

By the Bellman equation, for the minimizing J, |J| + EMD(c(J),c') = EMD(c,c').
For non-minimizing J (including J = {0,1,2}), |J| + EMD(c(J),c') > EMD(c,c').

But we need EXACT cancellation, not just inequality.
"""

# The correct approach: verify the matrix identity (I-A)*D = (1-x^3)*I directly.

# For d=1: A = x*P, D_{ij} = x^{d_ij} where d_ij is clockwise distance
# (I - xP) * D = D - xPD
# D_{ij} = x^{d_ij}, (PD)_{ij} = D_{(i-1)j} = x^{d_{(i-1)j}}
# d_{(i-1)j} = d_ij - 1 if d_ij > 0, else d_{(i-1)j} = 2 (when d_ij = 0, meaning i=j)
# 
# Wait: d_{ij} is the clockwise distance from i to j.
# d_{(i-1)j} = d_{ij} + 1 mod 3 = ?
# Actually P shifts: (Pv)_i = v_{i-1}. So P_{ij} = delta_{i-1,j}.
# (PD)_{ij} = sum_k P_{ik} D_{kj} = D_{(i-1)j} = x^{d((i-1),j)}
# d(i-1, j) = (j - (i-1)) mod 3 (in clockwise metric: steps from i-1 to j clockwise)
# d(i, j) = (j - i) mod 3
# d(i-1, j) = (j - i + 1) mod 3

# So (D - xPD)_{ij} = x^{d(i,j)} - x * x^{d(i-1,j)} = x^{d(i,j)} - x^{1 + d(i-1,j)}
# When i = j: d(i,j) = 0, d(i-1,j) = d(i-1,i) = 1. So = 1 - x^2.
#   Hmm, 1 - x^2 is NOT 1 - x^3. 

# Wait, I'm computing d(i-1, i) = (i - (i-1)) mod 3 = 1 mod 3 = 1.
# So D_{(i-1),i} = x^1. And x * x^1 = x^2.
# Entry = 1 - x^2. But we need 1 - x^3. Something is wrong with my D.

# OH WAIT. For d=1, the matrix D should have EMD as the clockwise transport distance,
# not just the cyclic distance. The EMD of (0,0,1) to (1,0,0) is 1 (moving mass from 
# position 2 to position 0, which is 1 step clockwise).
# But the permutation matrix A = x*P permutes profiles, not positions.

# Let me recompute D for d=1.
# Profiles: (0,0,1), (0,1,0), (1,0,0)
# EMD((0,0,1), (0,0,1)) = 0
# EMD((0,0,1), (0,1,0)) = 3*max(0, 1-0, 0-0) + (0-0) - (1-0) = 3 - 1 = 2
# EMD((0,0,1), (1,0,0)) = 3*max(0, 0-0, 0-1) + (1-0) - (0-0) = 0 + 1 = 1

# A(x) for d=1:
# c=(0,0,1): I_c = {2}. J={2}: c({2}) = (1,0,0). A[(0,0,1),(1,0,0)] = x
# c=(0,1,0): I_c = {1}. J={1}: c({1}) = (0,0,1). A[(0,1,0),(0,0,1)] = x
# c=(1,0,0): I_c = {0}. J={0}: c({0}) = (0,1,0). A[(1,0,0),(0,1,0)] = x

# So A = | 0 0 x |   and D = | 1  x^2  x |
#        | x 0 0 |           | x  1    x^2|
#        | 0 x 0 |           | x^2 x   1  |

# (I-A)*D = (D - AD):
# Let's compute AD:
# (AD)_{00} = 0*1 + 0*x + x*x^2 = x^3
# (AD)_{01} = 0*x^2 + 0*1 + x*x = x^2
# (AD)_{02} = 0*x + 0*x^2 + x*1 = x
# So AD row 0 = [x^3, x^2, x]

# D row 0 = [1, x^2, x]
# (D-AD) row 0 = [1-x^3, 0, 0] = (1-x^3) * [1, 0, 0]
# 
# (AD)_{10} = x*1 + 0*x + 0*x^2 = x
# (AD)_{11} = x*x^2 + 0*1 + 0*x = x^3
# (AD)_{12} = x*x + 0*x^2 + 0*1 = x^2
# AD row 1 = [x, x^3, x^2]
# D row 1 = [x, 1, x^2]
# (D-AD) row 1 = [0, 1-x^3, 0] = (1-x^3) * [0, 1, 0]
# 
# PERFECT! (I-A)*D = (1-x^3)*I for d=1.

# Now the general proof:
# We need (I-A)*D = (1-x^3)*I
# Entry (c,c'): D_{cc'} - (AD)_{cc'} = (1-x^3) * delta_{cc'}
# 
# (AD)_{cc'} = sum_{c''} A_{c,c''} * D_{c'',c'}
#            = sum_J (-1)^{|J|-1} x^{|J|} * x^{EMD(c(J),c')}
#            = sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}

# So the equation becomes:
# x^{EMD(c,c')} - sum_J (-1)^{|J|-1} x^{|J|+EMD(c(J),c')} = (1-x^3)*delta_{cc'}

# REARRANGING:
# x^{EMD(c,c')} + sum_J (-1)^{|J|} x^{|J|+EMD(c(J),c')} = (1-x^3)*delta_{cc'}

# The LHS is an alternating sum involving all nonempty subsets J of I_c.
# We can include J=emptyset with x^{0+EMD(c,c')} = x^{EMD(c,c')} and (-1)^0 = 1.
# So LHS = sum_{J subset I_c} (-1)^{|J|} x^{|J|+EMD(c(J),c')}
# where c(emptyset) = c and |emptyset| = 0.

# This is the INCLUSION-EXCLUSION form!
# sum_{J subset I_c} (-1)^{|J|} x^{|J|+EMD(c(J),c')}

# For this to equal (1-x^3)*delta_{cc'}, we need:
# Case c = c': LHS = 1 - x^3
# Case c != c': LHS = 0

# Since EMD(c(J), c') >= 0 and |J| >= 0, each term is a monomial x^{something}.
# The inclusion-exclusion must cancel to give 0 (when c != c') or 1-x^3 (when c = c').

# KEY INSIGHT: |J| + EMD(c(J), c') depends only on the "excess transport" beyond 
# what's needed. By the Bellman equation, the minimum of this over J is EMD(c,c').

# For c = c': EMD(c,c) = 0, and EMD(c(J),c) = |J| (by our proved lemma).
# So each term is (-1)^{|J|} * x^{|J| + |J|} = (-1)^{|J|} * x^{2|J|}.
# Hmm, that gives sum (-1)^{|J|} x^{2|J|}, not 1 - x^3.

# Wait, EMD(c(J), c) is NOT |J|. |J| = EMD(c, c(J)), not EMD(c(J), c).
# The EMD is NOT symmetric! EMD(c, c') != EMD(c', c) in general for clockwise metric.

# For d=1:
# EMD((0,0,1), (1,0,0)) = 1 (move from 2 to 0, clockwise distance 1)
# EMD((1,0,0), (0,0,1)) = 2 (move from 0 to 2, clockwise distance 2)

# So for c = (0,0,1): I_c = {2}, only J = {2}.
# c({2}) = (1,0,0). |{2}| = 1.
# Term: (-1)^1 x^{1 + EMD((1,0,0), (0,0,1))} = -x^{1+2} = -x^3
# Total LHS = x^0 + (-x^3) = 1 - x^3. CORRECT!

# For c=(0,1,1): I_c = {1,2}. J can be {1}, {2}, {1,2}.
# c({1}) = (0,0,2): EMD((0,0,2), c') needs to be computed for each c'.
# c({2}) = (1,0,1-1)... wait, let me use the actual formula for d=1.
# Oh wait, d=1 has only 3 profiles and each has exactly 1 nonzero entry, so I_c has exactly 1 element.

# Let me do d=2 instead.
def emd_cw(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def shifted_profile_fn(c, J):
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

d = 2
profs = [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

print(f"Verifying (I-A)*D = (1-x^3)*I for d={d}")
print(f"Using inclusion-exclusion: sum_J (-1)^|J| x^(|J|+EMD(c(J),c')) = (1-x^3)*delta_cc'")
print()

from collections import defaultdict

for c in profs:
    for cp in profs:
        I_c = [i for i in range(3) if c[i] > 0]
        # Sum over all subsets J of I_c (including empty set)
        total = defaultdict(int)  # power -> coefficient
        for mask in range(1 << len(I_c)):
            J = tuple(I_c[i] for i in range(len(I_c)) if mask & (1 << i))
            cJ = shifted_profile_fn(c, J) if J else c
            if all(ci >= 0 for ci in cJ):
                sign = (-1)**len(J)
                emd_val = emd_cw(cJ, cp)
                power = len(J) + emd_val
                total[power] += sign
        
        # Convert to polynomial string
        terms = sorted(total.items())
        nonzero = [(p, coeff) for p, coeff in terms if coeff != 0]
        
        if c == cp:
            expected = [(0, 1), (3, -1)]  # 1 - x^3
        else:
            expected = []  # 0
        
        match = (nonzero == expected)
        if not match:
            poly_str = " + ".join(f"{coeff}*x^{p}" for p, coeff in nonzero) or "0"
            exp_str = " + ".join(f"{coeff}*x^{p}" for p, coeff in expected) or "0"
            print(f"  ({c},{cp}): got {poly_str}, expected {exp_str}")
        
print(f"Checking d=4...")
d = 4
profs = [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
all_match = True
for c in profs:
    for cp in profs:
        I_c = [i for i in range(3) if c[i] > 0]
        total = defaultdict(int)
        for mask in range(1 << len(I_c)):
            J = tuple(I_c[i] for i in range(len(I_c)) if mask & (1 << i))
            cJ = shifted_profile_fn(c, J) if J else c
            if all(ci >= 0 for ci in cJ):
                sign = (-1)**len(J)
                emd_val = emd_cw(cJ, cp)
                power = len(J) + emd_val
                total[power] += sign
        
        nonzero = [(p, coeff) for p, coeff in sorted(total.items()) if coeff != 0]
        expected = [(0, 1), (3, -1)] if c == cp else []
        if nonzero != expected:
            all_match = False
            poly_str = " + ".join(f"{coeff}*x^{p}" for p, coeff in nonzero)
            print(f"  FAIL ({c},{cp}): {poly_str}")

if all_match:
    print(f"  VERIFIED for all {len(profs)**2} entries!")

print(f"\nChecking d=7...")
d = 7
profs = [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]
all_match = True
for c in profs:
    for cp in profs:
        I_c = [i for i in range(3) if c[i] > 0]
        total = defaultdict(int)
        for mask in range(1 << len(I_c)):
            J = tuple(I_c[i] for i in range(len(I_c)) if mask & (1 << i))
            cJ = shifted_profile_fn(c, J) if J else c
            if all(ci >= 0 for ci in cJ):
                sign = (-1)**len(J)
                emd_val = emd_cw(cJ, cp)
                power = len(J) + emd_val
                total[power] += sign
        
        nonzero = [(p, coeff) for p, coeff in sorted(total.items()) if coeff != 0]
        expected = [(0, 1), (3, -1)] if c == cp else []
        if nonzero != expected:
            all_match = False

if all_match:
    print(f"  VERIFIED for all {len(profs)**2} entries!")

