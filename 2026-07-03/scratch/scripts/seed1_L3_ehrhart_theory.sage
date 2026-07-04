"""
Seed 1 Layer 3: Theoretical Ehrhart analysis.

Key idea: The polytope P_w lives in the 2D slice {a0+a1+a2 = w} of a 3D cone C.
The cone C = {(a0,a1,a2) >= 0 : a1-a0<=c1, a2-a1<=c2, a0-a2<=c0} is a pointed 
polyhedral cone with apex at origin and a single ray (1,1,1).

The cross-section at sum=w is a convex polygon whose lattice point count
f(w) = |P_w ∩ Z^2| is the Ehrhart quasi-polynomial of P_w.

For a 2D convex polygon, the Ehrhart function is:
f(w) = area(P_w) + (perimeter correction) + (vertex correction)

Since P_w is the w-dilation of P_1 (adjusted for the cone constraints),
the area grows quadratically and the correction terms are lower order.

But ACTUALLY P_w is NOT just a dilation. The shape changes with w.
We need to understand this more carefully.
"""

from sage.all import *

def compute_f1_and_area(c, w_max=30):
    """Compute both lattice count and area of P_w."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    print(f"Profile c = {c}, d = {d}, base = {base}")
    print(f"{'w':>4} {'f(w)':>6} {'area':>10} {'perim':>10} {'nverts':>6}")
    
    for w in range(w_max + 1):
        ieqs = [
            [0, 1, 0],              # a0 >= 0
            [0, 0, 1],              # a1 >= 0
            [w, -1, -1],            # a2 >= 0
            [c1, 1, -1],            # a1-a0<=c1
            [-(w-c2), 1, 2],        # a0+2a1>=w-c2
            [w+c0, -2, -1],         # 2a0+a1<=w+c0
        ]
        P = Polyhedron(ieqs=ieqs, base_ring=QQ)
        if P.dimension() < 0:
            print(f"{w:4d} {'empty':>6}")
            continue
        
        npts = len(P.integral_points())
        area = float(P.volume()) if P.dimension() == 2 else 0
        
        # Perimeter (sum of edge lengths) - only meaningful for 2D
        perim = 0
        if P.dimension() == 2:
            for e in P.faces(1):
                v1, v2 = [list(v.vector()) for v in e.vertices()]
                perim += sqrt((v1[0]-v2[0])**2 + (v1[1]-v2[1])**2)
        
        nverts = len(P.vertices())
        print(f"{w:4d} {npts:6d} {float(area):10.4f} {float(perim):10.4f} {nverts:6d}")

def analyze_stabilized_polygon(c):
    """
    For large w, P_w stabilizes in shape (up to translation by (1,1,1)/3).
    Analyze this stable polygon.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    # For large w, the constraints a0>=0, a1>=0, a2>=0 are non-binding.
    # The active constraints are:
    #   a1 - a0 <= c1
    #   a2 - a1 <= c2  => (w-a0-a1) - a1 <= c2 => a0 + 2*a1 >= w - c2
    #   a0 - a2 <= c0  => 2*a0 + a1 <= w + c0
    
    # These define a triangle/polygon in the 2D plane {a0+a1+a2 = w}.
    # The vertices are at the intersections of pairs of these constraints.
    
    # At equality:
    # (1) a1 - a0 = c1 and a0 + 2*a1 = w - c2:
    #     a1 = a0 + c1, a0 + 2(a0+c1) = w-c2 => 3*a0 = w-c2-2*c1 => a0 = (w-c2-2*c1)/3
    #     a1 = (w-c2-2*c1)/3 + c1 = (w-c2+c1)/3
    
    # (2) a1 - a0 = c1 and 2*a0 + a1 = w + c0:
    #     a1 = a0 + c1, 2*a0 + a0 + c1 = w+c0 => 3*a0 = w+c0-c1 => a0 = (w+c0-c1)/3
    #     a1 = (w+c0-c1)/3 + c1 = (w+c0+2*c1)/3
    
    # (3) a0 + 2*a1 = w - c2 and 2*a0 + a1 = w + c0:
    #     From these: 3*a1 = 2(w-c2) - (w+c0) = w - 2*c2 - c0
    #     a1 = (w-2*c2-c0)/3
    #     a0 = (w+c0 - (w-2*c2-c0)/3)/2... let me redo.
    #     a0 + 2*a1 = w-c2 => a0 = w-c2-2*a1
    #     2*(w-c2-2*a1) + a1 = w+c0 => 2*w-2*c2-4*a1+a1 = w+c0
    #     => w - 2*c2 - 3*a1 = c0 => a1 = (w - 2*c2 - c0)/3
    #     => a0 = w - c2 - 2*(w-2*c2-c0)/3 = (3*w-3*c2-2*w+4*c2+2*c0)/3 = (w+c2+2*c0)/3
    
    print(f"\nStabilized polygon analysis for c = {c}:")
    
    # So the three vertices of the stabilized triangle are:
    # V1 = ((w-c2-2*c1)/3, (w-c2+c1)/3)   -- intersection of ineq 1&3 (shift constraints)
    # V2 = ((w+c0-c1)/3, (w+c0+2*c1)/3)   -- intersection of ineq 1&2
    # V3 = ((w+c2+2*c0)/3, (w-2*c2-c0)/3) -- intersection of ineq 2&3
    
    # Note: c0+c1+c2 = d, so these simplify.
    # V1 = ((w-d+c0)/3, (w-d+c0+3*c1)/3)... hmm let me just compute.
    
    # V1_a0 = (w - c2 - 2*c1)/3
    # V1_a1 = (w - c2 + c1)/3
    # V1_a2 = w - V1_a0 - V1_a1 = w - (2*w - 2*c2 - c1)/3 = (w + 2*c2 + c1)/3
    
    # V2_a0 = (w + c0 - c1)/3
    # V2_a1 = (w + c0 + 2*c1)/3
    # V2_a2 = w - V2_a0 - V2_a1 = w - (2*w + 2*c0 + c1)/3 = (w - 2*c0 - c1)/3
    
    # V3_a0 = (w + c2 + 2*c0)/3
    # V3_a1 = (w - 2*c2 - c0)/3
    # V3_a2 = w - V3_a0 - V3_a1 = w - (2*w - c2 + c0)/3 = (w + c2 - c0)/3... 
    # = (w + c2 - c0)/3
    
    # Area of this triangle:
    # Using the Shoelmaker formula in (a0, a1) coordinates:
    # 2*Area = |det([[V1_a0 - V3_a0, V2_a0 - V3_a0], [V1_a1 - V3_a1, V2_a1 - V3_a1]])|
    
    # V1 - V3:
    # a0: (w-c2-2*c1)/3 - (w+c2+2*c0)/3 = (-2*c2-2*c1-2*c0)/3 = -2*d/3
    # a1: (w-c2+c1)/3 - (w-2*c2-c0)/3 = (c2+c1+c0)/3 = d/3
    
    # V2 - V3:
    # a0: (w+c0-c1)/3 - (w+c2+2*c0)/3 = (-c2-c0-c1)/3 = -d/3
    # a1: (w+c0+2*c1)/3 - (w-2*c2-c0)/3 = (2*c0+2*c1+2*c2)/3 = 2*d/3
    
    # det = (-2*d/3)(2*d/3) - (d/3)(-d/3) = -4*d^2/9 + d^2/9 = -3*d^2/9 = -d^2/3
    # Area = |det|/2 = d^2/6
    
    print(f"  Area of stabilized triangle = d^2/6 = {d}^2/6 = {d**2/6}")
    print(f"  By Pick's theorem: A = I + B/2 - 1")
    print(f"  where I = interior points, B = boundary points")
    print(f"  So I + B/2 = A + 1 = d^2/6 + 1 = {d**2/6 + 1}")
    print(f"  And I + B = lattice points = base = {base} = (d+1)(d+2)/6")
    
    # Check: I + B = (d+1)(d+2)/6 and A = d^2/6
    # Pick: (d+1)(d+2)/6 - B/2 = d^2/6 + 1 - 1 = d^2/6
    # => (d+1)(d+2)/6 = d^2/6 + B/2
    # => B/2 = (d+1)(d+2)/6 - d^2/6 = ((d+1)(d+2) - d^2)/6 = (3d+2)/6
    # => B = (3d+2)/3
    
    # For d=7: B = 23/3... not integer! So this only works when 3 | (3d+2) mod 3 = 2 mod 3.
    # That means B is never an integer... something's wrong.
    
    # Actually, the polygon P_w has vertices with denominator 3 in general.
    # So Pick's theorem doesn't directly apply to P_w but rather to 3*P_w (dilated).
    # The period of the Ehrhart quasi-polynomial is at most 3.
    
    print(f"\n  Vertex denominators: all vertices have coordinates with denominator 3")
    print(f"  Ehrhart quasi-polynomial period divides 3")
    print(f"  This explains why f(w) depends on w mod 3")
    
    # Let's verify: compute f(w) for w = 0..3*d and check period
    f_vals = {}
    for w in range(3*d+1):
        ieqs = [
            [0, 1, 0], [0, 0, 1], [w, -1, -1],
            [c1, 1, -1], [-(w-c2), 1, 2], [w+c0, -2, -1],
        ]
        P = Polyhedron(ieqs=ieqs, base_ring=QQ)
        f_vals[w] = len(P.integral_points()) if P.dimension() >= 0 else 0
    
    # Check quasi-polynomial behavior for large w
    print(f"\n  f(w) values:")
    for w in range(3*d+1):
        print(f"    f({w}) = {f_vals[w]}")
    
    # For large w (after stabilization), f(w) = base = const
    # This means the Ehrhart quasi-polynomial has degree 0 for large w
    # (the area and boundary corrections exactly cancel the growth)
    # Wait, no — the area grows as w^2, but the polytope is NOT w*P_1.
    # The polytope P_w is a CROSS-SECTION, not a DILATION.
    # For large w, it's a TRANSLATION, so the lattice count is constant.
    
    print(f"\n  KEY INSIGHT: For w >= d, the polytope P_w is a TRANSLATE")
    print(f"  of P_d by the vector (w-d)/3 * (1,1,1).")
    print(f"  Since (1,1,1) is a lattice vector, lattice point count is preserved.")
    print(f"  So f(w) = f(d) = base for all w >= stabilization point.")
    
    return None

def find_explicit_ehrhart(c, w_range=30):
    """
    Compute f(w) and fit an Ehrhart quasi-polynomial.
    Since period divides 3, write f(w) = a_r(w) where r = w mod 3.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    print(f"\nEhrhart quasi-polynomial for c = {c}:")
    
    f_vals = []
    for w in range(w_range+1):
        ieqs = [
            [0, 1, 0], [0, 0, 1], [w, -1, -1],
            [c1, 1, -1], [-(w-c2), 1, 2], [w+c0, -2, -1],
        ]
        P = Polyhedron(ieqs=ieqs, base_ring=QQ)
        npts = len(P.integral_points()) if P.dimension() >= 0 else (1 if w == 0 else 0)
        f_vals.append(npts)
    
    # Separate by w mod 3
    for r in range(3):
        vals = [(w, f_vals[w]) for w in range(w_range+1) if w % 3 == r]
        print(f"  w ≡ {r} (mod 3): {vals[:10]}")
    
    # The function f(w) for small w is piecewise linear (since the polygon's area
    # is linear in w for the growth regime).
    # Actually, since it's a 2D cross-section of a 3D cone,
    # f(w) is the Ehrhart function of the w-th dilate of P_1...
    # No wait, P_w ≠ w*P_1 in general.
    
    # Let's think differently. The cone C has a single ray (1,1,1).
    # The cross-sections C ∩ {sum = w} for w = 0,1,2,... are nested
    # (after translation to center them).
    # Actually NOT nested — the shape can change.
    
    # Better: define the PROJECTED cone
    # In the (a0, a1) plane, the constraints not involving w are:
    #   a0 >= 0, a1 >= 0, a1 - a0 <= c1
    # The w-dependent constraints are:
    #   a0 + a1 <= w (from a2 >= 0)
    #   a0 + 2*a1 >= w - c2
    #   2*a0 + a1 <= w + c0
    
    # For small w, the a_i >= 0 constraints dominate.
    # For large w, the interlacing constraints dominate.
    # The transition happens around w ~ d.
    
    return f_vals

# Main computation
print("=" * 70)
print("EHRHART THEORY ANALYSIS")
print("=" * 70)

for c in [(2,1,1), (3,2,2), (4,2,1), (5,3,2)]:
    analyze_stabilized_polygon(c)
    find_explicit_ehrhart(c, w_range=20)
    print()

# KEY THEORETICAL RESULT:
# For the stabilized polygon (w >= d), the vertices have denominator 3.
# The area is d^2/6 (independent of profile c).
# base = (d+1)(d+2)/6 = d^2/6 + d/2 + 1/3... 
# Actually (d+1)(d+2)/6 = (d^2+3d+2)/6.
# And d^2/6 is the area. By Pick: I + B/2 = Area + 1.
# So total lattice points = I + B = Area + 1 + B/2.

# But when d not≡ 0 mod 3, the vertices have non-integer coordinates (denominator 3).
# So the Ehrhart correction terms are quasi-periodic in w.
# For the stabilized shape (large w), f(w) = base regardless of w mod 3,
# which means all three components of the quasi-polynomial agree at the stable value.

print("\n" + "=" * 70)
print("THEORETICAL MONOTONICITY ARGUMENT")
print("=" * 70)
print("""
THEOREM (informal): For any composition c = (c0,c1,c2) with d > 0,
the lattice point count f(w) = |P_w ∩ Z^2| is monotonically 
non-decreasing in w.

PROOF SKETCH:
1. The polytope P_w is a cross-section of the 3D cone
   C = {x >= 0 : x1-x0 <= c1, x2-x1 <= c2, x0-x2 <= c0}
   at hyperplane sum = w.

2. C is a pointed polyhedral cone with apex at origin and ray (1,1,1).

3. For w' = w + 1, the polytope P_{w+1} is obtained from P_w by:
   - Expanding the "simplex" constraints (a_i >= 0 gives a0+a1 <= w+1)
   - Shifting the "interlacing" constraints 
   
4. KEY OBSERVATION: The map phi: (a0,a1,a2) -> (a0,a1,a2) from P_w to P_{w+1}
   preserves all interlacing constraints (a1-a0<=c1, a2-a1<=c2, a0-a2<=c0)
   since these don't involve w. The only constraint that changes is sum = w+1.
   
   So every point (a0,a1,a2) in P_w ∩ {sum=w} can be mapped to one of:
   - (a0+1, a1, a2) in P_{w+1} (if the interlacing constraints allow)
   - (a0, a1+1, a2) in P_{w+1}
   - (a0, a1, a2+1) in P_{w+1}
   
   At least one of these shifts preserves all constraints, because the
   interlacing constraints are DIFFERENCES (a_{i+1} - a_i <= c_{i+1}),
   and adding 1 to a_i tightens at most one constraint while loosening another.

5. More precisely: the three shifts form a covering of the polytope.
   For each lattice point p in P_w, define:
   - p can shift right (increase a0) unless a0 - a2 = c0 and a1 - a0 = c1
     (both constraints tight)
   - p can shift middle (increase a1) unless a1 - a0 = c1 and a2 - a1 = c2
   - p can shift left (increase a2) unless a2 - a1 = c2 and a0 - a2 = c0
   
   Can all three constraints be simultaneously tight? Only if:
   a1 - a0 = c1, a2 - a1 = c2, a0 - a2 = c0
   Sum: 0 = c0 + c1 + c2... impossible since d > 0! (Wait, the sum of differences
   (a1-a0) + (a2-a1) + (a0-a2) = 0, and c1 + c2 + c0 = d > 0.)
   
   So it's IMPOSSIBLE for all three constraints to be tight simultaneously,
   which means at least one shift is always available.

6. This proves the existence of a shift map, but NOT injectivity.
   We need Hall's marriage theorem: the bipartite graph G with
   edges from P_w to P_{w+1} (via the three shifts) satisfies Hall's condition.

   CLAIM: Hall's condition holds because for any subset S of P_w,
   the neighborhood N(S) in P_{w+1} has |N(S)| >= |S|.
   
   This follows because each point in P_w has at least 2 valid shifts
   (since at most one pair of interlacing constraints can be simultaneously tight),
   and the shift map is "locally expanding" near the boundary.
""")

