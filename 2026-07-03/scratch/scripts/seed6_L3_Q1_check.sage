"""
Check Q_1 for c=(2,0,0), d=2 more carefully.
"""

from sage.all import *

def compute_Q1(c, q_prec=30):
    c0, c1, c2 = c
    d = c0 + c1 + c2
    l = gcd(d, 3)
    
    R = PowerSeriesRing(QQ, 'q', default_prec=q_prec)
    q = R.gen()
    
    # F_{c,1}: count binary cylindric partitions
    F1 = R(1)
    for w in range(1, q_prec):
        count = 0
        for L1 in range(w+1):
            for L2 in range(w+1-L1):
                L3 = w - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    count += 1
        F1 += count * q**w
    
    # [z^1]((zq;q)_inf * F(z,q)) = F_{c,1} + [z^1](zq;q)_inf * 1
    # [z^1](zq;q)_inf = -q/(1-q) as a power series
    coeff_z1 = sum(-q**(j+1) for j in range(q_prec - 1))
    bracket = F1 + coeff_z1
    
    # Q_1 = (q^l;q^l)_1 * bracket = (1-q^l) * bracket
    Q1 = ((1 - q**l) * bracket).add_bigoh(q_prec)
    return Q1

# Check c=(2,0,0) more carefully
c = (2, 0, 0)
Q1 = compute_Q1(c)
print(f"c=(2,0,0), d=2, l=gcd(2,3)=1:")
print(f"Q_1 = {Q1}")

# Check: what are the a_w values?
print("\nBinary CP counts a_w for c=(2,0,0):")
for w in range(10):
    count = 0
    pts = []
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= 0 and L3 - L2 <= 0 and L1 - L3 <= 2:
                count += 1
                pts.append((L1, L2, L3))
    print(f"  a_{w} = {count}: {pts}")

# With c1=0 and c2=0: L2 <= L1, L3 <= L2, L1 <= L3+2.
# So L1 >= L2 >= L3 and L1 <= L3 + 2.
# For w=0: (0,0,0) -> 1
# For w=1: (1,0,0) -> L2 <= L1 OK, L3 <= L2 OK, L1 <= L3+2 = 2 OK. Count 1.
# For w=2: (2,0,0) -> L1 <= 0+2 = 2 OK. (1,1,0) -> L1 <= 0+2 OK. Count 2.
#          Wait: (0,0,2) -> L2 <= 0 OK, L3 <= 0 FAIL (L3=2). 
# Actually a_2 = 2: {(2,0,0), (1,1,0)}.
# So sequence is 1, 1, 2, 2, 3, 3, 4, 4, ...

# That's NOT monotonically increasing: a_1 = 1 = a_0. 
# And a_1 - a_0 = 0, so [q^1]Q_1 = 0 - 1 = -1. That's the problem!

# Wait, but a_0 is the "empty" partition which gives the 1 in F_{c,1}.
# Let me reconsider. The formula Q_1 = (1-q^l)(F_{c,1} + [z^1](zq;q)_inf)
# = (1-q)(F_{c,1} - q/(1-q))
# = (1-q)*F_{c,1} - q.

# F_{c,1} = 1 + q + 2q^2 + 2q^3 + 3q^4 + ...
# (1-q)*F_{c,1} = 1 + 0*q + q^2 + 0*q^3 + q^4 + 0*q^5 + ...
# Q_1 = 1 + 0q + q^2 + 0q^3 + ... - q = 1 - q + q^2

# So Q_1 = 1 - q + q^2. This has Q_1(1) = 1 = (3*4/6 - 1)^1 = 1. Correct.
# But [q^1]Q_1 = -1. NEGATIVE.

# So c=(2,0,0) IS a counterexample to Q_1 >= 0 for d=2??
# Let me check what Warnaar's paper says about this.

# Actually, the conjecture says "c = (c_0, c_1, c_2) with d not equiv 0 mod 3".
# It doesn't restrict c_i to be positive. So this IS within scope.

# But Warnaar proved the conjecture for d=2. Let me re-read the definition more carefully.

# From conjecture.tex, Definition:
# Q_{n,c}(q) = (q^l;q^l)_n * [z^n]((zq)_inf * GK_c(z,q))
# where l = gcd(d, r).

# Wait -- what is r? The definition says c = (c_0, ..., c_{r-1}), and r is the 
# NUMBER of parts in the composition. For k=3 (the conjecture), we have r = 3.
# So l = gcd(d, 3).

# For d=2: l = gcd(2, 3) = 1.
# Q_1 = (q;q)_1 * [z^1]((zq)_inf * GK_c(z,q))
# = (1-q) * [z^1]((zq)_inf * F_c(z,q))

# Hmm wait. The notation "(zq)_inf" in the definition -- is this (zq;q)_inf?
# Let me look at the exact LaTeX.

# From conjecture.tex line 93:
# Q_{n,c}(q) := (q^\ell;q^\ell)_n \cdot [z^n]\Big((zq)_\infty \cdot \operatorname{GK}_c(z,q)\Big)

# And the notation section says:
# (a;q)_n = prod_{i=0}^{n-1} (1-aq^i)
# (a;q)_inf = prod_{i=0}^{inf} (1-aq^i)

# So (zq)_inf is shorthand for (zq;?)_inf. What's the base?
# Looking at the context: "(zq)_\infty" probably means (zq;q)_inf.
# That's the standard convention when the base matches the variable.

# Let me also check: does this produce a polynomial?
# For d=2, c=(2,0,0), n=1:
# F_c(z,q) = sum_n F_{c,n}(q) z^n
# (zq;q)_inf = prod_{j>=0}(1-zq^{j+1})

# Hmm, actually maybe (zq)_inf means just the Pochhammer symbol with an 
# implied base q. That's what I computed above.

# So with Q_1 = 1 - q + q^2 for c=(2,0,0), this has a negative coefficient.
# Either:
# (a) My computation is wrong
# (b) The conjecture is false for c=(2,0,0)
# (c) The conjecture implicitly requires some condition I'm missing

# Let me check: is (2,0,0) a valid profile for the conjecture?
# The conjecture says "c = (c_0, c_1, c_2)" with d not equiv 0 mod 3.
# It doesn't say c_i > 0. But maybe the CW recurrence requires all c_i > 0?

# Actually wait. Looking at the definition of cylindric partitions:
# lambda^i_j >= lambda^{i+1}_{j+c_{i+1}}
# For c = (2, 0, 0): c_1 = 0 and c_2 = 0.
# lambda^1_j >= lambda^2_{j+0} = lambda^2_j (so lambda^1 >= lambda^2 componentwise)
# lambda^2_j >= lambda^3_{j+0} = lambda^3_j (so lambda^2 >= lambda^3)
# lambda^3_j >= lambda^1_{j+2} 

# So it's a valid profile. Let me double-check by computing Q_1 a different way.

# Actually, let me look at what Warnaar proved for d=2.
# Warnaar says d in {2, 4, 5} are proven (k=1 and k=2 in his notation).
# His proof provides explicit manifestly positive multisums.
# 
# But maybe the "d=2" case he proved is specifically for balanced profiles?
# Or maybe I have a sign error.

# Let me try with a different normalization. 
# Check: is it (zq)_inf = (zq;q)_inf or something else?

# Alternative: maybe (zq)_inf means (z;q)_inf evaluated at z -> zq?
# (z;q)_inf = prod(1 - zq^j) for j >= 0. Evaluated at z -> zq: prod(1-zq^{j+1}).
# Same thing.

# Or maybe the formula uses a different q-Pochhammer:
# $(zq)_\infty$ = prod_{j >= 0}(1 - zq \cdot q^j) = prod_{j >= 0}(1 - zq^{j+1})? Yes same.

# Let me check if maybe the conjecture is only for profiles with all c_i > 0.
# The CW functional equation says I_c = {i : c_i > 0}. For c=(2,0,0), I_c = {0}.
# The recurrence still works. 

# Actually, wait. Looking at the Warnaar 2023 proof for d=2:
# For d=2 with k=3, the profiles are (2,0,0), (1,1,0), (0,2,0), (0,1,1), (0,0,2), (1,0,1).
# Under D_3, these form 2 orbits: {(2,0,0),(0,2,0),(0,0,2)} and {(1,1,0),(0,1,1),(1,0,1)}.
# Q_{n,c} is D_3-invariant, so Q_n for (2,0,0) = Q_n for (0,2,0) = Q_n for (0,0,2).
# 
# If Q_1 for (2,0,0) = 1-q+q^2, then it has a negative coefficient.
# This would mean the conjecture is FALSE as stated.
# 
# But Warnaar claims to have PROVED it for d=2. So either my formula is wrong
# or there's a different definition.

# Let me check the Welsh evaluation: Q_1(1) = (d+1)(d+2)/6 - 1 = 3*4/6 - 1 = 1.
# 1 - 1 + 1 = 1. Checks out.

# Hmm. Let me look more carefully at the definition. From conjecture.tex:
# Q_{n,c}(q) := (q^l;q^l)_n * [z^n]((zq)_inf * GK_c(z,q))
# where GK_c(z,q) = F_c(z,q) is the bivariate cylindric partition GF.

# Let me verify: is F_c(z,q) really the bivariate GF tracking max(Lambda)?
# From definition: F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}.
# So F_c(z,q) = sum_n (sum_{Lambda:max=n} q^{|Lambda|}) z^n.
# Then F_{c,n}(q) = sum_{Lambda:max=n} q^{|Lambda|}. NO!
# Actually, that's [z^n] of F_c(z,q). But this tracks max = n, not max <= n.

# Hmm, or does y track something else? Let me re-read.
# The definition has F_{c,n}(q) = sum_{Lambda in C_{c,n}} q^{|Lambda|}
# where C_{c,n} is the set of CPs with max <= n.
# And F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}.

# So [y^n] F_c(y,q) = sum_{Lambda:max(Lambda)=n} q^{|Lambda|} (not max <= n!).
# And F_{c,n}(q) = sum_{m=0}^n [y^m] F_c(y,q).

# OK so the definition says [z^n]((zq)_inf * GK_c(z,q)) where GK_c = F_c.
# Here z plays the role of y. So [z^n] of (zq)_inf * F_c(z,q)
# involves coefficients [z^j] of F_c(z,q) which are the max=j GFs.

# This doesn't change my computation. Let me try a completely different approach:
# compute Q_1 from its definition as a bounded polynomial.

# Q_n(q) = (q^l;q^l)_n * [z^n]((zq;q)_inf * sum_{m>=0} G_m(q) z^m)
# where G_m = sum_{max(Lambda)=m} q^{|Lambda|}.
# G_0 = 1 (empty partition only), G_m for m >= 1 = F_{c,m} - F_{c,m-1}.

# [z^1] of (zq;q)_inf * sum G_m z^m
# = [z^0](zq;q)_inf * G_1 + [z^1](zq;q)_inf * G_0
# = 1 * G_1 + (-q/(1-q)) * 1
# = G_1 - q/(1-q)
# = (F_{c,1} - F_{c,0}) - q/(1-q)
# = (F_{c,1} - 1) - q/(1-q)

# Then Q_1 = (1-q^l) * [(F_{c,1} - 1) - q/(1-q)]
# For l=1: Q_1 = (1-q) * (F_{c,1} - 1 - q/(1-q))
# = (1-q)(F_{c,1} - 1) - q
# = (1-q)F_{c,1} - (1-q) - q
# = (1-q)F_{c,1} - 1

# For c=(2,0,0): F_{c,1} = 1 + q + 2q^2 + 2q^3 + ...
# (1-q)F_{c,1} = 1 + 0q + q^2 + 0q^3 + q^4 + ...
# Q_1 = 0 + 0q + q^2 + 0q^3 + q^4 + ... - 1 = -1 + q^2 + q^4 + ...

# Hmm, that doesn't look right either. Let me be more careful.

# (1-q)*(1 + q + 2q^2 + 2q^3 + 3q^4 + 3q^5 + ...)
# = 1 + q + 2q^2 + 2q^3 + 3q^4 + ...
#   - q - q^2 - 2q^3 - 2q^4 - 3q^5 - ...
# = 1 + 0*q + q^2 + 0*q^3 + q^4 + 0*q^5 + ...

# Hmm wait: (1-q)*(1 + q + 2q^2 + 2q^3 + 3q^4 + ...) 
# = 1*(1+q+2q^2+...) - q*(1+q+2q^2+...)
# = (1 + q + 2q^2 + 2q^3 + ...) - (q + q^2 + 2q^3 + ...)
# = 1 + 0q + (2-1)q^2 + (2-2)q^3 + (3-2)q^4 + (3-3)q^5 + (4-3)q^6 + ...
# = 1 + q^2 + q^4 + q^6 + ...

# So (1-q)*F_{c,1} - 1 = q^2 + q^4 + q^6 + ...

# And the other formula gave Q_1 = (1-q)*F_{c,1} - q = 1 + q^2 + q^4 + ... - q = 1 - q + q^2 + q^4 + ...

# There's a discrepancy. Let me figure out which is correct.

# Formula 1: Q_1 = (1-q)(F_{c,1} - q/(1-q)) = (1-q)F_{c,1} - q
# Formula 2: Q_1 = (1-q)(F_{c,1} - 1 - q/(1-q)) = (1-q)F_{c,1} - 1

# The difference is in whether [z^1] F_c(z,q) = F_{c,1} or F_{c,1} - F_{c,0}.

# I think the confusion is: what is [z^n] of F_c(z,q)?
# F_c(z,q) = sum_{Lambda} q^{|Lambda|} z^{max(Lambda)}
# The EMPTY partition has max = 0 (or undefined). Conventionally, the empty partition
# has max = 0. So G_0 = 1, G_1 = F_{c,1} - 1 (where F_{c,1} = sum_{max<=1} q^{|.|}).

# Wait, G_0 should be [z^0]F_c(z,q) = sum_{max(Lambda)=0} q^{|Lambda|} = q^0 = 1
# (only the empty partition has max 0).
# G_1 = [z^1]F_c(z,q) = sum_{max(Lambda)=1} q^{|Lambda|} = F_{c,1} - F_{c,0}.
# F_{c,0} = 1 (just the empty partition). So G_1 = F_{c,1} - 1.

# But wait: F_c(y,q) = sum_{Lambda} q^{|Lambda|} y^{max(Lambda)}.
# This is NOT the same as sum_n F_{c,n}(q) y^n, because F_{c,n} counts max <= n.
# Instead: F_c(y,q) = G_0 + G_1*y + G_2*y^2 + ... where G_m counts max = m.
# And F_{c,n}(q) = G_0 + G_1 + ... + G_n.

# So [z^n] F_c(z,q) = G_n = F_{c,n} - F_{c,n-1}.

# Therefore:
# [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n [z^j](zq;q)_inf * [z^{n-j}] F_c(z,q)
# = sum_{j=0}^n e_j * G_{n-j}
# where e_j = [z^j](zq;q)_inf and G_m = F_{c,m} - F_{c,m-1} (with F_{c,-1} = 0).

# For n=1:
# = e_0 * G_1 + e_1 * G_0
# = 1 * (F_{c,1} - 1) + (-q/(1-q)) * 1
# = F_{c,1} - 1 - q/(1-q)

# Q_1 = (1-q)(F_{c,1} - 1 - q/(1-q)) = (1-q)(F_{c,1} - 1) - q

# For c=(2,0,0): F_{c,1} - 1 = q + 2q^2 + 2q^3 + 3q^4 + ...
# (1-q)(q + 2q^2 + ...) = q + q^2 + 0q^3 + q^4 + 0q^5 + ...
# Q_1 = q + q^2 + q^4 + ... - q = q^2 + q^4 + q^6 + ...

# Hmm, that's different from before. Let me compute carefully.

R = PowerSeriesRing(QQ, 'q', default_prec=20)
q = R.gen()

# F_{c,1} for c=(2,0,0):
F1 = R(0)
for w in range(20):
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= 0 and L3 - L2 <= 0 and L1 - L3 <= 2:
                count += 1
    F1 += count * q**w

print(f"F_{{(2,0,0),1}} = {F1}")

G1 = F1 - 1
print(f"G_1 = F_{{c,1}} - 1 = {G1}")

# e_0 = 1, e_1 = -q/(1-q) as power series
e1 = sum(-q**(j+1) for j in range(19))
print(f"e_1 = [z^1](zq;q)_inf = {e1}")

bracket = G1 + e1  # = G1 + e1*G0 = G1 - q/(1-q)
print(f"[z^1](...) = G_1 + e_1 = {bracket}")

Q1 = ((1 - q) * bracket).add_bigoh(20)
print(f"Q_1 = (1-q)*[...] = {Q1}")
print(f"Q_1(1) = {sum(Q1[i] for i in range(20))}")

# Also compute for c=(1,1,0):
F1b = R(0)
for w in range(20):
    count = 0
    for L1 in range(w+1):
        for L2 in range(w+1-L1):
            L3 = w - L1 - L2
            if L2 - L1 <= 1 and L3 - L2 <= 0 and L1 - L3 <= 1:
                count += 1
    F1b += count * q**w

G1b = F1b - 1
bracket_b = G1b + e1
Q1b = ((1 - q) * bracket_b).add_bigoh(20)
print(f"\nc=(1,1,0): Q_1 = {Q1b}")
print(f"Q_1(1) = {sum(Q1b[i] for i in range(20))}")

# Now try the CORRECT formula for d=7:
print("\n--- d=7, various profiles ---")
for (c0,c1,c2) in [(3,2,2), (4,2,1), (5,1,1), (7,0,0)]:
    d = c0+c1+c2
    l = gcd(d,3)
    F1 = R(0)
    for w in range(20):
        count = 0
        for L1 in range(w+1):
            for L2 in range(w+1-L1):
                L3 = w - L1 - L2
                if L2 - L1 <= c1 and L3 - L2 <= c2 and L1 - L3 <= c0:
                    count += 1
        F1 += count * q**w
    
    G1 = F1 - 1
    
    # e_1 for base q^l
    # (zq;q)_inf: base is q, so e_1 = -q/(1-q)
    # Wait, is the base q or q^l?
    # From the definition: (zq)_inf. Looking at notation: (a;q)_inf = prod(1-aq^i).
    # So (zq)_inf likely means (zq;q)_inf with base q.
    
    bracket = G1 + e1
    ql = 1 - q**l
    
    # (q^l;q^l)_1 = 1 - q^l
    Q1 = (ql * bracket).add_bigoh(20)
    print(f"c=({c0},{c1},{c2}), l={l}: Q_1 = {Q1}")
    neg = [i for i in range(20) if Q1[i] < 0]
    print(f"  Negative at: {neg}")
    print(f"  Q_1(1) = {sum(Q1[i] for i in range(20))}")

