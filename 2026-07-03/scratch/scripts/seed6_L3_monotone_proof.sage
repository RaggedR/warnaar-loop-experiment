"""
Seed 6, Layer 3: Clean monotonicity proof for a_w.

a_w = #{(L1, L2, L3) in Z_>=0^3 : sum = w, L2-L1 <= c1, L3-L2 <= c2, L1-L3 <= c0}

We want to prove a_w >= a_{w-1} for all w >= 1.
"""

from sage.all import *

def count_at_height(c0, c1, c2, w):
    """Count lattice points at height w."""
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    return count

# =========================================================
# EXHAUSTIVE VERIFICATION for all d up to 25
# =========================================================

print("=" * 60)
print("Exhaustive monotonicity check for ALL profiles, d <= 25")
print("=" * 60)

total_profiles = 0
total_failures = 0
for d in range(1, 26):
    failures_at_d = 0
    profiles_at_d = 0
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            profiles_at_d += 1
            max_w = 2*d + 10
            prev = count_at_height(c0, c1, c2, 0)
            for w in range(1, max_w+1):
                curr = count_at_height(c0, c1, c2, w)
                if curr < prev:
                    failures_at_d += 1
                    print(f"  FAIL: d={d}, c=({c0},{c1},{c2}), a_{w} = {curr} < a_{w-1} = {prev}")
                    break
                prev = curr
    
    total_profiles += profiles_at_d
    total_failures += failures_at_d
    print(f"  d={d}: {profiles_at_d} profiles, {failures_at_d} failures")

print(f"\nTotal: {total_profiles} profiles tested, {total_failures} failures")

# =========================================================
# a_1 values and the proof that a_1 >= 1
# =========================================================

print("\n" + "=" * 60)
print("PROVING a_1 >= 1")
print("=" * 60)

print("""
For w = 1, the lattice points (L1, L2, L3) with L1+L2+L3 = 1 and L_i >= 0 are:
  (1, 0, 0), (0, 1, 0), (0, 0, 1)

Check which satisfy the constraints:
  (1, 0, 0): L2-L1 = -1 <= c1 (YES), L3-L2 = 0 <= c2 (YES), L1-L3 = 1 <= c0 (iff c0 >= 1)
  (0, 1, 0): L2-L1 = 1 <= c1 (iff c1 >= 1), L3-L2 = -1 <= c2 (YES), L1-L3 = 0 <= c0 (YES)
  (0, 0, 1): L2-L1 = 0 <= c1 (YES), L3-L2 = 1 <= c2 (iff c2 >= 1), L1-L3 = -1 <= c0 (YES)

So:
  a_1 = #{i : c_i >= 1} = (number of positive components of c)

For d >= 1, at least one c_i >= 1, so a_1 >= 1. QED.

More precisely:
  a_1 = 1 if exactly one c_i > 0 (e.g., c = (d, 0, 0))
  a_1 = 2 if exactly two c_i > 0 (e.g., c = (d-1, 1, 0))
  a_1 = 3 if all three c_i > 0 (e.g., c = (a, b, c) with a,b,c >= 1)
""")

# Verify
for d in range(1, 15):
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            a1 = count_at_height(c0, c1, c2, 1)
            expected = sum(1 for x in [c0, c1, c2] if x >= 1)
            assert a1 == expected, f"MISMATCH: c=({c0},{c1},{c2}), a1={a1}, expected={expected}"

print("Verified: a_1 = #{i : c_i >= 1} for all d <= 14. QED.")

# =========================================================
# FORMAL PROOF OF MONOTONICITY
# =========================================================

print("\n" + "=" * 60)
print("FORMAL PROOF OF MONOTONICITY via explicit construction")
print("=" * 60)

print("""
THEOREM: For any composition c = (c0, c1, c2) with d = c0+c1+c2 >= 1,
the sequence (a_w)_{w >= 0} is weakly monotonically increasing.

PROOF:

We construct an injection phi: P_{w-1} -> P_w where 
  P_w = {(L1, L2, L3) in Z_>=0^3 : sum = w, L2-L1 <= c1, L3-L2 <= c2, L1-L3 <= c0}.

For (L1, L2, L3) in P_{w-1}, define:
  S(L) = {i in {1,2,3} : incrementing L_i preserves all constraints}

Specifically:
  1 in S iff L1+1-L3 <= c0 AND L2-(L1+1) <= c1, i.e., L1-L3 < c0 (the L2 constraint is automatic)
  2 in S iff L2+1-L1 <= c1 AND L3-(L2+1) <= c2, i.e., L2-L1 < c1 
  3 in S iff L3+1-L2 <= c2 AND L1-(L3+1) <= c0, i.e., L3-L2 < c2

CLAIM: S(L) is nonempty for all L in P_{w-1}.

PROOF OF CLAIM: If S(L) = emptyset, then L1-L3 >= c0, L2-L1 >= c1, L3-L2 >= c2.
But already L1-L3 <= c0, L2-L1 <= c1, L3-L2 <= c2.
So L1-L3 = c0, L2-L1 = c1, L3-L2 = c2.
Sum: 0 = c0 + c1 + c2 = d >= 1. Contradiction. QED.

Now define phi(L) = L + e_{min(S(L))} (add 1 to the smallest index in S).

CLAIM: phi is injective.

PROOF OF INJECTIVITY (by contradiction):
Suppose phi(L) = phi(L') with L != L'. Then L + e_i = L' + e_j for some i,j in {1,2,3}.
If i = j, then L = L', contradiction.
If i < j (say i=1, j=2 WLOG), then L1' = L1+1, L2' = L2-1, L3' = L3.
  Since 1 = min(S(L)), we have L1 - L3 < c0 (opt 1 available for L).
  Since 2 = min(S(L')), we have 1 not in S(L'), i.e., L1' - L3' >= c0, 
  i.e., (L1+1) - L3 >= c0, i.e., L1 - L3 >= c0 - 1.
  
  So c0 - 1 <= L1 - L3 < c0, which means L1 - L3 = c0 - 1.
  Then L1' - L3' = L1 + 1 - L3 = c0. So L1' - L3' = c0 (tight).
  And 1 not in S(L') iff L1' - L3' >= c0, which holds with equality. Good.
  
  For 2 in S(L'): L2' - L1' < c1, i.e., (L2-1) - (L1+1) < c1, i.e., L2 - L1 < c1 + 2.
  
  But we also need to check: is 1 not in S(L')? L1'-L3' = c0 >= c0, so yes.
  And is 2 in S(L')? We need L2'-L1' < c1, i.e., L2-1-(L1+1) = L2-L1-2 < c1.
  Since L2-L1 <= c1 (from L being valid), we get L2-L1-2 <= c1-2 < c1. YES.
  
  But wait -- does this actually lead to a contradiction? Not necessarily.
  We need to check whether the two preimages CAN have the same image.
  
  Let's check: L has 1 in S(L), meaning L1-L3 < c0, i.e., L1-L3 <= c0-1.
  L' = (L1+1, L2-1, L3) has 1 not in S(L'), meaning L1'-L3' = L1+1-L3 >= c0.
  Combined: L1-L3 = c0-1.
  
  Then phi(L) = (L1+1, L2, L3) and phi(L') = (L1+1, L2, L3). 
  But L' = (L1+1, L2-1, L3), so phi(L') = (L1+1, (L2-1)+1, L3) = (L1+1, L2, L3).
  YES, phi(L) = phi(L'). So the injection IS NOT injective with this rule!
""")

# So the min-index priority injection is NOT injective. 
# We need a smarter construction.

# Let me try: add 1 to the coordinate with the MOST slack.
# Define slack_i = c_i - (L_{i+1} - L_i) where indices are cyclic.
# Wait, the constraints are:
#   L2 - L1 <= c1 => slack1 = c1 - (L2-L1) >= 0
#   L3 - L2 <= c2 => slack2 = c2 - (L3-L2) >= 0
#   L1 - L3 <= c0 => slack0 = c0 - (L1-L3) >= 0

# i in S iff:
#   i=1: slack0 > 0 (incrementing L1 decreases slack0 by 1, needs slack0 >= 1)
#   i=2: slack1 > 0 (incrementing L2 decreases slack1 by 1)
#   i=3: slack2 > 0 (incrementing L3 decreases slack2 by 1)

# So S(L) = {indices with positive slack on their "incoming" constraint}.

# A natural injection: add 1 to the index with MAXIMUM incoming slack.
# If ties, break by... some consistent rule.

def test_maxslack_injection(c0, c1, c2, max_w=30):
    """Test injection that increments the coordinate with maximum slack."""
    d = c0 + c1 + c2
    
    all_ok = True
    for w in range(1, max_w+1):
        pts_prev = []
        for L1 in range(w):
            for L2 in range(w-L1):
                L3 = w - 1 - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    pts_prev.append((L1, L2, L3))
        
        pts_curr = set()
        for L1 in range(w+1):
            for L2 in range(w+1-L1):
                L3 = w - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    pts_curr.add((L1, L2, L3))
        
        images = {}
        for (L1, L2, L3) in pts_prev:
            slack0 = c0 - (L1 - L3)  # slack for incrementing L1
            slack1 = c1 - (L2 - L1)  # slack for incrementing L2
            slack2 = c2 - (L3 - L2)  # slack for incrementing L3
            
            slacks = [(slack0, 0), (slack1, 1), (slack2, 2)]
            # Sort by slack (descending), then by index (ascending) for tie-breaking
            slacks.sort(key=lambda x: (-x[0], x[1]))
            
            for s, i in slacks:
                if s > 0:
                    if i == 0:
                        img = (L1+1, L2, L3)
                    elif i == 1:
                        img = (L1, L2+1, L3)
                    else:
                        img = (L1, L2, L3+1)
                    break
            
            if img in images:
                if w <= 5 and d <= 5:
                    prev_pt = images[img]
                    # Don't spam output
                all_ok = False
            images[img] = (L1, L2, L3)
        
        if len(images) < len(pts_prev):
            pass  # collision found
    
    return all_ok

# Quick test
for (c0, c1, c2) in [(1,1,0), (2,1,1), (3,2,2)]:
    ok = test_maxslack_injection(c0, c1, c2, 20)
    print(f"c=({c0},{c1},{c2}): maxslack injection {'OK' if ok else 'COLLISIONS'}")

# Since simple injections have collisions, let me try Hall's theorem via 
# bipartite matching (max flow)
print("\n" + "=" * 60)
print("HALL'S THEOREM: Verify matching exists via max bipartite matching")
print("=" * 60)

def verify_matching(c0, c1, c2, max_w=30):
    """Verify that a perfect matching from P_{w-1} into P_w exists."""
    d = c0 + c1 + c2
    
    for w in range(1, max_w+1):
        pts_prev = []
        for L1 in range(w):
            for L2 in range(w-L1):
                L3 = w - 1 - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    pts_prev.append((L1, L2, L3))
        
        pts_curr = []
        for L1 in range(w+1):
            for L2 in range(w+1-L1):
                L3 = w - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    pts_curr.append((L1, L2, L3))
        
        if len(pts_curr) < len(pts_prev):
            print(f"  MONOTONICITY FAILS at w={w}: {len(pts_curr)} < {len(pts_prev)}")
            return False
        
        # Build bipartite graph: edge from p in P_{w-1} to q in P_w if q = p + e_i
        pts_curr_set = set(pts_curr)
        curr_idx = {p: i for i, p in enumerate(pts_curr)}
        
        # Use networkx-style matching via sage
        from sage.graphs.graph import Graph
        
        n1 = len(pts_prev)
        n2 = len(pts_curr)
        
        # Build bipartite graph with left vertices 0..n1-1, right vertices n1..n1+n2-1
        edges = []
        for i, (L1, L2, L3) in enumerate(pts_prev):
            for di in range(3):
                if di == 0:
                    q = (L1+1, L2, L3)
                elif di == 1:
                    q = (L1, L2+1, L3)
                else:
                    q = (L1, L2, L3+1)
                if q in pts_curr_set:
                    edges.append((i, n1 + curr_idx[q]))
        
        G = Graph(edges)
        matching = G.matching()
        
        if len(matching) < n1:
            print(f"  w={w}: matching size {len(matching)} < {n1} = |P_{w-1}|")
            return False
    
    return True

for (c0, c1, c2) in [(1,1,0), (2,0,0), (2,1,1), (3,1,0), (3,2,2), (4,2,1), (5,1,1)]:
    d = c0 + c1 + c2
    max_w_test = min(2*d + 5, 25)
    ok = verify_matching(c0, c1, c2, max_w_test)
    print(f"c=({c0},{c1},{c2}), d={d}: matching exists for all w=1..{max_w_test}: {'YES' if ok else 'NO'}")

