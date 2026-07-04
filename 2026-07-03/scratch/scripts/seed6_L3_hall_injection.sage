"""
Seed 6, Layer 3: Prove a_w >= a_{w-1} via Hall's marriage theorem.

For each point p in P_{w-1}, define the set N(p) of valid images in P_w:
  N(p) = {p + e_i : p + e_i in P_w} for i = 1, 2, 3

We showed that |N(p)| >= 1 always (since d > 0).

By Hall's marriage theorem, a perfect matching from P_{w-1} into P_w exists
iff for every subset S of P_{w-1}, |N(S)| >= |S|.

Alternative approach: use the fact that each point q in P_w has at most 3
preimages (q - e_1, q - e_2, q - e_3). Actually, we need to verify
that the bipartite graph has a perfect matching.

Actually, a much cleaner approach: prove the deficiency version.
Each point in P_w can be the image of at most 3 points from P_{w-1}.
If |P_w| >= |P_{w-1}|, that's what we need! And we know this from computation.

Wait -- that's circular. We need to PROVE |P_w| >= |P_{w-1}|.

Let me try a different angle: the DIRECT COUNTING argument.

The polytope P_w is defined by:
  L1 + L2 + L3 = w, L_i >= 0
  L2 - L1 <= c1, L3 - L2 <= c2, L1 - L3 <= c0

Change variables: x = L2 - L1, y = L3 - L2, z = L1 - L3.
Then x + y + z = 0 always, and the constraints are x <= c1, y <= c2, z <= c0.

But these are dependent: z = -x - y. So the constraint is:
  x <= c1, y <= c2, -x - y <= c0  =>  x + y >= -c0

With L1 = (w - x - 2y)/3 (from L1 + L2 + L3 = w, L2 = L1+x, L3 = L1+x+y).
Wait: L2 = L1 + x, L3 = L2 + y = L1 + x + y.
So w = L1 + (L1+x) + (L1+x+y) = 3L1 + 2x + y.
Hence L1 = (w - 2x - y)/3.

For this to be a non-negative integer:
  (i) w - 2x - y equiv 0 mod 3
  (ii) L1 = (w - 2x - y)/3 >= 0, i.e., 2x + y <= w
  (iii) L2 = L1 + x = (w + x - y)/3 >= 0, i.e., x - y >= -w (always)
  (iv) L3 = L1 + x + y = (w - 2x - y)/3 + x + y = (w + x + 2y)/3 >= 0, i.e., x + 2y >= -w (always)

So the count a_w = #{(x, y) in Z^2 : x <= c1, y <= c2, x+y >= -c0, 2x+y <= w, w-2x-y equiv 0 mod 3}

(excluding (0,0,0) when w=0, but that's the a_0 case)

The constraint w - 2x - y equiv 0 mod 3 means x + y equiv w mod 3 (since -2 equiv 1 mod 3... wait: 
w - 2x - y equiv 0 mod 3 => w equiv 2x + y mod 3).

Let me just use the (x,y) parameterization and count lattice points.
"""

from sage.all import *

def count_xy(c0, c1, c2, w):
    """Count using (x,y) coordinates where x = L2-L1, y = L3-L2."""
    count = 0
    for x in range(-c0 - c2, c1 + 1):  # x <= c1 and x >= -(c0+y) for some valid y
        for y in range(-c0 - x, c2 + 1):  # y <= c2 and x+y >= -c0
            if x + y < -c0:
                continue
            if (w - 2*x - y) % 3 != 0:
                continue
            L1 = (w - 2*x - y) // 3
            if L1 < 0:
                continue
            if 2*x + y > w:
                continue
            count += 1
    return count

# Verify this matches the direct count
def count_direct(c0, c1, c2, w):
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    return count

# Quick check
for d in [4, 7]:
    c0, c1, c2 = d//2, (d-d//2)//2, d - d//2 - (d-d//2)//2
    for w in range(15):
        a = count_xy(c0, c1, c2, w)
        b = count_direct(c0, c1, c2, w)
        assert a == b, f"Mismatch at w={w}: {a} vs {b}"
    print(f"d={d}, c=({c0},{c1},{c2}): xy-count matches direct count for w=0..14")

# =========================================================
# THE FORMAL COUNTING ARGUMENT
# =========================================================

print("\n" + "=" * 60)
print("FORMAL COUNTING ARGUMENT FOR MONOTONICITY")
print("=" * 60)
print()

print("""
THEOREM: For any composition c = (c0, c1, c2) with d = c0+c1+c2 >= 1,
the sequence a_w = |P_w| is weakly monotonically increasing.

PROOF:

Change variables: x = L2 - L1, y = L3 - L2. Then z := L1 - L3 = -x - y.

The constraints become:
  (C1) x <= c1
  (C2) y <= c2
  (C3) x + y >= -c0  (equivalently, z = -x-y <= c0)
  (C4) L1 = (w - 2x - y)/3 >= 0, i.e., 2x + y <= w
  (C5) w - 2x - y ≡ 0 mod 3

The region in the (x,y) plane satisfying (C1)-(C3) is a FIXED triangle T 
(independent of w):
  T = {(x,y) : x <= c1, y <= c2, x + y >= -c0}

The constraint (C4) says 2x + y <= w, which is a half-plane that moves 
outward as w increases.

The constraint (C5) is a mod-3 congruence: 2x + y ≡ w mod 3.

As w increases by 1:
  - The half-plane (C4) moves outward (more points become eligible)
  - The congruence class shifts by 1 (different lattice points selected)

For w large enough that (C4) doesn't cut T, the count is constant = |T ∩ Z^2 ∩ {2x+y ≡ w mod 3}|.

KEY OBSERVATION: The triangle T has vertices:
  V1 = (c1, c2) [constraints C1, C2 active]
  V2 = (c1, -c0-c1) [constraints C1, C3 active]  
  V3 = (-c0-c2, c2) [constraints C2, C3 active]

Wait, these are intersections of boundary lines:
  x = c1, y = c2: V1 = (c1, c2)
  x = c1, x+y = -c0: y = -c0-c1, so V2 = (c1, -c0-c1)
  y = c2, x+y = -c0: x = -c0-c2, so V3 = (-c0-c2, c2)

The values of 2x+y at these vertices:
  V1: 2c1 + c2
  V2: 2c1 + (-c0-c1) = c1 - c0
  V3: 2(-c0-c2) + c2 = -2c0 - c2

The half-plane 2x + y <= w first includes V3 when w = -2c0 - c2 (always included).
V2 is included when w >= c1 - c0 (need w >= max(0, c1-c0)).
V1 is included when w >= 2c1 + c2.

The "critical" vertex where (C4) last binds is at the maximum of 2x+y over T,
which is at V1 = (c1, c2) with value 2c1 + c2 = d + c1 - c0.

So for w >= 2c1 + c2, constraint (C4) does not cut T, and the count stabilizes.

Similarly, checking all permutations (since the profile is not symmetric),
the stabilization threshold is max(2c1+c2, ...) but we need to check which
vertex has the maximum of 2x+y.

Actually, let me verify the stabilization threshold formula.
""")

print("\n--- Verifying stabilization threshold ---")
for d in [2, 4, 5, 7, 8, 10, 11]:
    if d % 3 == 0:
        continue
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 > c1 or c1 > c2:
                continue  # skip non-canonical (reversed order)
            
            # The maximum of 2x+y over T is at (c1, c2), value 2c1+c2
            threshold = 2*c1 + c2
            
            stable_val = (d+1)*(d+2)//6
            counts = [count_direct(c0, c1, c2, w) for w in range(threshold + 5)]
            
            actual_stable = None
            for w in range(len(counts)):
                if counts[w] == stable_val:
                    actual_stable = w
                    break
            
            # Check: for w >= threshold, count should be stable
            all_stable = all(counts[w] == stable_val for w in range(threshold, len(counts)))
            
            status = "OK" if all_stable else "FAIL"
            if not all_stable or actual_stable != threshold:
                print(f"  c=({c0},{c1},{c2}): threshold={threshold}, actual_stable={actual_stable}, {status}")
                if actual_stable and actual_stable < threshold:
                    print(f"    (stabilizes EARLIER than predicted)")

print("\nHmm, the threshold depends on which vertex maximizes 2x+y.")
print("The three vertices of T are:")
print("  V1 = (c1, c2): 2x+y = 2c1+c2 = d+c1-c0")
print("  V2 = (c1, -c0-c1): 2x+y = c1-c0")
print("  V3 = (-c0-c2, c2): 2x+y = -2c0-c2 = -(d+c0-c1)")
print()
print("Maximum is at V1 = (c1, c2), with value 2c1+c2 = d+c1-c0.")
print("But we also need L1 >= 0 for ALL (x,y) in T with 2x+y <= w.")
print("The constraint L1 >= 0 is 2x+y <= w, which is most restrictive at V1.")
print()
print("BUT: the congruence condition means not all points in T are counted.")
print("The count at stabilization = (d+1)(d+2)/6 = |T cap Z^2| / 3")
print("(one third of the integer points in T, selected by the congruence).")

# Now compute |T cap Z^2| for comparison
print("\n--- |T cap Z^2| vs 3 * stable_value ---")
for d in [2, 4, 5, 7, 8]:
    if d % 3 == 0:
        continue
    c0, c1, c2 = sorted([d//3, d//3, d - 2*(d//3)], reverse=True)
    
    # Count all integer points in T
    T_count = 0
    for x in range(-c0-c2, c1+1):
        for y in range(-c0-c2, c2+1):
            if x <= c1 and y <= c2 and x + y >= -c0:
                T_count += 1
    
    stable = (d+1)*(d+2)//6
    print(f"  d={d}, c=({c0},{c1},{c2}): |T cap Z^2| = {T_count}, 3*stable = {3*stable}, ratio = {T_count/stable:.2f}")

# The ratio is 3 when gcd(d, 3) = 1, because the congruence x + y ≡ w mod 3
# picks out exactly 1/3 of the lattice points. When 3 | d, it might be different.

# =========================================================
# PROOF VIA MONOTONE LATTICE FUNCTION
# =========================================================

print("\n" + "=" * 60)
print("PROOF STRATEGY: Layer-by-layer growth")
print("=" * 60)

print("""
CLEAN PROOF via counting layers:

Fix (x,y) in T (i.e., x <= c1, y <= c2, x+y >= -c0).
This point contributes to a_w iff:
  (i) 2x + y <= w  (L1 >= 0)
  (ii) w ≡ 2x + y mod 3

For each fixed (x,y), let f(x,y) = 2x + y. Then (x,y) enters the count
at w = f(x,y) (if f(x,y) mod 3 matches), and stays forever after 
(at w = f(x,y), f(x,y)+3, f(x,y)+6, ...).

So a_w = #{(x,y) in T ∩ Z^2 : f(x,y) <= w AND f(x,y) ≡ w mod 3}.

Equivalently, a_w = #{(x,y) in T ∩ Z^2 : f(x,y) <= w, f(x,y) ≡ w mod 3}.

Now consider a_w vs a_{w-1}:
  a_w counts points with f(x,y) <= w AND f(x,y) ≡ w mod 3.
  a_{w-1} counts points with f(x,y) <= w-1 AND f(x,y) ≡ w-1 mod 3.

These are counts on DIFFERENT congruence classes!
  a_w picks f(x,y) ≡ w mod 3
  a_{w-1} picks f(x,y) ≡ w-1 mod 3

The new points in a_w (compared to a_{w-3}!) are those with f(x,y) = w-2 or w-1 or w.
But since we compare a_w with a_{w-1} (different congruence), the argument is subtler.

Let me think differently. Group by congruence class r = 0, 1, 2 mod 3.
Let b_r(w) = #{(x,y) in T ∩ Z^2 : f(x,y) ≡ r mod 3, f(x,y) <= w}.

Then a_w = b_{w mod 3}(w).

b_r(w) is non-decreasing in w (we only add points as w grows).
Moreover, b_r(w) = b_r(w-1) + #{(x,y) : f(x,y) = w, f(x,y) ≡ r mod 3}.
                  = b_r(w-1) + (1 if w ≡ r mod 3 else 0) * #{(x,y) : f(x,y) = w}.

So b_r increases by the number of points on the level set f(x,y) = w when w ≡ r,
and stays the same otherwise.

Then a_w - a_{w-1} = b_{w mod 3}(w) - b_{(w-1) mod 3}(w-1).

Since b_r(w) = b_r(w-1) when w ≢ r mod 3, and b_r(w) = b_r(w-1) + N_w when w ≡ r:

Case 1: w ≡ 0 mod 3. Then a_w = b_0(w) = b_0(w-1) + N_w.
         a_{w-1} = b_2(w-1) = b_2(w-2) (since w-1 ≢ 2 mod 3 when w ≡ 0... wait, w-1 ≡ 2 mod 3!)
         So a_{w-1} = b_2(w-1) = b_2(w-2) + N_{w-1}.
         
Hmm, this is getting complicated. Let me just verify numerically whether
a_w >= a_{w-1} for ALL profiles and ALL w, using the clean counting formula.
""")

# EXHAUSTIVE VERIFICATION for all d up to 20
print("\n--- Exhaustive monotonicity check for d up to 20 ---")
total_profiles = 0
total_failures = 0
for d in range(1, 21):
    failures_at_d = 0
    profiles_at_d = 0
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            profiles_at_d += 1
            max_w = 2*d + 10
            prev = count_direct(c0, c1, c2, 0)
            for w in range(1, max_w+1):
                curr = count_direct(c0, c1, c2, w)
                if curr < prev:
                    failures_at_d += 1
                    if d <= 10:
                        print(f"  FAIL: d={d}, c=({c0},{c1},{c2}), a_{w} = {curr} < a_{w-1} = {prev}")
                    break
                prev = curr
    
    total_profiles += profiles_at_d
    total_failures += failures_at_d
    if failures_at_d == 0:
        print(f"  d={d}: ALL {profiles_at_d} profiles monotone (including d%3=={d%3})")

print(f"\nTotal: {total_profiles} profiles tested, {total_failures} failures")

# a_1 >= 1 check
print("\n--- a_1 values ---")
for d in range(1, 21):
    min_a1 = None
    min_profile = None
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            a1 = count_direct(c0, c1, c2, 1)
            if min_a1 is None or a1 < min_a1:
                min_a1 = a1
                min_profile = (c0, c1, c2)
    print(f"  d={d}: min a_1 = {min_a1} at c={min_profile}")

