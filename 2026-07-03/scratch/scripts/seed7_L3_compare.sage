"""
Seed 7 Layer 3: Compare Q_{n,c}(q) with Demazure characters.
First compute Q_{n,c}(q) using the proper CW system, then compare.

Key insight from previous computation: we need to think about what
Q_{n,c}(q) ACTUALLY is as a character.

Recall: Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
     = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q * h_{n-j}
where h_m = (q;q)_m * g_m, and g_m = [y^m] F_c(y,q).

The Demazure character at specialization q^grade gives a POLYNOMIAL.
Q_n is also a polynomial. The question: is Q_n = (some shift) * Demazure char?

Looking at the d=4 data:
For B(2*L0 + L1 + L2), word [2,1]:
  D_{s2s1}: |D|=5, char = q^3 + q^2 + 2*q + 1
  This has char(1) = 5, Q_1(1) = 4. Not a match (off by 1).

But wait -- Q includes a shift and normalization.
Q_0 = 1, Q_1(1) = 4. 
The "base" is 5 = (d+1)(d+2)/6 = 5*6/6 = 5. Wait no: base = (d+1)(d+2)/6 - 1 = 5-1 = 4.

Actually I realize the Demazure character minus 1 (removing the highest weight contribution)
might give Q_1. Let's check.

D_{s2s1} - 1 = q^3 + q^2 + 2*q. Sum = 4 = Q_1(1). Possible!

Let me compute Q_1 for d=4, c=(2,1,1) properly and compare.
"""
from sage.all import *

R.<q> = PolynomialRing(ZZ)

# ======================================================================
# Known Q values from previous computations (or compute fresh)
# ======================================================================

# For d=4, c=(2,1,1), we know from Warnaar's paper that this case is proved.
# Let me compute Q_1 using the formula directly.

# The Borodin product for c = (2,1,1), d=4, t=7, k=3:
# F_c(q) = 1/((q^t;q^t)_inf * products)
# c = (c_0, c_1, c_2) = (2, 1, 1). In 1-indexed: c_1=2, c_2=1, c_3=1.

# First product: pairs (i,j) with i < j, both in {1,2,3}:
#   (1,2): c_1=2, d_{2,2}=c_2=1, j-i=1: m=1,2
#     m=1: a = 1+1+1 = 3
#     m=2: a = 2+1+1 = 4
#   (1,3): c_1=2, d_{2,3}=c_2+c_3=2, j-i=2: m=1,2
#     m=1: a = 1+2+2 = 5
#     m=2: a = 2+2+2 = 6
#   (2,3): c_2=1, d_{3,3}=c_3=1, j-i=1: m=1
#     m=1: a = 1+1+1 = 3

# Second product: pairs (i,j) with 2 <= j < i <= 3:
#   (3,2): c_3=1, d_{2,2}=c_2=1, i-j=1: m=1
#     a = t - (1+1+1) = 7-3 = 4
#     m=1: 1/(q^4; q^7)_inf

# So: F_{(2,1,1)}(q) = 1/((q^7;q^7) * (q^3;q^7)^2 * (q^4;q^7)^2 * (q^5;q^7) * (q^6;q^7))

PS.<q_ps> = PowerSeriesRing(QQ, default_prec=80)

def qpoch_ps(a, t, prec=80):
    result = PS(1)
    k = 0
    while a + t*k < prec:
        result *= (1 - q_ps^(a + t*k))
        k += 1
    return result

# F_{(2,1,1)}(q)
t = 7
F_c = 1 / (qpoch_ps(7,7) * qpoch_ps(3,7)^2 * qpoch_ps(4,7)^2 * qpoch_ps(5,7) * qpoch_ps(6,7))
print(f"F_c(q) for c=(2,1,1): {F_c}")

# Now I need g_m and h_m.
# g_m = [y^m] F_c(y,q)
# The unrestricted F_c(q) = sum_m g_m(q)

# For the bivariate GF, I need the CW recurrence.
# But for g_1, we can use the transfer matrix approach for max=1.

# Actually, let me use a known result. For d=4, Warnaar proved:
# Q_1 = q + q^2 + q^3 + q^4 (for some profile)
# Let me check which profile this is for.

# From the layer 2 results for d=7, c=(3,2,2):
# Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6

# For d=4, the key data I need is Q_1 for profile (2,1,1).
# Let me compute it using the enumeration approach, but more carefully.

# Actually, let me compute Q_n for d=4 by computing F_{c,N} directly.
# I'll enumerate cylindric partitions with max <= N for N = 0, 1, 2, 3.

def cylindric_gf_bounded(c, N, prec=60):
    """
    Compute F_{c,N}(q) = sum over cylindric partitions with max <= N of q^weight.
    Uses transfer matrix method.
    
    For k=3 and profile c, a cylindric partition with max <= N is determined by
    its "column profile" at each position. The state at column j is the triple
    (lambda^0_j, lambda^1_j, lambda^2_j) with 0 <= each <= N.
    
    Transition from column j to j+1:
    - lambda^i_{j+1} <= lambda^i_j for all i (decreasing within each partition)
    - Interlacing: lambda^i_j >= lambda^{(i+1) mod k}_{j + c_{(i+1) mod k}}
    
    The interlacing across different columns makes this a multi-column transfer.
    
    Simpler approach: directly enumerate using the column formulation.
    """
    k = len(c)
    d = sum(c)
    
    # A cylindric partition can be viewed as a function on Z/tZ x Z_+
    # where t = k + d, with certain constraints.
    # For k=3, d=4, t=7.
    
    # Alternative: enumerate each partition up to some weight.
    # For max <= N, the parts are in {0, ..., N}.
    # The weight of lambda^i is sum of its parts.
    
    # For a single partition with parts <= N and bounded weight:
    from sage.combinat.partition import Partitions
    
    def gen_partitions(max_part, max_weight):
        """Generate all partitions with parts <= max_part and weight <= max_weight."""
        result = [Partition([])]
        for w in range(1, max_weight + 1):
            for p in Partitions(w, max_part=max_part):
                result.append(p)
        return result
    
    max_wt = prec
    parts = gen_partitions(N, max_wt)
    
    # For small N and moderate prec, this is feasible.
    # Check interlacing conditions for all triples.
    
    def check_interlace(lam, mu, shift):
        """lambda_j >= mu_{j+shift} for all j >= 1."""
        max_j = max(len(lam), len(mu) + shift if len(mu) > 0 else 0) + 1
        for j in range(1, max_j + 1):
            l_j = lam[j-1] if j-1 < len(lam) else 0
            idx = j + shift - 1
            m_js = mu[idx] if 0 <= idx < len(mu) else 0
            if l_j < m_js:
                return False
        return True
    
    total_poly = PS(0)
    count = 0
    
    for l0 in parts:
        w0 = sum(l0)
        for l1 in parts:
            w01 = w0 + sum(l1)
            if w01 > max_wt:
                continue
            # Check l0 >= l1 shifted by c_1
            if not check_interlace(l0, l1, c[1]):
                continue
            for l2 in parts:
                wt = w01 + sum(l2)
                if wt > max_wt:
                    continue
                # Check l1 >= l2 shifted by c_2
                if not check_interlace(l1, l2, c[2]):
                    continue
                # Check l2 >= l0 shifted by c_0  (cyclic!)
                if not check_interlace(l2, l0, c[0]):
                    continue
                total_poly += q_ps^wt
                count += 1
    
    return total_poly, count


# d=4, c=(2,1,1)
c = (2, 1, 1)
prec = 40

print(f"\n{'='*70}")
print(f"Computing F_{{c,N}} for c={c}, d={sum(c)}")
print(f"{'='*70}")

F_bounded = {}
for N in range(5):
    F_N, cnt = cylindric_gf_bounded(c, N, prec=prec)
    F_bounded[N] = F_N
    print(f"F_{{c,{N}}}(q) first terms: {F_N.truncate(20)}")
    print(f"  F_{{c,{N}}}(1) = {cnt}")

# g_m = F_{c,m} - F_{c,m-1}
g = {0: PS(1)}
for m in range(1, 5):
    g[m] = F_bounded[m] - F_bounded[m-1]

# h_m = (q;q)_m * g_m
h = {}
for m in range(5):
    qfact = PS(1)
    for i in range(1, m+1):
        qfact *= (1 - q_ps^i)
    h[m] = qfact * g[m]

# Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q * h_{n-j}
def qbinom(n, j):
    if j < 0 or j > n:
        return PS(0)
    result = PS(1)
    for i in range(1, j+1):
        result *= (1 - q_ps^(n-j+i)) / (1 - q_ps^i)
    return result

print(f"\n--- Q_n for c={c} ---")
for n in range(4):
    Qn = PS(0)
    for j in range(n+1):
        if (n-j) not in h:
            break
        Qn += (-1)^j * q_ps^(j*(j+1)//2) * qbinom(n,j) * h[n-j]
    # Truncate to show only the polynomial part
    poly_terms = {i: Qn[i] for i in range(prec) if Qn[i] != 0}
    total = sum(poly_terms.values())
    print(f"Q_{n} = {Qn.truncate(25)}")
    print(f"Q_{n}(1) = {total}")

# Now the BIG comparison: do any Demazure characters match?
print(f"\n{'='*70}")
print("COMPARISON: Demazure chars vs Q_{n,c}(q)")
print(f"{'='*70}")

# From our earlier computation:
# For B(2*L0 + L1 + L2), word [2,1]: char = q^3 + q^2 + 2*q + 1 (sum=5)
# Q_1(1) should be 4. Let's see what Q_1 actually is.

# But actually, the issue is that the "principal grade" from the crystal
# may not be the same as the q-power in Q_n.
# In the crystal, grade = n0 + n1 + n2 (total number of simple root applications).
# In Q_n, the q-power is the SIZE of the cylindric partition.

# These might be related by a shift or rescaling.
# Also, Q_n might correspond to a DIFFERENCE of Demazure characters,
# not a single one.

# Let me check: is Q_1 = D_{s2s1} - D_e = (q^3 + q^2 + 2*q + 1) - 1 = q^3 + q^2 + 2*q?
# Sum = 4 = Q_1(1). Does this match Q_1 exactly?

