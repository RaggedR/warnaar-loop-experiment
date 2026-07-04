"""
Seed 3, R2L2, Script 2: Census of orbit EMD-triples and quotients s_{O,c}(x).

For each target c and each C_3-orbit O of sources, the triple
{EMD(sigma^j c', c)} has distinct residues mod 3 (gcd(d,3)=1).
s_{O,c}(x) = (x^{a0}+x^{a1}+x^{a2})/(1+x+x^2).
Consecutive triple {a,a+1,a+2} <=> s = x^a (nonneg monomial).
Census: how many (c,O) pairs are non-consecutive; where do they live?
"""
Rx.<x> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def rho(a): return (a[1], a[2], a[0])

def orbits(profs):
    seen, obs = set(), []
    for c in profs:
        if c in seen: continue
        O = [c, rho(c), rho(rho(c))]
        Ouniq = []
        for a in O:
            if a not in Ouniq: Ouniq.append(a)
        obs.append(Ouniq)
        seen.update(Ouniq)
    return obs

for d in [4, 5, 7, 8, 10, 11, 13, 14]:
    profs = profiles(d)
    obs = orbits(profs)
    total = 0; noncons = 0; mixed = 0
    bad_examples = []
    # classify c by min entry and zeros
    stats_by_czeros = {}
    for c in profs:
        nz_c = sum(1 for v in c if v == 0)
        for O in obs:
            triple = sorted(emd(cp, c) for cp in O)
            total += 1
            cons = (triple[2] - triple[0] == 2)
            spoly = sum(x^a for a in triple)
            quo, rem = spoly.quo_rem(1 + x + x^2)
            assert rem == 0
            has_neg = any(v < 0 for v in quo.list())
            if not cons: noncons += 1
            if has_neg:
                mixed += 1
                nz_o = sum(1 for v in O[0] if v == 0)
                key = (nz_c, nz_o)
                stats_by_czeros[key] = stats_by_czeros.get(key, 0) + 1
                if len(bad_examples) < 6:
                    bad_examples.append((c, O[0], triple, quo.list()))
    print(f"d={d}: pairs={total}, non-consecutive={noncons}, mixed-sign quotient={mixed}")
    if mixed:
        print(f"   mixed by (#zeros in c, #zeros in orbit rep): {stats_by_czeros}")
        for ex in bad_examples[:4]:
            print(f"   e.g. c={ex[0]} O={ex[1]} triple={ex[2]} s={ex[3]}")
