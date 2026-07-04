# Use transfer matrix approach to compute F_{c,n} exactly
# For profile c = (c_0, c_1, c_2), the transfer matrix A has
# rows/columns indexed by compositions c' with sum(c') = d
# A[c', c''] = q^{something} based on the CW recurrence

# Actually, let's use the matrix product formula from Round 1:
# (q^3;q^3)_n * F_{c,n} = P_n = sum over paths (c^(0),...,c^(n)=c) of prod q^{k*EMD(c^(k),c^(k-1))}
# This is the manifestly positive formula

# But I need Q_n, which involves the (zq;q)_inf factor.
# Let me just directly use Borodin's product formula for F_c(z,q) and extract coefficients.

from sage.all import *

def borodin_Fc(c, prec=100):
    """Compute F_c(z,q) = sum_n F_{c,n} z^n using Borodin's product formula
    as a double power series in z and q."""
    k = len(c)
    d = sum(c)
    t = d + k
    
    # We work in QQ[[q]][[z]] or a bivariate ring
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    S = PowerSeriesRing(R, 'z', default_prec=prec)
    z = S.gen()
    
    # F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}
    # From Borodin: F_c(q) = product formula (no y)
    # For the bivariate, we need the Corteel-Welsh recurrence
    
    # Actually, let's use the simpler approach:
    # F_{c,n}(q) can be computed via the transfer matrix
    # The state space is the set of "slices" of the cylindric partition
    
    # For r=3, a slice at level j consists of the values (lam^0_j, lam^1_j, lam^2_j)
    # But the interlacing makes this complicated
    
    # Better: Use the CW functional equation iteratively
    # F_c(y,q) = sum_{J subset I_c, J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})
    
    # This is a recurrence on c (through c(J))
    # For r=3, profiles with d fixed form a finite set
    
    # Let me implement this via memoization
    # The key insight: c(J) has the same sum d but different composition
    # And F_c(y,q) at y -> yq^{|J|} telescopes
    
    # Actually, the CW equation relates F_c for different profiles but same d
    # Let me use the simpler matrix approach from Agent B:
    # F_{c,n} = (1/P_n(c)) * ... actually let me just use the Borodin product
    # and extract coefficients of z^n via the CW equation
    
    pass

# Let me try a completely different approach: just compute Q_n directly
# using the definition with Borodin's product

def compute_Qn_via_product(c, N, prec=300):
    """Compute Q_n for n=0..N using Borodin's product formula."""
    k = len(c)
    d = sum(c)
    t = d + k
    ell = gcd(d, k)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    # Compute d_{i,j} = c_i + ... + c_j
    def d_range(i, j):
        # i,j are 1-indexed as in the formula
        return sum(c[ii-1] for ii in range(i, j+1))
    
    # Borodin's product for F_c(q) (univariate, no bound)
    # = 1/(q^t;q^t)_inf * prod_{...}
    
    # But we need F_c(z,q) bivariate
    # F_c(z,q) = sum_n F_{c,n}(q) z^n  (where F_{c,n} counts CPs with max <= n)
    
    # Alternatively: F_c(z,q) = F_c(q) * ... no, that's not right
    
    # Let me use the simplest correct formula:
    # Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m F_{c,m} z^m)
    
    # So I need F_{c,m} for m = 0..N
    # F_{c,m} = sum over CPs with max <= m of q^{|Lambda|}
    
    # For the transfer matrix, each "layer" of the CP adds one possible maximum value
    # g_m = F_{c,m} - F_{c,m-1} counts CPs with max exactly m
    
    # The transfer matrix T has entry T[c', c''] = 1 if c'' = c'(J) for some J
    # weighted by q^{sum of parts at level m}
    
    # Actually this is getting complicated. Let me just use a known implementation.
    # The simplest: compute Warnaar's Q_n for d=2 from the KNOWN explicit formula.
    
    # For d=2, r=3, t=5, ell=1
    # Warnaar proved Q_n for k=1 (d=2) explicitly.
    # Q_{n,(1,1,0)}(q) = ???
    
    # From Warnaar's paper, for k=1 (d=2), the profiles are (2,0,0), (0,2,0), (0,0,2),
    # (1,1,0), (1,0,1), (0,1,1)
    # That's binom(4,2) = 6 profiles
    
    # For d=2, Warnaar gives: Q_n(q) = sum_{...} q^{...} [n choose ...]_q
    # Actually let me try to look this up from the paper
    pass

# Instead, let me try with MUCH more parts in the CP enumeration
# The issue is: for d=2, c=(1,1,0), n=1, the CP has max <= 1
# Each partition has parts in {0,1}
# But the INTERLACING conditions extend: lam^i_j >= lam^{i+1}_{j+c_{i+1}}
# For c=(1,1,0): c_0=1, c_1=1, c_2=0
# Conditions:
#   lam^0_j >= lam^1_{j+c_1} = lam^1_{j+1}
#   lam^1_j >= lam^2_{j+c_2} = lam^2_j  
#   lam^2_j >= lam^0_{j+c_0} = lam^0_{j+1}
# So: lam^0_j >= lam^1_{j+1}, lam^1_j >= lam^2_j, lam^2_j >= lam^0_{j+1}
# Combining: lam^1_j >= lam^2_j >= lam^0_{j+1} >= lam^1_{j+2}
# So lam^1_j >= lam^1_{j+2} (automatic from decreasing)
# And lam^0_j >= lam^1_{j+1} >= lam^2_{j+1} >= lam^0_{j+2}

# For max=1, parts are 0 or 1. So each partition is (1,1,...,1,0,0,...) 
# determined by how many 1s. Let a_i = number of 1s in lam^i.
# Then lam^0_j >= lam^1_{j+1} means: if j+1 <= a_1 (i.e. lam^1_{j+1}=1), then j <= a_0
# i.e. a_0 >= a_1 (if a_1 > 0)... wait, more precisely:
# lam^0_j = 1 iff j <= a_0; lam^1_{j+1} = 1 iff j+1 <= a_1, i.e. j <= a_1-1
# So need: for all j: if j <= a_1-1 then j <= a_0-1, i.e. a_0 >= a_1
# Similarly: a_1 >= a_2 (from lam^1_j >= lam^2_j)
# And: lam^2_j >= lam^0_{j+1} means a_2 >= a_0 - 1 (i.e. a_0 <= a_2 + 1)

# So conditions: a_0 >= a_1 >= a_2, a_0 <= a_2 + 1
# Since a_0 >= a_1 >= a_2 and a_0 <= a_2 + 1, we get a_0 = a_2 or a_0 = a_2 + 1
# If a_0 = a_2: then a_1 = a_2 = a_0, all equal. Size = 3*a_0.
# If a_0 = a_2 + 1: then a_1 can be a_2 or a_2+1 = a_0.
#   If a_1 = a_2: size = (a_2+1) + a_2 + a_2 = 3*a_2 + 1
#   If a_1 = a_0 = a_2+1: size = (a_2+1) + (a_2+1) + a_2 = 3*a_2 + 2

# For max=1: a_i can be 0, 1, 2, ..., infinity! (parts are 0 or 1, but partition can be arbitrarily long)
# So F_{c,1} = sum_{a_2=0}^inf (q^{3a_2} + q^{3a_2+1} + q^{3a_2+2})
#            = (1 + q + q^2) * sum_{a_2=0}^inf q^{3a_2}
#            = (1 + q + q^2) / (1 - q^3)
#            = 1/(1-q)

# Wait: (1+q+q^2)/(1-q^3) = (1+q+q^2)/((1-q)(1+q+q^2)) = 1/(1-q)
# So F_{c,1} = 1/(1-q) = 1 + q + q^2 + q^3 + ...

# This is a POWER SERIES, not a polynomial! That makes sense -- F_{c,n} is a power series.

# But my enumeration with max_parts=8 only counted partitions with at most 8 parts.
# Partitions with parts 0 or 1 can have arbitrarily many 1s!
# The enumeration was WRONG because it truncated.

print("F_{c,1} for c=(1,1,0) should be 1/(1-q) = infinite series")
print("The enumeration with max_parts=8 misses long partitions")
print()

# So I need to compute F_{c,n} as a power series, not by enumeration.
# Let me use the transfer matrix approach properly.

# For profile c and max <= n, the generating function F_{c,n}(q) counts
# all CPs with parts in {0,...,n}. Each such CP is determined by choosing
# how many parts equal n, how many equal n-1, etc.

# The KEY insight: a CP of profile c with max <= n is equivalent to
# a sequence of n "layers", where layer k records which positions have value >= k.

# Actually, let me use the known result from Round 1:
# P_n(c) = (q^3;q^3)_n * F_{c,n}(q) = sum over paths of monomials
# This is a POLYNOMIAL.
# And Q_n = (q^ell;q^ell)_n * [z^n]((zq;q)_inf * sum_m F_{c,m} z^m)
#         = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_{q^ell} * P_j / (q^ell;q^ell)_j

# Wait, let me be more careful. We have:
# Q_n = (q^ell;q^ell)_n * [z^n](prod_{i>=1}(1-zq^i) * sum_m F_{c,m} z^m)
# (zq;q)_inf = prod_{i>=1}(1-zq^i) -- wait, (zq;q)_inf = prod_{i=0}^inf (1-zq^{1+i}) = prod_{i>=1}(1-zq^i)

# [z^n](prod_{i>=1}(1-zq^i) * sum_m F_{c,m} z^m)
# = sum_{j=0}^n c_{n-j} * F_{c,j}  where c_k = [z^k] prod_{i>=1}(1-zq^i)

# prod_{i>=1}(1-zq^i) = sum_{k>=0} (-z)^k q^{k(k+1)/2} / (q;q)_k  ... no, that's wrong
# Actually prod_{i>=1}(1-zq^i) = sum_{k>=0} (-1)^k q^{k(k+1)/2} z^k / (q;q)_k
# by the q-binomial theorem

# So [z^n](prod(1-zq^i) * sum_m F_m z^m) = sum_{j=0}^n (-1)^{n-j} q^{(n-j)(n-j+1)/2} / (q;q)_{n-j} * F_{c,j}

# And Q_n = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^{n-j} q^{(n-j)(n-j+1)/2} / (q;q)_{n-j} * F_{c,j}

# Now P_j = (q^ell;q^ell)_j * F_{c,j} is a polynomial (from Round 1).
# So F_{c,j} = P_j / (q^ell;q^ell)_j (a power series).

# Q_n = (q^ell;q^ell)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * P_j / (q^ell;q^ell)_j

# For ell=1 (d not divisible by 3):
# Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j} * P_j / (q;q)_j
#      = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j

# This is the q-binomial transform of P_j!

# So I need P_j (polynomial) and then apply the q-binomial transform.
# P_j is the manifestly positive path formula.

# Let me compute P_j via the EMD path formula.
# Profiles for d=2, r=3: compositions (a,b,c) with a+b+c=2
# (2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1) -- 6 profiles

# EMD(c, c') on Z/3Z: earth mover's distance with clockwise metric
# EMD formula from Round 1: EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
# Hmm, let me just compute it for all pairs

R = PolynomialRing(QQ, 'q')
q = R.gen()

profiles_d2 = [(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)]

def emd(c1, c2):
    """EMD on Z/3Z with clockwise metric, as per Agent B's formula."""
    # EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
    # This is for c=(c_0,c_1,c_2) -- check indices
    val = 3*max(0, c2[1]-c1[1], c1[0]-c2[0]) + (c2[0]-c1[0]) - (c2[1]-c1[1])
    return val

# Print EMD table
print("EMD table for d=2 profiles:")
print("       ", "  ".join(str(p) for p in profiles_d2))
for c1 in profiles_d2:
    row = []
    for c2 in profiles_d2:
        row.append(str(emd(c1, c2)))
    print(f"{c1}: {', '.join(row)}")

# P_n(c) = sum over paths (c^(0), ..., c^(n)=c) of prod_{k=1}^n q^{k*EMD(c^(k), c^(k-1))}
# Wait, I need to be careful about the path direction.
# From Round 1: P_n(c) = (q^3;q^3)_n * F_{c,n}(q)
# = sum over paths (c^(0),...,c^(n)=c) of prod_{k=1}^n q^{k*EMD(c^(k), c^(k-1))}
# Actually I think c^(n) is not fixed to c... let me re-read.

# From synthesis: "P_n(c) = (q^3;q^3)_n * F_{c,n} = sum over paths (c^(0),...,c^(n)=c) 
# of prod_{k=1}^n q^{k*EMD(c^(k),c^(k-1))}"
# So the ENDPOINT c^(n) = c is fixed, and the starting point c^(0) is summed over.

# For n=1: P_1(c) = sum_{c'} q^{1*EMD(c, c')} = sum_{c'} q^{EMD(c, c')}
# where c^(1) = c (fixed), c^(0) = c' (summed)

# Let me compute P_n for c = (1,1,0)
def compute_Pn(target_c, n, profiles):
    """Compute P_n(target_c) using the EMD path formula."""
    if n == 0:
        return R(1)
    
    # Recursive: P_n(c) = sum_{c'} q^{n*EMD(c, c')} * P_{n-1}(c')
    result = R(0)
    for c_prev in profiles:
        P_prev = compute_Pn(c_prev, n-1, profiles)
        e = emd(target_c, c_prev)
        result += q**(n * e) * P_prev
    return result

c_target = (1, 1, 0)
for n in range(5):
    Pn = compute_Pn(c_target, n, profiles_d2)
    print(f"\nP_{n}({c_target}) = {Pn}")
    print(f"  P_{n}(1) = {Pn(1)}")

# Now compute Q_n from P_j
# Q_n = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j

def qbinom(n, k, q_var):
    """q-binomial coefficient [n choose k]_q"""
    if k < 0 or k > n:
        return R(0)
    num = R(1)
    den = R(1)
    for i in range(1, k+1):
        num *= (1 - q_var**((n-i+1)))
        den *= (1 - q_var**i)
    # This is a polynomial division
    return num // den

print("\n\n=== Q_n computation ===")
for n in range(5):
    Qn = R(0)
    for j in range(n + 1):
        k = n - j
        Pj = compute_Pn(c_target, j, profiles_d2)
        coeff = (-1)**k * q**(k*(k+1)//2) * qbinom(n, j, q) * Pj
        Qn += coeff
    print(f"\nQ_{n}({c_target}) = {Qn}")
    print(f"  Q_{n}(1) = {Qn(1)}")
    # Check nonnegativity
    neg_coeffs = [(i, Qn[i]) for i in range(Qn.degree()+1) if Qn[i] < 0]
    if neg_coeffs:
        print(f"  *** NEGATIVE: {neg_coeffs[:5]}")
    else:
        print(f"  All nonneg!")

