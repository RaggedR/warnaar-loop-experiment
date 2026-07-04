"""
Agent B: Check adjugate nonnegativity for all k, and compute Q_n from the 
matrix product formula.

KEY FINDING FROM PREVIOUS SCRIPT: adj(I - A(q)) has ALL NONNEG entries for d=4!

Now check:
1. adj(I - A(q^k)) nonneg for k=1,2,...?
2. Product of adjugate matrices nonneg?
3. Compute Q_n from the matrix product.
"""
from sage.all import *

d = 4
r = 3
PREC = 80

R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

# Build compositions and CW shift matrix
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

from itertools import combinations

# Build A(x) as polynomial matrix
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
    """Evaluate A(x) at x=val (a power series element)."""
    A_eval = matrix(R, N, N)
    for i in range(N):
        for j in range(N):
            poly = A_poly[i,j]
            v = R(0)
            for k, coeff in enumerate(poly.list()):
                v += coeff * val**k
            A_eval[i,j] = v
    return A_eval

def compute_adjugate(val):
    """Compute adj(I - A(val))."""
    A_eval = eval_A(val)
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    B = I_mat - A_eval
    B_inv = B.inverse()
    # det(I - A(q^k)) = 1 - q^{3k}
    return B_inv  # We'll multiply by det separately

# Check adjugate nonnegativity for k=1,2,3
print("=" * 60)
print("Checking adjugate nonnegativity for k=1,2,3")
print("=" * 60)

for k in range(1, 4):
    qk = q**k
    det_val = 1 - q**(3*k)
    
    A_eval = eval_A(qk)
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    B = I_mat - A_eval
    B_inv = B.inverse()
    adj = det_val * B_inv
    
    all_nonneg = True
    min_neg = None
    for i in range(N):
        for j in range(N):
            entry = adj[i,j]
            coeffs = list(entry)[:PREC]
            for deg, c in enumerate(coeffs):
                if c < 0:
                    all_nonneg = False
                    if min_neg is None or deg < min_neg[0]:
                        min_neg = (deg, c, compositions[i], compositions[j])
    
    if all_nonneg:
        print(f"  k={k}: ALL ENTRIES NONNEG (through precision {PREC})")
    else:
        print(f"  k={k}: NEGATIVE at degree {min_neg[0]}, coeff={min_neg[1]}, entry [{min_neg[2]}, {min_neg[3]}]")

# Now compute the product of adjugate matrices and extract Q_n
print("\n" + "=" * 60)
print("Computing Q_n from matrix product formula")
print("=" * 60)

# v_n = prod_{k=1}^n (I - A(q^k))^{-1} * v_0
# P_n := (q^3;q^3)_n * v_n = prod_{k=1}^n adj(I - A(q^k)) * v_0
# Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m z^m F_{c,m})

# First compute F_{c,m} for m = 0, 1, 2 using the matrix product.
v0 = vector(R, [R(1)] * N)
idx_211 = comp_idx[(2,1,1)]

# v_1 = (I - A(q))^{-1} v_0
A1 = eval_A(q)
I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
v1 = (I_mat - A1).inverse() * v0

# v_2 = (I - A(q^2))^{-1} v_1
A2 = eval_A(q**2)
v2 = (I_mat - A2).inverse() * v1

# v_3 = (I - A(q^3))^{-1} v_2
A3 = eval_A(q**3)
v3 = (I_mat - A3).inverse() * v2

# F_{c,m} for c = (2,1,1)
Fc0 = R(1)  # = v0[idx_211]
Fc1 = v1[idx_211]
Fc2 = v2[idx_211]
Fc3 = v3[idx_211]

# g_m = F_{c,m} - F_{c,m-1}
g0 = R(1)
g1 = Fc1 - Fc0
g2 = Fc2 - Fc1
g3 = Fc3 - Fc2

print(f"\ng_0 = {g0}")
print(f"g_1 = {g1.add_bigoh(20)}")
print(f"g_2 = {g2.add_bigoh(20)}")
print(f"g_3 = {g3.add_bigoh(20)}")

# Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{T_{n-j}} / (q;q)_{n-j} * g_j
# where T_k = k(k+1)/2

def qpoch(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

# Q_1 = (1-q) * [g_1 - q*g_0/(1-q)]
# = (1-q)*g_1 - q
Q1 = qpoch(1) * g1 - q
print(f"\nQ_1((2,1,1)) = {Q1.add_bigoh(20)}")
Q1_coeffs = list(Q1)[:20]
print(f"Q_1 coefficients: {Q1_coeffs}")
print(f"Q_1(1) = {sum(Q1_coeffs)}")
print(f"All nonneg: {all(c >= 0 for c in Q1_coeffs)}")

# Q_2 = (1-q)(1-q^2) * [g_2 - q*g_1/(1-q) + q^3*g_0/((1-q)(1-q^2))]
Q2 = qpoch(2) * (g2 - q * g1 / qpoch(1) + q**3 * g0 / qpoch(2))
print(f"\nQ_2((2,1,1)) = {Q2.add_bigoh(30)}")
Q2_coeffs = list(Q2)[:30]
print(f"Q_2 coefficients: {[c for c in Q2_coeffs if c != 0]}")
print(f"Q_2(1) = {sum(Q2_coeffs)} (should be 16)")
print(f"All nonneg: {all(c >= 0 for c in Q2_coeffs)}")

# Q_3
Q3 = qpoch(3) * (g3 - q*g2/qpoch(1) + q**3*g1/qpoch(2) - q**6*g0/qpoch(3))
print(f"\nQ_3((2,1,1)) = {Q3.add_bigoh(40)}")
Q3_coeffs = list(Q3)[:40]
print(f"Q_3(1) = {sum(Q3_coeffs)} (should be 64)")
print(f"All nonneg: {all(c >= 0 for c in Q3_coeffs)}")
print(f"Q_3 first nonzero coefficients: {[(i, c) for i, c in enumerate(Q3_coeffs) if c != 0][:15]}")

# Now let's look at the STRUCTURE of the adjugate more carefully.
# For k=1: adj(I - A(q)) has entries that are MONOMIALS?
print("\n" + "=" * 60)
print("Detailed adjugate structure for k=1")
print("=" * 60)

det1 = 1 - q**3
A1_eval = eval_A(q)
B1 = I_mat - A1_eval
B1_inv = B1.inverse()
adj1 = det1 * B1_inv

# Are the entries monomials?
for i in range(N):
    for j in range(N):
        entry = adj1[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) > 1:
            print(f"  adj1[{compositions[i]}, {compositions[j]}] has {len(nonzero)} nonzero terms: {nonzero[:5]}")
            break
    else:
        continue
    break
else:
    print("  ALL entries of adj(I-A(q)) are MONOMIALS!")

# Print the full adjugate as monomials
print("\nadj(I-A(q)) as matrix of monomials:")
adj1_degrees = matrix(ZZ, N, N)
for i in range(N):
    for j in range(N):
        entry = adj1[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) == 0:
            adj1_degrees[i,j] = -1  # zero entry
        elif len(nonzero) == 1:
            adj1_degrees[i,j] = nonzero[0][0]
        else:
            adj1_degrees[i,j] = -2  # not monomial

print("Degree matrix (row=target profile, col=source profile):")
print(adj1_degrees)

# Now check adj(I - A(q^2))
det2 = 1 - q**6
A2_eval = eval_A(q**2)
B2 = I_mat - A2_eval
B2_inv = B2.inverse()
adj2 = det2 * B2_inv

# Are entries still monomials?
is_monomial = True
for i in range(N):
    for j in range(N):
        entry = adj2[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) > 1:
            is_monomial = False
            print(f"\nadj2[{compositions[i]}, {compositions[j]}] has {len(nonzero)} nonzero terms")
            print(f"  First few: {nonzero[:8]}")
            break
    if not is_monomial:
        break

if is_monomial:
    print("\nadj(I-A(q^2)) entries are also monomials!")
else:
    print("\nadj(I-A(q^2)) entries are NOT all monomials.")

# Check a specific entry
entry_22 = adj2[idx_211, idx_211]
print(f"\nadj2[(2,1,1),(2,1,1)] = {entry_22.add_bigoh(30)}")

