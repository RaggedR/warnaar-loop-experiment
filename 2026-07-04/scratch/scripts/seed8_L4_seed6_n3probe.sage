# Seed 8, Mission B5 probe: n=3 analogue of Seed 6's HM.
# No level-3 local formula exists yet, so probe DIRECT residue-respecting
# monotonicity of the raw coefficients [q^j] Q_{3,c}:
#   d=1 mod 3: steps e_i (d -> d+1, lands in d=2 mod 3);
#   d=2 mod 3: weight-2 steps (d -> d+2, lands in d=1 mod 3).
# Report failure counts per (d, j-range) -- empirical data for the level-3 lift.
import time
load("seed8_R2L3_engine.sage")
NLEV = 3
t0 = time.time()
Q = {}   # d -> {c: Q_3 poly}
for d in [4,5,7,8,10,11,13]:
    H, _v = build_H(d, NLEV+1, verbose=False)
    Q[d] = {tuple(c): gauss_a(H, tuple(c), NLEV) for c in profiles(d)}
    print(f"d={d}: Q_3 for {len(Q[d])} profiles ({time.time()-t0:.0f}s)", flush=True)
def coeffs(p, J):
    l = p.list() if hasattr(p, 'list') else [0]
    return l + [0]*(J+1-len(l))
J = 60
tot = fails = 0; failj = {}
for d in [4,7,10,13]:
    steps = [(1,0,0),(0,1,0),(0,0,1)]
    tgt = d+1
    if tgt not in Q: continue
    for c, p in Q[d].items():
        pc = coeffs(p, J)
        for st in steps:
            c2 = (c[0]+st[0], c[1]+st[1], c[2]+st[2])
            p2c = coeffs(Q[tgt][c2], J)
            for j in range(J+1):
                tot += 1
                if p2c[j] < pc[j]:
                    fails += 1; failj[j] = failj.get(j,0)+1
for d in [5,8,11]:
    steps = [(2,0,0),(0,2,0),(0,0,2),(1,1,0),(1,0,1),(0,1,1)]
    tgt = d+2
    if tgt not in Q: continue
    for c, p in Q[d].items():
        pc = coeffs(p, J)
        for st in steps:
            c2 = (c[0]+st[0], c[1]+st[1], c[2]+st[2])
            p2c = coeffs(Q[tgt][c2], J)
            for j in range(J+1):
                tot += 1
                if p2c[j] < pc[j]:
                    fails += 1; failj[j] = failj.get(j,0)+1
print(f"n=3 probe: {tot} coefficient comparisons, {fails} monotonicity failures")
print("failures by j:", dict(sorted(failj.items())))
print("NOTE: probe of RAW [q^j]Q_3 (no har-style correction); at n=2 the raw version also fails at small j -- compare patterns.")
