# Analyze the structure of the G_c system more carefully
# The system is: g_{c,n} = sum_J (-1)^{|J|-1} * [z^n of (zq;q)_{|J|-1} * G_{c(J)}(zq^|J|,q)]
#
# Let's separate into "current level" (involves g_{c',n}) and "past" (involves g_{c',m} for m<n):
#
# For |J|=1: contribution = q^n * g_{c(J),n}  [current level only]
# For |J|=2: sign=-1. (zq;q)_1 = 1-zq.
#   [z^n] of -(1-zq)*G_{c(J)}(zq^2,q) = -q^{2n}*g_{c(J),n} + q*q^{2(n-1)}*g_{c(J),n-1}
#   = -q^{2n}*g_{c(J),n} + q^{2n-1}*g_{c(J),n-1}
# For |J|=3: sign=+1. (zq;q)_2 = 1 - z(q+q^2) + z^2*q^3.
#   [z^n] of (1-z(q+q^2)+z^2q^3)*G_{c(J)}(zq^3,q)
#   = q^{3n}*g_{c(J),n} - (q+q^2)*q^{3(n-1)}*g_{c(J),n-1} + q^3*q^{3(n-2)}*g_{c(J),n-2}
#
# So: g_{c,n} = sum_{J,|J|=1} q^n g_{c(J),n} 
#             - sum_{J,|J|=2} q^{2n} g_{c(J),n}
#             + sum_{J,|J|=3} q^{3n} g_{c(J),n}
#             + [past terms]
#
# The "current level" matrix is exactly A_n[c,c'] evaluated at x = q^n:
# sum_{J with c(J)=c'} (-1)^{|J|-1} (q^n)^{|J|}
# = A(q^n)[c,c']
#
# So (I - A(q^n)) * g_n = b_n [past terms]
# And (I - A(q^n))^{-1} = adj(I-A(q^n)) / det(I-A(q^n))
# = (q^n)^{EMD(c,c')} / (1 - q^{3n})
#
# Therefore: g_{c,n} = sum_{c'} q^{n*EMD(c,c')} / (1 - q^{3n}) * b_n[c']
#
# This is the KEY FORMULA. Let me verify it.

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

d = 2
profs = profiles(d)
N = len(profs)
prof_idx = {p: i for i, p in enumerate(profs)}
ell = gcd(d, 3)
prec = 50
R = PowerSeriesRing(QQ, 'q', default_prec=prec)
q = R.gen()

# Compute g using adjugate formula
g = {}
for c in profs:
    g[(c, 0)] = R(1)

for n in range(1, 4):
    # Compute b_n (past terms)
    b = {}
    for c in profs:
        ic = I_c(c)
        val = R(0)
        for size in range(1, len(ic)+1):
            for J in combinations(ic, size):
                cp = shifted_profile(c, J)
                if any(ci < 0 for ci in cp) or sum(cp) != d:
                    continue
                s = size
                sign = (-1)**(s-1)
                
                if s == 2:
                    if n >= 1:
                        val += sign * (-q**(2*n-1)) * g[(cp, n-1)]
                elif s == 3:
                    if n >= 1:
                        val += sign * (-(q + q**2)) * q**(3*(n-1)) * g[(cp, n-1)]
                    if n >= 2:
                        val += sign * q**3 * q**(3*(n-2)) * g[(cp, n-2)]
        b[c] = val
    
    # Apply adjugate formula: g_{c,n} = sum_{c'} q^{n*EMD(c,c')} / (1-q^{3n}) * b[c']
    for c in profs:
        val = R(0)
        for cp in profs:
            emd = EMD_formula(c, cp)
            val += q**(n * emd) * b[cp]
        g[(c, n)] = val / (1 - q**(3*n))

# Compute Q and check positivity
print("Adjugate formula Q values for d=2:")
for n in range(1, 4):
    qpoch = R(1)
    for i in range(n):
        qpoch *= (1 - q**(ell*(i+1)))
    
    all_pos = True
    for c in profs:
        Qval = qpoch * g[(c, n)]
        has_neg = any(Qval[i] < 0 for i in range(prec))
        if has_neg:
            all_pos = False
            print(f"  NEG: Q_{n},{c}")
    
    if all_pos:
        print(f"  Q_{n} >= 0 for all profiles")

# Show Q_1
print("\nQ_1 values:")
qpoch1 = 1 - q
for c in profs:
    Q1 = qpoch1 * g[(c, 1)]
    coeffs = [Q1[i] for i in range(10)]
    print(f"  Q_1,{c} = {coeffs}")

# Now express Q_{1,c} explicitly:
# g_{c,1} = sum_{c'} q^{EMD(c,c')} / (1-q^3) * b_1[c']
# b_1[c'] comes from |J|=2 terms: sign=-1, term = (-1)*(-q)*g_{c'(J),0} = q*1 = q
# and |J|=3 terms: sign=+1, term = -(q+q^2)*g_{c'(J),0} = -(q+q^2)
#
# More precisely, b_1[c'] = sum over J with |J|=2 that shift some c'' to c':
#   sign = -1, past term = (-1)*(-q) * g_{c'',0} = q (but wait c'' is the EQUATION profile, not c')

# Let me be more careful. b[c] is the past contribution in the EQUATION for g_{c,n}.
# For each c, the past terms come from J subsets of I_c.
# So b[c'] in the adjugate formula is the b value for profile c', not c.

# Let me trace through n=1 for c = (1,1,0):
c = (1, 1, 0)
print(f"\n=== Tracing n=1 for c={c} ===")
print(f"I_c = {I_c(c)}")

# For n=1, only |J|=2 past terms exist (|J|=3 with n=1 gives past from n=0 via (q+q^2) factor)
# Actually |J|=3 with n=1: past from n-1=0 via -(q+q^2)*q^0 * g_{c(J),0}

for cp in profs:
    ic_cp = I_c(cp)
    past = R(0)
    for size in range(1, len(ic_cp)+1):
        for J in combinations(ic_cp, size):
            cpp = shifted_profile(cp, J)
            if any(ci < 0 for ci in cpp) or sum(cpp) != d:
                continue
            s = size
            sign = (-1)**(s-1)
            if s == 2:
                past += sign * (-q) * g[(cpp, 0)]  # -1 * (-q) * 1 = q
            elif s == 3:
                past += sign * (-(q + q**2)) * g[(cpp, 0)]  # 1 * -(q+q^2) * 1
    
    emd = EMD_formula(c, cp)
    if past != 0:
        print(f"  b[{cp}] = {past.polynomial() if past != 0 else 0}, EMD({c},{cp}) = {emd}")
