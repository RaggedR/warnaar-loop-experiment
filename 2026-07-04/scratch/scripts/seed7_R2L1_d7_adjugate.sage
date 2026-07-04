# Compute adjugate for d=7 — may be slow, verify EMD
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
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

A, profs, prof_idx = build_transfer_matrix(7)
N = len(profs)
R = A.base_ring()
x = R.gen()
I_mat = matrix(R, N, N, lambda i,j: 1 if i==j else 0)
M = I_mat - A

# Instead of full adjugate (expensive), verify EMD for a sample of entries
# using the relation: adj(M) = det(M) * M^{-1}
# det(M) = -(x^3-1), so adj = -(x^3-1) * M^{-1}
# M^{-1} exists over the fraction field

print("Computing M^{-1} over fraction field...")
import sys; sys.stdout.flush()

F = FractionField(R)
M_F = M.change_ring(F)
M_inv = M_F.inverse()

print("Verifying EMD monomial theorem for d=7...")

all_match = True
max_emd = 0
emd_values = set()

for i in range(N):
    for j in range(N):
        c = profs[i]
        cp = profs[j]
        emd = EMD_formula(c, cp)
        emd_values.add(emd)
        if emd > max_emd:
            max_emd = emd
        
        # adj[i,j] = det(M) * M_inv[i,j] = -(x^3-1) * M_inv[i,j]
        adj_entry = -(x**3 - 1) * M_inv[i,j]
        # Should equal x^emd
        expected = x**emd
        
        # Simplify the fraction
        num = adj_entry.numerator()
        den = adj_entry.denominator()
        if den != 1 or num != R(expected):
            print(f"  MISMATCH ({c} -> {cp}): adj = {adj_entry}, expected x^{emd}")
            all_match = False

print(f"\nAll 36x36 = {N*N} entries match EMD formula: {all_match}")
print(f"EMD values occurring: {sorted(emd_values)}")
print(f"Max EMD: {max_emd}")

# Show the EMD distribution
from collections import Counter
emd_counter = Counter()
for i in range(N):
    for j in range(N):
        emd = EMD_formula(profs[i], profs[j])
        emd_counter[emd] += 1
print(f"\nEMD value distribution: {dict(sorted(emd_counter.items()))}")
