# Debug rank-1 profiles: check Q_{n,(d,0,0)} and understand the issue
from itertools import combinations

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d-c0+1):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def EMD_formula(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def compute_Fcn_and_Qn(d, n_max, prec):
    profs = profiles(d)
    ell = gcd(d, 3)
    R = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q = R.gen()
    
    F = {(c, 0): R(1) for c in profs}
    for n in range(1, n_max + 1):
        denom = R(1) / (1 - q**(3*n))
        for c in profs:
            val = R(0)
            for cp in profs:
                emd = EMD_formula(c, cp)
                val += q**(n * emd) * F[(cp, n-1)]
            F[(c, n)] = val * denom
    
    Q = {}
    for n in range(1, n_max + 1):
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(ell*(i+1)))
        for c in profs:
            coeff_sum = R(0)
            for j in range(n+1):
                sign = (-1)**j
                qpower = j*(j+1)//2
                qfact = R(1)
                for i in range(1, j+1):
                    qfact *= (1 - q**i)
                coeff_sum += sign * q**qpower / qfact * F[(c, n-j)]
            Q[(c, n)] = qpoch * coeff_sum
    
    return F, Q, profs, R

# For d=4
d = 4
ell = gcd(d, 3)
prec = 50
F, Q, profs, R = compute_Fcn_and_Qn(d, 2, prec)
q = R.gen()

c_rank1 = (4, 0, 0)
print(f"d={d}, ell={ell}")
print(f"F_{{(4,0,0),0}} = {F[(c_rank1, 0)]}")
print(f"F_{{(4,0,0),1}} = {F[(c_rank1, 1)].polynomial()}")
print(f"Q_1,{c_rank1} = {Q[(c_rank1, 1)].polynomial()}")
print(f"Q_1,{c_rank1}(1) = {Q[(c_rank1, 1)].polynomial()(1)}")
expected = (d+1)*(d+2)//6 - 1
print(f"Expected Q_1(1) = {expected}")

# For d=7
d = 7
ell = gcd(d, 3)
prec = 80
F, Q, profs, R = compute_Fcn_and_Qn(d, 1, prec)
q = R.gen()

c_rank1 = (7, 0, 0)
print(f"\nd={d}, ell={ell}")
print(f"F_{{(7,0,0),1}} first 20 terms: {F[(c_rank1, 1)].polynomial().truncate(20)}")
print(f"Q_1,{c_rank1} = {Q[(c_rank1, 1)].polynomial()}")
print(f"Q_1,{c_rank1}(1) = {Q[(c_rank1, 1)].polynomial()(1)}")
expected = (d+1)*(d+2)//6 - 1
print(f"Expected Q_1(1) = {expected}")

# What's the EMD from (d,0,0) to other profiles?
print(f"\nEMD from (7,0,0) to all profiles:")
for cp in profs:
    emd = EMD_formula((7,0,0), cp)
    if emd <= 3:
        print(f"  EMD((7,0,0), {cp}) = {emd}")

# Check: is the negative coefficient at q^1 just -1?
print(f"\nQ_1,(7,0,0) coefficients: {Q[((7,0,0), 1)].padded_list(20)}")
print(f"Q_1,(0,7,0) coefficients: {Q[((0,7,0), 1)].padded_list(20)}")

# Also check what the CW system gives for (d,0,0): I_c = {0} only
# So J can only be {0}
# c({0}) = (c0-1, c1+1, c2) = (d-1, 1, 0)
c = (7, 0, 0)
J = (0,)
from itertools import combinations
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

cp = shifted_profile(c, J)
print(f"\n(7,0,0) shifts to: {cp}")
print(f"This is the only shift for I_c = {{0}}")
print(f"CW says: F_{{(7,0,0)}}(y,q) = F_{{{cp}}}(yq,q) / (1-yq)")
