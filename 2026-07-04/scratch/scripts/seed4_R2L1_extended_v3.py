"""
Extended path space enumeration for Q_2, d=4.
Fix the partition generation and carefully trace each contribution.
"""
from collections import defaultdict, Counter

def profiles(d):
    result = []
    for c0 in range(d+1):
        for c1 in range(d+1-c0):
            c2 = d - c0 - c1
            result.append((c0, c1, c2))
    return result

def emd_clockwise(c, cp):
    return 3*max(0, cp[1]-c[1], c[0]-cp[0]) + (cp[0]-c[0]) - (cp[1]-c[1])

def partitions_bounded_parts(max_part, max_total):
    """Generate all partitions with parts <= max_part and total <= max_total.
    Returns (partition_list, size)."""
    if max_part <= 0 or max_total <= 0:
        yield [], 0
        return
    def gen(mp, rem):
        yield [], 0
        for p in range(min(mp, rem), 0, -1):
            for rest, rest_size in gen(p, rem - p):
                yield [p] + rest, p + rest_size
    yield from gen(max_part, max_total)

def partitions_from_set(parts_set, max_total):
    """Generate all partitions with parts from parts_set, total <= max_total."""
    if not parts_set or max_total <= 0:
        yield [], 0
        return
    parts_list = sorted(parts_set)
    def gen(idx, rem):
        yield [], 0
        if idx >= len(parts_list):
            return
        p = parts_list[idx]
        if p > rem:
            return
        # Skip this part value
        yield from gen(idx + 1, rem)
        # Use this part value 1 or more times
        for count in range(1, rem // p + 1):
            for rest, rest_size in gen(idx + 1, rem - count * p):
                yield [p] * count + rest, count * p + rest_size
    yield from gen(0, max_total)

# Test partition generators
print("Test partitions_bounded_parts(2, 5):")
for p, s in partitions_bounded_parts(2, 5):
    print(f"  {p} (size {s})")

print("\nTest partitions_from_set({3, 6}, 10):")
for p, s in partitions_from_set({3, 6}, 10):
    print(f"  {p} (size {s})")

# Now the actual enumeration
d = 4
c = (2, 1, 1)
n = 2
max_weight = 25
profs = profiles(d)

# Precompute EMD
emd_tab = {}
for p1 in profs:
    for p2 in profs:
        emd_tab[(p1, p2)] = emd_clockwise(p1, p2)

def enum_paths(d, length, target, max_weight):
    """Enumerate EMD paths of given length ending at target, weight <= max_weight.
    Path = (c^0, c^1, ..., c^length) with c^length = target.
    Weight = sum_{k=1}^length k * EMD(c^k, c^{k-1})."""
    profs_local = profiles(d)
    if length == 0:
        yield [target], 0
        return
    
    def gen(step, prev, weight, path):
        """Build path forward: step goes from 1 to length."""
        if step > length:
            yield path, weight
            return
        for cp in profs_local:
            e = step * emd_tab[(cp, prev)]
            new_w = weight + e
            if new_w > max_weight:
                continue
            if step == length and cp != target:
                continue
            gen(step + 1, cp, new_w, path + [cp])
    
    for start in profs_local:
        if length == 1:
            e = emd_tab[(target, start)]
            if e <= max_weight:
                yield [start, target], e
        else:
            yield from gen(1, start, 0, [start])

# Extended path space for Q_2
# The formula (before multiplying by (q;q)_n):
# [z^n]((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} / (q;q)_{n-j} * F_{c,j}

# F_{c,j} = P_j(c) / (q^3;q^3)_j
# P_j(c) = sum over paths gamma of length j ending at c of q^{EMD_weight(gamma)}
# 1/(q^3;q^3)_j = sum over partitions mu with parts in {3,6,...,3j} of q^{|mu|}
# 1/(q;q)_m = sum over partitions rho with parts in {1,2,...,m} of q^{|rho|}

# So extended element: (gamma, mu, rho) where
#   gamma: path of length j ending at c
#   mu: partition with parts in {3, 6, ..., 3j}
#   m = n-j, rho: partition with parts in {1, 2, ..., m}
#   sign: (-1)^m
#   weight: EMD_weight(gamma) + |mu| + C(m+1,2) + |rho|

print(f"\n=== Extended path space for Q_{n}, d={d}, c={c} ===\n")

all_contributions = defaultdict(int)
detailed = []

for j in range(n+1):
    m = n - j
    sign = (-1)**m
    shift = m*(m+1)//2
    mu_set = set(range(3, 3*j+1, 3)) if j > 0 else set()
    
    count = 0
    for path, path_w in enum_paths(d, j, c, max_weight):
        remaining = max_weight - path_w - shift
        if remaining < 0:
            continue
        for mu, mu_size in partitions_from_set(mu_set, remaining):
            remaining2 = remaining - mu_size
            for rho, rho_size in partitions_bounded_parts(m, remaining2):
                total_w = path_w + mu_size + shift + rho_size
                all_contributions[total_w] += sign
                count += 1
                if total_w <= 12:
                    detailed.append((j, m, sign, path, mu, rho, total_w))
    
    print(f"j={j}: m={m}, sign={sign:+d}, shift=q^{shift}, mu_parts={mu_set if mu_set else '{}'}")
    print(f"  {count} extended elements enumerated (weight <= {max_weight})")

# Multiply by (q;q)_2 = (1-q)(1-q^2)
qq2 = {0: 1, 1: -1, 2: -1, 3: 1}
Q2_ext = defaultdict(int)
for w, coeff in all_contributions.items():
    for w2, c2 in qq2.items():
        Q2_ext[w + w2] += coeff * c2

print(f"\n--- Q_2 from extended path space (times (q;q)_2) ---")
for w in sorted(Q2_ext.keys()):
    if Q2_ext[w] != 0 and w <= 20:
        print(f"  q^{w}: {Q2_ext[w]}")

# Compare with direct computation
def poly_add(p1, p2):
    result = defaultdict(int, p1)
    for k, v in p2.items():
        result[k] += v
    return dict((k, v) for k, v in result.items() if v != 0)

def poly_shift(p, s):
    return {k+s: v for k, v in p.items()}

def poly_scale(p, s):
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
    d0_inv = d0
    result = {}
    for k in range(prec):
        val = num.get(k, 0)
        for j in range(k):
            if j in result and (k-j) in den:
                val -= result[j] * den[k-j]
        result[k] = val * d0_inv
    return {k: v for k, v in result.items() if v != 0}

def compute_P_paths(d, n_max, prec):
    profs_local = profiles(d)
    emd_table = {(c1, c2): emd_clockwise(c1, c2) for c1 in profs_local for c2 in profs_local}
    results = {}
    val = {p: {0: 1} for p in profs_local}
    results[0] = dict(val)
    for k in range(1, n_max+1):
        new_val = {}
        for cp in profs_local:
            s = {}
            for cpp in profs_local:
                e = emd_table[(cp, cpp)]
                s = poly_add(s, poly_shift(val[cpp], k * e))
            new_val[cp] = {kk: v for kk, v in s.items() if kk < prec}
        val = new_val
        results[k] = dict(val)
    return results

prec = 80
P_vals = compute_P_paths(d, 3, prec)

# h_m = (q;q)_m * P_m / (q^3;q^3)_m
h_vals = {}
for m_val in range(4):
    qq_m = q_ell_pochhammer_poly(1, m_val, prec)
    q3_m = q_ell_pochhammer_poly(3, m_val, prec)
    num = poly_mul_series(qq_m, P_vals[m_val][c], prec)
    h_vals[m_val] = poly_div_series(num, q3_m, prec)

# D_k^m
D = {}
for m_val in range(4):
    D[(0, m_val)] = h_vals[m_val]
for k in range(1, 4):
    for m_val in range(k, 4):
        D[(k, m_val)] = poly_add(D[(k-1, m_val)], poly_scale(poly_shift(D[(k-1, m_val-1)], k), -1))

Q2_direct = D[(2, 2)]
print(f"\n--- Q_2 from D_k^m (direct) ---")
for w in sorted(Q2_direct.keys()):
    if Q2_direct[w] != 0 and w <= 20:
        print(f"  q^{w}: {Q2_direct[w]}")

# Check match
print(f"\n--- Comparison ---")
all_keys = set(k for k in Q2_ext if Q2_ext[k] != 0 and k <= 20) | set(k for k in Q2_direct if Q2_direct[k] != 0 and k <= 20)
match = True
for w in sorted(all_keys):
    v1 = Q2_ext.get(w, 0)
    v2 = Q2_direct.get(w, 0)
    if v1 != v2:
        print(f"  MISMATCH at q^{w}: ext={v1}, direct={v2}")
        match = False
if match:
    print("  PERFECT MATCH for q^0 through q^20")

# Show the detailed cancellations
print(f"\n\n=== Detailed contributions to inner sum (before (q;q)_2) by j ===")
for w in range(13):
    parts = []
    for j in range(n+1):
        m = n - j
        sign = (-1)**m
        # Count contributions at this weight from this j
        count = sum(1 for dd in detailed if dd[0] == j and dd[6] == w)
        if count > 0:
            parts.append(f"j={j}: {sign:+d}*{count}")
    net = all_contributions.get(w, 0)
    if any(parts):
        print(f"  q^{w}: {' | '.join(parts)} => net = {net}")

