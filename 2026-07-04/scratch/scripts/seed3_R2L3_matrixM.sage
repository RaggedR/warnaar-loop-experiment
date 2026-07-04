"""
Seed 3, R2L3, Script 3: THE MATRIX QUESTION.
Is M_m := U(q^m) U(q^{m-1}) - U(q^{m-1}) entrywise nonneg?  (depth-2 smoothing)
If yes, D_m = M_m H_{m-2} >= 0 follows from H >= 0: monotonicity closes.
If no, test depth-3: M3_m := [U(q^m)-I] U(q^{m-1}) U(q^{m-2}).
"""
Rq.<q> = PolynomialRing(ZZ)
Rx.<x> = PolynomialRing(ZZ)

def profiles(d): return [(i, j, d-i-j) for i in range(d+1) for j in range(d-i+1)]
def emd(cp, c):
    e = [cp[i]-c[i] for i in range(3)]
    return 2*e[0]+e[1]+3*max(0,-e[0],-e[0]-e[1])
def rho(a): return (a[1], a[2], a[0])
def orbits(d): return sorted(set(min([c, rho(c), rho(rho(c))]) for c in profiles(d)))

def Umat(d):
    reps = orbits(d)
    K = len(reps)
    M = matrix(Rx, K, K)
    for i, c in enumerate(reps):
        for j, o in enumerate(reps):
            T = sum(x^emd(s, c) for s in {o, rho(o), rho(rho(o))})
            quo, rem = T.quo_rem(1+x+x^2)
            assert rem == 0
            M[i, j] = quo
    return reps, M

def subq(M, e):
    """substitute x -> q^e"""
    return M.apply_map(lambda p: p(q^e))

def nnmat(M):
    return all(all(v >= 0 for v in M[i,j].list()) for i in range(M.nrows()) for j in range(M.ncols()))

for d in [2, 4, 5, 7, 8]:
    reps, U = Umat(d)
    K = len(reps)
    print(f"\n===== d={d} (K={K}) =====")
    mmax = {2: 12, 4: 10, 5: 8, 7: 6, 8: 5}[d]
    for m in range(2, mmax+1):
        M2 = subq(U, m) * subq(U, m-1) - subq(U, m-1)
        ok2 = nnmat(M2)
        line = f"  m={m}: depth-2 M_m >= 0: {ok2}"
        if not ok2:
            # which entries fail
            fails = [(reps[i], reps[j]) for i in range(K) for j in range(K)
                     if any(v < 0 for v in M2[i,j].list())]
            line += f"  fails at {len(fails)} entries e.g. {fails[:3]}"
            if m >= 3:
                M3 = (subq(U, m) * subq(U, m-1) - subq(U, m-1)) * subq(U, m-2)
                ok3 = nnmat(M3)
                line += f" | depth-3: {ok3}"
                if not ok3 and m >= 4:
                    M4 = M3 * subq(U, m-3)
                    line += f" | depth-4: {nnmat(M4)}"
        print(line)
