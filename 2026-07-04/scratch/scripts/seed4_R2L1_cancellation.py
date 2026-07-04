"""
Study the cancellation pattern in Q_2 extended path space for d=4, c=(2,1,1).
Goal: identify a sign-reversing involution on negative-coefficient terms.

The extended element is (j, gamma, mu, rho) where:
- j: path length (0, 1, or 2 for n=2)
- gamma: EMD path of length j ending at c
- mu: partition with parts from {3, 6, ..., 3j}
- rho: partition with parts from {1, 2, ..., n-j}
- sign: (-1)^{n-j}
- q-weight: EMD_weight(gamma) + |mu| + C(n-j+1,2) + |rho|

Then Q_n = (q;q)_n * sum_elements sign * q^weight

The (q;q)_n = (1-q)(1-q^2) multiplication at the end is also a signed sum.
So really we need the inner sum (before (q;q)_n multiplication) to pair up
with the (q;q)_n factor to give a nonneg result.

OR: we could expand (q;q)_n into the extended space too.
(1-q)(1-q^2) = 1 - q - q^2 + q^3

So the FULL extended element is (j, gamma, mu, rho, sigma) where
sigma is a subset of {1, 2} (from the expansion of (q;q)_2 = prod(1-q^i))
and the total sign is (-1)^{n-j+|sigma|}, weight += sum(sigma).

Let me enumerate the FULL extended space and look for the involution.
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

def partitions_from_parts(parts_list, max_total):
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

d = 4
c = (2, 1, 1)
n = 2
max_weight = 15
profs = profiles(d)
emd_tab = {(p1, p2): emd_clockwise(p1, p2) for p1 in profs for p2 in profs}

# Enumerate full extended elements including (q;q)_n factor
# sigma: subset of {1, 2, ..., n}, contributes (-1)^|sigma| * q^{sum(sigma)}
from itertools import combinations

def subsets_of(s):
    """All subsets of a set s."""
    s = list(s)
    for r in range(len(s)+1):
        for combo in combinations(s, r):
            yield set(combo)

full_elements = []  # (sign, weight, j, gamma_desc, mu, rho, sigma)

for j in range(n+1):
    m = n - j
    inner_sign = (-1)**m
    shift = m*(m+1)//2
    mu_parts = sorted(range(3, 3*j+1, 3)) if j > 0 else []
    rho_parts = list(range(1, m+1)) if m > 0 else []
    
    if j == 0:
        paths = [("trivial", 0)]
    elif j == 1:
        paths = [(str(c0), emd_tab[(c, c0)]) for c0 in profs]
    else:
        paths = []
        for c0 in profs:
            for c1 in profs:
                w = emd_tab[(c1, c0)] + 2*emd_tab[(c, c1)]
                paths.append((f"{c0}->{c1}", w))
    
    for gdesc, gw in paths:
        if gw + shift > max_weight:
            continue
        for mu, mu_sz in partitions_from_parts(mu_parts, max_weight - gw - shift):
            for rho, rho_sz in partitions_from_parts(rho_parts, max_weight - gw - shift - mu_sz):
                inner_weight = gw + mu_sz + shift + rho_sz
                for sigma in subsets_of(set(range(1, n+1))):
                    sigma_weight = sum(sigma)
                    total_weight = inner_weight + sigma_weight
                    if total_weight > max_weight:
                        continue
                    total_sign = inner_sign * (-1)**len(sigma)
                    full_elements.append((total_sign, total_weight, j, gdesc, tuple(mu), tuple(rho), frozenset(sigma)))

# Count by (sign, weight)
pos_by_weight = defaultdict(int)
neg_by_weight = defaultdict(int)
for sign, weight, *_ in full_elements:
    if sign > 0:
        pos_by_weight[weight] += 1
    else:
        neg_by_weight[weight] += 1

print("Weight | +elements | -elements | net")
for w in range(max_weight+1):
    p = pos_by_weight.get(w, 0)
    ne = neg_by_weight.get(w, 0)
    if p or ne:
        print(f"  q^{w:2d}  |  {p:5d}     |  {ne:5d}     | {p-ne:+d}")

# Now look for patterns in the elements
print(f"\nTotal elements: {len(full_elements)}")
print(f"  Positive: {sum(pos_by_weight.values())}")
print(f"  Negative: {sum(neg_by_weight.values())}")
print(f"  Net: {sum(pos_by_weight.values()) - sum(neg_by_weight.values())}")

# Key question: can we find a weight-preserving, sign-reversing involution
# on the negative elements that pairs each negative element with a unique positive one?

# Let's look at the low-weight elements in detail
print("\n=== Elements at weight 0 ===")
for sign, weight, j, gdesc, mu, rho, sigma in full_elements:
    if weight == 0:
        print(f"  sign={sign:+d}, j={j}, path={gdesc}, mu={mu}, rho={rho}, sigma={set(sigma)}")

print("\n=== Elements at weight 1 ===")
for sign, weight, j, gdesc, mu, rho, sigma in full_elements:
    if weight == 1:
        print(f"  sign={sign:+d}, j={j}, path={gdesc}, mu={mu}, rho={rho}, sigma={set(sigma)}")

print("\n=== Elements at weight 2 ===")
for sign, weight, j, gdesc, mu, rho, sigma in full_elements:
    if weight == 2:
        print(f"  sign={sign:+d}, j={j}, path={gdesc}, mu={mu}, rho={rho}, sigma={set(sigma)}")

print("\n=== Elements at weight 3 ===")
for sign, weight, j, gdesc, mu, rho, sigma in full_elements:
    if weight == 3:
        print(f"  sign={sign:+d}, j={j}, path={gdesc}, mu={mu}, rho={rho}, sigma={set(sigma)}")

# Analyze the structure by (j, sigma) combination
print("\n=== Contribution by (j, |sigma|) ===")
for j in range(n+1):
    for s_size in range(n+1):
        m = n - j
        sign = (-1)**m * (-1)**s_size
        count = sum(1 for el in full_elements if el[2] == j and len(el[6]) == s_size)
        total_w = sum(el[1] for el in full_elements if el[2] == j and len(el[6]) == s_size)
        if count:
            print(f"  j={j}, |sigma|={s_size}: sign={sign:+d}, count={count}, total_weight={total_w}")

