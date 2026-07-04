"""
Agent A: Investigate the D_k^m tower decomposition carefully.

Discovery: h_m = (q;q)_m * g_m has NEGATIVE coefficients for m >= 2,
even for d not-equiv 0 mod 3. This is a critical observation.

But Q_n is nonneg. How? The tower must work differently.

Let me re-derive the tower from the formula:
Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} * qbinom(n,m) * g_m

This is a SIGNED sum of g_m terms. The positivity is NOT coming from
each term being positive -- it comes from cancellation.

The D_k^m tower (as defined in the synthesis) is probably about a 
different decomposition. Let me look at this more carefully.
"""
from sage.all import *

PREC = 80
R = PowerSeriesRing(QQ, 'q', default_prec=PREC)
q = R.gen()

def compute_gm(c, m, prec=PREC):
    """Compute g_m using column representation."""
    k = len(c)
    result = R(0)
    if m == 0: return R(1)
    
    max_s = min(prec // (m*k), 25)
    
    if m == 1:
        for s0 in range(max_s):
            for s1 in range(min(s0+c[1]+1, max_s)):
                for s2 in range(min(s1+c[2]+1, max_s)):
                    if s0 <= s2+c[0] and max(s0,s1,s2)>=1:
                        total = s0+s1+s2
                        if total < prec: result += q**total
        return result
    
    if m == 2:
        for a0 in range(max_s):
            for a1 in range(min(a0+c[1]+1, max_s)):
                for a2 in range(min(a1+c[2]+1, max_s)):
                    if a0 > a2+c[0]: continue
                    for b0 in range(min(a0+1, max_s)):
                        for b1 in range(min(b0+c[1]+1, a1+1, max_s)):
                            for b2 in range(min(b1+c[2]+1, a2+1, max_s)):
                                if b0 > b2+c[0]: continue
                                if max(b0,b1,b2)>=1:
                                    total = a0+a1+a2+b0+b1+b2
                                    if total < prec: result += q**total
        return result
    return None

def qpoch(m, prec=PREC):
    result = R(1)
    for i in range(1, m+1): result *= (1 - q**i)
    return result

def qbinom(n, m, prec=PREC):
    return qpoch(n, prec) / (qpoch(m, prec) * qpoch(n-m, prec))

# Profile c=(2,1,1), d=4
c = (2,1,1)
d = 4

g = {}
for m in range(5):
    gm = compute_gm(c, m)
    if gm is not None:
        g[m] = gm
        print(f"g_{m} computed, first terms: {[gm[i] for i in range(min(15, PREC))]}")
    else:
        print(f"g_{m} too complex")

# The D_k^m tower from the synthesis:
# Previous agents defined D_k^m via a specific decomposition of Q_n.
# Let me reconstruct this.

# From the Q_n formula:
# Q_n = sum_{m=0}^n (-1)^{n-m} q^{binom(n-m+1,2)} [n choose m]_q * g_m

# For n=1: Q_1 = -q * g_0 + g_1 = g_1 - q
# For n=2: Q_2 = q^3 * g_0 - q*(1+q)*g_1 + g_2

# The synthesis says the tower is:
# D_0^m = h_m (some quantity)
# D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
# And Q_n = sum of D_k^m terms

# Actually, looking at this more carefully, the "D_k^m tower" is probably
# about decomposing Q_n in a specific way.

# Let me define things differently. The key identity is:
# Q_n = (q;q)_n * [z^n] ((zq;q)_inf * F(z,q))
# 
# Write F(z,q) = sum_m z^m g_m
# (zq;q)_inf = sum_j (-z)^j q^{j(j+1)/2} / (q;q)_j
#
# Product: (zq;q)_inf * F = sum_n z^n * sum_{m+j=n} g_m (-1)^j q^{j(j+1)/2}/(q;q)_j
# 
# The coefficient of z^n is a signed alternating sum. We can write:
# [z^n](...) = sum_m g_m * (-1)^{n-m} q^{(n-m)(n-m+1)/2} / (q;q)_{n-m}
# = sum_m g_m * alpha_{n,m}  where alpha_{n,m} = (-1)^{n-m} q^{T_{n-m}} / (q;q)_{n-m}
# (T_k = k(k+1)/2 = triangular number)
#
# Q_n = (q;q)_n * sum_m alpha_{n,m} g_m

# The D_k^m tower from the synthesis seems to be about a DIFFERENT
# decomposition. Let me look at what happens if we define:
# 
# f_m = g_m - g_{m-1} (first difference)
# Then f_m = #{CPs with max = m} - #{CPs with max = m-1}
# From the injection lemma: g_m >= q * g_{m-1}, so f_m has nonneg coefficients
# (it's g_m - g_{m-1} but g_m has MORE at each degree than q*g_{m-1}, not g_{m-1})
# Actually the injection lemma says g_m >= q * g_{m-1} (shifted), not g_m >= g_{m-1} (unshifted).

# Let me think about what D_k^m might be.
# D_0^m could be defined as g_m itself (or some transform of it).
# D_1^m = D_0^m - q * D_0^{m-1} = g_m - q * g_{m-1}
# The injection lemma proves D_1^m >= 0.
# D_2^m = D_1^m - q^2 * D_1^{m-1} = (g_m - q*g_{m-1}) - q^2*(g_{m-1} - q*g_{m-2})
#        = g_m - (q+q^2)*g_{m-1} + q^3*g_{m-2}
# And so on.

# If we define D_0^m = g_m and D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1},
# then by induction:
# D_k^m = sum_{j=0}^k (-1)^j q^{j(j+1)/2} [k choose j]_q * g_{m-j}  (maybe?)

# Let me verify this. D_1^m = g_m - q*g_{m-1}. That's (-1)^0 q^0 * g_m + (-1)^1 q^1 * g_{m-1}
# = sum_j (-1)^j q^{T_j} [1 choose j] g_{m-j}. For j=0: [1,0]=1, q^0 = 1. For j=1: [1,1]=1, q^1=q.
# Yes, this matches with qbinom(1,j).

# D_2^m = D_1^m - q^2 D_1^{m-1}
# = (g_m - q g_{m-1}) - q^2(g_{m-1} - q g_{m-2})
# = g_m - (q+q^2) g_{m-1} + q^3 g_{m-2}
# Check: sum_j (-1)^j q^{T_j} [2,j] g_{m-j}
# j=0: q^0 [2,0] g_m = g_m
# j=1: -q^1 [2,1] g_{m-1} = -q(1+q) g_{m-1}
# j=2: q^3 [2,2] g_{m-2} = q^3 g_{m-2}
# YES! This matches.

# So D_k^m = sum_{j=0}^k (-1)^j q^{T_j} [k choose j]_q * g_{m-j}

# And Q_n = (q;q)_n * [z^n]((zq;q)_inf * F(z,q))
#         = (q;q)_n * sum_m alpha_{n,m} g_m  where alpha_{n,m} = (-1)^{n-m} q^{T_{n-m}} / (q;q)_{n-m}
#         = sum_m (-1)^{n-m} q^{T_{n-m}} [n choose m]_q g_m
#         = D_n^n  (with D_0^m = g_m)

# Wait: D_n^n = sum_{j=0}^n (-1)^j q^{T_j} [n,j] g_{n-j}
# Compare: Q_n = sum_{m=0}^n (-1)^{n-m} q^{T_{n-m}} [n,m] g_m
#              = sum_{j=0}^n (-1)^j q^{T_j} [n, n-j] g_{n-(n-j)... hmm}
# Let me substitute j = n-m: Q_n = sum_{j=0}^n (-1)^j q^{T_j} [n, n-j] g_{n-j}
# = sum_{j=0}^n (-1)^j q^{T_j} [n, j] g_{n-j}  (since [n,k] = [n,n-k])
# = D_n^n. Yes!

# So Q_n = D_n^n where D_0^m = g_m and D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}.

# This is the D_k^m tower! The conjecture Q_n >= 0 is equivalent to D_n^n >= 0.

# And the tower approach tries to prove D_k^m >= 0 for ALL k, m >= k.
# If D_k^m >= 0 for all k <= m, then in particular D_n^n >= 0 = Q_n >= 0.

# The base case: D_1^m = g_m - q*g_{m-1} >= 0 is the injection lemma.
# The inductive step: D_k^m >= 0 follows from D_{k-1}^m >= q^k D_{k-1}^{m-1}
# (domination). But this is NOT implied by D_{k-1}^m >= 0 alone.

# The ISP says: D_k^m matches q^{k+1} D_k^{m-1} for the first few leading coefficients.
# This is a stronger statement that could imply the domination.

# Key question: IS D_k^m >= 0 for all k <= m?
# Let me compute D_k^m directly.

print("\n" + "=" * 60)
print("D_k^m tower for c=(2,1,1), d=4")
print("=" * 60)

D = {}
for m in g:
    D[(0, m)] = g[m]

# Compute D_k^m
for k in range(1, 5):
    for m in range(k, 5):
        if (k-1, m) in D and (k-1, m-1) in D:
            D[(k, m)] = D[(k-1, m)] - q**k * D[(k-1, m-1)]
        else:
            break

for k in range(5):
    for m in range(k, 5):
        if (k, m) in D:
            dkm = D[(k, m)]
            coeffs = [dkm[i] for i in range(30)]
            neg = [i for i in range(30) if coeffs[i] < 0]
            last_nz = max([i for i in range(30) if coeffs[i] != 0], default=-1)
            print(f"D_{k}^{m}: coeffs[:15] = {coeffs[:15]}, deg={last_nz}, sum={sum(coeffs)}")
            if neg:
                print(f"  NEGATIVE at: {neg}")

# In particular, Q_1 = D_1^1 and Q_2 = D_2^2
print("\nVerification:")
if (1,1) in D:
    print(f"D_1^1 = Q_1? coeffs = {[D[(1,1)][i] for i in range(10)]}")
if (2,2) in D:
    print(f"D_2^2 = Q_2? coeffs = {[D[(2,2)][i] for i in range(15)]}")

# NOW let me check: D_1^m = g_m - q*g_{m-1} >= 0?
# This is the injection lemma applied. Let me verify.
print("\nD_1^m (injection lemma verification):")
for m in range(1, 5):
    if (1, m) in D:
        dkm = D[(1, m)]
        coeffs = [dkm[i] for i in range(20)]
        neg = [i for i in range(20) if coeffs[i] < 0]
        print(f"  D_1^{m}: {'NONNEG' if not neg else 'NEGATIVE at ' + str(neg)}")
        print(f"    first terms: {coeffs[:15]}")

# D_2^m:
print("\nD_2^m:")
for m in range(2, 5):
    if (2, m) in D:
        dkm = D[(2, m)]
        coeffs = [dkm[i] for i in range(25)]
        neg = [i for i in range(25) if coeffs[i] < 0]
        print(f"  D_2^{m}: {'NONNEG' if not neg else 'NEGATIVE at ' + str(neg)}")
        print(f"    first terms: {coeffs[:20]}")

