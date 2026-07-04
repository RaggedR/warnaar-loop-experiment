# Seed 8 adversary: Mission B3 — independent recomputation of Seed 3's d=7 g-values.
# Path: MY seed8 engine (target-first H-recursion + Gauss inversion) -> Q_{n,c};
# then g_c(n) = Q_{n,c}/(q)_n as a q-series to PREC=200. Compare vs their pickle
# (raw-CW z-recursion) and check g-positivity to NMAX=10 (their check was n<=8).
import pickle, time
load("seed8_R2L3_engine.sage")
D = 7; NMAX = 10; PREC = 200
t0 = time.time()
H, _viol = build_H(D, NMAX+2)
reps = orbit_reps(D)
with open("seed3_R2L4_g_d7.pkl","rb") as f:
    PK = pickle.load(f)["g"]
print(f"pickle levels: {len(PK)-1}, reps in pickle: {len(PK[0])}")
Rq = PolynomialRing(ZZ,'q'); q = Rq.gen()
Pow.<qq> = PowerSeriesRing(ZZ, default_prec=PREC)
def inv_poch(n):
    r = Pow(1)
    for k in range(1, n+1):
        r = r * (1 - qq**k + O(qq**PREC))**(-1)
    return r
bad = 0
for n in range(NMAX+1):
    ip = inv_poch(n)
    for c in reps:
        a = gauss_a(H, c, n)             # Q_{n,c} exact poly (dict or poly)
        s = Pow(Rq(a)) * ip
        coeffs = s.padded_list(PREC)
        mn = min(coeffs)
        if mn < 0:
            bad += 1; print(f"*** NEGATIVE g coeff n={n} c={c} min={mn}")
        if n < len(PK) and tuple(c) in PK[n]:
            pkc = PK[n][tuple(c)]
            if list(pkc)[:PREC] != coeffs:
                bad += 1; print(f"*** MISMATCH vs pickle n={n} c={c}")
    print(f"n={n}: all {len(reps)} reps g>=0 to q^{PREC}, pickle-compared where present ({time.time()-t0:.1f}s)", flush=True)
print(f"=== B3 g-check VERDICT: {bad} failures, n<={NMAX}, PREC={PREC} ===")
