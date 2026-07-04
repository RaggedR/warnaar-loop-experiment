"""Seed 2 R2 L2: Abel-summation strategy for h_m >= 0 (ell=1 case).
h_m(c) = sum_O U^top_{c,O}(q^m) * P_{m-1}(O),  P_j = (q;q)_j F_{c,j}.
Tests:
 1. P_j = (q;q)_j F_{c,j} >= 0 coefficientwise? (needed as base)
 2. Are the orbit values {P_j(O)} totally ordered by coefficientwise domination?
 3. Order orbits by decreasing P; are partial sums S_t(x) = sum_{i<=t} U_{c,O_i}(x) >= 0?
"""
from fractions import Fraction
from itertools import combinations

def emd(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])
def profiles(d):
    return [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]
def rot(c): return (c[2], c[0], c[1])
def orbit_reps(d):
    seen, reps = set(), []
    for c in profiles(d):
        if c in seen: continue
        seen |= {c, rot(c), rot(rot(c))}
        reps.append(c)
    return reps

def pdiv_exact(num, den):
    num = num[:]
    while num and num[-1] == 0: num.pop()
    if not num: return [0]
    q = [0]*(len(num)-len(den)+1)
    for i in range(len(num)-len(den), -1, -1):
        coef = num[i+len(den)-1] // den[-1]
        q[i] = coef
        for j, y in enumerate(den):
            num[i+j] -= coef*y
    if any(num): return None
    return q

def U_pair(cj, cjm1, top_diag=False):
    exps = []
    x = cjm1
    for r in range(3):
        e = emd(cj, x)
        if top_diag and x == cj: e = 3
        exps.append(e)
        x = rot(x)
    T = [0]*(max(exps)+1)
    for e in exps: T[e] += 1
    return pdiv_exact(T, [1, 1, 1])

def compute_F(d, m_max, prec):
    """F_{c,m} power series via proved inversion (1-q^{3m})F_m = sum q^{mEMD} F_{m-1}."""
    profs = profiles(d)
    one = [Fraction(0)]*prec; one[0] = Fraction(1)
    def smul(a, b):
        r = [Fraction(0)]*prec
        for i, x in enumerate(a):
            if x:
                for j, y in enumerate(b):
                    if i+j >= prec: break
                    if y: r[i+j] += x*y
        return r
    def sinv(a):
        r = [Fraction(0)]*prec; r[0] = 1/a[0]
        for n in range(1, prec):
            s = sum((a[k]*r[n-k] for k in range(1, n+1) if k < len(a) and a[k]), Fraction(0))
            r[n] = -s/a[0]
        return r
    Fs = [{c: one[:] for c in profs}]
    for m in range(1, m_max+1):
        den = one[:]; den[3*m] -= 1
        invden = sinv(den)
        newF = {}
        for c in profs:
            acc = [Fraction(0)]*prec
            for cp in profs:
                e = emd(c, cp)*m
                if e < prec:
                    f = Fs[-1][cp]
                    for i in range(prec-e):
                        if f[i]: acc[i+e] += f[i]
            newF[c] = smul(acc, invden)
        Fs.append(newF)
    return Fs

def qpoch(j, prec):
    one = [Fraction(0)]*prec; one[0] = Fraction(1)
    p = one[:]
    for i in range(1, j+1):
        np_ = p[:]
        for k in range(prec-i):
            np_[k+i] -= p[k]
        p = np_
    return p

def smul2(a, b, prec):
    r = [Fraction(0)]*prec
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if i+j >= prec: break
                if y: r[i+j] += x*y
    return r

def dominates(a, b, upto):
    return all(a[i] >= b[i] for i in range(upto))

for d in [2, 4, 5, 7]:
    m_max = 3 if d <= 5 else 2
    prec = 6*m_max**2 + 200
    Fs = compute_F(d, m_max, prec)
    reps = orbit_reps(d)
    print(f"\n=== d={d}, orbits={len(reps)} ===")
    check_upto = prec - 40
    for j in range(0, m_max):
        pochj = qpoch(j, prec)
        P = {c: smul2(pochj, Fs[j][c], prec) for c in reps}
        # 1. positivity of P_j
        negP = [c for c in reps if any(x < 0 for x in P[c][:check_upto])]
        # 2. total order by domination?
        order_ok = True
        import functools
        cmp_pairs_incomparable = []
        for a, b in combinations(reps, 2):
            ab = dominates(P[a], P[b], check_upto)
            ba = dominates(P[b], P[a], check_upto)
            if not ab and not ba:
                cmp_pairs_incomparable.append((a, b))
        print(f" j={j}: P_j>=0: {'YES' if not negP else 'NO '+str(negP)}; "
              f"incomparable pairs: {len(cmp_pairs_incomparable)} {cmp_pairs_incomparable[:4]}")
        # 3. Abel partial sums for h_{j+1}: order orbits by decreasing P (use eval near q->1 proxy: sum of first coeffs)
        m = j + 1
        for c in reps:
            # sort orbits: decreasing P by comparing series; fall back to sum of coeffs
            def keyf(O):
                s = 0
                for i in range(min(60, prec)):
                    s += float(P[O][i]) * (0.5**i)
                return -s
            ordered = sorted(reps, key=keyf)
            # check chain: P[ordered[t]] >= P[ordered[t+1]]?
            chain_ok = all(dominates(P[ordered[t]], P[ordered[t+1]], check_upto) for t in range(len(ordered)-1))
            # partial sums of U in this order
            S = [0]
            ok_partial = True
            first_bad = None
            for t, O in enumerate(ordered):
                U = U_pair(c, O, top_diag=True)
                n = max(len(S), len(U))
                S = [(S[i] if i < len(S) else 0) + (U[i] if i < len(U) else 0) for i in range(n)]
                if any(x < 0 for x in S):
                    ok_partial = False
                    if first_bad is None: first_bad = (t, O, S[:])
            if not (chain_ok and ok_partial):
                print(f"   m={m} c={c}: chain_ok={chain_ok}, partial_sums_ok={ok_partial}"
                      + (f" first_bad t={first_bad[0]} O={first_bad[1]} S={first_bad[2][:12]}" if first_bad else ""))
        print(f"   m={m}: (only failures printed)")
