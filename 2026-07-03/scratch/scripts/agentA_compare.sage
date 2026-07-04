"""
Agent A: Understand the weight correspondence and compute Q_n to compare
with energy-graded KR crystal characters.

Key observation: Element [[1^a, 2^b, 3^c]] of B^{1,d} has 
content (a,b,c) with a+b+c = d.
Its affine weight is (-a-c+b, a-2b+c, -a+b+2c-d)... 
Let me just compute directly.
"""

from sage.all import *

# First let's understand the weight map
# For A_2^(1), the simple roots are alpha_0, alpha_1, alpha_2
# Weight of [[1^a 2^b 3^c]] in terms of fundamental weights Lambda_0, Lambda_1, Lambda_2

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
print("Content -> Affine weight mapping for B^{1,4}:")
for b in K:
    wt = b.weight()
    # Count entries
    entries = list(b.to_tableau())[0]
    a = entries.count(1)
    bb = entries.count(2)
    c = entries.count(3)
    print(f"  ({a},{bb},{c}) -> ({wt[0]}, {wt[1]}, {wt[2]})")

# The content (a,b,c) IS the profile in the cylindric partition sense.
# Profile (c_0, c_1, c_2) = (a, b, c) = (#1s, #2s, #3s).
#
# Now, for tensor product B^{1,d}^{tensor n}, the weight is the sum of 
# individual weights. So elements with each factor having content (c_0,c_1,c_2)
# would have total affine weight = n * (weight of single factor with content c).
# But we don't restrict each factor - the partition function sums over ALL 
# tensor product elements.
#
# Actually, the connection via Tingley is:
# Cylindric plane partitions of profile c parametrize a crystal subgraph.
# The generating function F_c(q) = sum_Lambda q^{|Lambda|} should relate to
# the character of an integrable highest weight module.
#
# Let me try a different approach: compute one_dimensional_configuration_sum
# which is the standard way to get these sums in SageMath.

print("\n" + "=" * 60)
print("One-dimensional configuration sums")
print("=" * 60)

# For a single KR crystal
K4 = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
# one_dimensional_configuration_sum gives sum_b q^{D(b)} * e^{wt(b)}
# where D is the energy function and wt is the classical weight

# For tensor products, SageMath has a method:
# T.one_dimensional_configuration_sum(q)
# This returns a character (in the weight lattice) with q-grading

print("\nB^{1,4} one_dim_config_sum:")
try:
    odcs = K4.one_dimensional_configuration_sum()
    print(f"  Result: {odcs}")
except Exception as e:
    print(f"  Error: {e}")

print("\nB^{1,4} tensor B^{1,4} one_dim_config_sum:")
T = tensor([K4, K4])
try:
    odcs2 = T.one_dimensional_configuration_sum()
    print(f"  Result type: {type(odcs2)}")
    print(f"  Result: {odcs2}")
except Exception as e:
    print(f"  Error: {e}")

# Let me try a different approach - use the crystal directly
# and group by classical weight
print("\n" + "=" * 60) 
print("Manual energy computation for B^{1,4}^{tensor 2}")
print("=" * 60)

R = PolynomialRing(ZZ, 'q')
q = R.gen()

# Group tensor product elements by the content of each factor
# Content of b = (content_factor_1, content_factor_2)
# I want to group by TOTAL classical weight

# Classical weight for sl_3: if entry counts are (a,b,c) then
# classical weight = a*epsilon_1 + b*epsilon_2 + c*epsilon_3
# = (a-b)*omega_1 + (b-c)*omega_2 in fundamental weight basis

# For comparing with cylindric partitions, I think the key is:
# The unrestricted generating function F_c(q) = Borodin product
# The bounded one F_{c,n}(q) relates to tensor products

# Let me compute things more carefully.
# For the tensor product B^{1,d}^{tensor N}, I want to see if
# the energy-graded weight space for weight corresponding to
# profile c (repeated N times) gives something related to Q_{N,c}.

# Weight of profile c = (c_0, c_1, c_2) in B^{1,d}:
# From the data above, content (a,b,c) maps to affine weight
# (w_0, w_1, w_2). 

# For d=4: (2,1,1) -> (-1, 1, 0)
# For tensor product of 2 copies, total weight = (-2, 2, 0)
# But (-2, 2, 0) in the tensor product output gives:
# q^4 + 2*q^3 + 3*q^2 + 2*q + 1

# Let me check: Q_2 for c=(2,1,1), d=4 should be...
# From the synthesis: Q_2(1) = ((d+1)(d+2)/6 - 1)^2 = (5*6/6 - 1)^2 = 4^2 = 16
# But q^4 + 2*q^3 + 3*q^2 + 2*q + 1 evaluates to 1+2+3+2+1 = 9

# So the tensor product weight space does NOT directly equal Q_n.
# The relationship must be more indirect.

# Let me think about this differently.
# Tingley says: cylindric plane partitions parametrize V_Lambda tensor F.
# The size |pi| = principal grade of V_Lambda component + size of partition.
# So F_c(q) = (character of V_Lambda at weight mu) * 1/(q)_infty
# where the character is principally graded.

# Actually for the KR tensor product approach:
# The fermionic formula gives:
# sum_b q^{D(b)} = X_lambda(q) where the sum is over paths of 
# classical weight lambda in B^{1,s}^{tensor infinity}

# For finite tensor: B^{1,d}^{tensor n} gives F_{c,n} (bounded version)

# Let me compute F_{c,n} directly and compare
print("\n" + "=" * 60)
print("Direct computation of F_{c,n} via enumeration")
print("=" * 60)

def enumerate_cylindric_partitions(profile, max_val, prec=30):
    """
    Enumerate cylindric partitions of profile c with max entry <= max_val.
    Returns polynomial sum q^{|Lambda|}.
    """
    c = list(profile)
    k = len(c)
    d = sum(c)
    
    R = PolynomialRing(QQ, 'q')
    q = R.gen()
    
    # For k=3, c = (c_0, c_1, c_2), a CP is (lam^0, lam^1, lam^2) where
    # lam^i are partitions with max part <= max_val satisfying:
    # lam^i_j >= lam^{i+1}_{j + c_{i+1}} (cyclic)
    
    # For computational feasibility, restrict number of parts
    # A CP with max part m has at most d*m total parts...
    # This is too slow for large cases. Let me use the CW recurrence.
    
    # Actually, let me use the generating function approach.
    # g_m = coefficient of y^m in F_c(y,q)
    # F_{c,n} = sum_{m=0}^n g_m
    
    # The CW recurrence: F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^|J|,q)/(1-yq^|J|)
    # This is a recurrence that reduces d by 1 each step.
    
    # For small max_val, direct enumeration might work for k=3, small d
    pass

# Use the known formulas instead
# For d=4, c=(2,1,1):
# From Warnaar's paper, the sum side for k=1 (d=2) is known explicitly
# For d=4 (k=2), explicit formulas exist

# Let me compute Q_n directly using the definition
# Q_{n,c}(q) = (q;q)_n * [z^n]((zq)_infty * F_c(z,q))

# I need F_c(z,q). Let me compute g_m = [y^m] F_c(y,q) from Borodin's formula
# and the CW recurrence.

# Actually the simplest: compute G_n(q) = [y^n] F_c(y,q) for c = (2,1,1), d=4
# using the CW recurrence directly.

# Corteel-Welsh recurrence for k=3:
# I_c = {i : c_i > 0}
# For c=(2,1,1): I_c = {0,1,2}

# For J subset of I_c, c(J) shifts the profile
# This gets complicated. Let me use a simpler approach.

# For d=2, k=1, c=(1,1): F_c(y,q) = 1/((yq;q)_1 * (yq;q)_1) ??? No.
# Actually Borodin's formula gives F_c(q) (at z=1), and the CW recurrence
# gives the bivariate version.

# Let me take a step back and use SageMath to compute everything from scratch.
# The key question is: what does the energy-graded KR tensor product give us?

# For B^{1,d}, single crystal: sum_{b in B^{1,d}} q^0 * x^{wt(b)} 
# = sum of monomials (no energy for single factor)
# = character of V_{d*Lambda_1} for sl_3 (the d-th symmetric power)
# = sum_{a+b+c=d} x_1^a x_2^b x_3^c

# For B^{1,d}^{tensor 2}: sum_{b in T} q^{E(b)} x^{wt(b)}
# This gives a q-analogue of the character of V_{d*Lambda_1}^{tensor 2}

# The one-dimensional configuration sum should be:
# X(B, lambda, q) = sum_{b: cl_wt(b)=lambda} q^{D(b)}

# For comparing with F_{c,n}:
# Recall F_{c,n}(q) = sum_{Lambda in C_{c,n}} q^{|Lambda|}
# where C_{c,n} = CPs of profile c with max <= n

# The connection (if it exists) should be:
# F_{c,n}(q) = X(B^{1,d}^{tensor n}, lambda_c, q) (up to normalization)
# where lambda_c is the classical weight corresponding to profile c

# For c=(2,1,1), the classical sl_3 weight is:
# lambda = (2-1)*omega_1 + (1-1)*omega_2 = omega_1 = (1,0)

# For B^{1,4}^{tensor 2}, weight (-2, 2, 0) corresponds to:
# (Lambda_0 coeff, Lambda_1 coeff, Lambda_2 coeff) = (-2, 2, 0)
# This means level = wt[0] + wt[1] + wt[2] = 0... that's classical weight only
# Classical sl_3 weight: wt[1]*Lambda_1 + wt[2]*Lambda_2 = 2*Lambda_1

# So X(B^{1,4}^{tensor 2}, 2*Lambda_1, q) = q^4 + 2*q^3 + 3*q^2 + 2*q + 1

# And F_{c,2}(q) for c=(2,1,1) should be the generating function of CPs
# with profile (2,1,1) and max <= 2.
# F_{c,2} = g_0 + g_1 + g_2 where g_m = #{CPs with max = m, profile c}*q^{size}

# g_0 = 1 (empty CP)
# g_1 = q^3 + q^2 + 2*q + 1 ... let me compute

# Actually, let me verify numerically using the direct definition
# g_1 for c=(2,1,1): CPs with max part = 1
# Lambda = (lam^0, lam^1, lam^2) with max = 1 and profile (2,1,1)
# Conditions: lam^0_j >= lam^1_{j+1}, lam^1_j >= lam^2_{j+1}, lam^2_j >= lam^0_{j+2}
# All parts are 0 or 1.

# lam^0 = (1,...,1,0,...) with say a_0 ones
# lam^1 = (1,...,1,0,...) with a_1 ones  
# lam^2 = (1,...,1,0,...) with a_2 ones

# Conditions: lam^0_j >= lam^1_{j+1}: a_0 >= a_1 + 1 if a_1 >= 1, 
#   more precisely: for j <= a_0, 1 >= lam^1_{j+1} which requires j+1 <= a_1, 
#   so a_0 <= a_1 + 1... wait, let me be more careful.

# Actually lam^0_j >= lam^1_{j+c_1} = lam^1_{j+1} for all j >= 1
# This means: if lam^0_j = 0 then lam^1_{j+1} = 0, so a_1 <= a_0
# (if lam^0 has a_0 ones, then lam^0_j = 0 for j > a_0, so lam^1_{j+1} = 0 for j > a_0, i.e. a_1 <= a_0)

# lam^1_j >= lam^2_{j+c_2} = lam^2_{j+1}: similarly a_2 <= a_1
# lam^2_j >= lam^0_{j+c_0} = lam^0_{j+2}: a_0 <= a_2 + 2

# Also max = 1, so max(a_0, a_1, a_2) >= 1 (actually max = 1 means all parts <= 1
# AND at least one part = 1)

# Constraints: a_1 <= a_0, a_2 <= a_1, a_0 <= a_2 + 2
# Size = a_0 + a_1 + a_2
# At least one a_i >= 1

# All are nonneg integers. Let me enumerate:
# If a_0 = 0: a_1 = 0, a_2 = 0 -> max = 0, excluded
# If a_0 = 1: a_1 <= 1, a_2 <= a_1, a_0 <= a_2 + 2 (1 <= a_2 + 2, always true)
#   a_1=0, a_2=0: size 1
#   a_1=1, a_2=0: size 2
#   a_1=1, a_2=1: size 3
# If a_0 = 2: a_1 <= 2, a_2 <= a_1, 2 <= a_2 + 2 so a_2 >= 0
#   a_1=0, a_2=0: size 2
#   a_1=1, a_2=0: size 3
#   a_1=1, a_2=1: size 4
#   a_1=2, a_2=0: size 4
#   a_1=2, a_2=1: size 5
#   a_1=2, a_2=2: size 6, but check a_0=2 <= a_2+2=4, ok
# If a_0 = 3: 3 <= a_2 + 2 so a_2 >= 1
#   a_1 <= 3, a_2 <= a_1, a_2 >= 1
#   a_1=1, a_2=1: size 5
#   a_1=2, a_2=1: size 6
#   a_1=2, a_2=2: size 7
#   a_1=3, a_2=1: size 7
#   a_1=3, a_2=2: size 8
#   a_1=3, a_2=3: size 9
# If a_0 = 4: 4 <= a_2+2 so a_2 >= 2
#   similarly...
# This goes on forever! g_1 is an infinite series, not a polynomial.

# Oh right - g_m is a power series in q, not a polynomial.
# The generating function is infinite because the partitions can have
# arbitrarily many parts (all equal to 1).

# So g_m = sum_{a_0, a_1, a_2} q^{a_0 + a_1 + a_2}
# with constraints a_1 <= a_0, a_2 <= a_1, a_0 <= a_2 + 2

# This is an infinite series. The BOUNDED version F_{c,n} truncates.
# F_{c,n} = sum_{m=0}^n g_m

# Q_{n,c}(q) = (q;q)_n * [z^n]((zq)_infty * F_c(z,q))
# = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * g_j

# So Q_1(q) = (1-q) * (g_0 * (-q) + g_1 * 1)
# Wait: [z^1]((zq)_infty * F_c(z,q))
# (zq)_infty = prod_{j>=0} (1 - zq^{j+1}) = 1 - zq/(1-q) + ...
# Actually (zq)_infty = sum_{m>=0} (-z)^m q^{m(m+1)/2} / (q;q)_m
# = 1 - zq + z^2 q^3/(1-q) - ...
# Hmm let me just compute the coefficients properly.

# (zq;q)_infty = sum_{m>=0} z^m q^{m(m+1)/2} (-1)^m / (q;q)_m  [Euler]

# [z^n]((zq;q)_infty * F_c(z,q))
# = sum_{j=0}^n [z^j of F_c] * [z^{n-j} of (zq;q)_infty]
# = sum_{j=0}^n g_j * (-1)^{n-j} q^{(n-j)(n-j+1)/2} / (q;q)_{n-j}

# Q_n = (q;q)_n * this
# For n=1:
# = (1-q) * [g_0 * (-1)^1 q^1 / (q;q)_1 + g_1 * (-1)^0 q^0 / (q;q)_0]
# = (1-q) * [-g_0 * q / (1-q) + g_1]
# = -g_0 * q + (1-q) * g_1
# = (1-q)*g_1 - q  (since g_0 = 1)

# From the synthesis, h_1 = (1-q)*g_1 and Q_1 = h_1 - q... 
# Wait, that doesn't look right. Let me check.
# Actually Q_1 = (q;q)_1 * [g_1 + g_0 * (-q)/(1-q)]
# = (1-q) * [g_1 - q/(1-q)]
# = (1-q)*g_1 - q

# Hmm, but h_1 is defined as part of the D_k^m tower, not directly as (1-q)*g_1.
# Let me check: from the synthesis, the D_k^m tower decomposition is
# Q_n = sum_{k} D_k^m ... 
# And h_m relates to this somehow. Let me not worry about this notation for now.

# The key question: does the energy-graded KR tensor product match F_{c,n}?

# For d=4, n=1: KR crystal B^{1,4} has no energy function (single factor).
# For d=4, n=2: energy-graded weight space at weight (-2,2,0) gives
# q^4 + 2q^3 + 3q^2 + 2q + 1 = 9

# F_{c,2} for c=(2,1,1) should be sum_{m=0}^2 g_m at q=1:
# g_0 = 1, g_1 evaluated at 1 = sum of lattice points with max=1
# For max=1: # of (a_0,a_1,a_2) with a_1<=a_0, a_2<=a_1, a_0<=a_2+2
# These are unbounded! g_1(1) diverges.

# So the tensor product does NOT equal F_{c,n}. The relationship must be 
# through Q_n, not F_{c,n}.

# Let me check: Q_2(1) = 4^2 = 16 for c=(2,1,1), d=4.
# But the weight space gives 9. So it's not Q_n either.

# Hmm. Let me reconsider. Maybe the right object is different.
# Tingley: the space of CPPs with a given boundary = V_Lambda tensor F.
# The boundary is the PROFILE c, and Lambda depends on c.
# |pi| = principal grade of V_Lambda component + |lambda|
# So F_c(q) = chi_{V_Lambda}(q) * 1/prod(1-q^i)

# For A_2^(1) at level d, the highest weight module V_{d*Lambda_1} has
# principally graded character chi(q) = sum_n dim(V_n) q^n
# = prod formula from Weyl-Kac

# If F_c(q) = chi_Lambda(q) / (q)_infty (dividing by partition function),
# then Q_n involves extracting z^n and multiplying by (zq)_infty / (1/z terms)...

# Let me try a completely different approach. Use SageMath to compute 
# one_dimensional_configuration_sum more carefully.

print("\n" + "=" * 60)
print("Testing one_dimensional_configuration_sum")
print("=" * 60)

# The X function (1d config sum) for B^{r,s} type A is known to equal
# the Demazure character for certain parameters.
# For B^{1,s}: X = sum_{b in B, cl_wt(b)=mu} q^{E(b)}
# This should give the specialized Demazure character.

# For tensor products, the config sum gives the fermionic formula.

# Let me try computing it for B^{1,4}^{tensor 2}:
K4 = crystals.KirillovReshetikhin(['A',2,1], 1, 4)
T2 = tensor([K4, K4])

R = PolynomialRing(ZZ, 'q')
q = R.gen()

# Compute by hand
energy_data = {}
for b in T2:
    wt = b.weight()
    # Classical weight = (wt[1], wt[2]) as sl_3 weight
    cl = (wt[1], wt[2])
    e = b.energy_function()
    if cl not in energy_data:
        energy_data[cl] = R(0)
    energy_data[cl] += q**e

# Show weight (2,0) which corresponds to profile (2,1,1)
# since 2*Lambda_1 = (2,0) and content (2,1,1) gives weight
# (2-1,1-1)*root_space... Actually let me reconsider.

# For sl_3, fundamental weights omega_1, omega_2.
# Content (a,b,c) gives weight (a-b)*omega_1 + (b-c)*omega_2 in sl_3 weight lattice.
# BUT in SageMath, the weight is given in terms of Lambda_0, Lambda_1, Lambda_2 (affine).
# Classical part: Lambda_1, Lambda_2 components.

# For content (2,1,1): weight = (2-1)*omega_1 + (1-1)*omega_2 = omega_1 = Lambda_1 (classical)
# So in 2-fold tensor: weight = 2*omega_1 = 2*Lambda_1
# Affine weight with Lambda_1 = 2, Lambda_2 = 0 -> classical weight (2,0)

print("Classical weight (2,0) [= 2*omega_1, profile (2,1,1) x2]:")
if (2,0) in energy_data:
    print(f"  {energy_data[(2,0)]}")
    print(f"  Evaluation at q=1: {energy_data[(2,0)](1)}")

# Profile (1,1,2) in 2-fold: weight = (1-1)*omega_1 + (1-2)*omega_2 = -omega_2
# Hmm, negative weight. That doesn't correspond to a dominant weight.
# Let me list all profiles and their sl_3 weights:
print("\nProfile -> classical sl_3 weight for d=4:")
for a in range(5):
    for b in range(5-a):
        c = 4 - a - b
        w1 = a - b  # omega_1 coefficient
        w2 = b - c  # omega_2 coefficient
        lam1 = w1  # Lambda_1 in affine
        lam2 = w2  # Lambda_2 in affine
        print(f"  ({a},{b},{c}) -> ({lam1}, {lam2})")

print(f"\nAll classical weights in tensor product data:")
for cl in sorted(energy_data.keys()):
    p = energy_data[cl]
    print(f"  cl_wt {cl}: {p}  [eval at 1: {p(1)}]")

