"""
Check D_k^m negativity more carefully. Is D_4^5 really negative for d=7, c=(3,2,2)?
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

# Compute with higher precision
c = (3,2,2)
prec = 100
n_max = 5
print(f"Computing with precision {prec}...")
f_vals = compute_F_CW(c, n_max, prec)

PS = PowerSeriesRing(QQ, 'q', default_prec=prec)
q_ps = PS.gen()

# h_m
h = {}
for m in range(n_max + 1):
    F_cm = f_vals[(c, m)]
    qq_m = PS(1)
    for i in range(1, m+1):
        qq_m *= (1 - q_ps**i)
    h_m_ps = (qq_m * F_cm).add_bigoh(prec)
    h_m_poly = R_poly(0)
    for i in range(prec):
        coeff = h_m_ps[i]
        if coeff != 0: h_m_poly += ZZ(coeff) * q_var**i
    h[m] = h_m_poly

# D_k^m
D = {}
for m in range(n_max + 1):
    D[(0, m)] = h[m]

for k_val in range(1, n_max + 1):
    for m in range(k_val, n_max + 1):
        D[(k_val, m)] = D[(k_val-1, m)] - q_var**k_val * D[(k_val-1, m-1)]

# Check all D_k^m for positivity
print("\nD_k^m positivity check for d=7, c=(3,2,2):")
for k_val in range(n_max + 1):
    for m in range(k_val, n_max + 1):
        poly = D[(k_val, m)]
        coeffs = poly.coefficients()
        neg_coeffs = [c for c in coeffs if c < 0]
        pos = len(neg_coeffs) == 0
        val_at_1 = poly(q=1)
        if pos:
            print(f"  D_{k_val}^{m}: POSITIVE  (val@1={val_at_1})")
        else:
            min_coeff = min(neg_coeffs)
            print(f"  D_{k_val}^{m}: NEGATIVE  (min coeff={min_coeff}, val@1={val_at_1})")

# Also check d=4, c=(2,1,1) with higher m
print("\n" + "="*60)
print("D_k^m for d=4, c=(2,1,1)")
print("="*60)

c2 = (2,1,1)
f_vals2 = compute_F_CW(c2, 6, prec)

h2 = {}
for m in range(7):
    F_cm = f_vals2[(c2, m)]
    qq_m = PS(1)
    for i in range(1, m+1): qq_m *= (1 - q_ps**i)
    h_m_ps = (qq_m * F_cm).add_bigoh(prec)
    h_m_poly = R_poly(0)
    for i in range(prec):
        coeff = h_m_ps[i]
        if coeff != 0: h_m_poly += ZZ(coeff) * q_var**i
    h2[m] = h_m_poly

D2 = {}
for m in range(7): D2[(0, m)] = h2[m]
for k_val in range(1, 7):
    for m in range(k_val, 7):
        D2[(k_val, m)] = D2[(k_val-1, m)] - q_var**k_val * D2[(k_val-1, m-1)]

for k_val in range(7):
    for m in range(k_val, 7):
        poly = D2[(k_val, m)]
        coeffs = poly.coefficients()
        neg_coeffs = [c for c in coeffs if c < 0]
        pos = len(neg_coeffs) == 0
        val_at_1 = poly(q=1)
        status = "POSITIVE" if pos else f"NEGATIVE (min={min(neg_coeffs)})"
        print(f"  D_{k_val}^{m}: {status}  (val@1={val_at_1})")
