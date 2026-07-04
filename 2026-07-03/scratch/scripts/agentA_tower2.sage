"""
Agent A: Correct tower analysis.

Key insight: Q_n = D_n^n where D_k^m = sum_{j=0}^k (-1)^j q^{T_j} [k,j]_q g_{m-j}
and this is a POWER SERIES. Q_n = D_n^n is finite (polynomial) only because 
the cancellation is exact after enough terms.

But the synthesis says "h_m = (q;q)_m * g_m" and "D_k^m >= 0 verified for 87+ entries".
These D_k^m must be POLYNOMIALS. So they must be using a different definition.

Let me re-read the synthesis more carefully. The synthesis says:
"D_k^m >= 0 verified for d=4 (k,m <= 8, 36 entries)"
And "D_k^m computations require precision >= 6*max(k,m)^2 + 50"
The precision comment suggests they're working with power series to some precision.

But also: "D_k^m decompose into GL_3 key polynomials" (Seed 2)
So D_k^m ARE polynomials! How?

Answer: The D_k^m from the synthesis are probably defined differently.
Maybe with a DIFFERENT base case, like:
D_0^m = h_m = (q;q)_m * g_m (which IS a polynomial, though it can be negative)
Then D_k^m = D_{k-1}^m - q^{m+k} D_{k-1}^{m-1} (or similar)

Wait - if h_m = (q;q)_m * g_m then it's a polynomial (I verified this above).
But h_m has negatives for m >= 2. The tower then adjusts these.

Actually, let me re-think. I'll define:
h_m = (q;q)_m * g_m  (this IS a polynomial)
And the recurrence: 
D_k^m = D_{k-1}^m - q^{something} * D_{k-1}^{m-1}
with D_0^m = h_m

Let me figure out the correct recurrence from the Q_n formula.
"""
from sage.all import *

PREC = 80
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm(c, m, prec=PREC):
    k = len(c)
    result = R(0)
    if m == 0: return R(1)
    max_s = min(prec // (m*k), 25)
    
    if m == 1:
        for s0 in range(max_s):
            for s1 in range(min(s0+c[1]+1, max_s)):
                for s2 in range(min(s1+c[2]+1, max_s)):
                    if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                        total = s0+s1+s2
                        if total < prec: result += q**total
        return result
    if m == 2:
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
                                    if total < prec: result += q**total
        return result
    return None

def qpoch(m, prec=PREC):
    result = R(1)
    for i in range(1, m+1): result *= (1 - q**i)
    return result

# Profile c=(2,1,1), d=4
c = (2,1,1)

g = {}
h = {}
for m in range(3):
    gm = compute_gm(c, m)
    g[m] = gm
    hm = qpoch(m) * gm
    h[m] = hm
    coeffs = [hm[i] for i in range(25)]
    print(f"h_{m} = (q;q)_{m} * g_{m}: {coeffs}")

# Now Q_n = (q;q)_n * sum_{m=0}^n (-1)^{n-m} q^{T_{n-m}} g_m / (q;q)_{n-m}
# = sum_{m=0}^n (-1)^{n-m} q^{T_{n-m}} * (q;q)_n / (q;q)_m * g_m / ((q;q)_{n-m} / (q;q)_m... 

# Let me write it in terms of h_m = (q;q)_m * g_m:
# Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q * g_m
# = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q * h_m / (q;q)_m
# = sum_m (-1)^{n-m} q^{T_{n-m}} * (q;q)_n / ((q;q)_m (q;q)_{n-m}) * h_m / (q;q)_m

# Hmm, this doesn't simplify nicely. Let me try another way.

# Q_1 = g_1 - q = h_1 / (q;q)_1 - q = h_1/(1-q) - q... no that gives a fraction.
# Wait: Q_1 = (1-q)*g_1 - q = h_1 - q. Since h_1 = (1-q)*g_1.
# So Q_1 = h_1 - q.

# Q_2 = (1-q)(1-q^2) g_2 - (1-q^2) q g_1 + q^3
# = h_2 - q(1+q)*g_1*(1-q)/(1-q) + q^3... 
# No: (1-q^2) = (1-q)(1+q)
# Q_2 = h_2 - q(1+q)(1-q)g_1 + q^3 = h_2 - q(1+q)*h_1 + q^3

# Let me verify:
Q2_test = h[2] - q*(1+q)*h[1] + q**3
coeffs_Q2 = [Q2_test[i] for i in range(20)]
print(f"\nQ_2 = h_2 - q(1+q)*h_1 + q^3:")
print(f"  coeffs: {coeffs_Q2}")
print(f"  Q_2(1) = {sum(coeffs_Q2)}")

# YES! Q_2 = h_2 - q(1+q)*h_1 + q^3
# h_2 has negatives but Q_2 is nonneg because the -q(1+q)*h_1 + q^3 correction
# exactly fixes the negative coefficients of h_2.

# For general n:
# Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q g_m
# Writing g_m = h_m / (q;q)_m and [n,m]_q = (q;q)_n / ((q;q)_m (q;q)_{n-m}):
# Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} * h_m / ((q;q)_{n-m} * (q;q)_m)
# Hmm, this has (q;q)_m in the denominator which makes h_m / (q;q)_m = g_m.

# Let me try yet another approach. Define a new tower with polynomial base:
# P_0^m = h_m (polynomial)
# P_k^m = P_{k-1}^m - q^{k+?} * P_{k-1}^{m-1}
# And find which shift makes Q_n = sum of P terms.

# From Q_1 = h_1 - q and Q_2 = h_2 - q(1+q)*h_1 + q^3:
# Q_1 = h_1 - q*h_0 (since h_0 = 1)
# Check: Q_1 = h_1 - q*1 = h_1 - q. Yes!

# Q_2 = h_2 - q(1+q)*h_1 + q^3*h_0
# = h_2 - q(1+q)*h_1 + q^3
# Let me verify the pattern:
# The coefficients are (-1)^{n-m} q^{T_{n-m}} * ... 
# For Q_2: m=2 gives h_2, m=1 gives -q(1+q)h_1, m=0 gives q^3.

# So Q_n = sum_{m=0}^n alpha_{n,m} * h_m
# where alpha_{n,m} involves q-binomials and alternating signs.

# The Q_n formula: Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q g_m
# = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q h_m/(q;q)_m

# For n=2, m=1: (-1)^1 q^1 [2,1]_q h_1/(q;q)_1 = -q(1+q)*h_1/(1-q)
# But we computed Q_2 = h_2 - q(1+q)*h_1 + q^3, not h_2 - q(1+q)*h_1/(1-q) + ...
# So the formula doesn't work with h_m/(q;q)_m directly.

# Let me just compute directly.
# Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} [n,m]_q g_m
# We can rewrite using g_m = h_m / (q;q)_m:
# Q_n = sum_m (-1)^{n-m} q^{T_{n-m}} * (q;q)_n / ((q;q)_m * (q;q)_{n-m}) * h_m / (q;q)_m

# This has double (q;q)_m in the denominator. That's not helpful.

# Instead, think of Q_n as a q-INVERSE transform of g_m.
# The key is: can we decompose Q_n into a sum of manifestly positive pieces?

# Let me try a DIFFERENT approach: Kursungoz decomposition.
# The RAG showed that Kursungoz proved P_{n,c} has positive coefficients,
# where F_c(z,q) = (1-z) sum_{n>=0} P_{n,c}(q) z^n / (q^r;q^r)_n

# For r=3: F_c(z,q) = (1-z) sum_{n>=0} P_{n,c}(q) z^n / (q^3;q^3)_n
# = sum_{n>=0} P_{=n,c}(q) z^n / (q^3;q^3)_n

# Comparing with Q_n:
# Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))
# For ell = gcd(d,3). When d not-equiv 0 mod 3, ell = 1.
# So Q_n = (q;q)_n * [z^n]((zq;q)_inf * (1-z) sum_m P_m z^m/(q^3;q^3)_m)

# Wait, but ell depends on gcd(d,3), not on r=3.
# For d=4, ell = gcd(4,3) = 1. So Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q)).

# Kursungoz says P_{n,c} has positive coefficients. And P_{n,c} relates to Q_n how?
# F_c(z,q) = (1-z) sum_n P_n z^n / (q^3;q^3)_n
# This means g_m = sum_{n>=m} P_n binom... 
# Actually: [z^m] F_c(z,q) = P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1}
# So g_m = P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1}

# And Q_n involves a combination of g_m values.
# Let me compute P_n from g_m:
# F_c(z,q) = sum_m z^m g_m = (1-z) sum_n P_n z^n / (q^3;q^3)_n
# So sum_m z^m g_m = sum_n P_n z^n/(q^3;q^3)_n - sum_n P_n z^{n+1}/(q^3;q^3)_n
# g_m = P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1}
# Or equivalently: P_m/(q^3;q^3)_m = sum_{j=0}^m g_j = F_{c,m}(q)

# So P_m = (q^3;q^3)_m * F_{c,m}(q)... but F_{c,m} is an infinite series.
# Actually F_{c,m} = sum_{j=0}^m g_j which IS an infinite series.
# And (q^3;q^3)_m * (infinite series) would need to be a polynomial.

# Hmm, but Kursungoz proved P_m is a polynomial with positive coefficients.
# That means (q^3;q^3)_m * sum_{j=0}^m g_j is a polynomial.
# This is DIFFERENT from h_m = (q;q)_m * g_m.

# Let me compute P_m and see.
print("\n" + "=" * 60)
print("Kursungoz P_m polynomials for c=(2,1,1), d=4")
print("=" * 60)

# P_m = (q^3;q^3)_m * sum_{j=0}^m g_j... but for d=4, r=3 (NOT d+r=7).
# Wait, the profile has r=3 rows. The Kursungoz formula uses r=3.
# (q^r;q^r)_n = (q^3;q^3)_n

# But actually for r=3, ell = gcd(d,r). For d=4, ell=1.
# The formula is F_c(z,q) = (1-z) sum_n P_n z^n / (q^ell;q^ell)_n
# No - Kursungoz uses (q^r;q^r)_n where r is the number of partitions.

# Actually wait: Kursungoz eq (2): F_c(z,q) = (1-z) sum P_n z^n / (q^r;q^r)_n
# For our case r=3. So P_m = (q^3;q^3)_m * F_{c,m} where F_{c,m} = sum_{j<=m} g_j.

def qpoch_at(a, m):
    """(q^a;q^a)_m"""
    result = R(1)
    for i in range(1, m+1): result *= (1 - q**(a*i))
    return result

# F_{c,m} = sum_{j=0}^m g_j
Fcm = {}
Fcm[0] = g[0]
for m in range(1, 3):
    Fcm[m] = Fcm[m-1] + g[m]

# P_m = (q^3;q^3)_m * F_{c,m}
print("P_m = (q^3;q^3)_m * F_{c,m}:")
for m in range(3):
    Pm = qpoch_at(3, m) * Fcm[m]
    coeffs = [Pm[i] for i in range(30)]
    neg = [i for i in range(30) if coeffs[i] < 0]
    last_nz = max([i for i in range(30) if coeffs[i] != 0], default=-1)
    print(f"  P_{m}: coeffs = {coeffs[:20]}, deg={last_nz}")
    if neg:
        print(f"    NEGATIVE at: {neg}")
    else:
        print(f"    ALL NONNEG!")
    print(f"    P_{m}(1) = {sum(coeffs)}")

# Hmm wait, F_{c,m} is an infinite series. (q^3;q^3)_m * (infinite series)
# may or may not be a polynomial.
# Let me check if P_1 is a polynomial:
P1 = (1 - q**3) * (g[0] + g[1])
coeffs_P1 = [P1[i] for i in range(20)]
print(f"\nP_1 = (1-q^3)*(g_0 + g_1):")
print(f"  coeffs: {coeffs_P1}")
# g_0 + g_1 = 1 + 3q + 4q^2 + 5q^3 + 5q^4 + 5q^5 + ...
# (1-q^3) * this = 1 + 3q + 4q^2 + (5-1)q^3 + (5-3)q^4 + (5-4)q^5 + (5-5)q^6 + ...
# = 1 + 3q + 4q^2 + 4q^3 + 2q^4 + q^5 + 0 + 0 + ...
# = 1 + 3q + 4q^2 + 4q^3 + 2q^4 + q^5
# That IS a polynomial with positive coefficients!

# And P_1(1) = 1+3+4+4+2+1 = 15 = binom(4+2,2) = binom(6,2)
# Which is (d+1)(d+2)/2 = 5*6/2 = 15. Yes!

# Now: Q_n involves (q;q)_n (not (q^3;q^3)_n), and F_c(z,q).
# Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))

# Can we relate Q_n to P_n?
# Write F_c(z,q) = (1-z) sum P_m z^m / (q^3;q^3)_m
# Then (zq;q)_inf * F_c = (zq;q)_inf * (1-z) * sum P_m z^m / (q^3;q^3)_m
# Note (zq;q)_inf * (1-z) = (z;q)_inf (since (z;q)_inf = (1-z)(zq;q)_inf)

# So Q_n = (q;q)_n * [z^n]((z;q)_inf * sum_m P_m z^m / (q^3;q^3)_m)

# (z;q)_inf = sum_j (-1)^j z^j q^{j(j-1)/2} / (q;q)_j

# [z^n] = sum_{m+j=n} P_m / (q^3;q^3)_m * (-1)^j q^{j(j-1)/2} / (q;q)_j

# Q_n = (q;q)_n * sum_{m=0}^n P_m / (q^3;q^3)_m * (-1)^{n-m} q^{(n-m)(n-m-1)/2} / (q;q)_{n-m}

# = sum_{m=0}^n (-1)^{n-m} q^{T_{n-m-1}} * [n,m]_q * P_m / (q^3;q^3)_m

# where T_{-1} = 0 (T_k = k(k+1)/2, T_{-1} = 0).

# Hmm wait: (z;q)_inf = sum_j z^j (-1)^j q^{j(j-1)/2} / (q;q)_j
# This is slightly different from (zq;q)_inf = sum_j z^j (-1)^j q^{j(j+1)/2} / (q;q)_j

# So T_{n-m} for (zq;q) vs T_{n-m-1}+... for (z;q).
# (z;q)_inf coefficient of z^j: (-1)^j q^{j(j-1)/2} / (q;q)_j

# Q_n = (q;q)_n * sum_{m=0}^n P_m/(q^3;q^3)_m * (-1)^{n-m} q^{(n-m)(n-m-1)/2} / (q;q)_{n-m}
# = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m,2)} [n choose m]_q * P_m / (q^3;q^3)_m

# For n=1:
# Q_1 = P_0/(q^3;q^3)_0 * (-1) * q^0 * [1,0] + P_1/(q^3;q^3)_1 * 1 * q^0 * [1,1]
# = -1 + P_1/(1-q^3)

Q1_from_P = -1 + P1 / (1 - q**3)
# Wait P1 = (1-q^3)*(g_0+g_1) so P1/(1-q^3) = g_0+g_1 = 1 + g_1
# Q1 = -1 + 1 + g_1 = g_1
# But Q_1 = (1-q)*g_1 - q, not g_1. Something is wrong.

# Let me recheck. Actually:
# (zq;q)_inf * (1-z) = (zq;q)_inf - z*(zq;q)_inf
# = sum_j (-1)^j z^j q^{T_j}/(q;q)_j - sum_j (-1)^j z^{j+1} q^{T_j}/(q;q)_j
# = 1 + sum_{j>=1} z^j [(-1)^j q^{T_j}/(q;q)_j - (-1)^{j-1} q^{T_{j-1}}/(q;q)_{j-1}]
# = 1 + sum_{j>=1} z^j (-1)^j [q^{T_j}/(q;q)_j + q^{T_{j-1}}/(q;q)_{j-1}]

# Hmm this is getting complicated. Let me just verify numerically.
# The Kursungoz P_m are positive polynomials. Can we express Q_n directly 
# in terms of P_m in a manifestly positive way?

# Let me compute Q_n directly and see what we get:
Q1_computed = (1-q)*g[1] - q
Q2_computed = (1-q)*(1-q**2)*g[2] - (1-q**2)*q*g[1] + q**3

print(f"\nQ_1 = {[Q1_computed[i] for i in range(10)]}")
print(f"Q_2 = {[Q2_computed[i] for i in range(15)]}")

# The Q_n are polynomials with positive coefficients.
# P_m are also polynomials with positive coefficients.
# The relationship is:
# Q_n = (q;q)_n * [z^n]((zq;q)_inf * (1-z) * sum_m P_m z^m / (q^3;q^3)_m)
# = (q;q)_n * [z^n]((z;q)_inf * sum_m P_m z^m / (q^3;q^3)_m)

# This IS an alternating sum, so the relationship between Q_n and P_m is NOT manifestly positive.

# But maybe we can find a DIFFERENT decomposition.
# Key idea: P_n(q) counts some set of objects. Q_n(q) counts some other set.
# If we can find a WEIGHT-PRESERVING BIJECTION between the Q objects and 
# a manifestly positive set, we're done.

# From the data: P_1 = 1 + 3q + 4q^2 + 4q^3 + 2q^4 + q^5, P_1(1) = 15
# Q_1 = 2q + q^2 + q^3, Q_1(1) = 4
# 15 = binom(6,2), 4 = (d+1)(d+2)/6 - 1 = 5*6/6 - 1

# Interesting: P_1(1) = (d+1)(d+2)/2 = binom(d+2, 2) for d=4.
# And Q_1(1) = (d+1)(d+2)/6 - 1.
# (d+1)(d+2)/6 = P_1(1)/3 = 15/3 = 5.
# Q_1(1) = 5 - 1 = 4.

# So there's a factor of 3 between P and Q evaluations (plus a correction).
# This might reflect the (q;q)_n vs (q^3;q^3)_n difference.

print("\n" + "=" * 60)
print("Summary of key quantities for c=(2,1,1), d=4")
print("=" * 60)
print(f"g_0 = 1")
print(f"g_1 = 3q + 4q^2 + 5q^3 + 5q^4 + ... (stabilizes at 5)")
print(f"h_1 = (1-q)*g_1 = 3q + q^2 + q^3  (polynomial, all nonneg)")
print(f"P_1 = (1-q^3)*(1+g_1) = 1 + 3q + 4q^2 + 4q^3 + 2q^4 + q^5  (polynomial, all nonneg)")
print(f"Q_1 = h_1 - q = 2q + q^2 + q^3  (polynomial, all nonneg)")
print(f"")
print(f"h_1(1) = 5 = (d+1)(d+2)/6")
print(f"P_1(1) = 15 = (d+1)(d+2)/2 = 3 * h_1(1)")
print(f"Q_1(1) = 4 = h_1(1) - 1")

