"""
Seed 5 — Smart computation of Q_{n,c}(q).

Instead of enumerating cylindric partitions (which is exponential),
use the known product formulas.

For d=2, c=(1,0,1), k=3, t=5:
Borodin's formula gives F_c(q) = 1/((q^5;q^5)_inf * ...).

Let me use a transfer matrix on the COLUMN structure.
A cylindric partition of profile c=(c_0,...,c_{k-1}) with k parts and max <= n
can be represented as a sequence of "layers" from max_val = n down to 0.
At each layer m, we have a 0-1 pattern saying whether lam^i_j >= m.

Actually, let me use a much simpler approach. The polynomials Q_{n,c}(q)
for d=2 (which Warnaar proved) should equal specific known formulas.
Let me verify using the explicit formula.

For c = (1,0,1), d=2, this falls into the Andrews-Gordon / Rogers-Ramanujan
family. The modulus is t = k + d = 3 + 2 = 5.

Warnaar (2023) proved for d=2: Q_{n,(1,0,1)}(q) = q-binomial [n+1 choose 1]_q = q^0 + q^1 + ... + q^n?
No, that gives Q(1) = n+1, but we need Q(1) = 1^n = 1.

Wait, for d=2, ((d+1)(d+2)/6 - 1)^n = (3*4/6 - 1)^n = (2-1)^n = 1^n = 1.
So Q_{n,c}(q) should be a polynomial with Q(1) = 1 for all n.

Hmm, for d=2 the expected value at q=1 is 1 for all n. That means
Q_{n,c}(q) is a polynomial that sums to 1. The simplest possibility:
Q_{0,c}(q) = 1, Q_{1,c}(q) = q^a for some a, etc.

Actually wait — maybe Q_{n,c}(q) = 1 for all n? That seems too simple.
Or maybe Q_{n,c}(q) = q^{something}?

Let me look at this differently. Let me directly compute using the
Corteel-Welsh recurrence and Borodin's product formula, working with
q-series truncated to some order.

Key idea: work with power series in q truncated at order N,
and power series in y (really polynomials since we extract [y^n]).
"""

# Work with truncated q-series: polynomials mod q^N
N = 30  # truncation order

def series_add(a, b):
    r = list(a) + [0] * max(0, len(b) - len(a))
    for i in range(len(b)):
        r[i] += b[i]
    return r[:N]

def series_sub(a, b):
    r = list(a) + [0] * max(0, len(b) - len(a))
    for i in range(len(b)):
        r[i] -= b[i]
    return r[:N]

def series_mul(a, b):
    r = [0] * N
    for i in range(min(len(a), N)):
        if a[i] == 0:
            continue
        for j in range(min(len(b), N - i)):
            r[i + j] += a[i] * b[j]
    return r

def series_one():
    r = [0] * N
    r[0] = 1
    return r

def series_zero():
    return [0] * N

def series_qshift(a, k):
    """Multiply by q^k"""
    r = [0] * N
    for i in range(min(len(a), N)):
        if i + k < N:
            r[i + k] = a[i]
    return r

def series_inv(a):
    """Invert a power series a (assuming a[0] != 0)"""
    assert a[0] != 0
    r = [0] * N
    r[0] = 1  # assuming a[0] = 1 for now (we can generalize)
    # If a[0] = 1, then (1/a) is computed by:
    # r[n] = -sum_{k=1}^{n} a[k] * r[n-k]
    for n in range(1, N):
        s = 0
        for k in range(1, n + 1):
            if k < len(a):
                s += a[k] * r[n - k]
        r[n] = -s
    return r

def qpoch_inf(a_start, q_step):
    """Compute (q^a_start; q^q_step)_inf mod q^N = prod_{i>=0} (1 - q^{a_start + q_step * i})"""
    r = series_one()
    i = 0
    while True:
        exp = a_start + q_step * i
        if exp >= N:
            break
        factor = series_one()
        factor[exp] = -1
        r = series_mul(r, factor)
        i += 1
    return r

def qpoch_finite(a_start, q_step, count):
    """Compute (q^a_start; q^q_step)_count = prod_{i=0}^{count-1} (1 - q^{a_start + q_step * i})"""
    r = series_one()
    for i in range(count):
        exp = a_start + q_step * i
        if exp >= N:
            break
        factor = series_one()
        factor[exp] = -1
        r = series_mul(r, factor)
    return r


def borodin_Fc(c_profile):
    """
    Compute F_c(q) using Borodin's product formula, truncated to order N.
    
    F_c(q) = 1/((q^t;q^t)_inf) * prod_{i<j, m=1..c_i} 1/(q^{m+d_{i+1,j}+j-i}; q^t)_inf
           * prod_{i>j (certain range), m=1..c_i} 1/(q^{t-(m+...)}; q^t)_inf
    
    Where t = k + ell, ell = sum(c), d_{i,j} = c_i + ... + c_j.
    """
    k_val = len(c_profile)
    ell = sum(c_profile)
    t = k_val + ell
    
    # Using 1-indexed c_1, ..., c_k
    c = [0] + list(c_profile)  # 1-indexed
    
    def d(i, j):
        """d_{i,j} = c_i + c_{i+1} + ... + c_j"""
        return sum(c[m] for m in range(i, j + 1))
    
    # Start with 1/(q^t; q^t)_inf
    denom = qpoch_inf(t, t)
    result = series_inv(denom)
    
    # First product: i=1..k, j=i+1..k, m=1..c_i
    for i in range(1, k_val + 1):
        for j in range(i + 1, k_val + 1):
            for m in range(1, c[i] + 1):
                exp = m + d(i + 1, j) + j - i
                if exp > 0 and exp < t:
                    factor_denom = qpoch_inf(exp, t)
                    result = series_mul(result, series_inv(factor_denom))
    
    # Second product: i=2..k, j=2..i-1, m=1..c_i  (but only if i > j)
    # Wait, the formula says: i=2..k, j=2..i-1
    # But j goes from 2 to i-1, so this requires i >= 3
    for i in range(2, k_val + 1):
        for j in range(2, i):  # j from 2 to i-1
            for m in range(1, c[i] + 1):
                exp = t - (m + d(j, i - 1) + i - j)
                if exp > 0 and exp < t:
                    factor_denom = qpoch_inf(exp, t)
                    result = series_mul(result, series_inv(factor_denom))
    
    return result


def print_series(s, name="", var='q'):
    terms = []
    for i in range(min(len(s), N)):
        if s[i] != 0:
            if i == 0:
                terms.append(str(s[i]))
            elif s[i] == 1:
                terms.append(f"{var}^{i}" if i > 1 else var)
            elif s[i] == -1:
                terms.append(f"-{var}^{i}" if i > 1 else f"-{var}")
            else:
                terms.append(f"{s[i]}*{var}^{i}" if i > 1 else f"{s[i]}*{var}")
    if not terms:
        result = "0"
    else:
        result = terms[0]
        for t in terms[1:]:
            if t.startswith('-'):
                result += " - " + t[1:]
            else:
                result += " + " + t
    if name:
        print(f"{name} = {result} + O({var}^{N})")
    else:
        print(f"{result} + O({var}^{N})")


# Test Borodin's formula
print("Testing Borodin's formula")
print("=" * 70)

# c = (1,0,1), d=2, k=3, t=5
# Known: F_{(1,0,1)}(q) = 1/((q;q^5)(q^4;q^5)(q^5;q^5)) (Rogers-Ramanujan type)
# Actually for c=(1,0,1): the product should give us something related to RR identities.

c_test = (1, 0, 1)
F = borodin_Fc(c_test)
print_series(F, f"F_{c_test}(q)")

# Compare with 1/((q;q^5)(q^4;q^5)) * 1/(q^5;q^5)
# = prod_{n>=0} 1/((1-q^{5n+1})(1-q^{5n+4})(1-q^{5n+5}))
rr = series_one()
for exp_start, exp_step in [(1, 5), (4, 5), (5, 5)]:
    rr = series_mul(rr, series_inv(qpoch_inf(exp_start, exp_step)))

print_series(rr, "1/((q;q^5)(q^4;q^5)(q^5;q^5))")

# Check if they match
match = all(F[i] == rr[i] for i in range(N))
print(f"Match: {match}")

# Also try c = (2,0,0)
c_test2 = (2, 0, 0)
F2 = borodin_Fc(c_test2)
print_series(F2, f"\nF_{c_test2}(q)")

# For c=(2,0,0), d=2, k=3, t=5
# The product formula should give something related to RR
rr2 = series_one()
for exp_start, exp_step in [(2, 5), (3, 5), (5, 5)]:
    rr2 = series_mul(rr2, series_inv(qpoch_inf(exp_start, exp_step)))
print_series(rr2, "1/((q^2;q^5)(q^3;q^5)(q^5;q^5))")

match2 = all(F2[i] == rr2[i] for i in range(N))
print(f"Match: {match2}")

print("\n" + "=" * 70)
print("Now computing F_c(y,q) via Corteel-Welsh recurrence")
print("=" * 70)

# F_c(y,q) = sum_{empty != J subseteq I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
# where I_c = {i : c_i > 0} and c(J) is the shifted profile.

# For c = (1,0,1): I_c = {0, 2} (0-indexed: c_0=1, c_2=1)
# Nonempty subsets of I_c: {0}, {2}, {0,2}

# Actually, the formula uses 1-indexed: c = (c_1,...,c_k)
# I_c = {i : c_i > 0}
# For c = (1,0,1): I_c = {1, 3} (1-indexed)

# c(J): for i in J and (i-1) not in J: c_i(J) = c_i - 1
#        for i not in J and (i-1) in J: c_i(J) = c_i + 1
#        otherwise: c_i(J) = c_i
# Indices are cyclic.

# Let me implement this properly.

def shifted_profile(c_profile, J):
    """
    c_profile: tuple, 0-indexed (c_0, ..., c_{k-1})
    J: set of 0-indexed positions
    
    c_i(J) = c_i - 1 if i in J and (i-1) mod k not in J
           = c_i + 1 if i not in J and (i-1) mod k in J
           = c_i otherwise
    """
    k = len(c_profile)
    result = list(c_profile)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)


def I_c(c_profile):
    """Return set of indices where c_i > 0 (0-indexed)."""
    return {i for i in range(len(c_profile)) if c_profile[i] > 0}


def subsets(s):
    """All nonempty subsets of a set."""
    s = list(s)
    n = len(s)
    for mask in range(1, 2**n):
        yield frozenset(s[j] for j in range(n) if mask & (1 << j))


# For computing F_c(y,q), we represent it as a list of q-series indexed by y-power:
# F_c(y,q) = sum_{j>=0} f_j(q) * y^j
# We truncate y to some max power y_max.

def compute_F_bivariate(c_profile, y_max, cache=None):
    """
    Compute F_c(y,q) = [f_0(q), f_1(q), ..., f_{y_max}(q)]
    using the Corteel-Welsh recurrence.
    
    F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
    
    Base case: if I_c is empty (all c_i = 0), then the only cylindric partition
    is the trivial one, so F_c(y,q) = 1/(1-y)... 
    Wait, what is F_c(y,q) when c = (0,0,0)?
    The interlacing conditions become lam^i_j >= lam^{(i+1) mod 3}_j for all j,
    which means all three partitions are equal. So F_{(0,0,0)}(y,q) = 
    sum_{lambda partition} q^{3|lambda|} y^{lambda_1} = prod_{i>=1} 1/(1 - y q^{3i}) ??
    
    Hmm actually no. For c = (0,0,...,0) with k parts, the conditions
    lam^i_j >= lam^{(i+1) mod k}_j for all i,j means all partitions are identical.
    So F_{(0,...,0)}(y,q) = sum_{lambda} q^{k|lambda|} y^{max(lambda)}
    where max(lambda) = lambda_1.
    
    This equals prod_{i>=1} 1/(1 - y*q^{k*i}) ... no, that's the generating function
    for partitions with distinct parts. The generating function for partitions
    by size and max part is:
    
    sum_{lambda} q^{|lambda|} y^{lambda_1} = prod_{j>=1} 1/(1 - yq^j)
    
    Wait no. Let p(m,n) = number of partitions of n with largest part m.
    Then sum_{n,m} p(m,n) q^n y^m = sum_{m>=1} y^m q^m / ((q;q)_m) ??? No.
    
    The generating function is:
    sum_{lambda} q^{|lambda|} y^{lambda_1} = 1 + sum_{m>=1} y^m * q^m / (q;q)_m * ... 
    
    Hmm, actually:
    sum_{lambda} q^{|lambda|} y^{lambda_1} = sum_{n>=0} y^n * (sum_{lambda: max=n} q^{|lambda|} - sum_{lambda: max=n-1} q^{|lambda|})
    
    Nah, let me just note that y^{lambda_1} = y * y^{lambda_1 - 1} for lambda_1 >= 1.
    
    The standard identity is:
    sum_{lambda} q^{|lambda|} y^{lambda_1} = prod_{j>=1} (1 + yq^j + y^2 q^{2j} + ...)  ... no.
    
    Actually I think:
    sum_{lambda partition with parts <= M} q^{|lambda|} = 1/(q;q)_M   (partitions into parts 1..M)
    
    But we want to track the LARGEST part (= lambda_1 in decreasing notation, which
    equals the number of columns = largest part in the conjugate).
    
    Hmm, lambda_1 is the largest part if lambda is written in decreasing order:
    lambda = (lambda_1 >= lambda_2 >= ... >= 0).
    
    F_c(y,q) has F_c(0,q) = 1 (initial condition).
    
    Let me not worry about the base case and instead use Borodin for F_c(q) = F_c(1,q)
    and the Corteel-Welsh recurrence.
    
    Actually, I realize the recurrence requires computing F_{c(J)} recursively,
    and the shifted profiles may have all zeros. Let me handle this differently.
    
    For c with all zeros, F_c(y,q) is the generating function for k identical
    partitions tracked by size and max. If k=3, c=(0,0,0):
    F_{(0,0,0)}(y,q) = sum_{lambda} q^{3|lambda|} y^{lambda_1}
    
    I know that sum_{lambda} q^{|lambda|} y^{lambda_1} = 1/(yq; q)_inf ... let me check.
    For partitions with lambda_1 <= M: the generating function by size is 1/(q;q)_M.
    So sum_{M>=0} y^M * [partitions with max = M] = ... this is messy.
    
    Actually, the correct identity is:
    sum_{lambda} q^{|lambda|} z^{lambda_1} = sum_{n>=0} z^n q^n / (q;q)_n
                                            = 1/(zq; q)_inf   (by Euler)
    
    Wait: sum_{n>=0} z^n q^n/(q;q)_n is the q-exponential, which equals 1/((zq;q)_inf)
    by Euler's identity. And sum_{lambda: max(lambda)=n} q^{|lambda|} = 
    q^n/(q;q)_n * ... hmm, no.
    
    Partitions with largest part = n: these are partitions of the form (n, lambda_2, ...)
    with n >= lambda_2 >= ... >= 0. The generating function for such partitions by size is
    q^n * (generating function for partitions with parts <= n)
    = q^n / (q;q)_n.
    
    So sum_{n>=0} [z^n term] = sum_{n>=0} z^n * q^n / (q;q)_n = 1/(zq;q)_inf.
    
    But wait: this counts partitions with max part EXACTLY n, not AT MOST n.
    Partitions with max part exactly n have g.f. q^n/(q;q)_n - q^{n-1}/(q;q)_{n-1}... no.
    
    Actually, partitions with max part EXACTLY n:
    = partitions with parts <= n and at least one part = n
    = (partitions with parts <= n) - (partitions with parts <= n-1)
    = 1/(q;q)_n - 1/(q;q)_{n-1}
    
    But in the generating function sum_lambda q^{|lambda|} y^{lambda_1}:
    y^n coefficient = sum_{lambda: max(lambda)=n} q^{|lambda|}
    
    Hmm, I need to be careful. A partition lambda = (lambda_1, lambda_2, ...) with
    lambda_1 = n. The size is |lambda| = n + |mu| where mu = (lambda_2, ...) is
    a partition with max <= n. So:
    
    [y^n] F(y,q) = q^n * 1/(q;q)_n  ... no, that's wrong too.
    
    Let me reconsider. mu = (lambda_2, lambda_3, ...) is a partition with parts <= n.
    The number of parts is arbitrary. The generating function for such mu by size is
    1/((q;q)_n) ... wait no, that's partitions with at most n parts, not parts <= n.
    
    Partitions with parts <= n, any number of parts: this is the same as partitions
    into parts from {1, 2, ..., n}. The g.f. is 1/((1-q)(1-q^2)...(1-q^n)) = 1/(q;q)_n.
    
    So [y^n] sum_lambda q^{|lambda|} y^{lambda_1} = q^n / (q;q)_n.
    Hmm wait: if lambda_1 = n, then the rest is a partition with all parts <= lambda_1 = n.
    Size of rest = |lambda| - n. So sum_{lambda: lambda_1=n} q^{|lambda|} = q^n * sum_{mu: parts <= n} q^{|mu|}
    = q^n / (q;q)_n.
    
    Check: sum_{n>=0} y^n q^n / (q;q)_n. For y=0, we get just n=0 term = 1. Good.
    This equals 1/(yq;q)_inf by Euler's identity for the q-exponential.
    
    So F_{single partition}(y,q) = 1/(yq; q)_inf.
    
    For k identical partitions: F_{(0,...,0)}(y,q) = sum_lambda (q^k)^{|lambda|} y^{lambda_1}
    = 1/(yq^k; q^k)_inf.
    
    Wait: if all k partitions are identical, size = k*|lambda|, max = lambda_1.
    So F_{(0,...,0)}(y,q) = sum_lambda q^{k|lambda|} y^{lambda_1}
    = sum_{n>=0} y^n q^{kn} / (q^k; q^k)_n = 1/(yq^k; q^k)_inf.
    
    For k=3: F_{(0,0,0)}(y,q) = 1/(yq^3; q^3)_inf.
    
    OK great. Now let me implement the Corteel-Welsh recurrence properly.
    """
    if cache is None:
        cache = {}
    
    key = (c_profile, y_max)
    if key in cache:
        return cache[key]
    
    k = len(c_profile)
    Ic = I_c(c_profile)
    
    # Base case: Ic is empty means all c_i = 0
    if not Ic:
        # F_{(0,...,0)}(y,q) = 1/(yq^k; q^k)_inf
        # [y^n] = q^{kn} / (q^k; q^k)_n
        result = [series_zero() for _ in range(y_max + 1)]
        for n in range(y_max + 1):
            # q^{kn} / (q^k; q^k)_n
            num = series_zero()
            if k * n < N:
                num[k * n] = 1
            denom = qpoch_finite(k, k, n)
            coeff = series_mul(num, series_inv(denom))
            result[n] = coeff
        cache[key] = result
        return result
    
    # Recurrence: F_c(y,q) = sum_{J nonempty subset of I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
    #
    # [y^n] of F_{c(J)}(yq^s, q) / (1 - yq^s) where s = |J|:
    # 
    # Let G(y) = F_{c(J)}(y, q) = sum_m g_m y^m.
    # Then G(yq^s) = sum_m g_m q^{ms} y^m.
    # G(yq^s)/(1-yq^s) = (sum_m g_m q^{ms} y^m) * (sum_{j>=0} q^{js} y^j)
    # [y^n] = sum_{m=0}^{n} g_m q^{ms} * q^{(n-m)s} = q^{ns} sum_{m=0}^{n} g_m
    #
    # Wait that's not right. Let me redo:
    # [y^n] G(yq^s)/(1-yq^s) = sum_{m=0}^{n} [y^m] G(yq^s) * q^{(n-m)s}
    #                         = sum_{m=0}^{n} g_m * q^{ms} * q^{(n-m)s}
    #                         = q^{ns} * sum_{m=0}^{n} g_m
    #
    # That IS right. So [y^n] G(yq^s)/(1-yq^s) = q^{ns} * sum_{m=0}^{n} g_m.
    
    result = [series_zero() for _ in range(y_max + 1)]
    
    for J in subsets(Ic):
        s = len(J)
        sign = (-1) ** (s - 1)
        
        cp = shifted_profile(c_profile, J)
        # Check if cp has negative entries
        if any(x < 0 for x in cp):
            continue
        
        # Recursively compute F_{c(J)}(y,q)
        g = compute_F_bivariate(cp, y_max, cache)
        
        for n in range(y_max + 1):
            # [y^n] = sign * q^{ns} * sum_{m=0}^{n} g_m
            cumsum = series_zero()
            for m in range(n + 1):
                cumsum = series_add(cumsum, g[m])
            
            term = series_qshift(cumsum, n * s)
            term = [sign * x for x in term]
            result[n] = series_add(result[n], term)
    
    cache[key] = result
    return result


# Now compute Q_{n,c}(q)
def compute_Q_from_bivariate(c_profile, n_max):
    """
    Q_{n,c}(q) = (q;q)_n * [z^n]( (zq)_inf * F_c(z,q) )
    
    (zq)_inf = sum_{m>=0} (-1)^m q^{m(m+1)/2} / (q;q)_m * z^m
    
    [z^n] of (zq)_inf * F_c(z,q) = sum_{m=0}^{n} (-1)^m q^{m(m+1)/2}/(q;q)_m * f_{n-m}(q)
    
    where f_j = [z^j] F_c(z,q).
    
    Q_{n,c}(q) = sum_{m=0}^{n} (-1)^m q^{m(m+1)/2} * [(q;q)_n/(q;q)_m] * f_{n-m}
    """
    f = compute_F_bivariate(c_profile, n_max)
    
    results = {}
    for n in range(n_max + 1):
        Q = series_zero()
        for m in range(n + 1):
            sign = (-1) ** m
            shift = m * (m + 1) // 2
            
            # (q;q)_n / (q;q)_m
            ratio = series_one()
            for i in range(m + 1, n + 1):
                factor = series_one()
                if i < N:
                    factor[i] = -1
                ratio = series_mul(ratio, factor)
            
            term = series_qshift(f[n - m], shift)
            term = [sign * x for x in term]
            term = series_mul(term, ratio)
            Q = series_add(Q, term)
        
        results[n] = Q
    return results


# Main computation
print("Computing Q_{n,c}(q) via Corteel-Welsh recurrence")
print("=" * 70)

profiles = [
    (1, 0, 1),  # d=2
    (2, 0, 0),  # d=2
    (1, 1, 2),  # d=4
    (2, 2, 1),  # d=5
]

for c in profiles:
    d = sum(c)
    if d % 3 == 0:
        continue
    expected_base = ((d+1)*(d+2))//6 - 1
    print(f"\nProfile c = {c}, d = {d}, expected Q(1) = {expected_base}^n")
    print("-" * 50)
    
    Qs = compute_Q_from_bivariate(c, 4)
    
    for n in range(5):
        Q = Qs[n]
        # Check positivity
        all_pos = all(Q[i] >= 0 for i in range(N))
        q1 = sum(Q)
        expected = expected_base ** n
        
        # Print nonzero terms
        nonzero = [(i, Q[i]) for i in range(N) if Q[i] != 0]
        if len(nonzero) <= 15:
            terms_str = ", ".join(f"q^{e}:{c}" for e, c in nonzero)
        else:
            terms_str = ", ".join(f"q^{e}:{c}" for e, c in nonzero[:10]) + f" ... ({len(nonzero)} terms)"
        
        status = "POS" if all_pos else "NEG!"
        match = "OK" if q1 == expected else "MISMATCH!"
        print(f"  n={n}: [{status}] Q(1)={q1} (exp={expected}) {match}")
        if n <= 2:
            print(f"        {terms_str}")

