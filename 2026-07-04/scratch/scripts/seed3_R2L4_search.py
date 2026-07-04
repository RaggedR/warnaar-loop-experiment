"""
Seed 3 R2L4 Phase 3: beam search for positive core rows at d=7.

State = Expr (canonicalized). Move = substitute a library row into a full term.
Every move is exact => any positive endpoint is a PROVED row for the target.
"""
import sys
from collections import defaultdict
from seed3_R2L4_construct import (
    D, NMAX, rep, REPS, CORES, ZEROS, raw_row_expr, substitute, negatives,
    is_positive_row, head_of, verify_row, derive_zero_rows, show, load_g)

SMAX = 12      # max shift allowed
YMAX = 4      # max y-degree in coefficients
TMAX = 60     # max number of (rep, shift) terms

def canon(expr):
    return tuple(sorted((k, tuple(sorted(m.items()))) for k, m in expr.items()))

def score(expr):
    negs = negatives(expr)
    y0 = sum(1 for _, (j, a), v in negs if j == 0)
    mass = sum(-v * (1.0 / (1 + j + a)) for _, (j, a), v in negs)
    return (y0, len(negs), mass, len(expr))

def ok_state(expr):
    if len(expr) > TMAX:
        return False
    for (r, s), m in expr.items():
        if s > SMAX:
            # only prune if this term is negative or huge; positive deep terms fine
            if any(v < 0 for v in m.values()):
                return False
        if any(j > YMAX for (j, a) in m):
            return False
    return True

def search(target, library, beam_width=400, max_depth=10, verbose=False):
    """library: dict rep -> list of (tag, row_expr). Returns list of (expr, path)."""
    start = raw_row_expr(target)
    frontier = [(score(start), start, [])]
    seen = {canon(start)}
    goals = []
    for depth in range(max_depth):
        newf = []
        for sc, expr, path in frontier:
            for key in list(expr):
                r0, s0 = key
                for tag, row in library.get(r0, []):
                    new = substitute(expr, key, row)
                    c = canon(new)
                    if c in seen:
                        continue
                    seen.add(c)
                    if not ok_state(new):
                        continue
                    npath = path + [(key, tag)]
                    if is_positive_row(new):
                        ok, nn = verify_row(target, new)
                        goals.append((new, npath, ok))
                        if verbose:
                            print(f"  GOAL depth {depth+1} verify={ok} head={head_of(new)}")
                        continue
                    newf.append((score(new), new, npath))
        newf.sort(key=lambda t: t[0])
        frontier = newf[:beam_width]
        if verbose:
            print(f" depth {depth+1}: frontier {len(frontier)}, goals {len(goals)}, "
                  f"best {frontier[0][0] if frontier else None}", flush=True)
        if goals and depth >= 2:
            break
        if not frontier:
            break
    return goals

def build_library(core_rows):
    lib = defaultdict(list)
    zr = derive_zero_rows()
    for r in ZEROS:
        # A/B coincide; take first
        lib[r].append((f"R[{r}]", zr[r][0][0]))
    for r in REPS:
        lib[r].append((f"raw[{r}]", raw_row_expr(r)))
    for r, rows in core_rows.items():
        for tag, e in rows:
            lib[r].append((tag, e))
    return lib

if __name__ == "__main__":
    load_g()
    core_rows = defaultdict(list)   # rep -> [(tag, expr)]
    order_found = []
    for rnd in range(1, 6):
        lib = build_library(core_rows)
        progress = False
        for c in CORES:
            if core_rows[c]:
                continue
            print(f"round {rnd}: searching core {c} ...", flush=True)
            goals = search(c, lib, beam_width=400, max_depth=10, verbose=True)
            goodgoals = [(e, p) for (e, p, ok) in goals if ok]
            bad = [1 for (_, _, ok) in goals if not ok]
            if bad:
                print(f"  WARNING: {len(bad)} goal(s) FAILED verification (bug!)")
            if goodgoals:
                # keep up to 3 distinct heads
                byhead = {}
                for e, p in goodgoals:
                    byhead.setdefault(head_of(e), (e, p))
                for hd, (e, p) in byhead.items():
                    tag = f"C[{c}]h{hd}"
                    core_rows[c].append((tag, e))
                    print(f"  FOUND positive row for {c}, head={hd}, depth={len(p)}")
                    print(f"    path: {p}")
                    print(f"    row: {show(e)}")
                order_found.append(c)
                progress = True
        if all(core_rows[c] for c in CORES):
            print("ALL CORES DONE")
            break
        if not progress:
            print(f"round {rnd}: no progress; stopping")
            break
    print("summary:", {c: [t for t, _ in core_rows[c]] for c in CORES})
