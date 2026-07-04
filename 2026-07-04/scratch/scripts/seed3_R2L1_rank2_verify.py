"""
Seed 3, Round 2, Layer 1: Verify Warnaar's k=1,2 proof mechanism.
Compute Q_n for small d using direct enumeration of cylindric partitions.
"""
from functools import lru_cache

# Polynomial arithmetic (dict {exponent: coefficient})
def pa(): return {}
def p1(): return {0: 1}
def padd(p, q):
    r = dict(p)
    for k, v in q.items(): r[k] = r.get(k, 0) + v
    return {k: v for k, v in r.items() if v != 0}
def psub(p, q): return padd(p, {k: -v for k, v in q.items()})
def pmul(p, q):
    r = {}
    for k1, v1 in p.items():
        for k2, v2 in q.items(): r[k1+k2] = r.get(k1+k2, 0) + v1*v2
    return {k: v for k, v in r.items() if v != 0}
def pshift(p, s): return {k+s: v for k, v in p.items()}
def pnonneg(p): return all(v >= 0 for v in p.values())
def peval1(p): return sum(p.values()) if p else 0
def pdeg(p): return max(p.keys()) if p else -1
def pstr(p, mx=30):
    if not p: return "0"
    items = sorted(p.items())
    parts = []
    for k, v in items[:mx]:
        if v == 1: parts.append(f"q^{k}" if k else "1")
        elif v == -1: parts.append(f"-q^{k}" if k else "-1")
        else: parts.append(f"{v}q^{k}" if k else str(v))
    s = " + ".join(parts)
    if len(items) > mx: s += f" + ... ({len(items)} terms)"
    return s

def qpoch(n):
    if n <= 0: return p1()
    r = p1()
    for i in range(n): r = padd(r, pshift({k: -v for k, v in r.items()}, i+1))
    return r

@lru_cache(maxsize=50000)
def qbinom(n, k):
    if k < 0 or k > n or n < 0: return pa()
    if k == 0 or k == n: return p1()
    # [n choose k] = [n-1 choose k-1] + q^k [n-1 choose k]
    return padd(qbinom(n-1, k-1), pshift(qbinom(n-1, k), k))
# make hashable
qbinom_orig = qbinom
def qbinom(n, k):
    r = qbinom_orig(n, k)
    return dict(r) if isinstance(r, dict) else r

# Direct enumeration of bounded cylindric partitions
def enum_cp(c, n_max, size_max=40):
    """Enumerate CPs of profile c with max entry <= n_max, return {size: count}."""
    r = len(c)
    max_width = n_max + sum(c) + 3

    def get_part(lam, j):
        return lam[j-1] if j <= len(lam) else 0

    def gen_parts(max_val, max_len):
        """Generate partitions with parts <= max_val, length <= max_len."""
        if max_len == 0 or max_val == 0:
            yield ()
            return
        yield ()
        for first in range(1, max_val + 1):
            for rest in gen_parts(first, max_len - 1):
                yield (first,) + rest

    def check(lams):
        for i in range(r):
            inext = (i + 1) % r
            cn = c[inext]
            for j in range(1, max_width + 1):
                if get_part(lams[i], j) < get_part(lams[inext], j + cn):
                    return False
        return True

    all_p = list(gen_parts(n_max, max_width))
    counts = {}
    for l0 in all_p:
        for l1 in all_p:
            for l2 in all_p:
                if check([l0, l1, l2]):
                    s = sum(sum(l) for l in [l0, l1, l2])
                    if s <= size_max:
                        counts[s] = counts.get(s, 0) + 1
    return counts

# ============================================================
print("=" * 60)
print("PART 1: Enumerate CPs for d=2, compute Q_n")
print("=" * 60)

for profile in [(1,1,0), (2,0,0)]:
    d = sum(profile)
    ell = 1  # gcd(2,3) = 1
    print(f"\nProfile c={profile}, d={d}, ell={ell}")

    F = {}
    for m in range(5):
        if m == 0:
            F[0] = {0: 1}
        else:
            counts = enum_cp(profile, m, size_max=40)
            F[m] = counts if counts else {0: 1}
        print(f"  F_{{c,{m}}} = {pstr(F[m])}")

    # g_m = F_m - F_{m-1}
    g = {}
    g[0] = dict(F[0])
    for m in range(1, 5):
        g[m] = psub(F[m], F[m-1])

    # h_m = (q;q)_m * g_m
    h = {}
    for m in range(5):
        h[m] = pmul(qpoch(m), g[m])
    
    # D_k^m: D_0^m = h_m, D_k^m = D_{k-1}^m - q^k D_{k-1}^{m-1}
    for n in range(1, 4):
        D = {}
        for m in range(n+1):
            D[(0, m)] = h.get(m, pa())
        for k in range(1, n+1):
            for m in range(k, n+1):
                D[(k, m)] = psub(D[(k-1, m)], pshift(D.get((k-1, m-1), pa()), k))
        Q = D[(n, n)]
        print(f"  Q_{n} = {pstr(Q)}")
        print(f"    nonneg: {pnonneg(Q)}, Q_{n}(1) = {peval1(Q)}")

# ============================================================
print("\n" + "=" * 60)
print("PART 2: d=4 (k=1 for mod 7), profiles with d not div by 3")
print("=" * 60)

# d=4: profiles include (2,1,1), (3,1,0), (4,0,0), (2,2,0), (3,0,1), (1,2,1), etc.
# ell = gcd(4,3) = 1
# Q_n(1) = ((4+1)(4+2)/6 - 1)^n = (30/6 - 1)^n = 4^n

for profile in [(2,1,1), (1,1,2)]:
    d = sum(profile)
    ell = 1
    print(f"\nProfile c={profile}, d={d}, ell={ell}")
    
    F = {}
    for m in range(4):
        if m == 0:
            F[0] = {0: 1}
        else:
            counts = enum_cp(profile, m, size_max=50)
            F[m] = counts if counts else {0: 1}
        print(f"  F_{{c,{m}}} coeffs (first 15): {[F[m].get(i,0) for i in range(min(15, pdeg(F[m])+1 if F[m] else 1))]}")

    g = {0: dict(F[0])}
    for m in range(1, 4):
        g[m] = psub(F[m], F[m-1])

    h = {}
    for m in range(4):
        h[m] = pmul(qpoch(m), g[m])

    for n in range(1, 3):
        D = {}
        for m in range(n+1):
            D[(0, m)] = h.get(m, pa())
        for k in range(1, n+1):
            for m in range(k, n+1):
                D[(k, m)] = psub(D[(k-1, m)], pshift(D.get((k-1, m-1), pa()), k))
        Q = D[(n, n)]
        print(f"  Q_{n} = {pstr(Q)}")
        print(f"    nonneg: {pnonneg(Q)}, Q_{n}(1) = {peval1(Q)}")
