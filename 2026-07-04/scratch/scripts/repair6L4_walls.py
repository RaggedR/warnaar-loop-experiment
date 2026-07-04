#!/usr/bin/env python3
"""Repair of erratum E4 (Lemma 7.3, wall enumeration) -- pinning certificate.

The switch-locus enumeration (see proofs/prove-seed6-layer4.tex, Lemma 7.3, and
scratch/repair-seed6-layer4.md) shows: for j >= 15, on each residue class
(j,a) mod 12, phi_j(a) is a polynomial of degree <= 3 on each cell of the
arrangement of the EXPLICIT wall list
    W = {2a=j+t: |t|<=2} u {4a=j+t: |t|<=2} u {a=t: t<=2} u {a=j-t: 2<=t<=6},
and on each wall line the restriction is a quasi-polynomial of degree <= 3 and
period 12 in the line parameter.  (All pairwise intersections of walls have
j <= 14, so the cell structure is stable for j >= 15.)

This script supplies the finite identification (pinning) step, with generous
offset margins |t| <= 8:

  STEP 1  refit the 288 LOW/HIGH chamber polynomials and 24 strip polynomials
          exactly as in seed6_R2L4_r1poly.pipeline (exact Fractions), re-assert
          the cubic parts.
  STEP 2  sub-chamber pinning: for each residue class, fit a degree-<=3
          polynomial from points lying ONLY in the open sub-chamber
             LOW-A = {4a <= j-8},  LOW-B = {4a >= j+8, 2a <= j-8},
             HIGH' = {2a >= j+8, a <= j-9}
          (all with j >= 15); require FULL RANK (10) so the polynomial is the
          unique one through those points, and assert it equals the global
          LOW (resp. LOW, HIGH) polynomial.  This proves the polynomial on each
          side of every 4a=j+t wall is the fitted one -- the 4a-family carries
          no jump.
  STEP 3  wall-line pinning: for every wall family and offset (|t| <= 8,
          superset of the derived |t| <= 6), every residue class of the line
          parameter mod 12, verify pred(j,a) == phi_fast(j,a) at >= 10 points
          with j >= 15 (only 4 are needed to pin a cubic).  This proves each
          chamber polynomial remains valid ON the adjacent wall lines.

All arithmetic exact (int / Fraction).  Exit 0 iff everything passes.
"""
from fractions import Fraction
import sys, time
from seed6_R2L4_r1poly import phi_fast, MONO, poly_eval

def mono_eval(j, a):
    return [Fraction(j)**dj * Fraction(a)**da for (dj, da) in MONO]

def solve_rank(pts, vals):
    """Gaussian elimination over Fraction.  Returns (coeffs, rank, consistent).
    coeffs is the unique solution if rank == 10 and consistent, else None."""
    n = len(MONO)
    A = [mono_eval(j, a) + [Fraction(v)] for (j, a), v in zip(pts, vals)]
    row = 0
    for col in range(n):
        p = next((r for r in range(row, len(A)) if A[r][col] != 0), None)
        if p is None:
            continue
        A[row], A[p] = A[p], A[row]
        pv = A[row][col]
        A[row] = [x / pv for x in A[row]]
        for r in range(len(A)):
            if r != row and A[r][col] != 0:
                f = A[r][col]
                A[r] = [x - f * y for x, y in zip(A[r], A[row])]
        row += 1
        if row == n:
            break
    rank = row
    consistent = all(A[r][n] == 0 for r in range(rank, len(A)) if all(A[r][c] == 0 for c in range(n)))
    if rank < n or not consistent:
        return None, rank, consistent
    coeffs = [A[i][n] for i in range(n)]
    return coeffs, rank, consistent

def fit1d(js, vals):
    A = [[Fraction(j)**k for k in range(4)] + [Fraction(v)] for j, v in zip(js, vals)]
    row = 0
    for col in range(4):
        p = next((r for r in range(row, len(A)) if A[r][col] != 0), None)
        if p is None:
            return None
        A[row], A[p] = A[p], A[row]
        pv = A[row][col]
        A[row] = [x / pv for x in A[row]]
        for r in range(len(A)):
            if r != row and A[r][col] != 0:
                f = A[r][col]
                A[r] = [x - f * yy for x, yy in zip(A[r], A[row])]
        row += 1
    for r in range(4, len(A)):
        if A[r][4] != 0:
            return None
    return [A[i][4] for i in range(4)]

def main():
    t0 = time.time()
    CUB = {(3, 0): Fraction(1, 24), (2, 1): Fraction(1, 4),
           (1, 2): Fraction(-1, 4), (0, 3): Fraction(1, 12)}

    # ---------------- STEP 1: global fits (as in r1poly.pipeline) ----------------
    LOW, HIGH = {}, {}
    for rj in range(12):
        for ra in range(12):
            pL, pH = [], []
            for j in range(80, 200):
                if j % 12 != rj:
                    continue
                for a in range(ra, j - 3, 12):
                    (pL if 2 * a <= j - 4 else pH if (2 * a >= j + 4 and a <= j - 6) else []).append((j, a))
            cL, rkL, okL = solve_rank(pL, [phi_fast(j, a) for j, a in pL])
            cH, rkH, okH = solve_rank(pH, [phi_fast(j, a) for j, a in pH])
            assert cL is not None and cH is not None, (rj, ra, rkL, okL, rkH, okH)
            for c in (cL, cH):
                for co, (dj, da) in zip(c, MONO):
                    if dj + da == 3:
                        assert co == CUB[(dj, da)], (rj, ra, dj, da, co)
            LOW[(rj, ra)], HIGH[(rj, ra)] = cL, cH
    print(f"STEP 1: 288 chamber polys refitted (full rank, consistent); cubic parts == j^3 psi(a/j).  [{time.time()-t0:.0f}s]")

    STRIP = {}
    for nn in (2, 3):
        for rj in range(12):
            js = [j for j in range(60, 156) if j % 12 == rj]
            c = fit1d(js, [phi_fast(j, j - nn) for j in js])
            assert c and c[3] == Fraction(1, 8), (nn, rj)
            STRIP[(nn, rj)] = c
    print("STEP 1: 24 strip polys refitted; leading coefficients == 1/8.")

    # ---------------- STEP 2: sub-chamber full-rank pinning ----------------
    def collect(member, jmax=620):
        out = {}
        for rj in range(12):
            for ra in range(12):
                pts = []
                for j in range(15, jmax):
                    if j % 12 != rj:
                        continue
                    for a in range(ra, j - 1, 12):
                        if member(j, a):
                            pts.append((j, a))
                out[(rj, ra)] = pts
        return out

    regions = {
        'LOW-A': (lambda j, a: 4 * a <= j - 8 and a >= 3, LOW),
        'LOW-B': (lambda j, a: 4 * a >= j + 8 and 2 * a <= j - 8, LOW),
        "HIGH2": (lambda j, a: 2 * a >= j + 8 and a <= j - 9, HIGH),
    }
    for name, (member, GLOB) in regions.items():
        pts_by_class = collect(member)
        for key, pts in pts_by_class.items():
            c, rk, ok = solve_rank(pts, [phi_fast(j, a) for j, a in pts])
            assert c is not None, (name, key, len(pts), rk, ok)
            assert c == GLOB[key], (name, key)
        npts = sum(len(p) for p in pts_by_class.values())
        print(f"STEP 2: {name}: all 144 classes full-rank pinned ({npts} pts) and equal to the global fit.")
    print("STEP 2 conclusion: the 4a=j+t walls carry NO polynomial jump (LOW-A == LOW-B).")

    # ---------------- STEP 3: wall-line pinning ----------------
    def pred(j, a):
        if a in (j - 2, j - 3):
            c = STRIP[(j - a, j % 12)]
            return sum(cc * Fraction(j)**k for k, cc in enumerate(c))
        return poly_eval(LOW[(j % 12, a % 12)] if 2 * a < j else HIGH[(j % 12, a % 12)], j, a)

    NPTS = 10          # points per residue class per line (4 pin a cubic)
    total = 0
    lines = []
    for t in range(-8, 9):
        lines.append(('2a-j=%+d' % t, lambda s, t=t: (2 * s - t, s)))   # a=s, j=2s-t
        lines.append(('4a-j=%+d' % t, lambda s, t=t: (4 * s - t, s)))   # a=s, j=4s-t
    for t in range(0, 9):
        lines.append(('a=%d' % t, lambda s, t=t: (s, t)))               # j=s
    for t in range(2, 9):
        lines.append(('j-a=%d' % t, lambda s, t=t: (s + t, s)))         # a=s, j=s+t

    for name, par in lines:
        for r in range(12):
            got = 0
            s = r if r > 0 else 12
            while got < NPTS:
                j, a = par(s)
                s += 12
                if j < 15 or a < 0 or a > j - 2:
                    continue
                assert pred(j, a) == phi_fast(j, a), (name, r, j, a)
                got += 1
                total += 1
    print(f"STEP 3: all wall lines (2a-j, 4a-j offsets |t|<=8; a=t, t<=8; j-a=t, t<=8)")
    print(f"        x 12 residue classes x {NPTS} points, j >= 15: {total} exact matches, 0 mismatches.")

    print(f"ALL PASS  [{time.time()-t0:.0f}s]")
    print("LEMMA 7.3 PINNING CERTIFIED: every wall in the derived list W (offsets <= 6,")
    print("checked to 8) carries the fitted polynomials on both sides and on the line itself.")

if __name__ == '__main__':
    main()
