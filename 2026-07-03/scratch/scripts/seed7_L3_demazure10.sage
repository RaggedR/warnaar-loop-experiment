"""
Seed 7 Layer 3: Final analysis.

Key findings so far:
1. Q_1 = D_{s1s2} - 1 for d=4 (EXACT)
2. sum_{0..1} Q_n = D_{s1s2} for d=4 (EXACT)
3. For d=5: sum_{0..1} Q_n = D_{s0s2} = D_{s1s2} for d=5 (EXACT)
4. For d=2: sum_{0..1} Q_n = D_{s0} for d=2 (EXACT)

The N=2 pattern breaks. Let me check:
- Whether Q_n itself (not partial sum) is a Demazure DIFFERENCE
- The d=7 case (first unproved) for n=1
"""
from sage.all import *

R = PolynomialRing(ZZ, 'q')
q = R.gen()

PS = PowerSeriesRing(QQ, 'qq', default_prec=80)
qq = PS.gen()

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()

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
# d=7, c=(3,2,2): The FIRST UNPROVED case
# ======================================================================
print("="*70)
print("d=7, c=(3,2,2): base = (8*9/6-1) = 11")
print("="*70)

# Compute Q_1 for d=7
from sage.combinat.partition import Partitions

def compute_Q1(c, weight_max=60):
    k = len(c)
    
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
    
    Q1 = h1 - q  # Q_1 = h_1 - q*h_0 = h_1 - q
    return Q1, h1

# d=7, c=(3,2,2)
c722 = (3, 2, 2)
print(f"\nComputing Q_1 for c={c722}...")
Q1_722, h1_722 = compute_Q1(c722, weight_max=50)
print(f"h_1 = {h1_722}")
print(f"Q_1 = {Q1_722}  [sum={Q1_722(1)}]")

# d=7, c=(4,2,1)
c721 = (4, 2, 1)
print(f"\nComputing Q_1 for c={c721}...")
Q1_721, h1_721 = compute_Q1(c721, weight_max=50)
print(f"h_1 = {h1_721}")
print(f"Q_1 = {Q1_721}  [sum={Q1_721(1)}]")

# Demazure chars for B(3*L0 + 2*L1 + 2*L2)
print(f"\nDemazure chars for B(3*L0 + 2*L1 + 2*L2):")
hw722 = 3*Lambda[0] + 2*Lambda[1] + 2*Lambda[2]
C722 = crystals.LSPaths(ct, hw722)

target_722 = 1 + Q1_722  # sum_{0..1} Q_n

for name, word in [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s1s2', [1,2]), ('s2s1', [2,1]),
    ('s0s1', [0,1]), ('s0s2', [0,2]),
    ('s1s0', [1,0]), ('s2s0', [2,0]),
]:
    char = demazure_char(C722, word, hw722)
    marker = ""
    if char == target_722:
        marker = " <== MATCH for sum_{0..1} Q_n!"
    elif char(1) == target_722(1):
        marker = " <-- same sum"
    print(f"  D_{name} = {char}  [sum={char(1)}]{marker}")

# Demazure chars for B(4*L0 + 2*L1 + L2)  
print(f"\nDemazure chars for B(4*L0 + 2*L1 + L2):")
hw721 = 4*Lambda[0] + 2*Lambda[1] + Lambda[2]
C721 = crystals.LSPaths(ct, hw721)

target_721 = 1 + Q1_721

for name, word in [
    ('e', []),
    ('s0', [0]), ('s1', [1]), ('s2', [2]),
    ('s1s2', [1,2]), ('s2s1', [2,1]),
    ('s0s1', [0,1]), ('s0s2', [0,2]),
    ('s1s0', [1,0]), ('s2s0', [2,0]),
]:
    char = demazure_char(C721, word, hw721)
    marker = ""
    if char == target_721:
        marker = " <== MATCH for sum_{0..1} Q_n!"
    elif char(1) == target_721(1):
        marker = " <-- same sum"
    print(f"  D_{name} = {char}  [sum={char(1)}]{marker}")

# ======================================================================
# Summary: which words give the match at N=1 for each (d, c)?
# ======================================================================
print("\n" + "="*70)
print("SUMMARY: Demazure word for sum_{0..1} Q_n")
print("="*70)

cases = [
    (2, (1,1,0), Lambda[0]+Lambda[1]),
    (4, (2,1,1), 2*Lambda[0]+Lambda[1]+Lambda[2]),
    (5, (2,2,1), 2*Lambda[0]+2*Lambda[1]+Lambda[2]),
]

for d_val, c_val, hw_val in cases:
    Q1_test, _ = compute_Q1(c_val, weight_max=30)
    target = 1 + Q1_test
    C_test = crystals.LSPaths(ct, hw_val)
    
    found_words = []
    from itertools import product as iprod
    for length in range(1, 5):
        for w in iprod([0,1,2], repeat=length):
            word = list(w)
            try:
                char = demazure_char(C_test, word, hw_val)
                if char == target:
                    found_words.append(word)
            except:
                pass
    
    print(f"\nd={d_val}, c={c_val}:")
    print(f"  Q_1 = {Q1_test}")
    print(f"  target = {target}")
    print(f"  Matching words: {found_words[:5]}")

