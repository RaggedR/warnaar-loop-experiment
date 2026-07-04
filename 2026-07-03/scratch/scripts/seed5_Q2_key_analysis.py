"""
Seed 5: Check if Q_2 for (2,1,1) decomposes as a sum of key polynomial specializations.

Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

This has Q(1) = 16 = 4^2.

Key observation: Q_1 = K_{(1,0)} + K_{(0,1)} + K_{(1,1)} at (q, q^2).
These are the Demazure characters for compositions u with |u| in {1, 2}
(not all of them though: K_{(2,0)} and K_{(0,2)} are missing).

Actually K_{(1,0)}, K_{(0,1)}, K_{(1,1)}: these have |u| = 1, 1, 2.
The sum has 4 terms at q=1 matching expected_base = 4.

For Q_2, maybe: Q_2 = sum over pairs (u, v) of some kind?
Or: Q_2 = sum of K_{u} at (q, q^2) over some set of compositions u?

Let me compute all key poly specializations and try to find a decomposition.
"""

def key_poly(u, num_vars):
    n = num_vars
    u = list(u) + [0] * (n - len(u))
    u = u[:n]
    
    def sort_to_dominant(v):
        v = list(v)
        swaps = []
        for i in range(len(v)):
            for j in range(len(v) - 1, i, -1):
                if v[j] > v[j-1]:
                    v[j], v[j-1] = v[j-1], v[j]
                    swaps.append(j-1)
        return tuple(v), swaps
    
    def apply_pi(poly, i):
        result = {}
        for exp, coeff in poly.items():
            exp = list(exp)
            ai = exp[i]
            ai1 = exp[i + 1]
            rest = list(exp)
            P = ai + 1
            Q_val = ai1
            if P > Q_val:
                for j in range(P - Q_val):
                    new_exp = list(rest)
                    new_exp[i] = Q_val + j
                    new_exp[i + 1] = P - 1 - j
                    key = tuple(new_exp)
                    result[key] = result.get(key, 0) + coeff
            elif P < Q_val:
                for j in range(Q_val - P):
                    new_exp = list(rest)
                    new_exp[i] = P + j
                    new_exp[i + 1] = Q_val - 1 - j
                    key = tuple(new_exp)
                    result[key] = result.get(key, 0) - coeff
        return {k: v for k, v in result.items() if v != 0}
    
    dom, swaps = sort_to_dominant(u)
    poly = {dom: 1}
    for i in reversed(swaps):
        poly = apply_pi(poly, i)
    return poly


def specialize_key(u, num_vars, vals):
    poly = key_poly(u, num_vars)
    result = {}
    for exp, coeff in poly.items():
        q_deg = sum(vals[i] * exp[i] for i in range(num_vars))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


# Target: Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
Q2_target = {3:1, 4:3, 5:2, 6:3, 7:2, 8:2, 9:1, 10:1, 12:1}

# Compute all key polys at (q, q^2) up to |u| = 12
print("Key polys at (q, q^2) up to |u| = 6:")
keys_12 = {}
for u0 in range(7):
    for u1 in range(7):
        K = specialize_key((u0, u1), 2, [1, 2])
        if K and all(v > 0 for v in K.values()):
            keys_12[(u0, u1)] = K
            s = sum(K.values())
            max_d = max(K.keys())
            if max_d <= 12:
                print(f"  K_({u0},{u1}) -> {K}  (sum={s})")

# Now try: which positive integer linear combinations of these give Q_2?
# This is NP-hard in general, but the target is small.
# Use greedy + backtracking with small coefficients.

print("\nSearching for Q_2 = sum a_u * K_u(q, q^2)...")

# The sum at q=1 must be 16.
# Each K_u at q=1 has sum = number of monomials in K_u = |{w : w <= u under Bruhat}| ... 
# Actually for 2 vars: K_{(a,b)} with a >= b has 1 monomial (just x^{a,b}).
# K_{(a,b)} with a < b has b - a + 1 monomials.

# K_{(0,0)} -> 1 (sum=1)
# K_{(1,0)} -> q (sum=1)
# K_{(0,1)} -> q + q^2 (sum=2)
# K_{(2,0)} -> q^2 (sum=1)
# K_{(1,1)} -> q^3 (sum=1)
# K_{(0,2)} -> q^2 + q^3 + q^4 (sum=3)

# So to get sum=16, we need to pick keys whose sums add to 16.

# Let me try: Q_2 might be sum of K_u * K_v at (q, q^2)?
# No, that's multiplication, not addition.

# Or: Q_2 = product of (1 + terms) structure.

# Actually, let me think about this differently.
# For Q_1: the decomposition was K_{(1,0)} + K_{(0,1)} + K_{(1,1)} at (q, q^2).
# What if Q_n is a PRODUCT of copies of this?
# Q_1^2 = (2q + q^2 + q^3)^2 = 4q^2 + 4q^3 + 5q^4 + 2q^5 + 2q^6 + q^4 ... hmm
# = 4q^2 + 4q^3 + 5q^4 + 2q^5 + 2q^6 + q^6 = 
# Actually: (2q + q^2 + q^3)^2 = 4q^2 + 2*2*q^3 + (1+4)q^4 + (2+2)q^5 + (1+2)q^6 + 0 + q^6
# = 4q^2 + 4q^3 + 5q^4 + 4q^5 + 3q^6 + 2q^5 ... I'm making errors. Let me compute.

p1 = {1: 2, 2: 1, 3: 1}
p1sq = {}
for e1, c1 in p1.items():
    for e2, c2 in p1.items():
        e = e1 + e2
        p1sq[e] = p1sq.get(e, 0) + c1 * c2
print(f"\nQ_1^2 = {dict(sorted(p1sq.items()))}")
print(f"Q_2   = {dict(sorted(Q2_target.items()))}")
print(f"Match: {p1sq == Q2_target}")
# They don't match. Q is not multiplicative.

# Let me try the tensor product interpretation.
# If Q_n counts lattice points in some polytope P_n, and P_n is a Minkowski sum,
# then Q_n would be a convolution. But the convolution of Q_1 with itself
# doesn't match Q_2.

# Let me instead try a more sophisticated key polynomial decomposition for Q_2.
# Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12

# The isolated q^12 term is interesting — it corresponds to the maximum degree.
# K_{(6,0)}(q,q^2) = q^6. K_{(0,6)}(q,q^2) = q^6 + ... + q^12.
# K_{(0,6)} = sum_{j=0}^{6} x_1^j x_2^{6-j}. At (q,q^2): sum_{j=0}^{6} q^{j+2(6-j)} = sum q^{12-j} for j=0..6
# = q^12 + q^11 + q^10 + q^9 + q^8 + q^7 + q^6. Sum = 7. 
# This has many more terms than Q_2.

# Maybe use K at (q, q^3)?
print("\nKey polys at (q, q^3):")
for u0 in range(5):
    for u1 in range(5):
        K = specialize_key((u0, u1), 2, [1, 3])
        if K and all(v > 0 for v in K.values()):
            print(f"  K_({u0},{u1}) -> {K}")

# At (q, q^3): K_{(1,0)} = q. K_{(0,1)} = q + q^3. K_{(1,1)} = q^4.
# Sum: 2q + q^3 + q^4. But Q_1 = 2q + q^2 + q^3. Doesn't match.

# Conclusion: the key polynomial decomposition works at (q, q^2) for Q_1 
# but the specific set of keys {(1,0), (0,1), (1,1)} is probably not 
# generalizable naively to Q_n via products/sums.

# Let me try a completely different angle: Grothendieck polynomials.
# G_sigma(x, y) specialize to give polynomials with alternating signs in y.
# The (zq;q)_inf factor in the Q definition might correspond to the y-variables
# in a Grothendieck polynomial.

# For K-theory: the K-theoretic Schubert polynomial K_u = G_sigma(x, 1) has
# the property that its principal specialization x_i = q^{i-1} gives a 
# q-analogue of the number of lattice points in a certain polytope.

# Let me compute some Grothendieck specializations.

def grothendieck_poly(u, num_vars):
    """
    G_u(x) Grothendieck polynomial (not the two-alphabet version).
    G_lambda = prod (1 - y_j/x_i) for dominant lambda (with y=1).
    
    Actually this is complex. Let me use the definition via
    hat{pi}_i operators: hat{pi}_i(f) = pi_i(f(1 - x_{i+1}/x_i))
    or equivalently, hat{pi}_i(f) = (f - x_{i+1}/x_i s_i(f)) / (1 - x_{i+1}/x_i)
    = x_i(f - x_{i+1}/x_i s_i(f)) / (x_i - x_{i+1})
    = (x_i f - x_{i+1} s_i(f)) / (x_i - x_{i+1})
    
    Wait, that's the same as the Demazure operator pi_i!
    
    No, the Grothendieck version is different:
    hat{pi}_i(f) = pi_i((1 - x_{i+1})f) for the single-variable 0-Hecke.
    
    This is getting complicated. Let me skip this and focus on writing up.
    """
    pass


# Final summary computation
print("\n\n=== SUMMARY ===")
print("Q_1 for c=(2,1,1) decomposes as K_{(1,0)} + K_{(0,1)} + K_{(1,1)} at (q,q^2)")
print("This means Q_1 is the graded dimension of Dem(1,0) + Dem(0,1) + Dem(1,1)")
print("where Dem(u) denotes the Demazure module for GL_2.")
print()
print("The key polynomial K_{(0,1)}(x_1,x_2) = x_1 + x_2 is the character of")
print("the standard representation of GL_2 restricted to the Borel.")
print()
print("Together, K_{(1,0)} + K_{(0,1)} + K_{(1,1)} = x_1 + (x_1+x_2) + x_1*x_2")
print("= 2x_1 + x_2 + x_1*x_2")
print("which is NOT a single character of any representation.")
print()
print("However, the positivity of Q_1 at (q,q^2) follows immediately from the")
print("positivity of each key polynomial: key polynomials always have nonneg")
print("integer coefficients, hence any specialization at positive q-powers")
print("is a polynomial with nonneg coefficients.")
print()
print("The challenge is to show that Q_n decomposes as a POSITIVE sum of")
print("key polynomial specializations for ALL n and ALL profiles c.")

