"""
Agent C: Derive and verify the EXPLICIT SYSTEM RECURRENCE for Q_n.
The recurrence comes from H_c(z,q) functional equation.
"""
from sage.all import *
from itertools import combinations as combs

R = PowerSeriesRing(QQ, 'q', default_prec=50)
q = R.gen()

d = 4
compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        compositions.append((c0, c1, d-c0-c1))
N = len(compositions)
comp_idx = {c: i for i, c in enumerate(compositions)}

def shift_profile(c, J):
    result = list(c)
    J_set = set(J)
    for i in range(3):
        prev = (i - 1) % 3
        if i in J_set and prev not in J_set:
            result[i] -= 1
        elif i not in J_set and prev in J_set:
            result[i] += 1
    return tuple(result)

# Build CW matrix
Rx = PolynomialRing(QQ, 'x')
x_var = Rx.gen()
A_poly = matrix(Rx, N, N, 0)
for ic, c in enumerate(compositions):
    I_c = {i for i in range(3) if c[i] > 0}
    if not I_c:
        continue
    for size in range(1, len(I_c) + 1):
        for J in combs(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            jcJ = comp_idx[cJ]
            A_poly[ic, jcJ] += sign * x_var**size

def eval_A(val):
    A_eval = matrix(R, N, N)
    for i in range(N):
        for j in range(N):
            poly = A_poly[i,j]
            v = R(0)
            for k, coeff in enumerate(poly.list()):
                v += coeff * val**k
            A_eval[i,j] = v
    return A_eval

I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))

# Compute F_{c,m} vectors 
v_all = [vector(R, [R(1)] * N)]
for m in range(1, 6):
    Am = eval_A(q**m)
    Bm = I_mat - Am
    v_next = Bm.inverse() * v_all[-1]
    v_all.append(v_next)

g_all = [vector(R, [R(1)] * N)]
for m in range(1, 6):
    g_all.append(v_all[m] - v_all[m-1])

def qpoch(n):
    result = R(1)
    for i in range(1, n+1):
        result *= (1 - q**i)
    return result

# Compute Q_n for all profiles, n=0,1,2,3,4
Qn_all = {}
for c in compositions:
    Qn_all[(c, 0)] = R(1)  # Q_0 = 1 for all profiles

for n in range(1, 5):
    for ci, c in enumerate(compositions):
        Qn = R(0)
        for j in range(n+1):
            sign = (-1)**(n-j)
            tri = (n-j)*(n-j+1)//2
            coeff = sign * q**tri / qpoch(n-j)
            Qn += coeff * g_all[j][ci]
        Qn *= qpoch(n)
        Qn_all[(c, n)] = Qn

# Now: INSTEAD of deriving the recurrence from the functional equation,
# let me DISCOVER the recurrence numerically.
# 
# Hypothesis: Q_n(c) can be expressed as a LINEAR combination of 
# Q_{n-1}(c') and Q_{n-2}(c') with coefficients that are polynomials in q^n.
#
# Specifically, look for:
# Q_n(c) = sum_{c'} a_{c,c'}(q,n) * Q_{n-1}(c') + sum_{c'} b_{c,c'}(q,n) * Q_{n-2}(c')
# where a, b are "nice" (e.g., monomials or simple polynomials).

# Actually, from the functional equation approach, the recurrence should be:
# For each c, let I_c = {i: c_i > 0}. Then:
# 
# Q_n(c) = sum_{J single elem} q^n * Q_n(c(J))   ... (*)
#         - sum_{J pair} [q^{2n} Q_n(c(J)) - q^{2n-1}(1-q^n) Q_{n-1}(c(J))]
#         + sum_{J triple, if applicable} [q^{3n} Q_n(c) 
#           - (q^{3n-2} + q^{3n-1})(1-q^n) Q_{n-1}(c)
#           + q^{3n-3}(1-q^n)(1-q^{n-1}) Q_{n-2}(c)]
# 
# Rearranging to solve for Q_n(c):
# (1 - sum_{J single} q^n * delta(c(J)) + sum_{J pair} q^{2n} delta(c(J)) 
#   - (if |I_c|=3) q^{3n}) * Q_n(c) = known terms involving Q_{n-1}, Q_{n-2}
#
# But the LHS involves Q_n at MULTIPLE profiles, not just c!
# Because c(J) for a single-element J is a DIFFERENT profile.
# So (*) is a SYSTEM of equations for all Q_n(c) simultaneously.
# 
# The coefficient matrix for Q_n is: delta_{c,c'} - sum_{J single} q^n delta(c',c(J)) + ...
# This is exactly (I - A(q^n)) restricted to the Q_n system!
# 
# So (I - A(q^n)) * Q_n_vector = stuff involving Q_{n-1}, Q_{n-2}.
# 
# And we know det(I - A(q^n)) = 1 - q^{3n}.
# So Q_n = (I - A(q^n))^{-1} * (stuff).
# 
# By the Adjugate Monomial Theorem: 
# (I - A(q^n))^{-1} = adj(I-A(q^n)) / (1-q^{3n})
# And adj(I-A(q^n))[c,c'] = q^{n * EMD(c,c')}.
# 
# So Q_n(c) = sum_{c'} q^{n*EMD(c,c')} / (1-q^{3n}) * RHS(c')
# where RHS involves Q_{n-1} and Q_{n-2} terms.

# Let me verify this numerically. First, compute the "RHS" for each profile.
# From the functional equation analysis:
# The system is: sum_{c'} M_n[c,c'] Q_n(c') = R_n(c)
# where M_n = I - A(q^n) and R_n involves Q_{n-1}, Q_{n-2}.

# I need to extract R_n from the Q_n values.
# R_n(c) = Q_n(c) - sum_{|J|=1} q^n Q_n(c(J)) + sum_{|J|=2} q^{2n} Q_n(c(J))
#         - (if |I_c|=3) q^{3n} Q_n(c)
#        = [M_n * Q_n_vector](c)

# Let me compute M_n * Q_n and check what it equals in terms of Q_{n-1}, Q_{n-2}.
print("System recurrence analysis for d=4:")
print()

for n in [1, 2, 3]:
    print(f"n = {n}:")
    
    # Compute M_n * Q_n_vector
    An = eval_A(q**n)
    Mn = I_mat - An
    Qn_vec = vector(R, [Qn_all[(c, n)] for c in compositions])
    
    lhs = Mn * Qn_vec
    
    # What should the RHS be?
    # From the functional equation:
    # R_n(c) = sum_{|J|=2} q^{2n-1}(1-q^n) Q_{n-1}(c(J))
    #        - (if |I_c|=3) [(q^{3n-2} + q^{3n-1})(1-q^n) Q_{n-1}(c)
    #          - q^{3n-3}(1-q^n)(1-q^{n-1}) Q_{n-2}(c)]
    
    rhs = vector(R, N)
    for ci, c in enumerate(compositions):
        I_c = [i for i in range(3) if c[i] > 0]
        val = R(0)
        
        # |J|=2 contribution
        for J in combs(I_c, 2):
            cJ = shift_profile(c, set(J))
            if min(cJ) < 0 or cJ not in comp_idx:
                continue
            val += q**(2*n-1) * (1-q**n) * Qn_all[(cJ, n-1)]
        
        # |J|=3 contribution (only if all parts > 0)
        if len(I_c) == 3:
            val -= (q**(3*n-2) + q**(3*n-1)) * (1-q**n) * Qn_all[(c, n-1)]
            if n >= 2:
                val += q**(3*n-3) * (1-q**n) * (1-q**(n-1)) * Qn_all[(c, n-2)]
        
        rhs[ci] = val
    
    # Check
    diff = lhs - rhs
    max_nonzero = max((abs(diff[i].truncate(40)[j]) for i in range(N) for j in range(40)), default=0)
    print(f"  max |LHS - RHS| coefficient = {max_nonzero}")
    
    if max_nonzero > 0:
        print("  MISMATCH! Let me check individual profiles...")
        for ci, c in enumerate(compositions):
            d_val = (lhs[ci] - rhs[ci]).truncate(30)
            if d_val != 0:
                print(f"    c={c}: diff = {d_val}")
                print(f"      LHS = {lhs[ci].add_bigoh(15)}")
                print(f"      RHS = {rhs[ci].add_bigoh(15)}")
                break
    else:
        print("  VERIFIED: System recurrence holds!")
        
        # Now solve for Q_n:
        # Q_n = (I-A(q^n))^{-1} * RHS
        # = adj(I-A(q^n))/(1-q^{3n}) * RHS
        #
        # This means: Q_n(c) = sum_{c'} q^{n*EMD(c,c')}/(1-q^{3n}) * RHS(c')
        #
        # For positivity of Q_n, we need RHS * adj to give nonneg numerator,
        # and (1-q^{3n}) divides it evenly.
        
        if n == 2:
            print()
            print("  RHS for n=2:")
            for ci, c in enumerate(compositions):
                rhs_val = rhs[ci].truncate(30)
                if rhs_val != 0:
                    coeffs = [rhs_val[j] for j in range(30)]
                    max_d = max((j for j in range(30) if coeffs[j] != 0), default=0)
                    is_nonneg = all(coeffs[j] >= 0 for j in range(max_d+1))
                    print(f"    RHS({c}) nonneg={is_nonneg}, = {rhs_val}")

print()
print("=" * 70)
print("CRITICAL OBSERVATION:")
print("If the recurrence holds and RHS is expressible in terms of Q_{n-1},")
print("Q_{n-2} (which are nonneg by induction), then Q_n >= 0 follows IF")
print("the coefficients in the recurrence are nonneg.")
print("=" * 70)

