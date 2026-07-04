"""
Seed 5, Layer 2: Decompose Q_{n,c}(q) into GL_3 key polynomial specializations.

For sl_3 (GL_3), key polynomials K_u(x1,x2,x3) are indexed by compositions
u = (a,b,c) in N^3. They are Demazure characters and have nonneg coefficients
in the monomial basis.

The principal specialization at (q, q^2, q^3) gives:
  K_u(q, q^2, q^3) = sum over SSYT T of content u under Demazure crystal rules
                       of q^{wt(T)}

For a DOMINANT weight (partition) lambda = (a >= b >= c):
  K_lambda(x1,x2,x3) = s_lambda(x1,x2,x3) (the Schur polynomial)
  K_lambda(q,q^2,q^3) = q^{a+2b+3c} * s_lambda(1,q,q^2) (shifted Schur)

For non-dominant u, K_u is the Demazure character, obtained by applying
isobaric divided differences to a dominant monomial.

Let me compute K_u(q,q^2,q^3) for small u and check decomposability.

For the actual computation, I'll use the recursive definition:
  K_{(...,a,...,b,...)} where a < b at position (i,i+1):
    K_u = pi_i(K_{s_i(u)}) where s_i swaps positions i and i+1
    and pi_i(f) = (x_i * f - x_{i+1} * f^{s_i}) / (x_i - x_{i+1})
"""

from itertools import permutations
from collections import defaultdict


def demazure_op(poly, i, num_vars=3):
    """
    Apply the isobaric divided difference pi_i to a polynomial.
    pi_i(f) = (x_i * f - x_{i+1} * f^{s_i}) / (x_i - x_{i+1})
    
    poly is a dict mapping exponent tuples to coefficients.
    i is 0-indexed (swaps variables i and i+1).
    """
    result = {}
    for exp, coeff in poly.items():
        exp_list = list(exp)
        a, b = exp_list[i], exp_list[i+1]
        if a >= b:
            # Contribute x_i^a * x_{i+1}^b + x_i^{a-1} * x_{i+1}^{b+1} + ... + x_i^b * x_{i+1}^a
            for j in range(a - b + 1):
                new_exp = list(exp)
                new_exp[i] = a - j
                new_exp[i+1] = b + j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) + coeff
        else:
            # a < b: contribute -(x_i^{a+1} * x_{i+1}^{b-1} + ... + x_i^{b-1} * x_{i+1}^{a+1})
            for j in range(b - a - 1):
                new_exp = list(exp)
                new_exp[i] = a + 1 + j
                new_exp[i+1] = b - 1 - j
                new_exp = tuple(new_exp)
                result[new_exp] = result.get(new_exp, 0) - coeff
    
    return {k: v for k, v in result.items() if v != 0}


def compute_key_poly(u, num_vars=3):
    """
    Compute K_u(x_1,...,x_n) as a polynomial (dict of exponent tuples -> coefficients).
    
    Uses the recursive definition:
    If u is dominant (weakly decreasing), K_u = x^u.
    Otherwise, find i such that u_i < u_{i+1}, and K_u = pi_i(K_{s_i(u)}).
    """
    u = tuple(u)
    
    # Check if dominant
    is_dom = all(u[i] >= u[i+1] for i in range(len(u)-1))
    if is_dom:
        return {u: 1}
    
    # Find first descent (u_i < u_{i+1})
    for i in range(len(u)-1):
        if u[i] < u[i+1]:
            # Apply s_i to u
            u_swapped = list(u)
            u_swapped[i], u_swapped[i+1] = u_swapped[i+1], u_swapped[i]
            u_swapped = tuple(u_swapped)
            
            # Recursively compute K_{s_i(u)}
            K_swapped = compute_key_poly(u_swapped, num_vars)
            
            # Apply pi_i
            return demazure_op(K_swapped, i, num_vars)
    
    return {u: 1}


def specialize_key_poly(u, exponents=(1, 2, 3)):
    """
    Compute K_u(q^e1, q^e2, q^e3) as a polynomial in q.
    Returns dict {degree: coefficient}.
    """
    K = compute_key_poly(u, len(exponents))
    result = {}
    for exp, coeff in K.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


def poly_str(p):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"


def find_key_decomposition_3var(Q, max_comp_val=20, exponents=(1, 2, 3)):
    """
    Find nonneg integer coefficients such that
    Q(q) = sum a_u * K_u(q^e1, q^e2, q^e3).
    
    Uses greedy: subtract the longest key polynomials first.
    """
    if not Q:
        return {}, True
    
    max_deg = max(Q.keys())
    
    # Build dictionary of all key poly specializations up to max_deg
    available = {}
    for a in range(max_comp_val + 1):
        for b in range(max_comp_val + 1):
            for c_val in range(max_comp_val + 1):
                u = (a, b, c_val)
                min_possible = sum(e * x for e, x in zip(u, exponents))
                if min_possible > max_deg:
                    continue
                K = specialize_key_poly(u, exponents)
                if K and max(K.keys()) <= max_deg:
                    available[u] = K
    
    print(f"  Built {len(available)} available key polynomials")
    
    Q_rem = dict(Q)
    result = {}
    
    # Sort by number of terms (larger = more cancellation), then by max degree desc
    sorted_keys = sorted(available.items(), 
                         key=lambda x: (-len(x[1]), -max(x[1].keys())))
    
    # First pass: multi-term key polys
    for u, K in sorted_keys:
        if len(K) <= 1:
            continue
        max_mult = min(Q_rem.get(d, 0) for d in K.keys())
        if max_mult > 0:
            result[u] = max_mult
            for d, c in K.items():
                Q_rem[d] = Q_rem.get(d, 0) - max_mult * c
            Q_rem = {k: v for k, v in Q_rem.items() if v != 0}
    
    # Second pass: monomials (single-term key polys)
    for u, K in sorted_keys:
        if len(K) != 1:
            continue
        deg = list(K.keys())[0]
        if deg in Q_rem and Q_rem[deg] > 0:
            result[u] = Q_rem[deg]
            del Q_rem[deg]
    
    Q_rem = {k: v for k, v in Q_rem.items() if v != 0}
    success = len(Q_rem) == 0
    
    if not success:
        print(f"  REMAINDER: {Q_rem}")
    
    return result, success


def main():
    # First, verify the GL_2 decomposition from Layer 1 still works
    print("=" * 70)
    print("VERIFICATION: GL_2 key poly decomposition for c=(2,1,1), d=4")
    print("=" * 70)
    
    Q1_d4 = {1: 2, 2: 1, 3: 1}
    decomp, ok = find_key_decomposition_3var(Q1_d4, max_comp_val=5, exponents=(1, 2))
    print(f"Q_1 decomp (GL_2): {decomp}, success={ok}")
    for u, mult in sorted(decomp.items()):
        K = specialize_key_poly(u, (1, 2))
        print(f"  {mult} * K_{u}(q,q^2) = {mult} * ({poly_str(K)})")
    
    # Now: GL_3 decomposition for d=7, c=(3,2,2)
    print("\n" + "=" * 70)
    print("GL_3 KEY POLYNOMIAL DECOMPOSITION for c=(3,2,2), d=7")
    print("Specialization at (q, q^2, q^3)")
    print("=" * 70)
    
    # Q polynomials for d=7, c=(3,2,2) from the computation
    Q0 = {0: 1}
    Q1 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
    Q2 = {3:1, 4:5, 5:7, 6:10, 7:10, 8:12, 9:10, 10:11, 11:9, 12:9,
          13:7, 14:7, 15:5, 16:5, 17:3, 18:3, 19:2, 20:2, 21:1, 22:1, 24:1}
    
    for n, Q in [(0, Q0), (1, Q1), (2, Q2)]:
        print(f"\n--- Q_{n} ---")
        print(f"  Q = {poly_str(Q)}")
        print(f"  Q(1) = {sum(Q.values())}")
        decomp, ok = find_key_decomposition_3var(Q, max_comp_val=10, exponents=(1, 2, 3))
        print(f"  Decomposition success: {ok}")
        print(f"  Number of terms: {len(decomp)}")
        for u, mult in sorted(decomp.items()):
            K = specialize_key_poly(u, (1, 2, 3))
            K_str = poly_str(K)
            if len(K_str) > 80:
                K_str = K_str[:80] + "..."
            print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({K_str})")
    
    # Also try GL_3 for d=4, c=(2,1,1) and compare with GL_2
    print("\n" + "=" * 70)
    print("GL_3 decomposition for c=(2,1,1), d=4 (compare with GL_2)")
    print("=" * 70)
    
    for n, Q in [(1, Q1_d4)]:
        print(f"\n--- Q_{n} ---")
        decomp3, ok3 = find_key_decomposition_3var(Q, max_comp_val=5, exponents=(1, 2, 3))
        print(f"  GL_3 decomp success: {ok3}")
        for u, mult in sorted(decomp3.items()):
            K = specialize_key_poly(u, (1, 2, 3))
            print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({poly_str(K)})")
    
    # Try also for c=(4,2,1), d=7
    print("\n" + "=" * 70)
    print("GL_3 KEY POLYNOMIAL DECOMPOSITION for c=(4,2,1), d=7")
    print("=" * 70)
    
    Q1_421 = {1: 2, 2: 2, 3: 2, 4: 2, 5: 1, 6: 1, 8: 1}
    
    decomp, ok = find_key_decomposition_3var(Q1_421, max_comp_val=10, exponents=(1, 2, 3))
    print(f"Q_1 decomp success: {ok}")
    for u, mult in sorted(decomp.items()):
        K = specialize_key_poly(u, (1, 2, 3))
        print(f"  {mult} * K_{u}(q,q^2,q^3) = {mult} * ({poly_str(K)})")


if __name__ == "__main__":
    main()
