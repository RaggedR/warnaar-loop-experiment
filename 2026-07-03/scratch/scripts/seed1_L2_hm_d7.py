"""
Seed 1 Layer 2: Compute h_m(q) for d=5,7, m=0..4.
Uses direct enumeration (from seed1_correct_qnc.py) which is verified correct.
Needs enough max_w to get accurate h_m values.
"""

from collections import defaultdict
from math import gcd
import sys
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
    if shift > 0: pass
    else:
        init_ub = min(init_ub, get_part(nu_prev, 0) if nu_prev else 0)
        if init_ub <= 0:
            yield (); return
    for parts in _gen(0, init_ub, max_size):
        yield parts

def compute_gk(c, max_n, max_w):
    """Returns dict: (max_entry, weight) -> count."""
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

def extract_gm(gk, m):
    """Extract g_m(q) = [z^m] GK_c(z,q) as a dict: degree -> coefficient."""
    r = {}
    for (zn, qw), cnt in gk.items():
        if zn == m:
            r[qw] = r.get(qw, 0) + cnt
    return r

def qpoch_poly(m):
    """Compute (q;q)_m = prod_{i=1}^m (1-q^i) as a dict: degree -> coefficient."""
    result = {0: 1}
    for i in range(1, m + 1):
        new = {}
        for p, c in result.items():
            new[p] = new.get(p, 0) + c
            new[p + i] = new.get(p + i, 0) - c
        result = {k: v for k, v in new.items() if v != 0}
    return result

def poly_mul_dict(a, b, max_deg=None):
    result = {}
    for i, ai in a.items():
        if ai == 0: continue
        for j, bj in b.items():
            if bj == 0: continue
            k = i + j
            if max_deg is not None and k > max_deg: continue
            result[k] = result.get(k, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def compute_hm(gk, m, max_w=None):
    """h_m(q) = (q;q)_m * g_m(q)."""
    if m == 0:
        return {0: 1}
    gm = extract_gm(gk, m)
    if not gm:
        return {}
    qm = qpoch_poly(m)
    return poly_mul_dict(qm, gm, max_w)

def poly_str(p):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"

def main():
    profiles = [
        ((2,1,1), 4, 40),   # d=4
        ((2,2,1), 4, 40),   # d=5
        ((3,1,1), 4, 40),   # d=5
        ((3,2,2), 4, 35),   # d=7
        ((4,2,1), 4, 30),   # d=7
    ]

    for profile, m_max, max_w in profiles:
        d = sum(profile)
        if d % 3 == 0: continue
        base = (d+1)*(d+2)//6

        print(f"\n{'='*70}")
        print(f"Profile c = {profile}, d = {d}, base = {base}")
        print(f"Expected h_m(1) = {base}^m")
        print(f"{'='*70}")

        # Need max_n >= m_max and enough max_w
        gk_n = m_max + 1
        gk_w = max_w + 10

        t0 = time.time()
        gk, cnt = compute_gk(profile, gk_n, gk_w)
        elapsed = time.time() - t0
        print(f"  Enumerated {cnt} CPPs in {elapsed:.1f}s")

        for m in range(m_max + 1):
            hm = compute_hm(gk, m, max_w)
            h_sum = sum(hm.values()) if hm else (1 if m == 0 else 0)
            expected = base ** m
            neg_coeffs = {k: v for k, v in hm.items() if v < 0}

            print(f"\n  h_{m}(q):")
            print(f"    h_{m}(1) = {h_sum}, expected = {expected}, match = {h_sum == expected}")
            print(f"    nonneg = {len(neg_coeffs) == 0}")
            if neg_coeffs:
                print(f"    *** NEGATIVE: {dict(sorted(neg_coeffs.items())[:10])}")

            hm_sorted = sorted(hm.items())
            if len(hm_sorted) <= 25:
                print(f"    h_{m}(q) = {poly_str(hm)}")
            else:
                print(f"    {len(hm_sorted)} nonzero terms")
                print(f"    First 10: {hm_sorted[:10]}")
                print(f"    Last 5: {hm_sorted[-5:]}")

            if hm_sorted:
                print(f"    min deg = {hm_sorted[0][0]}, max deg = {hm_sorted[-1][0]}")

if __name__ == "__main__":
    main()
