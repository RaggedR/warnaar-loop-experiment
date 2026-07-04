"""
Agent A: Relate P_n (Kursungoz, positive) to Q_n (conjecture target).

Key equations:
F_c(z,q) = (1-z) sum_{n>=0} P_n z^n / (q^r;q^r)_n     [Kursungoz, r=3]
Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * F_c(z,q))   [Conjecture definition]

For r=3, d not-equiv 0 mod 3: ell = gcd(d,3) = 1.

Goal: Express Q_n in terms of P_m values.

F_c(z,q) = sum_{m>=0} z^m g_m where g_m = [y^m] F_c(y,q)
Also F_c(z,q) = (1-z) sum_n P_n z^n / (q^3;q^3)_n
= sum_n z^n (P_n/(q^3;q^3)_n - P_{n-1}/(q^3;q^3)_{n-1})
So g_m = P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1}

And F_{c,m} = sum_{j=0}^m g_j = P_m / (q^3;q^3)_m

Now Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
= (q;q)_n * sum_{m=0}^n g_m * (-1)^{n-m} q^{T_{n-m}} / (q;q)_{n-m}
= sum_{m=0}^n (-1)^{n-m} q^{T_{n-m}} [n choose m]_q * g_m

Substituting g_m = P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1}:

Q_n = sum_{m=0}^n (-1)^{n-m} q^{T_{n-m}} [n,m] (P_m/(q^3;q^3)_m - P_{m-1}/(q^3;q^3)_{m-1})

This is an alternating sum of P_m terms. Let's see if it simplifies.

Alternatively: use Abel summation (summation by parts).
Let a_m = (-1)^{n-m} q^{T_{n-m}} [n,m]
Let b_m = F_{c,m} = P_m / (q^3;q^3)_m

Then sum a_m g_m = sum a_m (b_m - b_{m-1}) = sum (a_m - a_{m+1}) b_m + boundary terms
= Abel summation.

Actually: Q_n = sum a_m g_m where a_m = (-1)^{n-m} q^{T_{n-m}} [n,m]_q
And b_m = P_m / (q^3;q^3)_m = F_{c,m} (cumulative sum of g's).
Since g_m = b_m - b_{m-1}, we can write:
Q_n = sum_m a_m (b_m - b_{m-1}) 
= sum_m a_m b_m - sum_m a_m b_{m-1}
= sum_m a_m b_m - sum_m a_{m+1} b_m (shifting index in second sum)
= sum_m (a_m - a_{m+1}) b_m + a_n b_n (boundary correction)

Wait let me be more careful. We have m from 0 to n, and g_{-1} = 0, b_{-1} = 0.
Q_n = sum_{m=0}^n a_m (b_m - b_{m-1})
= sum_{m=0}^n a_m b_m - sum_{m=0}^n a_m b_{m-1}
= sum_{m=0}^n a_m b_m - sum_{m=1}^n a_m b_{m-1}  (since b_{-1} = 0)
= sum_{m=0}^n a_m b_m - sum_{m=0}^{n-1} a_{m+1} b_m
= a_n b_n + sum_{m=0}^{n-1} (a_m - a_{m+1}) b_m

So Q_n = a_n b_n + sum_{m=0}^{n-1} (a_m - a_{m+1}) b_m

where a_m = (-1)^{n-m} q^{T_{n-m}} [n,m]_q and b_m = P_m/(q^3;q^3)_m.

a_n = (-1)^0 q^0 [n,n] = 1.
b_n = P_n/(q^3;q^3)_n.

So Q_n = P_n/(q^3;q^3)_n + sum_{m=0}^{n-1} (a_m - a_{m+1}) P_m/(q^3;q^3)_m

If we can show a_m - a_{m+1} >= 0 (coefficient-wise) for each m,
then since P_m >= 0 and 1/(q^3;q^3)_m has positive coefficients as a formal power series,
we'd get Q_n >= 0!

But a_m = (-1)^{n-m} q^{T_{n-m}} [n,m]_q has ALTERNATING signs, so a_m - a_{m+1}
is not obviously nonneg.

Let me compute these differences to check.
"""
from sage.all import *

PREC = 30
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qpoch(m):
    result = R(1)
    for i in range(1, m+1): result *= (1 - q**i)
    return result

def qbinom(n, m):
    if m < 0 or m > n: return R(0)
    return qpoch(n) / (qpoch(m) * qpoch(n-m))

def T(k):
    """Triangular number k(k+1)/2."""
    return k*(k+1)//2

# For n = 1, 2, 3: compute a_m and differences a_m - a_{m+1}
for n in range(1, 4):
    print(f"\n{'='*60}")
    print(f"n = {n}")
    print(f"{'='*60}")
    
    for m in range(n+1):
        am = (-1)**(n-m) * q**T(n-m) * qbinom(n, m)
        print(f"  a_{m} = (-1)^{n-m} q^T_{n-m} [n,m] = {am}")
    
    print()
    for m in range(n):
        am = (-1)**(n-m) * q**T(n-m) * qbinom(n, m)
        am1 = (-1)**(n-m-1) * q**T(n-m-1) * qbinom(n, m+1)
        diff = am - am1
        coeffs = [diff[i] for i in range(15)]
        neg = [i for i in range(15) if coeffs[i] < 0]
        print(f"  a_{m} - a_{m+1} = {diff}")
        print(f"    Nonneg? {'YES' if not neg else 'NO, neg at ' + str(neg)}")

# For n=1:
# a_0 = -q, a_1 = 1
# a_0 - a_1 = -q - 1. NEGATIVE!

# So the Abel summation approach doesn't directly give positivity.
# The differences a_m - a_{m+1} have mixed signs.

# Let me try a different approach. 
# Idea: instead of Abel summation with the q-binomial transform,
# use the fact that Q_n and P_n are both positive polynomials and 
# find a DIRECT BIJECTIVE relationship.

# Alternative: the Kursungoz decomposition gives a bijection
# CP <-> (ordinary partition, colored distinct part partition)
# with F_c(z,q) = (1-z) sum P_n z^n / (q^3;q^3)_n
# This means: F_{c,n}(q) = P_n / (q^3;q^3)_n
# i.e., CPs with max <= n are in bijection with:
# - a colored distinct part partition counted by P_n, and
# - an ordinary partition with parts divisible by 3 and <= 3n (counted by 1/(q^3;q^3)_n)

# Now Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# The key is the factor (zq;q)_inf which introduces alternating signs.

# Can we interpret Q_n combinatorially?
# Q_n extracts the "non-cancelling" part of [z^n]((zq;q)_inf * F_c(z,q))
# after multiplying by (q;q)_n.

# Another approach: use the WREATH PRODUCT structure.
# For the Kursungoz decomposition, the ordinary partition part is
# counted by 1/(q^3;q^3)_n. The (q;q)_n factor in Q_n partially
# cancels this, replacing 1/(q^3;q^3)_n with (q;q)_n/(q^3;q^3)_n.

# (q;q)_n / (q^3;q^3)_n = prod_{i=1}^n (1-q^i)/(1-q^{3i})
# For i not divisible by 3: (1-q^i)/(1-q^{3i}) has positive coefficients
#   since 1/(1-q^{3i}) = 1 + q^{3i} + q^{6i} + ... and 1-q^i subtracts
# For i = 3j: (1-q^{3j})/(1-q^{9j})... hmm.

# Actually: (q;q)_n = prod_{i=1}^n (1-q^i) 
# and (q^3;q^3)_n = prod_{i=1}^n (1-q^{3i})
# So (q;q)_n / (q^3;q^3)_n = prod_{i=1}^n (1-q^i)/(1-q^{3i})
# = prod_{i not divisible by 3, i<=n} (1-q^i) * prod_{j=1}^{floor(n/3)} (1-q^{3j})/(1-q^{9j})... 
# No wait: for i=3j, (1-q^{3j})/(1-q^{9j}) is NOT the right factor.
# Actually (1-q^i) for i=3j is (1-q^{3j}), and the denominator has (1-q^{3*3j})... no.
# (q;q)_n = prod_{i=1}^n (1-q^i) includes i=1,2,3,4,...,n
# (q^3;q^3)_n = prod_{j=1}^n (1-q^{3j}) 
# Their ratio: cancel common factors. (1-q^{3j}) appears in both for j=1,...,n.
# In (q;q)_n: (1-q^3)(1-q^6)(1-q^9)...(1-q^{3n}) among others.
# In (q^3;q^3)_n: same factors.
# So (q;q)_n / (q^3;q^3)_n = prod_{i=1, 3 nmid i}^n (1-q^i)

# For n=1: (1-q). For n=2: (1-q)(1-q^2). For n=4: (1-q)(1-q^2)(1-q^4).

# This is interesting! (q;q)_n / (q^3;q^3)_n = prod_{1<=i<=n, 3 nmid i} (1-q^i)

# So Q_n = [(q;q)_n / (q^3;q^3)_n] * (q^3;q^3)_n * [z^n]((zq;q)_inf * F_c(z,q))
# Hmm that doesn't simplify nicely either.

# Let me try yet another angle.
# The evaluation Q_n(1) = ((d+1)(d+2)/6 - 1)^n
# The evaluation P_n(1) = binom(d+r-1, r-1)^n for Kursungoz 
# = binom(d+2, 2)^n = ((d+1)(d+2)/2)^n for r=3.

# So Q_n(1) = (P_n(1)^{1/n}/3 - 1)^n. The factor of 3 is striking!
# P_1(1)/3 = 15/3 = 5 = (d+1)(d+2)/6. And Q_1(1) = 5-1 = 4.
# P_2(1)/9 = 225/9 = 25 = ((d+1)(d+2)/6)^2 = 5^2. Q_2(1) = (5-1)^2 = 16.

# So Q_n(1) = (P_1(1)/3 - 1)^n. Can we prove Q_n >= 0 from P_n >= 0?

# The factor of 3 suggests looking at the polynomial
# R_n = P_n mod (q^3-1) or some 3-fold decomposition.

# Actually, consider: F_{c,m} = P_m / (q^3;q^3)_m
# And (q^3;q^3)_m at q=1 is m! * 3^m / ... no.
# (1-q^3)(1-q^6)...(1-q^{3m}) at q=1: each factor is 0. 
# So the ratio P_m/(q^3;q^3)_m at q=1 is F_{c,m}(1) which diverges.
# But P_m(1)/(q^3;q^3)_m at q=1 via L'Hopital... that doesn't make sense.

# P_m/(q^3;q^3)_m is a power series with positive coefficients (it's F_{c,m}).

# Let me think about this problem from a COMPLETELY different angle.
# APPROACH: prove Q_n >= 0 by constructing a manifestly positive multisum.

# For d=2 (k=1): Warnaar proved Q_n = sum_{j >= 0} q^{j(j+a)} [n choose j]_q
# For d=4,5 (k=2): Warnaar proved similar explicit formulas.
# For general d: no formula is known.

# Can we find a PATTERN in the explicit formulas for small d?
# d=2, c=(1,1): Q_n = sum_j q^{j^2} [n,j]  (a=0 case)
# d=2, c=(2,0): Q_n = sum_j q^{j(j+1)} [n,j]  (a=1 case)

# For d=4, Warnaar's Theorem gives:
# Look for the explicit formula in the RAG/Warnaar paper.
print("\n" + "=" * 60)
print("Verifying Warnaar's formula for d=2, c=(1,1)")
print("=" * 60)

# Q_n = sum_{j>=0} q^{j^2} [n, j]_q for c=(1,1), d=2
# n=1: q^0 [1,0] + q^1 [1,1] = 1 + q = ???
# But we need Q_1 for c=(1,1), d=2.

c = (1,1,0)  # Wait, this is k=2 not k=3. The conjecture has k=3 (three partitions).
# Actually the conjecture is for c=(c_0,c_1,c_2), rank 3.
# d=2: profiles are (2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)
# For d=2 with k=3: c=(1,1,0) or (2,0,0) etc.

# Actually d=2 for rank 3 means c_0+c_1+c_2=2 with 3 components.
# Warnaar's k=1 means d=2 or d=3. But d=3 equiv 0 mod 3, so d=2.

# Let me just compute Q_1 for all d=2 profiles
print("Q_1 for d=2 profiles:")
for c in [(2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)]:
    def compute_g1_small(c, prec=20):
        R = PowerSeriesRing(QQ, 'q', default_prec=prec)
        q = R.gen()
        result = R(0)
        for s0 in range(prec):
            for s1 in range(min(s0+c[1]+1, prec)):
                for s2 in range(min(s1+c[2]+1, prec)):
                    if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                        total = s0+s1+s2
                        if total < prec: result += q**total
        return result
    
    g1 = compute_g1_small(c, 20)
    Q1 = (1-q)*g1 - q
    coeffs = [Q1[i] for i in range(10)]
    print(f"  c={c}: Q_1 = {coeffs[:8]}, sum={sum(coeffs)}")
    # For d=2: (d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 1. So Q_n(1) = 1^n = 1.

# Let me now check: for d=4, c=(2,1,1), what is the Warnaar-type multisum?
# From Warnaar 2023, Theorem for k=2: this gives a quadruple sum.
# Let me search for the explicit formula.
# From the Warnaar paper chunk: 
# Q_n = sum_{j>=0} q^{j(j+a)} [n,j] for rank 2 (r=2)
# For rank 3 (r=3), the formula is more complex.

print(f"\nVerification for d=2: Q_n(1) = {(2+1)*(2+2)//6 - 1}")

