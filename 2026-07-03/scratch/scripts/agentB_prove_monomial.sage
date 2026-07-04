"""
Agent B: Investigate WHY adj(I-A(x)) has monomial entries.

Key observation: I-A(x) has polynomial entries with alternating signs.
The adjugate (matrix of cofactors) turns out to have MONOMIAL entries.
This is extremely special.

Hypothesis: I-A(x) is related to an incidence matrix of a poset or graph,
and the cofactor formula gives a combinatorial interpretation.

Let me examine the structure of A(x) more carefully.

The matrix A(x) has entries:
- A[c,c'] = x if there's a single shift J={i} taking c to c'
- A[c,c'] = -x^2 if there's a double shift J={i,j} taking c to c'
- A[c,c'] = x^3 if there's a triple shift J={0,1,2} taking c to c'

The single shifts form a DIRECTED GRAPH on compositions.
The double shifts are "2-step combinations" and the triple shift is the "full rotation."

For rank r=3: the single shifts rotate mass cyclically:
  J={0}: c_0 -= 1, c_2 += 1  (rotate from 0 to 2, i.e., counterclockwise)
  J={1}: c_1 -= 1, c_0 += 1  (rotate from 1 to 0)
  J={2}: c_2 -= 1, c_1 += 1  (rotate from 2 to 1)

All three shifts rotate mass in the SAME cyclic direction!
Each shift is a counterclockwise rotation by 1 step.

The double shifts:
  J={0,1}: c_0 -= 1, c_1 -= 1, c_2 += 1, c_0 += 1 -> net: c_1 -= 1, c_2 += 1
  Wait let me recompute. J={0,1}: 
  i=0: in J, prev=2 not in J -> c_0 -= 1
  i=1: in J, prev=0 in J -> no change to c_1
  i=2: not in J, prev=1 in J -> c_2 += 1
  So c(J={0,1}) = (c_0-1, c_1, c_2+1). 
  BUT! This is the SAME as c(J={0}) = (c_0-1, c_1, c_2+1)!

Wait, that can't be right. Let me recheck.

For J={0}: 
  i=0: in J, prev=2 not in J -> c_0 -= 1
  i=1: not in J, prev=0 in J -> c_1 += 1
  i=2: not in J, prev=1 not in J -> no change
  c(J={0}) = (c_0-1, c_1+1, c_2)

For J={1}:
  i=0: not in J, prev=2 not in J -> no change
  i=1: in J, prev=0 not in J -> c_1 -= 1
  i=2: not in J, prev=1 in J -> c_2 += 1
  c(J={1}) = (c_0, c_1-1, c_2+1)

For J={2}:
  i=0: not in J, prev=2 in J -> c_0 += 1
  i=1: not in J, prev=0 not in J -> no change
  i=2: in J, prev=1 not in J -> c_2 -= 1
  c(J={2}) = (c_0+1, c_1, c_2-1)

OK so:
  J={0}: (c_0-1, c_1+1, c_2)   -- move from 0 to 1
  J={1}: (c_0, c_1-1, c_2+1)   -- move from 1 to 2
  J={2}: (c_0+1, c_1, c_2-1)   -- move from 2 to 0

These are all CLOCKWISE rotations by 1 step!

For J={0,1}:
  i=0: in J, prev=2 not in J -> c_0 -= 1
  i=1: in J, prev=0 in J -> no change to c_1
  i=2: not in J, prev=1 in J -> c_2 += 1
  c(J={0,1}) = (c_0-1, c_1, c_2+1) -- net: move from 0 to 2

For J={0,2}:
  i=0: in J, prev=2 in J -> no change to c_0
  i=1: not in J, prev=0 in J -> c_1 += 1
  i=2: in J, prev=1 not in J -> c_2 -= 1
  c(J={0,2}) = (c_0, c_1+1, c_2-1) -- net: move from 2 to 1

For J={1,2}:
  i=0: not in J, prev=2 in J -> c_0 += 1
  i=1: in J, prev=0 not in J -> c_1 -= 1
  i=2: in J, prev=1 in J -> no change to c_2
  c(J={1,2}) = (c_0+1, c_1-1, c_2) -- net: move from 1 to 0

For J={0,1,2}:
  i=0: in J, prev=2 in J -> no change
  i=1: in J, prev=0 in J -> no change
  i=2: in J, prev=1 in J -> no change
  c(J={0,1,2}) = (c_0, c_1, c_2) -- no change (identity!)

So the CW shifts organize as:
|J|=1: move 1 unit clockwise by 1 step (3 directions)
|J|=2: move 1 unit COUNTERCLOCKWISE by 1 step (equivalent to clockwise by 2) (3 directions)
|J|=3: identity (no movement)

And A(x) = x * (sum of clockwise shifts) - x^2 * (sum of counterclockwise shifts) + x^3 * I

Let me define:
  S+ = clockwise shift matrix (A[c,c'] = 1 if c' is obtained by moving 1 unit clockwise)
  S- = counterclockwise shift matrix

Then A(x) = x * S+ - x^2 * S- + x^3 * I

But S- = (S+)^{-1}? No, S+ is not invertible -- it's a directed graph adjacency matrix.
Actually, S- is the TRANSPOSE-like counterpart. Since clockwise and counterclockwise
are opposite rotations, S- is related to S+ by transposition or inversion.

Let me think about this more carefully with the specific structure.

Actually: For a profile c with ALL c_i > 0, the clockwise shifts give 3 neighbors.
For c with some c_i = 0, fewer shifts are available.

The matrix A(x) over the ring Z[x] has the structure:
I - A(x) = I - x*S+ + x^2*S- - x^3*I = (1-x^3)*I - x*S+ + x^2*S-

And det(I-A(x)) = 1 - x^3 = (1-x)(1+x+x^2).

This is EXACTLY (1-x^3)*det(I) if the matrix (I - A(x))/(1-x^3) were the identity.
But it's not -- instead, the adjugate absorbs all the structure.

KEY QUESTION: Can we prove that adj((1-x^3)I - xS+ + x^2 S-) has monomial entries?

Let me verify this algebraically for small d.
"""
from sage.all import *
from itertools import combinations

# For d=1, the compositions of 1 into 3 parts are:
# (1,0,0), (0,1,0), (0,0,1)
# N=3, which is nice for explicit computation.

print("=" * 60)
print("d=1: Explicit computation")
print("=" * 60)

d = 1
r = 3
compositions = [(1,0,0), (0,1,0), (0,0,1)]
N = 3
comp_idx = {c: i for i, c in enumerate(compositions)}

def shift_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

Rx = PolynomialRing(QQ, 'x')
x = Rx.gen()

A = matrix(Rx, N, N, 0)
for ic, c in enumerate(compositions):
    I_c = {i for i in range(r) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = comp_idx[cJ]
            A[ic, jcJ] += sign * x**size

print("A(x) for d=1:")
print(A)
print()

I_mat = matrix(Rx, N, N, lambda i,j: 1 if i==j else 0)
B = I_mat - A
print("I - A(x):")
print(B)
print()

det_B = B.determinant()
print(f"det(I-A(x)) = {det_B}")

# Adjugate
adj_B = B.adjugate()
print("\nadj(I-A(x)):")
print(adj_B)
print()

# Check if entries are monomials
for i in range(N):
    for j in range(N):
        entry = adj_B[i,j]
        print(f"  adj[{compositions[i]}, {compositions[j]}] = {entry}")

# For d=1: the compositions are (1,0,0), (0,1,0), (0,0,1).
# Only |J|=1 shifts exist (since each profile has exactly one nonzero component).
# J={0} for (1,0,0): c(J) = (0,1,0). Weight x.
# J={1} for (0,1,0): c(J) = (0,0,1). Weight x.
# J={2} for (0,0,1): c(J) = (1,0,0). Weight x.
# So A(x) is a permutation matrix times x!
# A = x * P where P is the cyclic permutation (1,0,0)->(0,1,0)->(0,0,1)->(1,0,0).
# I - A(x) = I - x*P.
# det(I - xP) = 1 - x^3 (since P^3 = I).
# adj(I - xP) = ?

# P is the matrix with P[i,(i+1)%3] = 1.
# (I-xP)^{-1} = (I + xP + x^2 P^2) / (1-x^3).
# So adj(I-xP) = (1-x^3) * (I-xP)^{-1} = I + xP + x^2 P^2.
# adj[i,j] = x^{dist(i,j)} where dist is the cyclic distance from i to j via P.
print("\nFor d=1: adj(I-xP) = I + xP + x^2 P^2")
print("This is a CYCLIC DISTANCE matrix!")

# So for d=1, adj(I-A(x))[c,c'] = x^{cyclic_dist(c,c')} where the cyclic distance
# is the number of clockwise steps from c to c'.

# For GENERAL d: the structure should be similar but the "distance" is more complex.
# The compositions form a larger space, and the shifts are generalized cyclic rotations.

print("\n" + "=" * 60)
print("d=2: Explicit computation")
print("=" * 60)

d = 2
compositions2 = [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]
N2 = len(compositions2)
comp_idx2 = {c: i for i, c in enumerate(compositions2)}

A2 = matrix(Rx, N2, N2, 0)
for ic, c in enumerate(compositions2):
    I_c = {i for i in range(r) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            if cJ in comp_idx2:
                jcJ = comp_idx2[cJ]
                A2[ic, jcJ] += sign * x**size

B2 = matrix(Rx, N2, N2, lambda i,j: 1 if i==j else 0) - A2
det2 = B2.determinant()
adj2 = B2.adjugate()

print(f"det(I-A(x)) for d=2: {det2}")
print("\nadj(I-A(x)) for d=2:")
for i in range(N2):
    for j in range(N2):
        entry = adj2[i,j]
        if entry != 0:
            terms = len(entry.list())
            if terms > 1:
                print(f"  MULTI-TERM: adj[{compositions2[i]}, {compositions2[j]}] = {entry}")
            else:
                print(f"  adj[{compositions2[i]}, {compositions2[j]}] = {entry}")

# Check if all entries are monomials
all_mono = True
for i in range(N2):
    for j in range(N2):
        entry = adj2[i,j]
        if entry == 0:
            continue
        coeffs = entry.list()
        nonzero = [c for c in coeffs if c != 0]
        if len(nonzero) > 1:
            all_mono = False
            
if all_mono:
    print("\nd=2: All adjugate entries are monomials!")
    print("\nValuation matrix:")
    for i in range(N2):
        row = []
        for j in range(N2):
            entry = adj2[i,j]
            if entry == 0:
                row.append(-1)
            else:
                row.append(entry.degree())
        print(f"  {compositions2[i]}: {row}")
else:
    print("\nd=2: NOT all monomials")

# For d=2 check: the distance function D should relate to 
# the minimum number of unit transfers needed.
# A unit transfer moves 1 unit from position i to position (i+1)%3.
# (These are the |J|=1 shifts.)
# D(c,c') = minimum weighted transfers.

# But D is NOT the graph distance (as we found for d=4).
# It's something else -- perhaps a TROPICAL distance?

# KEY INSIGHT: The adjugate being monomial means that the matrix I-A(x)
# is a "tropical matrix" in some sense. The adjugate computation can
# be done in the tropical semiring (min-plus), where det -> permanent
# with min/+ instead of sum/*.

# In the tropical semiring, adj(B)[i,j] = minimum weight of a "spanning tree
# minus one edge" configuration. Since B = I - A(x) has a very specific structure,
# the minimum-weight configurations might correspond to unique paths.

# This is getting into tropical linear algebra territory. Let me check if
# the distance function D satisfies D(c,c') = min over "tropical spanning trees."

print("\n" + "=" * 60)
print("Trying to identify D(c,c') for d=4")
print("=" * 60)

# For d=4, I know D from the previous computation. Let me check a specific formula.
# 
# Hypothesis: D(c,c') is the MINIMUM of sum of abs differences weighted by position.
# Or perhaps it's related to the "earth mover's distance" on the cyclic group Z/3Z.

# The Earth Mover's Distance (EMD) on Z/3Z between distributions c and c' 
# (both summing to d) is the minimum total "work" to transform c into c',
# where work = amount * cyclic distance.

# For the cyclic group Z/3Z, the EMD can be computed as:
# EMD(c,c') = min over rotations r of sum_i max(0, c_i - c'_{(i+r)%3})

# Actually for distributions on Z/3Z, the EMD is:
# min_{f: Z/3Z -> R} sum_{edge (i,i+1)} |f(i)| subject to div(f) = c' - c

# Let me compute D(c,c') using a specific formula and check against the matrix.

# For c=(2,1,1), c'=(0,0,4):
# We need to move mass from (2,1,1) to (0,0,4).
# Net flow: c' - c = (-2, -1, 3).
# On the cycle 0->1->2->0, the flow must satisfy conservation.
# If f_{01} is flow from 0 to 1, f_{12} from 1 to 2, f_{20} from 2 to 0:
# f_{01} - f_{20} = -2 (outflow at 0)
# f_{12} - f_{01} = -1 (outflow at 1)
# f_{20} - f_{12} = 3 (outflow at 2)
# These sum to 0 (consistency). Two independent equations.
# f_{01} = f_{20} - 2, f_{12} = f_{01} - 1 = f_{20} - 3.
# Cost = |f_{01}| + |f_{12}| + |f_{20}| = |f_{20}-2| + |f_{20}-3| + |f_{20}|
# Minimize over f_{20}: minimum at f_{20} = 2: cost = 0 + 1 + 2 = 3.
# Or f_{20} = 3: cost = 1 + 0 + 3 = 4. So min = 3.
# But D[(2,1,1),(0,0,4)] = 5. Not matching!

# Hmm. But the shifts are DIRECTED. J={0} goes 0->1 (clockwise), not 0->1 undirected.
# In the CW recurrence, the single shifts are:
# J={0}: move from 0 to 1
# J={1}: move from 1 to 2
# J={2}: move from 2 to 0
# These are all CLOCKWISE.
# The counterclockwise shifts have |J|=2 and come with a MINUS sign in A(x).
# So in I-A(x), the counterclockwise shifts have positive coefficient x^2.

# The "distance" D should count the minimum number of clockwise unit transfers.
# From (2,1,1) to (0,0,4): need -2 at position 0, -1 at position 1, +3 at position 2.
# Using only clockwise transfers (0->1, 1->2, 2->0):
# f_{01} from 0->1, f_{12} from 1->2, f_{20} from 2->0.
# Constraint: f_{01} - f_{20} = -2, f_{12} - f_{01} = -1, f_{20} - f_{12} = 3.
# Since transfers are NONNEG: f_{01}, f_{12}, f_{20} >= 0.
# f_{01} = f_{20} - 2, f_{12} = f_{20} - 3. Both nonneg => f_{20} >= 3.
# Cost = f_{01} + f_{12} + f_{20} = (f_{20}-2) + (f_{20}-3) + f_{20} = 3*f_{20} - 5.
# Minimize: f_{20} = 3, cost = 4. 
# But D = 5.

# Hmm, that's 4 not 5. Let me try with clockwise being the OTHER direction.
# What if J={0}: move from 0 to (0-1)%3 = 2?
# Actually let me recheck: J={0} gives c(J) = (c_0-1, c_1+1, c_2).
# So c_0 DECREASES and c_1 INCREASES. This is a transfer from position 0 to position 1.
# In the cyclic ordering 0 -> 1 -> 2 -> 0, this is clockwise.

# The EMD with CLOCKWISE-ONLY transfers is called the "one-way EMD" or 
# "Wasserstein distance on Z_3 with directed metric."
# The cost is the total number of unit transfers.

# Let me try a different formula. Maybe the cost should be WEIGHTED by |J|.
# In the adjugate, A(x) has terms x^{|J|} for shifts of size |J|.
# The adjugate "inverts" this structure. The monomial x^D in the adjugate
# might correspond to a weighted sum where |J|=1 shifts cost 1, 
# |J|=2 shifts cost 2, but appear with coefficient -1 in the matrix.

# Actually, in the tropical adjugate, we're looking at the (N-1)x(N-1) minor
# determinant in the tropical sense. This involves finding a minimum-weight
# perfect matching in a bipartite graph.

# Let me just check: for the 3x3 case (d=1), the result is clear:
# D = cyclic distance. For d=2, let me check a few values.

# d=2 compositions: (2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)

# For d=2, build and print D
d2 = 2
comp2 = [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]
N2 = 6

print("\nD matrix for d=2:")
for i in range(N2):
    row = []
    for j in range(N2):
        entry = adj2[i,j]
        if entry == 0:
            row.append(-1)
        else:
            # valuation of a polynomial
            for k in range(20):
                if entry[k] != 0:
                    row.append(k)
                    break
            else:
                row.append(-1)
    print(f"  {comp2[i]}: {row}")

