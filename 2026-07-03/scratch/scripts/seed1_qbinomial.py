"""
Seed 1: Look for q-binomial structure in Q_{n,c}(q).

The key formula: Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}
where h_m = (q;q)_m * g_m and g_m = [z^m] GK_c(z,q).

Let's verify this formula and check if there's a simpler expression.

Also check: does Q_n(q) factor nicely?
"""

from collections import defaultdict
from math import gcd

# Core enumeration (same as before)
def get_part(nu, j):
    return nu[j] if j < len(nu) else 0

def gen_partitions(max_part, max_size):
    def _gen(prev_val, remaining):
        if remaining <= 0 or prev_val <= 0:
            yield ()
            return
        yield ()
        for p in range(min(prev_val, remaining), 0, -1):
            for rest in _gen(p, remaining - p):
                yield (p,) + rest
    return _gen(max_part, max_size)

def gen_compatible(nu_prev, shift, max_part, max_size):
    max_len = len(nu_prev) + shift
    if max_len == 0:
        if shift == 0:
            yield ()
            return
        else:
            max_len = shift
    def _gen(pos, prev_val, remaining):
        if remaining <= 0 or prev_val <= 0:
            yield ()
            return
        if pos >= max_len:
            yield ()
            return
        yield ()
        if pos >= shift:
            ub = min(prev_val, get_part(nu_prev, pos - shift), remaining)
        else:
            ub = min(prev_val, max_part, remaining)
        for p in range(ub, 0, -1):
            for rest in _gen(pos + 1, p, remaining - p):
                yield (p,) + rest
    init_ub = min(max_part, max_size)
    if shift > 0: pass
    else:
        init_ub = min(init_ub, get_part(nu_prev, 0) if nu_prev else 0)
        if init_ub <= 0:
            yield (); return
    for parts in _gen(0, init_ub, max_size):
        yield parts

def compute_gk(c, max_n, max_w):
    c0, c1, c2 = c
    result = defaultdict(int)
    for nu1 in gen_partitions(max_n, max_w):
        s1 = sum(nu1)
        for nu2 in gen_compatible(nu1, c1, max_n, max_w - s1):
            s2 = sum(nu2)
            for nu3 in gen_compatible(nu2, c2, max_n, max_w - s1 - s2):
                s3 = sum(nu3)
                ok = True
                for j in range(len(nu3)):
                    if nu3[j] < get_part(nu1, j + c0):
                        ok = False; break
                if ok and len(nu1) > len(nu3) + c0:
                    ok = False
                if not ok: continue
                total = s1 + s2 + s3
                mx = max(get_part(nu1, 0), get_part(nu2, 0), get_part(nu3, 0))
                result[(mx, total)] += 1
    return dict(result)

def extract_z(gk, n):
    r = {}
    for (zn, qw), cnt in gk.items():
        if zn == n: r[qw] = r.get(qw, 0) + cnt
    return r

def qpoch(m, prec):
    """(q;q)_m as list"""
    result = [0]*prec; result[0] = 1
    for k in range(1, m+1):
        if k >= prec: break
        new = list(result)
        for i in range(prec - k):
            new[i+k] -= result[i]
        result = new
    return result

def qbinomial(n, k, prec):
    """[n choose k]_q as list of prec coefficients."""
    if k < 0 or k > n:
        return [0]*prec
    # [n;k]_q = (q;q)_n / ((q;q)_k * (q;q)_{n-k})
    # Compute as polynomial product
    num = qpoch(n, prec)
    d1 = qpoch(k, prec)
    d2 = qpoch(n-k, prec)
    den = poly_mul(d1, d2, prec)
    # Polynomial division: num / den (exact)
    return poly_div(num, den, prec)

def poly_mul(a, b, prec):
    result = [0]*prec
    for i in range(min(len(a), prec)):
        if a[i] == 0: continue
        for j in range(min(len(b), prec-i)):
            if b[j] != 0: result[i+j] += a[i]*b[j]
    return result

def poly_div(num, den, prec):
    """Exact polynomial division num/den, assuming it divides exactly."""
    result = [0]*prec
    remainder = list(num[:prec])
    # Find leading term of den
    den_lead = 0
    while den_lead < len(den) and den[den_lead] == 0:
        den_lead += 1
    if den_lead >= len(den):
        raise ValueError("Division by zero polynomial")
    
    for i in range(prec):
        if remainder[i] == 0:
            continue
        coeff = remainder[i] // den[den_lead]
        if remainder[i] % den[den_lead] != 0:
            raise ValueError(f"Non-exact division at position {i}")
        result[i - den_lead] = coeff  # Hmm, this doesn't work for general case
    
    # Better approach: long division
    result = [0]*prec
    rem = list(num[:prec])
    for i in range(prec):
        if i < den_lead:
            continue
        if rem[i] == 0:
            continue
        c = rem[i]
        if den[den_lead] != 0:
            c = rem[i] // den[den_lead]
        result[i - den_lead] = c
        for j in range(len(den)):
            if den_lead + j < prec and i - den_lead + j < prec:
                rem[i - den_lead + j] -= c * den[j]
    
    # Actually, this is getting complicated. Let me just use the formula:
    # [n;k]_q = prod_{i=1}^k (1-q^{n-k+i}) / (1-q^i)
    # = prod_{i=1}^k (1-q^{n-k+i}) * 1/(q;q)_k
    # Let me rewrite qbinomial without division.
    return result

def qbinomial_v2(n, k, prec):
    """[n;k]_q directly via the product formula."""
    if k < 0 or k > n:
        return [0]*prec
    if k == 0:
        r = [0]*prec; r[0] = 1; return r
    # [n;k] = prod_{i=1}^k (1-q^{n-i+1}) / (1-q^i)
    # = prod_{i=1}^k [n-i+1]_q / [i]_q  ... no, that's not simpler
    # Actually [n;k] = [n-1;k] + q^{n-k} [n-1;k-1]
    # Use recurrence
    cache = {}
    def qb(n, k):
        if k < 0 or k > n: return [0]*prec
        if k == 0 or k == n:
            r = [0]*prec; r[0] = 1; return r
        if (n,k) in cache: return cache[(n,k)]
        a = qb(n-1, k)
        b = qb(n-1, k-1)
        # shift b by q^{n-k}
        shift = n - k
        b_shifted = [0]*prec
        for i in range(prec):
            if i + shift < prec and b[i] != 0:
                b_shifted[i + shift] = b[i]
        result = [a[i] + b_shifted[i] for i in range(prec)]
        cache[(n,k)] = result
        return result
    return qb(n, k)

def inv_qj(j, prec):
    result = [0]*prec; result[0] = 1
    for k in range(1, j+1):
        if k >= prec: break
        for i in range(k, prec):
            result[i] += result[i-k]
    return result

def compute_Q(c, n, max_w, gk):
    d = sum(c); ell = gcd(d, 3); prec = max_w + 1
    g = {m: extract_z(gk, m) for m in range(n+1)}
    fn = [0]*prec
    for j in range(n+1):
        tri = j*(j+1)//2
        if tri >= prec: break
        sign = (-1)**j
        iqj = inv_qj(j, prec)
        gm = [0]*prec
        for w, v in g.get(n-j, {}).items():
            if w < prec: gm[w] = v
        prod = poly_mul(iqj, gm, prec)
        for w in range(prec):
            if w+tri < prec and prod[w] != 0:
                fn[w+tri] += sign * prod[w]
    qn = [0]*prec; qn[0] = 1
    for k in range(1, n+1):
        e = k*ell
        if e >= prec: break
        new = list(qn)
        for i in range(prec - e):
            new[i+e] -= qn[i]
        qn = new
    return poly_mul(fn, qn, prec)

# ============================================================================
# Verify Q_n = sum (-1)^j q^{j(j+1)/2} [n;j] h_{n-j} formula
# ============================================================================

print("="*60)
print("Verifying Q = sum (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}")
print("="*60)

c = (2,1,1); d = 4; max_w = 30; prec = max_w + 1
gk = compute_gk(c, 5, max_w + 8)

for n in range(4):
    # Method 1: direct Q computation
    Q1 = compute_Q(c, n, max_w, gk)
    
    # Method 2: via h_m
    # h_m = (q)_m * g_m
    def get_h(m):
        gm_dict = extract_z(gk, m)
        gm = [0]*prec
        for w, v in gm_dict.items():
            if w < prec: gm[w] = v
        qm = qpoch(m, prec)
        return poly_mul(qm, gm, prec)
    
    Q2 = [0]*prec
    for j in range(n+1):
        tri = j*(j+1)//2
        if tri >= prec: break
        sign = (-1)**j
        qb = qbinomial_v2(n, j, prec)
        hm = get_h(n - j)
        term = poly_mul(qb, hm, prec)
        for w in range(prec):
            if w + tri < prec and term[w] != 0:
                Q2[w + tri] += sign * term[w]
    
    match = all(Q1[i] == Q2[i] for i in range(prec))
    print(f"\n  n={n}: match={match}")
    if not match:
        for i in range(prec):
            if Q1[i] != Q2[i]:
                print(f"    diff at q^{i}: Q1={Q1[i]}, Q2={Q2[i]}")
                break

# Now look at the h_m themselves
print("\n" + "="*60)
print("h_m polynomials for c=(2,1,1), d=4")
print("="*60)

for m in range(5):
    gm_dict = extract_z(gk, m)
    gm = [0]*prec
    for w, v in gm_dict.items():
        if w < prec: gm[w] = v
    qm = qpoch(m, prec)
    hm = poly_mul(qm, gm, prec)
    nz = [(i, hm[i]) for i in range(prec) if hm[i] != 0]
    neg = [i for i in range(prec) if hm[i] < 0]
    print(f"  h_{m} = {nz}  nonneg={len(neg)==0}")

# Check: is h_m a known q-series? E.g., a q-binomial or Gaussian polynomial?
print("\nChecking if h_m is a q-binomial for c=(2,1,1):")
for m in range(4):
    gm_dict = extract_z(gk, m)
    gm = [0]*prec
    for w, v in gm_dict.items():
        if w < prec: gm[w] = v
    qm = qpoch(m, prec)
    hm = poly_mul(qm, gm, prec)
    # h_0 = 1 = [any;0]
    # h_1 = 3q + q^2 + q^3 = ?
    # Let's check [3;1] = 1+q+q^2 ... no that's different.
    # [4;1] = 1+q+q^2+q^3 ... no.
    # Maybe h_1 = (1+q)(1+q^2)? = 1+q+q^2+q^3 ... no.
    # h_1 = {1:3, 2:1, 3:1}. h_1(1) = 5 = (d+1) = 5.
    # h_1(1) should be... let me check what g_1(1) is.
    g1_total = sum(gm_dict.values())
    qm_at_1 = 0  # (q;q)_m at q=1 is 0 for m>=1 ... wait, (1;1)_m = m!
    # Actually (q;q)_m |_{q=1} = m! via L'Hopital or directly: (1-q)(1-q^2)...(1-q^m) -> 0
    # But we're working with polynomials, so h_m(1) = prod_{k=1}^m 0 * g_m(1)... 
    # Hmm no, h_m is a POLYNOMIAL, not a power series. (q;q)_m is a polynomial, g_m is a series.
    # When we multiply, only finitely many terms survive. h_m is the polynomial
    # (q;q)_m * g_m truncated appropriately.
    
    # Actually h_m(1) requires evaluating the polynomial. Let me just compute it.
    h_at_1 = sum(hm[i] for i in range(prec))
    print(f"  h_{m}(1) = {h_at_1}")

# Check factorization patterns in Q for d=4
print("\nLooking for patterns in Q polynomials (d=4):")
Q1 = compute_Q(c, 1, max_w, gk)
nz1 = [(i, Q1[i]) for i in range(prec) if Q1[i] != 0]
print(f"  Q_1 = {nz1}")
# Q_1 = 2q + q^2 + q^3 = q(2 + q + q^2)
# Is 2+q+q^2 = [3;1]_q = 1+q+q^2? No, coefficient of q^0 is 2, not 1.
# 2+q+q^2 = 1 + (1+q+q^2) = 1 + [3;1]? Kind of.
# Or: 2+q+q^2 = (1+q) + (1+q^2)? Hmm.
# For d=4, k=3, t=7. The formula might involve t-related quantities.

# Let's look at (d+1)(d+2)/6 - 1 = 5*6/6 - 1 = 4.
# Q_1(1) = 4 = 2+1+1. So the coefficients sum to 4.

print("\nGCD structure of Q coefficients:")
for n in range(4):
    Q = compute_Q(c, n, max_w, gk)
    nz = [Q[i] for i in range(prec) if Q[i] != 0]
    if nz:
        from math import gcd as mgcd
        from functools import reduce
        g = reduce(mgcd, nz)
        print(f"  Q_{n}: GCD of coefficients = {g}")

