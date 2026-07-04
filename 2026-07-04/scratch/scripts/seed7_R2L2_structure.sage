# Seed 7 R2 L2: deeper structure.
# E6: divisibility of N_2 by (1+q^2+q^4) reduces to a SINGLE scalar identity per root:
#     since EMD(c,c') mod 3 = delta(c') - delta(c) with delta(c)=(c0-c1) mod 3,
#     N_2(c)(zeta) = omega^{-delta(c)} * S(zeta) with S(zeta) = sum_{c'} om^{delta(c')} BR_2(c')(zeta)
#     (om = zeta^2, since zeta^{2*EMD} = om^{EMD}). Check S(zeta) = 0 for zeta = om, -om.
# E7: regroup N_2 by Q_1 argument:
#     N_2(c) = sum_{c'} W(c,c') Q_1(c') + T(c),
#     W(c,c') = q^3 sum_{(c'',J): c''(J)=c'} q^{2EMD(c,c'')} - (q^4+q^5) q^{2EMD(c,c')} [r3(c')]
#     T(c) = sum_{r3 c'} q^{2EMD(c,c')} q^3 (1-q)
#     Check: W(c,c') >= 0 coefficientwise?
# E9: n=3 at d=4: N_3 = (1+q^3+q^6) Q_3 with N_3 = sum q^{3EMD} BR_3. N_3 >= 0?
#     (1+q^3+q^6 = Phi_9, irreducible)

from itertools import combinations

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

Rq = PolynomialRing(QQ, 'q'); qq = Rq.gen()

def Qn_polys(d, n_max):
    """Exact polynomial Q_n via master recursion (gcd(d,3)=1)."""
    profs = profiles(d)
    Q = {(c,0): Rq(1) for c in profs}
    for n in range(1, n_max+1):
        den = 1 + qq**n + qq**(2*n)
        for c in profs:
            tot = Rq(0)
            for cp in profs:
                ic = I_c(cp)
                br = Rq(0)
                for J in combinations(ic, 2):
                    cJ = shifted_profile(cp, J)
                    if any(x < 0 for x in cJ): continue
                    br += qq**(2*n-1) * Q[(cJ, n-1)]
                if rank(cp) == 3:
                    br += -(qq**(3*n-2) + qq**(3*n-1)) * Q[(cp, n-1)]
                    if n >= 2:
                        br += qq**(3*n-3) * (1 - qq**(n-1)) * Q[(cp, n-2)]
                tot += qq**(n*EMD(c, cp)) * br
            quo, rem = tot.quo_rem(den)
            assert rem == 0, f"not divisible n={n} c={c}"
            Q[(c, n)] = quo
    return Q

def nonneg(p): return all(co >= 0 for co in Rq(p).list())

for d in [4, 5, 7]:
    print(f"==================== d = {d} ====================")
    profs = profiles(d)
    Q = Qn_polys(d, 2)
    Q1 = {c: Q[(c,1)] for c in profs}

    # BR_2
    BR = {}
    for cp in profs:
        ic = I_c(cp)
        br = Rq(0)
        for J in combinations(ic, 2):
            cJ = shifted_profile(cp, J)
            if any(x < 0 for x in cJ): continue
            br += qq**3 * Q1[cJ]
        if rank(cp) == 3:
            br += -(qq**4 + qq**5) * Q1[cp] + qq**3 * (1 - qq)
        BR[cp] = br

    # E6: scalar identity
    K.<z> = CyclotomicField(12)
    om = z**4
    for zeta, name in [(om, "om"), (-om, "-om")]:
        w = zeta**2   # zeta^{2 EMD} = (zeta^2)^{EMD}, and EMD mod 3 = delta(c')-delta(c)
        S = sum(w**((cp[0]-cp[1]) % 3) * BR[cp](zeta) for cp in profs)
        print(f"E6 scalar sum S({name}) = {S}   {'ZERO ok' if S == 0 else 'NONZERO!'}")

    # E7: W(c,c') weights. Preimages of c' under 2-shifts:
    # J={0,1}: c'' = c' + e0 - e2 (needs c'2 >= 1, and c''0,c''1 > 0)
    # J={1,2}: c'' = c' - e0 + e1 (needs c'0 >= 1 -> c''... needs c''1,c''2>0)
    # J={0,2}: c'' = c' - e1 + e2 (needs c''0? J={0,2} subset I_c'' -> c''0,c''2>0)
    def preimages(cpr):
        out = []
        for J in [(0,1),(1,2),(0,2)]:
            # invert: solve c''(J) = cpr
            if J == (0,1): cc = (cpr[0]+1, cpr[1], cpr[2]-1)
            elif J == (1,2): cc = (cpr[0]-1, cpr[1]+1, cpr[2])
            else: cc = (cpr[0], cpr[1]-1, cpr[2]+1)
            if any(x < 0 for x in cc): continue
            if not set(J).issubset(set(I_c(cc))): continue
            # sanity
            assert shifted_profile(cc, J) == cpr
            out.append((cc, J))
        return out

    badW = []
    exW = None
    for c in profs:
        for cpr in profs:
            W = sum(qq**(2*EMD(c, cc) + 3) for (cc, J) in preimages(cpr))
            if rank(cpr) == 3:
                W -= (qq**4 + qq**5) * qq**(2*EMD(c, cpr))
            if not nonneg(W):
                badW.append((c, cpr))
                if exW is None: exW = (c, cpr, W)
    print(f"E7 W(c,c') >= 0: {'ALL' if not badW else f'{len(badW)} failures'} "
          f"(out of {len(profs)**2})")
    if exW: print(f"   example c={exW[0]} c'={exW[1]}: W = {exW[2]}")

    # E7b: check N_2 regroup identity + whether sum_{c'} W Q_1 >= 0 alone
    bad7b = []
    for c in profs:
        SW = sum((sum(qq**(2*EMD(c, cc) + 3) for (cc, J) in preimages(cpr))
                  - ((qq**4 + qq**5) * qq**(2*EMD(c, cpr)) if rank(cpr)==3 else 0)) * Q1[cpr]
                 for cpr in profs)
        T = sum(qq**(2*EMD(c, cpr)) * qq**3 * (1 - qq) for cpr in profs if rank(cpr)==3)
        N2 = sum(qq**(2*EMD(c, cp)) * BR[cp] for cp in profs)
        assert SW + T == N2, "regroup identity failed!"
        if not nonneg(SW): bad7b.append(c)
    print(f"E7b sum_c' W(c,c') Q_1(c') >= 0 alone: {len(profs)-len(bad7b)}/{len(profs)}; fails {bad7b[:5]}")

print("==================== n=3, d=4 ====================")
d = 4
profs = profiles(d)
Q = Qn_polys(d, 3)
badN3 = []
for c in profs:
    n = 3
    tot = Rq(0)
    for cp in profs:
        ic = I_c(cp)
        br = Rq(0)
        for J in combinations(ic, 2):
            cJ = shifted_profile(cp, J)
            if any(x < 0 for x in cJ): continue
            br += qq**(2*n-1) * Q[(cJ, n-1)]
        if rank(cp) == 3:
            br += -(qq**(3*n-2) + qq**(3*n-1)) * Q[(cp, n-1)]
            br += qq**(3*n-3) * (1 - qq**(n-1)) * Q[(cp, n-2)]
        tot += qq**(n*EMD(c, cp)) * br
    if not nonneg(tot): badN3.append(c)
print(f"E9 N_3(c) >= 0 (d=4): {len(profs)-len(badN3)}/{len(profs)}; fails {badN3[:6]}")
# Q_3 itself
badQ3 = [c for c in profs if not nonneg(Q[(c,3)])]
print(f"    Q_3 >= 0 (d=4): {len(profs)-len(badQ3)}/{len(profs)}")
