# Explore Q_2 structure via the adjugate recursion
# For n=2: b_2[c'] involves g_{c',1} (via |J|=2 terms) and g_{c',0} (via |J|=3 terms)
# g_{c,2} = sum_{c''} q^{2*EMD(c,c'')} / (1-q^6) * b_2[c'']
# Q_{2,c} = (1-q)(1-q^2) * g_{c,2}

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

d = 7
profs = profiles(d)
N = len(profs)
prof_idx = {p: i for i, p in enumerate(profs)}
ell = gcd(d, 3)  # = 1
prec = 200

R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

# Compute g_{c,1} first
g = {}
for c in profs:
    g[(c, 0)] = R(1)

# n=1
b1 = {}
for cp in profs:
    ic = I_c(cp)
    val = R(0)
    for size in range(1, len(ic)+1):
        for J in combinations(ic, size):
            cpp = shifted_profile(cp, J)
            if any(ci < 0 for ci in cpp) or sum(cpp) != d:
                continue
            s = size
            sign = (-1)**(s-1)
            if s == 2:
                val += sign * (-q) * g[(cpp, 0)]
            elif s == 3:
                val += sign * (-(q + q**2)) * g[(cpp, 0)]
    b1[cp] = val

for c in profs:
    val = R(0)
    for cp in profs:
        emd = EMD_formula(c, cp)
        val += q**emd * b1[cp]
    g[(c, 1)] = val / (1 - q**3)

# n=2
b2 = {}
for cp in profs:
    ic = I_c(cp)
    val = R(0)
    for size in range(1, len(ic)+1):
        for J in combinations(ic, size):
            cpp = shifted_profile(cp, J)
            if any(ci < 0 for ci in cpp) or sum(cpp) != d:
                continue
            s = size
            sign = (-1)**(s-1)
            if s == 2:
                # past from n-1=1: sign * (-q^{2*2-1}) * g_{cpp,1} = sign * (-q^3) * g_{cpp,1}
                val += sign * (-q**3) * g[(cpp, 1)]
            elif s == 3:
                # past from n-1=1: sign * (-(q+q^2)) * q^{3*1} * g_{cpp,1}
                val += sign * (-(q + q**2)) * q**3 * g[(cpp, 1)]
                # past from n-2=0: sign * q^3 * q^{3*0} * g_{cpp,0}
                val += sign * q**3 * g[(cpp, 0)]
    b2[cp] = val

for c in profs:
    val = R(0)
    for cp in profs:
        emd = EMD_formula(c, cp)
        val += q**(2*emd) * b2[cp]
    g[(c, 2)] = val / (1 - q**6)

# Compute Q_2
qpoch2 = (1 - q) * (1 - q**2)
print("Q_2 for d=7:")
all_pos = True
for c in profs:
    Q2 = qpoch2 * g[(c, 2)]
    has_neg = any(Q2[i] < 0 for i in range(prec))
    if has_neg:
        all_pos = False
        print(f"  NEG: Q_2,{c}")

if all_pos:
    print(f"  ALL {N} profiles have Q_2 >= 0")

# Show a few Q_2 values
print("\nSample Q_2 values:")
for c in [(2,2,3), (2,3,2), (3,3,1), (7,0,0)]:
    Q2 = qpoch2 * g[(c, 2)]
    max_nz = max((i for i in range(prec) if Q2[i] != 0), default=-1)
    coeffs = [Q2[i] for i in range(min(30, max_nz+2))]
    ev = sum(Q2[i] for i in range(max_nz+1))
    print(f"  Q_2,{c}: deg={max_nz}, eval={ev}, coeffs={coeffs}")

# Check if Q_2 / (1+q+q^2) has a nice structure too
# (1-q)(1-q^2) / (1-q^6) = (1-q)(1-q^2) / ((1-q)(1+q)(1-q^2+q^4)... )
# Wait: 1-q^6 = (1-q)(1+q+q^2)(1-q+q^2)(1+q)(... no)
# 1-q^6 = (1-q^3)(1+q^3) = (1-q)(1+q+q^2)(1+q^3)
# So g_{c,2} has denom (1-q^6) and Q_2 = (1-q)(1-q^2) * g_{c,2}
# = (1-q)(1-q)(1+q) / ((1-q)(1+q+q^2)(1+q^3)) * num
# = (1-q)(1+q) / ((1+q+q^2)(1+q^3)) * num
# Hmm this is getting complicated. Let me just check the structure numerically.

print(f"\n(1-q^6) = (1-q^3)(1+q^3) = (1-q)(1+q+q^2)(1+q^3)")
print(f"Q_2 = (1-q)(1-q^2) * g_{{c,2}} where g has denom (1-q^6)")
print(f"= (1-q)^2(1+q) / (1-q^6) * numerator")
print(f"= (1-q)(1+q) / ((1+q+q^2)(1+q^3)) * numerator")
