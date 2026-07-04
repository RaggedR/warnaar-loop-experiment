# Debug: the EMD formula might be wrong
# From Agent B: adj(I-A(x))[c,c'] = x^{EMD(c,c')}
# EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
# This is a SPECIFIC directed EMD, not the symmetric Wasserstein distance.

# Let me recheck. The EMD for the adjugate is the CLOCKWISE Earth Mover Distance
# on Z/3Z.

# Actually, looking at the synthesis more carefully:
# "adj(I-A(x))[c,c'] = x^{EMD(c,c')} where EMD is the Earth Mover's Distance 
# on Z/3Z with clockwise metric"

# For Z/3Z, the clockwise distance from i to j is (j-i) mod 3
# So moving one unit of mass from position 0 to position 1 costs 1,
# from 0 to 2 costs 2, etc.

# EMD(c,c') = minimum cost to transport mass distribution c to c'
# where cost of moving 1 unit from i to j = (j-i) mod 3

# For r=3, this is the asymmetric EMD. Let me compute it via LP or direct formula.

def emd_clockwise(c, cp):
    """Clockwise EMD on Z/3Z from c to cp.
    c and cp are compositions of the same total d.
    Cost of moving mass from position i to position j = (j-i) mod 3.
    """
    # For 3 positions, the LP is simple.
    # excess[i] = cp[i] - c[i] (how much more mass is needed at i)
    # We need to find flows f[i][j] >= 0 with:
    # sum_j f[i][j] - sum_j f[j][i] = excess[i]
    # Minimize sum f[i][j] * ((j-i) mod 3)
    
    # For r=3, there are only 6 possible flow directions (including cost-0 self-loops)
    # Non-trivial flows: 0->1 (cost 1), 1->2 (cost 1), 2->0 (cost 1),
    #                    0->2 (cost 2), 2->1 (cost 2), 1->0 (cost 2)
    
    # The optimal solution uses only clockwise (cost-1) flows:
    # It's like solving a circulation problem on a directed 3-cycle
    
    # Standard formula for 1d Wasserstein on a LINE:
    # EMD = sum |prefix_sums|
    # For a CYCLE with directed cost, we minimize over starting point.
    
    # Actually for directed cost on Z/3Z:
    # The cumulative excess S_k = sum_{i=0}^{k} (cp[i] - c[i])
    # S_0 = cp[0] - c[0], S_1 = S_0 + cp[1] - c[1], S_2 = 0 (since same total)
    
    # The min-cost flow on the directed cycle has cost:
    # sum of max(0, S_k) for the clockwise direction,
    # minus sum of min(0, S_k) * (cost of counterclockwise)
    # Hmm this is getting complicated.
    
    # Let me just solve by brute force for small d.
    d = sum(c)
    from itertools import product
    
    # Flows f01, f12, f20 (clockwise, cost 1 each)
    # and f02, f21, f10 (counterclockwise, cost 2 each)
    # Balance: at each node, outflow - inflow = excess
    # node 0: f01 + f02 - f10 - f20 = cp[0] - c[0]
    # node 1: f10 + f12 - f01 - f21 = cp[1] - c[1]  
    # node 2: f20 + f21 - f02 - f12 = cp[2] - c[2]
    # Cost = f01 + f12 + f20 + 2*(f02 + f21 + f10)
    
    e0 = cp[0] - c[0]
    e1 = cp[1] - c[1]
    e2 = cp[2] - c[2]
    
    best = float('inf')
    # Brute force: each flow in [0, d]
    for f01 in range(d+1):
        for f12 in range(d+1):
            for f20 in range(d+1):
                for f10 in range(d+1):
                    for f02 in range(d+1):
                        f21 = e2 - f20 + f02 + f12
                        if f21 < 0:
                            continue
                        # Check node 0: f01 + f02 - f10 - f20 = e0
                        if f01 + f02 - f10 - f20 != e0:
                            continue
                        # Check node 1: f10 + f12 - f01 - f21 = e1
                        if f10 + f12 - f01 - f21 != e1:
                            continue
                        cost = f01 + f12 + f20 + 2*(f02 + f21 + f10)
                        if cost < best:
                            best = cost
    return best

# Test for d=2
profiles_d2 = [(2,0,0),(1,1,0),(1,0,1),(0,2,0),(0,1,1),(0,0,2)]
print("Clockwise EMD matrix for d=2:")
for c in profiles_d2:
    row = [emd_clockwise(c, cp) for cp in profiles_d2]
    print(f"  {c}: {row}")

# Compare with the formula from Agent B
def emd_agentB(c, cp):
    """EMD formula from Agent B:
    EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
    """
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

print("\nAgent B EMD formula for d=2:")
for c in profiles_d2:
    row = [emd_agentB(c, cp) for cp in profiles_d2]
    print(f"  {c}: {row}")

# Also try: maybe the profile indexing is (c_0, c_1, c_2) where k=3 rows
# but the matrix A(x) might use a different convention

