"""
Agent A: Compute Q_n directly from the definition for d=4, c=(2,1,1)
and compare with KR crystal data.
"""
from sage.all import *

R = PowerSeriesRing(QQ, 'q', default_prec=40)
q = R.gen()

# For d=4, c=(2,1,1), Borodin's product formula gives F_c(q):
# t = k + ell = 3 + 4 = 7
# F_c(q) = 1/(q^7;q^7)_infty * product terms

# The profile c=(2,1,1) has k=3, d=4, t=7
# d_{i,j} = c_i + ... + c_j

# Actually, let me use the Corteel-Welsh recurrence to compute g_m.
# For the CW recurrence, we need the shifted profiles c(J).

# Profile c = (c_0, c_1, c_2) = (2,1,1)
# I_c = {0,1,2} (all positive)
# For J subset of I_c:
# c_i(J) = c_i - 1 if i in J and (i-1) not in J
# c_i(J) = c_i + 1 if i not in J and (i-1) in J  
# c_i(J) = c_i otherwise
# (indices mod 3)

# Let me enumerate all J and compute c(J):
def shift_profile(c, J):
    """Compute the shifted profile c(J)."""
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

c = (2, 1, 1)
I_c = {i for i in range(3) if c[i] > 0}
print(f"Profile: {c}, I_c = {I_c}")

from itertools import combinations

for size in range(1, len(I_c) + 1):
    for J in combinations(I_c, size):
        J_set = set(J)
        cJ = shift_profile(c, J_set)
        print(f"  J = {J_set}: c(J) = {cJ}, |J| = {size}")

# CW recurrence:
# F_c(y,q) = sum_{J nonempty subset of I_c} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
# 
# This reduces the problem: c(J) has the same sum d but different distribution.
# Since d is preserved, this is a recurrence in the profile space at fixed d.
#
# For d=4, rank 3, the profiles are:
# (4,0,0), (3,1,0), (2,2,0), (2,1,1), (1,1,2), (0,3,1), etc.
# (plus cyclic permutations)
#
# For profiles with some c_i = 0, I_c is smaller and the recurrence is simpler.
#
# Actually, the recurrence reduces profiles with all c_i > 0 to profiles
# with some c_i = 0, which are simpler. Let me trace this.

print("\n" + "=" * 60)
print("CW recurrence tree for c=(2,1,1)")
print("=" * 60)

def trace_cw(c, depth=0):
    I_c = {i for i in range(len(c)) if c[i] > 0}
    prefix = "  " * depth
    print(f"{prefix}c = {c}, I_c = {I_c}")
    if len(I_c) <= 1:
        print(f"{prefix}  -> base case (single positive component)")
        return
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            print(f"{prefix}  J={J_set}: c(J) = {cJ}")
            if depth < 2 and min(cJ) >= 0:
                # Check if it's a genuinely different profile
                pass

trace_cw((2,1,1))

# Let me instead compute g_m numerically using a transfer matrix approach.
# For rank 3, profile (c_0, c_1, c_2), the cylindric partitions can be 
# encoded as sequences of "layers". At each layer m, we have three rows
# of the partitions at position m.

# A state at level m is (l_0, l_1, l_2) where l_i is the number of parts
# of lambda^i that are >= m. The interlacing conditions constrain transitions.

# Actually, the state is the "slice" at height m:
# s_i = #{j : lambda^i_j >= m}  for i = 0, 1, 2
# Then s_i can be any nonneg integer.

# Transitions from level m to m+1:
# s_i(m+1) <= s_i(m) (partition condition: each lambda^i is weakly decreasing)
# And the interlacing: lambda^i_j >= lambda^{i+1}_{j+c_{i+1}}
# In terms of slice counts: s_i(m) >= s_{i+1}(m) + c_{i+1} ... no wait.

# Actually the slice at height m is more complex. Let me think differently.
# 
# The transfer matrix approach: Define T as a matrix where
# T[s, s'] = q^{s_0' + s_1' + s_2'} if the transition s -> s' is valid
# where s = (s_0, s_1, s_2) are the row lengths at the current level.
#
# Wait, g_m for a FIXED profile counts CPs with max = m.
# g_m = sum_{CPs with max(Lambda) = m} q^{|Lambda|}
# |Lambda| = sum_i sum_j lambda^i_j = sum_m (s_0(m) + s_1(m) + s_2(m))
#
# The transfer matrix gives us: if at level m we have slice (s_0, s_1, s_2),
# then at level m-1 we can have slice (s_0', s_1', s_2') with s_i' >= s_i
# and s_i' satisfying the interlacing with s_{i+1 mod 3}'.
# Each such transition contributes q^{s_0' + s_1' + s_2'} to the weight.

# This is the standard approach. The transfer matrix is infinite-dimensional
# but can be truncated.

# Let me just use a direct computation approach.
# For fixed max = m, a CP of profile (2,1,1) is:
# - lambda^0 has parts in {0,...,m}, weakly decreasing
# - lambda^1 has parts in {0,...,m}, weakly decreasing  
# - lambda^2 has parts in {0,...,m}, weakly decreasing
# Subject to: lambda^0_j >= lambda^1_{j+1}, lambda^1_j >= lambda^2_{j+1},
#             lambda^2_j >= lambda^0_{j+2}

# For a partition lambda with max part <= m, it's determined by 
# (s_1, s_2, ..., s_m) where s_j = #{parts >= j}. These satisfy
# s_1 >= s_2 >= ... >= s_m >= 0.
# Actually, a partition with max part <= m and ALL parts <= m is just
# determined by its parts. The number of parts is unbounded.

# The COLUMN representation is more useful:
# A partition lambda = (parts in weakly decreasing order)
# Column lengths: c_j = #{i : lambda_i >= j}
# lambda <-> (c_1 >= c_2 >= ... >= c_m >= 0) where c_j = s_j from above

# The interlacing lambda^i_j >= lambda^{i+1}_{j + c_{i+1}} translates to:
# column-wise: for each height h, #{parts of lambda^i >= h} >= #{parts of lambda^{i+1} >= h} + c_{i+1}... 
# No wait. Let me use the direct part-based approach.

# For small m, let me enumerate directly using the CW recurrence system.
# Actually, let me just compute Q_n for d=4 using the formula directly.

# Use the Borodin product formula to get F_c(q) as infinite product,
# then extract coefficients.

print("\n" + "=" * 60)
print("Computing Q_n for d=4, c=(2,1,1) using Borodin + extraction")
print("=" * 60)

# For c = (c_0, c_1, c_2) = (2, 1, 1), k=3, d=4, t=7
# Borodin: F_c(q) = 1/(q^7;q^7)_inf * product of 1/(q^{m+d_{i+1,j}+j-i};q^t)_inf terms
# 
# d_{i,j} = c_i + c_{i+1} + ... + c_j
# d_{1,1} = c_1 = 1, d_{1,2} = c_1+c_2 = 2, d_{2,2} = c_2 = 1
# (using 0-indexed: d_{i+1,j} for i=0,j=1: d_{1,1}=c_1=1; i=0,j=2: d_{1,2}=c_1+c_2=2)
# 
# First product: prod_{i=1}^k prod_{j=i+1}^k prod_{m=1}^{c_i}
# i=1, j=2, m=1..c_1=1: term 1/(q^{m+d_{2,2}+2-1};q^7)_inf = 1/(q^{1+1+1};q^7)_inf = 1/(q^3;q^7)_inf
# ... but wait, indices in Borodin are 1-based.
# Actually let me re-index. c = (c_1,...,c_k) in Borodin's notation with k parts.
# For our profile (c_0,c_1,c_2) = (2,1,1), Borodin uses c = (c_1,c_2,c_3) = (2,1,1) with k=3.
# d_{i,j} = c_i + ... + c_j (partial sums)
# d_{1,1}=2, d_{1,2}=3, d_{1,3}=4, d_{2,2}=1, d_{2,3}=2, d_{3,3}=1

# First product (i < j): prod_{i=1}^3 prod_{j=i+1}^3 prod_{m=1}^{c_i}
# i=1, j=2: m=1..2, factor 1/(q^{m+d_{2,2}+j-i}; q^7)_inf = 1/(q^{m+1+1};q^7)_inf
#   m=1: 1/(q^3; q^7)_inf
#   m=2: 1/(q^4; q^7)_inf
# i=1, j=3: m=1..2, factor 1/(q^{m+d_{2,3}+3-1}; q^7)_inf = 1/(q^{m+2+2};q^7)_inf
#   m=1: 1/(q^5; q^7)_inf
#   m=2: 1/(q^6; q^7)_inf
# i=2, j=3: m=1..1, factor 1/(q^{m+d_{3,3}+3-2}; q^7)_inf = 1/(q^{m+1+1};q^7)_inf
#   m=1: 1/(q^3; q^7)_inf  (duplicate factor!)

# Hmm wait, 1/(q^3;q^7)_inf appears twice. Let me re-check.
# i=2,j=3: m=1..c_2=1, 1/(q^{m + d_{i+1,j} + j - i};q^t)_inf
# = 1/(q^{1 + d_{3,3} + 1};q^7)_inf = 1/(q^{1+1+1};q^7)_inf = 1/(q^3;q^7)_inf
# Yes, same factor. So we get 1/(q^3;q^7)_inf^2 * 1/(q^4;q^7)_inf * 1/(q^5;q^7)_inf * 1/(q^6;q^7)_inf

# Second product (i > j, "backward wrapping"):
# prod_{i=2}^k prod_{j=2}^{i-1} prod_{m=1}^{c_i}
# This product is empty for k=3 when we check:
# i=2: j=2..1 (empty)
# i=3: j=2..2, m=1..c_3=1, factor 1/(q^{t-(m+d_{j,i-1}+i-j)}; q^t)_inf
#   = 1/(q^{7-(1+d_{2,2}+3-2)};q^7)_inf = 1/(q^{7-(1+1+1)};q^7)_inf = 1/(q^4;q^7)_inf

# So total:
# F_c(q) = 1/(q^7;q^7)_inf * 1/(q^3;q^7)_inf^2 * 1/(q^4;q^7)_inf^2 * 1/(q^5;q^7)_inf * 1/(q^6;q^7)_inf

# Let me verify: total number of factors (excluding (q^t;q^t)):
# 2 (from q^3) + 2 (from q^4) + 1 (from q^5) + 1 (from q^6) = 6
# Should be sum_{i<j} c_i + sum backward terms = (2+2+1) + 1 = 6. Checks out.

# F_c(q) as a power series:
PREC = 40
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qpoch_inv(a, p, prec=PREC):
    """1/(a; p)_infinity as power series."""
    result = R(1)
    power = a
    for i in range(prec):
        result *= 1/(1 - power)
        power *= p
        if power.valuation() >= prec:
            break
    return result

# More carefully: 1/(q^a; q^t)_inf = prod_{j>=0} 1/(1 - q^{a+j*t})
def infinite_product_inv(a, t, prec=PREC):
    """Compute 1/(q^a; q^t)_infinity to given precision."""
    result = R(1)
    for j in range(prec):
        exp = a + j*t
        if exp >= prec:
            break
        result /= (1 - q**exp)
    return result

F_c = infinite_product_inv(7, 7) * infinite_product_inv(3, 7)**2 * \
      infinite_product_inv(4, 7)**2 * infinite_product_inv(5, 7) * \
      infinite_product_inv(6, 7)

print(f"F_c(q) = {F_c}")

# Now compute F_c(z,q) = sum_m z^m g_m(q)
# where g_m(q) = [y^m] F_c(y,q) = sum_{CPs with max=m} q^{|CP|}
# We can get these from F_c(q) and the bounded versions.

# Actually, g_0 = 1 (empty CP) and 
# F_c(q) = sum_{m>=0} g_m(q)

# To get individual g_m, we need the bivariate generating function.
# The CW recurrence gives us F_c(y,q) as a function of y.

# For simplicity, let me compute Q_n directly from the known formula.
# From Warnaar 2023, for d=4 (k=2 in his notation), the explicit formula 
# for Q_n is known.

# Actually, let me compute Q_1 and Q_2 directly.
# Q_n(q) = (q;q)_n * [z^n]((zq;q)_infty * sum_m z^m g_m(q))
# = (q;q)_n * sum_{j=0}^n g_j(q) * (-1)^{n-j} * q^{(n-j)(n-j+1)/2} / (q;q)_{n-j}

# For this we need g_0, g_1, ..., g_n.
# These can be extracted from the Corteel-Welsh recurrence.

# Let me use the TRANSFER MATRIX approach to compute g_m.
# The transfer matrix A encodes transitions between "column states".
# For profile c = (c_0, c_1, c_2) = (2,1,1), the column state at height m
# is (a_0, a_1, a_2) where a_i = #{parts of lambda^i that are >= m}.

# The interlacing condition lambda^i_j >= lambda^{i+1}_{j+c_{i+1}} means:
# If lambda^i has a_i parts >= m and lambda^{i+1} has a_{i+1} parts >= m,
# then a_i >= a_{i+1} + c_{i+1} (is this right? only at the boundary where
# part equals exactly m-1 vs m)

# Actually no. The interlacing says lambda^0_j >= lambda^1_{j+c_1} for all j.
# In the column picture, this means that the column of height m in position j
# of lambda^0 dominates the column of height m in position j+c_1 of lambda^1.
# So #{parts of lambda^0 >= m} >= #{parts of lambda^1 >= m} + c_1 ... wait,
# that's also not right in general.

# The relationship between row and column interlacing is subtle.
# Let me just enumerate g_m for small m using direct computation.

# g_0 = 1 (only the empty CP has max = 0)
# g_1: CPs with max = 1, i.e., all parts are 0 or 1.
# lambda^i = (1^{a_i}, 0, 0, ...) for some a_i >= 0
# Interlacing: lambda^0_j >= lambda^1_{j+1} means:
#   for j=1: if a_0 >= 1 then lambda^0_1 = 1 >= lambda^1_2 (need a_1 >= 2 for this to be 1, so ok if a_1 < 2)
#   Actually: lambda^0_j = 1 if j <= a_0, else 0.
#   lambda^1_{j+1} = 1 if j+1 <= a_1, else 0.
#   So lambda^0_j >= lambda^1_{j+1} requires: if j+1 <= a_1 (so lambda^1_{j+1}=1), then j <= a_0.
#   i.e., a_1 - 1 <= a_0, i.e., a_1 <= a_0 + 1.
# Wait actually c_1 = 1 here. lambda^0_j >= lambda^1_{j+c_1} = lambda^1_{j+1}.
# So for all j >= 1: if lambda^1_{j+1} = 1 then lambda^0_j = 1.
# lambda^1_{j+1} = 1 iff j+1 <= a_1, i.e., j <= a_1 - 1.
# So need a_0 >= a_1 - 1, i.e., a_1 <= a_0 + 1.

# Similarly: lambda^1_j >= lambda^2_{j+c_2} = lambda^2_{j+1}: a_2 <= a_1 + 1
# lambda^2_j >= lambda^0_{j+c_0} = lambda^0_{j+2}: 
#   lambda^0_{j+2} = 1 iff j+2 <= a_0, i.e., j <= a_0 - 2.
#   Need: if j <= a_0 - 2 then j <= a_2 - 1, i.e., a_2 >= a_0 - 1.

# Hmm wait, I had c = (c_0, c_1, c_2) = (2,1,1). But which interlacing?
# The definition says: lambda^i_j >= lambda^{i+1}_{j + c_{i+1}}
# So:
# i=0: lambda^0_j >= lambda^1_{j + c_1} = lambda^1_{j+1}
# i=1: lambda^1_j >= lambda^2_{j + c_2} = lambda^2_{j+1}
# i=2 (cyclic, wraps to i=0): lambda^2_j >= lambda^0_{j + c_0} = lambda^0_{j+2}

# For max=1 partitions:
# (1) a_1 <= a_0 + 1  (from i=0 condition)
# (2) a_2 <= a_1 + 1  (from i=1 condition)  
# (3) a_0 <= a_2 + 2  (from i=2 condition, c_0=2: need lambda^2_j >= lambda^0_{j+2})
#    lambda^0_{j+2} = 1 iff j <= a_0 - 2. Need a_2 >= a_0 - 2, i.e., a_0 <= a_2 + 2.

# Wait, but I also need the max to be EXACTLY 1, meaning max(a_0, a_1, a_2) >= 1.

# And size = a_0 + a_1 + a_2.

# g_1 = sum_{(a_0,a_1,a_2) satisfying constraints, max >= 1} q^{a_0+a_1+a_2}

# The constraints are: a_1 <= a_0+1, a_2 <= a_1+1, a_0 <= a_2+2
# All a_i >= 0.

# These define an infinite cone (a_0 can be arbitrarily large).
# g_1 is a power series.

# Let me compute the first few terms:
g1_terms = {}
for a0 in range(PREC):
    for a1 in range(min(a0+2, PREC)):
        for a2 in range(min(a1+2, PREC)):
            if a0 <= a2 + 2:
                if max(a0, a1, a2) >= 1:
                    s = a0 + a1 + a2
                    if s < PREC:
                        g1_terms[s] = g1_terms.get(s, 0) + 1

g1 = R(0)
for s, count in g1_terms.items():
    g1 += count * q**s

print(f"\ng_1(q) = {g1}")
print(f"g_1(1) first few coefficients sum... (infinite series)")

# Similarly compute g_2
# For max = 2: lambda^i has parts from {0,1,2}, weakly decreasing.
# lambda^i is determined by (a_i, b_i) where a_i = #{parts >= 1}, b_i = #{parts >= 2}
# with b_i <= a_i.
# lambda^i_j = 2 if j <= b_i, 1 if b_i < j <= a_i, 0 if j > a_i.

# Interlacing lambda^0_j >= lambda^1_{j+1}:
# For each j >= 1:
#   If lambda^1_{j+1} = 2 (j+1 <= b_1, j <= b_1-1): need lambda^0_j >= 2, so j <= b_0.
#   Thus b_1 - 1 <= b_0, i.e., b_1 <= b_0 + 1.
#   If lambda^1_{j+1} = 1 (b_1 < j+1 <= a_1, b_1 <= j <= a_1-1): need lambda^0_j >= 1, so j <= a_0.
#   Thus a_1 - 1 <= a_0, i.e., a_1 <= a_0 + 1.

# lambda^1_j >= lambda^2_{j+1}: b_2 <= b_1 + 1, a_2 <= a_1 + 1
# lambda^2_j >= lambda^0_{j+2}: b_0 <= b_2 + 2, a_0 <= a_2 + 2

# Size = sum_i (a_i + b_i) = sum(a) + sum(b)
# Max = 2 requires at least one b_i >= 1.

g2_terms = {}
for a0 in range(PREC // 2):
    for a1 in range(min(a0+2, PREC // 2)):
        for a2 in range(min(a1+2, PREC // 2)):
            if a0 <= a2 + 2:
                for b0 in range(a0+1):
                    for b1 in range(min(b0+2, a1+1)):
                        for b2 in range(min(b1+2, a2+1)):
                            if b0 <= b2 + 2:
                                if max(b0, b1, b2) >= 1:
                                    s = a0 + a1 + a2 + b0 + b1 + b2
                                    if s < PREC:
                                        g2_terms[s] = g2_terms.get(s, 0) + 1

g2 = R(0)
for s, count in g2_terms.items():
    g2 += count * q**s

print(f"\ng_2(q) = {g2}")

# Now compute Q_1 and Q_2
# Q_n = (q;q)_n * sum_{j=0}^n g_j * (-1)^{n-j} * q^{(n-j)(n-j+1)/2} / (q;q)_{n-j}

# q-Pochhammer
def qpoch(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

g0 = R(1)

# Q_1 = (1-q) * [g_1 * 1 + g_0 * (-q) / (1-q)]
# = (1-q) * g_1 + (-q) * g_0
# = (1-q) * g_1 - q
Q1 = qpoch(1) * (g1 * 1 + g0 * (-1) * q / qpoch(1))
print(f"\nQ_1(q) = {Q1}")
print(f"Q_1(1) should be 4")

# For evaluation at q=1, coefficients should sum to 4
coeffs = list(Q1)[:30]
print(f"Sum of first 30 coefficients: {sum(coeffs)}")
print(f"Coefficients: {coeffs[:15]}")

# Q_2 = (q;q)_2 * [g_2 + g_1 * (-q)/(1-q) + g_0 * q^3 / ((1-q)(1-q^2))]
# = (1-q)(1-q^2) * [g_2 - g_1 * q/(1-q) + g_0 * q^3/((1-q)(1-q^2))]
Q2 = qpoch(2) * (g2 * 1 + g1 * (-1) * q / qpoch(1) + g0 * 1 * q**3 / qpoch(2))
print(f"\nQ_2(q) = {Q2}")
coeffs2 = list(Q2)[:30]
print(f"Sum of first 30 coefficients: {sum(coeffs2)}")
print(f"Q_2(1) should be 16")
print(f"Coefficients: {coeffs2[:20]}")

# Now let's compare Q_1 and Q_2 with the KR tensor product data.
# KR tensor product B^{1,4}^{tensor 2} at weight (2,0) gave:
# q^4 + 2q^3 + 3q^2 + 2q + 1
# This evaluates to 9.

# Is there a relationship between Q_2 and this?
# Q_2(1) = 16, KR gives 9. 
# Q_1(1) = 4. 
# F_{c,2}(1) = sum_{m=0}^2 g_m(1) which diverges.

# Hmm. The bounded GF F_{c,n}(q) itself is a power series, not a polynomial.
# Q_n extracts the polynomial part via the (zq;q)_inf factor.

# Could the KR crystal correspond to a DIFFERENT quantity?
# Note: 9 = binom(4+2, 2) - binom(4, 2) = 15 - 6 = 9? No.
# 9 = 3^2. Hmm. 
# The weight space of (B^{1,4})^{tensor 2} at weight 2*omega_1 
# should have dimension = # of ways to write 2*omega_1 as sum of 
# two weights from B^{1,4}.
# Weight omega_1 in B^{1,4} corresponds to content (2,1,1).
# So we need two tableaux each with content (2,1,1), giving 
# 1 * 1 = 1 configuration at energy 0... wait, there are multiple
# configurations because the order matters. How many tableaux in B^{1,4}
# have weight omega_1? From the data: weight (1,0) has multiplicity 1
# (element [[1,1,2,3]]). So there's only 1 such element, and 
# (1,0) + (1,0) = (2,0) has 1^2 = 1 at energy = 2*0 = 0.
# But the actual polynomial has 9 terms. So other pairs contribute too.

# Content pairs summing to (2,0):
# (a1,a2) + (b1,b2) = (2,0) where (a1,a2) and (b1,b2) are in the weight set.
# Weight (2,0) in B^{1,4}: content (2,1,1)... wait, (2,0) means 
# 2*Lambda_1 + 0*Lambda_2 in sl_3. Content (a,b,c) maps to 
# w = (a-b)*omega_1 + (b-c)*omega_2 = (a-b, b-c).
# So (2,0) means a-b=2, b-c=0, a+b+c=4. So a=3, b=1, c=1 -> (3,1,0)?
# Wait: (a,b,c) = (3,1,0): w = (3-1, 1-0) = (2, 1). That's (2,1) not (2,0).
# Let me recheck: content (4,0,0) -> (4,0), (3,1,0) -> (2,1), (2,2,0) -> (0,2),
# (2,1,1) -> (1,0), (1,2,1) -> (-1,1), etc.

# So for tensor product weight (2,0), pairs that contribute:
# (1,0) + (1,0) = (2,0): [[1,1,2,3]] x [[1,1,2,3]]
# (2,1) + (0,-1) = (2,0): [[1,1,1,2]] x [[1,2,2,3]]
# (-1,1) + (3,-1) = (2,0): [[1,2,2,3]] x [[1,1,1,3]]  Wait, (3,-1) isn't right.
# Let me just list all pairs:
# Need (w1_a, w2_a) + (w1_b, w2_b) = (2, 0)

all_weights_B14 = {
    (4,0): '1111', (2,1): '1112', (0,2): '1122', (-2,3): '1222', (-4,4): '2222',
    (3,-1): '1113', (1,0): '1123', (-1,1): '1223', (-3,2): '2223',
    (2,-2): '1133', (0,-1): '1233', (-2,0): '2233',
    (1,-3): '1333', (-1,-2): '2333',
    (0,-4): '3333'
}

print("\nPairs summing to classical weight (2,0):")
for (w1a, w2a), ta in all_weights_B14.items():
    w1b = 2 - w1a
    w2b = 0 - w2a
    if (w1b, w2b) in all_weights_B14:
        print(f"  ({w1a},{w2a}) + ({w1b},{w2b}): {ta} x {all_weights_B14[(w1b,w2b)]}")

