"""
Verify h_m >= 0 for d divisible by 3 (ell=3 cases).
For ell=3: Q_n = (q^3;q^3)_n / (q;q)_n * D_n^n
So h_m >= 0 would give D_k^m >= 0 (for k >= 0), hence D_n^n >= 0,
but Q_n involves an extra factor (q^3;q^3)_n / (q;q)_n.

Wait -- for ell=3, the definition changes:
Q_n = (q^3;q^3)_n * [z^n]((zq;q)_inf * F_c(z,q))
   = (q^3;q^3)_n / (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j] h_j

Hmm, this is NOT = D_n^n when ell=3. Let me be careful.

Actually D_n^n = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j] h_j
= (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

So Q_n = (q^ell;q^ell)_n / (q;q)_n * D_n^n for ell=1: Q_n = D_n^n.
For ell=3: Q_n = (q^3;q^3)_n / (q;q)_n * D_n^n.

The factor (q^3;q^3)_n / (q;q)_n is NOT a polynomial with nonneg coefficients.
For n=1: (1-q^3)/(1-q) = 1+q+q^2. That's fine.
For n=2: (1-q^3)(1-q^6)/((1-q)(1-q^2)) = (1+q+q^2)(1+q^2+q^4). Still nonneg!
For n=3: add factor (1-q^9)/(1-q^3) = 1+q^3+q^6. Still nonneg!

So (q^3;q^3)_n / (q;q)_n = prod_{i=1}^n (1-q^{3i})/(1-q^i) = prod_{i=1}^n (1+q^i+q^{2i}).
EVERY factor is nonneg! So (q^3;q^3)_n / (q;q)_n >= 0 always.

Therefore: if D_n^n >= 0 (which follows from h_m >= 0), then Q_n >= 0 for ell=3 too!
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=800)

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

# First verify (q^3;q^3)_n / (q;q)_n = prod (1+q^i+q^{2i}) >= 0
print("Verifying (q^3;q^3)_n / (q;q)_n = prod_{i=1}^n (1+q^i+q^{2i}):")
for n in range(1, 8):
    q3n = prod(1 - q^(3*i) for i in range(1, n+1))
    qn = prod(1 - q^i for i in range(1, n+1))
    ratio = q3n / qn
    prod_form = prod(1 + q^i + q^(2*i) for i in range(1, n+1))
    diff = ratio - prod_form
    coeffs = ratio.list()[:30]
    is_nn = all(c >= 0 for c in coeffs)
    print(f"  n={n}: ratio == prod form: {diff == R(0)}, nonneg: {is_nn}")

# Now check h_m for d=3 and d=6
for d in [3, 6]:
    profs = profiles(d)
    ell = gcd(d, 3)
    m_max = 5 if d <= 6 else 3
    
    print(f"\nd={d}, ell={ell}, checking h_m:")
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, m_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(m_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(m_max+1)}
    
    for m in range(m_max+1):
        neg_count = 0
        for c in profs:
            gm = F[(c, m)] - F.get((c, m-1), R(0)) if m > 0 else F[(c, 0)]
            hm = qn[m] * gm
            coeffs = hm.list()
            if any(v < 0 for v in coeffs):
                neg_count += 1
                if neg_count <= 2:
                    min_v = min(coeffs)
                    print(f"  h_{m} NEGATIVE at c={c}, min = {min_v}")
        if neg_count == 0:
            print(f"  h_{m}: All nonneg ({len(profs)} profiles)")
        elif neg_count > 2:
            print(f"  h_{m}: NEGATIVE for {neg_count} profiles total")

# Also verify Q_n >= 0 for d=3, d=6 with ell=3
print("\n" + "=" * 60)
print("Q_n verification for d=3 (ell=3) and d=6 (ell=3)")
print("=" * 60)

for d in [3, 6]:
    profs = profiles(d)
    ell = gcd(d, 3)
    n_max = 4 if d <= 6 else 2
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, n_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(n_max+1)}
    
    for n in range(1, n_max+1):
        all_nn = True
        for c in profs:
            g = {0: F[(c, 0)]}
            for m in range(1, n+1):
                g[m] = F[(c, m)] - F[(c, m-1)]
            h = {m: qn[m] * g[m] for m in range(n+1)}
            
            D = {}
            for m in range(n+1): D[(0, m)] = h[m]
            for k in range(1, n+1):
                for m in range(k, n+1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            
            Dnn = D[(n, n)]
            # Q_n = (q^ell;q^ell)_n / (q;q)_n * D_n^n
            qelln = prod(1 - q^(ell*i) for i in range(1, n+1))
            Qn = qelln * Dnn / qn[n]
            
            coeffs = Qn.list()
            if any(v < 0 for v in coeffs):
                all_nn = False
                print(f"  d={d}, c={c}, n={n}: NEGATIVE Q_n!")
        
        if all_nn:
            # Sample eval
            sample_c = profs[len(profs)//2]
            g = {0: F[(sample_c, 0)]}
            for m in range(1, n+1):
                g[m] = F[(sample_c, m)] - F[(sample_c, m-1)]
            h = {m: qn[m] * g[m] for m in range(n+1)}
            D = {}
            for m in range(n+1): D[(0, m)] = h[m]
            for k in range(1, n+1):
                for m in range(k, n+1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            qelln = prod(1 - q^(ell*i) for i in range(1, n+1))
            Qn = qelln * D[(n, n)] / qn[n]
            ev = sum(Qn.list())
            print(f"  d={d}, n={n}: ALL Q_n nonneg ({len(profs)} profiles), sample Q_n(1) = {ev}")
