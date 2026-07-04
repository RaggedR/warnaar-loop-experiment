"""
Seed 8, Layer 3, Task 4: Ehrhart h*-vector check for cylindric partition polytopes.

For a lattice polytope P, the Ehrhart series is sum_{m>=0} |mP cap Z^d| * t^m = h*(t) / (1-t)^{d+1}.
Stanley proved: if P is a lattice polytope, then h*(t) has nonneg coefficients.
Moreover, if P has the Integer Decomposition Property (IDP), then h* is nonneg.

We construct the cylindric partition polytope at "level m" (max entry = m)
and check its Ehrhart h*-vector.

Actually, the correct approach: h_m(q) for the cylindric partition problem
is related to the Ehrhart polynomial of a certain polytope.

g_m(q) = [y^m] F_c(y,q) counts cylindric partitions with max = m by total weight q.
h_m(q) = (q;q)_m * g_m(q).

The cylindric partition polytope at max = m is:
  P_m = {(x_1^(1), ..., x_{c_i}^(i)) : interlacing conditions, 0 <= x <= m}
  
This is a lattice polytope in Z^d (d = c_0 + c_1 + c_2).
Its lattice point count at "level" m is g_m = [coeff of y^m in F_c(y,q)] evaluated at q=1.

But we want the q-WEIGHTED count, which is the Ehrhart series with q-refinement.

Let me instead focus on a simpler approach:
Construct the polytope for small d and compute its h*-vector.
"""

print("="*80)
print("Task 4: Ehrhart h*-vector analysis of cylindric partition polytopes")
print("="*80)

# For profile c = (c_0, c_1, c_2), a cylindric partition with max <= m
# is a tuple of k=3 partitions (lambda^(0), lambda^(1), lambda^(2)) where:
# - lambda^(i) has at most c_i parts (each row has c_i entries)
# - lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}} (interlacing, cyclic)
# - 0 <= all entries <= m

# For binary (max <= 1), the polytope is just {0,1}^d with interlacing constraints.
# For general m, it's m * P_1 where P_1 is the binary polytope? NO, because
# the interlacing is on actual values, not fractions.
# Actually, P_m = {x in Z^d_>=0 : interlacing, x_i <= m} = m * P_1 cap Z^d
# where P_1 is the rational polytope {x in R^d_>=0 : interlacing, x_i <= 1}.

# Let's construct P_1 for small profiles and compute Ehrhart.

def build_interlacing_constraints(c):
    """Build the linear inequalities for cylindric partition polytope.
    Variables: x^(i)_j for i=0,...,k-1 and j=1,...,c_i (where c_i > 0).
    But actually, for cylindric partitions the variables are entries of the
    partitions arranged on a cylinder.
    
    Interlacing: lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}} for all valid j, i.
    Wait, the conjecture defines: lambda^(i)_j >= lambda^(i+1)_{j+c_{i+1}}.
    
    Actually, for a cylindric partition of profile c = (c_0, c_1, c_2),
    we have k=3 partitions. Each partition lambda^(i) has entries that can go
    on indefinitely, but with max <= m, only finitely many are nonzero.
    
    For the polytope at level 1 (max <= 1), the entries are binary.
    The number of variables is at most... well, it depends on the interlacing depth.
    
    Let me think about this differently. For max <= m, the cylindric partition
    can be described as a plane partition on a cylinder of circumference t = k + d.
    The variables are the entries at each position on the cylinder.
    """
    k = len(c)
    d = sum(c)
    t = k + d  # circumference
    
    # A cylindric partition of profile (c_0, c_1, ..., c_{k-1}) on t = k + d
    # positions arranged as: c_0 entries of partition 0, then 1 separator,
    # then c_1 entries of partition 1, then 1 separator, etc.
    # 
    # Actually, let's use the row-based encoding.
    # For max <= 1 (binary), the partitions have at most 1 row each.
    # lambda^(i) = (a^(i)_1, a^(i)_2, ...) with a^(i)_j in {0, 1}, weakly decreasing.
    # So lambda^(i) is determined by the number of 1's: lambda^(i) = (1^{n_i}, 0^{...})
    # where n_i <= c_i (each partition has at most c_i parts when max = 1).
    
    # Wait, that's not right. For max = m, partition i can have entries up to m.
    # Each row of partition i is a (weakly decreasing) sequence of length... 
    # Actually, for cylindric partitions, each partition lambda^(i) has 
    # lambda^(i)_j defined for j >= 1, and the interlacing with the next partition
    # involves a shift by c_{i+1}.
    
    # For the PURPOSE OF THE POLYTOPE, when max <= 1:
    # lambda^(i) = (a_1, a_2, ...) where each a_j in {0,1} and a_j >= a_{j+1}.
    # So lambda^(i) = (1, 1, ..., 1, 0, 0, ...) = (1^{L_i}) for some L_i >= 0.
    # The interlacing: L_i >= L_{i+1} + c_{i+1} - c_i ... no, that's not right.
    
    # Let me re-read the definition.
    # lambda^(i)_j >= lambda^(i+1)_{j + c_{i+1}} for 1 <= i <= k-1.
    # lambda^(k)_j >= lambda^(1)_{j + c_1}.
    # And max(Lambda) = max_i lambda^(i)_1 <= 1.
    
    # For max = 1: each lambda^(i) = (1^{L_i}) where L_i >= 0.
    # Interlacing: 1^{L_i}_j >= 1^{L_{i+1}}_{j+c_{i+1}}.
    # This means: if j <= L_i then 1 >= ..., if j > L_i then 0 >= 1^{L_{i+1}}_{j+c_{i+1}}.
    # The constraint 0 >= 1^{L_{i+1}}_{j+c_{i+1}} means j + c_{i+1} > L_{i+1},
    # i.e., j > L_{i+1} - c_{i+1}.
    # This must hold for j = L_i + 1, so L_i + 1 > L_{i+1} - c_{i+1},
    # i.e., L_i >= L_{i+1} - c_{i+1}.
    # Actually we also need: for j <= L_i, lambda^(i)_j = 1 >= lambda^(i+1)_{j+c_{i+1}}.
    # lambda^(i+1)_{j+c_{i+1}} = 1 if j + c_{i+1} <= L_{i+1}, i.e., j <= L_{i+1} - c_{i+1}.
    # So we need 1 >= 1 (trivially true) when j <= L_{i+1} - c_{i+1},
    # and 1 >= 0 (trivially true) when j > L_{i+1} - c_{i+1}.
    # 
    # For j > L_i: lambda^(i)_j = 0 >= lambda^(i+1)_{j+c_{i+1}}.
    # We need j + c_{i+1} > L_{i+1}, i.e., j > L_{i+1} - c_{i+1}.
    # Since j > L_i, we need L_i >= L_{i+1} - c_{i+1}, i.e., L_{i+1} <= L_i + c_{i+1}.
    
    # So the constraint is: L_{i+1} <= L_i + c_{i+1} (cyclic).
    # And L_i >= 0, L_i <= ... (how many 1's can partition i have?)
    
    # Total weight = sum L_i.
    
    return None  # Placeholder

# Instead of building the full polytope, let me directly enumerate
# binary cylindric partitions and check against Ehrhart theory.

# For profile c = (c_0, c_1, c_2), max = 1:
# Each partition lambda^(i) = (1^{L_i}) where L_i >= 0.
# Constraint: L_{i+1} <= L_i + c_{i+1} for i = 0, 1, 2 (cyclic, mod 3).
# Weight = L_0 + L_1 + L_2.

# This is a polytope in (L_0, L_1, L_2) space!
# The constraints are:
# L_1 <= L_0 + c_1  (from i=0)
# L_2 <= L_1 + c_2  (from i=1)
# L_0 <= L_2 + c_0  (from i=2, cyclic)
# L_i >= 0

# For max = m, each partition lambda^(i) has m rows (each row is a partition).
# The structure is much more complex.

# Let's start with the binary case (max = 1) and verify the lattice point count.

print("\n--- Binary cylindric partition polytope (max = 1) ---")

for c in [(2,1,1), (3,2,2), (4,2,1), (3,3,2), (4,3,3)]:
    d = sum(c)
    k = 3
    
    # Enumerate lattice points (L_0, L_1, L_2) with:
    # L_1 <= L_0 + c[1], L_2 <= L_1 + c[2], L_0 <= L_2 + c[0]
    # L_i >= 0
    
    # For weight w = L_0 + L_1 + L_2, count the lattice points.
    max_w = 3 * d + 10  # generous upper bound for max weight
    
    count_by_weight = {}
    for L0 in range(max_w + 1):
        for L1 in range(max_w + 1):
            if L1 > L0 + c[1]:
                continue
            for L2 in range(max_w + 1):
                if L2 > L1 + c[2]:
                    continue
                if L0 > L2 + c[0]:
                    continue
                w = L0 + L1 + L2
                if w > max_w:
                    continue
                count_by_weight[w] = count_by_weight.get(w, 0) + 1
    
    counts = [count_by_weight.get(w, 0) for w in range(max_w + 1)]
    
    # Find where it stabilizes
    stable_val = None
    stable_from = None
    for w in range(len(counts) - 1, -1, -1):
        if counts[w] != counts[-1]:
            stable_from = w + 1
            stable_val = counts[-1]
            break
    
    expected_stable = (d+1)*(d+2)//6
    
    print(f"\nc = {c}, d = {d}")
    print(f"  Counts by weight: {counts[:stable_from+3]}")
    print(f"  Stabilizes to {stable_val} from w={stable_from}")
    print(f"  Expected (d+1)(d+2)/6 = {expected_stable}, match: {stable_val == expected_stable}")
    
    # h_1 = (1-q) * g_1 where g_1[w] = count[w] for w >= 1, g_1[0] = count[0] - 1
    # (subtracting the empty partition at max = 0)
    # Actually g_1 = B_1 - B_0 = B_1 - 1, so g_1[0] = count[0] - 1 = 0 (since count[0] = 1 for empty).
    g1 = [0] + counts[1:stable_from+3]
    h1 = [g1[0]] + [g1[w] - g1[w-1] for w in range(1, len(g1))]
    h1_nonzero = [(w, h1[w]) for w in range(len(h1)) if h1[w] != 0]
    print(f"  g_1 coefficients: {g1[:stable_from+2]}")
    print(f"  h_1 = (1-q)*g_1: {h1_nonzero}")
    print(f"  h_1(1) = {sum(h for _, h in h1_nonzero)}")
    print(f"  All h_1 nonneg: {all(h >= 0 for _, h in h1_nonzero)}")

# Now let's construct the actual polytope in SageMath and compute Ehrhart series.
print("\n\n--- Ehrhart series computation ---")

for c in [(2,1,1), (1,1,2), (3,2,2)]:
    d = sum(c)
    k = 3
    
    print(f"\nc = {c}, d = {d}")
    
    # The binary CP polytope has variables (L_0, L_1, L_2) with constraints:
    # L_i >= 0
    # L_1 <= L_0 + c[1]
    # L_2 <= L_1 + c[2]
    # L_0 <= L_2 + c[0]
    #
    # This is an UNBOUNDED cone (no upper bound on L_i).
    # For the Ehrhart theory to apply, we need a BOUNDED polytope.
    #
    # The bounded version: at max = m, the constraint is max entry <= m.
    # For binary, max = 1 means lambda^(i)_1 <= 1, i.e., L_i can be 0 or more but...
    # wait, L_i is the NUMBER of 1's in partition i. There's no bound on L_i from max = 1.
    # The bound on max entry is already 1. L_i counts how many entries equal 1.
    # L_i can range from 0 to infinity (the partition can have arbitrarily many parts).
    
    # Hmm, but for bounded cylindric partitions (max <= n), the entries are bounded.
    # Each entry is at most n. Each partition lambda^(i) has entries lambda^(i)_j <= n.
    # The partition lambda^(i) can have at most... well, lambda^(i)_j >= 0 for all j,
    # and it's weakly decreasing. If lambda^(i)_1 <= n, then all entries are <= n.
    # The number of nonzero entries is unbounded (we can have (1, 1, 1, ..., 1, 0, 0, ...)).
    
    # So for the BOUNDED problem, the polytope is:
    # P_n = {multipartitions: interlacing, max entry <= n}
    # This is an INFINITE-dimensional object (infinitely many entries per partition).
    
    # But g_n(q) = [y^n] F_c(y,q) is an infinite series! So g_n is NOT a polynomial.
    # h_n = (q;q)_n * g_n IS a polynomial (by Welsh's theorem).
    
    # The Ehrhart approach needs a different formulation.
    # Instead of the "number of partitions" polytope, we should think of
    # each FIXED-WEIGHT cylindric partition as a lattice point in some polytope.
    
    # Alternative: the Gelfand-Tsetlin polytope approach.
    # For fixed weight w, the number of cylindric partitions of profile c
    # with max <= n and total weight w can be written as a lattice point count
    # in a GT-type polytope.
    
    # Let me try a different angle: construct the polytope for the ROWS.
    # A cylindric partition with max <= n has n "layers" (from entry value 1 to n).
    # Each layer defines a binary constraint system.
    
    # For n=1 (binary): the polytope is the CONE described above.
    # Its generating function sum_w count(w) * q^w = g_1(q).
    # The "Ehrhart series" of this cone is sum_m |m*P cap Z^3| * t^m
    # where P is the fundamental polytope of the cone.
    
    # Actually, the CONE itself generates g_1: the lattice points at height w
    # (L_0 + L_1 + L_2 = w) in the cone give count(w).
    
    # For the h_m approach: h_m = (q;q)_m * g_m = (q;q)_m * [y^m] F_c(y,q).
    # At q=1: h_m(1) = m! * g_m(1) ... no, (q;q)_m at q=1 = 0 for m >= 1.
    # Wait: (1;1)_m = (1-1)(1-1)...(1-1) = 0. So h_m(1) should be 0?
    # But h_m(1) = ((d+1)(d+2)/6)^m according to synthesis.
    
    # There's a subtlety. (q;q)_m = product_{i=1}^m (1-q^i), so (q;q)_m|_{q=1} = 0 for m >= 1.
    # But g_m(q) has a pole at q=1 of order m (since g_m ~ 1/(q;q)_m^{...}).
    # So h_m(1) = lim_{q->1} (q;q)_m * g_m(q) is a finite nonzero limit.
    
    # The Ehrhart theory doesn't directly apply to this limit.
    # Let me think about what polytope encodes h_m.
    
    # The correct Ehrhart polytope is the ORDER POLYTOPE of the cylindric poset.
    # For a cylindric partition of profile c with max <= m, the entries form
    # an order-reversing map from the poset to {0, 1, ..., m}.
    # By Stanley's theory, this is related to the order polytope of the poset.
    
    # The order polytope O(P) of a poset P has lattice point count
    # |m * O(P) cap Z^n| = Omega_P(m+1) = order polynomial of P.
    # And the Ehrhart series has h*-vector with nonneg coefficients.
    
    # Let's construct the poset and its order polytope.
    
    # The cylindric poset: vertices are the "entry positions" of the cylindric partition.
    # For profile c = (c_0, c_1, c_2) with k=3:
    # - Partition 0 has positions (0, j) for j = 1, 2, 3, ...
    # - Partition 1 has positions (1, j) for j = 1, 2, 3, ...
    # - Partition 2 has positions (2, j) for j = 1, 2, 3, ...
    # Ordering within each partition: (i, j) >= (i, j+1)
    # Interlacing between partitions: (i, j) >= (i+1, j + c_{i+1})
    
    # This poset is INFINITE (infinitely many positions).
    # But for max <= m with finitely many nonzero entries, we can truncate.
    # The key insight: if max <= 1, the nonzero entries are at positions where
    # the value is 1, and these positions must form an "order ideal" of the poset.
    # The weight = number of nonzero entries.
    
    # For the ORDER POLYTOPE, we set each position's value to a real in [0, 1]
    # with the ordering constraints. The m-th dilation gives max <= m.
    
    # But the infinite poset makes this tricky. Let me TRUNCATE.
    # For max <= 1 and weight <= W, how many positions per partition can be nonzero?
    # Each partition has at most W parts (since each part is at most 1).
    # So truncate at depth W for each partition.
    
    # Let's build the finite truncated order polytope for small W.
    
    W = d + 5  # truncation depth
    
    # Variables: x_{i,j} for i=0,1,2 and j=1,...,W
    # Constraints:
    # 0 <= x_{i,j} <= 1
    # x_{i,j} >= x_{i,j+1}  (weakly decreasing within each partition)
    # x_{i,j} >= x_{(i+1)%3, j + c[(i+1)%3]}  (interlacing)
    
    # Build the polytope
    n_vars = 3 * W
    
    # Variable indexing: x_{i,j} -> variable index i*W + (j-1)
    def var_idx(i, j):
        return i * W + (j - 1)
    
    ieqs = []  # [b, a_0, a_1, ...] means b + a_0*x_0 + a_1*x_1 + ... >= 0
    eqns = []
    
    for i in range(3):
        for j in range(1, W + 1):
            # x_{i,j} >= 0
            v = [0] * (n_vars + 1)
            v[0] = 0
            v[1 + var_idx(i, j)] = 1
            ieqs.append(v)
            
            # x_{i,j} <= 1
            v = [0] * (n_vars + 1)
            v[0] = 1
            v[1 + var_idx(i, j)] = -1
            ieqs.append(v)
            
            # x_{i,j} >= x_{i,j+1} (if j < W)
            if j < W:
                v = [0] * (n_vars + 1)
                v[1 + var_idx(i, j)] = 1
                v[1 + var_idx(i, j+1)] = -1
                ieqs.append(v)
            
            # Interlacing: x_{i,j} >= x_{(i+1)%3, j + c[(i+1)%3]}
            i_next = (i + 1) % 3
            j_next = j + c[i_next]
            if 1 <= j_next <= W:
                v = [0] * (n_vars + 1)
                v[1 + var_idx(i, j)] = 1
                v[1 + var_idx(i_next, j_next)] = -1
                ieqs.append(v)
    
    print(f"  Building polytope with {n_vars} variables, {len(ieqs)} inequalities...")
    
    try:
        P = Polyhedron(ieqs=ieqs, backend='cdd')
        n_vertices = len(P.vertices())
        n_lattice = len(P.integral_points())
        dim = P.dimension()
        
        print(f"  Dimension: {dim}")
        print(f"  Vertices: {n_vertices}")
        print(f"  Lattice points: {n_lattice}")
        
        # Compute Ehrhart series
        if dim <= 15 and n_vertices <= 100:
            print(f"  Computing Ehrhart polynomial...")
            try:
                E = P.ehrhart_polynomial()
                print(f"  Ehrhart polynomial: {E}")
                print(f"  E(0) = {E(0)}, E(1) = {E(1)}, E(2) = {E(2)}")
                
                # The h*-vector
                R = PolynomialRing(QQ, 't')
                t = R.gen()
                
                # Ehrhart series = h*(t) / (1-t)^{dim+1}
                # h*(t) = (1-t)^{dim+1} * sum_{m>=0} E(m) * t^m
                # Compute h* by evaluating enough terms
                d_poly = dim
                h_star_coeffs = []
                for j in range(d_poly + 1):
                    # h*_j = sum_{i=0}^j (-1)^{j-i} binomial(d_poly+1, j-i) * E(i)
                    val = sum((-1)**(j-i) * binomial(d_poly+1, j-i) * E(i) for i in range(j+1))
                    h_star_coeffs.append(val)
                
                print(f"  h*-vector: {h_star_coeffs}")
                print(f"  All h* nonneg: {all(h >= 0 for h in h_star_coeffs)}")
                
            except Exception as e:
                print(f"  Ehrhart computation failed: {e}")
        else:
            print(f"  Polytope too large for Ehrhart computation (dim={dim}, vertices={n_vertices})")
            
    except Exception as e:
        print(f"  Polytope construction failed: {e}")

# Simpler approach: construct the 3-variable CONE directly
print("\n\n--- 3-variable cone Ehrhart analysis ---")
print("Binary CP as cone in (L_0, L_1, L_2) space")

for c in [(2,1,1), (1,1,2), (3,2,2), (4,2,1)]:
    d = sum(c)
    
    print(f"\nc = {c}, d = {d}")
    
    # Cone: L_i >= 0, L_1 <= L_0 + c[1], L_2 <= L_1 + c[2], L_0 <= L_2 + c[0]
    # This is unbounded. Cross-section at L_0 + L_1 + L_2 = w gives the lattice points of weight w.
    
    # The FUNDAMENTAL PARALLELEPIPED of this cone determines the h*-vector of the 
    # associated Ehrhart series.
    
    # Let's use SageMath's polyhedral tools to study this cone.
    
    # Define the cone as Polyhedron with rays
    # Constraints: L_1 - L_0 <= c[1], L_2 - L_1 <= c[2], L_0 - L_2 <= c[0], L_i >= 0
    # Rewritten as ieqs:
    ieqs = [
        [0, 1, 0, 0],      # L_0 >= 0
        [0, 0, 1, 0],      # L_1 >= 0
        [0, 0, 0, 1],      # L_2 >= 0
        [c[1], 1, -1, 0],  # L_0 - L_1 + c[1] >= 0, i.e., L_1 <= L_0 + c[1]
        [c[2], 0, 1, -1],  # L_1 - L_2 + c[2] >= 0, i.e., L_2 <= L_1 + c[2]
        [c[0], -1, 0, 1],  # -L_0 + L_2 + c[0] >= 0, i.e., L_0 <= L_2 + c[0]
    ]
    
    cone = Polyhedron(ieqs=ieqs, backend='cdd')
    print(f"  Cone: dim={cone.dimension()}, rays={len(cone.rays())}, bounded={cone.is_compact()}")
    
    # Cross-section at L_0+L_1+L_2 = 1 gives a bounded polytope
    # Use eqns to add the constraint L_0+L_1+L_2 = 1
    cross_ieqs = list(ieqs)
    cross_eqns = [[- 1, 1, 1, 1]]  # L_0 + L_1 + L_2 = 1 ... but this gives a rational polytope
    
    # Actually for lattice point counting we want integer cross-sections.
    # Let's compute the cross-section at sum = w for various w.
    
    # The generating function of lattice points by weight is:
    # g_1(q) = sum_w |{(L_0,L_1,L_2) in cone, sum = w}| q^w
    
    # For the RATIONAL cross-section P_1 at sum = 1 (a 2-dim simplex in 3-space):
    P1 = Polyhedron(ieqs=cross_ieqs, eqns=cross_eqns, backend='cdd')
    print(f"  Cross-section at sum=1: dim={P1.dimension()}, vertices={len(P1.vertices())}")
    if P1.dimension() <= 3:
        for v in P1.vertices():
            print(f"    vertex: {v}")
    
    # Ehrhart polynomial of P1 (the rational cross-section)
    # |w*P1 cap Z^3 with sum = w| = number of lattice points at weight w
    if P1.dimension() >= 1:
        try:
            # For rational polytopes, use ehrhart_quasipolynomial
            # or compute manually
            
            # Manual: count lattice points at each weight
            counts = []
            for w in range(20):
                n_pts = 0
                for L0 in range(w + 1):
                    for L1 in range(w - L0 + 1):
                        L2 = w - L0 - L1
                        if L2 < 0:
                            continue
                        if L1 <= L0 + c[1] and L2 <= L1 + c[2] and L0 <= L2 + c[0]:
                            n_pts += 1
                counts.append(n_pts)
            
            print(f"  Lattice point counts by weight: {counts}")
            
            # The differences give h_1 coefficients
            diffs = [counts[0]] + [counts[w] - counts[w-1] for w in range(1, len(counts))]
            nonzero_diffs = [(w, diffs[w]) for w in range(len(diffs)) if diffs[w] != 0]
            print(f"  Differences (= g_1 diffs): {nonzero_diffs}")
            
            # h_1 = (1-q) * g_1 where g_1[w] = counts[w] for w >= 1, g_1[0] = counts[0] - 1
            g1 = [counts[0] - 1] + counts[1:]
            h1_coeffs = [g1[0]] + [g1[w] - g1[w-1] for w in range(1, len(g1))]
            h1_nonzero = [(w, h1_coeffs[w]) for w in range(len(h1_coeffs)) if h1_coeffs[w] != 0]
            print(f"  h_1 coefficients: {h1_nonzero}")
            print(f"  h_1 all nonneg: {all(v >= 0 for _, v in h1_nonzero)}")
            print(f"  h_1(1) = {sum(v for _, v in h1_nonzero)}")
            
            # Ehrhart polynomial of the rational cross-section
            # For a RATIONAL polytope, the Ehrhart function is a quasi-polynomial.
            # Try to fit a polynomial to the counts.
            
            if len(counts) >= 5:
                # Check if counts form a polynomial in w
                # For a 2-dim polytope, should be quadratic eventually
                second_diffs = [counts[w+2] - 2*counts[w+1] + counts[w] for w in range(len(counts)-2)]
                print(f"  Second differences of counts: {second_diffs[:15]}")
                
                # If second diffs stabilize, it's polynomial
                if all(sd == second_diffs[-1] for sd in second_diffs[-3:]):
                    print(f"  Second differences stabilize to {second_diffs[-1]} -> polynomial of degree 2")
                    
                    # Fit: counts[w] = a*w^2 + b*w + c_coeff
                    # Using w=0,1,2: solve
                    c_coeff = counts[0]
                    # a + b + c_coeff = counts[1]
                    # 4a + 2b + c_coeff = counts[2]
                    # So a + b = counts[1] - c_coeff, 4a + 2b = counts[2] - c_coeff
                    # 2a = counts[2] - c_coeff - 2*(counts[1] - c_coeff) = counts[2] - 2*counts[1] + c_coeff
                    a = (counts[2] - 2*counts[1] + c_coeff) / 2
                    b = counts[1] - c_coeff - a
                    
                    print(f"  Ehrhart quasi-polynomial: {a}*w^2 + {b}*w + {c_coeff}")
                    print(f"  Verification: E(3) = {a*9 + b*3 + c_coeff}, actual = {counts[3]}")
                    print(f"  Verification: E(5) = {a*25 + b*5 + c_coeff}, actual = {counts[5]}")
                    
                    # Stable value = lim of counts[w] / w^2 * 2! ... 
                    # Actually for w large: counts[w] ~ a*w^2
                    # And a should be related to the volume of the cross-section
                    
                    print(f"  Leading coefficient a = {a}")
                    print(f"  Volume of cross-section * 2! = {2*a}")
                    
        except Exception as e:
            print(f"  Error: {e}")

print("\n\nDone with Task 4.")
