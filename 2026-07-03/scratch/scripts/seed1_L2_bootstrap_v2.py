"""
Seed 1 Layer 2 v2: Focused bootstrap analysis with smaller parameters.
"""
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
        if shift == 0: yield (); return
        else: max_len = shift
    def _gen(pos, prev_val, remaining):
        if remaining <= 0 or prev_val <= 0: yield (); return
        if pos >= max_len: yield (); return
        yield ()
        if pos >= shift:
            ub = min(prev_val, get_part(nu_prev, pos - shift), remaining)
        else:
            ub = min(prev_val, max_part, remaining)
        for p in range(ub, 0, -1):
            for rest in _gen(pos + 1, p, remaining - p):
                yield (p,) + rest
    init_ub = min(max_part, max_size)
    if shift == 0:
        init_ub = min(init_ub, get_part(nu_prev, 0) if nu_prev else 0)
        if init_ub <= 0: yield (); return
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
                    if nu3[j] < get_part(nu1, j + c0): ok = False; break
                if ok and len(nu1) > len(nu3) + c0: ok = False
                if not ok: continue
                total = s1 + s2 + s3
                mx = max(get_part(nu1, 0), get_part(nu2, 0), get_part(nu3, 0))
                result[(mx, total)] += 1
    return dict(result)

def extract_gm(gk, m):
    r = {}
    for (zn, qw), cnt in gk.items():
        if zn == m: r[qw] = r.get(qw, 0) + cnt
    return r

def qpoch_poly(m):
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

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def compute_hm(gk, m, max_w=None):
    if m == 0: return {0: 1}
    gm = extract_gm(gk, m)
    if not gm: return {}
    qm = qpoch_poly(m)
    return poly_mul_dict(qm, gm, max_w)

def qbinom(n, j):
    if j < 0 or j > n: return {}
    if j == 0 or j == n: return {0: 1}
    table = {}
    for nn in range(n+1):
        for jj in range(min(nn, j)+1):
            if jj == 0 or jj == nn:
                table[(nn, jj)] = {0: 1}
            else:
                a = table[(nn-1, jj-1)]
                b = table[(nn-1, jj)]
                b_shifted = {k + nn - jj: v for k, v in b.items()}
                result = dict(a)
                for k, v in b_shifted.items():
                    result[k] = result.get(k, 0) + v
                table[(nn, jj)] = {k: v for k, v in result.items() if v != 0}
    return table[(n, j)]

def compute_Q_from_hm(h_polys, n, max_w=None):
    result = {}
    for j in range(n+1):
        sign = (-1)**j
        tri = j*(j+1)//2
        qbin = qbinom(n, j)
        hm = h_polys.get(n-j, {})
        if not hm or not qbin: continue
        prod = poly_mul_dict(qbin, hm, max_w)
        for k, v in prod.items():
            kk = k + tri
            if max_w is not None and kk > max_w: continue
            result[kk] = result.get(kk, 0) + sign * v
    return {k: v for k, v in result.items() if v != 0}

def poly_str(p, max_terms=30):
    if not p: return "0"
    parts = []
    for e in sorted(p.keys()):
        c = p[e]
        if c == 0: continue
        if e == 0: parts.append(str(c))
        elif c == 1: parts.append(f"q^{e}")
        elif c == -1: parts.append(f"-q^{e}")
        else: parts.append(f"{c}q^{e}")
        if max_terms and len(parts) >= max_terms:
            parts.append("...")
            break
    return " + ".join(parts).replace("+ -", "- ") if parts else "0"

def main():
    profile = (2, 1, 1)
    d = sum(profile)
    base = (d+1)*(d+2)//6
    n_max = 3
    max_w = 35

    print(f"Profile c = {profile}, d = {d}, base = {base}")

    gk_n = n_max + 1
    gk_w = max_w + n_max*(n_max+1)//2 + 10
    t0 = time.time()
    gk = compute_gk(profile, gk_n, gk_w)
    print(f"Enumerated CPPs in {time.time()-t0:.1f}s")

    h_polys = {}
    for m in range(n_max + 1):
        h_polys[m] = compute_hm(gk, m, max_w)
        h_sum = sum(h_polys[m].values()) if h_polys[m] else (1 if m == 0 else 0)
        print(f"h_{m}(1) = {h_sum}, expected = {base**m}")

    # Term analysis
    print(f"\n=== Term-by-term analysis ===")
    for n in range(1, n_max + 1):
        print(f"\nQ_{n} = sum_j (-1)^j q^{{j(j+1)/2}} [n;j] h_{{n-j}}:")
        terms = []
        for j in range(n+1):
            sign = (-1)**j
            tri = j*(j+1)//2
            qbin = qbinom(n, j)
            hm = h_polys.get(n-j, {})
            prod = poly_mul_dict(qbin, hm, max_w)
            shifted = {k + tri: v for k, v in prod.items() if max_w is None or k + tri <= max_w}
            s = sum(shifted.values()) if shifted else 0
            terms.append((j, sign, tri, shifted, sign*s))
            print(f"  j={j} ({'-' if sign<0 else '+'}): q^{tri} * [{n};{j}] * h_{n-j}, eval = {sign*s}")

        Q = compute_Q_from_hm(h_polys, n, max_w)
        q1 = sum(Q.values())
        expected = (base-1)**n
        neg = {k: v for k, v in Q.items() if v < 0}
        nz = sorted(Q.items())
        print(f"\n  Q_{n}(q) = {poly_str(Q)}")
        print(f"  Q_{n}(1) = {q1}, expected = {expected}, match = {q1==expected}")
        print(f"  nonneg = {len(neg)==0}")

    # Multiplicativity check
    print(f"\n=== Multiplicativity of h_m ===")
    h1 = h_polys[1]
    h2 = h_polys[2]
    h3 = h_polys[3]
    h1_sq = poly_mul_dict(h1, h1, max_w)
    h1_cube = poly_mul_dict(h1_sq, h1, max_w)
    
    # h_2 vs h_1^2
    print(f"\nh_2 vs h_1^2:")
    diff_2 = dict(h2)
    for k, v in h1_sq.items():
        diff_2[k] = diff_2.get(k, 0) - v
    diff_2 = {k: v for k, v in diff_2.items() if v != 0}
    print(f"  h_2 - h_1^2 = {poly_str(diff_2)}")
    
    # h_3 vs h_1^3
    print(f"\nh_3 vs h_1^3:")
    diff_3 = dict(h3)
    for k, v in h1_cube.items():
        diff_3[k] = diff_3.get(k, 0) - v
    diff_3 = {k: v for k, v in diff_3.items() if v != 0}
    print(f"  h_3 - h_1^3 = {poly_str(diff_3)}")
    
    # h_3 vs h_1 * h_2
    h1h2 = poly_mul_dict(h1, h2, max_w)
    diff_3b = dict(h3)
    for k, v in h1h2.items():
        diff_3b[k] = diff_3b.get(k, 0) - v
    diff_3b = {k: v for k, v in diff_3b.items() if v != 0}
    print(f"\nh_3 vs h_1*h_2:")
    print(f"  h_3 - h_1*h_2 = {poly_str(diff_3b)}")
    
    # KEY TEST: Can we write h_m = h_1^m + (nonneg correction)?
    # If h_m >= h_1^m coefficientwise, we might be able to bootstrap.
    print(f"\n=== Is h_m >= h_1^m coefficientwise? ===")
    for m in [2, 3]:
        h1_m = h_polys[1]
        for _ in range(m-1):
            h1_m = poly_mul_dict(h1_m, h_polys[1], max_w)
        diff = dict(h_polys[m])
        for k, v in h1_m.items():
            diff[k] = diff.get(k, 0) - v
        diff = {k: v for k, v in diff.items() if v != 0}
        neg = {k: v for k, v in diff.items() if v < 0}
        print(f"  h_{m} - h_1^{m}: {len(neg)} neg terms, {len(diff)-len(neg)} pos terms")
        if neg:
            print(f"    NEG: {dict(sorted(neg.items())[:5])}")
    
    # DIAGONAL ANALYSIS: decompose Q_n coefficient-by-coefficient
    print(f"\n=== Coefficient-by-coefficient Q_2 construction ===")
    n = 2
    # Q_2 = h_2 - q * [2;1] * h_1 + q^3 * h_0
    #      = h_2 - q*(1+q)*h_1 + q^3
    # Verify:
    q_2_manual = dict(h_polys[2])  # j=0 term: h_2
    qbin_21 = qbinom(2, 1)  # = 1 + q
    term_j1 = poly_mul_dict(qbin_21, h_polys[1], max_w)  # [2;1]*h_1
    # shift by q^1 and negate
    for k, v in term_j1.items():
        kk = k + 1  # q^{1*2/2} = q^1
        if max_w is None or kk <= max_w:
            q_2_manual[kk] = q_2_manual.get(kk, 0) - v
    # j=2 term: q^3 * h_0 = q^3
    q_2_manual[3] = q_2_manual.get(3, 0) + 1
    q_2_manual = {k: v for k, v in q_2_manual.items() if v != 0}
    
    print(f"  Q_2 (manual) = {poly_str(q_2_manual)}")
    print(f"  h_2 = {poly_str(h_polys[2])}")
    print(f"  [2;1]*h_1 = {poly_str(term_j1)}")
    print(f"  h_1 = {poly_str(h_polys[1])}")

if __name__ == "__main__":
    main()
