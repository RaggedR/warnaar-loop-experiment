"""Seed 7 R2L4 fingerprints, round 2.
 F4: seed3-L2 orbit EMD triples (targets (2,1,1),(4,0,0) at d=4), TRUE vs REVERSED.
 F5: seed5-L2 emd == engine emd on all d=8 pairs; JSON Q_n vs TRUE engine Q_n at the
     chirality pair (4,1,3)/(4,3,1) (and (5,1,2)/(5,2,1)), n<=3.
 F6: seed6-L2 G-relations vs TRUE engine F-series, d=5 and d=8, z-coeffs n<=4, exact.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")
import json

def orbit_members(rep):
    return sorted(set([tuple(rep), (rep[1],rep[2],rep[0]), (rep[2],rep[0],rep[1])]))

# ---- F4 ----
for target in [(2,1,1),(4,0,0)]:
    for O in [(4,0,0),(3,1,0),(0,1,3),(0,2,2),(1,1,2),(2,1,1)]:
        Om = orbit_members(O)
        t_true = sorted(emd(target, cp) for cp in Om)
        t_rev  = sorted(emd(cp, target) for cp in Om)
        print("F4 d=4 target %s orbit-of %s: TRUE-triple %s  REV-triple %s" % (target, O, t_true, t_rev))

# ---- F5 ----
def emd5(c, cp):
    g1 = c[1] - cp[1]; g2 = c[1] + c[2] - cp[1] - cp[2]
    g = [0, g1, g2]
    return sum(g) - 3*min(g)
profs8 = profiles(8)
same = all(emd5(a,b) == emd(a,b) for a in profs8 for b in profs8)
print("F5: seed5-L2 emd(c,cp) == engine emd(c,cp) on all d=8 pairs:", same)

QN = json.load(open('/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed5_R2L2_qn_d8.json'))
NCHK = 3
H8, _ = build_H(8, NCHK, verbose=False)
for c in [(4,1,3),(4,3,1),(5,1,2),(5,2,1)]:
    okall = True
    for n in range(NCHK+1):
        key = "(%d, %d, %d)|%d" % (c[0], c[1], c[2], n)
        js = Rq(QN[key])
        an = gauss_a(H8, c, n)
        if js != an: okall = False; print("F5 MISMATCH c=%s n=%d json=%s engine=%s" % (c, n, js, an))
    print("F5: seed5 json Q_n[%s] == TRUE engine, n<=%d: %s" % (c, NCHK, okall))

# ---- F6 ----
def F_series(H, c, m_max):
    """list of g_m = F_{c,m}-F_{c,m-1} as exact rationals in power series? Use series F_{c,m}=H/(q;q)_m."""
    PREC = 61
    PS = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    poch = PS(1)
    Fs = []
    prev = PS(0)
    for m in range(m_max+1):
        if m: poch *= (1 - PS.gen()**m)
        Fm = PS(H[m][c])/poch
        Fs.append(Fm - prev)
        prev = Fm
    return Fs  # g_m, m=0..m_max

def G_zcoeff(H, c, n, m_max):
    """[z^n] G_c(z) = sum_{j+m=n} eul_j g_m with (zq;q)_inf = sum_j (-1)^j q^{j(j+1)/2}/(q;q)_j z^j."""
    PREC = 61
    PS = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    qq = PS.gen()
    g = F_series(H, c, m_max)
    tot = PS(0)
    for j in range(n+1):
        poch = PS(1)
        for i in range(1, j+1): poch *= (1 - qq**i)
        eul = (-1)**j * qq**(j*(j+1)//2) / poch
        tot += eul * g[n-j]
    return tot

# relation check: G_target(z) = sum_i z^{s_i} q^{t_i(n-shift)} ... easier: check coefficientwise
# G_c(z) = G_{h}(zq) + sum_k zq^{a_k} G_{t_k}(zq^{k+1}) with the quoted shapes:
def check_rel(d, target, head, tail, m_max=5):
    """Relation shape: G_t(z) = G_head(z q) + sum_{k=1..len(tail)} z q^k G_{tail[k-1]}(z q^{k+1}).
    [z^n]: G_t[n] = q^n G_head[n] + sum_k q^k q^{(k+1)(n-1)} G_{tail[k]}[n-1]."""
    H, _ = build_H(d, m_max, verbose=False)
    ok = True
    for n in range(0, m_max):
        lhs = G_zcoeff(H, target, n, m_max)
        PS = lhs.parent(); qq = PS.gen()
        rhs = qq**n * G_zcoeff(H, head, n, m_max)
        for k in range(1, len(tail)+1):
            if n >= 1:
                rhs += qq**k * qq**((k+1)*(n-1)) * G_zcoeff(H, tail[k-1], n-1, m_max)
        if (lhs - rhs) != 0:
            ok = False
            print("F6 rel d=%d target %s FAIL at n=%d: diff=%s" % (d, target, n, (lhs-rhs).truncate(20)))
    print("F6 d=%d relation G_%s = G_%s(zq) + tail %s : %s (n<%d, prec 60)" % (d, target, head, tail, "PASS" if ok else "FAIL", m_max))

check_rel(5, (4,0,1), (3,1,1), [(4,1,0)])
check_rel(5, (3,0,2), (2,2,1), [(3,1,1),(4,1,0)])
check_rel(5, (3,2,0), (3,1,1), [(2,2,1),(3,1,1),(4,1,0)])
check_rel(8, (6,0,2), (5,1,2), [(6,1,1),(7,1,0)], m_max=4)
