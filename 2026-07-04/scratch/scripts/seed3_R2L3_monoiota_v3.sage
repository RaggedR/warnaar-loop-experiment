"""
V3: general monotone injective weight+1 self-map iota on S_{<=W}:
iota(a) = b, |b| = |a|+1, b in S arbitrary; monotone (a<=a' => iota(a)<=iota(a'));
injective. ILP with pairwise forbidden combinations.
Infeasible on a truncation => no global iota exists.
"""
from itertools import product as iproduct
from collections import defaultdict

def in_S(a, c):
    return all(a[i] >= 0 and a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states(c, W):
    return [a for a in iproduct(range(W+2), repeat=3) if sum(a) <= W and in_S(a, c)]

def leq(a, b):
    return all(a[i] <= b[i] for i in range(3))

def V3(c, W):
    S = states(c, W)
    byrank = defaultdict(list)
    for a in S:
        byrank[sum(a)].append(a)
    dom = [a for a in S if sum(a) <= W - 1]   # keep images within truncation
    p = MixedIntegerLinearProgram(solver="GLPK")
    x = p.new_variable(binary=True)
    cand = {a: byrank[sum(a)+1] for a in dom}
    for a in dom:
        p.add_constraint(sum(x[(a,b)] for b in cand[a]) == 1)
    for w in S:
        lst = [(a,w) for a in dom if sum(a)+1 == sum(w)]
        if len(lst) > 1:
            p.add_constraint(sum(x[t] for t in lst) <= 1)
    ncon = 0
    for a in dom:
        for a2 in dom:
            if a != a2 and leq(a, a2):
                for b in cand[a]:
                    for b2 in cand[a2]:
                        if not leq(b, b2):
                            p.add_constraint(x[(a,b)] + x[(a2,b2)] <= 1)
                            ncon += 1
    try:
        p.solve()
        sol = p.get_values(x)
        pick = {a: b for (a,b), v in sol.items() if v > 0.5}
        print(f"V3 FEASIBLE c={c} W={W} |dom|={len(dom)} (forbid pairs {ncon})")
        return pick
    except Exception:
        print(f"V3 INFEASIBLE c={c} W={W} |dom|={len(dom)} (forbid pairs {ncon})")
        return None

for (c, W) in [((1,1,0), 8), ((2,0,0), 8), ((2,1,1), 7), ((4,0,0), 7),
               ((0,3,1), 7), ((5,0,0), 6)]:
    pick = V3(c, W)
    if pick is not None:
        for a in sorted(pick, key=lambda t:(sum(t),t))[:20]:
            print("   ", a, "->", pick[a], "" if leq(a,pick[a]) else "(NON-COVER)")
