"""
Seed 4, Layer 3: Investigate the injection h_m >= q * h_{m-1}.

h_m = (q;q)_m * [z^m] F_c(z,q)
    = (q;q)_m * g_m

g_m = sum over cylindric partitions of profile c with max = m of q^{|Lambda|}.

So h_m counts cylindric partitions with max = m, weighted by q^{size} * (q;q)_m.

The domination h_m >= q * h_{m-1} means:
  (q;q)_m * g_m >= q * (q;q)_{m-1} * g_{m-1}
  (1 - q^m) * (q;q)_{m-1} * g_m >= q * (q;q)_{m-1} * g_{m-1}
  (1 - q^m) * g_m >= q * g_{m-1}  ... NO, this is wrong because h_m is a polynomial
  
Actually h_m = (q;q)_m * g_m where g_m is the POWER SERIES coefficient.
But (q;q)_m * g_m is a polynomial. The inequality is coefficient-wise.

Let's think more carefully. h_m >= q * h_{m-1} means:
  (q;q)_m g_m - q (q;q)_{m-1} g_{m-1} >= 0
  (1-q^m)(q;q)_{m-1} g_m - q (q;q)_{m-1} g_{m-1} >= 0
  (q;q)_{m-1} [(1-q^m) g_m - q g_{m-1}] >= 0

Since (q;q)_{m-1} has alternating signs, this doesn't simplify nicely.

Alternative: look at the RATIO h_m / h_{m-1} and see if it has a nice form.

Let's also look at D_1^m = h_m - q * h_{m-1} more carefully.
D_1^m(1) = (base-1) * base^{m-1}.

Can we write D_1^m = (1-q^m) * something_positive + other_positive?

Actually, let's focus on WHAT h_m counts. 
h_m = (q;q)_m * g_m where g_m = F_{c,m} - F_{c,m-1} = generating function for 
cylindric partitions with max EXACTLY m.

Wait, that's not right either. g_m = [z^m] F_c(z,q) where F_c(z,q) = sum g_m z^m.
And F_{c,n}(q) = sum_{m=0}^n g_m = sum over cylindric partitions with max <= n.

So g_m = F_{c,m} - F_{c,m-1} counts those with max = m.

And h_m = (q;q)_m * g_m.

The (q;q)_m factor is the q-Pochhammer symbol = product (1-q)(1-q^2)...(1-q^m).
This has alternating signs! So h_m being nonneg is not obvious from g_m >= 0 alone.

Let me compute g_m and h_m and examine the relationship.
"""

from collections import defaultdict
from itertools import combinations
from math import gcd

MAX_Q_DEG = 150

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items(): result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}
def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})
def poly_mul(a, b, max_deg=MAX_Q_DEG):
    result = {}
    for i, ai in a.items():
        if ai == 0 or i > max_deg: continue
        for j, bj in b.items():
            if bj == 0 or i + j > max_deg: continue
            result[i + j] = result.get(i + j, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}
def poly_scale(p, s):
    if s == 0: return {}
    return {k: v * s for k, v in p.items()}
def poly_shift(p, s, max_deg=MAX_Q_DEG):
    return {k + s: v for k, v in p.items() if k + s <= max_deg and k + s >= 0}

def all_profiles(d, k=3):
    if k == 1: return [(d,)]
    result = []
    for c0 in range(d + 1):
        for rest in all_profiles(d - c0, k - 1):
            result.append((c0,) + rest)
    return result

def shifted_profile(c, J):
    k = len(c); J_set = set(J); c_new = list(c)
    for i in range(k):
        i_prev = (i - 1) % k
        if i in J_set and i_prev not in J_set: c_new[i] -= 1
        elif i not in J_set and i_prev in J_set: c_new[i] += 1
    return tuple(c_new)

def get_transitions(c):
    k = len(c); I_c = [i for i in range(k) if c[i] > 0]
    if not I_c: return []
    trans = []
    for size in range(1, len(I_c) + 1):
        for J in combinations(I_c, size):
            sign = (-1) ** (size - 1)
            cJ = shifted_profile(c, J)
            if any(x < 0 for x in cJ): continue
            trans.append((sign, size, cJ))
    return trans

def compute_gn_system(d, n_max, max_q=MAX_Q_DEG, k=3):
    profiles = all_profiles(d, k)
    trans = {c: get_transitions(c) for c in profiles}
    g = defaultdict(lambda: defaultdict(dict))
    for c in profiles: g[0][c] = {0: 1}
    for n in range(1, n_max + 1):
        rhs = {}
        for c in profiles:
            r = {}
            for sign, s, cJ in trans[c]:
                partial_sum = {}
                for m in range(n): partial_sum = poly_add(partial_sum, g[m][cJ])
                term = poly_shift(poly_scale(partial_sum, sign), n * s, max_q)
                r = poly_add(r, term)
            rhs[c] = r
        curr_gn = {c: {} for c in profiles}
        for deg in range(max_q + 1):
            for c in profiles:
                val = rhs[c].get(deg, 0)
                for sign, s, cJ in trans[c]:
                    src_deg = deg - n * s
                    if src_deg >= 0: val += sign * curr_gn[cJ].get(src_deg, 0)
                if val != 0: curr_gn[c][deg] = val
        for c in profiles: g[n][c] = curr_gn[c]
    return g, profiles

def compute_hm(g, profile, m, max_q):
    gm = g[m].get(profile, {})
    qpoch = {0: 1}
    for i in range(1, m + 1):
        new = {}
        for p, c in qpoch.items():
            if p <= max_q: new[p] = new.get(p, 0) + c
            if p + i <= max_q: new[p + i] = new.get(p + i, 0) - c
        qpoch = {k: v for k, v in new.items() if v != 0}
    return poly_mul(qpoch, gm, max_q)

def poly_str(p, max_terms=20):
    if not p: return "0"
    items = sorted(p.items())
    parts = []
    for deg, coeff in items[:max_terms]:
        if coeff == 1: parts.append(f"q^{deg}")
        else: parts.append(f"{coeff}*q^{deg}")
    s = " + ".join(parts)
    if len(items) > max_terms: s += f" + ... ({len(items)} terms)"
    return s

# Detailed analysis for d=4
print("="*80)
print("Detailed injection analysis: d=4, c=(2,1,1), base=5")
print("="*80)

d, profile = 4, (2,1,1)
max_q = 100
g, profiles = compute_gn_system(d, 6, max_q)

print("\n--- g_m (raw cylindric partition GF for max=m) ---")
for m in range(7):
    gm = g[m].get(profile, {})
    gm_sum = sum(gm.values())
    print(f"g_{m} = {poly_str(gm)}")
    print(f"  g_{m}(1) = {gm_sum}")

print("\n--- h_m = (q;q)_m * g_m ---")
h = {}
for m in range(7):
    h[m] = compute_hm(g, profile, m, max_q)
    print(f"h_{m} = {poly_str(h[m])}")
    print(f"  h_{m}(1) = {sum(h[m].values())}")

print("\n--- D_1^m = h_m - q*h_{m-1} ---")
for m in range(1, 7):
    D1m = poly_sub(h[m], poly_shift(h[m-1], 1, max_q))
    D1m_sum = sum(D1m.values())
    neg = any(v < 0 for v in D1m.values())
    print(f"D_1^{m} = {poly_str(D1m)}")
    print(f"  D_1^{m}(1) = {D1m_sum}, expected = 4*5^{m-1} = {4 * 5**(m-1)}, neg={neg}")

# Now look at whether D_1^m has a nice factored form
print("\n--- Check if D_1^m is divisible by (1-q^something) ---")
for m in range(1, 5):
    D1m = poly_sub(h[m], poly_shift(h[m-1], 1, max_q))
    # Check divisibility by (1-q), (1-q^2), etc.
    for j in range(1, 8):
        # Try polynomial division of D1m by (1-q^j)
        # (1-q^j) means we check if sum of coefficients at positions k mod j equals 0
        items = sorted(D1m.items())
        quotient = {}
        remainder = dict(D1m)
        can_divide = True
        for deg in sorted(remainder.keys()):
            c = remainder.get(deg, 0)
            if c == 0: continue
            quotient[deg] = c
            remainder[deg] = 0
            if deg + j <= max_q:
                remainder[deg + j] = remainder.get(deg + j, 0) + c
        remainder = {k: v for k, v in remainder.items() if v != 0}
        if not remainder:
            print(f"  D_1^{m} is divisible by (1-q^{j})!")
            print(f"    quotient = {poly_str(quotient)}")
            # Check if quotient is nonneg
            q_neg = any(v < 0 for v in quotient.values())
            print(f"    quotient nonneg: {not q_neg}")

# Look at D_1^m / D_1^{m-1} coefficient-wise: is there a pattern?
print("\n--- Ratio structure D_1^m vs D_1^{m-1} ---")
D1 = {}
for m in range(1, 7):
    D1[m] = poly_sub(h[m], poly_shift(h[m-1], 1, max_q))

for m in range(2, 6):
    # Check D_1^m - q * D_1^{m-1} >= 0 (this would be D_2^m >= 0 check,
    # but specifically via domination at level 1)
    D2m = poly_sub(D1[m], poly_shift(D1[m-1], 2, max_q))
    D2m_sum = sum(D2m.values())
    neg = any(v < 0 for v in D2m.values())
    print(f"D_2^{m} = D_1^{m} - q^2*D_1^{m-1}: sum={D2m_sum}, expected = {4*4 * 5**(m-2) if m >= 2 else '?'}, neg={neg}")

print("\n--- Now for d=7 ---")
d, profile = 7, (3,2,2)
max_q = 100
g7, profiles7 = compute_gn_system(d, 5, max_q)

print("\n--- g_m for d=7, c=(3,2,2) ---")
for m in range(6):
    gm = g7[m].get(profile, {})
    print(f"g_{m}(1) = {sum(gm.values())}")

print("\n--- h_m for d=7 ---")
h7 = {}
for m in range(6):
    h7[m] = compute_hm(g7, profile, m, max_q)
    print(f"h_{m}(1) = {sum(h7[m].values())}, nonneg = {all(v >= 0 for v in h7[m].values())}")

print("\n--- D_1^m for d=7 ---")
for m in range(1, 6):
    D1m = poly_sub(h7[m], poly_shift(h7[m-1], 1, max_q))
    D1m_sum = sum(D1m.values())
    neg = any(v < 0 for v in D1m.values())
    print(f"D_1^{m}: sum={D1m_sum}, expected={11*12**(m-1)}, nonneg={not neg}")
    if m <= 2:
        print(f"  D_1^{m} = {poly_str(D1m)}")

# The KEY question: what makes D_1^m nonneg?
# D_1^m = h_m - q*h_{m-1} = (q;q)_m g_m - q (q;q)_{m-1} g_{m-1}
#        = (1-q^m)(q;q)_{m-1} g_m - q (q;q)_{m-1} g_{m-1}
# For this to be nonneg, we need (1-q^m) g_m - q/(q;q)_{m-1} ... no, this doesn't help
# because (q;q)_{m-1} has alternating signs.

# Let's try a different angle: look at g_m directly
# g_m = F_{c,m} - F_{c,m-1} = number of CPs with max = m
# Can we find an injection from {CPs with max=m-1} to {CPs with max=m}
# that increases size by exactly 1?
# That would give g_m(q) >= q * g_{m-1}(q) coefficient-wise, which is stronger
# than h_m >= q * h_{m-1}.

print("\n--- Check g_m >= q * g_{m-1} ---")
for m in range(1, 6):
    gm = g7[m].get(profile, {})
    gm1 = g7[m-1].get(profile, {})
    gm1_shifted = poly_shift(gm1, 1, max_q)
    diff = poly_sub(gm, gm1_shifted)
    neg = [(deg, v) for deg, v in sorted(diff.items()) if v < 0]
    diff_sum = sum(diff.values())
    print(f"g_{m} - q*g_{m-1}: sum={diff_sum}, negative terms = {neg[:10]}")

# If g_m >= q * g_{m-1} FAILS, then the injection at g-level doesn't exist.
# In that case, positivity of D_1^m = h_m - q*h_{m-1} relies on the (q;q)_m factor.

print("\n--- Check F_{c,m} >= F_{c,m-1} (obvious: more partitions with larger bound) ---")
# F_{c,m} = sum_{j=0}^m g_j, so F_{c,m} - F_{c,m-1} = g_m >= 0. Yes, trivially.

# What about F_{c,m} >= q * F_{c,m-1}?
print("\n--- Check F_{c,m} >= q * F_{c,m-1} ---")
for m in range(1, 6):
    Fm = {}
    for j in range(m+1):
        Fm = poly_add(Fm, g7[j].get(profile, {}))
    Fm1 = {}
    for j in range(m):
        Fm1 = poly_add(Fm1, g7[j].get(profile, {}))
    Fm1_shifted = poly_shift(Fm1, 1, max_q)
    diff = poly_sub(Fm, Fm1_shifted)
    neg = [(deg, v) for deg, v in sorted(diff.items()) if v < 0]
    print(f"F_{{c,{m}}} - q*F_{{c,{m-1}}}: neg = {neg[:5]}")

