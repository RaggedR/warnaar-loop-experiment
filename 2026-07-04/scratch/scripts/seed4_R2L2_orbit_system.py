"""
Seed 4 R2 L2: orbit-space system for H_m = h_m (per profile).

H_m(a) = P_m(a) / prod_{k<=m} (1+q^k+q^{2k}), computed via the orbit recursion
   H_m(O_i) = sum_j U_{ij}(q^m) H_{m-1}(O_j)
with exact polynomial division. Cross-checked against direct P_m computation.
"""
from collections import defaultdict
from itertools import product

def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

def emd(c, cp):
    a = cp[1]-c[1]; b = c[0]-cp[0]
    return 3*max(0, a, b) - a - b

def rho(c):
    return (c[2], c[0], c[1])

# polynomial = dict {deg: coeff}
def padd(p1, p2):
    r = defaultdict(int, p1)
    for k, v in p2.items(): r[k] += v
    return {k: v for k, v in r.items() if v}

def pmul(p1, p2):
    r = defaultdict(int)
    for k1, v1 in p1.items():
        for k2, v2 in p2.items(): r[k1+k2] += v1*v2
    return {k: v for k, v in r.items() if v}

def pdivexact(num, den):
    """Exact division of polynomials (dicts). Returns quotient, asserts remainder 0."""
    num = dict(num); q = {}
    dmax = max(den); dc = den[dmax]
    while num:
        nmax = max(num)
        assert num[nmax] % dc == 0, "nonexact"
        c = num[nmax] // dc; e = nmax - dmax
        assert e >= 0, "nonexact (deg)"
        q[e] = c
        for k, v in den.items():
            num[k+e] = num.get(k+e, 0) - c*v
            if num[k+e] == 0: del num[k+e]
    return q

def psub(p1, p2):
    return padd(p1, {k: -v for k, v in p2.items()})

def pscale_x(p, k):
    """substitute x -> q^k in poly of x"""
    return {kk*k: v for kk, v in p.items()}

def orbit_data(d):
    profs = profiles(d)
    seen = set(); orbits = []
    for p in profs:
        if p in seen: continue
        orb = [p, rho(p), rho(rho(p))]
        seen.update(orb); orbits.append(orb)
    return profs, orbits

def build_U(d):
    profs, orbits = orbit_data(d)
    N = len(orbits)
    onepxx = {0:1, 1:1, 2:1}
    U = [[None]*N for _ in range(N)]
    for i, Oi in enumerate(orbits):
        a = Oi[0]
        for j, Oj in enumerate(orbits):
            tri = defaultdict(int)
            for t in range(3):
                tri[emd(a, Oj[0] if t==0 else (rho(Oj[0]) if t==1 else rho(rho(Oj[0]))))] += 1
            U[i][j] = pdivexact(dict(tri), onepxx)
    return orbits, U

def H_tower(d, mmax):
    orbits, U = build_U(d)
    N = len(orbits)
    H = [{0:1} for _ in range(N)]
    hist = [list(H)]
    for m in range(1, mmax+1):
        newH = []
        for i in range(N):
            s = {}
            for j in range(N):
                s = padd(s, pmul(pscale_x(U[i][j], m), H[j]))
            newH.append(s)
        H = newH; hist.append(list(H))
    return orbits, U, hist

def pstr(p):
    if not p: return "0"
    return " + ".join(f"{v}q^{k}" if k else f"{v}" for k, v in sorted(p.items()))

def direct_P(d, m):
    """P_m(c) directly: recursion P_k(a) = sum_b q^{k*emd(a,b)} P_{k-1}(b)."""
    profs = profiles(d)
    P = {p: {0:1} for p in profs}
    for k in range(1, m+1):
        P = {a: (lambda a: [s := {}, [s := padd(s, {kk + k*emd(a,b): v for kk,v in P[b].items()}) for b in profs], s][-1])(a) for a in profs}
    return P

if __name__ == "__main__":
    for d in [2, 4]:
        print(f"\n========== d={d} ==========")
        orbits, U, hist = H_tower(d, 6 if d==2 else 5)
        N = len(orbits)
        print("Orbit reps:", [o[0] for o in orbits])
        print("U(x) entries:")
        for i in range(N):
            for j in range(N):
                print(f"  U[{i}][{j}] = {pstr(U[i][j])}")
        # cross-check vs direct P_m / product
        mchk = 3
        P = direct_P(d, mchk)
        denom = {0:1}
        for k in range(1, mchk+1):
            denom = pmul(denom, {0:1, k:1, 2*k:1})
        for i, orb in enumerate(orbits):
            Hd = pdivexact(P[orb[0]], denom)
            assert Hd == hist[mchk][i], (d, i, Hd, hist[mchk][i])
        print(f"cross-check vs direct P_{mchk}: OK")
        for m in range(len(hist)):
            neg = [i for i in range(N) if any(v < 0 for v in hist[m][i].values())]
            print(f" m={m}: negatives in orbits {neg if neg else 'NONE'}")
            for i in range(N):
                print(f"    H_{m}({orbits[i][0]}) = {pstr(hist[m][i])}")
