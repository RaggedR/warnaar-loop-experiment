"""
Seed 7 Layer 3: Complete the d=7 verification and find the word pattern.

ESTABLISHED PATTERN:
  sum_{n=0}^1 Q_n = D_{w_1}(B(Lambda), principal grading) for:
  - d=2, c=(1,1,0), hw=L0+L1: w_1 in {s0, s1}
  - d=4, c=(2,1,1), hw=2L0+L1+L2: w_1 in {s1s2, s2s1}
  - d=5, c=(2,2,1), hw=2L0+2L1+L2: w_1 in {s0s2, s1s2}
  - d=7, c=(3,2,2), hw=3L0+2L1+2L2: w_1 in {s1s2, s2s1}

The word w_1 = s_1 s_2 (or equivalent) appears consistently.
This is the LONGEST ELEMENT of the FINITE Weyl group A_2!
w_0^{fin} = s_1 s_2 s_1 = s_2 s_1 s_2 (length 3 for A_2).
But our words have length 2: s_1 s_2 or s_2 s_1.

Actually for A_2, s_1 s_2 has length 2 (NOT the longest element).
The longest element is s_1 s_2 s_1 (length 3).

Let me check: what is s_1 s_2 in the affine Weyl group?
It's just the product of two finite reflections.
In the finite Weyl group S_3 of A_2: s_1 s_2 is a 3-cycle.
So D_{s_1 s_2} is the Demazure module for a 3-cycle.

Now verify for d=7, c=(4,2,1) and find the right word.
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
    Q1 = h1 - q
    return Q1


# ======================================================================
# d=7, c=(4,2,1): Find matching Demazure word
# ======================================================================
print("="*70)
print("d=7, c=(4,2,1), hw = 4*L0 + 2*L1 + L2")
print("="*70)

Q1_721 = compute_Q1((4,2,1), weight_max=50)
target_721 = 1 + Q1_721
print(f"Q_1 = {Q1_721}")
print(f"target sum_{{0..1}} = {target_721}  [sum={target_721(1)}]")

hw721 = 4*Lambda[0] + 2*Lambda[1] + Lambda[2]
C721 = crystals.LSPaths(ct, hw721)

from itertools import product as iprod
found = []
for length in range(1, 5):
    for w in iprod([0,1,2], repeat=length):
        word = list(w)
        char = demazure_char(C721, word, hw721)
        if char == target_721:
            found.append(word)
    if found:
        break

print(f"Matching words: {found}")

# ======================================================================
# Verify for ALL d=7 profiles
# ======================================================================
print("\n" + "="*70)
print("d=7: All non-trivially different profiles")
print("="*70)

# Profiles with d=7: compositions of 7 into 3 nonneg parts
# By D_3 symmetry, we only need representative profiles.
# Representatives: (7,0,0), (6,1,0), (5,2,0), (5,1,1), (4,3,0),
#                  (4,2,1), (3,3,1), (3,2,2)

profiles_d7 = [
    (7,0,0), (6,1,0), (5,2,0), (5,1,1), (4,3,0),
    (4,2,1), (3,3,1), (3,2,2)
]

for c in profiles_d7:
    d = sum(c)
    hw = c[0]*Lambda[0] + c[1]*Lambda[1] + c[2]*Lambda[2]
    
    Q1 = compute_Q1(c, weight_max=30)
    target = 1 + Q1
    
    Cryst = crystals.LSPaths(ct, hw)
    
    found_w = []
    for length in range(1, 5):
        for w in iprod([0,1,2], repeat=length):
            word = list(w)
            try:
                char = demazure_char(Cryst, word, hw)
                if char == target:
                    found_w.append(word)
                    if len(found_w) >= 3:
                        break
            except:
                pass
        if found_w:
            break
    
    nonneg = all(Q1[i] >= 0 for i in range(Q1.degree() + 1))
    print(f"  c={c}: Q_1={Q1} [sum={Q1(1)}, nonneg={nonneg}]")
    print(f"    Demazure match: {found_w[:3]}")


# ======================================================================
# Pattern analysis
# ======================================================================
print("\n" + "="*70)
print("PATTERN: Which word gives sum_{0..1} Q_n?")
print("="*70)

# For symmetric profiles (c_1 = c_2): the word [1,2] or [2,1] works.
# For asymmetric profiles: does the word depend on the profile?

# Let me check more d values.
for d_val in [2, 4, 5, 7, 8]:
    print(f"\nd={d_val}:")
    # Just a couple of profiles per d
    for c_choice in [(d_val,0,0), (d_val-1,1,0), (d_val-2,1,1)]:
        if any(ci < 0 for ci in c_choice):
            continue
        hw_c = sum(ci*Lambda[i] for i, ci in enumerate(c_choice))
        
        Q1_c = compute_Q1(c_choice, weight_max=20)
        target_c = 1 + Q1_c
        C_c = crystals.LSPaths(ct, hw_c)
        
        found_w = []
        for length in range(1, 5):
            for w in iprod([0,1,2], repeat=length):
                word = list(w)
                try:
                    char = demazure_char(C_c, word, hw_c)
                    if char == target_c:
                        found_w.append(word)
                        if len(found_w) >= 2:
                            break
                except:
                    pass
            if found_w:
                break
        
        print(f"  c={c_choice}: Q_1(1)={Q1_c(1)}, match={found_w[:2]}")

