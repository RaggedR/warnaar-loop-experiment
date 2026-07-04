"""
Agent B: Understand the distance matrix D from the adjugate.

adj(I-A(q))[c,c'] = q^{D(c,c')} where D is an integer matrix.
D is NOT the L1/2 distance. What IS it?

Key observation: A(x) is the CW shift matrix with entries 
A[c,c'] = sum_J (-1)^{|J|-1} x^{|J|} if c(J) = c'.
The shifts move mass between adjacent positions cyclically.

D might be a graph distance on the shift graph (compositions connected by single shifts).
"""
from sage.all import *
from itertools import combinations

d = 4
r = 3

compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        c2 = d - c0 - c1
        compositions.append((c0, c1, c2))
N = len(compositions)
comp_idx = {c: i for i, c in enumerate(compositions)}

# The D matrix from previous computation:
D_raw = [
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
D = matrix(ZZ, D_raw)

# Is D symmetric? 
print("Is D symmetric?", D == D.transpose())

# D is NOT symmetric! D[c,c'] != D[c',c] in general.
# For example: D[(0,0,4),(0,1,3)] = 2, D[(0,1,3),(0,0,4)] = 1.
# So it's a DIRECTED distance.

# What ARE the single-step shifts?
# The matrix A has first-order terms A[c,c'] = x when c -> c' is a |J|=1 shift.
# |J|=1 shifts: one component decreases by 1, next one increases by 1 (cyclically).
# Specifically: c_i -> c_i - 1, c_{i-1 mod 3} -> c_{i-1 mod 3} + 1
# (for i in I_c, the shift moves mass from position i to position (i-1) mod 3)

# Wait, let me recheck. For J = {i}:
# c_i(J) = c_i - 1 (since i in J and (i-1) not in J, unless i-1 is also in J)
# c_{(i-1 mod 3)}(J) = c_{(i-1 mod 3)} + 1 (since (i-1) not in J and i in J)

# So the single shift J={i} moves one unit from position i to position (i-1 mod 3).
# These are the edges of the directed shift graph.

# For c = (c_0, c_1, c_2):
# J={0}: c_0 -1, c_2 +1 -> (c_0-1, c_1, c_2+1)
# J={1}: c_1 -1, c_0 +1 -> (c_0+1, c_1-1, c_2)
# J={2}: c_2 -1, c_1 +1 -> (c_0, c_1+1, c_2-1)

# So the directed graph has edges:
# (c_0, c_1, c_2) -> (c_0-1, c_1, c_2+1) [shift 0->2]
# (c_0, c_1, c_2) -> (c_0+1, c_1-1, c_2) [shift 1->0]
# (c_0, c_1, c_2) -> (c_0, c_1+1, c_2-1) [shift 2->1]

# And D[c,c'] is the shortest directed path length in this graph?
# Let me check.

# Build the directed graph
from sage.graphs.digraph import DiGraph
G = DiGraph()
for c in compositions:
    G.add_vertex(c)
    # Add edges for single shifts
    shifts = [
        (c[0]-1, c[1], c[2]+1),   # J={0}
        (c[0]+1, c[1]-1, c[2]),    # J={1}
        (c[0], c[1]+1, c[2]-1),    # J={2}
    ]
    for cp in shifts:
        if min(cp) >= 0 and sum(cp) == d:
            G.add_edge(c, cp)

# Compute shortest directed distances
print("\nDirected graph shortest distances:")
match = True
for i in range(N):
    for j in range(N):
        c = compositions[i]
        cp = compositions[j]
        try:
            dist = G.shortest_path_length(c, cp)
        except Exception:
            dist = -1
        if dist != D[i,j]:
            match = False
            if abs(i-j) <= 3:  # only print nearby pairs
                print(f"  D[{c},{cp}] = {D[i,j]}, graph_dist = {dist}")

if match:
    print("  YES! D[c,c'] = directed shortest path length in the CW shift graph!")
else:
    print("  MISMATCH between D and graph distance")
    
    # Print the first few mismatches
    count = 0
    for i in range(N):
        for j in range(N):
            c = compositions[i]
            cp = compositions[j]
            try:
                dist = G.shortest_path_length(c, cp)
            except:
                dist = -1
            if dist != D[i,j]:
                print(f"  D[{c},{cp}] = {D[i,j]}, graph_dist = {dist}")
                count += 1
                if count > 10:
                    break
        if count > 10:
            break

# Check if D is related to the CYCLIC distance on the simplex
# The shift graph has 3 types of edges. Each edge moves mass cyclically.
# On the simplex Delta_d = {(c0,c1,c2) : sum = d, ci >= 0},
# the cyclic shifts rotate mass: 0->2, 1->0, 2->1.
# So each shift is a "clockwise" rotation by 1 step.
# The distance D[c,c'] should be the minimum number of clockwise unit transfers
# to get from c to c'.

# This is equivalent to: the minimum number of single-unit cyclic transfers
# needed to transform c into c'.

# For (2,1,1) -> (1,2,1): need to move 1 from position 0 to position 1.
# But shift 1->0 moves from 1 to 0 (wrong direction).
# Shift 2->1 moves from 2 to 1 (partial).
# Hmm, the shifts are:
#   J={0}: 0->2 (move from 0 to 2)
#   J={1}: 1->0 (move from 1 to 0)
#   J={2}: 2->1 (move from 2 to 1)
# So to go from (2,1,1) to (1,2,1), we need c0 to decrease by 1 and c1 to increase by 1.
# Shift J={2} does exactly this (c_2 -1, c_1 +1) -> (2, 2, 0). But that's not (1,2,1).
# No! J={2}: (c_0, c_1+1, c_2-1). So (2,1,1) -> (2,2,0). Then we need (2,2,0) -> (1,2,1).
# J={0}: (1, 2, 1). YES! Two steps: (2,1,1) ->{2} (2,2,0) ->{0} (1,2,1).
# But D[(2,1,1), (1,2,1)] = 1, not 2!

# Hmm. But adjacency in the shift graph is with edges from J={0},{1},{2}.
# (2,1,1) -> (1,1,2) via J={0}: c0-1, c2+1 = (1,1,2). Weight = q^1.
# (2,1,1) -> (3,0,1) via J={1}: c0+1, c1-1 = (3,0,1). Weight = q^1.
# (2,1,1) -> (2,2,0) via J={2}: c1+1, c2-1 = (2,2,0). Weight = q^1.
# So 1-step neighbors of (2,1,1) are (1,1,2), (3,0,1), (2,2,0).
# But D[(2,1,1), (1,2,1)] = 1, and (1,2,1) is NOT a 1-step neighbor!

# So D is NOT the shortest path in the shift graph. The adjugate encodes
# something different.

# Let me think about what the adjugate represents algebraically.
# adj(I-A(x)) is a matrix of cofactors. The (i,j) cofactor is
# (-1)^{i+j} times the determinant of the (N-1)x(N-1) minor obtained
# by deleting row j and column i.

# For a matrix with polynomial entries of degree at most 3 (since A has 
# entries of degree at most 3), the (N-1)x(N-1) determinant has degree
# at most 3*(N-1) = 42 for N=15. But our cofactors are MONOMIALS of degree
# at most 8. This is a very special structure.

# The fact that adj(I-A(x)) has monomial entries means that the cofactors
# are monomials. This is extremely special and likely has a combinatorial
# explanation (e.g., via the matrix-tree theorem or related).

# IMPORTANT: Since adj(I-A(x))[c,c'] = x^{D(c,c')} (with coefficient 1),
# the matrix product formula gives:
# P_n(c) = sum_{c_0 -> c_1 -> ... -> c_n = all compositions}
#           prod_{k=1}^n q^{k * D(c_{k-1}, c_k)}
# where the sum is over ALL sequences of compositions.

# No wait, v_n = prod_{k=1}^n (I-A(q^k))^{-1} * v_0
# = prod_{k=1}^n adj(I-A(q^k)) / (1-q^{3k}) * v_0
# Since adj(I-A(q^k))[c,c'] = q^{k*D(c,c')}, this gives:
# (q^3;q^3)_n * F_{c,n} = sum_{c_1,...,c_{n-1}} prod_{k=1}^n q^{k*D(c_{k-1},c_k)}
# where c_0 = some profile, c_n runs over all, and we sum over all.

# Wait, v_0 = (1,...,1), so:
# (q^3;q^3)_n * F_{c,n} = sum over all paths c = c_0 -> c_1 -> ... -> c_{n-1}
#                          starting at c, of prod_{k=1}^n ??? 

# Actually the product goes adj_n * adj_{n-1} * ... * adj_1 * v_0.
# [adj_k * v]_c = sum_{c'} adj_k[c,c'] * v[c'] = sum_{c'} q^{k*D(c,c')} * v[c']

# So P_n(c) = (q^3;q^3)_n * F_{c,n}(c) 
#           = sum_{c_1,...,c_{n-1}} q^{n*D(c,c_1) + (n-1)*D(c_1,c_2) + ... + 1*D(c_{n-1},*)}
# Wait no. Let me be more careful.

# v_n = B_n^{-1} * v_{n-1} = adj_n/(1-q^{3n}) * v_{n-1}
# So (q^3;q^3)_n * v_n = adj_n * adj_{n-1} * ... * adj_1 * v_0.

# Actually: (1-q^3) * v_1 = adj_1 * v_0
#           (1-q^3)(1-q^6) * v_2 = adj_2 * adj_1 * v_0
# Wait, v_1 = B_1^{-1} v_0, v_2 = B_2^{-1} v_1 = B_2^{-1} B_1^{-1} v_0.
# (1-q^3)(1-q^6) * v_2 = (1-q^6) * adj_1/(1-q^3) * ... no.
# B_k^{-1} = adj_k / det(B_k) = adj_k / (1-q^{3k}).
# v_n = adj_n/(1-q^{3n}) * adj_{n-1}/(1-q^{3(n-1)}) * ... * adj_1/(1-q^3) * v_0
# prod_{k=1}^n (1-q^{3k}) * v_n = adj_n * adj_{n-1} * ... * adj_1 * v_0
# i.e., (q^3;q^3)_n * v_n = adj_n * adj_{n-1} * ... * adj_1 * v_0.

# Since adj_k[c,c'] = q^{k*D(c,c')}, the product is:
# [adj_n * adj_{n-1} * ... * adj_1 * v_0]_c 
# = sum_{c_{n-1},...,c_1,c_0} adj_n[c,c_{n-1}] adj_{n-1}[c_{n-1},c_{n-2}] ... adj_1[c_1,c_0] * v_0[c_0]
# = sum_{c_{n-1},...,c_0} q^{n*D(c,c_{n-1}) + (n-1)*D(c_{n-1},c_{n-2}) + ... + 1*D(c_1,c_0)}
# = sum_{path c = c_n, c_{n-1}, ..., c_0} q^{sum_{k=1}^n k*D(c_k, c_{k-1})}

# This is a MANIFESTLY POSITIVE multisum (all exponents nonneg)!
# So P_n = (q^3;q^3)_n * F_{c,n} has a manifestly positive interpretation
# as a sum over paths in the composition space, weighted by the distance function D.

# This is KURSUNGOZ'S RESULT (P_n >= 0) with a NEW PROOF via the adjugate!
# The question is: can we get Q_n from this?

print("\n\n" + "=" * 60)
print("THE ADJUGATE PATH FORMULA")
print("=" * 60)
print("""
P_n(c) = (q^3;q^3)_n * F_{c,n} = sum_{c_0,...,c_{n-1}} q^{sum_{k=1}^n k*D(c_k,c_{k-1})}

where c_n = c (the target profile) and c_0,...,c_{n-1} range over all compositions.

This is manifestly nonneg because D >= 0 (all adjugate entries are q^{nonneg}).

The distance D(c,c') is the valuation of adj(I-A(q))[c,c'], which is a monomial
with coefficient 1. The key properties:
- D is NOT symmetric: D(c,c') != D(c',c) in general
- D(c,c) = 0 for all c
- adj(I-A(q^k))[c,c'] = q^{k*D(c,c')} (exact scaling)
""")

# Now: Q_n involves (zq;q)_inf * F_c(z,q). Can we relate Q_n to a SIGNED
# sum over paths, and then show the signs cancel to give nonneg result?

# Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{T_{n-j}} F_{c,j} / (q;q)_{n-j} * (q;q)_j / (q;q)_j
# = (q;q)_n * sum_j (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}
# = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * F_{c,j}

# Since P_j = (q^3;q^3)_j * F_{c,j}:
# F_{c,j} = P_j / (q^3;q^3)_j

# Q_n = sum_j (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^3;q^3)_j

# This is an alternating-sign linear combination of the P_j values!
# P_j >= 0 is known, but the coefficients alternate.

# However, P_j has the path formula. So Q_n = sum over paths with signs.
# The question: do the signs cancel?

# Let me compute the EXACT Q_n for several profiles and n, using the path formula.
# First, let me verify D for d=7 to see if the monomial adjugate structure persists.

print("\n\n" + "=" * 60)
print("Checking monomial adjugate for d=7")
print("=" * 60)

d7 = 7
r7 = 3
PREC7 = 50
R7 = PowerSeriesRing(QQ, 'q', default_prec=PREC7)
q7 = R7.gen()

comps7 = []
for c0 in range(d7+1):
    for c1 in range(d7+1-c0):
        c2 = d7 - c0 - c1
        comps7.append((c0, c1, c2))
N7 = len(comps7)
cidx7 = {c: i for i, c in enumerate(comps7)}

def shift_profile7(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

Rx7 = PolynomialRing(QQ, 'x')
x7 = Rx7.gen()
A7_poly = matrix(Rx7, N7, N7, 0)

for ic, c in enumerate(comps7):
    I_c = {i for i in range(r7) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile7(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = cidx7[cJ]
            A7_poly[ic, jcJ] += sign * x7**size

# Check det
I7 = matrix(Rx7, N7, N7, lambda i,j: 1 if i==j else 0)
D7 = (I7 - A7_poly).determinant()
print(f"det(I-A(x)) for d=7: {D7} (should be -(x^3-1))")

# Evaluate at q and compute adjugate
A7q = matrix(R7, N7, N7)
for i in range(N7):
    for j in range(N7):
        poly = A7_poly[i,j]
        v = R7(0)
        for k, coeff in enumerate(poly.list()):
            v += coeff * q7**k
        A7q[i,j] = v

I7R = matrix(R7, N7, N7, lambda i,j: R7(1) if i==j else R7(0))
B7 = I7R - A7q
det7 = 1 - q7**3
B7_inv = B7.inverse()
adj7 = det7 * B7_inv

# Check if all entries are monomials with coefficient 1
all_mono7 = True
max_terms = 0
for i in range(N7):
    for j in range(N7):
        entry = adj7[i,j]
        coeffs = list(entry)[:PREC7]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) > 1:
            all_mono7 = False
            max_terms = max(max_terms, len(nonzero))
        elif len(nonzero) == 1 and nonzero[0][1] != 1:
            all_mono7 = False

if all_mono7:
    print(f"d=7: ALL {N7}x{N7} = {N7**2} adjugate entries are monomials with coefficient 1!")
else:
    print(f"d=7: NOT all monomials (max terms = {max_terms})")

# Print D for profile (3,2,2) row
idx_322 = cidx7[(3,2,2)]
print(f"\nValuation row for c=(3,2,2):")
vals = []
for j in range(N7):
    v = adj7[idx_322, j].valuation()
    vals.append(v)
print(f"  Valuations: {vals}")
print(f"  Max valuation: {max(vals)}")

