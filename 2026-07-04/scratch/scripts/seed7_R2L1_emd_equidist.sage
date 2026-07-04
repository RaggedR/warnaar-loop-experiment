# EMD equidistribution mod 3: is EMD(c, .) equidistributed mod 3 across rank-r profiles?
from collections import Counter

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def EMD_formula(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def rank(c):
    return sum(1 for ci in c if ci > 0)

for d in range(2, 15):
    profs = profiles(d)
    all_equi = True
    for c in profs:
        for r in [1, 2, 3]:
            profs_r = [cp for cp in profs if rank(cp) == r]
            if len(profs_r) == 0:
                continue
            mod3_counts = Counter(EMD_formula(c, cp) % 3 for cp in profs_r)
            # Check equidistribution
            vals = list(mod3_counts.values())
            if len(set(vals)) > 1:
                all_equi = False
                print(f"  d={d}, c={c}, rank={r}: NOT equidistributed! {dict(mod3_counts)}")
    
    if all_equi:
        # Count profiles by rank
        rank_counts = Counter(rank(cp) for cp in profs)
        print(f"d={d:2d}: EMD equidistributed mod 3 for ALL profiles/ranks. Rank counts: {dict(sorted(rank_counts.items()))}")
    else:
        print(f"d={d}: FAILED")
