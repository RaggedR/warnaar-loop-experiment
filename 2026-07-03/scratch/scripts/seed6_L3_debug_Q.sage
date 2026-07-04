"""
Debug: my Q computation gives Q_1 starting with -1, but Layer 2 says 
Q_1 for c=(3,2,2) is 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6.

The issue: my correct computation above (seed6_L3_Q1_check.sage) gives 
Q_1 = 2q + 3q^2 + ..., which starts at q^1, not q^0.

But my d9_d12 script gives Q_1 with a -1 at q^0 and 3 at q^1.
The difference is the constant term. Let me check.
"""

from sage.all import *

R = PowerSeriesRing(QQ, 'q', default_prec=20)
q = R.gen()

# From seed6_L3_Q1_check.sage (correct):
# Q_1 for c=(3,2,2), d=7, l=1:
# = (1-q) * [G_1 + e_1]
# where G_1 = F_{c,1} - 1 and e_1 = -q/(1-q)

# F_{c,1} for c=(3,2,2):
F1 = R(0)
c0, c1, c2 = 3, 2, 2
for w in range(20):
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    F1 += count * q**w

print(f"F_{{c,1}} = {F1}")
G1 = F1 - 1
print(f"G_1 = {G1}")

e1 = sum(-q**(j+1) for j in range(19))
print(f"e_1 = {e1}")

bracket = G1 + e1
print(f"bracket = G_1 + e_1 = {bracket}")

Q1_correct = ((1-q) * bracket).add_bigoh(20)
print(f"Q_1 (correct) = {Q1_correct}")

# From the d9_d12 script:
# The e_j formula: e_j = (-1)^j q^{j(j+1)/2} / (q;q)_j
# e_0 = 1, e_1 = -q / (1-q)
# G_0 = 1

# [z^1] = e_0 * G_1 + e_1 * G_0 = G_1 - q/(1-q)
# This should be: G_1 + e_1 (same as above). Let me check.

e0 = R(1)
# e_1 = -q^{1*2/2} / (q;q)_1 = -q / (1-q)
e1_formula = -q / (1-q)
print(f"\ne_1 from formula = {e1_formula.add_bigoh(20)}")
print(f"e_1 from series  = {e1}")
# These should match.

bracket_formula = e0 * G1 + e1_formula * R(1)
print(f"bracket formula = {bracket_formula.add_bigoh(20)}")

# Q_1 = (q^l;q^l)_1 * bracket = (1-q)*bracket
Q1_formula = ((1-q) * bracket_formula).add_bigoh(20)
print(f"Q_1 (formula) = {Q1_formula}")

# They match! So why does the d9_d12 script give different results?
# The issue must be in the CW recurrence for computing F_{c,n}.

# Let me check: the d9_d12 script computes F_{c,1} via CW, while 
# the Q1_check script computes it by direct enumeration. If they differ,
# the CW implementation is wrong.

# In the d9_d12 script, the CW recurrence is:
# F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} sum_{j=0}^n F_{c(J),j}

# For n=1, c=(3,2,2):
# I_c = {0, 1, 2} (all positive)
# Subsets J of I_c:

def shifted_profile(c, J):
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

c = (3, 2, 2)
Ic = {0, 1, 2}

print("\nCW shifts for c=(3,2,2):")
for mask in range(1, 8):
    J = frozenset(i for i in range(3) if mask & (1 << i))
    cp = shifted_profile(c, J)
    print(f"  J = {set(J)}, |J| = {len(J)}, c(J) = {cp}")

# OK the CW recurrence:
# F_{c,1} = sum_J (-1)^{|J|-1} q^{|J|} * (F_{c(J),0} + F_{c(J),1})
# = sum_J (-1)^{|J|-1} q^{|J|} * (1 + F_{c(J),1})
# 
# This is a SYSTEM: F_{c,1} depends on F_{c(J),1} for all shifted profiles.
# The system (I - A(q)) F_1 = b where b depends on F_{.,0} = 1.

# In the d9_d12 script, I solve this system. But maybe the CW formula 
# I derived is wrong?

# Let me verify against the known d=2 case.
# For d=2, c=(1,1,0):
# I_c = {0, 1}
# J = {0}: c(J) = shifted_profile((1,1,0), {0})
c22 = (1, 1, 0)
print(f"\nCW for c=(1,1,0), d=2:")
for mask in range(1, 4):
    J = frozenset(i for i in range(3) if mask & (1 << i) and c22[i] > 0)
    if len(J) == 0:
        continue
    cp = shifted_profile(c22, J)
    print(f"  J = {set(J)}, |J| = {len(J)}, c(J) = {cp}")

# Hmm wait, I_c for (1,1,0) is {0, 1} (c_2 = 0). So J ranges over nonempty subsets of {0,1}.
# J = {0}: c(J): i=0 in J, prev=2 not in J: c_0 - 1 = 0. i=1 not in J, prev=0 in J: c_1 + 1 = 2.
#   c(J) = (0, 2, 0).
# J = {1}: i=1 in J, prev=0 not in J: c_1 - 1 = 0. i=2 not in J, prev=1 in J: c_2 + 1 = 1.
#   c(J) = (1, 0, 1).
# J = {0,1}: i=0 in J, prev=2 not in J: c_0 - 1 = 0. i=1 in J, prev=0 in J: c_1 unchanged = 1.
#   i=2 not in J, prev=1 in J: c_2 + 1 = 1. c(J) = (0, 1, 1).

# CW for n=1:
# F_{(1,1,0),1} = (-1)^0 q * (1 + F_{(0,2,0),1})
#               + (-1)^0 q * (1 + F_{(1,0,1),1})
#               + (-1)^1 q^2 * (1 + F_{(0,1,1),1})

# The known answer: F_{(1,1,0),1}(q) = sum of q^w * count(w).
# count(0) = 1, count(w) = 2 for w >= 1.
# F = 1 + 2q + 2q^2 + ... = 1 + 2q/(1-q) = (1+q)/(1-q)

# So F_{(1,1,0),1} = (1+q)/(1-q).
# Let's check: F = 1 + 2q + 2q^2 + 2q^3 + ... = 1 + 2q/(1-q).

F_test = 1 + 2*q/(1-q)
print(f"F_{{(1,1,0),1}} = {F_test.add_bigoh(10)}")

# Now from the CW formula, substituting x = q:
# Previously computed: F_{(1,1,0),1} = -2x/(x-1) = 2x/(1-x) = 2q/(1-q)
# But direct computation gives F = 1 + 2q/(1-q) = (1+q)/(1-q).
# 
# DISCREPANCY: 2q/(1-q) vs (1+q)/(1-q).
# 
# 2q/(1-q) = 2q + 2q^2 + ... (missing the constant term 1)
# (1+q)/(1-q) = 1 + 2q + 2q^2 + ...
#
# The CW system gives 2q/(1-q), missing F_{c,0} = 1.
# This is because the CW system I set up computes F_{c,n} for n >= 1 
# relative to F_{c,0} = 1, which is the RHS.
# 
# So the CW system gives F_{c,1} - 1? Or F_{c,1} itself?
# Actually, let me re-examine the CW recurrence derivation.

# From the CW functional equation:
# F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
# with F_c(0,q) = 1 and F_c(y,0) = 1.

# Wait: F_c(0,q) = 1. So [y^0] F_c(y,q) = 1, which is F_{c,0} = 1. Good.

# [y^1]: F_{c,1} = sum_J (-1)^{|J|-1} [y^1] (F_{c(J)}(yq^s)/(1-yq^s))
# 
# We computed: [y^1] = q^s * sum_{j=0}^1 F_{c(J),j} = q^s * (1 + F_{c(J),1})
# 
# So: F_{c,1} = sum_J (-1)^{|J|-1} q^s * (1 + F_{c(J),1})
# 
# This is the correct recurrence. For c=(1,1,0):
# F_{(1,1,0),1} = q*(1 + F_{(0,2,0),1}) + q*(1 + F_{(1,0,1),1}) - q^2*(1 + F_{(0,1,1),1})
#
# If we set up the system correctly, the solution should include the constant 1.
# The RHS of the system is sum_J (-1)^{|J|-1} q^s * 1 = sum_J (-1)^{|J|-1} q^s
# (the contribution from F_{c(J),0} = 1).
#
# And the matrix equation is:
# F_{c,1} - sum_J (-1)^{|J|-1} q^s F_{c(J),1} = sum_J (-1)^{|J|-1} q^s
# i.e., (I - A(q))F_1 = b where b_c = sum_J (-1)^{|J|-1} q^{|J|}.

# My d9_d12 script computes the Neumann series approximation. The issue might be
# convergence or that S_{c,0} is handled incorrectly.

# Actually, in the d9_d12 script, I have:
# b[i] += coeff * S[cp, n-1]
# For n=1: S[cp, 0] = F_{cp, 0} = 1.
# So b[i] = sum_J sign * q^{|J|} * 1.
# And M[i,j] = delta_{ij} - sum_J sign * q^{|J|} (for j = comp_idx[cp]).

# This looks correct. Let me check whether the issue is in the Q computation,
# not the F computation.

# Actually, looking at the output more carefully:
# For d=7, c=(3,2,2): Q_1 (first 15 terms): [-1, 3, 3, 2, 2, 1, 1, 0, ...]
# From the correct computation: Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6

# The d9_d12 result has Q_1[0] = -1, Q_1[1] = 3. But the correct result has
# Q_1[0] = 0, Q_1[1] = 2. So Q_1 is shifted by (1-q): 
# -1 + 3q + 3q^2 + ... vs 2q + 3q^2 + ...
# The difference is -1 + q = -(1-q). 

# AH HA. The issue is in the e_j expansion. Let me check.
# (zq;q)_inf = prod_{j >= 0}(1 - zq^{j+1})
# e_0 = [z^0] = 1. CORRECT.
# e_1 = [z^1] = -(q + q^2 + q^3 + ...) = -q/(1-q). CORRECT.

# But maybe I should be using (zq)_inf differently.
# Actually, looking at the conjecture definition again:
# "$Q_{n,c}(q) := (q^\ell;q^\ell)_n \cdot [z^n]\Big((zq)_\infty \cdot \operatorname{GK}_c(z,q)\Big)$"

# What if (zq)_inf means something different? In the notation section:
# (a;q)_inf = prod_{i=0}^inf (1 - aq^i)
# So (zq;q)_inf = prod_{i>=0} (1 - zq*q^i) = prod_{i>=0} (1 - zq^{i+1})

# But what if (zq)_inf is shorthand for (zq;zq)_inf?
# (zq;zq)_inf = prod_{i>=0} (1 - (zq)^{i+1}) = prod_{j>=1} (1 - z^j q^j)
# This would be completely different.

# Or maybe (zq)_inf = prod_{j>=0} (1 - zq) ... no that's just 1-zq to the infinity.

# Let me try the interpretation (zq)_inf = prod_{j >= 1} (1 - zq^j):
# This is (zq;q)_inf, which is what I've been using.

# Let me also try: (zq)_inf = the "factorial" (q;q)_inf evaluated at z*q?
# No, that doesn't make sense in context.

# Wait, maybe the issue is simpler. Let me look at the d9_d12 script's 
# Q computation more carefully. In that script, I compute:

# bracket = sum_{j=0}^n e_j * G_{n-j}
# where G_0 = 1 (correct), G_m = F[c, m] - F[c, m-1] for m >= 1.

# Then Q_n = (q^l;q^l)_n * bracket.

# For n=1: bracket = e_0 * G_1 + e_1 * G_0 = G_1 - q/(1-q)
# Q_1 = (1 - q^l) * (G_1 - q/(1-q))

# With l=1: Q_1 = (1-q) * (G_1 - q/(1-q))

# For my CW-computed F_{c,1}: if the CW gives the right F_{c,1}, then 
# G_1 = F_{c,1} - 1 should be correct.

# Let me trace through: if F_{c,1} via CW = 2q/(1-q) (missing the 1),
# then G_1 = 2q/(1-q) - 1 = (2q - 1 + q)/(1-q) = (3q-1)/(1-q)
# = (-1 + 3q + 3q^2 + ...)
# bracket = G_1 - q/(1-q) = (-1 + 3q + 3q^2 + ...) - (q + q^2 + ...)
# = -1 + 2q + 2q^2 + ...
# Q_1 = (1-q)(-1 + 2q + 2q^2 + ...) = -1 + 2q + 2q^2 + ... + 1 - 2q - ...
# = -1 + 3q + 0q^2 + ... WRONG

# If F_{c,1} via CW is CORRECT = (1+q)/(1-q), then:
# G_1 = (1+q)/(1-q) - 1 = 2q/(1-q) = 2q + 2q^2 + ...
# bracket = 2q/(1-q) - q/(1-q) = q/(1-q) = q + q^2 + ...
# Q_1 = (1-q)(q + q^2 + ...) = q. 

# Hmm, that gives Q_1 = q for c=(1,1,0), d=2. But earlier correct computation
# also gives Q_1 = q. Good.

# For c=(3,2,2), d=7:
# F_{c,1} = 1 + 3q + 6q^2 + 8q^3 + 10q^4 + 11q^5 + 12q^6 + 12q^7 + ...
# G_1 = 3q + 6q^2 + 8q^3 + 10q^4 + 11q^5 + 12q^6 + 12q^7 + ...
# e_1 = -q - q^2 - q^3 - ...
# bracket = 2q + 5q^2 + 7q^3 + 9q^4 + 10q^5 + 11q^6 + 11q^7 + ...
# Q_1 = (1-q)*bracket = 2q + (5-2)q^2 + (7-5)q^3 + (9-7)q^4 + ...
#      = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 + 0q^7 + ...
# CORRECT!

# So the bug in d9_d12 is that the CW recurrence gives F_{c,1} WITHOUT
# the constant term. The issue is in my CW implementation.

# Actually wait -- let me re-examine. The CW recurrence IS:
# F_{c,n} = sum_J (-1)^{|J|-1} q^{|J|n} * S_{c(J),n}
# where S_{c,n} = sum_{j=0}^n F_{c,j}.
# 
# For n >= 1 and the empty partition contributes 1 to F_{c,n} (it has max = 0 <= n).
# So F_{c,n} includes the 1. Therefore my CW system should give the correct F_{c,n}.

# Let me check what the CW system actually gives for d=2.
# From the first script: M2 * F1 = b, solved to give
# F_{(1,1,0),1} = -2x/(x-1) = 2x/(1-x)
# At x = q: 2q/(1-q) = 2q + 2q^2 + ...
# But the correct F_{(1,1,0),1} = 1 + 2q + 2q^2 + ...

# So the CW system gives F_{c,1} - 1. The "1" is being absorbed into the RHS.

# Going back to the recurrence:
# F_{c,n} = sum_J (-1)^{|J|-1} q^{sn} (S_{c(J),n-1} + F_{c(J),n})
# => F_{c,n} - sum_J (-1)^{|J|-1} q^{sn} F_{c(J),n} = sum_J (-1)^{|J|-1} q^{sn} S_{c(J),n-1}

# For n=1: S_{c(J),0} = F_{c(J),0} = 1 for all c(J).
# So RHS = sum_J (-1)^{|J|-1} q^s * 1.

# Now: F_{c,1} includes the empty partition (which has max=0 <= 1).
# So F_{c,1} = 1 + (contributions from max-1 partitions).

# The CW recurrence computes ALL of F_{c,1}, including the 1.
# But my solution gives 2q/(1-q), not 1 + 2q/(1-q).

# Let me solve the system again more carefully.
# For d=2, c=(1,1,0), the CW shifts are:
# J={0}: cp=(0,2,0), s=1
# J={1}: cp=(1,0,1), s=1
# J={0,1}: cp=(0,1,1), s=2

# System: F_{c,1} - q*F_{(0,2,0),1} - q*F_{(1,0,1),1} + q^2*F_{(0,1,1),1} = q + q - q^2 = 2q - q^2

# By symmetry: F_{(1,1,0),1} = F_{(0,1,1),1} = F_{(1,0,1),1} (all have same structure).
# And F_{(0,2,0),1} = F_{(2,0,0),1} = F_{(0,0,2),1}.

# Let X = F_{(1,1,0),1} = F_{(0,1,1),1} = F_{(1,0,1),1}
# Let Y = F_{(0,2,0),1} = F_{(2,0,0),1} = F_{(0,0,2),1}

# For c=(1,1,0): X - q*Y - q*X + q^2*X = 2q - q^2
# => X(1 - q + q^2) - qY = 2q - q^2   ... (*)

# For c=(0,2,0), I_c = {1}: only J={1}.
# J={1}: cp = shifted_profile((0,2,0), {1}) 
# i=1 in J, prev=0 not in J: c_1 - 1 = 1.
# i=2 not in J, prev=1 in J: c_2 + 1 = 1.
# cp = (0, 1, 1). So:
# Y - q*X = q   ... (**)

# From (**): Y = q + qX. Substitute into (*):
# X(1-q+q^2) - q(q+qX) = 2q - q^2
# X(1-q+q^2) - q^2 - q^2*X = 2q - q^2
# X(1-q+q^2-q^2) - q^2 = 2q - q^2
# X(1-q) = 2q
# X = 2q/(1-q)

# So X = F_{(1,1,0),1} = 2q/(1-q). No constant term!

# But we KNOW F_{(1,1,0),1} = 1 + 2q + 2q^2 + ... (by direct counting).

# The issue: the CW recurrence as I derived it is MISSING the constant term.
# Let me re-derive from scratch.

# The CW FUNCTIONAL EQUATION (from conjecture.tex):
# F_c(y,q) = sum_{emptyset != J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
# with F_c(0,q) = 1.

# This defines F_c(y,q) implicitly. Let me check if F_c(0,q) = 1 is consistent.
# At y=0: LHS = F_c(0,q) = 1.
# RHS = sum_J (-1)^{|J|-1} F_{c(J)}(0,q)/(1-0) = sum_J (-1)^{|J|-1} * 1.
# = sum_J (-1)^{|J|-1}.
# For I_c = {0,1}: sum = 1 + 1 - 1 = 1. OK!
# For I_c = {0,1,2}: sum = 3 - 3 + 1 = 1. OK!
# This is inclusion-exclusion: sum_{emptyset != J subset I} (-1)^{|J|-1} = 1.

# So the initial condition is satisfied by the formula. Good.

# Now [y^n] for n >= 1:
# F_{c,n} = [y^n] sum_J (-1)^{|J|-1} F_{c(J)}(yq^s)/(1-yq^s)
# = sum_J (-1)^{|J|-1} q^{sn} sum_{j=0}^n F_{c(J),j}

# Wait, I computed earlier that [y^n] G(yq^s)/(1-yq^s) = q^{sn} sum_{j=0}^n G_j
# where G(y) = sum G_j y^j.

# But G here is F_{c(J)}, so G_j = F_{c(J),j}.

# For n=1: F_{c,1} = sum_J (-1)^{|J|-1} q^s (F_{c(J),0} + F_{c(J),1})
# = sum_J (-1)^{|J|-1} q^s (1 + F_{c(J),1})
# = sum_J (-1)^{|J|-1} q^s + sum_J (-1)^{|J|-1} q^s F_{c(J),1}

# The first sum = 1 (by inclusion-exclusion applied to x*I_c weights? No...)
# sum_J (-1)^{|J|-1} q^s where s = |J|.
# For I_c = {0,1}: q + q - q^2 = 2q - q^2.
# For I_c = {0,1,2}: q + q + q - q^2 - q^2 - q^2 + q^3 = 3q - 3q^2 + q^3.

# For c=(1,1,0), I_c = {0,1}:
# F_{(1,1,0),1} = (2q - q^2) + q*F_{(0,2,0),1} + q*F_{(1,0,1),1} - q^2*F_{(0,1,1),1}
# = (2q - q^2) + q*Y + q*X - q^2*X    (using the symmetry X = F_{(1,1,0),1}, Y = F_{(0,2,0),1})
# => X = 2q - q^2 + qY + qX - q^2*X
# => X - qX + q^2*X = 2q - q^2 + qY
# => X(1 - q + q^2) = 2q - q^2 + qY

# From c=(0,2,0): F_{(0,2,0),1} = q + q*F_{(0,1,1),1} = q + qX.
# So Y = q + qX.
# X(1-q+q^2) = 2q - q^2 + q(q + qX) = 2q - q^2 + q^2 + q^2*X = 2q + q^2*X
# X(1-q+q^2) - q^2*X = 2q
# X(1-q) = 2q
# X = 2q/(1-q) = 2q + 2q^2 + 2q^3 + ...

# So the CW gives F_{(1,1,0),1} = 2q/(1-q), but direct counting gives 1 + 2q/(1-q).

# THE ISSUE: The CW equation says F_c(y) = sum_J ..., but this is an EQUATION,
# not a definition. Is F_c(y) supposed to be the GF including the empty partition?

# Yes, F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}. The empty partition
# has |Lambda| = 0 and max = 0 (or undefined). If max(emptyset) = 0, then
# [y^0] F_c(y,q) gets a contribution of 1 from the empty partition, 
# and F_{c,0} = 1. But [y^1] should NOT get a contribution from the empty partition.

# For max <= 1: F_{c,1} = #{Lambda: max(Lambda) <= 1, weight w} * q^w
# = 1 (empty) + sum_{w >= 1} a_w q^w
# = 1 + q + 2q^2 + 2q^3 + ... for c=(1,1,0).

# So F_{c,1} includes the 1 from the empty partition. But the CW gives 2q/(1-q).
# This means the CW is giving F_{c,1} - F_{c,0} = F_{c,1} - 1. 
# Or equivalently, it's giving G_1 = [y^1] F_c(y,q).

# AH HA! That's it. The CW functional equation is for F_c(y,q) which is a GF
# in y. Its [y^n] coefficient is G_n = #{max = n}, NOT F_{c,n} = #{max <= n}.
# I was CONFUSING G_n with F_{c,n}.

# Let me verify: G_1 for c=(1,1,0) = F_{c,1} - F_{c,0} = (1+2q/(1-q)) - 1 = 2q/(1-q).
# That's what the CW gives! So the CW computes G_n, not F_{c,n}.

# This means in my d9_d12 script, I should use F[c, m] directly as G_m (the CW output),
# and NOT subtract F[c, m-1] when computing the G_m for the Q formula.

print("\n" + "=" * 60)
print("RESOLUTION: CW computes G_n = [y^n]F(y,q), not F_{c,n}")
print("=" * 60)
print("The CW recurrence gives G_n = F_{c,n} - F_{c,n-1}, the EXACT coefficient of y^n.")
print("In the Q formula: bracket = sum_j e_j G_{n-j}, where G is what CW gives.")
print("So DO NOT subtract F_{c,m-1} from the CW output -- it's already G_m!")

