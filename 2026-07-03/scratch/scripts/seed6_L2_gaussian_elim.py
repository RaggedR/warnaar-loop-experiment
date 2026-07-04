#!/usr/bin/env python3
"""
Seed 6, Layer 2: Uncu-style Gaussian elimination for d=7.

The CW system gives:
  F_{c,n} = F_{c,n-1} + sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}

For fixed n, this is: (I - A(q^n)) F_n = F_{n-1}
where A is a matrix with entries that are monomials in q^n.

Gaussian elimination on (I - A) to solve for F_{c,n} in terms of F_{c,n-1}
gives a formula for each F_{c,n} as a RATIO of polynomials in q^n times F_{c,n-1}.

The key insight: if we set q_n = q^n, then A(q_n) is a matrix with
entries q_n, q_n^2, q_n^3 (since |J| can be 1, 2, or 3).

We can do Gaussian elimination symbolically in q_n.
"""

from fractions import Fraction
import sys

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
    from itertools import combinations
    S = list(S)
    for r in range(1, len(S) + 1):
        for combo in combinations(S, r):
            yield frozenset(combo)

class RatPoly:
    """Rational function in one variable x, stored as num/den polynomials (dict: power -> Fraction)."""
    def __init__(self, num=None, den=None):
        self.num = num if num is not None else {0: Fraction(1)}
        self.den = den if den is not None else {0: Fraction(1)}
        self._simplify()

    def _simplify(self):
        # Remove zero terms
        self.num = {k: v for k, v in self.num.items() if v != 0}
        self.den = {k: v for k, v in self.den.items() if v != 0}
        if not self.num:
            self.num = {}
            self.den = {0: Fraction(1)}
        # Factor out minimum power
        if self.num and self.den:
            min_n = min(self.num.keys()) if self.num else 0
            min_d = min(self.den.keys()) if self.den else 0
            shift = min(min_n, min_d)
            if shift > 0:
                self.num = {k - shift: v for k, v in self.num.items()}
                self.den = {k - shift: v for k, v in self.den.items()}

    @staticmethod
    def zero():
        return RatPoly({}, {0: Fraction(1)})

    @staticmethod
    def one():
        return RatPoly({0: Fraction(1)}, {0: Fraction(1)})

    @staticmethod
    def monomial(power, coeff=Fraction(1)):
        return RatPoly({power: coeff}, {0: Fraction(1)})

    def is_zero(self):
        return not self.num

    def __neg__(self):
        return RatPoly({k: -v for k, v in self.num.items()}, dict(self.den))

    def __add__(self, other):
        # a/b + c/d = (ad + bc) / bd
        new_num = poly_add(poly_mul(self.num, other.den), poly_mul(other.num, self.den))
        new_den = poly_mul(self.den, other.den)
        return RatPoly(new_num, new_den)

    def __sub__(self, other):
        return self + (-other)

    def __mul__(self, other):
        new_num = poly_mul(self.num, other.num)
        new_den = poly_mul(self.den, other.den)
        return RatPoly(new_num, new_den)

    def inv(self):
        if not self.num:
            raise ZeroDivisionError
        return RatPoly(dict(self.den), dict(self.num))

    def __truediv__(self, other):
        return self * other.inv()

    def __repr__(self):
        def poly_str(p):
            if not p:
                return "0"
            terms = []
            for k in sorted(p.keys()):
                v = p[k]
                if v == 1 and k > 0:
                    terms.append(f"x^{k}" if k > 1 else "x")
                elif v == -1 and k > 0:
                    terms.append(f"-x^{k}" if k > 1 else "-x")
                elif k == 0:
                    terms.append(str(v))
                else:
                    terms.append(f"{v}*x^{k}" if k > 1 else f"{v}*x")
            return " + ".join(terms) if terms else "0"

        n = poly_str(self.num)
        d = poly_str(self.den)
        if d == "1":
            return n
        return f"({n})/({d})"

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, Fraction(0)) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(a, b):
    if not a or not b:
        return {}
    result = {}
    for ka, va in a.items():
        for kb, vb in b.items():
            k = ka + kb
            result[k] = result.get(k, Fraction(0)) + va * vb
    return {k: v for k, v in result.items() if v != 0}

def build_symbolic_system(d):
    """Build (I - A) as a matrix of RatPoly in x = q^n."""
    compositions = list(all_compositions(d))
    comp_to_idx = {c: i for i, c in enumerate(compositions)}
    N = len(compositions)

    # Build I - A
    M = [[RatPoly.zero() for _ in range(N)] for _ in range(N)]

    # Identity part
    for i in range(N):
        M[i][i] = RatPoly.one()

    # -A part
    for c in compositions:
        I_c = get_I_c(c)
        row = comp_to_idx[c]
        for J in nonempty_subsets(I_c):
            c_J = shifted_profile(c, J)
            col = comp_to_idx[c_J]
            j_size = len(J)
            sign = (-1)**(j_size - 1)
            # Subtract sign * x^j_size
            M[row][col] = M[row][col] - RatPoly.monomial(j_size, Fraction(sign))

    return compositions, comp_to_idx, M

def gaussian_eliminate(M, N, target_row=None):
    """
    Gaussian elimination on N x N matrix of RatPoly.
    Reduce to upper triangular form.
    If target_row is specified, only eliminate enough to solve for that row.
    """
    M = [[M[i][j] for j in range(N)] for i in range(N)]  # copy

    for col in range(N):
        # Find pivot
        pivot = None
        for row in range(col, N):
            if not M[row][col].is_zero():
                pivot = row
                break
        if pivot is None:
            print(f"  WARNING: No pivot found for column {col}")
            continue
        if pivot != col:
            M[col], M[pivot] = M[pivot], M[col]

        # Eliminate below
        pivot_val = M[col][col]
        for row in range(col + 1, N):
            if not M[row][col].is_zero():
                factor = M[row][col] / pivot_val
                for j in range(col, N):
                    M[row][j] = M[row][j] - factor * M[col][j]

        print(f"  Eliminated column {col}/{N}")

    return M

def main():
    # Start small: d=2
    print("=" * 70)
    print("GAUSSIAN ELIMINATION: d=2")
    print("=" * 70)

    d = 2
    compositions, comp_to_idx, M = build_symbolic_system(d)
    N = len(compositions)
    print(f"System size: {N} x {N}")
    print(f"Compositions: {compositions}")

    # Print the matrix
    print("\nMatrix (I - A):")
    for i in range(N):
        for j in range(N):
            if not M[i][j].is_zero():
                print(f"  [{i},{j}] = {M[i][j]}  (c={compositions[i]} -> c'={compositions[j]})")

    # For d=2, try elimination
    M_elim = gaussian_eliminate(M, N)

    print("\nAfter elimination (upper triangular):")
    for i in range(N):
        for j in range(i, N):
            if not M_elim[i][j].is_zero():
                print(f"  [{i},{j}] = {M_elim[i][j]}")

    # d=4
    print("\n" + "=" * 70)
    print("GAUSSIAN ELIMINATION: d=4")
    print("=" * 70)

    d = 4
    compositions, comp_to_idx, M = build_symbolic_system(d)
    N = len(compositions)
    print(f"System size: {N} x {N}")

    M_elim = gaussian_eliminate(M, N)

    # Check: for profile (2,1,1), what is the diagonal entry?
    idx_211 = comp_to_idx[(2,1,1)]
    print(f"\nDiagonal entry for (2,1,1) (row {idx_211}): {M_elim[idx_211][idx_211]}")

    # For d=7, the system is 36x36 which may be too large for exact symbolic elimination
    # Let's try with the reduced D3-quotient system

    print("\n" + "=" * 70)
    print("SYSTEM SIZE COMPARISON")
    print("=" * 70)
    for d in [2, 4, 5, 7, 8, 10]:
        compositions = list(all_compositions(d))
        print(f"d={d}: full system {len(compositions)}x{len(compositions)}")


if __name__ == "__main__":
    main()
