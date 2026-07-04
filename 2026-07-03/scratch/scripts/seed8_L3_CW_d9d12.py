"""
Seed 8, Layer 3, Task 3: Compute Q_{n,c}(q) for d=9 and d=12.
Verify positivity for these larger values.
Uses the CW iterative system from seed8_L2_compute_d7.py.
"""

from itertools import combinations
from math import gcd

MAX_Q = 200  # Need larger for d=9,12
MAX_N = 3    # n up to 3

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

def compute_Dkm(h_polys, max_n, max_q):
    """Compute D_k^m from the tower: D_0^m = h_m, D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}"""
    D = {}
    for m in range(max_n + 1):
        D[(0, m)] = dict(h_polys.get(m, {}))

    for k in range(1, max_n + 1):
        for m in range(k, max_n + 1):
            prev = D.get((k-1, m), {})
            prev_shift = poly_shift(D.get((k-1, m-1), {}), k, max_q)
            D[(k, m)] = poly_sub(prev, prev_shift)

    return D

def main():
    # d=9 profiles (d not equiv 0 mod 3? 9 equiv 0 mod 3! So NOT in the conjecture.)
    # But Seed 7 discovered positivity holds for d equiv 0 mod 3 too.
    # d=9: (d+1)(d+2)/6 = 10*11/6 = not integer! So we need gcd(d,3) = gcd(9,3) = 3.
    # ell = gcd(d, r) = gcd(9, 3) = 3.
    # base formula: needs the correct formula for d equiv 0 mod 3.

    # d=10 (not equiv 0 mod 3): (11)(12)/6 - 1 = 22 - 1 = 21. Q_n(1) = 21^n.
    # d=8 (not equiv 0 mod 3): (9)(10)/6 - 1 = 15 - 1 = 14. Q_n(1) = 14^n.

    # Let's test d=8 first (smaller, already partially verified)
    # Then d=10 (first large unverified case with d not equiv 0 mod 3)
    # Then d=9 (d equiv 0 mod 3, to extend Seed 7's observation)

    test_cases = [
        # (profile, d, expected_base, description)
        ((3, 3, 2), 8, 14, "d=8, balanced"),
        ((4, 3, 1), 8, 14, "d=8, asymmetric"),
        ((4, 3, 3), 10, 21, "d=10, balanced"),
        ((5, 3, 2), 10, 21, "d=10, mid"),
        ((3, 3, 3), 9, None, "d=9, fully balanced (d equiv 0 mod 3)"),
        ((4, 3, 2), 9, None, "d=9, asymmetric (d equiv 0 mod 3)"),
    ]

    for profile, d, expected_base, desc in test_cases:
        assert sum(profile) == d
        k = 3
        ell = gcd(d, k)

        if expected_base is None:
            if d % 3 == 0:
                # For d equiv 0 mod 3, the evaluation formula is different
                # Just compute and check positivity
                pass

        print(f"\n{'=' * 80}")
        print(f"{desc}: c = {profile}, d = {d}, ell = {ell}")
        if expected_base:
            print(f"Expected Q(1) = {expected_base}^n")
        print(f"{'=' * 80}")

        max_n = 2 if d >= 10 else 3  # Reduce for larger d
        max_q = 150 if d >= 10 else MAX_Q

        print(f"Computing with max_q = {max_q}, max_n = {max_n}...")
        try:
            b_coeffs, B = solve_CW_system(profile, k, max_n, max_q)

            Q_polys = compute_Q(b_coeffs, profile, max_n, max_q)
            h_polys = compute_hm(b_coeffs, max_n, max_q)
            D = compute_Dkm(h_polys, max_n, max_q)

            print(f"\nQ_{{n,c}}(q):")
            for n in range(max_n + 1):
                Q = Q_polys.get(n, {})
                q1 = sum(Q.values())
                neg = [(kk, v) for kk, v in sorted(Q.items()) if v < 0]
                all_pos = len(neg) == 0
                print(f"\n  Q_{{{n}}}:")
                print(f"    Q(1) = {q1}")
                if expected_base:
                    print(f"    expected = {expected_base ** n}, match = {q1 == expected_base ** n}")
                print(f"    deg = {max(Q.keys()) if Q else 0}")
                print(f"    # terms = {len(Q)}")
                if all_pos:
                    print(f"    ALL COEFFICIENTS NONNEG")
                else:
                    print(f"    *** NEGATIVE COEFFICIENTS: {neg[:5]} ***")
                if n <= 1:
                    print(f"    = {poly_str(Q, 25)}")

            # h_m
            print(f"\nh_m:")
            for m in range(max_n + 1):
                h = h_polys.get(m, {})
                h1 = sum(h.values())
                neg_h = [(kk, v) for kk, v in sorted(h.items()) if v < 0]
                print(f"  h_{m}: sum={h1}, nonneg={len(neg_h)==0}, deg={max(h.keys()) if h else 0}")
                if neg_h:
                    print(f"    *** NEGATIVE h coefficients: {neg_h[:5]} ***")

            # D_k^m tower
            print(f"\nD_k^m tower:")
            for kk in range(max_n + 1):
                for m in range(kk, max_n + 1):
                    Dkm = D.get((kk, m), {})
                    s = sum(Dkm.values())
                    neg_d = [(p, v) for p, v in sorted(Dkm.items()) if v < 0]
                    status = "NONNEG" if len(neg_d) == 0 else f"NEGATIVE! {neg_d[:3]}"
                    print(f"  D_{{{kk}}}^{{{m}}}: sum={s}, {status}")

        except Exception as e:
            print(f"ERROR: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    main()
