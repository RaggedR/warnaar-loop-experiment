# Seed 7 R2 L2: verify the MASTER RECURSION
#   Q_{n,c} = (1-q^{ln})/(1-q^{3n}) * sum_{c'} q^{n*EMD(c,c')} * BR_n(c')
#   BR_n(c') = q^{2n-1} sum_{|J|=2} Q_{n-1,c'(J)}
#              + [r3](-(q^{3n-2}+q^{3n-1}) Q_{n-1,c'} + q^{3n-3}(1-q^{l(n-1)}) Q_{n-2,c'})
# against an INDEPENDENT iterative (Neumann) solve of the CW linear system
# (I - A(q^n)) g_n = b_n  -- no adjugate theorem used.
#
# Also verify the fully-unfolded n=2 DOUBLE SUM (Q_1 closed form inlined).

from itertools import combinations

PREC = 300

def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d-c0+1)]

def I_c(c):
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    Js = set(J); res = list(c)
    for i in range(3):
        prev = (i-1) % 3
        if i in Js and prev not in Js: res[i] -= 1
        elif i not in Js and prev in Js: res[i] += 1
    return tuple(res)

def EMD(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def rank(c):
    return sum(1 for ci in c if ci > 0)

R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def poch_z(s):
    # coefficients a_k = [z^k] (zq;q)_s as list of q-series
    Rz = PolynomialRing(R, 'z'); z = Rz.gen()
    p = Rz(1)
    for i in range(1, s+1):
        p *= (1 - z*q**i)
    return p.list()

def solve_iterative(d, n_max):
    """Neumann iteration on the CW system. Returns g[(c,n)]. No adjugate."""
    profs = profiles(d)
    g = {(c,0): R(1) for c in profs}
    for n in range(1, n_max+1):
        # b_n from past levels
        b = {}
        Aterms = {}  # c -> list of (c(J), coeff) for current level
        for c in profs:
            ic = I_c(c)
            bv = R(0); at = []
            for s in range(1, len(ic)+1):
                a = poch_z(s-1)  # z-coeffs of (zq;q)_{s-1}
                for J in combinations(ic, s):
                    cp = shifted_profile(c, J)
                    if any(x < 0 for x in cp): continue
                    sign = (-1)**(s-1)
                    # [z^n] sign*(zq;q)_{s-1} * sum_m g_{cp,m} q^{sm} z^m
                    # k=0 term: current level
                    at.append((cp, sign * q**(s*n)))
                    for k in range(1, s):
                        if n-k >= 0:
                            bv += sign * a[k] * q**(s*(n-k)) * g[(cp, n-k)]
            b[c] = bv; Aterms[c] = at
        # iterate g = A g + b
        cur = {c: b[c] for c in profs}
        for it in range(PREC//n + 2):
            nxt = {}
            for c in profs:
                v = b[c]
                for (cp, coef) in Aterms[c]:
                    v += coef * cur[cp]
                nxt[c] = v
            cur = nxt
        for c in profs:
            g[(c, n)] = cur[c]
    return g

def qpoch(l, n):
    r = R(1)
    for i in range(1, n+1):
        r *= (1 - q**(l*i))
    return r

def master_recursion_Q(d, n_max):
    """Q_n via the master recursion, starting from Q_0 = 1."""
    profs = profiles(d)
    l = gcd(d, 3)
    Q = {(c,0): R(1) for c in profs}
    for n in range(1, n_max+1):
        pref = (1 - q**(l*n)) / (1 - q**(3*n))
        for c in profs:
            tot = R(0)
            for cp in profs:
                ic = I_c(cp)
                br = R(0)
                for J in combinations(ic, 2):
                    cpp = shifted_profile(cp, J)
                    if any(x < 0 for x in cpp): continue
                    br += q**(2*n-1) * Q[(cpp, n-1)]
                if rank(cp) == 3:
                    br += -(q**(3*n-2) + q**(3*n-1)) * Q[(cp, n-1)]
                    if n >= 2:
                        br += q**(3*n-3) * (1 - q**(l*(n-1))) * Q[(cp, n-2)]
                    else:
                        pass  # n=1: no n-2 term (g_{c,-1}=0)
                tot += q**(n*EMD(c, cp)) * br
            Q[(c, n)] = pref * tot
    return Q

def double_sum_Q2(d):
    """Fully unfolded n=2 double sum (only for gcd(d,3)=1)."""
    profs = profiles(d)
    def B(c):
        r = rank(c)
        return q*(2-q) if r == 3 else (q if r == 2 else R(0))
    out = {}
    den = (1 + q**2 + q**4) * (1 + q + q**2)
    for c in profs:
        S = R(0)   # double sum part
        T = R(0)   # Q_0 part
        for cp in profs:
            w2 = q**(2*EMD(c, cp))
            ic = I_c(cp)
            for cpp in profs:
                inner = R(0)
                for J in combinations(ic, 2):
                    cJ = shifted_profile(cp, J)
                    if any(x < 0 for x in cJ): continue
                    inner += q**3 * q**(EMD(cJ, cpp))
                if rank(cp) == 3:
                    inner += -(q**4 + q**5) * q**(EMD(cp, cpp))
                S += w2 * inner * B(cpp)
            if rank(cp) == 3:
                T += w2 * q**3 * (1 - q)
        out[c] = S/den + T/(1 + q**2 + q**4)
    return out

def coeffs(f, upto=PREC):
    return [f[i] for i in range(upto)]

for d in [4, 5, 7]:
    print(f"=== d = {d} ===")
    l = gcd(d, 3)
    n_max = 3 if d == 4 else 2
    profs = profiles(d)
    g = solve_iterative(d, n_max)
    Qm = master_recursion_Q(d, n_max)
    ok = True
    for n in range(1, n_max+1):
        pn = qpoch(l, n)
        for c in profs:
            Qdirect = pn * g[(c, n)]
            if coeffs(Qdirect, PREC-10) != coeffs(Qm[(c, n)], PREC-10):
                ok = False
                print(f"  MISMATCH master recursion: n={n}, c={c}")
    print(f"  master recursion n=1..{n_max}: {'MATCH (all %d profiles)' % len(profs) if ok else 'FAIL'}")
    if l == 1:
        Qd = double_sum_Q2(d)
        ok2 = all(coeffs(Qd[c], PREC-10) == coeffs(Qm[(c,2)], PREC-10) for c in profs)
        print(f"  unfolded double sum n=2: {'MATCH' if ok2 else 'FAIL'}")
    # sanity: Q_n(1) check for l=1
    if l == 1:
        target = ((d+1)*(d+2)//6 - 1)
        c0 = profs[0]
        Q2 = Qm[(c0,2)]
        deg = max(i for i in range(PREC) if Q2[i] != 0)
        val = sum(Q2[i] for i in range(deg+1))
        print(f"  sanity Q_2,{c0}(1) = {val} (target {target**2}), deg={deg}")
