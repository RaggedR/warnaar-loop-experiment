"""
Seed 2, Layer 1: Use Borodin's product formula + Corteel-Welsh functional equation
to compute F_c(z,q) more efficiently, then extract Q_{n,c}(q).

For k=3, profile c=(c_0,c_1,c_2), t = 3 + d where d = c_0+c_1+c_2.

Borodin's formula gives F_c(q) (unrestricted, no bound on max).
The Corteel-Welsh recurrence gives F_c(y,q) from which we can extract
[z^n] via the functional equation.

Let me use the Corteel-Welsh recurrence directly.
"""

from collections import defaultdict
from fractions import Fraction
import sys


class QPoly:
    """Polynomial in q with integer coefficients, truncated to max_deg."""
    def __init__(self, coeffs=None, max_deg=50):
        self.max_deg = max_deg
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in coeffs.items():
                if k <= max_deg:
                    self.coeffs[k] = v

    @staticmethod
    def one(max_deg=50):
        return QPoly({0: 1}, max_deg)

    @staticmethod
    def zero(max_deg=50):
        return QPoly({}, max_deg)

    def __add__(self, other):
        result = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            result.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg:
                result.coeffs[k] += v
        return result

    def __sub__(self, other):
        result = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            result.coeffs[k] += v
        for k, v in other.coeffs.items():
            if k <= self.max_deg:
                result.coeffs[k] -= v
        return result

    def __mul__(self, other):
        result = QPoly(max_deg=self.max_deg)
        for i, ai in self.coeffs.items():
            if ai == 0:
                continue
            for j, bj in other.coeffs.items():
                if bj == 0 or i + j > self.max_deg:
                    continue
                result.coeffs[i + j] += ai * bj
        return result

    def shift(self, s):
        """Multiply by q^s."""
        result = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            if k + s <= self.max_deg:
                result.coeffs[k + s] = v
        return result

    def scale(self, c):
        result = QPoly(max_deg=self.max_deg)
        for k, v in self.coeffs.items():
            result.coeffs[k] = v * c
        return result

    def to_list(self):
        if not self.coeffs:
            return [0]
        md = max(self.coeffs.keys())
        result = [self.coeffs.get(i, 0) for i in range(md + 1)]
        while len(result) > 1 and result[-1] == 0:
            result.pop()
        return result

    def eval_at_1(self):
        return sum(self.coeffs.values())

    def is_nonneg(self):
        return all(v >= 0 for v in self.coeffs.values())

    def __repr__(self):
        return str(self.to_list())


def qpoch_finite(a, b, n, max_deg):
    """(q^a; q^b)_n = prod_{i=0}^{n-1} (1 - q^{a+bi})"""
    result = QPoly.one(max_deg)
    for i in range(n):
        exp = a + b * i
        if exp > max_deg:
            break
        factor = QPoly({0: 1, exp: -1}, max_deg)
        result = result * factor
    return result


def compute_Fc_bounded_via_enumeration(c, n_max, q_max):
    """
    Use the direct approach: enumerate cylindric partitions with max <= n_max.
    Return b[m] = [z^m] F_c(z,q) as QPoly for m = 0..n_max.

    For efficiency, use a transfer-matrix-like approach.
    A cylindric partition of profile c = (c_0,c_1,c_2) is a triple
    (lam^0, lam^1, lam^2) with cyclic interlacing.

    The key insight: think of these as periodic sequences of interlacing partitions
    on the cylinder. The "slices" at each level form a transfer matrix.

    Actually, for bounded max <= n, we can use the fact that
    F_{c,n}(q) = sum_{max<=n} q^|Lambda|
    and the Corteel-Welsh recurrence relates F_c(y,q) values.

    But let me try a different approach: use the generating function
    F_c(y,q) = sum_n F_{c,n}(q) y^n (cumulative)
    Wait, that's not quite right. F_c(y,q) = sum_Lambda q^|Lambda| y^max(Lambda).
    So [y^m] F_c(y,q) = sum_{Lambda: max=m} q^|Lambda| = b_m(q).

    The Corteel-Welsh recurrence is:
    F_c(y,q) = sum_{emptyset != J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)

    This is a recurrence that reduces to profiles with smaller d (since c(J) has
    smaller total in some sense... actually not necessarily smaller d).

    Wait, actually c(J) has the same sum d. The operation shifts entries.
    Let me re-read...
    """
    # For now, use brute force for small cases.
    # But we need a smarter approach for d >= 4.
    pass


def compute_Q_from_Fc_coeffs(b, n_max, q_max):
    """
    Given b[m] = [z^m] F_c(z,q) for m=0..n_max,
    compute Q_n(q) for n=0..n_max.

    Q_n(q) = (q;q)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2} / (q;q)_j * b[n-j](q)
    """
    results = {}
    for n in range(n_max + 1):
        Q_n = QPoly.zero(q_max)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j + 1) // 2

            # (q;q)_n / (q;q)_j = prod_{i=j+1}^{n} (1 - q^i)
            ratio = qpoch_finite(j + 1, 1, n - j, q_max)

            # term = ratio * b[n-j]
            term = ratio * b[n - j]

            # Apply sign and q-shift
            term = term.scale(sign).shift(q_shift)

            Q_n = Q_n + term

        results[n] = Q_n
    return results


def cylindric_partitions_transfer_matrix(c, max_entry, q_max):
    """
    Use a slice-based approach for k=3 cylindric partitions.

    A cylindric partition of profile c = (c_0, c_1, c_2) with k=3 and max entry <= N
    can be thought of as a sequence of interlacing partitions on a cylinder.

    For profile (c_0, c_1, c_2), the cylinder has circumference t = 3 + d.

    An equivalent description: it's a plane partition inside a certain skew shape
    on a cylinder. The rows are periodic with period t.

    For the transfer matrix approach:
    - State = a partition mu (with parts bounded by N and length bounded)
    - Transitions encode the interlacing conditions

    Actually, let me use the direct description.
    Lambda = (lam^0, lam^1, lam^2) where each lam^i is a partition with parts <= N.

    Conditions:
    lam^0_j >= lam^1_{j+c_1}    for all j
    lam^1_j >= lam^2_{j+c_2}    for all j
    lam^2_j >= lam^0_{j+c_0}    for all j

    For a given N = max_entry, enumerate all partitions with parts <= N and
    at most L parts (where L is large enough).

    The number of partitions with parts <= N and at most L parts equals
    the number of partitions fitting in an L x N box = qbinom(N+L, L).
    For small N and L, this is manageable.
    """
    k = 3
    max_parts = max_entry + max(c) + 2

    # Generate all partitions with parts <= max_entry and at most max_parts parts
    def gen_parts(max_val, num_parts, max_size):
        if num_parts == 0:
            yield ()
            return
        for first in range(min(max_val, max_size), -1, -1):
            for rest in gen_parts(first, num_parts - 1, max_size - first):
                yield (first,) + rest

    all_partitions = list(gen_parts(max_entry, max_parts, q_max))
    print(f"  {len(all_partitions)} partitions with parts <= {max_entry}, <= {max_parts} parts")

    # For each pair, check interlacing
    # lam_j >= mu_{j+shift} for all j
    def interlaces(lam, mu, shift):
        for j in range(len(lam)):
            js = j + shift
            mu_val = mu[js] if js < len(mu) else 0
            if lam[j] < mu_val:
                return False
        return True

    # Build adjacency: for each (lam0, lam1) check lam0 >> lam1 with shift c_1
    # Then for each (lam1, lam2) with shift c_2
    # Then for each (lam2, lam0) with shift c_0

    # This is O(P^3) where P = number of partitions, which can be huge.
    # Let's be smarter and iterate.

    # For N <= 2, P is small enough.
    if len(all_partitions) > 500:
        print(f"  Too many partitions ({len(all_partitions)}), reducing max_parts")
        max_parts = max_entry + max(c)
        all_partitions = list(gen_parts(max_entry, max_parts, q_max))
        print(f"  Now {len(all_partitions)} partitions")

    # Build b[m] for each max value m
    b = {m: QPoly.zero(q_max) for m in range(max_entry + 1)}

    count = 0
    for lam0 in all_partitions:
        s0 = sum(lam0)
        for lam1 in all_partitions:
            if not interlaces(lam0, lam1, c[1]):
                continue
            s1 = sum(lam1)
            if s0 + s1 > q_max:
                continue
            for lam2 in all_partitions:
                if not interlaces(lam1, lam2, c[2]):
                    continue
                if not interlaces(lam2, lam0, c[0]):
                    continue
                s2 = sum(lam2)
                total = s0 + s1 + s2
                if total > q_max:
                    continue
                mx = max(lam0[0], lam1[0], lam2[0])
                b[mx].coeffs[total] += 1
                count += 1

    print(f"  Found {count} cylindric partitions")
    return b


def main():
    print("=" * 60)
    print("Q_{n,c}(q) computation — Seed 2, Layer 1")
    print("=" * 60)

    test_cases = [
        ((1, 1, 0), 3, 20),   # d=2
        ((2, 1, 1), 2, 15),   # d=4
        ((1, 2, 1), 2, 15),   # d=4
        ((2, 2, 1), 2, 15),   # d=5
    ]

    for profile, n_max, q_max in test_cases:
        d = sum(profile)
        if d % 3 == 0:
            continue
        expected_base = (d + 1) * (d + 2) // 6 - 1
        print(f"\n{'='*50}")
        print(f"Profile c = {profile}, d = {d}")
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")
        print(f"{'='*50}")

        b = cylindric_partitions_transfer_matrix(profile, n_max, q_max)

        print(f"\n  b[m] = [z^m] F_c(z,q):")
        for m in range(n_max + 1):
            print(f"    b[{m}] = {b[m]}")

        Qs = compute_Q_from_Fc_coeffs(b, n_max, q_max)

        for n in range(n_max + 1):
            coeffs = Qs[n].to_list()
            eval1 = Qs[n].eval_at_1()
            nonneg = Qs[n].is_nonneg()
            print(f"\n  Q_{{{n},c}}(q) = {coeffs}")
            print(f"    Q(1) = {eval1}, expected = {expected_base**n}, nonneg = {nonneg}")
            if not nonneg:
                print(f"    *** NEGATIVE COEFFICIENTS FOUND ***")
                neg_terms = {k: v for k, v in Qs[n].coeffs.items() if v < 0}
                print(f"    Negative terms: {dict(neg_terms)}")


if __name__ == "__main__":
    main()
