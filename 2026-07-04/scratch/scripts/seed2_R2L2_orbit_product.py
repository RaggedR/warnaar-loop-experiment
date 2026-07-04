"""Seed 2 R2 L2: Orbit-product formula for h_m.
1. Verify EMD(sigma a, sigma b) = EMD(a, b).
2. Verify h_m = sum over orbit sequences of prod_j U^(j)(q^j)  against transfer-matrix h_m.
3. Check whether each orbit product is individually nonneg.

Uses exact polynomial arithmetic over Z via dict/lists (no sage needed).
"""
from itertools import product as iproduct
from fractions import Fraction

def emd(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]

def rot(c):
    return (c[2], c[0], c[1])

# ---------- 1. rotation invariance ----------
bad = 0
for d in range(1, 21):
    for c in profiles(d):
        for cp in profiles(d):
            if emd(rot(c), rot(cp)) != emd(c, cp):
                bad += 1
print("EMD rotation invariance:", "OK" if bad == 0 else f"FAILS ({bad} cases)")

# ---------- polynomial helpers (lists of ints, index = exponent) ----------
def pmul(a, b):
    r = [0]*(len(a)+len(b)-1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if y:
                    r[i+j] += x*y
    return r

def padd(a, b):
    n = max(len(a), len(b))
    return [(a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n)]

def pdiv_exact(num, den):
    # exact division in Z[x]; returns None if not exact
    num = num[:]
    while num and num[-1] == 0: num.pop()
    den2 = den[:]
    while den2 and den2[-1] == 0: den2.pop()
    if not num: return [0]
    q = [0]*(len(num)-len(den2)+1)
    for i in range(len(num)-len(den2), -1, -1):
        coef = num[i+len(den2)-1]
        if coef % den2[-1] != 0 and den2[-1] != 1: pass
        coef = coef // den2[-1]
        q[i] = coef
        for j, y in enumerate(den2):
            num[i+j] -= coef*y
    if any(num): return None
    return q

def substitute_qj(p, j, maxdeg):
    # p(x) -> p(q^j) as coefficient list
    r = [0]*(min(maxdeg, (len(p)-1)*j) + 1)
    for i, x in enumerate(p):
        if x and i*j < len(r):
            r[i*j] += x
    return r

# ---------- transfer matrix h_m (rational power series, exact) ----------
def hm_transfer(d, m_max, prec):
    """Return dict (c, m) -> list of coeffs of h_m (ell = gcd(d,3)), via exact linear algebra
    over Q[[q]] truncated to prec. Uses F_{c,m} recursion (I-A(q^m)) F_m = F_{m-1}."""
    from math import gcd
    ell = 3 if d % 3 == 0 else 1
    profs = profiles(d)
    N = len(profs)
    idx = {p: i for i, p in enumerate(profs)}
    # CW shift matrix entries as polys in x: A[c][c'] built from subsets J
    from itertools import combinations
    def shift_profile(comp, J):
        res = list(comp); Js = set(J)
        for i in range(3):
            prev = (i-1) % 3
            if i in Js and prev not in Js: res[i] -= 1
            elif i not in Js and prev in Js: res[i] += 1
        return tuple(res)
    A = [[[0]*4 for _ in range(N)] for _ in range(N)]  # poly in x, deg<=3
    for i2, comp in enumerate(profs):
        I_c = [i for i in range(3) if comp[i] > 0]
        for size in range(1, len(I_c)+1):
            for J in combinations(I_c, size):
                cJ = shift_profile(comp, J)
                if min(cJ) < 0: continue
                A[i2][idx[cJ]][size] += (-1)**(size-1)
    # power series arithmetic mod q^prec with Fractions
    def smul(a, b):
        r = [Fraction(0)]*prec
        for i, x in enumerate(a):
            if x:
                for j, y in enumerate(b):
                    if i+j >= prec: break
                    if y: r[i+j] += x*y
        return r
    def sadd(a, b): return [a[i]+b[i] for i in range(prec)]
    def ssub(a, b): return [a[i]-b[i] for i in range(prec)]
    one = [Fraction(0)]*prec; one[0] = Fraction(1)
    def sinv(a):
        # invert power series, a[0] != 0
        r = [Fraction(0)]*prec
        r[0] = 1/a[0]
        for n in range(1, prec):
            s = Fraction(0)
            for k in range(1, n+1):
                if k < len(a) and a[k]:
                    s += a[k]*r[n-k]
            r[n] = -s/a[0]
        return r
    # solve (I - A(q^m)) v = w by Gaussian elimination over series? N small; use adjugate instead:
    # (I-A(x))^{-1} = x^{EMD}/(1-x^3). Use PROVED adjugate formula for speed.
    F = {c: one[:] for c in profs}  # F_{c,0} = 1
    hms = {}
    Fs = [F]
    for m in range(1, m_max+1):
        newF = {}
        inv13 = sinv(ssub(one, [Fraction(1) if i == 3*m else Fraction(0) for i in range(prec)]))
        for c in profs:
            acc = [Fraction(0)]*prec
            for cp in profs:
                e = emd(c, cp)*m
                if e < prec:
                    # acc += q^e * F[cp]
                    fcp = Fs[-1][cp]
                    for i in range(prec-e):
                        if fcp[i]: acc[i+e] += fcp[i]
            newF[c] = smul(acc, inv13)
        Fs.append(newF)
        # h_m = (q^ell;q^ell)_m * (F_m - F_{m-1})
        poch = one[:]
        for jj in range(1, m+1):
            poch = smul(poch, ssub(one, [Fraction(1) if i == ell*jj else Fraction(0) for i in range(prec)]))
        for c in profs:
            g = ssub(Fs[m][c], Fs[m-1][c])
            hms[(c, m)] = smul(poch, g)
    return hms

# ---------- orbit-product formula ----------
def orbit_reps(d):
    profs = profiles(d)
    seen, reps = set(), []
    for c in profs:
        if c in seen: continue
        orb = {c, rot(c), rot(rot(c))}
        seen |= orb
        reps.append(c)
    return reps

def U_pair(cj, cjm1, top_diag=False):
    """T(x) = sum_r x^{EMD(cj, sigma^r cjm1)} (with diagonal modification if top_diag
    and cjm1 orbit == cj orbit: the r with sigma^r cjm1 == cj uses exponent 3 instead of 0).
    Return U = T/(1+x+x^2) as int list, or None if not divisible."""
    exps = []
    x = cjm1
    for r in range(3):
        e = emd(cj, x)
        if top_diag and x == cj:
            assert e == 0
            e = 3
        exps.append(e)
        x = rot(x)
    T = [0]*(max(exps)+1)
    for e in exps: T[e] += 1
    return pdiv_exact(T, [1, 1, 1])

def hm_orbit_formula(d, m, c, maxdeg):
    """h_m(c) via orbit-product formula. Returns (total poly, list of orbit products)."""
    reps = orbit_reps(d)
    total = [0]
    products = []
    npos = nneg = 0
    # orbit sequences: ([c_{m-1}], ..., [c_0]) -- but U^(j) for j<m depends on pair
    # (c_j, c_{j-1}) only through orbits; use reps, since U invariant under rotating either arg.
    for seq in iproduct(reps, repeat=m):
        # seq[0] = orbit of c_{m-1}, ..., seq[m-1] = orbit of c_0
        chain = [c] + list(seq)
        prod = [1]
        ok = True
        for jidx in range(m):
            j = m - jidx           # level j: pair (chain[jidx], chain[jidx+1])
            U = U_pair(chain[jidx], chain[jidx+1], top_diag=(jidx == 0))
            if U is None:
                ok = False; break
            prod = pmul(prod, substitute_qj(U, j, maxdeg))
            if len(prod) > maxdeg+1: prod = prod[:maxdeg+1]  # safe: degrees bounded? keep full
        if not ok:
            return None, None
        products.append((seq, prod))
        total = padd(total, prod)
    return total, products

# ---------- run comparison ----------
from math import gcd
for d in [1, 2, 4]:
    m_max = 3 if d <= 2 else 2
    prec = 6*m_max**2 + 200
    hms = hm_transfer(d, m_max, prec)
    reps = orbit_reps(d)
    print(f"\n=== d={d} (ell={3 if d%3==0 else 1}) ===")
    for m in range(1, m_max+1):
        for c in reps:
            total, products = hm_orbit_formula(d, m, c, prec-1)
            href = hms[(c, m)]
            # compare
            match = True
            for i in range(prec - 30):
                a = total[i] if i < len(total) else 0
                if Fraction(a) != href[i]: match = False; break
            negorbs = [(seq, p) for seq, p in products if any(x < 0 for x in p)]
            print(f"  m={m} c={c}: formula {'MATCHES' if match else 'MISMATCH'}; "
                  f"orbits={len(products)}, orbits w/ neg coeff={len(negorbs)}")
            if not match:
                print("    ref :", [str(href[i]) for i in range(15)])
                print("    form:", total[:15])
            for seq, p in negorbs[:3]:
                print(f"    NEG orbit {seq}: {p[:20]}")
