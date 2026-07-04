"""
Seed 3, R2L1: Check h_m positivity for all profiles at d=4.
Round 1 claimed h_m < 0 for m >= 2 (even when d not div by 3).
But our computation for c=(2,1,1) showed D_0^m = h_m >= 0 for m up to 5.
This contradicts Round 1. Let me verify more carefully.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=600)

def profiles(d):
    result = []
    for i in range(d+1):
        for j in range(d-i+1):
            result.append((i, j, d-i-j))
    return result

def emd(c, cp):
    e = [c[i] - cp[i] for i in range(3)]
    t_min = max(0, -e[0], -e[0]-e[1])
    return 2*e[0] + e[1] + 3*t_min

def compute_h(d, m_max, prec=600):
    profs = profiles(d)
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, m_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(m_max+1)}
    
    h = {}
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, m_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        for m in range(m_max+1):
            h[(c, m)] = qn[m] * g[m]
    
    return h, F, profs

# Check h_m for d=4, all profiles, m up to 8
d = 4
m_max = 8
h, F, profs = compute_h(d, m_max, prec=600)

print(f"d={d}: Checking h_m = (q;q)_m * g_m positivity")
print(f"Precision = 600 terms (threshold from Round 1: >= 6*max(k,m)^2 + 50 = {6*m_max**2 + 50})")

for m in range(m_max+1):
    neg_profiles = []
    for c in profs:
        hm = h[(c, m)]
        coeffs = hm.list()
        if any(v < 0 for v in coeffs):
            min_coeff = min(coeffs)
            min_idx = coeffs.index(min_coeff)
            neg_profiles.append((c, min_coeff, min_idx))
    if neg_profiles:
        print(f"  h_{m}: NEGATIVE for {len(neg_profiles)} profiles:")
        for c, mc, mi in neg_profiles[:3]:
            print(f"    c={c}: min coeff = {mc} at q^{mi}")
    else:
        print(f"  h_{m}: All nonneg ({len(profs)} profiles)")

# Check d=5 as well
print(f"\nd=5:")
d = 5
m_max = 6
h5, F5, profs5 = compute_h(d, m_max, prec=600)
for m in range(m_max+1):
    neg_profiles = []
    for c in profs5:
        hm = h5[(c, m)]
        coeffs = hm.list()
        if any(v < 0 for v in coeffs):
            min_coeff = min(coeffs)
            min_idx = coeffs.index(min_coeff)
            neg_profiles.append((c, min_coeff, min_idx))
    if neg_profiles:
        print(f"  h_{m}: NEGATIVE for {len(neg_profiles)} profiles:")
        for c, mc, mi in neg_profiles[:3]:
            print(f"    c={c}: min coeff = {mc} at q^{mi}")
    else:
        print(f"  h_{m}: All nonneg ({len(profs5)} profiles)")

# Check d=7
print(f"\nd=7:")
d = 7
m_max = 4
h7, F7, profs7 = compute_h(d, m_max, prec=600)
for m in range(m_max+1):
    neg_profiles = []
    for c in profs7:
        hm = h7[(c, m)]
        coeffs = hm.list()
        if any(v < 0 for v in coeffs):
            min_coeff = min(coeffs)
            min_idx = coeffs.index(min_coeff)
            neg_profiles.append((c, min_coeff, min_idx))
    if neg_profiles:
        print(f"  h_{m}: NEGATIVE for {len(neg_profiles)} profiles:")
        for c, mc, mi in neg_profiles[:5]:
            print(f"    c={c}: min coeff = {mc} at q^{mi}")
    else:
        print(f"  h_{m}: All nonneg ({len(profs7)} profiles)")

# Round 1 specifically said h_2 is negative for d=4, c=(2,1,1).
# Let me look at the actual coefficients.
print(f"\nDetailed check: d=4, c=(2,1,1), h_2:")
d = 4
hm = h[(( 2,1,1), 2)]
coeffs = hm.list()
print(f"  h_2 coeffs (all {len(coeffs)} terms): {coeffs}")
print(f"  nonneg: {all(c >= 0 for c in coeffs)}")
