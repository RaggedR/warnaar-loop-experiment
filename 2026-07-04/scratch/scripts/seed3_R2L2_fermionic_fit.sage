"""
Seed 3, R2L2, Script 6: Fit bounded fermionic forms to H_{c,m}.

d=2:  H_{c,m} =? sum_j q^{j^2 + a*j} [m,j]_q                  (RR polynomials), a in {0,1,2}
d=4:  H_{c,m} =? sum_{n1,n2} q^{n1^2+n2^2-n1n2 + a*n1 + b*n2} [m,n1]_q [2n1+eps, n2]_q
      (bounded ASW mod-7), (a,b,eps) in {0,1,2}^2 x {0,1}
d=5:  H_{c,m} =? sum q^{n1^2+n2^2+n3^2+n4^2-n1n2+n2n4 + a.n} [m,n1][n1,n2][n2,n3][n1,n4]
      (bounded CDU mod-8), a in {0,1}^4 (+ a few extras)
Exact H from the recursion; exact polynomial comparison for m = 0..M.
"""
from itertools import product as iproduct
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    e = [cp[i] - c[i] for i in range(3)]
    return 2*e[0] + e[1] + 3*max(0, -e[0], -e[0]-e[1])

def compute_H(d, m_max):
    profs = profiles(d)
    Hs = [{c: Rq(1) for c in profs}]
    for m in range(1, m_max+1):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*emd(cp, c)) * Hs[m-1][cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0
            Hnew[c] = quo
        Hs.append(Hnew)
    return Hs

def qbin(n, k):
    if k < 0 or k > n: return Rq(0)
    return Rq(q_binomial(n, k))

def rho(a): return (a[1], a[2], a[0])
def orbit_reps(d):
    profs = profiles(d); seen = set(); reps = []
    for c in profs:
        if c in seen: continue
        reps.append(c); seen.update([c, rho(c), rho(rho(c))])
    return reps

# ---------- d=2 ----------
print("=== d=2 ===")
Hs = compute_H(2, 8)
for c in orbit_reps(2):
    found = None
    for a in range(4):
        ok = all(Hs[m][c] == sum(q^(j^2 + a*j) * qbin(m, j) for j in range(m+1)) for m in range(9))
        if ok: found = a; break
    print(f"  c={c}: H_m = sum_j q^(j^2+{found}*j) [m,j]  -> {'MATCH m<=8' if found is not None else 'NO MATCH'}")

# ---------- d=4 ----------
print("=== d=4 ===")
Hs = compute_H(4, 6)
M = 6
for c in orbit_reps(4):
    found = []
    for a, b, eps in iproduct(range(3), range(3), range(2)):
        ok = True
        for m in range(M+1):
            s = Rq(0)
            for n1 in range(m+1):
                for n2 in range(2*n1+eps+1):
                    s += q^(n1^2+n2^2-n1*n2 + a*n1 + b*n2) * qbin(m, n1) * qbin(2*n1+eps, n2)
            if s != Hs[m][c]:
                ok = False; break
        if ok: found.append((a, b, eps))
    print(f"  c={c}: (a,b,eps) matches m<=6: {found if found else 'NONE'}")

# ---------- d=5 ----------
print("=== d=5 ===")
Hs = compute_H(5, 5)
M = 5
for c in orbit_reps(5):
    found = []
    for a in iproduct(range(2), range(2), range(2), range(2)):
        ok = True
        for m in range(M+1):
            s = Rq(0)
            for n1 in range(m+1):
                for n2 in range(n1+1):
                    for n3 in range(n2+1):
                        for n4 in range(n1+1):
                            s += q^(n1^2+n2^2+n3^2+n4^2 - n1*n2 + n2*n4
                                     + a[0]*n1 + a[1]*n2 + a[2]*n3 + a[3]*n4) \
                                 * qbin(m, n1) * qbin(n1, n2) * qbin(n2, n3) * qbin(n1, n4)
            if s != Hs[m][c]:
                ok = False; break
        if ok: found.append(a)
    print(f"  c={c}: linear terms matching m<=5: {found if found else 'NONE'}", flush=True)
