"""
Seed 1 Layer 3: Verify the shift argument for monotonicity proof.

For each lattice point p = (a0,a1,a2) in P_w, count how many
of the three shifts (+1,0,0), (0,+1,0), (0,0,+1) land in P_{w+1}.

The key claim: at least 2 shifts always work (since at most 1 pair
of interlacing constraints can be simultaneously tight).
"""

from sage.all import *

def lattice_points_3d(c, w):
    """Return all lattice points (a0,a1,a2) with a_i >= 0, sum = w, interlacing."""
    c0, c1, c2 = c
    points = []
    for a0 in range(w+1):
        for a1 in range(w-a0+1):
            a2 = w - a0 - a1
            if a2 < 0:
                continue
            if a1 - a0 <= c1 and a2 - a1 <= c2 and a0 - a2 <= c0:
                points.append((a0, a1, a2))
    return points

def check_shifts(c, w_max=30):
    """For each point in P_w, check which shifts land in P_{w+1}."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    print(f"Profile c = {c}, d = {d}, base = {base}")
    
    min_valid_shifts = 3  # track minimum
    all_at_least_2 = True
    
    for w in range(w_max):
        pts_w = lattice_points_3d(c, w)
        pts_w1_set = set(lattice_points_3d(c, w+1))
        
        for p in pts_w:
            a0, a1, a2 = p
            valid = 0
            shifts = []
            
            # Shift a0
            new = (a0+1, a1, a2)
            if new in pts_w1_set:
                valid += 1
                shifts.append('+a0')
            
            # Shift a1
            new = (a0, a1+1, a2)
            if new in pts_w1_set:
                valid += 1
                shifts.append('+a1')
            
            # Shift a2
            new = (a0, a1, a2+1)
            if new in pts_w1_set:
                valid += 1
                shifts.append('+a2')
            
            if valid < min_valid_shifts:
                min_valid_shifts = valid
            
            if valid < 2:
                all_at_least_2 = False
                print(f"  w={w}, p={p}: only {valid} valid shifts: {shifts}")
                # Show which constraints are tight
                tight = []
                if a1 - a0 == c1: tight.append(f'a1-a0={c1}')
                if a2 - a1 == c2: tight.append(f'a2-a1={c2}')
                if a0 - a2 == c0: tight.append(f'a0-a2={c0}')
                if a0 == 0: tight.append('a0=0')
                if a1 == 0: tight.append('a1=0')
                if a2 == 0: tight.append('a2=0')
                print(f"    Tight constraints: {tight}")
    
    print(f"  Min valid shifts: {min_valid_shifts}")
    print(f"  All points have >= 2 valid shifts: {all_at_least_2}")
    return all_at_least_2, min_valid_shifts

# Test
profiles = [
    (1, 1, 0),   # d=2
    (2, 1, 1),   # d=4
    (2, 2, 1),   # d=5
    (3, 1, 1),   # d=5
    (3, 2, 2),   # d=7
    (4, 2, 1),   # d=7
    (3, 3, 2),   # d=8
    (5, 2, 1),   # d=8
    (4, 3, 3),   # d=10
    (5, 3, 2),   # d=10
    (5, 4, 4),   # d=13
    (6, 4, 4),   # d=14
]

print("=" * 70)
print("SHIFT ANALYSIS FOR MONOTONICITY PROOF")
print("=" * 70)

for c in profiles:
    d = sum(c)
    check_shifts(c, w_max=2*d+5)
    print()

