"""
Seed 1 Layer 3: Prove Hall's condition using the cyclic structure.

Key observation from degree analysis:
After stabilization, the bipartite graph G has:
- |L| = |R| = base
- L has exactly 1 vertex of degree 1, (d-2) vertices of degree 2, 
  and the rest of degree 3.
- R has the same distribution, cyclically shifted.
- Total edges = 1 + 2*(d-2) + 3*rest... 

Actually let me count: for c=(3,2,2), d=7, base=12:
L_deg = {1:1, 2:6, 3:5}, total = 1+12+15 = 28.
R_deg = {1:1, 2:6, 3:5}, total = 28.

The graph is (almost) regular with average degree 28/12 ≈ 2.33.

For base = (d+1)(d+2)/6, the number of interior points of the triangle is
I = (d-1)(d-2)/6, the number of boundary points is B = d, and base = I + B.

Points with degree 3 are the interior points (all three shifts valid).
Points with degree 2 are on the boundary (one shift fails: the one that
would push them off the edge).
Points with degree 1 are at the vertices (two shifts fail).

So: deg-3 count = I = (d-1)(d-2)/6
    deg-2 count = B - 1 = d - 1 (boundary minus one vertex)... 
    
Wait, for c=(3,2,2), d=7: I = 5*6/6 = 5. B = 12-5 = 7. But deg-2 = 6, deg-1 = 1.
So B = 7 = 6 + 1 = (deg-2) + (deg-1). Makes sense: boundary = edges + vertices.
Interior = degree-3. This confirms:
  deg-1 count = V = number of vertices where 2 interlacing constraints are tight
  deg-2 count = E = boundary points on edges of the triangle
  deg-3 count = I = interior points

For a triangle with denominator 3 vertices, the boundary lattice points are
NOT simply d (that's for a triangle with integer vertices).

Anyway, the key structural fact is:
- The bipartite graph at each level has the SAME structure (up to cyclic shift).
- The degree sequence is the same for L and R.
- The graph is "almost 2-regular" with a few degree-3 and one degree-1 vertex.

This is a SEMI-REGULAR bipartite graph. By Konig's theorem, such a graph
has a perfect matching iff it satisfies Hall's condition.

Let me verify Hall's condition by a more sophisticated method: find
the minimum vertex cover and verify it equals the maximum matching.
"""

from sage.all import *

def build_full_bipartite(c, w):
    """Build the bipartite graph as a SageMath graph."""
    c0, c1, c2 = c
    pts_w = []
    for a0 in range(w+1):
        for a1 in range(w-a0+1):
            a2 = w - a0 - a1
            if a2 >= 0 and a1-a0 <= c1 and a2-a1 <= c2 and a0-a2 <= c0:
                pts_w.append((a0, a1, a2))
    
    pts_w1 = []
    pts_w1_set = set()
    for a0 in range(w+2):
        for a1 in range(w+1-a0+1):
            a2 = w + 1 - a0 - a1
            if a2 >= 0 and a1-a0 <= c1 and a2-a1 <= c2 and a0-a2 <= c0:
                pts_w1.append((a0, a1, a2))
                pts_w1_set.add((a0, a1, a2))
    
    edges = []
    for p in pts_w:
        a0, a1, a2 = p
        for s in [(1,0,0), (0,1,0), (0,0,1)]:
            t = (a0+s[0], a1+s[1], a2+s[2])
            if t in pts_w1_set:
                edges.append((f"L{p}", f"R{t}"))
    
    G = Graph(edges)
    return G, len(pts_w), len(pts_w1)

# For the stabilized graph, verify Hall's condition using SageMath matching
print("=" * 70)
print("PERFECT MATCHING VERIFICATION VIA SAGE")
print("=" * 70)

for c in [(2,1,1), (3,2,2), (4,2,1), (3,3,2), (5,2,1), (5,3,2)]:
    d = sum(c)
    base = (d+1)*(d+2)//6
    print(f"\nProfile c = {c}, d = {d}, base = {base}")
    
    all_ok = True
    for w in range(3*d + 3):
        G, nL, nR = build_full_bipartite(c, w)
        if nL == 0:
            continue
        matching = G.matching()
        if len(matching) < nL:
            print(f"  w={w}: MATCHING FAILS: {len(matching)} < {nL}")
            all_ok = False
    
    if all_ok:
        print(f"  Perfect matching exists for all w in [0, {3*d+2}]")

# Now let's investigate the structure of the matching
print("\n" + "=" * 70)
print("MATCHING STRUCTURE ANALYSIS")
print("=" * 70)

for c in [(3,2,2)]:
    d = sum(c)
    base = (d+1)*(d+2)//6
    
    # Look at the matching for the stabilized case
    for w in [7, 8, 9]:
        G, nL, nR = build_full_bipartite(c, w)
        matching = G.matching()
        
        print(f"\nc = {c}, w = {w}: matching size {len(matching)}")
        for u, v, _ in sorted(matching):
            # Extract coordinates
            if u.startswith("L"):
                l_pt = u[1:]
                r_pt = v[1:]
            else:
                l_pt = v[1:]
                r_pt = u[1:]
            print(f"  {l_pt} -> {r_pt}")

