"""
Agent B: Detailed adjugate structure investigation.
The degree matrix was all zeros, which looks wrong. Let me check the actual values.
"""
from sage.all import *

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

from itertools import combinations

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

# adj(I - A(q)) for k=1
I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
A1 = eval_A(q)
B1 = I_mat - A1
det1 = 1 - q**3
B1_inv = B1.inverse()
adj1 = det1 * B1_inv

# Print the ACTUAL adjugate entries, not just degrees
print("adj(I-A(q)) entries (profile c=(2,1,1) row):")
idx = comp_idx[(2,1,1)]
for j in range(N):
    entry = adj1[idx, j]
    # Get the actual polynomial
    coeffs = list(entry)[:10]
    nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
    print(f"  adj[({compositions[idx]}), ({compositions[j]})] = {entry.add_bigoh(10)} | nonzero at degrees: {[k for k,c in nonzero]}")

# Check: is adj really just permutation-like?
print("\n\nFull adjugate matrix (rounded to first nonzero term):")
for i in range(N):
    row = []
    for j in range(N):
        entry = adj1[i,j]
        coeffs = list(entry)[:10]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if nonzero:
            row.append(f"q^{nonzero[0][0]}")
        else:
            row.append("0")
    print(f"  {compositions[i]}: {' '.join(row)}")

# Check if adj is a PERMUTATION MATRIX times q^{something}
print("\n\nIs adj(I-A(q)) a monomial matrix (one nonzero per row/col)?")
for i in range(N):
    nonzero_cols = []
    for j in range(N):
        entry = adj1[i,j]
        if entry != 0:
            nonzero_cols.append(j)
    if len(nonzero_cols) != N:  # should be N nonzero entries per row based on what we saw
        print(f"  Row {i} ({compositions[i]}): {len(nonzero_cols)} nonzero entries")

# Actually let me check: maybe EVERY entry is a monomial (single term)
# and the coefficient is always 1?
print("\n\nChecking if all adjugate entries have coefficient 1:")
all_coeff_one = True
for i in range(N):
    for j in range(N):
        entry = adj1[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) == 1 and nonzero[0][1] != 1:
            all_coeff_one = False
            print(f"  adj[{compositions[i]}, {compositions[j]}] = {nonzero[0][1]} * q^{nonzero[0][0]}")
        elif len(nonzero) > 1:
            all_coeff_one = False
            print(f"  adj[{compositions[i]}, {compositions[j]}] has {len(nonzero)} terms")

if all_coeff_one:
    print("  YES! Every entry is either 0 or q^k for some k >= 0.")

# Print the degree matrix properly
print("\n\nDegree matrix of adj(I-A(q)):")
for i in range(N):
    row = []
    for j in range(N):
        entry = adj1[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if nonzero:
            row.append(nonzero[0][0])
        else:
            row.append(-1)
    print(f"  {compositions[i]}: {row}")

# Now check the SAME for adj(I-A(q^2))
print("\n\n" + "=" * 60)
print("adj(I-A(q^2)) structure")
print("=" * 60)

A2 = eval_A(q**2)
B2 = I_mat - A2
det2 = 1 - q**6
B2_inv = B2.inverse()
adj2 = det2 * B2_inv

# Check if all entries are monomials
all_mono = True
for i in range(N):
    for j in range(N):
        entry = adj2[i,j]
        coeffs = list(entry)[:PREC]
        nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
        if len(nonzero) > 1:
            all_mono = False
            print(f"  adj2[{compositions[i]}, {compositions[j]}] has {len(nonzero)} terms: {nonzero[:5]}")
            break
    if not all_mono:
        break

if all_mono:
    print("All entries are monomials!")
    # Print degree matrix
    print("\nDegree matrix of adj(I-A(q^2)):")
    for i in range(N):
        row = []
        for j in range(N):
            entry = adj2[i,j]
            coeffs = list(entry)[:PREC]
            nonzero = [(k, c) for k, c in enumerate(coeffs) if c != 0]
            if nonzero:
                row.append(nonzero[0][0])
            else:
                row.append(-1)
        print(f"  {compositions[i]}: {row}")

# KEY INSIGHT: if adj(I-A(q^k)) = q^{k * D} where D is a fixed integer matrix,
# then adj(I-A(q^k)) has the SAME structure for all k, just with q -> q^k.
# Let me check: does D_k = k * D_1?

print("\n\nChecking if degree(adj(I-A(q^k))) = k * degree(adj(I-A(q))):")
deg1 = []
deg2 = []
for i in range(N):
    for j in range(N):
        e1 = adj1[i,j]
        e2 = adj2[i,j]
        c1 = list(e1)[:PREC]
        c2 = list(e2)[:PREC]
        nz1 = [k for k, c in enumerate(c1) if c != 0]
        nz2 = [k for k, c in enumerate(c2) if c != 0]
        d1 = nz1[0] if nz1 else -1
        d2 = nz2[0] if nz2 else -1
        deg1.append(d1)
        deg2.append(d2)
        if d1 >= 0 and d2 != 2 * d1:
            print(f"  MISMATCH at [{compositions[i]}, {compositions[j]}]: deg1={d1}, deg2={d2}, 2*deg1={2*d1}")

if all(d2 == 2*d1 for d1, d2 in zip(deg1, deg2)):
    print("  YES! deg(adj(I-A(q^k))) = k * deg(adj(I-A(q))) for k=2.")
    print("  This means adj(I-A(q^k)) is obtained from adj(I-A(q)) by substituting q -> q^k!")

