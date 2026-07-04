"""
Seed 3 R2L4: substitution engine — derive manifestly positive rows for all 12 orbits at d=7
from the raw CW system by exact algebraic substitution (each derived row is PROVED: it is
obtained from valid identities by substitution only).

Expression = {(rep, shift): {(ypow,qpow): int}}   meaning  Sum coeff y^j q^a G_rep(y q^shift)
Row = (target_rep, expression, derivation_log)    meaning  G_target(y) = expression

Moves: substitute a known row (raw or derived-positive) into any term.
Stage 1: (a,0,0)-types (raw row already positive, single term).
Stage 2: |I|=2 zero-containing — greedy head-cancellation (Substitution Lemma, all rotation
         variants kept).
Stage 3: cores — beam search over substitution sequences.
Every accepted row is verified numerically against the g-engine (PREC window).
"""
import sys, json, itertools, heapq
from collections import defaultdict
sys.setrecursionlimit(10000)
exec(open('seed3_R2L4_engine.py').read().split('# ---------------- main verification')[0])

D = 7; NMAX = 6
MAXSHIFT = 9
print("solving g (quiet) ...", flush=True)
g = solve_g(D, NMAX, verbose=False)
REPS = orbit_reps(D)
CORES = [c for c in REPS if all(x > 0 for x in c)]
ZC = [c for c in REPS if not all(x > 0 for x in c)]
print("cores:", CORES, "\nzero-containing:", ZC, flush=True)

# ---------- expression algebra ----------
def canon(c): return orbit_rep(c)

def raw_expr(c):
    """raw CW row of the specific rotation c, canonicalized reps."""
    E = defaultdict(lambda: defaultdict(int))
    for (cp, s, coeff) in raw_row(c):
        for k, v in coeff.items():
            E[(canon(cp), s)][k] += v
    return {k: dict(v) for k, v in E.items()}

def eclean(E):
    out = {}
    for k, ydict in E.items():
        yd = {kk: vv for kk, vv in ydict.items() if vv}
        if yd: out[k] = yd
    return out

def eadd(E, key, ydict, mult_ydict=None):
    """E[key] += ydict (optionally multiplied by mult_ydict)"""
    tgt = E.setdefault(key, {})
    if mult_ydict is None:
        for k, v in ydict.items(): tgt[k] = tgt.get(k, 0) + v
    else:
        for (j1, a1), v1 in ydict.items():
            for (j2, a2), v2 in mult_ydict.items():
                k = (j1+j2, a1+a2)
                tgt[k] = tgt.get(k, 0) + v1*v2

def subst(E, key, rowexpr):
    """substitute row (for profile key[0], shift s=key[1]) into E at term key.
    rowexpr is for G_p(y); at yq^s: y^j q^a -> y^j q^{a+j*s}, shifts add s."""
    p, s = key
    C = E[key]
    E2 = {k: dict(v) for k, v in E.items()}
    del E2[key]
    for (pt, st), m in rowexpr.items():
        mshift = {(j, a + j*s): v for (j, a), v in m.items()}
        eadd(E2, (pt, st + s), C, mshift)
    return eclean(E2)

def negmass(E):
    return sum(-v for yd in E.values() for v in yd.values() if v < 0)
def esize(E):
    return sum(len(yd) for yd in E.values())
def is_positive_row(E):
    return all(v >= 0 for yd in E.values() for v in yd.values()) and \
           all(s >= 1 for (_, s) in E) and all(s <= MAXSHIFT for (_, s) in E)

def ekey(E):
    return tuple(sorted((k, tuple(sorted(yd.items()))) for k, yd in E.items()))

# ---------- numeric verification ----------
def eval_expr_level(E, n):
    """[y^n] of E as truncated series (list)."""
    acc = snew()
    for (p, s), yd in E.items():
        for (j, a), v in yd.items():
            if n-j < 0: continue
            sh = a + s*(n-j)
            if sh < PREC: sadd(acc, g[n-j][p], v, sh)
    return acc

def verify_row(target, E, nmax=NMAX):
    for n in range(0, nmax+1):
        lhs = g[n][target]
        rhs = eval_expr_level(E, n)
        # compare within safe window: shifts fine, exact
        if lhs != rhs:
            return False
    return True

# ---------- known rows ----------
ROWS = defaultdict(list)   # rep -> list of (expr, tag)

def add_row(rep, E, tag, check=True):
    if check:
        assert verify_row(rep, E), f"row FAILED numeric check: {rep} {tag}"
    k = ekey(E)
    for (E0, t0) in ROWS[rep]:
        if ekey(E0) == k: return False
    ROWS[rep].append((E, tag))
    return True

RAWS = {}  # rotation-specific raw rows, list per rep
RAWLIST = []
for c in profiles(D):
    E = eclean(raw_expr(c))
    RAWLIST.append((canon(c), E, f"raw{c}"))

def head_of(E):
    """terms at shift 1 with y^0 coefficient (the 'heads')"""
    return [(p, yd.get((0, 0), 0)) for (p, s), yd in E.items() if s == 1 and (0, 0) in yd]

# ---------- Stage 1+2: zero-containing rows by greedy head-cancellation ----------
def try_positive_derivation(startE, target, avail_rows, maxdepth=8):
    """greedy: while negatives, try all single substitutions with a known positive row;
    pick the one minimizing (negmass, size). Returns (E, log) or None."""
    E = startE; log = []
    for depth in range(maxdepth):
        if is_positive_row(E): return E, log
        best = None
        for key in list(E):
            p, s = key
            for (rowE, tag) in avail_rows.get(p, []):
                if any(st + s > MAXSHIFT for (_, st) in rowE): continue
                E2 = subst(E, key, rowE)
                sc = (negmass(E2), esize(E2))
                if best is None or sc < best[0]:
                    best = (sc, E2, (key, tag))
        if best is None: return None
        if best[0][0] >= negmass(E):   # no progress
            return None
        E = best[1]; log.append(best[2])
    return (E, log) if is_positive_row(E) else None

print("\n=== Stage 1+2: zero-containing rows ===", flush=True)
# iterate passes until closure; use rotation-specific raw rows as starting points
POS = defaultdict(list)  # rep -> [(E, tag)]
for _pass in range(6):
    added = 0
    for c in profiles(D):
        if all(x > 0 for x in c): continue
        rep = canon(c)
        E0 = eclean(raw_expr(c))
        if is_positive_row(E0):
            if add_row(rep, E0, f"raw{c} (already positive)"):
                POS[rep].append((E0, f"raw{c}")); added += 1
            continue
        res = try_positive_derivation(E0, rep, POS)
        if res:
            E, log = res
            tag = f"from raw{c} via {[t for _, t in log]}"
            if add_row(rep, E, tag):
                POS[rep].append((E, tag)); added += 1
    print(f"pass {_pass}: added {added} rows; reps covered: {sum(1 for r in ZC if ROWS[r])}/{len(ZC)}", flush=True)
    if added == 0: break

for rep in ZC:
    print(f"  {rep}: {len(ROWS[rep])} positive row variant(s)")
    for E, tag in ROWS[rep][:4]:
        heads = [(p, s) for (p, s), yd in sorted(E.items()) if (0,0) in yd]
        print(f"    heads {heads}  [{tag[:100]}]")

# ---------- Stage 2b: enumerate MORE zc variants by bounded DFS ----------
print("\n=== Stage 2b: exhaustive zc variant enumeration (DFS) ===", flush=True)
def dfs_variants(E, target, avail_rows, maxdepth, out, seen, cap=40):
    if len(out) >= cap: return
    k = ekey(E)
    if k in seen: return
    seen.add(k)
    if is_positive_row(E):
        out.append(E); return
    if maxdepth == 0: return
    nm = negmass(E)
    cands = []
    for key in list(E):
        p, s = key
        for (rowE, tag) in avail_rows.get(p, []):
            if any(st + s > MAXSHIFT for (_, st) in rowE): continue
            E2 = subst(E, key, rowE)
            if negmass(E2) < nm or (negmass(E2) == nm and esize(E2) < esize(E)):
                cands.append((negmass(E2), esize(E2), key, E2))
    cands.sort(key=lambda t: (t[0], t[1]))
    for _, _, key, E2 in cands[:6]:
        dfs_variants(E2, target, avail_rows, maxdepth-1, out, seen, cap)

for _pass in range(3):
    added = 0
    for c in profiles(D):
        if all(x > 0 for x in c): continue
        rep = canon(c)
        out = []; seen = set()
        dfs_variants(eclean(raw_expr(c)), rep, POS, 8, out, seen)
        for E in out:
            if add_row(rep, E, f"dfs from raw{c}"):
                POS[rep].append((E, f"dfs raw{c}")); added += 1
    print(f"variant pass: added {added}", flush=True)
    if added == 0: break
for rep in ZC:
    heads = sorted(set(tuple(sorted(p for (p, s), yd in E.items() if s == 1 and (0,0) in yd)) for E, _ in ROWS[rep]))
    print(f"  {rep}: {len(ROWS[rep])} variants; head-sets {heads}")

# ---------- Stage 3: core rows via beam search ----------
print("\n=== Stage 3: core rows (beam search) ===", flush=True)
RAW_BY_REP = defaultdict(list)
for (rep, E, tag) in RAWLIST:
    RAW_BY_REP[rep].append((E, tag))

def all_avail(p):
    return POS.get(p, []) + RAW_BY_REP.get(p, [])

def beam_search(target_rotations, beamwidth=40, maxdepth=10):
    starts = [eclean(raw_expr(c)) for c in target_rotations]
    beam = [( (negmass(E), esize(E)), E, [] ) for E in starts]
    seen = set(ekey(E) for E in starts)
    found = []
    for depth in range(maxdepth):
        nxt = []
        for (sc, E, log) in beam:
            for key in list(E):
                p, s = key
                for (rowE, tag) in all_avail(p):
                    if any(st + s > MAXSHIFT for (_, st) in rowE): continue
                    E2 = subst(E, key, rowE)
                    if esize(E2) > 120: continue
                    k = ekey(E2)
                    if k in seen: continue
                    seen.add(k)
                    log2 = log + [(key, tag)]
                    if is_positive_row(E2):
                        found.append((E2, log2)); continue
                    nxt.append(((negmass(E2), esize(E2)), E2, log2))
        if found: return found
        nxt.sort(key=lambda t: t[0])
        beam = nxt[:beamwidth]
        if not beam: break
        print(f"    depth {depth+1}: beam best negmass={beam[0][0][0]} size={beam[0][0][1]} (beam {len(beam)})", flush=True)
    return found

core_rows = {}
for rep in CORES:
    rots = [c for c in profiles(D) if canon(c) == rep]
    print(f"  core {rep}: searching ...", flush=True)
    found = beam_search(rots)
    if not found:
        print(f"  core {rep}: NOT FOUND at depth<=10", flush=True)
        continue
    # verify and keep the smallest
    ok = []
    for E, log in found:
        if verify_row(rep, E):
            ok.append((esize(E), E, log))
        else:
            print(f"  core {rep}: FOUND ROW FAILED NUMERIC CHECK (bug!)", flush=True)
    ok.sort(key=lambda t: t[0])
    if ok:
        sz, E, log = ok[0]
        core_rows[rep] = (E, log)
        add_row(rep, E, f"beam: {log}")
        POS[rep].append((E, f"beam"))
        print(f"  core {rep}: FOUND {len(ok)} verified positive rows; smallest size {sz}", flush=True)
        for (p, s), yd in sorted(E.items()):
            print(f"      G_{p}(yq^{s}) * {yd}")

print(f"\ncores found: {len(core_rows)}/5")
