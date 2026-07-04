# Compute Q_{n,c}(q) for d=7 using the G_c system (CW for normalized GF)
# G_c(z,q) = sum_J (-1)^{|J|-1} (zq;q)_{|J|-1} G_{c(J)}(zq^{|J|}, q)
# g_{c,n} = [z^n] G_c(z,q)
# Q_{n,c} = (q^ell;q^ell)_n * g_{c,n}

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

def compute_Qn(d, n_max, prec):
    """Compute Q_{n,c} for all profiles c, n = 0..n_max."""
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
        print(f"  Computing n={n}...")
        
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
                    s = size
                    sign = (-1)**(s-1)
                    
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
    
    # Compute Q_{n,c} = (q^ell;q^ell)_n * g_{c,n}
    Q = {}
    for n in range(0, n_max + 1):
        qpoch = R(1)
        for i in range(n):
            qpoch *= (1 - q**(ell*(i+1)))
        for c in profs:
            Q[(c, n)] = qpoch * g[(c, n)]
    
    return Q, profs

# First test with d=2
print("=== d=2 ===")
prec_d2 = 50
Q2, profs2 = compute_Qn(2, 3, prec_d2)

R = PowerSeriesRing(QQ, 'q', default_prec=prec_d2)
q = R.gen()

for n in range(1, 4):
    all_pos = True
    for c in profs2:
        Qval = Q2[(c, n)]
        has_neg = any(Qval[i] < 0 for i in range(prec_d2))
        if has_neg:
            all_pos = False
            print(f"  Q_{n},{c} has neg coefficients: {[Qval[i] for i in range(20)]}")
    if all_pos:
        print(f"  Q_{n} >= 0 for all profiles (d=2)")

# Show Q_1 for all d=2 profiles
print("\nQ_1 for d=2:")
for c in profs2:
    Qval = Q2[(c, 1)]
    print(f"  Q_1,{c} first 10 coeffs: {[Qval[i] for i in range(10)]}")

# Now d=7
print("\n=== d=7 ===")
# Precision guideline from synthesis: >= 6*max(k,m)^2 + 50
# For n=2: 6*4 + 50 = 74, but let's be generous
prec_d7 = 150
Q7, profs7 = compute_Qn(7, 2, prec_d7)

R7 = PowerSeriesRing(QQ, 'q', default_prec=prec_d7)
q7 = R7.gen()

for n in range(1, 3):
    neg_profiles = []
    for c in profs7:
        Qval = Q7[(c, n)]
        has_neg = any(Qval[i] < 0 for i in range(prec_d7))
        if has_neg:
            neg_profiles.append(c)
    if not neg_profiles:
        print(f"  Q_{n} >= 0 for ALL {len(profs7)} profiles (d=7) to O(q^{prec_d7})")
    else:
        print(f"  Q_{n} has negatives for {len(neg_profiles)} profiles: {neg_profiles[:5]}")

# Show some Q_1 values for d=7
print("\nSample Q_1 for d=7:")
for c in [(1,1,5), (2,2,3), (2,3,2), (3,3,1), (1,3,3), (7,0,0), (0,0,7)]:
    if c in [p for p in profs7]:
        Qval = Q7[(c, 1)]
        coeffs = [Qval[i] for i in range(30)]
        # Find last nonzero
        last_nz = max((i for i in range(prec_d7) if Qval[i] != 0), default=-1)
        print(f"  Q_1,{c} = {coeffs[:min(20, last_nz+2)]}, deg={last_nz}, eval(1)={sum(Qval[i] for i in range(last_nz+1))}")
