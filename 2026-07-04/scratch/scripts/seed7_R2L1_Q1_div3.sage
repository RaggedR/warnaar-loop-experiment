# Check d divisible by 3 with ell = gcd(d,3) = 3
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

for d in [3, 6, 9]:
    ell = gcd(d, 3)  # = 3
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
        
        # For ell=3: Q_1 = (1-q^3) * g_{c,1} = (1-q^3)/(1-q^3) * numerator = numerator
        # Wait: g_{c,1} = (1/(1-q^3)) * sum q^{EMD} B(c'), and Q_1 = (q^3;q^3)_1 * g = (1-q^3) * g = numerator
        # So Q_1 = numerator directly! No division needed.
        
        Q1 = numerator
        has_neg = any(co < 0 for co in Q1.coefficients()) if Q1 != 0 else False
        if has_neg:
            all_pos = False
    
    print(f"d={d}: ell={ell}, N={len(profs)}, all_pos={all_pos}")
    # Show a sample
    c_sample = profs[len(profs)//2]
    numerator = R(0)
    for cp in profs:
        r = rank(cp)
        emd = EMD_formula(c_sample, cp)
        if r == 3:
            B = q*(2 - q)
        elif r == 2:
            B = q
        else:
            B = R(0)
        numerator += q**emd * B
    print(f"  Q_1,{c_sample} = {numerator}, eval(1) = {numerator(1)}")
