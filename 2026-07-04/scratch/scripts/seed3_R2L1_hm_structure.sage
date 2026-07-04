"""
Seed 3, R2L1: Understand WHY h_m >= 0 when gcd(d,3)=1.

h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1}.

Key identity: (q;q)_m = sum_{j=0}^m (-1)^j q^{binom(j,2)} [m choose j]_q ... no wait.
(q;q)_m = prod_{i=1}^m (1-q^i) = sum_{j=0}^m (-1)^j q^{binom(j,2)} [m choose j]_q (q-binomial expansion?)

Actually, (q;q)_m * g_m means:
h_m = g_m - (sum of parts) g_m + ...

From the injection lemma: g_m >= q * g_{m-1} coefficient-wise.
This means F_{c,m} - F_{c,m-1} >= q * (F_{c,m-1} - F_{c,m-2}).
So the DIFFERENCES are q-monotone.

Can we iterate this? If g_m >= q g_{m-1} >= q^2 g_{m-2} >= ..., then
h_m = prod(1-q^i) * g_m involves subtracting q g_m, adding q^3 g_m, etc.
The monotonicity g_m >> g_{m-1} means the "main term" g_m dominates.

Let me compute: for d=4, c=(2,1,1), look at g_m / g_{m-1} ratios.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=400)

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

d = 4
profs = profiles(d)

P = {}
for c in profs: P[(c, 0)] = R(1)
for n in range(1, 8):
    for c in profs:
        P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)

q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(8)]
qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(8)]
F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(8)}

c0 = (2, 1, 1)
g = {0: F[(c0, 0)]}
for m in range(1, 8):
    g[m] = F[(c0, m)] - F[(c0, m-1)]

h = {m: qn[m] * g[m] for m in range(8)}

print("d=4, c=(2,1,1):")
print("\ng_m coefficients:")
for m in range(6):
    print(f"  g_{m}: {g[m].list()[:20]}")

print("\ng_m - q*g_{m-1} (should be >= 0 by injection lemma):")
for m in range(1, 6):
    diff = g[m] - q * g[m-1]
    coeffs = diff.list()[:20]
    is_nn = all(c >= 0 for c in diff.list())
    print(f"  g_{m} - q*g_{m-1}: nonneg={is_nn}, coeffs={coeffs}")

print("\ng_m - q^2*g_{m-1} (stronger monotonicity?):")
for m in range(1, 6):
    diff = g[m] - q^2 * g[m-1]
    coeffs = diff.list()[:20]
    is_nn = all(c >= 0 for c in diff.list())
    print(f"  g_{m} - q^2*g_{m-1}: nonneg={is_nn}, coeffs={coeffs}")

# Try: g_m >= q * g_{m-1} + q^2 * g_{m-2}?
print("\ng_m - q*g_{m-1} - q^2*g_{m-2}:")
for m in range(2, 6):
    diff = g[m] - q * g[m-1] - q^2 * g[m-2]
    coeffs = diff.list()[:20]
    is_nn = all(c >= 0 for c in diff.list())
    print(f"  m={m}: nonneg={is_nn}, coeffs={coeffs}")

# The key: h_m = (1-q)(1-q^2)...(1-q^m) * g_m
# = g_m - q*g_m - q^2*g_m + q^3*g_m + ... (expanding the product)
# But this uses g_m for FIXED m, not different m values.

# Wait, h_m = (q;q)_m * g_m means we multiply the polynomial g_m by (q;q)_m.
# This is NOT the same as applying (q;q)_m as an operator on the g sequence.
# It's just polynomial multiplication.

# So h_m >= 0 means: g_m(q) * (1-q)(1-q^2)...(1-q^m) has nonneg coefficients.
# In other words: g_m is divisible by (q;q)_m^{-1} = 1/((1-q)...(1-q^m)) as a formal power series,
# and the quotient has nonneg coefficients.

# Actually, (q;q)_m * g_m being a polynomial with nonneg coefficients is a SPECIFIC condition
# on g_m. Let me check: is g_m itself a polynomial?

print("\n\nIs g_m a polynomial?")
for m in range(6):
    # g_m = F_{c,m} - F_{c,m-1}, both are power series (quotients of P_m and (q^3;q^3)_m).
    # But F_{c,m} is a power series, not a polynomial. So g_m is a power series.
    # However, h_m = (q;q)_m * g_m IS a polynomial (verified).
    gm_list = g[m].list()[:50]
    hm_list = h[m].list()
    print(f"  g_{m} first 20 coeffs: {gm_list[:20]}")
    print(f"  h_{m} = (q;q)_{m} * g_{m}: {hm_list}")
    
# KEY INSIGHT: g_m is a POWER SERIES (not polynomial), but (q;q)_m * g_m IS polynomial.
# This means g_m = h_m / (q;q)_m, so g_m's coefficients are determined by h_m.
# And h_m having nonneg coefficients means g_m = h_m / (q;q)_m is a specific positive
# power series expansion.

# For the ell=3 case (d=3): g_m is still a power series, h_m = (q;q)_m * g_m is polynomial,
# but h_m has NEGATIVE coefficients. This is because (q;q)_m and the structure of g_m
# interact differently when 3|d.

# The difference: for gcd(d,3)=1, the period-3 structure of the transfer matrix
# eigenvalues doesn't create destructive interference with (q;q)_m.
# For 3|d, the cube roots of unity in det(I-A(x)) = -(x^3-1) create
# period-3 oscillations in g_m that cause negativity when multiplied by (q;q)_m.

print("\n\nCompare g_m structure for d=4 vs d=3:")
print("\nd=4 (gcd=1):")
for m in range(1, 4):
    gm = g[m]
    # Coefficients modulo 3 structure
    coeffs = gm.list()[:30]
    print(f"  g_{m} mod pattern: {coeffs[:21]}")

# Now d=3
P3 = {}
profs3 = profiles(3)
for c in profs3: P3[(c, 0)] = R(1)
for n in range(1, 6):
    for c in profs3:
        P3[(c, n)] = sum(q^(n*emd(cp, c)) * P3[(cp, n-1)] for cp in profs3)
q3_3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(6)]
F3 = {(c, n): P3[(c, n)] / q3_3[n] for c in profs3 for n in range(6)}

c3 = (1, 1, 1)
g3 = {0: F3[(c3, 0)]}
for m in range(1, 6):
    g3[m] = F3[(c3, m)] - F3[(c3, m-1)]

print(f"\nd=3, c=(1,1,1) (gcd=3):")
for m in range(1, 4):
    coeffs = g3[m].list()[:30]
    print(f"  g_{m}: {coeffs[:21]}")
    # Check: does g_m have period-3 pattern?
    # Group by residue mod 3:
    r0 = [coeffs[i] for i in range(0, min(21, len(coeffs)), 3)]
    r1 = [coeffs[i] for i in range(1, min(21, len(coeffs)), 3)]
    r2 = [coeffs[i] for i in range(2, min(21, len(coeffs)), 3)]
    print(f"    mod 3 pattern: r0={r0}, r1={r1}, r2={r2}")
