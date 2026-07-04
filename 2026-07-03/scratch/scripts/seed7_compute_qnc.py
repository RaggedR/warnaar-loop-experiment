"""
Seed 7, Layer 1: Compute Q_{n,c}(q) for small profiles and n values.
Focus: vertex operator / D4(3) perspective from Tsuchioka's work.
"""

import itertools
from math import gcd

MAX_Q_POWER = 30
MAX_Z_POWER = 5


def get_part(lam, j):
    """Get j-th part of partition (0-indexed), 0 if beyond length."""
    return lam[j] if j < len(lam) else 0


def gen_partitions(max_val, max_parts, max_size):
    """Generate partitions (weakly decreasing) with parts <= max_val."""
    if max_parts == 0 or max_val == 0 or max_size <= 0:
        yield ()
        return
    yield ()
    for first in range(1, min(max_val, max_size) + 1):
        for rest in gen_partitions(first, max_parts - 1, max_size - first):
            yield (first,) + rest


def check_cylindric(partitions, c):
    """Check cyclic interlacing for cylindric partition of profile c."""
    k = len(c)
    max_len = max(len(p) for p in partitions) + max(c) + 2 if any(len(p) > 0 for p in partitions) else max(c) + 2
    for i in range(k):
        i_next = (i + 1) % k
        c_next = c[(i + 1) % k] if i < k - 1 else c[0]
        for j in range(max_len):
            if get_part(partitions[i], j) < get_part(partitions[i_next], j + c_next):
                return False
    return True


def compute_F_bounded(c, max_n, max_q):
    """Compute F_{c,n}(q) by direct enumeration for n = 0, ..., max_n."""
    k = len(c)
    max_parts = 5
    results = []

    for n in range(max_n + 1):
        all_parts = list(gen_partitions(n, max_parts, max_q))
        count = {}
        for combo in itertools.product(all_parts, repeat=k):
            if check_cylindric(combo, c):
                size = sum(sum(p) for p in combo)
                if size <= max_q:
                    count[size] = count.get(size, 0) + 1
        results.append(count)

    return results


def compute_Q(c, max_n=4, max_q=MAX_Q_POWER):
    """Compute Q_{n,c}(q)."""
    k = len(c)
    d = sum(c)
    ell = gcd(d, k)

    # Step 1: F_{c,n}(q)
    F_cn = compute_F_bounded(c, max_n, max_q)

    # Step 2: a_n(q) = F_{c,n} - F_{c,n-1}
    a = [dict(F_cn[0])]
    for n in range(1, len(F_cn)):
        diff = dict(F_cn[n])
        for p, v in F_cn[n - 1].items():
            diff[p] = diff.get(p, 0) - v
        a.append({kk: v for kk, v in diff.items() if v != 0})

    # Step 3: (zq;q)_inf coefficients
    # (zq;q)_inf = sum_{m>=0} (-1)^m q^{m(m+1)/2} / (q;q)_m z^m
    zq_coeffs = []
    for m in range(max_n + 1):
        sign = (-1) ** m
        q_shift = m * (m + 1) // 2
        inv_qpoch = {0: 1}
        for i in range(1, m + 1):
            new_inv = dict(inv_qpoch)
            for p in sorted(inv_qpoch.keys()):
                pp = p + i
                while pp <= max_q:
                    new_inv[pp] = new_inv.get(pp, 0) + new_inv.get(pp - i, 0)
                    pp += i
            inv_qpoch = new_inv
        coeff = {}
        for p, v in inv_qpoch.items():
            new_p = p + q_shift
            if new_p <= max_q:
                coeff[new_p] = sign * v
        zq_coeffs.append(coeff)

    # Step 4: [z^n] of product, then multiply by (q^ell; q^ell)_n
    Q_values = []
    for n in range(max_n + 1):
        coeff_n = {}
        for m in range(n + 1):
            j = n - m
            if j < len(a):
                for p1, v1 in zq_coeffs[m].items():
                    for p2, v2 in a[j].items():
                        p = p1 + p2
                        if p <= max_q:
                            coeff_n[p] = coeff_n.get(p, 0) + v1 * v2

        # (q^ell; q^ell)_n
        qpoch = {0: 1}
        for i in range(n):
            shift = ell * (i + 1)
            new_qpoch = dict(qpoch)
            for p, v in qpoch.items():
                pp = p + shift
                if pp <= max_q:
                    new_qpoch[pp] = new_qpoch.get(pp, 0) - v
            qpoch = new_qpoch

        Q_n = {}
        for p1, v1 in qpoch.items():
            for p2, v2 in coeff_n.items():
                p = p1 + p2
                if p <= max_q:
                    Q_n[p] = Q_n.get(p, 0) + v1 * v2

        Q_n = {kk: v for kk, v in Q_n.items() if v != 0}
        Q_values.append(Q_n)

    return Q_values


def print_poly(d, name=""):
    if not d:
        print(f"{name} = 0")
        return
    terms = []
    for p in sorted(d.keys()):
        c = d[p]
        if c == 0:
            continue
        if p == 0:
            terms.append(str(c))
        elif c == 1:
            terms.append(f"q^{p}")
        elif c == -1:
            terms.append(f"-q^{p}")
        else:
            terms.append(f"{c}*q^{p}")
    result = " + ".join(terms).replace("+ -", "- ")
    print(f"{name} = {result}")


if __name__ == "__main__":
    test_profiles = [
        (1, 1, 0),  # d=2
        (2, 0, 0),  # d=2
        (2, 1, 1),  # d=4
        (1, 2, 1),  # d=4
        (2, 2, 1),  # d=5
    ]

    print("=" * 70)
    print("Q_{n,c}(q) computation")
    print("=" * 70)

    for c in test_profiles:
        d = sum(c)
        ell = gcd(d, 3)
        print(f"\nProfile c = {c}, d = {d}, ell = {ell}")
        if d % 3 == 0:
            print("  SKIP: d divisible by 3")
            continue

        try:
            Qs = compute_Q(c, max_n=3, max_q=20)
            for n in range(len(Qs)):
                pos = all(v >= 0 for v in Qs[n].values())
                print_poly(Qs[n], f"  Q_{n}")
                val_at_1 = sum(Qs[n].values()) if Qs[n] else 0
                expected = ((d + 1) * (d + 2) // 6 - 1) ** n if n > 0 else 1
                status = "POS" if pos else "NEG!"
                match = "q=1 OK" if val_at_1 == expected else f"q=1 MISMATCH (got {val_at_1}, exp {expected})"
                print(f"    [{status}] {match}")
        except Exception as e:
            print(f"  ERROR: {e}")
            import traceback
            traceback.print_exc()
