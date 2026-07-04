"""
Seed 2, Layer 1: Analyze patterns in Q_{n,c}(q) coefficients.

Key observations to check:
1. Degree of Q_{n,c}(q) as a function of n and d
2. Symmetry/unimodality of coefficients
3. Whether Q_{n,c}(q) factors nicely 
4. Connection to q-binomial coefficients or other known positive polynomials
5. Whether coefficients have a combinatorial interpretation via bead model
"""

# Reuse data from previous computation
import sys

# d=4, c=(2,1,1):
Q_211 = {
    0: [1],
    1: [0, 2, 1, 1],
    2: [0, 0, 0, 1, 3, 2, 3, 2, 2, 1, 1, 0, 1],
    3: [0, 0, 0, 0, 0, 0, 0, 2, 2, 5, 4, 6, 6, 6, 5, 6, 4, 4, 3, 3, 2, 2, 1, 1, 1, 0, 0, 1],
}

# d=4, c=(3,1,0):
Q_310 = {
    0: [1],
    1: [0, 1, 1, 1, 0, 1],
    2: [0, 0, 0, 0, 2, 1, 2, 2, 2, 1, 2, 1, 1, 1, 0, 0, 1],
    3: [0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 2, 3, 4, 5, 4, 5, 4, 5, 4, 4, 3, 4, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 1],
}

# d=5, c=(2,2,1):
Q_221 = {
    0: [1],
    1: [0, 2, 2, 1, 1],
    2: [0, 0, 0, 1, 4, 4, 5, 4, 5, 3, 3, 2, 2, 1, 1, 0, 1],
    3: [0, 0, 0, 0, 0, 0, 0, 2, 4, 8, 9, 12, 14, 15, 15, 16, 15, 14, 14, 12, 11, 10, 8, 7, 7, 5, 4, 3, 3, 2, 2, 1, 1, 1, 0, 0, 1],
}

# d=5, c=(1,3,1):
Q_131 = {
    0: [1],
    1: [0, 2, 1, 2, 0, 1],
    2: [0, 0, 0, 1, 3, 3, 5, 4, 4, 3, 4, 2, 2, 1, 2, 1, 0, 0, 1],
    3: [0, 0, 0, 0, 0, 0, 0, 2, 2, 7, 7, 11, 11, 14, 13, 16, 13, 15, 13, 13, 10, 12, 9, 9, 6, 6, 5, 6, 3, 3, 2, 2, 1, 2, 1, 1, 0, 0, 0, 1],
}

print("=" * 60)
print("Pattern Analysis of Q_{n,c}(q)")
print("=" * 60)

for name, Qs, profile in [
    ("c=(2,1,1), d=4", Q_211, (2,1,1)),
    ("c=(3,1,0), d=4", Q_310, (3,1,0)),
    ("c=(2,2,1), d=5", Q_221, (2,2,1)),
    ("c=(1,3,1), d=5", Q_131, (1,3,1)),
]:
    d = sum(profile)
    t = 3 + d
    print(f"\n{name}, t={t}")
    for n in range(4):
        if n not in Qs: continue
        coeffs = Qs[n]
        deg = len(coeffs) - 1
        total = sum(coeffs)
        
        # Find minimum degree (first nonzero)
        min_deg = next((i for i, c in enumerate(coeffs) if c > 0), -1)
        
        # Check for palindrome/quasi-symmetry
        nz_coeffs = coeffs[min_deg:deg+1]
        rev_nz = list(reversed(nz_coeffs))
        is_palindrome = (nz_coeffs == rev_nz)
        
        print(f"  n={n}: min_deg={min_deg}, deg={deg}, sum={total}, "
              f"palindrome={is_palindrome}")
        
        # Check if degree follows a pattern
        if n >= 1:
            print(f"    deg/n = {deg/n:.2f}, deg/n^2 = {deg/n**2:.2f}")
            # For c=(2,1,1): deg = 3, 12, 27 => 3n^2/1 = 3, 12, 27. So deg = 3n(n+...)?
            # Actually: 3, 12, 27 = 3*1, 3*4, 3*9 = 3n^2. Check!
            # For c=(3,1,0): 5, 16, 33 => ?
            # For c=(2,2,1): 4, 16, 36 = 4, 16, 36 = 4n^2? No, 4*1=4, 4*4=16, 4*9=36. Yes!
            # For c=(1,3,1): 5, 18, 39 => ?

print("\n\nDegree patterns:")
print("c=(2,1,1): n=1->3, n=2->12, n=3->27 => deg = 3n^2? 3,12,27 = 3(1,4,9)")
print("c=(3,1,0): n=1->5, n=2->16, n=3->33 => 5,16,33 ??")
print("  Differences: 11, 17. Second diff: 6. So deg = 3n^2 + 2n? 3+2=5, 12+4=16, 27+6=33. Yes!")
print("c=(2,2,1): n=1->4, n=2->16, n=3->36 => deg = 4n^2")
print("c=(1,3,1): n=1->5, n=2->18, n=3->39 => 5,18,39")
print("  Differences: 13, 21. Second diff: 8. 4n^2 + n? 5,18,39. Yes!")

print("\n\nMinimum degree patterns:")
for name, Qs, profile in [
    ("c=(2,1,1)", Q_211, (2,1,1)),
    ("c=(3,1,0)", Q_310, (3,1,0)),
    ("c=(2,2,1)", Q_221, (2,2,1)),
    ("c=(1,3,1)", Q_131, (1,3,1)),
]:
    min_degs = []
    for n in range(4):
        if n not in Qs: continue
        coeffs = Qs[n]
        md = next((i for i, c in enumerate(coeffs) if c > 0), 0)
        min_degs.append(md)
    print(f"  {name}: min_degs = {min_degs}")
    # c=(2,1,1): 0, 1, 3, 7 => differences 1, 2, 4. 
    # c=(3,1,0): 0, 1, 4, 8 =>
    # c=(2,2,1): 0, 1, 3, 7 =>
    # These look like n(n-1)/2 + n = n(n+1)/2 - ish

print("\n\nLeading coefficient (highest degree term):")
for name, Qs in [
    ("c=(2,1,1)", Q_211),
    ("c=(3,1,0)", Q_310),
    ("c=(2,2,1)", Q_221),
    ("c=(1,3,1)", Q_131),
]:
    for n in range(4):
        if n not in Qs: continue
        coeffs = Qs[n]
        print(f"  {name}, n={n}: leading coeff = {coeffs[-1]} at degree {len(coeffs)-1}")
