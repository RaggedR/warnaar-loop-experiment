"""
Agent B: Attempt to prove the Adjugate Monomial Theorem algebraically.

Key idea: The CW shift matrix A(x) on compositions of d into 3 parts has structure:
  A(x) = x * S_+ - x^2 * S_- + x^3 * I_*
where:
  S_+ = clockwise shift adjacency
  S_- = counterclockwise shift adjacency 
  I_* = identity restricted to interior (all c_i > 0)

Note: S_-[c,c'] = S_+[c',c] when both c and c' have all parts positive.
So S_- is the "transpose-like" of S_+ (but not exactly, because boundary behavior differs).

Approach: Show that (I - A(x)) factors or has a special structure.

I - A(x) = I - x*S_+ + x^2*S_- - x^3*I_*
          = (1-x^3)*I_* + I_boundary - x*S_+ + x^2*S_-

where I_boundary is the identity restricted to boundary compositions (some c_i = 0).

Actually, let me think about this differently. 

OBSERVATION: For d=1, A = xP where P is the cyclic permutation.
I - xP has adj = I + xP + x^2 P^2, which equals the geometric sum (I - x^3 P^3)/(I - xP) = (1-x^3)I/(I-xP).

For general d, A(x) is NOT simply xP for a permutation P. But the result
adj(I-A(x))[c,c'] = x^{EMD(c,c')} suggests there's an analogous "geometric sum" structure.

Let me check: is adj(I-A(x)) = sum_{k=0}^{2} x^k * S_+^k in some sense?
For d=1: S_+ = P, and adj = I + xP + x^2 P^2 = sum_{k=0}^2 x^k P^k. Yes!

For d=2: does adj = I + x*S_+ + x^2*S_+^2 work?
S_+^2 should give the 2-step clockwise shift, which equals S_-.
So adj = I + x*S_+ + x^2*S_- (for d=1 where S_- = P^2 = S_+^2).
For general d, S_+^2 != S_- because multiple paths exist in the shift graph.

Actually, maybe the theorem follows from a FLOW interpretation.
The (i,j) cofactor of (I-A(x)) equals (-1)^{i+j} det(minor).
If we can show this equals x^{EMD(i,j)}, we need a tropical argument.

Let me try a different approach: direct computation of (I-A(x)) * adj_predicted
and check that it equals (1-x^3) * I.

If adj_predicted[c,c'] = x^{EMD(c,c')}, then:
[(I-A(x)) * adj_predicted][c,c'] = sum_c'' (I-A(x))[c,c''] * x^{EMD(c'',c')}

This should equal (1-x^3) * delta_{c,c'}.
"""
from sage.all import *
from itertools import combinations

def clockwise_emd(c, cp):
    e = [cp[i] - c[i] for i in range(3)]
    t_min = max(0, e[1], -e[0])
    return 3 * t_min + e[0] - e[1]

# For d=4, verify (I-A(x)) * adj_predicted = (1-x^3) * I directly
d = 4
r = 3
compositions = []
for c0 in range(d+1):
    for c1 in range(d+1-c0):
        c2 = d - c0 - c1
        compositions.append((c0, c1, c2))
N = len(compositions)
comp_idx = {c: i for i, c in enumerate(compositions)}

def shift_profile(c, J):
    k = len(c)
    result = list(c)
    for i in range(k):
        prev = (i - 1) % k
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

Rx = PolynomialRing(QQ, 'x')
x = Rx.gen()

A = matrix(Rx, N, N, 0)
for ic, c in enumerate(compositions):
    I_c = {i for i in range(r) if c[i] > 0}
    for size in range(1, len(I_c) + 1):
        for J in combinations(sorted(I_c), size):
            J_set = set(J)
            cJ = shift_profile(c, J_set)
            if min(cJ) < 0:
                continue
            sign = (-1)**(size - 1)
            if cJ in comp_idx:
                A[ic, comp_idx[cJ]] += sign * x**size

I_mat = matrix(Rx, N, N, lambda i,j: 1 if i==j else 0)
B = I_mat - A

# Build predicted adjugate
adj_pred = matrix(Rx, N, N)
for i in range(N):
    for j in range(N):
        adj_pred[i,j] = x**clockwise_emd(compositions[i], compositions[j])

# Check B * adj_pred = (1-x^3) * I
product = B * adj_pred
target = (1 - x**3) * I_mat

if product == target:
    print("VERIFIED: (I-A(x)) * adj_EMD = (1-x^3) * I for d=4!")
else:
    print("FAILED for d=4")
    for i in range(N):
        for j in range(N):
            if product[i,j] != target[i,j]:
                print(f"  [{compositions[i]},{compositions[j]}]: got {product[i,j]}, expected {target[i,j]}")
                break
        else:
            continue
        break

# Now let me understand WHY this works.
# (I-A(x))[c,c'] = delta_{cc'} - A(x)[c,c']
# A(x)[c,c'] = sum_J (-1)^{|J|-1} x^{|J|} [c(J) = c']

# [(I-A(x)) * adj_EMD][c,c'] = x^{EMD(c,c')} - sum_{c''} A(x)[c,c''] * x^{EMD(c'',c')}
# = x^{EMD(c,c')} - sum_J (-1)^{|J|-1} x^{|J|} * x^{EMD(c(J),c')}
# = x^{EMD(c,c')} - sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}

# For this to equal (1-x^3) * delta_{cc'}:
# When c != c': x^{EMD(c,c')} = sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}
# When c = c': 1 - x^3 = 1 - sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c)} 
#            = 1 - sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c)}

# The off-diagonal equation says:
# x^{EMD(c,c')} = sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}

# Let me check the exponents. For the RHS, each term has exponent |J| + EMD(c(J), c').
# For the LHS, the exponent is EMD(c, c').

# CLAIM: EMD(c,c') = min_J (|J| + EMD(c(J), c'))
# This is a BELLMAN-FORD type equation! EMD satisfies the dynamic programming
# relation for shortest path with edge weights |J|.

# But the EMD is the EARTH MOVER'S DISTANCE, which already has a definition.
# The Bellman equation would say: the minimum cost to transform c into c'
# equals the minimum over single steps J of (step cost |J|) + (remaining cost EMD(c(J), c')).

# This is exactly the shortest-path characterization of EMD!
# But the edge weights are |J| = 1 for clockwise shifts, |J| = 2 for counterclockwise,
# |J| = 3 for the identity (when all c_i > 0).

# So the EMD on Z/3Z with clockwise metric is the SHORTEST PATH in a weighted 
# directed graph where:
# - Clockwise single shifts (|J|=1) have weight 1
# - Counterclockwise single shifts (|J|=2) have weight 2
# - Identity (|J|=3) has weight 3

# This makes sense! Moving counterclockwise by 1 step costs 2 = 3-1 
# (going "the long way around" in the clockwise direction).

# The ALTERNATING SIGNS in A(x) implement inclusion-exclusion that reduces
# the sum to the MINIMUM weight path, making the adjugate monomial.

# This is the key algebraic insight. Let me verify the Bellman equation.
print("\n\nVerifying Bellman equation: EMD(c,c') = min_J (|J| + EMD(c(J), c')):")
for i in range(N):
    for j in range(N):
        c = compositions[i]
        cp = compositions[j]
        emd_direct = clockwise_emd(c, cp)
        
        # Compute min over valid shifts
        I_c = {k for k in range(r) if c[k] > 0}
        min_via_shift = float('inf')
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                via_cost = size + clockwise_emd(cJ, cp)
                if via_cost < min_via_shift:
                    min_via_shift = via_cost
        
        if i == j:
            # c = c': EMD = 0, and the shift J={0,1,2} gives cost 3 + EMD(c,c) = 3
            # The minimum should be 3 (via the identity shift), not 0.
            # So Bellman doesn't directly hold for c=c'.
            # But EMD(c,c) = 0 and min_via_shift = 3 (or less).
            # The Bellman equation would give EMD(c,c) = 0 if we allow the "no shift" option.
            pass
        else:
            if emd_direct != min_via_shift:
                print(f"  MISMATCH at ({c},{cp}): EMD={emd_direct}, min_via_shift={min_via_shift}")

print("  Done checking off-diagonal Bellman equation.")

# Now check: for c != c', does the alternating sum reduce to x^{EMD}?
# The key identity is:
# sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')} = x^{EMD(c,c')} [when c != c']
# sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')} = x^3 [when c = c', all c_i > 0]
# sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')} = 0 [when c = c', some c_i = 0]

# This is an INCLUSION-EXCLUSION on the shifts that reduces to a single term.

# The proof would go: for c != c', the shifts have a unique minimum-weight path,
# and the inclusion-exclusion cancels all non-minimal contributions.
# The key is that EMD satisfies the subadditivity property needed for this.

print("\n\nChecking the alternating sum identity:")
for i in range(min(5, N)):
    for j in range(min(5, N)):
        c = compositions[i]
        cp = compositions[j]
        I_c = {k for k in range(r) if c[k] > 0}
        
        # Compute sum_J (-1)^{|J|-1} x^{|J| + EMD(c(J),c')}
        total = Rx(0)
        for size in range(1, len(I_c) + 1):
            for J in combinations(sorted(I_c), size):
                J_set = set(J)
                cJ = shift_profile(c, J_set)
                if min(cJ) < 0:
                    continue
                sign = (-1)**(size - 1)
                emd = clockwise_emd(cJ, cp)
                total += sign * x**(size + emd)
        
        expected = x**clockwise_emd(c, cp) if i != j else x**3 if len(I_c) == 3 else Rx(0)
        
        # For c=c' with some c_i=0, I_c has size < 3
        if i == j and len(I_c) < 3:
            expected = Rx(0)
        # For c=c' with all c_i > 0, the sum should be x^3
        # Because J={0,1,2} gives (-1)^2 x^{3+0} = x^3 and other terms cancel
        
        if total != expected:
            print(f"  ({c},{cp}): sum = {total}, expected = {expected}")

print("  Done.")

