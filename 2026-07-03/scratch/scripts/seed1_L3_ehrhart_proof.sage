"""
Seed 1 Layer 3: PROVE f_1 monotonicity via Ehrhart theory.

Key theorem we want to prove:
For any composition c = (c0, c1, c2) with d = c0+c1+c2 > 0,
the lattice point count f_1(w) = |P_w ∩ Z^2| is monotonically
non-decreasing in w, where P_w is the polygon:

P_w = {(a0, a1) in R^2 : a0 >= 0, a1 >= 0, a0+a1 <= w,
       a1 - a0 <= c1, w-a0-2*a1 <= c2, 2*a0+a1-w <= c0}

Strategy: Show that for each w, there exists an injection
P_w ∩ Z^2 -> P_{w+1} ∩ Z^2.

Candidate injection: (a0, a1) -> (a0+t0, a1+t1) where t0+t1 = 1,
i.e., we add 1 to one of the coordinates.
"""

from sage.all import *

def binary_cpp_polytope_2d(c, w):
    """P_w as a 2D polytope in (a0, a1) coordinates."""
    c0, c1, c2 = c
    ieqs = [
        [0, 1, 0],              # a0 >= 0
        [0, 0, 1],              # a1 >= 0
        [w, -1, -1],            # a0 + a1 <= w (a2 >= 0)
        [c1, 1, -1],            # a1 - a0 <= c1
        [-(w - c2), 1, 2],      # a0 + 2*a1 >= w - c2
        [w + c0, -2, -1],       # 2*a0 + a1 <= w + c0
    ]
    return Polyhedron(ieqs=ieqs, base_ring=QQ)

def lattice_points_set(c, w):
    """Return the set of lattice points in P_w."""
    P = binary_cpp_polytope_2d(c, w)
    if P.dimension() < 0:
        return set()
    return set(tuple(p) for p in P.integral_points())

def find_injection(c, w):
    """
    Try to find an explicit injection P_w -> P_{w+1}.
    Strategy: for each (a0, a1) in P_w, try:
      1. (a0+1, a1) — add 1 to coordinate 0
      2. (a0, a1+1) — add 1 to coordinate 1
      3. (a0, a1) with a2+1 — but a2 = w-a0-a1, so new a2 = w+1-a0-a1, 
         meaning the same (a0,a1) but in P_{w+1}
    Check which strategy puts us in P_{w+1}.
    """
    c0, c1, c2 = c
    S_w = lattice_points_set(c, w)
    S_w1 = lattice_points_set(c, w+1)
    
    if not S_w:
        return True, {}  # empty set trivially injects
    
    # Strategy: try the three shifts, pick any valid one for each point
    injection = {}
    used = set()
    
    for pt in sorted(S_w):
        a0, a1 = pt
        a2 = w - a0 - a1
        
        candidates = []
        
        # Option 1: increase a0 by 1
        new = (a0+1, a1)
        if new in S_w1 and new not in used:
            candidates.append(new)
        
        # Option 2: increase a1 by 1
        new = (a0, a1+1)
        if new in S_w1 and new not in used:
            candidates.append(new)
        
        # Option 3: increase a2 by 1 (same (a0,a1) in P_{w+1})
        new = (a0, a1)  # a2 becomes w+1-a0-a1 = a2+1
        if new in S_w1 and new not in used:
            candidates.append(new)
        
        if not candidates:
            return False, {}
        
        # Greedy: pick first available
        chosen = candidates[0]
        injection[pt] = chosen
        used.add(chosen)
    
    return True, injection

def prove_injection_greedy(c, w_max=50):
    """Try greedy injection for all w up to w_max."""
    d = sum(c)
    base = (d+1)*(d+2)//6
    print(f"Profile c = {c}, d = {d}, base = {base}")
    
    all_ok = True
    first_stable = None
    for w in range(w_max):
        ok, inj = find_injection(c, w)
        S_w = lattice_points_set(c, w)
        S_w1 = lattice_points_set(c, w+1)
        if not ok:
            print(f"  w={w}: INJECTION FAILED! |P_w|={len(S_w)}, |P_{{w+1}}|={len(S_w1)}")
            all_ok = False
        else:
            if len(S_w) == base and first_stable is None:
                first_stable = w
            # Verify injection is actually injective
            if len(set(inj.values())) != len(inj):
                print(f"  w={w}: NOT INJECTIVE! Values collide.")
                all_ok = False
    
    print(f"  Greedy injection works for w = 0..{w_max-1}: {all_ok}")
    if first_stable is not None:
        print(f"  Stabilizes at w = {first_stable}")
    return all_ok

def prove_injection_optimal(c, w_max=50):
    """
    Use bipartite matching to find optimal injection.
    This is stronger than greedy — it proves monotonicity
    if any injection exists.
    """
    d = sum(c)
    base = (d+1)*(d+2)//6
    print(f"\nOptimal matching for c = {c}, d = {d}")
    
    all_ok = True
    for w in range(w_max):
        S_w = sorted(lattice_points_set(c, w))
        S_w1 = sorted(lattice_points_set(c, w+1))
        
        if len(S_w) > len(S_w1):
            print(f"  w={w}: |P_w|={len(S_w)} > |P_{{w+1}}|={len(S_w1)} — NOT MONOTONE!")
            all_ok = False
            continue
        
        if not S_w:
            continue
        
        # Build bipartite graph and find matching using networkx-like approach
        # Use SageMath's Graph/matching
        from sage.graphs.graph import Graph
        
        n = len(S_w)
        m = len(S_w1)
        
        # Create bipartite graph with edges for valid maps
        edges = []
        c0, c1, c2 = c
        for i, pt in enumerate(S_w):
            a0, a1 = pt
            for j, pt2 in enumerate(S_w1):
                b0, b1 = pt2
                # Valid map: b0-a0 >= 0, b1-a1 >= 0, b0+b1-(a0+a1) <= 1... 
                # Actually we want ANY injection, not necessarily "shift by +1"
                # The three shifts are: (+1,0), (0,+1), (0,0) [a2 increases]
                if pt2 == (a0+1, a1) or pt2 == (a0, a1+1) or pt2 == (a0, a1):
                    edges.append((f"L{i}", f"R{j}"))
        
        if not edges:
            if S_w:
                print(f"  w={w}: No valid edges!")
                all_ok = False
            continue
        
        G = Graph(edges)
        matching = G.matching()
        if len(matching) < n:
            print(f"  w={w}: Matching size {len(matching)} < {n} = |P_w|. FAIL.")
            all_ok = False
        
    print(f"  Optimal matching works: {all_ok}")
    return all_ok

# Main
print("=" * 70)
print("PROVING f_1 MONOTONICITY VIA INJECTION")
print("=" * 70)

profiles = [
    (1, 1, 0),   # d=2
    (2, 1, 1),   # d=4
    (2, 2, 1),   # d=5
    (3, 1, 1),   # d=5
    (3, 2, 2),   # d=7
    (4, 2, 1),   # d=7
    (3, 3, 2),   # d=8
    (5, 2, 1),   # d=8
    (4, 3, 3),   # d=10
    (5, 3, 2),   # d=10
    (5, 4, 4),   # d=13
    (6, 4, 4),   # d=14
]

for c in profiles:
    prove_injection_greedy(c, w_max=3*sum(c)+5)
    print()

# For the cases where greedy fails, try optimal matching
print("\n--- OPTIMAL MATCHING ---\n")
for c in [(3,2,2), (4,2,1), (3,3,2), (5,2,1)]:
    prove_injection_optimal(c, w_max=3*sum(c)+5)
    print()

