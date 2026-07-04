# Same as before but handle output properly
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

d = 2
profs = profiles(d)
prec = 50
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

n_max = 2
F = {}
for c in profs:
    F[(c, 0)] = R(1)

for n in range(1, n_max + 1):
    N = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    
    A = matrix(R, N, N)
    for i, c in enumerate(profs):
        ic = I_c(c)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    j = prof_idx[cp]
                    A[i, j] += (-1)**(size-1) * q**(size*n)
    
    b = vector(R, N)
    for i, c in enumerate(profs):
        ic = I_c(c)
        val = R(0)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    S_cp = sum(F[(cp, m)] for m in range(n))
                    val += (-1)**(size-1) * q**(size*n) * S_cp
        b[i] = val
    
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    M = I_mat - A
    F_n = M.solve_right(b)
    
    for i, c in enumerate(profs):
        F[(c, n)] = F_n[i]

# Output
print("CW recurrence F_{c,n} for d=2:")
for c in [(1,1,0), (2,0,0)]:
    for n in range(n_max + 1):
        v = F[(c,n)]
        print(f"  F_{{{c},{n}}} = {v}")
    print()

# Compare F_{(1,1,0),1} with brute force value
bf = R([1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1])  # coefficients from brute force
print(f"Brute force F_{{(1,1,0),1}} = {bf}")
print(f"CW F_{{(1,1,0),1}} = {F[((1,1,0), 1)]}")
print(f"Match: {F[((1,1,0), 1)] == bf}")
