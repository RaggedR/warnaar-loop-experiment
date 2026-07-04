"""
Seed 1 R2 L3: exact engine for the H-tower, BOTH EMD orientations,
plus brute-force cylindric partition ground truth (truncated series).

Standing notation (synthesis-layer2.md):
  H_{c,m} = (q;q)_m F_{c,m}
  (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}    [Seed 3: source-first]
  EMD(a,b) = 3*max(0, b_1-a_1, a_0-b_0) + (b_0-a_0) - (b_1-a_1)
Seed 4's engine used weight EMD(target, source) instead. We build both and let
brute force decide.
"""
from collections import defaultdict
from itertools import product
from functools import lru_cache

# ---------- polynomial dicts ----------
def padd(p1, p2):
    r = defaultdict(int, p1)
    for k, v in p2.items(): r[k] += v
    return {k: v for k, v in r.items() if v}

def psub(p1, p2):
    return padd(p1, {k: -v for k, v in p2.items()})

def pmul(p1, p2):
    r = defaultdict(int)
    for k1, v1 in p1.items():
        for k2, v2 in p2.items(): r[k1+k2] += v1*v2
    return {k: v for k, v in r.items() if v}

def pdivexact(num, den):
    num = dict(num); q = {}
    dmax = max(den); dc = den[dmax]
    while num:
        nmax = max(num)
        assert num[nmax] % dc == 0, "nonexact coeff"
        c = num[nmax] // dc; e = nmax - dmax
        assert e >= 0, "nonexact deg"
        q[e] = c
        for k, v in den.items():
            num[k+e] = num.get(k+e, 0) - c*v
            if num[k+e] == 0: del num[k+e]
    return q

def pscale_x(p, k):   # x -> q^k
    return {kk*k: v for kk, v in p.items()}

def pstr(p, upto=None):
    if not p: return "0"
    ks = sorted(p)
    if upto is not None: ks = [k for k in ks if k <= upto]
    return " + ".join((f"{p[k]}" if k==0 else (f"q^{k}" if p[k]==1 else f"{p[k]}q^{k}")) for k in ks)

def pneg(p):
    return {k:v for k,v in p.items() if v < 0}

# ---------- profiles / EMD / orbits ----------
def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d+1-c0)]

def EMD(a, b):
    """standing EMD(a,b) = 3*max(0, b1-a1, a0-b0) + (b0-a0) - (b1-a1)"""
    u = b[1]-a[1]; v = a[0]-b[0]
    return 3*max(0, u, v) - u - v

def rho(c):
    return (c[2], c[0], c[1])

def orbit_data(d):
    profs = profiles(d)
    seen = set(); orbits = []
    for p in profs:
        if p in seen: continue
        orb = [p, rho(p), rho(rho(p))]
        seen.update(orb); orbits.append(orb)
    return profs, orbits

ONEPXX = {0:1, 1:1, 2:1}

def build_U(d, orientation):
    """orientation='source_first': weight q^{m*EMD(source, target)}  [Seed 3]
       orientation='target_first': weight q^{m*EMD(target, source)}  [Seed 4 engine]"""
    profs, orbits = orbit_data(d)
    N = len(orbits)
    U = [[None]*N for _ in range(N)]
    for i, Oi in enumerate(orbits):
        tgt = Oi[0]
        for j, Oj in enumerate(orbits):
            tri = defaultdict(int)
            for t in range(3):
                src = Oj[0]
                for _ in range(t): src = rho(src)
                e = EMD(src, tgt) if orientation=='source_first' else EMD(tgt, src)
                tri[e] += 1
            U[i][j] = pdivexact(dict(tri), ONEPXX)
    return orbits, U

def H_tower(d, mmax, orientation):
    orbits, U = build_U(d, orientation)
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

# ---------- brute-force cylindric partitions ----------
def parts_leq(maxpart, maxsize):
    """all partitions (as tuples, no trailing zeros) with parts <= maxpart, size <= maxsize"""
    out = [()]
    def rec(prefix, last, rem):
        for p in range(1, min(last, rem)+1):
            newp = prefix + (p,)
            out.append(newp)
            rec(newp, p, rem - p)
    rec((), maxpart, maxsize)
    return out

def interlace_ok(lam, mu, shift, T):
    """lam_j >= mu_{j+shift} for all j>=1 (1-indexed)."""
    for j in range(1, len(mu)+1):
        muj = mu[j-1]
        idx = j - shift   # lam index such that lam_idx >= mu_j  <=>  lam_j >= mu_{j+shift}
        if idx >= 1:
            lamv = lam[idx-1] if idx <= len(lam) else 0
            if lamv < muj: return False
    return True

def brute_F(c, m, T):
    """F_{c,m} up to q^T by enumeration. Convention (conjecture.tex, k=3, c=(c1,c2,c3)):
       lam1_j >= lam2_{j+c2}, lam2_j >= lam3_{j+c3}, lam3_j >= lam1_{j+c1},
       with our (c_0,c_1,c_2) = (c1,c2,c3)."""
    c1, c2, c3 = c
    plist = parts_leq(m, T)
    F = defaultdict(int)
    for l1 in plist:
        s1 = sum(l1)
        for l2 in plist:
            s2 = s1 + sum(l2)
            if s2 > T: continue
            if not interlace_ok(l1, l2, c2, T): continue
            for l3 in plist:
                s3 = s2 + sum(l3)
                if s3 > T: continue
                if not interlace_ok(l2, l3, c3, T): continue
                if not interlace_ok(l3, l1, c1, T): continue
                F[s3] += 1
    return dict(F)

def qpoch(m):
    """(q;q)_m as dict"""
    r = {0:1}
    for k in range(1, m+1):
        r = pmul(r, {0:1, k:-1})
    return r

def truncate(p, T):
    return {k:v for k,v in p.items() if k <= T}

if __name__ == "__main__":
    import sys
    d = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    T = int(sys.argv[2]) if len(sys.argv) > 2 else 14
    mmax = 3
    orbits, Us, hs = H_tower(d, mmax, 'source_first')
    _, Ut, ht = H_tower(d, mmax, 'target_first')
    print(f"d={d}, orbits: {[o[0] for o in orbits]}")
    for m in range(1, mmax+1):
        print(f"--- m={m} ---")
        for i, orb in enumerate(orbits):
            F = brute_F(orb[0], m, T)
            Hb = truncate(pmul(qpoch(m), F), T)   # (q;q)_m F_{c,m} truncated at T
            hs_t = truncate(hs[m][i], T); ht_t = truncate(ht[m][i], T)
            ok_s = (Hb == hs_t); ok_t = (Hb == ht_t)
            print(f"  orbit {orb[0]}: brute==source_first: {ok_s}, brute==target_first: {ok_t}")
            if not (ok_s or ok_t):
                print(f"    brute: {pstr(Hb)}")
                print(f"    src  : {pstr(hs_t)}")
                print(f"    tgt  : {pstr(ht_t)}")
