"""
Compute P_n and Q_n using coefficient dictionaries (sparse polynomials).
"""
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
        if k1 >= prec:
            continue
        for k2, v2 in p2.items():
            k = k1 + k2
            if k < prec:
                result[k] += v1 * v2
    return dict((k, v) for k, v in result.items() if v != 0)

def q_ell_pochhammer_poly(ell, n, prec):
    """(q^ell; q^ell)_n = prod_{i=1}^n (1 - q^{ell*i})"""
    result = {0: 1}
    for i in range(1, n+1):
        factor = {0: 1, ell*i: -1}
        result = poly_mul_series(result, factor, prec)
    return result

def q_pochhammer_poly(a, n, prec):
    """(q^a; q)_n = prod_{i=0}^{n-1} (1 - q^{a+i})"""
    result = {0: 1}
    for i in range(n):
        factor = {0: 1, a+i: -1}
        result = poly_mul_series(result, factor, prec)
    return result

def poly_div_series(num, den, prec):
    """Compute num/den as power series, truncated to prec terms."""
    d0 = den.get(0, 0)
    assert d0 in (1, -1), f"Constant term {d0} not +-1"
    d0_inv = d0  # 1/1 = 1, 1/(-1) = -1
    result = {}
    for k in range(prec):
        val = num.get(k, 0)
        for j in range(k):
            if j in result and (k-j) in den:
                val -= result[j] * den[k-j]
        result[k] = val * d0_inv
    return {k: v for k, v in result.items() if v != 0}

def poly_str(p, max_terms=20):
    if not p:
        return "0"
    sorted_keys = sorted(p.keys())
    terms = []
    for k in sorted_keys[:max_terms]:
        v = p[k]
        if k == 0:
            terms.append(str(v))
        elif v == 1:
            terms.append("q^" + str(k))
        elif v == -1:
            terms.append("-q^" + str(k))
        else:
            terms.append(str(v) + "*q^" + str(k))
    s = " + ".join(terms).replace("+ -", "- ")
    if len(sorted_keys) > max_terms:
        s += " + ... (" + str(len(sorted_keys)) + " terms total)"
    return s

def compute_P_paths(d, n_max, prec=60):
    profs = profiles(d)
    emd_table = {}
    for c in profs:
        for cp in profs:
            emd_table[(c, cp)] = emd_clockwise(c, cp)
    
    results = {}
    val = {p: {0: 1} for p in profs}
    results[0] = dict(val)
    
    for k in range(1, n_max+1):
        new_val = {}
        for cp in profs:
            s = {}
            for cpp in profs:
                e = emd_table[(cp, cpp)]
                shifted = poly_shift(val[cpp], k * e)
                s = poly_add(s, shifted)
            new_val[cp] = {kk: v for kk, v in s.items() if kk < prec}
        val = new_val
        results[k] = dict(val)
        sample_p = profs[0]
        max_deg = max(val[sample_p].keys()) if val[sample_p] else 0
        print(f"  P_{k} computed, sample max degree: {max_deg}")
    
    return results

# Main computation
d = 4
prec = 80  # Need >= 6*max(k,m)^2 + 50 per Round 1 precision warning
print(f"=== d = {d}, prec = {prec} ===")
print("Computing P_n values...")
P_vals = compute_P_paths(d, n_max=3, prec=prec)

profs = profiles(d)
c = (2, 1, 1)

print(f"\n--- P values at c = {c} ---")
for n in range(4):
    p = P_vals[n][c]
    num_terms = len(p)
    total = sum(p.values())
    print(f"P_{n}: {num_terms} terms, P_{n}(1) = {total}, deg = {max(p.keys()) if p else 0}")
    if n <= 1:
        print(f"  = {poly_str(p, 25)}")

# Compute h_m = (q;q)_m * F_{c,m} = (q;q)_m * P_m / (q^3;q^3)_m
print(f"\n--- h_m values at c = {c} ---")
h_vals = {}
for m in range(4):
    qq_m = q_pochhammer_poly(1, m, prec)
    q3_m = q_ell_pochhammer_poly(3, m, prec)
    num = poly_mul_series(qq_m, P_vals[m][c], prec)
    h_m = poly_div_series(num, q3_m, prec)
    h_vals[m] = h_m
    max_deg = max(h_m.keys()) if h_m else 0
    neg_coeffs = {k: v for k, v in h_m.items() if v < 0}
    print(f"h_{m}: {len(h_m)} terms, h_{m}(1) = {sum(h_m.values())}, max_deg = {max_deg}")
    if neg_coeffs:
        print(f"  NEGATIVE coefficients: {dict(sorted(neg_coeffs.items())[:10])}")
    if m <= 1:
        print(f"  = {poly_str(h_m, 25)}")

# Compute Q_n using D_k^m formulation
# D_0^m = h_m
# D_k^m = D_{k-1}^m - q^k * D_{k-1}^{m-1}
# Q_n = D_n^n
print(f"\n--- D_k^m table and Q_n ---")
D = {}
for m in range(4):
    D[(0, m)] = h_vals[m]

for k in range(1, 4):
    for m in range(k, 4):
        dm = D[(k-1, m)]
        dm1 = D[(k-1, m-1)]
        shifted = poly_shift(dm1, k)
        D[(k, m)] = poly_add(dm, poly_scale(shifted, -1))

for n in range(1, 4):
    Q = D[(n, n)]
    neg = {k: v for k, v in Q.items() if v < 0}
    total = sum(Q.values())
    max_deg = max(Q.keys()) if Q else 0
    print(f"Q_{n} = D_{n}^{n}: {len(Q)} terms, Q_{n}(1) = {total}, max_deg = {max_deg}")
    if neg:
        print(f"  NEGATIVE coefficients found: {dict(sorted(neg.items())[:5])}")
    else:
        print(f"  ALL NONNEG")
    if n <= 2:
        print(f"  = {poly_str(Q, 30)}")

# EMD table
print(f"\n--- EMD table for d={d} (subset) ---")
sample = [(2,1,1), (1,2,1), (1,1,2), (0,2,2), (2,0,2), (2,2,0)]
print(f"{'c->c_prime':>25s} | EMD")
for cp in sample:
    for cpp in sample:
        e = emd_clockwise(cp, cpp)
        print(f"  {str(cp):>10s} -> {str(cpp):<10s} | {e}")

# Q_2 decomposition: which path/partition pairs contribute to each coefficient
print(f"\n\n=== Q_2 term-by-term on extended path space ===")
print(f"Q_2 = h_2 - (q + q^2)*h_1 + q^3")
print(f"    = h_2 - q*h_1 - q^2*h_1 + q^3")
print(f"")
print(f"Each term of h_m involves the EMD path formula.")
print(f"h_m = (q;q)_m * F_{{c,m}} where F_{{c,m}} = P_m / (q^3;q^3)_m")
print(f"")
print(f"The challenge: h_m involves division by (q^3;q^3)_m,")
print(f"introducing an infinite series expansion. This is the")
print(f"cross-N obstruction mentioned in Round 1.")
print(f"")

# Let's try a different approach: work purely at the P_n level
# Q_n = (q;q)_n * sum_{j=0}^n (-1)^{n-j} q^{C(n-j+1,2)} P_j / ((q^3;q^3)_j * (q;q)_{n-j})
# For n=2:
# Q_2 = (q;q)_2 * [P_2/(q^3;q^3)_2 - q*P_1/((q^3;q^3)_1*(q;q)_1) + q^3*P_0/((q^3;q^3)_0*(q;q)_2)]
# = (q;q)_2*P_2/(q^3;q^3)_2 - (q;q)_2*q*P_1/((1-q^3)(1-q)) + q^3

# Let's see: (q;q)_2 / (1-q) = 1-q^2
# and (q;q)_2 / (q^3;q^3)_2 = (1-q)(1-q^2) / ((1-q^3)(1-q^6))

# Number of paths for P_n
for n in range(4):
    total_paths = sum(P_vals[n][cp].get(0, 0) for cp in profs)
    print(f"Number of paths of length {n} (coefficient of q^0 in sum over all profiles): P_{n}(c) has {sum(P_vals[n][c].values())} total")

# Critical computation: can we write Q_2 directly as a sum over an extended space?
# The extended space would be pairs (path, partition from (zq;q)_inf expansion)
# An element is (path gamma of length j, partition mu of size n-j parts)
# Weight: q^{EMD_weight(gamma)} * (-1)^{n-j} * q^{mu_weight}

# For the involution: we need to pair up elements with opposite signs
# Signs come from (-1)^{n-j}, so paths of even length j have sign (-1)^{n-j}
# For n=2: j=0 has sign +1, j=1 has sign -1, j=2 has sign +1

# But F_{c,j} is not P_j -- it's P_j / (q^3;q^3)_j, which has an infinite series expansion.
# This is the fundamental difficulty.

# ALTERNATIVE: work with P_j directly and the transform
# Q_n * (q^3;q^3)_0 * ... = ??
# No, the denominators differ per j.

# Let me instead check: what happens if we expand (q^3;q^3)_j^{-1} as a sum over partitions
# with parts divisible by 3, bounded by 3j?
# 1/(q^3;q^3)_j = sum over partitions into parts from {3, 6, 9, ..., 3j} of q^{|mu|}
# = sum_{mu: parts in {3,6,...,3j}} q^{|mu|}

# So F_{c,j} = P_j * (sum over such partitions q^{|mu|})
# And the extended path space element is: (path gamma of length j, partition mu with parts in {3,6,...,3j}, partition nu with |nu|=n-j from (zq;q)_inf)

# Actually, (zq;q)_inf contributes: z^m * (-1)^m * q^{C(m+1,2)} / (q;q)_m
# The 1/(q;q)_m factor gives a sum over partitions with parts <= m
# So element in extended space: z^m * partition rho with parts <= m, weight q^{C(m+1,2) + |rho|}

# Total extended element for [z^n] coefficient:
# (gamma, mu, m, rho) where:
#   - gamma: EMD path of length j ending at c
#   - mu: partition with parts in {3, 6, ..., 3j}
#   - m = n - j
#   - rho: partition with parts <= m
#   - sign: (-1)^m
#   - weight: q^{EMD_weight(gamma) + |mu| + C(m+1,2) + |rho|}

# Multiplied by (q;q)_n outside.

# This is the extended path space! Let me enumerate it for Q_2, d=4.

print(f"\n=== Enumerating extended path space for Q_2, c = {c} ===")
# n = 2
# j ranges from 0 to 2, m = 2-j

# For each j, we need:
# - All EMD paths of length j ending at c
# - All partitions mu with parts in {3, 6, ..., 3j}
# - m = 2-j, rho = partition with parts <= m
# - sign = (-1)^m
# - weight = EMD_weight + |mu| + C(m+1,2) + |rho|

# Then Q_2 = (q;q)_2 * sum of sign * q^weight

# Let's enumerate up to total weight <= 15

max_weight = 20

def partitions_with_parts_in(parts_set, max_size):
    """Generate all partitions with parts from parts_set and total size <= max_size."""
    if not parts_set:
        yield [], 0
        return
    parts_list = sorted(parts_set, reverse=True)
    
    def gen(remaining, max_part_idx, current):
        yield list(current), max_size - remaining if remaining < max_size else sum(current)
        # Actually let me just do it differently
        pass
    
    # Simple recursive generation
    def generate(max_part_idx, remaining):
        yield []
        if max_part_idx >= len(parts_list):
            return
        p = parts_list[max_part_idx]
        for count in range(1, remaining // p + 1):
            for rest in generate(max_part_idx + 1, remaining - count * p):
                yield [p] * count + rest
        yield from generate(max_part_idx + 1, remaining)
    
    for part in generate(0, max_size):
        yield part, sum(part)

def partitions_parts_at_most(m, max_size):
    """Generate partitions with parts <= m and total <= max_size."""
    if m <= 0:
        yield [], 0
        return
    def generate(max_part, remaining):
        yield []
        for p in range(min(max_part, remaining), 0, -1):
            for rest in generate(p, remaining - p):
                yield [p] + rest
    for part in generate(m, max_size):
        yield part, sum(part)

def enum_paths(d, length, target, max_weight):
    """Enumerate all EMD paths of given length ending at target, with weight <= max_weight."""
    profs = profiles(d)
    if length == 0:
        yield [target], 0
        return
    
    # DP: generate paths backward
    def gen(k, current_end, current_weight, path):
        if k == 0:
            yield list(reversed(path)) + [current_end], current_weight
            return
        for cp in profs:
            e = emd_clockwise(current_end, cp)  # EMD(c^k, c^{k-1}) where c^k = current_end
            # Wait, in the path formula: weight = sum_{k=1}^n k * EMD(c^k, c^{k-1})
            # At step k from the end, the EMD contribution is (length - k + 1) * EMD
            # Actually, let me re-index. path = c^0, ..., c^length
            # weight = sum_{i=1}^{length} i * EMD(c^i, c^{i-1})
            # At step i, the contribution is i * EMD(c^i, c^{i-1})
            step = length - k + 1
            new_weight = current_weight + step * emd_clockwise(current_end, cp)
            if new_weight <= max_weight:
                yield from gen(k - 1, cp, new_weight, path + [current_end])
    
    # Actually let me build forward instead
    def gen_forward(step, prev, weight, path):
        """step goes from 1 to length."""
        if step > length:
            if prev == target:
                yield path, weight
            return
        for cp in profs:
            e = step * emd_clockwise(cp, prev)
            new_w = weight + e
            if new_w <= max_weight:
                if step == length and cp != target:
                    continue
                gen_forward(step + 1, cp, new_w, path + [cp])
    
    for start in profs:
        yield from gen_forward(1, start, 0, [start])

# Enumerate the extended path space
from collections import Counter

contributions = Counter()  # weight -> net coefficient (before (q;q)_n multiplication)

for j in range(3):  # j = 0, 1, 2
    m = 2 - j
    sign = (-1)**m
    shift = m * (m + 1) // 2  # C(m+1, 2)
    
    # mu parts: {3, 6, ..., 3j}
    mu_parts = set(range(3, 3*j+1, 3)) if j > 0 else set()
    
    path_count = 0
    for path, path_weight in enum_paths(d, j, c, max_weight):
        for mu, mu_size in partitions_with_parts_in(mu_parts, max_weight - path_weight - shift):
            for rho, rho_size in partitions_parts_at_most(m, max_weight - path_weight - mu_size - shift):
                total_w = path_weight + mu_size + shift + rho_size
                if total_w <= max_weight:
                    contributions[total_w] += sign
                    path_count += 1
    
    print(f"j={j}, m={m}, sign={sign}, shift={shift}, mu_parts={mu_parts}: {path_count} elements enumerated")

# Now multiply by (q;q)_2 = (1-q)(1-q^2) = 1 - q - q^2 + q^3
qq2 = {0: 1, 1: -1, 2: -1, 3: 1}

print(f"\nRaw inner sum (before (q;q)_2 multiplication):")
for w in sorted(contributions.keys())[:25]:
    print(f"  q^{w}: {contributions[w]}")

Q2_check = defaultdict(int)
for w1, v1 in contributions.items():
    for w2, v2 in qq2.items():
        Q2_check[w1 + w2] += v1 * v2

print(f"\nQ_2 from extended path space:")
for w in sorted(Q2_check.keys())[:25]:
    if Q2_check[w] != 0:
        print(f"  q^{w}: {Q2_check[w]}")

# Compare with direct computation
Q2_direct = D[(2, 2)]
print(f"\nQ_2 from D_k^m (direct):")
for w in sorted(Q2_direct.keys())[:25]:
    print(f"  q^{w}: {Q2_direct[w]}")

# Check agreement
match = True
all_keys = set(Q2_check.keys()) | set(Q2_direct.keys())
for w in sorted(all_keys):
    v1 = Q2_check.get(w, 0)
    v2 = Q2_direct.get(w, 0)
    if v1 != v2 and w <= max_weight:
        print(f"MISMATCH at q^{w}: path_space={v1}, direct={v2}")
        match = False

if match:
    print("MATCH confirmed for coefficients up to q^" + str(max_weight))

