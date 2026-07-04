"""
Seed 1 R2 L3: the positive difference-closed ladder program.

d=2 fact (predecessor's reframe): with E_{a,m} = sum_j q^{j^2+aj} [m,j],
  (L1) E_{a,m} - E_{a,m-1} = q^{m+a} E_{a+1,m-1},
so the orbit components {E_0, E_1} extend to an infinite family closed under
the operator  f |-> (f_m - f_{m-1}) / q^{m+shift},  every member nonneg.

Program: BFS the surplus family at d=2,4,5 from the orbit components.
For each member f (a sequence of polys over levels m), compute
D_m = f_m - f_{m-1}; test
  (i)  nonnegativity of D_m (FAMILY BREAK if it fails),
  (ii) val(D_m) = m + s for a member-constant shift s,
  (iii) recognition of g_{m-1} = D_m / q^{m+s} as an exact constant-rational
        combination of existing members.
"""
import sys, os
from fractions import Fraction
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seed1_R2L3_engine import padd, psub, pmul, pstr, pneg, H_tower

def val(p):
    return min(p) if p else None

def pshift(p, k):
    assert all(e >= k for e in p), "inexact q^k division"
    return {e-k: v for e, v in p.items()}

def poly_to_vec(p, deg):
    return [Fraction(p.get(i, 0)) for i in range(deg+1)]

def solve_combo(target_seq, member_seqs, levels):
    """constant rationals lam_j with target[m] = sum_j lam_j member_j[m] for m in levels."""
    cols = len(member_seqs)
    rows, rhs = [], []
    for m in levels:
        deg = max([max(target_seq[m], default=0)] +
                  [max(s[m], default=0) for s in member_seqs])
        tv = poly_to_vec(target_seq[m], deg)
        mv = [poly_to_vec(s[m], deg) for s in member_seqs]
        for i in range(deg+1):
            rows.append([mv[j][i] for j in range(cols)])
            rhs.append(tv[i])
    n = len(rows)
    aug = [rows[i] + [rhs[i]] for i in range(n)]
    piv_rows = []
    r = 0
    for c in range(cols):
        pr = next((i for i in range(r, n) if aug[i][c] != 0), None)
        if pr is None: continue
        aug[r], aug[pr] = aug[pr], aug[r]
        pv = aug[r][c]
        aug[r] = [x / pv for x in aug[r]]
        for i in range(n):
            if i != r and aug[i][c] != 0:
                f = aug[i][c]
                aug[i] = [x - f*y for x, y in zip(aug[i], aug[r])]
        piv_rows.append(c); r += 1
    for i in range(r, n):
        if aug[i][cols] != 0: return None
    sol = [Fraction(0)] * cols
    for i, c in enumerate(piv_rows):
        sol[c] = aug[i][cols]
    for i in range(n):
        if sum(rows[i][j]*sol[j] for j in range(cols)) != rhs[i]: return None
    return sol

def ladder(d, mmax=9, max_members=40):
    orbits, U, hist = H_tower(d, mmax, 'target_first')
    N = len(orbits)
    reps = [o[0] for o in orbits]
    print(f"\n================ d={d}, orbits {reps}, mmax={mmax} ================")
    members = [(f"H{reps[i]}", [hist[m][i] for m in range(mmax+1)]) for i in range(N)]
    queue = list(range(N))
    processed = set()
    while queue and len(members) < max_members:
        idx = queue.pop(0)
        if idx in processed: continue
        processed.add(idx)
        name, seq = members[idx]
        L = len(seq) - 1
        if L < 3:
            print(f"  [{name}] too short to difference (L={L}); branch stops")
            continue
        D = [None] + [psub(seq[m], seq[m-1]) for m in range(1, L+1)]
        negs = [m for m in range(1, L+1) if pneg(D[m])]
        if negs:
            print(f"  [{name}] *** FAMILY BREAK: Delta has NEGATIVE coeffs at m={negs} ***")
            for m in negs[:2]:
                print(f"      Delta_{m} = {pstr(D[m])}")
            continue
        shifts = [(m, val(D[m])) for m in range(1, L+1) if D[m]]
        if not shifts:
            print(f"  [{name}] Delta identically 0"); continue
        svals = sorted(set(v - m for m, v in shifts))
        if len(svals) != 1:
            print(f"  [{name}] val(Delta_m)-m NOT constant: {[(m, v-m) for m, v in shifts]}")
        s = svals[0]
        # g at level m-1 is D[m]/q^{m+s}; index gseq[i] = level i, i = 0..L-1
        gseq = [pshift(D[i+1], i+1+s) if D[i+1] else {} for i in range(L)]
        recog = None
        for nm, sq in members:
            if all(gseq[i] == sq[i] for i in range(min(len(gseq), len(sq)))):
                recog = f"= {nm}"; break
        if recog is None and len(gseq) >= 3:
            seqs = [sq for nm, sq in members]
            lv = list(range(1, min(len(gseq), min(len(sq) for sq in seqs))))
            sol = solve_combo(gseq, seqs, lv[:4])
            if sol is not None:
                terms = [f"{sol[j]}*{members[j][0]}" for j in range(len(sol)) if sol[j] != 0]
                nn = all(c >= 0 for c in sol)
                recog = f"= {' + '.join(terms) if terms else '0'}  (nonneg comb: {nn})"
        print(f"  [{name}] Delta_m = q^(m+{s}) * S_(m-1), S>=0: True; S {recog if recog else 'is NEW'}")
        if recog is None:
            newname = f"d({name})"
            members.append((newname, gseq))
            queue.append(len(members)-1)
            print(f"      new member {newname}: lvl1 = {pstr(gseq[1])}; lvl2 = {pstr(gseq[2])}")
    print(f"  total members discovered: {len(members)}")
    return members

if __name__ == "__main__":
    for d in [2, 4, 5]:
        ladder(d, mmax=9)
