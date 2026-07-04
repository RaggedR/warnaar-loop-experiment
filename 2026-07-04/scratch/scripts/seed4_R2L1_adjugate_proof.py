"""
Prove the Adjugate Monomial Theorem: adj(I - A(x))[c,c'] = x^{EMD(c,c')}

Strategy: Use the Bellman equation for EMD and the inclusion-exclusion structure of A(x).

Key facts established by Agent B:
1. det(I - A(x)) = -(x^3 - 1) for all d
2. A(x)[c, c'] = sum_{J: c(J)=c'} (-1)^{|J|-1} x^{|J|}

The Bellman equation: EMD(c, c') = min_{J subset I_c, J nonempty} (|J| + EMD(c(J), c'))

Proof sketch:
adj(I-A(x)) = det(I-A(x)) * (I-A(x))^{-1} = -(x^3-1) * (I-A(x))^{-1}

So we need (I-A(x))^{-1}[c,c'] = -x^{EMD(c,c')} / (x^3-1)
                                 = x^{EMD(c,c')} / (1-x^3)
                                 = x^{EMD(c,c')} * sum_{k>=0} x^{3k}
                                 = sum_{k>=0} x^{EMD(c,c') + 3k}

This is interesting! (I-A(x))^{-1} = sum_{k>=0} A(x)^k, so:
sum_{k>=0} A(x)^k [c,c'] = sum_{k>=0} x^{EMD(c,c') + 3k}

This means: the k-fold composition A(x)^k contributes x^{EMD+3k} terms,
or more precisely: the sum over all paths of length k in the A-graph
from c' to c, with weight product x^{sum |J_i|}, equals x^{EMD(c,c') + 3k}
(modulo lower order terms? No, exactly this).

Wait, actually A(x)^k is convolution. Let me think about this differently.

Let me verify the (I-A)^{-1} formula computationally first.
"""
from sympy import symbols, Matrix, eye, det, factor, simplify, expand, cancel
from sympy import zeros as szeros, Poly, series, Symbol, oo
from itertools import combinations

x = Symbol('x')

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def I_c(c):
    return [i for i in range(3) if c[i] > 0]

def shifted_profile(c, J):
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
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def build_A_matrix(d):
    profs = profiles(d)
    n = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    A = szeros(n, n)
    for c in profs:
        ic = I_c(c)
        if not ic:
            continue
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

# Test for d=1 (3 profiles)
d = 1
A, profs = build_A_matrix(d)
n = len(profs)
M = eye(n) - A
print(f"d = {d}, {n} profiles: {profs}")
print(f"A(x) = {A}")
print(f"det(I-A) = {factor(det(M))}")

# Compute (I-A)^{-1} and check
Minv = M.inv()
print(f"\n(I-A)^{-1}:")
for i in range(n):
    for j in range(n):
        entry = cancel(Minv[i,j])
        emd_val = emd_clockwise(profs[i], profs[j])
        expected = cancel(x**emd_val / (1 - x**3))
        diff = cancel(entry - expected)
        match = "OK" if diff == 0 else f"MISMATCH: got {entry}"
        print(f"  [{profs[i]}, {profs[j]}]: EMD={emd_val}, (I-A)^{{-1}} = x^{emd_val}/(1-x^3) {match}")

# Now d=2
print(f"\n{'='*60}")
d = 2
A, profs = build_A_matrix(d)
n = len(profs)
M = eye(n) - A
print(f"d = {d}, {n} profiles: {profs}")
print(f"det(I-A) = {factor(det(M))}")

# Check adjugate
adj = M.adjugate()
print(f"\nadjugate entries:")
all_match = True
for i in range(n):
    for j in range(n):
        entry = expand(adj[i,j])
        emd_val = emd_clockwise(profs[i], profs[j])
        expected = x**emd_val
        if expand(entry - expected) != 0:
            print(f"  MISMATCH: adj[{profs[i]},{profs[j]}] = {entry}, expected x^{emd_val}")
            all_match = False
if all_match:
    print(f"  All {n*n} entries match x^EMD!")

# Now let me look at the STRUCTURE of A for d=1 more carefully
print(f"\n{'='*60}")
print("Structure analysis for d=1:")
d = 1
profs = profiles(d)
print(f"Profiles: {profs}")
print(f"EMD table:")
for c1 in profs:
    for c2 in profs:
        print(f"  EMD({c1}, {c2}) = {emd_clockwise(c1, c2)}")

# The CW shifts for each profile
print(f"\nCW shifts:")
for c in profs:
    ic = I_c(c)
    print(f"  c = {c}, I_c = {ic}")
    for size in range(1, len(ic)+1):
        for J in combinations(ic, size):
            cp = shifted_profile(c, J)
            print(f"    J = {J}, |J| = {len(J)}, c(J) = {cp}")

# Key insight: for r=3, the EMD on Z/3Z with clockwise metric has
# EMD(c, c') = cost of transporting c to c'
# where moving one unit clockwise costs 1
# and moving one unit counterclockwise costs 2

# The Bellman equation:
# EMD(c, c') = min_{J nonempty subset of I_c} (|J| + EMD(c(J), c'))
# This needs to be verified

print(f"\n{'='*60}")
print("Bellman equation verification for d=2:")
d = 2
profs = profiles(d)
for c in profs:
    for cp in profs:
        emd_val = emd_clockwise(c, cp)
        ic = I_c(c)
        if not ic:
            # c = (0,0,d) or similar - only one nonzero entry
            # Actually for d=2, (0,0,2) has I_c = {2}
            continue
        min_bellman = float('inf')
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cJ = shifted_profile(c, J)
                if all(ci >= 0 for ci in cJ):
                    bell = len(J) + emd_clockwise(cJ, cp)
                    if bell < min_bellman:
                        min_bellman = bell
        # Check: EMD(c,c') = min_J (|J| + EMD(c(J), c')) 
        # Only when c != c' (self-loop has EMD=0 and Bellman gives >= 1)
        if c != cp:
            match = "OK" if emd_val == min_bellman else f"MISMATCH: Bellman={min_bellman}"
            print(f"  EMD({c},{cp}) = {emd_val}, Bellman min = {min_bellman} {match}")

# For c = c', EMD = 0 but Bellman min >= 1, so we need the base case.
# The correct Bellman equation is:
# EMD(c, c') = 0 if c = c'
# EMD(c, c') = min_J (|J| + EMD(c(J), c')) if c != c'

# But this is a RECURSIVE equation - does it terminate?
# Since |J| >= 1 and the total weight d is preserved, 
# the recursion might cycle (e.g., c -> c(J) -> c(J(J')) -> ... -> c)

# Actually the key point is that the CW shift c(J) is NOT a simple 
# "move one step" in EMD space. The shifts can be complex.

# Let me check: does c(J) always have EMD(c(J), c') < EMD(c, c')?
# If |J| + EMD(c(J), c') = EMD(c, c'), then EMD(c(J), c') = EMD(c,c') - |J| < EMD(c,c')
# So yes, the minimizing J always reduces EMD!

print(f"\n{'='*60}")
print("Checking Bellman optimality for d=4:")
d = 4
profs = profiles(d)
failures = 0
for c in profs:
    for cp in profs:
        if c == cp:
            continue
        emd_val = emd_clockwise(c, cp)
        ic = I_c(c)
        min_val = float('inf')
        minimizers = []
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cJ = shifted_profile(c, J)
                if all(ci >= 0 for ci in cJ):
                    bell = len(J) + emd_clockwise(cJ, cp)
                    if bell < min_val:
                        min_val = bell
                        minimizers = [J]
                    elif bell == min_val:
                        minimizers.append(J)
        if emd_val != min_val:
            print(f"  FAIL: EMD({c},{cp}) = {emd_val}, Bellman = {min_val}")
            failures += 1

if failures == 0:
    print(f"  Bellman equation verified for all {len(profs)**2 - len(profs)} pairs!")
else:
    print(f"  {failures} failures")

