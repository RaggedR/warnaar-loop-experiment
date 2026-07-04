"""
Compute Q_{n,c}(q) for small cases using direct enumeration of cylindric partitions.
Seed 1, Layer 1.
"""
from math import gcd
from itertools import product as iterproduct

MAX_Q = 30

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
        if result[k] == 0:
            del result[k]
    return result

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=MAX_Q):
    result = {}
    for i, ai in a.items():
        if i > max_deg: continue
        for j, bj in b.items():
            if i+j > max_deg: continue
            result[i+j] = result.get(i+j, 0) + ai*bj
    return {k:v for k,v in result.items() if v != 0}

def gen_partitions(max_val, max_len):
    """Generate partitions with parts <= max_val and <= max_len parts, in weakly decreasing order."""
    if max_len == 0 or max_val == 0:
        yield ()
        return
    for first in range(max_val, -1, -1):
        if first == 0:
            yield ()
        else:
            for rest in gen_partitions(first, max_len - 1):
                yield (first,) + rest

def get_part(lam, j):
    """j is 1-indexed."""
    return lam[j-1] if j <= len(lam) else 0

def check_cylindric(lams, c, max_check=20):
    """Check cylindric interlacing for profile c."""
    k = len(c)
    for i in range(k):
        i_next = (i+1) % k
        shift = c[i_next]
        for j in range(1, max_check+1):
            left = get_part(lams[i], j)
            right = get_part(lams[i_next], j + shift)
            if left < right:
                return False
            if left == 0 and right == 0:
                break
    return True

def compute_Fcn(c, n, max_q, max_parts=6):
    """F_{c,n}(q) = sum_{Lambda in C_{c,n}} q^{|Lambda|}"""
    k = len(c)
    parts_list = list(gen_partitions(n, max_parts))
    result = {}

    if k == 3:
        for l0 in parts_list:
            s0 = sum(l0)
            if s0 > max_q: continue
            for l1 in parts_list:
                s1 = sum(l1)
                if s0+s1 > max_q: continue
                for l2 in parts_list:
                    s2 = sum(l2)
                    total = s0+s1+s2
                    if total > max_q:
                        continue
                    if check_cylindric([l0,l1,l2], c, max_parts+max(c)+2):
                        result[total] = result.get(total, 0) + 1
    return result

def inv_qpoch_series(j, max_deg):
    """1/(q;q)_j as power series up to max_deg."""
    result = {0: 1}
    for i in range(1, j+1):
        new = {}
        for k, v in result.items():
            m = 0
            while k + m*i <= max_deg:
                new[k+m*i] = new.get(k+m*i, 0) + v
                m += 1
        result = new
    return result

def euler_coeff(j, max_deg):
    """[z^j] of prod_{i>=1}(1-zq^i) = (-1)^j q^{j(j+1)/2} / (q;q)_j"""
    shift = j*(j+1)//2
    sign = (-1)**j
    if shift > max_deg:
        return {}
    inv = inv_qpoch_series(j, max_deg - shift)
    return {k+shift: sign*v for k,v in inv.items() if k+shift <= max_deg}

def qpoch_finite(a, step, n, max_deg):
    """(q^a; q^step)_n = prod_{i=0}^{n-1}(1 - q^{a+i*step})"""
    result = {0: 1}
    for i in range(n):
        pw = a + i*step
        if pw > max_deg: break
        new = dict(result)
        for k, v in result.items():
            if k+pw <= max_deg:
                new[k+pw] = new.get(k+pw, 0) - v
                if new[k+pw] == 0: del new[k+pw]
        result = new
    return result

def compute_Qnc(c, n_max, max_q, max_parts=5):
    d = sum(c)
    r = len(c)
    ell = gcd(d, r)

    # Compute F_{c,m} for m = 0..n_max
    F = {}
    for m in range(n_max+1):
        F[m] = compute_Fcn(c, m, max_q, max_parts)

    # g_m = [z^m] F_c(z,q) = F_{c,m} - F_{c,m-1}
    g = {}
    g[0] = dict(F[0])
    for m in range(1, n_max+1):
        g[m] = poly_sub(F[m], F[m-1])

    results = {}
    for n in range(n_max+1):
        # [z^n]((zq)_inf * F_c(z,q)) = sum_{j=0}^{n} euler_coeff(j) * g_{n-j}
        coeff = {}
        for j in range(n+1):
            aj = euler_coeff(j, max_q)
            gnj = g.get(n-j, {})
            coeff = poly_add(coeff, poly_mul(aj, gnj, max_q))

        # Multiply by (q^ell; q^ell)_n
        qell = qpoch_finite(ell, ell, n, max_q)
        Q = poly_mul(coeff, qell, max_q)
        results[n] = Q
    return results

def print_poly(p, name=""):
    if not p:
        print(f"  {name} = 0")
        return
    terms = sorted(p.items())
    parts = []
    for k, v in terms:
        if v == 0: continue
        if k == 0: parts.append(str(v))
        elif v == 1: parts.append(f"q^{k}")
        elif v == -1: parts.append(f"-q^{k}")
        else: parts.append(f"{v}q^{k}")
    s = " + ".join(parts).replace("+ -", "- ") if parts else "0"
    print(f"  {name} = {s}")
    neg = [(k,v) for k,v in terms if v < 0]
    if neg:
        print(f"  *** NEGATIVE COEFFICIENTS at powers: {[k for k,v in neg]}")
    else:
        print(f"  All non-negative: YES")
    print(f"  Value at q=1: {sum(v for k,v in terms)}")

if __name__ == "__main__":
    profiles = [
        ((1,1,0), 3, 5),  # d=2, small
        ((2,1,1), 3, 5),  # d=4
        ((2,2,1), 2, 4),  # d=5
        ((3,2,2), 2, 4),  # d=7, unproved
    ]

    for c, n_max, mp in profiles:
        d = sum(c)
        if d % 3 == 0:
            continue
        ell = gcd(d, 3)
        expected = (d+1)*(d+2)//6 - 1
        print(f"\n{'='*60}")
        print(f"c={c}, d={d}, ell={ell}, expected Q(1)={expected}^n")
        print(f"{'='*60}")
        try:
            results = compute_Qnc(c, n_max, MAX_Q, mp)
            for n in range(n_max+1):
                print(f"\nn={n}:")
                print_poly(results[n], f"Q_{{{n},c}}")
        except Exception as e:
            import traceback
            traceback.print_exc()
