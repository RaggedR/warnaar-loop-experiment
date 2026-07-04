"""
Agent A: Use Warnaar's A_2 invariance identity to prove Q_n >= 0.

The key identity (Warnaar 2023, eq. around chunk_109):
sum_{0 <= m <= n <= n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n]_q [n_0-n+m,m_0]_q 
    * Phi_{n,m}(z,w;q) = Phi_{n_0,m_0}(z,w;q)

where Phi_{n,m}(z,w;q) = [n,m]_q / ((zq)_{n-m} (wq)_n)

This is the BOUNDED version that gives F_c(z,q) for rank-3 cylindric partitions.

The infinite-level version (n_0 -> inf) gives:
sum_{n_1,n_2,... >= 0, m_1,m_2,... >= 0}
    (1/(q)_{n_1}) prod_{i>=1} z^{n_i-m_i} w^{m_i} q^{n_i^2-n_i*m_i+m_i^2}
    [n_i, n_{i+1}] [n_i-n_{i+1}+m_{i+1}, m_i]
= 1/((zq)_inf (wq)_inf)

For profile c = (c_0, c_1, c_2), the two variables z,w correspond to
different profile components. Specifically:
- For profiles of the form c = (a+1, 1-a, 0), z relates to the first component
  and the sum is a single sum (k=1 case).
- For general c, we need the bounded version with specific n_0, m_0.

Let me verify: for c = (2,1,1), d=4, what are the parameters?
This corresponds to the rank-3 case with the shape lambda/mu/d notation.

From Warnaar's notation:
- lambda = (lambda_1, lambda_2, lambda_3) gives the row lengths of the skew shape
- mu = (mu_1, mu_2, mu_3) gives the inner boundary
- d is the "level" (circumference - rank)

For profile c = (c_0, c_1, c_2) = (2,1,1):
The cylindric partition has circumference t = 3 + 4 = 7.
lambda = (c_0, c_0+c_1, c_0+c_1+c_2) - shifted? No...

Actually the connection between profile c and shape lambda/mu is:
c_i = lambda_{i+1} - mu_i (or similar). Let me look at this more carefully.

For the rank-2 case: GK_{(L+b+1,L)/(1-a,0)/3}(z,q) 
corresponds to a specific shape with d=3.
For the rank-3 case, the shapes are more complex.

Let me focus on VERIFYING the Warnaar identity numerically
and then extracting Q_n from it.
"""
from sage.all import *

PREC = 40
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def qpoch_series(m, prec=PREC):
    result = R(1)
    for i in range(1, m+1): result *= (1 - q**i)
    return result

def qbinom(n, m, prec=PREC):
    if m < 0 or m > n: return R(0)
    return qpoch_series(n, prec) / (qpoch_series(m, prec) * qpoch_series(n-m, prec))

# The Warnaar invariance identity for A_2:
# Phi_{n_0, m_0}(z, w; q) = sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} 
#     [n_0, n] [n_0-n+m, m_0] Phi_{n,m}(z,w;q)
# where Phi_{n,m} = [n,m] / ((zq)_{n-m} (wq)_n)

# At z = 0: only the n = m term survives.
# sum_{m=0}^{n_0} w^m q^{m^2} [n_0, m] [n_0, m_0] Phi_{m,m}(0,w;q)
# = Phi_{n_0, m_0}(0, w; q)

# Phi_{m,m}(0,w;q) = [m,m] / ((0*q)_0 (wq)_m) = 1/(wq)_m
# Phi_{n_0,m_0}(0,w;q) = [n_0,m_0] / ((0*q)_{n_0-m_0} (wq)_{n_0})
# But (0*q)_k = (0;q)_k = 1 for all k.
# Wait: (zq;q)_k = prod_{j=0}^{k-1}(1-zq^{j+1}). At z=0: = 1 for all k.
# So Phi_{n,m}(0,w;q) = [n,m] / (wq)_n.
# Then the identity at z=0:
# sum_{m=0}^{n_0} w^m q^{m^2} [n_0,m] [n_0-m+m, m_0] [m,m] / (wq)_m
# = [n_0, m_0] / (wq)_{n_0}
# sum_{m=0}^{n_0} w^m q^{m^2} [n_0,m] [n_0, m_0] / (wq)_m = [n_0,m_0]/(wq)_{n_0}
# This simplifies to: sum_m w^m q^{m^2} [n_0,m] / (wq)_m = 1/(wq)_{n_0}
# This IS the q-binomial theorem!

# OK so the Warnaar identity is a 2-variable generalization.

# For the connection to Q_n:
# F_c(z,q) = GK_c(z,q) involves the UNBOUNDED version (n_0 -> inf).
# The BOUNDED version GK_{c,N}(q) = F_{c,N}(q) uses the identity at finite n_0.

# Q_n involves F_c(z,q) multiplied by (zq;q)_inf and extracting z^n.
# Let me think about what happens when we multiply both sides of the 
# Warnaar identity by (zq;q)_inf.

# The infinite-level identity:
# sum_{n,m} stuff = 1/((zq)_inf (wq)_inf)
# So F_c(z,q) = 1/((zq)_inf (wq)_inf) for the trivial profile?
# No -- the profile determines the shape, and for general shapes the 
# formula involves summing over a lattice with specific bounds.

# Let me try a completely different angle. The Warnaar bounded identity
# for rank 2 gives:
# GK_{(i,j)/(s,0)/d}(z,q) = product * sum
# For specific shapes. The rank 3 case uses level-rank duality to
# reduce to rank 2.

# For d=4, the rank-3 identity with k=2 gives a QUADRUPLE SUM that is 
# manifestly positive. This is exactly what proves positivity for d=4,5!

# The question is: can we extend this to ALL d (not just d=4,5)?

# Warnaar proves the bounded identity only for k=1 (d=2,3) and k=2 (d=4,5).
# The general k case is the CONJECTURE.

# So: we need a bounded version of the A_2 invariance identity at level k=n_0.
# If we can prove that the multisum
# sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n] [n_0-n+m,m_0] [n,m] / ((zq)_{n-m} (wq)_n)
# gives the right generating function for BOUNDED cylindric partitions of any profile,
# then Q_n >= 0 follows from the manifest positivity of the sum.

# But this is exactly what Warnaar's identity ASSERTS (for all n_0),
# and the claim is PROVED by induction using the bounded CW equations.

# Wait -- let me re-read. The identity eq. (A_2 invariance) IS proved for all n_0.
# It gives Phi_{n_0, m_0}(z, w; q) as a manifestly positive multisum.

# So: 1/((zq)_{n_0-m_0} (wq)_{n_0}) * [n_0, m_0]
# = sum_{0<=m<=n<=n_0} z^{n-m} w^m q^{n^2-mn+m^2} [n_0,n] [n_0-n+m,m_0] [n,m] / ((zq)_{n-m}(wq)_n)

# This is an identity between rational functions of z, w, q.
# It IS manifestly positive on the right (all terms nonneg).
# But this is for RANK 2 shapes (2 rows), not rank 3 (3 rows).

# For rank 3, the cylindric partition has 3 rows. The formula involves
# a TOWER of sums (iterated application of the rank-2 step).

# Let me verify the identity numerically for small n_0.
print("Verifying Warnaar A_2 invariance for n_0=2, m_0=0:")

# LHS: Phi_{2,0}(z,w;q) = [2,0]_q / ((zq)_2 (wq)_2) = 1/((zq)_2 (wq)_2)
# RHS: sum_{0<=m<=n<=2} z^{n-m} w^m q^{n^2-mn+m^2} [2,n] [2-n+m, 0] [n,m] / ((zq)_{n-m}(wq)_n)
# [k, 0] = 1 for all k

# Note: we can't work with z, w as formal parameters in a power series ring
# with finite precision. Let me evaluate at specific z, w values.

# Actually, let me verify by computing both sides as Laurent series.
# Or better: extract the coefficient of z^a w^b for specific a, b.

# LHS: 1/((zq)_2 (wq)_2) = 1/((1-zq)(1-zq^2)(1-wq)(1-wq^2))
# = sum_{a,b >= 0} G(a,b,q) z^a w^b where G is a polynomial in q.

# RHS: complex. Let me just test numerically at q = 1/2.
# Actually, let me use formal power series in z and w by working
# with coefficients.

# For the purpose of understanding, let me trace the structure:
# F_c(z,q) for profile c = (c_0, c_1, c_2) is the bivariate GF for
# cylindric partitions. For rank 3, this is GK_c(z,q).

# The Warnaar identity gives GK for rank-2 shapes explicitly.
# For rank 3, there's a level-rank duality that relates rank-3 profile
# to rank-2 shape. This only works for k=1 (d=2) and k=2 (d=4,5) explicitly.

# For GENERAL d, no explicit multisum is known. The conjecture IS
# that Q_n >= 0, and no proof exists for d >= 7.

# So what can I contribute? Let me think about what the RAG corpus
# offers that's NEW.

# KEY INSIGHT from the RAG:
# 1. Kursungoz proves P_n >= 0 where F = (1-z) sum P_n z^n / (q^3;q^3)_n
# 2. Tingley connects cylindric partitions to affine crystal bases
# 3. Imamura connects energy functions to Demazure subgraphs (via Schilling-Tingley)
# 4. The Warnaar invariance identity gives a manifestly positive multisum at finite level

# The most promising avenue: can we use the Warnaar identity directly?
# The identity is PROVED (for all n_0). If we can express Q_n in terms of
# the quantities in the identity, positivity follows.

# Let me look at this from the BOUNDED version perspective.
# The bounded GF: F_{c,N}(q) = sum_{max <= N} q^{|Lambda|}
# The Warnaar identity gives F_{c,N}(q) as a positive multisum.

# Wait -- does it? Let me check.
# GK_{(i,j)/(s,0)/d}(z,q) = specific formula for rank-2 shapes.
# For the unbounded case: sum z^n * GK_{m=n}(q)
# For the bounded case: sum_{n=0}^N z^n * GK_{m=n}(q)

# Q_n = (q;q)_n * [z^n]((zq;q)_inf * sum_m z^m g_m)
# The extraction of z^n from the product of (zq;q)_inf and F_c(z,q)
# is what introduces the alternating signs.

# NEW IDEA: Instead of extracting z^n from the product, can we use 
# the CRYSTAL-THEORETIC interpretation to get a manifestly positive formula?

# From Tingley: CPPs parametrize V_Lambda tensor F.
# |pi| = principal grade + partition size.
# The (zq;q)_inf factor in Q_n corresponds to removing the partition F factor!

# Q_n = (q;q)_n * [z^n]((zq;q)_inf * F_c(z,q))
# Now (zq;q)_inf = 1/(sum_m z^m / (q;q)_m) (inverse of partition GF in z)
# Wait no: 1/(zq;q)_inf = sum z^m/(q;q)_m (the q-exponential).
# So (zq;q)_inf is the RECIPROCAL of the q-exponential.

# (zq;q)_inf * F_c(z,q) strips out the partition part!
# In crystal language: F_c(z,q) = chi(V_Lambda) * 1/(q;q)_inf (schematic)
# Then (zq;q)_inf * F_c(z,q) = chi(V_Lambda) * (zq;q)_inf / (q;q)_inf
# Hmm, this is getting complicated.

# Let me take a completely DIFFERENT approach.
# APPROACH: Prove Q_n >= 0 using the q-DIFFERENCE EQUATION that Q_n satisfies.

# From the CW recurrence, the g_m satisfy a transfer matrix equation.
# Q_n inherits a recurrence from this.

# More specifically: Q_n satisfies a q-difference equation in n.
# If we can show that this recurrence preserves nonnegativity, we're done.

# Q_1 = (1-q)*g_1 - q >= 0 (proved by injection lemma)
# Q_2 = Q_2 formula >= 0 (verified computationally)
# Q_{n+1} = f(Q_n, Q_{n-1}, ...) for some recurrence f

# What is the recurrence for Q_n?
# From the CW functional equation: F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^|J|,q)/(1-yq^|J|)
# This gives a relationship between F_c at different profiles and shifted y.

# For FIXED profile, the relationship between g_m at different m is:
# g_m(c) = sum of terms involving g_{m'}(c') for shifted profiles c' and m' < m.

# The Q_n are then determined by the g_m via the q-binomial transform.

# Actually, the synthesis mentions the universal determinant:
# det(I - A(x)) = -(x^3 - 1) for ALL d >= 1.
# This means the transfer matrix A has eigenvalues that are cube roots of unity!
# The g_m eventually become a quasi-polynomial with period 3.
# When d not-equiv 0 mod 3, g_m stabilizes to a POLYNOMIAL (period 1).
# When d equiv 0 mod 3, g_m oscillates with period 3.

# The transfer matrix approach: g_m = v^T A^m w for some vectors v, w
# (schematically). The eigenvalues of A determine the asymptotics.

# For Q_n = (q;q)_n * [z^n]((zq;q)_inf * F(z,q)):
# Using the transfer matrix: F(z,q) = sum_m z^m g_m = v^T (I - zA)^{-1} w
# (I - zA)^{-1} = sum_m z^m A^m.

# (zq;q)_inf * F = (zq;q)_inf * v^T (I-zA)^{-1} w

# This is a ratio of the form p(z) / det(I - zA) where p is a polynomial in z.
# The coefficient of z^n is determined by partial fractions.

# Since det(I - xA) = -(x^3 - 1) (the universal determinant!), the poles of 
# (I - zA)^{-1} are at z = omega, omega^2, 1 (cube roots of unity).
# But (zq;q)_inf also vanishes at z = q^{-k} for k >= 1.
# So the product (zq;q)_inf * F might have additional cancellations.

# This is getting deep. Let me now write up all findings and pursue
# the most promising specific direction.

# MOST PROMISING DIRECTION: 
# Use the transfer matrix + universal determinant to get an EXPLICIT
# formula for Q_n that is manifestly positive.

# Since det(I - xA) = -(x^3 - 1) = (1-x)(1+x+x^2), the transfer matrix
# has eigenvalues 1, omega, omega^2 (cube roots of unity).
# For d not-equiv 0 mod 3: all three eigenvalues contribute, but the
# omega components cancel out in Q_n.
# For d equiv 0 mod 3: the eigenvalue 1 has multiplicity... 

# Let me compute the transfer matrix for d=4 and verify the determinant.

print("\n" + "=" * 60)
print("Transfer matrix for d=4, c=(2,1,1)")
print("=" * 60)

# The transfer matrix A acts on the state space of "slices" (shapes).
# A slice at weight w is a triple (s_0, s_1, s_2) satisfying
# s_1 <= s_0 + c_1, s_2 <= s_1 + c_2, s_0 <= s_2 + c_0
# The weight is w = s_0 + s_1 + s_2.
# The transition A maps slice at weight w to slice at weight w' <= w:
# s_i' <= s_i (column decreasing condition)
# AND s_i' satisfy the same interlacing at the new level.

# Actually, the transfer matrix has entries A[s, s'] = 1 if s' <= s componentwise
# and s' satisfies the interlacing conditions.
# The generating function: g_m = sum_{s: max(s) >= 1} sum_{s_1,...,s_{m-1}} q^{total}
# where each transition contributes q^{weight(s_j)}.

# For the CW recurrence, the states are profiles (compositions summing to d).
# Wait, from the synthesis: "the N x N matrix (N = (d+1)(d+2)/2) encoding the CW shift operation"
# For d=4: N = 5*6/2 = 15.
# And "det(I - A(x)) = -(x^3 - 1)" for all d.

# The CW shift matrix is 15x15 for d=4. Its eigenvalues are all cube roots of unity.
# This is remarkable: a 15x15 matrix has only 3 distinct eigenvalues!

# If I compute the Jordan normal form or the spectral decomposition of A,
# I can get an EXPLICIT formula for g_m and hence for Q_n.

# Let me construct the transfer matrix. The states are compositions (a,b,c)
# with a+b+c = 4, a,b,c >= 0. There are 15 such compositions.
# State (a,b,c) corresponds to a slice where lambda^0 has a parts at the
# current height, lambda^1 has b parts, lambda^2 has c parts.

# The interlacing at each height requires:
# b <= a + c_1 = a + 1
# c <= b + c_2 = b + 1  
# a <= c + c_0 = c + 2
# (for profile c = (2,1,1))

# So the valid states are (a,b,c) with a+b+c=4 and b<=a+1, c<=b+1, a<=c+2.

# Let me list valid states:
states = []
for a in range(5):
    for b in range(5-a):
        c_val = 4 - a - b
        if b <= a + 1 and c_val <= b + 1 and a <= c_val + 2:
            states.append((a, b, c_val))

print(f"Valid states for d=4, c=(2,1,1): {len(states)} states")
for s in states:
    print(f"  {s}")

# The transfer matrix A(x): A[s', s] = x (with weight x being a formal variable)
# if s' <= s componentwise and s' is also a valid state.
# Actually, A[s', s] should encode the transition from slice s at height h
# to slice s' at height h+1, with s' <= s componentwise.
# The weight contributed is q^{|s'|} = q^{a'+b'+c'} = q^4 (always for d=4).

# Wait no, the weight is q^{s'_0 + s'_1 + s'_2}. But these are the column counts
# at the new height, so the contribution to size is s'_0 + s'_1 + s'_2.

# The transfer matrix in the CW formulation is different. Let me use the
# actual CW recurrence. The CW recurrence relates F_c(y,q) to F_{c(J)}(yq^|J|,q)
# for various shifted profiles c(J). This gives a matrix equation on the vector
# of F_c values at all profiles with the same d.

# The transfer matrix A(x) from the synthesis acts on the vector of 
# GK_c(z,q) values as z varies. Specifically:
# v(zq) = A * v(z) + boundary terms

# Since det(I - A(x)) = -(x^3 - 1), the matrix I - A has determinant 
# -(1-1)(1+1+1) = 0 when x=1. So A has 1 as an eigenvalue.
# (I - A(omega)) is also singular since det = -(omega^3 - 1) = 0.

# This means A has eigenvalues exactly at {1, omega, omega^2}.
# For a 15x15 matrix! With multiplicities summing to 15.

# The dimension of the eigenspace for eigenvalue lambda tells us the 
# "period-3" structure. If all eigenvalues are cube roots of unity,
# then A^3 = I (A is of order 3).

# Wait: if A has eigenvalues only among {1, omega, omega^2} and 
# A is diagonalizable, then A^3 = I.

# Let me verify: if g_m ~ A^m * v, and A^3 = I, then g_{m+3} = g_m.
# But g_m stabilizes (coefficients become constant), which contradicts period 3
# UNLESS some eigenspaces don't contribute to the specific component we're extracting.

# Hmm. The transfer matrix must NOT be A^m directly but rather something
# involving q-weights. Let me think again.

# The generating function approach: F_{c,m}(q) = sum_{max <= m} q^{size}
# = F_{c,m-1}(q) + g_m(q)
# g_m(q) = sum_{sigma: valid slice} q^{|sigma|} * #{configurations at heights 1..m-1 consistent with sigma at height m}

# This is more like: g_m is the sum over slices sigma of q^{|sigma|} * F_{c',m-1}(q)
# where c' depends on sigma.

# Actually for the simple case of binary cylindric partitions (max=1):
# g_1 = sum_{valid slices (a,b,c)} q^{a+b+c} = sum_states q^4 = 15 * q^4... 
# No, for max=1 the slices are (a,b,c) with 0<=a,b,c and the interlacing conditions,
# and a+b+c can vary. The weight is a+b+c.
# For c=(2,1,1), g_1 = 3q + 4q^2 + 5q^3 + 5q^4 + ... (we computed this).

# At weight w: #{(a,b,c): a+b+c=w, b<=a+1, c<=b+1, a<=c+2, max(a,b,c)>=1}
# w=1: (1,0,0), (0,1,0), (0,0,1) -> check interlacing:
#   (1,0,0): b=0<=1+1, c=0<=0+1, a=1<=0+2. Valid.
#   (0,1,0): b=1<=0+1, c=0<=1+1, a=0<=0+2. Valid.
#   (0,0,1): b=0<=0+1, c=1<=0+1, a=0<=1+2. Valid.
#   All valid. Count = 3. Matches g_1 coefficient of q^1 = 3.

# w=2: (2,0,0), (1,1,0), (1,0,1), (0,2,0), (0,1,1), (0,0,2)
#   (2,0,0): b=0<=3, c=0<=1, a=2<=2. Valid.
#   (1,1,0): b=1<=2, c=0<=2, a=1<=2. Valid.
#   (1,0,1): b=0<=2, c=1<=1, a=1<=3. Valid.
#   (0,2,0): b=2<=1? NO! 2 > 0+1=1. Invalid.
#   (0,1,1): b=1<=1, c=1<=2, a=0<=3. Valid.
#   (0,0,2): b=0<=1, c=2<=1? NO! 2 > 0+1=1. Invalid.
#   Count = 4. Matches g_1 coefficient of q^2 = 4.

# w=3: count should be 5
#   (3,0,0): b=0<=4, c=0<=1, a=3<=2. NO! a=3>c+2=2.
#   (2,1,0): b=1<=3, c=0<=2, a=2<=2. Valid.
#   (2,0,1): b=0<=3, c=1<=1, a=2<=3. Valid.
#   (1,2,0): b=2<=2, c=0<=3, a=1<=2. Valid.
#   (1,1,1): b=1<=2, c=1<=2, a=1<=3. Valid.
#   (1,0,2): b=0<=2, c=2<=1. NO!
#   (0,2,1): b=2<=1. NO!
#   (0,1,2): b=1<=1, c=2<=2, a=0<=4. Valid.
#   (0,0,3): b=0<=1, c=3<=1. NO!
#   Count = 5. Matches!

# w=4: count should be 5
# All valid states with a+b+c=4:
count_w4 = 0
for a in range(5):
    for b in range(5-a):
        cc = 4-a-b
        if b <= a+1 and cc <= b+1 and a <= cc+2:
            count_w4 += 1
print(f"\nCount at w=4: {count_w4} (should be 5)")

# This confirms: the number of valid slices at weight w stabilizes at 5 = (d+1)(d+2)/6 - 1? No, 5 = (4+1)(4+2)/6 = 5. 
# Actually (d+1)(d+2)/6 = 5 when d=4. And g_1 stabilizes at 5.
# L = (d+1)(d+2)/6 is the stable lattice point count. 
# For d not-equiv 0 mod 3: all three congruence classes have equal size L = (d+1)(d+2)/6.

# So g_1 = L*q/(1-q) + correction terms for small w.
# h_1 = (1-q)*g_1 = L*q + corrections = a polynomial.
# Q_1 = h_1 - q.

# For g_m with m >= 2: g_m stabilizes to a QUASI-POLYNOMIAL of degree m-1 in w.
# The first differences stabilize to L * q^{m-1} * (degree m-2 polynomial).
# And (q;q)_m * g_m is a polynomial.

# The question is whether this polynomial has nonneg coefficients.

# CRUCIAL OBSERVATION: Let me compute g_m coefficients and look for the
# EHRHART-LIKE structure.
# g_m(w) = #{cylindric partitions of profile c with max = m and size = w}
# This is the number of lattice points in the polytope P(c, m, w) = 
# {(s^i_h): interlacing, column decreasing, sum = w, max(s^i_m) >= 1}

# For FIXED m, as w increases, g_m(w) eventually equals a POLYNOMIAL in w
# (Ehrhart theory). The polynomial has degree 3m-4 (dimension of polytope minus 1).

# For m=1: g_1(w) stabilizes at L = (d+1)(d+2)/6 (a constant = degree 0 poly)
# For m=2: g_2(w) should stabilize to a LINEAR function of w.

# Let me check:
g2_coeffs = [3, 7, 15, 22, 33, 42, 55, 65, 79, 89, 104, 114, 129, 139, 154, 164, 179, 189, 204, 214]
# Differences: 4, 8, 7, 11, 9, 13, 10, 14, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10
diffs = [g2_coeffs[i+1] - g2_coeffs[i] for i in range(len(g2_coeffs)-1)]
print(f"\ng_2 first differences: {diffs}")
# Second differences:
diffs2 = [diffs[i+1] - diffs[i] for i in range(len(diffs)-1)]
print(f"g_2 second differences: {diffs2}")

# The coefficients eventually become: 25*w/2 + constant (roughly)
# Differences stabilize at period 2: 10, 15, 10, 15, ...
# Average difference: 12.5 = 25/2
# So g_2(w) ~ 25w/2 + const for large w.
# That's a degree-1 quasi-polynomial with period 2.

# h_2 = (1-q)(1-q^2) * g_2. Since (1-q)(1-q^2) kills quasi-polynomials
# of period 2 and degree <= 1... hmm, does it?
# (1-q)(1-q^2) = 1 - q - q^2 + q^3
# Applied to the sequence a_w: sum_{j} c_j a_{w-j} where c = [1,-1,-1,1]
# This is a "second difference" operator, killing degree <= 1 polynomials.
# So it kills the eventual quasi-polynomial part and leaves a finite polynomial.

# For d not-equiv 0 mod 3: g_2 is eventually a TRUE polynomial (not quasi-polynomial)
# of degree 1 in w, so (1-q)(1-q^2) kills it and h_2 is a polynomial.
# The SIGN of h_2's coefficients depends on the transient behavior of g_2.

print("\n" + "=" * 60)
print("SUMMARY: Most promising directions")
print("=" * 60)
print("""
1. Kursungoz proved P_n >= 0 (a DIFFERENT positive polynomial from Q_n).
   P_n has evaluation P_n(1) = binom(d+2,2)^n.
   Q_n has evaluation Q_n(1) = ((d+1)(d+2)/6 - 1)^n.
   
   KEY QUESTION: Can Q_n be expressed as a positive linear combination
   of P_m values? Or is there a direct bijective proof?

2. The Warnaar A_2 invariance identity gives a manifestly positive multisum
   for the bounded generating function. But extracting Q_n from this
   requires the (zq;q)_inf factor which introduces signs.

3. The transfer matrix approach: A has eigenvalues {1, omega, omega^2}.
   When d not-equiv 0 mod 3, the omega-eigenspaces cancel in Q_n.
   Can we prove that the residual (eigenvalue-1 component) gives nonneg Q_n?

4. The Ehrhart theory approach: g_m coefficients are eventually polynomial.
   (q;q)_m kills the polynomial tail, leaving a finite polynomial h_m.
   Can we show h_m >= 0 by analyzing the TRANSIENT behavior of g_m?
   (This is exactly the "second-order condition" from the synthesis.)
""")

