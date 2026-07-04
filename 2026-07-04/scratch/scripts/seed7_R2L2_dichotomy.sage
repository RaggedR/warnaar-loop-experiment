# Preimage EMD Dichotomy check:
# for all c and rank-3 c', the 3 preimages c'' (2-shift preimages) satisfy
#   Delta = EMD(c,c'') - EMD(c,c') in {-2, +1},  and #{Delta = -2} <= 1.
# Also test trigger: is (#Delta=-2 == 1) <=> EMD(c,c') >= 3? or some condition.
# Also rank-2 preimage Deltas.
def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d-c0+1)]
def I_c(c): return [i for i in range(3) if c[i] > 0]
def EMD(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])
def rank(c): return sum(1 for ci in c if ci > 0)
def preimages(cpr):
    out = []
    for J in [(0,1),(1,2),(0,2)]:
        if J == (0,1): cc = (cpr[0]+1, cpr[1], cpr[2]-1)
        elif J == (1,2): cc = (cpr[0]-1, cpr[1]+1, cpr[2])
        else: cc = (cpr[0], cpr[1]-1, cpr[2]+1)
        if any(x < 0 for x in cc): continue
        if not set(J).issubset(set(I_c(cc))): continue
        out.append(cc)
    return out

for d in [4, 5, 7, 8, 10]:
    profs = profiles(d)
    deltas_seen = set()
    max_k = 0
    trigger_data = {}   # e0 -> set of k values
    viol = []
    for c in profs:
        for cpr in profs:
            pres = preimages(cpr)
            e0 = EMD(c, cpr)
            ds = [EMD(c, cc) - e0 for cc in pres]
            for dd in ds: deltas_seen.add((rank(cpr), dd))
            k = sum(1 for dd in ds if dd < 0)
            if rank(cpr) == 3:
                max_k = max(max_k, k)
                trigger_data.setdefault(e0, set()).add(k)
                if k > 1 or any(dd not in (-2, 1) for dd in ds):
                    viol.append((c, cpr, ds))
    print(f"d={d}: dichotomy violations: {len(viol)}; max #closer preimages (rank3): {max_k}")
    print(f"   Delta values by rank(c'): {sorted(deltas_seen)}")
    ks = sorted((e0, sorted(v)) for e0, v in trigger_data.items())
    print(f"   e0 -> k values (rank-3 c'): {ks}")
