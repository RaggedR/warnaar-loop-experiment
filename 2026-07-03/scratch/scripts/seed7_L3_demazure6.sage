"""
Seed 7 Layer 3: Unified Demazure comparison.
Compute Q_n and Demazure chars, compare systematically.
"""
from sage.all import *

R_poly = PolynomialRing(ZZ, 'q')
q_poly = R_poly.gen()

PS = PowerSeriesRing(QQ, 'q', default_prec=100)
q_ps = PS.gen()

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()

# ======================================================================
# Part 1: Compute Q_n via direct enumeration
# ======================================================================

def compute_Q_direct(c, n_max, prec=25):
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

    F_bounded = {}
    for N in range(n_max + 1):
        parts = gen_partitions(N, prec)
        poly = PS(0)
        count = 0
        for l0 in parts:
            w0 = sum(l0)
            for l1 in parts:
                w01 = w0 + sum(l1)
                if w01 > prec:
                    continue
                if not check_interlace(l0, l1, c[1]):
                    continue
                for l2 in parts:
                    wt = w01 + sum(l2)
                    if wt > prec:
                        continue
                    if not check_interlace(l1, l2, c[2]):
                        continue
                    if not check_interlace(l2, l0, c[0]):
                        continue
                    poly += q_ps^wt
                    count += 1
        F_bounded[N] = poly
        print(f"  F_{{c,{N}}} computed: {count} CPs, F(1)={count}")

    g = {0: PS(1)}
    for m in range(1, n_max + 1):
        g[m] = F_bounded[m] - F_bounded[m-1]

    h = {}
    for m in range(n_max + 1):
        qfact = PS(1)
        for i in range(1, m+1):
            qfact *= (1 - q_ps^i)
        h[m] = qfact * g[m]

    Q = {}
    for n in range(n_max + 1):
        coeff = PS(0)
        for j in range(n + 1):
            if (n-j) not in g:
                continue
            qfact_j = PS(1)
            for i in range(1, j+1):
                qfact_j *= (1 - q_ps^i)
            coeff += (-1)**j * q_ps**(j*(j+1)//2) / qfact_j * g[n-j]

        qfact_ell_n = PS(1)
        for i in range(1, n+1):
            qfact_ell_n *= (1 - q_ps**(ell*i))

        Q[n] = qfact_ell_n * coeff

    return Q, h, F_bounded


# ======================================================================
# Part 2: Demazure character computation
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
    grade = n0 + n1 + n2
    return n0, n1, n2, grade


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
    char = R_poly(0)
    for b in D:
        _, _, _, grade = extract_grade(b.weight(), hw_wt)
        char += q_poly**grade
    return char


# ======================================================================
# d=2, c=(1,1,0)
# ======================================================================
print("="*70)
print("d=2, c=(1,1,0), ell=gcd(2,3)=1, base=(3*4/6-1)=1")
print("="*70)

c_d2 = (1, 1, 0)
Q_d2, h_d2, F_d2 = compute_Q_direct(c_d2, 3, prec=20)

print("\nQ_n values:")
for n in range(4):
    Qn = Q_d2[n]
    poly_coeffs = {i: Qn[i] for i in range(50) if Qn[i] != 0}
    total = sum(poly_coeffs.values())
    print(f"  Q_{n} = {dict(sorted(poly_coeffs.items()))} (sum={total})")

print("\nF_{c,N} values:")
for N in range(4):
    FN = F_d2[N]
    fc = {i: FN[i] for i in range(20) if FN[i] != 0}
    print(f"  F_{{c,{N}}} = {dict(sorted(fc.items()))}")

# Demazure for B(Lambda_0 + Lambda_1)
print("\nDemazure chars for B(Lambda_0 + Lambda_1):")
hw_d2 = Lambda[0] + Lambda[1]
C_d2_crystal = crystals.LSPaths(ct, hw_d2)

words_systematic = [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s0s1', [0,1]), ('s1s0', [1,0]),
    ('s0s2', [0,2]), ('s2s0', [2,0]),
    ('s1s2', [1,2]), ('s2s1', [2,1]),
    ('s0s1s2', [0,1,2]), ('s2s1s0', [2,1,0]),
    ('s1s2s0', [1,2,0]), ('s0s2s1', [0,2,1]),
    ('s2s0s1', [2,0,1]), ('s1s0s2', [1,0,2]),
    ('s0s1s2s0', [0,1,2,0]),
    ('s1s2s0s1', [1,2,0,1]),
    ('s2s0s1s2', [2,0,1,2]),
    ('(s0s1s2)^2', [0,1,2,0,1,2]),
    ('(s1s2s0)^2', [1,2,0,1,2,0]),
    ('(s2s0s1)^2', [2,0,1,2,0,1]),
]

for name, word in words_systematic:
    try:
        char = demazure_char(C_d2_crystal, word, hw_d2)
        print(f"  D_{name}: char={char}, sum={char(1)}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# d=4, c=(2,1,1)
# ======================================================================
print("\n" + "="*70)
print("d=4, c=(2,1,1), ell=gcd(4,3)=1, base=(5*6/6-1)=4")
print("="*70)

c_d4 = (2, 1, 1)
Q_d4, h_d4, F_d4 = compute_Q_direct(c_d4, 3, prec=20)

print("\nQ_n values:")
for n in range(4):
    Qn = Q_d4[n]
    poly_coeffs = {i: Qn[i] for i in range(50) if Qn[i] != 0}
    total = sum(poly_coeffs.values())
    print(f"  Q_{n} = {dict(sorted(poly_coeffs.items()))} (sum={total})")

print("\nF_{c,N} values:")
for N in range(4):
    FN = F_d4[N]
    fc = {i: FN[i] for i in range(20) if FN[i] != 0}
    print(f"  F_{{c,{N}}} = {dict(sorted(fc.items()))}")

# Demazure for B(2*L0 + L1 + L2)
print("\nDemazure chars for B(2*L0 + L1 + L2):")
hw_d4 = 2*Lambda[0] + Lambda[1] + Lambda[2]
C_d4_crystal = crystals.LSPaths(ct, hw_d4)

for name, word in words_systematic:
    try:
        char = demazure_char(C_d4_crystal, word, hw_d4)
        print(f"  D_{name}: char={char}, sum={char(1)}")
    except Exception as e:
        print(f"  D_{name}: ERROR: {e}")


# ======================================================================
# Also try different highest weights for the SAME d=4
# ======================================================================
print("\n" + "="*70)
print("d=4: Try different highest weights")
print("="*70)

for hw_label, hw_wt in [
    ("4*L0", 4*Lambda[0]),
    ("L0+3*L1", Lambda[0] + 3*Lambda[1]),
    ("L0+L1+2*L2", Lambda[0] + Lambda[1] + 2*Lambda[2]),
]:
    print(f"\n--- B({hw_label}) ---")
    C_test = crystals.LSPaths(ct, hw_wt)
    # Just try a few words
    for name, word in [('e', []), ('s0', [0]), ('s2s1', [2,1]),
                        ('s0s1s2', [0,1,2]), ('s2s1s0', [2,1,0]),
                        ('s0s1s2s0', [0,1,2,0])]:
        try:
            char = demazure_char(C_test, word, hw_wt)
            print(f"  D_{name}: char={char}, sum={char(1)}")
        except Exception as e:
            print(f"  D_{name}: ERROR: {e}")
