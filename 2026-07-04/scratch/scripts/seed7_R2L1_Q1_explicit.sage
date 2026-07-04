# Derive explicit Q_1 formula for general d
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

# For n=1, b[c'] depends only on rank(c'):
# rank 3: b = 2q - q^2 (but need to account for shifts being valid!)
# rank 2: b = q
# rank 1: b = 0

# Wait, I need to check that c'(J) is valid (all components >= 0)
# For |J|=2 and c' with rank 2, say c' = (a,b,0), I_{c'} = {0,1}, J = {0,1}
# c'(J): i=0: 0 in J, prev=2 not in J -> c'_0 - 1 = a-1
#         i=1: 1 in J, prev=0 in J -> c'_1 unchanged = b
#         i=2: 2 not in J, prev=1 in J -> c'_2 + 1 = 1
# Result: (a-1, b, 1). Valid iff a >= 1, which is true since a > 0 for rank >= 2.

# For |J|=3, c' must have rank 3, J = {0,1,2}.
# c'({0,1,2}): all i in J and all prev in J, so c'(J) = c'. Valid.

# For |J|=2 and c' with rank 3, J can be {0,1}, {1,2}, {0,2}.
# Each shifts in a specific direction. All c'(J) valid since all c'_i > 0.

# So the formula is correct:
# b[c'] = q * binom(rank(c'), 2) - (q+q^2) * binom(rank(c'), 3)

# For rank 3: b = 3q - (q+q^2) = 2q - q^2
# For rank 2: b = q
# For rank 1: b = 0

# Then: g_{c,1} = (1/(1-q^3)) * [sum_{c' rank 3} q^{EMD(c,c')} (2q-q^2) + sum_{c' rank 2} q^{EMD(c,c')} * q]
# Q_{1,c} = ((1-q)/(1-q^3)) * [sum above]
#         = (1/(1+q+q^2)) * [sum above]

# For d=7:
d = 7
profs = profiles(d)
R = PolynomialRing(QQ, 'q')
q = R.gen()

# Verify for a specific profile
c = (2, 3, 2)  # rank 3
print(f"=== Q_1 for c={c}, d={d} ===")

numerator = R(0)
for cp in profs:
    r = rank(cp)
    emd = EMD_formula(c, cp)
    if r == 3:
        b_val = 2*q - q**2
    elif r == 2:
        b_val = q
    else:
        b_val = R(0)
    
    if b_val != 0:
        numerator += q**emd * b_val

# Q_1 = numerator / (1+q+q^2)
# Check if divisible
quo, rem = numerator.quo_rem(1 + q + q**2)
print(f"Numerator: {numerator}")
print(f"Divisible by (1+q+q^2): {rem == 0}")
if rem == 0:
    print(f"Q_1,{c} = {quo}")
    print(f"Q_1,{c}(1) = {quo(1)}")

# Do for all profiles
print(f"\nAll Q_1 for d={d}:")
all_pos = True
for c in profs:
    numerator = R(0)
    for cp in profs:
        r = rank(cp)
        emd = EMD_formula(c, cp)
        if r == 3:
            b_val = 2*q - q**2
        elif r == 2:
            b_val = q
        else:
            b_val = R(0)
        if b_val != 0:
            numerator += q**emd * b_val
    
    quo, rem = numerator.quo_rem(1 + q + q**2)
    has_neg = any(co < 0 for co in quo.coefficients())
    if has_neg:
        all_pos = False
    if rem != 0:
        print(f"  ERROR: Q_1,{c} not divisible by 1+q+q^2! rem = {rem}")
    else:
        deg = quo.degree()
        ev = quo(1)
        print(f"  Q_1,{c} = {quo}, deg={deg}, eval={ev}{' [NEG!]' if has_neg else ''}")

print(f"\nAll Q_1 nonneg: {all_pos}")
