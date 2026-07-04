"""
Seed 1 Layer 3: Prove Hall's condition via deficiency analysis.

Key idea: In the bipartite graph G = (L, R, E) where L = P_w, R = P_{w+1},
and edges are the three shifts, we need to verify that for every S ⊆ L,
|N(S)| ≥ |S|.

Equivalently, the maximum deficiency def(G) = max_S(|S| - |N(S)|) = 0.

For our graph:
- Each L-vertex has degree 1, 2, or 3.
- Each R-vertex can receive at most 3 incoming edges.

The graph has a very specific structure: it's a "unit shift" graph on a 
convex lattice polygon. Such graphs are well-studied.

Let me verify the R-degrees and check if the graph is "balanced enough".
"""

from sage.all import *

def lattice_points_3d(c, w):
    c0, c1, c2 = c
    points = []
    for a0 in range(w+1):
        for a1 in range(w-a0+1):
            a2 = w - a0 - a1
            if a2 >= 0 and a1-a0 <= c1 and a2-a1 <= c2 and a0-a2 <= c0:
                points.append((a0, a1, a2))
    return points

def analyze_graph_structure(c, w):
    """Analyze the bipartite shift graph at level w."""
    c0, c1, c2 = c
    pts_w = lattice_points_3d(c, w)
    pts_w1 = lattice_points_3d(c, w+1)
    pts_w1_set = set(pts_w1)
    
    # L-degrees (how many valid shifts each L-vertex has)
    L_deg = {}
    for p in pts_w:
        a0, a1, a2 = p
        deg = 0
        for s in [(1,0,0), (0,1,0), (0,0,1)]:
            if (a0+s[0], a1+s[1], a2+s[2]) in pts_w1_set:
                deg += 1
        L_deg[p] = deg
    
    # R-degrees (how many L-vertices map to each R-vertex)
    R_deg = {p: 0 for p in pts_w1}
    for p in pts_w:
        a0, a1, a2 = p
        for s in [(1,0,0), (0,1,0), (0,0,1)]:
            t = (a0+s[0], a1+s[1], a2+s[2])
            if t in pts_w1_set:
                R_deg[t] = R_deg.get(t, 0) + 1
    
    L_deg_dist = {}
    for d in L_deg.values():
        L_deg_dist[d] = L_deg_dist.get(d, 0) + 1
    
    R_deg_dist = {}
    for d in R_deg.values():
        R_deg_dist[d] = R_deg_dist.get(d, 0) + 1
    
    return L_deg_dist, R_deg_dist, len(pts_w), len(pts_w1)

# Main analysis
print("=" * 70)
print("BIPARTITE GRAPH DEGREE ANALYSIS")
print("=" * 70)

for c in [(2,1,1), (3,2,2), (4,2,1), (5,3,2), (6,4,4)]:
    d = sum(c)
    base = (d+1)*(d+2)//6
    print(f"\nProfile c = {c}, d = {d}, base = {base}")
    
    for w in range(2*d+3):
        L_dist, R_dist, nL, nR = analyze_graph_structure(c, w)
        if nL > 0:
            # Check: sum of L degrees = sum of R degrees (edge count)
            total_edges = sum(k*v for k,v in L_dist.items())
            print(f"  w={w}: |L|={nL}, |R|={nR}, L_deg={L_dist}, R_deg={R_dist}, edges={total_edges}")

# Now let's prove the crucial property: no R-vertex has degree > |its incoming set|
# Actually, let's check if the graph is "König regular" in some sense.

print("\n" + "=" * 70)
print("EXPLICIT INJECTION CONSTRUCTION")
print("=" * 70)

# New idea: use a CANONICAL injection based on lexicographic priority.
# For each point, try shifts in order +a0, +a1, +a2.
# If this greedy assignment (with used-target tracking) works, we're done.

def canonical_injection(c, w):
    """
    Construct injection using the cyclic priority rule:
    At weight w ≡ r (mod 3), use priority order:
    r=0: +a0, +a1, +a2
    r=1: +a1, +a2, +a0
    r=2: +a2, +a0, +a1
    
    This rotates the priority to avoid collisions at the vertex points.
    """
    c0, c1, c2 = c
    pts_w = sorted(lattice_points_3d(c, w))
    pts_w1_set = set(lattice_points_3d(c, w+1))
    
    r = w % 3
    # Try different priority orderings
    priorities = [
        [(1,0,0), (0,1,0), (0,0,1)],
        [(0,1,0), (0,0,1), (1,0,0)],
        [(0,0,1), (1,0,0), (0,1,0)],
    ]
    
    for prio in priorities:
        used = set()
        injection = {}
        ok = True
        for p in pts_w:
            a0, a1, a2 = p
            found = False
            for s in prio:
                t = (a0+s[0], a1+s[1], a2+s[2])
                if t in pts_w1_set and t not in used:
                    injection[p] = t
                    used.add(t)
                    found = True
                    break
            if not found:
                ok = False
                break
        if ok:
            return True, injection, prio
    
    return False, {}, None

# Test canonical injection
for c in [(2,1,1), (3,2,2), (4,2,1), (5,3,2), (6,4,4)]:
    d = sum(c)
    base = (d+1)*(d+2)//6
    print(f"\nProfile c = {c}, d = {d}, base = {base}")
    
    all_ok = True
    for w in range(3*d+5):
        ok, inj, prio = canonical_injection(c, w)
        if not ok:
            print(f"  w={w}: ALL PRIORITY ORDERINGS FAIL")
            all_ok = False
    
    if all_ok:
        print(f"  Canonical injection works for all w in [0, {3*d+4}]")

