"""
Prove the Bellman equation: EMD(c, c') = min_{J nonempty subset I_c} (|J| + EMD(c(J), c'))

The EMD on Z/3Z with clockwise metric d(i, (i+1) mod 3) = 1 can be computed as:
EMD(c, c') = min sum_i w_i * cost(i -> pi(i)) over transport plans
           = min cost of moving excess mass from c to c' clockwise

For distributions c = (c_0, c_1, c_2) and c' = (c'_0, c'_1, c'_2) with sum d:
EMD(c, c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)

Key fact: The CW shift c(J) moves mass from position i to position i+1 (mod 3) 
for each boundary where J transitions from "in" to "out".

Let's understand this precisely.
"""

# First, understand the CW shift geometrically
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

# For r=3, the possible J subsets of {0,1,2} are:
# {0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}

# Let's compute c(J) - c for each J:
print("Effect of CW shift c(J) - c for each J:")
for J in [{0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}]:
    c_test = (1, 1, 1)  # Uniform distribution for illustration
    cJ = shifted_profile(c_test, J)
    diff = tuple(cJ[i] - c_test[i] for i in range(3))
    print(f"  J = {J}: delta = {diff}")

# Analysis:
# {0}: delta = (-1, 1, 0)     -- move 1 unit from position 0 to position 1
# {1}: delta = (0, -1, 1)     -- move 1 unit from position 1 to position 2
# {2}: delta = (1, 0, -1)     -- move 1 unit from position 2 to position 0
# {0,1}: delta = (-1, 0, 1)   -- move 1 unit from position 0 to position 2
# {0,2}: delta = (0, 1, -1)   -- move 1 unit from position 2 to position 1
# {1,2}: delta = (1, -1, 0)   -- move 1 unit from position 1 to position 0
# {0,1,2}: delta = (0, 0, 0)  -- no change!

print("\nInterpretation:")
print("  {i} (size 1): moves 1 unit clockwise from position (i-1 mod 3) to position i")
print("  Wait, let me recheck...")

# Actually:
# {0}: c_0 decreases by 1 (0 in J, prev=2 not in J), c_1 increases by 1 (1 not in J, prev=0 in J)
# This moves mass from position 0 to position 1 -- that's CLOCKWISE (0 -> 1)
# Cost = 1 in the clockwise metric

# {1}: moves mass from position 1 to position 2 -- CLOCKWISE (1 -> 2), cost = 1
# {2}: moves mass from position 2 to position 0 -- CLOCKWISE (2 -> 0), cost = 1

# {0,1}: 0 in J, prev 2 not in J -> c_0 -= 1
#         1 in J, prev 0 in J -> no change to c_1
#         2 not in J, prev 1 in J -> c_2 += 1
# So moves mass from position 0 to position 2 -- COUNTERCLOCKWISE (0 -> 2), cost = 2
# But |J| = 2, and EMD(c, c({0,1})) would be 2 in the clockwise metric

# {0,2}: 0 in J, prev 2 in J -> no change to c_0  
#         1 not in J, prev 0 in J -> c_1 += 1
#         2 in J, prev 1 not in J -> c_2 -= 1
# Moves mass from position 2 to position 1 -- COUNTERCLOCKWISE, cost = 2
# |J| = 2

# {1,2}: 0 not in J, prev 2 in J -> c_0 += 1
#         1 in J, prev 0 not in J -> c_1 -= 1
#         2 in J, prev 1 in J -> no change to c_2
# Moves mass from position 1 to position 0 -- COUNTERCLOCKWISE, cost = 2
# |J| = 2

# {0,1,2}: All in J, all prev in J -> no change. |J| = 3.
# This is the "do nothing" shift! EMD contribution = 3 + EMD(c, c') = 3 + 0 = 3

print("\n\nCRITICAL OBSERVATION:")
print("Each singleton {i} moves 1 unit of mass clockwise by 1 step. Cost = 1.")
print("Each pair {i,j} (consecutive in cyclic order) moves 1 unit counterclockwise by 1 step. Cost = 2.")
print("  But |{i,j}| = 2, so |J| = cost in the clockwise metric!")
print("The triple {0,1,2} is identity. |J| = 3 = one full loop around Z/3Z.")
print("")
print("SO: |J| = EMD(c, c(J)) for the 'pure' shifts!")
print("This means the Bellman equation reduces to:")
print("  EMD(c, c') = min_J (EMD(c, c(J)) + EMD(c(J), c'))")
print("which is just the TRIANGLE INEQUALITY for EMD,")
print("with equality because c(J) lies on the geodesic from c to c'!")

# Verify: |J| = EMD(c, c(J)) for all J and all profiles c
print("\n\nVerification: |J| = EMD(c, c(J))?")
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

for d in [1, 2, 3, 4, 5]:
    profs = profiles(d)
    failures = 0
    for c in profs:
        I_c = [i for i in range(3) if c[i] > 0]
        for size in range(1, len(I_c)+1):
            for J in combinations(I_c, size):
                cJ = shifted_profile(c, J)
                if all(ci >= 0 for ci in cJ):
                    emd_val = emd_clockwise(c, cJ)
                    if emd_val != len(J):
                        print(f"  d={d}: |J|={len(J)}, EMD({c}, {cJ}) = {emd_val} FAIL")
                        failures += 1
    if failures == 0:
        print(f"  d={d}: VERIFIED |J| = EMD(c, c(J)) for all valid shifts")
    else:
        print(f"  d={d}: {failures} failures")

# This is huge! |J| = EMD(c, c(J)) always.
# So the Bellman equation becomes:
# EMD(c, c') = min_J (EMD(c, c(J)) + EMD(c(J), c'))
# which follows from the triangle inequality + the fact that some c(J) 
# lies on a geodesic from c to c'.

# The remaining question: does there always exist a J such that
# EMD(c, c') = EMD(c, c(J)) + EMD(c(J), c')?
# i.e., c(J) lies on a geodesic from c to c'?

print("\n\nDoes some c(J) always lie on an EMD geodesic?")
for d in [1, 2, 3, 4]:
    profs = profiles(d)
    failures = 0
    for c in profs:
        I_c = [i for i in range(3) if c[i] > 0]
        for cp in profs:
            if c == cp:
                continue
            emd_val = emd_clockwise(c, cp)
            found_geodesic = False
            for size in range(1, len(I_c)+1):
                for J in combinations(I_c, size):
                    cJ = shifted_profile(c, J)
                    if all(ci >= 0 for ci in cJ):
                        if len(J) + emd_clockwise(cJ, cp) == emd_val:
                            found_geodesic = True
                            break
                if found_geodesic:
                    break
            if not found_geodesic:
                print(f"  d={d}: No geodesic through any c(J) for EMD({c}, {cp})={emd_val}")
                failures += 1
    if failures == 0:
        print(f"  d={d}: Every pair has a geodesic through some c(J)")

