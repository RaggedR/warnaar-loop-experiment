# Implement CW recurrence directly to compute F_{c,n}
# CW says: F_c(y,q) = sum_{J != empty, J subset I_c} (-1)^{|J|-1} F_{c(J)}(yq^|J|, q) / (1-yq^|J|)
#
# Write F_c(y,q) = sum_{m>=0} F_{c,m}(q) y^m. Then:
# sum_m F_{c,m} y^m = sum_J (-1)^{|J|-1} / (1-yq^|J|) * sum_m F_{c(J),m} (yq^|J|)^m
#
# RHS = sum_J (-1)^{|J|-1} * sum_m F_{c(J),m} * sum_{n>=m} y^n * q^{|J|*(m + ... + n)}
# 
# Wait, let me expand 1/(1-yq^s) * sum_m F_{c(J),m} (yq^s)^m:
# = sum_m F_{c(J),m} q^{s*m} * y^m / (1 - yq^s)
# = sum_m F_{c(J),m} q^{s*m} * y^m * sum_{j>=0} (yq^s)^j
# = sum_m F_{c(J),m} * sum_{j>=0} q^{s*(m+j)} * y^{m+j}
# 
# Setting n = m+j:
# = sum_{n>=0} y^n * sum_{m=0}^n F_{c(J),m} * q^{s*n}    where s = |J|
# Wait: q^{s*(m+j)} = q^{s*m} * q^{s*j} and n = m+j, so q^{s*n} = q^{s*(m+j)}.
# No: q^{s*m} * (yq^s)^j = q^{s*m} * y^j * q^{s*j} = y^j * q^{s*(m+j)}.
# So after n = m+j:
# = sum_{n>=0} y^n * q^{s*n} * sum_{m=0}^n F_{c(J),m}  ... no, that's wrong too.
#
# Let me redo: 1/(1-yq^s) * sum_m F_{c(J),m} (yq^s)^m
# = sum_m F_{c(J),m} * y^m * q^{s*m} * 1/(1-yq^s)
# = sum_m F_{c(J),m} * y^m * q^{s*m} * sum_{j>=0} y^j * q^{s*j}
# = sum_{m,j>=0} F_{c(J),m} * q^{s*(m+j)} * y^{m+j}
# = sum_{n>=0} y^n * sum_{m=0}^n F_{c(J),m} * q^{s*n}
# 
# Hmm that gives [y^n] = q^{s*n} * sum_{m=0}^n F_{c(J),m}. But this can't be right
# because the coefficient should depend on m. Let me redo more carefully.
#
# sum_{m>=0} F_{c(J),m} * (yq^s)^m / (1-yq^s)
# = sum_{m>=0} F_{c(J),m} * (yq^s)^m * sum_{j>=0} (yq^s)^j
# = sum_{m>=0} sum_{j>=0} F_{c(J),m} * (yq^s)^{m+j}
# = sum_{n>=0} (yq^s)^n * sum_{m=0}^n F_{c(J),m}
# = sum_{n>=0} y^n * q^{s*n} * sum_{m=0}^n F_{c(J),m}
#
# So [y^n] of RHS = sum_J (-1)^{|J|-1} * q^{|J|*n} * sum_{m=0}^n F_{c(J),m}
#
# This gives: F_{c,n} = sum_J (-1)^{|J|-1} * q^{|J|*n} * sum_{m=0}^n F_{c(J),m}
#
# Let S_{c,n} = sum_{m=0}^n F_{c,m}. Then F_{c,n} = S_{c,n} - S_{c,n-1}.
# And the equation becomes:
# S_{c,n} - S_{c,n-1} = sum_J (-1)^{|J|-1} * q^{|J|*n} * S_{c(J),n}

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

# Compute F_{c,n} using the derived recurrence:
# F_{c,n} = sum_J (-1)^{|J|-1} * q^{|J|*n} * sum_{m=0}^n F_{c(J),m}
# with F_{c,0} = 1 for all c.

n_max = 3
F = {}
for c in profs:
    F[(c, 0)] = R(1)

for n in range(1, n_max + 1):
    # We need sum_{m=0}^n F_{c(J),m}, but F_{c(J),n} is what we're computing!
    # So the equation is:
    # F_{c,n} = sum_J (-1)^{|J|-1} * q^{|J|*n} * (sum_{m=0}^{n-1} F_{c(J),m} + F_{c(J),n})
    # This is a LINEAR SYSTEM in the unknowns F_{c,n}:
    # F_{c,n} - sum_J (-1)^{|J|-1} * q^{|J|*n} * F_{c(J),n} = sum_J (-1)^{|J|-1} * q^{|J|*n} * sum_{m=0}^{n-1} F_{c(J),m}
    
    # This is exactly (I - A(q^n)) * vec(F_{.,n}) = b_n
    # where A(x)[c,c'] = sum over J with c(J)=c' of (-1)^{|J|-1} * x^{|J|}
    # and b_n[c] = sum_J (-1)^{|J|-1} * q^{|J|*n} * sum_{m=0}^{n-1} F_{c(J),m}
    
    N = len(profs)
    prof_idx = {p: i for i, p in enumerate(profs)}
    
    # Build A(q^n)
    A = matrix(R, N, N)
    for i, c in enumerate(profs):
        ic = I_c(c)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if all(ci >= 0 for ci in cp) and sum(cp) == d:
                    j = prof_idx[cp]
                    A[i, j] += (-1)**(size-1) * q**(size*n)
    
    # Build RHS
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
    
    # Solve (I - A) * F_n = b
    I_mat = matrix(R, N, N, lambda i,j: R(1) if i==j else R(0))
    M = I_mat - A
    F_n = M.solve_right(b)
    
    for i, c in enumerate(profs):
        F[(c, n)] = F_n[i]

# Compare with brute force
print("CW recurrence F_{c,n} for d=2:")
for c in [(1,1,0), (2,0,0), (0,1,1)]:
    for n in range(3):
        poly = F[(c,n)]
        # Truncate to show as polynomial
        p = poly.polynomial()
        print(f"  F_{{{c},{n}}} = {p}")
    print()
