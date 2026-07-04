# Decompose Q_n into GL_3 key polynomials at specialisation (q, q^2, q^3)
# Using pure Python with numpy for the linear algebra

import numpy as np
from itertools import product as iprod

# Key polynomials for GL_3
# Implement recursively using Demazure operators

def key_polynomial_coeffs(alpha, max_deg):
    """Return coefficients of kappa_alpha(q, q^2, q^3) as array of length max_deg+1."""
    a = list(alpha)
    
    # Base case: dominant (weakly decreasing)
    if a[0] >= a[1] >= a[2]:
        # kappa_alpha = x1^a0 * x2^a1 * x3^a2 -> q^(a0 + 2*a1 + 3*a2)
        result = np.zeros(max_deg + 1, dtype=int)
        deg = a[0] + 2*a[1] + 3*a[2]
        if deg <= max_deg:
            result[deg] = 1
        return result
    
    # Find i such that a[i] < a[i+1]
    for i in range(2):
        if a[i] < a[i+1]:
            a_new = list(a)
            a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
            # Need to apply pi_{i+1} to kappa_{a_new}
            # pi_{i+1} operates on polynomials in x1, x2, x3
            # We need the full polynomial, not just the specialisation
            # Actually let me compute the full polynomial first
            break
    
    # This approach is getting complicated. Let me compute key polynomials differently.
    # Use the explicit formula via Kohnert diagrams or direct Demazure operators
    # on the polynomial ring.
    
    # Actually, let me work directly with the polynomial ring representation.
    pass

def demazure_op(i, poly_dict):
    """Apply pi_i to a polynomial represented as dict {(e1,e2,e3): coeff}.
    pi_i: swap variables x_i and x_{i+1}, compute (x_i*f - x_{i+1}*s_i(f))/(x_i-x_{i+1})."""
    # i is 0-indexed: i=0 swaps x1,x2; i=1 swaps x2,x3
    result = {}
    for (e1, e2, e3), c in poly_dict.items():
        exps = [e1, e2, e3]
        # Term: c * x1^e1 * x2^e2 * x3^e3
        # x_i * term = c * x^{e + delta_i}
        # s_i(term) = c * x^{swap(e, i, i+1)}
        # x_{i+1} * s_i(term) = c * x^{swap(e, i, i+1) + delta_{i+1}}
        
        # Numerator contribution: x_i * term - x_{i+1} * s_i(term)
        # = c * x^{e + delta_i} - c * x^{swap(e) + delta_{i+1}}
        
        # x_i * term
        e_up = list(exps)
        e_up[i] += 1
        key1 = tuple(e_up)
        result[key1] = result.get(key1, 0) + c
        
        # - x_{i+1} * s_i(term)
        e_swap = list(exps)
        e_swap[i], e_swap[i+1] = e_swap[i+1], e_swap[i]
        e_swap[i+1] += 1
        key2 = tuple(e_swap)
        result[key2] = result.get(key2, 0) - c
    
    # Now divide by (x_i - x_{i+1})
    # This is polynomial division; the result should be exact
    # (x_i - x_{i+1}) = x^{delta_i} - x^{delta_{i+1}}
    
    # Use synthetic division: repeatedly extract the leading term
    # Actually, for Demazure operators the division always works.
    # A simpler approach: use the identity
    # (a * x_i^{k+1} - a * x_{i+1}^{k+1}) / (x_i - x_{i+1}) = a * sum_{j=0}^k x_i^j * x_{i+1}^{k-j}
    
    # But the numerator is a general polynomial. Let me do long division.
    # For each monomial pair that differs only in x_i, x_{i+1} exponents...
    
    # Actually, the simplest approach: compute the numerator as a polynomial,
    # then perform multivariate polynomial division by (x_i - x_{i+1}).
    
    # Group terms by the exponents of all variables OTHER than x_i, x_{i+1}
    from collections import defaultdict
    groups = defaultdict(lambda: defaultdict(int))
    for (e1, e2, e3), c in result.items():
        exps = [e1, e2, e3]
        other_exp = list(exps)
        ei = other_exp[i]
        ej = other_exp[i+1]
        other_exp[i] = 0
        other_exp[i+1] = 0
        groups[tuple(other_exp)][(ei, ej)] += c
    
    # For each group, divide the bivariate polynomial by (x_i - x_{i+1})
    final = {}
    for other_exp, bivar in groups.items():
        # bivar is a dict {(ei, ej): coeff}
        # Divide by (x_i - x_{i+1}) = x_i - x_{i+1}
        # Polynomial in x_i, x_{i+1}: sum c_{a,b} x_i^a x_{i+1}^b
        # Divide by x_i - x_{i+1}
        
        # Use synthetic division: sort by total degree, process from highest
        max_total = max(a+b for (a,b) in bivar.keys()) if bivar else 0
        
        # Build coefficient array
        quotient = {}
        remainder = dict(bivar)
        
        while remainder:
            # Find leading term (highest total degree, then highest x_i power)
            best = None
            for (a, b) in sorted(remainder.keys(), key=lambda x: (-x[0]-x[1], -x[0])):
                if remainder[(a,b)] != 0:
                    best = (a, b)
                    break
            if best is None:
                break
            
            a, b = best
            c = remainder[(a, b)]
            
            if a == 0 and b == 0:
                # Remainder should be zero for Demazure operators
                if c != 0:
                    print(f"WARNING: nonzero remainder {c} at ({a},{b})")
                break
            
            # Divide leading term c * x_i^a * x_{i+1}^b by x_i - x_{i+1}
            # c * x_i^a * x_{i+1}^b / (x_i - x_{i+1})
            # = c * x_i^{a-1} * x_{i+1}^b + (quotient of c * x_i^{a-1} * x_{i+1}^{b+1})/(x_i-x_{i+1})
            # So: quotient term: c * x_i^{a-1} * x_{i+1}^b
            # New remainder: add c * x_i^{a-1} * x_{i+1}^{b+1} to remainder
            
            if a > 0:
                q_key = (a-1, b)
                quotient[q_key] = quotient.get(q_key, 0) + c
                # Subtract c * x_i^a * x_{i+1}^b from remainder (it's accounted for)
                remainder[(a, b)] = 0
                # Add c * x_i^{a-1} * x_{i+1}^{b+1} to remainder
                r_key = (a-1, b+1)
                remainder[r_key] = remainder.get(r_key, 0) + c
            else:
                # a=0, need x_{i+1} to handle
                # c * x_{i+1}^b / (x_i - x_{i+1}) -- this shouldn't happen for Demazure
                if c != 0:
                    print(f"WARNING: can't divide term {c}*x_i^0 * x_{i+1}^{b}")
                break
        
        # Convert quotient back to full exponent
        for (qi, qj), c in quotient.items():
            if c != 0:
                full_exp = list(other_exp)
                full_exp[i] += qi
                full_exp[i+1] += qj
                final[tuple(full_exp)] = final.get(tuple(full_exp), 0) + c
    
    return {k: v for k, v in final.items() if v != 0}

def key_polynomial(alpha):
    """Compute key polynomial as dict {(e1,e2,e3): coeff}."""
    a = list(alpha)
    
    if a[0] >= a[1] >= a[2]:
        return {tuple(a): 1}
    
    for i in range(2):
        if a[i] < a[i+1]:
            a_new = list(a)
            a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
            kappa_s = key_polynomial(tuple(a_new))
            return demazure_op(i, kappa_s)

def specialise(poly_dict):
    """Evaluate at x1=q, x2=q^2, x3=q^3. Return list of coefficients."""
    coeffs = {}
    for (e1, e2, e3), c in poly_dict.items():
        deg = e1 + 2*e2 + 3*e3
        coeffs[deg] = coeffs.get(deg, 0) + c
    return coeffs

# Build key polynomial basis
def build_key_basis(max_deg):
    """Build all specialised key polynomials up to given degree."""
    basis = []
    seen = set()
    for c_val in range(max_deg // 3 + 1):
        for b_val in range((max_deg - 3*c_val) // 2 + 1):
            for a_val in range(max_deg - 2*b_val - 3*c_val + 1):
                alpha = (a_val, b_val, c_val)
                kp = key_polynomial(alpha)
                sp = specialise(kp)
                # Convert to tuple for hashing
                sp_key = tuple(sorted(sp.items()))
                if sp_key not in seen and sp:
                    seen.add(sp_key)
                    # Convert to coefficient array
                    max_d = max(sp.keys())
                    arr = [0] * (max_deg + 1)
                    for d, v in sp.items():
                        arr[d] = v
                    basis.append((alpha, arr, sp))
    return basis

# Q_n polynomials (computed earlier)
Q_polys = {
    1: {0: 1, 1: 1, 2: 2, 3: 1},
    2: {0: 1, 1: 1, 2: 1, 3: 1, 4: 3, 5: 4, 6: 6, 7: 3, 8: 3, 9: 1, 10: 1},
    3: {0: 1, 1: 1, 2: 1, 4: 2, 5: 3, 6: 4, 7: 3, 8: 6, 9: 8, 10: 13, 11: 14, 12: 15, 13: 14, 14: 12, 15: 9, 16: 7, 17: 5, 18: 3, 19: 2, 20: 1, 21: 1}
}

for n in [1, 2, 3]:
    print(f"\n=== Decomposing Q_{n} ===")
    Q = Q_polys[n]
    max_deg = max(Q.keys())
    
    basis = build_key_basis(max_deg)
    print(f"Number of key polynomials: {len(basis)}")
    
    # Solve via nonneg integer least squares
    # Target vector
    target = np.array([Q.get(d, 0) for d in range(max_deg + 1)], dtype=float)
    
    # Basis matrix
    A_mat = np.zeros((max_deg + 1, len(basis)), dtype=float)
    for j, (alpha, arr, sp) in enumerate(basis):
        for d in range(max_deg + 1):
            A_mat[d, j] = arr[d]
    
    # Solve A_mat @ x = target with x >= 0, x integer
    # Use scipy linprog or just brute force for small cases
    from scipy.optimize import linprog
    
    c_obj = np.ones(len(basis))  # minimize total
    A_eq = A_mat
    b_eq = target
    bounds = [(0, None)] * len(basis)
    
    res = linprog(c_obj, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    if res.success:
        x_sol = np.round(res.x).astype(int)
        # Verify
        check = A_mat @ x_sol
        if np.allclose(check, target):
            terms = [(basis[j][0], x_sol[j]) for j in range(len(basis)) if x_sol[j] > 0]
            print(f"Q_{n} = " + " + ".join(f"{v}*kappa_{a}" for a, v in sorted(terms)))
            print(f"  Total multiplicity: {sum(v for _, v in terms)} (should be {sum(Q.values()) if n==1 else '?'})")
        else:
            print("LP solution doesn't verify as integer!")
            # Show residual
            print(f"Residual: {check - target}")
    else:
        print(f"LP failed: {res.message}")

