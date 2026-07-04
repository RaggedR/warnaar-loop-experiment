"""
Seed 4, Layer 2: Gaussian elimination on the CW system for d=7.

Goal: Following Uncu's approach for moduli 11,13, attempt to solve the coupled
CW recurrence system for d=7 (modulus t=10) to extract a manifestly positive
multisum formula for Q_{n,c}(q).

The system for g_n^c involves ALL 36 profiles with d=7.
But using D_3 symmetry, we can reduce to 8 canonical classes.

For the CW recurrence (after extracting [y^n]):
  g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} [sum_{m=0}^{n-1} g_m^{c(J)} + g_n^{c(J)}]

At n=1, this gives a linear system in {g_1^c} with known RHS (depending on g_0^c = 1).

Let's write this system explicitly for ALL profiles.
"""
from collections import defaultdict
from itertools import combinations
from math import gcd

def all_profiles(d, k=3):
    if k == 1: return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c)
    J_set = set(J)
    c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set: c_new[i] -= 1
        elif i not in J_set and i_prev in J_set: c_new[i] += 1
    return tuple(c_new)

def get_transitions(c):
    k = len(c)
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    trans = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            sign = (-1) ** (size - 1)
            cJ = shifted_profile(c, J)
            if any(x < 0 for x in cJ): continue
            trans.append((sign, size, cJ))
    return trans

def canonical_profile(c):
    k = len(c)
    variants = []
    for start in range(k):
        rotated = tuple(c[(start + i) % k] for i in range(k))
        variants.append(rotated)
        reversed_rot = tuple(rotated[k - 1 - i] for i in range(k))
        variants.append(reversed_rot)
    return min(variants)

# For n=1:
# g_1^c = sum_J (-1)^{|J|-1} q^{|J|} (1 + g_1^{c(J)})
# g_1^c = sum_J (-1)^{|J|-1} q^{|J|} + sum_J (-1)^{|J|-1} q^{|J|} g_1^{c(J)}
#
# Define: alpha_c = sum_J (-1)^{|J|-1} q^{|J|} (known constant for each c)
# Then: g_1^c - sum_J (-1)^{|J|-1} q^{|J|} g_1^{c(J)} = alpha_c
#
# This is a linear system. But with polynomial coefficients (powers of q).
# Since the coefficient of g_1^{c(J)} is q^{|J|}, this system is "lower triangular"
# in q-degree: at each q-degree d, the equation for g_1^c at degree d
# depends on g_1^{c(J)} at degree d - |J|.
# Since |J| >= 1, we can solve degree by degree.

# But Uncu's approach is different: he works with the CW recurrence for F_c(y,q)
# as formal power series in y and q, using Gaussian elimination on a MATRIX
# of profiles to express F for one profile in terms of base cases.

# The key insight from Uncu: the CW recurrence can be rewritten as:
# F_c(y,q) = alpha_c(y,q) + sum over c' of M_{c,c'}(y,q) F_{c'}(y,q)
# where M is a "matrix" of operators (involving y-shifts and divisions).
# Gaussian elimination on this matrix yields F_c as an explicit positive multisum.

# For our degree-by-degree approach, let me build the EXPLICIT linear system
# for g_1 (the y^1 coefficient) and solve it.

d = 7
profiles = all_profiles(d, 3)
N = len(profiles)
prof_idx = {c: i for i, c in enumerate(profiles)}
trans = {c: get_transitions(c) for c in profiles}

print(f"System size: {N} profiles for d={d}")

# At q-degree 0: g_1^c has no q^0 term (since alpha_c starts at q^1)
# At q-degree 1: 
# [q^1] g_1^c = [q^1] alpha_c + sum_J (-1)^{|J|-1} [q^{1-|J|}] g_1^{c(J)}
#             = [q^1] alpha_c + sum_{|J|=1} (+1) [q^0] g_1^{c(J)}
#             = [q^1] alpha_c (since [q^0] g_1^{anything} = 0)
#
# alpha_c = sum_J (-1)^{|J|-1} q^{|J|}
# For |I_c| = s, this is sum_{k=1}^s (-1)^{k-1} C(s,k) q^k = 1 - (1-q)^s
# So: [q^1] alpha_c = s = |I_c|.
#
# But wait, for profiles with c_i = 0 for some i, |I_c| < 3.
# For (0,0,7): |I_c| = 1, so alpha = q, [q^1]=1.
# For (3,2,2): |I_c| = 3, alpha = 3q - 3q^2 + q^3, [q^1]=3.

# Actually we need to be careful: alpha is profile-dependent because
# the J subsets depend on I_c, and c(J) is used but only for the coefficient
# of g_1^{c(J)}, not alpha itself.

# Let me compute alpha for each canonical profile:
print("\nalpha_c = sum_J (-1)^{|J|-1} q^{|J|}:")
for c in sorted(set(canonical_profile(p) for p in profiles)):
    ic = [i for i in range(3) if c[i] > 0]
    s = len(ic)
    # alpha = sum_{k=1}^s (-1)^{k-1} C(s,k) q^k = 1 - (1-q)^s
    from math import comb
    alpha = {}
    for k in range(1, s + 1):
        coeff = (-1)**(k-1) * comb(s, k)
        if coeff != 0:
            alpha[k] = coeff
    print(f"  {c}: I_c={ic}, |I_c|={s}, alpha = {alpha}")

# Now let me solve the system for g_1 at each q-degree
# This is what the degree-by-degree solver in the compute script already does.
# Let me verify its output by comparing with a direct matrix approach.

# For n=1, the system at each fixed q-degree d is:
# [q^d] g_1^c = [q^d] alpha_c + sum_J (-1)^{|J|-1} [q^{d-|J|}] g_1^{c(J)}
# This is truly a degree-by-degree recursion, not a matrix system.
# The "Gaussian elimination" Uncu does operates at the level of the
# FUNCTIONAL EQUATION for F_c(y,q), not at fixed y-degree.

# Let me think about what Uncu actually does.
# Uncu starts with the CW recurrence:
# F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1 - yq^{|J|})
#
# This relates F for profile c to F for profiles c(J).
# Since all profiles have the same d, this is a COUPLED system.
# Uncu applies Gaussian elimination to ELIMINATE profiles one by one,
# eventually expressing F for one profile purely in terms of the base case
# (zero profile or trivial cases).
#
# The result is an EXPLICIT formula for F_c(y,q) as a multisum.

# For d=7, the system has 36 unknowns (one per profile, or 8 up to symmetry).
# Gaussian elimination would produce very large expressions.

# Let me try a SIMPLER version first: d=4 (known case, Warnaar proved it).
# d=4 has 15 profiles, 4 canonical classes.

print("\n" + "=" * 70)
print("GAUSSIAN ELIMINATION for d=4")
print("=" * 70)

d4_profiles = all_profiles(4, 3)
d4_trans = {c: get_transitions(c) for c in d4_profiles}

# For d=4, list the transition structure
print(f"\nd=4 profiles: {len(d4_profiles)}")
for c in sorted(set(canonical_profile(p) for p in d4_profiles)):
    ic = [i for i in range(3) if c[i] > 0]
    tr = d4_trans.get(c, [])
    print(f"\n{c} (|I_c|={len(ic)}):")
    for sign, s, cJ in tr:
        print(f"  {'+' if sign > 0 else '-'} F_{cJ}(yq^{s},q)/(1-yq^{s})  [canon: {canonical_profile(cJ)}]")

# The key question for Gaussian elimination:
# Can we express F_{(2,1,1)} purely in terms of F_{(0,...)} (zero-like profiles)?
# 
# Profile (0,0,4) has I_c = {2}, only one transition: to (1,0,3).
# Profile (0,1,3) has I_c = {1,2}, transitions to (0,0,4), (1,1,2), (1,0,3).
# etc.
#
# The elimination would need to reduce from "interior" profiles to "boundary" ones.
# Interior = all c_i > 0. Boundary = at least one c_i = 0.
# For d=4: interior profiles are (1,1,2), (1,2,1), (2,1,1), (2,2,0)... wait.
# (2,2,0) has a zero so it's boundary. Interior (all c_i > 0): (1,1,2) and permutations.

# Let me count:
interior_d4 = [c for c in d4_profiles if all(ci > 0 for ci in c)]
boundary_d4 = [c for c in d4_profiles if any(ci == 0 for ci in c)]
print(f"\nInterior profiles (all c_i>0): {len(interior_d4)}: {interior_d4}")
print(f"Boundary profiles: {len(boundary_d4)}")

# For d=7:
interior_d7 = [c for c in profiles if all(ci > 0 for ci in c)]
boundary_d7 = [c for c in profiles if any(ci == 0 for ci in c)]
print(f"\nd=7 Interior: {len(interior_d7)}: {[canonical_profile(c) for c in interior_d7]}")
print(f"d=7 Boundary: {len(boundary_d7)}")

# Interior canonical classes for d=7:
int_canon_d7 = sorted(set(canonical_profile(c) for c in interior_d7))
print(f"d=7 Interior canonical: {int_canon_d7}")

# For Gaussian elimination, we want to express interior profiles in terms
# of boundary profiles. The CW recurrence for an interior profile c 
# involves both interior and boundary targets c(J).
# Can we verify that the boundary profiles eventually reduce to (0,0,0)?
# No -- (0,0,0) has d=0, not d=7. The boundary profiles with d=7 are 
# like (7,0,0), (0,7,0), (6,1,0), etc.

# For these boundary profiles, the CW recurrence is simpler:
# E.g., for c=(7,0,0): I_c = {0}, only one J = {0}
# c({0}) = (6, 1, 0)
# F_{(7,0,0)}(y,q) = F_{(6,1,0)}(yq,q) / (1-yq)

# This is a DIRECT formula: F_{(7,0,0)} in terms of F_{(6,1,0)}.
# Similarly, (6,1,0) has I_c = {0,1}:
# J={0}: c(J) = (5,2,0), J={1}: c(J) = (7,0,0) -- back to boundary!
# J={0,1}: c(J) = (6,1,0) -- self!

# So the boundary profiles form their own coupled subsystem.
# The observation: for profiles with c_2=0:
# c = (a,b,0) with a+b=d=7. These satisfy:
# CW recurrence involves only profiles with c_2=0 OR c_2=1 
# (since shifting can increment c_2 by at most 1).

# Hmm, this is getting complex. Let me instead focus on what Uncu's 
# Gaussian elimination actually produces.

# UNCU'S INSIGHT: The CW system for a fixed d can be ordered so that
# elimination proceeds from "simpler" profiles to "more complex" ones.
# The order is by the NUMBER OF NONZERO entries: first profiles with 1 nonzero,
# then 2, then 3.

# For 1-nonzero profiles (like (7,0,0)):
# F_{(7,0,0)}(y,q) = F_{(6,1,0)}(yq,q) / (1-yq)
# This expresses it in terms of a 2-nonzero profile.

# For 2-nonzero profiles (like (6,1,0)):
# F_{(6,1,0)} = F_{(5,2,0)}(yq,q)/(1-yq) + F_{(7,0,0)}(yq,q)/(1-yq) 
#             - F_{(6,1,0)}(yq^2,q)/(1-yq^2)
# Substituting the formula for F_{(7,0,0)}:
# ... this telescopes or can be solved.

# The key difficulty: for 3-nonzero profiles, the system is coupled.
# Uncu solves this by introducing "Bailey-type" transformations.

# Let me investigate the structure of the CW system more carefully
# by looking at how many profiles each profile's recurrence involves.

print("\n" + "=" * 70)
print("TRANSITION STRUCTURE ANALYSIS for d=7")
print("=" * 70)

for c in sorted(int_canon_d7):
    tr = d4_trans.get(c, []) if d == 4 else get_transitions(c)
    int_targets = [cJ for _, _, cJ in tr if all(ci > 0 for ci in cJ)]
    bdy_targets = [cJ for _, _, cJ in tr if any(ci == 0 for ci in cJ)]
    self_targets = [cJ for _, _, cJ in tr if canonical_profile(cJ) == canonical_profile(c)]
    print(f"\n{c}:")
    print(f"  Interior targets: {len(int_targets)} ({[canonical_profile(t) for t in int_targets]})")
    print(f"  Boundary targets: {len(bdy_targets)} ({[canonical_profile(t) for t in bdy_targets]})")
    print(f"  Self-referencing: {len(self_targets)}")

