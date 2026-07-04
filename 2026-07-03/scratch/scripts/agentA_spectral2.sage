"""
Agent A: Transfer matrix spectral decomposition (fixed).
"""
from sage.all import *

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

d = 4
profiles = []
for a in range(d+1):
    for b in range(d+1-a):
        c_val = d - a - b
        profiles.append((a, b, c_val))

N = len(profiles)
prof_idx = {p: i for i, p in enumerate(profiles)}

# Build M at x=1 (evaluate the polynomial)
M1 = Matrix(QQ, N, N)
for idx, c in enumerate(profiles):
    I_c = {i for i in range(3) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            sign = (-1)**(size - 1)
            if cJ in prof_idx:
                j_idx = prof_idx[cJ]
                M1[idx, j_idx] += sign * 1**size  # x=1

print(f"M(1) matrix ({N}x{N}):")
print(f"Rank of (I - M(1)) = {(Matrix.identity(QQ, N) - M1).rank()}")

ker1 = (Matrix.identity(QQ, N) - M1).right_kernel()
print(f"Kernel dimension at x=1: {ker1.dimension()}")
for v in ker1.basis():
    print(f"  ker vector: {v}")

# Eigenvalues of M at x=1
# Actually, det(I - M(x)) = -(x^3 - 1) means that M(x) is NOT a numerical matrix
# but a POLYNOMIAL matrix. The eigenvalues of M (as a polynomial matrix) are
# the roots of det(M - lambda*I) = 0.
# But M(x) has entries that are polynomials in x.

# What the universal determinant tells us:
# When we evaluate at any x, det(I - M(x)) = -(x^3 - 1).
# So (I - M(x)) is always rank N-1 when x is a cube root of unity.
# For other values of x, I - M(x) is nonsingular.

# The CW system: (I - M(q^n)) * v_n = v_{n-1}
# where v_n = (F_{c,n})_{all profiles c}
# But M(q^n) changes with n!

# The key observation: the system is LINEAR but NON-AUTONOMOUS (matrix changes each step).
# However, the structure det(I - M(x)) = -(x^3-1) means:
# - For x not a cube root: I - M(x) is invertible, so v_n = (I-M(q^n))^{-1} v_{n-1}
# - As n -> inf, q^n -> 0, so M(q^n) -> M(0). 
# - M(0) encodes only the |J|=0 part... wait, the minimum |J| is 1.
#   So M(q^n) -> 0 as n -> inf (all entries have x as a factor).
#   Then I - M(0) = I, so v_n ~ v_{n-1} for large n.
#   But that means F_{c,n} stabilizes, which contradicts F_{c,n} -> infinity.

# Hmm, I think I'm confusing the CW system structure. Let me reconsider.

# Actually: F_{c,n} is the CUMULATIVE sum of g_m, which grows without bound.
# The CW recurrence is for F_c(y,q) not F_{c,n}(q).
# Let me re-derive.

# CW: F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
# Extracting [y^n]:
# g_n^c = [y^n] F_c(y,q) = sum_J (-1)^{|J|-1} q^{n|J|} * sum_{m=0}^n g_m^{c(J)}
# = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}

# So we have: g_n = M(q^n) * F_n (in vector notation)
# And F_n = F_{n-1} + g_n = F_{n-1} + M(q^n) F_n
# => (I - M(q^n)) F_n = F_{n-1}
# => F_n = (I - M(q^n))^{-1} F_{n-1}

# For q^n far from a cube root of unity: I - M(q^n) is invertible.
# The product formula: F_n = prod_{k=1}^n (I - M(q^k))^{-1} * F_0
# where F_0 = (1, 1, ..., 1) (empty CP has F = 1 for each profile).

# This is a MATRIX PRODUCT FORMULA for the bounded generating functions!
# F_n = (I - M(q^n))^{-1} (I - M(q^{n-1}))^{-1} ... (I - M(q))^{-1} * v_0

# Now Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m z^m g_m)
# This involves a specific combination of F values.

# But the matrix product formula is very suggestive!
# (I - M(q^k))^{-1} = adj(I - M(q^k)) / det(I - M(q^k))
# det(I - M(q^k)) = -(q^{3k} - 1) = (1 - q^{3k})(and maybe sign)
# So: (I - M(q^k))^{-1} = -adj(I - M(q^k)) / (q^{3k} - 1)
# = adj(I - M(q^k)) / (1 - q^{3k})

# Therefore: F_n = prod_{k=1}^n adj(I - M(q^k)) / (1 - q^{3k}) * v_0
# = [prod_{k=1}^n adj(I - M(q^k))] * v_0 / (q^3;q^3)_n

# So F_n * (q^3;q^3)_n = [prod adj terms] * v_0

# This is exactly the Kursungoz P_n!
# P_n = (q^3;q^3)_n * F_n = product of adjugate matrices times initial vector!

# And P_n >= 0 because...? The adjugate matrix has entries that are (N-1)x(N-1) 
# minors of I - M(q^k), which can have mixed signs.

# Hmm, that doesn't immediately help. But the STRUCTURE is clear:
# F_n = P_n / (q^3;q^3)_n, and the denominator comes from the determinant.

# Now Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m z^m g_m)
# The (zq;q)_inf factor removes the 1/(z;q)_inf = sum z^m/(q;q)_m part.
# So (zq;q)_inf * F_c(z,q) extracts the "non-partition" part of the GF.

# In terms of the matrix product:
# sum_m z^m g_m = sum_m z^m M(q^m) F_m
# F_m = prod_{k=1}^m (I-M(q^k))^{-1} v_0
# g_m = M(q^m) * F_m

# This is getting complex. Let me instead verify Q_2 for d=7 numerically.
print("\n" + "=" * 60)
print("Computing Q_n for d=7, c=(3,2,2)")
print("=" * 60)

PREC = 50
PR = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = PR.gen()

c = (3, 2, 2)
d = 7

# g_1
g1 = PR(0)
for s0 in range(PREC):
    for s1 in range(min(s0+c[1]+1, PREC)):
        for s2 in range(min(s1+c[2]+1, PREC)):
            if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < PREC: g1 += q**total

Q1 = (1-q)*g1 - q
coeffs_Q1 = [Q1[i] for i in range(30)]
print(f"Q_1 coeffs: {coeffs_Q1[:15]}")
print(f"Q_1(1) = {sum(coeffs_Q1)}")

# g_2 (optimized bounds)
print("Computing g_2...")
g2 = PR(0)
max_s = 12
for a0 in range(max_s):
    for a1 in range(min(a0+c[1]+1, max_s)):
        for a2 in range(min(a1+c[2]+1, max_s)):
            if a0 > a2+c[0]: continue
            for b0 in range(min(a0+1, max_s)):
                for b1 in range(min(b0+c[1]+1, a1+1, max_s)):
                    for b2 in range(min(b1+c[2]+1, a2+1, max_s)):
                        if b0 > b2+c[0]: continue
                        if max(b0,b1,b2)>=1:
                            total = a0+a1+a2+b0+b1+b2
                            if total < PREC: g2 += q**total

Q2 = (1-q)*(1-q**2)*g2 - (1-q**2)*q*g1 + q**3
coeffs_Q2 = [Q2[i] for i in range(40)]
last_nz = max([i for i in range(40) if coeffs_Q2[i] != 0], default=-1)
print(f"Q_2 coeffs: {coeffs_Q2[:last_nz+2]}")
print(f"Q_2(1) = {sum(coeffs_Q2)} (expected {11**2})")
neg2 = [i for i in range(40) if coeffs_Q2[i] < 0]
print(f"Negative: {neg2 if neg2 else 'NONE'}")

# Also check: does Q_2 have a "nice" form?
# For d=4, Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
# Is there a pattern?

print("\n" + "=" * 60)
print("Looking for multisum structure in Q_n")
print("=" * 60)

# For d=2 (k=1), Warnaar proved:
# Q_n = sum_{j>=0} q^{j^2} [n,j]_q (for a=0 case)
# Let me verify for d=2, c=(1,1,0):
c2 = (1,1,0)
g1_d2 = PR(0)
for s0 in range(PREC):
    for s1 in range(min(s0+c2[1]+1, PREC)):
        for s2 in range(min(s1+c2[2]+1, PREC)):
            if s0 <= s2+c2[0] and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < PREC: g1_d2 += q**total

Q1_d2 = (1-q)*g1_d2 - q
print(f"d=2, c=(1,1,0): Q_1 = {[Q1_d2[i] for i in range(10)]}")

# Warnaar formula: Q_1 = sum_j q^{j^2} [1,j] = q^0 [1,0] + q^1 [1,1] = 1 + q
# But Q_1(1) = 1 for d=2. Hmm, that gives 2.
# Wait, maybe the formula is Q_n = sum_{j>=0} q^{j(j+a)} [n,j] for profile-dependent a.
# For c=(1,1,0): maybe a=1? Q_1 = q^0*[1,0] + q^{1*2}*[1,1] = 1 + q^2 -> 2 at q=1.
# Still wrong. Let me check what Q_1 actually is for d=2, c=(1,1,0): it's just [0,1,0,...] = q.
# Q_1 = q, Q_1(1) = 1. So the Warnaar formula should give q.
# sum_j q^{j(j+a)} [1,j]:
# j=0: q^0 = 1
# j=1: q^{1+a}
# For a=0: 1 + q. At q=1: 2 != 1.
# For a=1: 1 + q^2. At q=1: 2 != 1.

# Hmm, the Warnaar formula must involve a different setup.
# Reading more carefully: the formula is for the RANK-2 case (2 partitions, not 3).
# For rank 3 at d=2, the formula is different.

# Actually from the chunk: "The k=1 case of Theorem_k12 is given by
# GK_{(a+1,1-a,0)}(z,q) = 1/(zq)_inf * sum_n z^n q^{n(n+a)} / (q)_n"
# This is for SPECIFIC profiles (a+1, 1-a, 0).
# For a=0: profile (1,1,0). For a=1: profile (2,0,0).

# Q_n is defined as (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# = (q;q)_n * [z^n]((zq;q)_inf * 1/(zq)_inf * sum z^n q^{n(n+a)}/(q)_n)
# = (q;q)_n * [z^n](sum z^n q^{n(n+a)}/(q)_n)
# = (q;q)_n * q^{n(n+a)} / (q)_n
# = q^{n(n+a)}

# For a=0: Q_n = q^{n^2}
# For a=1: Q_n = q^{n(n+1)} = q^{n^2+n}

# Let me verify: Q_1 for a=0 (profile (1,1,0)): Q_1 = q^1 = q. Matches!
# Q_1 for a=1 (profile (2,0,0)): Q_1 = q^2. Let me check...
c_test = (2,0,0)
g1_test = PR(0)
for s0 in range(PREC):
    for s1 in range(min(s0+0+1, PREC)):  # c1=0
        for s2 in range(min(s1+0+1, PREC)):  # c2=0
            if s0 <= s2+2 and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < PREC: g1_test += q**total
Q1_test = (1-q)*g1_test - q
print(f"d=2, c=(2,0,0): Q_1 = {[Q1_test[i] for i in range(10)]}")
# Expected: Q_1 = q^2. Let's see.

# OK so for d=2 at rank 3:
# Q_n((1,1,0)) = q^{n^2}
# Q_n((2,0,0)) = q^{n(n+1)}
# Both are MONOMIALS! Trivially nonneg.

# For d=4 (k=2), the Warnaar formula involves a double sum.
# Can I derive it from the rank-2 Proposition 8?
# GK_{(L+b+1,L)/(1-a,0)/3}(z,q) = 1/(zq)_{2L+a+b} * sum_n z^n q^{n(n+a)} [2L+b-n, n]
# This is for rank-2 shapes with d=3.
# For rank-3 at d=4, level-rank duality converts to rank-2 at d=3.
# But this only gives specific profiles.

# Let me try to compute Q_n for d=4, c=(2,1,1) using the Warnaar formula.
# From the invariance identity at rank 3:
# Phi_{n_0,m_0}(z,w;q) = manifestly positive sum
# We need to specialize z, w and choose n_0, m_0 to get the right profile.

# The profile c = (c_0, c_1, c_2) determines the shape.
# For the A_2 case with two variables z, w:
# z tracks one type of "box addition" and w tracks another.
# For profile (2,1,1): c_0=2, c_1=1, c_2=1.

# From the Warnaar rational identity (eq. A_2 rational):
# sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n][n_0-n+m,m_0] Phi_{n,m} = Phi_{n_0,m_0}
# Taking n_0 -> inf:
# sum_{n,m} z^{n-m} w^m q^{n^2-mn+m^2} [n,m] / ((q)_n * (zq)_{n-m} * (wq)_n)
# = 1 / ((zq)_inf * (wq)_inf)

# The full GF: F_c(z,q) = 1/((zq)_inf (wq)_inf) but with w = z (both track max part).
# No, that's not right either. The two variables z, w correspond to different
# things in the rank-3 case.

# Actually, looking at Warnaar more carefully:
# For A_2 with k levels of sum, the bivariate GF has z for max of lambda^0 and 
# w for max of lambda^1 (in a rank-3 CP).

# This is getting quite involved. Let me summarize what I've found and 
# report back.

print("\n" + "=" * 60)
print("FINAL VERIFICATION: Universal determinant for d=7")
print("=" * 60)

# Build M(x) for d=7
R = PolynomialRing(QQ, 'x')
x = R.gen()

d = 7
profiles7 = []
for a in range(d+1):
    for b in range(d+1-a):
        c_val = d - a - b
        profiles7.append((a, b, c_val))

N7 = len(profiles7)
prof_idx7 = {p: i for i, p in enumerate(profiles7)}

M7 = Matrix(R, N7, N7)
for idx, c in enumerate(profiles7):
    I_c = {i for i in range(3) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            sign = (-1)**(size - 1)
            if cJ in prof_idx7:
                j_idx = prof_idx7[cJ]
                M7[idx, j_idx] += sign * x**size

det7 = (Matrix.identity(R, N7) - M7).determinant()
print(f"d=7: N={N7} profiles, det(I-M(x)) = {det7}")
print(f"Matches -(x^3-1)? {det7 == -(x**3 - 1)}")

