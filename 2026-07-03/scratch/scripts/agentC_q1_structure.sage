"""
Agent C: Deep analysis of Q_1 structure.

Q_1(c) = (1-q) * g_1(c) - q  where g_1 is the GF for CPPs with max=1.

CPPs with max=1 and profile c = (c_0,c_1,c_2): these are triples of partitions
(lam^0, lam^1, lam^2) satisfying cyclic interlacing with all parts in {0,1}.
A partition with parts in {0,1} is just (1^a) for some a >= 0.
So the CPP is determined by three numbers (a_0, a_1, a_2) where lam^i = (1^{a_i}).

The interlacing condition: lam^i_j >= lam^{i+1}_{j+c_{i+1}} for all j.
For binary partitions (1^a): lam^i_j = 1 if j <= a_i, else 0.
So lam^i_j >= lam^{i+1}_{j+c_{i+1}} becomes: if j > a_i then j+c_{i+1} > a_{i+1},
i.e., a_{i+1} < j + c_{i+1}. The binding constraint is j = a_i+1:
a_{i+1} < a_i + 1 + c_{i+1}, i.e., a_{i+1} <= a_i + c_{i+1}.

Wait, that's the constraint from the weakest j. Let me think more carefully.
The constraint is: for ALL j >= 1, lam^i_j >= lam^{i+1}_{j+c_{i+1}}.
lam^i_j = 1 iff j <= a_i.
lam^{i+1}_{j+c_{i+1}} = 1 iff j + c_{i+1} <= a_{i+1}, iff j <= a_{i+1} - c_{i+1}.

So the constraint is: for all j, if j <= a_{i+1} - c_{i+1} then j <= a_i.
This means a_{i+1} - c_{i+1} <= a_i, i.e., a_{i+1} <= a_i + c_{i+1}.

And the cyclic condition: a_0 <= a_2 + c_0. 
(From lam^k_j >= lam^1_{j+c_1} with i=k=2 -> lam^2_j >= lam^0_{j+c_0},
 so a_0 - c_0 <= a_2, i.e., a_0 <= a_2 + c_0.)

Weight = |Lambda| = a_0 + a_1 + a_2.
Max = max(a_0, a_1, a_2)... wait no, max is the max part of any partition.
For binary partitions, max part is 1 if any a_i > 0, else 0.
So max = 1 iff at least one a_i > 0.

Actually wait, I need to reconsider. The max is the max entry, which for parts-in-{0,1} is just 1 (as long as any partition is nonempty). For the empty partition, max part is 0.

So g_1(c) = sum over (a_0, a_1, a_2) with all a_i >= 0, 
a_{i+1} <= a_i + c_{i+1} cyclically, and not all a_i = 0, 
of q^{a_0+a_1+a_2}.

Actually g_1 = F_{c,1} - F_{c,0} where F_{c,m} is the GF for CPPs with max <= m.
F_{c,0} = 1 (the empty CPP).
F_{c,1} = GF for CPPs with all parts in {0,1} = sum over valid (a_0,a_1,a_2) of q^{sum a_i}.
g_1 = F_{c,1} - 1 = sum over valid (a_0,a_1,a_2) with not all zero.

So g_1 includes the case where all a_i = 0 in F_{c,1} (contributing 1), 
and g_1 = F_{c,1} - 1.

Now Q_1 = (1-q)*g_1 - q = (1-q)*(F_{c,1} - 1) - q = (1-q)*F_{c,1} - 1 + q - q
         = (1-q)*F_{c,1} - 1.

Hmm, let me recheck. Actually Q_1 = (q;q)_1 * [z^1] H where H = (zq;q)_inf * F.
[z^1] H = [z^1]((1-zq)(1-zq^2)... * sum z^m g_m)
        = g_1 * 1 + g_0 * (-q) = g_1 - q.
(Since [z^0](zq;q)_inf = 1 and [z^1](zq;q)_inf = -q.)
Q_1 = (1-q)(g_1 - q).

With g_1 = F_{c,1} - 1 (removing the empty partition):
Q_1 = (1-q)(F_{c,1} - 1 - q).

Actually, F_{c,0} = 1 (just the zero partition = empty CPP).
g_0 = F_{c,0} = 1 (the partition with max = 0 is the empty partition).
g_1 = F_{c,1} - F_{c,0} = F_{c,1} - 1.

So Q_1 = (1-q)(g_1 - q) = (1-q)(F_{c,1} - 1 - q).

Let me compute F_{c,1} explicitly.
"""
from sage.all import *

# F_{c,1} for d=4
# Valid triples (a_0, a_1, a_2) with:
# a_1 <= a_0 + c_1, a_2 <= a_1 + c_2, a_0 <= a_2 + c_0 (cyclic)
# All a_i >= 0, parts are in {0,1} so a_i can be 0, 1, 2, ..., infinity.
# Wait -- a partition with parts in {0,1} and c parts... no.
# a_i is the NUMBER of 1's in lam^i. There's no upper bound on a_i from parts being in {0,1}.
# But max part = 1 means all parts are <= 1, which means lam^i = (1^{a_i}).
# The number of parts is a_i, and each part is 1. So |lam^i| = a_i.

# But there IS an implicit upper bound: the interlacing forces finite a_i.
# Actually no -- a_0 can be arbitrarily large if c_1 is large enough.
# For example, if c_1 >= 1, then a_1 <= a_0 + c_1 allows a_1 to grow with a_0.

# Hmm, but this is an infinite sum (g_1 is a power series, not a polynomial).
# Q_1 = (1-q)(g_1 - q) is a polynomial though!

# Let me compute F_{c,1} as a formal power series.
R = PowerSeriesRing(QQ, 'q', default_prec=30)
q = R.gen()

def F_c1(c, prec=30):
    """Compute F_{c,1}(q) = sum over valid (a0,a1,a2) of q^{a0+a1+a2}."""
    c0, c1, c2 = c
    result = R(0)
    # a0 can be 0, 1, 2, ... 
    # Constraint: a1 <= a0 + c1, a2 <= a1 + c2, a0 <= a2 + c0
    # From these: a0 <= a2 + c0 <= a1 + c2 + c0 <= a0 + c1 + c2 + c0 = a0 + d
    # So no contradiction, but also: a0 <= a2 + c0, a2 <= a1 + c2, a1 <= a0 + c1.
    # Combined: a0 <= a1 + c2 + c0 <= a0 + c1 + c2 + c0 = a0 + d. Always true.
    # But for convergence of q^{sum}, we need sum >= 0, and the GF converges for |q|<1.
    
    for total in range(prec):
        for a0 in range(total+1):
            for a1 in range(total+1-a0):
                a2 = total - a0 - a1
                # Check constraints
                if a1 <= a0 + c1 and a2 <= a1 + c2 and a0 <= a2 + c0:
                    result += q**total
    return result

# Test for d=4, various profiles
for c in [(2,1,1), (3,0,1), (4,0,0), (3,1,0), (2,2,0)]:
    F1 = F_c1(c, prec=20)
    g1 = F1 - 1
    Q1 = (1-q) * (g1 - q)
    Q1_trunc = Q1.truncate(20)
    print(f"c={c}: F_{{c,1}} = {F1.add_bigoh(15)}")
    print(f"  g_1 = {g1.add_bigoh(15)}")
    print(f"  Q_1 = (1-q)(g_1 - q) = {Q1_trunc}")
    
    # Count integer points for Q_1
    coeffs = [Q1_trunc[i] for i in range(20)]
    max_deg = max((i for i in range(20) if coeffs[i] != 0), default=0)
    print(f"  Q_1 as polynomial: {coeffs[:max_deg+1]}")
    print()

# Now: KEY OBSERVATION. The set of valid (a_0, a_1, a_2) with a_i >= 0 and
# cyclic interlacing a_{i+1} <= a_i + c_{i+1} can be viewed as lattice points
# in a cone. The generating function F_{c,1} = sum q^{a_0+a_1+a_2} over this cone.
#
# The polynomial Q_1 = (1-q) * F_{c,1} - 1 - q + q = (1-q) * F_{c,1} - 1.
# Wait, let me recompute: Q_1 = (1-q)(g_1 - q) = (1-q)(F_{c,1} - 1 - q).
# For c=(2,1,1): Q_1 = 2q + q^2 + q^3.
# F_{c,1} - 1 - q = ? Let me check.

print("Detailed check for c=(2,1,1):")
c = (2,1,1)
F1 = F_c1(c, prec=15)
print(f"F_{{c,1}} = {F1.add_bigoh(12)}")
print(f"F_{{c,1}} - 1 - q = {(F1 - 1 - q).add_bigoh(12)}")
print(f"(1-q)(F_{{c,1}} - 1 - q) = {((1-q)*(F1 - 1 - q)).truncate(15)}")

# Let me also count: how many valid triples for each total weight?
print("\nCounting valid triples (a_0,a_1,a_2) for c=(2,1,1):")
for total in range(8):
    triples = []
    for a0 in range(total+1):
        for a1 in range(total+1-a0):
            a2 = total - a0 - a1
            if a1 <= a0 + 1 and a2 <= a1 + 1 and a0 <= a2 + 2:
                triples.append((a0,a1,a2))
    print(f"  weight {total}: {len(triples)} triples: {triples}")

# KEY INSIGHT: F_{c,1}(q) = sum over lattice cone points of q^{sum a_i}.
# This is a rational function in q!
# F_{c,1}(q) = numerator(q) / (1-q)^? 
# 
# Actually for the cone a_{i+1} <= a_i + c_{i+1} (cyclic), 
# this is an Ehrhart-type generating function.
# The denominator should be (1-q)^2 since the cone is 2-dimensional
# (three variables a_0,a_1,a_2 with one linear relation mod shifting).

print("\n\nRational function analysis:")
for c in [(2,1,1), (3,0,1), (4,0,0)]:
    F1 = F_c1(c, prec=25)
    # Try to find rational function F1 = p(q) / (1-q)^k
    # F1 * (1-q) should simplify
    for k in range(1, 5):
        test = F1 * (1-q)**k
        test_trunc = test.truncate(20)
        coeffs = [test_trunc[i] for i in range(20)]
        # Check if it stabilizes to 0
        if all(coeffs[i] == 0 for i in range(8, 20)):
            max_d = max((i for i in range(20) if coeffs[i] != 0), default=0)
            print(f"c={c}: F_{{c,1}} = [{coeffs[:max_d+1]}] / (1-q)^{k}")
            break

