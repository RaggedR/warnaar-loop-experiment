"""
Formalize the proof of the Adjugate Monomial Theorem.

THEOREM: For r=3 and any d >= 1, adj(I - A(x))[c, c'] = x^{EMD(c,c')}.

PROOF STRUCTURE:

Step 1: det(I - A(x)) = -(x^3 - 1). [Known, verified for d=1..11]

Step 2: For J != {0,1,2} a nonempty proper subset of I_c:
  |J| = EMD(c, c(J)) where EMD is the clockwise transport distance on Z/3Z.
  [Proved below]

Step 3: The Bellman equation holds:
  EMD(c, c') = min_{J proper nonempty subset of I_c} (|J| + EMD(c(J), c'))
  [Follows from Step 2 + triangle inequality + geodesic existence]

Step 4: (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')} / (1-x^3)
  [Follows from Step 3 via Neumann series argument]

Step 5: adj(I-A(x)) = det(I-A(x)) * (I-A(x))^{-1} = -(x^3-1) * x^{EMD}/(1-x^3) = x^{EMD}

Let me prove Step 2 rigorously.
"""

# Step 2 proof: For proper nonempty J subset {0,1,2}, |J| = EMD(c, c(J))

# The CW shift c -> c(J) has the following effect:
# For each "J-boundary" (i in J, (i-1) mod 3 not in J):
#   c_i decreases by 1, c_{i+1 mod 3} increases by 1 (where i+1 means the next index after i not in J)
#
# Wait, let me be more precise. The rule is:
# c_i(J) = c_i - 1 if i in J and (i-1 mod 3) not in J
# c_i(J) = c_i + 1 if i not in J and (i-1 mod 3) in J
# c_i(J) = c_i otherwise
#
# So mass moves from i to the next index clockwise that is NOT in J,
# for each "entry boundary" of J.

# For r=3, the possible proper nonempty subsets J and their effects:
# {0}: boundaries at (0 in J, 2 not in J) -> c_0 -= 1
#      (1 not in J, 0 in J) -> c_1 += 1
#      Net: move 1 unit from position 0 to position 1. EMD cost = 1. |J| = 1. CHECK.

# {1}: move 1 unit from 1 to 2. Cost 1. |J| = 1. CHECK.
# {2}: move 1 unit from 2 to 0. Cost 1. |J| = 1. CHECK.

# {0,1}: boundaries at (0 in J, 2 not in J) -> c_0 -= 1
#         (2 not in J, 1 in J) -> c_2 += 1
#         Net: move 1 unit from 0 to 2. Clockwise cost = 2. |J| = 2. CHECK.

# {0,2}: boundaries at (0 in J, 2 in J) -> nothing at 0
#         (1 not in J, 0 in J) -> c_1 += 1
#         (2 in J, 1 not in J) -> c_2 -= 1
#         Net: move 1 unit from 2 to 1. Clockwise cost = 2. |J| = 2. CHECK.

# {1,2}: boundaries at (1 in J, 0 not in J) -> c_1 -= 1
#         (0 not in J, 2 in J) -> c_0 += 1
#         Net: move 1 unit from 1 to 0. Clockwise cost = 2. |J| = 2. CHECK.

# So for SINGLETONS {i}: the shift moves 1 unit clockwise by 1 step. |J| = 1.
# For PAIRS {i, i+1 mod 3}: moves 1 unit clockwise by 2 steps. |J| = 2.
# These are ALL the proper nonempty subsets of {0,1,2}.

# The EMD of moving 1 unit from position a to position b clockwise is:
# (b - a) mod 3, which equals the clockwise distance.
# For singletons: distance = 1 = |J|
# For pairs {i, j} where j = (i+1) mod 3: the mass moves from i to (i+2) mod 3 = (j+1) mod 3
#   Wait let me recompute for {0,1}: mass from 0 to 2, clockwise distance = 2 = |J|
#   For {0,2}: mass from 2 to 1, clockwise distance = 2 = |J|
#   For {1,2}: mass from 1 to 0, clockwise distance = 2 = |J|

# So |J| always equals the clockwise distance of the unit mass transport.
# BUT: c(J) requires c_source >= 1 (i.e., source position must have positive mass).
# This is exactly the condition that J subset I_c!

# FORMAL PROOF of |J| = EMD(c, c(J)):
#
# For a proper nonempty J subset {0,1,2}, the shift c -> c(J) moves exactly
# one unit of mass by |J| steps clockwise. Specifically:
# - J has exactly one "entry boundary" (position i where i in J, (i-1) not in J)
#   and one "exit boundary" (position j where j not in J, (j-1) in J).
# - The entry removes 1 from position i, the exit adds 1 at position j.
# - The clockwise distance from i to j is |J| (since J is a consecutive arc of size |J|
#   in the cyclic order, and j is the position right after the arc).
#
# Wait, is J always a consecutive arc?
# For r=3: {0}, {1}, {2} are single elements (arcs of length 1).
# {0,1}, {1,2}, {0,2} -- is {0,2} consecutive? In cyclic order 0,1,2,0,...
# {0,2} = {2,0} which is the arc 2->0 of length 2. Yes, it's consecutive cyclically!
# All subsets of {0,1,2} of size 1 or 2 are consecutive arcs in the cyclic order.

# But what about r > 3? For r=3, we're fine because ALL proper nonempty subsets
# of {0,1,2} are arcs. For general r, non-arc subsets would have multiple boundaries.

# KEY REALIZATION: For r=3, every proper nonempty J subset {0,1,2} is a 
# consecutive arc (interval) in cyclic order. This means each shift moves
# exactly 1 unit of mass, and |J| = clockwise distance of that unit.

# EMD of moving 1 unit by distance d_step on Z/3Z:
# EMD(c, c') = 1 * d_step = d_step (for unit mass transport)
# Since d_step = |J| (clockwise), we get EMD(c, c(J)) = |J|.

# QED for Step 2.

print("Step 2 proved: For r=3, every proper nonempty J subset I_c gives |J| = EMD(c, c(J))")
print("Reason: J is a consecutive arc in Z/3Z, creating a single-unit mass transport")
print("by |J| clockwise steps. This is independent of the profile c (given c_source >= 1).")

# Now Step 3: Bellman equation
# Need: For c != c', there exists J proper nonempty subset I_c such that
# EMD(c, c') = |J| + EMD(c(J), c')
# i.e., EMD(c, c') = EMD(c, c(J)) + EMD(c(J), c')  [triangle equality]
# i.e., c(J) lies on a geodesic from c to c' in the Wasserstein metric.

# By Step 2, each c(J) is obtained by moving 1 unit clockwise by |J| steps.
# The optimal transport from c to c' uses only clockwise moves (since we use
# the clockwise metric). So there EXISTS a J that makes a "first step" along
# the optimal transport.

# More precisely: let T* be an optimal transport plan from c to c'.
# T* moves some mass clockwise from various positions.
# Take any position i where T*_i > 0 (mass leaving position i).
# Then J = {i} moves 1 unit from position i clockwise by 1 step.
# This reduces EMD by 1 (since it makes partial progress toward the target).
# So EMD(c, c') = 1 + EMD(c({i}), c').

# But wait: what if c(J) is invalid (c_i = 0)? Then i not in I_c, so {i} not in 
# the allowed subsets. But T* moves mass from i, which requires c_i > 0, so i in I_c.

# Actually this argument only works for |J| = 1. For |J| = 2, we might need 
# a 2-step move when the 1-step move is suboptimal.

# Can the Bellman minimum require |J| = 2?
# Yes! If EMD(c, c') = 2, and the unique optimal transport moves 1 unit 
# counterclockwise (which costs 2 clockwise), then:
# - |{i}| + EMD(c({i}), c') = 1 + (2-1) = 2 for the right singleton i
# - |{i,j}| + EMD(c({i,j}), c') = 2 + 0 = 2 for the right pair
# Both achieve the minimum. So the singleton is always sufficient!

# CLAIM: For c != c', there always exists a singleton {i} subset I_c such that
# EMD(c, c') = 1 + EMD(c({i}), c').
# PROOF: Choose i to be a position where the optimal transport T* moves mass away.
# Then c({i}) makes 1 unit of progress toward c', reducing EMD by exactly 1.

# Actually this isn't quite right because the EMD formula is nonlinear.
# Let me verify computationally.

from itertools import combinations

def emd_clockwise(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def shifted_profile(c, J):
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

print("\nVerifying singleton sufficiency for Bellman:")
for d in range(1, 8):
    profs = profiles(d)
    failures = 0
    for c in profs:
        for cp in profs:
            if c == cp:
                continue
            emd_val = emd_clockwise(c, cp)
            # Check if some singleton {i} in I_c achieves Bellman minimum
            found = False
            for i in range(3):
                if c[i] > 0:
                    cJ = shifted_profile(c, (i,))
                    if all(ci >= 0 for ci in cJ):
                        if 1 + emd_clockwise(cJ, cp) == emd_val:
                            found = True
                            break
            if not found:
                failures += 1
                if failures <= 3:
                    # Check what the minimum is
                    I_c = [i for i in range(3) if c[i] > 0]
                    bests = []
                    for size in range(1, len(I_c)+1):
                        for J in combinations(I_c, size):
                            cJ = shifted_profile(c, J)
                            if all(ci >= 0 for ci in cJ):
                                val = len(J) + emd_clockwise(cJ, cp)
                                bests.append((J, val, cJ))
                    min_val = min(b[1] for b in bests)
                    print(f"  d={d}: Singleton fails for EMD({c}, {cp})={emd_val}")
                    for J, val, cJ in bests:
                        if val == min_val:
                            print(f"    Minimizer: J={J}, |J|+EMD(c(J),c')={val}, c(J)={cJ}")
    if failures == 0:
        print(f"  d={d}: Singleton always suffices (Bellman = 1 + EMD reduction)")
    else:
        print(f"  d={d}: {failures} cases where singleton fails")

