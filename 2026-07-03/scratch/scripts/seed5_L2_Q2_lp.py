"""
Seed 5, Layer 2: Use numpy to solve the key polynomial decomposition for Q_2
at d=7 as a nonneg integer linear programming problem.

The question: does Q_2 at d=7, c=(3,2,2) decompose as
  Q_2 = sum_u a_u * K_u(q, q^2, q^3)  with all a_u >= 0 integers?

We set this up as: for each degree d of q, sum_u a_u * [coeff of q^d in K_u] = [coeff of q^d in Q_2].
"""

import numpy as np
from itertools import product as iter_product


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


def specialize_key_poly(u, exponents=(1, 2, 3)):
    K = compute_key_poly(u, len(exponents))
    result = {}
    for exp, coeff in K.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}


# Q_2 for d=7, c=(3,2,2)
Q2 = {3:1, 4:5, 5:7, 6:10, 7:10, 8:12, 9:10, 10:11, 11:9, 12:9,
      13:7, 14:7, 15:5, 16:5, 17:3, 18:3, 19:2, 20:2, 21:1, 22:1, 24:1}

max_deg = max(Q2.keys())
degrees = list(range(min(Q2.keys()), max_deg + 1))

# Build the set of candidate key polynomials
print("Building key polynomial specializations...")
candidates = {}
for a in range(12):
    for b in range(12):
        for c in range(12):
            u = (a, b, c)
            K = specialize_key_poly(u, (1, 2, 3))
            if not K:
                continue
            if max(K.keys()) > max_deg:
                continue
            if min(K.keys()) < min(Q2.keys()):
                continue
            # Only keep if all coefficients positive (key polys should have this)
            if any(v < 0 for v in K.values()):
                continue
            candidates[u] = K

print(f"Found {len(candidates)} candidate key polynomials")

# Set up the LP
# Variables: a_u for each candidate u
# Constraints: sum_u a_u * K_u[d] = Q2[d] for each degree d
# Bounds: a_u >= 0

cand_list = sorted(candidates.keys())
n_vars = len(cand_list)
n_constraints = len(degrees)

A = np.zeros((n_constraints, n_vars))
b_vec = np.zeros(n_constraints)

for i, deg in enumerate(degrees):
    b_vec[i] = Q2.get(deg, 0)
    for j, u in enumerate(cand_list):
        A[i, j] = candidates[u].get(deg, 0)

print(f"System: {n_constraints} equations, {n_vars} variables")
print(f"Q2(1) = {sum(Q2.values())} = 121")

# Try to solve using scipy linprog (minimize 0 subject to Ax = b, x >= 0)
try:
    from scipy.optimize import linprog
    
    # Minimize sum of x (to get sparse solution)
    c_obj = np.ones(n_vars)
    
    result = linprog(c_obj, A_eq=A, b_eq=b_vec, bounds=[(0, None)] * n_vars,
                     method='highs')
    
    if result.success:
        print(f"\nLP solved! Objective = {result.fun:.4f}")
        x = result.x
        
        # Round to nearest integers
        x_int = np.round(x).astype(int)
        
        # Check if integer solution is valid
        residual = A @ x_int - b_vec
        if np.all(residual == 0) and np.all(x_int >= 0):
            print("INTEGER SOLUTION FOUND!")
            print(f"Number of nonzero components: {np.sum(x_int > 0)}")
            for j, u in enumerate(cand_list):
                if x_int[j] > 0:
                    K = specialize_key_poly(u, (1, 2, 3))
                    dim = sum(K.values())
                    print(f"  {x_int[j]} * K_{u} (dim={dim})")
        else:
            print("LP relaxation solved but integer rounding failed.")
            print(f"Max residual: {max(abs(residual))}")
            
            # Show the fractional solution
            print("\nFractional solution (top 20 by value):")
            idx_sorted = np.argsort(-x)
            for j in idx_sorted[:20]:
                if x[j] > 1e-8:
                    u = cand_list[j]
                    K = specialize_key_poly(u, (1, 2, 3))
                    dim = sum(K.values())
                    print(f"  {x[j]:.4f} * K_{u} (dim={dim})")
            
            # Try branch and bound manually for small solution
            print("\nTrying exact integer search...")
            
            # Reduce: only consider variables that are nonzero in LP relaxation
            active = [j for j in range(n_vars) if x[j] > 0.01]
            print(f"Active variables: {len(active)}")
            
            if len(active) <= 30:
                # Build reduced system
                A_red = A[:, active]
                cand_red = [cand_list[j] for j in active]
                
                # Get bounds from LP
                bounds_red = [int(np.ceil(x[j])) + 2 for j in active]
                
                # Brute force search
                from itertools import product as iter_prod
                
                found = False
                count = 0
                total = 1
                for b in bounds_red:
                    total *= (b + 1)
                print(f"Search space: {total}")
                
                if total < 10**7:
                    ranges = [range(b+1) for b in bounds_red]
                    for combo in iter_prod(*ranges):
                        x_try = np.array(combo)
                        if np.all(A_red @ x_try == b_vec):
                            print(f"\nINTEGER SOLUTION FOUND!")
                            for k, j in enumerate(active):
                                if combo[k] > 0:
                                    u = cand_list[j]
                                    K = specialize_key_poly(u, (1, 2, 3))
                                    dim = sum(K.values())
                                    print(f"  {combo[k]} * K_{u} (dim={dim})")
                            found = True
                            break
                        count += 1
                        if count % 1000000 == 0:
                            print(f"  Searched {count}/{total}...")
                    
                    if not found:
                        print("No integer solution found in search space!")
                else:
                    print("Search space too large for brute force.")
    else:
        print(f"LP failed: {result.message}")
        print("This means Q_2 CANNOT be decomposed into these key polynomials!")

except ImportError:
    print("scipy not available, skipping LP approach")
    
    # Fallback: just try a smarter greedy
    print("\nTrying smarter greedy (by Schur polynomials first)...")
    
    # Key observation: K_{(0,0,m)} = s_m (Schur, dim = (m+1)(m+2)/2)
    # These are the "biggest" building blocks
    
    Q_rem = dict(Q2)
    decomp = {}
    
    # Try subtracting Schur polys s_m = K_{(0,0,m)} from highest m down
    for m in range(8, 0, -1):
        u = (0, 0, m)
        K = specialize_key_poly(u, (1, 2, 3))
        if not K or max(K.keys()) > max_deg:
            continue
        if not all(d >= min(Q_rem.keys()) if Q_rem else True for d in K.keys()):
            continue
        
        max_mult = min(Q_rem.get(d, 0) for d in K.keys()) if K else 0
        if max_mult > 0:
            decomp[u] = max_mult
            for d, c in K.items():
                Q_rem[d] = Q_rem.get(d, 0) - max_mult * c
            Q_rem = {k: v for k, v in Q_rem.items() if v != 0}
    
    print(f"After Schur subtraction, remainder: {Q_rem}")
    print(f"Decomposition so far: {decomp}")

