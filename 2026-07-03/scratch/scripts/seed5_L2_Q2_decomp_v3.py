"""
Seed 5, Layer 2: Better decomposition approach.

Key insight: instead of raw key polynomials K_u(q,q^2,q^3), think about
what SCHUR functions s_lambda(q,q^2,q^3) appear. Since K_u with u dominant
IS the Schur function, and non-dominant K_u are Demazure truncations of
Schur functions, maybe Q_2 decomposes into SCHUR polynomials.

s_lambda(q, q^2, q^3) for GL_3 with lambda = (a >= b >= c >= 0):
  These are q^{a+2b+3c} * s_{(a-c,b-c)}(1, q, q^2) * q^{...}
  
Actually simpler: just compute Schur polynomials directly.

For GL_3, the Schur polynomial s_lambda(x1,x2,x3) for lambda=(a,b,c) with a>=b>=c is:
  s_lambda = det(x_i^{lambda_j + n - j}) / det(x_i^{n-j})  (Weyl character formula)

The key polynomials K_u for non-dominant u are NOT Schur polynomials.
But ANY polynomial with nonneg coefficients in the Schur basis has nonneg
coefficients in the monomial basis. So Schur-positivity implies positivity.

Let me check: is Q_2 Schur-positive at the specialization (q,q^2,q^3)?
"""

import numpy as np
from collections import defaultdict


def schur_poly_3vars(lam):
    """
    Compute the Schur polynomial s_lambda(x1,x2,x3) for partition lambda
    with at most 3 parts. Uses the Weyl character formula.
    
    Returns dict of exponent tuples -> coefficients.
    """
    a, b, c = lam[0] if len(lam) > 0 else 0, lam[1] if len(lam) > 1 else 0, lam[2] if len(lam) > 2 else 0
    
    # rho = (2, 1, 0)
    # Numerator: det(x_i^{lambda_j + rho_j}) = det of 3x3 matrix
    # with entries x_i^{lambda_j + 3 - j}
    
    exps = [a + 2, b + 1, c]  # lambda + rho
    
    # Generate all permutations of (1,2,3) -> sign * x^perm(exps)
    from itertools import permutations as perms
    
    numerator = {}
    for perm in perms([0, 1, 2]):
        # sign of permutation
        inversions = sum(1 for i in range(3) for j in range(i+1, 3) if perm[i] > perm[j])
        sign = (-1) ** inversions
        exp = tuple(exps[perm[i]] for i in range(3))
        numerator[exp] = numerator.get(exp, 0) + sign
    numerator = {k: v for k, v in numerator.items() if v != 0}
    
    # Denominator: det(x_i^{rho_j}) = Vandermonde
    # = prod_{i<j} (x_i - x_j)
    # For exponents (2,1,0): this is the Vandermonde
    denom = {}
    rho_exps = [2, 1, 0]
    for perm in perms([0, 1, 2]):
        inversions = sum(1 for i in range(3) for j in range(i+1, 3) if perm[i] > perm[j])
        sign = (-1) ** inversions
        exp = tuple(rho_exps[perm[i]] for i in range(3))
        denom[exp] = denom.get(exp, 0) + sign
    denom = {k: v for k, v in denom.items() if v != 0}
    
    # Polynomial division: numerator / denominator
    # Since s_lambda is a polynomial, the division is exact.
    # Use iterative subtraction.
    result = {}
    num = dict(numerator)
    
    # Sort denominator terms
    denom_lead_exp = max(denom.keys(), key=sum)
    denom_lead_coeff = denom[denom_lead_exp]
    
    max_iters = 1000
    for _ in range(max_iters):
        if not num:
            break
        # Find the largest remaining numerator term
        num_lead_exp = max(num.keys(), key=sum)
        num_lead_coeff = num[num_lead_exp]
        
        # Quotient term
        q_exp = tuple(num_lead_exp[i] - denom_lead_exp[i] for i in range(3))
        if any(e < 0 for e in q_exp):
            # This shouldn't happen for valid Schur polynomials
            break
        q_coeff = num_lead_coeff // denom_lead_coeff
        
        result[q_exp] = q_coeff
        
        # Subtract q_coeff * q_exp * denom from num
        for d_exp, d_coeff in denom.items():
            combined_exp = tuple(q_exp[i] + d_exp[i] for i in range(3))
            num[combined_exp] = num.get(combined_exp, 0) - q_coeff * d_coeff
        
        num = {k: v for k, v in num.items() if v != 0}
    
    return result


def specialize_poly(poly, exponents=(1, 2, 3)):
    """Specialize a 3-variable polynomial to (q^e1, q^e2, q^e3)."""
    result = {}
    for exp, coeff in poly.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


# Q_2 for d=7, c=(3,2,2)
Q2 = {3:1, 4:5, 5:7, 6:10, 7:10, 8:12, 9:10, 10:11, 11:9, 12:9,
      13:7, 14:7, 15:5, 16:5, 17:3, 18:3, 19:2, 20:2, 21:1, 22:1, 24:1}

max_deg = max(Q2.keys())
min_deg = min(Q2.keys())

print("=" * 70)
print("SCHUR POLYNOMIAL DECOMPOSITION OF Q_2")
print("d=7, c=(3,2,2), Q_2(1) = 121 = 11^2")
print("=" * 70)

# Build Schur specializations
print("\nBuilding Schur polynomial specializations s_lambda(q, q^2, q^3)...")
schur_specs = {}
for a in range(15):
    for b in range(a+1):
        for c in range(b+1):
            lam = (a, b, c)
            S = schur_poly_3vars(lam)
            S_spec = specialize_poly(S, (1, 2, 3))
            if S_spec and min(S_spec.keys()) >= min_deg and max(S_spec.keys()) <= max_deg:
                schur_specs[lam] = S_spec

print(f"Found {len(schur_specs)} Schur polynomials with degrees in [{min_deg}, {max_deg}]")

# List some Schur specializations
for lam in sorted(schur_specs.keys())[:15]:
    S = schur_specs[lam]
    dim = sum(S.values())
    degs = sorted(S.keys())
    print(f"  s_{lam}: dim={dim}, degrees=[{degs[0]}..{degs[-1]}], num_terms={len(S)}")

# Try LP for Schur decomposition
try:
    from scipy.optimize import linprog, milp, LinearConstraint, Bounds
    
    cand_list = sorted(schur_specs.keys())
    n_vars = len(cand_list)
    degrees = list(range(min_deg, max_deg + 1))
    n_eq = len(degrees)
    
    A = np.zeros((n_eq, n_vars))
    b_vec = np.zeros(n_eq)
    
    for i, deg in enumerate(degrees):
        b_vec[i] = Q2.get(deg, 0)
        for j, lam in enumerate(cand_list):
            A[i, j] = schur_specs[lam].get(deg, 0)
    
    print(f"\nLP system: {n_eq} equations, {n_vars} Schur variables")
    
    # Minimize sum (for sparsity)
    c_obj = np.ones(n_vars)
    
    result = linprog(c_obj, A_eq=A, b_eq=b_vec, bounds=[(0, None)] * n_vars, method='highs')
    
    if result.success:
        x = result.x
        print(f"LP objective = {result.fun:.4f}")
        
        # Round
        x_int = np.round(x).astype(int)
        residual = A @ x_int - b_vec
        
        if np.all(residual == 0) and np.all(x_int >= 0):
            print("\nSCHUR-POSITIVE INTEGER DECOMPOSITION FOUND!")
            for j, lam in enumerate(cand_list):
                if x_int[j] > 0:
                    dim = sum(schur_specs[lam].values())
                    print(f"  {x_int[j]} * s_{lam} (dim={dim})")
            
            # Verify
            check = {}
            for j, lam in enumerate(cand_list):
                if x_int[j] > 0:
                    for d, c in schur_specs[lam].items():
                        check[d] = check.get(d, 0) + x_int[j] * c
            check = {k: v for k, v in check.items() if v != 0}
            print(f"\nVerification: {'PASS' if check == Q2 else 'FAIL'}")
            if check != Q2:
                print(f"  Got: {sorted(check.items())[:10]}")
                print(f"  Expected: {sorted(Q2.items())[:10]}")
        else:
            print("LP solved but integer rounding failed.")
            print(f"Max absolute residual: {max(abs(residual))}")
            
            # Show fractional solution
            print("\nFractional solution:")
            for j, lam in enumerate(cand_list):
                if x[j] > 0.01:
                    dim = sum(schur_specs[lam].values())
                    print(f"  {x[j]:.4f} * s_{lam} (dim={dim})")
            
            # Try different objective to get integral solution
            # Minimize max(x) or minimize L-infinity
            print("\nTrying integer rounding with floor...")
            x_floor = np.floor(x).astype(int)
            remainder = b_vec - A @ x_floor
            print(f"  Remainder after floor: {dict(zip(degrees, remainder.astype(int)))}")
            
    else:
        print(f"LP infeasible: {result.message}")
        print("Q_2 is NOT Schur-positive at this specialization!")

except ImportError:
    print("scipy not available")

# Also try the DEMAZURE key polynomial LP with better objective
print("\n" + "=" * 70)
print("KEY POLYNOMIAL DECOMPOSITION (better LP)")
print("=" * 70)

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

def specialize_key(u, exponents=(1, 2, 3)):
    K = compute_key_poly(u, len(exponents))
    result = {}
    for exp, coeff in K.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

# Build key polynomial candidates
key_specs = {}
for a in range(12):
    for b in range(12):
        for c in range(12):
            u = (a, b, c)
            K = specialize_key(u, (1, 2, 3))
            if not K:
                continue
            if max(K.keys()) > max_deg or min(K.keys()) < min_deg:
                continue
            if any(v < 0 for v in K.values()):
                continue
            key_specs[u] = K

print(f"Found {len(key_specs)} key polynomial candidates")

try:
    from scipy.optimize import linprog
    
    cand_list_k = sorted(key_specs.keys())
    n_vars_k = len(cand_list_k)
    
    A_k = np.zeros((n_eq, n_vars_k))
    for i, deg in enumerate(degrees):
        for j, u in enumerate(cand_list_k):
            A_k[i, j] = key_specs[u].get(deg, 0)
    
    # Try multiple LP objectives to find integer solutions
    # Objective 1: minimize sum (sparse)
    for obj_name, c_obj in [("sum", np.ones(n_vars_k)), 
                              ("weighted_sum", np.array([sum(u) for u in cand_list_k], dtype=float))]:
        result = linprog(c_obj, A_eq=A_k, b_eq=b_vec, bounds=[(0, None)] * n_vars_k, method='highs')
        if result.success:
            x = result.x
            x_int = np.round(x).astype(int)
            residual = A_k @ x_int - b_vec
            if np.all(residual == 0) and np.all(x_int >= 0):
                print(f"\nKEY-POSITIVE INTEGER DECOMPOSITION FOUND (obj={obj_name})!")
                total_at_1 = 0
                for j, u in enumerate(cand_list_k):
                    if x_int[j] > 0:
                        dim = sum(key_specs[u].values())
                        total_at_1 += x_int[j] * dim
                        print(f"  {x_int[j]} * K_{u} (dim={dim})")
                print(f"Total at q=1: {total_at_1}")
                
                # Verify
                check = {}
                for j, u in enumerate(cand_list_k):
                    if x_int[j] > 0:
                        for d, c_val in key_specs[u].items():
                            check[d] = check.get(d, 0) + x_int[j] * c_val
                check = {k: v for k, v in check.items() if v != 0}
                if check == Q2:
                    print("VERIFIED!")
                break
            else:
                print(f"  obj={obj_name}: LP solved (obj={result.fun:.2f}) but integer rounding failed, max_res={max(abs(residual)):.1f}")

except ImportError:
    pass

