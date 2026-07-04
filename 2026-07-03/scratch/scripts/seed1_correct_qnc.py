"""Compute Q_{n,c}(q) for d=4,5,7 using correct enumeration."""

from collections import defaultdict
from math import gcd
import time

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
    if shift > 0:
        init_ub = min(init_ub, max_part)
    else:
        init_ub = min(init_ub, get_part(nu_prev, 0) if nu_prev else 0)
        if init_ub <= 0:
            yield ()
            return
    for parts in _gen(0, init_ub, max_size):
        yield parts

def compute_gk(c, max_n, max_w):
    c0, c1, c2 = c
    result = defaultdict(int)
    count = 0
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
                count += 1
    return dict(result), count

def extract_z(gk, n):
    r = {}
    for (zn, qw), cnt in gk.items():
        if zn == n: r[qw] = r.get(qw, 0) + cnt
    return r

def inv_qj(j, prec):
    result = [0]*prec; result[0] = 1
    for k in range(1, j+1):
        if k >= prec: break
        for i in range(k, prec):
            result[i] += result[i-k]
    return result

def poly_mul(a, b, prec):
    result = [0]*prec
    for i in range(min(len(a), prec)):
        if a[i] == 0: continue
        for j in range(min(len(b), prec-i)):
            if b[j] != 0: result[i+j] += a[i]*b[j]
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

def show_Q(Q, n, c, expected_base, prec):
    q1 = sum(Q)
    expected = expected_base ** n
    neg = [(i, Q[i]) for i in range(prec) if Q[i] < 0]
    nz = [(i, Q[i]) for i in range(prec) if Q[i] != 0]
    print(f"  n={n}: Q(1)={q1}, expected={expected}, match={q1==expected}, nonneg={len(neg)==0}")
    if len(nz) <= 25:
        poly_str = " + ".join(f"{v}q^{i}" if v != 1 else f"q^{i}" for i, v in nz)
        poly_str = poly_str.replace("+ -", "- ")
        print(f"    Q = {poly_str}")
    else:
        print(f"    Q has {len(nz)} nonzero terms, max degree {max(i for i,v in nz)}")
        # Show first and last few
        print(f"    First: {nz[:8]}")
        print(f"    Last:  {nz[-5:]}")
    if neg:
        print(f"    *** NEGATIVE: {neg[:5]}")

# ============================================================================

cases = [
    ((1,1,0), 4, 25),    # d=2
    ((2,1,1), 3, 30),    # d=4
    ((2,2,1), 3, 25),    # d=5
    ((3,2,2), 2, 20),    # d=7
]

for profile, n_max, max_w in cases:
    d = sum(profile)
    if d % 3 == 0: continue
    ell = gcd(d, 3)
    expected_base = (d+1)*(d+2)//6 - 1
    
    print(f"\n{'='*60}")
    print(f"c = {profile}, d = {d}, ell = {ell}")
    print(f"Expected Q(1) = {expected_base}^n")
    
    gk_n = n_max + 2
    gk_w = max_w + n_max*(n_max+1)//2 + 5
    t0 = time.time()
    gk, cnt = compute_gk(profile, gk_n, gk_w)
    print(f"  {cnt} CPPs in {time.time()-t0:.1f}s")
    
    for n in range(n_max + 1):
        Q = compute_Q(profile, n, max_w, gk)
        show_Q(Q, n, profile, expected_base, max_w + 1)

