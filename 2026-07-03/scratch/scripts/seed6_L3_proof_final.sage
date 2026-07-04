"""
Seed 6, Layer 3: FINAL VERIFICATION - equal-distribution lemma and Q1 for all d=2 profiles.
"""

from sage.all import *

# PART 1: Equal-distribution lemma
print("=" * 60)
print("EQUAL-DISTRIBUTION LEMMA VERIFICATION")
print("=" * 60)

def count_congruence_classes(c0, c1, c2):
    d = c0 + c1 + c2
    counts = [0, 0, 0]
    for x in range(-d, d+1):
        for y in range(-d, d+1):
            if x <= c1 and y <= c2 and x + y >= -c0:
                r = (2*x + y) % 3
                counts[r] += 1
    return counts

for d in range(1, 21):
    if d % 3 == 0:
        continue
    all_equal = True
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            counts = count_congruence_classes(c0, c1, c2)
            if counts[0] != counts[1] or counts[1] != counts[2]:
                all_equal = False
                break
        if not all_equal:
            break
    if all_equal:
        stable = (d+1)*(d+2)//6
        print(f"  d={d}: ALL profiles equal (each class = {stable})")
    else:
        print(f"  d={d}: FAIL!")

# PART 2: Q_1 for ALL d=2 profiles
print("\n" + "=" * 60)
print("Q_1 FOR ALL d=2 PROFILES (checking c=(2,0,0) issue)")
print("=" * 60)

R = PowerSeriesRing(QQ, 'q', default_prec=15)
q = R.gen()

for c0 in range(3):
    for c1 in range(3-c0):
        c2 = 2 - c0 - c1
        F1 = R(0)
        for w in range(15):
            count = 0
            for L1 in range(w+1):
                for L2 in range(w+1-L1):
                    L3 = w - L1 - L2
                    if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                        count += 1
            F1 += count * q**w
        G1 = F1 - 1
        e1 = sum(-q**(j+1) for j in range(14))
        bracket = G1 + e1
        Q1 = ((1 - q) * bracket).add_bigoh(15)
        neg = [i for i in range(15) if Q1[i] < 0]
        print(f"  c=({c0},{c1},{c2}): Q_1 = {Q1}, neg at: {neg}")

# PART 3: Layer-by-layer analysis for d=7
print("\n" + "=" * 60)
print("LAYER-BY-LAYER for d=7, c=(3,2,2)")
print("=" * 60)

c0, c1, c2 = 3, 2, 2
d = c0 + c1 + c2

levels = {}
for x in range(-d, d+1):
    for y in range(-d, d+1):
        if x <= c1 and y <= c2 and x + y >= -c0:
            f = 2*x + y
            r = f % 3
            if f not in levels:
                levels[f] = [0, 0, 0]
            levels[f][r] += 1

for f in sorted(levels.keys()):
    total = sum(levels[f])
    print(f"  f = {f:3d}: class 0: {levels[f][0]}, class 1: {levels[f][1]}, class 2: {levels[f][2]}, total: {total}")

# Cumulative: a_w = sum of levels[f][w%3] for f <= w with f equiv w mod 3
print("\n  Cumulative counts (= a_w):")
def count_at_height(c0, c1, c2, w):
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                count += 1
    return count

stable = (d+1)*(d+2)//6
for w in range(15):
    aw = count_at_height(c0, c1, c2, w)
    print(f"  a_{w:2d} = {aw:3d} (class {w%3}), delta = {'+' if w == 0 else ''}{aw - count_at_height(c0,c1,c2,w-1) if w > 0 else aw}")

# PART 4: Prove the equal-distribution lemma algebraically
print("\n" + "=" * 60)
print("ALGEBRAIC PROOF OF EQUAL-DISTRIBUTION")
print("=" * 60)

print("""
LEMMA: For d not equiv 0 mod 3 and any c = (c0,c1,c2) with sum = d,
  |{(x,y) in T : 2x+y equiv r mod 3}| = (d+1)(d+2)/6
for all r = 0,1,2.

PROOF: 
T = {(x,y) in Z^2 : x <= c1, y <= c2, x+y >= -c0}.
|T| = (d+1)(d+2)/2 (number of compositions of d into 3 nonneg parts).

The map (x,y) -> (x-1, y+2) shifts 2x+y by 2(-1)+2 = 0 mod 3.
  But this doesn't preserve T in general.

The map (x,y) -> (x+1, y-1) shifts 2x+y by 2(1)+(-1) = 1 mod 3.
  If this preserves T, then it cyclically permutes the 3 classes.
  But it doesn't preserve T (x <= c1 may fail after incrementing).

Alternative: use the C3 symmetry of the problem.
  The composition c = (c0,c1,c2) defines T via x <= c1, y <= c2, x+y >= -c0.
  The cyclic shift (c0,c1,c2) -> (c1,c2,c0) permutes the triangle.
  Under this shift, the congruence classes also rotate (since the 
  coordinate transform is a Z/3 rotation).
  
Actually, let's use generating functions. The count n_r(c) is the 
number of (x,y) in T with 2x+y equiv r mod 3. 

Key: the sum sum_{r=0}^2 n_r omega^r = sum_{(x,y) in T} omega^{2x+y}
where omega = e^{2pi i/3} is a primitive cube root of unity.

This equals: sum_{x=-c0-c2}^{c1} sum_{y=max(-c0-x, -inf)}^{c2} omega^{2x+y}
where x ranges from -c0-c2 to c1 and y from max(-c0-x, ...) to c2.

If this sum = 0, then n_0 = n_1 = n_2 = |T|/3.

The character sum is: sum_{(x,y) in T} omega^{2x+y}.
This sum being 0 for d not equiv 0 mod 3 is the key fact.

When d equiv 0 mod 3, this sum is nonzero, explaining the imbalance.
""")

# Verify the character sum
omega = exp(2*pi*I/3)
for d in range(1, 16):
    for c0 in [d, d//2]:
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 < 0 or c1 < 0 or c2 < 0:
                continue
            char_sum = 0
            for x in range(-d, d+1):
                for y in range(-d, d+1):
                    if x <= c1 and y <= c2 and x + y >= -c0:
                        char_sum += omega**(2*x + y)
            # Should be 0 when d % 3 != 0
            if abs(char_sum) > 0.01:
                print(f"  d={d}, c=({c0},{c1},{c2}): char_sum = {complex(char_sum):.3f} (d%3={d%3})")
            break
        break
