"""
Seed 1 R2 L3: surplus-vector structure of the monotonicity conjecture.

Delta_m := H_m - H_{m-1} = (U(q^m) - I) H_{m-1}.
d=2 facts: Delta_m = q^m * S_{m-1} with S_{m-1} = (qC_{m-1}, A_{m-1}) >= 0.
Questions probed here for d=4,5,7:
  (Q1) Is Delta_m divisible by q^m (val >= m)?  [expected: yes if d=2 pattern holds]
  (Q2) Define S_{m-1} := Delta_m / q^m (if Q1). Is S_m >= 0? What is its structure?
  (Q3) Pairwise dominations H_m(O_i) - H_m(O_j) >= 0 : the cross-orbit poset.
  (Q4) matrix (U(x)-I): print entries; is (U(x)-I)/x a matrix over Z[x] (val>=1)?
"""
from seed1_R2L3_engine import *

def val(p):
    return min(p) if p else None

def analyze(d, mmax=6):
    orbits, U, hist = H_tower(d, mmax, 'target_first')
    N = len(orbits)
    reps = [o[0] for o in orbits]
    print(f"\n=========== d={d}, N={N}, orbits {reps} ===========")
    # Q4: U - I entries
    print("U(x) - I  (row = target orbit, col = source orbit):")
    for i in range(N):
        row = []
        for j in range(N):
            e = dict(U[i][j])
            if i == j: e = psub(e, {0:1})
            row.append(pstr(e).replace(" ", ""))
        print(f"  {reps[i]}: [" + " | ".join(row) + "]")
    vals = []
    for i in range(N):
        for j in range(N):
            e = psub(U[i][j], {0:1}) if i==j else U[i][j]
            if e: vals.append(val(e))
    print(f"min valuation of (U-I) entries: {min(vals)}")
    # Q1/Q2
    print("Delta_m = H_m - H_{m-1}: valuation and S = Delta/q^m nonneg?")
    for m in range(1, mmax+1):
        for i in range(N):
            D = psub(hist[m][i], hist[m-1][i])
            v = val(D)
            neg = pneg(D)
            okv = (v is not None and v >= m) or v is None
            print(f"  m={m} O={reps[i]}: val(Delta)={v} (>=m: {okv}), Delta>=0: {not neg}")
    # Q3: pairwise dominations at each level
    print("Pairwise dominations H_m(O_i) >= H_m(O_j) (stable across m=1..mmax):")
    dom = {}
    for i in range(N):
        for j in range(N):
            if i == j: continue
            ok_all = all(not pneg(psub(hist[m][i], hist[m][j])) for m in range(1, mmax+1))
            dom[(i,j)] = ok_all
    for i in range(N):
        doms = [reps[j] for j in range(N) if j != i and dom[(i,j)]]
        print(f"  {reps[i]} >= {doms}")
    return orbits, U, hist

if __name__ == "__main__":
    for d in [2, 4, 5, 7]:
        analyze(d, 6 if d < 7 else 5)
