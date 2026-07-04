"""
Seed 7 Layer 3: PRECISE Q_n vs Demazure comparison.
The key observation: Q_1 for d=4 appears to match D_{s1s2} - D_e = D_{s1s2} - 1.
Verify this precisely and extend to higher n.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()

R = PolynomialRing(ZZ, 'q')
q = R.gen()

# ======================================================================
# Demazure character computation
# ======================================================================
def extract_grade(wt, hw_wt):
    diff = hw_wt - wt
    coeffs = diff.monomial_coefficients()
    d0 = coeffs.get(0, 0)
    d1 = coeffs.get(1, 0)
    d2 = coeffs.get(2, 0)
    d_delta = coeffs.get('delta', 0)
    n0 = d_delta
    n1 = (d1 - d0 + 3*d_delta) // 3
    n2 = (d2 - d0 + 3*d_delta) // 3
    return n0 + n1 + n2

def demazure_set(crystal, word):
    hw = crystal.module_generators[0]
    current = set([hw])
    for i in reversed(word):
        new_set = set()
        for b in current:
            x = b
            while x is not None:
                new_set.add(x)
                x = x.f(i)
        current = new_set
    return current

def demazure_char(crystal, word, hw_wt):
    D = demazure_set(crystal, word)
    char = R(0)
    for b in D:
        grade = extract_grade(b.weight(), hw_wt)
        char += q**grade
    return char

# ======================================================================
# Compute Q_n EXACTLY using q-series with enough precision
# ======================================================================
def compute_Q_exact(c, n_max, weight_max=60):
    """Compute Q_n by enumerating cylindric partitions directly.
    Returns exact polynomials."""
    k = len(c)
    d = sum(c)
    ell = gcd(d, k)
    
    from sage.combinat.partition import Partitions
    
    def gen_partitions(max_part, max_weight):
        result = [Partition([])]
        for w in range(1, max_weight + 1):
            for p in Partitions(w, max_part=max_part):
                result.append(p)
        return result
    
    def check_interlace(lam, mu, shift):
        max_j = max(len(lam), len(mu) + shift, 1) + 1
        for j in range(1, max_j + 1):
            l_j = lam[j-1] if j-1 < len(lam) else 0
            idx = j + shift - 1
            m_js = mu[idx] if 0 <= idx < len(mu) else 0
            if l_j < m_js:
                return False
        return True
    
    # For exact Q_n computation, we need g_m(q) which are infinite series.
    # But h_m(q) = (q;q)_m * g_m(q) should be a POLYNOMIAL.
    # This is the key fact (Welsh proved it).
    
    # Compute h_m by: h_m(q) = (q;q)_m * (F_{c,m} - F_{c,m-1})
    # where F_{c,m} is a power series.
    # The trick: (q;q)_m * g_m should be polynomial of degree (d-1)*m^2 + O(m).
    # So we only need to compute g_m up to that degree.
    
    PS_loc = PowerSeriesRing(QQ, 'qq', default_prec=weight_max+10)
    qq = PS_loc.gen()
    
    F_bounded = {}
    for N in range(n_max + 1):
        parts = gen_partitions(N, weight_max)
        poly = PS_loc(0)
        count = 0
        for l0 in parts:
            w0 = sum(l0)
            for l1 in parts:
                w01 = w0 + sum(l1)
                if w01 > weight_max:
                    continue
                if not check_interlace(l0, l1, c[1]):
                    continue
                for l2 in parts:
                    wt = w01 + sum(l2)
                    if wt > weight_max:
                        continue
                    if not check_interlace(l1, l2, c[2]):
                        continue
                    if not check_interlace(l2, l0, c[0]):
                        continue
                    poly += qq**wt
                    count += 1
        F_bounded[N] = poly
        print(f"  F_{{c,{N}}}: {count} CPs enumerated")
    
    g = {0: PS_loc(1)}
    for m in range(1, n_max + 1):
        g[m] = F_bounded[m] - F_bounded[m-1]
    
    h = {}
    for m in range(n_max + 1):
        qfact = PS_loc(1)
        for i in range(1, m+1):
            qfact *= (1 - qq**i)
        hm_series = qfact * g[m]
        # Convert to polynomial (should be exact if weight_max is large enough)
        hm_poly = R(0)
        for i in range(weight_max + 1):
            c_i = hm_series[i]
            if c_i != 0:
                hm_poly += int(c_i) * q**i
        h[m] = hm_poly
    
    # Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q * h_{n-j}
    def qbinom_poly(n, j):
        if j < 0 or j > n:
            return R(0)
        # [n choose j]_q = (q^{n-j+1};q)_j / (q;q)_j
        num = R(1)
        den = R(1)
        for i in range(1, j+1):
            num *= (1 - q**(n-j+i))
            den *= (1 - q**i)
        return num // den  # exact division in Z[q]
    
    Q = {}
    for n in range(n_max + 1):
        Qn = R(0)
        for j in range(n + 1):
            if (n-j) not in h:
                break
            Qn += (-1)**j * q**(j*(j+1)//2) * qbinom_poly(n, j) * h[n-j]
        Q[n] = Qn
    
    return Q, h


# ======================================================================
# d=2 comparison
# ======================================================================
print("="*70)
print("d=2, c=(1,1,0)")
print("base = (3*4/6 - 1) = 1")
print("="*70)

c = (1, 1, 0)
Q2, h2 = compute_Q_exact(c, 3, weight_max=40)

print("\nh_m:")
for m in range(4):
    print(f"  h_{m} = {h2[m]}")

print("\nQ_n:")
for n in range(4):
    print(f"  Q_{n} = {Q2[n]}  [sum = {Q2[n](1)}]")

print("\nDemazure chars for B(L0 + L1):")
hw = Lambda[0] + Lambda[1]
C = crystals.LSPaths(ct, hw)

# Systematic longer words
for name, word in [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s2s1', [2,1]), ('s1s2', [1,2]),
    ('s0s1', [0,1]), ('s1s0', [1,0]),
    ('s0s2', [0,2]), ('s2s0', [2,0]),
    ('s0s1s2', [0,1,2]), ('s2s1s0', [2,1,0]),
    ('s0s1s2s0', [0,1,2,0]),
    ('s2s1s0s2', [2,1,0,2]),
    ('s1s2s1s0', [1,2,1,0]),
    ('s0s2s1s0', [0,2,1,0]),
    ('s2s0s1s2', [2,0,1,2]),
    ('s0s1s2s0s1', [0,1,2,0,1]),
    ('s2s1s0s2s1', [2,1,0,2,1]),
    ('s0s1s2s0s1s2', [0,1,2,0,1,2]),
]:
    try:
        char = demazure_char(C, word, hw)
        print(f"  D_{name} = {char}  [sum={char(1)}]")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# d=4 comparison 
# ======================================================================
print("\n" + "="*70)
print("d=4, c=(2,1,1)")
print("base = (5*6/6 - 1) = 4")
print("="*70)

c = (2, 1, 1)
Q4, h4 = compute_Q_exact(c, 2, weight_max=40)

print("\nh_m:")
for m in range(3):
    print(f"  h_{m} = {h4[m]}")

print("\nQ_n:")
for n in range(3):
    print(f"  Q_{n} = {Q4[n]}  [sum = {Q4[n](1)}]")

print("\nDemazure chars for B(2*L0 + L1 + L2):")
hw = 2*Lambda[0] + Lambda[1] + Lambda[2]
C = crystals.LSPaths(ct, hw)

for name, word in [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s1s2', [1,2]), ('s2s1', [2,1]),
    ('s0s1', [0,1]), ('s1s0', [1,0]),
    ('s0s2', [0,2]), ('s2s0', [2,0]),
    ('s0s1s2', [0,1,2]), ('s2s1s0', [2,1,0]),
    ('s0s2s1', [0,2,1]), ('s1s0s2', [1,0,2]),
    ('s1s2s0', [1,2,0]), ('s2s0s1', [2,0,1]),
    ('s0s1s2s0', [0,1,2,0]),
    ('s2s1s0s2', [2,1,0,2]),
    ('s0s1s2s1', [0,1,2,1]),
    ('s0s2s1s0', [0,2,1,0]),
    ('s1s2s0s1', [1,2,0,1]),
    ('s2s0s1s2', [2,0,1,2]),
    ('s0s1s2s0s1', [0,1,2,0,1]),
    ('s2s1s0s2s1', [2,1,0,2,1]),
    ('s0s1s2s0s1s2', [0,1,2,0,1,2]),
    ('s2s1s0s2s1s0', [2,1,0,2,1,0]),
]:
    try:
        char = demazure_char(C, word, hw)
        print(f"  D_{name} = {char}  [sum={char(1)}]")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")

# KEY CHECK
print("\n" + "="*70)
print("KEY COMPARISON")
print("="*70)

# Q_1 for d=4 should be 2q + q^2 + q^3 (sum=4)
# D_{s1s2} for B(2*L0+L1+L2) should be q^3 + q^2 + 2q + 1 (sum=5)
# D_{s1s2} - 1 = q^3 + q^2 + 2q (sum=4)
# Check: does Q_1 = D_{s1s2} - D_e ?

Q1 = Q4[1]
D_e = demazure_char(C, [], hw)
D_s1s2 = demazure_char(C, [1,2], hw)

print(f"Q_1 = {Q1}")
print(f"D_e = {D_e}")
print(f"D_{{s1s2}} = {D_s1s2}")
print(f"D_{{s1s2}} - D_e = {D_s1s2 - D_e}")
print(f"MATCH: Q_1 == D_{{s1s2}} - D_e ? {Q1 == D_s1s2 - D_e}")

# Also check Q_2
if 2 in Q4:
    Q2_val = Q4[2]
    print(f"\nQ_2 = {Q2_val}")
    print(f"Q_2(1) = {Q2_val(1)}")
    
    # If the pattern holds, Q_2 = D_{w_2} - D_{w_1} or similar
    # Q_2(1) should be 16 (= 4^2)
    # Check various Demazure differences
    for name2, word2 in [
        ('s0s1s2', [0,1,2]),
        ('s2s1s0', [2,1,0]),
        ('s0s2s1', [0,2,1]),
        ('s1s0s2', [1,0,2]),
        ('s1s2s0', [1,2,0]),
        ('s2s0s1', [2,0,1]),
        ('s0s1s2s0', [0,1,2,0]),
        ('s2s1s0s2', [2,1,0,2]),
        ('s0s1s2s1', [0,1,2,1]),
        ('s0s2s1s0', [0,2,1,0]),
        ('s1s2s0s1', [1,2,0,1]),
        ('s2s0s1s2', [2,0,1,2]),
    ]:
        D2 = demazure_char(C, word2, hw)
        diff = D2 - D_s1s2
        if diff(1) == Q2_val(1):
            print(f"  D_{name2} - D_s1s2: sum={diff(1)}, match_sum=True")
            print(f"    D_{name2} - D_s1s2 = {diff}")
            print(f"    Q_2 = {Q2_val}")
            print(f"    EXACT MATCH: {diff == Q2_val}")

