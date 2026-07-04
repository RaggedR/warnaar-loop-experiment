"""Seed 7 R2L4 (verifier): fingerprints for the label audit.
All in TRUE convention (target-first kernel, reference engine), plus a REVERSED build
for comparison. Fingerprints:
 F1: d=4,5 ferm(m,a,b,eps) fits per orbit (TRUE labels) -> which orbits match/miss.
 F2: d=4 orbit-level U-I rows (targets (1,1,2) and all), TRUE vs REVERSED.
 F3: EMD values for ((0,0,4),(0,1,3)) both orders.
"""
load("/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts/seed8_R2L3_engine.sage")

def rev(c): return (c[2], c[1], c[0])

def orb(c):
    return min(c, (c[1], c[2], c[0]), (c[2], c[0], c[1]))

def build_H_reversed(d, m_max):
    """Source-first kernel (the Layer-2 bug): q^{m*EMD(c', c)} with c' source."""
    profs = profiles(d)
    E = {(a, b): emd(a, b) for a in profs for b in profs}
    H = {0: {c: Rq(1) for c in profs}}
    for m in range(1, m_max+1):
        div = 1 + q**m + q**(2*m)
        Hm = {}
        for c in profs:
            rhs = sum(q**(m*E[(cp, c)]) * H[m-1][cp] for cp in profs)  # SOURCE-first
            quo, rem = rhs.quo_rem(div)
            assert rem == 0
            Hm[c] = quo
        H[m] = Hm
    return H

def ferm(m, a, b, eps, MMAX=None):
    tot = Rq(0)
    for n in range(0, m+1):
        for j in range(0, 2*n+eps+1):
            tot += q**(n*n - n*j + j*j + a*n + b*j) * q_binomial(m, n, q) * q_binomial(2*n+eps, j, q)
    return tot

# ---- F3: EMD values ----
print("F3: EMD(target=(0,0,4), source=(0,1,3)) =", emd((0,0,4),(0,1,3)))
print("F3: EMD(target=(0,1,3), source=(0,0,4)) =", emd((0,1,3),(0,0,4)))

# ---- build H both conventions ----
for d in (4, 5):
    MM = 5
    Ht, _ = build_H(d, MM, verbose=False)
    Hr = build_H_reversed(d, MM)
    # sanity: Hr[c] == Ht[rev(c)]
    ok = all(Hr[m][c] == Ht[m][rev(c)] for m in range(MM+1) for c in profiles(d))
    print("d=%d sanity Hrev[c]==Htrue[rev(c)]: %s" % (d, ok))
    # F1: ferm fits, TRUE labels, orbit reps
    reps = orbit_reps(d)
    matched = {}
    for c in reps:
        hit = None
        for a in range(0, 5):
            for b in range(0, 5):
                for e in range(0, 4):
                    if all(Ht[m][c] == ferm(m, a, b, e) for m in range(0, 5)):
                        hit = (a, b, e); break
                if hit: break
            if hit: break
        matched[c] = hit
        print("F1 d=%d TRUE orbit %s: %s" % (d, c, ("MATCH ferm(m,%d,%d,%d)" % hit) if hit else "NO MATCH"))

# ---- F2: orbit-level U-I rows at d=4, symbolic ----
Rx = PolynomialRing(QQ, 'x'); x = Rx.gen()
d = 4
reps = orbit_reps(d)
def orbit_members(rep):
    return sorted(set([rep, (rep[1],rep[2],rep[0]), (rep[2],rep[0],rep[1])]))
print("d=4 orbit reps:", reps)
for conv in ("TRUE-target-first", "REVERSED-source-first"):
    for target in reps:
        row = []
        for Op in reps:
            p = Rx(0)
            for cp in orbit_members(Op):
                e = emd(target, cp) if conv.startswith("TRUE") else emd(cp, target)
                p += x**e
            quo, rem = p.quo_rem(Rx(1 + x + x**2))
            if rem != 0:
                row.append("NONPOLY(%s)" % p)
            else:
                entry = quo - (1 if Op == target else 0)
                row.append(str(entry))
        print("F2 %s d=4 (U-I) row target %s: [%s]" % (conv, target, ", ".join(row)))
