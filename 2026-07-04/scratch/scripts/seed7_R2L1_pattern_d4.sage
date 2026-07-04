# Q_n for d=4 - look for structure
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

def compute_Qn_all(d, n_max, prec):
    profs = profiles(d)
    N = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    ell = gcd(d, 3)
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    g = {}
    for c in profs:
        g[(c, 0)] = R(1)
    
    for n in range(1, n_max + 1):
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
                    s = size; sign = (-1)**(s-1)
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
    
    Q = {}
    for n in range(1, n_max+1):
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(ell*(i+1)))
        for c in profs:
            Q[(c, n)] = qpoch * g[(c, n)]
    return Q, profs

# d=4
d = 4
prec = 200
Q, profs = compute_Qn_all(d, 3, prec)
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

print(f"Q_n for d={d}:")
for c in profs:
    line = f"  c={c}:"
    for n in range(1, 4):
        Qval = Q[(c, n)]
        max_nz = max((i for i in range(prec) if Qval[i] != 0), default=-1)
        coeffs = [Qval[i] for i in range(min(25, max_nz+2))]
        line += f" n={n}: {coeffs};"
    print(line)
