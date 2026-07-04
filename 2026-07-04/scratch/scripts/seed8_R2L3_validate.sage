"""Seed 8 R2L3: validate the exact engine against (i) d=2 closed forms Q_n = q^{n^2},
q^{n(n+1)}; (ii) an INDEPENDENT truncated Corteel-Welsh power-series solve of F_{c,m}
(inclusion-exclusion functional equation, no H-recursion) for d=4,5, all profiles, m<=4."""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
from itertools import combinations as combs

# ---------- (i) d=2 closed forms ----------
H, viol = build_H(2, 9, verbose=False)
ok = True
for c, expo in [((1,1,0), lambda n: n*n), ((2,0,0), lambda n: n*(n+1))]:
    D = dtower(H, c, 9)
    for n in range(1, 10):
        Qn = D[(n, n)]
        if Qn != q**expo(n):
            ok = False; print("d=2 FAIL c=%s n=%d Q_n=%s" % (c, n, Qn))
print("d=2 closed-form check (n<=9): %s; violations=%d" % ("PASS" if ok else "FAIL", len(viol)))

# ---------- (ii) independent CW truncated solve ----------
def cw_F(d, m_max, PREC):
    """F_{c,m} for all profiles via the CW system solved iteratively in truncated series.
    v_m = (I - A(q^m))^{-1} v_{m-1}, v_0 = 1: v_m[c] = F_{c,m} (bounded max <= m)."""
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    qq = R.gen()
    profs = profiles(d); N = len(profs); idx = {p: i for i, p in enumerate(profs)}
    def shift_profile(comp, J):
        res = list(comp); Js = set(J)
        for i in range(3):
            prev = (i-1) % 3
            if i in Js and prev not in Js: res[i] -= 1
            elif i not in Js and prev in Js: res[i] += 1
        return tuple(res)
    Rx = PolynomialRing(QQ, 'x'); x = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    for ic2, comp2 in enumerate(profs):
        I_c = {i for i in range(3) if comp2[i] > 0}
        for size in range(1, len(I_c)+1):
            for J in combs(sorted(I_c), size):
                cJ = shift_profile(comp2, set(J))
                if min(cJ) < 0: continue
                A_poly[ic2, idx[cJ]] += (-1)**(size-1) * x**size
    v = vector(R, [R(1)]*N)
    out = {0: {p: R(1) for p in profs}}
    Imat = identity_matrix(R, N)
    for m in range(1, m_max+1):
        Am = matrix(R, N, N, lambda i, j: A_poly[i, j](qq**m))
        v = (Imat - Am).solve_right(v)
        out[m] = {p: v[idx[p]] for p in profs}
    return out

for d in [4, 5]:
    m_max = 4; PREC = 80
    H, viol = build_H(d, m_max, verbose=False)
    F = cw_F(d, m_max, PREC)
    SAFE = PREC - 30
    bad = 0
    poch = [Rq(1)]
    for i in range(1, m_max+1): poch.append(poch[-1]*(1-q**i))
    PS = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    for m in range(0, m_max+1):
        for c in profiles(d):
            lhs_s = PS(H[m][c])
            rhs_s = PS(poch[m]) * F[m][c]
            if any(lhs_s[i] != rhs_s[i] for i in range(SAFE)):
                bad += 1; print("MISMATCH d=%d m=%d c=%s" % (d, m, c))
    print("d=%d cross-check H vs CW-solve (all %d profiles, m<=%d, mod q^%d): %s"
          % (d, len(profiles(d)), m_max, SAFE, "PASS" if bad == 0 else "FAIL"))
