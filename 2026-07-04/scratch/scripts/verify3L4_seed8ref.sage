# Independent verifier: reference-engine cross-check (seed8 raw-validated, TRUE labels,
# target-first kernel).  Q_{n,c} = (q;q)_n g_c(n) must equal gauss_a(H,c,n) with the
# IDENTITY label map, for the positive-system solution gpos (junk-start solve).
load("seed8_R2L3_engine.sage")
import pickle
gpos = pickle.load(open("verify3L4_gpos.pkl","rb"))
d=7; NMAX=8; PREC=200
H,viol = build_H(d, NMAX, verbose=False)
print("build_H violations:", viol if viol else "none")
reps = orbit_reps(d)
print("orbit reps:", reps)
ok=True
for c in reps:
    for n in range(NMAX+1):
        a = gauss_a(H,c,n)
        dega = a.degree()
        qq = prod(1-q**i for i in range(1,n+1))
        # (q;q)_n * gpos series, truncated to q^PREC
        gs = gpos[(c,n)]
        Rser = a.list() + [0]*max(0, PREC-dega-1)
        # multiply gs by qq exactly (poly x truncated series)
        prodser = [0]*PREC
        for e,cf in enumerate(qq.list()):
            if cf:
                for i in range(PREC-e):
                    if gs[i]: prodser[i+e]+=cf*gs[i]
        lim = min(PREC, dega+1 if dega < PREC else PREC)
        if prodser[:PREC] != Rser[:PREC]:
            ok=False; print("MISMATCH c=%s n=%d"%(c,n))
        if dega >= PREC: print("note: deg a_%d(%s)=%d >= PREC, compared first %d coeffs"%(n,c,dega,PREC))
        if sum(a.list()) != 11**n:
            ok=False; print("Q_n(1) FAIL c=%s n=%d"%(c,n))
        if any(v<0 for v in a.list()):
            print("note: negative coeff in Q_%d(%s) (would refute conjecture)"%(n,c))
print("reference-engine cross-check ((q;q)_n g_pos == gauss_a, identity labels, n<=%d):"%NMAX, "PASS" if ok else "FAIL")
