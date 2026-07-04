"""
Seed 4, Layer 2: Corteel-Welsh recurrence system for d=7 (modulus 10).
Enumerates profile transition graph and reachability.
"""
from collections import defaultdict
from itertools import combinations

def all_profiles(d, k=3):
    if k == 1:
        return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c)
    J_set = set(J)
    c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set:
            c_new[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_new[i] += 1
    return tuple(c_new)

def I_c(c):
    return [i for i in range(len(c)) if c[i] > 0]

def canonical_profile(c):
    k = len(c)
    variants = []
    for start in range(k):
        rotated = tuple(c[(start + i) % k] for i in range(k))
        variants.append(rotated)
        reversed_rot = tuple(rotated[k - 1 - i] for i in range(k))
        variants.append(reversed_rot)
    return min(variants)

def enumerate_cw_transitions(d, k=3):
    profiles = all_profiles(d, k)
    transitions = {}
    for c in profiles:
        ic = I_c(c)
        if not ic:
            transitions[c] = []
            continue
        trans = []
        for size in range(1, len(ic) + 1):
            for J in combinations(ic, size):
                sign = (-1) ** (size - 1)
                cJ = shifted_profile(c, J)
                if any(x < 0 for x in cJ):
                    continue
                trans.append((sign, size, cJ))
        transitions[c] = trans
    return transitions

print("=" * 70)
print("PROFILES FOR d=7, k=3")
print("=" * 70)

profiles_d7 = all_profiles(7, 3)
print(f"Total profiles: {len(profiles_d7)}")

canon_groups = defaultdict(list)
for c in profiles_d7:
    canon_groups[canonical_profile(c)].append(c)

print(f"Distinct profiles (up to D_3): {len(canon_groups)}")
for canon, members in sorted(canon_groups.items()):
    print(f"  {canon}: {len(members)} members -> {members}")

transitions = enumerate_cw_transitions(7, 3)

print("\n" + "=" * 70)
print("CW TRANSITION GRAPH")
print("=" * 70)

for canon in sorted(canon_groups.keys()):
    c = canon
    trans = transitions[c]
    print(f"\nProfile {c}:")
    print(f"  I_c = {I_c(c)}")
    for sign, size, cJ in trans:
        print(f"  J size {size}, sign {'+' if sign > 0 else '-'}, c(J) = {cJ} (canon: {canonical_profile(cJ)})")

print("\n" + "=" * 70)
print("REACHABILITY FROM (3,2,2)")
print("=" * 70)

start = (3, 2, 2)
visited = set()
queue = [start]
visited.add(start)
while queue:
    c = queue.pop(0)
    for sign, size, cJ in transitions.get(c, []):
        if cJ not in visited:
            visited.add(cJ)
            queue.append(cJ)

print(f"Profiles reachable from {start}: {len(visited)}")
for c in sorted(visited):
    print(f"  {c} (canon: {canonical_profile(c)})")

canon_classes = set(canonical_profile(c) for c in visited)
print(f"\nCanonical classes involved: {len(canon_classes)}")
for cc in sorted(canon_classes):
    print(f"  {cc}")

print("\n" + "=" * 70)
print("REACHABILITY FROM (4,2,1)")
print("=" * 70)

start2 = (4, 2, 1)
visited2 = set()
queue2 = [start2]
visited2.add(start2)
while queue2:
    c = queue2.pop(0)
    for sign, size, cJ in transitions.get(c, []):
        if cJ not in visited2:
            visited2.add(cJ)
            queue2.append(cJ)

print(f"Profiles reachable from {start2}: {len(visited2)}")
canon_classes2 = set(canonical_profile(c) for c in visited2)
print(f"Canonical classes: {len(canon_classes2)}")
print(f"\nSame reachability set? {visited == visited2}")
print(f"Union size: {len(visited | visited2)}")
print(f"\nIs (0,0,0) reachable? {(0,0,0) in visited}")
