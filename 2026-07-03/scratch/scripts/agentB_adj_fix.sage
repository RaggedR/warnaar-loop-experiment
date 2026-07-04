"""
Agent B: Fix the degree extraction. The issue is likely that list(entry) doesn't 
include leading zeros properly. Use valuation() instead.
"""
from sage.all import *
from itertools import combinations

d = 4
r = 3
PREC = 30

R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

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
x_var = Rx.gen()
A_poly = matrix(Rx, N, N, 0)

for ic, c in enumerate(compositions):
    I_c = {i for i in range(r) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = comp_idx[cJ]
            A_poly[ic, jcJ] += sign * x_var**size

def eval_A(val):
    A_eval = matrix(R, N, N)
    for i in range(N):
        for j in range(N):
            poly = A_poly[i,j]
            v = R(0)
            for k, coeff in enumerate(poly.list()):
                v += coeff * val**k
            A_eval[i,j] = v
    return A_eval

I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))

# k=1
A1 = eval_A(q)
B1 = I_mat - A1
det1 = 1 - q**3
B1_inv = B1.inverse()
adj1 = det1 * B1_inv

# Print actual entries using valuation
print("adj(I-A(q)) entries using valuation():")
idx = comp_idx[(2,1,1)]
for j in range(N):
    entry = adj1[idx, j]
    val = entry.valuation()
    # Check if it's a monomial
    shifted = entry * q**(-val) if val > 0 else entry
    print(f"  adj[c=(2,1,1), c'={compositions[j]}] = {entry.add_bigoh(val+3)}, valuation={val}")

# Degree matrix using valuation
print("\nValuation matrix of adj(I-A(q)):")
for i in range(N):
    row = []
    for j in range(N):
        entry = adj1[i,j]
        row.append(entry.valuation())
    print(f"  {compositions[i]}: {row}")

# Now k=2
A2 = eval_A(q**2)
B2 = I_mat - A2
det2 = 1 - q**6
B2_inv = B2.inverse()
adj2 = det2 * B2_inv

print("\nValuation matrix of adj(I-A(q^2)):")
for i in range(N):
    row = []
    for j in range(N):
        entry = adj2[i,j]
        row.append(entry.valuation())
    print(f"  {compositions[i]}: {row}")

# Check if deg(adj2) = 2 * deg(adj1)
print("\nChecking deg(adj2) = 2 * deg(adj1):")
match = True
for i in range(N):
    for j in range(N):
        v1 = adj1[i,j].valuation()
        v2 = adj2[i,j].valuation()
        if v2 != 2*v1:
            match = False
            print(f"  MISMATCH at [{compositions[i]}, {compositions[j]}]: v1={v1}, v2={v2}")

if match:
    print("  YES! All valuations scale by factor 2!")

# THE DEGREE MATRIX IS A KEY OBJECT. Let me understand its structure.
# It should be related to a DISTANCE function on compositions.
print("\n\nValuation matrix D where adj(I-A(q))[c,c'] = q^{D[c,c']}:")
D = matrix(ZZ, N, N)
for i in range(N):
    for j in range(N):
        D[i,j] = adj1[i,j].valuation()

# Is D a metric? Check triangle inequality
print("D matrix:")
print(D)

# Check: D[c,c'] = some combinatorial distance between compositions c and c'?
# For c=(2,1,1), c'=(2,1,1): D=0 (identity)
# For c=(2,1,1), c'=(1,2,1): D=1 
# For c=(2,1,1), c'=(1,1,2): D=2
# For c=(2,1,1), c'=(0,0,4): D=5

# This looks like the L1 distance divided by something, or a cyclic distance.
# Let me check: is D[c,c'] = sum |c_i - c'_i| / 2?
print("\nChecking if D[c,c'] = sum|c_i - c'_i|/2:")
for i in range(N):
    for j in range(N):
        c = compositions[i]
        cp = compositions[j]
        l1 = sum(abs(c[k] - cp[k]) for k in range(3))
        if D[i,j] != l1 // 2:
            print(f"  D[{c},{cp}] = {D[i,j]}, L1/2 = {l1//2}, L1 = {l1}")
            break
    else:
        continue
    break
else:
    print("  YES! D[c,c'] = L1(c,c')/2 for all pairs!")

# More interesting: compute the product of TWO adjugate matrices
# adj(I-A(q)) * adj(I-A(q^2))
# Since each adj is a monomial matrix (with coefficient 1), the product
# is also a monomial matrix: entry [i,j] = sum_k q^{D[i,k]} * q^{2*D[k,j]}
# = sum_k q^{D[i,k] + 2*D[k,j]}
# This is a SUM of monomials, not a single monomial!

prod12 = adj1 * adj2
print("\n\nProduct adj1 * adj2:")
idx = comp_idx[(2,1,1)]
entry = prod12[idx, idx]
print(f"  [(2,1,1),(2,1,1)] = {entry.add_bigoh(20)}")

entry2 = prod12[idx, comp_idx[(1,2,1)]]
print(f"  [(2,1,1),(1,2,1)] = {entry2.add_bigoh(20)}")

# Check positivity
print("\nProduct adj1 * adj2: all nonneg entries?")
all_nonneg = True
for i in range(N):
    for j in range(N):
        entry = prod12[i,j]
        coeffs = list(entry)[:PREC]
        for deg, c in enumerate(coeffs):
            if c < 0:
                all_nonneg = False
                print(f"  NEGATIVE: [{compositions[i]}, {compositions[j]}] at degree {deg}")
                break
if all_nonneg:
    print("  YES! All entries of adj1 * adj2 are nonneg.")

# P_2 = adj1 * adj2 * v0 for v0 = (1,...,1)
v0 = vector(R, [R(1)] * N)
P2_vec = prod12 * v0
idx_211 = comp_idx[(2,1,1)]
P2 = P2_vec[idx_211]
print(f"\nP_2((2,1,1)) = (q^3;q^3)_2 * F_{{(2,1,1),2}} = {P2.add_bigoh(25)}")

# Check: P_2 should equal (q^3;q^3)_2 * F_{c,2}
# = (1-q^3)(1-q^6) * F_{c,2}
# We already know F_{c,2} from the inverse computation.
# P_2(1) should be binom(d+2,2)^2 = 15^2 = 225 (Kursungoz)

P2_coeffs = list(P2)[:30]
print(f"P_2(1) = {sum(P2_coeffs)} (should be 225)")
print(f"All nonneg: {all(c >= 0 for c in P2_coeffs)}")

