"""
Seed 4, Layer 3: Understand why g_1 is monotonically increasing when d ≢ 0 mod 3.

g_1(q) = sum_{w>=0} a_w q^w where a_w = #{(a0,a1,a2) : a_i >= 0, sum = w, 
                                          a_{i+1} <= a_i + c_{i+1} cyclically}

h_1 = (1-q) * g_1 = sum (a_w - a_{w-1}) q^w.
So h_1 >= 0 iff a_w >= a_{w-1} for all w (monotonicity of g_1 coefficients).

The KEY observation from the d=9 computation: g_1 is NOT monotone when d ≡ 0 mod 3.
For d=9, c=(3,3,3): coefficients oscillate between 18 and 19 with period 3.

For d=7, c=(3,2,2): coefficients stabilize to 12 = (d+1)(d+2)/6.
Let's understand the approach to the limit and why it's monotone.
"""

def count_g1(c, w):
    """Count #{(a0,a1,a2) : sum=w, a_{i+1} <= a_i + c_{i+1} cyclically}"""
    c0, c1, c2 = c
    count = 0
    for a0 in range(w + 1):
        for a1 in range(w - a0 + 1):
            a2 = w - a0 - a1
            if a1 <= a0 + c1 and a2 <= a1 + c2 and a0 <= a2 + c0:
                count += 1
    return count

# Detailed study for d=7
print("d=7, t=10, stable value should be (8*9)/6 = 12")
for c in [(3,2,2), (4,2,1), (1,3,3)]:
    print(f"\nc={c}, d={sum(c)}, t={sum(c)+3}")
    vals = [count_g1(c, w) for w in range(30)]
    print(f"  g_1 coefficients: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  Differences: {diffs}")
    
    # Check what period the sequence has
    # For profile (c0,c1,c2), the constraint polytope has volume related to d
    # The Ehrhart function stabilizes when all constraints are non-binding
    # The first non-monotone point tells us when the polytope boundary matters
    
    # What w_0 does it take for g_1(w) = g_1(w-1)?
    for w in range(1, 30):
        if vals[w] == vals[w-1]:
            break
    else:
        w = None
    if w:
        print(f"  First w where g_1(w) = g_1(w-1): w={w}, value={vals[w]}")
    else:
        print(f"  g_1 is strictly increasing throughout!")

# Same for d=4
print("\n" + "="*60)
print("d=4, stable value = (5*6)/6 = 5")
for c in [(2,1,1), (1,2,1), (3,1,0)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(20)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")

# d=5
print("\n" + "="*60)
print("d=5, stable value = (6*7)/6 = 7")
for c in [(2,2,1), (3,1,1), (4,1,0)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(20)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")

# d=8
print("\n" + "="*60)
print("d=8, stable value = (9*10)/6 = 15")
for c in [(3,3,2), (4,3,1), (5,2,1)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(25)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")

# d=9 (mod 3 = 0)
print("\n" + "="*60)
print("d=9 (d ≡ 0 mod 3!), expected stable = 55/3 ≈ 18.33 (NOT INTEGER!)")
for c in [(3,3,3), (4,3,2), (5,2,2)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(30)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")
    
    # Check if it has period 3
    for w in range(20, 30):
        print(f"    w={w}: a_w={vals[w]}, mod 3: w%3={w%3}")

# d=3 (smallest mod 3 = 0)
print("\n" + "="*60)
print("d=3, stable = (4*5)/6 = 10/3 ≈ 3.33 (NOT INTEGER)")
for c in [(1,1,1), (2,1,0)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(20)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")

# d=6 (mod 3 = 0)
print("\n" + "="*60)
print("d=6, stable = (7*8)/6 = 56/6 ≈ 9.33 (NOT INTEGER)")
for c in [(2,2,2), (3,2,1)]:
    print(f"\nc={c}")
    vals = [count_g1(c, w) for w in range(25)]
    print(f"  g_1: {vals}")
    diffs = [vals[w] - vals[w-1] for w in range(1, len(vals))]
    print(f"  diffs: {diffs}")

