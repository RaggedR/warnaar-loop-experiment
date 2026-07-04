#!/usr/bin/env python3
"""
Seed 6, Layer 2: Build the Corteel-Welsh coupled system for d=7.
Implements Uncu-style approach: build system, attempt Gaussian elimination.
"""

from fractions import Fraction
from itertools import combinations

def all_compositions(d, k=3):
    """All compositions of d into k non-negative parts."""
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

def build_cw_system(d):
    """
    Build the CW system for d.
    
    CW recurrence gives:
    F_{c,n} = F_{c,n-1} + sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}
    
    Rearranging: (I - A(n)) F_n = F_{n-1}
    where A(n)_{c,c'} = sum over J where c(J)=c' of (-1)^{|J|-1} q^{n|J|}
    """
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

    return compositions, comp_to_idx, system

def solve_system_iterative(d, max_n, q_bound):
    """
    Solve (I - A(n)) F_n = F_{n-1} iteratively using Neumann series.
    Returns all_F: dict mapping (c, m) -> polynomial (dict deg->coeff).
    """
    compositions, comp_to_idx, system = build_cw_system(d)
    N = len(compositions)

    all_F = {}
    F_prev = [{0: Fraction(1)} for _ in range(N)]
    for i, c in enumerate(compositions):
        all_F[(c, 0)] = {0: Fraction(1)}

    for n in range(1, max_n + 1):
        # Build A(n) matrix
        A = [[{} for _ in range(N)] for _ in range(N)]
        for (row, col), coeffs in system.items():
            for j_size, coeff in coeffs.items():
                power = n * j_size
                if power <= q_bound:
                    A[row][col][power] = A[row][col].get(power, 0) + coeff

        # Neumann series: x = b + A*b + A^2*b + ...
        x = [dict(b) for b in F_prev]
        correction = [dict(b) for b in F_prev]

        for iteration in range(q_bound // n + 2):
            new_correction = [{} for _ in range(N)]
            any_nonzero = False
            for i in range(N):
                for j in range(N):
                    if not A[i][j]:
                        continue
                    for da, ca in A[i][j].items():
                        if ca == 0:
                            continue
                        for db, cb in correction[j].items():
                            dd = da + db
                            if dd <= q_bound:
                                new_correction[i][dd] = new_correction[i].get(dd, Fraction(0)) + Fraction(ca) * cb
                                any_nonzero = True
            if not any_nonzero:
                break
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
    """Compute Q_{n,c}(q) from stored F values."""
    # f_{c,m} = F_{c,m} - F_{c,m-1}
    f = {}
    for m in range(n + 1):
        fm = dict(all_F.get((c, m), {}))
        if m > 0:
            for k, v in all_F.get((c, m-1), {}).items():
                fm[k] = fm.get(k, Fraction(0)) - v
        fm = {k: v for k, v in fm.items() if v != 0}
        f[m] = fm

    # [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n a_j * f_{n-j}
    # a_j = (-1)^j q^{j(j+1)/2} / (q;q)_j as truncated power series

    # Compute (q;q)_j^{-1} as power series
    def q_poch_inv(j, qb):
        """Compute 1/(q;q)_j truncated to degree qb."""
        result = {0: Fraction(1)}
        for s in range(1, j+1):
            # multiply by 1/(1-q^s)
            new_result = dict(result)
            for deg in range(1, qb+1):
                if deg - s >= 0 and (deg-s) in new_result:
                    pass  # handled below
            # 1/(1-q^s) = 1 + q^s + q^{2s} + ...
            # multiply: new[d] = sum_{k>=0} old[d - k*s]
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

    # Compute z1 = [z^n]((zq;q)_inf * F_c(z,q))
    z_n = {}
    for j in range(n + 1):
        sign = (-1)**j
        shift = j*(j+1)//2
        inv_j = q_poch_inv(j, q_bound - shift) if shift <= q_bound else {}
        # a_j * f_{n-j}: multiply (sign * q^shift * inv_j) by f[n-j]
        for da, ca in inv_j.items():
            if da + shift > q_bound:
                continue
            for db, cb in f[n-j].items():
                dd = da + shift + db
                if dd <= q_bound:
                    z_n[dd] = z_n.get(dd, Fraction(0)) + sign * ca * cb

    z_n = {k: v for k, v in z_n.items() if v != 0}

    # Q_n = (q;q)_n * z_n
    # (q;q)_n = prod_{i=1}^n (1-q^i)
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

def poly_str(p, max_terms=20):
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys()):
        v = p[deg]
        if v != 0:
            terms.append(f"{v}*q^{deg}")
    return " + ".join(terms[:max_terms])

def main():
    print("=" * 70)
    print("CW SYSTEM STRUCTURE")
    print("=" * 70)

    for d in [2, 4, 5, 7]:
        compositions, _, system = build_cw_system(d)
        N = len(compositions)
        nnz = sum(1 for v in system.values() if any(c != 0 for c in v.values()))
        print(f"d={d}: {N} compositions, {nnz} nonzero matrix entries")

    # Verify for d=4
    print("\n" + "=" * 70)
    print("VERIFICATION: d=4")
    print("=" * 70)

    d = 4
    q_bound = 25
    compositions, all_F = solve_system_iterative(d, 2, q_bound)

    test_profiles = [(2,1,1), (1,2,1), (3,1,0)]
    for c in test_profiles:
        Q1 = compute_Q(c, 1, all_F, q_bound)
        Q2 = compute_Q(c, 2, all_F, q_bound)
        print(f"\nc={c}:")
        print(f"  Q_1 = {poly_str(Q1)}")
        Q1_sum = sum(Q1.values())
        print(f"  Q_1(1) = {Q1_sum} (expected {(d+1)*(d+2)//6 - 1})")
        print(f"  Q_1 nonneg: {all(v >= 0 for v in Q1.values())}")
        Q2_sum = sum(Q2.values())
        expected2 = ((d+1)*(d+2)//6 - 1)**2
        print(f"  Q_2(1) = {Q2_sum} (expected {expected2})")
        print(f"  Q_2 nonneg: {all(v >= 0 for v in Q2.values())}")

    # Now d=7
    print("\n" + "=" * 70)
    print("d=7: FIRST UNPROVED CASE")
    print("=" * 70)

    d = 7
    q_bound = 40
    compositions, all_F = solve_system_iterative(d, 2, q_bound)

    test_profiles_7 = [(3,2,2), (4,2,1), (2,3,2), (5,1,1)]
    for c in test_profiles_7:
        Q1 = compute_Q(c, 1, all_F, q_bound)
        Q2 = compute_Q(c, 2, all_F, q_bound)
        print(f"\nc={c}:")
        print(f"  Q_1 = {poly_str(Q1)}")
        Q1_sum = sum(Q1.values())
        expected = (d+1)*(d+2)//6 - 1
        print(f"  Q_1(1) = {Q1_sum} (expected {expected})")
        print(f"  Q_1 nonneg: {all(v >= 0 for v in Q1.values())}")
        Q2_sum = sum(Q2.values())
        print(f"  Q_2(1) = {Q2_sum} (expected {expected**2})")
        print(f"  Q_2 nonneg: {all(v >= 0 for v in Q2.values())}")

if __name__ == "__main__":
    main()
