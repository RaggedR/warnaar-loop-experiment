#!/usr/bin/env python3
"""
Seed 6, Layer 2: Gaussian elimination for d=7 system.

For d=7, the system is 36x36. This is feasible for symbolic elimination
but the rational functions may grow large. Let's try it and see.

Alternative: work with the D3-reduced system (8 unknowns) by summing
over orbit members.
"""

from fractions import Fraction
from itertools import combinations
import time

def all_compositions(d, k=3):
    if k == 1:
        yield (d,)
        return
    for i in range(d+1):
        for rest in all_compositions(d - i, k - 1):
            yield (i,) + rest

def shifted_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

def get_I_c(c):
    return frozenset(i for i, ci in enumerate(c) if ci > 0)

def nonempty_subsets(S):
    S = list(S)
    for r in range(1, len(S) + 1):
        for combo in combinations(S, r):
            yield frozenset(combo)

def solve_numerical(d, n_val, q_bound):
    """Solve the system numerically for specific n, return F_{c,n} for all c."""
    compositions = list(all_compositions(d))
    comp_to_idx = {c: i for i, c in enumerate(compositions)}
    N = len(compositions)

    system = {}
    for c in compositions:
        I_c = get_I_c(c)
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            j_size = len(J)
            sign = (-1)**(j_size - 1)
            key = (comp_to_idx[c], comp_to_idx[c_J])
            if key not in system:
                system[key] = {}
            system[key][j_size] = system[key].get(j_size, 0) + sign

    # Iterate from n=0 to n_val
    all_F = {}
    F_prev = [{0: Fraction(1)} for _ in range(N)]
    for i, c in enumerate(compositions):
        all_F[(c, 0)] = {0: Fraction(1)}

    for n in range(1, n_val + 1):
        A = [[{} for _ in range(N)] for _ in range(N)]
        for (row, col), coeffs in system.items():
            for j_size, coeff in coeffs.items():
                power = n * j_size
                if power <= q_bound:
                    A[row][col][power] = A[row][col].get(power, 0) + coeff

        x = [dict(b) for b in F_prev]
        correction = [dict(b) for b in F_prev]
        for iteration in range(q_bound // n + 2):
            new_correction = [{} for _ in range(N)]
            any_nonzero = False
            for i in range(N):
                for j in range(N):
                    if not A[i][j]: continue
                    for da, ca in A[i][j].items():
                        if ca == 0: continue
                        for db, cb in correction[j].items():
                            dd = da + db
                            if dd <= q_bound:
                                new_correction[i][dd] = new_correction[i].get(dd, Fraction(0)) + Fraction(ca) * cb
                                any_nonzero = True
            if not any_nonzero: break
            for i in range(N):
                new_correction[i] = {k: v for k, v in new_correction[i].items() if v != 0}
            for i in range(N):
                for k, v in new_correction[i].items():
                    x[i][k] = x[i].get(k, Fraction(0)) + v
            correction = new_correction
        for i in range(N):
            x[i] = {k: v for k, v in x[i].items() if v != 0}
        F_prev = x
        for i, c in enumerate(compositions):
            all_F[(c, n)] = dict(x[i])

    return compositions, all_F

def compute_Q(c, n, all_F, q_bound):
    f = {}
    for m in range(n + 1):
        fm = dict(all_F.get((c, m), {}))
        if m > 0:
            for k, v in all_F.get((c, m-1), {}).items():
                fm[k] = fm.get(k, Fraction(0)) - v
        fm = {k: v for k, v in fm.items() if v != 0}
        f[m] = fm
    def q_poch_inv(j, qb):
        result = {0: Fraction(1)}
        for s in range(1, j+1):
            new_result = {}
            for deg in range(qb+1):
                val = Fraction(0)
                k = 0
                while deg - k*s >= 0:
                    val += result.get(deg - k*s, Fraction(0))
                    k += 1
                if val != 0:
                    new_result[deg] = val
            result = new_result
        return result
    z_n = {}
    for j in range(n + 1):
        sign = (-1)**j
        shift = j*(j+1)//2
        inv_j = q_poch_inv(j, q_bound - shift) if shift <= q_bound else {}
        for da, ca in inv_j.items():
            if da + shift > q_bound: continue
            for db, cb in f[n-j].items():
                dd = da + shift + db
                if dd <= q_bound:
                    z_n[dd] = z_n.get(dd, Fraction(0)) + sign * ca * cb
    z_n = {k: v for k, v in z_n.items() if v != 0}
    qq_n = {0: Fraction(1)}
    for i in range(1, n+1):
        new = {}
        for k, v in qq_n.items():
            new[k] = new.get(k, Fraction(0)) + v
            if k + i <= q_bound:
                new[k+i] = new.get(k+i, Fraction(0)) - v
        qq_n = {k: v for k, v in new.items() if v != 0}
    Q_n = {}
    for da, ca in qq_n.items():
        for db, cb in z_n.items():
            dd = da + db
            if dd <= q_bound:
                Q_n[dd] = Q_n.get(dd, Fraction(0)) + ca * cb
    Q_n = {k: v for k, v in Q_n.items() if v != 0}
    return Q_n

def analyze_F_structure(d, compositions, all_F, q_bound, max_n=2):
    """
    Analyze the structure of F_{c,n} to look for patterns.
    
    Key question: does F_{c,n}/F_{c,n-1} simplify?
    If F_{c,n} = R_c(q^n) * F_{c,n-1} for some rational function R_c,
    then F_{c,n} = prod_{m=1}^n R_c(q^m) and we can analyze positivity.
    """
    print(f"\n{'='*70}")
    print(f"ANALYZING F-RATIO STRUCTURE for d={d}")
    print(f"{'='*70}")
    
    for c in [(3,2,2), (2,3,2)] if d == 7 else [(2,1,1)]:
        print(f"\nc = {c}:")
        for n in range(1, max_n + 1):
            F_n = all_F.get((c, n), {})
            F_prev = all_F.get((c, n-1), {})
            
            # Check if F_n / F_prev is a nice rational function
            # Compute the ratio as a power series
            if F_prev.get(0, 0) == 0:
                print(f"  n={n}: F_{{n-1}} has no constant term, skipping")
                continue
            
            # F_n = R * F_{n-1} means [q^d] F_n = sum_k R_k * [q^{d-k}] F_{n-1}
            # So R = F_n / F_{n-1} as formal power series
            
            inv_Fprev = {0: Fraction(1)}
            c0 = F_prev[0]
            inv_c0 = Fraction(1, c0)
            inv_Fprev[0] = inv_c0
            for deg in range(1, q_bound + 1):
                s = Fraction(0)
                for j in range(1, deg + 1):
                    pj = F_prev.get(j, Fraction(0))
                    rj = inv_Fprev.get(deg - j, Fraction(0))
                    s += pj * rj
                inv_Fprev[deg] = -inv_c0 * s
            
            # ratio = F_n * inv_Fprev
            ratio = {}
            for da, ca in F_n.items():
                if da > q_bound: continue
                for db, cb in inv_Fprev.items():
                    dd = da + db
                    if dd <= q_bound:
                        ratio[dd] = ratio.get(dd, Fraction(0)) + ca * cb
            ratio = {k: v for k, v in ratio.items() if v != 0}
            
            print(f"  F_{{{c},{n}}} / F_{{{c},{n-1}}} (first 20 terms):")
            for deg in range(min(20, q_bound+1)):
                v = ratio.get(deg, Fraction(0))
                if v != 0:
                    print(f"    q^{deg}: {v}")

def main():
    q_bound = 50
    
    # Compute for d=7
    print("Computing F_{c,n} for d=7, n=0,1,2,3...")
    t0 = time.time()
    compositions, all_F = solve_numerical(7, 3, q_bound)
    t1 = time.time()
    print(f"Done in {t1-t0:.1f}s")
    
    # Compute Q for several profiles
    for c in [(3,2,2), (4,2,1), (2,3,2), (5,1,1)]:
        print(f"\nc={c}:")
        for n in range(1, 4):
            Q = compute_Q(c, n, all_F, q_bound)
            Q_sum = sum(Q.values())
            expected = ((7+1)*(7+2)//6 - 1)**n
            nonneg = all(v >= 0 for v in Q.values())
            
            # Print Q_n
            terms = []
            for deg in sorted(Q.keys()):
                v = Q[deg]
                if v != 0:
                    terms.append(f"{v}q^{deg}")
            if n <= 2:
                print(f"  Q_{n} = {' + '.join(terms[:15])}{'...' if len(terms) > 15 else ''}")
            print(f"  Q_{n}(1) = {Q_sum} (expected {expected}), nonneg: {nonneg}")
            
            if not nonneg:
                neg_terms = {k: v for k, v in Q.items() if v < 0}
                print(f"  NEGATIVE TERMS: {neg_terms}")

    # Analyze F-ratio structure
    analyze_F_structure(7, compositions, all_F, q_bound, max_n=3)

if __name__ == "__main__":
    main()
