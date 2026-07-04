"""
Seed 3, R2L1: CRITICAL VERIFICATION.
Round 1 said h_m < 0 for m >= 2 (Agent A, killed Path A).
We found h_m >= 0 for d=4,5,7 with precision 600.
Round 1's precision warning (BA15) said need >= 6*max(k,m)^2 + 50.
For m=8: need >= 6*64 + 50 = 434.

Let me verify with VERY high precision to make sure these aren't artifacts.
Also check d=8,10,11 for robustness.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=1000)

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

def check_hm(d, m_max, prec=1000):
    profs = profiles(d)
    ell = gcd(d, 3)
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, m_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(m_max+1)}
    
    results = []
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, m_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        for m in range(m_max+1):
            hm = qn[m] * g[m]
            coeffs = hm.list()
            is_nn = all(v >= 0 for v in coeffs)
            if not is_nn:
                min_v = min(coeffs)
                results.append((c, m, min_v))
    return results, profs

for d in [4, 5, 7, 8, 10, 11]:
    m_max = min(6, max(3, 12 - d))  # smaller for larger d (computational cost)
    print(f"\nd={d}, m_max={m_max}:")
    neg, profs = check_hm(d, m_max)
    if neg:
        for c, m, mv in neg[:5]:
            print(f"  h_{m} NEGATIVE at c={c}, min coeff = {mv}")
    else:
        print(f"  ALL h_m nonneg for all {len(profs)} profiles, m=0,...,{m_max}")
        print(f"  (This means h_m >= 0 conjecture holds for d={d}!)")

# Also verify D_k^m >= 0 for k >= 0 (not just k >= 1)
print("\n" + "=" * 60)
print("D_k^m positivity for d=4, all profiles, all k,m <= 5")
print("=" * 60)

d = 4
profs = profiles(d)
m_max = 5
neg_results = check_hm(d, m_max)

# Compute D_k^m for a selection of profiles
for c0 in [(2,1,1), (4,0,0), (1,1,2), (0,2,2)]:
    P = {}
    P[(c0, 0)] = R(1)
    for n in range(1, m_max+1):
        P[(c0, n)] = sum(q^(n*emd(cp, c0)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    
    # Need P for all profiles at all levels
    PP = {}
    for c in profs: PP[(c, 0)] = R(1)
    for n in range(1, m_max+1):
        for c in profs:
            PP[(c, n)] = sum(q^(n*emd(cp, c)) * PP[(cp, n-1)] for cp in profs)
    
    F = {n: PP[(c0, n)] / q3[n] for n in range(m_max+1)}
    g = {0: F[0]}
    for m in range(1, m_max+1):
        g[m] = F[m] - F[m-1]
    h = {m: qn[m] * g[m] for m in range(m_max+1)}
    
    D = {}
    for m in range(m_max+1):
        D[(0, m)] = h[m]
    for k in range(1, m_max+1):
        for m in range(k, m_max+1):
            D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
    
    print(f"\nc={c0}:")
    for k in range(m_max+1):
        for m in range(k, m_max+1):
            coeffs = D[(k,m)].list()
            is_nn = all(v >= 0 for v in coeffs)
            if not is_nn:
                print(f"  D_{k}^{m}: NEGATIVE (min = {min(coeffs)})")
            else:
                ev = sum(coeffs)
                print(f"  D_{k}^{m}: nonneg, eval = {ev}")
