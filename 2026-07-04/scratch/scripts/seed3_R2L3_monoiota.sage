"""
Seed 3, R2L3, Script 9: does the state lattice S admit a monotone injective
weight+1 self-map iota?  (Levelwise application would give the psi-injection
for f_0^{(m)} >= 0 for ALL m at once.)

V1 (single-box): iota(a) = a + e_{y(a)}, y(a) slack at a.
  (M) consistency: a' <= a, a'_{y(a')} = a_{y(a')}  =>  y(a) = y(a').
  (I) injectivity of a |-> a + e_{y(a)}.
ILP feasibility on truncation S_{<=W}.

V3 (general): iota(a) = any b in S with |b| = |a|+1; monotone + injective.
  Lazy-constraint ILP (only run if V1 infeasible).
"""
from itertools import product as iproduct

def in_S(a, c):
    return all(a[i] >= 0 and a[i] <= a[(i-1) % 3] + c[i] for i in range(3))

def states(c, W):
    return [a for a in iproduct(range(W+2), repeat=3) if sum(a) <= W and in_S(a, c)]

def slack(a, c):
    return [i for i in range(3) if a[i] < a[(i-1) % 3] + c[i]]

def leq(a, b):
    return all(a[i] <= b[i] for i in range(3))

def V1(c, W):
    S = states(c, W)
    Sset = set(S)
    p = MixedIntegerLinearProgram(solver="GLPK")
    y = p.new_variable(binary=True)
    for a in S:
        sl = slack(a, c)
        assert sl
        p.add_constraint(sum(y[(a,i)] for i in sl) == 1)
    # injectivity
    from collections import defaultdict
    into = defaultdict(list)
    for a in S:
        for i in slack(a, c):
            w = tuple(a[j] + (1 if j == i else 0) for j in range(3))
            into[w].append((a,i))
    for w, lst in into.items():
        if len(lst) > 1:
            p.add_constraint(sum(y[t] for t in lst) <= 1)
    # (M)
    nM = 0
    for a in S:
        for b in S:
            if a != b and leq(a, b):
                for i in slack(a, c):
                    if a[i] == b[i]:
                        p.add_constraint(y[(a,i)] <= y[(b,i)])
                        nM += 1
    try:
        p.solve()
        sol = p.get_values(y)
        pick = {a: i for (a,i), v in sol.items() if v > 0.5}
        print(f"V1 FEASIBLE c={c} W={W} |S|={len(S)} (M-constraints {nM})")
        return pick
    except Exception as e:
        print(f"V1 INFEASIBLE c={c} W={W} |S|={len(S)} (M-constraints {nM})")
        return None

for (c, W) in [((1,1,0), 9), ((2,0,0), 9), ((2,1,1), 8), ((4,0,0), 8),
               ((0,3,1), 8), ((0,1,3), 8), ((0,2,2), 8), ((3,1,1), 7),
               ((5,0,0), 7), ((7,0,0), 7)]:
    pick = V1(c, W)
    if pick is not None and c in [(1,1,0),(4,0,0)]:
        # print the selection on low-weight states to look for a pattern
        for a in sorted(pick, key=lambda t:(sum(t),t))[:25]:
            print("   ", a, "->", pick[a])
