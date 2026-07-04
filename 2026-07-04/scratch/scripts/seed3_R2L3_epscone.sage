"""
Seed 3, R2L3, Script 4: epsilon-inequalities and cone closure.

Step A: for each d, harvest eps vectors from x-power groups of U(x)-I rows; verify
        eps . H_m >= 0 on exact data for all available m.
Step B: closure: for each valid eps, compute eps^T U(x), group by x-powers, get new integer
        vectors; check whether each is a nonneg combination of current valid set + coordinate
        vectors (LP); if not, add it (if it verifies on data) and iterate.
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
    reps = orbits(d); K = len(reps)
    M = matrix(Rx, K, K)
    for i, c in enumerate(reps):
        for j, o in enumerate(reps):
            T = sum(x^emd(s, c) for s in {o, rho(o), rho(rho(o))})
            quo, rem = T.quo_rem(1+x+x^2); assert rem == 0
            M[i, j] = quo
    return reps, M

def computeH(d, m_max, reps, U):
    K = len(reps)
    H = [vector(Rq, [1]*K)]
    for m in range(1, m_max+1):
        H.append(U.apply_map(lambda p: p(q^m)) * H[m-1])
    return H

def xgroups(vec_of_polys, K):
    """vec_of_polys: list of K polys in x. Return dict j -> integer vector (coeff of x^j)."""
    out = {}
    for i, p in enumerate(vec_of_polys):
        for j, cval in enumerate(p.list()):
            if cval:
                out.setdefault(j, [0]*K)
                out[j][i] += cval
    return {j: tuple(v) for j, v in out.items()}

def is_nonneg_combo(target, gens, K):
    """Is target (int tuple) = sum lambda_g g + sum mu_i e_i with lambda,mu >= 0? LP feasibility."""
    p = MixedIntegerLinearProgram(maximization=False, solver="GLPK")
    lam = p.new_variable(nonnegative=True)
    for i in range(K):
        p.add_constraint(sum(lam[gi]*g[i] for gi, g in enumerate(gens))
                         + lam[('e', i)] == target[i])
    p.set_objective(None)
    try:
        p.solve(); return True
    except Exception:
        return False

for d, m_max in [(4, 7), (5, 6), (7, 4), (2, 8)]:
    reps, U = Umat(d); K = len(reps)
    H = computeH(d, m_max, reps, U)
    print(f"\n===== d={d}, K={K} =====")
    # Step A: harvest
    UmI = [[U[i,j] - (1 if i==j else 0) for j in range(K)] for i in range(K)]
    eps_set = []   # list of tuples
    for i in range(K):
        for j, v in sorted(xgroups(UmI[i], K).items()):
            if j == 0:
                assert all(z == 0 for z in v), f"nonzero x^0 group row {reps[i]}"
                continue
            if any(z < 0 for z in v) and v not in eps_set:
                eps_set.append(v)
    # dedupe also pure-nonneg groups aren't needed
    print(f"Step A: {len(eps_set)} distinct mixed-sign eps vectors from U-I rows")
    def check(v):
        for m in range(0, m_max+1):
            val = sum(v[i]*H[m][i] for i in range(K))
            if any(cc < 0 for cc in val.list()): return m
        return None
    badA = [(v, check(v)) for v in eps_set if check(v) is not None]
    if badA:
        print("  Step A FAILURES (eps, first bad m):")
        for v, m in badA: print("   ", v, "fails at m =", m)
    else:
        print("  Step A: ALL eps-inequalities hold on data, m <=", m_max)
    # Step B: closure iteration (only if A passed)
    if not badA:
        valid = list(eps_set)
        frontier = list(eps_set)
        rounds = 0; blown = False
        while frontier and rounds < 6:
            rounds += 1
            newfront = []
            for v in frontier:
                colvec = [sum(v[i]*U[i,j] for i in range(K)) for j in range(K)]
                for jj, w in sorted(xgroups(colvec, K).items()):
                    if all(z >= 0 for z in w): continue
                    if is_nonneg_combo(w, valid, K): continue
                    bm = check(w)
                    if bm is not None:
                        print(f"  Step B: propagated vector {w} (from {v}, x^{jj}) FAILS data at m={bm} -> grouping too coarse")
                        blown = True
                    else:
                        valid.append(w); newfront.append(w)
            frontier = newfront
            if blown: break
            print(f"  closure round {rounds}: +{len(newfront)} new vectors (total {len(valid)})")
        if not blown and not frontier:
            print(f"  *** CLOSURE ACHIEVED with {len(valid)} eps vectors, all data-valid ***")
        elif not blown:
            print(f"  closure not reached in {rounds} rounds; total {len(valid)}")
