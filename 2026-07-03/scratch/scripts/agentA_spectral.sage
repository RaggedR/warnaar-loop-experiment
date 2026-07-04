"""
Agent A: Transfer matrix spectral decomposition for the CW system.

Since det(I - xA) = -(x^3 - 1), the matrix A has eigenvalues that are 
cube roots of unity. Decomposing g_m into eigencomponents should reveal 
the structure that makes Q_n nonneg.

The CW system: for each profile c with sum d, we have g_m^c (the GF 
for CPs with profile c and max = m). The CW recurrence relates these
across profiles at the SAME level d.

The transfer matrix acts on the vector of all F_c values (for all 
profiles with sum d).
"""
from sage.all import *

# For d=4, the profiles are compositions of 4 into 3 nonneg parts.
# There are binom(d+2, 2) = 15 such profiles.
# The CW recurrence: F_c(y,q) = sum_{J nonempty subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^|J|,q)/(1-yq^|J|)
# This can be written as a matrix equation on the vector (F_c)_{profiles c}.

# But the transfer matrix acts by y -> yq (shift), so it's a functional equation,
# not a simple matrix multiplication.

# The synthesis says: "det(I - A(x)) = -(x^3 - 1)" universally.
# Here A(x) is the matrix of the CW system evaluated at specific values.
# The eigenvalues of A are 1, omega, omega^2.

# Let me construct the transfer matrix explicitly for d=4.

# The CW recurrence at the coefficient level:
# g_m^c = sum_J (-1)^{|J|-1} q^{m*|J|} * (sum_{k=0}^m g_k^{c(J)})
# Wait, that's not right. Let me re-derive.

# F_c(y,q) = sum_m y^m g_m^c
# CW: F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
# F_{c(J)}(yq^|J|, q) = sum_m (yq^|J|)^m g_m^{c(J)} = sum_m y^m q^{m|J|} g_m^{c(J)}
# 1/(1 - yq^|J|) = sum_{k>=0} y^k q^{k|J|}

# So F_c(y,q) = sum_J (-1)^{|J|-1} sum_m sum_k y^{m+k} q^{(m+k)|J|} g_m^{c(J)}
# = sum_J (-1)^{|J|-1} sum_n y^n sum_{m=0}^n q^{n|J|} g_m^{c(J)}
# = sum_J (-1)^{|J|-1} sum_n y^n q^{n|J|} F_{c(J),n}

# where F_{c,n} = sum_{m=0}^n g_m^c = #{CPs with max <= n and profile c}

# Extracting coefficient of y^n:
# g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}
# But F_{c(J),n} = F_{c(J),n-1} + g_n^{c(J)}
# This is a recurrence relating g_n^c to F_{c(J),n} values.

# The transfer matrix encodes this. Let's work with the vector 
# v_n = (F_{c,n})_{all profiles c} and compute how it evolves.

# F_{c,n} = F_{c,n-1} + g_n^c
# g_n^c = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}

# So F_{c,n} = F_{c,n-1} + sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}
# This gives: (I - B_n) v_n = v_{n-1}
# where B_n has entry B_n[c, c'] = sum_{J: c(J) = c'} (-1)^{|J|-1} q^{n|J|}

# Note: the matrix B_n DEPENDS on n through q^{n|J|}.
# This makes the system non-autonomous.

# However, for the purposes of eigenvalue analysis, we can look at the 
# matrix M(x) = sum_J (-1)^{|J|-1} x^{|J|} * (permutation matrix from c to c(J))
# and then B_n = M(q^n).

# The synthesis says det(I - M(x)) = -(x^3 - 1).
# Let me verify this for d=4.

PREC = 30
R = PolynomialRing(QQ, 'x')
x = R.gen()

def shift_profile(c, J):
    """Compute shifted profile c(J). Indices are mod 3."""
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

# All profiles with d=4, k=3
d = 4
profiles = []
for a in range(d+1):
    for b in range(d+1-a):
        c_val = d - a - b
        profiles.append((a, b, c_val))

N = len(profiles)
print(f"Number of profiles for d={d}: {N}")

# Profile index map
prof_idx = {p: i for i, p in enumerate(profiles)}

# Build M(x) matrix
from itertools import combinations

M = Matrix(R, N, N)
for idx, c in enumerate(profiles):
    I_c = {i for i in range(3) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            sign = (-1)**(size - 1)
            if cJ in prof_idx:
                j_idx = prof_idx[cJ]
                M[idx, j_idx] += sign * x**size

# Compute det(I - M)
I_mat = Matrix.identity(R, N)
det_val = (I_mat - M).determinant()
print(f"\ndet(I - M(x)) = {det_val}")
print(f"Expected: -(x^3 - 1) = {-(x**3 - 1)}")
print(f"Match: {det_val == -(x**3 - 1)}")

# Now factor
print(f"Factored: {det_val.factor()}")

# The eigenvalues of M are the values of lambda such that det(M - lambda I) = 0.
# Since det(I - M(x)) = -(x^3 - 1) = (1-x)(1-omega*x)(1-omega^2*x)... 
# Wait, that's not right. det(I - M(x)) = -(x^3 - 1) as a polynomial in x.
# This means: when we substitute x = 1: det(I - M(1)) = -(1-1) = 0.
# When x = omega: det(I - M(omega)) = -(omega^3 - 1) = 0.
# When x = omega^2: similarly 0.

# So I - M(x) is singular at x = 1, omega, omega^2.
# The nullity at each point tells us the multiplicity.

# At x = 1: rank deficiency = dim(ker(I - M(1)))
M1 = M.change_ring(QQ)  # Evaluate at x=1
M1_eval = Matrix(QQ, N, N)
for i in range(N):
    for j in range(N):
        M1_eval[i,j] = M[i,j](1)

rank_deficiency = N - (Matrix.identity(QQ, N) - M1_eval).rank()
print(f"\nAt x=1: rank deficiency = {rank_deficiency}")
print(f"  rank of (I - M(1)) = {(Matrix.identity(QQ, N) - M1_eval).rank()}")

# The kernel at x=1 gives the stationary distribution.
ker1 = (Matrix.identity(QQ, N) - M1_eval).right_kernel()
print(f"  kernel dimension = {ker1.dimension()}")
if ker1.dimension() > 0:
    for v in ker1.basis():
        print(f"  kernel vector: {v}")

# Now let me also check: for the REDUCED system (only profiles with all c_i > 0),
# what is the structure?
print(f"\n{'='*60}")
print(f"Reduced system: profiles with all c_i > 0")
print(f"{'='*60}")

# For d=4, profiles with all c_i > 0:
interior_profiles = [(a,b,c_val) for (a,b,c_val) in profiles if a > 0 and b > 0 and c_val > 0]
print(f"Interior profiles: {interior_profiles}")

# The CW recurrence for profiles with all c_i > 0 involves all 7 subsets J.
# For profiles with some c_i = 0, I_c is smaller.
# But the matrix M connects ALL profiles, including boundary ones.

# Key insight: the eigenvalue 1 has kernel dimension = rank_deficiency.
# The F_{c,n} for large n grows like the eigenvalue-1 component.
# The omega and omega^2 components oscillate (period 3).
# When d not-equiv 0 mod 3, these oscillations cancel in Q_n.

# The most interesting quantity is the PROJECTION onto the eigenvalue-1 eigenspace.
# If we can show that the projected g_m has nonneg coefficients (after 
# applying the (q;q)_n transform), then Q_n >= 0.

# For this, I need the eigendecomposition of M(q^n) at EACH n.
# But M depends on n through x = q^n, making this a q-deformation.

# Let me try a different approach: compute Q_n for d=7 to higher n values
# and verify positivity.

print(f"\n{'='*60}")
print(f"Computing Q_n for d=7, c=(3,2,2) to check positivity")
print(f"{'='*60}")

# Use the CW recurrence system to compute g_m for d=7, c=(3,2,2)
# g_m for max = m: need to enumerate all column configurations.
# For m=1: straightforward (3 variables)

PR = PowerSeriesRing(QQ, 'q', default_prec=50)
q = PR.gen()

c = (3, 2, 2)
d = 7

# g_1 for d=7, c=(3,2,2)
g1 = PR(0)
for s0 in range(50):
    for s1 in range(min(s0+c[1]+1, 50)):
        for s2 in range(min(s1+c[2]+1, 50)):
            if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                total = s0+s1+s2
                if total < 50:
                    g1 += q**total

# h_1 = (1-q)*g_1
h1 = (1-q)*g1
Q1 = h1 - q
coeffs_Q1 = [Q1[i] for i in range(30)]
print(f"Q_1 for c=(3,2,2), d=7: {coeffs_Q1[:15]}")
print(f"Q_1(1) = {sum(coeffs_Q1)} (expected {(d+1)*(d+2)//6 - 1})")
neg = [i for i in range(30) if coeffs_Q1[i] < 0]
print(f"Negative: {neg if neg else 'NONE'}")

# g_2 for d=7, c=(3,2,2) -- this is slower (6 variables)
print("\nComputing g_2 for d=7, c=(3,2,2)...")
g2 = PR(0)
max_s = 16
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
                            if total < 50:
                                g2 += q**total

g0 = PR(1)

# Q_2 = (1-q)(1-q^2)*g_2 - (1-q^2)*q*g_1 + q^3
Q2 = (1-q)*(1-q**2)*g2 - (1-q**2)*q*g1 + q**3
coeffs_Q2 = [Q2[i] for i in range(40)]
print(f"Q_2 for c=(3,2,2), d=7: {coeffs_Q2[:25]}")
print(f"Q_2(1) = {sum(coeffs_Q2)} (expected {((d+1)*(d+2)//6 - 1)**2})")
neg2 = [i for i in range(40) if coeffs_Q2[i] < 0]
print(f"Negative: {neg2 if neg2 else 'NONE'}")

