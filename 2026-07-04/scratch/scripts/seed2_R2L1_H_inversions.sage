from sage.all import *

def compute_H(d):
    K = crystals.KirillovReshetikhin(['A',2,1], 1, d)
    T = crystals.TensorProduct(K, K)
    def prof(b):
        tab = list(b.to_tableau())[0]
        return (tab.count(1), tab.count(2), tab.count(3))
    H = {}
    for b in T:
        H[(prof(b[0]), prof(b[1]))] = b.energy_function()
    profiles = sorted(set(prof(b) for b in K))
    return H, profiles

# The energy function for KR crystals B^{1,s} of type A_{n-1}^(1)
# counts "winding pairs" in the R-matrix algorithm
# For ROWS of length s, the R-matrix uses the Lusztig involution / promotion

# Key insight from Schilling et al: for B^{1,s} of type A_{n-1}^(1),
# the energy function H(b1 tensor b2) can be computed as follows:
# Create a 2xd array with b1 on top and b2 on bottom
# Apply jeu de taquin to produce a pair of tableaux
# H = number of boxes that "wrap around" (change from column i to column i+1)

# Actually, for single-row KR crystals, there's a simpler formula
# (see Kirillov-Schilling-Shimozono):
# H(b1, b2) = sum_{a=1}^{n-1} min(m_a(b1), M_a(b2))
# where m_a(b) = #{entries of b equal to a} 
# and M_a(b) = #{entries of b > a}

# Wait, let me check this formula:
# For n=3 (A_2^(1)), a ranges over {1, 2}
# m_a(c) = c_{a-1} (number of a's in the word)
# M_a(c) = sum_{j>a} c_{j-1} (number of entries > a)

# So the formula would be:
# H(c, c') = min(c_0, c'_1+c'_2) + min(c_1, c'_2)

# Check for d=2:
H2, profs2 = compute_H(2)
print("Testing H = min(c_0, c'_1+c'_2) + min(c_1, c'_2) for d=2:")
all_ok = True
for c in profs2:
    for cp in profs2:
        f = min(c[0], cp[1]+cp[2]) + min(c[1], cp[2])
        h = H2[(c, cp)]
        if f != h:
            print(f"  FAIL: H({c},{cp})={h}, formula={f}")
            all_ok = False
print(f"  Result: {all_ok}")

# Hmm wait, the reference might use the opposite convention
# (which tensor factor is "first")
# Try: H = min(c'_0, c_1+c_2) + min(c'_1, c_2)
print("\nTesting H = min(c'_0, c_1+c_2) + min(c'_1, c_2) for d=2:")
all_ok2 = True
for c in profs2:
    for cp in profs2:
        f = min(cp[0], c[1]+c[2]) + min(cp[1], c[2])
        h = H2[(c, cp)]
        if f != h:
            print(f"  FAIL: H({c},{cp})={h}, formula={f}")
            all_ok2 = False
print(f"  Result: {all_ok2}")

# Check for d=3 and d=4
for d in [3, 4]:
    H_d, profs_d = compute_H(d)
    all_ok = True
    for c in profs_d:
        for cp in profs_d:
            f = min(cp[0], c[1]+c[2]) + min(cp[1], c[2])
            h = H_d[(c, cp)]
            if f != h:
                all_ok = False
                break
        if not all_ok:
            break
    print(f"\nH = min(c'_0, c_1+c_2) + min(c'_1, c_2) for d={d}: {all_ok}")

# General formula for A_{n-1}^(1):
# H(c, c') = sum_{a=1}^{n-1} min(c'_{a-1}, sum_{j=a}^{n-1} c_j)
# = sum_{a=1}^{n-1} min(c'_{a-1}, c_a + c_{a+1} + ... + c_{n-1})

# For n=3 (A_2):
# H = min(c'_0, c_1+c_2) + min(c'_1, c_2)

# This is a beautiful formula! It says:
# H = (how many 1's in c' can be matched with 2's and 3's in c)
#   + (how many 2's in c' can be matched with 3's in c)

# This is exactly the number of "descents" or "inversions" between
# the sorted words of c and c' in a specific sense

