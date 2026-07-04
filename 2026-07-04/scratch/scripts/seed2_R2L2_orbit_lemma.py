"""Seed 2 R2 L2: Test the Orbit Lemma.
For all c and all sigma-orbits O of profiles (d not div by 3),
is {EMD(c,c'), EMD(c,sc'), EMD(c,s^2 c')} a set of 3 consecutive integers?
Also test 3|d for comparison, and both rotation conventions.
EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
"""
def emd(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]

def rotL(c):  # (c0,c1,c2) -> (c1,c2,c0)
    return (c[1], c[2], c[0])

def rotR(c):  # (c0,c1,c2) -> (c2,c0,c1)
    return (c[2], c[0], c[1])

for name, rot in [("rotL", rotL), ("rotR", rotR)]:
    print(f"=== rotation {name} ===")
    for d in range(1, 31):
        profs = profiles(d)
        ok = True
        patterns = set()
        for c in profs:
            for cp in profs:
                vals = sorted([emd(c, cp), emd(c, rot(cp)), emd(c, rot(rot(cp)))])
                diffs = (vals[1]-vals[0], vals[2]-vals[1])
                patterns.add(diffs)
                if diffs != (1, 1):
                    ok = False
        tag = "CONSECUTIVE" if ok else f"FAIL patterns={sorted(patterns)}"
        print(f"d={d:2d} (d%3={d%3}): {tag}")
    print()
