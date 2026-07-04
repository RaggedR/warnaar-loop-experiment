"""
Seed 7 Layer 3: Search for longer words for asymmetric profiles.

The match only works for "balanced" profiles: c_1 = c_2.
For asymmetric profiles, try longer words.

Also: check if the GRADING needs to be different for different profiles.
"""
from sage.all import *

R = PolynomialRing(ZZ, 'q')
q = R.gen()

PS = PowerSeriesRing(QQ, 'qq', default_prec=80)
qq = PS.gen()

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()

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

from sage.combinat.partition import Partitions

def compute_Q1(c, weight_max=50):
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
    
    parts = gen_partitions(1, weight_max)
    F1 = PS(0)
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
                F1 += qq**wt
    
    g1 = F1 - 1
    h1_ps = (1 - qq) * g1
    h1 = R(0)
    for i in range(weight_max + 1):
        c_i = h1_ps[i]
        if c_i != 0:
            h1 += int(c_i) * q**i
    return h1 - q

# ======================================================================
# Test d=4, c=(3,1,0): asymmetric profile that failed
# ======================================================================
print("="*70)
print("d=4, c=(3,1,0): asymmetric profile")
print("="*70)

c = (3, 1, 0)
Q1 = compute_Q1(c, weight_max=30)
target = 1 + Q1
hw = 3*Lambda[0] + Lambda[1]

print(f"Q_1 = {Q1}")
print(f"target = {target}  [sum={target(1)}]")

C = crystals.LSPaths(ct, hw)

# Search up to length 8
from itertools import product as iprod
found = []
for length in range(1, 9):
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        char = demazure_char(C, word, hw)
        if char(1) == target(1) and char == target:
            found.append(word)
            print(f"  MATCH at length {length}: word={word}")
            break
    if found:
        break
    print(f"  No match at length {length}")

# Also print some Demazure chars to see what's available
print("\nSample Demazure chars with sum close to target:")
for length in range(1, 5):
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        char = demazure_char(C, word, hw)
        if abs(char(1) - target(1)) <= 2:
            print(f"  word={word}: char={char} [sum={char(1)}]")


# ======================================================================
# Now try: maybe the profile-dependence means the WEIGHT needs adjustment.
# For profile c = (c_0, c_1, c_2), the crystal is B(c_0*L_0 + c_1*L_1 + c_2*L_2).
# But the Demazure word might depend on the profile too.
# 
# Alternative hypothesis: the match works for ALL profiles, but the 
# grading is DIFFERENT for each profile.
# ======================================================================

print("\n" + "="*70)
print("Testing: profile-dependent grading")
print("="*70)

# For c = (c_0, c_1, c_2), maybe the grading should be:
# deg(alpha_i) = c_i (or c_{i+1}, or some function of c)

def demazure_char_custom(crystal, word, hw_wt, weights):
    """Demazure char with custom grading: deg(alpha_i) = weights[i]."""
    D = demazure_set(crystal, word)
    
    char = R(0)
    for b in D:
        diff = hw_wt - b.weight()
        coeffs = diff.monomial_coefficients()
        d0 = coeffs.get(0, 0)
        d1 = coeffs.get(1, 0)
        d2 = coeffs.get(2, 0)
        d_delta = coeffs.get('delta', 0)
        n0 = d_delta
        n1_num = d1 - d0 + 3*d_delta
        n2_num = d2 - d0 + 3*d_delta
        if n1_num % 3 != 0 or n2_num % 3 != 0:
            return None
        n1 = n1_num // 3
        n2 = n2_num // 3
        grade = weights[0]*n0 + weights[1]*n1 + weights[2]*n2
        if grade < 0:
            return None
        char += q**grade
    return char


# For d=4, c=(3,1,0): try various weight triples
c_test = (3, 1, 0)
hw_test = 3*Lambda[0] + Lambda[1]
C_test = crystals.LSPaths(ct, hw_test)
Q1_test = compute_Q1(c_test, weight_max=20)
target_test = 1 + Q1_test
print(f"\nc={c_test}, target = {target_test}")

for w0 in range(1, 8):
    for w1 in range(1, 8):
        for w2 in range(1, 8):
            weights = (w0, w1, w2)
            # Try word [1,2]
            char = demazure_char_custom(C_test, [1,2], hw_test, weights)
            if char is not None and char == target_test:
                print(f"  MATCH with weights={weights}, word=[1,2]!")
            # Try word [0,1]
            char = demazure_char_custom(C_test, [0,1], hw_test, weights)
            if char is not None and char == target_test:
                print(f"  MATCH with weights={weights}, word=[0,1]!")
            # Try word [2,0]
            char = demazure_char_custom(C_test, [2,0], hw_test, weights)
            if char is not None and char == target_test:
                print(f"  MATCH with weights={weights}, word=[2,0]!")


# ======================================================================
# Also: check if Q_1 itself is a Demazure character (not partial sum)
# ======================================================================
print("\n" + "="*70)
print("Check: is Q_1 a Demazure DIFFERENCE for asymmetric profiles?")
print("="*70)

# For c=(3,1,0), d=4:
# Q_1 has sum 4.
# Check if Q_1 = D_w - D_{w'} for some pair.

c_asym = (3, 1, 0)
hw_asym = 3*Lambda[0] + Lambda[1]
C_asym = crystals.LSPaths(ct, hw_asym)
Q1_asym = compute_Q1(c_asym, weight_max=20)
print(f"c={c_asym}: Q_1 = {Q1_asym}")

# Collect all Demazure chars up to length 3
all_chars = {}
for length in range(4):
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        char = demazure_char(C_asym, word, hw_asym)
        key = str(char)
        if key not in all_chars:
            all_chars[key] = (word, char)

print(f"Collected {len(all_chars)} distinct Demazure chars")

# Check all pairs (D_w - D_{w'})
for k1, (w1, c1) in all_chars.items():
    for k2, (w2, c2) in all_chars.items():
        diff = c1 - c2
        if diff == Q1_asym:
            print(f"  Q_1 = D_{w1} - D_{w2}")
            print(f"    D_{w1} = {c1}")
            print(f"    D_{w2} = {c2}")

# Check all pairs for Q_1 + 1 (= target)
target_asym = 1 + Q1_asym
for k1, (w1, c1) in all_chars.items():
    if c1 == target_asym:
        print(f"  target = D_{w1}")

