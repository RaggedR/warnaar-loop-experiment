"""
Seed 8, Layer 3: Demazure character match with Q_{n,c}(q).
Uses BFS depth as grading. Compares Demazure subcrystal sizes and graded characters.
"""
from collections import deque

print("="*80)
print("Demazure character match: hat{sl}_3 level d vs Q_{n,c}(q)")
print("="*80)

ct = CartanType(['A', 2, 1])
P = RootSystem(ct).weight_space(extended=True)
Lambda = P.fundamental_weights()
alpha = P.simple_roots()

def compute_bfs(crystal, hw, max_depth=30):
    visited = {}
    queue = deque()
    queue.append((hw, 0))
    visited[hw] = 0
    depth_count = {0: 1}
    while queue:
        b, d = queue.popleft()
        if d >= max_depth:
            continue
        for i in [0, 1, 2]:
            b_next = b.f(i)
            if b_next is not None and b_next not in visited:
                visited[b_next] = d + 1
                depth_count[d + 1] = depth_count.get(d + 1, 0) + 1
                queue.append((b_next, d + 1))
    return depth_count, visited

def demazure_graded(crystal, hw, word, visited):
    D = crystal.demazure_subcrystal(hw, word)
    elts = list(D)
    grade_dist = {}
    unknown = 0
    for b in elts:
        if b in visited:
            g = visited[b]
            grade_dist[g] = grade_dist.get(g, 0) + 1
        else:
            unknown += 1
    return len(elts), grade_dist, unknown

# d=4, c=(2,1,1)
print("\n--- d=4, c=(2,1,1) ---")
lam = 2*Lambda[0] + Lambda[1] + Lambda[2]
C = crystals.LSPaths(lam)
hw = list(C.highest_weight_vectors())[0]
print(f"Lambda = {lam}, level = {lam.level()}")

print("Computing BFS...")
dc, vis = compute_bfs(C, hw, 25)
print(f"Elements by BFS depth: {dict(sorted(dc.items()))}")
cum = {}; t = 0
for d_val in sorted(dc.keys()):
    t += dc[d_val]; cum[d_val] = t
print(f"Cumulative: {dict(sorted(cum.items()))}")
# Targets: h_1(1)=5, Q_1(1)=4, h_2(1)=25, Q_2(1)=16

print("\nDemazure subcrystals:")
words = [
    ("(012)^1", [0,1,2]*1), ("(012)^2", [0,1,2]*2),
    ("(012)^3", [0,1,2]*3), ("(012)^4", [0,1,2]*4),
    ("(012)^5", [0,1,2]*5),
    ("(210)^1", [2,1,0]*1), ("(210)^2", [2,1,0]*2),
    ("(210)^3", [2,1,0]*3), ("(210)^4", [2,1,0]*4),
    ("(120)^2", [1,2,0]*2), ("(120)^3", [1,2,0]*3),
    ("(120)^4", [1,2,0]*4),
    ("(201)^2", [2,0,1]*2), ("(201)^3", [2,0,1]*3),
    ("(021)^2", [0,2,1]*2), ("(021)^3", [0,2,1]*3),
    ("(102)^2", [1,0,2]*2), ("(102)^3", [1,0,2]*3),
]
for name, word in words:
    try:
        ne, gd, unk = demazure_graded(C, hw, word, vis)
        s = sum(gd.values())
        mk = ""
        if s in [4,5,16,20,25,64,100,125,256,625]: mk = f" ***"
        print(f"  {name:15s}: {ne:4d} elts, sum={s:6d}{mk}")
        if ne <= 30:
            print(f"    graded: {dict(sorted(gd.items()))}")
    except Exception as e:
        print(f"  {name:15s}: ERROR - {str(e)[:60]}")

# Also try the level-rank dual: hat{sl}_t at level 3 where t = k+d = 3+4 = 7
# So A_6^(1) at level 3.
print("\n\n--- Level-rank dual: A_6^(1) at level 3 ---")
ct7 = CartanType(['A', 6, 1])
P7 = RootSystem(ct7).weight_space(extended=True)
L7 = P7.fundamental_weights()

# Weight: need to determine which weight corresponds to c=(2,1,1)
# Under level-rank duality, the weight on the dual side depends on the profile.
# For A_{t-1}^(1) at level k, the weights are k-tuples in {0,...,t-1}.
# Profile c=(c_0,c_1,c_2) maps to positions on the cylinder.
# The dual weight should have the form sum Lambda_{a_i} where a_i are related to c.

# For c=(2,1,1) and t=7:
# The cylinder has positions 0,...,6. Profile (2,1,1) means:
# partition 0 occupies 2 positions, then boundary, partition 1 occupies 1, boundary, partition 2 occupies 1, boundary.
# Boundaries at positions: 2, 2+1=3, 3+1+1=4+1=5 (?)
# The k=3 boundaries are at cumulative sums: c_0=2, c_0+1=3, c_0+1+c_1=4, c_0+1+c_1+1=5, c_0+1+c_1+1+c_2=6.
# Hmm, the boundaries in the cylinder of circumference t=7 are at:
# After c_0=2 entries of part 0: boundary at position 2.
# After 1 separator: position 3.
# After c_1=1 entries of part 1: position 4.
# After 1 separator: position 5.
# After c_2=1 entries of part 2: position 6.
# After 1 separator: position 7 = 0.
# So the 3 boundaries are at positions 2, 4, 6.
# Under level-rank duality, these boundary positions become the weight indices.

lam_dual = L7[2] + L7[4] + L7[6]  # level 3 weight of A_6^(1)
print(f"Lambda_dual = {lam_dual}, level = {lam_dual.level()}")

try:
    C_dual = crystals.LSPaths(lam_dual)
    hw_dual = list(C_dual.highest_weight_vectors())[0]
    print(f"HW vector: {hw_dual}")

    print("Computing BFS for dual...")
    dc_d, vis_d = compute_bfs(C_dual, hw_dual, 15)
    print(f"Elements by BFS depth: {dict(sorted(dc_d.items()))}")
    cum_d = {}; t_d = 0
    for d_val in sorted(dc_d.keys()):
        t_d += dc_d[d_val]; cum_d[d_val] = t_d
    print(f"Cumulative: {dict(sorted(cum_d.items()))}")

    print("\nDemazure subcrystals (dual):")
    # For A_6^(1), the Coxeter element uses generators 0,...,6
    for depth in range(1, 6):
        word = list(range(7)) * depth
        name = f"(0123456)^{depth}"
        try:
            ne, gd, unk = demazure_graded(C_dual, hw_dual, word, vis_d)
            s = sum(gd.values())
            mk = ""
            if s in [4,5,16,20,25,64,100,125,256,625]: mk = f" ***"
            print(f"  {name}: {ne} elts, sum={s}{mk}")
            if ne <= 30:
                print(f"    graded: {dict(sorted(gd.items()))}")
        except Exception as e:
            print(f"  {name}: ERROR - {str(e)[:60]}")
except Exception as e:
    print(f"ERROR: {e}")

print("\n\nDone.")
