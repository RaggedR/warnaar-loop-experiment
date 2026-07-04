# E11: per-pair positivity W(c,c') * Q_1(c') >= 0 ?
# E12: shape of W failures; how T(c) negatives are absorbed.
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

def Q1_poly(d):
    profs = profiles(d)
    def B(c):
        r = rank(c)
        return qq*(2-qq) if r == 3 else (qq if r == 2 else Rq(0))
    out = {}
    for c in profs:
        num = sum(qq**EMD(c, cp) * B(cp) for cp in profs)
        quo, rem = num.quo_rem(1 + qq + qq**2)
        assert rem == 0
        out[c] = quo
    return out

def preimages(cpr):
    out = []
    for J in [(0,1),(1,2),(0,2)]:
        if J == (0,1): cc = (cpr[0]+1, cpr[1], cpr[2]-1)
        elif J == (1,2): cc = (cpr[0]-1, cpr[1]+1, cpr[2])
        else: cc = (cpr[0], cpr[1]-1, cpr[2]+1)
        if any(x < 0 for x in cc): continue
        if not set(J).issubset(set(I_c(cc))): continue
        out.append((cc, J))
    return out

for d in [4, 5, 7]:
    profs = profiles(d)
    Q1 = Q1_poly(d)
    badWQ = []
    Wfail_shapes = set()
    for c in profs:
        for cpr in profs:
            W = sum(qq**(2*EMD(c, cc) + 3) for (cc, J) in preimages(cpr))
            if rank(cpr) == 3:
                W -= (qq**4 + qq**5) * qq**(2*EMD(c, cpr))
            if not nonneg(W):
                # record shifted shape: divide by lowest monomial
                Wl = Rq(W).list()
                lo = min(i for i,co in enumerate(Wl) if co != 0)
                Wfail_shapes.add(tuple(Wl[lo:]))
            if not nonneg(Rq(W) * Q1[cpr]):
                badWQ.append((c, cpr))
    print(f"d={d}: W*Q1 >= 0 per pair: {'ALL OK' if not badWQ else f'{len(badWQ)} FAIL, e.g. {badWQ[:3]}'}")
    print(f"   distinct normalized W-failure shapes: {len(Wfail_shapes)}")
    for sh in sorted(Wfail_shapes)[:8]:
        print(f"     {sh}")
