"""
Agent C: Investigate multisum decomposition of Q_n.

Key question: For d=4 (k=2), Q_1 = 2q + q^2 + q^3 for profile (2,1,1).
Can we express this as a DOUBLE SUM in q-binomial coefficients?

The evaluation Q_n(1) = ((d+1)(d+2)/6 - 1)^n.
For d=4: (5*6/6 - 1) = (5-1) = 4. So Q_n(1) = 4^n.

Since the k=1 formula gives Q_n = q^{n(n+a)} (a single monomial!),
the k=2 formula should give Q_n as a sum of q-binomials times q-powers.

Strategy: Compute Q_n for multiple profiles at d=4 and d=5,
then try to recognize the structure as a double sum.

For d=4, the profiles split into orbits under C_3 rotation:
- (4,0,0), (0,4,0), (0,0,4) -- orbit of size 3
- (3,1,0), (1,0,3), (0,3,1) -- orbit of size 3
- (3,0,1), (0,1,3), (1,3,0) -- orbit of size 3
- (2,2,0), (2,0,2), (0,2,2) -- orbit of size 3
- (2,1,1), (1,1,2), (1,2,1) -- orbit of size 3
Total: 15 compositions, 5 orbits.
"""
from sage.all import *
from itertools import combinations

def compute_Qn(d, c_target, n_max, PREC=100):
    """Compute Q_1, Q_2, ..., Q_{n_max} for profile c_target.
    Adapted from Agent B's working code."""
    r = 3
    R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
    q = R.gen()
    
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            compositions.append((c0, c1, c2))
    N = len(compositions)
    comp_idx = {c: i for i, c in enumerate(compositions)}
    
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
    
    Rx = PolynomialRing(QQ, 'x')
    x_var = Rx.gen()
    A_poly = matrix(Rx, N, N, 0)
    
    for ic, c in enumerate(compositions):
        I_c = {i for i in range(r) if c[i] > 0}
        if not I_c:
            continue
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                jcJ = comp_idx[cJ]
                A_poly[ic, jcJ] += sign * x_var**size
    
    def eval_A(val):
        A_eval = matrix(R, N, N)
        for i in range(N):
            for j in range(N):
                poly = A_poly[i,j]
                v = R(0)
                for k, coeff in enumerate(poly.list()):
                    v += coeff * val**k
                A_eval[i,j] = v
        return A_eval
    
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    
    v = vector(R, [R(1)] * N)
    idx = comp_idx[c_target]
    F_vals = [R(1)]
    
    for m in range(1, n_max + 1):
        Am = eval_A(q**m)
        Bm = I_mat - Am
        v = Bm.inverse() * v
        F_vals.append(v[idx])
    
    g_vals = [R(1)]
    for m in range(1, n_max + 1):
        g_vals.append(F_vals[m] - F_vals[m-1])
    
    def qpoch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**i)
        return result
    
    Q_vals = []
    for n in range(1, n_max + 1):
        Qn = R(0)
        for j in range(n + 1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_vals[j]
        Qn *= qpoch(n)
        Q_vals.append(Qn)
    
    return Q_vals

def qbinom(n, k, q):
    """q-binomial coefficient [n choose k]_q as a polynomial."""
    if k < 0 or k > n or n < 0:
        return q.parent()(0)
    num = prod(1 - q**i for i in range(1, n+1))
    den = prod(1 - q**i for i in range(1, k+1)) * prod(1 - q**i for i in range(1, n-k+1))
    return num / den

# Compute Q_n for all profiles at d=4
print("=" * 70)
print("Q_n for d=4, all C_3 orbit representatives")
print("=" * 70)

d = 4
representatives = [(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,1,1)]

R = PowerSeriesRing(QQ, 'q', default_prec=80)
q = R.gen()

for c in representatives:
    Qs = compute_Qn(d, c, 4, PREC=80)
    print(f"\nProfile c = {c}:")
    for i, Q in enumerate(Qs):
        n = i + 1
        coeffs = [Q[j] for j in range(80)]
        max_deg = max((j for j in range(80) if coeffs[j] != 0), default=0)
        poly = coeffs[:max_deg+1]
        print(f"  Q_{n}(1) = {sum(poly)}, deg = {max_deg}")
        if n <= 2:
            # Show the polynomial
            terms = [(j, poly[j]) for j in range(len(poly)) if poly[j] != 0]
            print(f"    Q_{n} = " + " + ".join(f"{c}*q^{j}" if c != 1 else f"q^{j}" for j, c in terms))

# Now try to fit Q_1 as a q-binomial sum
print()
print("=" * 70)
print("Attempting to decompose Q_1 for d=4 as multisum")
print("=" * 70)

# For d=4, c=(2,1,1): Q_1 = 2q + q^2 + q^3
# Q_1(1) = 4
# Natural guess: Q_1 = sum_{i,j} q^{f(i,j)} [a choose b]_q
# Since Q_1(1) = 4 = 2^2, and Q_1 has 3 terms with sum 4,
# maybe it's a double sum?

# Actually, let me think about what Q_1 means.
# Q_1 = (q;q)_1 * [z^1] ((zq;q)_inf * F_c(z,q))
# = (1-q) * [z^1] ((zq;q)_inf * F_c(z,q))
# = (1-q) * (g_1 - g_0 * q / (1-q))  ... no, let me compute directly.
# [z^1] (zq;q)_inf * F_c = g_1 * 1 + g_0 * (-q)
# (since (zq;q)_inf = 1 - zq - z^2 q^3/(1-q) + ..., so [z^0] = 1, [z^1] = -q)
# Q_1 = (1-q) * (g_1 - q * g_0) = (1-q) * (g_1 - q)

# For c=(2,1,1): g_1 is the number of CPPs of profile (2,1,1) with max = 1.
# These are sequences of 3 partitions satisfying interlacing with max part 1.

# Actually, let me look at Q_1 more structurally.
# The KNOWN FORMULA for Q_1 is proven (injection lemma from Layer 3):
# Q_1 = (1-q) * g_1 + q

# Wait, Agent A said Q_1 >= 0 is proved. Let me check the Layer 3 results.
# The injection lemma gives: g_m >= q * g_{m-1}, which means g_m - q*g_{m-1} >= 0.
# And Q_n involves an alternating sum, so for n=1:
# Q_1 = (1-q) * [g_1 * 1 + g_0 * (-q)] = (1-q)(g_1 - q)

# Hmm, (1-q)(g_1 - q) with Q_1(1) = 4 means g_1(1) - 1 = 4/0... 
# that doesn't make sense. Let me just compute directly.

print("\nDirect Q_1 computation for c=(2,1,1):")
print("Q_1 = (q;q)_1 * sum_{m=0}^1 (-1)^{1-m} q^{binom(2-m,2)} / (q;q)_{1-m} * g_m")
print("    = (1-q) * [(-1)^1 q^1 / (1-q) * 1 + (-1)^0 * 1 * g_1]")
print("    = (1-q) * [-q/(1-q) + g_1]")
print("    = (1-q) * g_1 - q")

# So Q_1 = (1-q)*g_1 - q. With Q_1 = 2q + q^2 + q^3, we get
# (1-q)*g_1 = 3q + q^2 + q^3
# g_1 = (3q + q^2 + q^3)/(1-q) = 3q + 4q^2 + 5q^3 + ...  (power series!)

# Actually g_1 is the generating function for CPPs with max part 1.
# These are interlacing sequences of partitions where each part is 0 or 1.
# This is essentially a configuration of a binary cylindric partition.

# Now: Q_1 = (1-q)*g_1 - q where g_1 is a power series.
# Q_1 is claimed to be a polynomial. So (1-q)*g_1 must be a polynomial plus q.

# Let me compute g_1 and verify
Qs = compute_Qn(4, (2,1,1), 1, PREC=40)
print(f"\nQ_1 = {Qs[0].add_bigoh(20)}")

# Compute g_1 from the matrix formula
R2 = PowerSeriesRing(QQ, 'q', default_prec=40)
q2 = R2.gen()

# Actually, let me focus on understanding the STRUCTURE of Q_n for d=5 (modulus 8)
# since that's the first case where CDU proved new identities.

print()
print("=" * 70)
print("Q_n for d=5, selected profiles")
print("=" * 70)

d = 5
reps5 = [(3,1,1), (2,2,1), (4,1,0), (5,0,0), (3,2,0)]

for c in reps5:
    Qs = compute_Qn(d, c, 3, PREC=100)
    print(f"\nProfile c = {c}:")
    for i, Q in enumerate(Qs):
        n = i + 1
        coeffs = [Q[j] for j in range(100)]
        max_deg = max((j for j in range(100) if coeffs[j] != 0), default=0)
        poly = coeffs[:max_deg+1]
        print(f"  Q_{n}(1) = {sum(poly)}, deg = {max_deg}")
        if n <= 2:
            terms = [(j, poly[j]) for j in range(len(poly)) if poly[j] != 0]
            print(f"    Q_{n} = " + " + ".join(f"{c}*q^{j}" if c != 1 else f"q^{j}" for j, c in terms))

# Compute Q_1(1) = (d+1)(d+2)/6 - 1 for d=5: 6*7/6 - 1 = 7-1 = 6
print(f"\nExpected Q_1(1) for d=5: {(5+1)*(5+2)//6 - 1}")

