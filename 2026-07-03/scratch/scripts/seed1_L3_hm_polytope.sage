"""
Seed 1 Layer 3: h_m polytope and h*-vector analysis.

For m >= 2, g_m counts cylindric partitions with max entry <= m.
Each partition nu^i has parts in {0,...,m}, so we can represent it
by its "signature" -- the number of parts equal to each value.

For m=2, a binary-plus CPP has parts in {0,1,2}.
For the lattice point interpretation, we need the full partition,
not just part counts.

Let's focus on h*-vector computation for the m=1 case first,
then try to extend.
"""

from sage.all import *

def binary_cpp_polytope_cone(c):
    """
    The cone C = {(a0,a1,a2) >= 0 : interlacing constraints}.
    This is a 3D pointed cone.
    """
    c0, c1, c2 = c
    ieqs = [
        [0, 1, 0, 0],       # a0 >= 0
        [0, 0, 1, 0],       # a1 >= 0
        [0, 0, 0, 1],       # a2 >= 0
        [c1, 1, -1, 0],     # a1 - a0 <= c1
        [c2, 0, 1, -1],     # a2 - a1 <= c2
        [c0, -1, 0, 1],     # a0 - a2 <= c0
    ]
    return Polyhedron(ieqs=ieqs, base_ring=QQ)

def compute_hstar(c):
    """
    Compute the h*-vector of the cone cross-section polytope.
    
    The generating function for f(w) = lattice point count is:
    sum_{w>=0} f(w) t^w = h*(t) / (1-t)^{dim+1}
    
    For a 2D cross-section of a 3D cone with one ray,
    the generating function is h*(t) / (1-t)^3... no, we need
    to think about this differently.
    
    The lattice point count f(w) stabilizes to base for large w.
    So the generating function is a rational function in t.
    
    f(t) = sum_{w>=0} f(w) t^w
    
    For the cone C with ray (1,1,1), the Hilbert series is:
    H(t) = sum_{w>=0} f(w) t^w = h*(t) / (1-t)
    where h* encodes the non-trivial part.
    
    Actually, since f(w) = base for w >= w_0 (stabilization),
    f(t) = sum_{w=0}^{w_0-1} f(w) t^w + base * t^{w_0} / (1-t)
         = polynomial + base * t^{w_0} / (1-t)
         = [polynomial * (1-t) + base * t^{w_0}] / (1-t)
    
    So (1-t) * f(t) = polynomial, and f(t) = P(t) / (1-t).
    The numerator P(t) has coefficients = first differences of f(w),
    plus the base at w_0.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    # Compute f(w) values
    f_vals = []
    for w in range(3*d):
        pts = 0
        for a0 in range(w+1):
            for a1 in range(w-a0+1):
                a2 = w - a0 - a1
                if a2 >= 0 and a1-a0 <= c1 and a2-a1 <= c2 and a0-a2 <= c0:
                    pts += 1
        f_vals.append(pts)
        if pts == base and w > 0 and f_vals[w-1] == base:
            break
    
    # Find stabilization point
    stab = len(f_vals) - 1
    for w in range(len(f_vals)):
        if f_vals[w] == base:
            stab = w
            break
    
    # Compute h*-vector: first differences of f up to stabilization
    # (1-t) * sum f(w) t^w = f(0) + sum_{w>=1} (f(w)-f(w-1)) t^w
    # For w >= stab: f(w)-f(w-1) = 0
    hstar = [f_vals[0]]
    for w in range(1, stab + 1):
        hstar.append(f_vals[w] - f_vals[w-1])
    
    print(f"Profile c = {c}, d = {d}, base = {base}")
    print(f"  f(w) = {f_vals[:stab+3]}")
    print(f"  Stabilizes at w = {stab}")
    print(f"  h*-vector: {hstar}")
    print(f"  h*(1) = {sum(hstar)} should = base = {base}")
    print(f"  All h* >= 0: {all(h >= 0 for h in hstar)}")
    
    # By Stanley's theorem, the h*-vector of a lattice polytope is nonneg.
    # Here we're computing it for the Ehrhart function of a cone cross-section.
    # The nonnegativity of h* IS the monotonicity of f(w).
    
    return hstar

# Compute h*-vectors for all profiles
print("=" * 70)
print("h*-VECTOR COMPUTATION FOR CONE CROSS-SECTIONS")
print("=" * 70)

profiles = [
    (1, 1, 0), (2, 1, 1), (2, 2, 1), (3, 1, 1),
    (3, 2, 2), (4, 2, 1), (3, 3, 2), (5, 2, 1),
    (4, 3, 3), (5, 3, 2), (5, 4, 4), (6, 4, 4),
]

for c in profiles:
    compute_hstar(c)
    print()

# Now let's try to use SageMath's Ehrhart polynomial tools
print("=" * 70)
print("SAGE EHRHART POLYNOMIAL COMPUTATION")
print("=" * 70)

for c in [(2,1,1), (3,2,2), (4,2,1)]:
    c0, c1, c2 = c
    d = c0 + c1 + c2
    base = (d+1)*(d+2)//6
    
    # The cross-section P_1 (unit cross-section of the cone)
    # In (a0, a1) space with a2 = 1 - a0 - a1
    ieqs = [
        [0, 1, 0],              # a0 >= 0
        [0, 0, 1],              # a1 >= 0
        [1, -1, -1],            # a2 = 1-a0-a1 >= 0
        [c1, 1, -1],            # a1 - a0 <= c1
        [-(1-c2), 1, 2],        # a0 + 2*a1 >= 1-c2
        [1+c0, -2, -1],         # 2*a0 + a1 <= 1+c0
    ]
    P1 = Polyhedron(ieqs=ieqs, base_ring=QQ)
    
    print(f"\nProfile c = {c}, d = {d}")
    print(f"  P_1: dim={P1.dimension()}, vertices={[list(v) for v in P1.vertices()]}")
    
    if P1.dimension() == 2:
        try:
            # SageMath can compute Ehrhart polynomial
            ehr = P1.ehrhart_polynomial()
            print(f"  Ehrhart polynomial: {ehr}")
        except Exception as e:
            print(f"  Ehrhart computation failed: {e}")
    
    # The CONE itself (in 3D)
    C = binary_cpp_polytope_cone(c)
    print(f"  Cone: dim={C.dimension()}, bounded={C.is_compact()}")
    
    # Try the Hilbert series of the cone
    try:
        # The Hilbert series counts lattice points in C at each level w
        # For a simplicial cone, SageMath can compute this
        hs = C.generating_function_of_integral_points()
        print(f"  Hilbert generating function: {hs}")
    except Exception as e:
        print(f"  Hilbert series failed: {e}")

