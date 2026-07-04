"""
Seed 3 R2L4 Phase 4: deterministic replay of the core-row derivations, assembly of the
full positive y-system at d=7, and the decisive independent check: solve the positive
system ALONE as a q-adic fixed point and compare with the raw-CW engine solution.
"""
import pickle
from collections import defaultdict
import seed3_R2L4_engine as E
from seed3_R2L4_construct import (
    D, NMAX, PREC, rep, REPS, CORES, ZEROS, raw_row_expr, substitute,
    is_positive_row, head_of, verify_row, derive_zero_rows, show, load_g)

# ---- derivation paths found by seed3_R2L4_search.py (each step exact) ----
PATHS = {
    (1, 1, 5): [(((0, 6, 1), 1), "raw", (0, 6, 1)),
                (((0, 2, 5), 1), "R",   (0, 2, 5)),
                (((0, 1, 6), 2), "R",   (0, 1, 6))],
    (1, 2, 4): [(((1, 1, 5), 1), "raw", (1, 1, 5)),
                (((0, 6, 1), 2), "raw", (0, 6, 1)),
                (((0, 3, 4), 1), "R",   (0, 3, 4)),
                (((0, 2, 5), 2), "R",   (0, 2, 5)),
                (((0, 1, 6), 3), "R",   (0, 1, 6))],
    (1, 3, 3): [(((1, 2, 4), 1), "raw", (1, 2, 4)),
                (((1, 1, 5), 2), "raw", (1, 1, 5)),
                (((0, 6, 1), 3), "raw", (0, 6, 1)),
                (((0, 4, 3), 1), "R",   (0, 4, 3)),
                (((0, 3, 4), 2), "R",   (0, 3, 4)),
                (((0, 2, 5), 3), "R",   (0, 2, 5)),
                (((0, 1, 6), 4), "R",   (0, 1, 6))],
    (1, 4, 2): [(((0, 5, 2), 1), "raw", (0, 5, 2)),
                (((1, 2, 4), 1), "raw", (1, 2, 4)),
                (((1, 1, 5), 2), "raw", (1, 1, 5)),
                (((0, 6, 1), 3), "raw", (0, 6, 1)),
                (((0, 3, 4), 2), "R",   (0, 3, 4)),
                (((0, 2, 5), 3), "R",   (0, 2, 5)),
                (((0, 1, 6), 4), "R",   (0, 1, 6))],
    (2, 2, 3): [(((1, 3, 3), 1), "C",   (1, 3, 3)),
                (((1, 2, 4), 2), "C",   (1, 2, 4)),
                (((1, 4, 2), 1), "C",   (1, 4, 2))],
}
ORDER = [(1, 1, 5), (1, 2, 4), (1, 3, 3), (1, 4, 2), (2, 2, 3)]

def build_system():
    zr = derive_zero_rows()
    rows = {}                       # rep -> positive row Expr
    for r in ZEROS:
        rows[r] = zr[r][0][0]
    for t in ORDER:
        expr = raw_row_expr(t)
        for key, kind, src in PATHS[t]:
            row = (raw_row_expr(src) if kind == "raw"
                   else rows[src])   # "R" and "C" both live in rows{}
            expr = substitute(expr, key, row)
        rows[t] = expr
    return rows

def solve_positive_system(rows, nmax=NMAX):
    """q-adic fixed point per y-level using ONLY the positive system."""
    g = [{r: E.sfromdict({0: 1}) for r in REPS}]
    for n in range(1, nmax + 1):
        cur = {r: E.snew() for r in REPS}
        for _ in range(PREC // max(n, 1) + 3):
            changed = False
            for t in REPS:
                acc = E.snew()
                for (r, s), m in rows[t].items():
                    for (j, a), v in m.items():
                        if n - j < 0:
                            continue
                        src = cur[r] if j == 0 else g[n - j][r]
                        sh = a + s * (n - j)
                        if sh < PREC:
                            E.sadd(acc, src, v, sh)
                if acc != cur[t]:
                    cur[t] = acc
                    changed = True
            if not changed:
                break
        g.append(cur)
        print(f"  positive-system level n={n} solved", flush=True)
    return g

if __name__ == "__main__":
    rows = build_system()
    print("=== the positive y-system at d=7 (modulus 10) ===")
    allpos, allver = True, True
    for r in REPS:
        pos = is_positive_row(rows[r])
        ok, nn = verify_row(r, rows[r])
        hd = head_of(rows[r])
        allpos &= pos
        allver &= ok
        print(f"G{r}(y) = {show(rows[r])}")
        print(f"   positive={pos} head={hd} verify-vs-engine(n<={NMAX},q^{PREC})="
              f"{'PASS' if ok else f'FAIL@n={nn}'}")
    print(f"ALL ROWS POSITIVE: {allpos}; ALL ROWS VERIFIED: {allver}")

    print("Solving the positive system standalone (uniqueness/fixed-point check) ...")
    gp = solve_positive_system(rows)
    g = load_g()
    match = all(gp[n][r] == g[n][r] for n in range(NMAX + 1) for r in REPS)
    print(f"positive-system solution == raw-CW engine solution (all 12 orbits, "
          f"n<={NMAX}, q^{PREC}): {'PASS' if match else 'FAIL'}")
    neg = any(v < 0 for n in range(NMAX + 1) for r in REPS for v in gp[n][r])
    print(f"nonnegativity of solved g (sanity of positivity transmission): "
          f"{'PASS' if not neg else 'FAIL'}")
    with open("seed3_R2L4_system_d7.pkl", "wb") as f:
        pickle.dump({"rows": rows, "paths": PATHS, "order": ORDER}, f)
    print("system saved to seed3_R2L4_system_d7.pkl")
