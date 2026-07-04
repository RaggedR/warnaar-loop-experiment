# Agent C: Investigate Warnaar's k=2 bounded multisum
# 
# For k=2 (d=4, modulus 3k+2=8), Warnaar's Conjecture 1 gives:
# sum_{n1,n2>=0, m1>=0} q^{n2^2 + n1^2 - n1*m1 + m1^2 + m1 + correction} 
#   * [n1 choose n2]_q * [n1 - n2 + m2 choose m1]_q / (q)_{n1}
# = product side
#
# where m2 = 2*n2 (since k=2 in Conjecture 1).
#
# But more importantly: Warnaar PROVED k=2 using level-rank duality to
# reduce to the rank-2 bounded formula (Proposition RRcase-rank2).
#
# The rank-2 bounded formula for d=4:
# GK_{(L+b+1,L)/(1-a,0)/3}(z,q) = 1/(zq)_{2L+a+b} * sum_{n>=0} z^n q^{n(n+a)} [2L+b-n choose n]_q
#
# Via level-rank duality, rank-3 profiles with d=4 relate to rank-2 profiles.
# Level-rank duality for A_{r-1}^(1): interchanges rank r with level d.
# So rank 3, level 4 <-> rank 4, level 3? No -- that doesn't reduce.
#
# Actually: Warnaar's level-rank duality identity is:
# GK_{(c_0,c_1,c_2)}(z,q) = GK_{lambda/mu/3}(z,q) for appropriate lambda, mu
# where lambda = (c_0, c_1) shifted and the "3" is the rank.
# And by level-rank duality this equals a rank-2 GK.
#
# For k=1 (d=2): rank 3, level 2. Level-rank: rank 2, level 3.
# The rank-2, level-3 means profiles (c_0, c_1) with c_0+c_1=3.
# GK_{(2,1)}(z,q) = GK_{(a+2, 1-a)}(z,q) with a in {0,1}.
#
# For k=2 (d=4): I need to understand the duality more carefully.
# Actually, looking at the RAG output more carefully:
# 
# Warnaar's proof of k=2 uses a DIFFERENT mechanism -- a double sum involving
# the A2 invariance identity, not just level-rank duality to rank-2.

# Let me instead directly verify the multisum formulas from Corteel-Dousse-Uncu
# for d=5 (modulus 8).

# CDU Theorem for d=5: They give 7 identities. Let me check the simplest.
# For profile c = (2,2,1), the CDU paper gives a quadruple sum formula.

# Instead of trying to reproduce the exact CDU formulas (which I don't have
# the precise form of), let me take a computational approach:
# Extract Q_n from the BOUNDED GF directly and see if I can find the multisum pattern.

# Key insight from Warnaar's paper:
# For BOUNDED case, GK_{lambda/mu/d;n}(q) is a FINITE sum.
# The bounded GF is GK(z,q) = sum_{n>=0} z^n * GK_{..;n}(q).
# 
# Q_n = (q;q)_n * [z^n] ((zq;q)_inf * GK(z,q))
# 
# For k=1 (d=2), this gives Q_n = q^{n^2} or q^{n(n+1)}.
# 
# For k=2 (d=4), Q_n should be a DOUBLE SUM with manifest positivity.

# Let me compute Q_n for d=4 and see if I can decompose it as a double sum
# in q-binomial coefficients times q-powers.

R.<q> = PowerSeriesRing(QQ, default_prec=120)

def qfact(n, q=q):
    if n < 0:
        return R(0)
    return prod(1 - q^i for i in range(1, n+1)) if n > 0 else R(1)

def qbinom(n, k, q=q):
    if k < 0 or k > n or n < 0:
        return R(0)
    return qfact(n) / (qfact(k) * qfact(n-k))

# First verify: for d=2, c=(1,1,0), the multisum gives Q_n = q^{n^2}
print("Verification for d=2, c=(1,1,0):")
for n in range(5):
    # H(z,q) = sum_m z^m q^{m^2} / (q)_m
    # Q_n = (q;q)_n * q^{n^2} / (q;q)_n = q^{n^2}
    Qn = q^(n^2)
    print(f"  Q_{n} = q^{n^2} = {Qn.truncate(30)}")

print()
print("Now computing Q_n for d=4 using transfer matrix approach...")
print("Looking for multisum decomposition of Q_1 and Q_2.")
print()

# Build CW system for d=4 manually
# Compositions of 4 into 3 parts:
comps4 = [(a,b,4-a-b) for a in range(5) for b in range(5-a)]
print(f"Number of compositions of 4 into 3 parts: {len(comps4)}")
print(f"Compositions: {comps4}")
print()

# I need g_m(c) for each composition c and each m.
# g_0(c) = 1 for all c.
# g_m(c) = sum over nonempty J subset I_c: (-1)^{|J|-1} q^{m|J|} g_{m-1}(c(J))

def shift_profile(c, J):
    """Compute the shifted profile c(J) for J subset of I_c."""
    c_new = list(c)
    J_set = set(J)
    for i in range(3):
        i_prev = (i - 1) % 3
        if i in J_set and i_prev not in J_set:
            c_new[i] -= 1
        elif i not in J_set and i_prev in J_set:
            c_new[i] += 1
    return tuple(c_new)

def compute_g_vectors(d, m_max, prec=120):
    """Compute g_m(c) for all compositions c of d and m from 0 to m_max."""
    comps = [(a,b,d-a-b) for a in range(d+1) for b in range(d+1-a)]
    comp_to_idx = {c: i for i, c in enumerate(comps)}
    N = len(comps)
    
    R2 = PowerSeriesRing(QQ, 'q', default_prec=prec)
    q2 = R2.gen()
    
    g = [[R2(0)]*N for _ in range(m_max+1)]
    
    # g_0 = 1 for all
    for i in range(N):
        g[0][i] = R2(1)
    
    for m in range(1, m_max+1):
        for idx, c in enumerate(comps):
            I_c = [i for i in range(3) if c[i] > 0]
            if not I_c:
                g[m][idx] = R2(0)
                continue
            
            val = R2(0)
            from itertools import combinations
            for r in range(1, len(I_c)+1):
                for J in combinations(I_c, r):
                    c_new = shift_profile(c, J)
                    if any(ci < 0 for ci in c_new) or sum(c_new) != d:
                        continue
                    if c_new not in comp_to_idx:
                        continue
                    jdx = comp_to_idx[c_new]
                    sign = (-1)**(r - 1)
                    val += sign * q2^(m*r) * g[m-1][jdx]
            
            g[m][idx] = val
    
    return g, comps, comp_to_idx

# Compute for d=4
g4, comps4, c2i4 = compute_g_vectors(4, 5, prec=120)

print("g_m for d=4, selected profiles:")
for c in [(2,1,1), (1,2,1), (3,1,0), (4,0,0)]:
    if c not in c2i4:
        continue
    idx = c2i4[c]
    for m in range(4):
        gm = g4[m][idx]
        print(f"  g_{m}({c}) = {gm.truncate(20)} + ...")

print()
print("Computing Q_n for d=4:")
for c in [(2,1,1), (1,2,1), (3,1,0), (4,0,0), (2,2,0), (1,1,2)]:
    if c not in c2i4:
        continue
    idx = c2i4[c]
    
    for n in range(1, 4):
        # Q_n = (q;q)_n * sum_{m=0}^n a_{n-m} * g_m(c)
        # a_k = (-1)^k * q^{k(k+1)/2} / (q;q)_k
        q_s = q
        qfact_n = prod(1 - q_s^i for i in range(1, n+1))
        
        Qn = R(0)
        for m in range(n+1):
            k = n - m
            qfact_k = prod(1 - q_s^i for i in range(1, k+1)) if k > 0 else R(1)
            a_k = (-1)^k * q_s^(k*(k+1)//2) / qfact_k
            gm = R(g4[m][idx])
            Qn += a_k * gm
        
        Qn = qfact_n * Qn
        Qn_poly = Qn.truncate(80)
        
        # Extract polynomial coefficients
        coeffs = [Qn_poly[i] for i in range(80)]
        max_deg = max((i for i in range(80) if coeffs[i] != 0), default=0)
        poly_coeffs = coeffs[:max_deg+1]
        is_nonneg = all(c >= 0 for c in poly_coeffs)
        
        print(f"  Q_{n}({c}): deg={max_deg}, nonneg={is_nonneg}, Q(1)={sum(poly_coeffs)}")
        if max_deg <= 40:
            print(f"    coeffs = {poly_coeffs}")

