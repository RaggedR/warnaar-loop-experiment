"""
Seed 1 R2 L3: matrix-level q-Pascal via LP feasibility.

Depth-k scheme: with x a formal variable (in application x = q^{m-k+1}),
  target   M_k(x,q) := (U(xq^k) - I) U(xq^{k-1}) ... U(xq) U(x)   [row i separately]
  cone     G_0 = I,  G_j = (U(xq^{j-1}) - I) U(xq^{j-2}) ... U(x),  j = 1..k
Question: does M_k[i] = sum_j A_j G_j + B with all A_j, B having NONNEGATIVE
coefficients as bivariate polynomials in (x,q)?
LP: vars lambda_{g} >= 0 for shifted generators g = x^a q^b * G_j[r];
constraints: (M_k[i] - sum lambda_g g) >= 0 coefficientwise.
If feasible for every row i: monotonicity T_m >= 0 follows for m >= k by
induction (bases T_0..T_{k-1} checked directly).
"""
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import lil_matrix
from seed1_R2L3_engine import build_U, psub, pneg

# bivariate poly: dict {(a,b): coeff} meaning x^a q^b

def embed(u):            # Z[x] -> Z[x,q]
    return {(a,0): v for a,v in u.items()}

def subst_xq(u, k):      # u(x) -> u(x q^k): x^a -> x^a q^{ka}
    return {(a, k*a): v for a,v in u.items()}

def badd(p1, p2):
    r = dict(p1)
    for k,v in p2.items():
        r[k] = r.get(k,0) + v
        if r[k] == 0: del r[k]
    return r

def bmul(p1, p2):
    r = {}
    for (a1,b1),v1 in p1.items():
        for (a2,b2),v2 in p2.items():
            k = (a1+a2, b1+b2)
            r[k] = r.get(k,0) + v1*v2
            if r[k] == 0: del r[k]
    return r

def matmul(M1, M2, N):
    return [[ (lambda s: s)( {k:v for k,v in
              __import__('functools').reduce(lambda acc, t: badd(acc, bmul(M1[i][t], M2[t][j])), range(N), {}).items()} )
             for j in range(N)] for i in range(N)]

def matsub_I(M, N):
    out = [[dict(M[i][j]) for j in range(N)] for i in range(N)]
    for i in range(N):
        out[i][i] = badd(out[i][i], {(0,0): -1})
    return out

def build_targets_cones(d, depth):
    orbits, Uu = build_U(d, 'target_first')
    N = len(orbits)
    Ux = [[embed(Uu[i][j]) for j in range(N)] for i in range(N)]
    # prods[j] = U(xq^{j-1})...U(x) for j>=1; prods[0] = I
    I = [[({(0,0):1} if i==j else {}) for j in range(N)] for i in range(N)]
    prods = [I]
    for j in range(1, depth+1):
        Uj = [[subst_xq(Uu[i][jj], j-1) for jj in range(N)] for i in range(N)]
        prods.append(matmul(Uj, prods[-1], N))
    # cone G_j = (U(xq^{j-1}) - I) * prods[j-1], j=1..depth ; G_0 = I
    cones = [I]
    for j in range(1, depth+1):
        Uj = [[subst_xq(Uu[i][jj], j-1) for jj in range(N)] for i in range(N)]
        cones.append(matmul(matsub_I(Uj, N), prods[j-1], N))
    # target M = (U(xq^depth) - I) * prods[depth]
    Ud = [[subst_xq(Uu[i][jj], depth) for jj in range(N)] for i in range(N)]
    target = matmul(matsub_I(Ud, N), prods[depth], N)
    return orbits, N, cones, target

def row_feasible(N, cones, target_row, amax, bmax, verbose=False):
    """LP: target_row (list of N bivariate polys) minus nonneg combo of shifted
    cone rows is >= 0."""
    # collect generators: (j, r, a, b) -> vector of N bivariate polys shifted
    gens = []
    for j, G in enumerate(cones):
        for r in range(N):
            row = G[r]
            if all(not row[c] for c in range(N)): continue
            for a in range(amax+1):
                for b in range(bmax+1):
                    gens.append((j, r, a, b))
    # monomial index set: union of supports of target and all shifted gens
    def shifted(row, a, b):
        return [ {(aa+a, bb+b): v for (aa,bb),v in row[c].items()} for c in range(N) ]
    monos = set()
    for c in range(N):
        monos.update(target_row[c].keys())
    gvecs = []
    for (j, r, a, b) in gens:
        gv = shifted(cones[j][r], a, b)
        gvecs.append(gv)
        for c in range(N):
            monos.update(gv[c].keys())
    monos = sorted(monos)
    midx = {m: i for i, m in enumerate(monos)}
    ncons = N * len(monos)
    nvars = len(gvecs)
    A = lil_matrix((ncons, nvars))
    rhs = np.zeros(ncons)
    for c in range(N):
        for m, v in target_row[c].items():
            rhs[c*len(monos)+midx[m]] = v
    for t, gv in enumerate(gvecs):
        for c in range(N):
            for m, v in gv[c].items():
                A[c*len(monos)+midx[m], t] = v
    # constraints: A @ lam <= rhs ; lam >= 0
    res = linprog(np.zeros(nvars), A_ub=A.tocsr(), b_ub=rhs,
                  bounds=[(0, None)]*nvars, method='highs')
    return res.status == 0, res, gens

if __name__ == "__main__":
    import sys
    d = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    depth = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    orbits, N, cones, target = build_targets_cones(d, depth)
    # degree bounds for shifts
    tx = max((k[0] for i in range(N) for c in range(N) for k in target[i][c]), default=0)
    tq = max((k[1] for i in range(N) for c in range(N) for k in target[i][c]), default=0)
    print(f"d={d} depth={depth} N={N}, target degs: x<={tx}, q<={tq}")
    allok = True
    for i in range(N):
        # does the row even need help? (already nonneg?)
        need = any(any(v < 0 for v in target[i][c].values()) for c in range(N))
        if not need:
            print(f" row {orbits[i][0]}: target already nonneg, trivially OK")
            continue
        ok, res, gens = row_feasible(N, cones, target[i], tx, tq)
        print(f" row {orbits[i][0]}: feasible={ok}")
        allok = allok and ok
    print("ALL ROWS FEASIBLE:", allok)
