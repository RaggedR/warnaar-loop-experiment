"""
Seed 3, R2L2, Script 1: Validate the H-recursion (**) and lemmas.

H_{c,0} = 1;  (1+q^m+q^{2m}) H_{c,m} = sum_{c'} q^{m*EMD(c',c)} H_{c',m-1}
h_{c,m} = H_{c,m} - (1-q^m) H_{c,m-1}

All EXACT in ZZ[q]. Checks:
 A. EMD rotation equivariance: EMD(rho a, rho b) = EMD(a,b), d=4,5,7 all pairs.
 B. Lemma R: EMD(rho c', c) == EMD(c',c) + d mod 3.
 C. Exact division in (**) holds at every step (gcd(d,3)=1).
 D. h_m from recursion matches power-series h_m (prec 800) for d=4, all profiles, m<=5.
    In particular h_2 at c=(2,1,1) should be [0,0,3,4,5,3,3,2,2,1,1,0,1].
 E. h_m matches for d=5, spot profiles.
"""
Rq.<q> = PolynomialRing(ZZ)

def profiles(d):
    return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]

def emd(cp, c):
    # EMD from source cp to target c; e = cp - c
    e = [cp[i] - c[i] for i in range(3)]
    t_min = max(0, -e[0], -e[0]-e[1])
    return 2*e[0] + e[1] + 3*t_min

def rho(a):
    return (a[1], a[2], a[0])

# --- A, B ---
for d in [4, 5, 7]:
    profs = profiles(d)
    okA = all(emd(rho(a), rho(b)) == emd(a, b) for a in profs for b in profs)
    okB = all((emd(rho(a), b) - emd(a, b) - d) % 3 == 0 for a in profs for b in profs)
    print(f"d={d}: rotation equivariance {okA}, shift lemma {okB}")

# --- exact H recursion ---
def compute_H(d, m_max):
    profs = profiles(d)
    H = {c: Rq(1) for c in profs}
    Hs = [dict(H)]
    for m in range(1, m_max+1):
        div = 1 + q^m + q^(2*m)
        Hnew = {}
        for c in profs:
            rhs = sum(q^(m*emd(cp, c)) * H[cp] for cp in profs)
            quo, rem = rhs.quo_rem(div)
            assert rem == 0, f"DIVISION NOT EXACT d={d} m={m} c={c}"
            Hnew[c] = quo
        H = Hnew
        Hs.append(dict(H))
    return Hs

def h_from_H(Hs, c, m):
    if m == 0: return Rq(1)
    return Hs[m][c] - (1 - q^m) * Hs[m-1][c]

# --- D: compare with power series method ---
d = 4; m_max = 5
Hs = compute_H(d, m_max)
print("\nExact division held for d=4, m<=5.")

PREC = 800
Rps.<t> = PowerSeriesRing(ZZ, default_prec=PREC)
profs = profiles(d)
P = {c: Rps(1) for c in profs}
Plevels = [dict(P)]
for n in range(1, m_max+1):
    P = {c: sum(t^(n*emd(cp, c)) * Plevels[n-1][cp] for cp in profs) for c in profs}
    Plevels.append(dict(P))
q3 = [prod(1 - t^(3*i) for i in range(1, n+1)) if n > 0 else Rps(1) for n in range(m_max+1)]
qn = [prod(1 - t^i for i in range(1, n+1)) if n > 0 else Rps(1) for n in range(m_max+1)]
F = {(c, n): Plevels[n][c] / q3[n] for c in profs for n in range(m_max+1)}

allmatch = True
for c in profs:
    for m in range(m_max+1):
        gm = F[(c, m)] - (F[(c, m-1)] if m > 0 else Rps(0))
        if m == 0: gm = F[(c, 0)]
        hm_ps = (qn[m] * gm).list()
        hm_ex = h_from_H(Hs, c, m).list()
        L = min(len(hm_ps), PREC - 50)
        # exact h should be short; compare full exact poly against series prefix
        if len(hm_ex) > L:
            print(f"  WARNING exact h longer than trusted prefix c={c} m={m}")
        ok = all((hm_ex[i] if i < len(hm_ex) else 0) == (hm_ps[i] if i < len(hm_ps) else 0) for i in range(L))
        if not ok:
            allmatch = False
            print(f"  MISMATCH d=4 c={c} m={m}")
print(f"d=4 recursion-vs-powerseries match (all profiles, m<=5): {allmatch}")
print("h_2 at (2,1,1):", h_from_H(Hs, (2,1,1), 2).list(), "(expect [0,0,3,4,5,3,3,2,2,1,1,0,1])")

# also verify h_m >= 0 for d=4 exactly
neg = [(c, m) for c in profs for m in range(m_max+1)
       if any(v < 0 for v in h_from_H(Hs, c, m).list())]
print("d=4 exact h_m negatives:", neg if neg else "NONE (all nonneg, m<=5)")

# --- E: d=5 quick exact run ---
d = 5; Hs5 = compute_H(d, 4)
profs5 = profiles(5)
neg5 = [(c, m) for c in profs5 for m in range(5)
        if any(v < 0 for v in h_from_H(Hs5, c, m).list())]
print("d=5 exact division OK; h_m negatives m<=4:", neg5 if neg5 else "NONE")

# --- sanity: 3|d should BREAK exact division ---
try:
    compute_H(3, 2)
    print("d=3: exact division unexpectedly held (BAD for our theory)")
except AssertionError as ex:
    print(f"d=3: division fails as predicted -> {ex}")
