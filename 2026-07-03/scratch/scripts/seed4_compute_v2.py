"""
Seed 4, Layer 1, v2: Compute Q_{n,c}(q) using the Corteel-Welsh recurrence.

The Corteel-Welsh functional equation:
F_c(y,q) = sum_{nonempty J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1 - yq^{|J|})

with F_c(0,q)=1 and F_c(y,0)=1.

Strategy: compute the z^n coefficient of (zq;q)_inf * F_c(z,q) iteratively.

Actually, let's use a cleaner approach. We know:
  F_c(z,q) = sum_{n>=0} G_n(q) z^n
where G_n(q) can be computed from the Corteel-Welsh recurrence.

But the recurrence mixes profiles, which is complex. Let me try a different route.

Alternative: Use Borodin's formula for the BOUNDED case.
Welsh (2021) showed that F_{c,n}(q) can be expressed via q-binomial type formulas
for small profiles.

For c=(1,1,0), d=2, t=k+d=3+2=5:
Borodin: F_c(q) = 1/((q^5;q^5)_inf * ... )

Actually let me try to use SageMath or sympy to compute this properly.
Let me try yet another approach: compute F_{c,n}(q) using the transfer matrix method.

For cylindric partitions of profile c with k parts and max entry n,
the transfer matrix approach works on the "state" which is the tuple of 
current column values satisfying the interlacing conditions.

For profile c = (c_0, c_1, c_2) with k=3, a cylindric partition
is a triple (lam^0, lam^1, lam^2) of partitions satisfying:
  lam^0_j >= lam^1_{j+c_1} for all j
  lam^1_j >= lam^2_{j+c_2} for all j  
  lam^2_j >= lam^0_{j+c_0} for all j

With max entry <= n, each column is a triple (a,b,c) with 0 <= a,b,c <= n
satisfying certain constraints from the interlacing.

Actually this is getting complicated. Let me try to use the KNOWN formulas
for small d cases. Warnaar proved the conjecture for d=2.

For c=(1,0,1) (or any permutation), d=2, Warnaar gives an explicit
manifestly positive formula for Q_{n,c}(q). Let me look up what it is.

For d=2 with k=3: t = 3 + 2 = 5, l = gcd(2,3) = 1.
Q_{n,c}(q) should be a polynomial with Q_{n,c}(1) = ((3)(4)/6 - 1)^n = (2-1)^n = 1.

So Q_{n,c}(q) = 1 for all n when d=2? That seems too simple but 
(d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 2 - 1 = 1. So yes, Q_{n,c}(1) = 1^n = 1.
That means Q_{n,c}(q) is a polynomial evaluating to 1 at q=1.

For d=4 with k=3: (5)(6)/6 - 1 = 5 - 1 = 4. So Q_{n,c}(1) = 4^n.
For d=5 with k=3: (6)(7)/6 - 1 = 7 - 1 = 6. So Q_{n,c}(1) = 6^n.

Let me try to compute Q more carefully using a proper implementation.
The issue before was that max_parts=4 was too small.

Key insight: for computing [z^n] of (zq;q)_inf * F_c(z,q), we don't need
the full F_c(z,q). We need F_{c,m}(q) for m=0,...,n, or equivalently
the coefficient of z^m in F_c(z,q) for m=0,...,n.

But F_c(z,q) = sum_{Lambda} z^{max(Lambda)} q^{|Lambda|} where the sum
is over ALL cylindric partitions (unbounded). The z^m coefficient is
the generating function for cylindric partitions with max entry exactly m.

For max entry exactly 0: only the empty partition. So [z^0] = 1.
For max entry exactly 1: cylindric partitions where all entries are 0 or 1
and at least one entry is 1.

Actually, let me reconsider. The max is unbounded, so each z^m coefficient
is an infinite power series in q (for m >= 1), not a polynomial.

But Q_{n,c}(q) is supposed to be a polynomial! The (q^l;q^l)_n factor
must kill the denominators.

Let me think about this from the Borodin product formula perspective.

F_c(q) = product formula (infinite product in q).
F_c(z,q) = bivariate generating function.

The CW recurrence relates F_c(y,q) to itself at shifted arguments.
For k=3, I_c = {i : c_i > 0}.

Let me just implement the CW recurrence properly for a specific small case.
Take c = (1,0,1). Then I_c = {0, 2} (0-indexed) or {1, 3} (1-indexed)?

Wait, the conjecture.tex uses 0-indexed: c = (c_0, c_1, ..., c_{r-1}) with r=k=3.
And I_c = {i : c_i > 0}. For c = (1,0,1): I_c = {0, 2}.

Nonempty subsets J of I_c: {0}, {2}, {0,2}.
For each J, we compute c(J).

The shifted profile c(J)_i:
  c_i(J) = c_i - 1 if i in J and (i-1) not in J
  c_i(J) = c_i + 1 if i not in J and (i-1) in J
  c_i(J) = c_i otherwise
(indices cyclic: i-1 for i=0 means i=k-1=2)

For J = {0}:
  i=0: 0 in J, (0-1)=2 not in J -> c_0 - 1 = 0
  i=1: 1 not in J, (1-1)=0 in J -> c_1 + 1 = 1  
  i=2: 2 not in J, (2-1)=1 not in J -> c_2 = 1
  c({0}) = (0, 1, 1)

For J = {2}:
  i=0: 0 not in J, (0-1)=2 in J -> c_0 + 1 = 2
  i=1: 1 not in J, (1-1)=0 not in J -> c_1 = 0
  i=2: 2 in J, (2-1)=1 not in J -> c_2 - 1 = 0
  c({2}) = (2, 0, 0)

For J = {0, 2}:
  i=0: 0 in J, (0-1)=2 in J -> c_0 = 1
  i=1: 1 not in J, (1-1)=0 in J -> c_1 + 1 = 1
  i=2: 2 in J, (2-1)=1 not in J -> c_2 - 1 = 0
  c({0,2}) = (1, 1, 0)

So the CW recurrence for c=(1,0,1):
F_{(1,0,1)}(y,q) = F_{(0,1,1)}(yq,q)/(1-yq) 
                  + F_{(2,0,0)}(yq,q)/(1-yq)
                  - F_{(1,1,0)}(yq^2,q)/(1-yq^2)

Note: all shifted profiles still have d=2 and k=3.
And these shifted profiles might have their own CW recurrences!

This is getting recursive. Let me instead try to directly verify
the conjecture using SageMath-style computation.

Actually, let me just try to use known formulas. For d=2, t=5, the 
Borodin formula gives:

For c=(1,1,0): d_{i,j} terms... let me compute.
k=3, c=(c_1,c_2,c_3)=(1,1,0) in 1-indexed notation.
l = c_1+c_2+c_3 = 2, t = 3+2 = 5.

d_{i,j} = c_i + ... + c_j.
d_{2,2} = c_2 = 1
d_{2,3} = c_2 + c_3 = 1
d_{3,3} = c_3 = 0

First product: i=1..3, j=i+1..3, m=1..c_i
i=1, j=2, m=1..c_1=1: exp = 1 + d_{2,2} + 2-1 = 1+1+1 = 3, step=5
i=1, j=3, m=1..c_1=1: exp = 1 + d_{2,3} + 3-1 = 1+1+2 = 4, step=5
i=2, j=3, m=1..c_2=1: exp = 1 + d_{3,3} + 3-2 = 1+0+1 = 2, step=5

Second product: i=2..3, j=2..i-1, m=1..c_i
i=3: j=2..2, m=1..c_3=0: empty (c_3=0)
i=2: j=2..1: empty (j range empty)

So F_{(1,1,0)}(q) = 1/((q^5;q^5)_inf * (q^3;q^5)_inf * (q^4;q^5)_inf * (q^2;q^5)_inf)
= 1/((q^2;q^5)_inf * (q^3;q^5)_inf * (q^4;q^5)_inf * (q^5;q^5)_inf)
= 1/((q^2,q^3,q^4,q^5;q^5)_inf)

But (q;q)_inf = (q;q^5)_inf * (q^2;q^5)_inf * (q^3;q^5)_inf * (q^4;q^5)_inf * (q^5;q^5)_inf

So F_{(1,1,0)}(q) = (q;q^5)_inf / (q;q)_inf ... wait that doesn't look right.

Actually: 1/((q^2,q^3,q^4,q^5;q^5)_inf) = (q;q^5)_inf / (q;q)_inf * ... no.

Let me just compute: (q;q)_inf = prod(1-q^n, n>=1)
= (q;q^5)(q^2;q^5)(q^3;q^5)(q^4;q^5)(q^5;q^5) where each is an inf product.

So 1/((q^2,q^3,q^4,q^5;q^5)_inf) = (q;q^5)_inf / (q;q)_inf * (q;q^5)_inf ... 
no, simpler: (q;q)_inf / (q;q^5)_inf = (q^2,q^3,q^4,q^5;q^5)_inf.

So F_{(1,1,0)}(q) = 1 / ((q^2,q^3,q^4,q^5;q^5)_inf) = (q;q^5)_inf / (q;q)_inf ... 
actually that's wrong too.

Correctly: F_{(1,1,0)}(q) = 1 / prod where the product is over the factors listed.
= 1 / ((q^2;q^5)(q^3;q^5)(q^4;q^5)(q^5;q^5))_inf

This equals (q;q^5)_inf / (q;q)_inf ... Let's verify numerically.

from fractions import Fraction

prec = 30

def qpoch_series_inf(a_exp, q_exp, prec):
    result = [0] * prec
    result[0] = 1
    i = 0
    while a_exp + i * q_exp < prec:
        power = a_exp + i * q_exp
        new_result = list(result)
        for j in range(prec):
            if j + power < prec:
                new_result[j + power] -= result[j]
        result = new_result
        i += 1
    return result

def inverse_series(s, prec):
    result = [0] * prec
    result[0] = 1
    for n in range(1, prec):
        val = 0
        for k in range(1, n + 1):
            if k < len(s):
                val += s[k] * result[n - k]
        result[n] = -val
    return result

def multiply_series(a, b, prec):
    result = [0] * prec
    for i in range(min(len(a), prec)):
        if a[i] == 0:
            continue
        for j in range(min(len(b), prec - i)):
            result[i + j] += a[i] * b[j]
    return result

# Compute F_{(1,1,0)}(q) = 1/((q^2;q^5)(q^3;q^5)(q^4;q^5)(q^5;q^5))
factors_inv = []
for a in [2, 3, 4, 5]:
    s = qpoch_series_inf(a, 5, prec)
    inv = inverse_series(s, prec)
    factors_inv.append(inv)

Fc = [0]*prec
Fc[0] = 1
for inv in factors_inv:
    Fc = multiply_series(Fc, inv, prec)

print("F_{(1,1,0)}(q) coefficients:")
print(Fc[:20])

# Compare with 1/((q;q)_inf / (q;q^5)_inf)
# = (q;q^5)_inf / ... no.
# The Rogers-Ramanujan-type product 1/(q,q^4;q^5)_inf corresponds to 
# the first RR identity. Our F has 1/(q^2,q^3;q^5)_inf * 1/(q^4,q^5;q^5)_inf.

# Let's see: does this match a known partition generating function?
# 1/((q^2,q^3,q^4,q^5;q^5)_inf) counts partitions into parts not congruent to 1 mod 5?
# No: 1/(q^a;q^t)_inf = sum partitions into parts = a mod t.
# So 1/((q^2,q^3,q^4,q^5;q^5)_inf) counts partitions where no part is congruent to 1 mod 5.

# The RR identities say:
# sum q^{n^2} / (q;q)_n = 1/(q,q^4;q^5)_inf   (parts ≡ 1,4 mod 5)
# sum q^{n(n+1)} / (q;q)_n = 1/(q^2,q^3;q^5)_inf   (parts ≡ 2,3 mod 5)

# So F_{(1,1,0)}(q) = 1/((q^2,q^3;q^5)(q^4,q^5;q^5))_inf 
# = [1/(q^2,q^3;q^5)_inf] * [1/(q^4,q^5;q^5)_inf]

# Interesting! The first factor is related to the second RR identity.

# Now I need the BIVARIATE generating function F_c(z,q).
# For that, I need the Corteel-Welsh recurrence or another method.

# Let me try the approach: F_{c,n}(q) via the transfer matrix.
# For c=(1,1,0), cylindric partitions with max entry <= n.
# These are triples (lam^0, lam^1, lam^2) with:
# lam^0_j >= lam^1_{j+1}
# lam^1_j >= lam^2_{j+0} = lam^2_j
# lam^2_j >= lam^0_{j+1}
# (using 1-indexed c; but we said c=(c_1,c_2,c_3)=(1,1,0), so
#  the shifts are c_2=1, c_3=0, c_1=1)

# Actually I need to be more careful about the indexing convention.
# conjecture.tex says: lam^(i)_j >= lam^(i+1)_{j+c_{i+1}} for 1<=i<=k-1
# and lam^(k)_j >= lam^(1)_{j+c_1}
# This uses 1-indexed i and 1-indexed c.

# For c = (c_1,c_2,c_3) = (1,1,0):
# lam^1_j >= lam^2_{j+c_2} = lam^2_{j+1}
# lam^2_j >= lam^3_{j+c_3} = lam^3_{j}
# lam^3_j >= lam^1_{j+c_1} = lam^1_{j+1}

# So the conditions are:
# lam^1_j >= lam^2_{j+1}  (shift by c_2=1)
# lam^2_j >= lam^3_j      (shift by c_3=0)
# lam^3_j >= lam^1_{j+1}  (shift by c_1=1)

# These together with lam^2_j >= lam^3_j mean lam^2 dominates lam^3 componentwise.
# And lam^1_j >= lam^2_{j+1}: lam^1 interlaces with lam^2 (shifted).
# And lam^3_j >= lam^1_{j+1}: lam^3 interlaces with lam^1 (shifted).

# With all entries <= n, this defines a transfer matrix on "columns".
# Column j has values (lam^1_j, lam^2_j, lam^3_j).
# Constraints between column j and j+1:
# From lam^1_j >= lam^2_{j+1}: next column's lam^2 <= current lam^1
# From lam^3_j >= lam^1_{j+1}: next column's lam^1 <= current lam^3
# Plus each partition is weakly decreasing: lam^i_j >= lam^i_{j+1}
# And lam^2_j >= lam^3_j (same column)

# Wait, lam^2_j >= lam^3_j is NOT a same-column constraint on consecutive 
# columns. It's an inter-partition constraint for all j.

# Actually, the interlacing conditions mix different j values.
# The transfer matrix approach would need to track all active constraints.

# Let me try a MUCH simpler approach: just compute F_{c,n}(q) for very small n
# by counting cylindric partitions with UNLIMITED parts but max entry <= n.

# For max entry <= 0: only the zero partition triple. F_{c,0} = 1.
# For max entry <= 1: entries are 0 or 1. Each partition is determined by
# how many leading 1s it has. So lam^i is (1^{a_i}, 0, 0, ...) for some a_i >= 0.

# For c=(1,1,0), the conditions lam^1_j >= lam^2_{j+1}, lam^2_j >= lam^3_j, 
# lam^3_j >= lam^1_{j+1}:
# With lam^i = (1^{a_i}, 0, ...), lam^i_j = 1 if j <= a_i, else 0.
# Condition lam^1_j >= lam^2_{j+1}: if j+1 <= a_2, then j <= a_1. So a_1 >= a_2.
#   Wait: lam^2_{j+1} = 1 iff j+1 <= a_2, i.e. j <= a_2-1. 
#   We need lam^1_j >= 1 whenever j <= a_2-1, so a_1 >= a_2-1... 
#   Actually lam^1_j = 1 iff j <= a_1. So we need: for all j with lam^2_{j+1}=1, 
#   lam^1_j=1. lam^2_{j+1}=1 iff j+1<=a_2, i.e. j<=a_2-1. 
#   So we need a_1 >= a_2-1, i.e. a_1 >= a_2 (since they're integers and 
#   a_1 >= a_2-1 with a_2>=1 gives a_1>=0 which is always true... wait).
#   
#   Hmm, let me be more careful. a_1 >= a_2-1 is not quite right.
#   We need: if a_2 >= 1, then for j = 1, ..., a_2-1, lam^1_j = 1. But j is 1-indexed!
#   Actually, let's use 1-indexed parts: lam^1_j = 1 for j=1,...,a_1 and 0 for j>a_1.
#   Condition: lam^1_j >= lam^2_{j+1} for all j >= 1.
#   lam^2_{j+1} = 1 iff j+1 <= a_2, i.e. j <= a_2-1.
#   So for j = 1,...,a_2-1, we need lam^1_j = 1, hence a_1 >= a_2-1.
#   But if a_2 = 0, condition is vacuous. If a_2 = 1, need a_1 >= 0 (always true).
#   If a_2 = 2, need a_1 >= 1. Etc.
#   So: a_1 >= a_2 - 1.
#
# Similarly lam^2_j >= lam^3_j: a_2 >= a_3.
# And lam^3_j >= lam^1_{j+1}: a_3 >= a_1 - 1.
#
# Size = a_1 + a_2 + a_3.
# F_{c,1}(q) = sum over valid (a_1,a_2,a_3) of q^{a_1+a_2+a_3}
# with constraints: a_1 >= a_2-1, a_2 >= a_3, a_3 >= a_1-1, a_i >= 0.
#
# From a_3 >= a_1-1 and a_1 >= a_2-1 and a_2 >= a_3:
# a_3 >= a_1-1, a_1 >= a_2-1, a_2 >= a_3
# Let's enumerate: a_1, a_2, a_3 >= 0.
#
# Case a_1 = 0: a_3 >= -1 (true), a_2 >= a_3, a_1=0 >= a_2-1 so a_2 <= 1.
#   a_2=0: a_3=0. Size=0. q^0=1.
#   a_2=1: a_3 <= 1. a_3=0: size=1, q^1. a_3=1: size=2, q^2.
# Case a_1 = 1: a_3 >= 0, a_1=1 >= a_2-1 so a_2 <= 2. a_2 >= a_3.
#   a_2=0: a_3=0. Size=1. q^1.
#   a_2=1: a_3 in {0,1}. Sizes 2,3. q^2+q^3.
#   a_2=2: a_3 in {0,1,2}. Also a_3 >= a_1-1=0. Sizes 3,4,5. q^3+q^4+q^5.
# Case a_1 = 2: a_3 >= 1, a_2 <= 3, a_2 >= a_3 >= 1.
#   a_2=1: a_3=1. Size=4. q^4.
#   a_2=2: a_3 in {1,2}. Sizes 5,6. q^5+q^6.
#   a_2=3: a_3 in {1,2,3}. Sizes 6,7,8. q^6+q^7+q^8.
# Case a_1 = 3: a_3 >= 2, a_2 <= 4, a_2 >= a_3 >= 2.
#   a_2=2: a_3=2. Size=7. q^7.
#   a_2=3: a_3 in {2,3}. Sizes 8,9. q^8+q^9.
#   a_2=4: a_3 in {2,3,4}. Sizes 9,10,11.
# ...

# This gives an infinite series for F_{c,1}(q)! 
# F_{c,1} = 1 + 2q + 3q^2 + 4q^3 + 4q^4 + 4q^5 + 4q^6 + ...
# Actually let me just compute it properly.

# The key realization: for 0-1 valued partitions, the number of parts is 
# unlimited, so we get infinite sums. F_{c,n} is NOT a polynomial but an 
# infinite power series.

# This means we need (q^l;q^l)_n to cancel the denominators.

# OK let me just compute this numerically to high precision.
# For (a_1, a_2, a_3) satisfying a_1 >= a_2-1, a_2 >= a_3, a_3 >= a_1-1,
# F_{c,1}(q) = sum q^{a_1+a_2+a_3}

# This is a rational function in q. Let me find it.
# Set b_1 = a_1 - a_3 + 1 >= 0 (from a_3 >= a_1-1, equivalently a_1 <= a_3+1)
# Hmm, the constraints are more symmetric. Let me just compute F_{c,1}
# as a power series.

prec = 30
Fc1 = [0] * prec
max_a = prec + 5  # enough to capture all terms

for a1 in range(max_a):
    for a2 in range(max_a):
        for a3 in range(max_a):
            if a1 >= a2 - 1 and a2 >= a3 and a3 >= a1 - 1:
                s = a1 + a2 + a3
                if s < prec:
                    Fc1[s] += 1

print("F_{(1,1,0),1}(q) =", Fc1[:20])

# Check: this should be the coefficient of the bounded cylindric partition
# generating function with max entry <= 1.

# Now F_{c,0}(q) = 1 (only empty partition)
Fc0 = [0] * prec
Fc0[0] = 1

# a_1(q) = [y^1] F_c(y,q) = F_{c,1} - F_{c,0}
a1_q = [Fc1[i] - Fc0[i] for i in range(prec)]
print("a_1(q) = [y^1]F_c(y,q) =", a1_q[:15])

# Now Q_{1,c}(q) = (q;q)_1 * [z^1]((zq;q)_inf * F_c(z,q))
# [z^1] of (zq;q)_inf * F_c(z,q):
# = [z^1](sum_m c_m z^m)(sum_n a_n z^n) 
# = c_0 * a_1 + c_1 * a_0
# where c_0 = 1, c_1 = -q/(1-q)... wait, c_m is from (zq;q)_inf expansion
# (zq;q)_inf = sum_m (-1)^m q^{m(m+1)/2} / (q;q)_m z^m
# c_0(q) = 1
# c_1(q) = -q / (q;q)_1 = -q/(1-q)
# But -q/(1-q) = -q - q^2 - q^3 - ... (power series)

# [z^1] = c_0 * a_1 + c_1 * a_0 = a_1(q) + (-q/(1-q)) * 1

c1_q = [0] * prec
# c_1(q) = -q * 1/(1-q) = -q * (1 + q + q^2 + ...)
for i in range(1, prec):
    c1_q[i] = -1  # coefficient of q^i for i >= 1

z1_coeff = [a1_q[i] + c1_q[i] for i in range(prec)]
print("[z^1]((zq)_inf * F_c(z,q)) =", z1_coeff[:15])

# Q_1(q) = (q;q)_1 * z1_coeff = (1-q) * z1_coeff
qpoch_1 = [0] * prec
qpoch_1[0] = 1
qpoch_1[1] = -1

Q1 = multiply_series(qpoch_1, z1_coeff, prec)
print("Q_{1,(1,1,0)}(q) =", Q1[:20])
print("Q_1(1) =", sum(Q1))
neg = [(i, Q1[i]) for i in range(prec) if Q1[i] < 0]
if neg:
    print("NEGATIVE:", neg)
else:
    print("All nonneg!")
