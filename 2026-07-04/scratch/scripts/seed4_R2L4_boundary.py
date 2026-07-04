#!/usr/bin/env python3
"""(M3) FINITE CASE CHECK for the per-boundary ballot condition (2a-i).

Reduction proved in scratch [t3]: at a boundary s>=1 of a v-chain with
delta = k_s - k_{s+1} >= 1 and x = -k_s, the boundary letters are, per slot
j in {0,1,2} (F(y) = d*(y-x) - 3*Offext(y) - 3s, period 3):
  ')' at T = F(x+j),           color (s + Offext(x+j)) mod d,        iff w_j > 0
  '(' at T = F(x+j) - d*delta, color same,                            iff w_{(j-delta)%3} > 0
where w_i = Offext(x+i+delta) - Offext(x+i)  (the window).
Everything is invariant under x -> x+3 (F periodic; colors shift by d = 0 mod d;
w unchanged), so x ranges over {0,-1,-2}. All T-comparisons and existence flags
depend only on (c, xi, delta). We exhaustively enumerate:
  - ALL compositions c of d into 3 nonneg parts, for d = 1..12  (covers every
    zero pattern with generic and degenerate value relations), plus a batch of
    large generic c per zero pattern,
  - xi in {0,1,2}  (x = -xi), delta in 1..9, s in {1,2} (color shift only).
CHECK: per color, letters of the boundary sorted by T pass the ballot condition
(every prefix has #'(' >= #')').  Boundary s=0 has no removables (nothing to check).
ALSO: end-to-end re-verification of discovery (E): full v-chain words have
every ')' immediately preceded by '(' -> eps_kappa = 0, on a wide sweep.
"""
import sys, itertools
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/scratch/scripts')
from seed5_R2L3_crystal import boxes_add_remove, reduce_brackets

def offext(c, x):
    d = sum(c); base = [0, c[1], c[1]+c[2]]
    q, r = divmod(x, 3)
    return q*d + base[r]

def boundary_ballot(c, xi, delta, s):
    """Build boundary letters and check per-color ballot. Returns list of failures."""
    d = sum(c)
    if d == 0: return []
    x = -xi
    F = lambda y: d*(y - x) - 3*offext(c, y) - 3*s
    letters = []  # (T, type, color)
    w = [offext(c, x+i+delta) - offext(c, x+i) for i in range(3)]
    for j in range(3):
        col = (s + offext(c, x+j)) % d
        if w[j] > 0:
            letters.append((F(x+j), 0, col))          # ')'
        if w[(j - delta) % 3] > 0:
            letters.append((F(x+j) - d*delta, 1, col)) # '('
    fails = []
    for kappa in set(l[2] for l in letters):
        seq = sorted([l for l in letters if l[2] == kappa])
        # tie check: no equal T within a color
        Ts = [t for (t,_,_) in seq]
        if len(set(Ts)) != len(Ts):
            fails.append((c, xi, delta, s, kappa, 'TIE'))
        depth = 0
        for (T, typ, _) in seq:
            depth += 1 if typ == 1 else -1
            if depth < 0:
                fails.append((c, xi, delta, s, kappa, 'BALLOT'))
                break
    return fails

def all_c(dmax):
    for d in range(1, dmax+1):
        for c0 in range(d+1):
            for c1 in range(d+1-c0):
                yield (c0, c1, d-c0-c1)

def generic_batch():
    vals = [23, 17, 11]  # distinct generic values
    out = []
    for pat in itertools.product([0,1], repeat=3):
        if pat == (0,0,0): continue
        c = tuple(vals[i] if pat[i] else 0 for i in range(3))
        out.append(c)
        # also permuted magnitudes
        out.append(tuple(vals[2-i] if pat[i] else 0 for i in range(3)))
    return out

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def check_E(c, ks):
    """Full v-chain: every ')' immediately preceded by '(' in each color word."""
    m = len(ks) + 1
    d = sum(c)
    A = tuple(vvec(c, k) for k in ks) + ((0,)*3,)
    bad = 0
    for kappa in range(d):
        br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
        for idx, (T, typ, pos) in enumerate(br):
            if typ == 0:  # ')'
                if idx == 0 or br[idx-1][1] != 1:
                    bad += 1
        adds, rems = reduce_brackets(br)
        if rems: bad += 100
    return bad

if __name__ == "__main__":
    total = fails = 0
    allf = []
    cs = list(all_c(12)) + generic_batch()
    for c in cs:
        for xi in range(3):
            for delta in range(1, 10):
                for s in (1, 2):
                    total += 1
                    f = boundary_ballot(c, xi, delta, s)
                    if f:
                        fails += 1; allf.extend(f)
    print(f"[boundary ballot] cases={total} profiles={len(cs)} FAILURES={fails}")
    for f in allf[:20]: print("  FAIL:", f)

    # (E) end-to-end on full v-chains
    badE = casesE = 0
    for d in range(2, 9):
        for c in [cc for cc in all_c(d) if sum(cc) == d][:12]:
            for ks in [[1], [2], [3,1], [2,2], [5,2], [4,3,1], [3,3,3], [6,1,1], [2,1,1,1]]:
                casesE += 1
                badE += check_E(c, list(ks))
    print(f"[E full v-chain words] cases={casesE} violations={badE}")
