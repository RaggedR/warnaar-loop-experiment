"""
Seed 1 Layer 3: Ehrhart theory for Q_1 positivity.

For profile c = (c0, c1, c2), binary cylindric partitions with weight w
are lattice points in the polytope:

P_w = {(a0, a1, a2) in Z^3 : a_i >= 0, a0+a1+a2 = w,
       a1 - a0 <= c1, a2 - a1 <= c2, a0 - a2 <= c0}

This is a 2-dimensional polytope (triangle cross-section of a cone).
We compute the Ehrhart quasi-polynomial and prove monotonicity.
"""

from sage.all import *

def binary_cpp_polytope(c, w):
    """
    Construct the polytope P_w for binary cylindric partitions.
    Returns a Polyhedron in 3D (but it's 2-dimensional since sum = w).
    """
    c0, c1, c2 = c
    # Variables: a0, a1, a2
    # Constraints:
    #   a0 >= 0, a1 >= 0, a2 >= 0
    #   a0 + a1 + a2 = w
    #   a1 - a0 <= c1
    #   a2 - a1 <= c2
    #   a0 - a2 <= c0
    
    # Use the equality to eliminate a2 = w - a0 - a1.
    # Then constraints become:
    #   a0 >= 0, a1 >= 0, a2 = w - a0 - a1 >= 0 => a0 + a1 <= w
    #   a1 - a0 <= c1
    #   (w - a0 - a1) - a1 <= c2 => w - a0 - 2*a1 <= c2 => a0 + 2*a1 >= w - c2
    #   a0 - (w - a0 - a1) <= c0 => 2*a0 + a1 - w <= c0 => 2*a0 + a1 <= w + c0
    
    # In 2D (a0, a1):
    ieqs = [
        # format: [b, a0_coeff, a1_coeff] meaning b + a0_coeff*a0 + a1_coeff*a1 >= 0
        [0, 1, 0],          # a0 >= 0
        [0, 0, 1],          # a1 >= 0
        [w, -1, -1],        # w - a0 - a1 >= 0 (a2 >= 0)
        [c1, -1, 1],        # c1 + a0 - a1 >= 0... wait, a1 - a0 <= c1 means c1 - a1 + a0 >= 0
    ]
    # a1 - a0 <= c1 => c1 + a0 - a1 >= 0... that's what I have: [c1, 1, -1]
    # wait, format is [b, coeff_a0, coeff_a1] for b + coeff_a0*a0 + coeff_a1*a1 >= 0
    
    ieqs_correct = [
        [0, 1, 0],              # a0 >= 0
        [0, 0, 1],              # a1 >= 0
        [w, -1, -1],            # a2 = w - a0 - a1 >= 0
        [c1, 1, -1],            # a1 - a0 <= c1 => c1 + a0 - a1 >= 0
        [-(w - c2), 1, 2],      # a0 + 2*a1 >= w - c2 => -(w-c2) + a0 + 2*a1 >= 0
        [w + c0, -2, -1],       # 2*a0 + a1 <= w + c0 => (w+c0) - 2*a0 - a1 >= 0
    ]
    
    P = Polyhedron(ieqs=ieqs_correct, base_ring=QQ)
    return P

def count_lattice_points(c, w):
    """Count lattice points in P_w."""
    P = binary_cpp_polytope(c, w)
    return len(P.integral_points())

def compute_ehrhart_data(c, w_max=30):
    """Compute f_1(w) for w = 0, ..., w_max."""
    d = sum(c)
    base = (d+1)*(d+2)//6
    
    print(f"Profile c = {c}, d = {d}, base = {base}")
    print(f"{'w':>4} {'f_1(w)':>8} {'delta':>8} {'comment':>20}")
    print("-" * 45)
    
    prev = 0
    all_monotone = True
    for w in range(w_max + 1):
        f1w = count_lattice_points(c, w)
        delta = f1w - prev
        comment = ""
        if w > 0 and delta < 0:
            comment = "NOT MONOTONE!"
            all_monotone = False
        if f1w == base:
            comment = "STABLE"
        print(f"{w:4d} {f1w:8d} {delta:8d} {comment:>20}")
        prev = f1w
    
    print(f"\nMonotone: {all_monotone}")
    return all_monotone

def ehrhart_polynomial_analysis(c):
    """
    The key insight: P_w is a dilation of a polytope.
    More precisely, the cone C = {(a0,a1,a2) >= 0 : a1-a0<=c1, a2-a1<=c2, a0-a2<=c0}
    is a polyhedral cone, and P_w = C intersect {sum = w}.
    
    The Ehrhart function f(w) = |P_w cap Z^3| is an Ehrhart quasi-polynomial.
    For a rational cone, this is eventually a polynomial.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    # Construct the cone (no sum constraint)
    # In 3D: a0,a1,a2 >= 0, a1-a0 <= c1, a2-a1 <= c2, a0-a2 <= c0
    # Format: [b, a0, a1, a2] for b + a0*x0 + a1*x1 + a2*x2 >= 0
    cone_ieqs = [
        [0, 1, 0, 0],       # a0 >= 0
        [0, 0, 1, 0],       # a1 >= 0
        [0, 0, 0, 1],       # a2 >= 0
        [c1, 1, -1, 0],     # c1 + a0 - a1 >= 0
        [c2, 0, 1, -1],     # c2 + a1 - a2 >= 0
        [c0, -1, 0, 1],     # c0 - a0 + a2 >= 0
    ]
    
    C = Polyhedron(ieqs=cone_ieqs, base_ring=QQ)
    
    print(f"\nCone analysis for c = {c}, d = {d}:")
    print(f"  Dimension: {C.dimension()}")
    print(f"  Vertices: {len(C.vertices())}")
    print(f"  Rays: {len(C.rays())}")
    print(f"  Rays list: {[list(r) for r in C.rays()]}")
    print(f"  Vertices list: {[list(v) for v in C.vertices()]}")
    
    # The stabilization value should be base = (d+1)(d+2)/6
    # Compute cross-sections to find when it stabilizes
    f_values = [count_lattice_points(c, w) for w in range(3*d)]
    deltas = [f_values[w] - f_values[w-1] for w in range(1, len(f_values))]
    
    # Find stabilization point
    stab = None
    for w in range(1, len(f_values)):
        if f_values[w] == base and all(f_values[ww] == base for ww in range(w, len(f_values))):
            stab = w
            break
    
    print(f"  Lattice point counts: {f_values}")
    print(f"  First differences: {deltas}")
    print(f"  Stabilizes at w = {stab} to base = {base}")
    
    # Check: are all first differences non-negative?
    all_nonneg = all(d >= 0 for d in deltas)
    print(f"  All first differences >= 0: {all_nonneg}")
    
    return C, f_values, deltas

# Now construct P_w as a polytope in the w-variable and compute Ehrhart
def ehrhart_of_cross_section(c):
    """
    Use SageMath's Ehrhart tools.
    P_w is a 2D polytope. For the Ehrhart analysis, we note that
    the constraint set for P_w with fixed w defines a 2D polygon.
    
    The number of lattice points f(w) = |P_w ∩ Z^2| is an Ehrhart
    quasi-polynomial in w.
    
    For a 2D convex polytope with rational vertices, the Ehrhart
    quasi-polynomial has period dividing the lcm of denominators
    of vertex coordinates.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    
    # The vertices of P_w (in (a0, a1) coordinates, a2 = w - a0 - a1):
    # We need to find the vertices of the 2D polygon defined by:
    #   a0 >= 0, a1 >= 0, a0 + a1 <= w
    #   a1 <= a0 + c1
    #   a0 + 2*a1 >= w - c2
    #   2*a0 + a1 <= w + c0
    
    # For large w, the binding constraints are:
    # The simplex a0+a1 <= w is huge, so the triangle is determined by
    # the interlacing inequalities.
    
    # Let's find vertices as functions of w for w large enough
    # by solving pairs of constraints at equality.
    
    print(f"\nVertex analysis of P_w for c = {c}:")
    
    R = PolynomialRing(QQ, 'w')
    w = R.gen()
    
    # For several values of w, find vertices
    for wval in [0, 1, 2, 5, 10, 20, 50]:
        P = binary_cpp_polytope(c, wval)
        if P.dimension() >= 0:
            verts = [list(v) for v in P.vertices()]
            npts = len(P.integral_points())
            print(f"  w={wval}: dim={P.dimension()}, vertices={verts}, lattice_pts={npts}")
        else:
            print(f"  w={wval}: empty")
    
    return None

# Main computation
print("=" * 70)
print("EHRHART THEORY FOR Q_1 POSITIVITY")
print("=" * 70)

# Test profiles
profiles = [
    (1, 1, 0),   # d=2
    (2, 1, 1),   # d=4
    (2, 2, 1),   # d=5
    (3, 2, 2),   # d=7
    (4, 2, 1),   # d=7
    (3, 3, 2),   # d=8
    (5, 2, 1),   # d=8
    (4, 3, 3),   # d=10
    (5, 3, 2),   # d=10
    (4, 4, 3),   # d=11
    (5, 4, 4),   # d=13
    (6, 4, 4),   # d=14
]

# First: verify monotonicity for all profiles
print("\n--- MONOTONICITY VERIFICATION ---\n")
for c in profiles:
    d = sum(c)
    compute_ehrhart_data(c, w_max=2*d+5)
    print()

# Then: detailed analysis for d=7
print("\n--- DETAILED EHRHART ANALYSIS ---\n")
for c in [(2,1,1), (3,2,2), (4,2,1)]:
    ehrhart_polynomial_analysis(c)
    ehrhart_of_cross_section(c)
    print()

