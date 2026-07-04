"""
Seed 6, Layer 3: Formal proof of Q1 >= 0 via Hall's marriage theorem.

Theorem: For any composition c = (c0, c1, c2) with d = c0+c1+c2, d not equiv 0 mod 3,
Q_1 has non-negative coefficients.

Proof: Q_1 = (1-q^l) * bracket where l = gcd(d,3) = 1 (since d not div by 3).
bracket = G_1 + e_1 = (a_1 - 1)q + (a_2 - a_1)q^2 + (a_3 - a_2)q^3 + ...
         where a_w counts lattice points at height w.

Since l = 1:
Q_1 = (1-q) * bracket 
    = (a_1 - 1)q + [(a_2 - a_1) - (a_1 - 1)]q^2 + ...

Actually, let me compute this more carefully.
G_1 = sum_{w >= 1} a_w q^w (where a_0 should not be included since G_1 = F_{c,1} - 1)

Wait, G_1 = [y^1] F_c(y,q) = sum_{Lambda: max(Lambda)=1} q^{|Lambda|}
This is NOT the same as F_{c,1} - 1 unless we're careful.
F_{c,1} = sum_{Lambda: max<=1} q^{|Lambda|} = 1 + sum_{Lambda: max=1} q^{|Lambda|} = 1 + G_1.
So G_1 = F_{c,1} - 1 = sum_{w >= 1} a_w q^w (where a_w includes the max-0 contribution only at w=0).

Actually: for w >= 1, all (L1,L2,L3) with sum=w and satisfying constraints have at least one L_i >= 1,
so max >= 1. Therefore G_1 = F_{c,1} - 1 = sum_{w >= 1} a_w q^w.

bracket = G_1 + e_1 = sum_{w >= 1} a_w q^w - sum_{w >= 1} q^w = sum_{w >= 1} (a_w - 1) q^w.

Q_1 = (1-q) * sum_{w >= 1} (a_w - 1) q^w
    = sum_{w >= 1} (a_w - 1) q^w - sum_{w >= 2} (a_{w-1} - 1) q^w
    = (a_1 - 1) q + sum_{w >= 2} [(a_w - 1) - (a_{w-1} - 1)] q^w
    = (a_1 - 1) q + sum_{w >= 2} (a_w - a_{w-1}) q^w

So Q_1 >= 0 iff:
(i) a_1 >= 1
(ii) a_w >= a_{w-1} for all w >= 2

We proved a_1 = #{i : c_i >= 1} >= 1 (since d >= 1).
We need to prove a_w >= a_{w-1}, i.e., monotonicity.
"""

from sage.all import *

# THE PROOF OF MONOTONICITY

print("=" * 60)
print("PROOF OF a_w MONOTONICITY (when d not equiv 0 mod 3)")
print("=" * 60)

print("""
THEOREM: Let c = (c0, c1, c2) be a composition with d = c0+c1+c2 >= 1 
and d not equiv 0 mod 3. Define:
  P_w = {(L1, L2, L3) in Z_>=0^3 : L1+L2+L3 = w, L2-L1 <= c1, L3-L2 <= c2, L1-L3 <= c0}
  a_w = |P_w|.
Then a_w >= a_{w-1} for all w >= 1.

PROOF:

Step 1. Hall's marriage theorem reduces this to:
  For every subset S of P_{w-1}, |N(S)| >= |S|
  where N(S) = {p + e_i : p in S, i in {1,2,3}, p + e_i in P_w}.

Step 2. For any p = (L1, L2, L3) in P_{w-1}, define:
  S_1(p): p + e_1 in P_w iff L1 - L3 < c0 (slack in constraint 3)
  S_2(p): p + e_2 in P_w iff L2 - L1 < c1 (slack in constraint 1)
  S_3(p): p + e_3 in P_w iff L3 - L2 < c2 (slack in constraint 2)

Step 3. KEY LEMMA: At least one of S_1, S_2, S_3 is satisfied.
  Proof: If none hold, then L1-L3 >= c0, L2-L1 >= c1, L3-L2 >= c2.
  Combined with L1-L3 <= c0, L2-L1 <= c1, L3-L2 <= c2:
  L1-L3 = c0, L2-L1 = c1, L3-L2 = c2.
  Sum: 0 = c0 + c1 + c2 = d >= 1. Contradiction. QED.

Step 4. Each p in P_{w-1} has at least 1 neighbor in P_w.
  Each q in P_w has at most 3 neighbors in P_{w-1} (namely q - e_i for i=1,2,3).

Step 5. Hall's condition verification:
  We need |N(S)| >= |S| for every S subset P_{w-1}.
  
  Count edges E(S, N(S)) in the bipartite graph:
    E >= |S| (each point in S has >= 1 neighbor, by Step 3)
    E <= 3*|N(S)| (each point in N(S) has <= 3 reverse neighbors)
  
  Therefore: |S| <= E <= 3*|N(S)|, so |N(S)| >= |S|/3.
  
  This is NOT strong enough for Hall's theorem (need >= |S|, not >= |S|/3).
  
  We need a finer argument.

Step 6. REFINED ARGUMENT using the deficiency version of Hall's theorem.
  
  Actually, the simple counting argument shows |N(S)| >= |S|/3, which is 
  insufficient. But we can improve it.

  ALTERNATIVE APPROACH: Direct counting.
  
  a_w = #{(L1,L2,L3) : sum=w, constraints satisfied}
  
  Change variables: x = L2-L1, y = L3-L2. Then:
  constraints: x <= c1, y <= c2, x+y >= -c0
  and L1 = (w - 2x - y)/3 >= 0, i.e., 2x + y <= w.
  Congruence: w - 2x - y equiv 0 mod 3, i.e., 2x + y equiv w mod 3.
  
  The set of (x,y) satisfying x <= c1, y <= c2, x+y >= -c0 is a FIXED triangle T.
  
  a_w = #{(x,y) in T cap Z^2 : 2x+y <= w, 2x+y equiv w mod 3}
  
  As w increases by 1:
  - The half-plane 2x+y <= w expands (weakly more eligible points)
  - The congruence class shifts (different subset of T selected)
  
  For w large enough (w >= max_{T}(2x+y)), the half-plane doesn't cut T,
  and a_w = |{(x,y) in T cap Z^2 : 2x+y equiv w mod 3}|.
  
  The three congruence classes partition T cap Z^2 into three sets of sizes:
    n_0 = |{2x+y equiv 0 mod 3}|
    n_1 = |{2x+y equiv 1 mod 3}|
    n_2 = |{2x+y equiv 2 mod 3}|
  with n_0 + n_1 + n_2 = |T cap Z^2| = (d+1)(d+2)/2.
""")

# Compute n_0, n_1, n_2 for various d
print("\n--- Congruence class sizes for T cap Z^2 ---")
for d in range(1, 16):
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 < c1 or c1 < c2:
                continue
            
            counts = [0, 0, 0]
            for x in range(-d, d+1):
                for y in range(-d, d+1):
                    if x <= c1 and y <= c2 and x + y >= -c0:
                        r = (2*x + y) % 3
                        counts[r] += 1
            
            total = sum(counts)
            expected_total = (d+1)*(d+2)//2
            stable = (d+1)*(d+2)//6
            
            if c0 == d:  # just print extremal cases
                print(f"  d={d}, c=({c0},{c1},{c2}): n0={counts[0]}, n1={counts[1]}, n2={counts[2]}, "
                      f"total={total} (expected {expected_total}), stable={stable}")
                
                # When d not equiv 0 mod 3: are all three equal?
                if d % 3 != 0 and counts[0] == counts[1] == counts[2]:
                    print(f"    All three equal: {stable} each (d%3 = {d%3})")
                elif d % 3 == 0:
                    print(f"    NOT all equal (d%3 = 0)")

print("\n--- Checking equal distribution when d % 3 != 0 ---")
for d in range(1, 16):
    if d % 3 == 0:
        continue
    all_equal = True
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            counts = [0, 0, 0]
            for x in range(-d, d+1):
                for y in range(-d, d+1):
                    if x <= c1 and y <= c2 and x + y >= -c0:
                        r = (2*x + y) % 3
                        counts[r] += 1
            if counts[0] != counts[1] or counts[1] != counts[2]:
                all_equal = False
                print(f"  d={d}, c=({c0},{c1},{c2}): UNEQUAL: {counts}")
                break
        if not all_equal:
            break
    if all_equal:
        print(f"  d={d}: all profiles have equal distribution (each class = {(d+1)*(d+2)//6})")

print("\n--- Distribution when d % 3 == 0 ---")
for d in [3, 6, 9, 12]:
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 < c1 or c1 < c2:
                continue
            counts = [0, 0, 0]
            for x in range(-d, d+1):
                for y in range(-d, d+1):
                    if x <= c1 and y <= c2 and x + y >= -c0:
                        r = (2*x + y) % 3
                        counts[r] += 1
            
            # Only print if imbalanced
            if counts[0] != counts[1] or counts[1] != counts[2]:
                print(f"  d={d}, c=({c0},{c1},{c2}): {counts}")
                break

