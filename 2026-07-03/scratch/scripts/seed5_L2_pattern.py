"""
Seed 5, Layer 2: Analyze the pattern in key polynomial decompositions.

Known decompositions:

d=4, c=(2,1,1):
  Q_1 = K_{(0,0,1)} + K_{(1,0,0)}
  Q_2 = K_{(0,4)} + K_{(0,5)} + K_{(1,1)} + 2*K_{(2,1)} + K_{(2,2)} + K_{(4,4)}  [GL_2]
  Q_2 = K_{(0,0,3)} + K_{(1,1,1)} + 2*K_{(2,1,0)} + K_{(2,2,2)} + K_{(3,1,1)} + K_{(3,2,1)}  [GL_3]

d=7, c=(3,2,2):
  Q_1 = K_{(0,0,1)} + K_{(0,0,2)} + K_{(0,1,0)}
  Q_2 = 2*K_{(0,0,4)} + 2*K_{(0,1,2)} + K_{(0,2,4)} + K_{(0,3,0)} + K_{(0,5,4)} + K_{(0,8,0)} + K_{(1,0,4)} + K_{(4,4,4)}

Questions:
1. Are the indices related to tensor products of the Q_1 pieces?
2. Do the indices come from some crystal graph structure?
3. Is Q_n = (Q_1)^{*n} in some tensor product sense?

Key observation: Q_n(1) = (Q_1(1))^n, suggesting Q_n might be the
n-th tensor power character of some representation.

For d=7, c=(3,2,2): Q_1 decomposes as 3 Demazure modules:
  K_{(0,0,1)} (dim 3) + K_{(0,0,2)} (dim 6) + K_{(0,1,0)} (dim 2) = 11

If this were a representation V, then V^{tensor 2} should have character Q_2.
dim(V^{tensor 2}) = 11^2 = 121. Check!

But V is NOT an actual sl_3 representation (it's a mix of Demazure modules
at different levels). The tensor product of Demazure modules is not a
Demazure module in general.

However, if we think of the MONOMIALS (weight spaces) of V as a set S
of 11 elements, then the n-th symmetric or tensor power of S would give
121 elements. The q-weighting might come from the power sum specialization.

Actually, let's check: is Q_2 = Q_1^2 as a polynomial?
"""

Q1_d7 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
Q2_d7 = {3:1, 4:5, 5:7, 6:10, 7:10, 8:12, 9:10, 10:11, 11:9, 12:9,
         13:7, 14:7, 15:5, 16:5, 17:3, 18:3, 19:2, 20:2, 21:1, 22:1, 24:1}

# Compute Q_1^2
Q1_sq = {}
for d1, c1 in Q1_d7.items():
    for d2, c2 in Q1_d7.items():
        d = d1 + d2
        Q1_sq[d] = Q1_sq.get(d, 0) + c1 * c2

print("Q_1^2:", sorted(Q1_sq.items()))
print("Q_2:  ", sorted(Q2_d7.items()))
print("Equal:", Q1_sq == Q2_d7)

# Hmm, Q_1^2 is just squaring the polynomial. Let me check...
print(f"\nQ_1^2(1) = {sum(Q1_sq.values())}, Q_2(1) = {sum(Q2_d7.values())}")

# They won't be equal as polynomials. Q_2 has a quadratic degree formula
# while Q_1^2 has degree = 2 * deg(Q_1).
# deg(Q_1) = 6, deg(Q_1^2) = 12, deg(Q_2) = 24. So Q_2 is NOT Q_1^2.

# Let me look at the KEY INDICES more carefully
print("\n" + "=" * 70)
print("DECOMPOSITION INDICES ANALYSIS")
print("=" * 70)

# Q_1 indices for d=7, c=(3,2,2):
Q1_indices = [(0,0,1), (0,0,2), (0,1,0)]
Q2_indices = [(0,0,4), (0,0,4), (0,1,2), (0,1,2), (0,2,4), (0,3,0), (0,5,4), (0,8,0), (1,0,4), (4,4,4)]

# Denote Q_1 pieces as A=(0,0,1), B=(0,0,2), C=(0,1,0)
# Then Q_2 indices should be "products" or "sums" of pairs from {A,B,C}

print("\nQ_1 pieces: A=(0,0,1), B=(0,0,2), C=(0,1,0)")
print("Possible pairwise sums:")
pieces = {'A': (0,0,1), 'B': (0,0,2), 'C': (0,1,0)}
for n1, v1 in pieces.items():
    for n2, v2 in pieces.items():
        s = tuple(v1[i] + v2[i] for i in range(3))
        print(f"  {n1}+{n2} = {s}")

# Compare with Q_2 indices (with multiplicity):
# (0,0,4)x2, (0,1,2)x2, (0,2,4), (0,3,0), (0,5,4), (0,8,0), (1,0,4), (4,4,4)

# Pairwise sums:
# A+A = (0,0,2), A+B = (0,0,3), A+C = (0,1,1)
# B+A = (0,0,3), B+B = (0,0,4), B+C = (0,1,2)
# C+A = (0,1,1), C+B = (0,1,2), C+C = (0,2,0)

# So componentwise sums give: (0,0,2), (0,0,3)x2, (0,1,1)x2, (0,0,4), (0,1,2)x2, (0,2,0)
# But Q_2 has (0,0,4)x2, (0,1,2)x2 among others.
# The sum (0,0,4) appears in Q_2 with multiplicity 2, but B+B = (0,0,4) appears only once.

# So componentwise addition is NOT the right operation.
# This makes sense: tensor product of Demazure modules doesn't decompose
# into Demazure modules at the componentwise sum.

# Let me instead check the DIMENSION pattern
print("\n" + "=" * 70)
print("DIMENSION ANALYSIS")
print("=" * 70)

def demazure_op(poly, i, num_vars=3):
    result = {}
    for exp, coeff in poly.items():
        exp_list = list(exp)
        a, b = exp_list[i], exp_list[i+1]
        if a >= b:
            for j in range(a - b + 1):
                new_exp = list(exp)
                new_exp[i] = a - j
                new_exp[i+1] = b + j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) + coeff
        else:
            for j in range(b - a - 1):
                new_exp = list(exp)
                new_exp[i] = a + 1 + j
                new_exp[i+1] = b - 1 - j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) - coeff
    return {k: v for k, v in result.items() if v != 0}


def compute_key_poly(u, num_vars=3):
    u = tuple(u)
    is_dom = all(u[i] >= u[i+1] for i in range(len(u)-1))
    if is_dom:
        return {u: 1}
    for i in range(len(u)-1):
        if u[i] < u[i+1]:
            u_swapped = list(u)
            u_swapped[i], u_swapped[i+1] = u_swapped[i+1], u_swapped[i]
            u_swapped = tuple(u_swapped)
            K_swapped = compute_key_poly(u_swapped, num_vars)
            return demazure_op(K_swapped, i, num_vars)
    return {u: 1}


def key_dim(u):
    K = compute_key_poly(u, 3)
    return sum(K.values())

# Q_1 pieces and their dimensions
print("\nd=7, c=(3,2,2):")
print("Q_1 decomposition:")
q1_decomp = {(0,0,1): 1, (0,0,2): 1, (0,1,0): 1}
for u, mult in sorted(q1_decomp.items()):
    print(f"  {mult} * K_{u} (dim={key_dim(u)})")
print(f"  Total dim = {sum(mult * key_dim(u) for u, mult in q1_decomp.items())}")

print("\nQ_2 decomposition:")
q2_decomp = {(0,0,4): 2, (0,1,2): 2, (0,2,4): 1, (0,3,0): 1, (0,5,4): 1, (0,8,0): 1, (1,0,4): 1, (4,4,4): 1}
for u, mult in sorted(q2_decomp.items()):
    print(f"  {mult} * K_{u} (dim={key_dim(u)})")
print(f"  Total dim = {sum(mult * key_dim(u) for u, mult in q2_decomp.items())}")

# Check which Demazure modules appear
print("\nDemazure module levels (sum of indices):")
for u, mult in sorted(q2_decomp.items()):
    level = sum(u)
    s = sorted(u, reverse=True)
    is_dom = (list(u) == s)
    print(f"  K_{u}: level={level}, dominant={'Y' if is_dom else 'N'}, sorted={tuple(s)}")

# For Q_1: levels are 1, 2, 1. For Q_2: levels are 4, 3, 6, 3, 9, 8, 5, 12
# This doesn't have an obvious pattern related to tensor products.

# Let me check: are the Q_2 indices all "Littelmann path concatenations" of Q_1 indices?
# In crystal base theory, the tensor product B(lambda) x B(mu) decomposes into
# connected components, each of which is a Demazure crystal B_w(nu) for some
# weight nu and Weyl group element w.

# Let me instead check if the MULTISET of all monomials in Q_2 matches
# the multiset of pairwise products of monomials from Q_1.

print("\n" + "=" * 70)
print("MONOMIAL PRODUCT CHECK")
print("=" * 70)

# Get all monomials (with multiplicities) in Q_1 decomposition
q1_monomials = {}  # monomial exponent -> total multiplicity in Q_1
for u, mult in q1_decomp.items():
    K = compute_key_poly(u, 3)
    for exp, c in K.items():
        q1_monomials[exp] = q1_monomials.get(exp, 0) + mult * c

print("Q_1 monomials (weights with multiplicities):")
for exp, mult in sorted(q1_monomials.items()):
    q_deg = exp[0] + 2*exp[1] + 3*exp[2]
    print(f"  x^{exp} (q^{q_deg}): mult={mult}")

# Product of two copies: x^a * x^b -> x^{a+b}
product_monomials = {}
for exp1, m1 in q1_monomials.items():
    for exp2, m2 in q1_monomials.items():
        combined = tuple(exp1[i] + exp2[i] for i in range(3))
        q_deg = combined[0] + 2*combined[1] + 3*combined[2]
        product_monomials[q_deg] = product_monomials.get(q_deg, 0) + m1 * m2

# Compare with Q_2
print("\nProduct of Q_1 monomials (by q-degree):")
for d in sorted(product_monomials.keys()):
    prod_c = product_monomials[d]
    q2_c = Q2_d7.get(d, 0)
    match = "=" if prod_c == q2_c else "!="
    print(f"  q^{d}: product={prod_c} {match} Q_2={q2_c}")

print(f"\nProduct total at q=1: {sum(product_monomials.values())}")
print(f"Q_2 total at q=1: {sum(Q2_d7.values())}")

# The monomial products won't match Q_2 because Q_n is NOT a tensor power.
# deg(Q_2) = 24 but the product of two Q_1's has deg at most 12.

# Actually, the multiplicities in Q_1 as a polynomial (after specialization)
# are the coefficients of Q_1(q). The product Q_1(q)^2 has max degree 12,
# but Q_2 has max degree 24.

# So the key polynomial decomposition is NOT about "tensor product" in the
# naive sense. The KEY INDICES in Q_2 go up to (4,4,4) which sums to 12,
# much larger than the Q_1 indices which sum to at most 2.

# The decomposition is non-trivial and doesn't follow from Q_1's structure
# in any obvious way.

print("\n" + "=" * 70)
print("CONCLUSION")
print("=" * 70)
print("""
Key findings:
1. Q_n decomposes into GL_3 key polynomial specializations K_u(q,q^2,q^3)
   with nonneg integer coefficients for d=4 (n=1,2) and d=7 (n=1,2).

2. The decomposition is NOT a tensor product of the Q_1 decomposition.
   Q_2 indices are NOT pairwise sums of Q_1 indices.

3. The decomposition is NON-UNIQUE (LP gives different solutions with
   different objectives).

4. The key polynomial specialization at (q,q^2,q^3) is the right one
   for GL_3 (3 variables for k=3 in the profile).

5. The Q_1 decomposition shows a clear pattern:
   - Always includes K_{(0,0,1)} (fundamental representation, dim 3)
   - Profile-dependent additional pieces
   - K_{(0,0,m)} pieces are complete symmetric functions (Schur for one-row)

6. The NON-UNIQUENESS of the Q_2 decomposition suggests that key polynomials
   are NOT the canonical basis for this expansion. Perhaps Schur functions
   or some other positive basis is more natural.

7. The Schur decomposition also has fractional LP solutions, suggesting
   that Q_2 is NOT Schur-positive at the specialization (q,q^2,q^3).
   (Though the LP might just not find the right integer solution.)
""")

