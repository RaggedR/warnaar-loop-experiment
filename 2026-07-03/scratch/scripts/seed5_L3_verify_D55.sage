"""
CRITICAL: Check if D_5^5 = Q_5 is negative for d=7, c=(3,2,2).
If so, either our computation has a precision issue or the conjecture is false!
Compute with higher precision.
"""
from itertools import combinations, product as iproduct

R_poly = PolynomialRing(ZZ, 'q')
q_var = R_poly.gen()

def compute_F_CW(c, n_max, prec):
    k = len(c); d = sum(c); t = k + d
    PS = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q_ps = PS.gen()
    all_profiles = [tuple(parts) for parts in iproduct(range(d+1), repeat=k) if sum(parts) == d]

    def shifted_profile(cc, J):
        cc_new = list(cc)
        J_set = set(J)
        for i in range(k):
            prev = (i - 1) % k
            if i in J_set and prev not in J_set: cc_new[i] -= 1
            elif i not in J_set and prev in J_set: cc_new[i] += 1
        return tuple(cc_new)

    f = {}; S = {}
    for cc in all_profiles: f[(cc, 0)] = PS(1); S[(cc, 0)] = PS(1)

    for N in range(1, n_max + 1):
        b_vec = {}; B_entries = {}
        for cc in all_profiles:
            I_cc = [i for i in range(k) if cc[i] > 0]
            b_val = PS(0)
            for r in range(1, len(I_cc) + 1):
                for J in combinations(I_cc, r):
                    J = list(J); s = len(J); sign = (-1)**(s - 1)
                    cc_J = shifted_profile(cc, J)
                    if any(x < 0 for x in cc_J) or sum(cc_J) != d: continue
                    coeff = sign * q_ps**(s * N)
                    b_val += coeff * S.get((cc_J, N-1), PS(0))
                    key = (cc, cc_J)
                    B_entries[key] = B_entries.get(key, PS(0)) + coeff
            b_vec[cc] = b_val

        x = dict(b_vec)
        for _ in range(prec // N + 3):
            x_new = {}
            for cc in all_profiles:
                val = PS(b_vec[cc])
                for cc2 in all_profiles:
                    key = (cc, cc2)
                    if key in B_entries: val += B_entries[key] * x.get(cc2, PS(0))
                x_new[cc] = val.add_bigoh(prec)
            x = x_new
        for cc in all_profiles:
            f[(cc, N)] = x[cc]
            S[(cc, N)] = S.get((cc, N-1), PS(0)) + f[(cc, N)]
    return f

c = (3,2,2)
# deg(Q_5) ~ 6*25 = 150. Need prec at least 160.
prec = 180
n_max = 5
print(f"Computing F_{{c,m}} with precision {prec}...")
f_vals = compute_F_CW(c, n_max, prec)

PS = PowerSeriesRing(QQ, 'q', default_prec=prec)
q_ps = PS.gen()

# Compute Q_5 directly from the definition
print("\nComputing Q_5 directly...")
ell = gcd(7, 3)  # = 1
for n in [4, 5]:
    val = PS(0)
    for j in range(n + 1):
        sign = (-1)**j
        q_shift = q_ps**(j*(j+1)//2)
        qq_j = PS(1)
        for i in range(1, j+1): qq_j *= (1 - q_ps**i)
        F_val = f_vals[(c, n-j)]
        val += sign * q_shift * F_val / qq_j

    qq_ell_n = PS(1)
    for i in range(1, n+1): qq_ell_n *= (1 - q_ps**(ell*i))

    Q_n = (qq_ell_n * val).add_bigoh(prec)
    Q_poly = R_poly(0)
    for i in range(prec):
        coeff = Q_n[i]
        if coeff != 0: Q_poly += ZZ(coeff) * q_var**i

    coeffs = Q_poly.coefficients()
    neg = [c for c in coeffs if c < 0]
    print(f"Q_{n}(1) = {Q_poly(q=1)}")
    print(f"  degree = {Q_poly.degree()}")
    print(f"  # terms = {len(coeffs)}")
    if neg:
        print(f"  NEGATIVE coefficients found! min = {min(neg)}")
        # Show the negative terms
        for exp, c in Q_poly.dict().items():
            if c < 0:
                print(f"    q^{exp}: {c}")
    else:
        print(f"  ALL POSITIVE ({len(coeffs)} coefficients)")

# Also compute h_m and D_k^m to precision 180
print("\nComputing D_k^m tower with prec=180...")
h = {}
for m in range(n_max + 1):
    F_cm = f_vals[(c, m)]
    qq_m = PS(1)
    for i in range(1, m+1): qq_m *= (1 - q_ps**i)
    h_m_ps = (qq_m * F_cm).add_bigoh(prec)
    h_m_poly = R_poly(0)
    for i in range(prec):
        coeff = h_m_ps[i]
        if coeff != 0: h_m_poly += ZZ(coeff) * q_var**i
    h[m] = h_m_poly

D = {}
for m in range(n_max + 1): D[(0, m)] = h[m]
for k_val in range(1, n_max + 1):
    for m in range(k_val, n_max + 1):
        D[(k_val, m)] = D[(k_val-1, m)] - q_var**k_val * D[(k_val-1, m-1)]

# Check D_4^5 and D_5^5
for kk, mm in [(4,5), (5,5)]:
    poly = D[(kk, mm)]
    coeffs = poly.coefficients()
    neg = [c for c in coeffs if c < 0]
    print(f"\nD_{kk}^{mm}(1) = {poly(q=1)}")
    print(f"  degree = {poly.degree()}")
    if neg:
        print(f"  NEGATIVE! min={min(neg)}, count={len(neg)}")
        for exp, c in poly.dict().items():
            if c < 0:
                print(f"    q^{exp}: {c}")
    else:
        print(f"  POSITIVE")

# Check: does D_5^5 agree with Q_5?
Q5_direct = R_poly(0)
n = 5
val = PS(0)
for j in range(n + 1):
    sign = (-1)**j
    q_shift = q_ps**(j*(j+1)//2)
    qq_j = PS(1)
    for i in range(1, j+1): qq_j *= (1 - q_ps**i)
    F_val = f_vals[(c, n-j)]
    val += sign * q_shift * F_val / qq_j
qq_ell_n = PS(1)
for i in range(1, n+1): qq_ell_n *= (1 - q_ps**(i))
Q5_ps = (qq_ell_n * val).add_bigoh(prec)
for i in range(prec):
    coeff = Q5_ps[i]
    if coeff != 0: Q5_direct += ZZ(coeff) * q_var**i

diff = D[(5,5)] - Q5_direct
print(f"\nD_5^5 - Q_5 = {diff}")
print(f"D_5^5 == Q_5: {diff == 0}")
