"""
Seed 4 R2 L2: Rotation-orbit structure of EMD.

rho(c) = (c_2, c_0, c_1): mass moves one step clockwise (position i gets c_{i-1}).

Census of triples {EMD(a,b), EMD(a,rho b), EMD(a,rho^2 b)} for gcd(d,3)=1.
Also verify: EMD rotation-invariance, freeness, mod-3 equidistribution.
"""
from collections import Counter
from itertools import product

def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

def emd(c, cp):
    a = cp[1]-c[1]; b = c[0]-cp[0]
    return 3*max(0, a, b) - a - b

def rho(c):
    return (c[2], c[0], c[1])

for d in [1, 2, 4, 5, 7, 8, 10, 11]:
    profs = profiles(d)
    # sanity: rotation invariance and freeness
    for a in profs:
        assert rho(a) != a
        for b in profs:
            assert emd(rho(a), rho(b)) == emd(a, b)
    patterns = Counter()
    examples = {}
    for a in profs:
        for b in profs:
            t = [emd(a, b), emd(a, rho(b)), emd(a, rho(rho(b)))]
            assert sorted(x % 3 for x in t) == [0, 1, 2], (a, b, t)
            e = min(t)
            pat = tuple(sorted(x - e for x in t))
            patterns[pat] += 1
            examples.setdefault(pat, (a, b, t))
    print(f"d={d}: #profiles={len(profs)}, patterns:")
    for pat, cnt in sorted(patterns.items()):
        print(f"   {pat}: {cnt}   e.g. {examples[pat]}")
