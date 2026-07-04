"""
Seed 5, Layer 2: Better key polynomial decomposition using ILP or
exhaustive backtracking.

The greedy approach fails for Q_2 at d=7. We need a more systematic
method. Use integer linear programming: find nonneg integer coefficients
a_u such that sum_u a_u * K_u(q,q^2,q^3) = Q(q).

This is a system of linear equations (one per q-degree) with the constraint
that all a_u >= 0. Since the system is over Z_>=0, we can use LP relaxation
or direct enumeration.
"""

from itertools import permutations
from collections import defaultdict


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


def find_decomposition_backtrack(Q, available_list, idx=0, current=None):
    """
    Backtracking search for nonneg integer decomposition.
    available_list is [(u, K_dict), ...] sorted by length desc.
    """
    if current is None:
        current = {}
    
    # Check if Q is all zeros
    if all(v == 0 for v in Q.values()):
        return dict(current)
    
    # Check if any negative
    if any(v < 0 for v in Q.values()):
        return None
    
    if idx >= len(available_list):
        # No more available; check if Q is zero
        if all(v == 0 for v in Q.values()):
            return dict(current)
        return None
    
    u, K = available_list[idx]
    
    # How many times can we use K?
    max_mult = min(Q.get(d, 0) for d in K.keys()) if K else 0
    max_mult = max(0, max_mult)
    
    # Try from max down to 0
    for mult in range(max_mult, -1, -1):
        Q_new = dict(Q)
        for d, c in K.items():
            Q_new[d] = Q_new.get(d, 0) - mult * c
        Q_new = {k: v for k, v in Q_new.items() if v != 0}
        
        if any(v < 0 for v in Q_new.values()):
            continue
        
        if mult > 0:
            current[u] = mult
        
        result = find_decomposition_backtrack(Q_new, available_list, idx + 1, current)
        if result is not None:
            return result
        
        if mult > 0:
            del current[u]
    
    return None


def try_decomposition(Q, exponents, max_comp_val=10, label=""):
    """Try to decompose Q into key polynomial specializations."""
    if not Q:
        return {}, True
    
    max_deg = max(Q.keys())
    
    # Build available key polys
    available = {}
    nv = len(exponents)
    ranges = [range(max_comp_val + 1)] * nv
    
    from itertools import product as iter_product
    for u in iter_product(*ranges):
        min_possible = sum(e * x for e, x in zip(u, exponents))
        if min_possible > max_deg:
            continue
        K = specialize_key_poly(u, exponents)
        if K and max(K.keys()) <= max_deg and min(K.keys()) >= (min(Q.keys()) if Q else 0):
            available[u] = K
    
    print(f"  {label}: {len(available)} available key polynomials for max_deg={max_deg}")
    
    # Sort: prefer multi-term polys first, then by length desc
    avail_list = sorted(available.items(), key=lambda x: (-len(x[1]), -max(x[1].keys())))
    
    # Limit search space for tractability
    if len(avail_list) > 100:
        # Keep only the most promising
        avail_list = avail_list[:100]
    
    result = find_decomposition_backtrack(dict(Q), avail_list)
    
    if result is not None:
        return result, True
    else:
        return {}, False


def main():
    print("=" * 70)
    print("SYSTEMATIC KEY POLYNOMIAL DECOMPOSITION")
    print("=" * 70)
    
    # ===== d=4, c=(2,1,1) =====
    print("\n--- d=4, c=(2,1,1) ---")
    Q1_d4 = {1: 2, 2: 1, 3: 1}
    Q2_d4 = {3:1, 4:3, 5:2, 6:3, 7:2, 8:2, 9:1, 10:1, 12:1}
    
    # GL_2
    for n, Q in [(1, Q1_d4), (2, Q2_d4)]:
        print(f"\n  Q_{n} = {poly_str(Q)}, Q(1) = {sum(Q.values())}")
        decomp, ok = try_decomposition(Q, (1, 2), max_comp_val=15, label=f"GL_2 Q_{n}")
        print(f"  GL_2 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2))
                print(f"    {mult} * K_{u}(q,q^2) = {mult} * ({poly_str(K)})")
    
    # GL_3
    for n, Q in [(1, Q1_d4), (2, Q2_d4)]:
        decomp, ok = try_decomposition(Q, (1, 2, 3), max_comp_val=8, label=f"GL_3 Q_{n}")
        print(f"  GL_3 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2, 3))
                K_s = poly_str(K)
                if len(K_s) > 80: K_s = K_s[:80] + "..."
                print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({K_s})")
    
    # ===== d=7, c=(3,2,2) =====
    print("\n" + "=" * 70)
    print("--- d=7, c=(3,2,2) ---")
    Q1_d7 = {1: 2, 2: 3, 3: 2, 4: 2, 5: 1, 6: 1}
    Q2_d7 = {3:1, 4:5, 5:7, 6:10, 7:10, 8:12, 9:10, 10:11, 11:9, 12:9,
             13:7, 14:7, 15:5, 16:5, 17:3, 18:3, 19:2, 20:2, 21:1, 22:1, 24:1}
    
    for n, Q in [(1, Q1_d7)]:
        print(f"\n  Q_{n} = {poly_str(Q)}, Q(1) = {sum(Q.values())}")
        
        # GL_3
        decomp, ok = try_decomposition(Q, (1, 2, 3), max_comp_val=8, label=f"GL_3 Q_{n}")
        print(f"  GL_3 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2, 3))
                print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({poly_str(K)})")
    
    for n, Q in [(2, Q2_d7)]:
        print(f"\n  Q_{n} = {poly_str(Q)[:100]}..., Q(1) = {sum(Q.values())}")
        
        # GL_3 - this is the big test
        decomp, ok = try_decomposition(Q, (1, 2, 3), max_comp_val=10, label=f"GL_3 Q_{n}")
        print(f"  GL_3 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2, 3))
                K_s = poly_str(K)
                if len(K_s) > 80: K_s = K_s[:80] + "..."
                print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({K_s})")
    
    # ===== d=7, c=(4,2,1) =====
    print("\n" + "=" * 70)
    print("--- d=7, c=(4,2,1) ---")
    Q1_421 = {1: 2, 2: 2, 3: 2, 4: 2, 5: 1, 6: 1, 8: 1}
    
    for n, Q in [(1, Q1_421)]:
        print(f"\n  Q_{n} = {poly_str(Q)}, Q(1) = {sum(Q.values())}")
        decomp, ok = try_decomposition(Q, (1, 2, 3), max_comp_val=8, label=f"GL_3 Q_{n}")
        print(f"  GL_3 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2, 3))
                print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({poly_str(K)})")
    
    # ===== Also try d=5, c=(2,2,1) =====
    print("\n" + "=" * 70)
    print("--- d=5, c=(2,2,1) ---")
    Q1_d5 = {1: 2, 2: 2, 3: 1, 4: 1}
    
    for n, Q in [(1, Q1_d5)]:
        print(f"\n  Q_{n} = {poly_str(Q)}, Q(1) = {sum(Q.values())}")
        decomp, ok = try_decomposition(Q, (1, 2, 3), max_comp_val=5, label=f"GL_3 Q_{n}")
        print(f"  GL_3 success: {ok}")
        if ok:
            for u, mult in sorted(decomp.items()):
                K = specialize_key_poly(u, (1, 2, 3))
                print(f"    {mult} * K_{u}(q,q^2,q^3) = {mult} * ({poly_str(K)})")


if __name__ == "__main__":
    main()
