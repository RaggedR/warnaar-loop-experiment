# N_n >= 0 for n=4,5 at d=4 (exact polynomial arithmetic).
from itertools import combinations
def profiles(d):
    return [(c0, c1, d-c0-c1) for c0 in range(d+1) for c1 in range(d-c0+1)]
def I_c(c): return [i for i in range(3) if c[i] > 0]
def shifted_profile(c, J):
    Js = set(J); res = list(c)
    for i in range(3):
        prev = (i-1) % 3
        if i in Js and prev not in Js: res[i] -= 1
        elif i not in Js and prev in Js: res[i] += 1
    return tuple(res)
def EMD(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])
def rank(c): return sum(1 for ci in c if ci > 0)
Rq = PolynomialRing(QQ, 'q'); qq = Rq.gen()
def nonneg(p): return all(co >= 0 for co in Rq(p).list())

d = 4; n_max = 5
profs = profiles(d)
Q = {(c,0): Rq(1) for c in profs}
for n in range(1, n_max+1):
    den = 1 + qq**n + qq**(2*n)
    badN = []
    for c in profs:
        tot = Rq(0)
        for cp in profs:
            br = Rq(0)
            for J in combinations(I_c(cp), 2):
                cJ = shifted_profile(cp, J)
                if any(x < 0 for x in cJ): continue
                br += qq**(2*n-1) * Q[(cJ, n-1)]
            if rank(cp) == 3:
                br += -(qq**(3*n-2) + qq**(3*n-1)) * Q[(cp, n-1)]
                if n >= 2:
                    br += qq**(3*n-3) * (1 - qq**(n-1)) * Q[(cp, n-2)]
            tot += qq**(n*EMD(c, cp)) * br
        if not nonneg(tot): badN.append(c)
        quo, rem = tot.quo_rem(den)
        assert rem == 0
        Q[(c, n)] = quo
    badQ = [c for c in profs if not nonneg(Q[(c,n)])]
    print(f"n={n}: N_n >= 0: {len(profs)-len(badN)}/{len(profs)} (fails {badN[:4]}); "
          f"Q_n >= 0: {len(profs)-len(badQ)}/{len(profs)}; deg Q_n[(0,0,4)] = {Q[((0,0,4),n)].degree()}")
