"""
Seed 6, Layer 3: Ehrhart theory proof of Q1 >= 0

The key claim: a_k (lattice points in the cross-section of a polyhedral cone 
at height k) is monotonically increasing for all profiles c with d not equiv 0 mod 3.

The polytope P_w for a composition c = (c0, c1, c2) with d = c0+c1+c2 is:
  P_w = {(L1, L2, L3) in R^3_>=0 : L1+L2+L3 = w, 
         L2 <= L1+c1, L3 <= L2+c2, L1 <= L3+c0}

This is a 2-dimensional polytope (a polygon in R^3 on the plane sum=w).
"""

from sage.all import *

def build_cone(c0, c1, c2):
    """Build the cone whose lattice points at height w give a_w.
    
    Variables: (L1, L2, L3, w) where L1+L2+L3 = w.
    Eliminate w: set w = L1+L2+L3.
    
    Constraints:
      L1 >= 0, L2 >= 0, L3 >= 0
      L2 - L1 <= c1   =>  -L1 + L2 <= c1
      L3 - L2 <= c2   =>  -L2 + L3 <= c2  
      L1 - L3 <= c0   =>  L1 - L3 <= c0
    """
    # Work in 3D: (L1, L2, L3)
    # The height function is w = L1 + L2 + L3
    
    # Define the cone as intersection of half-spaces
    # Polyhedron format: Ax <= b where rows are [b, -a1, -a2, -a3]
    # i.e., b - a1*x1 - a2*x2 - a3*x3 >= 0
    ieqs = [
        [0, 1, 0, 0],     # L1 >= 0
        [0, 0, 1, 0],     # L2 >= 0
        [0, 0, 0, 1],     # L3 >= 0
        [c1, 1, -1, 0],   # L1 - L2 + c1 >= 0, i.e., L2 - L1 <= c1
        [c2, 0, 1, -1],   # L2 - L3 + c2 >= 0, i.e., L3 - L2 <= c2
        [c0, -1, 0, 1],   # -L1 + L3 + c0 >= 0, i.e., L1 - L3 <= c0
    ]
    P = Polyhedron(ieqs=ieqs, base_ring=QQ)
    return P

def count_lattice_points_at_height(c0, c1, c2, w):
    """Count lattice points (L1, L2, L3) with sum = w satisfying constraints."""
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L3 < 0:
                continue
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    return count

def compute_ehrhart_quasi_polynomial(c0, c1, c2):
    """Compute the Ehrhart quasi-polynomial for the polytope P_1.
    
    P_1 is the cross-section at w=1. We dilate it: P_w = w * P_1.
    The lattice point count |P_w cap Z^3| is an Ehrhart quasi-polynomial in w.
    
    Actually, the polytope at height w is NOT a dilation of P_1 due to the 
    constant terms c0, c1, c2 in the inequalities. Instead:
      P_w = {(L1,L2,L3) : L_i >= 0, sum = w, L2-L1 <= c1, L3-L2 <= c2, L1-L3 <= c0}
    
    This is a slice of a 3D polyhedral cone at height w.
    The Ehrhart theory for cones says the count is a quasi-polynomial in w.
    """
    # Build the CONE in 4D: (L1, L2, L3, t) where t >= 0 is the "height" parameter
    # and the constraints are L_i >= 0, L2-L1 <= c1*t, etc., L1+L2+L3 = w*t... 
    # Actually, we should think of this differently.
    
    # The cone C in R^3 is defined by:
    #   L1 >= 0, L2 >= 0, L3 >= 0
    #   L2 - L1 <= c1 (constant, NOT scaled)
    #   L3 - L2 <= c2
    #   L1 - L3 <= c0
    # And we count points on the hyperplane L1+L2+L3 = w.
    
    # This is NOT a cone dilation problem -- the bounds c0,c1,c2 are fixed.
    # Let me think again...
    
    # Actually, let's just compute a_w for many values and find the quasi-polynomial.
    d = c0 + c1 + c2
    max_w = 3*d + 20  # enough to see the pattern
    
    counts = []
    for w in range(0, max_w + 1):
        counts.append(count_lattice_points_at_height(c0, c1, c2, w))
    
    return counts

def analyze_monotonicity(c0, c1, c2, verbose=True):
    """Check if a_w is monotonically increasing and find the quasi-polynomial."""
    d = c0 + c1 + c2
    stable_value = (d+1)*(d+2)//6
    
    counts = compute_ehrhart_quasi_polynomial(c0, c1, c2)
    
    # Check monotonicity
    mono_failures = []
    for w in range(2, len(counts)):
        if counts[w] < counts[w-1]:
            mono_failures.append((w, counts[w-1], counts[w]))
    
    # Find where it stabilizes
    stable_from = None
    for w in range(len(counts)):
        if counts[w] == stable_value:
            stable_from = w
            break
    
    if verbose:
        print(f"c = ({c0},{c1},{c2}), d = {d}")
        print(f"  Stable value: {stable_value}")
        print(f"  Stabilizes from w = {stable_from}")
        print(f"  First 20 counts: {counts[:20]}")
        print(f"  Differences: {[counts[i]-counts[i-1] for i in range(1, min(20, len(counts)))]}")
        if mono_failures:
            print(f"  MONOTONICITY FAILURES: {mono_failures}")
        else:
            print(f"  Monotonically increasing: YES")
    
    return counts, mono_failures, stable_from

# ==========================================
# PART 1: Detailed analysis for small d
# ==========================================

print("=" * 60)
print("PART 1: Ehrhart analysis for small d")
print("=" * 60)

for d in [2, 4, 5, 7, 8]:
    print(f"\n--- d = {d} ---")
    # Pick a few representative profiles
    profiles = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 >= c1 >= c2:  # canonical representative
                profiles.append((c0, c1, c2))
    
    for (c0, c1, c2) in profiles:
        analyze_monotonicity(c0, c1, c2, verbose=True)

# ==========================================
# PART 2: Use SageMath's Polyhedron to compute Ehrhart
# ==========================================

print("\n" + "=" * 60)
print("PART 2: Ehrhart quasi-polynomial via SageMath Polyhedron")
print("=" * 60)

def ehrhart_via_polyhedron(c0, c1, c2):
    """
    Use SageMath's Polyhedron and Ehrhart tools.
    
    The polytope at height w is:
      P_w = {(L1, L2) : L1 >= 0, L2 >= 0, w-L1-L2 >= 0,
             L2-L1 <= c1, w-L1-2*L2 <= c2, 2*L1+L2-w <= c0}
    
    We eliminate L3 = w - L1 - L2.
    This is a RATIONAL polytope in 2D whose vertices depend linearly on w.
    """
    d = c0 + c1 + c2
    
    # Work in the 2D space (L1, L2) with L3 = w - L1 - L2.
    # For a specific w, the polytope is:
    #   L1 >= 0
    #   L2 >= 0  
    #   L1 + L2 <= w   (L3 >= 0)
    #   L2 - L1 <= c1
    #   w - L1 - 2*L2 <= c2   =>  L1 + 2*L2 >= w - c2
    #   2*L1 + L2 - w <= c0   =>  2*L1 + L2 <= w + c0
    
    # Build this for a specific w to get the shape, then use Ehrhart.
    # Actually, let's build the 3D cone version.
    
    # Think of it as a parametric family P_w. For large w, the polytope
    # is the same shape scaled. For small w, boundary effects matter.
    
    # The "cone" approach: introduce w as a variable.
    # (L1, L2, w) in R^3 with:
    #   L1 >= 0, L2 >= 0, w - L1 - L2 >= 0
    #   L2 - L1 <= c1, w - L1 - 2*L2 <= c2, 2*L1 + L2 - w <= c0
    # This is a polyhedral cone IF c0=c1=c2=0; otherwise it's a polyhedron.
    
    # For Ehrhart: fix w and count lattice points.
    # Let's use the parametric polytope P_w for w = 1, 2, ..., 3*d+5
    # and fit the quasi-polynomial.
    
    # Actually, let's think about when a_w stabilizes.
    # a_w = stable_value for all w >= w_0.
    # We need to find w_0.
    
    stable_value = (d+1)*(d+2)//6
    
    # The polytope P_w in 2D (L1, L2 plane):
    # Vertices are intersections of:
    #   L1 = 0, L2 = 0, L1+L2 = w
    #   L2-L1 = c1, L1+2*L2 = w-c2, 2*L1+L2 = w+c0
    
    # For w large enough, the non-negativity constraints don't bind,
    # and the shape is determined by the three difference constraints.
    # The three difference constraints form a triangle (or degenerate).
    
    # Check: the three constraints are:
    #   L2 - L1 <= c1        (line with slope 1, intercept c1)
    #   -L1 - 2*L2 <= c2-w   (line with slope -1/2, intercept (w-c2)/2)
    #   2*L1 + L2 <= w+c0    (line with slope -2, intercept w+c0)
    
    # Intersection of constraint pairs:
    # (1)&(2): L2-L1=c1, L1+2L2=w-c2 => 3L2=w-c2+c1 => L2=(w-c2+c1)/3, L1=(w-c2-2c1)/3
    # (2)&(3): L1+2L2=w-c2, 2L1+L2=w+c0 => 3L1=w+2c0+c2 => L1=(w+2c0+c2)/3, L2=(w-2c2-c0)/3
    # (1)&(3): L2-L1=c1, 2L1+L2=w+c0 => 3L1=w+c0-c1 => L1=(w+c0-c1)/3, L2=(w+c0+2c1)/3
    
    # For these to give a triangle with all vertices having both coordinates >= 0
    # and L1+L2 <= w, we need w large enough.
    
    # The three vertices of the "inner triangle" are:
    v1 = lambda w: ((w-c2-2*c1)/3, (w-c2+c1)/3)  # (1)&(2)
    v2 = lambda w: ((w+2*c0+c2)/3, (w-2*c2-c0)/3)  # (2)&(3)  
    v3 = lambda w: ((w+c0-c1)/3, (w+c0+2*c1)/3)   # (1)&(3)
    
    # All coordinates non-negative when:
    # v1: w >= c2+2c1 = d-c0+c1 AND w >= c2-c1 = d-c0-2c1
    # v2: always >= 0 (first), w >= 2c2+c0 = d+c2-c1 (second)
    # v3: w >= c1-c0 (first), always >= 0 (second)
    # L1+L2 <= w: 
    #   v1: (2w-2c2-c1)/3 <= w => w >= 2c2+c1 = d+c2-c0
    #   v2: (2w+2c0-c2)/3 <= w => 2c0-c2 <= w/3 (usually fine)
    #   v3: (2w+c0+c1)/3 <= w => c0+c1 <= w/3 (usually fine)
    
    # The stabilization threshold w_0 is approximately d + max(c_i).
    # Let me compute it exactly for each profile.
    
    # For w >= w_0, the polytope is the triangle with vertices v1, v2, v3.
    # Its area is constant (independent of w): 
    # A = (1/2)|det[[v2-v1, v3-v1]]|
    
    # v2 - v1 = ((2c0+c2+2c1+c2)/3, (-2c2-c0-c2+c1)/3) = ((2c0+2c1+2c2)/3, (-3c2-c0+c1)/3) = (2d/3, (c1-c0-3c2)/3)
    # v3 - v1 = ((c0-c1+c2+2c1)/3, (c0+2c1+c2-c1)/3) = ((c0+c1+c2)/3, (c0+c1+c2)/3) = (d/3, d/3)
    
    vdiff21 = (2*d/3, (c1-c0-3*c2)/3)
    vdiff31 = (d/3, d/3)
    
    det_val = vdiff21[0]*vdiff31[1] - vdiff21[1]*vdiff31[0]
    area = abs(det_val) / 2
    
    print(f"c = ({c0},{c1},{c2}), d = {d}")
    print(f"  Triangle area = {area}")
    print(f"  Expected stable lattice count = area + boundary/2 + 1 = ... (Pick's theorem)")
    print(f"  Actual stable value = {stable_value}")
    
    # By Pick's theorem: lattice_points = area + boundary/2 + 1
    # Let's verify: area = |det|/2 = |2d*d/3 - d*(c1-c0-3c2)/3|/2*1/9
    # Wait, let me recompute. The determinant of the 2x2 matrix is:
    # (2d/3)(d/3) - ((c1-c0-3c2)/3)(d/3) = (d/9)(2d - c1 + c0 + 3c2)
    # = (d/9)(2d - c1 + c0 + 3(d-c0-c1)) = (d/9)(2d - c1 + c0 + 3d - 3c0 - 3c1)
    # = (d/9)(5d - 2c0 - 4c1) 
    # Hmm, that doesn't simplify to d^2/6 cleanly. Let me just verify numerically.
    
    # For c = (2,1,1), d=4: expected stable = 5
    # area = 4/9 * |5*4 - 2*2 - 4*1| / 2 = 4/9 * 12 / 2 = 24/9 = 8/3
    # Pick: 8/3 + boundary/2 + 1 = 5 => boundary = 2*(5-1-8/3) = 2*(4-8/3) = 2*4/3 = 8/3
    # This should be an integer... 8/3 is not an integer.
    
    # The issue is that the triangle has vertices at points with denominator 3,
    # so it's a RATIONAL polytope, and the count is a quasi-polynomial, not a polynomial.
    # The period divides 3.
    
    # Let's just compute and verify.
    return None

for (c0, c1, c2) in [(2,1,1), (3,1,0), (3,2,2), (4,2,1), (5,1,1)]:
    ehrhart_via_polyhedron(c0, c1, c2)

# ==========================================
# PART 3: SageMath Ehrhart computation
# ==========================================

print("\n" + "=" * 60)
print("PART 3: Formal Ehrhart quasi-polynomial via SageMath")
print("=" * 60)

def formal_ehrhart(c0, c1, c2):
    """
    Compute Ehrhart quasi-polynomial using SageMath's built-in tools.
    
    We construct the polytope P_1 (at height w=1) and use dilation.
    But our polytope is NOT a dilation of a fixed polytope -- the constraints
    have constant terms c0, c1, c2.
    
    Instead, we use a different approach: construct the 3D CONE and 
    compute cross-sections.
    
    The cone C in R^4 is: (L1, L2, L3, w) with
      L1 >= 0, L2 >= 0, L3 >= 0, w >= 0
      L1 + L2 + L3 = w  (implicit)
      L2 - L1 <= c1
      L3 - L2 <= c2
      L1 - L3 <= c0
      
    a_w = #{Z^3 cap P_w} where P_w = {(L1,L2,L3) in C : L1+L2+L3 = w}
    
    For a fixed shape polytope: use Ehrhart directly.
    For our family: it's the "slice counting function" of a polyhedron.
    
    Key insight: For w >= d, the polytope P_w is ALWAYS the same triangle
    (just translated), so a_w is constant for w >= d.
    More precisely: the shape stabilizes once the non-negativity constraints
    don't cut into the triangle defined by the difference constraints.
    """
    d = c0 + c1 + c2
    
    # Let's compute the stabilization point precisely.
    # The three difference constraints define a triangle with vertices (in the L1-L2 plane):
    #   v1 = ((w-c2-2c1)/3, (w-c2+c1)/3)
    #   v2 = ((w+2c0+c2)/3, (w-2c2-c0)/3)  
    #   v3 = ((w+c0-c1)/3, (w+c0+2c1)/3)
    
    # These vertices are all in the first quadrant AND satisfy L1+L2 <= w when:
    # From v1: L1 = (w-c2-2c1)/3 >= 0 => w >= c2+2c1 = d-c0+c1
    #          L2 = (w-c2+c1)/3 >= 0 => w >= c2-c1 (always true if c1 >= c2, else need w >= c2-c1)
    #          L3 = w-L1-L2 = w - (2w-2c2-c1)/3 = (w+2c2+c1)/3 >= 0 (always)
    # From v2: L1 = (w+2c0+c2)/3 >= 0 (always)
    #          L2 = (w-2c2-c0)/3 >= 0 => w >= 2c2+c0 = d+c2-c1
    #          L3 = w - (2w+2c0-c2)/3 = (w-2c0+c2)/3 >= 0 => w >= 2c0-c2 (need this)
    # From v3: L1 = (w+c0-c1)/3 >= 0 => w >= c1-c0 (true when c0 >= c1, else need this)
    #          L2 = (w+c0+2c1)/3 >= 0 (always)
    #          L3 = w - (2w+c0+c1)/3 = (w-c0-c1)/3 = c2/3 * ... no: = (w-c0-c1)/3
    #          >= 0 => w >= c0+c1 = d-c2
    
    # The stabilization threshold is:
    thresholds = [
        c2 + 2*c1,      # = d - c0 + c1
        max(0, c2 - c1),
        2*c2 + c0,      # = d + c2 - c1
        max(0, 2*c0 - c2),
        max(0, c1 - c0),
        c0 + c1,        # = d - c2
    ]
    w0 = max(thresholds)
    
    # For w >= w0, a_w = stable_value
    stable_value = (d+1)*(d+2)//6
    
    # Verify
    counts = [count_lattice_points_at_height(c0, c1, c2, w) for w in range(w0 + 5)]
    actual_stable_from = None
    for w in range(len(counts)):
        if counts[w] == stable_value:
            actual_stable_from = w
            break
    
    print(f"c = ({c0},{c1},{c2}), d = {d}")
    print(f"  Predicted w0 = {w0}")
    print(f"  Actual stabilization: w = {actual_stable_from}")
    print(f"  Counts: {counts}")
    print(f"  Stable value = {stable_value}")
    
    # Now prove monotonicity for w < w0 by exhaustive check (finite computation).
    # For w >= w0, constant implies trivially non-decreasing.
    mono_ok = True
    for w in range(1, len(counts)):
        if counts[w] < counts[w-1]:
            print(f"  FAIL: a_{w} = {counts[w]} < a_{w-1} = {counts[w-1]}")
            mono_ok = False
    
    if mono_ok:
        print(f"  Monotonicity: VERIFIED for all w up to {len(counts)-1}")
    
    return w0, actual_stable_from, counts

print("\n--- Testing stabilization thresholds ---")
for d in [2, 4, 5, 7, 8, 10, 11, 13, 14]:
    if d % 3 == 0:
        continue
    print(f"\n=== d = {d} ===")
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 >= c1 >= c2:
                formal_ehrhart(c0, c1, c2)

