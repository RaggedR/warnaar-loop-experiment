"""
Verify the Adjugate Monomial Theorem: adj(I - A(x))[c,c'] = x^{EMD(c,c')}
and understand the structure of A(x) for the CW system.

For r=3 parts, profiles are compositions (c_0, c_1, c_2) with c_0+c_1+c_2 = d.
"""
from itertools import combinations
from fractions import Fraction
import numpy as np
from sympy import symbols, Matrix, eye, det, factor, simplify, Poly, Symbol, expand
from sympy import zeros as szeros

x = Symbol('x')

def profiles(d):
    """All compositions of d into 3 nonneg parts."""
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def I_c(c):
    """Indices i where c_i > 0."""
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
    """
    Compute c(J) from the CW functional equation.
    c_i(J) = c_i - 1 if i in J and (i-1 mod 3) not in J
    c_i(J) = c_i + 1 if i not in J and (i-1 mod 3) in J
    c_i(J) = c_i otherwise
    """
    J_set = set(J)
    result = list(c)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

def emd_clockwise(c, cp):
    """
    EMD on Z/3Z with clockwise metric d(0,1)=d(1,2)=d(2,0)=1.
    EMD(c,c') = 3*max(0, c'_1-c_1, c_0-c'_0) + (c'_0-c_0) - (c'_1-c_1)
    """
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def build_A_matrix(d):
    """
    Build the transfer matrix A(x) for the CW system.
    
    The CW functional equation is:
    F_c(y,q) = sum_{J nonempty} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1 - yq^|J|)
    
    In matrix form with generating function in y:
    The matrix A(x) has entry A[c, c'] = sum over J s.t. c(J) = c' of (-1)^{|J|-1} x^|J|
    
    Then F = A(x) * F(shifted) implies (I - A(x)) * something = ...
    
    Actually, let me be more careful. The equation is:
    G_c(z) = F_c(z) = sum_J (-1)^{|J|-1} * z*q^|J| / (1 - z*q^|J|) * F_{c(J)}(z*q^|J|)
    
    But at the level of extracting [z^n], we get a matrix product structure.
    The key formula is: P_n(c) = (q^3;q^3)_n * F_{c,n}
    and P_n = sum over paths of q^{sum k*EMD(c^k, c^{k-1})}
    
    The matrix (I - A(x))^{-1} gives the generating function, and
    adj(I - A(x))[c,c'] should be x^{EMD(c,c')}.
    
    A(x)[c, c'] = coefficient of the transition c' -> c in the inclusion-exclusion.
    For each nonempty J subset I_c:
      if c(J) = c', then A(x)[c, c'] += (-1)^{|J|-1} * x^|J|
    """
    profs = profiles(d)
    n = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    A = szeros(n, n)
    
    for c in profs:
        ic = I_c(c)
        if not ic:
            continue
        # All nonempty subsets of I_c
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    j_idx = prof_idx.get(cp)
                    if j_idx is not None:
                        i_idx = prof_idx[c]
                        sign = (-1)**(len(J) - 1)
                        A[i_idx, j_idx] += sign * x**len(J)
    
    return A, profs

def verify_adjugate_theorem(d):
    """Verify adj(I - A(x))[c,c'] = x^{EMD(c,c')} for given d."""
    A, profs = build_A_matrix(d)
    n = len(profs)
    M = eye(n) - A
    
    # Compute determinant
    d_val = det(M)
    d_factored = factor(d_val)
    print(f"\nd = {d}, {n} profiles")
    print(f"det(I - A(x)) = {d_factored}")
    
    # Compute adjugate
    adj = M.adjugate()
    
    # Check each entry
    all_match = True
    mismatches = []
    for i in range(n):
        for j in range(n):
            entry = expand(adj[i, j])
            expected_emd = emd_clockwise(profs[i], profs[j])
            expected = x**expected_emd
            if expand(entry - expected) != 0:
                all_match = False
                mismatches.append((profs[i], profs[j], entry, expected_emd))
    
    if all_match:
        print(f"  VERIFIED: All adj(I-A(x))[c,c'] = x^EMD(c,c')")
    else:
        print(f"  FAILED: {len(mismatches)} mismatches")
        for c, cp, got, exp_emd in mismatches[:5]:
            print(f"    adj[{c},{cp}] = {got}, expected x^{exp_emd} = {x**exp_emd}")
    
    # Print a few sample entries
    print(f"  Sample entries:")
    for i in range(min(3, n)):
        for j in range(min(3, n)):
            emd_val = emd_clockwise(profs[i], profs[j])
            print(f"    adj[{profs[i]},{profs[j]}] = {expand(adj[i,j])}, EMD = {emd_val}")
    
    return all_match, A, adj, profs

# Test for small d
for d in [1, 2, 3, 4]:
    verify_adjugate_theorem(d)
