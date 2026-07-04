"""
Agent B: Verify the main theorem and formulate precisely.

THEOREM (conjectured, verified for d=1,2,4,7):
Let A(x) be the Corteel-Welsh shift matrix on compositions of d into 3 nonneg parts.
Then:
1. det(I - A(x)) = 1 - x^3
2. adj(I - A(x))[c,c'] = x^{EMD(c,c')}
   where EMD is the Earth Mover's Distance on Z/3Z with clockwise metric.

The EMD formula: for c=(c_0,c_1,c_2) and c'=(c_0',c_1',c_2') with sum d:
  e_i = c'_i - c_i
  t_min = max(0, e_1, -e_0) 
  EMD(c,c') = 3*t_min + e_0 - e_1

Let me verify for d=7 and also prove the formula algebraically.
"""
from sage.all import *
from itertools import combinations

def clockwise_emd(c, cp):
    e = [cp[i] - c[i] for i in range(3)]
    t_min = max(0, e[1], -e[0])
    return 3 * t_min + e[0] - e[1]

def build_CW_matrix(d):
    r = 3
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            compositions.append((c0, c1, c2))
    N = len(compositions)
    comp_idx = {c: i for i, c in enumerate(compositions)}
    
    def shift_profile(c, J):
        k = len(c)
        result = list(c)
        for i in range(k):
            prev = (i - 1) % k
            if i in J and prev not in J:
                result[i] -= 1
            elif i not in J and prev in J:
                result[i] += 1
        return tuple(result)
    
    Rx = PolynomialRing(QQ, 'x')
    x = Rx.gen()
    A = matrix(Rx, N, N, 0)
    
    for ic, c in enumerate(compositions):
        I_c = {i for i in range(r) if c[i] > 0}
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                if cJ in comp_idx:
                    jcJ = comp_idx[cJ]
                    A[ic, jcJ] += sign * x**size
    
    return A, compositions, comp_idx

# Verify for d=7
print("Verifying for d=7 (36x36 matrix)...")
A7, comps7, cidx7 = build_CW_matrix(7)
N7 = len(comps7)

Rx = PolynomialRing(QQ, 'x')
x = Rx.gen()
I7 = matrix(Rx, N7, N7, lambda i,j: 1 if i==j else 0)
B7 = I7 - A7
det7 = B7.determinant()
print(f"det(I-A(x)) = {det7}")

adj7 = B7.adjugate()

# Check every entry against EMD
match = True
mismatch_count = 0
for i in range(N7):
    for j in range(N7):
        entry = adj7[i,j]
        emd = clockwise_emd(comps7[i], comps7[j])
        expected = x**emd
        if entry != expected:
            match = False
            mismatch_count += 1
            if mismatch_count <= 3:
                print(f"  MISMATCH: adj[{comps7[i]},{comps7[j]}] = {entry}, expected x^{emd}")

if match:
    print(f"  VERIFIED: adj(I-A(x))[c,c'] = x^{{EMD(c,c')}} for ALL {N7**2} entries!")
else:
    print(f"  {mismatch_count} mismatches out of {N7**2}")

# Also verify for d=5
print("\nVerifying for d=5 (21x21 matrix)...")
A5, comps5, cidx5 = build_CW_matrix(5)
N5 = len(comps5)
I5 = matrix(Rx, N5, N5, lambda i,j: 1 if i==j else 0)
B5 = I5 - A5
det5 = B5.determinant()
adj5 = B5.adjugate()

match5 = True
for i in range(N5):
    for j in range(N5):
        entry = adj5[i,j]
        emd = clockwise_emd(comps5[i], comps5[j])
        if entry != x**emd:
            match5 = False
            break
    if not match5:
        break

print(f"d=5: {'VERIFIED' if match5 else 'FAILED'}")
print(f"det = {det5}")

# Verify d=3 (mod 3 = 0 case)
print("\nVerifying for d=3 (10x10 matrix, d equiv 0 mod 3)...")
A3, comps3, cidx3 = build_CW_matrix(3)
N3 = len(comps3)
I3 = matrix(Rx, N3, N3, lambda i,j: 1 if i==j else 0)
B3 = I3 - A3
det3 = B3.determinant()
adj3 = B3.adjugate()

match3 = True
for i in range(N3):
    for j in range(N3):
        entry = adj3[i,j]
        emd = clockwise_emd(comps3[i], comps3[j])
        if entry != x**emd:
            match3 = False
            if not match3:
                print(f"  adj[{comps3[i]},{comps3[j]}] = {entry}, expected x^{emd}")
                break
    if not match3:
        break

print(f"d=3: {'VERIFIED' if match3 else 'FAILED'}")
print(f"det = {det3}")

# And d=8
print("\nVerifying for d=8 (45x45 matrix)...")
A8, comps8, cidx8 = build_CW_matrix(8)
N8 = len(comps8)
I8 = matrix(Rx, N8, N8, lambda i,j: 1 if i==j else 0)
B8 = I8 - A8
det8 = B8.determinant()
print(f"det = {det8}")

adj8 = B8.adjugate()
match8 = True
for i in range(N8):
    for j in range(N8):
        entry = adj8[i,j]
        emd = clockwise_emd(comps8[i], comps8[j])
        if entry != x**emd:
            match8 = False
            break
    if not match8:
        break
print(f"d=8: {'VERIFIED' if match8 else 'FAILED'}")

print("\n" + "=" * 60)
print("THEOREM STATEMENT")
print("=" * 60)
print("""
THEOREM: Let A(x) be the CW shift matrix on compositions of d into 3 nonneg 
parts (for any d >= 1). Then:

(1) det(I - A(x)) = 1 - x^3

(2) adj(I - A(x))[c, c'] = x^{EMD(c, c')}

where EMD(c, c') is the Earth Mover's Distance on Z/3Z with clockwise metric:

    EMD(c, c') = 3 * max(0, c'_1 - c_1, c_0 - c'_0) + (c'_0 - c_0) - (c'_1 - c_1)

Equivalently, EMD is the minimum total clockwise transport cost to transform
the distribution c = (c_0, c_1, c_2) into c' = (c'_0, c'_1, c'_2) on Z/3Z.

COROLLARY: 
(I - A(x))^{-1}[c, c'] = x^{EMD(c,c')} / (1 - x^3)

And the matrix product formula for the bounded cylindric partition GF becomes:

(q^3; q^3)_n * F_{c,n}(q) = sum_{c_1,...,c_{n-1}} prod_{k=1}^n q^{k * EMD(c_k, c_{k-1})}

where c_n = c (target profile) and c_0,...,c_{n-1} range over all compositions of d.

This is a MANIFESTLY POSITIVE formula for P_n(c) = (q^3;q^3)_n * F_{c,n}(q).
""")

