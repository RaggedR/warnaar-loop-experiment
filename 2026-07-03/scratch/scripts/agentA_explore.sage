"""
Agent A: Explore the relationship between KR crystals and Q_n more carefully.

Key insight from Tingley: cylindric plane partitions of profile c parametrize
V_Lambda tensor F, where Lambda depends on c. The SIZE of a CPP equals
principal grade + partition size.

For A_2^(1) at level d=4, profile c=(2,1,1):
The highest weight Lambda = ? 
Tingley works with sl_n, n = circumference of cylinder = k + d = 3 + 4 = 7.
So we should use sl_7-hat, not sl_3-hat!

This is a crucial point: the cylindric partition has circumference t = k + d,
so the relevant affine algebra is sl_t, not sl_k.
"""
from sage.all import *

# Tingley uses sl_n-hat where n = circumference = k + d
# For profile c = (c_0, c_1, c_2) with k=3, d=4, t=7:
# The crystal should be for sl_7-hat.

# But the KR crystal B^{1,d} for sl_3-hat is what previous agents used.
# These are DIFFERENT algebras!

# Let me reconsider. Warnaar's paper uses rank r=3 (the number of partitions
# in the cylindric partition), while t = r + d is the modulus.
# The Rogers-Ramanujan identities for A_2 involve modulus t = d + 3.

# The connection:
# - Borodin's product formula involves (q^t; q^t)_inf factors
# - The Andrews-Schilling-Warnaar identity involves sl_3 at level (d+3)/3...
#   wait, for A_2 RR identities, the level is related to d.

# Let me look at this differently.
# Previous agents used sl_3-hat because the profile has 3 components.
# But Tingley's paper uses sl_n-hat where n = circumference.
# These are connected by level-rank duality:
# sl_r-hat at level d <-> sl_d-hat at level r (roughly)

# For our problem: sl_3-hat at level d=4 <-> A_6^(1) at level 3
# (since t = r + d = 7, and level-rank uses sl_t)

# But previous agents already tried level-rank duality and found no match.
# Let me instead focus on the fermionic formula / RSOS-type approach.

# Actually, the more productive direction is:
# Can we prove h_m >= 0 for m >= 2 using the structure of g_m?

# From the computation above:
# g_1 = 3q + 4q^2 + 5q^3 + 5q^4 + ... (stabilizes at 5)
# h_1 = (1-q) * g_1 = 3q + q^2 + q^3 + 0 + 0 + ... 
# Q_1 = h_1 - q = 2q + q^2 + q^3

# For g_2:
# g_2 = 3q^2 + 7q^3 + 15q^4 + 22q^5 + 33q^6 + 42q^7 + 55q^8 + 65q^9 + 79q^10 + 89q^11 + ...
# The coefficients eventually grow linearly (like (d+1)(d+2)/6 * w + const)

# h_2 = (1-q)(1-q^2) * g_2 = (1 - q - q^2 + q^3) * g_2
# Let's compute h_2 explicitly:

R = PowerSeriesRing(QQ, 'q', default_prec=50)
q = R.gen()

# g_2 coefficients from direct enumeration (using agentA_qn_compute results)
# Re-enumerate more carefully
g2_coeffs = {}
PREC = 50
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
                                        g2_coeffs[s] = g2_coeffs.get(s, 0) + 1

g2 = R(0)
for s, count in g2_coeffs.items():
    g2 += count * q**s

h2 = (1 - q) * (1 - q**2) * g2
print("h_2(q) =", h2)

coeffs_h2 = [h2[i] for i in range(30)]
print("h_2 coefficients:", coeffs_h2)
print("All nonneg?", all(c >= 0 for c in coeffs_h2))

# Also compute h_3 = (1-q)(1-q^2)(1-q^3) * g_3
# But g_3 requires enumeration with max=3 parts (0,1,2,3), which has 
# 3 levels of nesting. Let me check if the pattern continues.

# More importantly: let me verify the KEY formula
# Q_n = sum_{k=0}^{n-1} sum_m D_k^m (from the D_k^m tower)
# where h_m = D_0^m is the base case.
# D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}

# For n=2: Q_2 = D_0^1 + D_0^2 + D_1^1 + D_1^2 ... no, let me re-read
# the tower structure from previous agents.

# Actually from the synthesis: Q_n = (q;q)_n * [z^n] ((zq;q)_inf * F_c(z,q))
# And the D_k^m tower decomposes this.
# D_k^m is defined recursively. Let me just compute Q_2 = h_2 directly.
# Wait, Q_2 = (q;q)_2 * [z^2] stuff, which I already computed.

# Let me verify: Q_2 from the previous script was 
# q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
# Let's recompute more carefully

g1_coeffs = {}
for a0 in range(PREC):
    for a1 in range(min(a0+2, PREC)):
        for a2 in range(min(a1+2, PREC)):
            if a0 <= a2 + 2:
                if max(a0, a1, a2) >= 1:
                    s = a0 + a1 + a2
                    if s < PREC:
                        g1_coeffs[s] = g1_coeffs.get(s, 0) + 1

g1 = R(0)
for s, count in g1_coeffs.items():
    g1 += count * q**s
g0 = R(1)

# (zq;q)_inf coefficients in z:
# c_m = (-1)^m * q^{m(m+1)/2} / (q;q)_m
# [z^n] ((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n g_j * c_{n-j}

def qpoch_poly(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

# Q_2 = (q;q)_2 * sum_{j=0}^2 g_j * (-1)^{2-j} q^{(2-j)(3-j)/2} / (q;q)_{2-j}
Q2 = qpoch_poly(2) * (
    g2 * 1 * q**0 / qpoch_poly(0) +      # j=2: (-1)^0 q^0 / 1
    g1 * (-1) * q**1 / qpoch_poly(1) +     # j=1: (-1)^1 q^1 / (1-q)
    g0 * 1 * q**3 / qpoch_poly(2)          # j=0: (-1)^2 q^3 / (1-q)(1-q^2)
)
print("\nQ_2(q) =", Q2)
coeffs_Q2 = [Q2[i] for i in range(25)]
print("Q_2 coefficients:", coeffs_Q2)
print("Q_2(1) =", sum(coeffs_Q2))
print("All nonneg?", all(c >= 0 for c in coeffs_Q2))

# Now the key question: what is h_m in the D_k^m tower?
# From the synthesis, the D_k^m tower decomposes Q_n as:
# Let g_m = [y^m] F_c(y,q) (g-coefficients)
# h_m = (q;q)_m * g_m (the "filtered" version)
# D_0^m = h_m
# D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}

# Wait no: that's not what the synthesis says exactly. Let me re-derive.
# Q_n = (q;q)_n * sum_{j=0}^n g_j * (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j}

# Let me define h_m via: Q_n = sum_m a_{n,m} h_m for some triangular change of basis.
# Actually from the synthesis:
# "h_m = (q;q)_m * g_m" is used in the injection lemma context.
# And "h_1 >= 0 follows from g_1 monotone" (injection lemma).

# But this notation is from the agents, not from a standard reference.
# Let me define things from scratch.

# From the conjecture definition:
# Q_{n,c}(q) = (q^ell; q^ell)_n * [z^n] ((zq)_inf * GK_c(z,q))
# For r=3, ell = gcd(d, 3). For d=4, ell = gcd(4,3) = 1.
# So Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

# (zq;q)_inf * F_c(z,q) = (zq;q)_inf * sum_m z^m g_m
# = sum_m z^m g_m * sum_j z^j (-1)^j q^{j(j+1)/2} / (q;q)_j
# [z^n] = sum_{m=0}^n g_m * (-1)^{n-m} q^{(n-m)(n-m+1)/2} / (q;q)_{n-m}

# Q_n = (q;q)_n * sum_{m=0}^n g_m * (-1)^{n-m} q^{(n-m)(n-m+1)/2} / (q;q)_{n-m}
# = sum_{m=0}^n g_m * (-1)^{n-m} q^{(n-m)(n-m+1)/2} * qbinom(n, m)
# where qbinom(n, m) = (q;q)_n / ((q;q)_m * (q;q)_{n-m})

# So Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} * qbinom(n,m) * g_m

# This is a q-binomial transform with alternating signs!
# For n=1: Q_1 = -q * g_0 + g_1 * qbinom(1,1) = g_1 - q
# Hmm wait: qbinom(1,1) = 1, and (-1)^0 q^0 = 1. 
# Also (-1)^1 q^1 * qbinom(1,0) * g_0 = -q * 1 * 1 = -q. So Q_1 = g_1 - q. Yes.

# For n=2: 
# Q_2 = q^3 * qbinom(2,0) * g_0 - q * qbinom(2,1) * g_1 + qbinom(2,2) * g_2
# = q^3 - q * (1+q) * g_1 + g_2

# Let me verify
Q2_check = q**3 - q * (1+q) * g1 + g2
print("\nQ_2 check:", Q2_check)
print("Matches?", Q2_check == Q2)

# Now the key insight from the D_k^m tower:
# Define D_k^m recursively:
# D_0^m = h_m = some quantity related to g_m
# But what IS h_m exactly?

# From the synthesis context, the "tower" works as follows:
# Write Q_n using the q-binomial transform and then decompose by
# splitting g_m into differences.

# Actually, let me try a different angle: compute Q_n for several profiles
# and look for patterns in the coefficients.

print("\n" + "=" * 60)
print("Q_1 for all profiles with d=4")
print("=" * 60)

def compute_g1(c):
    """Compute g_1 for profile c as power series."""
    R = PowerSeriesRing(QQ, 'q', default_prec=30)
    q = R.gen()
    k = len(c)
    # c = (c_0, c_1, c_2) with k=3
    # CPs with max=1: lambda^i = (1^{a_i})
    # Interlacing: a_{i+1} <= a_i + c_{i+1 mod k}... wait
    # lambda^i_j >= lambda^{i+1}_{j + c_{i+1}}
    # For max=1: a_{i+1} - c_{i+1} <= a_i... 
    # Actually: lambda^{i+1}_{j+c_{i+1}} = 1 iff j + c_{i+1} <= a_{i+1}, 
    #   i.e., j <= a_{i+1} - c_{i+1}
    # Need lambda^i_j >= 1 for all such j, i.e., a_i >= a_{i+1} - c_{i+1}
    # So: a_i + c_{i+1} >= a_{i+1} for all i (mod k)
    
    # For k=3: a_0 + c_1 >= a_1, a_1 + c_2 >= a_2, a_2 + c_0 >= a_0
    # i.e., a_1 <= a_0 + c_1, a_2 <= a_1 + c_2, a_0 <= a_2 + c_0
    
    result = R(0)
    for a0 in range(30):
        for a1 in range(min(a0 + c[1] + 1, 30)):
            for a2 in range(min(a1 + c[2] + 1, 30)):
                if a0 <= a2 + c[0]:
                    if max(a0, a1, a2) >= 1:
                        s = a0 + a1 + a2
                        if s < 30:
                            result += q**s
    return result

# All profiles with d=4:
profiles_d4 = [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,0,2), (0,2,2),
               (2,1,1), (1,2,1), (1,1,2), (1,3,0), (0,4,0), (0,0,4),
               (0,3,1), (0,1,3), (1,0,3)]
# Remove duplicates (cyclic equivalence):
# (4,0,0) ~ (0,4,0) ~ (0,0,4)
# (3,1,0) ~ (1,0,3) ~ (0,3,1) 
# (3,0,1) ~ (0,1,3) ~ (1,3,0)  wait, (1,3,0) is a cyclic shift of (3,0,1)? No.
# Cyclic: (c_0,c_1,c_2) ~ (c_1,c_2,c_0) ~ (c_2,c_0,c_1)
# So (3,1,0) ~ (1,0,3) ~ (0,3,1)
# And (3,0,1) ~ (0,1,3) ~ (1,3,0)

# Representative profiles:
rep_profiles = [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,1,1)]

for c in rep_profiles:
    g1 = compute_g1(c)
    Q1 = g1 - q
    coeffs = [Q1[i] for i in range(15)]
    print(f"c={c}: Q_1 = {Q1}, coeffs={coeffs[:10]}, Q_1(1)={sum(coeffs)}")
    # Check positivity
    neg = [i for i in range(15) if Q1[i] < 0]
    if neg:
        print(f"  NEGATIVE at positions: {neg}")
    else:
        print(f"  All nonneg!")

# Now try d=7
print("\n" + "=" * 60)
print("Q_1 for representative profiles with d=7")
print("=" * 60)

rep_profiles_d7 = [(7,0,0), (5,1,1), (4,2,1), (3,3,1), (3,2,2)]

R = PowerSeriesRing(QQ, 'q', default_prec=30)
q = R.gen()

for c in rep_profiles_d7:
    g1 = compute_g1(c)
    Q1 = g1 - q
    coeffs = [Q1[i] for i in range(20)]
    val = sum(coeffs)
    expected = (7+1)*(7+2)//6 - 1  # = 11
    print(f"c={c}: Q_1(1)={val} (expected {expected}), coeffs[:15]={coeffs[:15]}")
    neg = [i for i in range(20) if Q1[i] < 0]
    if neg:
        print(f"  NEGATIVE at positions: {neg}")
    else:
        print(f"  All nonneg!")

