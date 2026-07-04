"""
Agent C: Investigate signed involution on the extended path space.

Q_n(c) = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * F_{c,j}

where F_{c,j} = e_c^T * prod_{k=1}^j (I - A(q^k))^{-1} * v_0.

By the Adjugate Monomial Theorem, (I-A(q^k))^{-1} = adj(I-A(q^k))/(1-q^{3k}).
And adj(I-A(q^k))[c,c'] = q^{k * EMD(c,c')}.

So F_{c,j} = sum over paths (c_0,...,c_{j-1}) with c_j = c of
  q^{sum_{k=1}^j k * EMD(c_k, c_{k-1})} / (q^3; q^3)_j

And P_j = (q^3;q^3)_j * F_{c,j} = sum over paths of q^{EMD weight}.

Therefore:
Q_n(c) = sum_{j=0}^n (-1)^{n-j} q^{binom(n-j+1,2)} [n choose j]_q * P_j / (q^3;q^3)_j

The key insight from the involution approach: consider PAIRS (path, subset)
where:
- path = (c_0, ..., c_{j-1}) of length j (with c_j = c) contributing q^{EMD weight}
- subset = S in binom([n] setminus [j], ...) encoding the (zq;q)_inf factor

The q^{binom(n-j+1,2)} / (q;q)_{n-j} factor comes from expanding (zq;q)_inf.
More precisely, (zq;q)_inf contributes z^{n-j} q^{binom(n-j+1,2)} / (q;q)_{n-j}
with sign (-1)^{n-j}.

Actually, let me think about this differently.
The q-binomial [n choose j]_q counts lattice paths in a j x (n-j) grid.
So the TOTAL weight of a contribution to Q_n is:
  q^{binom(n-j+1,2)} * q^{lattice_path_weight} * q^{EMD_weight}

with sign (-1)^{n-j}.

A signed involution would pair terms with different j-values.

ALTERNATIVE: Think of [n choose j]_q / (q^3;q^3)_j directly.
[n choose j]_q = (q;q)_n / ((q;q)_j * (q;q)_{n-j}).
So [n choose j]_q / (q^3;q^3)_j = (q;q)_n / ((q;q)_j * (q;q)_{n-j} * (q^3;q^3)_j).

Hmm, this is getting complicated. Let me try a more computational approach.
For n=2, d=4, c=(2,1,1), enumerate ALL contributions to Q_2.
"""
from sage.all import *
from itertools import combinations

# Use Agent B's compute_Qn function
def compute_Q_and_P(d, c_target, n_max, PREC=100):
    """Compute both Q_n and P_n, plus the individual terms."""
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
    
    def qbinom(n, k):
        if k < 0 or k > n:
            return R(0)
        return qpoch(n) / (qpoch(k) * qpoch(n-k))
    
    # Compute P_j = (q^3;q^3)_j * F_{c,j}
    def q3poch(n):
        result = R(1)
        for i in range(1, n+1):
            result *= (1 - q**(3*i))
        return result
    
    P_vals = []
    for j in range(n_max + 1):
        P_vals.append(q3poch(j) * F_vals[j])
    
    # Compute Q_n and show individual terms
    Q_results = []
    for n in range(1, n_max + 1):
        print(f"\nQ_{n} decomposition for c={c_target}:")
        terms = []
        Qn = R(0)
        for j in range(n + 1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            # Q_n = sum (-1)^{n-j} q^{tri} [n,j]_q * F_{c,j}
            #     = sum (-1)^{n-j} q^{tri} [n,j]_q * P_j / (q^3;q^3)_j
            term = sign * q**tri * qbinom(n, j) * F_vals[j]
            Qn += term
            
            # Print the term
            term_poly = (term * qpoch(n)).truncate(40)
            print(f"  j={j}: sign=({'+' if sign > 0 else '-'}) q^{tri} * [n,j] * F_j")
            term_contrib = (qpoch(n) * sign * q**tri * qbinom(n, j) * F_vals[j])
            print(f"    contribution to Q_n = {term_contrib.add_bigoh(20)}")
            
            terms.append(term)
        
        Qn = qpoch(n) * Qn
        print(f"  TOTAL Q_{n} = {Qn.add_bigoh(20)}")
        Q_results.append(Qn)
    
    return Q_results, P_vals, F_vals

# Test for d=4, c=(2,1,1)
print("=" * 70)
print("d=4, c=(2,1,1)")
print("=" * 70)
Qs, Ps, Fs = compute_Q_and_P(4, (2,1,1), 3, PREC=50)

# Now let me also check: what is the relationship between Q_n and
# the Ehrhart polynomial of some polytope?

# For Q_1: we showed Q_1 = (1-q)*g_1 - q where g_1 = F_{c,1} - 1.
# g_1 stabilizes to 5q^k per unit weight for large k.
# (1-q)*g_1 truncates this to a polynomial.
# Q_1 = (1-q)*g_1 - q = "first differences of g_1" minus q.
# The "first differences" of a function that stabilizes give a polynomial.
# This is exactly the Ehrhart polynomial interpretation!

# For Q_2: more complex. Let me look at the structure.

# KEY IDEA: Can I express Q_n as a POSITIVE LINEAR COMBINATION of 
# terms involving q-binomial coefficients?

# For d=2, Q_n = q^{n^2} = q^{n choose 2 + n/something}...
# This is a monomial. For d=4, Q_1 = 2q + q^2 + q^3.

# Let me try to decompose Q_1 = sum_{i} q^{e_i} for appropriate exponents.
# Q_1 for c=(2,1,1) = 2q + q^2 + q^3. The exponents are 1,1,2,3 (with multiplicity).
# These are the EMD distances? Let me check.

# EMD(c', c) for c=(2,1,1) and all c':
# Actually, Q_1 depends on the LATTICE POINTS of the interlacing cone 
# "truncated" by the (zq;q)_inf factor. The (zq;q)_inf acts as a sieve
# that picks out certain lattice points.

# Let me try a completely different approach: look for a COMBINATORIAL 
# INTERPRETATION of Q_n directly.

print()
print("=" * 70)
print("Looking for combinatorial interpretation of Q_1")
print("=" * 70)

# Q_1(c) = (1-q) * sum_{j=0}^1 (-1)^{1-j} q^{binom(2-j,2)} / (q;q)_{1-j} * g_j
# = (1-q) * [-q * 1/(1-q) * 1 + 1 * g_1]
# = (1-q)*g_1 - q

# For c=(2,1,1): g_1 = 3q + 4q^2 + 5q^3 + 5q^4 + ...
# (1-q)*g_1 = 3q + q^2 + q^3 + 0 + 0 + ... (polynomial!)
# Q_1 = 3q + q^2 + q^3 - q = 2q + q^2 + q^3

# The polynomial (1-q)*g_1 counts: first differences of lattice points in the cone.
# Specifically: (1-q)*g_1 at degree k = g_1[k] - g_1[k-1].
# g_1[0] = 0, g_1[1] = 3, g_1[2] = 4, g_1[3] = 5, g_1[k] = 5 for k >= 3.
# Differences: 3, 1, 1, 0, 0, ... -> polynomial 3q + q^2 + q^3.

# So (1-q)*g_1 is the "boundary" of the cone: it counts how many NEW lattice 
# points appear at each weight level.

# And Q_1 = (boundary count) - q.

# What is the "q" subtraction? It corresponds to the g_0 term in the formula.
# g_0 = 1 (the empty partition). The subtraction q removes one lattice point 
# from weight 1. Which one? The one that's "already counted" by the lower-order
# term in the (zq;q)_inf expansion.

# COMBINATORIAL INTERPRETATION of Q_1:
# Q_1(c) = #{lattice points (a_0,a_1,a_2) in the interlacing cone at weight w,
#           that are NEW at level 1 (i.e., not accessible at level 0)}
#         minus 1 at weight 1 (from the empty partition correction).

# More precisely: Q_1 counts the "Hilbert function first difference" of the cone
# minus the empty partition correction.

# This is interesting but doesn't immediately generalize to Q_n.

# Let me now focus on understanding Q_2 structure.
print()
print("=" * 70)
print("Structure of Q_2 for d=4")
print("=" * 70)

# Q_2 = (q;q)_2 * sum_{j=0}^2 (-1)^{2-j} q^{binom(3-j,2)} / (q;q)_{2-j} * g_j
# = (1-q)(1-q^2) * [q^3 / ((1-q)(1-q^2)) * 1 - q / (1-q) * g_1 + 1 * g_2]
# = q^3 - (1-q^2)*q*g_1 + (1-q)(1-q^2)*g_2

# Hmm, let me just look at the COEFFICIENTS.
R = PowerSeriesRing(QQ, 'q', default_prec=30)
q = R.gen()

# From the output above:
# Q_2 for (2,1,1) = q^3 + 3*q^4 + 2*q^5 + 3*q^6 + 2*q^7 + 2*q^8 + q^9 + q^10 + q^12
# Sum = 1+3+2+3+2+2+1+1+1 = 16 = 4^2. Check.

# The degree is 12. Minimum degree is 3.

# For comparison, P_2 = (q^3;q^3)_2 * F_{c,2} should be manifestly positive.
# P_2 = sum over paths (c_0, c_1) with c_2 = c of q^{EMD(c_1,c_0) + 2*EMD(c,c_1)}.

# Let me compute P_2 via the path formula and compare.
# Actually Agent B already verified P_n >= 0. The question is about Q_n.

# Let me now investigate a DIFFERENT approach: the q-difference equation.
# From the functional equation for H_c(z,q), we get:
# H_c(z,q) = sum_{|J|=1} H_{c(J)}(zq,q) 
#           - sum_{|J|=2} (1-zq) H_{c(J)}(zq^2,q)
#           + sum_{|J|=3} (1-zq)(1-zq^2) H_c(zq^3,q)
# 
# This means: Q_n(c) / (q;q)_n = sum_{|J|=1} q^n Q_n(c(J)) / (q;q)_n
#             - sum_{|J|=2} stuff involving Q_n and Q_{n-1} at shifted profiles
#             + ...
#
# Let me derive the EXPLICIT RECURRENCE for Q_n.

# [z^n] H_c(z,q) = Q_n(c) / (q;q)_n.
# 
# From H_c(z,q) = sum_{|J|=1} H_{c(J)}(zq,q) - ...
# 
# [z^n] H_{c(J)}(zq, q) = q^n * [z^n] H_{c(J)}(z, q) = q^n * Q_n(c(J)) / (q;q)_n
# 
# [z^n] (1-zq) H_{c(J)}(zq^2, q) = q^{2n} * Q_n(c(J))/(q;q)_n 
#                                   - q * q^{2(n-1)} * Q_{n-1}(c(J))/(q;q)_{n-1}
#                                 = q^{2n} Q_n(c(J))/(q;q)_n 
#                                   - q^{2n-1} Q_{n-1}(c(J))/(q;q)_{n-1}
#
# [z^n] (1-zq)(1-zq^2) H_{c(J)}(zq^3, q) = 
#   q^{3n} Q_n/(q;q)_n - q(q^{3(n-1)}) Q_{n-1}/(q;q)_{n-1} 
#   - q^2(q^{3(n-1)}) Q_{n-1}/(q;q)_{n-1} + q^3(q^{3(n-2)}) Q_{n-2}/(q;q)_{n-2}
# = q^{3n} Q_n/(q;q)_n - (q+q^2)q^{3n-3} Q_{n-1}/(q;q)_{n-1}
#   + q^3 q^{3n-6} Q_{n-2}/(q;q)_{n-2}

# Multiplying through by (q;q)_n:
# Q_n(c) = sum_{|J|=1} q^n Q_n(c(J))
#         - sum_{|J|=2} [q^{2n} Q_n(c(J)) - q^{2n-1} (1-q^n) Q_{n-1}(c(J))]
#         + [q^{3n} Q_n(c) - (q+q^2)q^{3n-3} (1-q^n) Q_{n-1}(c)
#            + q^3 q^{3n-6} (1-q^n)(1-q^{n-1}) Q_{n-2}(c)]

# Wait, (q;q)_n / (q;q)_{n-1} = 1 - q^n. And (q;q)_n / (q;q)_{n-2} = (1-q^n)(1-q^{n-1}).

# This is getting messy. Let me compute it numerically for d=4 and verify.

print("Verifying system recurrence for Q_n, d=4:")
print()

# Compute Q_n for ALL profiles at d=4, n=1,2,3
from itertools import combinations as combs

d = 4
compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        compositions.append((c0, c1, d-c0-c1))
N = len(compositions)
comp_idx = {c: i for i, c in enumerate(compositions)}

def shift_profile(c, J):
    result = list(c)
    J_set = set(J)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

# Compute all Q_n using Agent B's method
Rx = PolynomialRing(QQ, 'x')
x_var = Rx.gen()
A_poly = matrix(Rx, N, N, 0)

for ic, c in enumerate(compositions):
    I_c = {i for i in range(3) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combs(sorted(I_c), size):
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

# Compute ALL F_{c,m} vectors for m up to 4
v_all = [vector(R, [R(1)] * N)]
for m in range(1, 5):
    Am = eval_A(q**m)
    Bm = I_mat - Am
    v_next = Bm.inverse() * v_all[-1]
    v_all.append(v_next)

# g_m vectors
g_all = [vector(R, [R(1)] * N)]
for m in range(1, 5):
    g_all.append(v_all[m] - v_all[m-1])

# Q_n for all profiles
def qpoch(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

Qn_all = {}  # Qn_all[(c, n)] = Q_n(c)
for n in range(1, 4):
    for ci, c in enumerate(compositions):
        Qn = R(0)
        for j in range(n+1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_all[j][ci]
        Qn *= qpoch(n)
        Qn_all[(c, n)] = Qn

# Now verify the recurrence:
# Q_n(c) = sum_{|J|=1} q^n Q_n(c(J)) - sum_{|J|=2} [...] + sum_{|J|=3} [...]
# 
# Let me compute the RHS of the recurrence for a specific profile and check.
c = (2,1,1)
n = 2

print(f"Testing recurrence for c={c}, n={n}:")
print(f"  LHS: Q_{n}({c}) = {Qn_all[(c,n)].add_bigoh(20)}")

# RHS: 
# Term 1: sum_{|J|=1} q^n Q_n(c(J))
I_c = {i for i in range(3) if c[i] > 0}
term1 = R(0)
for J in combs(sorted(I_c), 1):
    cJ = shift_profile(c, set(J))
    if min(cJ) < 0 or cJ not in comp_idx:
        continue
    term1 += q**n * Qn_all[(cJ, n)]
print(f"  Term 1 (|J|=1): {term1.add_bigoh(20)}")

# Term 2: -sum_{|J|=2} [q^{2n} Q_n(cJ) - q^{2n-1}(1-q^n) Q_{n-1}(cJ)]
term2 = R(0)
for J in combs(sorted(I_c), 2):
    cJ = shift_profile(c, set(J))
    if min(cJ) < 0 or cJ not in comp_idx:
        continue
    t = q**(2*n) * Qn_all[(cJ, n)] - q**(2*n-1) * (1-q**n) * Qn_all[(cJ, n-1)]
    term2 -= t
print(f"  Term 2 (|J|=2): {term2.add_bigoh(20)}")

# Term 3: + [q^{3n} Q_n(c) - (q+q^2)q^{3n-3}(1-q^n) Q_{n-1}(c) 
#            + q^3 q^{3n-6}(1-q^n)(1-q^{n-1}) Q_{n-2}(c)]
# But only if |I_c| = 3 (all parts > 0)
if len(I_c) == 3:
    term3_val = q**(3*n) * Qn_all[(c, n)]
    if n >= 1:
        term3_val -= (q + q**2) * q**(3*n-3) * (1-q**n) * Qn_all[(c, n-1)]
    if n >= 2:
        term3_val += q**3 * q**(3*n-6) * (1-q**n) * (1-q**(n-1)) * Qn_all[(c, n-2)]
    # Note: Q_0 = 1 (since [z^0] H = 1 and (q;q)_0 = 1)
    print(f"  Term 3 (|J|=3): {term3_val.add_bigoh(20)}")
    
    RHS = term1 + term2 + term3_val
else:
    RHS = term1 + term2

print(f"  RHS total: {RHS.add_bigoh(20)}")
print(f"  LHS - RHS: {(Qn_all[(c,n)] - RHS).add_bigoh(20)}")

