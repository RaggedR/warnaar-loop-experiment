"""
Seed 7 Layer 3: Systematic search for Demazure-Q relationship.

Confirmed: Q_1 = D_{s1s2} - 1 for d=4, c=(2,1,1).
Now search for Q_2 = D_w2 - D_w1 or similar.

Also: Q_n for d=2 is just q^{n^2}. Check this against Demazure.
For d=2: Q_1 = q, Q_2 = q^4, Q_3 = q^9.
D_e = 1, D_s0 = q+1, D_s1 = q+1.
Q_1 = q = D_s0 - 1 = D_s1 - 1. (Both work because of symmetry.)

Key hypothesis: F_{c,N} = Demazure char D_{w_N} for some word w_N.
Then Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_N D_{w_N} z^N).

But let me check if F_{c,N} matches ANY Demazure character directly.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()

R = PolynomialRing(ZZ, 'q')
q = R.gen()

PS = PowerSeriesRing(QQ, 'qq', default_prec=80)
qq = PS.gen()

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
# F_{c,N} as power series (truncated)
# ======================================================================
def compute_F_bounded_ps(c, N, prec=50):
    """Compute F_{c,N}(q) as truncated power series."""
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
    
    parts = gen_partitions(N, prec)
    poly = PS(0)
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
                poly += qq**wt
    return poly


# ======================================================================
# d=4, c=(2,1,1): Check if F_{c,N} = D_{w_N}
# ======================================================================
print("="*70)
print("d=4, c=(2,1,1): Testing F_{c,N} = D_{w_N}")
print("="*70)

c = (2, 1, 1)
hw = 2*Lambda[0] + Lambda[1] + Lambda[2]
C = crystals.LSPaths(ct, hw)

# Compute F_{c,N} for N=0,1,2
F_bounded = {}
for N in range(3):
    print(f"\nComputing F_{{c,{N}}}...")
    F_bounded[N] = compute_F_bounded_ps(c, N, prec=20)
    fc = {i: F_bounded[N][i] for i in range(20) if F_bounded[N][i] != 0}
    print(f"  F_{{c,{N}}} = {dict(sorted(fc.items()))}")

# Compute Demazure chars as power series for comparison
# Convert poly to PS for comparison
def poly_to_ps(p):
    result = PS(0)
    for i in range(p.degree() + 1):
        result += p[i] * qq**i
    return result

# Try all Demazure chars and see which matches F_{c,1}
# F_{c,1} starts: 1 + 3q + 4q^2 + 5q^3 + 5q^4 + 5q^5 + ...
print("\n--- Looking for D_w matching F_{c,1} (first 15 terms) ---")
F1_target = F_bounded[1]

# Generate many reduced words systematically
from itertools import product as iproduct

def generate_words(max_len):
    words = []
    for length in range(max_len + 1):
        for w in iproduct([0,1,2], repeat=length):
            words.append(list(w))
    return words

all_words = generate_words(6)

matches_F1 = []
for word in all_words:
    try:
        char = demazure_char(C, word, hw)
        char_ps = poly_to_ps(char)
        # Check first 15 coefficients
        match = True
        for i in range(15):
            if char_ps[i] != F1_target[i]:
                match = False
                break
        if match:
            matches_F1.append((word, char))
            print(f"  MATCH (15 terms): word={word}, |D|={char(1)}")
            if len(matches_F1) >= 5:
                break
    except:
        pass

if not matches_F1:
    # Try partial matches: find chars with same first few terms
    print("\n  No exact match for 15 terms. Looking for closest match...")
    best = None
    best_terms = 0
    for word in all_words:
        if len(word) > 4:
            continue
        try:
            char = demazure_char(C, word, hw)
            char_ps = poly_to_ps(char)
            terms = 0
            for i in range(20):
                if char_ps[i] == F1_target[i]:
                    terms += 1
                else:
                    break
            if terms > best_terms:
                best_terms = terms
                best = (word, char, terms)
        except:
            pass
    if best:
        print(f"  Best match: word={best[0]}, {best[2]} terms, char={best[1]}")

# F_{c,1} is an infinite power series. But D_w is a POLYNOMIAL.
# So F_{c,1} CANNOT be a single Demazure character.
# F_{c,1} = sum_{m=0}^1 g_m(q) where g_0=1 and g_1 is infinite.

# The right relationship might be:
# g_m = sum of Demazure characters at depth m (multiple words)
# Or: the FULL crystal character (not Demazure) matches F_c(q) = F_{c,infty}

print("\n" + "="*70)
print("KEY INSIGHT: F_{c,N} is a POWER SERIES, not a polynomial.")
print("Demazure characters are POLYNOMIALS.")
print("So F_{c,N} != D_w for any w.")
print("")
print("But Q_n IS a polynomial, and so is D_w - D_w'.")
print("The match Q_1 = D_{s1s2} - 1 is a polynomial-level match.")
print("="*70)

# So the hypothesis is: Q_n = D_{w_n} - D_{w_{n-1}} (or similar)
# with the principal grading.

# For d=4:
# Q_0 = 1 (= D_e)
# Q_1 = D_{s1s2} - D_e = D_{s1s2} - 1

# For Q_2: Q_2(1) = 16. D_{s1s2}(1) = 5.
# If Q_0 + Q_1 + Q_2 = D_{w_2} for some w_2, then:
# D_{w_2}(1) = 1 + 4 + 16 = 21. 
# Hmm, no Demazure char has sum 21.

# Actually the relationship between Q_n and F_{c,N} involves (q;q)_n factors.
# Let me think about this differently.

# Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_N g_N z^N)
# The key identity: [z^n]((zq;q)_inf * sum_N g_N z^N)
# = sum_j (-1)^j q^{j(j+1)/2}/(q;q)_j * g_{n-j}
# = sum_j (-1)^j q^{j(j+1)/2}/(q;q)_j * (h_{n-j}/(q;q)_{n-j})

# This is a specific alternating sum of the g_m.
# The g_m themselves are infinite series counting cylindric partitions.

# Let me instead focus on a different question:
# Is h_m = (q;q)_m * g_m a Demazure character?

# h_0 = 1 = D_e ✓
# h_1 = q^3 + q^2 + 3q for d=4, c=(2,1,1). Sum = 5.
# D_{s1s2} = q^3 + q^2 + 2q + 1. Sum = 5. NOT equal to h_1.
# Diff: h_1 - D_{s1s2} = 3q - 2q - 1 = q - 1. Not good.

# What about h_1 + 1 = q^3 + q^2 + 3q + 1. Sum = 6. No match either.

# What about Q_1 + 1 = D_{s1s2}? YES! Q_1 + 1 = D_{s1s2}.
# So sum_{n=0}^1 Q_n = D_{s1s2}? Check: Q_0 + Q_1 = 1 + 2q + q^2 + q^3.
# D_{s1s2} = q^3 + q^2 + 2q + 1 = 1 + 2q + q^2 + q^3. YES!

# So: sum_{n=0}^N Q_n = D_{w_N} for some word w_N??
# For N=0: sum = Q_0 = 1 = D_e. ✓
# For N=1: sum = Q_0 + Q_1 = 1 + 2q + q^2 + q^3 = D_{s1s2}. ✓

# For N=2: sum = 1 + (2q+q^2+q^3) + Q_2
#         = 1 + 2q + q^2 + q^3 + q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
#         = 1 + 2q + q^2 + 2q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

print("\n" + "="*70)
print("Testing: sum_{n=0}^N Q_n = D_{w_N}?")
print("="*70)

# Use the exact Q values from the previous computation
Q = {
    0: R(1),
    1: 2*q + q**2 + q**3,
    2: q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12,
}
# Wait, Q_2 from the output is:
# Q_2 = q^12 + q^10 + q^9 + 2*q^8 + 2*q^7 + 3*q^6 + 2*q^5 + 3*q^4 + q^3
Q[2] = q**3 + 3*q**4 + 2*q**5 + 3*q**6 + 2*q**7 + 2*q**8 + q**9 + q**10 + q**12

partial_sums = {}
for N in range(3):
    s = R(0)
    for n in range(N+1):
        s += Q[n]
    partial_sums[N] = s
    print(f"sum_{{n=0}}^{N} Q_n = {s}  [sum={s(1)}]")

# Now find Demazure chars matching these partial sums
print("\nSearching for matching Demazure characters...")
for N in range(3):
    target = partial_sums[N]
    target_sum = target(1)
    print(f"\n  Target sum_{N}: sum={target_sum}")
    
    found = False
    for word in all_words:
        try:
            char = demazure_char(C, word, hw)
            if char(1) == target_sum:
                if char == target:
                    print(f"    EXACT MATCH: word={word}")
                    found = True
                    break
                else:
                    diff = char - target
                    # print(f"    sum matches but poly differs: word={word}, diff={diff}")
        except:
            pass
    if not found:
        print(f"    No exact match found among words up to length 6")

# Let's also try for d=2
print("\n" + "="*70)
print("d=2, c=(1,1,0): sum_{n=0}^N Q_n vs Demazure")
print("="*70)

hw2 = Lambda[0] + Lambda[1]
C2 = crystals.LSPaths(ct, hw2)

Q2 = {0: R(1), 1: q, 2: q**4, 3: q**9}

for N in range(4):
    s = sum(Q2[n] for n in range(N+1))
    print(f"  sum_{{0..{N}}} Q_n = {s}  [sum={s(1)}]")
    
    # Search
    for word in all_words:
        try:
            char = demazure_char(C2, word, hw2)
            if char == s:
                print(f"    MATCH: word={word}")
                break
        except:
            pass

# ======================================================================
# d=5, c=(2,2,1): first test of a genuinely new case
# ======================================================================
print("\n" + "="*70)
print("d=5, c=(2,2,1): base = (6*7/6-1) = 6")
print("="*70)

c5 = (2, 2, 1)
hw5 = 2*Lambda[0] + 2*Lambda[1] + Lambda[2]
C5 = crystals.LSPaths(ct, hw5)

# Compute Q_1 for d=5
from sage.combinat.partition import Partitions

def compute_Q1_exact(c, weight_max=60):
    """Compute Q_1 = h_1 - q*h_0 = h_1 - q."""
    k = len(c)
    d = sum(c)
    
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
    
    # F_{c,0} = 1, F_{c,1}
    parts1 = gen_partitions(1, weight_max)
    
    F1 = PS(0)
    for l0 in parts1:
        w0 = sum(l0)
        for l1 in parts1:
            w01 = w0 + sum(l1)
            if w01 > weight_max:
                continue
            if not check_interlace(l0, l1, c[1]):
                continue
            for l2 in parts1:
                wt = w01 + sum(l2)
                if wt > weight_max:
                    continue
                if not check_interlace(l1, l2, c[2]):
                    continue
                if not check_interlace(l2, l0, c[0]):
                    continue
                F1 += qq**wt
    
    g1 = F1 - 1
    h1_ps = (1 - qq) * g1
    
    # h_1 should be polynomial
    h1 = R(0)
    for i in range(weight_max + 1):
        c_i = h1_ps[i]
        if c_i != 0:
            h1 += int(c_i) * q**i
    
    Q1 = h1 - q
    return Q1, h1

Q1_d5, h1_d5 = compute_Q1_exact(c5, weight_max=30)
print(f"h_1 = {h1_d5}")
print(f"Q_1 = {Q1_d5}  [sum={Q1_d5(1)}]")

# Demazure chars for B(2*L0 + 2*L1 + L2)
print(f"\nDemazure chars for B(2*L0 + 2*L1 + L2):")
for name, word in [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s1s2', [1,2]), ('s2s1', [2,1]),
    ('s0s1', [0,1]), ('s0s2', [0,2]),
    ('s1s0', [1,0]), ('s2s0', [2,0]),
    ('s0s1s2', [0,1,2]), ('s0s2s1', [0,2,1]),
    ('s2s1s0', [2,1,0]),
]:
    char = demazure_char(C5, word, hw5)
    print(f"  D_{name} = {char}  [sum={char(1)}]")

# Check: Q_0 + Q_1 = 1 + Q1_d5
S1_d5 = 1 + Q1_d5
print(f"\nsum_{{0..1}} Q_n = {S1_d5}  [sum={S1_d5(1)}]")
print(f"Looking for Demazure match...")

for word in all_words:
    if len(word) > 5:
        continue
    try:
        char = demazure_char(C5, word, hw5)
        if char == S1_d5:
            print(f"  MATCH: word={word}")
            break
    except:
        pass
else:
    print("  No match found in words up to length 5")

