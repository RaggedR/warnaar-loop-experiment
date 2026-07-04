"""
Seed 1 Layer 2: Investigate the Q_1 -> Q_n bootstrap.

Given h_m >= 0 and h_m(1) = base^m, is there a q-analogue of the binomial 
theorem that implies positivity of the alternating q-binomial transform?

Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n choose j]_q h_{n-j}

At q=1: Q_n(1) = sum (-1)^j C(n,j) base^{n-j} = (base-1)^n.

Key idea: In the ordinary case, (x-1)^n = sum (-1)^j C(n,j) x^{n-j} is
non-negative for x >= 1 because it equals (x-1)^n and x >= 1 => x-1 >= 0.

For the q-analogue, we need a q-version of this argument. 

Approach 1: q-binomial theorem
  The Cauchy q-binomial theorem says:
  sum_{j=0}^n (-1)^j q^{j(j-1)/2} [n;j] x^j = (x;q)_n = prod (1-xq^i)
  
  NOTE the exponent is j(j-1)/2, not j(j+1)/2!
  Our formula has j(j+1)/2 = j(j-1)/2 + j.

  So: Q_n = sum_j (-1)^j q^{j(j-1)/2} * q^j * [n;j] h_{n-j}
           = sum_j (-1)^j q^{j(j-1)/2} [n;j] (q * h_{n-j})   -- not quite right
  
  Actually q^j multiplied with h_{n-j} gives a shifted polynomial.

Approach 2: Rewrite Q_n using the q-binomial theorem applied differently.
  Let's define f_m = h_m / base^m. Then f_m(1) = 1 and 
  Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j] base^{n-j} f_{n-j}
      = base^n * sum_j (-1)^j q^{j(j+1)/2} [n;j] (1/base)^j f_{n-j}

  Hmm, this doesn't help directly.

Approach 3: Write h_m = sum_alpha c_alpha(m) q^alpha where c_alpha(m) >= 0.
  Then Q_n = sum_alpha q^alpha sum_j (-1)^j q^{j(j+1)/2} [n;j] c_alpha(n-j).
  
  Positivity of Q_n reduces to showing that for each alpha, the inner sum
  sum_j (-1)^j q^{j(j+1)/2} [n;j] c_alpha(n-j) has nonneg q^beta coefficients
  for all beta. But c_alpha(m) is just a number, so the inner sum is
  c_alpha(n-j) * (-1)^j * q^{j(j+1)/2} * [n;j].
  
  This reduces to: for each fixed power of q in h_{n-j}, the contribution
  from different j values must cancel to give non-negative result.

Approach 4: Think of Q_n as a q-difference operator applied to {h_m}.
  The operator Delta_q^n applied to h at position n is:
  (Delta_q)^n h_0 = sum_{j=0}^n (-1)^j [n;j] q^{j(j-1)/2} h_{n-j}
  
  But our formula has q^{j(j+1)/2} = q^j * q^{j(j-1)/2}.
  
  So Q_n = sum_j (-1)^j [n;j] q^{j(j-1)/2} * q^j * h_{n-j}
  
  If we define h_m^*(q) = q^{-m} h_m(q) (shift), then q^j h_{n-j} = q^j q^{n-j} h^*_{n-j}
  = q^n h^*_{n-j}... no, that doesn't work because h_m has general coefficients.

Let me just compute and study the structure numerically.
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

def compute_hm(gk, m, max_w=None):
    if m == 0: return {0: 1}
    gm = extract_gm(gk, m)
    if not gm: return {}
    qm = qpoch_poly(m)
    return poly_mul_dict(qm, gm, max_w)

def qbinom(n, j):
    """Compute [n choose j]_q as a polynomial dict."""
    if j < 0 or j > n: return {}
    # [n choose j]_q = (q;q)_n / ((q;q)_j * (q;q)_{n-j})
    # More practical: build via recurrence
    # [n;0] = 1, [n;n] = 1, [n;j] = [n-1;j-1] + q^{n-j} [n-1;j]
    if j == 0 or j == n: return {0: 1}
    # Use dynamic programming
    table = {}
    for nn in range(n+1):
        for jj in range(min(nn, j)+1):
            if jj == 0 or jj == nn:
                table[(nn, jj)] = {0: 1}
            else:
                # [nn;jj] = [nn-1;jj-1] + q^{nn-jj} * [nn-1;jj]
                a = table[(nn-1, jj-1)]
                b = table[(nn-1, jj)]
                # shift b by nn-jj
                b_shifted = {k + nn - jj: v for k, v in b.items()}
                # add
                result = dict(a)
                for k, v in b_shifted.items():
                    result[k] = result.get(k, 0) + v
                table[(nn, jj)] = {k: v for k, v in result.items() if v != 0}
    return table[(n, j)]

def compute_Q_from_hm(h_polys, n, max_w=None):
    """
    Q_n = sum_{j=0}^n (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}(q)
    """
    result = {}
    for j in range(n+1):
        sign = (-1)**j
        tri = j*(j+1)//2
        qbin = qbinom(n, j)
        hm = h_polys.get(n-j, {})
        if not hm or not qbin: continue
        
        # Multiply qbin * hm
        prod = poly_mul_dict(qbin, hm, max_w)
        
        # Shift by tri and apply sign
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
    # Focus on d=4 first (well-studied) then d=7
    profiles = [
        ((2,1,1), 4, 50),  # d=4
        ((3,2,2), 3, 35),  # d=7
    ]

    for profile, n_max, max_w in profiles:
        d = sum(profile)
        base = (d+1)*(d+2)//6

        print(f"\n{'='*70}")
        print(f"Profile c = {profile}, d = {d}, base = {base}")
        print(f"{'='*70}")

        gk_n = n_max + 1
        gk_w = max_w + n_max*(n_max+1)//2 + 10
        t0 = time.time()
        gk = compute_gk(profile, gk_n, gk_w)
        print(f"  Enumerated CPPs in {time.time()-t0:.1f}s")

        # Compute h_m for all needed m
        h_polys = {}
        for m in range(n_max + 1):
            h_polys[m] = compute_hm(gk, m, max_w)
            h_sum = sum(h_polys[m].values()) if h_polys[m] else (1 if m == 0 else 0)
            print(f"  h_{m}(1) = {h_sum}, expected = {base**m}")

        # Compute Q_n from h_m and verify
        print(f"\n  Q_n from h_m decomposition:")
        for n in range(n_max + 1):
            Q = compute_Q_from_hm(h_polys, n, max_w)
            q1 = sum(Q.values())
            expected = (base - 1)**n
            neg = {k: v for k, v in Q.items() if v < 0}
            nz = sorted(Q.items())

            print(f"\n  Q_{n}(q) from h_m:")
            print(f"    Q_{n}(1) = {q1}, expected = {expected}, match = {q1 == expected}")
            print(f"    nonneg = {len(neg) == 0}")
            if neg:
                print(f"    *** NEGATIVE: {dict(sorted(neg.items())[:5])}")
            if len(nz) <= 25:
                print(f"    Q_{n}(q) = {poly_str(Q)}")
            else:
                print(f"    {len(nz)} terms, min_deg={nz[0][0]}, max_deg={nz[-1][0]}")

        # Investigate structure: what is the decomposition of Q_n into 
        # terms from even j vs odd j?
        print(f"\n  === Term-by-term analysis of Q_n ===")
        for n in [2, 3]:
            if n > n_max: break
            print(f"\n  Q_{n} term analysis:")
            for j in range(n+1):
                sign = (-1)**j
                tri = j*(j+1)//2
                qbin = qbinom(n, j)
                hm = h_polys.get(n-j, {})
                prod = poly_mul_dict(qbin, hm, max_w)
                # shift by tri
                shifted = {k + tri: v for k, v in prod.items() if max_w is None or k + tri <= max_w}
                s = sum(shifted.values()) if shifted else 0
                print(f"    j={j}: sign={sign:+d}, shift=q^{tri}, [n;j]_q*h_{n-j}, sum = {sign*s}")
                if shifted:
                    sk = sorted(shifted.keys())
                    print(f"      deg range: [{sk[0]}, {sk[-1]}], #terms={len(shifted)}")

        # Key test: for the q-binomial theorem approach, check if 
        # sum_j (-1)^j q^{j(j-1)/2} [n;j] x^j = (x;q)_n
        # matches our structure when x = q * (something from h)
        print(f"\n  === Cauchy q-binomial theorem comparison ===")
        # Our formula: Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j] h_{n-j}
        #            = sum_j (-1)^j q^{j(j-1)/2 + j} [n;j] h_{n-j}
        # Cauchy:    (x;q)_n = sum_j (-1)^j q^{j(j-1)/2} [n;j] x^j
        # 
        # If we set x = q and multiply both sides by h_n, we get:
        # (q;q)_n * h_n -- but that's not what we have.
        #
        # Actually: sum_j (-1)^j q^{j(j-1)/2} [n;j] (q*h_{n-j}/h_n) = ??
        # This doesn't factor nicely because h_{n-j}/h_n is not a simple power.
        
        # Let's check: is h_m multiplicative? i.e., h_{m+k} ~ h_m * h_k?
        print(f"\n  === Checking multiplicativity of h_m ===")
        for m1 in range(1, min(3, n_max)):
            for m2 in range(1, min(3, n_max - m1 + 1)):
                h_m1 = h_polys.get(m1, {})
                h_m2 = h_polys.get(m2, {})
                h_m1m2 = h_polys.get(m1 + m2, {})
                prod_h = poly_mul_dict(h_m1, h_m2, max_w)
                
                # Check ratio h_{m1+m2} / (h_{m1} * h_{m2})
                # Just compare evaluations and leading terms
                s_prod = sum(prod_h.values()) if prod_h else 0
                s_hm = sum(h_m1m2.values()) if h_m1m2 else 0
                print(f"    h_{m1}*h_{m2}(1) = {s_prod}, h_{m1+m2}(1) = {s_hm}, ratio = {s_hm/s_prod:.4f}" if s_prod else f"    h_{m1}*h_{m2} = 0")
                
                # Check if h_{m1+m2} dominates h_{m1}*h_{m2} coefficientwise
                diff = dict(h_m1m2)
                for k, v in prod_h.items():
                    diff[k] = diff.get(k, 0) - v
                diff = {k: v for k, v in diff.items() if v != 0}
                neg_diff = {k: v for k, v in diff.items() if v < 0}
                pos_diff = {k: v for k, v in diff.items() if v > 0}
                print(f"      h_{m1+m2} - h_{m1}*h_{m2}: {len(neg_diff)} neg, {len(pos_diff)} pos terms")

if __name__ == "__main__":
    main()
