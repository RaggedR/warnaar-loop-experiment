# Use ILP (integer linear programming) for key polynomial decomposition
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds

def demazure_op(i, poly_dict):
    """Apply pi_i to polynomial dict {(e1,e2,e3): coeff}."""
    from collections import defaultdict
    
    # Compute numerator: x_i * f - x_{i+1} * s_i(f)
    result = {}
    for (e1, e2, e3), c in poly_dict.items():
        exps = [e1, e2, e3]
        # x_i * term
        e_up = list(exps)
        e_up[i] += 1
        key1 = tuple(e_up)
        result[key1] = result.get(key1, 0) + c
        # -x_{i+1} * s_i(term)
        e_swap = list(exps)
        e_swap[i], e_swap[i+1] = e_swap[i+1], e_swap[i]
        e_swap[i+1] += 1
        key2 = tuple(e_swap)
        result[key2] = result.get(key2, 0) - c
    
    # Divide by (x_i - x_{i+1}) using synthetic division
    groups = defaultdict(lambda: defaultdict(int))
    for (e1, e2, e3), c in result.items():
        exps = [e1, e2, e3]
        other_exp = list(exps)
        ei = other_exp[i]
        ej = other_exp[i+1]
        other_exp[i] = 0
        other_exp[i+1] = 0
        groups[tuple(other_exp)][(ei, ej)] += c
    
    final = {}
    for other_exp, bivar in groups.items():
        remainder = dict(bivar)
        quotient = {}
        
        for _ in range(1000):
            best = None
            for (a, b) in sorted(remainder.keys(), key=lambda x: (-x[0]-x[1], -x[0])):
                if remainder.get((a,b), 0) != 0:
                    best = (a, b)
                    break
            if best is None:
                break
            a, b = best
            c = remainder[(a, b)]
            if a > 0:
                q_key = (a-1, b)
                quotient[q_key] = quotient.get(q_key, 0) + c
                remainder[(a, b)] = 0
                r_key = (a-1, b+1)
                remainder[r_key] = remainder.get(r_key, 0) + c
            else:
                break
        
        for (qi, qj), c in quotient.items():
            if c != 0:
                full_exp = list(other_exp)
                full_exp[i] += qi
                full_exp[i+1] += qj
                final[tuple(full_exp)] = final.get(tuple(full_exp), 0) + c
    
    return {k: v for k, v in final.items() if v != 0}

def key_polynomial(alpha):
    a = list(alpha)
    if a[0] >= a[1] >= a[2]:
        return {tuple(a): 1}
    for i in range(2):
        if a[i] < a[i+1]:
            a_new = list(a)
            a_new[i], a_new[i+1] = a_new[i+1], a_new[i]
            kappa_s = key_polynomial(tuple(a_new))
            return demazure_op(i, kappa_s)

def specialise_to_array(poly_dict, max_deg):
    arr = np.zeros(max_deg + 1, dtype=int)
    for (e1, e2, e3), c in poly_dict.items():
        deg = e1 + 2*e2 + 3*e3
        if deg <= max_deg:
            arr[deg] += c
    return arr

# Build key polynomial basis
def build_key_basis(max_deg):
    basis = []
    seen_specs = set()
    for c_val in range(max_deg // 3 + 1):
        for b_val in range((max_deg - 3*c_val) // 2 + 1):
            for a_val in range(max_deg - 2*b_val - 3*c_val + 1):
                alpha = (a_val, b_val, c_val)
                kp = key_polynomial(alpha)
                arr = specialise_to_array(kp, max_deg)
                arr_key = tuple(arr)
                if arr_key not in seen_specs and any(arr != 0):
                    seen_specs.add(arr_key)
                    basis.append((alpha, arr))
    return basis

# Q_n data
Q_data = {
    1: [1, 1, 2, 1],
    2: [1, 1, 1, 1, 3, 4, 6, 3, 3, 1, 1],
    3: [1, 1, 1, 0, 2, 3, 4, 3, 6, 8, 13, 14, 15, 14, 12, 9, 7, 5, 3, 2, 1, 1],
}

for n in [1, 2, 3]:
    print(f"\n{'='*60}")
    print(f"Decomposing Q_{n} for d=2, c=(1,1,0)")
    print(f"{'='*60}")
    
    target = np.array(Q_data[n], dtype=float)
    max_deg = len(target) - 1
    
    basis = build_key_basis(max_deg)
    nb = len(basis)
    print(f"Number of distinct key polynomials: {nb}")
    
    # Build matrix
    A_mat = np.zeros((max_deg + 1, nb), dtype=float)
    for j, (alpha, arr) in enumerate(basis):
        A_mat[:, j] = arr[:max_deg+1]
    
    # ILP: minimize sum x_j subject to A x = target, x >= 0, x integer
    c_obj = np.ones(nb)
    constraints = LinearConstraint(A_mat, target, target)
    integrality = np.ones(nb)  # all integer
    bounds = Bounds(0, np.inf)
    
    from scipy.optimize import milp
    result = milp(c_obj, constraints=constraints, integrality=integrality, bounds=bounds)
    
    if result.success:
        x_sol = np.round(result.x).astype(int)
        # Verify
        check = A_mat @ x_sol
        if np.allclose(check, target):
            terms = [(basis[j][0], x_sol[j]) for j in range(nb) if x_sol[j] > 0]
            print(f"Q_{n} = " + " + ".join(f"{v}*kappa_{a}" for a, v in sorted(terms)))
            print(f"  Number of distinct key polys used: {len(terms)}")
            print(f"  Total multiplicity: {sum(v for _, v in terms)}")
            
            # Check if decomposition is unique
            # Try to find another solution by excluding this one
        else:
            print(f"ILP solution doesn't verify!")
            print(f"  Max error: {np.max(np.abs(check - target))}")
    else:
        print(f"ILP failed: {result.message}")

