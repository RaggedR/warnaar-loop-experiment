"""
Seed 7, Layer 2: Test the Demazure / key polynomial decomposition for d=7.

For sl_3, the key polynomials (Demazure characters) at specialization
x_1 = q, x_2 = q^2 give polynomials in q with non-negative coefficients.

Q_{n,c}(q) should decompose as a non-negative sum of such specializations.
"""

def key_polynomial_sl2(a, b, q_spec='q'):
    """
    GL_2 key polynomial K_{(a,b)} specialized at (q, q^2).
    For a >= b: K_{(a,b)}(q, q^2) = q^{a+2b} + q^{a-1+2b+2} + ... (Demazure formula)
    Actually, K_{(a,b)} for GL_2 is the Demazure character.
    For a >= b >= 0: K_{(a,b)}(x_1, x_2) = x_1^a * x_2^b (dominant, just a monomial? No.)
    
    Actually for GL_2: Key polynomials = Demazure characters.
    For weight (a,b) with a >= b:
      K_{(a,b)}(x_1, x_2) = x_1^a x_2^b + x_1^{a-1} x_2^{b+1} + ... + x_1^b x_2^a
                           = x_2^b (x_1^a + x_1^{a-1}x_2 + ... + x_1^b x_2^{a-b})
                           = x_2^b * sum_{j=0}^{a-b} x_1^{a-j} x_2^j

    Wait, that's the Schur polynomial s_{(a-b)}(x_1, x_2) * x_2^b.
    Actually K_{(a,b)} for dominant (a >= b) IS the Schur polynomial
    s_{a-b}(x_1, x_2) * x_1^b * x_2^b ... no.
    
    Let me just use the definition:
    For (a,b) dominant (a >= b >= 0):
      K_{(a,b)}(x_1, x_2) = s_{(a,b)}(x_1, x_2)
                           = sum over SSYT of shape (a,b) of x^content
    
    For GL_2, s_{(a,b)}(x_1,x_2) = sum_{j=0}^{a-b} x_1^{a-j} x_2^{b+j}
    (this is the Schur poly for two variables).
    
    Specializing x_1 = q, x_2 = q^2:
    K_{(a,b)}(q, q^2) = sum_{j=0}^{a-b} q^{a-j} * q^{2(b+j)} = sum_{j=0}^{a-b} q^{a+2b+j}
    = q^{a+2b} * (1 + q + q^2 + ... + q^{a-b})
    = q^{a+2b} * (q^{a-b+1} - 1) / (q - 1)  if q != 1
    
    At q=1: K_{(a,b)}(1,1) = a - b + 1.
    
    For (a,b) with a < b (anti-dominant):
    K_{(a,b)} = x_1^a x_2^b (just the monomial, in the key polynomial convention).
    So K_{(a,b)}(q, q^2) = q^{a+2b}.
    """
    if a >= b >= 0:
        result = {}
        for j in range(a - b + 1):
            deg = a + 2*b + j
            result[deg] = result.get(deg, 0) + 1
        return result
    elif b > a >= 0:
        return {a + 2*b: 1}
    else:
        return {}


# Test: Q_1 for c = (3,2,2), d=7
Q1 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}  # 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6

print("Q_1 for c=(3,2,2), d=7:")
print(f"  Q_1 = {Q1}")
print(f"  Q_1(1) = {sum(Q1.values())}")
print()

# Try to decompose Q_1 as a sum of K_{(a,b)}(q, q^2) with non-negative integer coefficients.
# K_{(a,b)}(q,q^2) = q^{a+2b} (1 + q + ... + q^{a-b}) for a >= b >= 0
#                  = q^{a+2b} for a < b

# The smallest degree terms of Q_1 are at q^1. So we need K's with min degree 1.
# K_{(1,0)}(q,q^2) = q^1 (1+q) = q + q^2
# K_{(0,0)}(q,q^2) = 1
# K_{(2,0)}(q,q^2) = q^2(1+q+q^2) = q^2 + q^3 + q^4
# K_{(1,1)}(q,q^2) = q^3 (just monomial since a=b)
# K_{(2,1)}(q,q^2) = q^4(1+q) = q^4 + q^5
# K_{(3,0)}(q,q^2) = q^3(1+q+q^2+q^3) = q^3 + q^4 + q^5 + q^6
# K_{(0,1)}(q,q^2) = q^2 (anti-dominant: monomial)

# Let's try greedy decomposition
print("Available key polynomials K_{(a,b)}(q,q^2) for small a,b:")
keys = {}
for a in range(8):
    for b in range(8):
        k = key_polynomial_sl2(a, b)
        if k and max(k.keys()) <= 10:
            keys[(a,b)] = k
            if min(k.keys()) <= 6:
                print(f"  K_{{{a},{b}}} = {k}")

print()

# Greedy decomposition of Q_1
def poly_sub_safe(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) - v
    return {k: v for k, v in result.items() if v != 0}

def try_decompose(target, keys_list):
    """Try greedy decomposition of target into sum of keys."""
    remaining = dict(target)
    decomp = []
    
    # Sort keys by min degree (ascending), then by size (descending)
    sorted_keys = sorted(keys_list.items(), key=lambda x: (min(x[1].keys()), -sum(x[1].values())))
    
    for (a,b), kpoly in sorted_keys:
        if not remaining:
            break
        # How many times can we subtract kpoly from remaining?
        if not kpoly:
            continue
        max_times = float('inf')
        for deg, coeff in kpoly.items():
            if deg in remaining:
                max_times = min(max_times, remaining[deg] // coeff)
            else:
                max_times = 0
                break
        if max_times > 0 and max_times < float('inf'):
            for _ in range(int(max_times)):
                for deg, coeff in kpoly.items():
                    remaining[deg] = remaining.get(deg, 0) - coeff
                remaining = {k:v for k,v in remaining.items() if v != 0}
                decomp.append((a,b))
    
    return decomp, remaining

# Filter to keys with coefficients fitting in Q_1's range
relevant_keys = {k: v for k, v in keys.items() if min(v.keys()) >= 1 and max(v.keys()) <= 6}
decomp, remaining = try_decompose(Q1, relevant_keys)
print(f"Greedy decomposition of Q_1:")
print(f"  Components: {decomp}")
print(f"  Remaining: {remaining}")
print()

# Try a more systematic approach: enumerate all possible decompositions
# Q_1 has terms from q^1 to q^6. The coefficient of q^1 is 2.
# Only K_{(1,0)} contributes at q^1 (with coefficient 1).
# So we need exactly 2 copies of K_{(1,0)} = q + q^2.
# After subtracting: 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6 - 2(q+q^2) = q^2 + 2q^3 + 2q^4 + q^5 + q^6

remainder_after_K10 = {2: 1, 3: 2, 4: 2, 5: 1, 6: 1}
print(f"After subtracting 2·K_{{(1,0)}}: {remainder_after_K10}")

# Now q^2: need to decompose q^2 + 2q^3 + 2q^4 + q^5 + q^6
# K_{(2,0)} = q^2 + q^3 + q^4. Subtract 1 copy:
# 2q^3 + 2q^4 + q^5 + q^6 - (q^3 + q^4) = q^3 + q^4 + q^5 + q^6
remainder2 = {3: 1, 4: 1, 5: 1, 6: 1}
print(f"After further subtracting K_{{(2,0)}}: {remainder2}")

# q^3 + q^4 + q^5 + q^6 = K_{(3,0)} = q^3(1+q+q^2+q^3) = q^3+q^4+q^5+q^6. YES!
print(f"This equals K_{{(3,0)}}!")
print()
print(f"DECOMPOSITION: Q_1 = 2·K_{{(1,0)}} + K_{{(2,0)}} + K_{{(3,0)}}")
print(f"  = 2·s_{{(1)}}(q,q²) + s_{{(2)}}(q,q²) + s_{{(3)}}(q,q²)")
print()

# Verify
total = {}
for _ in range(2):
    for k, v in key_polynomial_sl2(1, 0).items():
        total[k] = total.get(k, 0) + v
for k, v in key_polynomial_sl2(2, 0).items():
    total[k] = total.get(k, 0) + v
for k, v in key_polynomial_sl2(3, 0).items():
    total[k] = total.get(k, 0) + v
print(f"Verification: 2K_{{10}} + K_{{20}} + K_{{30}} = {total}")
print(f"Q_1 = {Q1}")
print(f"Match: {total == Q1}")
print()

# Note: all (a,b) in the decomposition have b=0, so these are
# K_{(a,0)}(q,q^2) = q^a(1+q+...+q^a) = q-analogue of (a+1)
# These are just q^a · [a+1]_q where [n]_q = (q^n-1)/(q-1)

# For the other profile (4,2,1):
Q1_421 = {1: 2, 2: 2, 3: 2, 4: 2, 5: 1, 6: 1, 8: 1}  # 2q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6 + q^8
print(f"Q_1 for c=(4,2,1), d=7:")
print(f"  Q_1 = {Q1_421}")

# q^1 coefficient = 2: need 2 copies of K_{(1,0)} = q + q^2
# After subtracting: 2q^3 + 2q^4 + q^5 + q^6 + q^8
remainder = {3: 2, 4: 2, 5: 1, 6: 1, 8: 1}
print(f"After 2·K_{{(1,0)}}: {remainder}")

# K_{(1,1)} = q^3 (monomial). Take 1:
# q^3 + 2q^4 + q^5 + q^6 + q^8
remainder = {3: 1, 4: 2, 5: 1, 6: 1, 8: 1}
print(f"After K_{{(1,1)}}: {remainder}")

# K_{(3,0)} = q^3 + q^4 + q^5 + q^6. Take 1:
# q^4 + q^8
remainder = {4: 1, 8: 1}
print(f"After K_{{(3,0)}}: {remainder}")

# K_{(4,0)} = q^4 + q^5 + q^6 + q^7 + q^8. No, doesn't fit.
# K_{(0,2)} = q^4 (monomial). Take 1:
# q^8
remainder = {8: 1}
print(f"After K_{{(0,2)}}: {remainder}")

# q^8 = K_{(0,4)} = q^8 or K_{(2,3)} = q^8 etc.
# K_{(0,4)} has b=4 > a=0, so it's anti-dominant: K_{(0,4)}(q,q^2) = q^{0+8} = q^8. YES!
print(f"After K_{{(0,4)}}: 0")
print()
print(f"DECOMPOSITION: Q_1((4,2,1)) = 2·K_{{(1,0)}} + K_{{(1,1)}} + K_{{(3,0)}} + K_{{(0,2)}} + K_{{(0,4)}}")
print()

# Verify
total2 = {}
for comp, mult in [((1,0),2), ((1,1),1), ((3,0),1), ((0,2),1), ((0,4),1)]:
    for _ in range(mult):
        for k, v in key_polynomial_sl2(*comp).items():
            total2[k] = total2.get(k, 0) + v
print(f"Verification: {total2}")
print(f"Q_1 = {Q1_421}")
print(f"Match: {total2 == Q1_421}")
print()

# Key observation: The decomposition uses GL_2 key polynomials (2 variables).
# But the sl_3 setting has 3 variables. We should use GL_3 key polynomials
# with x_1=q, x_2=q^2, x_3=q^3.

# For GL_3, the key polynomial K_alpha(x_1,x_2,x_3) for composition alpha = (a,b,c):
# If alpha is dominant (a >= b >= c): K_alpha = Schur poly s_{alpha}
# Otherwise: apply Demazure operators

# Let me just check GL_3 Schur at (q, q^2, q^3):
print("GL_3 Schur polynomials at (q, q^2, q^3):")
# s_{(1,0,0)}(q,q^2,q^3) = q + q^2 + q^3 = [3]_q · q
# s_{(2,0,0)}(q,q^2,q^3) = q^2 + q^3 + q^4 + q^3 + q^4 + q^5 = q^2 + 2q^3 + 2q^4 + q^5
# Wait, for 3 variables: s_{(2)} = sum x_i x_j for i <= j = x1^2 + x1*x2 + x1*x3 + x2^2 + x2*x3 + x3^2
# At (q,q^2,q^3): q^2 + q^3 + q^4 + q^4 + q^5 + q^6 = q^2 + q^3 + 2q^4 + q^5 + q^6

# s_{(1,1,0)}(q,q^2,q^3) = sum x_i*x_j for i < j = q*q^2 + q*q^3 + q^2*q^3 = q^3 + q^4 + q^5

# s_{(1,0,0)}(q,q^2,q^3) = q + q^2 + q^3

print(f"s_{{(1,0,0)}} = q + q^2 + q^3")
print(f"s_{{(2,0,0)}} = q^2 + q^3 + 2q^4 + q^5 + q^6")
print(f"s_{{(1,1,0)}} = q^3 + q^4 + q^5")
print(f"s_{{(1,1,1)}} = q^6")
print()

# Now try decomposing Q_1((3,2,2)) = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
# using GL_3 Schur polys at (q, q^2, q^3):
# 2·s_{(1,0,0)} = 2q + 2q^2 + 2q^3
# Q_1 - 2·s_{(1,0,0)} = q^2
# s_{(0,1,0)}? For GL_3, s_{(0,1,0)} is not standard.
# Actually for GL_3, key poly K_{(0,1,0)} = x_2 = q^2 at our specialization.
# So Q_1 = 2·s_{(1,0,0)} + K_{(0,1,0)}? = 2q + 2q^2 + 2q^3 + q^2 = 2q + 3q^2 + 2q^3
# Missing: 2q^4 + q^5 + q^6

# Hmm, let me try differently:
# s_{(1,0,0)} = q + q^2 + q^3 (dim 3 at q=1)
# s_{(1,1,0)} = q^3 + q^4 + q^5 (dim 3 at q=1)
# s_{(1,1,1)} = q^6 (dim 1 at q=1)
# s_{(2,0,0)} = q^2 + q^3 + 2q^4 + q^5 + q^6 (dim 6 at q=1)

# Try: Q_1 = 2·s_{(1,0,0)} + ... 
# 2·s_{(1)} = 2q + 2q^2 + 2q^3, sum = 6
# Remaining: q^2 + 2q^4 + q^5 + q^6, sum = 5
# That's hard to decompose with Schur polys. 
# Let me try: s_{(1)} + s_{(2)} = (q+q^2+q^3) + (q^2+q^3+2q^4+q^5+q^6) = q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6
# This is close to Q_1 = 2q + 3q^2 + 2q^3 + 2q^4 + q^5 + q^6
# Difference: q + q^2 = s_{(1)} without q^3... that's K_{(1,0,0)} minus K_{(0,0,1)} perhaps?

# Actually, let me just check Q_1(1) = 11 against sum of Schur poly values at q=1
# s_{(a,b,c)}(1,1,1) = product formula... for GL_3:
# s_{(a,b,c)} at (1,1,1) = det of (C(a_i+3-i, 3-j)) / det Vandermonde
# Actually easier: s_lambda(1,1,1) = product_{(i,j) in lambda} (3 + j - i) / hook(i,j)

# For Q_1(1) = 11, we need to express 11 as sum of Schur polynomial dimensions.
# Dimensions of GL_3 Schur polys:
# s_() = 1
# s_{(1)} = 3
# s_{(2)} = 6
# s_{(1,1)} = 3
# s_{(3)} = 10
# s_{(2,1)} = 8
# s_{(1,1,1)} = 1

# 11 = 3 + 8 = s_{(1)} + s_{(2,1)}
# 11 = 1 + 10 = s_{()} + s_{(3)}  ... but s_{()} = 1 contributes q^0 term
# 11 = 3 + 3 + 3 + 1 + 1 = s_{(1)} + s_{(1)} + s_{(1,1)} + 2 ... doesn't work
# 11 = 10 + 1 = s_{(3)} + s_{(1,1,1)} (but these have dims 10 and 1)

# s_{(3)}(q,q^2,q^3) = q^3 + q^4 + 2q^5 + 2q^6 + 2q^7 + q^8 + q^9
# That's too high degree for Q_1 which maxes at q^6.

# So GL_3 Schur decomposition doesn't directly work with specialization (q,q^2,q^3).
# Maybe we need specialization (q,q,q)? Or (1,q,q^2)?
print("Trying specialization (1, q, q^2) for GL_3:")
print(f"  s_{{(1)}}(1,q,q^2) = 1 + q + q^2")
print(f"  s_{{(2)}}(1,q,q^2) = 1 + q + 2q^2 + q^3 + q^4")
print(f"  s_{{(1,1)}}(1,q,q^2) = q + q^2 + q^3")
print(f"  s_{{(3)}}(1,q,q^2) = 1 + q + 2q^2 + 2q^3 + 2q^4 + q^5 + q^6")
print(f"  s_{{(2,1)}}(1,q,q^2) = q + 2q^2 + 2q^3 + 2q^4 + q^5")
print()
# These have q^0 terms, while Q_1 starts at q^1. So this specialization doesn't match.

# Maybe the right specialization involves a shift (Demazure-type).
# For ŝl_3 at level d, the principal specialization of the character involves
# x_i = q^i for the principal grading.
print("The correct framework is likely the AFFINE sl_3 Demazure crystal,")
print("not the finite GL_3 Schur decomposition.")
print("The Demazure operators in the affine setting produce different polynomials.")
