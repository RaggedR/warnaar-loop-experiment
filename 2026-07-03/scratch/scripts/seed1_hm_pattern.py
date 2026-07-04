"""
Seed 1: Verify h_m(1) = ((d+1)(d+2)/6)^m for all profiles.

If h_m(1) = ((d+1)(d+2)/6)^m, then:
  Q_n(1) = sum_j (-1)^j C(n,j) ((d+1)(d+2)/6)^{n-j}
         = ((d+1)(d+2)/6 - 1)^n
which is exactly the known evaluation!

This means: the h_m polynomials are q-analogues of ((d+1)(d+2)/6)^m.
"""

from collections import defaultdict
from math import gcd

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
    result = [0]*prec; result[0] = 1
    for k in range(1, m+1):
        if k >= prec: break
        new = list(result)
        for i in range(prec - k):
            new[i+k] -= result[i]
        result = new
    return result

def poly_mul(a, b, prec):
    result = [0]*prec
    for i in range(min(len(a), prec)):
        if a[i] == 0: continue
        for j in range(min(len(b), prec-i)):
            if b[j] != 0: result[i+j] += a[i]*b[j]
    return result

def compute_hm(gk, m, prec):
    gm_dict = extract_z(gk, m)
    gm = [0]*prec
    for w, v in gm_dict.items():
        if w < prec: gm[w] = v
    qm = qpoch(m, prec)
    return poly_mul(qm, gm, prec)

# ============================================================================

print("="*60)
print("VERIFYING h_m(1) = ((d+1)(d+2)/6)^m")
print("="*60)

profiles = [
    ((1,0,0), 6, 25),   # d=1, base=(2*3/6)=1
    ((1,1,0), 6, 30),   # d=2, base=(3*4/6)=2
    ((2,0,0), 4, 25),   # d=2, base=2
    ((2,1,1), 4, 35),   # d=4, base=(5*6/6)=5
    ((1,2,1), 4, 35),   # d=4, base=5
    ((2,2,1), 4, 30),   # d=5, base=(6*7/6)=7
    ((3,1,1), 3, 25),   # d=5, base=7
    ((3,2,2), 3, 20),   # d=7, base=(8*9/6)=12
]

for profile, m_max, max_w in profiles:
    d = sum(profile)
    if d % 3 == 0:
        continue
    base = (d+1)*(d+2)//6
    prec = max_w + 1
    
    print(f"\nc = {profile}, d = {d}, base = {base}")
    gk = compute_gk(profile, m_max + 2, max_w + 5)
    
    all_match = True
    for m in range(m_max + 1):
        hm = compute_hm(gk, m, prec)
        h_at_1 = sum(hm)
        expected = base ** m
        neg = any(hm[i] < 0 for i in range(prec))
        match = (h_at_1 == expected)
        if not match:
            all_match = False
        
        # Compact polynomial display
        nz = [(i, hm[i]) for i in range(prec) if hm[i] != 0]
        nz_str = str(nz[:8])
        if len(nz) > 8:
            nz_str += f"... ({len(nz)} terms)"
        
        status = "OK" if match else f"FAIL (got {h_at_1})"
        neg_str = "  ***NEG***" if neg else ""
        print(f"  h_{m}(1) = {h_at_1:8d}  expected = {expected:8d}  {status}  nonneg={not neg}{neg_str}")
    
    print(f"  ALL h_m(1) MATCH: {all_match}")

