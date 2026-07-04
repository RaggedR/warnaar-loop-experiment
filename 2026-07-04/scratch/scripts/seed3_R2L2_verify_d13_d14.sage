"""
Seed 3, R2L2, Script 3: EXACT verification of h_m >= 0 for d=13,14, all profiles, m<=6.
Uses the H-recursion in ZZ[q]: no truncation, so the precision rule is trivially satisfied.
(1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1};  h = H_m - (1-q^m)H_{m-1}.
Exact division is asserted at every step (this also re-verifies polynomiality).
"""
import time
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

for d in [13, 14]:
    profs = profiles(d)
    E = {(cp, c): emd(cp, c) for cp in profs for c in profs}
    H = {c: Rq(1) for c in profs}
    Hprev = None
    t0 = time.time()
    ok = True
    for m in range(1, 7):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*E[(cp, c)]) * H[cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0, f"DIV FAIL d={d} m={m} c={c}"
            Hnew[c] = quo
        # h_m = Hnew - (1-q^m) H
        negs = []
        for c in profs:
            hm = Hnew[c] - (1 - q^m) * H[c]
            if any(v < 0 for v in hm.list()):
                negs.append((c, min(hm.list())))
        if negs:
            ok = False
            print(f"d={d} m={m}: NEGATIVE h_m at {negs[:10]}")
        else:
            print(f"d={d} m={m}: all {len(profs)} profiles h_m >= 0 (exact), deg(H) up to {max(Hnew[c].degree() for c in profs)}, {time.time()-t0:.1f}s", flush=True)
        H = Hnew
    print(f"d={d}: {'ALL NONNEG m=1..6' if ok else 'FAILURES FOUND'}; total {time.time()-t0:.1f}s")
