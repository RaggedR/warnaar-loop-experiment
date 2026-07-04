"""
Seed 8: Compute Q_{n,c}(q) for small cases.
Explore plane partition / lozenge tiling connections to positivity.
"""

from collections import defaultdict

def poly_mult(p1, p2, max_deg):
    """Multiply two polynomials (as dicts power->coeff), truncated at max_deg."""
    result = {}
    for e1, c1 in p1.items():
        if c1 == 0:
            continue
        for e2, c2 in p2.items():
            if c2 == 0:
                continue
            e = e1 + e2
            if e <= max_deg:
                result[e] = result.get(e, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}


def enumerate_cylindric_k3(profile, max_entry, L):
    """Enumerate cylindric partitions for k=3 profiles.
    Returns size_counts: dict mapping total_size -> count."""
    c0, c1, c2 = profile

    size_counts = defaultdict(int)
    count = 0

    def gen_parts(max_val, length):
        """Generate weakly decreasing sequences."""
        if length == 0:
            yield ()
            return
        for first in range(max_val, -1, -1):
            for rest in gen_parts(first, length - 1):
                yield (first,) + rest

    def gen_parts_bounded(max_val, length, bounds):
        """Generate weakly decreasing sequences with upper bounds."""
        if length == 0:
            yield ()
            return
        ub = min(max_val, bounds[0] if len(bounds) > 0 else max_val)
        if ub < 0:
            return
        for first in range(ub, -1, -1):
            new_bounds = tuple(
                min(first, bounds[j+1] if j+1 < len(bounds) else max_val)
                for j in range(length - 1)
            )
            for rest in gen_parts_bounded(first, length - 1, new_bounds):
                yield (first,) + rest

    def get_part(lam, idx):
        return lam[idx] if idx < len(lam) else 0

    for lam0 in gen_parts(max_entry, L):
        bounds1 = tuple(
            get_part(lam0, m - c1) if m >= c1 else max_entry
            for m in range(L)
        )
        for lam1 in gen_parts_bounded(max_entry, L, bounds1):
            bounds2 = tuple(
                get_part(lam1, m - c2) if m >= c2 else max_entry
                for m in range(L)
            )
            for lam2 in gen_parts_bounded(max_entry, L, bounds2):
                # Wrap-around: lam2[j] >= lam0[j + c0] for j >= 0
                valid = True
                for j in range(L):
                    rhs = get_part(lam0, j + c0)
                    if get_part(lam2, j) < rhs:
                        valid = False
                        break
                if valid:
                    total_size = sum(lam0) + sum(lam1) + sum(lam2)
                    size_counts[total_size] += 1
                    count += 1

    return size_counts, count


def compute_Q_nc(profile, max_n, max_deg):
    """Compute Q_{n,c}(q) for n = 0, ..., max_n."""
    d = sum(profile)
    # ell = gcd(d, 3) = 1 since d not div by 3

    # Step 1: Compute F_{c,n}(q) for n = 0, ..., max_n
    # F_{c,n}(q) = sum over cyl. partitions with max <= n of q^|Lambda|
    F_cn = {}
    for n in range(max_n + 1):
        L = n + d + 2
        size_counts, count = enumerate_cylindric_k3(profile, n, L)
        F_cn[n] = dict(size_counts)
        print(f"  F_{{c,{n}}}(q): {count} cylindric partitions")

    # Step 2: [z^j] F_c(z,q) = F_{c,j}(q) - F_{c,j-1}(q)
    f_coeffs = {}
    for j in range(max_n + 1):
        curr = F_cn.get(j, {})
        prev = F_cn.get(j - 1, {}) if j > 0 else {}
        f_j = {}
        for s in set(list(curr.keys()) + list(prev.keys())):
            val = curr.get(s, 0) - prev.get(s, 0)
            if val != 0:
                f_j[s] = val
        f_coeffs[j] = f_j

    # Step 3: Compute Q_{n,c}(q)
    # Q_{n,c}(q) = (q;q)_n * sum_{m=0}^{n} (-1)^m * q^{m(m+1)/2} / (q;q)_m * f_{n-m}(q)

    def qpoch_n(m):
        """(q;q)_m as polynomial."""
        result = {0: 1}
        for i in range(1, m + 1):
            new_result = {}
            for p, c in result.items():
                if p <= max_deg:
                    new_result[p] = new_result.get(p, 0) + c
                if p + i <= max_deg:
                    new_result[p + i] = new_result.get(p + i, 0) - c
            result = {k: v for k, v in new_result.items() if v != 0}
        return result

    def qpoch_inv(m):
        """1/(q;q)_m as power series truncated at max_deg."""
        result = {0: 1}
        for i in range(1, m + 1):
            new_result = {}
            for p, c in result.items():
                j = 0
                while p + i * j <= max_deg:
                    new_result[p + i * j] = new_result.get(p + i * j, 0) + c
                    j += 1
            result = {k: v for k, v in new_result.items() if v != 0}
        return result

    Q_polys = {}
    for n in range(max_n + 1):
        inner_sum = {}
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            inv_qm = qpoch_inv(m)
            f_j = f_coeffs.get(n - m, {})
            product = poly_mult(inv_qm, f_j, max_deg)
            for p, c in product.items():
                new_p = p + shift
                if new_p <= max_deg:
                    inner_sum[new_p] = inner_sum.get(new_p, 0) + sign * c

        qq_n = qpoch_n(n)
        Q_n = poly_mult(qq_n, inner_sum, max_deg)
        Q_n = {p: c for p, c in Q_n.items() if c != 0}
        Q_polys[n] = Q_n

    return Q_polys


def format_poly(terms):
    if not terms:
        return "0"
    parts = []
    for p, c in sorted(terms):
        if c == 0:
            continue
        if p == 0:
            parts.append(str(c))
        elif c == 1:
            parts.append(f"q^{p}")
        elif c == -1:
            parts.append(f"-q^{p}")
        else:
            parts.append(f"{c}*q^{p}")
    return " + ".join(parts) if parts else "0"


def main():
    profiles_to_test = [
        (1, 1, 0),  # d = 2
        (2, 0, 0),  # d = 2
        (0, 1, 1),  # d = 2
    ]

    for profile in profiles_to_test:
        d = sum(profile)
        print(f"\n{'='*60}")
        print(f"Profile c = {profile}, d = {d}")
        print(f"{'='*60}")

        max_n = 3
        max_deg = 25

        Q_polys = compute_Q_nc(profile, max_n, max_deg)

        expected_eval = (d + 1) * (d + 2) // 6 - 1
        print(f"\nQ_{{n,c}}(q), expected Q(1) = {expected_eval}^n")

        for n in range(max_n + 1):
            Q = Q_polys.get(n, {})
            terms = sorted(Q.items())
            poly_str = format_poly(terms)
            eval_at_1 = sum(c for _, c in terms)
            expected = expected_eval ** n
            check = "OK" if eval_at_1 == expected else f"MISMATCH (got {eval_at_1}, expected {expected})"
            neg_coeffs = [(p, c) for p, c in terms if c < 0]
            pos_check = "POSITIVE" if not neg_coeffs else f"NEGATIVE at {neg_coeffs}"

            print(f"\n  Q_{{{n}}}(q) = {poly_str}")
            print(f"    Q(1) = {eval_at_1} {check}")
            print(f"    Positivity: {pos_check}")


if __name__ == "__main__":
    main()
