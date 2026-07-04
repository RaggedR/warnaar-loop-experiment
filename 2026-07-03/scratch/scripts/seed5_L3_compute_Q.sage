"""
Seed 5, Layer 3: Compute Q_{n,c}(q) for d=7 profiles using CW recurrence.
"""

from itertools import combinations

R = PolynomialRing(ZZ, 'q')
q = R.gen()

def shifted_profile(cc, J, k):
    cc_new = list(cc)
    J_set = set(J)
    for i in range(k):
        prev = (i - 1) % k
        if i in J_set and prev not in J_set:
            cc_new[i] = cc[i] - 1
        elif i not in J_set and prev in J_set:
            cc_new[i] = cc[i] + 1
    return tuple(cc_new)

def compute_Q_via_CW(c, n_max, prec):
    k = len(c)
    d = sum(c)
    ell = gcd(d, k)
    t = k + d

    PS = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q_ps = PS.gen()

    # All profiles
    from itertools import product as iproduct
    all_profiles = []
    for parts in iproduct(range(d+1), repeat=k):
        if sum(parts) == d:
            all_profiles.append(tuple(parts))
    print(f"  {len(all_profiles)} profiles for d={d}, k={k}")

    # Initialize f and S
    f = {}
    S = {}
    for cc in all_profiles:
        f[(cc, 0)] = PS(1)
        S[(cc, 0)] = PS(1)

    for N in range(1, n_max + 1):
        # Build B and b for Neumann series
        b_vec = {}
        B_entries = {}

        for cc in all_profiles:
            I_cc = [i for i in range(k) if cc[i] > 0]
            b_val = PS(0)

            for r in range(1, len(I_cc) + 1):
                for J in combinations(I_cc, r):
                    J = list(J)
                    s = len(J)
                    sign = (-1)**(s - 1)
                    cc_J = shifted_profile(cc, J, k)
                    if any(x < 0 for x in cc_J):
                        continue
                    if sum(cc_J) != d:
                        continue

                    coeff = sign * q_ps**(s * N)
                    b_val += coeff * S.get((cc_J, N-1), PS(0))

                    key = (cc, cc_J)
                    B_entries[key] = B_entries.get(key, PS(0)) + coeff

            b_vec[cc] = b_val

        # Neumann series
        x = dict(b_vec)
        for iteration in range(prec // N + 3):
            x_new = {}
            for cc in all_profiles:
                val = PS(b_vec[cc])
                for cc2 in all_profiles:
                    key = (cc, cc2)
                    if key in B_entries:
                        val = val + B_entries[key] * x.get(cc2, PS(0))
                x_new[cc] = val.add_bigoh(prec)
            x = x_new

        for cc in all_profiles:
            f[(cc, N)] = x[cc]
            S[(cc, N)] = S.get((cc, N-1), PS(0)) + f[(cc, N)]

    # Compute Q_n
    results = {}
    target_c = tuple(c)

    for n in range(n_max + 1):
        val = PS(0)
        for j in range(n + 1):
            sign = (-1)**j
            q_shift = q_ps**(j*(j+1)//2)
            qq_j = PS(1)
            for i in range(1, j+1):
                qq_j *= (1 - q_ps**i)
            f_val = f.get((target_c, n-j), PS(0))
            val += sign * q_shift * f_val / qq_j

        qq_ell_n = PS(1)
        for i in range(1, n+1):
            qq_ell_n *= (1 - q_ps**(ell*i))

        Q_n = (qq_ell_n * val).add_bigoh(prec)

        Q_poly = R(0)
        for i in range(prec):
            coeff = Q_n[i]
            if coeff != 0:
                Q_poly += ZZ(coeff) * q**i

        results[n] = Q_poly
        coeffs_list = Q_poly.coefficients()
        pos = all(c >= 0 for c in coeffs_list) if coeffs_list else True
        print(f"  Q_{n} = {Q_poly}")
        print(f"    Q_{n}(1) = {Q_poly(1)}, positive = {pos}")

    return results

print("=" * 60)
print("d=7, c=(3,2,2)")
print("=" * 60)
Q_322 = compute_Q_via_CW((3,2,2), 3, 80)

print()
print("=" * 60)
print("d=7, c=(4,2,1)")
print("=" * 60)
Q_421 = compute_Q_via_CW((4,2,1), 3, 80)
