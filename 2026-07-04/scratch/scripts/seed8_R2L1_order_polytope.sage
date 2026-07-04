"""
Seed 8, R2L1: Order polytope interpretation of cylindric partitions.

Key idea: CPs with max <= m are order-preserving maps from a poset to {0,...,m}.
This is exactly Stanley's P-partition framework.

For the ORDER POLYTOPE O(P): |m*O(P) cap Z^d| = Omega_P(m+1) = # order-preserving maps P -> {0,...,m}.
The Ehrhart series is sum_{m>=0} Omega_P(m+1) t^{m+1} = h*(t) / (1-t)^{d+1}.
Stanley proved h* has nonneg coefficients (= descent polynomial of linear extensions of P).

For CPs: the poset is INFINITE but the generating function at fixed weight is finite.
Let me test this by constructing the truncated poset for small d.

For profile c = (c_0, c_1, c_2), the poset elements are positions (i, j) for i=0,1,2 and j >= 1.
Ordering: (i,j) covers (i, j+1) (within partition: weakly decreasing)
          (i,j) covers ((i+1)%3, j + c_{(i+1)%3}) (interlacing)

For max <= 1 (binary case): entry at (i,j) is 0 or 1. An order-preserving map.
The weight = number of 1's = number of positions labeled 1.
Since entries are weakly decreasing within each partition, if entry (i,j) = 1 then (i,j') = 1 for all j' < j.
So binary CPs are determined by "cut levels" L_0, L_1, L_2 (first 0 position in each partition).
"""
from sage.all import *

print("="*80)
print("Order Polytope interpretation")
print("="*80)

# For binary CPs (max = 1), the constraint is:
# L_i >= L_{i+1 mod 3} - c_{(i+1) mod 3} for all i (from the interlacing)
# Equivalently: L_{(i+1)%3} <= L_i + c_{(i+1)%3}
# And L_i >= 0.

# The generating function by weight (sum of L_i):
# g_1(q) = sum_{L_0,L_1,L_2 in Z_>=0, interlacing} q^{L_0+L_1+L_2} - 1
# (subtracting 1 for the empty partition at max = 0)

# For the ORDER POLYTOPE, we should think of the poset restricted to 
# some finite set of positions, and count P-partitions.

# Let me try a different approach: directly check if g_m restricted to 
# weight <= W forms the Ehrhart polynomial of some polytope.

# For profile c = (2,1,1), d = 4:
# The "binary cone" is: L_1 <= L_0 + 1, L_2 <= L_1 + 1, L_0 <= L_2 + 2, L_i >= 0
# g_1(q) = sum q^{L_0+L_1+L_2} - 1 over valid (L_0,L_1,L_2)

c = (2, 1, 1)
d = sum(c)
R = PowerSeriesRing(QQ, 'q', default_prec=100)
q = R.gen()

# Compute g_1 by enumeration
g1 = R(0)
for L0 in range(30):
    for L1 in range(min(L0 + c[1] + 1, 30)):
        for L2 in range(min(L1 + c[2] + 1, 30)):
            if L0 <= L2 + c[0]:
                w = L0 + L1 + L2
                if w < 100 and w >= 1:
                    g1 += q**w

# h_1 = (1-q) * g_1
h1 = (1 - q) * g1
h1_coeffs = [h1[i] for i in range(20)]
print(f"c = {c}")
print(f"g_1 first terms: {[g1[i] for i in range(15)]}")
print(f"h_1 = (1-q)*g_1: {h1_coeffs}")

# For the order polytope interpretation:
# The lattice point count at level w is #{(L_0,L_1,L_2) in cone, sum = w}
# = g_1[w] (the coefficient of q^w in g_1).
# This is the Ehrhart function of the 2-dimensional rational cross-section 
# P = {(L_0,L_1,L_2) in R^3_>=0 : interlacing, L_0+L_1+L_2 = 1}
# scaled by w.

# The Ehrhart POLYNOMIAL (or quasi-polynomial) for rational polytopes:
# |w*P cap Z^3 with sum = w| = E(w)

# For the cone, the cross-section at sum = 1 is a 2-dim polytope in R^3.
# Its Ehrhart quasi-polynomial tells us the lattice point count.

# Let's compute E(w) = g_1[w] and check if it's quasi-polynomial:
g1_vals = [g1[w] for w in range(30)]
print(f"\nLattice point counts: {g1_vals}")

# Check second differences:
second_diffs = [g1_vals[w+2] - 2*g1_vals[w+1] + g1_vals[w] for w in range(len(g1_vals)-2)]
print(f"Second diffs: {second_diffs}")

# Check if it's polynomial (constant second difference)
# or quasi-polynomial (periodic second difference)
print(f"\nSecond diffs from w=5: {second_diffs[5:15]}")
print(f"Constant second diff (polynomial)? {len(set(second_diffs[3:])) == 1}")
if len(set(second_diffs[3:])) <= 3:
    print(f"  Values: {set(second_diffs[3:])}")

# Fit polynomial through the data
# g_1[w] = a*w^2/2 + b*w + c_coeff for large w
# From the stable values: second_diff = a
# a = second_diffs[-1] (assuming stable)
a = second_diffs[5]  # should be stable by now
# Using w=5,6: g_1[5] = a*25/2 + b*5 + c_coeff; g_1[6] = a*36/2 + b*6 + c_coeff
# Difference: g_1[6] - g_1[5] = a*11/2 + b
# So b = (g1_vals[6] - g1_vals[5]) - 11*a/2
b = g1_vals[6] - g1_vals[5] - QQ(11)*a/2
c_coeff_val = g1_vals[5] - QQ(25)*a/2 - 5*b
print(f"\nEhrhart polynomial: E(w) = {a/2}*w^2 + {b}*w + {c_coeff_val}")
print(f"Verification: E(7) = {a*49/2 + 7*b + c_coeff_val}, actual = {g1_vals[7]}")
print(f"E(10) = {a*100/2 + 10*b + c_coeff_val}, actual = {g1_vals[10]}")

# The h*-vector of this Ehrhart series:
# Ehrhart series = sum_{w>=0} E(w) t^w = h*(t) / (1-t)^3
# h*_0 = E(0) = 1 (should be)
# h*_1 = E(1) - 3*E(0) ... actually for degree-2 Ehrhart poly:
# sum E(w) t^w = (h0 + h1*t + h2*t^2) / (1-t)^3
# E(0) = h0
# E(1) = h0 + h1 + h2 ... wait, that's for (1-t)^3 expansion.
# Actually: h0 = E(0), h1 = E(1) - 3*E(0), h2 = E(2) - 3*E(1) + 3*E(0) ... no.
# For Ehrhart series of dim-2 polytope:
# sum_{m>=0} E(m) t^m = (h0 + h1 t + h2 t^2) / (1-t)^3
# Expanding: E(m) = h0 * C(m+2,2) + h1 * C(m+1,2) + h2 * C(m,2)
# So E(0) = h0, E(1) = 3h0 + h1, E(2) = 6h0 + 3h1 + h2
# h0 = E(0)
# h1 = E(1) - 3*E(0)
# h2 = E(2) - 3*E(1) + 3*E(0)

h0 = g1_vals[0]
h1_star = g1_vals[1] - 3*g1_vals[0]
h2_star = g1_vals[2] - 3*g1_vals[1] + 3*g1_vals[0]

print(f"\nh*-vector of binary CP cone cross-section: ({h0}, {h1_star}, {h2_star})")
print(f"All nonneg: {h0 >= 0 and h1_star >= 0 and h2_star >= 0}")

# Verify: E(3) should be h0*C(5,2) + h1_star*C(4,2) + h2_star*C(3,2)
E3_check = h0 * binomial(5,2) + h1_star * binomial(4,2) + h2_star * binomial(3,2)
print(f"E(3) check: {E3_check} vs {g1_vals[3]}, match: {E3_check == g1_vals[3]}")
E5_check = h0 * binomial(7,2) + h1_star * binomial(6,2) + h2_star * binomial(5,2)
print(f"E(5) check: {E5_check} vs {g1_vals[5]}, match: {E5_check == g1_vals[5]}")

# Now the KEY connection:
# h_1 in the CP sense = (1-q) * g_1 = g_1(q) - q * g_1(q)
# In Ehrhart terms: h_1[w] = g_1[w] - g_1[w-1] = E(w) - E(w-1)
# For polynomial E(w): E(w) - E(w-1) is a polynomial of degree dim-1.
# For dim 2: E(w) - E(w-1) = a*w + (b - a/2) for quadratic E.
# This is eventually LINEAR, and its coefficients should match h_1.

# But h_1 = (1-q) * g_1 has degree 3 = [0, 3, 1, 1].
# E(w) - E(w-1) for w >= 1 should be:
# First few: E(1)-E(0) = 3-1 = 2... wait, h_1 = [0, 2, 1, 1] for the D_1^m notation.
# Actually h_1 = (q;q)_1 * g_1 = (1-q) * g_1.
# g_1[0] = 0 (no CPs with max=1 and weight 0... wait, is the empty partition counted?)

# Let me reclarify: g_m counts CPs with max EXACTLY m.
# For max exactly 1: every partition has maximum entry 1.
# Weight 0 would mean all entries are 0, but max = 1 requires at least one entry = 1.
# Wait, no: max(Lambda) = max_i lambda^(i)_1. If all entries are 0, max = 0 not 1.
# So g_1[0] = 0.
# g_1[1] = #{CPs with max = 1, weight = 1}: three such (one 1 in any of the three partitions).
# Actually, for c=(2,1,1), the CPs with max=1, weight=1 correspond to L_0+L_1+L_2=1.
# L_0=1,L_1=0,L_2=0: check L_1<=L_0+1=2 OK, L_2<=L_1+1=1 OK, L_0<=L_2+2=2 OK. Valid.
# L_0=0,L_1=1,L_2=0: L_1<=L_0+1=1 OK, L_2<=L_1+1=2 OK, L_0<=L_2+2=2 OK. Valid.
# L_0=0,L_1=0,L_2=1: L_1<=L_0+1=1 OK, L_2<=L_1+1=1 OK, L_0<=L_2+2=3 OK. Valid.
# So g_1[1] = 3. Good.

# h_1 = (1-q) * g_1:
# h_1[0] = g_1[0] = 0
# h_1[1] = g_1[1] - g_1[0] = 3
# h_1[2] = g_1[2] - g_1[1] = count(w=2) - 3
# ...

# The relationship between the CP h_m and the Ehrhart h*:
# F_{c,m} = sum_{j=0}^m g_j, so F_{c,m}(q) = sum_{j=0}^m g_j(q) is the generating function.
# This is NOT the Ehrhart polynomial applied to m.
# But F_{c,m}(q=1) IS the number of CPs with max <= m.

# More precisely: |{CPs with max <= m}| = F_{c,m}(1) = sum_{j=0}^m g_j(1)

# For ordinary plane partitions in a box:
# |{PP in a x b x c box}| = product formula (MacMahon).
# This is the Ehrhart polynomial of the Gelfand-Tsetlin polytope.

# For CPs: the analogy is that CPs with max <= m are lattice points of m * O(P)
# where O(P) is the order polytope of the cylindric poset, RESTRICTED to 
# finitely many positions.

# But the cylindric poset is infinite! So O(P) is infinite-dimensional.
# The q-weighting (by total size) lives in the generating function, not the polytope.

# KEY INSIGHT: Think of it column by column.
# A CP with max <= m in profile (c_0,c_1,c_2) can be decomposed as:
# For each "column" of the cylinder, the entries form a weakly decreasing sequence
# with interlacing constraints between columns.

# For max <= m: each column entry is in {0, 1, ..., m}.
# The constraint is that certain entries must be >= certain others.
# This IS an order-preserving map from a FINITE poset to {0, ..., m}.

# Wait -- for finitely many columns? The issue is that CPs can have
# arbitrarily many rows (arbitrarily long partitions).
# But with max <= m and weight <= w, only finitely many rows are nonzero.

# The generating function F_{c,m}(q) is exactly the q-analogue:
# F_{c,m}(q) = Omega_P(m; q) = "q-Ehrhart function" of the cylindric order polytope.

# The connection to (q;q)_m is through the STRIP DECOMPOSITION:
# g_m = F_{c,m} - F_{c,m-1} counts CPs with max exactly m.
# (q;q)_m * g_m = h_m is the "q-analogue of the Ehrhart h*-vector".

# For ORDINARY partitions in a 1×m box (a single partition with parts <= 1, max <= m):
# g_m counts partitions with max exactly m = partitions with at least one part = m.
# (q;q)_m * g_m = ? 

# Let me test with the simplest example: profile c = (1,0,0), d = 1.
# CPs of profile (1,0,0): just a single partition lambda^(0) with 1 part.
# (But k=3, so there are 3 partitions, but partitions 1 and 2 have 0 parts.)
# Actually c_1 = c_2 = 0 means partitions 1 and 2 are empty. Only partition 0 exists.
# A single partition lambda^(0) = (lambda^(0)_1, lambda^(0)_2, ...) with lambda^(0)_j >= lambda^(0)_{j+1}.
# Wait, c_0 = 1 means... the partition has at most 1 part? No, c_0 is part of the profile.
# The interlacing: lambda^(0)_j >= lambda^(1)_{j+c_1} = lambda^(1)_{j} (since c_1=0).
# But partition 1 is empty (c_1=0 means it has 0 entries? Or c_1=0 but it can still have entries?)

# I think the profile determines the interlacing shifts, not the number of parts.
# Each partition can have arbitrarily many rows.
# For c=(1,0,0), d=1: interlacing is lambda^(0)_j >= lambda^(1)_{j+0} = lambda^(1)_j,
# lambda^(1)_j >= lambda^(2)_{j+0} = lambda^(2)_j,
# lambda^(2)_j >= lambda^(0)_{j+1}.
# So lambda^(0)_j >= lambda^(1)_j >= lambda^(2)_j >= lambda^(0)_{j+1}.
# This means we have a plane partition of shape (infinity, infinity, infinity) 
# on a cylinder of circumference t = 3 + 1 = 4.

# For max <= 1: each entry is 0 or 1. The interlacing means:
# If lambda^(0)_j = 0, then lambda^(1)_j = 0, lambda^(2)_j = 0.
# So the "cut level" is the same for all three: L_0 >= L_1 >= L_2,
# and L_0 <= L_2 + 1 (from the cyclic constraint).

# For c=(1,0,0): CPs with max <= m are plane partitions on a cylinder.
# F_{c,m}(q) = 1/(q;q)_1 * something (Borodin's formula).

# Anyway, this is getting complex. Let me focus on the KEY RESULT:
# h_m >= 0 has been verified, and connect it to Ehrhart theory.

print("\n" + "="*80)
print("MAIN RESULT: h_m >= 0 conjecture (stronger than Warnaar's conjecture)")
print("="*80)
print("""
We have verified h_m = (q;q)_m * g_m >= 0 for:
  d = 1..10 (excluding d divisible by 3)
  ALL profiles for each d
  m up to 8 (d=1,2), 5 (d=7), 2 (d=10)

CONJECTURE (NEW, stronger than Warnaar):
  h_m(q) = (q;q)_m * g_m(q) has nonneg coefficients for all m >= 0,
  all profiles c with d not divisible by 3.

If true, this implies Q_n >= 0 (Warnaar's conjecture) because:
  Q_n = D_n^n where D_0^m = h_m, D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
  and h_m >= 0 is the base case.

But h_m >= 0 alone is NOT sufficient -- we also need D_k^m >= 0 for k >= 1.
The full tower condition D_k^m >= 0 for all k, m with m >= k has been verified
for d=4,7 with k,m up to 8.

EHRHART INTERPRETATION:
- g_m counts lattice points in a rational cone (the binary CP cone at level m)
- h_m = (1-q)(1-q^2)...(1-q^m) * g_m is analogous to an h*-vector
- By Stanley's theorem, h*-vectors of lattice polytopes are nonneg
- If g_m = Ehrhart series of a suitable order polytope, h_m >= 0 follows

The connection to order polytopes of posets is promising but requires
identifying the correct FINITE poset whose P-partitions are the CPs.
""")
