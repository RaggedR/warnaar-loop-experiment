"""
Seed 7 Layer 3: Compute graded Demazure characters and compare with Q_{n,c}(q).
Focus on getting the grading right.
"""
from sage.all import *

ct = CartanType(['A', 2, 1])
WS = RootSystem(ct).weight_space(extended=True)
Lambda = WS.fundamental_weights()
alpha = WS.simple_roots()
delta = WS.null_root()

# The weight of highest weight element is hw_wt.
# Any other element has weight hw_wt - sum c_i alpha_i.
# The "grade" or "energy" is the coefficient of delta in the difference.
# Since alpha_0 = delta - theta (where theta is the highest root of the finite part),
# we need to extract the delta-coefficient.

# In the extended weight space, we can write:
# mu = <mu, Lambda_0^vee> * Lambda_0 + <mu, Lambda_1^vee> * Lambda_1 + <mu, Lambda_2^vee> * Lambda_2 + c * delta
# where the c is what we want (related to the grading/energy).

# For A_2: Lambda_0, Lambda_1, Lambda_2 are fundamental weights.
# In the extended space, there's also delta and the derivation d.
# <d, alpha_i> = delta_{i,0}, <d, delta> = 0, <d, Lambda_i> = 0

# So the grade of a weight mu (relative to hw_wt) is:
# Let diff = hw_wt - mu.
# grade = <diff, d> = <d, diff>
# But actually, in SageMath's extended weight space, we need to figure out
# how to extract the delta coefficient.

# Let me try a different approach: compute the inner products directly.
# For A_2^(1), the simple coroots are alpha_0^vee, alpha_1^vee, alpha_2^vee.
# The "level" of mu is <mu, c> where c = alpha_0^vee + alpha_1^vee + alpha_2^vee.

# The "grade" of mu (relative to hw) is more subtle in the extended weight space.
# Let me try to extract it from the weight representation.

def extract_grade(wt, hw_wt):
    """
    Extract the grade (depth) of weight wt relative to hw_wt.
    For A_2^(1), diff = hw_wt - wt = sum n_i alpha_i + grade * delta
    Actually: diff = sum n_i alpha_i where n_i >= 0.
    The grade is the number of times alpha_0 appears in the expansion
    (since delta = alpha_0 + alpha_1 + alpha_2 for A_2^(1), the "affine level"
    contribution).
    
    More precisely: diff = n_0 * alpha_0 + n_1 * alpha_1 + n_2 * alpha_2
    This can be rewritten as:
    diff = min(n_0,n_1,n_2) * delta + remaining alpha_i terms
    
    The grade (for the principal grading) is different.
    The principal grading assigns grade 1 to each simple root alpha_i.
    So grade = n_0 + n_1 + n_2.
    
    But that's the total depth, not the "energy" used in Q_{n,c}(q).
    
    Actually, for cylindric partitions, the weight |Lambda| corresponds to
    the grading. Let me think about what grading matches Q_{n,c}(q).
    """
    diff = hw_wt - wt
    # Express diff in terms of simple roots
    # In SageMath, we can extract the coefficients
    # diff is in the weight space, alpha_i are also in the weight space.
    
    # The Cartan matrix for A_2^(1):
    # alpha_0 = 2*Lambda_0 - Lambda_1 - Lambda_2 + delta
    # alpha_1 = -Lambda_0 + 2*Lambda_1 - Lambda_2
    # alpha_2 = -Lambda_0 - Lambda_1 + 2*Lambda_2
    
    # We need to solve: diff = n_0*alpha_0 + n_1*alpha_1 + n_2*alpha_2
    # This is a linear system. Let's compute the coefficients using inner products
    # with the fundamental coweights.
    
    # <Lambda_i, alpha_j^vee> = delta_{ij}
    # So <diff, alpha_j^vee> = sum_i n_i <alpha_i, alpha_j^vee> = sum_i n_i A_{ij}
    # where A is the Cartan matrix.
    
    # For A_2^(1): A = [[2,-1,-1],[-1,2,-1],[-1,-1,2]]
    # So: [<diff,alpha_0^v>, <diff,alpha_1^v>, <diff,alpha_2^v>] = [n0,n1,n2] * A
    # => [n0,n1,n2] = [<diff,alpha_0^v>, <diff,alpha_1^v>, <diff,alpha_2^v>] * A^{-1}
    
    # Actually, we have the dual pairing:
    # <alpha_i, alpha_j^vee> = A_{ji}  (the TRANSPOSED Cartan matrix entry)
    # For A_2^(1), A is symmetric, so it doesn't matter.
    
    coroot = RootSystem(ct).coroot_space()
    # Actually let's just check delta coefficient
    # diff should be expressible as: 
    # diff = (stuff in finite root lattice) + n * delta
    # where n is the "affine grade"
    
    return None  # placeholder


# Let me take a more computational approach.
# Instead of trying to extract the grade from the weight,
# let me compute what Q_{n,c}(q) IS for d=2 and then try to match.

print("="*70)
print("Step 1: Compute Q_{n,c}(q) for d=2 independently")
print("="*70)

# For d=2, k=3, t=5, c=(2,0,0), ell=gcd(2,3)=1
# Borodin product: F_{(2,0,0)}(q) = 1/((q^5;q^5)_inf * (q^2;q^5)_inf * (q^3;q^5)_inf)
# = 1/((q^2,q^3,q^5;q^5)_inf)
# This is a known modular form / RR-type product.

# For d=2 with c=(2,0,0), the CW system has C(4,2)=6 profiles:
# (2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)

# The Borodin product for c=(2,0,0):
# k=3, d=2, t=5
# c = (c_1, c_2, c_3) = (2, 0, 0) in 1-indexed
# First product: i=1, j=2,3; i=2, j=3
#   i=1, j=2: m=1,2; d_{2,2}=c_2=0; a = m + 0 + 2-1 = m+1
#     m=1: a=2; m=2: a=3
#   i=1, j=3: m=1,2; d_{2,3}=c_2+c_3=0; a = m + 0 + 3-1 = m+2
#     m=1: a=3; m=2: a=4
#   i=2, j=3: m=1,...,c_2=0; empty!
# Second product: i=2, j from 2 to 1: empty; i=3, j=2: m=1,...,c_3=0; empty!
# So F_{(2,0,0)}(q) = 1/((q^5;q^5) * (q^2;q^5) * (q^3;q^5) * (q^3;q^5) * (q^4;q^5))
# Wait, that has (q^3;q^5) twice!

# Let me be more careful. The formula is:
# F = 1/(q^t;q^t)_inf * prod_{i<j} prod_{m=1}^{c_i} 1/(q^{m+d_{i+1,j}+j-i};q^t)_inf
#     * prod_{i>j>=2} prod_{m=1}^{c_i} 1/(q^{t-(m+d_{j,i-1}+i-j)};q^t)_inf
# For k=3, 1-indexed c = (2,0,0):
# First product pairs (i,j): (1,2), (1,3), (2,3)
#   (1,2): c_1=2, d_{2,2}=c_2=0, j-i=1: m=1,2 gives a=2,3
#   (1,3): c_1=2, d_{2,3}=c_2+c_3=0, j-i=2: m=1,2 gives a=3,4
#   (2,3): c_2=0: empty
# Second product pairs: (3,2): c_3=0: empty
# Overall: 1/(q^5;q^5) * 1/(q^2;q^5) * 1/(q^3;q^5) * 1/(q^3;q^5) * 1/(q^4;q^5)
# = 1/(q^2,q^3,q^3,q^4,q^5;q^5)_inf

# Hmm, q^3 appears twice. So the denominator has double zeros at q^3 mod 5.

R.<q> = PowerSeriesRing(QQ, default_prec=50)

def qpoch(a, t, prec):
    """(a; t)_inf truncated"""
    result = R(1)
    k = 0
    while a + t*k < prec:
        result *= (1 - q**(a + t*k))
        k += 1
    return result

# F_{(2,0,0)}(q)
F200 = 1 / (qpoch(2,5,50) * qpoch(3,5,50)^2 * qpoch(4,5,50) * qpoch(5,5,50))
print(f"F_{{(2,0,0)}}(q) = {F200}")

# Now extract g_m = [y^m] F(y,q) and h_m = (q;q)_m * g_m
# For this we need the bivariate GF. But for d=2, k=3, the CW system is small.

# Actually, for d=2, Warnaar proved the conjecture. Let me compute Q_n directly.
# Q_n = sum_j (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}
# with ell=1.

# For d=2, the bounded GF F_{(2,0,0),N}(q) can be computed.
# F_{c,0} = 1, F_{c,1} = 1 + g_1, F_{c,2} = 1 + g_1 + g_2, etc.
# And g_m counts cylindric partitions with max entry exactly m.

# For d=2, c=(2,0,0): cylindric partitions are triples (lambda^1, lambda^2, lambda^3)
# with lambda^1_j >= lambda^2_{j+0} (since c_2=0), lambda^2_j >= lambda^3_{j+0},
# lambda^3_j >= lambda^1_{j+2}.
# So lambda^1 >= lambda^2 >= lambda^3 and lambda^3_j >= lambda^1_{j+2}.

# g_1: max entry = 1, so each lambda^i is a partition with parts 0 or 1.
# lambda^i = (1^{a_i}) for some a_i >= 0.
# Interlacing: a_1 >= a_2 >= a_3 and a_3 >= a_1 - 2.
# Weight: a_1 + a_2 + a_3.
# With max = 1: at least one a_i >= 1.

# The valid triples (a_1, a_2, a_3) with a_1 >= a_2 >= a_3 >= 0, a_3 >= a_1-2, and max >= 1:
# a_1=1: a_2 in {0,1}, a_3 in {max(0,a_1-2)..a_2} = {0..a_2}
#   (1,0,0): weight 1, ok since a_3=0 >= 1-2=-1
#   (1,1,0): weight 2
#   (1,1,1): weight 3
# a_1=2: a_2 in {0,1,2}, a_3 >= 0
#   (2,0,0): a_3 >= 0, a_3 <= 0: a_3=0. Weight 2.
#   (2,1,0): a_3 >= 0, a_3 <= 1: a_3=0. Weight 3.
#   (2,1,1): weight 4.
#   (2,2,0): a_3=0. Weight 4.
#   (2,2,1): weight 5.
#   (2,2,2): weight 6.
# a_1=3: a_3 >= 1
#   (3,1,1): weight 5
#   (3,2,1): weight 6
#   (3,2,2): weight 7
#   (3,3,1): weight 7
#   (3,3,2): weight 8
#   (3,3,3): weight 9
# ...this goes on forever! g_1 is an infinite series.

# OK so g_m is not a polynomial — it's a power series. Only after multiplying
# by (q;q)_m and forming Q_n do we get polynomials.

# Let me compute g_1 as a power series:
# g_1 = sum over valid (a_1,a_2,a_3) with max=1 of q^{a_1+a_2+a_3}
# Wait, max entry = 1 means each lambda^i has parts at most 1.
# So lambda^i = (1^{a_i}) and the max part is 1 (if any a_i > 0).

# Hmm wait, I confused "max entry" with "max part". In the cylindric partition,
# "max" is max_i lambda^i_1, the largest part in any of the partitions.
# For max = 1: lambda^i_1 <= 1 for all i. So each partition is of the form (1^{a_i}).
# Then lambda^i_j = 1 if j <= a_i, 0 if j > a_i.
# Interlacing: lambda^i_j >= lambda^{i+1}_{j+c_{i+1}}.
# For c = (2,0,0): c_1=2, c_2=0, c_3=0.
# lambda^1_j >= lambda^2_{j+c_2} = lambda^2_{j+0} = lambda^2_j
# lambda^2_j >= lambda^3_{j+c_3} = lambda^3_{j+0} = lambda^3_j
# lambda^3_j >= lambda^1_{j+c_1} = lambda^1_{j+2}
# So: a_1 >= a_2 >= a_3 and a_3 >= a_1 - 2 (from lambda^3_j >= lambda^1_{j+2}).
# This means a_1 - 2 <= a_3 <= a_2 <= a_1.

# g_1 = sum_{a_1 >= 0} sum_{a_2=max(0,a_1-2)}^{a_1} sum_{a_3=max(0,a_1-2)}^{a_2} q^{a_1+a_2+a_3}
#        - 1 (subtract the zero term)

# Actually F_{c,1} includes max <= 1, so F_{c,1} = 1 + g_1 where g_1 counts max=1.
# But F_{c,0} = 1 counts max=0 (empty partitions).

# Let me compute F_{c,1} numerically from Borodin divided by appropriate factors.
# Actually, let me just compute Q_n for d=2 using the known formula.

# For d=2, k=3, c=(c_0,c_1,c_2) with sum = 2:
# Warnaar proved Q_n = q^n [n]_q for the profile giving base = 2.
# Let's verify: Q_1 = q * 1 = q (hmm, should have Q_1(1) = 2-1 = 1... no, base = (3)(4)/6-1 = 1)

# Wait: (d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 2-1 = 1 for d=2.
# So Q_n(1) = 1^n = 1 for all n? That seems wrong.

# Let me recheck. d=2, t=5. Q_n(1) = ((d+1)(d+2)/6 - 1)^n = (2-1)^n = 1.
# So Q_n(q) should be a polynomial with Q_n(1) = 1 for all n.
# Q_0 = 1. Q_1 should be a polynomial with sum 1.

# Hmm, maybe Q_1 = q or Q_1 = 1. Let me compute.
# Actually for d=2, there are only a few compositions:
# (2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1) — 6 profiles.

# Let me use the Borodin products more carefully.
# For c=(1,1,0): c_1=1, c_2=1, c_3=0, d=2, t=5.
# First product pairs (i,j):
#   (1,2): c_1=1, d_{2,2}=c_2=1, j-i=1: m=1: a=1+1+1=3
#   (1,3): c_1=1, d_{2,3}=c_2+c_3=1, j-i=2: m=1: a=1+1+2=4
#   (2,3): c_2=1, d_{3,3}=c_3=0, j-i=1: m=1: a=1+0+1=2
# Second product: (3,2): c_3=0: empty
# F_{(1,1,0)} = 1/((q^3;q^5)(q^4;q^5)(q^2;q^5)(q^5;q^5))
F110 = 1 / (qpoch(3,5,50) * qpoch(4,5,50) * qpoch(2,5,50) * qpoch(5,5,50))
print(f"\nF_{{(1,1,0)}} = {F110}")

# For d=2, k=3, this is equivalent to the first Rogers-Ramanujan identity
# (or close to it). Let me check: 1/((q^2;q^5)(q^3;q^5)(q^4;q^5)(q^5;q^5))
# Hmm, that's 1/((q^2,q^3,q^4,q^5;q^5)_inf) = 1/((q^2;q)_3 * (q^5;q^5))... no.

# Let me just compute Q_n for various small d values numerically.
# I'll compute h_m and then Q_n.

def compute_h_m_numerically(c, m_max, prec=80):
    """Compute h_m(q) for a given profile c by brute force enumeration
    of cylindric partitions with max entry exactly m."""
    k = len(c)
    d = sum(c)
    
    # This is only feasible for small m and small d.
    # A cylindric partition with max entry m has each lambda^i a partition
    # with parts in {0, 1, ..., m}.
    
    # For max = m: at least one lambda^i has a part equal to m.
    # The constraint is cyclic interlacing.
    
    # For max <= m: enumerate all valid tuples.
    # Use the transfer matrix approach: each "column" j has state
    # (lambda^1_j, ..., lambda^k_j) with entries in {0,...,m}.
    # Moving from column j to column j+1, the interlacing conditions
    # constrain transitions.
    
    # State = (v_1, ..., v_k) with 0 <= v_i <= m.
    # Transition from state u to state v (column j to j+1):
    #   v_i <= u_i for all i (partitions are decreasing in j)
    #   AND the cyclic interlacing: for each i, u_i >= v_{sigma(i)}
    #   where sigma depends on c.
    
    # Actually, the interlacing is:
    # lambda^i_j >= lambda^{i+1}_{j + c_{i+1}}
    # This relates different columns, making it more complex.
    
    # For a simpler computation, let me use the direct approach:
    # A cylindric partition is a periodic skew plane partition.
    # With max <= m, it's a lozenge tiling of a cylinder.
    
    # Actually, let me use the generating function approach.
    # F_{c,m}(q) = sum over all cylindric partitions with max <= m of q^{weight}.
    # We can compute this via the transfer matrix (column by column).
    
    # For the transfer matrix, we think of a cylindric partition as a sequence
    # of "slices". Each slice is a column (lambda^1_j, ..., lambda^k_j).
    # The partition condition requires non-increasing columns.
    # The cylindric condition wraps around.
    
    # This is complex but well-known. Let me use a recursion instead.
    
    # Simpler: use the fact that for c = (c_0, ..., c_{k-1}),
    # a cylindric partition with max <= m can be encoded as a path on a graph.
    # The states are the "profiles" at each column boundary.
    
    # For k=3 and max <= m, the state at column j is (a,b,c) with
    # 0 <= a, b, c <= m. The transfer matrix has size (m+1)^3.
    
    # But the interlacing introduces offsets: lambda^i_j >= lambda^{i+1}_{j+c_{i+1}}.
    # This means different rows of the cylindric partition are shifted.
    
    # I'll use a different approach: compute via Borodin product and the y-coefficient extraction.
    pass

# Let me try a completely different route: directly compute Q_n using the
# Corteel-Welsh matrix system. I'll implement it for small d.

print("\n" + "="*70)
print("Computing Q_n for d=2 via direct cylindric partition enumeration")
print("="*70)

def cylindric_partitions_bounded(c, N, weight_max=50):
    """
    Enumerate cylindric partitions of profile c with max <= N.
    Returns a dictionary: weight -> count.
    
    c = (c_0, c_1, ..., c_{k-1})
    A cylindric partition is (lambda^0, lambda^1, ..., lambda^{k-1})
    where each lambda^i is a partition.
    Interlacing: lambda^i_j >= lambda^{i+1 mod k}_{j + c_{(i+1) mod k}} for all i,j.
    Max: max_i lambda^i_1 <= N.
    """
    k = len(c)
    d = sum(c)
    
    # Each lambda^i is a partition with parts <= N.
    # We need to enumerate all valid k-tuples.
    # For small N and small parts, we can represent each partition
    # by its first few parts (since they must be <= N and decreasing).
    
    # A partition with parts <= N and weight <= weight_max:
    # lambda = (lambda_1, lambda_2, ...) with N >= lambda_1 >= lambda_2 >= ... >= 0
    # and sum <= weight_max.
    
    # Generate all such partitions up to weight_max.
    from sage.combinat.partition import Partitions
    
    # Generate partitions with parts <= N and total weight <= weight_max
    def gen_partitions(N_bound, wt_max):
        result = [Partition([])]  # empty partition
        for w in range(1, wt_max + 1):
            for p in Partitions(w, max_part=N_bound):
                result.append(p)
        return result
    
    all_parts = gen_partitions(N, weight_max)
    print(f"  Generated {len(all_parts)} partitions with max part <= {N}, weight <= {weight_max}")
    
    # Now check interlacing conditions for all k-tuples.
    # This is exponential in k, only feasible for very small cases.
    
    # For k=3 and small N:
    # Condition: for i = 0, 1, 2 (cyclic):
    #   lambda^i_j >= lambda^{(i+1)%3}_{j + c_{(i+1)%3}} for all j >= 1
    
    def interlaces(lam, mu, shift):
        """Check lambda_j >= mu_{j+shift} for all j >= 1."""
        for j in range(1, max(len(lam), len(mu) + shift) + 2):
            lam_j = lam[j-1] if j <= len(lam) else 0
            mu_idx = j + shift
            mu_js = mu[mu_idx - 1] if mu_idx >= 1 and mu_idx <= len(mu) else 0
            if lam_j < mu_js:
                return False
        return True
    
    weight_counts = {}
    total = 0
    
    if k == 3:
        for l0 in all_parts:
            for l1 in all_parts:
                w01 = sum(l0) + sum(l1)
                if w01 > weight_max:
                    continue
                # Check lambda^0_j >= lambda^1_{j + c_1}
                if not interlaces(l0, l1, c[1]):
                    continue
                for l2 in all_parts:
                    wt = w01 + sum(l2)
                    if wt > weight_max:
                        continue
                    # Check lambda^1_j >= lambda^2_{j + c_2}
                    if not interlaces(l1, l2, c[2]):
                        continue
                    # Check lambda^2_j >= lambda^0_{j + c_0}
                    if not interlaces(l2, l0, c[0]):
                        continue
                    weight_counts[wt] = weight_counts.get(wt, 0) + 1
                    total += 1
    
    return weight_counts, total

# d=2, c=(2,0,0)
c = (2, 0, 0)
N_vals = [0, 1, 2, 3]

PS = PowerSeriesRing(QQ, 'q', default_prec=50)
qps = PS.gen()

F_bounded = {}
for N in N_vals:
    counts, total = cylindric_partitions_bounded(c, N, weight_max=30)
    poly = sum(cnt * qps^wt for wt, cnt in counts.items())
    F_bounded[N] = poly
    print(f"F_{{c,{N}}}(q) = {poly}")
    print(f"  F_{{c,{N}}}(1) = {total}")

# Compute g_m = F_{c,m} - F_{c,m-1}
g = {}
g[0] = F_bounded[0]
for m in range(1, max(N_vals) + 1):
    if m in F_bounded:
        g[m] = F_bounded[m] - F_bounded[m-1]
        print(f"g_{m} = {g[m]}")

# Compute h_m = (q;q)_m * g_m
def q_factorial(m, prec=50):
    PS2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = PS2.gen()
    result = PS2(1)
    for i in range(1, m+1):
        result *= (1 - q2^i)
    return result

h = {}
for m in g:
    h[m] = q_factorial(m) * g[m]
    print(f"h_{m} = {h[m]}")

# Compute Q_n
def q_binomial(n, j, prec=50):
    PS2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = PS2.gen()
    if j < 0 or j > n:
        return PS2(0)
    result = PS2(1)
    for i in range(1, j+1):
        result *= (1 - q2^(n-j+i)) / (1 - q2^i)
    return result

print("\n--- Q_n for d=2, c=(2,0,0) ---")
for n in range(min(4, max(N_vals) + 1)):
    Qn = PS(0)
    for j in range(n + 1):
        if (n - j) not in h:
            break
        sign = (-1)^j
        shift = j * (j + 1) // 2
        qbin = q_binomial(n, j)
        Qn += sign * qps^shift * qbin * h[n - j]
    else:
        print(f"Q_{n} = {Qn}")
        print(f"Q_{n}(1) = {sum(Qn[i] for i in range(50))}")

