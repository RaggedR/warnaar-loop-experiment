"""
Seed 7 — Deeper exploration: Z-algebra difference conditions vs cylindric partitions.

The Lepowsky-Wilson Z-algebra for a level-k representation gives a vacuum space
Omega_V spanned by Z-operator monomials satisfying "difference conditions."

For the basic representation of A_{k-1}^(1) at level 1:
  The vacuum space Omega_V has a basis of colored partitions satisfying
  "difference 2 conditions" (parts differ by at least 2).
  This gives the Rogers-Ramanujan identities!

For level-3 representations (which is what we need for k=3 cylindric partitions):
  The Z-algebra produces more complex difference conditions.

Key question: Can Q_{n,c}(q) be expressed as a sum over colored partitions
with difference conditions AND a bounded maximum part condition?

If so, the bounded version would be manifestly positive.

Let's test this by:
1. Computing Q_{n,c}(q) correctly for very small cases
2. Looking for a multisum decomposition that matches difference-condition partitions
"""

from math import gcd, comb
from collections import defaultdict
from itertools import product as iprod

def poly_ops():
    """Return polynomial operation functions."""
    def add(a, b):
        r = dict(a)
        for k, v in b.items():
            r[k] = r.get(k, 0) + v
            if r[k] == 0: del r[k]
        return r

    def sub(a, b):
        return add(a, {k: -v for k, v in b.items()})

    def mul(a, b, M=200):
        r = {}
        for i, ai in a.items():
            if i > M: continue
            for j, bj in b.items():
                if i+j > M: continue
                r[i+j] = r.get(i+j, 0) + ai*bj
        return {k:v for k,v in r.items() if v!=0}

    def shift(a, s):
        return {k+s: v for k, v in a.items()}

    def scale(a, c):
        return {k: v*c for k, v in a.items() if v*c != 0}

    return add, sub, mul, shift, scale

add, sub, mul, shift, scale = poly_ops()


def compute_Q_exact_small(c, n_val, max_q=100):
    """
    Compute Q_{n,c}(q) for a specific n value using careful enumeration.
    
    We need:
    1. All cylindric partitions of profile c grouped by max entry m
       (giving g_m(q) = number with max entry exactly m)
    2. Euler coefficients e_j(q) = (-1)^j q^{j(j+1)/2} / (q;q)_j
    3. [z^n]((zq;q)_inf * F(z,q)) = sum_{j=0}^n e_j * g_{n-j}
    4. Q_{n,c}(q) = (q^ell;q^ell)_n * above
    
    For exact computation, we need enough parts. With max entry m and 
    interlacing conditions for profile c with d = sum(c), the number of
    non-zero parts is bounded by m*d (approximately, since each d-step
    the max decreases).
    
    But actually, it could be more — need to think about this carefully.
    The interlacing chain: lam^0_j >= lam^1_{j+c_1} >= lam^2_{j+c_1+c_2} >= lam^0_{j+d}
    So lam^0_j >= lam^0_{j+d}. If lam^0_1 = m, then lam^0_{1+kd} >= 0 always holds.
    The parts are weakly decreasing, so we just need lam^0 to have at most
    m * d (roughly) non-zero parts... actually no, the interlacing doesn't force
    strict decrease. We just know lam^0_j >= lam^0_{j+d}, but lam^0_j could equal
    lam^0_{j+d}.
    
    For exact computation with small m, let's be generous with max_parts.
    """
    k = len(c)
    d = sum(c)
    ell = gcd(d, k)
    
    # For n_val small, max_parts can be generous
    # With max entry = m, total size <= m * max_parts * k
    max_parts = max(15, n_val * d + 5)
    
    def get(lam, j):
        """1-indexed."""
        return lam[j-1] if 0 < j <= len(lam) else 0
    
    def gen_parts(mx, mp):
        if mp == 0 or mx == 0:
            yield ()
            return
        yield ()
        for first in range(1, mx+1):
            for rest in gen_parts(first, mp-1):
                yield (first,) + rest
    
    # Compute g_m(q) for m = 0, ..., n_val
    g = {}
    for m in range(n_val + 1):
        parts = list(gen_parts(m, max_parts))
        count = defaultdict(int)
        
        for combo in iprod(parts, repeat=k):
            # Check interlacing
            ok = True
            for i in range(k):
                i_next = (i+1) % k
                c_shift = c[i_next] if i < k-1 else c[0]
                for j in range(1, max_parts + 1):
                    if get(combo[i], j) < get(combo[i_next], j + c_shift):
                        ok = False
                        break
                if not ok:
                    break
            
            if ok:
                # max entry exactly m? Need to subtract those with max < m
                mx = max(get(combo[i], 1) for i in range(k))
                if mx == m:
                    size = sum(sum(p) for p in combo)
                    if size <= max_q:
                        count[size] += 1
        
        g[m] = dict(count)
    
    # Euler coefficients
    def euler_coeff(j, mq):
        s = j*(j+1)//2
        sign = (-1)**j
        if s > mq:
            return {}
        inv = {0: 1}
        for i in range(1, j+1):
            new = dict(inv)
            for p in sorted(inv.keys()):
                pp = p + i
                while pp <= mq - s:
                    new[pp] = new.get(pp, 0) + new.get(pp - i, 0)
                    pp += i
            inv = new
        return {p + s: sign * v for p, v in inv.items() if p + s <= mq}
    
    # [z^n] = sum_{j=0}^n euler_coeff(j) * g_{n-j}
    coeff = {}
    for j in range(n_val + 1):
        ej = euler_coeff(j, max_q)
        gm = g.get(n_val - j, {})
        coeff = add(coeff, mul(ej, gm, max_q))
    
    # Q = (q^ell; q^ell)_n * coeff
    qpoch = {0: 1}
    for i in range(n_val):
        s = ell * (i + 1)
        new = dict(qpoch)
        for p, v in qpoch.items():
            if p + s <= max_q:
                new[p + s] = new.get(p + s, 0) - v
                if new[p + s] == 0: del new[p + s]
        qpoch = new
    
    Q = mul(qpoch, coeff, max_q)
    
    return Q, g


def poly_str(p, max_terms=25):
    if not p:
        return "0"
    terms = sorted(p.items())[:max_terms]
    parts = []
    for e, c in terms:
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    s = " + ".join(parts).replace("+ -", "- ") if parts else "0"
    if len(terms) < len(p):
        s += " + ..."
    return s


if __name__ == "__main__":
    # Start with the simplest case: c = (1,1,0), d=2
    # This should relate to Rogers-Ramanujan (modulus 5)
    print("CASE: c = (1,1,0), d=2, t=5")
    print("Expected Q(1) = ((3*4/6)-1)^n = 1^n = 1")
    print()
    
    for n in range(4):
        print(f"  Computing Q_{n}...")
        Q, g = compute_Q_exact_small((1,1,0), n, max_q=60)
        print(f"  Q_{n} = {poly_str(Q)}")
        q1 = sum(Q.values()) if Q else 0
        pos = all(v >= 0 for v in Q.values())
        print(f"  Q(1) = {q1}, all non-neg = {pos}")
        print(f"  g_m sizes: {[(m, sum(g[m].values()) if g[m] else 0) for m in range(n+1)]}")
        print()
    
    print("="*60)
    print("CASE: c = (2,1,1), d=4, t=7")
    print("Expected Q(1) = ((5*6/6)-1)^n = 4^n")
    print()
    
    for n in range(3):
        print(f"  Computing Q_{n}...")
        Q, g = compute_Q_exact_small((2,1,1), n, max_q=60)
        print(f"  Q_{n} = {poly_str(Q)}")
        q1 = sum(Q.values()) if Q else 0
        pos = all(v >= 0 for v in Q.values())
        print(f"  Q(1) = {q1}, all non-neg = {pos}")
        print()

    print("="*60)
    print("CASE: c = (2,2,1), d=5, t=8")
    print("Expected Q(1) = ((6*7/6)-1)^n = 6^n")
    print()

    for n in range(3):
        print(f"  Computing Q_{n}...")
        Q, g = compute_Q_exact_small((2,2,1), n, max_q=50)
        print(f"  Q_{n} = {poly_str(Q)}")
        q1 = sum(Q.values()) if Q else 0
        pos = all(v >= 0 for v in Q.values())
        print(f"  Q(1) = {q1}, all non-neg = {pos}")
        print()
