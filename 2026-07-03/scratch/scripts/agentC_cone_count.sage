"""
Agent C: Count lattice points in the interlacing cone for general d.
The cone is: a_{i+1} <= a_i + c_{i+1} (mod 3 cyclically), a_i >= 0.
For large total weight, the count stabilizes.
"""
from sage.all import *

def count_cone_points(c, max_weight=20):
    """Count lattice points in interlacing cone by total weight."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    counts = []
    for total in range(max_weight):
        count = 0
        for a0 in range(total+1):
            for a1 in range(total+1-a0):
                a2 = total - a0 - a1
                if a1 <= a0 + c1 and a2 <= a1 + c2 and a0 <= a2 + c0:
                    count += 1
        counts.append(count)
    return counts

# Check for various d
for d in [2, 4, 5, 7, 8]:
    print(f"d = {d}:")
    # Use a representative profile
    if d == 2:
        profiles = [(1,1,0), (2,0,0)]
    elif d == 4:
        profiles = [(2,1,1), (3,0,1), (4,0,0)]
    elif d == 5:
        profiles = [(2,2,1), (3,1,1), (5,0,0)]
    elif d == 7:
        profiles = [(3,2,2), (4,2,1), (7,0,0)]
    elif d == 8:
        profiles = [(3,3,2), (4,2,2), (8,0,0)]
    
    expected_Qn1 = (d+1)*(d+2)//6 - 1
    print(f"  Expected Q_1(1) = {expected_Qn1}")
    
    for c in profiles:
        counts = count_cone_points(c, 15)
        # The stabilized value is the "eventual" count
        stable = counts[-1]
        print(f"  c={c}: counts = {counts[:12]}, stable = {stable}")
    print()

# KEY OBSERVATION: The stable count should be related to the number of lattice 
# points in the polytope a_i >= 0, a_{i+1} - a_i <= c_{i+1} (cyclic).
# Summing all three inequalities: 0 <= c_0 + c_1 + c_2 = d. Always true.
# So the constraints are 2-dimensional (up to translation along (1,1,1)).

# The number of orbits under the (1,1,1) translation is the "area" of the 
# fundamental domain, which should be the eventual count.

# For d=4, the stable count is always 5.
# For d=5, let me check.
print("\n\nd=5 detailed:")
for c in [(2,2,1), (3,1,1), (5,0,0), (4,1,0), (3,2,0)]:
    counts = count_cone_points(c, 20)
    print(f"  c={c}: stable = {counts[-1]}, counts = {counts[:12]}")

# Formula for the stable count: the number of lattice points in the 
# fundamental domain of the cone modulo (1,1,1)-translation.
# This is the number of (a_0, a_1, a_2) with 0 <= a_i, a_{i+1} <= a_i + c_{i+1},
# and 0 <= a_0 + a_1 + a_2 < 3 (one period of the translation).
# Wait, that's not right either. The period is 1 in each direction.

# Actually: by substituting b_i = a_i - n for large n, the constraints become
# b_{i+1} <= b_i + c_{i+1} with b_i unbounded below. But since we need a_i >= 0,
# the constraints become active only near the boundary.
# The eventual count is the NUMBER OF LATTICE POINTS in the "shape" defined by
# the cyclic differences.

# Let me think about it differently. The eventual count equals the coefficient
# of 1/(1-q) in the partial fraction of F_{c,1}.
# We showed F_{c,1} = p(q)/(1-q).
# So the eventual count is p(1).
# And Q_1 = p(q) - 1 + q^2. 
# Q_1(1) = p(1) - 1 + 1 = p(1).
# So Q_1(1) = eventual count of lattice points per unit weight!
# And Q_1(1) = (d+1)(d+2)/6 - 1.

# Wait, for d=4: eventual count = 5, but Q_1(1) = 4. Let me recheck.
# p(q) = [1, 2, 1, 1] for c=(2,1,1), so p(1) = 5.
# Q_1 = p(q) - 1 + q^2 = 2q + 2q^2 + q^3. Q_1(1) = 5 - 1 + 1 = 5. 
# But earlier we got Q_1(1) = 4!

# Hmm, there's a discrepancy. Let me recheck.
print("\n\nRechecking Q_1 for c=(2,1,1):")
R = PowerSeriesRing(QQ, 'q', default_prec=20)
q = R.gen()

# Verify using Agent B's method
from itertools import combinations

def shift_profile(c, J):
    result = list(c)
    J_set = set(J)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

d = 4
compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        compositions.append((c0, c1, d-c0-c1))
N = len(compositions)
comp_idx = {c: i for i, c in enumerate(compositions)}

Rx = PolynomialRing(QQ, 'x')
x_var = Rx.gen()
A_poly = matrix(Rx, N, N, 0)

for ic, c in enumerate(compositions):
    I_c = {i for i in range(3) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = comp_idx[cJ]
            A_poly[ic, jcJ] += sign * x_var**size

def eval_A(val):
    A_eval = matrix(R, N, N)
    for i in range(N):
        for j in range(N):
            poly = A_poly[i,j]
            v = R(0)
            for k, coeff in enumerate(poly.list()):
                v += coeff * val**k
            A_eval[i,j] = v
    return A_eval

I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))

v = vector(R, [R(1)] * N)
c_target = (2,1,1)
idx = comp_idx[c_target]

# F_{c,0} = 1
F0 = v[idx]
print(f"F_{{c,0}} = {F0}")

# F_{c,1} 
A1 = eval_A(q)
B1 = I_mat - A1
v1 = B1.inverse() * v
F1_matrix = v1[idx]
print(f"F_{{c,1}} from matrix = {F1_matrix.add_bigoh(15)}")

g1 = F1_matrix - F0
print(f"g_1 = {g1.add_bigoh(15)}")

# Q_1 = (1-q) * (g_1 * 1 + g_0 * (-q)) = (1-q) * (g_1 - q)
Q1 = (1-q) * (g1 - q)
print(f"Q_1 = {Q1.add_bigoh(15)}")
coeffs = [Q1[i] for i in range(20)]
max_deg = max((i for i in range(20) if coeffs[i] != 0), default=0)
print(f"Q_1 coefficients: {coeffs[:max_deg+1]}")
print(f"Q_1(1) = {sum(coeffs[:max_deg+1])}")

# Hmm wait, Q_1 = 2q + q^2 + q^3, sum = 4. Let me recheck my formula.
# p(q) = (1-q) * F_{c,1} = [1, 2, 1, 1]. p(1) = 1+2+1+1 = 5.
# Q_1 = (1-q)(g_1 - q) = (1-q)(F_{c,1} - 1 - q)
#      = (1-q)F_{c,1} - (1-q) - q(1-q)
#      = p(q) - 1 + q - q + q^2
#      = p(q) - 1 + q^2
# p(q) - 1 + q^2 = (1 + 2q + q^2 + q^3) - 1 + q^2 = 2q + 2q^2 + q^3.
# Sum = 2 + 2 + 1 = 5. But computed Q_1(1) = 4!

# There's a bug. Let me recompute from scratch.
print("\nDirect computation:")
print(f"(1-q)*g_1 = {((1-q)*g1).add_bigoh(15)}")
print(f"q*(1-q) = {(q*(1-q)).add_bigoh(10)}")
print(f"(1-q)*g_1 - q*(1-q) = {((1-q)*g1 - q*(1-q)).add_bigoh(15)}")
# Hmm that's = (1-q)*(g_1 - q), which is what I computed.

# Wait, maybe my F_{c,1} from the direct enumeration doesn't match the matrix computation?
# Let me check.
print(f"\nF_{{c,1}} from enumeration: 1 + 3q + 4q^2 + 5q^3 + ...")
print(f"F_{{c,1}} from matrix: {F1_matrix.add_bigoh(10)}")

# If they match, then Q_1 should be 2q + 2q^2 + q^3 with sum 5, not 4.
# But Agent B got Q_1 = 2q + q^2 + q^3 with sum 4!
# So either my enumeration is wrong, or the matrix computation gives different F_{c,1}.

