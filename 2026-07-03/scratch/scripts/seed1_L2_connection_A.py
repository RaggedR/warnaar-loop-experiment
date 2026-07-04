"""
Seed 1 Layer 2: Connection A — h_m conjecture vs total positivity of {F_{c,N}}.

F_{c,N}(q) = sum_{Lambda in C_{c,N}} q^{|Lambda|} — bounded cylindric partition GF.

g_m(q) = F_{c,m} - F_{c,m-1}  (counts CPPs with max entry exactly m)
h_m(q) = (q;q)_m * sum_{k=0}^m g_k(q) / ... wait no.

Actually:
  g_m = [z^m] F_c(z,q) where F_c(z,q) = sum_Lambda q^|Lambda| z^max(Lambda)
  
  So sum_{m=0}^N g_m = [z^0 + z^1 + ... + z^N] F_c(z,q) = F_{c,N}(q)
  i.e., F_{c,N} = sum_{m=0}^N g_m.

Now h_m = (q;q)_m * g_m.

Seed 2's total positivity: {F_{c,N}} is totally positive if all Hankel-type
determinants det(F_{c,N_{i+j}}) are nonneg coeff-wise.

The simplest case (q-log-concavity):
  F_{c,N}^2 - F_{c,N-1} * F_{c,N+1} >= 0.

Relation to h_m: Since F_{c,N} = sum_{m=0}^N g_m = sum_{m=0}^N h_m/(q;q)_m,
the F_{c,N} sequence is a cumulative sum of h_m/(q;q)_m.

Let's verify the log-concavity and check if h_m >= 0 implies it.

Also: Q_n = (q;q)_n * [z^n] ((zq;q)_inf * F_c(z,q))
     = (q;q)_n * sum_{j=0}^n (zq;q)_inf coefficient * g_{n-j}
     
The coefficient [z^j] (zq;q)_inf = (-1)^j q^{j(j+1)/2} / (q;q)_j.

So: [z^n] ((zq;q)_inf * F_c(z,q)) = sum_{j=0}^n (-1)^j q^{j(j+1)/2}/(q;q)_j * g_{n-j}

And Q_n = (q;q)_n * this = sum_j (-1)^j q^{j(j+1)/2} * (q;q)_n / (q;q)_j * g_{n-j}
        = sum_j (-1)^j q^{j(j+1)/2} * (q^{j+1};q)_{n-j} * g_{n-j}

Since g_{n-j} = h_{n-j} / (q;q)_{n-j}:
Q_n = sum_j (-1)^j q^{j(j+1)/2} [n;j]_q h_{n-j}

This confirms the formula. Now let's explore:

1. Does h_m >= 0 imply F_{c,N} log-concave?
   F_N = sum_{m=0}^N h_m/(q;q)_m
   F_N^2 - F_{N-1} F_{N+1} = ... involves cross terms.

2. Does total positivity of {F_{c,N}} imply Q_n >= 0?
   Q_n/(q;q)_n = sum_j (-1)^j q^{j(j+1)/2}/(q;q)_j g_{n-j}
   = "q-complete monotonicity" of g at index n.
   
   This is circular (Broken Assumption 7).

Let me just compute and verify relationships.
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

def poly_add(a, b):
    result = dict(a)
    for k, v in b.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_sub(a, b):
    return poly_add(a, {k: -v for k, v in b.items()})

def poly_mul(a, b, max_deg=None):
    result = {}
    for i, ai in a.items():
        if ai == 0: continue
        for j, bj in b.items():
            if bj == 0: continue
            k = i + j
            if max_deg is not None and k > max_deg: continue
            result[k] = result.get(k, 0) + ai * bj
    return {k: v for k, v in result.items() if v != 0}

def inv_qpoch(m, max_deg):
    """Compute 1/(q;q)_m as polynomial up to max_deg."""
    result = {0: 1}
    for i in range(1, m + 1):
        new = {}
        for p, c in result.items():
            j = 0
            while p + i * j <= max_deg:
                new[p + i * j] = new.get(p + i * j, 0) + c
                j += 1
        result = {k: v for k, v in new.items() if v != 0}
    return result

def main():
    profile = (2, 1, 1)
    d = sum(profile)
    max_w = 30
    max_n = 5

    print(f"Profile c = {profile}, d = {d}")
    print(f"Computing F_{{c,N}} for N = 0..{max_n}")

    gk = compute_gk(profile, max_n + 1, max_w + 10)

    # Compute g_m for each m
    g = {}
    for m in range(max_n + 1):
        g[m] = extract_gm(gk, m)
        s = sum(g[m].values()) if g[m] else 0
        print(f"  g_{m}(1) = {s}")

    # Compute F_{c,N} = sum_{m=0}^N g_m as power series (truncated)
    F = {}
    for N in range(max_n + 1):
        cum = {}
        for m in range(N + 1):
            for k, v in g[m].items():
                if k <= max_w:
                    cum[k] = cum.get(k, 0) + v
        # Add g_0 = empty partition contribution
        if 0 not in cum:
            cum[0] = cum.get(0, 0)
        F[N] = cum

    # Add F[-1] = 0 and the empty partition counts
    # Actually F_{c,0} should include max entry = 0, which is the empty partition
    # g_0 = 1 (just the empty CPP), so F_0 = 1
    
    print(f"\nF_{{c,N}}(1) values:")
    for N in range(max_n + 1):
        s = sum(F[N].values()) if F[N] else 0
        print(f"  F_{N}(1) = {s}")

    # Check q-log-concavity: F_N^2 - F_{N-1} * F_{N+1} >= 0
    print(f"\nq-log-concavity check: F_N^2 - F_{{N-1}} * F_{{N+1}}")
    for N in range(1, max_n):
        FN = F[N]
        FN1 = F.get(N-1, {0: 1} if N == 1 else {})
        FN2 = F.get(N+1, {})
        
        sq = poly_mul(FN, FN, max_w)
        prod = poly_mul(FN1, FN2, max_w)
        diff = poly_sub(sq, prod)
        
        neg = {k: v for k, v in diff.items() if v < 0}
        s = sum(diff.values())
        print(f"  N={N}: diff(1) = {s}, nonneg = {len(neg) == 0}")
        if neg:
            print(f"    *** NEGATIVE: {dict(sorted(neg.items())[:5])}")

    # Compute h_m and check relationship
    print(f"\nh_m via g_m and (q;q)_m:")
    h = {}
    for m in range(max_n + 1):
        if m == 0:
            h[0] = {0: 1}
        else:
            from functools import reduce
            qm = {0: 1}
            for i in range(1, m + 1):
                new = {}
                for p, c in qm.items():
                    new[p] = new.get(p, 0) + c
                    if p + i <= max_w:
                        new[p + i] = new.get(p + i, 0) - c
                qm = {k: v for k, v in new.items() if v != 0}
            h[m] = poly_mul(qm, g[m], max_w)
        
        s = sum(h[m].values()) if h[m] else 0
        neg = any(v < 0 for v in h[m].values())
        print(f"  h_{m}(1) = {s}, nonneg = {not neg}")

    # Check: does F_{c,N} = sum_{m=0}^N h_m / (q;q)_m?
    print(f"\nVerification: F_N = sum h_m / (q;q)_m")
    for N in range(max_n + 1):
        F_from_h = {}
        for m in range(N + 1):
            inv_m = inv_qpoch(m, max_w)
            term = poly_mul(h[m], inv_m, max_w)
            F_from_h = poly_add(F_from_h, term)
        
        diff = poly_sub(F[N], F_from_h)
        # Only check up to a reasonable degree
        diff_trunc = {k: v for k, v in diff.items() if k <= max_w - 5}
        print(f"  N={N}: diff = {sum(abs(v) for v in diff_trunc.values())} (should be ~0)")

    # KEY INSIGHT: Let's check if the Toeplitz-like determinants of h_m are nonneg.
    # The h_m sequence is the key; its own total-positivity-like properties
    # might be what controls both F_{c,N} log-concavity AND Q_n positivity.
    
    print(f"\n=== h_m Hankel-like structure ===")
    print(f"Checking h_i * h_j vs h_{'{i+j}'} structure:")
    for i in range(1, min(3, max_n)):
        for j in range(i, min(3, max_n)):
            if i + j > max_n: continue
            prod = poly_mul(h[i], h[j], max_w)
            hij = h.get(i+j, {})
            
            # Ratio at q=1
            s_prod = sum(prod.values())
            s_hij = sum(hij.values())
            if s_prod:
                print(f"  h_{i}*h_{j}(1) = {s_prod}, h_{i+j}(1) = {s_hij}, ratio = {s_hij/s_prod:.4f}")
            
            # Coefficientwise comparison
            diff = poly_sub(hij, prod)
            neg_diff = sum(1 for v in diff.values() if v < 0)
            pos_diff = sum(1 for v in diff.values() if v > 0)
            print(f"    h_{i+j} - h_{i}*h_{j}: {neg_diff} neg, {pos_diff} pos")

    # Check h_m "super-multiplicativity": is h_{m+1}/h_m >= h_m/h_{m-1} in some sense?
    print(f"\n=== h_m growth structure ===")
    print(f"Checking coefficient-wise: h_m * h_{'{m+2}'} vs h_{'{m+1}'}^2 (log-concavity of h)")
    for m in range(max_n - 1):
        if m + 2 > max_n: break
        hm = h.get(m, {})
        hm1 = h.get(m+1, {})
        hm2 = h.get(m+2, {})
        
        prod1 = poly_mul(hm, hm2, max_w)
        prod2 = poly_mul(hm1, hm1, max_w)
        diff = poly_sub(prod2, prod1)  # h_{m+1}^2 - h_m * h_{m+2}
        
        neg = {k: v for k, v in diff.items() if v < 0}
        s = sum(diff.values())
        print(f"  m={m}: h_{m+1}^2 - h_{m}*h_{m+2} at q=1: {s}, nonneg = {len(neg) == 0}")
        if neg:
            print(f"    NEGATIVE at: {dict(sorted(neg.items())[:5])}")

if __name__ == "__main__":
    main()
