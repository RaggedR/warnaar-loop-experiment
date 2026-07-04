# Seed 7 R2L1: Compute adjugate of (I-A(x)) for d=7, verify EMD monomial structure
from itertools import combinations

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def I_c(c):
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

def build_transfer_matrix(d):
    profs = profiles(d)
    prof_idx = {p: i for i, p in enumerate(profs)}
    N = len(profs)
    R = PolynomialRing(QQ, 'x')
    x = R.gen()
    A = matrix(R, N, N)
    for i, c in enumerate(profs):
        ic = I_c(c)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    j = prof_idx[cp]
                    A[i, j] += (-1)**(size-1) * x**size
    return A, profs, prof_idx

def EMD_formula(c, cp):
    """EMD on Z/3Z with clockwise metric, as per synthesis:
    EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
    """
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

print("Building for d=7...")
A, profs, prof_idx = build_transfer_matrix(7)
N = len(profs)
R = A.base_ring()
x = R.gen()
I_mat = matrix(R, N, N, lambda i,j: 1 if i==j else 0)
M = I_mat - A

print("Computing adjugate (this may take a while for 36x36)...")
import sys
sys.stdout.flush()

# adj(M) = det(M) * M^{-1}, but M^{-1} might not be over polynomials
# Instead, adj(M)[i,j] = (-1)^{i+j} * det(M with row j, col i removed)
# For a 36x36 matrix this is 36^2 = 1296 determinants of 35x35 matrices.
# This could be slow. Let me try a smaller d first.

for d in [2, 4, 5]:
    A_d, profs_d, prof_idx_d = build_transfer_matrix(d)
    N_d = len(profs_d)
    I_d = matrix(R, N_d, N_d, lambda i,j: 1 if i==j else 0)
    M_d = I_d - A_d
    adj_d = M_d.adjugate()
    
    print(f"\n=== d={d}, N={N_d} ===")
    all_monomial = True
    emd_match = True
    for i in range(N_d):
        for j in range(N_d):
            entry = adj_d[i,j]
            c = profs_d[i]
            cp = profs_d[j]
            emd = EMD_formula(c, cp)
            expected = x**emd
            if entry != expected:
                print(f"  MISMATCH at ({c}, {cp}): adj={entry}, EMD={emd}, expected=x^{emd}={expected}")
                emd_match = False
            # Check if monomial
            coeffs = entry.coefficients()
            if len(coeffs) != 1 or coeffs[0] != 1:
                all_monomial = False
    
    print(f"  All entries monomials: {all_monomial}")
    print(f"  All match EMD formula: {emd_match}")

print("\nNow trying d=7 (36x36 adjugate)...")
sys.stdout.flush()
