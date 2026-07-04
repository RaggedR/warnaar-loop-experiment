"""
Debug: which triples (a1,a2,a3) of column partitions pass the check for c=(1,1,0)?
Focus on size 1 (should have 0 valid partitions per Borodin).
"""

def get_part(lam, j):
    return lam[j-1] if j <= len(lam) else 0

def check_cylindric_verbose(lams, c, max_j=10):
    k = len(c)
    for i in range(k):
        i_next = (i+1) % k
        shift = c[i_next]
        for j in range(1, max_j+1):
            left = get_part(lams[i], j)
            right = get_part(lams[i_next], j + shift)
            if left < right:
                return False, f"Failed: lam^{i+1}_{j}={left} < lam^{i_next+1}_{j+shift}={right}, i={i}, j={j}, shift={shift}"
            if left == 0 and right == 0:
                break
    return True, "OK"

# c = (1,1,0)
# For size 1: exactly one of a1,a2,a3 is 1, rest are 0.

# (a1=1, a2=0, a3=0): lams = [(1,), (), ()]
lams = [(1,), (), ()]
ok, msg = check_cylindric_verbose(lams, (1,1,0))
print(f"(1^1, 0, 0): {ok} - {msg}")
# Check manually:
# lam^1 = (1), lam^2 = (), lam^3 = ()
# Cond 1: lam^1_j >= lam^2_{j+1}. j=1: 1 >= lam^2_2 = 0. OK.
# Cond 2: lam^2_j >= lam^3_j. j=1: 0 >= 0. OK (all empty).
# Cond 3: lam^3_j >= lam^1_{j+1}. j=1: 0 >= lam^1_2 = 0. OK.
# So this should pass. But Borodin says NO cylindric partition of size 1!

# Let me re-read the Borodin formula more carefully.
# c = (c_1,...,c_k). For the Borodin product:
# t = k + ell where ell = c_1 + ... + c_k

# WAIT. The conjecture uses c = (c_0, c_1, c_2) and the cylindric partition uses
# c = (c_1, ..., c_k). These might be DIFFERENT INDEXINGS.

# More importantly: does the Borodin product really correspond to c=(1,1,0)?
# Let me check: for c=(1,1,0), t = 3+2 = 5.
# The product is 1/((q^2,q^3,q^4,q^5;q^5)_inf)
# = 1/prod_{n not equiv 0,1 mod 5} (1-q^n) ... wait no.
# (q^2;q^5) gives factors at 2,7,12,...
# (q^3;q^5) gives factors at 3,8,13,...
# (q^4;q^5) gives factors at 4,9,14,...
# (q^5;q^5) gives factors at 5,10,15,...
# So the product is 1/prod_{n>=2}(1-q^n) * prod_{n equiv 1 mod 5}(1-q^n)
# Wait no: the product is over n=2,3,4,5 mod 5 for n>=2 (plus 5,10,15...).
# Combined: every n>=1 EXCEPT n equiv 1 mod 5.
# 1/prod_{n>=1, n not equiv 1 mod 5}(1-q^n)

# This is related to Rogers-Ramanujan! The second RR identity.
# RR2: sum q^{n(n+1)}/((q;q)_n) = prod 1/((1-q^{5n-1})(1-q^{5n-4}))
# So the complement would give prod 1/((1-q^{5n-2})(1-q^{5n-3})(1-q^{5n}))
# But our product is 1/prod_{n not 1 mod 5}(1-q^n)
# = (q;q^5)_inf / (q)_inf = (q;q^5)_inf * 1/(q)_inf

# Hmm, let me just compute the series directly.
# The first nonzero term after q^0 should be q^2. So there's NO partition of size 1.
# But my enumeration found 2 triples of size 1.

# The issue is: is ((1,), (), ()) really a valid cylindric partition of profile (1,1,0)?
# Let me think about this more carefully using the PERIODIC plane partition interpretation.

# A cylindric partition of profile (c_1,...,c_k) with ell = sum c_i and t = k+ell
# is a periodic skew plane partition on a cylinder of circumference t.

# For c=(1,1,0): t=5, ell=2. The cylinder has 5 columns.
# The profile tells us the "shape" of the interlacing.

# Actually, let me re-examine. Maybe my Borodin formula is wrong.
# Let me use a DIFFERENT profile and see if the formula matches.

# For c = (1,0,0): d=1, t=4, ell=1. (But d=1 has gcd(1,3)=1.)
# Borodin: k=3, c=(1,0,0).
# First product: i=1..3, j=i+1..3, m=1..c_i
#   i=1,j=2: m=1..1: exp = 1 + d_{2,2} + 2-1 = 1+0+1=2
#   i=1,j=3: m=1..1: exp = 1 + d_{2,3} + 3-1 = 1+0+2=3
#   i=2,j=3: m=1..0 -> empty
# Second product: empty (c_2=c_3=0)
# F = 1/((q^4;q^4)(q^2;q^4)(q^3;q^4))_inf
# = 1/(prod n>=1 n=2,3,0 mod 4) (1-q^n)
# = 1/prod_{n>=2}(1-q^n)  [since 2,3,4,6,7,8,10,11,12,...] = all n>=2
# So F_{(1,0,0)}(q) = (1-q)/prod_{n>=1}(1-q^n) = (1-q)/(q)_inf

# That seems odd. Let me verify with partition theory:
# c=(1,0,0) means the interlacing is:
# lam^1_j >= lam^2_j (shift 0)
# lam^2_j >= lam^3_j (shift 0)
# lam^3_j >= lam^1_{j+1} (shift 1)
# So lam^1 >= lam^2 >= lam^3 componentwise, and lam^3_j >= lam^1_{j+1}.
# This means lam^1 is a partition where removing the first column gives something <= lam^3 <= lam^2 <= lam^1.
# These are basically plane partitions in a "tube" shape.

# Actually wait, for c=(1,0,0) with max entry n, the set C_{c,n} has:
# lam^3_j >= lam^1_{j+1} and lam^1_1 <= n, so lam^3 >= "lam^1 shifted".
# This is saying that the three partitions interleave cyclically with one shift.

# OK but the key point is whether my Borodin formula computation is correct.
# Let me check a well-known case.

# For k=2, c=(1,1): d=2, t=4.
# This gives the cylindric partitions related to modulus 4.
# Borodin: k=2, c=(1,1).
# d_{1,1}=1, d_{1,2}=2, d_{2,2}=1.
# First product: i=1,j=2, m=1..1: exp = 1+d_{2,2}+2-1 = 1+1+1=3
# Second product: i=2, j=2..1: empty
# F = 1/((q^4;q^4)(q^3;q^4))_inf = 1/prod_{n equiv 0,3 mod 4}(1-q^n)
# First terms: 1 + q^3 + q^4 + q^6 + q^7 + 2q^8 + ...

# Hmm, but with k=2 and c=(1,1), t=4, ell=2:
# lam^1_j >= lam^2_{j+1} and lam^2_j >= lam^1_{j+1}
# The minimum nonzero size partition: need at least size 3?
# Actually (1^1, ()) has size 1: lam^1=(1), lam^2=()
# lam^1_1=1 >= lam^2_2=0. OK.
# lam^2_1=0 >= lam^1_2=0. OK.
# Size = 1. But Borodin gives first nonzero at q^3...

# So either Borodin gives the UNRESTRICTED generating function (no max bound),
# or my formula is wrong.

# F_c(q) = sum over ALL cylindric partitions (no bound on max).
# So ((1,), ()) of size 1 SHOULD be counted. But the Borodin product has no q^1 term.
# This means either:
# 1. My Borodin computation is wrong, or
# 2. ((1,), ()) is NOT a valid cylindric partition of this profile.

# Let me re-read the definition more carefully.

# "A cylindric partition of profile c is a sequence of k partitions
#  Lambda = (lam^1, ..., lam^k) such that:
#  lam^i_j >= lam^{i+1}_{j+c_{i+1}} for all 1 <= i <= k-1, j >= 1
#  lam^k_j >= lam^1_{j+c_1} for all j >= 1"

# For k=2, c=(c_1,c_2)=(1,1):
# lam^1_j >= lam^2_{j+c_2} = lam^2_{j+1}  for all j >= 1
# lam^2_j >= lam^1_{j+c_1} = lam^1_{j+1}  for all j >= 1

# Check ((1,), ()): lam^1=(1), lam^2=()
# Cond 1: j=1: lam^1_1=1 >= lam^2_2=0. OK.
# Cond 2: j=1: lam^2_1=0 >= lam^1_2=0. OK.
# So it IS valid. Size = 1.

# But Borodin has no q^1 term. So my Borodin formula must be wrong!

# Let me recompute. For k=2, c=(1,1), t=4.
# d_{i,j}: d_{1,1}=c_1=1, d_{2,2}=c_2=1, d_{1,2}=c_1+c_2=2
# Note: d_{i+1,j} when i=1,j=2 means d_{2,2}=1.

# First product: prod_{i=1}^{k} prod_{j=i+1}^{k} prod_{m=1}^{c_i}
# i=1, j=2: m=1..c_1=1: exponent = m + d_{i+1,j} + j - i = 1 + d_{2,2} + 2-1 = 1+1+1 = 3
# So we get 1/(q^3;q^4)_inf

# Second product: prod_{i=2}^{k} prod_{j=2}^{i-1} prod_{m=1}^{c_i}
# i=2: j=2..1 -> empty range
# So second product contributes nothing.

# Total: F = 1/((q^4;q^4)_inf * (q^3;q^4)_inf)

# Series: 1/((1-q^3)(1-q^4)(1-q^7)(1-q^8)(1-q^{11})(1-q^{12})...)
# q^0: 1, q^1: 0, q^2: 0, q^3: 1, q^4: 1, ...
# But we showed ((1,), ()) is a valid cylindric partition of size 1!

# CONCLUSION: Either the Borodin formula or my definition of cylindric partition is wrong.

# Let me look at this from a different angle. Borodin's formula says F_c(q) for 
# UNRESTRICTED cylindric partitions. Maybe the definition I'm using is different 
# from Borodin's. Let me check the ORIGINAL definition in Borodin's paper.

# Actually, wait. The issue might be more subtle. The definition in conjecture.tex says
# "a composition c = (c_1,...,c_k) with c_i >= 0". But maybe Borodin's formula
# requires all c_i > 0? Or maybe the product formula has additional conditions.

# Let me try c = (2,1) (k=2). This has all c_i > 0.
# t = 2+3 = 5.
# d_{1,1}=2, d_{2,2}=1, d_{1,2}=3
# First product: i=1,j=2, m=1..2:
#   m=1: exp = 1 + d_{2,2} + 2-1 = 1+1+1 = 3
#   m=2: exp = 2 + 1 + 1 = 4
# Second product: empty
# F = 1/((q^5;q^5)(q^3;q^5)(q^4;q^5))_inf
# = 1/prod_{n=3,4,5,8,9,10,13,...}(1-q^n)
# = 1/prod_{n>=1, n not in {1,2,6,7,11,12,...} = not 1,2 mod 5}(1-q^n)

# For k=2, c=(2,1):
# lam^1_j >= lam^2_{j+1}
# lam^2_j >= lam^1_{j+2}
# Check ((1,), ()): 
#   lam^1_1=1 >= lam^2_2=0, OK
#   lam^2_1=0 >= lam^1_3=0, OK
# Valid, size 1. But no q^1 in product.

# Check ((),(1,)):
#   lam^1_1=0 >= lam^2_2=0, OK
#   lam^2_1=1 >= lam^1_3=0, OK
# Valid, size 1.

# So we'd have coefficient 2 at q^1, but Borodin gives 0.

# SOMETHING IS FUNDAMENTALLY WRONG WITH MY UNDERSTANDING.

# Let me look at this from the periodic plane partition perspective.
# "A cylindric partition of profile (c_1,...,c_k) with ell=sum c_i and t=k+ell
#  is equivalently a periodic skew plane partition on a cylinder of circumference t."

# For c=(1,1), t=4: cylinder of circumference 4.
# A periodic plane partition on such a cylinder must have period 4.
# The entries can be 0,1,2,...

# In a periodic plane partition, we have an infinite array a_{i,j} with
# a_{i,j} >= a_{i,j+1} and a_{i,j} >= a_{i+1,j} and a_{i+t,j} = a_{i,j+1}...
# This is more constrained than what I wrote!

# Actually I think the issue is that in the cylindric partition framework,
# the partitions are REVERSE-sorted or there's a different convention.

# Let me look at a reference. In Borodin 2007, a cylindric partition of shape
# lambda/mu with period N is defined as a sequence of interlacing partitions
# ... >= nu^{-1} >= nu^0 >= nu^1 >= ... with nu^{i+N}_j = nu^i_{j-1} + const.

# The point is: the PROFILE determines a SHAPE (like a skew shape on the cylinder),
# and the cylindric partition fills this shape with non-negative integers 
# satisfying certain monotonicity.

# I think my error is in the definition. The conjecture.tex definition might
# be using a different normalization than what leads to Borodin's product.

# Let me try: maybe the cylindric partition conditions should be STRICT
# inequalities, or maybe the shift goes the other way.

# Actually wait -- maybe I have the wrong formula. Let me re-read Borodin.
# The product formula involves (q^t;q^t)_inf in the denominator and then
# products indexed by pairs and a shift parameter d_{i,j}.

# Let me try the REVERSE convention: maybe c = (c_0,c_1,c_2) in Q maps to
# a different ordering in the cylindric partition definition.

# Or maybe the issue is simpler: the product formula is for the generating function
# of SIZE, not NUMBER of cylindric partitions.

# Hmm no, q^{|Lambda|} IS the size. Let me try a simpler approach:
# compute the EXACT generating function for c=(1,1) by brute force for small n.

print("=== Brute force F_{(1,1)}(q) by enumeration ===")
# c=(1,1), k=2
# lam^1_j >= lam^2_{j+1}
# lam^2_j >= lam^1_{j+1}

from itertools import product as iterproduct

def gen_parts(max_val, max_len):
    if max_len == 0 or max_val == 0:
        yield ()
        return
    for f in range(max_val, -1, -1):
        if f == 0:
            yield ()
        else:
            for r in gen_parts(f, max_len - 1):
                yield (f,) + r

MAX_ENTRY = 5
MAX_LEN = 6
MAX_SIZE = 20

parts = list(gen_parts(MAX_ENTRY, MAX_LEN))
count = {}
for l1 in parts:
    s1 = sum(l1)
    if s1 > MAX_SIZE: continue
    for l2 in parts:
        s2 = sum(l2)
        if s1+s2 > MAX_SIZE: continue
        # Check conditions
        ok = True
        for j in range(1, MAX_LEN+3):
            p1 = l1[j-1] if j <= len(l1) else 0
            p2s = l2[j] if j+1 <= len(l2) else 0  # lam^2_{j+1}
            if p1 < p2s:
                ok = False
                break
            p2 = l2[j-1] if j <= len(l2) else 0
            p1s = l1[j] if j+1 <= len(l1) else 0  # lam^1_{j+1}
            if p2 < p1s:
                ok = False
                break
        if ok:
            total = s1 + s2
            count[total] = count.get(total, 0) + 1

print("F_{(1,1)}(q) from brute force:")
for k in sorted(count.keys()):
    if k <= 15:
        print(f"  q^{k}: {count[k]}")

# Borodin for c=(1,1):
exps_11 = [n for n in range(1, 50) if n % 4 in (3, 0)]  # 3,4,7,8,11,12,...
F_bor_11 = {}
F_bor_11[0] = 1
result = {0: 1}
for e in exps_11:
    if e > 30: break
    new = {}
    for k, v in result.items():
        j = 0
        while k + j*e <= 30:
            new[k+j*e] = new.get(k+j*e, 0) + v
            j += 1
    result = new

print("\nBorodin F_{(1,1)}:")
for k in sorted(result.keys()):
    if k <= 15:
        print(f"  q^{k}: {result[k]}")

