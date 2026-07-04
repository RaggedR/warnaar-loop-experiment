"""
Agent B: Identify D(c,c') as an earth mover's distance on Z/3Z.

The shifts in the CW recurrence move 1 unit clockwise:
  J={0}: position 0 -> position 1 (cost 1)
  J={1}: position 1 -> position 2 (cost 1)
  J={2}: position 2 -> position 0 (cost 1)

D(c,c') should be the minimum TOTAL clockwise transport cost to transform
distribution c into distribution c'.

On the cyclic group Z/3Z, the cost of moving 1 unit from position i to position j
via clockwise steps is (j-i) mod 3. But we're counting the TOTAL number of 
individual unit transfers.

The Earth Mover's Distance on Z/3Z with the CLOCKWISE metric:
  d(i,j) = (j-i) mod 3   (cost to move 1 unit from i to j clockwise)

EMD(c,c') = min sum_{i,j} f_{ij} * d(i,j) subject to:
  sum_j f_{ij} - sum_j f_{ji} = c'_i - c_i for all i
  f_{ij} >= 0

For Z/3Z with clockwise cost d(i,j) = (j-i) mod 3:
  d(0,0) = 0, d(0,1) = 1, d(0,2) = 2
  d(1,0) = 2, d(1,1) = 0, d(1,2) = 1
  d(2,0) = 1, d(2,1) = 2, d(2,2) = 0

Let me compute this EMD and check against D.
"""
from sage.all import *

# Compute clockwise EMD on Z/3Z
def clockwise_emd(c, cp):
    """EMD on Z/3Z with clockwise metric d(i,j) = (j-i) mod 3."""
    # Solve the optimal transport problem
    # We need to minimize sum f_ij * ((j-i) mod 3)
    # subject to flow conservation: outflow - inflow = c'_i - c_i at each i
    
    # For Z/3Z, this can be solved by a flow decomposition.
    # The excess at each position: e_i = c'_i - c_i
    # sum e_i = 0
    
    # Optimal: route flow clockwise around the cycle.
    # The cumulative excess determines the flow on each edge.
    
    # Edges: 0->1, 1->2, 2->0 (clockwise)
    # Flow on edge (i, (i+1)%3): f_i
    # Conservation: f_{(i-1)%3} - f_i = e_i = c'_i - c_i
    # f_{2} - f_0 = c'_0 - c_0
    # f_{0} - f_1 = c'_1 - c_1
    # f_{1} - f_2 = c'_2 - c_2
    
    e = [cp[i] - c[i] for i in range(3)]
    
    # f_0 - f_1 = e_1
    # f_1 - f_2 = e_2
    # f_2 - f_0 = e_0
    # One free variable, say f_0 = t.
    # f_1 = t - e_1
    # f_2 = t - e_1 - e_2 = t + e_0 (since e_0 + e_1 + e_2 = 0)
    
    # Total cost: f_0 + f_1 + f_2 = t + (t - e_1) + (t + e_0) = 3t + e_0 - e_1
    # subject to t >= 0, t - e_1 >= 0, t + e_0 >= 0
    # i.e., t >= max(0, e_1, -e_0)
    
    # Minimum cost: 3 * max(0, e_1, -e_0) + e_0 - e_1
    
    t_min = max(0, e[1], -e[0])
    cost = 3 * t_min + e[0] - e[1]
    return cost

# Check against d=2 adjugate
comp2 = [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]

D_adj = [
    [0, 1, 2, 2, 3, 4],
    [2, 0, 1, 1, 2, 3],
    [1, 2, 0, 3, 1, 2],
    [4, 2, 3, 0, 1, 2],
    [3, 1, 2, 2, 0, 1],
    [2, 3, 1, 4, 2, 0],
]

print("d=2: Checking if D = clockwise EMD:")
match = True
for i in range(6):
    for j in range(6):
        emd = clockwise_emd(comp2[i], comp2[j])
        if emd != D_adj[i][j]:
            match = False
            print(f"  D[{comp2[i]},{comp2[j]}] = {D_adj[i][j]}, EMD = {emd}")

if match:
    print("  YES! D = clockwise EMD for d=2!")
else:
    print("  Checking detailed mismatches...")

# Check d=4
comp4 = []
for c0 in range(5):
    for c1 in range(5-c0):
        c2 = 4 - c0 - c1
        comp4.append((c0, c1, c2))

D4_adj = [
    [0, 2, 4, 6, 8, 1, 3, 5, 7, 2, 4, 6, 3, 5, 4],
    [1, 0, 2, 4, 6, 2, 1, 3, 5, 3, 2, 4, 4, 3, 5],
    [2, 1, 0, 2, 4, 3, 2, 1, 3, 4, 3, 2, 5, 4, 6],
    [3, 2, 1, 0, 2, 4, 3, 2, 1, 5, 4, 3, 6, 5, 7],
    [4, 3, 2, 1, 0, 5, 4, 3, 2, 6, 5, 4, 7, 6, 8],
    [2, 1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 2, 4, 3],
    [3, 2, 1, 3, 5, 1, 0, 2, 4, 2, 1, 3, 3, 2, 4],
    [4, 3, 2, 1, 3, 2, 1, 0, 2, 3, 2, 1, 4, 3, 5],
    [5, 4, 3, 2, 1, 3, 2, 1, 0, 4, 3, 2, 5, 4, 6],
    [4, 3, 2, 4, 6, 2, 1, 3, 5, 0, 2, 4, 1, 3, 2],
    [5, 4, 3, 2, 4, 3, 2, 1, 3, 1, 0, 2, 2, 1, 3],
    [6, 5, 4, 3, 2, 4, 3, 2, 1, 2, 1, 0, 3, 2, 4],
    [6, 5, 4, 3, 5, 4, 3, 2, 4, 2, 1, 3, 0, 2, 1],
    [7, 6, 5, 4, 3, 5, 4, 3, 2, 3, 2, 1, 1, 0, 2],
    [8, 7, 6, 5, 4, 6, 5, 4, 3, 4, 3, 2, 2, 1, 0],
]

print("\nd=4: Checking if D = clockwise EMD:")
match4 = True
for i in range(15):
    for j in range(15):
        emd = clockwise_emd(comp4[i], comp4[j])
        if emd != D4_adj[i][j]:
            match4 = False

if match4:
    print("  YES! D = clockwise EMD for d=4!")
else:
    # Count mismatches
    mismatch = 0
    for i in range(15):
        for j in range(15):
            emd = clockwise_emd(comp4[i], comp4[j])
            if emd != D4_adj[i][j]:
                mismatch += 1
                if mismatch <= 5:
                    print(f"  D[{comp4[i]},{comp4[j]}] = {D4_adj[i][j]}, EMD = {emd}")
    print(f"  Total mismatches: {mismatch} out of {15**2}")

# Now check d=1
comp1 = [(1,0,0), (0,1,0), (0,0,1)]
D1_adj = [[0,1,2], [2,0,1], [1,2,0]]

print("\nd=1: Checking if D = clockwise EMD:")
match1 = True
for i in range(3):
    for j in range(3):
        emd = clockwise_emd(comp1[i], comp1[j])
        if emd != D1_adj[i][j]:
            match1 = False
            print(f"  D[{comp1[i]},{comp1[j]}] = {D1_adj[i][j]}, EMD = {emd}")
if match1:
    print("  YES! D = clockwise EMD for d=1!")

