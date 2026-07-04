"""
Seed 6, Layer 3: FORMAL PROOF of Q1 >= 0.

Strategy: 
1. Show a_w is monotonically increasing by proving a_w - a_{w-1} >= 0.
2. The key: for each (L1, L2, L3) counted in a_{w-1}, construct an injection 
   into tuples counted in a_w.
3. The injection: (L1, L2, L3) -> (L1+1, L2, L3) if this satisfies constraints,
   else (L1, L2+1, L3), else (L1, L2, L3+1).
   
Actually, a cleaner approach: define the MAP phi: P_{w-1} -> P_w by 
adding 1 to the coordinate that is "most constrained" or by a fixed rule.

Even cleaner: We can prove this using the LATTICE POINT INJECTION LEMMA.

For a polytope P_w defined by:
  L1 + L2 + L3 = w, L_i >= 0
  L2 - L1 <= c1, L3 - L2 <= c2, L1 - L3 <= c0

The map phi: P_{w-1} -> P_w defined by 
  phi(L1, L2, L3) = (L1+1, L2, L3) if L1+1-L3 <= c0 and L2-(L1+1) <= c1
  else phi(L1, L2, L3) = (L1, L2+1, L3) if L2+1-L1 <= c1 and L3-(L2+1) <= c2  
  else phi(L1, L2, L3) = (L1, L2, L3+1)

is well-defined and injective if at least one of the three options satisfies constraints.
"""

from sage.all import *

def count_at_height(c0, c1, c2, w):
    """Count lattice points at height w."""
    count = 0
    pts = []
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
                pts.append((L1, L2, L3))
    return count, pts

def verify_injection(c0, c1, c2, max_w=30):
    """
    Verify that the simple injection phi: P_{w-1} -> P_w works.
    
    The injection: for (L1, L2, L3) in P_{w-1}, try:
    1. (L1+1, L2, L3): requires L1+1-L3 <= c0 and L2-(L1+1) <= c1
       i.e., L1-L3 <= c0-1 and L2-L1 <= c1-1 (actually c1+1... wait)
       Actually: L2 - (L1+1) = (L2-L1) - 1 <= c1 iff L2-L1 <= c1+1 (always true since L2-L1 <= c1)
       And: (L1+1) - L3 <= c0 iff L1-L3 <= c0-1.
       So option 1 works iff L1 - L3 <= c0 - 1, i.e., L1 - L3 < c0.
    2. (L1, L2+1, L3): works iff L2 - L1 < c1 AND L3 - (L2+1) <= c2 iff L3-L2 <= c2+1 (always).
       Wait: (L2+1) - L1 <= c1 iff L2-L1 <= c1-1 iff L2-L1 < c1.
       And L3 - (L2+1) = L3-L2-1 <= c2 (always since L3-L2 <= c2).
       So option 2 works iff L2 - L1 < c1.
    3. (L1, L2, L3+1): works iff L3 - L2 < c2 AND L1 - (L3+1) <= c0 iff L1-L3 <= c0+1 (always).
       Wait: (L3+1) - L2 <= c2 iff L3-L2 <= c2-1 iff L3-L2 < c2.
       And L1 - (L3+1) = L1-L3-1 <= c0 (always since L1-L3 <= c0).
       So option 3 works iff L3 - L2 < c2.
    
    KEY CLAIM: At least one of {L1-L3 < c0, L2-L1 < c1, L3-L2 < c2} holds.
    
    Proof: If all three are tight, i.e., L1-L3 = c0, L2-L1 = c1, L3-L2 = c2, then
    summing: (L1-L3) + (L2-L1) + (L3-L2) = c0 + c1 + c2 = d.
    But (L1-L3) + (L2-L1) + (L3-L2) = 0. So d = 0. Contradiction (d >= 1).
    
    THEREFORE: the injection is ALWAYS well-defined!
    """
    print("=" * 60)
    print(f"INJECTION PROOF for c = ({c0},{c1},{c2}), d = {c0+c1+c2}")
    print("=" * 60)
    
    print()
    print("KEY LEMMA: For (L1,L2,L3) in P_w, at least one of:")
    print("  (a) L1 - L3 < c0")
    print("  (b) L2 - L1 < c1") 
    print("  (c) L3 - L2 < c2")
    print("holds.")
    print()
    print("Proof: If all are tight: L1-L3=c0, L2-L1=c1, L3-L2=c2.")
    print("Sum: 0 = c0+c1+c2 = d. But d >= 1. Contradiction. QED.")
    print()
    
    # Verify computationally that the injection works
    for w in range(1, max_w+1):
        _, pts_prev = count_at_height(c0, c1, c2, w-1)
        _, pts_curr = count_at_height(c0, c1, c2, w)
        pts_curr_set = set(pts_curr)
        
        images = set()
        for (L1, L2, L3) in pts_prev:
            # Try option 1: increment L1
            if L1 - L3 < c0:
                img = (L1+1, L2, L3)
            elif L2 - L1 < c1:
                img = (L1, L2+1, L3)
            elif L3 - L2 < c2:
                img = (L1, L2, L3+1)
            else:
                print(f"  ERROR at w={w}: no option for ({L1},{L2},{L3})")
                return False
            
            if img not in pts_curr_set:
                print(f"  ERROR at w={w}: image {img} not in P_{w}")
                return False
            
            if img in images:
                print(f"  ERROR at w={w}: collision! {img} already used")
                # This means the injection might not be injective with this priority
                # Let's check if a different priority works
                pass
            images.add(img)
        
        if len(images) < len(pts_prev):
            print(f"  w={w}: injection has collisions ({len(images)} images for {len(pts_prev)} points)")
            return False
    
    print(f"Injection verified for all w from 1 to {max_w}.")
    return True

# Wait, the injection might have collisions because different points
# could map to the same image. Let me check injectivity more carefully.

def verify_injection_v2(c0, c1, c2, max_w=30):
    """
    More careful injection: use priority (1,2,3) and check injectivity.
    
    Actually, injectivity is guaranteed because the map is:
    phi(L1,L2,L3) = (L1 + e_i) where i is the FIRST coordinate satisfying:
      i=1: L1-L3 < c0
      i=2: L2-L1 < c1
      i=3: L3-L2 < c2
    
    If phi(p) = phi(q) then p+e_i = q+e_j.
    If i=j then p=q.
    If i != j, then p_i = q_i + 1 and p_j = q_j - 1 and p_k = q_k (k != i,j).
    But then the priority condition fails: p chose i (not j), meaning 
    the earlier conditions were violated for p but not for q? 
    This needs careful checking.
    """
    print("=" * 60)
    print(f"INJECTION v2 for c = ({c0},{c1},{c2}), d = {c0+c1+c2}")
    print("=" * 60)
    
    all_ok = True
    for w in range(1, max_w+1):
        _, pts_prev = count_at_height(c0, c1, c2, w-1)
        _, pts_curr = count_at_height(c0, c1, c2, w)
        pts_curr_set = set(pts_curr)
        
        images = {}
        for (L1, L2, L3) in pts_prev:
            if L1 - L3 < c0:
                img = (L1+1, L2, L3)
                choice = 1
            elif L2 - L1 < c1:
                img = (L1, L2+1, L3)
                choice = 2
            elif L3 - L2 < c2:
                img = (L1, L2, L3+1)
                choice = 3
            else:
                print(f"  IMPOSSIBLE at w={w}: ({L1},{L2},{L3})")
                return False
            
            assert img in pts_curr_set, f"Image {img} not in P_{w}"
            
            if img in images:
                prev_pt, prev_choice = images[img]
                print(f"  COLLISION at w={w}: phi({prev_pt}) = phi({L1},{L2},{L3}) = {img}")
                print(f"    choices: {prev_choice} vs {choice}")
                all_ok = False
            else:
                images[img] = ((L1,L2,L3), choice)
    
    if all_ok:
        print(f"  Injection verified (no collisions) for w = 1..{max_w}")
    return all_ok

# Test on several profiles
for d in [2, 4, 5, 7, 8, 10, 11, 13, 14]:
    if d % 3 == 0:
        continue
    profiles = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 >= c1 >= c2:
                profiles.append((c0, c1, c2))
    
    for (c0, c1, c2) in profiles:
        if not verify_injection_v2(c0, c1, c2, max_w=max(2*d+5, 20)):
            print(f"  FAILED for c = ({c0},{c1},{c2})")
            break

# Now verify that a_1 >= 1 for all valid profiles
print("\n" + "=" * 60)
print("VERIFYING a_1 >= 1 for all profiles")
print("=" * 60)

for d in range(1, 20):
    if d % 3 == 0:
        continue
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            a1, _ = count_at_height(c0, c1, c2, 1)
            if a1 < 1:
                print(f"  FAIL: c=({c0},{c1},{c2}), d={d}, a_1 = {a1}")
    print(f"  d={d}: all a_1 >= 1 verified ({(d+1)*(d+2)//2} profiles)")

# Check a_1 values
print("\n--- a_1 values for d=7 canonical profiles ---")
for c0 in range(8):
    for c1 in range(8-c0):
        c2 = 7 - c0 - c1
        if c0 >= c1 >= c2:
            a1, pts = count_at_height(c0, c1, c2, 1)
            print(f"  c=({c0},{c1},{c2}): a_1 = {a1}, points = {pts}")

