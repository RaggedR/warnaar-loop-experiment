"""
Seed 8, Layer 2: Compute Q_{n,(3,2,2)}(q) for d=7, n=1,2,3,4 using the CW iterative system.
Also compute h_m(q) = (q;q)_m * g_m(q) for verification.
"""

from itertools import combinations
from math import gcd

MAX_Q = 120
MAX_N = 4


def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})


def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg:
            continue
        for j, bj in b.items():
            if bj == 0 or i + j > max_deg:
                continue
            result[i + j] = result.get(i + j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}


def poly_shift(p, s, max_deg=MAX_Q):
    return {k + s: v for k, v in p.items() if k + s <= max_deg}


def poly_scale(p, s):
    if s == 0:
        return {}
    return {k: v * s for k, v in p.items()}


def poly_str(p, max_terms=20):
    if not p:
        return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0:
            continue
        if e == 0:
            parts.append(str(c))
        elif c == 1:
            parts.append(f"q^{e}")
        elif c == -1:
            parts.append(f"-q^{e}")
        else:
            parts.append(f"{c}q^{e}")
    if len(parts) > max_terms:
        return " + ".join(parts[:max_terms]).replace("+ -", "- ") + f" + ... ({len(parts)} terms total)"
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"


def enumerate_profiles(d, k):
    if k == 1:
        yield (d,)
        return
    for i in range(d + 1):
        for rest in enumerate_profiles(d - i, k - 1):
            yield (i,) + rest


def compute_cJ(c, J):
    k = len(c)
    J_set = set(J)
    c_J = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set:
            c_J[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_J[i] += 1
    return tuple(c_J)


def build_CW_system(c, k=3):
    I_c = [i for i in range(k) if c[i] > 0]
    if not I_c:
        return []
    terms = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            c_J = compute_cJ(c, J)
            if any(x < 0 for x in c_J):
                continue
            sign = (-1) ** (size - 1)
            terms.append((sign, size, c_J))
    return terms


def compute_base_case_coeffs(k, max_n, max_q):
    result = {}
    prev_cum = {0: 1}
    result[0] = {0: 1}
    for n in range(1, max_n + 1):
        curr_cum = {}
        kn = k * n
        for p, c in prev_cum.items():
            j = 0
            while p + kn * j <= max_q:
                curr_cum[p + kn * j] = curr_cum.get(p + kn * j, 0) + c
                j += 1
        curr_cum = {p: c for p, c in curr_cum.items() if c != 0}
        result[n] = poly_sub(curr_cum, prev_cum)
        prev_cum = curr_cum
    return result


def solve_CW_system(target_profile, k, max_n, max_q):
    d = sum(target_profile)
    all_profiles = list(enumerate_profiles(d, k))
    zero_profile = tuple([0] * k)

    cw_system = {}
    for p in all_profiles:
        if p == zero_profile:
            continue
        cw_system[p] = build_CW_system(p, k)

    base_coeffs = compute_base_case_coeffs(k, max_n, max_q)
    B = {}
    B[zero_profile] = {}
    cum = {0: 1}
    for n in range(max_n + 1):
        if n == 0:
            B[zero_profile][0] = {0: 1}
        else:
            cum = poly_add(cum, base_coeffs.get(n, {}))
            B[zero_profile][n] = dict(cum)

    for p in all_profiles:
        if p == zero_profile:
            continue
        B[p] = {-1: {}}

    for p in all_profiles:
        B[p][0] = {0: 1}

    non_zero = [p for p in all_profiles if p != zero_profile]

    for n in range(1, max_n + 1):
        print(f"  Solving CW system for n={n}...")
        rhs = {}
        for p in non_zero:
            known = dict(B[p][n - 1])
            for sign, s, target in cw_system[p]:
                if target == zero_profile:
                    contrib = poly_scale(B[zero_profile][n], sign)
                    contrib = poly_shift(contrib, n * s, max_q)
                    known = poly_add(known, contrib)
            rhs[p] = known

        for p in non_zero:
            B[p][n] = dict(rhs[p])

        max_iter = max_q // max(1, n) + 2
        for iteration in range(max_iter):
            changed = False
            for p in non_zero:
                new_val = dict(rhs[p])
                for sign, s, target in cw_system[p]:
                    if target != zero_profile:
                        contrib = poly_shift(B[target][n], n * s, max_q)
                        contrib = poly_scale(contrib, sign)
                        new_val = poly_add(new_val, contrib)
                if new_val != B[p][n]:
                    changed = True
                B[p][n] = new_val
            if not changed:
                print(f"    Converged after {iteration+1} iterations")
                break

    result = {}
    for m in range(max_n + 1):
        if m == 0:
            result[m] = B[target_profile][0]
        else:
            result[m] = poly_sub(B[target_profile][m], B[target_profile][m - 1])

    return result, B


def compute_Q(b_coeffs, profile, max_n, max_q):
    d = sum(profile)
    r = len(profile)
    ell = gcd(d, r)

    def inv_qpoch(m):
        result = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in result.items():
                j = 0
                while p + i * j <= max_q:
                    new[p + i * j] = new.get(p + i * j, 0) + c
                    j += 1
            result = {k: v for k, v in new.items() if v != 0}
        return result

    def qpoch_fin(n):
        result = {0: 1}
        for i in range(1, n + 1):
            exp = ell * i
            new = {}
            for p, c in result.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + exp <= max_q:
                    new[p + exp] = new.get(p + exp, 0) - c
            result = {k: v for k, v in new.items() if v != 0}
        return result

    Q_polys = {}
    for n in range(max_n + 1):
        inner = {}
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            if shift > max_q:
                break
            inv_m = inv_qpoch(m)
            b = b_coeffs.get(n - m, {})
            term = poly_mul(inv_m, b, max_q)
            term = poly_shift(term, shift, max_q)
            term = poly_scale(term, sign)
            inner = poly_add(inner, term)

        qpn = qpoch_fin(n)
        Q = poly_mul(qpn, inner, max_q)
        Q_polys[n] = {k: v for k, v in Q.items() if v != 0}

    return Q_polys


def compute_hm(b_coeffs, max_n, max_q):
    h_polys = {}
    for m in range(max_n + 1):
        qpoch = {0: 1}
        for i in range(1, m + 1):
            new = {}
            for p, c in qpoch.items():
                if p <= max_q:
                    new[p] = new.get(p, 0) + c
                if p + i <= max_q:
                    new[p + i] = new.get(p + i, 0) - c
            qpoch = {k: v for k, v in new.items() if v != 0}
        b = b_coeffs.get(m, {})
        h = poly_mul(qpoch, b, max_q)
        h_polys[m] = h
    return h_polys


def main():
    profiles = [
        (3, 2, 2),  # d=7, first unproved case
        (4, 2, 1),  # d=7, another profile
    ]

    for profile in profiles:
        d = sum(profile)
        k = 3
        ell = gcd(d, k)
        expected_base = (d + 1) * (d + 2) // 6 - 1

        print(f"\n{'=' * 80}")
        print(f"Profile c = {profile}, d = {d}, ell = {ell}")
        print(f"Expected Q(1) = {expected_base}^n = {expected_base}")
        print(f"{'=' * 80}")

        max_n = MAX_N
        max_q = MAX_Q

        print(f"Computing with max_q = {max_q}, max_n = {max_n}...")
        b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)

        Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)

        print(f"\nQ_{{n,c}}(q):")
        for n in range(max_n + 1):
            Q = Q_polys.get(n, {})
            q1 = sum(Q.values())
            neg = [(kk, v) for kk, v in sorted(Q.items()) if v < 0]
            all_pos = len(neg) == 0
            print(f"\n  Q_{{{n}}}(q):")
            print(f"    = {poly_str(Q, 30)}")
            print(f"    Q(1) = {q1}, expected = {expected_base ** n}, match = {q1 == expected_base ** n}")
            print(f"    deg = {max(Q.keys()) if Q else 0}")
            print(f"    num_terms = {len(Q)}")
            if all_pos:
                print(f"    ALL NONNEG")
            else:
                print(f"    NEGATIVE COEFFICIENTS: {neg[:10]}")

        # Compute h_m
        print(f"\nh_m(q) = (q;q)_m * [y^m] F_c(y,q):")
        h_polys = compute_hm(b_coeffs, max_n, max_q)
        for m in range(max_n + 1):
            h = h_polys.get(m, {})
            h1 = sum(h.values())
            neg = [(kk, v) for kk, v in sorted(h.items()) if v < 0]
            all_pos = len(neg) == 0
            base_val = (d + 1) * (d + 2) // 6
            print(f"\n  h_{m}(q) = {poly_str(h, 30)}")
            print(f"    h(1) = {h1}, expected {base_val}^{m} = {base_val ** m}, match = {h1 == base_val ** m}")
            if all_pos:
                print(f"    ALL NONNEG")
            else:
                print(f"    NEGATIVE: {neg[:5]}")


if __name__ == "__main__":
    main()
