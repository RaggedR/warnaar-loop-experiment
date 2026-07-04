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
    for a in S: byrank[sum(a)].append(a)
    dom = [a for a in S if sum(a) <= W - 1]
    p = MixedIntegerLinearProgram(solver="GLPK")
    x = p.new_variable(binary=True)
    cand = {a: byrank[sum(a)+1] for a in dom}
    for a in dom:
        p.add_constraint(sum(x[(a,b)] for b in cand[a]) == 1)
    for w in S:
        lst = [(a,w) for a in dom if sum(a)+1 == sum(w)]
        if len(lst) > 1:
            p.add_constraint(sum(x[t] for t in lst) <= 1)
    for a in dom:
        for a2 in dom:
            if a != a2 and leq(a, a2):
                for b in cand[a]:
                    for b2 in cand[a2]:
                        if not leq(b, b2):
                            p.add_constraint(x[(a,b)] + x[(a2,b2)] <= 1)
    try:
        p.solve()
        print("V3 FEASIBLE   c=%s W=%d |dom|=%d" % (str(c), W, len(dom)))
    except Exception:
        print("V3 INFEASIBLE c=%s W=%d |dom|=%d" % (str(c), W, len(dom)))
    import sys; sys.stdout.flush()

for (c, W) in [((0,2,2), 7), ((0,1,3), 7), ((3,1,1), 7), ((1,1,2), 7),
               ((7,0,0), 6), ((3,2,2), 6), ((4,2,1), 6),
               ((4,0,0), 6), ((4,0,0), 5), ((0,3,1), 6), ((5,0,0), 5),
               ((2,2,0), 7), ((3,1,0), 7), ((0,4,1), 6)]:
    V3(c, W)
