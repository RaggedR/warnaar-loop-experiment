"""
Debug: the brute force gives too many partitions.

The problem is that my definition of cylindric partition might be incomplete.
Let me look at what Borodin's product formula actually counts.

For c = (1,1) (k=2, t=4), F_{(1,1)}(q) = 1/((q^3,q^4;q^4)_inf).
This starts 1 + q^3 + q^4 + q^6 + 2q^7 + ...

But brute force gives 1 + 2q + 3q^2 + ...

The difference is dramatic. Let me look at what's counted at q^1:
lam^1=(1), lam^2=() and lam^1=(), lam^2=(1) both pass my check.
But neither should be counted by Borodin.

I think the issue is that I'm confusing TWO DIFFERENT objects:
1. Cylindric partitions as defined in the "profile" sense
2. What Borodin actually counts

Let me look at this from the REVERSE PLANE PARTITION perspective.

A reverse plane partition (RPP) of shape lambda/mu is a filling of the
skew diagram with non-negative integers that are weakly increasing
along rows and columns.

A CYLINDRIC partition extends this to a cylindrical shape.

The key missing constraint might be that the entries must be
WEAKLY INCREASING along the cylinder, not just satisfying interlacing.

Actually, let me reconsider. Maybe the issue is that in the conjecture's
definition, the interlacing goes the OPPOSITE WAY from what I coded.

The definition says: lam^i_j >= lam^{i+1}_{j+c_{i+1}}

If we think of this as the i-th partition dominating the (i+1)-th
partition after a shift, this is CORRECT for a decreasing sequence
of partitions.

But wait -- for a CYLINDRIC partition in the standard sense, the
partitions should INTERLACE, not just dominate. Let me look at
Gessel-Krattenthaler or McNamara for the standard definition.

Actually, I think the issue might be much simpler. Let me look at
the case k=1 (one partition) more carefully.

For k=1, c=(d), we have:
lam^1_j >= lam^1_{j+d} for all j >= 1

This means each part is >= the part d positions later.
If d=1: lam_j >= lam_{j+1} -- always true for partitions! So all partitions count.
F_{(1)}(q) = 1/(q)_inf. And t = 1+1 = 2.
Borodin: 1/((q^2;q^2)_inf) * product terms.
For k=1, the products are empty (need i<j and i>=2,j>=2 but k=1).
So F_{(1)}(q) = 1/(q^2;q^2)_inf = 1/((1-q^2)(1-q^4)...) 
= 1 + q^2 + q^4 + 2q^6 + ...

But if every partition counts, F should be 1/(q)_inf = 1+q+2q^2+3q^3+...

HUGE discrepancy. So Borodin's formula does NOT count what I think.

The issue must be that my DEFINITION is wrong, or the profile
convention is different.

Let me re-read conjecture.tex more carefully...

The definition says: "cylindric partition of profile c" where
c = (c_1,...,c_k). The interlacing conditions use c_{i+1} in the
shift for the i-th condition, with cyclic wrap.

But Borodin's formula uses a DIFFERENT convention for the profile.
Let me check: maybe in Borodin, the profile describes the
DIFFERENCES between successive partitions in the interlacing sequence.

In Borodin 2007, a cylindric partition of type (n_1,...,n_k) where
n_1+...+n_k = n (the circumference) is a sequence of partitions
mu^1, mu^2, ..., mu^k such that:
mu^1 >= mu^2 >= ... >= mu^k and the parts satisfy a periodic condition.

Actually, I think the issue is that Borodin defines cylindric partitions
as NON-INCREASING SEQUENCES of interlacing partitions, where the interlacing
means mu^i / mu^{i+1} is a HORIZONTAL STRIP.

A horizontal strip condition: mu^i >= mu^{i+1} AND mu^i_j >= mu^{i+1}_j
AND (mu^i)' >= (mu^{i+1})' + ... (conjugate conditions).

No wait, horizontal strip: mu supset nu and mu/nu has at most one box
in each column. This means mu_j >= nu_j >= mu_{j+1}.

THAT'S IT. The interlacing condition for a horizontal strip is:
mu_j >= nu_j >= mu_{j+1}

This is STRONGER than just mu >= nu componentwise. It also requires
nu_j >= mu_{j+1}, which ensures the skew shape has at most one box per column.

So the cylindric partition might require HORIZONTAL STRIP conditions,
not just componentwise domination!

Let me test: for c=(1), k=1, t=2:
The condition is lam_j >= lam_{j+1} (automatic for partitions).
But if horizontal strip is required: lam_j >= lam_{j+1} >= lam_{j+2}... 
which is still automatic. Hmm.

Actually for k=1, t=2, Borodin gives 1/(q^2;q^2)_inf which counts
partitions INTO EVEN PARTS. So the cylindric condition for k=1, c=(1)
must somehow select only even partitions. That's very specific.

The resolution might be: the cylindric partition is not just a tuple of
partitions. It's a PERIODIC SKEW PLANE PARTITION. The periodicity
constrains things further.

For a cylinder of circumference t, the entries go around and must
satisfy: a_{i+t} = a_i - 1 (or similar).

Actually, the standard definition is: a cylindric partition with
t rows (circumference t) is a two-way infinite sequence of integers
... lambda_{-1} >= lambda_0 >= lambda_1 >= ... such that
lambda_{i-t} = lambda_i + some_constant for all i.

This is VERY different from a tuple of separate partitions!

Let me re-read conjecture.tex once more to see if there's a
generating function approach I can use instead of enumeration.
"""

# Actually, I should USE the product formula and the functional equation
# rather than enumerate directly. Let me compute Q_{n,c}(q) using
# Borodin's product (for F_c(q)) and the Corteel-Welsh functional equation
# (for the bounded version).

# The Corteel-Welsh equation is:
# F_c(y,q) = sum_{emptyset != J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1-yq^{|J|})

# with F_c(0,q) = 1 and F_c(y,0) = 1.

# This recursion on y can be used to compute F_{c,n}(q) = [y^0,y^1,...,y^n stuff]

# But more directly, Q_{n,c}(q) involves [z^n] of (zq)_inf * F_c(z,q).
# And (zq)_inf is the Euler function.

# Let me use the Corteel-Welsh equation directly.
# Writing F_c(y,q) = sum_{n>=0} f_n(q) y^n, where f_n = F_{c,n} - F_{c,n-1}:

# Hmm, but the Corteel-Welsh equation involves shifted profiles c(J).
# For k=3, c=(c_0,c_1,c_2), the shifted profiles depend on J.
# I_c = {i : c_i > 0}.

# Actually this might be complex to implement. Let me try a different approach:
# use SageMath or a known implementation of Q_{n,c}(q).

# For now, let me verify my understanding using the SIMPLEST case that Warnaar proved.
# For d=2, the only profile (up to cyclic permutation) with d not div by 3 is c=(1,1,0).
# Warnaar proved Q_{n,(1,1,0)} has non-negative coefficients.

# In Warnaar's paper, Q_{n,c}(q) is defined using the BOUNDED generating function
# F_{c,n}(q) and the product (q^ell;q^ell)_n * [z^n]((zq)_inf * F_c(z,q))

# The key issue is computing F_c(z,q) correctly. Let me use Borodin's product
# formula for F_c(q) (the UNBOUNDED generating function), and then try to
# extract information about the bounded version.

# ACTUALLY: wait. Let me re-read the definition. It says:
# Q_{n,c}(q) = (q^ell;q^ell)_n * [z^n]((zq)_infty * GK_c(z,q))
# where GK_c(z,q) = F_c(z,q) is the BIVARIATE generating function.

# F_c(z,q) = sum_{Lambda} q^{|Lambda|} z^{max(Lambda)}

# This is NOT F_c(q). It's the bivariate version tracking max entry.
# I need to compute this correctly.

# Using the relationship:
# F_c(z,q) = sum_{n>=0} z^n * (F_{c,n}(q) - F_{c,n-1}(q))
# = sum_{n>=0} z^n * g_n(q)

# where g_n(q) counts cylindric partitions with max EXACTLY n.

# To get F_{c,n}(q) I need to enumerate correctly. My enumeration is WRONG
# because I'm not implementing the cylindric partition definition correctly.

# Let me try using the Corteel-Welsh functional equation instead.
# F_c(y,q) satisfies the functional equation. I can solve for the
# coefficients of the y-expansion iteratively.

# For c = (1,1,0), k=3:
# I_c = {0, 1} (indices where c_i > 0, using 0-indexing: c_0=1, c_1=1, c_2=0)

# The shifted profile c(J) for J subset I_c:
# c_i(J) = c_i - 1 if i in J and (i-1) not in J
#         = c_i + 1 if i not in J and (i-1) in J
#         = c_i     otherwise
# indices cyclic (c_{-1} = c_{k-1} = c_2)

# J = {0}: 
#   i=0: i in J, (i-1)=(-1 mod 3)=2, 2 not in J. So c_0(J)=c_0-1=0.
#   i=1: i not in J, (i-1)=0, 0 in J. So c_1(J)=c_1+1=2.
#   i=2: i not in J, (i-1)=1, 1 not in J. So c_2(J)=c_2=0.
#   c(J) = (0,2,0), |J|=1

# J = {1}:
#   i=0: not in J, (i-1)=2, not in J. c_0=1.
#   i=1: in J, (i-1)=0, not in J. c_1=c_1-1=0.
#   i=2: not in J, (i-1)=1, in J. c_2=c_2+1=1.
#   c(J) = (1,0,1), |J|=1

# J = {0,1}:
#   i=0: in J, (i-1)=2, not in J. c_0=0.
#   i=1: in J, (i-1)=0, in J. c_1=c_1=1.
#   i=2: not in J, (i-1)=1, in J. c_2=c_2+1=1.
#   c(J) = (0,1,1), |J|=2

# So the CW equation for c=(1,1,0) is:
# F_{(1,1,0)}(y,q) = F_{(0,2,0)}(yq,q)/(1-yq) - F_{(1,0,1)}(yq,q)/(1-yq)... 
# wait, let me be more careful.

# F_c(y,q) = sum_{J} (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|})

# = 1/(1-yq) * [F_{(0,2,0)}(yq,q) + F_{(1,0,1)}(yq,q)]
#   - 1/(1-yq^2) * F_{(0,1,1)}(yq^2,q)

# But now I need F for those shifted profiles too, which requires more recursion...
# This gets complex. Let me instead look for an existing implementation.

print("Looking for Warnaar's explicit formulas for Q_{n,c}(q)...")
print()
print("For d=2, c=(1,1,0):")
print("Warnaar proves Q_{n,(1,1,0)}(q) = sum over some manifestly positive multisum.")
print("The expected Q(1) = (3*4/6 - 1)^n = (2-1)^n = 1^n = 1.")
print()
print("For d=4, c=(2,1,1):")
print("Q(1) = (5*6/6 - 1)^n = (5-1)^n = 4^n")
print()
print("For d=5, c=(2,2,1):")
print("Q(1) = (6*7/6 - 1)^n = (7-1)^n = 6^n")
print()
print("For d=7 (first unproved), c=(3,2,2):")
print("Q(1) = (8*9/6 - 1)^n = (12-1)^n = 11^n")

