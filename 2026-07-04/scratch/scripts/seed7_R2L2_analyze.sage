# Seed 7 R2 L2: positivity + equidistribution analysis of the n=2 numerator.
# N_2(c) := (1+q^2+q^4) * Q_2(c) = sum_{c'} q^{2*EMD(c,c')} * BR_2(c')
# BR_2(c') = q^3 sum_{|J|=2} Q_{1,c'(J)} + [r3](-(q^4+q^5) Q_{1,c'} + q^3(1-q))
#
# E1: BR_2(c') >= 0 per profile?
# E2: N_2(c) >= 0?
# E3: N_2/(1+q+q^2) >= 0 (= (1-q+q^2) Q_2)?
# E4: Q_{1,c'(J)} >= q^a Q_{1,c'} coefficientwise, a = 1, 2?
# E5: at roots of 1+q^2+q^4 (om, -om): is BR_2(c') rank-constant? invariant?

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

Rq = PolynomialRing(QQ, 'q')
qq = Rq.gen()

def Q1_poly(d):
    """Q_1 closed form as exact polynomial (gcd(d,3)=1 assumed)."""
    profs = profiles(d)
    def B(c):
        r = rank(c)
        return qq*(2-qq) if r == 3 else (qq if r == 2 else Rq(0))
    out = {}
    den = 1 + qq + qq**2
    for c in profs:
        num = sum(qq**EMD(c, cp) * B(cp) for cp in profs)
        quo, rem = num.quo_rem(den)
        assert rem == 0, f"Q1 division not exact for {c}"
        out[c] = quo
    return out

def nonneg(p):
    return all(co >= 0 for co in p.list())

for d in [4, 5, 7]:
    print(f"==================== d = {d} ====================")
    profs = profiles(d)
    Q1 = Q1_poly(d)
    assert all(nonneg(Q1[c]) for c in profs)

    # BR_2 per profile
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

    # E1
    bad1 = [cp for cp in profs if not nonneg(BR[cp])]
    print(f"E1 BR_2(c') >= 0: {len(profs)-len(bad1)}/{len(profs)} nonneg; failures: {bad1[:6]}")
    if bad1:
        cp = bad1[0]
        print(f"   example BR_2{cp} = {BR[cp]}")

    # E2, E3
    den1 = 1 + qq + qq**2
    den2 = 1 - qq + qq**2
    bad2 = []; bad3a = []; bad3b = []
    for c in profs:
        N2 = sum(qq**(2*EMD(c, cp)) * BR[cp] for cp in profs)
        if not nonneg(N2): bad2.append(c)
        quo1, rem1 = N2.quo_rem(den1)
        assert rem1 == 0
        if not nonneg(quo1): bad3a.append(c)
        quo2, rem2 = N2.quo_rem(den2)
        assert rem2 == 0
        if not nonneg(quo2): bad3b.append(c)
    print(f"E2 N_2(c) >= 0: {len(profs)-len(bad2)}/{len(profs)}; failures: {bad2[:6]}")
    print(f"E3a N_2/(1+q+q^2) = (1-q+q^2)Q_2 >= 0: {len(profs)-len(bad3a)}/{len(profs)}; failures: {bad3a[:6]}")
    print(f"E3b N_2/(1-q+q^2) = (1+q+q^2)Q_2 >= 0: {len(profs)-len(bad3b)}/{len(profs)}; failures: {bad3b[:6]}")

    # E4: profile monotonicity
    fail_a1 = 0; fail_a2 = 0; tot = 0
    ex1 = None; ex2 = None
    for cp in profs:
        if rank(cp) < 2: continue
        ic = I_c(cp)
        for J in combinations(ic, 2):
            cJ = shifted_profile(cp, J)
            if any(x < 0 for x in cJ): continue
            tot += 1
            if not nonneg(Q1[cJ] - qq * Q1[cp]):
                fail_a1 += 1
                if ex1 is None: ex1 = (cp, J)
            if not nonneg(Q1[cJ] - qq**2 * Q1[cp]):
                fail_a2 += 1
                if ex2 is None: ex2 = (cp, J)
    print(f"E4 Q1[c'(J)] >= q Q1[c']: {tot-fail_a1}/{tot} hold (first fail {ex1})")
    print(f"E4 Q1[c'(J)] >= q^2 Q1[c']: {tot-fail_a2}/{tot} hold (first fail {ex2})")

    # E5: evaluate BR_2 at om (prim 3rd root) and -om (prim 6th root)
    K.<z> = CyclotomicField(12)
    om = z**4       # primitive cube root
    mom = -om       # primitive 6th root of unity: (-om)^2 = om^2, (-om)^3 = -1
    print("E5 BR_2 values at q=om and q=-om, grouped by (rank, (c0-c1) mod 3):")
    seen = {}
    for cp in profs:
        key = (rank(cp), (cp[0]-cp[1]) % 3)
        v = (BR[cp](om), BR[cp](mom))
        seen.setdefault(key, set()).add(v)
    for key in sorted(seen):
        vals = seen[key]
        tag = "CONSTANT" if len(vals) == 1 else f"{len(vals)} distinct values"
        sample = next(iter(vals))
        print(f"   key={key}: {tag}; sample={sample}")
    # is BR_2(om) rank-constant?
    byrank = {}
    for cp in profs:
        byrank.setdefault(rank(cp), set()).add((BR[cp](om), BR[cp](mom)))
    for r in sorted(byrank):
        print(f"   rank {r}: {'CONSTANT' if len(byrank[r])==1 else str(len(byrank[r]))+' distinct'} -> {list(byrank[r])[:3]}")
