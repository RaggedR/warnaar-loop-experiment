"""
Agent B: Spectral decomposition of the transfer matrix M for cylindric partitions.

The CW transfer matrix M acts on the vector of g_m values for all profiles
with the same d. We need to build this matrix and decompose it spectrally.

For rank 3, profile c = (c_0, c_1, c_2) with d = c_0+c_1+c_2, 
the states are all compositions (a_0, a_1, a_2) with a_i >= 0, sum = d,
satisfying interlacing conditions that depend on the profile.

But wait -- the transfer matrix from the CW recurrence acts on ALL profiles
with the same d, not just the valid states for one profile. Let me think
about this more carefully.

The transfer matrix approach: for FIXED profile c, the generating function
g_m(q) counts cylindric partitions with max = m. The column-slice at height m
is a composition (s_0, s_1, s_2) with s_i >= 0 satisfying:
  s_1 <= s_0 + c_1
  s_2 <= s_1 + c_2  
  s_0 <= s_2 + c_0

The transfer from height m+1 to height m requires s'_i <= s_i (weakly decreasing
columns). The contribution to weight is q^{s_0 + s_1 + s_2}.

So the transfer matrix T(q) has entries:
  T(q)[s, s'] = q^{|s'|} if s' <= s component-wise and s' is valid
  T(q)[s, s'] = 0 otherwise

This is an INFINITE matrix (s_i unbounded). But det(I - xM) = -(x^3 - 1) 
where M is some finite reduction.

Actually, the key insight from Seed 6 / Agent A is that the transfer matrix
acts on the VECTOR of GK_c values as c ranges over all compositions of d into
3 nonneg parts. The CW recurrence relates F_c(y,q) to F_{c(J)}(yq^{|J|},q)
for shifted profiles. This gives a LINEAR relationship between the vectors
{g_m(c)} at weight m and {g_{m-1}(c')} at weight m-1.

Let me construct this CW transfer matrix.

For d=4, rank=3: compositions of 4 into 3 nonneg parts:
(4,0,0), (3,1,0), (3,0,1), (2,2,0), (2,1,1), (2,0,2), 
(1,3,0), (1,2,1), (1,1,2), (1,0,3), (0,4,0), (0,3,1), 
(0,2,2), (0,1,3), (0,0,4)
That's 15 compositions = (d+2 choose 2) = 15. Correct.

The CW recurrence: For profile c with all c_i > 0 (I_c = {0,1,2}):
F_c(y,q) = sum_{J nonempty subset of I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|}, q) / (1 - yq^{|J|})

This relates F_c(y,q) to F_{c(J)} at shifted y. In terms of g_m coefficients:
g_m(c) = sum_J (-1)^{|J|-1} * [extraction involving g_{m'}(c(J)) for m' <= m]

Actually, the CW recurrence is a functional equation in y. 
Let me think about this differently using the approach from Seed 6.

The CW recurrence gives:
G_n(c) := [y^n] F_c(y,q) = F_{c,n}(q) - F_{c,n-1}(q) = g_n(q)

Wait, from Seed 6's finding: "The CW recurrence computes G_n = [y^n] F_c(y,q) = F_{c,n} - F_{c,n-1}."

So G_n(c) is the generating function for CPs of profile c with max EXACTLY n.
The CW recurrence relates G_n(c) to G_n(c') for shifted profiles.

From F_c(y,q) = sum_J (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|}):
[y^n] of LHS = g_n(c)
[y^n] of F_{c(J)}(yq^{|J|},q)/(1-yq^{|J|}) 
  = sum_{m=0}^n q^{(n-m)|J|} g_m(c(J))
  (since 1/(1-yq^{|J|}) = sum y^{n-m} q^{(n-m)|J|} and F(yq^{|J|},q) shifts)

Wait, F(yq^{|J|},q) = sum_m (yq^{|J|})^m g_m = sum_m y^m q^{m|J|} g_m.
So [y^n](F(yq^{|J|},q)/(1-yq^{|J|})) = sum_{m=0}^n q^{m|J|} g_m(c(J)) * q^{(n-m)|J|}
  = q^{n|J|} sum_{m=0}^n g_m(c(J))
  = q^{n|J|} F_{c(J),n}(q)

So: g_n(c) = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}(q)
           = sum_J (-1)^{|J|-1} q^{n|J|} sum_{m=0}^n g_m(c(J))

This is NOT a simple linear recurrence on g_n alone -- it involves
sum_{m=0}^n g_m. But F_{c,n} = sum_{m=0}^n g_m, so:

g_n(c) = sum_J (-1)^{|J|-1} q^{n|J|} F_{c(J),n}(q)

And F_{c,n} = F_{c,n-1} + g_n, so:

F_{c,n}(c) = sum_{m=0}^n g_m(c)

The vector v_n := (F_{c,n})_{c: compositions of d} satisfies:
v_n(c) = v_{n-1}(c) + sum_J (-1)^{|J|-1} q^{n|J|} v_n(c(J))

This is an IMPLICIT equation for v_n in terms of v_{n-1}!

Rearranging: v_n(c) - sum_J (-1)^{|J|-1} q^{n|J|} v_n(c(J)) = v_{n-1}(c)

In matrix form: (I - A(q^n)) v_n = v_{n-1}
So: v_n = (I - A(q^n))^{-1} v_{n-1}

Where A(x) is the matrix with entries:
A(x)[c, c'] = sum_{J: c(J) = c'} (-1)^{|J|-1} x^{|J|}

And the universal determinant is: det(I - A(x)) = -(x^3 - 1).

So: v_n = prod_{k=1}^n (I - A(q^k))^{-1} v_0

And since det(I-A(q^k)) = -(q^{3k}-1) = (1-q^{3k}):
(I - A(q^k))^{-1} = adj(I - A(q^k)) / (1 - q^{3k})

So: v_n * (q^3;q^3)_n = prod_{k=1}^n adj(I - A(q^k)) * v_0

The ADJUGATE matrices are the key objects! If adj(I - A(q^k)) has nonneg
entries for all k, then v_n * (q^3;q^3)_n has nonneg entries,
which means P_n := (q^3;q^3)_n * F_{c,n} >= 0 (Kursungoz's result).

But we need Q_n, not P_n. Still, understanding the adjugate structure
is valuable.

Let me now build A(x) explicitly for d=4.
"""
from sage.all import *

# Build the CW shift matrix A(x) for d=4, rank=3.
# States: compositions (c_0, c_1, c_2) with c_0+c_1+c_2 = 4, c_i >= 0.

d = 4
r = 3

# All compositions of d into r parts
compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        c2 = d - c0 - c1
        compositions.append((c0, c1, c2))

N = len(compositions)
print(f"Number of compositions: {N} (should be {binomial(d+r-1, r-1)})")
comp_idx = {c: i for i, c in enumerate(compositions)}

def shift_profile(c, J):
    """Compute shifted profile c(J)."""
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

# Build A as a matrix over QQ[x]
Rx = PolynomialRing(QQ, 'x')
x = Rx.gen()

A = matrix(Rx, N, N, 0)

from itertools import combinations

for ic, c in enumerate(compositions):
    I_c = {i for i in range(r) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            # Check validity (all parts >= 0)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = comp_idx[cJ]
            A[ic, jcJ] += sign * x**size

print("\nA(x) matrix (nonzero entries):")
for i in range(N):
    for j in range(N):
        if A[i,j] != 0:
            print(f"  A[{compositions[i]}, {compositions[j]}] = {A[i,j]}")

# Compute det(I - A(x))
I_mat = matrix(Rx, N, N, lambda i,j: 1 if i==j else 0)
D = (I_mat - A).determinant()
print(f"\ndet(I - A(x)) = {D}")
print(f"Should be -(x^3 - 1) = {-(x**3 - 1)}")
print(f"Match: {D == -(x**3 - 1)}")

# Now compute the adjugate matrix adj(I - A(q)) for q as a power series
PREC = 50
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

# Evaluate A at x = q (not q as power series -- x is a single value)
# We need A(q) where q is the power series variable.
# This means replacing x with q in the polynomial entries of A.

A_q = matrix(R, N, N)
for i in range(N):
    for j in range(N):
        poly = A[i,j]
        # Evaluate polynomial at x=q
        val = R(0)
        for k, coeff in enumerate(poly.list()):
            val += coeff * q**k
        A_q[i,j] = val

I_R = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
B = I_R - A_q  # I - A(q)

# Check determinant
det_B = B.determinant()
print(f"\ndet(I - A(q)) = {det_B}")
print(f"Should be 1 - q^3 = {1 - q**3}")

# Compute adjugate = det * inverse
# adj(B) = det(B) * B^{-1}
B_inv = B.inverse()
adj_B = (1 - q**3) * B_inv

print(f"\nAdjugate matrix adj(I - A(q)):")
print("Checking nonnegativity of entries...")
all_nonneg = True
for i in range(N):
    for j in range(N):
        entry = adj_B[i,j]
        coeffs = list(entry)[:30]
        neg_coeffs = [(k, c) for k, c in enumerate(coeffs) if c < 0]
        if neg_coeffs:
            all_nonneg = False
            print(f"  NEGATIVE at [{compositions[i]}, {compositions[j]}]: first neg at degree {neg_coeffs[0][0]}, coeff = {neg_coeffs[0][1]}")

if all_nonneg:
    print("  ALL ENTRIES NONNEG! (through precision)")
else:
    print("  Some entries have negative coefficients.")

# Print a few interesting entries
print(f"\nSample adjugate entries for profile (2,1,1):")
idx_211 = comp_idx[(2,1,1)]
for j in range(N):
    entry = adj_B[idx_211, j]
    coeffs = list(entry)[:15]
    if any(c != 0 for c in coeffs):
        print(f"  adj[{compositions[idx_211]}, {compositions[j]}] = {entry.add_bigoh(15)}")

# Now compute v_0 = (1, 1, ..., 1) (empty CP has F_{c,0} = 1 for all c)
# But wait -- F_{c,0} counts CPs with max <= 0, which is just the empty CP.
# So F_{c,0}(q) = 1 for all c.
# v_0 = (1, ..., 1)

# v_1 = (I - A(q))^{-1} v_0
v0 = vector(R, [R(1)] * N)
v1 = B_inv * v0

print(f"\nv_1 = (I-A(q))^{{-1}} * v_0 (F_{{c,1}} for each profile c):")
for i in range(N):
    print(f"  F_{{({compositions[i]}),1}} = {v1[i].add_bigoh(15)}")

# Check: F_{(2,1,1),1} = 1 + g_1((2,1,1))
# g_1 should have coefficients 3, 4, 5, 5, 5, 5, ...
print(f"\ng_1((2,1,1)) = F_{{(2,1,1),1}} - 1 = {(v1[idx_211] - 1).add_bigoh(15)}")

