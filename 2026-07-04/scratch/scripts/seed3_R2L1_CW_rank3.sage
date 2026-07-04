"""
Seed 3, R2L1: Study the rank-3 CW functional equation system directly.

For rank 3, the CW functional equation is:
F_c(y,q) = sum_{J nonempty, J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^{|J|},q) / (1-yq^{|J|})

where I_c = {i : c_i > 0}, and c(J) is the shifted profile.

For bounded CPs (max <= n), this gives:
F_{c,n} = sum_{J nonempty, J subset I_c} (-1)^{|J|-1} [certain combination of F_{c(J),n-|J|}]

Agent C found that for k >= 3, the system has 7 types instead of 3.
Let me enumerate these types for a specific d and see if the system closes.

Then test whether the EMD adjugate structure can close it.
"""

R.<q> = PowerSeriesRing(ZZ, default_prec=300)

def profiles(d):
    result = []
    for i in range(d+1):
        for j in range(d-i+1):
            result.append((i, j, d-i-j))
    return result

def I_c(c):
    """Set of indices i where c_i > 0."""
    return {i for i in range(3) if c[i] > 0}

def shift_profile(c, J):
    """Compute c(J) for nonempty J subset of I_c."""
    r = len(c)
    result = list(c)
    for i in range(r):
        prev = (i - 1) % r
        if i in J and prev not in J:
            result[i] -= 1
        elif i not in J and prev in J:
            result[i] += 1
    return tuple(result)

def nonempty_subsets(S):
    """Generate all nonempty subsets of set S."""
    S = list(S)
    n = len(S)
    for mask in range(1, 2**n):
        yield frozenset(S[i] for i in range(n) if mask & (1 << i))

# ======================================================================
# Enumerate the shift types for d=7 (k=2 for modulus 10)
# ======================================================================
print("=" * 60)
print("CW shift analysis for d=7")
print("=" * 60)

d = 7
profs = profiles(d)
print(f"Number of profiles: {len(profs)}")

# For each profile c, list all (J, c(J)) pairs
shift_types = set()
for c in profs:
    Ic = I_c(c)
    for J in nonempty_subsets(Ic):
        cJ = shift_profile(c, J)
        # Check if cJ has nonneg entries (valid composition)
        if all(x >= 0 for x in cJ):
            shift_types.add((len(J), sum(cJ), cJ))

print(f"Number of distinct (|J|, d(c(J)), c(J)) shift types: {len(shift_types)}")
for jsize, dsum, cJ in sorted(shift_types):
    print(f"  |J|={jsize}, d(c(J))={dsum}, c(J)={cJ}")

# ======================================================================
# For d=4 (k=1 for modulus 7), let's trace the CW functional equation
# and see how many distinct profile types the system visits.
# ======================================================================
print("\n" + "=" * 60)
print("CW shift closure analysis for d=4")
print("=" * 60)

d = 4

# Starting from a specific profile, apply CW shifts repeatedly
# and see what profiles we visit.
def closure(c, d):
    """Find all profiles reachable from c by iterated CW shifts."""
    visited = set()
    queue = [c]
    while queue:
        curr = queue.pop()
        if curr in visited:
            continue
        visited.add(curr)
        Ic = I_c(curr)
        for J in nonempty_subsets(Ic):
            cJ = shift_profile(curr, J)
            if all(x >= 0 for x in cJ) and sum(cJ) == d:
                queue.append(cJ)
    return visited

c_start = (2, 1, 1)
reachable = closure(c_start, d)
print(f"Starting from {c_start}: reachable profiles ({len(reachable)}):")
for c in sorted(reachable):
    print(f"  {c}")

# The system visits ALL profiles (since shifts are between profiles of same d).
# The question is whether the FUNCTIONAL EQUATION system closes.
# For bounded CPs: the functional equation relates F_{c,n} to F_{c',n'} where
# n' < n (because of the z shift). So it always closes in finite steps.
# But the issue is whether we can get MANIFESTLY POSITIVE expressions.

# ======================================================================
# The rank-2 closure:
# For rank 2, d=3: profiles are (3,0), (2,1), (1,2), (0,3)
# But actually rank 2 means r=2, so compositions of d into 2 parts.
# The CW shifts for r=2 are simpler:
# I_c = {i : c_i > 0}, and for r=2, J can be {0}, {1}, or {0,1}.
# c(J) shifts are determined by boundary effects.
# ======================================================================

# For rank 2, d=3:
print("\n" + "=" * 60)
print("Rank-2 CW shift analysis for d=3")
print("=" * 60)

d_r2 = 3
r2_profs = [(i, d_r2-i) for i in range(d_r2+1)]
print(f"Rank-2 profiles for d={d_r2}: {r2_profs}")

for c in r2_profs:
    Ic = {i for i in range(2) if c[i] > 0}
    print(f"\nc = {c}, I_c = {Ic}")
    for J in nonempty_subsets(Ic):
        cJ_list = list(c)
        for i in range(2):
            prev = (i-1) % 2
            if i in J and prev not in J:
                cJ_list[i] -= 1
            elif i not in J and prev in J:
                cJ_list[i] += 1
        cJ = tuple(cJ_list)
        print(f"  J={set(J)}, c(J)={cJ}")

# ======================================================================
# NOW the crucial computation:
# For rank 3, d=4, try to write the bounded functional equation as
# a MATRIX recurrence on F_{c,n} and see if it can be inverted
# to give a manifestly positive expression.
# ======================================================================

print("\n" + "=" * 60)
print("Matrix form of CW bounded recurrence for d=4, rank 3")
print("=" * 60)

d = 4
profs = profiles(d)

# The transfer matrix approach:
# F_{c,n} = 1/(1-q^{3n}) * sum_{c'} q^{n*EMD(c,c')} F_{c',n-1}
# = (I - A(q^n))^{-1}[c,c'] summed with F_{c',n-1}
# where (I-A(x))^{-1} = adj(I-A(x))/det(I-A(x)) = x^{EMD(c,c')}/(1-x^3)

# So F_{c,n} = sum_{c'} q^{n*EMD(c,c')}/(1-q^{3n}) * F_{c',n-1}

# This is the same as the EMD path formula divided by (q^3;q^3)_n.

# The question for manifestly positive Q_n:
# Q_n involves extracting [z^n] of (zq;q)_inf * sum g_m z^m
# = [z^n] of prod(1-zq^j) * sum g_m z^m

# The product (1-zq^j) introduces alternating signs.
# But in the rank-2 case, Warnaar found a bounded multisum where these signs cancel.

# For rank 2, the manifestly positive formula is:
# GK_{lambda/mu/d;n0}(q) = sum_{n1,...,n_{k-1}} q^{quadratic} prod [binomial]
# This is a q-series with all nonneg terms.

# For rank 3, we need a similar representation but with more summation variables.
# The 7 types for k>=3 come from the fact that the CW shifts for J={0}, {1}, {2},
# {0,1}, {0,2}, {1,2}, {0,1,2} give 7 different profile modifications.
# But some of these might be related.

# Let me count the effective number of independent shift types for d=4:
print(f"\nCW shifts for d={d}, rank 3:")
all_shifts = {}
for c in profs:
    Ic = I_c(c)
    shifts = []
    for J in nonempty_subsets(Ic):
        cJ = shift_profile(c, J)
        if all(x >= 0 for x in cJ):
            shifts.append((sorted(J), cJ, len(J)))
    all_shifts[c] = shifts
    print(f"  c={c}: {len(shifts)} shifts")
    for J, cJ, jsize in shifts:
        print(f"    J={J}, c(J)={cJ}, |J|={jsize}")

# ======================================================================
# KEY INSIGHT FROM WARNAAR'S PROOF:
# For rank 2, the system closes because:
# 1. There are only 2 types: J={0} and J={1} (plus J={0,1} but |J|=2 means it appears
#    at a different level of the recursion).
# 2. The profiles (lambda,mu) live in a 1-parameter family indexed by L.
# 3. The recurrence in L closes into a 3-term recurrence solvable by q-binomials.
#
# For rank 3, we'd need:
# 1. Up to 7 types of J.
# 2. Profiles (lambda,mu) live in a multi-parameter family.
# 3. The recurrence needs to close in this larger space.
#
# The EMD structure provides a UNIVERSAL simplification:
# Instead of tracking individual profile-to-profile transitions,
# we can use the fact that the transfer matrix entries are monomials q^{n*EMD}.
# This means the MATRIX recurrence factors through the EMD structure.
# ======================================================================

# ======================================================================
# COMPUTATION: Test whether the (1+q^n+q^{2n}) denominator from det(I-A)
# leads to a manifestly positive quotient.
#
# From Agent C: Q_n(c) * (1+q^n+q^{2n}) = sum_{c'} q^{n*EMD(c,c')} * R(c',n)
# where R involves Q_{n-1} and Q_{n-2}.
# If R is nonneg and the quotient is nonneg, we'd have an inductive proof.
# ======================================================================

def emd(c, cp):
    e = [c[i] - cp[i] for i in range(3)]
    t_min = max(0, -e[0], -e[0]-e[1])
    return 2*e[0] + e[1] + 3*t_min

# Compute Q_n using verified method
def compute_Qn(d, n_max, prec=300):
    profs = profiles(d)
    ell = gcd(d, 3)
    
    P = {}
    for c in profs: P[(c, 0)] = R(1)
    for n in range(1, n_max+1):
        for c in profs:
            P[(c, n)] = sum(q^(n*emd(cp, c)) * P[(cp, n-1)] for cp in profs)
    
    q3 = [prod(1 - q^(3*i) for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    qn = [prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1) for n in range(n_max+1)]
    
    F = {(c, n): P[(c, n)] / q3[n] for c in profs for n in range(n_max+1)}
    
    Q = {}
    for c in profs:
        g = {0: F[(c, 0)]}
        for m in range(1, n_max+1):
            g[m] = F[(c, m)] - F[(c, m-1)]
        h = {m: qn[m] * g[m] for m in range(n_max+1)}
        
        Q[(c, 0)] = R(1)
        for n in range(1, n_max+1):
            D = {}
            for m in range(n+1): D[(0, m)] = h[m]
            for k in range(1, n+1):
                for m in range(k, n+1):
                    D[(k, m)] = D[(k-1, m)] - q^k * D.get((k-1, m-1), R(0))
            if ell == 1:
                Q[(c, n)] = D[(n, n)]
            else:
                qelln = prod(1 - q^(ell*i) for i in range(1, n+1))
                Q[(c, n)] = qelln * D[(n, n)] / qn[n]
    
    return Q, P, profs

print("\n" + "=" * 60)
print("Testing the inductive quotient for d=4")
print("=" * 60)

d = 4
Q, P, profs = compute_Qn(d, 4)

# For the induction: need to express Q_n in terms of Q_{n-1} and Q_{n-2}.
# From the P_n recurrence: P_n(c) = sum_{c'} q^{n*EMD(c,c')} P_{n-1}(c')
# And P_n = (q^3;q^3)_n F_{c,n}

# The Q_n recurrence should come from substituting F_{c,n} and the iterated q-difference.
# Let me try to DERIVE it from scratch.

# Q_n(c) is a polynomial. Let's find a recurrence by computing:
# For each n >= 2, express Q_n(c) as a linear combination of {Q_{n-1}(c') : c' in profs}
# plus possibly {Q_{n-2}(c') : c' in profs}.

# This is a linear algebra problem: for each c, we have one equation
# Q_n(c) = sum_{c'} a_{c,c'}(q,n) Q_{n-1}(c') + sum_{c'} b_{c,c'}(q,n) Q_{n-2}(c')

# For fixed n, this gives #profs equations in 2*#profs unknowns.
# But the a's and b's should be "simple" functions of q and n.

# Let me try a SPECIFIC ansatz: 
# Q_n(c) = 1/phi_3(q^n) [sum_{c'} q^{n*EMD(c,c')} * (alpha(n) Q_{n-1}(c') + beta(n) Q_{n-2}(c'))]

# Test for c = (2,1,1), n = 2:
c0 = (2,1,1)
n = 2
phi3 = 1 + q^n + q^(2*n)
lhs = phi3 * Q[(c0, 2)]

# Build matrix: lhs = sum_{c'} q^{2*EMD(c0,c')} * (alpha * Q_1(c') + beta * Q_0(c'))
# where alpha, beta are to be determined.

# First list EMD values from c0 to all c':
print(f"\nEMD from {c0} to all profiles:")
for cp in profs:
    e = emd(cp, c0)
    print(f"  EMD({cp}, {c0}) = {e}")

# Compute sum_{c'} q^{n*EMD} Q_{n-1}(c') for n=2
sum_Q1 = sum(q^(2*emd(cp, c0)) * Q[(cp, 1)] for cp in profs)
sum_Q0 = sum(q^(2*emd(cp, c0)) * Q[(cp, 0)] for cp in profs)

print(f"\n(1+q^2+q^4) Q_2((2,1,1)) = {lhs.list()[:20]}")
print(f"sum q^{{2*EMD}} Q_1 = {sum_Q1.list()[:20]}")
print(f"sum q^{{2*EMD}} Q_0 = {sum_Q0.list()[:20]}")

# Try: lhs = alpha * sum_Q1 + beta * sum_Q0
# This is one equation in two unknowns (both power series).
# Can we find alpha, beta as simple rational functions of q?

# Actually, maybe the recurrence is NOT of this simple form.
# Let me try a more general approach: for EACH c', find the coefficient.

# Write Q_2(c0) = sum_{c'} a_{c'} Q_1(c') + sum_{c'} b_{c'} Q_0(c')
# where a_{c'}, b_{c'} are unknown power series.
# With 30 unknowns (15+15) and one equation, this is underdetermined.
# But if we use ALL profiles c0, we get 15 equations in 30 unknowns.

# However, if the a's and b's have a specific form related to EMD,
# we can reduce the unknowns.

# Let me try the simplest non-trivial form:
# phi_3(q^n) Q_n(c) = sum_{c'} q^{n*EMD(c,c')} [alpha_0 Q_{n-1}(c') + alpha_1 q^n Q_{n-1}(c')
#                                                  + beta_0 Q_{n-2}(c') + ...]

# Actually, let me compute the FULL relationship between Q_2 and Q_1 numerically
# for ALL profiles simultaneously, and see if there's a pattern.

print("\n" + "=" * 60)
print("Full Q_2 vs Q_1 analysis for d=4")
print("=" * 60)

# The EMD matrix for d=4:
print("EMD matrix:")
for c in profs:
    emds = [emd(cp, c) for cp in profs]
    print(f"  row {c}: {emds}")

# The distinct EMD values (for d=4, r=3):
emd_vals = sorted(set(emd(c, cp) for c in profs for cp in profs))
print(f"\nDistinct EMD values: {emd_vals}")

# For d=4: EMD values are 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
# Actually, max EMD = 3*(d) = 12 (move all mass around the cycle).
# But many intermediate values might not appear.

# The KEY structural question:
# Can we group profiles by their "type" such that within each type,
# the Q_n recurrence has the same form?

# From the cyclic C_3 invariance: Q_n(c_0,c_1,c_2) = Q_n(c_1,c_2,c_0).
# So profiles differing by cyclic rotation give the same Q_n.

# Orbits under C_3 for d=4:
from itertools import groupby
orbits = {}
for c in profs:
    orbit = tuple(sorted([c, (c[1],c[2],c[0]), (c[2],c[0],c[1])]))
    orbits.setdefault(orbit, []).append(c)

print(f"\nC_3 orbits for d=4:")
for orbit, members in sorted(orbits.items()):
    Qvals = [Q[(m, 1)].list()[:10] for m in members[:1]]
    print(f"  {members[0]} (orbit size {len(set(members))}): Q_1 = {Qvals[0]}")
