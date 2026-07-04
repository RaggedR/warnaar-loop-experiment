# Seed 3, Layer 3: Ehrhart theory for h_m base case.
#
# h_m = (q;q)_m * g_m where g_m counts CPs with max = m.
# The coefficient [q^w] g_m is the number of CPs of profile c with max = m and weight w.
#
# For the base case of the induction (h_m >= 0), we need to understand
# the structure of these counting functions.
#
# The claim that min_deg(h_m) = m and that the first m-1 coefficients of h_{m+1}
# match those of h_m (shifted by 1) suggests that g_m has a very regular
# structure near its minimum.
#
# Let's verify: for fixed profile c, the set of CPs with max <= N and weight = w
# is a set of lattice points in a polytope. Study this polytope.

from sage.all import *

# For profile c = (c_0, c_1, c_2) with k=3:
# A CP Lambda = (lambda^(0), lambda^(1), lambda^(2)) satisfies:
# lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}} for all j >= 1 (indices mod 3)
# and max(lambda^(i)_1) <= N

# The simplest case: CPs with max = 1 (binary CPs, all parts are 0 or 1)
# These are exactly the binary sequences that satisfy the interlacing conditions.

# For profile c = (2,1,1), d=4:
# A binary CP with max = 1 is: lambda^(i) are partitions into 0s and 1s
# lambda^(i) = (1^{a_i}) for some a_i >= 0
# The interlacing conditions become:
# 1 >= lambda^(1)_{1+1} = lambda^(1)_2 (if a_0 >= 1 and c_1 = 1)
# ... actually for max=1, the conditions simplify.

# Let me directly enumerate binary CPs for small profiles
def enumerate_binary_CPs(c, max_parts=10):
    """
    Enumerate CPs with max <= 1 (binary).
    Lambda = (lam0, lam1, lam2) where each lam_i is a partition with parts 0 or 1.
    lam_i = (1, 1, ..., 1, 0, 0, ...) = (1^{a_i}) for some a_i >= 0.
    
    The interlacing: lam^(i)_j >= lam^(i+1)_{j + c_{i+1}} for all j >= 1.
    With max = 1: lam^(i)_j = 1 if j <= a_i, else 0.
    So: 1_{j <= a_i} >= 1_{j + c_{i+1} <= a_{i+1}} = 1_{j <= a_{i+1} - c_{i+1}}
    
    This means: if j > a_i, then j > a_{i+1} - c_{i+1}, i.e., a_{i+1} < j + c_{i+1}.
    Equivalently: a_{i+1} <= a_i + c_{i+1} - 1 when a_i < j.
    
    Actually, the condition simplifies to: a_{i+1} <= a_i + c_{i+1}.
    Because: for all j >= 1, if lam^(i)_j = 0 (i.e., j > a_i),
    then lam^(i+1)_{j+c_{i+1}} = 0, i.e., j + c_{i+1} > a_{i+1},
    i.e., a_{i+1} < j + c_{i+1}.
    The tightest constraint is at j = a_i + 1: a_{i+1} < a_i + 1 + c_{i+1},
    i.e., a_{i+1} <= a_i + c_{i+1}.
    """
    k = len(c)
    # CPs with max=1 are parametrized by (a_0, a_1, ..., a_{k-1}) >= 0
    # with a_{i+1} <= a_i + c_{i+1} for all i (cyclic)
    
    # Weight = a_0 + a_1 + ... + a_{k-1}
    
    results = {}
    for a0 in range(max_parts + 1):
        for a1 in range(max_parts + 1):
            for a2 in range(max_parts + 1):
                # Check interlacing (cyclic)
                if a1 <= a0 + c[1] and a2 <= a1 + c[2] and a0 <= a2 + c[0]:
                    w = a0 + a1 + a2
                    results[w] = results.get(w, 0) + 1
    return results

# Test for c = (2, 1, 1)
c = (2, 1, 1)
binary_counts = enumerate_binary_CPs(c, max_parts=20)
print(f"Binary CPs for c={c}:")
for w in sorted(binary_counts.keys())[:20]:
    print(f"  weight {w}: {binary_counts[w]} CPs")

# g_1 = binary CP counts minus CP counts with max = 0
# g_0 = {0: 1} (empty CP)
# g_1 = binary_counts - {0: 1}
# But g_1 should give the coefficient of z^1 in F_c(z,q)

# Actually: F_{c,1}(q) = sum over CPs with max <= 1 of q^w
#         = sum_w (binary_counts[w]) q^w
# And F_{c,0}(q) = 1 (only empty CP with max <= 0? No, max <= 0 means all parts are 0.)
# Actually max <= 0 means all lambda^(i)_j <= 0, so all are 0. Only the empty CP.
# So F_{c,0}(q) = 1.
# g_1 = F_{c,1} - F_{c,0} = (binary_counts as polynomial) - 1
# h_1 = (1-q) * g_1

# Let me compute h_1
R = PolynomialRing(QQ, 'q')
q = R.gen()

F_c1 = sum(binary_counts[w] * q^w for w in binary_counts)
g1 = F_c1 - 1
h1 = (1 - q) * g1

print(f"\nF_{{c,1}} = {F_c1}")
print(f"g_1 = {g1}")
print(f"h_1 = {h1}")
print(f"h_1(1) = {h1(1)}")

# For d=4, c=(2,1,1): h_1 should be 3q + q^2 + q^3
# Check:

# Now study the cone structure for binary CPs
# The binary CPs at weight w form a lattice point set in the cone:
# {(a_0, a_1, a_2) in Z^3_{>=0} : a_1 <= a_0 + 1, a_2 <= a_1 + 1, a_0 <= a_2 + 2, a_0+a_1+a_2 = w}
# This is a 2-dimensional polytope (intersection of cone with hyperplane sum = w).

print(f"\n=== Lattice points in the cyclic polytope ===")
for w in range(1, 15):
    points = []
    for a0 in range(w + 1):
        for a1 in range(w - a0 + 1):
            a2 = w - a0 - a1
            if a2 >= 0 and a1 <= a0 + 1 and a2 <= a1 + 1 and a0 <= a2 + 2:
                points.append((a0, a1, a2))
    print(f"  w={w}: {len(points)} points: {points}")

# The Ehrhart polynomial of this polytope as w varies gives g_1 coefficients
# For large enough w, this should be a polynomial in w.
# Let's check: 
g1_coeffs = {w: binary_counts.get(w, 0) for w in range(30)}
print(f"\ng_1 coefficients (= lattice point counts):")
print([g1_coeffs[w] for w in range(20)])

# Check: is this sequence eventually polynomial?
# Diffs:
vals = [g1_coeffs[w] for w in range(20)]
diffs1 = [vals[i+1] - vals[i] for i in range(len(vals)-1)]
diffs2 = [diffs1[i+1] - diffs1[i] for i in range(len(diffs1)-1)]
print(f"First diffs: {diffs1}")
print(f"Second diffs: {diffs2}")

# For a 2D polytope, the Ehrhart quasi-polynomial should be linear for large w.
# That is, g_1[w] = A*w + B for large w (up to quasi-polynomial periodicity).

# The limit should be: g_1[w] -> base = (d+1)(d+2)/6 = 5 for d=4.
# Let's verify:
print(f"\nLarge-w behavior:")
for w in range(10, 30):
    print(f"  g_1[{w}] = {g1_coeffs.get(w, binary_counts.get(w, 0))}")

# Now for h_1 = (1-q) * g_1:
# [q^w] h_1 = g_1[w] - g_1[w-1]
# If g_1[w] is eventually constant (= base), then h_1[w] = 0 for large w.
# The non-zero part of h_1 is the "transient" before g_1 stabilizes.
print(f"\nh_1 = g_1 - q*g_1:")
h1_coeffs = {}
for w in range(30):
    h1_coeffs[w] = g1_coeffs.get(w, 0) - g1_coeffs.get(w-1, 0)
print([h1_coeffs[w] for w in range(10)])

# KEY OBSERVATION: g_1[w] is MONOTONICALLY INCREASING and converges to base.
# This is EXACTLY the Seed 6 observation about f_1 monotonicity.
# h_1 = first difference of g_1, which is nonneg because g_1 is increasing.

print("\n=== Monotonicity of g_1 ===")
print("g_1 is monotonically increasing:")
is_mono = all(g1_coeffs.get(w+1, 0) >= g1_coeffs.get(w, 0) for w in range(25))
print(f"  Verified: {is_mono}")

