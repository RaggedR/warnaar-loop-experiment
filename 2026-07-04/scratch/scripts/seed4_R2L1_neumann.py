"""
Prove that (I-A(x))^{-1}[c,c'] = x^{EMD(c,c')} / (1-x^3) using the Neumann series.

The Neumann series: (I-A)^{-1} = sum_{k>=0} A^k

We need: sum_{k>=0} A(x)^k [c,c'] = x^{EMD(c,c')} / (1-x^3) = sum_{m>=0} x^{EMD(c,c') + 3m}

That is: for each k, the signed sum of walks of length k from c' to c in the A-graph
equals the coefficient of A^k in the geometric series x^{EMD}/(1-x^3).

But this isn't quite right because A(x) has entries that are polynomials in x,
and A^k accumulates these. What we need is:

(I-A)^{-1} = sum_{k>=0} A^k means the (i,j) entry is sum_{k>=0} (A^k)_{ij}
where (A^k)_{ij} is a polynomial in x.

The claim (I-A)^{-1}_{cc'} = x^{EMD(c,c')}/(1-x^3) means that this infinite sum
of polynomials converges (formally) to a rational function.

Let me verify this for d=1 where A = x*P (cyclic permutation).
A^k = x^k P^k. P^k has entry P^k_{ij} = 1 if j = (i-k) mod 3, else 0.
So (I-A)^{-1}_{cc'} = sum_{k>=0} x^k * [c' = (c shifted by -k mod 3)]
= sum_{k: k = EMD(c,c') mod 3} x^k = x^{EMD(c,c')} / (1-x^3). CHECK!

For general d, A is more complex. Let me verify A^2 for d=2.
"""
from sympy import symbols, Matrix, eye, expand, factor
from itertools import combinations

x = symbols('x')

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
    from sympy import zeros as szeros
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

# The key insight for the proof via Neumann series:
# We need to show that the "signed walk" structure of A respects EMD.
# 
# Define the RESIDUE of a walk w = (c_0, J_1, c_1, J_2, c_2, ..., J_k, c_k) as
# the total shift |J_1| + |J_2| + ... + |J_k| modulo 3.
# The sign of the walk is (-1)^{sum(|J_i|-1)} = (-1)^{sum|J_i| - k}.
# The x-weight is x^{sum|J_i|}.
#
# CLAIM: For each walk from c' to c with total shift s = sum|J_i|,
# if s = EMD(c,c') mod 3, then the signed contribution is +x^s;
# otherwise it is 0 (after summing over all walks with the same total shift s).
#
# This is equivalent to: the signed count of walks from c' to c with total shift s is:
# 1 if s >= EMD(c,c') and s = EMD(c,c') mod 3, else 0.

# Let me verify this for d=2, small k.
d = 2
A, profs = build_A_matrix(d)
n = len(profs)

print(f"d = {d}, {n} profiles")
print(f"A(x) = ")
for i in range(n):
    row = [str(expand(A[i,j])) for j in range(n)]
    print(f"  {profs[i]}: {row}")

# Compute A^k for k = 0, 1, 2, 3
Ak = eye(n)
for k in range(4):
    print(f"\nA^{k}:")
    for i in range(n):
        for j in range(n):
            entry = expand(Ak[i,j])
            emd = emd_clockwise(profs[i], profs[j])
            expected_terms = [f"x^{emd + 3*m}" for m in range(k+1) if emd + 3*m <= 3*k]
            # Actually the expected contribution at A^k level is just the sum-to-k
            # We're checking: does A^k[i,j] have coefficient 1 at x^s for s = emd mod 3, s <= sum|J|=some value
            if entry != 0:
                print(f"  [{profs[i]},{profs[j]}]: A^{k} = {entry}, EMD = {emd}")
    Ak = Ak * A
    Ak = Matrix([[expand(Ak[i,j]) for j in range(n)] for i in range(n)])

# Now compute cumulative sum I + A + A^2 + A^3
cumul = eye(n)
Ak = eye(n)
for k in range(1, 5):
    Ak = Ak * A
    Ak_exp = Matrix([[expand(Ak[i,j]) for j in range(n)] for i in range(n)])
    cumul = cumul + Ak_exp

print(f"\n\nsum_{{k=0}}^4 A^k:")
for i in range(min(3, n)):
    for j in range(min(3, n)):
        entry = expand(cumul[i,j])
        emd = emd_clockwise(profs[i], profs[j])
        # Expected: x^emd + x^{emd+3} + ... up to degree 4*max_edge_weight
        print(f"  [{profs[i]},{profs[j]}]: EMD={emd}, partial sum = {entry}")
        # The expected full sum is x^emd/(1-x^3) = x^emd + x^{emd+3} + x^{emd+6} + ...

