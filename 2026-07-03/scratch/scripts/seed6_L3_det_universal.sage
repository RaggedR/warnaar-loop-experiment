"""
Seed 6, Layer 3: The UNIVERSAL determinant det(I - A(x)) = -(x-1)(x^2+x+1) = -(x^3-1).

This is a major structural discovery. Let me verify for several d and understand why.
"""

from sage.all import *

def shifted_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] = c[i] - 1
        elif i not in J and prev in J:
            result[i] = c[i] + 1
    return tuple(result)

def get_Ic(c):
    return frozenset(i for i in range(len(c)) if c[i] > 0)

def all_nonempty_subsets(S):
    S = list(S)
    n = len(S)
    for mask in range(1, 1 << n):
        yield frozenset(S[j] for j in range(n) if mask & (1 << j))

def compute_det(d, k=3):
    compositions = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            compositions.append((c0, c1, c2))
    
    comp_idx = {c: i for i, c in enumerate(compositions)}
    N = len(compositions)
    
    R = PolynomialRing(QQ, 'x')
    x = R.gen()
    
    A = matrix(R, N, N)
    for i, c in enumerate(compositions):
        Ic = get_Ic(c)
        if not Ic:
            continue
        for J in all_nonempty_subsets(Ic):
            cp = shifted_profile(c, J)
            if cp in comp_idx:
                j = comp_idx[cp]
                s = len(J)
                sign = (-1)**(s - 1)
                A[i, j] += sign * x**s
    
    I_mat = matrix.identity(R, N)
    M = I_mat - A
    det_val = M.determinant()
    return det_val, det_val.factor(), A

print("UNIVERSAL DETERMINANT TEST")
print("=" * 60)

for d in range(1, 12):
    det_val, det_factored, A = compute_det(d)
    N = (d+1)*(d+2)//2
    print(f"d={d} ({N}x{N}): det = {det_val}, factored = {det_factored}")

# This is remarkable: det(I - A(x)) = -(x^3 - 1) = -(x-1)(x^2+x+1) for ALL d!
# The singularity at x = 1 (i.e., q^n = 1, i.e., q = 1 for n=1) is the trivial one.
# The singularity at x = omega (cube root of unity) is the mod-3 obstruction.

print("\n" + "=" * 60)
print("ANALYSIS: Why det = -(x^3 - 1)?")
print("=" * 60)

print("""
The matrix A(x) encodes the CW shift operation on compositions of d into 3 parts.
For k=3, the set I_c has at most 3 elements, so |J| ranges from 1 to 3.

The determinant det(I - A(x)) = -(x^3 - 1) says:
1. The system (I - A(x))F_n = b has a UNIQUE solution except when x^3 = 1.
2. When x = q^n, the system is solvable for all q with q^{3n} != 1.
3. The factor (x^2+x+1) vanishes at primitive cube roots of unity.
   This is why the conjecture requires d not equiv 0 mod 3!

When d equiv 0 mod 3, the cube root of unity has additional structure
that interferes with the positivity. Specifically:
  - The eigenvalues of A at x = omega include 1 (since det = 0).
  - This means the CW system has a nontrivial kernel at these special q values.
""")

# Now let's use the adjugate matrix to extract explicit formulas
# (I - A)^{-1} = adj(I - A) / det(I - A) = adj(I - A) / (-(x^3 - 1))

print("\n" + "=" * 60)
print("EXTRACTING EXPLICIT FORMULAS via adjugate for d=2")
print("=" * 60)

det_val2, _, A2 = compute_det(2)
R = A2.base_ring()
x = R.gen()
N2 = A2.nrows()
I2 = matrix.identity(R, N2)
M2 = I2 - A2

# Compute adjugate
adj_M2 = M2.adjugate()

# The transfer matrix T = (I - A)^{-1} = adj / det
# For a specific profile c, F_{c,n} = sum_{c'} T_{c,c'} * b_{c'}
# where b = RHS vector

compositions2 = []
for c0 in range(3):
    for c1 in range(3-c0):
        c2 = 2 - c0 - c1
        compositions2.append((c0, c1, c2))
comp_idx2 = {c: i for i, c in enumerate(compositions2)}

# Print the adjugate row for profile (1,1,0)
c_target = (1, 1, 0)
idx = comp_idx2[c_target]
print(f"\nAdjugate row for {c_target} (index {idx}):")
for j in range(N2):
    if adj_M2[idx, j] != 0:
        print(f"  adj[{idx},{j}] = {adj_M2[idx, j]}  (profile {compositions2[j]})")

# det = -(x^3 - 1) = -(x-1)(x^2+x+1)
# So T = adj / (-(x^3-1))
# F_{c,n} = (1/det) * sum_j adj_{c,j} * b_j

# For d=2, the bounded GF is:
# F_{(1,1,0),n}(q) = [adjugate * b] / (-(q^{3n} - 1)) = [adjugate * b] / (1 - q^{3n})

# For n=1: x = q^1 = q
# F_{(1,1,0),1} = [adj * b1] / (1 - q^3)

# From the solve_right above: F_{(1,1,0),1} = -2x/(x-1) = 2x/(1-x)
# So F_{(1,1,0),1}(q) = 2q/(1-q) ... wait, x = q^n = q for n=1.
# This gives 2q/(1-q) which diverges. Something is off.

# The issue: the system solves for F_{c,n} as a function of x = q^n, 
# but the RHS also depends on q through S_{n-1}.
# Actually no -- for n=1, S_{c,0} = 1, and the RHS depends only on x.
# The result F_{c,1} = 2x/(1-x) is a rational function of x.
# Setting x = q: F_{(1,1,0),1}(q) = 2q/(1-q) = 2(q + q^2 + q^3 + ...).
# This DIVERGES, which makes sense because F_{c,1} is the generating function
# for cylindric partitions of profile c with max <= 1. This is a power series, not a polynomial!

# Ah, I see: F_{c,n}(q) = sum over bounded cylindric partitions with max <= n, q^|size|.
# This is an infinite series (the parts can be arbitrarily large as long as all <= n).
# So F_{c,1} being 2q/(1-q) = 2q + 2q^2 + ... is correct: it counts pairs (L1, L2, L3) 
# with max = 1 (binary) weighted by q^{L1+L2+L3}, and for c=(1,1,0) with constraints
# L2 <= L1+1, L3 <= L2, L1 <= L3+1, and all 0 or 1 parts.
# Wait, that should give a polynomial, not a power series. There's a confusion.

# Actually, the bounded cylindric partitions of profile c with max <= n allow 
# ARBITRARILY MANY columns, each with values in {0, 1, ..., n}.
# So the size can be arbitrarily large. Hence F_{c,n}(q) is indeed a power series.

# For d=2, c=(1,1,0):
# F_{c,1}(q) = 2q/(1-q) means there are 2 binary CPs of each weight >= 1.
# Let me verify: at weight k, count triples (L1, L2, L3) with 
# L1+L2+L3 = k, all in {0,1}, L2-L1 <= 1, L3-L2 <= 0, L1-L3 <= 1.
# Actually no -- the columns are independent, each column is a triple of 0s and 1s.

# I think I'm confusing two things. Let me just extract the Q polynomial.

print("\n" + "=" * 60)
print("COMPUTING Q_{1,c}(q) for d=2 from the CW system")
print("=" * 60)

# Q_n = (q;q)_n * [z^n] ((zq;zq)_inf * GK(z,q))
# For n=1: Q_1 = (1-q) * [z] ((1-zq) * F_c(z,q))
#        = (1-q) * ([z] F_c(z,q) - q)
#        = (1-q) * (F_{c,1}(q) - q)  ... wait, [z] of (1-zq)*F_c(z,q) = F_{c,1} - q*F_{c,0} = F_{c,1} - q.
# Actually: (zq;zq)_inf at zq → (1-zq) for the z^1 coefficient. No, (zq)_inf = prod_{j>=0} (1-zq^{j+1}).
# For [z^1]: [z](1-zq)(1-zq^2)... * F_c(z,q) = [z]F_c(z,q) - q*[z^0]F_c(z,q) = F_{c,1} - q.
# Wait, (zq)_inf = prod (1-zq^j) for j >= 1, so [z^1] of (zq)_inf = -q (from the j=1 factor).
# Then [z^1] of (zq)_inf * F_c(z,q) = F_{c,1}*1 + (-q)*F_{c,0} = F_{c,1} - q.
# And Q_1 = (1-q) * (F_{c,1} - q).

# For c=(1,1,0), d=2: F_{c,1}(q) = 2q/(1-q)
# Q_1 = (1-q)(2q/(1-q) - q) = (1-q)*q*(2/(1-q) - 1) = q*(2 - (1-q)) = q*(1+q)
# So Q_1 = q + q^2. This has sum 2, and B = (3*4/6) - 1 = 1. Hmm, Q_1(1) should be 1.

# Wait, for d=2, k=3: B = (d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 2 - 1 = 1. So Q_1(1) = 1.
# But q + q^2 sums to 2. Something is wrong.

# Let me recheck the definition. From the conjecture:
# Q_{n,c}(q) = (q^l; q^l)_n * [z^n]((zq)_inf * GK_c(z,q))
# where l = gcd(d, r) = gcd(d, 3).
# For d=2, l = gcd(2,3) = 1. So (q;q)_1 = (1-q).
# Then Q_1 = (1-q)*[z](sum_{m>=0} (-1)^m q^{m(m+1)/2}/(q;q)_m z^m * F_c(z,q))
# = (1-q)*[z](F_c(z,q) - zq*F_c(z,q) + ...)
# Actually, (zq)_inf = sum_{m>=0} (-zq)^... No.
# (zq)_inf = prod_{j>=0}(1 - zq^{j+1}) (if the notation means (a;q)_inf = prod(1-aq^j)).
# Wait -- the notation says (a;q)_n = prod_{i=0}^{n-1} (1-aq^i).
# So (zq;q)_inf = prod_{i>=0} (1 - zq*q^i) = prod_{j>=1} (1 - zq^j).
# Hmm, but in the definition it says (zq)_inf, not (zq;q)_inf. 
# Looking at conjecture.tex: "$[z^n]\Big((zq)_\infty \cdot \operatorname{GK}_c(z,q)\Big)$"
# I think (zq)_inf = (zq;q)_inf = prod_{j>=0} (1 - zq^{j+1}).

# Let's just use the definition directly and compute Q_1 for d=2.
# OK let me do a clean numerical computation.

# Compute F_{c,n}(q) numerically as a power series in q.

def compute_F_bounded(c, n_max, q_prec=30):
    """
    Compute F_{c,n}(q) for n = 0, 1, ..., n_max as polynomials in q.
    Uses direct enumeration of cylindric partitions with max <= n.
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    R = PowerSeriesRing(QQ, 'q', default_prec=q_prec)
    q = R.gen()
    
    results = {}
    for n in range(n_max + 1):
        # Count cylindric partitions with max entry <= n
        # A CP of profile c is a sequence of partitions (lam1, lam2, lam3)
        # satisfying interlacing. But for the "binary" case, 
        # we can enumerate columns.
        
        # Actually, the generating function F_{c,n}(q) counts
        # cylindric partitions of profile c with max entry <= n, by size.
        # Each CP is a tuple of partitions (lambda^1, ..., lambda^k) 
        # satisfying cyclic interlacing.
        
        # For k=3, profile (c0,c1,c2), the CP has:
        # lambda^1_j >= lambda^2_{j+c1} for all j
        # lambda^2_j >= lambda^3_{j+c2} for all j
        # lambda^3_j >= lambda^1_{j+c0} for all j
        
        # Each lambda^i is a partition with all parts <= n.
        
        # This is hard to enumerate directly for large n. Let me use
        # the CW recurrence instead.
        pass
    
    return results

# Actually, let me just compute Q_n numerically using the alternating sum formula.
# Q_n = (q^l;q^l)_n * sum_{j=0}^n (-1)^j q^{j(j+1)/2} * [n choose j]_q * h_{n-j}
# where h_m = F_{c,m}(q) * (q;q)_m / (q^l;q^l)_m ... 
# Actually, I should look at what previous seeds computed.

# Let me use the simpler definition from Seed 4's proof:
# Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}
# where h_m is defined from F_{c,m}.

# Actually, the simplest route: compute F_{c,n} from the CW recurrence,
# then extract Q_n.

# For the CW system, I already have (I - A(x))^{-1} = adj(I-A(x))/det(I-A(x)).
# det = -(x^3 - 1), and adj is computed.

# F_{c,n} = sum_{c'} [(I-A(q^n))^{-1}]_{c,c'} * b_{c'}(q^n, S_{n-1})

# This is getting complex. Let me instead do a numerical verification of Q_1.

print("\n" + "=" * 60)
print("NUMERICAL Q_1 COMPUTATION via direct counting")
print("=" * 60)

def compute_Q1_direct(c, q_prec=30):
    """
    Compute Q_1 directly from the definition.
    
    Q_1 = (q^l;q^l)_1 * [z^1]((zq;q)_inf * F_c(z,q))
    
    = (1 - q^l) * (F_{c,1} - q * F_{c,0})
    
    where l = gcd(d, 3), F_{c,0} = 1, and F_{c,1} = sum_{Lambda: max <= 1} q^{|Lambda|}.
    
    Wait: [z^1] of (zq;q)_inf * F_c(z,q) needs more care.
    (zq;q)_inf = sum_{m >= 0} e_m z^m  where e_0 = 1, and the expansion...
    
    Actually: (zq;q)_inf = prod_{j >= 0} (1 - zq^{j+1}) = 1 - z(q + q^2 + ...) + z^2(...) - ...
    
    More precisely: [z^0] = 1, [z^1] = -sum_{j>=1} q^j = -q/(1-q).
    
    So [z^1]((zq;q)_inf * F_c(z,q)) = [z^0](zq;q)_inf * [z^1]F_c(z,q) + [z^1](zq;q)_inf * [z^0]F_c(z,q)
    = 1 * F_{c,1} + (-q/(1-q)) * 1 = F_{c,1} - q/(1-q)
    
    Then Q_1 = (1 - q^l) * (F_{c,1} - q/(1-q))
    
    For d=2, l=1: Q_1 = (1-q) * (F_{c,1} - q/(1-q)) = (1-q)*F_{c,1} - q.
    
    With F_{(1,1,0),1} = 2q/(1-q): Q_1 = (1-q)*2q/(1-q) - q = 2q - q = q. Good!
    Q_1 = q, so Q_1(1) = 1 = B. 
    """
    c0, c1, c2 = c
    d = c0 + c1 + c2
    l = gcd(d, 3)
    
    # Compute F_{c,1}: count binary CPs (max <= 1) by weight.
    # A binary CP = columns of (a1, a2, a3) with a_i in {0, 1} satisfying interlacing.
    # Actually, F_{c,1}(q) = sum over all CPs with max <= 1 of q^{size}.
    # A CP with max <= 1 is determined by how many columns have each pattern.
    # But the interlacing conditions make it non-trivial.
    
    # For k=3, a binary CP of profile c is a collection of binary triples
    # satisfying the interlacing. The number of valid weight-w triples was
    # computed in Layer 2 as a_w.
    
    # Actually, F_{c,1}(q) = 1 + sum_{w >= 1} a_w q^w (NOT sum_w f_1(w) q^w).
    # No wait: the UNRESTRICTED (not bounded) generating function F_c(z,q) has 
    # [z^1] = F_{c,1}, which counts CPs with max <= 1.
    
    # Hmm, actually F_c(z,q) = sum_n F_{c,n} z^n is the bivariate GF with 
    # y=z tracking max entry. But y^n doesn't quite mean max = n; it means
    # max <= n in the bounded version.
    
    # Let me just compute F_{c,1} as a power series by direct enumeration.
    # F_{c,1} = #{CPs with max <= 1, weight w} * q^w.
    # A CP with entries in {0,1} and three partitions satisfying interlacing.
    
    # For profile c = (c0, c1, c2), the CP is (lambda^1, lambda^2, lambda^3) where:
    # lambda^i is a partition into parts from {0, 1}, i.e., a binary string.
    # lambda^1_j >= lambda^2_{j+c1}
    # lambda^2_j >= lambda^3_{j+c2}
    # lambda^3_j >= lambda^1_{j+c0}
    
    # Each lambda^i is a "staircase": some number L_i of 1s followed by 0s.
    # So lambda^i = (1^{L_i}, 0, 0, ...) with L_i = length of partition.
    
    # The interlacing: lambda^1_j >= lambda^2_{j+c1} becomes:
    # If j <= L_1 (lambda^1_j = 1): need lambda^2_{j+c1} <= 1 (automatic).
    # If j > L_1 (lambda^1_j = 0): need lambda^2_{j+c1} <= 0, i.e., j+c1 > L_2,
    #   i.e., j > L_2 - c1.
    # So we need: L_1 >= L_2 - c1, i.e., L_2 - L_1 <= c1.
    
    # Similarly: L_3 - L_2 <= c2, L_1 - L_3 <= c0.
    
    # And the weight = L_1 + L_2 + L_3.
    
    # So F_{c,1}(q) = sum_{(L1,L2,L3) valid} q^{L1+L2+L3}
    # = 1 + sum_{w >= 1} a_w q^w (including w=0: L1=L2=L3=0 gives weight 0, which is the "1")
    
    # Let's compute it.
    R = PowerSeriesRing(QQ, 'q', default_prec=q_prec)
    q = R.gen()
    
    F1 = R(1)  # the w=0 contribution
    for w in range(1, q_prec):
        count = 0
        for L1 in range(w+1):
            for L2 in range(w+1-L1):
                L3 = w - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    count += 1
        F1 += count * q**w
    
    # Compute (zq;q)_inf to sufficient order
    # (zq;q)_inf = prod_{j >= 0} (1 - zq^{j+1}) 
    # [z^1] = -sum_{j>=0} q^{j+1} = -q/(1-q)
    # As a power series: -q - q^2 - q^3 - ...
    
    coeff_z1_of_zqinf = sum(-q**(j+1) for j in range(q_prec - 1))
    
    # [z^1]((zq;q)_inf * F_c(z,q)) = 1 * F_{c,1} + coeff_z1_of_zqinf * F_{c,0}
    # = F_{c,1} + (-q/(1-q)) * 1
    
    bracket = F1 + coeff_z1_of_zqinf
    
    # Q_1 = (q^l;q^l)_1 * bracket = (1 - q^l) * bracket
    qfac = 1 - q**l
    Q1 = (qfac * bracket).add_bigoh(q_prec)
    
    return Q1

for d in [2, 4, 5, 7, 8]:
    if d % 3 == 0:
        continue
    profiles = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            if c0 >= c1 >= c2:
                profiles.append((c0, c1, c2))
    
    for c in profiles[:3]:  # test a few
        Q1 = compute_Q1_direct(c, q_prec=20)
        c0, c1, c2 = c
        print(f"d={d}, c={c}: Q_1 = {Q1}")
        # Check non-negativity
        neg = [i for i in range(20) if Q1[i] < 0]
        if neg:
            print(f"  NEGATIVE coefficients at degrees: {neg}")
        else:
            print(f"  All non-negative. Q_1(1) = {sum(Q1[i] for i in range(20))}")

