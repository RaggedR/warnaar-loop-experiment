"""
Seed 3: Compute Q_{n,c}(q) polynomials for small cases.

Computes the bounded cylindric partition polynomials Q_{n,c}(q)
directly from the definition:
  Q_{n,c}(q) = (q^ell; q^ell)_n * [z^n]( (zq)_inf * F_c(z,q) )

where F_c(z,q) is the bivariate cylindric partition generating function
and ell = gcd(d, r) with d = c_0 + c_1 + c_2, r = 3.
"""

from collections import defaultdict
from math import gcd


def enumerate_cylindric_partitions(c, n_max, max_parts=4):
    """
    Enumerate cylindric partitions of profile c = (c0, c1, c2) with
    max entry <= n_max, at most max_parts parts per partition.
    Returns list of (total_size, max_entry) pairs (excluding empty).
    """
    k = len(c)
    
    def gen_partitions(max_val, num_parts):
        if num_parts == 0:
            yield ()
            return
        if max_val == 0:
            yield (0,) * num_parts
            return
        for first in range(max_val, -1, -1):
            for rest in gen_partitions(first, num_parts - 1):
                yield (first,) + rest

    def get_part(lam, j):
        if j < 1 or j > len(lam):
            return 0
        return lam[j - 1]

    def check_interlacing(lams, c):
        k = len(lams)
        for i in range(k):
            i_next = (i + 1) % k
            c_shift = c[i_next]
            for j in range(1, len(lams[i]) + 1):
                if get_part(lams[i], j) < get_part(lams[i_next], j + c_shift):
                    return False
        return True

    results = []
    all_parts = list(gen_partitions(n_max, max_parts))
    
    for lam0 in all_parts:
        for lam1 in all_parts:
            for lam2 in all_parts:
                lams = [lam0, lam1, lam2]
                if check_interlacing(lams, c):
                    total = sum(sum(l) for l in lams)
                    mx = max((max(l) if l else 0) for l in lams)
                    if total > 0:
                        results.append((total, mx))

    return results


def compute_zq_inf(max_z, max_deg):
    """
    Compute (zq)_inf = prod_{j>=1} (1 - z*q^j)
    truncated to z^max_z and q^max_deg.
    Returns dict: power_of_z -> dict{q_power: coeff}.
    """
    result = {0: {0: 1}}
    
    for j in range(1, max_deg + 1):
        new_result = defaultdict(lambda: defaultdict(int))
        for z_pow, q_poly in result.items():
            for q_pow, coeff in q_poly.items():
                if q_pow <= max_deg:
                    new_result[z_pow][q_pow] += coeff
                new_z = z_pow + 1
                new_q = q_pow + j
                if new_z <= max_z and new_q <= max_deg:
                    new_result[new_z][new_q] -= coeff
        result = dict(new_result)
    
    return result


def q_pochhammer_poly(a, b, n, max_deg):
    """Compute (q^a; q^b)_n as polynomial dict."""
    result = {0: 1}
    for i in range(n):
        power = a + i * b
        if power > max_deg:
            break
        new_result = {}
        for deg, coeff in result.items():
            if deg <= max_deg:
                new_result[deg] = new_result.get(deg, 0) + coeff
            if deg + power <= max_deg:
                new_result[deg + power] = new_result.get(deg + power, 0) - coeff
        result = {k: v for k, v in new_result.items() if v != 0}
    return result


def compute_Q_nc(c, n_val, max_deg):
    """Compute Q_{n,c}(q)."""
    r = len(c)
    d = sum(c)
    ell = gcd(d, r)

    # Compute (zq)_inf truncated
    zq_inf = compute_zq_inf(n_val, max_deg)
    
    # Compute F_c(z,q) as bivariate: z_power -> {q_power: count}
    cyl_parts = enumerate_cylindric_partitions(c, n_val, max_parts=4)
    
    F_biv = defaultdict(lambda: defaultdict(int))
    F_biv[0][0] = 1  # empty partition
    for total, mx in cyl_parts:
        if mx <= n_val and total <= max_deg:
            F_biv[mx][total] += 1

    # Multiply (zq)_inf * F_c(z,q), extract [z^n_val]
    product_coeff = defaultdict(int)
    for z1 in range(n_val + 1):
        z2 = n_val - z1
        if z1 not in zq_inf or z2 not in F_biv:
            continue
        q_poly1 = zq_inf[z1]
        q_poly2 = F_biv[z2]
        for qp1, c1 in q_poly1.items():
            for qp2, c2 in q_poly2.items():
                if qp1 + qp2 <= max_deg:
                    product_coeff[qp1 + qp2] += c1 * c2

    # Multiply by (q^ell; q^ell)_n
    q_ell_n = q_pochhammer_poly(ell, ell, n_val, max_deg)
    
    Q = {}
    for d1, c1 in q_ell_n.items():
        for d2, c2 in product_coeff.items():
            deg = d1 + d2
            if deg <= max_deg:
                Q[deg] = Q.get(deg, 0) + c1 * c2
    
    Q = {k: v for k, v in Q.items() if v != 0}
    return Q


def poly_to_list(poly):
    if not poly:
        return [0]
    max_deg = max(poly.keys())
    return [poly.get(i, 0) for i in range(max_deg + 1)]


def main():
    print("=" * 70)
    print("Computing Q_{n,c}(q) for small profiles c = (c0, c1, c2)")
    print("=" * 70)

    profiles = [
        (1, 1, 0),  # d=2
        (0, 1, 1),  # d=2
        (2, 0, 0),  # d=2
        (2, 1, 1),  # d=4
        (1, 2, 1),  # d=4
        (2, 2, 1),  # d=5
    ]

    max_deg = 25

    for c in profiles:
        d = sum(c)
        if d % 3 == 0:
            continue

        print(f"\nProfile c = {c}, d = {d}")
        print("-" * 50)

        expected_base = (d + 1) * (d + 2) // 6 - 1
        print(f"Expected Q_{{n,c}}(1) = {expected_base}^n")

        for n in range(1, 5):
            try:
                Q = compute_Q_nc(c, n, max_deg)
                coeffs = poly_to_list(Q)
                while coeffs and coeffs[-1] == 0:
                    coeffs.pop()
                if not coeffs:
                    coeffs = [0]

                all_pos = all(x >= 0 for x in coeffs)
                eval_at_1 = sum(coeffs)

                print(f"  n={n}: Q = {coeffs}")
                print(f"    Q(1) = {eval_at_1} (expected {expected_base**n}), positive: {all_pos}")

                if not all_pos:
                    neg = [(i, x) for i, x in enumerate(coeffs) if x < 0]
                    print(f"    NEGATIVE at: {neg}")
            except Exception as e:
                print(f"  n={n}: ERROR - {e}")


if __name__ == "__main__":
    main()
