"""Debug the extended path space computation."""
from collections import defaultdict

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def emd_clockwise(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

d = 4
c = (2, 1, 1)
profs = profiles(d)

# Debug j=2: paths of length 2 ending at c
# Weight = 1*EMD(c^1, c^0) + 2*EMD(c^2, c^1), c^2 = c
print("Paths of length 2 ending at c =", c)
count = 0
for c0 in profs:
    for c1 in profs:
        e1 = emd_clockwise(c1, c0)
        e2 = emd_clockwise(c, c1)
        w = 1*e1 + 2*e2
        count += 1
        if w <= 10:
            print(f"  {c0} -> {c1} -> {c}: EMDs = ({e1}, {e2}), weight = {w}")

print(f"Total: {count} paths")
print(f"This should equal P_2(c)(1) = 225")

# Ah, these are paths with ANY starting point, ending at c.
# P_2(c) = sum over all c^0 of q^{1*EMD(c^1,c^0) + 2*EMD(c,c^1)}
# That has 15*15 = 225 paths, consistent.

# Now for j=2 in the extended space:
# m = 0, sign = +1, shift = 0
# mu: partitions with parts in {3, 6}
# rho: partitions with parts <= 0 => only empty partition

# The issue: 1/(q^3;q^3)_2 is what gives the mu partitions.
# (q^3;q^3)_2 = (1-q^3)(1-q^6)
# 1/(q^3;q^3)_2 = sum over partitions mu with parts from {3,6} repeated
# These are partitions into parts from the MULTISET {3, 6} with repetition.
# i.e., mu_i in {3, 6} for each part.

# But wait: 1/(1-q^3)(1-q^6) is the generating function for partitions
# with parts in {3, 6} (with repetition allowed).
# That's partitions of the form (6,...,6,3,...,3) = a copies of 6 and b copies of 3.
# Size = 6a + 3b.

# My partitions_from_set function had a bug -- it was yielding duplicates and
# the empty partition multiple times. Let me rewrite.

def partitions_from_parts(parts_list, max_total):
    """Partitions using the given part sizes (with repetition), total <= max_total.
    parts_list should be sorted ascending."""
    if not parts_list:
        yield [], 0
        return
    def gen(idx, rem):
        if idx >= len(parts_list) or rem <= 0:
            yield [], 0
            return
        p = parts_list[idx]
        for count in range(0, rem // p + 1):
            for rest, rest_size in gen(idx + 1, rem - count * p):
                yield [p] * count + rest, count * p + rest_size
    yield from gen(0, max_total)

print("\nPartitions from {3, 6} up to size 20:")
for mu, sz in partitions_from_parts([3, 6], 20):
    if mu:
        print(f"  {mu} (size {sz})")
    else:
        print(f"  [] (size 0)")

# Now recount j=2 contributions
print("\nj=2 contributions:")
j = 2
m = 0
sign = 1
shift = 0
mu_parts = [3, 6]
count = 0
for c0 in profs:
    for c1 in profs:
        e1 = emd_clockwise(c1, c0)
        e2 = emd_clockwise(c, c1)
        path_w = e1 + 2*e2
        for mu, mu_size in partitions_from_parts(mu_parts, 25 - path_w - shift):
            total_w = path_w + mu_size + shift
            count += 1
            if total_w <= 8:
                print(f"  path ({c0}->{c1}->{c}) w={path_w}, mu={mu} sz={mu_size}, total={total_w}")

print(f"Total j=2 elements: {count}")

# Now redo the full computation with the fixed partition function
print("\n=== Full extended path space, Q_2, d=4, c=(2,1,1) ===")
all_contrib = defaultdict(int)
max_w = 25

for j in range(3):
    m_val = 2 - j
    sign = (-1)**m_val
    shift = m_val*(m_val+1)//2
    mu_parts_list = sorted(range(3, 3*j+1, 3)) if j > 0 else []
    
    jcount = 0
    
    if j == 0:
        # Only path is [c] with weight 0
        # mu: empty (no mu parts for j=0)
        # rho: parts <= 2
        for rho, rho_sz in partitions_from_parts(list(range(1, m_val+1)), max_w - shift):
            total_w = shift + rho_sz
            all_contrib[total_w] += sign
            jcount += 1
    elif j == 1:
        # Paths of length 1 ending at c
        for c0 in profs:
            path_w = emd_clockwise(c, c0)
            for mu, mu_sz in partitions_from_parts(mu_parts_list, max_w - path_w - shift):
                for rho, rho_sz in partitions_from_parts(list(range(1, m_val+1)), max_w - path_w - mu_sz - shift):
                    total_w = path_w + mu_sz + shift + rho_sz
                    all_contrib[total_w] += sign
                    jcount += 1
    elif j == 2:
        # Paths of length 2 ending at c
        for c0 in profs:
            for c1 in profs:
                e1 = emd_clockwise(c1, c0)
                e2 = emd_clockwise(c, c1)
                path_w = e1 + 2*e2
                if path_w > max_w - shift:
                    continue
                for mu, mu_sz in partitions_from_parts(mu_parts_list, max_w - path_w - shift):
                    total_w = path_w + mu_sz + shift
                    all_contrib[total_w] += sign
                    jcount += 1
    
    print(f"j={j}: m={m_val}, sign={sign:+d}, shift={shift}, count={jcount}")

# Multiply by (q;q)_2
qq2 = {0: 1, 1: -1, 2: -1, 3: 1}
Q2_ext = defaultdict(int)
for w, coeff in all_contrib.items():
    for w2, c2 in qq2.items():
        Q2_ext[w + w2] += coeff * c2

print("\nQ_2 from extended path space:")
for w in sorted(Q2_ext.keys()):
    if Q2_ext[w] != 0 and w <= 15:
        print(f"  q^{w}: {Q2_ext[w]}")

# Direct computation for comparison
def poly_add(p1, p2):
    result = defaultdict(int, p1)
    for k, v in p2.items(): result[k] += v
    return dict((k, v) for k, v in result.items() if v != 0)

def poly_shift_fn(p, s):
    return {k+s: v for k, v in p.items()}

def poly_scale_fn(p, s):
    return {k: v*s for k, v in p.items() if v*s != 0}

def poly_mul_series(p1, p2, prec):
    result = defaultdict(int)
    for k1, v1 in p1.items():
        if k1 >= prec: continue
        for k2, v2 in p2.items():
            k = k1 + k2
            if k < prec: result[k] += v1 * v2
    return dict((k, v) for k, v in result.items() if v != 0)

def q_ell_pochhammer_poly(ell, n, prec):
    result = {0: 1}
    for i in range(1, n+1):
        result = poly_mul_series(result, {0: 1, ell*i: -1}, prec)
    return result

def poly_div_series(num, den, prec):
    d0 = den.get(0, 0)
    assert d0 in (1, -1)
    result = {}
    for k in range(prec):
        val = num.get(k, 0)
        for j_val in range(k):
            if j_val in result and (k-j_val) in den:
                val -= result[j_val] * den[k-j_val]
        result[k] = val * d0
    return {k: v for k, v in result.items() if v != 0}

prec = 80
P_vals = {}
val = {p: {0: 1} for p in profs}
P_vals[0] = dict(val)
emd_tab = {(p1, p2): emd_clockwise(p1, p2) for p1 in profs for p2 in profs}
for k in range(1, 4):
    new_val = {}
    for cp in profs:
        s = {}
        for cpp in profs:
            e = emd_tab[(cp, cpp)]
            s = poly_add(s, poly_shift_fn(val[cpp], k * e))
        new_val[cp] = {kk: v for kk, v in s.items() if kk < prec}
    val = new_val
    P_vals[k] = dict(val)

h_vals = {}
for m_val in range(4):
    qq_m = q_ell_pochhammer_poly(1, m_val, prec)
    q3_m = q_ell_pochhammer_poly(3, m_val, prec)
    num = poly_mul_series(qq_m, P_vals[m_val][c], prec)
    h_vals[m_val] = poly_div_series(num, q3_m, prec)

D = {}
for m_val in range(4):
    D[(0, m_val)] = h_vals[m_val]
for k in range(1, 4):
    for m_val in range(k, 4):
        D[(k, m_val)] = poly_add(D[(k-1, m_val)], poly_scale_fn(poly_shift_fn(D[(k-1, m_val-1)], k), -1))

Q2_direct = D[(2, 2)]
print("\nQ_2 from D_k^m (direct):")
for w in sorted(Q2_direct.keys()):
    if Q2_direct[w] != 0 and w <= 15:
        print(f"  q^{w}: {Q2_direct[w]}")

match = True
for w in range(20):
    v1 = Q2_ext.get(w, 0)
    v2 = Q2_direct.get(w, 0)
    if v1 != v2:
        print(f"MISMATCH at q^{w}: ext={v1}, direct={v2}")
        match = False
if match:
    print("MATCH through q^19!")
