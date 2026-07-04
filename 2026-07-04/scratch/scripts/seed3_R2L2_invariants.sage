"""
Seed 3, R2L2, Script 4: hunt for the right inductive invariant.
Compute exact H_{c,m} tables for d=2,4,5 (m<=6) and test candidate coefficientwise inequalities:
 (I1) H_{c,m} >= 0
 (I2) h_{c,m} >= 0 (known)
 (I3) H_{a,m} >= q^{EMD(b,a)} H_{b,m} for all ordered pairs (a,b)   [cross-profile domination]
 (I4) H_{a,m} >= q^{m*EMD(b,a)} H_{b,m}
 (I5) H_{c,m} >= H_{c,m-1}    [level monotonicity]
 (I6) H_{c,m} >= (1+q^m) ... skip
 (I7) H_{a,m} - q^{EMD(b,a)}H_{b,m} >= 0 with EMD in the OTHER direction q^{EMD(a,b)}
 (I8) T-dominance: for target c, T(q)=sum_c' q^{m*E}H_{c'}: check quotient stays >= 0 (same as I1 next level)
"""
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def geq(f, g):
    return all(v >= 0 for v in (f - g).list())

for d in [2, 4, 5]:
    profs = profiles(d)
    Hs = [{c: Rq(1) for c in profs}]
    for m in range(1, 7):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*emd(cp, c)) * Hs[m-1][cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0
            Hnew[c] = quo
        Hs.append(Hnew)
    print(f"\n===== d={d} =====")
    for m in range(1, 7):
        I1 = all(all(v >= 0 for v in Hs[m][c].list()) for c in profs)
        I2 = all(all(v >= 0 for v in (Hs[m][c] - (1-q^m)*Hs[m-1][c]).list()) for c in profs)
        I3 = all(geq(Hs[m][a], q^emd(b, a) * Hs[m][b]) for a in profs for b in profs)
        I4 = all(geq(Hs[m][a], q^(m*emd(b, a)) * Hs[m][b]) for a in profs for b in profs)
        I4b = all(geq(Hs[m][a], q^((m+1)*emd(b, a)) * Hs[m][b]) for a in profs for b in profs)
        I5 = all(geq(Hs[m][c], Hs[m-1][c]) for c in profs)
        print(f" m={m}: H>=0:{I1} h>=0:{I2} dom-q^E:{I3} dom-q^mE:{I4} dom-q^(m+1)E:{I4b} monot:{I5}")
    # print small tables for d=2
    if d == 2:
        for m in range(0, 5):
            print("  m=%d:" % m, {c: Hs[m][c] for c in [(1,1,0), (2,0,0)]})
