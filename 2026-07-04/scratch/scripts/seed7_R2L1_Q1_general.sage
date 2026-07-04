# Q_1 formula for general d:
# Q_{1,c} = (1/(1+q+q^2)) * sum_{c'} q^{EMD(c,c')} * B(c')
# where B(c') = (2q-q^2) if rank(c')=3, B(c')=q if rank(c')=2, B(c')=0 if rank(c')=1
#
# Can we simplify B(c')?
# B(c') = q * (2 - q) if rank 3, q if rank 2, 0 if rank 1
# 
# Actually B(c') = q * (number of size-1 subsets of I_{c'}) 
#                 - q * (number of size-2 subsets of I_{c'}) * q^0  
#   ... let me recalculate from the definition.
#
# For n=1, b[c'] = sum_{J subset I_{c'}, |J|>=2} (-1)^{|J|-1} * past_term(J)
# |J|=2: sign = -1, past = -q * g_{c'(J),0} = -q. So contribution: (-1)(-q) = q per J.
# |J|=3: sign = +1, past = -(q+q^2) * g_{c'(J),0} = -(q+q^2). So contribution: -(q+q^2) per J.
#
# b[c'] = q * binom(|I_{c'}|, 2) - (q+q^2) * binom(|I_{c'}|, 3)
# rank 3: b = 3q - (q+q^2) = 2q - q^2 = q(2-q)
# rank 2: b = q
# rank 1: b = 0
#
# Rewrite: B(c') = q * [binom(r,2) - (1+q)*binom(r,3)]  where r = rank(c')
# For r=3: q * [3 - (1+q)] = q(2-q)
# For r=2: q * [1 - 0] = q
# For r=1: q * [0] = 0

# Let me verify this formula holds for multiple d values
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

R = PolynomialRing(QQ, 'q')
q = R.gen()

for d in [2, 4, 5, 7, 8, 10, 11, 13]:
    ell = gcd(d, 3)
    profs = profiles(d)
    
    all_pos = True
    all_divisible = True
    
    for c in profs:
        numerator = R(0)
        for cp in profs:
            r = rank(cp)
            emd = EMD_formula(c, cp)
            if r == 3:
                B = q*(2 - q)
            elif r == 2:
                B = q
            else:
                B = R(0)
            numerator += q**emd * B
        
        # Q_1 = numerator / (1+q+q^2)
        quo, rem = numerator.quo_rem(1 + q + q**2)
        if rem != 0:
            all_divisible = False
        else:
            has_neg = any(co < 0 for co in quo.coefficients())
            if has_neg:
                all_pos = False
    
    expected_eval = (d+1)*(d+2)//6 - 1 if ell == 1 else ell * (d+4)*(d-1)//6
    print(f"d={d:2d}: ell={ell}, N={len(profs):3d}, all_divisible={all_divisible}, all_pos={all_pos}, Q_1(1)={expected_eval}")
