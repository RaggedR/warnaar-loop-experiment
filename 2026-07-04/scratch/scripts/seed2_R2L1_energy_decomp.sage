# Seed 2, R2L1: Energy decomposition by profile for B^{1,4}^{tensor n}
from sage.all import *
from collections import defaultdict

R = QQ['q']
q = R.gen()

K = crystals.KirillovReshetikhin(['A',2,1], 1, 4)

def element_to_profile(b):
    tab = list(b.to_tableau())[0]
    return (tab.count(1), tab.count(2), tab.count(3))

# ============ n=1 ============
print("=" * 60)
print("n=1: B^{1,4}")
print("=" * 60)
energy_n1 = defaultdict(lambda: R(0))
for b in K:
    # For a single crystal, there's no energy function (it's 0)
    prof = element_to_profile(b)
    energy_n1[prof] += R(1)

for prof in sorted(energy_n1.keys()):
    print(f"  c={prof}: {energy_n1[prof]}")

# ============ n=2 ============
print("\n" + "=" * 60)
print("n=2: B^{1,4} tensor B^{1,4}")
print("=" * 60)

T2 = crystals.TensorProduct(K, K)

# Group by RIGHT profile (the "output" profile)
energy_by_right = defaultdict(lambda: R(0))
# Group by LEFT profile
energy_by_left = defaultdict(lambda: R(0))
# Group by pair
energy_by_pair = defaultdict(lambda: R(0))

for b in T2:
    e = b.energy_function()
    prof1 = element_to_profile(b[0])
    prof2 = element_to_profile(b[1])
    energy_by_right[prof2] += q**e
    energy_by_left[prof1] += q**e
    energy_by_pair[(prof1, prof2)] += q**e

print("\nGrouped by RIGHT factor profile (sum over left):")
for prof in sorted(energy_by_right.keys()):
    poly = energy_by_right[prof]
    print(f"  c={prof}: {poly}  [q=1: {poly(q=1)}]")

print("\nGrouped by LEFT factor profile (sum over right):")
for prof in sorted(energy_by_left.keys()):
    poly = energy_by_left[prof]
    print(f"  c={prof}: {poly}  [q=1: {poly(q=1)}]")

# ============ Compute Q_{n,c} for d=4 ============
print("\n" + "=" * 60)
print("Computing Q_{n,c}(q) for d=4 via CW recurrence")
print("=" * 60)

# We need to compute Q_{n,c}(q) for all profiles c with |c|=4
# Using the definition: Q_{n,c}(q) = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# For small n, we can compute F_{c,N} directly and use inclusion-exclusion

# Actually, let's use the iterated q-difference: Q_n = D_n^n
# where D_0^m = h_m = (q;q)_m * [z^m]F_c(z,q) - (q;q)_m * [z^{m-1}]F_c(z,q)  ... 
# Actually h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1}
# and Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

# Simpler: compute F_{c,N} for N=0,1,...,n+10
# Then Q_n = (q;q)_n * sum_{j=0}^{n} (-1)^{n-j} q^{C(n-j+1,2)} / ((q;q)_j * (q;q)_{n-j}) * F_{c,j}

# For d=4, the transfer matrix A has size 15x15
# Let me use Python to compute F_{c,N} via direct enumeration for small cases

# Actually, let me use the Borodin product formula for unbounded F_c(z,q)
# and extract coefficients.

# For now, let me compute Q_1 and Q_2 for a few profiles

# Profile (2,1,1): balanced-ish
# Profile (4,0,0): extreme
# Profile (3,1,0): asymmetric

# Direct computation: enumerate cylindric partitions
# A cylindric partition of profile c = (c_0,c_1,c_2) is 3 partitions
# (lam0, lam1, lam2) with:
# lam0_j >= lam1_{j+c_1} for all j
# lam1_j >= lam2_{j+c_2} for all j
# lam2_j >= lam0_{j+c_0} for all j
# with max entry <= n

def cylindric_partitions_bounded(c, n, max_parts=20):
    """Enumerate cylindric partitions of profile c with max entry <= n.
    Returns list of (lam0, lam1, lam2) tuples."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    
    # Each partition has parts bounded by n, and we truncate after max_parts parts
    # (since parts eventually become 0 due to interlacing)
    
    results = []
    
    # For max entry n, parts are in {0, 1, ..., n}
    # Interlacing forces parts to decrease quickly
    # Let's use recursion with memoization
    
    # Actually for small n this is tractable by direct search
    # lam_i has at most n*k parts where k relates to profile
    # but they decrease fast due to interlacing
    
    # For n small (1,2) and d=4, let's enumerate
    # Max number of nonzero parts: for max=n, after wrapping around the cylinder,
    # each step can shift by at most c_i, so parts are bounded by
    # n - (# wraps) * something
    
    # Actually, let me compute F_{c,N}(q) = sum_{Lambda: max <= N} q^|Lambda|
    # using the transfer matrix approach
    
    # The transfer matrix approach: F_{c,N} = sum over composition sequences
    # This is what Round 1 used
    pass

# Use a simpler approach: compute via power series
# F_c(z,q) has a product formula (Borodin)
# t = d + 3 = 7 for d=4

# For profile c = (c_0, c_1, c_2), compute Borodin's product
def borodin_product(c, prec=100):
    """Compute F_c(q) as a power series using Borodin's formula."""
    c0, c1, c2 = c
    d = c0 + c1 + c2
    k = 3  # number of parts
    t = d + k  # = d + 3
    
    PS = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = PS.gen()
    
    # Borodin formula is complex, let me just compute F_{c,n}(q) via
    # direct enumeration using the recurrence approach
    pass

# Let me use the functional equation approach instead
# F_c(y,q) satisfies the CW recurrence

# Actually the simplest approach for small d: compute Q_n directly
# using the matrix formulation from Agent B/C

# From synthesis: P_n(c) = (q^3;q^3)_n * F_{c,n}
# For d=4, ell = gcd(4,3) = 1, so (q^ell;q^ell)_n = (q;q)_n

# Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
#      = sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} * [n choose j]_q * F_{c,j}

# where [n choose j]_q = (q;q)_n / ((q;q)_j * (q;q)_{n-j})

# So I need F_{c,j} for j = 0, 1, ..., n

# F_{c,0} = 1 (empty partition)
# F_{c,1} = number of CPs with max <= 1, counted by size

# For max=1: each partition has parts in {0,1}
# Interlacing: lam_i is a partition with parts 0 or 1
# So lam_i = (1^{a_i}) for some a_i >= 0
# Conditions: lam0_j >= lam1_{j+c_1}: need a_0 >= a_1 + c_1 (if a_1 > 0) etc.
# Wait, lam0_j >= lam1_{j+c_1} means the j-th part of lam0 >= the (j+c_1)-th part of lam1
# If lam1 = (1^{a_1}), then lam1_{j+c_1} = 1 if j+c_1 <= a_1, else 0
# So we need lam0_j >= 1 for all j such that j+c_1 <= a_1, i.e., j <= a_1-c_1
# Since lam0 = (1^{a_0}), this means a_0 >= a_1 - c_1 (if a_1 > c_1)

# In general: a_0 >= max(0, a_1 - c_1), a_1 >= max(0, a_2 - c_2), a_2 >= max(0, a_0 - c_0)
# Size = a_0 + a_1 + a_2

# Easier: Just compute F_{c,N} using explicit enumeration for max <= N
# with parts-as-0/1 for N=1 and general parts for N=2

# For max <= 1: each lambda^(i) is (1^{a_i}) 
# Conditions become:
# a_0 >= a_1 - c_1  (take max with 0)
# a_1 >= a_2 - c_2
# a_2 >= a_0 - c_0
# All a_i >= 0

# For d=4, profile (2,1,1):
c = (2, 1, 1)
c0, c1, c2 = c
print(f"\nProfile c = {c}, d = {sum(c)}")

PS = PowerSeriesRing(QQ, 'q', default_prec=200)
qq = PS.gen()

# F_{c,1}: sum over valid (a_0, a_1, a_2) with constraints
# Parts are bounded by... actually a_i can be arbitrarily large
# No! For max=1, each partition has first part <= 1
# So a_i <= 1... wait no.
# A partition with max entry <= 1 means all parts are 0 or 1.
# lam = (1, 1, ..., 1, 0, 0, ...) = (1^a) for some a.
# There's no upper bound on a.

# So we need sum over (a_0, a_1, a_2) with a_i >= 0 and:
# a_0 >= a_1 - c_1 => a_0 >= max(0, a_1 - 1)
# a_1 >= a_2 - c_2 => a_1 >= max(0, a_2 - 1) 
# a_2 >= a_0 - c_0 => a_2 >= max(0, a_0 - 2)
# Size = a_0 + a_1 + a_2

# This is an infinite sum but converges as a power series in q
# F_{c,1}(q) = sum q^{a_0+a_1+a_2} over valid (a_0,a_1,a_2)

# Let's compute this up to high order
Fc1 = PS(0)
for a0 in range(60):
    for a1 in range(60):
        if a0 < max(0, a1 - c1):
            continue
        for a2 in range(60):
            if a1 < max(0, a2 - c2):
                continue
            if a2 < max(0, a0 - c0):
                continue
            Fc1 += qq**(a0 + a1 + a2)

print(f"F_{{c,1}}(q) = {Fc1.add_bigoh(20)}")

# For max <= 2: each partition has parts in {0,1,2}
# lam^(i) = (2^{b_i}, 1^{a_i}) with b_i >= 0, a_i >= 0
# lam^(i)_j = 2 if j <= b_i, 1 if b_i < j <= b_i + a_i, 0 if j > b_i + a_i

# Interlacing: lam0_j >= lam1_{j+c_1}
# This gets complicated. Let me use a different approach.

# Use the transfer matrix / matrix product approach from Round 1
# F_{c,n}(q) can be computed from the transfer matrix

# Actually, let me just directly compute Q_n for a few profiles using
# the product formula and coefficient extraction

# Borodin's product formula for F_c(q):
# F_c(q) = 1/((q^t;q^t)_inf) * product terms
# where t = d + 3 = 7

# For c = (c_0, c_1, c_2) = (2, 1, 1), d = 4, t = 7
# d_{i,j} = c_i + ... + c_j

# Actually this is getting complex. Let me compute Q_n using the
# bivariate generating function approach with power series.

# F_c(z,q) = sum_{N=0}^inf F_{c,N}(q) * z^N (NO! this is wrong)
# Actually F_c(z,q) = sum_{Lambda} q^{|Lambda|} z^{max(Lambda)}
# = sum_{N=0}^inf G_N * z^N where G_N = F_{c,N} - F_{c,N-1}
# Wait, from BA14: CW recurrence computes G_n = F_{c,n} - F_{c,n-1}

# Actually: F_c(y,q) = sum_{Lambda} q^|Lambda| y^{max(Lambda)}
# If we write it as sum_N F_{c,N} z^N, that's wrong
# F_c(z,q) = sum_N (F_{c,N} - F_{c,N-1}) z^N = sum_N G_N z^N

# But for Q_n: Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# = (q;q)_n * [z^n](sum_m (-1)^m q^{C(m+1,2)}/(q;q)_m z^m * sum_N G_N z^N)
# = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} / (q;q)_{n-j} * G_j

# Hmm, but this uses G_j not F_{c,j}. Let me re-derive.

# Actually from the conjecture.tex:
# Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq)_inf * GK_c(z,q))
# where GK_c(z,q) = F_c(z,q) is the bivariate GF

# (zq)_inf = (zq;q)_inf = prod_{i>=1} (1 - zq^i) -- NO
# Wait: (zq)_inf in the notation means (zq;q)_inf = prod_{i=0}^inf (1 - zq^{i+1})

# So [z^n]((zq;q)_inf * F_c(z,q))
# = [z^n](sum_m (-q)^m q^{C(m,2)}/(q;q)_m z^m * sum_N G_N z^N)
# Wait, (zq;q)_inf = sum_m (-1)^m q^{m + C(m,2)} z^m ... 
# Actually (a;q)_inf = sum_{m>=0} (-1)^m q^{C(m,2)} a^m / (q;q)_m
# So (zq;q)_inf = sum_m (-1)^m q^{C(m,2)} (zq)^m / (q;q)_m
#               = sum_m (-1)^m q^{m + C(m,2)} z^m / (q;q)_m
#               = sum_m (-1)^m q^{C(m+1,2)} z^m / (q;q)_m

# So [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} / (q;q)_{n-j} * G_j

# where G_j = [z^j] F_c(z,q) -- the coefficient of z^j in the bivariate GF

# And F_c(z,q) = sum_Lambda q^{|Lambda|} z^{max(Lambda)}
# So G_j = sum_{Lambda: max=j} q^{|Lambda|}

# But also sum_{j=0}^N G_j = F_{c,N} = sum_{Lambda: max <= N} q^{|Lambda|}
# So G_j = F_{c,j} - F_{c,j-1} with F_{c,-1} = 0

# Therefore: [z^n]((zq;q)_inf * F_c(z,q))
# = sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} / (q;q)_{n-j} * (F_{c,j} - F_{c,j-1})
# Telescoping: = sum_{j=0}^n [(-1)^{n-j} q^{C(n-j+1,2)}/(q;q)_{n-j} - (-1)^{n-j-1} q^{C(n-j,2)}/(q;q)_{n-j-1}] F_{c,j}
# Hmm this gets messy. Let me just compute G_j directly and use the formula.

# Plan: compute G_0, G_1, G_2, ... for profile (2,1,1) d=4
# G_0 = F_{c,0} = 1 (the empty CP has max=0... actually max of empty is undefined)
# Convention: F_{c,0} = 1 (just the empty partition tuple)

# Let me compute F_{c,N} for N=0,1,2 for c=(2,1,1)

# F_{c,0}: only the tuple of 3 empty partitions. Size = 0. So F_{c,0} = 1.
# G_0 = F_{c,0} - F_{c,-1} = 1 - 0 = 1

# F_{c,1}: computed above
print(f"\nF_{{c,0}} = 1")
print(f"F_{{c,1}} = {Fc1.add_bigoh(20)}")
print(f"G_1 = F_{{c,1}} - 1 = {(Fc1 - 1).add_bigoh(20)}")

# Compute Q_1:
# Q_1 = (q;q)_1 * [z^1]((zq;q)_inf * F_c(z,q))
# = (1-q) * [z^1](... G_0 * (-1)^1 q^1/(q;q)_1 z^0 ... + G_1 * 1)
# Wait, [z^1] = sum of terms with m+j=1:
# m=0, j=1: G_1 * 1 / 1 = G_1
# m=1, j=0: G_0 * (-1)^1 q^{C(2,2)} / (q;q)_1 = -q / (1-q)
# So [z^1] = G_1 - q/(1-q)

# Q_1 = (1-q) * (G_1 - q/(1-q)) = (1-q)*G_1 - q

G1 = Fc1 - 1
Q1_attempt = (1 - qq) * G1 - qq
print(f"\nQ_1 attempt = (1-q)*G_1 - q = {Q1_attempt.add_bigoh(20)}")

# This should be a polynomial. Let's see...
# G_1 = sum_{valid (a0,a1,a2)} q^{a0+a1+a2} - 1

# For Q_1 to be a polynomial, (1-q)*G_1 must equal q + polynomial
# That means G_1 = (q + poly) / (1-q) which is a power series

# Let me check: is Q_1 a polynomial?
# The issue is G_1 is an infinite series (CPs with max=1 have unbounded size)
# But Q_1 should still be a polynomial after the cancellation

# Let me verify: from the synthesis, Q_1(1) = 4 for d=4
print(f"\nQ_1 truncated to O(q^30): {Q1_attempt.add_bigoh(30)}")
# Check if coefficients stabilize
coeffs = [Q1_attempt[i] for i in range(30)]
print(f"Coefficients: {coeffs}")

