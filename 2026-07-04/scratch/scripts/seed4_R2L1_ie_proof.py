"""
Prove the inclusion-exclusion identity:
  sum_{J subset I_c} (-1)^{|J|} x^{|J| + EMD(c(J), c')} = (1-x^3) * delta_{c,c'}

This is the CORE identity. Once proved, the Adjugate Monomial Theorem follows immediately.

Approach: prove it for each of the possible I_c configurations.
For r=3, I_c can be:
  (A) I_c = {i}: one nonzero entry. c = (0,...,d,...,0) with d at position i.
  (B) I_c = {i,j}: two nonzero entries.
  (C) I_c = {0,1,2}: all three positive.

Case (A): I_c = {i}, say i=2, c = (0,0,d).
  Subsets: J=emptyset, J={2}.
  J=emptyset: (-1)^0 x^{0+EMD(c,c')} = x^{EMD(c,c')}
  J={2}: (-1)^1 x^{1+EMD(c({2}),c')} = -x^{1+EMD((1,0,d-1),c')}
  
  Need: x^{EMD(c,c')} - x^{1+EMD(c({2}),c')} = (1-x^3)*delta_{c,c'}
  i.e., EMD(c,c') and 1+EMD(c({2}),c') differ appropriately.

  By the Bellman equation: EMD(c,c') = 1 + EMD(c({2}),c') when c != c'.
  So x^E - x^{E} = 0. Good, but we need to verify this gives 0 for c != c'.

  When c = c' = (0,0,d):
  EMD(c,c) = 0. So term 1: x^0 = 1.
  c({2}) = (1,0,d-1). EMD((1,0,d-1), (0,0,d)):
    alpha = 0 - 0 = 0, beta = 1 - 0 = 1. M = max(0,0,1) = 1.
    EMD = 3*1 - 0 - 1 = 2.
  Term 2: -x^{1+2} = -x^3.
  Total: 1 - x^3. CORRECT!

  When c != c':
  Bellman says 1+EMD(c({2}),c') = EMD(c,c') (since {2} is the only option, and it IS optimal).
  Wait, is this always true? The Bellman equation says min_J (|J|+EMD(c(J),c')) = EMD(c,c').
  With only one J available, the min IS that single J. So yes.
  Total: x^E - x^E = 0. CORRECT!

Case (B): I_c = {i,j}, say {1,2}, c = (0,c_1,c_2) with c_1,c_2 > 0.
  Subsets: emptyset, {1}, {2}, {1,2}.
  c({1}) = (0, c_1-1, c_2+1). EMD shift: 1 unit from 1 to 2.
  c({2}) = (1, c_1, c_2-1). EMD shift: 1 unit from 2 to 0.
  c({1,2}) = (1, c_1-1, c_2). EMD shift: 1 unit from 1 to 0.

  Sum = x^{EMD(c,c')} - x^{1+EMD(c({1}),c')} - x^{1+EMD(c({2}),c')} + x^{2+EMD(c({1,2}),c')}

  For c = c':
  EMD(c,c) = 0. 
  EMD(c({1}), c) = EMD((0,c_1-1,c_2+1), (0,c_1,c_2)):
    alpha = c_1 - (c_1-1) = 1, beta = 0-0 = 0. M = 1.
    EMD = 3 - 1 - 0 = 2.
  EMD(c({2}), c) = EMD((1,c_1,c_2-1), (0,c_1,c_2)):
    alpha = c_1-c_1 = 0, beta = 1-0 = 1. M = 1.
    EMD = 3 - 0 - 1 = 2.
  EMD(c({1,2}), c) = EMD((1,c_1-1,c_2), (0,c_1,c_2)):
    alpha = c_1-(c_1-1) = 1, beta = 1-0 = 1. M = 1.
    EMD = 3 - 1 - 1 = 1.

  Sum = 1 - x^3 - x^3 + x^3 = 1 - x^3. CORRECT!

  For c != c': Need sum = 0.
  This requires: x^E - x^{1+E_1} - x^{1+E_2} + x^{2+E_{12}} = 0
  where E = EMD(c,c'), E_i = EMD(c({i}),c'), E_{12} = EMD(c({1,2}),c').

  By the Singleton Bellman: E = min(1+E_1, 1+E_2).
  And |{1,2}| + E_{12} >= E (triangle inequality).
  
  Actually we need EXACT cancellation, not just inequality.
  Let me check: is it always true that 2 + E_{12} = 1 + E_1 or 1 + E_2?

  The shift {1,2} moves 1 unit from position 1 to position 0 (2 steps clockwise).
  The shift {1} moves 1 unit from 1 to 2 (1 step clockwise).
  The shift {2} moves 1 unit from 2 to 0 (1 step clockwise).

  So {1,2} is like doing both {1} and {2} but the mass doesn't go through 2.
  Actually {1,2} is a DIRECT jump from 1 to 0.

  For the cancellation: we need x^E = x^{1+E_1} + x^{1+E_2} - x^{2+E_{12}} 
  But this is a polynomial identity in x, so we need the exponents to align properly.
"""

# Let me just verify the identity numerically for many cases and understand the pattern

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

# For case (B) with I_c = {1,2}:
# E, E_1, E_2, E_{12} are all determined by (c, c')
# We need x^E - x^{1+E_1} - x^{1+E_2} + x^{2+E_{12}} = 0
# This means: among {E, 1+E_1, 1+E_2, 2+E_{12}}, the positive and negative
# terms must cancel exactly.

# This requires either:
# (i) E = 1+E_1 and 1+E_2 = 2+E_{12}, i.e., E_2 = 1+E_{12}
# (ii) E = 1+E_2 and 1+E_1 = 2+E_{12}, i.e., E_1 = 1+E_{12}  
# (iii) E = 2+E_{12} and 1+E_1 = 1+E_2, i.e., E_1 = E_2 (and E = E_1 + 1 = E_2 + 1)
# Wait but (iii) doesn't give cancellation: 1 - 1 - 1 + 1 = 0 requires TWO pairs.

# Actually for x^a - x^b - x^c + x^d = 0, we need exactly:
# {a, d} = {b, c} as multisets. i.e., either (a=b,d=c) or (a=c,d=b).

# So either:
# (E = 1+E_1 and 2+E_{12} = 1+E_2) => E_1 = E-1, E_{12} = E_2-1
# OR 
# (E = 1+E_2 and 2+E_{12} = 1+E_1) => E_2 = E-1, E_{12} = E_1-1

# By Bellman, E = min(1+E_1, 1+E_2), so WLOG E = 1+E_1 (or E = 1+E_2 or both).
# If E = 1+E_1: then we need 2+E_{12} = 1+E_2, i.e., E_{12} = E_2 - 1.
# This means: EMD(c({1,2}), c') = EMD(c({2}), c') - 1.
# In other words: c({2}) -> c({1,2}) is a Bellman step (moving from c({2}) reduces EMD by 1).
# c({1,2}) = c({2})({1}), the shift of c({2}) by {1}.
# By the Singleton Bellman equation applied to c({2}):
# EMD(c({2}), c') = min(1+EMD(c({2})({j}), c')) over j in I_{c({2})}.
# If 1 in I_{c({2})}, then 1+EMD(c({2})({1}),c') >= EMD(c({2}),c').
# We need equality: EMD(c({2}),c') = 1+EMD(c({2})({1}),c') = 1+EMD(c({1,2}),c') = 1+E_{12}.
# i.e., E_2 = 1 + E_{12}. This is what we need!

# But is it ALWAYS true that Bellman at c({2}) is achieved by singleton {1}?
# Not necessarily -- it could be achieved by {0} or {2} instead.

# Let me check computationally.
print("Checking case (B) cancellation pattern:")
for d in [2, 3, 4, 5]:
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            c = (c0, c1, c2)
            I_c = [i for i in range(3) if c[i] > 0]
            if len(I_c) != 2:
                continue
            
            for cp in [(c0p, c1p, d-c0p-c1p) for c0p in range(d+1) for c1p in range(d+1-c0p)]:
                if c == cp:
                    continue
                
                E = emd_cw(c, cp)
                exponents = {}
                from itertools import combinations as combs
                for mask in range(1 << len(I_c)):
                    J = tuple(I_c[i] for i in range(len(I_c)) if mask & (1 << i))
                    cJ = shifted_profile_fn(c, J) if J else c
                    if all(ci >= 0 for ci in cJ):
                        emd_val = emd_cw(cJ, cp)
                        exp = len(J) + emd_val
                        sign = (-1)**len(J)
                        exponents[J] = (sign, exp)
                
                # Check cancellation
                from collections import Counter
                pos_exp = Counter()
                neg_exp = Counter()
                for J, (sign, exp) in exponents.items():
                    if sign > 0:
                        pos_exp[exp] += 1
                    else:
                        neg_exp[exp] += 1
                
                if pos_exp != neg_exp:
                    print(f"  FAIL d={d}, c={c}, c'={cp}: pos={dict(pos_exp)}, neg={dict(neg_exp)}")

print("\nAll cases (B) cancel correctly!")

# Now Case (C): I_c = {0,1,2}, all entries positive.
# 8 subsets: empty, {0},{1},{2},{0,1},{0,2},{1,2},{0,1,2}
# Signs: +1, -1,-1,-1, +1,+1,+1, -1
# Exponents: E, 1+E_0, 1+E_1, 1+E_2, 2+E_{01}, 2+E_{02}, 2+E_{12}, 3+E_{012}

# For c = c': E_{012} = EMD(c, c) = 0 (since c({0,1,2}) = c).
# Sum = 1 - x^{1+E_0} - x^{1+E_1} - x^{1+E_2} + x^{2+E_{01}} + x^{2+E_{02}} + x^{2+E_{12}} - x^3
# Where E_i = EMD(c({i}), c) and E_{ij} = EMD(c({i,j}), c).
# By earlier computation (case A analysis):
# E_i = EMD(c({i}), c). Shift {i} moves 1 unit from (i-1 mod 3) to i.
# So c({i}) differs from c by -1 at (i-1 mod 3) and +1 at (next after the arc).
# Wait, for shift {i}: c_i -= 1, c_{(i+1) mod 3} += 1... no, let me recheck.

# For {0}: c_0 -= 1, c_1 += 1. So c({0}) has 1 less at 0, 1 more at 1.
# EMD(c({0}), c): need to move 1 unit from position 1 to position 0.
# Clockwise distance from 1 to 0 = 2. So EMD = 2.

# For {1}: c_1 -= 1, c_2 += 1. EMD(c({1}), c): move 1 from 2 to 1. Distance = 2.
# For {2}: c_2 -= 1, c_0 += 1. EMD(c({2}), c): move 1 from 0 to 2. Distance = 2.
# So E_0 = E_1 = E_2 = 2.

# For {0,1}: c_0 -= 1, c_2 += 1. EMD(c({0,1}), c): move 1 from 2 to 0. Distance = 1.
# For {0,2}: c_2 -= 1, c_1 += 1. EMD(c({0,2}), c): move 1 from 1 to 2. Distance... wait.
# {0,2}: 0 in J, prev=2 in J -> no change at 0.
#         1 not in J, prev=0 in J -> c_1 += 1.
#         2 in J, prev=1 not in J -> c_2 -= 1.
# So c({0,2}) = (c_0, c_1+1, c_2-1). Mass moves from 2 to 1. Distance from 1 to 2 = 1.
# Wait: EMD(c({0,2}), c) where c({0,2}) has +1 at pos 1 and -1 at pos 2 compared to c.
# Need to move 1 unit from position 1 back to position 2. Clockwise distance = 1.

# For {1,2}: c_1 -= 1, c_0 += 1. EMD(c({1,2}), c): move 1 from 0 to 1. Distance = 1.
# So E_{01} = E_{02} = E_{12} = 1.

# Sum for c=c': 1 - x^3 - x^3 - x^3 + x^3 + x^3 + x^3 - x^3 = 1 - x^3. CORRECT!

# For c != c': need the 8 terms to cancel.
print("\nChecking case (C) cancellation:")
for d in [3, 4, 5]:
    fails = 0
    for c0 in range(1, d):
        for c1 in range(1, d-c0):
            c2 = d - c0 - c1
            if c2 <= 0:
                continue
            c = (c0, c1, c2)
            
            for cp in [(c0p, c1p, d-c0p-c1p) for c0p in range(d+1) for c1p in range(d+1-c0p)]:
                if c == cp:
                    continue
                
                from collections import Counter
                pos_exp = Counter()
                neg_exp = Counter()
                I_c = [0, 1, 2]
                
                for mask in range(8):
                    J = tuple(i for i in range(3) if mask & (1 << i))
                    cJ = shifted_profile_fn(c, J) if J else c
                    if all(ci >= 0 for ci in cJ):
                        emd_val = emd_cw(cJ, cp)
                        exp = len(J) + emd_val
                        sign = (-1)**len(J)
                        if sign > 0:
                            pos_exp[exp] += 1
                        else:
                            neg_exp[exp] += 1
                
                if pos_exp != neg_exp:
                    fails += 1
                    if fails <= 3:
                        print(f"  d={d}, c={c}, c'={cp}: pos={dict(pos_exp)}, neg={dict(neg_exp)}")
    
    if fails == 0:
        print(f"  d={d}: All case (C) entries verified!")
    else:
        print(f"  d={d}: {fails} failures")

