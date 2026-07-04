"""
Seed 5 — Deeper Schubert/Lascoux analysis.

Key idea: Can Q_{n,c}(q) be interpreted as a graded dimension of a 
Demazure module or a Richardson variety?

Observations from the data:
1. For d=2: Q_n = q^{n^2}. This is the Hilbert function of a point.
2. For d=4, c=(2,1,1): 
   Q_1 = 2q + q^2 + q^3
   Q_2 = q^3 + 3q^4 + 2q^5 + 3q^6 + 2q^7 + 2q^8 + q^9 + q^10 + q^12
   Q_3 has leading term 1*q^27, and an isolated term q^27 at the end.

3. The degree sequence for (2,1,1): 0, 3, 12, 27, 48 = 3*n^2
   The min degree: 0, 1, 3, 7, 12 = n(n-1)/2 + ...
   Actually: 0, 1, 3, 7, 12. Diffs: 1, 2, 4, 5. Not clean.
   Wait, from the output: n=4 has deg=[12, 48]. min_deg=12 = 3*4*(4-1)/2/? 
   0, 1, 3, 7, 12: diffs 1, 2, 4, 5. That's n(3n-1)/2 for n=0,1,2,3,4 gives 0, 1, 5, 12, 22. No.
   
   Hmm: 0, 1, 3, 7, 12. These are triangular numbers shifted? 
   T_0=0, T_1=1, T_2=3, T_3=6, T_4=10. Not exactly.
   n=3: min_deg=7 = 6+1. n=4: 12 = 10+2. So min_deg = T_n + (n-1)?
   T_n + n - 1 = n(n+1)/2 + n - 1 = n^2/2 + 3n/2 - 1. For n=3: 9/2+9/2-1=8. No.
   
   Let me just note the pattern and move on.

Now for the Schubert connection. The key polynomial K_lambda (Demazure character)
and the Grothendieck polynomial G_sigma are both related to Q_{n,c} potentially via:

IDEA: The bounded cylindric partition F_{c,n}(q) at q→1 counts lattice points 
in a polytope. This polytope might be a Gelfand-Tsetlin polytope or a 
Feigin-Fourier-Littelmann polytope, whose lattice point count is given 
by a Demazure character.

If F_{c,n}(q) = sum_lambda (key polynomial K_lambda specialized at q),
then Q_{n,c}(q) = (q;q)_n * [z^n](zq;q)_inf * F_c(z,q) would inherit 
positivity from the key polynomial expansion.

Let me test: does F_{c,n}(1) have a Demazure character interpretation?

For c=(1,1,0), d=2, k=3:
F_{c,n}(1) values: 1, 81, 1622, 14119, 67940 (from seed8 output)
Is 81 = 3^4? Yes. Is 1622 recognizable? 1622 = 2 * 811. Not obvious.

For c=(2,1,1), d=4, k=3:
Need to compute F_{c,n}(1).

Actually, from Borodin's formula, F_c(q) has known product form.
F_{c,n}(1) should be computable.

Let me focus on the actual Schubert-theoretic angle.

CORE IDEA from Lascoux's work:
The divided difference operators pi_i act on polynomials and produce 
Schubert polynomials. The key property is:
- If f is a polynomial with positive integer coefficients,
  then pi_i(f) may or may not be positive.
- BUT: if f = Y_v (a Schubert polynomial), then pi_i(Y_v) is either
  0 or another Schubert polynomial Y_{v'}.
- The Cauchy kernel Theta_n^Y = sum_v Y_v(x,y) is a reproducing kernel.

CONNECTION TO CYLINDRIC PARTITIONS:
The cylindric partition generating function F_c(q) is (by Borodin) a 
specialization of an infinite product. This infinite product can be 
related to the Cauchy identity for Schur functions:

prod_{i,j} 1/(1 - x_i y_j) = sum_lambda s_lambda(x) s_lambda(y)

For the cylindric case, the product formula involves q-pochhammer 
factors (q^a; q^t)_inf, which are specializations of the Cauchy kernel
at geometric sequences x = (q^a, q^{a+t}, q^{a+2t}, ...).

So F_c(q) = specialization of an infinite Schur function sum, where
the specialization is x_i = q^{a_i}, y_j = q^{b_j} for sequences
determined by the profile c.

This means F_c(z,q) should similarly be a specialization of a 
two-parameter Cauchy-type kernel. The question is whether the extraction
[z^n]((zq;q)_inf * F_c(z,q)) produces something that remains positive
under this specialization.

KEY LEMMA (from Lascoux, Chunk 4): 
K_u * x_1^k ... x_k = Y_{u+[k,...,1,0^{n-k}]}(x, 0)

This connects key polynomials (which are Demazure characters = 
nonneg integer-coefficient polynomials) to Schubert polynomials.

QUESTION: Is Q_{n,c}(q) a specialization of a key polynomial K_u?

For a key polynomial K_u(x_1,...,x_m), the specialization 
K_u(q, q^2, ..., q^m) gives a polynomial in q with positive coefficients
(since K_u has positive integer coefficients in the x_i).

If Q_{n,c}(q) = K_u(q, q^a, q^b, ...) for some u and some positive exponents,
then positivity follows immediately!

Let me check: for d=4, c=(2,1,1):
Q_1 = 2q + q^2 + q^3

Can this be K_u(q) for a 1-variable key polynomial?
K_u(x) = x^u for dominant u. So K_u(q) = q^u. Only monomials. No.

For 2 variables: K_{(a,b)}(q, q^2) = ?
K_{(1,0)}(x,y) = x. K_{(1,0)}(q,q^2) = q.
K_{(0,1)}(x,y) = x + y. K_{(0,1)}(q,q^2) = q + q^2.
K_{(2,0)}(x,y) = x^2. K_{(2,0)}(q,q^2) = q^2.
K_{(1,1)}(x,y) = xy. K_{(1,1)}(q,q^2) = q^3.
K_{(0,2)}(x,y) = x^2 + xy + y^2. K_{(0,2)}(q,q^2) = q^2 + q^3 + q^4.

Hmm: Q_1 = 2q + q^2 + q^3. 
= q + K_{(0,1)}(q,q^2) + q^3?
= q + (q + q^2) + q^3 = 2q + q^2 + q^3. Yes!

So Q_1 = K_{(1,0)}(q,q^2) + K_{(0,1)}(q,q^2) + K_{(1,1)}(q,q^2)
       = q + (q + q^2) + q^3

Wait, K_{(1,0)} + K_{(0,1)} + K_{(1,1)} at (q, q^2):
= q + (q + q^2) + q^3 = 2q + q^2 + q^3. YES!

This is exactly Q_1 for profile (2,1,1)!

Now K_{(1,0)} = x, K_{(0,1)} = x + y (the Demazure character for s_1 acting on y),
K_{(1,1)} = xy.

In terms of representations: these are Demazure characters for GL_2.
K_{(1,0)} = character of B-module corresponding to highest weight (1,0)
K_{(0,1)} = character of B-module for weight (0,1) after applying s_1
K_{(1,1)} = character of 1-dim representation of weight (1,1)

The sum K_{(1,0)} + K_{(0,1)} + K_{(1,1)} is NOT a single Demazure character
but a sum of three. In representation theory, this would be the character of
a direct sum of three Demazure modules.

Let me check Q_1 for other profiles.
"""

# Key polynomial computation
def key_poly(u, num_vars):
    """
    Compute Demazure character K_u in variables x_1, ..., x_{num_vars}.
    
    K_lambda = x^lambda for dominant lambda.
    K_{..., u_i, u_{i+1}, ...} with u_i < u_{i+1} is obtained by
    applying pi_i to K_{..., u_{i+1}, u_i, ...} where pi_i is the
    Demazure operator: pi_i(f) = (x_i f - x_{i+1} s_i(f)) / (x_i - x_{i+1}).
    
    Representation: polynomial as dict of tuples -> coefficient.
    """
    n = num_vars
    u = list(u) + [0] * (n - len(u))
    u = u[:n]
    
    def sort_to_dominant(v):
        """Sort v to dominant (decreasing) and record the permutation."""
        # Bubble sort, tracking swaps
        v = list(v)
        swaps = []
        for i in range(len(v)):
            for j in range(len(v) - 1, i, -1):
                if v[j] > v[j-1]:
                    v[j], v[j-1] = v[j-1], v[j]
                    swaps.append(j-1)  # swap at position j-1
        return tuple(v), swaps
    
    def apply_pi(poly, i):
        """
        Apply Demazure operator pi_i to a polynomial.
        pi_i(f) = (x_i f - x_{i+1} s_i(f)) / (x_i - x_{i+1})
        
        For a monomial x^a: if a_i >= a_{i+1}, then
        pi_i(x^a) = x^{a} + x^{a with a_i-1, a_{i+1}+1} + ... + x^{a with a_i=a_{i+1}, a_{i+1}=a_i}
        (sum of monomials from a to s_i(a))
        
        If a_i < a_{i+1}, then pi_i(x^a) = -pi_i(x^{s_i(a)}) + x^{s_i(a)}
        ... this is getting complicated. Let me use the direct formula.
        
        pi_i(x^a) = sum_{j=0}^{a_i - a_{i+1}} x^{a with a_i -> a_i - j, a_{i+1} -> a_{i+1} + j}
        if a_i >= a_{i+1}, and 0 if a_i < a_{i+1}... no that's not right either.
        
        Actually, pi_i(x^a) = sum_{k=a_{i+1}}^{a_i} x^{a with a_i -> k, a_{i+1} -> a_i + a_{i+1} - k}
        = sum of monomials obtained by "distributing" the total a_i + a_{i+1} between positions i and i+1,
        keeping a_i >= a_{i+1}.
        
        Wait no. The isobaric divided difference is:
        pi_i(f) = (f - s_i(f)) / (1 - x_{i+1}/x_i) for the 0-Hecke version.
        More precisely:
        pi_i(f) = partial_i(x_i * f) where partial_i(g) = (g - s_i(g))/(x_i - x_{i+1}).
        
        For a monomial x^a:
        x_i * x^a = x^{a + e_i}
        partial_i(x^{a + e_i}) = (x^{a+e_i} - x^{s_i(a+e_i)}) / (x_i - x_{i+1})
        
        If (a+e_i)_i > (a+e_i)_{i+1}, i.e., a_i + 1 > a_{i+1}:
        partial_i(x^{a+e_i}) = x^{a_1,...,a_{i+1},a_{i+1},...} + ... (all intermediate monomials)
        
        Actually for the simple case: partial_i(x_i^p x_{i+1}^q) = 
        sum_{j=0}^{p-q-1} x_i^{q+j} x_{i+1}^{p-j} if p > q, else 0 if p = q, else -(partial applied to swapped).
        
        Hmm wait: partial_i(x_i^a x_{i+1}^b) = (x_i^a x_{i+1}^b - x_i^b x_{i+1}^a) / (x_i - x_{i+1})
        = x_i^b x_{i+1}^b * (x_i^{a-b} - x_{i+1}^{a-b}) / (x_i - x_{i+1})
        = x_i^b x_{i+1}^b * sum_{j=0}^{a-b-1} x_i^j x_{i+1}^{a-b-1-j}   (if a > b)
        = sum_{j=0}^{a-b-1} x_i^{b+j} x_{i+1}^{a-1-j}
        
        So pi_i(x^a) = partial_i(x_i * x^a) = partial_i(x_i^{a_i+1} x_{i+1}^{a_{i+1}} * rest)
        = sum_{j=0}^{a_i - a_{i+1}} x_i^{a_{i+1}+j} x_{i+1}^{a_i-j} * rest
        (if a_i + 1 > a_{i+1}, i.e., a_i >= a_{i+1})
        
        = 0 if a_i + 1 <= a_{i+1}, i.e., a_i < a_{i+1}
        
        And if a_i = a_{i+1} - 1: partial_i(x_i^{a_i+1} x_{i+1}^{a_i+1}) 
        with a_i+1 = a_{i+1}, so partial_i = 0, and pi_i = 0? 
        No: pi_i(x^a) = partial_i(x_i * x^a). If a_i + 1 = a_{i+1}, this is
        partial_i(x_i^{a_{i+1}} x_{i+1}^{a_{i+1}}) = 0.
        If a_i + 1 > a_{i+1}: we get the sum above.
        If a_i + 1 < a_{i+1}: partial_i gives a negative result... 
        Actually no: pi_i is the Demazure operator, not the divided difference.
        
        Let me just use: pi_i(x^a) = sum_{k=0}^{max(0, a_i - a_{i+1})} x^{a'} where
        a'_j = a_j for j != i, i+1, and a'_i = a_{i+1} + k, a'_{i+1} = a_i - k.
        But only if a_i >= a_{i+1}. If a_i < a_{i+1}, pi_i(x^a) = 0.
        
        Wait no, that's the formula for the key polynomial directly. Let me
        reconsider. The Demazure operator is:
        
        pi_i(f) = (x_i f - x_{i+1} s_i(f)) / (x_i - x_{i+1})
        
        For x^a with a_i >= a_{i+1}:
        pi_i(x^a) = sum_{j=a_{i+1}}^{a_i} x^{..., j, a_i+a_{i+1}-j, ...}
        
        For x^a with a_i < a_{i+1}:
        pi_i(x^a) = -sum_{j=a_i+1}^{a_{i+1}-1} x^{..., j, a_i+a_{i+1}-j, ...}
        
        Hmm, this is negative! So pi_i can produce negative coefficients.
        But for KEY polynomials, it always stays positive because we start from
        dominant and apply pi in the right order.
        """
        result = {}
        for exp, coeff in poly.items():
            exp = list(exp)
            ai = exp[i]
            ai1 = exp[i + 1]
            rest = list(exp)
            if ai >= ai1:
                for j in range(ai1, ai + 1):
                    new_exp = list(rest)
                    new_exp[i] = j
                    new_exp[i + 1] = ai + ai1 - j
                    key = tuple(new_exp)
                    result[key] = result.get(key, 0) + coeff
            else:
                # ai < ai1: pi_i(x^a) = 0 ... actually I think for Demazure
                # it's just 0 when the weight is already "on the wrong side"
                # In the standard convention: pi_i(f) = partial_i(x_i * f)
                # For x^a with a_i < a_{i+1}:
                # x_i * x^a has exponent (a_i+1, a_{i+1}) at positions i, i+1.
                # If a_i + 1 <= a_{i+1}: partial_i gives monomials.
                # Let me just compute directly.
                p = ai + 1
                q = ai1
                if p > q:
                    for j in range(q, p + 1):
                        new_exp = list(rest)
                        new_exp[i] = j
                        new_exp[i + 1] = p + q - 1 - j + ai1 - q  # this is getting confused
                        # Let me redo: pi_i(x^a) = partial_i(x_i^{a_i+1} x_{i+1}^{a_{i+1}} * prod_{j!=i,i+1} x_j^{a_j})
                        pass
                # Actually, let me just implement it cleanly.
                # f = x^a. s_i(f) = x^{s_i(a)} where s_i swaps positions i, i+1.
                # pi_i(f) = (x_i * f - x_{i+1} * s_i(f)) / (x_i - x_{i+1})
                # = (x_i^{a_i+1} x_{i+1}^{a_{i+1}} - x_i^{a_{i+1}} x_{i+1}^{a_i+1}) / (x_i - x_{i+1}) * rest
                # Let P = a_i + 1, Q = a_{i+1}.
                # (x_i^P x_{i+1}^Q - x_i^Q x_{i+1}^P) / (x_i - x_{i+1})
                # If P > Q: = sum_{j=0}^{P-Q-1} x_i^{Q+j} x_{i+1}^{P-1-j}
                # If P = Q: = 0
                # If P < Q: = -sum_{j=0}^{Q-P-1} x_i^{P+j} x_{i+1}^{Q-1-j}
                P = ai + 1
                Q = ai1
                if P > Q:
                    for j in range(P - Q):
                        new_exp = list(rest)
                        new_exp[i] = Q + j
                        new_exp[i + 1] = P - 1 - j
                        key = tuple(new_exp)
                        result[key] = result.get(key, 0) + coeff
                elif P < Q:
                    for j in range(Q - P):
                        new_exp = list(rest)
                        new_exp[i] = P + j
                        new_exp[i + 1] = Q - 1 - j
                        key = tuple(new_exp)
                        result[key] = result.get(key, 0) - coeff
                # P == Q: contribution is 0
        return {k: v for k, v in result.items() if v != 0}
    
    # Start from dominant (sorted decreasing)
    dom, swaps = sort_to_dominant(u)
    
    # Start with x^dom
    poly = {dom: 1}
    
    # Apply pi_i in reverse order of swaps
    for i in reversed(swaps):
        poly = apply_pi(poly, i)
    
    return poly


def specialize_key(u, num_vars, vals):
    """Specialize K_u(x_1,...,x_n) at x_i = vals[i]."""
    # vals should be a list of q-powers, but we work symbolically
    # For now, vals[i] = q^{a_i}, and we return a polynomial in q.
    poly = key_poly(u, num_vars)
    result = {}
    for exp, coeff in poly.items():
        # q-degree = sum_i a_i * exp_i where vals[i] = q^{a_i}
        q_deg = sum(vals[i] * exp[i] for i in range(num_vars))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


# Test key polynomial computation
print("Key polynomial tests:")
# K_{(2,1)} should be x^{2,1} = x_1^2 * x_2
K21 = key_poly((2, 1), 2)
print(f"K_(2,1) = {K21}")  # Should be {(2,1): 1}

# K_{(0,1)} = pi_1(K_{(1,0)}) = pi_1(x_1) = x_1 + x_2
K01 = key_poly((0, 1), 2)
print(f"K_(0,1) = {K01}")  # Should be {(1,0): 1, (0,1): 1}

# K_{(0,2)} = pi_1(K_{(2,0)}) = x_1^2 + x_1*x_2 + x_2^2
K02 = key_poly((0, 2), 2)
print(f"K_(0,2) = {K02}")

# K_{(1,0,2)} in 3 variables
K102 = key_poly((1, 0, 2), 3)
print(f"K_(1,0,2) = {K102}")

print()

# Now test the Q_1 = K decomposition for (2,1,1), d=4
print("Q_1 for profile (2,1,1) = 2q + q^2 + q^3")
print("Testing Key polynomial decompositions at (q, q^2):")

# Sum over all compositions u with |u| in some range
for u0 in range(4):
    for u1 in range(4):
        K = specialize_key((u0, u1), 2, [1, 2])
        if K:
            print(f"  K_({u0},{u1})(q, q^2) = {K}")

print("\nSum K_(1,0) + K_(0,1) + K_(1,1) at (q, q^2):")
s = {}
for u in [(1,0), (0,1), (1,1)]:
    K = specialize_key(u, 2, [1, 2])
    for k, v in K.items():
        s[k] = s.get(k, 0) + v
print(f"  = {s}")
print(f"  Q_1 = {dict(sorted({1:2, 2:1, 3:1}.items()))}")
print(f"  Match: {s == {1:2, 2:1, 3:1}}")

# Try with 3 variables at (q, q^2, q^3) or (q, q, q)
print("\nTrying 3 variables at (q, q^2, q^3):")
for u0 in range(3):
    for u1 in range(3):
        for u2 in range(3):
            if u0 + u1 + u2 > 3:
                continue
            K = specialize_key((u0, u1, u2), 3, [1, 2, 3])
            if K:
                print(f"  K_({u0},{u1},{u2})(q,q^2,q^3) = {K}")

# Try: Q_1 = sum of key polys at (q, q^2, q^3)?
# Q_1 = 2q + q^2 + q^3
# Looking at the 3-var specializations...

print("\n\nTrying specialization (q, q, q) (all equal):")
for u0 in range(4):
    for u1 in range(u0+1):
        for u2 in range(u1+1):
            K = specialize_key((u0, u1, u2), 3, [1, 1, 1])
            if K:
                print(f"  K_({u0},{u1},{u2})(q,q,q) = {K}")

print("\n\nKey polynomial expansion search for Q_1 = 2q + q^2 + q^3:")
target = {1: 2, 2: 1, 3: 1}
# Try specializations (q^a, q^b) for various a, b
for a in range(1, 5):
    for b in range(a, 5):
        # Enumerate key polys and check if any subset sums to target
        keys = {}
        for u0 in range(5):
            for u1 in range(5):
                if u0 + u1 > 5:
                    continue
                K = specialize_key((u0, u1), 2, [a, b])
                if K and all(v > 0 for v in K.values()):
                    keys[(u0, u1)] = K
        
        # Check if target is a sum of some subset
        # This is a subset-sum problem; for small cases, just try pairs
        for u, Ku in keys.items():
            if Ku == target:
                print(f"  Q_1 = K_{u}(q^{a}, q^{b})")
            for v, Kv in keys.items():
                s = dict(Ku)
                for k, val in Kv.items():
                    s[k] = s.get(k, 0) + val
                if s == target:
                    print(f"  Q_1 = K_{u}(q^{a},q^{b}) + K_{v}(q^{a},q^{b})")

