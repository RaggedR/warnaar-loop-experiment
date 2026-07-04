R.<q> = PowerSeriesRing(ZZ, default_prec=100)

# Q_1 values for d=4, organized by C_3 orbits:
# Orbit 1: (4,0,0),(0,4,0),(0,0,4): Q_1 = q^2 + q^3 + q^4 + q^6
# Orbit 2: (3,1,0),(1,0,3),(0,3,1): Q_1 = q + q^2 + q^3 + q^4  
# Orbit 3: (2,2,0),(0,2,2),(2,0,2): Q_1 = q + 2q^2 + q^4
# Orbit 4: (2,1,1),(1,1,2),(1,2,1): Q_1 = 2q + q^2 + q^3
# Orbit 5: (3,0,1),(0,1,3),(1,3,0): Q_1 = q + q^2 + q^3 + q^5

# Each Q_1 sums to 4. But the degree distributions differ.
# The degrees present are related to the EMD from c to other orbits.

# Let me compute the EMD from each profile to each other orbit representative.

def emd_clockwise(c, cp):
    """Exact EMD on Z/3Z with clockwise cost from c to cp"""
    d = sum(c)
    best = float('inf')
    for f01 in range(d+1):
        for f12 in range(d+1):
            for f20 in range(d+1):
                for f10 in range(d+1):
                    for f02 in range(d+1):
                        f21 = (cp[2] - c[2]) - f20 + f02 + f12
                        if f21 < 0: continue
                        if f01 + f02 - f10 - f20 != cp[0] - c[0]: continue
                        if f10 + f12 - f01 - f21 != cp[1] - c[1]: continue
                        cost = f01 + f12 + f20 + 2*(f02 + f21 + f10)
                        if cost < best: best = cost
    return best

# Let me use a simpler symmetric EMD instead
def emd_symmetric(c, cp):
    """Symmetric Earth Mover Distance on Z/3Z"""
    d = sum(c)
    # Min of clockwise and counterclockwise
    cw = emd_clockwise(c, cp)
    ccw = emd_clockwise(cp, c)
    return min(cw, ccw)

# Actually for the q-grading, let me just look at the data and see if Q_1(c) can be
# written as sum over orbits o != orbit(c) of q^{dist(c, o)} for some distance function.

orbits_d4 = [
    [(4,0,0),(0,4,0),(0,0,4)],
    [(3,1,0),(1,0,3),(0,3,1)],
    [(2,2,0),(0,2,2),(2,0,2)],
    [(2,1,1),(1,1,2),(1,2,1)],
    [(3,0,1),(0,1,3),(1,3,0)],
]

# Q_1 values:
Q1_vals = {
    (4,0,0): [2, 3, 4, 6],
    (3,1,0): [1, 2, 3, 4],
    (2,2,0): [1, 2, 2, 4],
    (2,1,1): [1, 1, 2, 3],
    (3,0,1): [1, 2, 3, 5],
}

# For each orbit representative, compute EMDs to representatives of other orbits
print("=== EMD analysis ===")
for rep in [(4,0,0), (3,1,0), (2,2,0), (2,1,1), (3,0,1)]:
    print(f"\nFrom c = {rep}, Q_1 degrees = {Q1_vals[rep]}:")
    other_reps = [o[0] for o in orbits_d4 if rep not in o]
    for o in orbits_d4:
        if rep in o:
            continue
        # Compute min EMD from rep to any element of this orbit
        min_emd = min(emd_clockwise(rep, cp) for cp in o)
        emds = [emd_clockwise(rep, cp) for cp in o]
        print(f"  To orbit {o[0]}: EMDs = {emds}, min = {min_emd}")

# Let me also check if the degrees in Q_1 match the EMD values
# from the profile c to the 4 other orbit representatives

print("\n\n=== Checking if Q_1 degrees = sorted EMDs to other orbit reps ===")
for rep in [(4,0,0), (3,1,0), (2,2,0), (2,1,1), (3,0,1)]:
    emds_to_others = []
    for o in orbits_d4:
        if rep in o:
            continue
        # Use min EMD to this orbit
        min_emd = min(emd_clockwise(rep, cp) for cp in o)
        emds_to_others.append(min_emd)
    emds_to_others.sort()
    
    print(f"  c={rep}: Q_1 degrees = {Q1_vals[rep]}, min EMDs = {emds_to_others}")
    match = Q1_vals[rep] == emds_to_others
    print(f"    Match: {match}")

# Let me also try the clockwise EMD from c to orbit reps
print("\n\n=== Trying clockwise EMD to specific orbit reps ===")
orbit_reps = [(4,0,0), (3,1,0), (2,2,0), (2,1,1), (3,0,1)]
for rep in orbit_reps:
    emds = []
    for target_rep in orbit_reps:
        if target_rep == rep:
            continue
        emds.append(emd_clockwise(rep, target_rep))
    emds.sort()
    print(f"  c={rep}: CW-EMDs to other reps = {emds}, Q_1 degrees = {Q1_vals[rep]}")

# Try with different orbit representatives
print("\n=== Trying all orbit elements ===")
for rep in [(2,1,1)]:
    print(f"From c = {rep}:")
    all_targets = []
    for o in orbits_d4:
        if rep in o:
            continue
        for cp in o:
            e = emd_clockwise(rep, cp)
            all_targets.append((cp, e))
    all_targets.sort(key=lambda x: x[1])
    for cp, e in all_targets:
        print(f"  EMD to {cp} = {e}")
    
    # Q_1 has 4 terms: 2q + q^2 + q^3
    # degrees with multiplicity: 1,1,2,3
    # The 12 targets have EMDs covering these values?

