"""
Seed 5 — Compute Q_{n,c}(q) for small cases.

Q_{n,c}(q) = (q;q)_n * [z^n]( (zq)_infty * F_c(z,q) )

where ell = gcd(d,3) = 1 since d not div by 3, so (q^ell;q^ell)_n = (q;q)_n.
"""

def poly_zero():
    return {}

def poly_one():
    return {0: 1}

def poly_add(p, q):
    r = dict(p)
    for e, c in q.items():
        r[e] = r.get(e, 0) + c
    return {e: c for e, c in r.items() if c != 0}

def poly_mul(p, q):
    r = {}
    for e1, c1 in p.items():
        for e2, c2 in q.items():
            e = e1 + e2
            r[e] = r.get(e, 0) + c1 * c2
    return {e: c for e, c in r.items() if c != 0}

def poly_scale(p, s):
    if s == 0:
        return {}
    return {e: c * s for e, c in p.items()}

def poly_shift(p, k):
    return {e + k: c for e, c in p.items()}

def poly_str(p, var='q'):
    if not p:
        return "0"
    terms = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0:
            continue
        if e == 0:
            terms.append(str(c))
        elif e == 1:
            if c == 1: terms.append(var)
            elif c == -1: terms.append(f"-{var}")
            else: terms.append(f"{c}*{var}")
        else:
            if c == 1: terms.append(f"{var}^{e}")
            elif c == -1: terms.append(f"-{var}^{e}")
            else: terms.append(f"{c}*{var}^{e}")
    if not terms:
        return "0"
    result = terms[0]
    for t in terms[1:]:
        if t.startswith('-'):
            result += " - " + t[1:]
        else:
            result += " + " + t
    return result


def enumerate_cylindric_partitions(c, max_val):
    """Enumerate cylindric partitions of profile c with max entry <= max_val."""
    k = len(c)
    d = sum(c)
    max_parts = max_val + d + 2

    def get_part(lam, j):
        if j < len(lam):
            return lam[j]
        return 0

    def check_interlacing(lams):
        for i in range(k):
            i_next = (i + 1) % k
            c_next = c[i_next]
            for j in range(max_parts):
                if get_part(lams[i], j) < get_part(lams[i_next], j + c_next):
                    return False
        return True

    def gen_partitions(max_entry, max_len):
        if max_len == 0 or max_entry == 0:
            yield ()
            return
        yield ()
        for first in range(1, max_entry + 1):
            for rest in gen_partitions(first, max_len - 1):
                yield (first,) + rest

    all_parts = list(gen_partitions(max_val, min(max_parts, 6)))  # limit length for speed

    results = []
    if k == 3:
        for lam0 in all_parts:
            for lam1 in all_parts:
                for lam2 in all_parts:
                    lams = [lam0, lam1, lam2]
                    if check_interlacing(lams):
                        total = sum(sum(l) for l in lams)
                        mx = max((l[0] if l else 0) for l in lams)
                        results.append((total, mx))
    return results


def compute_b_j(c, j_max):
    """b_j = [z^j] F_c(z,q) = sum_{Lambda: max(Lambda)=j} q^{|Lambda|}"""
    cps = enumerate_cylindric_partitions(c, j_max)
    b = [poly_zero() for _ in range(j_max + 1)]
    for total, mx in cps:
        if mx <= j_max:
            b[mx] = poly_add(b[mx], {total: 1})
    return b


def compute_Q_nc(c, n):
    """
    Q_{n,c}(q) = (q;q)_n * sum_{m=0}^{n} (-1)^m * q^{binom(m+1,2)} / (q;q)_m * b_{n-m}
               = sum_{m=0}^{n} (-1)^m * q^{m(m+1)/2} * [(q;q)_n/(q;q)_m] * b_{n-m}
    """
    b = compute_b_j(c, n)
    result = poly_zero()
    for m in range(n + 1):
        sign = (-1) ** m
        shift = m * (m + 1) // 2
        # (q;q)_n / (q;q)_m = prod_{i=m+1}^{n} (1 - q^i)
        ratio = poly_one()
        for i in range(m + 1, n + 1):
            factor = poly_add(poly_one(), {i: -1})
            ratio = poly_mul(ratio, factor)
        term = poly_scale(b[n - m], sign)
        term = poly_shift(term, shift)
        term = poly_mul(term, ratio)
        result = poly_add(result, term)
    return result


print("=" * 70)
print("Computing Q_{n,c}(q) for small profiles c = (c_0, c_1, c_2)")
print("d not divisible by 3")
print("=" * 70)

profiles = [
    (1, 0, 1),   # d=2
    (0, 1, 1),   # d=2
    (2, 0, 0),   # d=2
    (1, 1, 2),   # d=4
    (2, 1, 1),   # d=4
    (2, 2, 1),   # d=5
]

for c in profiles:
    d = sum(c)
    if d % 3 == 0:
        continue
    print(f"\nProfile c = {c}, d = {d}")
    expected_base = ((d+1)*(d+2))//6 - 1
    print(f"Expected Q(1) = {expected_base}^n")
    print("-" * 50)

    for n in range(4):
        Q = compute_Q_nc(c, n)
        all_pos = all(v >= 0 for v in Q.values())
        pos_str = "POS" if all_pos else "NEG!"
        q1_val = sum(Q.values())
        expected = expected_base ** n
        print(f"  n={n}: Q = {poly_str(Q)}")
        print(f"       [{pos_str}]  Q(1)={q1_val}  exp={expected}  {'OK' if q1_val == expected else 'MISMATCH!'}")

print("\nDone.")
