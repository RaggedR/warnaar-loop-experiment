# Verify g_{c,n} and Q_{n,c} for d=2 with higher precision
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

def compute_gn(d, n_max, prec):
    profs = profiles(d)
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    g = {}
    for c in profs:
        g[(c, 0)] = R(1)
    
    for n in range(1, n_max + 1):
        N = len(profs)
        prof_idx = {p: i for i, p in enumerate(profs)}
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
    
    return g, profs

d = 2
ell = gcd(d, 3)
prec = 100
g, profs = compute_gn(d, 2, prec)

R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

# Compute Q_1 for (1,1,0)
c = (1, 1, 0)
g_val = g[(c, 1)]
qpoch = 1 - q
Q1 = qpoch * g_val

print(f"g_{{({c}),1}} first 30 coeffs: {[g_val[i] for i in range(30)]}")
print(f"Q_1({c}) first 30 coeffs: {[Q1[i] for i in range(30)]}")

# Check if Q_1 is polynomial (all coeffs 0 after some point)
max_nonzero = max(i for i in range(prec) if Q1[i] != 0)
print(f"Last nonzero coeff of Q_1 at q^{max_nonzero}")
print(f"Q_1({c}) = {Q1.polynomial() if max_nonzero < prec - 10 else 'NOT POLYNOMIAL (within precision)'}")

# Also for (2,0,0)
c = (2, 0, 0)
g_val = g[(c, 1)]
Q1 = qpoch * g_val
max_nonzero = max((i for i in range(prec) if Q1[i] != 0), default=-1)
print(f"\nQ_1({c}) first 20 coeffs: {[Q1[i] for i in range(20)]}")
print(f"Last nonzero coeff at q^{max_nonzero}")
if max_nonzero < prec - 10:
    print(f"Q_1({c}) = {Q1.polynomial()}")
