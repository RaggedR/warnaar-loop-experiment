#!/usr/bin/env python3
"""EDGE THEOREM certification script (Seed 6 R2L4).

Statement being certified:
  For all j not in {2,4} and all a >= 0:  (i) D(j,a) := har_edge(j,a)-har_edge(j,a-1) >= 0
  for a >= 1, and (ii) har_edge(j,0) >= 0.  Hence har_edge(j,a) >= 0 and is nondecreasing
  in a: S1 and (full, residue-free) coordinate monotonicity hold on region <= 1
  (at most one coordinate < j-1), for ALL d (including 3|d).

Certification scheme (backing the hand-proved quasipolynomiality lemma):
  chambers  LOW: 1 <= a < j/2;  WALL: a = j/2 (j even);  HIGH: j/2 < a <= j-4;
            TOP: a in {j-3, j-2, j-1} (D(j,a) = 0 for a >= j);
  periods: j mod 12, a mod 6 (a mod 12 for TOP constants keyed by (j mod 12, j-a)).
  Each class: exact interpolation (degree <= 2 for D; degree <= 3 for F0(j) := har_edge(j,0)),
  verification on an independent grid, then positivity by nonneg coefficients in
  chamber-adapted nonneg coordinates (fallback: exact vertex/boundary minimization).
"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from seed6_R2L4_edge import har_edge
from fractions import Fraction as F
from itertools import product

def D(j, a): return har_edge(j, a) - har_edge(j, a - 1)

MONS2 = [(0,0),(1,0),(0,1),(2,0),(1,1),(0,2)]

def solve(pts, mons):
    A = [[F(j**p * a**q) for (p,q) in mons] + [F(val)] for (j,a,val) in pts]
    n = len(mons); r = 0
    for c in range(n):
        piv = next((i for i in range(r, len(A)) if A[i][c] != 0), None)
        if piv is None: return None
        A[r], A[piv] = A[piv], A[r]
        A[r] = [x / A[r][c] for x in A[r]]
        for i in range(len(A)):
            if i != r and A[i][c] != 0:
                A[i] = [x - A[i][c]*y for x, y in zip(A[i], A[r])]
        r += 1
        if r == n: break
    for i in range(r, len(A)):
        if A[i][n] != 0: return None
    return [A[i][n] for i in range(n)]

def evalp(sol, j, a, mons=MONS2):
    return sum(c * j**p * a**q for c, (p,q) in zip(sol, mons))

def subs_poly(sol, jc, ac, mons=MONS2):
    """Substitute j = jc(u,v), a = ac(u,v) (linear with Fraction coeffs, as (const, cu, cv))
    into the poly; return dict (pu,pv) -> coeff."""
    out = {}
    def addmul(dct, key, val):
        dct[key] = dct.get(key, F(0)) + val
    for c, (p, q) in zip(sol, mons):
        if c == 0: continue
        # expand (jc)^p (ac)^q
        terms = {(0,0): F(1)}
        for lin, power in ((jc, p), (ac, q)):
            for _ in range(power):
                new = {}
                for (pu, pv), cv0 in terms.items():
                    addmul(new, (pu, pv), cv0 * lin[0])
                    addmul(new, (pu+1, pv), cv0 * lin[1])
                    addmul(new, (pu, pv+1), cv0 * lin[2])
                terms = new
        for k, v in terms.items():
            addmul(out, k, c * v)
    return {k: v for k, v in out.items() if v != 0}

report = {"fit_fail": [], "grid_bad": [], "pos_fail": [], "notes": []}

# ---------- fit LOW / HIGH ----------
polys = {}
for ch in ('low', 'high'):
    for rj in range(12):
        for ra in range(6):
            pts = []
            js = [j for j in range(50, 700) if j % 12 == rj][:6]
            for j in js:
                cnt = 0
                for a in range(1, j-3):
                    if a % 6 != ra: continue
                    if ch == 'low' and not (7 <= a <= (j-1)//2 - 7): continue
                    if ch == 'high' and not (j//2 + 7 <= a <= j - 10): continue
                    pts.append((j, a, D(j, a))); cnt += 1
                    if cnt >= 4: break
            sol = solve(pts, MONS2)
            if sol is None: report["fit_fail"].append((ch, rj, ra))
            polys[(ch, rj, ra)] = sol
print("LOW/HIGH fit failures:", report["fit_fail"])

# ---------- fit WALL (a = j/2, j even): 1-D in a, degree <= 2, period: a mod 6 with j=2a
wall = {}
for ra in range(6):
    pts = [(2*a, a, D(2*a, a)) for a in range(30 + ra, 30 + ra + 6*8, 6)]
    sol = solve(pts, MONS2[:1] + [(0,1),(0,2)])  # 1, a, a^2
    wall[ra] = sol
    if sol is None: report["fit_fail"].append(('wall', ra))
print("WALL fits ok:", all(wall[r] is not None for r in range(6)))

# ---------- fit TOP: a = j-g, g in {1,2,3}: constants? check
top = {}
for g in (1, 2, 3):
    for rj in range(12):
        vals = {D(j, j-g) for j in range(40 + rj, 40 + rj + 12*10, 12) if (40+rj) % 12 == rj}
        js = [j for j in range(36, 200) if j % 12 == rj]
        vals = [D(j, j-g) for j in js]
        if len(set(vals)) == 1:
            top[(g, rj)] = vals[0]
        else:
            # maybe linear in j; fit 1-D linear
            sol = solve([(j, j-g, D(j, j-g)) for j in js[:4]], [(0,0),(1,0)])
            top[(g, rj)] = ('lin', sol)
            report["notes"].append(("top nonconstant", g, rj, vals[:4]))
print("TOP entries:", {k: v for k, v in top.items() if not isinstance(v, int)} or "all constant")
print("TOP constants:", sorted((k, v) for k, v in top.items() if isinstance(v, int)))

# ---------- fit F0(j) = har_edge(j, 0): cubic per j mod 12 ----------
MONS1 = [(0,0),(1,0),(2,0),(3,0)]
f0 = {}
for rj in range(12):
    js = [j for j in range(24, 400) if j % 12 == rj][:4]
    sol = solve([(j, 0, har_edge(j, 0)) for j in js], MONS1)
    f0[rj] = sol
    if sol is None: report["fit_fail"].append(('f0', rj))
print("F0 fits ok:", all(f0[r] is not None for r in range(12)))

# ---------- global model + big grid verification ----------
def model_D(j, a):
    if a >= j: return 0
    if a >= j - 3:
        t = top[(j - a, j % 12)]
        return t if isinstance(t, int) else evalp(t[1], j, a, [(0,0),(1,0)])
    if 2*a < j: return evalp(polys[('low', j % 12, a % 6)], j, a)
    if 2*a == j: return evalp(wall[a % 6], j, a, MONS2[:1] + [(0,1),(0,2)])
    return evalp(polys[('high', j % 12, a % 6)], j, a)

def model_F0(j): return evalp(f0[j % 12], j, 0, MONS1)

JV = 320
bad = 0
for j in range(24, JV + 1):   # j < 24 handled by the exhaustive direct check below
    if model_F0(j) != har_edge(j, 0):
        bad += 1; report["grid_bad"].append(('f0', j))
    for a in range(1, j + 2):
        if model_D(j, a) != D(j, a):
            bad += 1
            if bad < 8: report["grid_bad"].append((j, a, model_D(j, a), D(j, a)))
print(f"FULL model verification j <= {JV}, all a: mismatches = {bad}")

# ---------- positivity certificates ----------
# LOW chamber: a >= 1, j >= 2a+1 -> j = 2u + v + 3, a = u + 1, u,v >= 0
#   (u = a-1, v = j-2a-1)
# HIGH chamber: j/2 < a <= j-4 -> 2a-j >= 1, j-a >= 4:
#   u = 2a-j-1 >= 0, v = j-a-4 >= 0  => j = u + 2v + 9? check: a = u+v+5, j = u+2v+9?
#   2a-j = u+1 ✓ ; j-a = v+4 ✓.
LOWSUB  = ((F(3), F(2), F(1)), (F(1), F(1), F(0)))    # j = 3+2u+v, a = 1+u
HIGHSUB = ((F(9), F(1), F(2)), (F(5), F(1), F(1)))    # j = 9+u+2v, a = 5+u+v
def check_pos(sol, sub, name):
    coeffs = subs_poly(sol, sub[0], sub[1])
    neg = {k: v for k, v in coeffs.items() if v < 0}
    if not neg: return True
    report["pos_fail"].append((name, neg))
    return False

# Class-aware certificates: for each residue class find minimal (j0,a0) in the chamber
# and class; the class lattice inside the chamber is {(j0+12s+..)}: we use exact steps
# (j,a) = (j0 + 12 s + 12 t, a0 + 6 s + 12 t)?? -- simpler: chamber coords.
# LOW: u = a-1, v = j-2a-1; class fixes u mod 6 and v mod 12; lattice = (u0+6s, v0+12t)
#   with (s,t) >= 0 integers, u0,v0 minimal nonneg class reps... but not every (s,t)
#   combination corresponds to integer (j,a)? j = v+2u+3, a = u+1: any (u,v) integer
#   gives integer (j,a), and class membership <=> u,v residues. OK.
# HIGH: u = 2a-j-1, v = j-a-4; j = u+2v+9, a = u+v+5; class: a mod 6, j mod 12 <=>
#   (u+v) mod 6 and (u+2v) mod 12 -- lattice generated over the (u,v) residue pairs
#   mod 12: enumerate all (u0,v0) in [0,12)^2 in the class, certify each on (12s,12t).
def class_pos(sol, ch, rj, ra, name):
    okall = True
    for u0 in range(12):
        for v0 in range(12):
            if ch == 'low':
                j = v0 + 2*u0 + 3; a = u0 + 1
            else:
                j = u0 + 2*v0 + 9; a = u0 + v0 + 5
            if j % 12 != rj or a % 6 != ra: continue
            # expand around (u0, v0) with steps 12
            jj = (F(j), F(24) if ch=='low' else F(12), F(12) if ch=='low' else F(24))
            aa = (F(a), F(12), F(0)) if ch=='low' else (F(a), F(12), F(12))
            coeffs = subs_poly(sol, jj, aa)
            neg = {k: v for k, v in coeffs.items() if v < 0}
            if neg:
                okall = False; report["pos_fail"].append((name, (u0, v0), neg))
    return okall

allpos = True
for (ch, rj, ra), sol in polys.items():
    if sol is None: continue
    if not class_pos(sol, ch, rj, ra, (ch, rj, ra)): allpos = False
print("LOW/HIGH class-aware positivity certificates:", "ALL PASS" if allpos else f"FAILURES: {report['pos_fail'][:6]} ...")

# WALL: j = 2a, a >= 1; class = a mod 6; expand around a0 in class, steps 6
wallpos = True
WMONS = MONS2[:1] + [(0,1),(0,2)]
for ra, sol in wall.items():
    for a0 in range(1, 13):
        if a0 % 6 != ra: continue
        coeffs = subs_poly(sol, (F(0),F(0),F(0)), (F(a0), F(6), F(0)), WMONS)
        neg = {k: v for k, v in coeffs.items() if v < 0}
        if neg:
            wallpos = False; report["pos_fail"].append(('wall', ra, a0, neg))
print("WALL class-aware positivity:", wallpos)

# TOP: constants >= 0?
toppos = all((v >= 0) if isinstance(v, int) else False for v in top.values())
print("TOP nonneg:", toppos)

# F0: cubic per class, positivity for j >= 24 via expansion at base 24+((rj-24)%12)
f0pos = True
for rj, sol in f0.items():
    base = 24 + ((rj - 24) % 12)
    coeffs = subs_poly(sol, (F(base), F(12), F(0)), (F(0),F(0),F(0)), MONS1)
    neg = {k: v for k, v in coeffs.items() if v < 0}
    if neg:
        f0pos = False; report["pos_fail"].append(('f0', rj, neg))
print("F0 coefficient positivity (j >= 24):", f0pos)

# ---------- exhaustive small range (covers all chamber corners & small j) ----------
small_bad = [(j, a) for j in range(0, 80) if j not in (2, 4)
             for a in range(0, j + 2)
             if har_edge(j, a) < 0 or (a >= 1 and D(j, a) < 0)]
print("exhaustive j < 60 direct check failures:", small_bad)

print()
ok = (not report["fit_fail"] and bad == 0 and allpos and wallpos and toppos and f0pos
      and not small_bad)
print("EDGE THEOREM CERTIFICATE:", "COMPLETE" if ok else "INCOMPLETE -- see report")
for k, v in report.items():
    if v: print(k, v[:8])
