# Compute P_n and Q_n from F_{c,n}, compare with KR crystal energy sums

R.<q> = PowerSeriesRing(ZZ, default_prec=100)

# From enumeration above for d=2:
# Profile (1,1,0):
F_110 = {
    0: R(1),
    1: R(1 + 2*q + 2*q^2 + 2*q^3 + 2*q^4 + 2*q^5 + 2*q^6 + 2*q^7 + 2*q^8 + 2*q^9 + 2*q^10 + 2*q^11 + 2*q^12 + 2*q^13 + 2*q^14 + q^15),
}
# Profile (2,0,0):
F_200 = {
    0: R(1),
    1: R(1 + q + 2*q^2 + 2*q^3 + 2*q^4 + 2*q^5 + 2*q^6 + 2*q^7 + 2*q^8 + 2*q^9 + 2*q^10 + 2*q^11 + 2*q^12 + 2*q^13 + 2*q^14 + 2*q^15 + 2*q^16 + q^17 + q^18),
}
# Profile (0,1,1):
F_011 = {
    0: R(1),
    1: R(1 + 2*q + 2*q^2 + 2*q^3 + 2*q^4 + 2*q^5 + 2*q^6 + 2*q^7 + 2*q^8 + 2*q^9 + 2*q^10 + 2*q^11 + 2*q^12 + 2*q^13 + 2*q^14 + q^15),
}

d = 2
ell = gcd(d, 3)  # = 1
print(f"d={d}, ell={ell}")

# P_n = (q^ell;q^ell)_n * F_{c,n}
# Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m F_{c,m} z^m)

# For n=1:
# [z^1]((zq;q)_inf * (F_{c,0} + F_{c,1}*z + F_{c,2}*z^2 + ...))
# = [z^1]((1-zq)(1-zq^2)... * (F_{c,0} + F_{c,1}*z + ...))
# = F_{c,1} - q * F_{c,0}
# = F_{c,1} - q

# Q_1 = (1-q) * (F_{c,1} - q)

# Let's also compute P_n = (q;q)_n * F_{c,n} (since ell=1)
def qpoch(a, n, prec=100):
    """(a;q)_n = prod_{i=0}^{n-1} (1 - a*q^i)"""
    result = R(1)
    for i in range(n):
        result *= (1 - a * q^i)
    return result

for name, F_data in [("(1,1,0)", F_110), ("(2,0,0)", F_200), ("(0,1,1)", F_011)]:
    print(f"\nProfile {name}:")
    
    # P_1 = (q;q)_1 * F_{c,1} = (1-q) * F_{c,1}
    P1 = (1-q) * F_data[1]
    print(f"  P_1 = {P1}")
    print(f"  P_1(1) = {P1.polynomial()(1) if P1 != 0 else 0}")
    
    # Q_1 = (1-q) * (F_{c,1} - q * F_{c,0}) = (1-q) * (F_{c,1} - q)
    h1 = F_data[1] - q * F_data[0]
    Q1 = (1-q) * h1
    print(f"  h_1 = F_1 - q = {h1}")
    print(f"  Q_1 = (1-q) * h_1 = {Q1}")
    print(f"  Q_1(1) should be (d+1)(d+2)/6 - 1 = {(d+1)*(d+2)//6 - 1}")
    print(f"  Q_1(1) = {Q1.polynomial()(1) if Q1 != 0 else 0}")

print("\n=== KR Crystal B^{1,2} for A_2^(1) ===")
print()

# Now compute KR tensor product energy sums
# B^{1,2} has 6 elements, matching 6 profiles

K = crystals.KirillovReshetikhin(['A', 2, 1], 1, 2)
print("Elements of B^{1,2} and their classical weights:")
for b in K:
    # Classical weight = projection to finite part
    cwt = b.weight().to_ambient()
    print(f"  {b}: wt = {b.weight()}")

print()

# Tensor product B^{1,2} tensor B^{1,2}
T2 = crystals.TensorProduct(K, K)
print(f"B^{{1,2}}^{{tensor 2}} has {T2.cardinality()} elements")

# Compute energy-graded character
# Group by classical weight
from collections import defaultdict
energy_by_weight = defaultdict(lambda: R(0))

for b in T2:
    try:
        e = b.energy_function()
        wt = tuple(b.weight().to_ambient())
        energy_by_weight[wt] += q^e
    except Exception as ex:
        print(f"  Error computing energy for {b}: {ex}")

print("\nEnergy sums by weight:")
for wt in sorted(energy_by_weight.keys()):
    print(f"  wt={wt}: {energy_by_weight[wt]}")

# Total energy sum
total = sum(energy_by_weight.values())
print(f"\nTotal energy sum: {total}")
print(f"Total at q=1: {total.polynomial()(1)}")
print(f"6^2 = {6^2}")

# Now the 1d configuration sum for ground state Lambda_0:
# X(Lambda_0, q) = sum over paths p in P(Lambda_0) truncated to length n of q^{D(p)}
# where D is the energy function

# Actually, the 1d config sum is:
# X_n(Lambda, q) = sum_{b_1,...,b_n in B^{1,d}} q^{sum H(b_i tensor b_{i+1})} * (ground state condition)

# In the Kyoto path model, paths of length n starting from ground state
# p = (b_n, b_{n-1}, ..., b_1) such that phi(b_1) = Lambda, eps(b_k) = phi(b_{k+1})

# For the KR crystal, the 1d configuration sum is computed differently
# Let me try a direct approach

print("\n=== 1d Configuration Sums ===")

# The 1d config sum for B^{1,d} at level d:
# X_n(Lambda, q) = sum over (b_1,...,b_n) in B^{1,d}^n with
# phi(b_1) = Lambda_reduced, eps(b_k) = phi(b_{k+1}) 
# of q^{sum H_i}

# This is the character of a Demazure-like module

# Let me try SageMath's built-in Kyoto path realization
print("\nKyoto path model for Lambda_0 level 2:")
try:
    # The highest weight crystal
    La = RootSystem(['A',2,1]).weight_lattice(extended=True).fundamental_weights()
    C = crystals.LSPaths(2*La[0])
    # This is infinite, take Demazure subcrystal
    # B_{t_Lambda^n}(Lambda) for translation t_Lambda
    
    # Actually let's try the alcove path model or direct KR path
    # Use KR crystal as perfect crystal
    
    # Try computing the one-dimensional sum directly
    # Using the formula from KKMMNN
    
    # For paths of length n in B^{1,d}:
    # need eps(b_k) = phi(b_{k+1}) (perfect crystal condition)
    # and phi(b_1) = Lambda
    
    # For B^{1,2} for A_2^(1):
    # The elements are tableaux [[1,1]], [[1,2]], [[2,2]], [[1,3]], [[2,3]], [[3,3]]
    # phi and eps are the crystal functions
    
    for b in K:
        eps = tuple(b.epsilon(i) for i in [0,1,2])
        phi = tuple(b.phi(i) for i in [0,1,2])
        print(f"  {b}: eps={eps}, phi={phi}")
    
except Exception as e:
    print(f"Error: {e}")

# The ground state path for Lambda = 2*Lambda_0:
# phi(b_1) = 2*Lambda_0 means phi_0(b_1) = 2, phi_1(b_1) = 0, phi_2(b_1) = 0
# Looking at the output above, this should be [[3,3]] (highest weight under f_0)

