"""
Seed 5, Layer 2: Check if Q_1 is the graded character of an sl_3 crystal
at level d.

sl_3 has simple roots alpha_1 = (1,-1,0), alpha_2 = (0,1,-1).
The fundamental weights are omega_1 = (1,0,0), omega_2 = (1,1,0) in
the "epsilon basis" after projecting out the trace.

For the crystal graph B(lambda), the character is the Schur polynomial
s_lambda(x_1, x_2, x_3).

But Q_1 is NOT a single Schur polynomial. It decomposes into multiple
Demazure characters. So Q_1 might be the character of a REDUCIBLE
representation, i.e., a DIRECT SUM of irreducibles.

For d=7, c=(3,2,2), Q_1(1) = 11. What sl_3 representations have dim 11?
- s_{(4,0,0)} has dim 15
- s_{(3,1,0)} has dim 8  (= 8 at q=1 for (x1,x2,x3))
- s_{(2,2,0)} has dim 6
- s_{(1,0,0)} + s_{(2,0,0)} has dim 3 + 6 = 9
- s_{(1,0,0)} + s_{(1,1,0)} has dim 3 + 3 = 6... no, s_{(1,1,0)} has dim 3
  Wait: s_{lambda}(x1,x2,x3) for lambda=(1,1,0) is x1*x2 + x1*x3 + x2*x3, dim=3.

Actually for GL_3, dim(s_lambda) = prod_{1<=i<j<=3} (lambda_i - lambda_j + j - i)/(j-i)
= (lambda_1 - lambda_2 + 1)(lambda_1 - lambda_3 + 2)(lambda_2 - lambda_3 + 1) / 2

Let me compute dimensions of small representations.
"""

def gl3_schur_dim(lam):
    """Dimension of the GL_3 irrep with highest weight lambda."""
    a, b, c = lam[0], lam[1] if len(lam) > 1 else 0, lam[2] if len(lam) > 2 else 0
    return (a - b + 1) * (a - c + 2) * (b - c + 1) // 2


# List all GL_3 irreps with dimension <= 20
print("GL_3 irreps with dim <= 20:")
for a in range(15):
    for b in range(a+1):
        for c in range(b+1):
            d = gl3_schur_dim((a,b,c))
            if d <= 20:
                print(f"  s_{(a,b,c)}: dim={d}")

# Q_1(1) values:
# d=2: Q_1(1)=1 -> trivial rep s_{(0,0,0)}? No, Q_1 = q, not 1.
# d=4: Q_1(1)=4 -> no single irrep of dim 4... wait
#   s_{(1,1,0)} has dim 3. But we could have s_{(2,1,0)} with dim
#   = (2-1+1)*(2-0+2)*(1-0+1)/2 = 2*4*2/2 = 8. No.
#   Actually let me compute: s_{(1,0,0)} has dim = 1*3*1/2 = ... hmm
#   let me use the formula more carefully.

# dim = product_{1<=i<j<=3} (lam_i - lam_j + j - i) / product_{1<=i<j<=3} (j-i)
# denominator = 1*2*1 = 2
# For (a,b,c): 
#   (a-b+1) * (a-c+2) * (b-c+1) / 2

for (a,b,c) in [(1,0,0), (0,0,0), (1,1,0), (2,0,0), (2,1,0), (1,1,1), (3,0,0), (2,1,1)]:
    d = (a-b+1) * (a-c+2) * (b-c+1) // 2
    print(f"  dim(s_{(a,b,c)}) = {d}")

# What direct sums give dim 4?
# 3+1: s_{(1,0,0)} + s_{(0,0,0)} -- but s_{(0,0,0)} is trivial, dim 1
# This gives dim 3+1 = 4.

# What direct sums give dim 11?
# 6+3+2 = 11: s_{(2,0,0)} + s_{(1,0,0)} + ??? (dim 2 irrep doesn't exist for sl_3)
# 6+3+1+1 = 11: too many pieces
# 8+3 = 11: s_{(2,1,0)} + s_{(1,0,0)} but 8+3=11. Let me verify.
# Actually dim(s_{(2,1,0)}) = (2-1+1)(2-0+2)(1-0+1)/2 = 2*4*2/2 = 8. YES.
# So s_{(2,1,0)} + s_{(1,0,0)} has dim 8+3 = 11. 
# But we need to check if this matches Q_1 at the specialization.

print("\n" + "=" * 70)
print("CHECKING IF Q_1 IS A SUM OF SCHUR SPECIALIZATIONS")
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

def specialize(poly, exponents=(1,2,3)):
    result = {}
    for exp, coeff in poly.items():
        q_deg = sum(e * ex for e, ex in zip(exp, exponents))
        result[q_deg] = result.get(q_deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

# For each Q_1, check all direct sums of Schur functions that give the right dim
Q1_data = {
    (2, (1,1,0)): {1: 1, 2: 1, 3: 1},  # dim 3, but Q(1)=1, hmm
    (4, (2,1,1)): {1: 2, 2: 1, 3: 1},
    (5, (2,2,1)): {1: 2, 2: 2, 3: 1, 4: 1},
    (7, (3,2,2)): {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1},
}

# Wait: for d=2, Q_1(1) = 1. But Q_1 = q+q^2+q^3 has Q(1) = 3? No...
# Let me recheck. For d=2, base = (3*4)/6 - 1 = 2-1 = 1. So Q_1(1)=1.
# But Q_1 = q^{n^2} = q^1 for n=1. So Q_1 = q, Q_1(1) = 1. Not q+q^2+q^3.
# The decomposition I had for d=2 was from a different computation. Let me fix this.

# Actually from the earlier computation:
# d=2, c=(1,1,0): Q_1 = q^1. This is K_{(1,0,0)}(q) = q. NOT q+q^2+q^3.

# Let me correct:
Q1_data = {
    (2, (1,1,0)): {1: 1},  # Q_1 = q, Q(1) = 1
    (4, (2,1,1)): {1: 2, 2: 1, 3: 1},  # Q(1) = 4
    (5, (2,2,1)): {1: 2, 2: 2, 3: 1, 4: 1},  # Q(1) = 6
    (7, (3,2,2)): {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1},  # Q(1) = 11
    (7, (4,2,1)): {1: 2, 2: 2, 3: 2, 4: 2, 5: 1, 6: 1, 8: 1},  # Q(1) = 11
}

# Try Schur decomposition for each Q_1
for (d, profile), Q1 in Q1_data.items():
    print(f"\nd={d}, c={profile}: Q_1(1) = {sum(Q1.values())}")
    
    target = sum(Q1.values())
    max_deg = max(Q1.keys())
    
    # Enumerate all Schur functions with min_deg >= 1 and max_deg <= max_deg
    schur_candidates = {}
    for a in range(max_deg + 1):
        for b in range(a + 1):
            for c in range(b + 1):
                lam = (a, b, c)
                if a == 0 and b == 0 and c == 0:
                    continue
                S = compute_key_poly(lam, 3)  # dominant => Schur
                S_spec = specialize(S, (1, 2, 3))
                if S_spec and max(S_spec.keys()) <= max_deg and min(S_spec.keys()) >= 1:
                    schur_candidates[lam] = S_spec
    
    # Try all subsets with right total dimension
    from itertools import combinations_with_replacement
    import numpy as np
    
    # Build LP
    cand_list = sorted(schur_candidates.keys())
    n_vars = len(cand_list)
    degrees = list(range(1, max_deg + 1))
    
    A = np.zeros((len(degrees), n_vars))
    b_vec = np.zeros(len(degrees))
    
    for i, deg in enumerate(degrees):
        b_vec[i] = Q1.get(deg, 0)
        for j, lam in enumerate(cand_list):
            A[i, j] = schur_candidates[lam].get(deg, 0)
    
    try:
        from scipy.optimize import linprog
        c_obj = np.ones(n_vars)
        result = linprog(c_obj, A_eq=A, b_eq=b_vec, bounds=[(0, None)] * n_vars, method='highs')
        
        if result.success:
            x = result.x
            x_int = np.round(x).astype(int)
            residual = A @ x_int - b_vec
            
            if np.all(residual == 0) and np.all(x_int >= 0):
                print(f"  SCHUR DECOMPOSITION:")
                for j, lam in enumerate(cand_list):
                    if x_int[j] > 0:
                        dim = sum(schur_candidates[lam].values())
                        spec_str = dict(sorted(schur_candidates[lam].items()))
                        print(f"    {x_int[j]} * s_{lam} (dim={dim})")
            else:
                print(f"  No integer Schur decomposition (rounding failed, max_res={max(abs(residual)):.1f})")
                print(f"  Fractional:")
                for j, lam in enumerate(cand_list):
                    if x[j] > 0.01:
                        print(f"    {x[j]:.4f} * s_{lam}")
        else:
            print(f"  LP infeasible: NOT Schur-positive!")
    except ImportError:
        print("  scipy not available")

# FINAL: Check what s_{(2,1,0)}(q, q^2, q^3) looks like
print("\n" + "=" * 70)
print("SCHUR POLYNOMIAL SPECIALIZATIONS")
print("=" * 70)

for lam in [(1,0,0), (1,1,0), (2,0,0), (2,1,0), (2,1,1), (2,2,0), (3,0,0), (3,1,0), (3,2,0)]:
    S = compute_key_poly(lam, 3)
    S_spec = specialize(S, (1, 2, 3))
    dim = sum(S_spec.values())
    parts = []
    for e in sorted(S_spec.keys()):
        c = S_spec[e]
        if c == 1: parts.append(f"q^{e}")
        else: parts.append(f"{c}q^{e}")
    print(f"s_{lam}: dim={dim}, spec = {' + '.join(parts)}")

