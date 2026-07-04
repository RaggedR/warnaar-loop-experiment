"""
Seed 2, Layer 1: Compute Q_{n,c}(q) for small cases.

Q_{n,c}(q) = (q;q)_n * [z^n]( (zq;q)_inf * F_c(z,q) )

where F_c(z,q) = sum over cylindric partitions of profile c: q^|Lambda| z^max(Lambda)
and (zq;q)_inf = prod_{j>=1}(1-zq^j).

For r=3, d not div by 3 => ell = gcd(d,3) = 1, so (q^ell;q^ell)_n = (q;q)_n.
"""

from collections import defaultdict


def poly_add(a, b):
    result = defaultdict(int)
    for k, v in a.items():
        result[k] += v
    for k, v in b.items():
        result[k] += v
    return result

def poly_mul(a, b, max_deg=None):
    result = defaultdict(int)
    for i, ai in a.items():
        if ai == 0:
            continue
        for j, bj in b.items():
            if bj == 0:
                continue
            if max_deg is not None and i + j > max_deg:
                continue
            result[i + j] += ai * bj
    return result

def poly_one():
    return defaultdict(int, {0: 1})

def poly_to_list(p, max_deg=None):
    if not p:
        return [0]
    md = max(p.keys()) if max_deg is None else max_deg
    return [p.get(i, 0) for i in range(md + 1)]


def enumerate_cylindric_partitions_bounded(c, max_entry, max_total_size):
    """
    Enumerate cylindric partitions of profile c = (c_0, c_1, c_2) (k=3)
    with max entry <= max_entry and total size <= max_total_size.

    Interlacing conditions (cyclic, indices mod 3):
      lam^(i)_j >= lam^(i+1 mod 3)_{j + c_{(i+1) mod 3}} for all j >= 1

    Returns list of (total_size, max_value).
    """
    k = len(c)
    assert k == 3, "Only k=3 implemented"

    # Determine how many parts we need per partition
    # The shifts are c_1, c_2, c_0 for the three interlacing conditions
    max_shift = max(c) + 1
    num_parts = max_entry + max_shift + 1  # generous

    results = []

    def gen_partitions(max_val, nparts, max_size):
        """Generate weakly decreasing sequences of length nparts, values in [0, max_val], sum <= max_size."""
        if nparts == 0:
            yield ()
            return
        for first in range(min(max_val, max_size), -1, -1):
            for rest in gen_partitions(first, nparts - 1, max_size - first):
                yield (first,) + rest

    all_parts = list(gen_partitions(max_entry, num_parts, max_total_size))
    print(f"  Generated {len(all_parts)} candidate partitions")

    for lam0 in all_parts:
        s0 = sum(lam0)
        if s0 > max_total_size:
            continue
        for lam1 in all_parts:
            s1 = sum(lam1)
            if s0 + s1 > max_total_size:
                continue
            # Check interlacing: lam0_j >= lam1_{j+c_1} for all j
            ok01 = True
            for j in range(num_parts):
                js = j + c[1]
                v1 = lam1[js] if js < num_parts else 0
                if lam0[j] < v1:
                    ok01 = False
                    break
            if not ok01:
                continue

            for lam2 in all_parts:
                s2 = sum(lam2)
                total = s0 + s1 + s2
                if total > max_total_size:
                    continue
                # Check lam1_j >= lam2_{j+c_2}
                ok12 = True
                for j in range(num_parts):
                    js = j + c[2]
                    v2 = lam2[js] if js < num_parts else 0
                    if lam1[j] < v2:
                        ok12 = False
                        break
                if not ok12:
                    continue

                # Check lam2_j >= lam0_{j+c_0} (cyclic wrap)
                ok20 = True
                for j in range(num_parts):
                    js = j + c[0]
                    v0 = lam0[js] if js < num_parts else 0
                    if lam2[j] < v0:
                        ok20 = False
                        break
                if not ok20:
                    continue

                mx = max(lam0[0], lam1[0], lam2[0])
                results.append((total, mx))

    return results


def compute_Q_nc(c, n_max, q_deg_max):
    """Compute Q_{n,c}(q) for n = 0..n_max."""
    print(f"Enumerating cylindric partitions for c={c}...")
    cp_list = enumerate_cylindric_partitions_bounded(c, n_max, q_deg_max)
    print(f"  Found {len(cp_list)} cylindric partitions")

    # Build b_m(q) = [z^m] F_c(z,q)
    b = {}
    for m in range(n_max + 1):
        bm = defaultdict(int)
        for (total, mx) in cp_list:
            if mx == m:
                bm[total] += 1
        b[m] = bm

    # Compute Q_n(q) = (q;q)_n * sum_{j=0}^n a_j(q) * b_{n-j}(q)
    # where a_j(q) = (-1)^j q^{j(j+1)/2} / (q;q)_j
    # So (q;q)_n * a_j(q) = (-1)^j q^{j(j+1)/2} * (q;q)_n / (q;q)_j
    #                      = (-1)^j q^{j(j+1)/2} * prod_{i=j+1}^{n} (1-q^i)
    results = {}
    for n in range(n_max + 1):
        Q_n = defaultdict(int)
        for j in range(n + 1):
            sign = (-1) ** j
            q_shift = j * (j + 1) // 2

            # Compute (q;q)_n / (q;q)_j = prod_{i=j+1}^{n} (1 - q^i)
            ratio = poly_one()
            for i in range(j + 1, n + 1):
                factor = defaultdict(int, {0: 1, i: -1})
                ratio = poly_mul(ratio, factor, q_deg_max)

            # Multiply by b_{n-j}
            term = poly_mul(ratio, b[n - j], q_deg_max)

            # Shift by q^{j(j+1)/2} and apply sign
            shifted = defaultdict(int)
            for exp, coeff in term.items():
                new_exp = exp + q_shift
                if new_exp <= q_deg_max:
                    shifted[new_exp] += sign * coeff

            Q_n = poly_add(Q_n, shifted)

        results[n] = Q_n
    return results


def main():
    print("=" * 60)
    print("Computing Q_{n,c}(q) for small profiles")
    print("=" * 60)

    profiles_to_test = [
        (1, 0, 0),
        (0, 1, 0),
        (0, 0, 1),
        (2, 0, 0),
        (1, 1, 0),
        (0, 1, 1),
    ]

    for profile in profiles_to_test:
        d = sum(profile)
        if d % 3 == 0:
            print(f"\nSkipping c={profile}, d={d} (divisible by 3)")
            continue
        expected_q1 = (d + 1) * (d + 2) // 6 - 1
        print(f"\nProfile c = {profile}, d = {d}")
        print(f"Expected Q_{{n,c}}(1) = {expected_q1}^n")

        n_max = 3
        q_deg_max = 15

        try:
            Qs = compute_Q_nc(profile, n_max, q_deg_max)

            for n in range(n_max + 1):
                coeffs = poly_to_list(Qs[n], q_deg_max)
                while len(coeffs) > 1 and coeffs[-1] == 0:
                    coeffs.pop()
                eval_at_1 = sum(coeffs)
                all_nonneg = all(c >= 0 for c in coeffs)
                print(f"  Q_{{{n},c}}(q) = {coeffs}")
                print(f"    Q(1) = {eval_at_1}, expected = {expected_q1**n}, nonneg = {all_nonneg}")
        except Exception as e:
            print(f"  Error: {e}")
            import traceback
            traceback.print_exc()


if __name__ == "__main__":
    main()
