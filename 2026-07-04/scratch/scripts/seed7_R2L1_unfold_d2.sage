# Unfold the recursion for d=2 to understand why Q_n = q^{n^2} for c=(1,1,0)
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
print("Profiles:", profs)
print("EMD table:")
for c in profs:
    emds = [EMD_formula(c, cp) for cp in profs]
    print(f"  {c}: {emds}")

# For d=2, rank-1 profiles: (2,0,0), (0,2,0), (0,0,2)
# rank-2: (1,1,0), (1,0,1), (0,1,1)
# rank-3: none!

print("\nRanks:", [sum(1 for ci in c if ci > 0) for c in profs])

# So for d=2, there are NO rank-3 profiles! B(c') = q for rank 2, 0 for rank 1.
# Q_{1,c} = (1/(1+q+q^2)) * sum_{c' rank 2} q^{EMD(c,c')+1}

# For c=(1,1,0):
# rank-2 profiles: (0,1,1) EMD=2, (1,0,1) EMD=1, (1,1,0) EMD=0
# numerator = q * (q^2 + q + 1) = q * (1+q+q^2)
# Q_1 = q. Check!

# For c=(2,0,0):
# rank-2 profiles: (0,1,1) EMD=3, (1,0,1) EMD=2, (1,1,0) EMD=1
# numerator = q * (q^3 + q^2 + q) = q^2 * (1+q+q^2)
# Q_1 = q^2. Check!

print("\nFor c=(1,1,0):")
print("  rank-2 neighbors and EMDs:")
for cp in profs:
    if sum(1 for ci in cp if ci > 0) == 2:
        print(f"    {cp}: EMD = {EMD_formula((1,1,0), cp)}")

print("\nFor c=(2,0,0):")
for cp in profs:
    if sum(1 for ci in cp if ci > 0) == 2:
        print(f"    {cp}: EMD = {EMD_formula((2,0,0), cp)}")

# Now trace n=2 for d=2, c=(1,1,0): Q_2 should be q^4.
# g_{c,2} = (1/(1-q^6)) * sum_{c'} q^{2*EMD(c,c')} * b_2(c')
# b_2(c') involves g_{c'',1} from |J|=2 terms.
# For d=2, max |J| = 2 (no rank-3), so no |J|=3 terms.

# b_2(c') = sum_{J subset I_{c'}, |J|=2} (-1) * (-q^3) * g_{c'(J), 1}
#          = sum_{J, |J|=2} q^3 * g_{c'(J), 1}

# For rank 2 c': one J of size 2, c'(J) = some profile.
# For rank 1 c': no J of size >= 2, so b_2 = 0.

R = PowerSeriesRing(QQ, 'q', default_prec=50)
q = R.gen()

# Compute g_{c,1} explicitly for d=2
g1 = {}
for c in profs:
    val = R(0)
    for cp in profs:
        r = sum(1 for ci in cp if ci > 0)
        emd = EMD_formula(c, cp)
        if r == 2:
            val += q**(emd + 1)
    g1[c] = val / (1 - q**3)

print("\ng_{c,1} for d=2:")
for c in profs:
    print(f"  g_1({c}) = {g1[c]}")

# Compute b_2(c')
b2 = {}
for cp in profs:
    ic = I_c(cp)
    val = R(0)
    for J in combinations(ic, 2):
        cpp = shifted_profile(cp, J)
        if any(ci < 0 for ci in cpp) or sum(cpp) != d:
            continue
        # |J|=2, sign=-1, past = -q^{2*2-1} * g_{cpp,1} = -q^3 * g_1[cpp]
        val += (-1) * (-q**3) * g1[cpp]
    b2[cp] = val

print("\nb_2(c') for d=2:")
for cp in profs:
    if b2[cp] != 0:
        print(f"  b_2({cp}) = {b2[cp]}")

# g_{c,2} = (1/(1-q^6)) * sum_{c'} q^{2*EMD(c,c')} * b_2(c')
g2 = {}
for c in profs:
    val = R(0)
    for cp in profs:
        emd = EMD_formula(c, cp)
        val += q**(2*emd) * b2[cp]
    g2[c] = val / (1 - q**6)

# Q_2 = (1-q)(1-q^2) * g_2
print("\nQ_2 for d=2:")
for c in profs:
    Q2 = (1-q)*(1-q**2) * g2[c]
    max_nz = max((i for i in range(50) if Q2[i] != 0), default=-1)
    print(f"  Q_2({c}) = q^{max_nz} (single monomial? {all(Q2[i] == 0 for i in range(50) if i != max_nz)})")

# Let me trace the algebra for c=(1,1,0):
# rank-2 c' with nonzero b_2:
print("\n=== Tracing c=(1,1,0) for n=2 ===")
c = (1,1,0)
for cp in profs:
    if b2[cp] == 0:
        continue
    emd = EMD_formula(c, cp)
    ic = I_c(cp)
    # What is c'(J) for |J|=2?
    for J in combinations(ic, 2):
        cpp = shifted_profile(cp, J)
        if any(ci < 0 for ci in cpp) or sum(cpp) != d:
            continue
        print(f"  c'={cp}, J={J}, c'(J)={cpp}, g_1(c'(J))={g1[cpp]}")
        print(f"    b_2(c')=q^3 * g_1({cpp})")
        print(f"    contribution to g_2({c}): q^{2*emd} * q^3 * g_1({cpp}) / (1-q^6)")
