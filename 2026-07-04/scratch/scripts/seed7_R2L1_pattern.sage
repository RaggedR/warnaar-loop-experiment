# Look for pattern in the multisum structure for Q_n
# The recursion is:
# g_{c,n} = (1/(1-q^{3n})) * sum_{c'} q^{n*EMD(c,c')} * b_n(c')
# where b_n(c') = sum_{J subset I_{c'}} sign(J) * past_terms(J, g_{.,n-1}, g_{.,n-2})
#
# For n=1: b_1(c') = q*binom(r,2) - (q+q^2)*binom(r,3) with r=rank(c')
# For n=2: b_2(c') involves g_{c'',1} and g_{c'',0}
#
# The question is: can we unfold this recursion to get a multisum over PATHS
# (c = c^(n), c^(n-1), ..., c^(0)) where each step contributes a manifestly positive term?
#
# Let me try to understand the n=2 case by tracing through one specific profile.

from itertools import combinations

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
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

def EMD_formula(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def rank(c):
    return sum(1 for ci in c if ci > 0)

# Instead of unfolding, let me look at Q_n for small d to see the pattern.
# For d=2 (6 profiles), compute Q_n for n=1,2,3 and look at the structure.

d = 2
profs = profiles(d)
N = len(profs)
ell = gcd(d, 3)
prec = 100
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

# Full computation via G_c system
g = {}
for c in profs:
    g[(c, 0)] = R(1)

prof_idx = {p: i for i, p in enumerate(profs)}

for n in range(1, 5):
    A_n = matrix(R, N, N)
    b_n = vector(R, N)
    
    for idx, c in enumerate(profs):
        ic = I_c(c)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if any(ci < 0 for ci in cp) or sum(cp) != d:
                    continue
                j_idx = prof_idx[cp]
                s = size
                sign = (-1)**(s-1)
                if s == 1:
                    A_n[idx, j_idx] += sign * q**n
                elif s == 2:
                    A_n[idx, j_idx] += sign * q**(2*n)
                    if n >= 1:
                        b_n[idx] += sign * (-q**(2*n-1)) * g[(cp, n-1)]
                elif s == 3:
                    A_n[idx, j_idx] += sign * q**(3*n)
                    if n >= 1:
                        b_n[idx] += sign * (-(q + q**2)) * q**(3*(n-1)) * g[(cp, n-1)]
                    if n >= 2:
                        b_n[idx] += sign * q**3 * q**(3*(n-2)) * g[(cp, n-2)]
    
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    M = I_mat - A_n
    g_n = M.solve_right(b_n)
    for i, c in enumerate(profs):
        g[(c, n)] = g_n[i]

# Q_n values for d=2
print("Q_n for d=2, c=(1,1,0):")
c = (1, 1, 0)
for n in range(1, 5):
    qpoch = R(1)
    for i in range(n):
        qpoch *= (1 - q**(i+1))
    Q = qpoch * g[(c, n)]
    max_nz = max((i for i in range(prec) if Q[i] != 0), default=-1)
    coeffs = [Q[i] for i in range(min(40, max_nz+2))]
    ev = sum(Q[i] for i in range(max_nz+1))
    print(f"  Q_{n}: deg={max_nz}, eval={ev}, coeffs={coeffs}")

print("\nQ_n for d=2, c=(2,0,0):")
c = (2, 0, 0)
for n in range(1, 5):
    qpoch = R(1)
    for i in range(n):
        qpoch *= (1 - q**(i+1))
    Q = qpoch * g[(c, n)]
    max_nz = max((i for i in range(prec) if Q[i] != 0), default=-1)
    coeffs = [Q[i] for i in range(min(40, max_nz+2))]
    ev = sum(Q[i] for i in range(max_nz+1))
    print(f"  Q_{n}: deg={max_nz}, eval={ev}, coeffs={coeffs}")

# Look for q-binomial or gaussian polynomial decomposition
print("\n=== Looking at Q_n degree pattern ===")
for c in profs:
    degs = []
    for n in range(1, 5):
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(i+1))
        Q = qpoch * g[(c, n)]
        max_nz = max((i for i in range(prec) if Q[i] != 0), default=-1)
        degs.append(max_nz)
    print(f"  c={c}: degrees = {degs}")
