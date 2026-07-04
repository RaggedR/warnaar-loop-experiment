"""
Seed 3, Layer 2: sl_3 crystal decomposition of Q_{n,c}.

Key idea from Seeds 5+7+8: Q_{n,c}(q) should decompose as a sum of
Demazure characters for sl_3 (or an affine algebra with sl_3 at level 3).

For sl_3, a Demazure character at specialization x = (q, q^2, q^3) would be:
  K_w(lambda)(q, q^2, q^3) for w in S_3 and lambda a dominant weight.

Let's compute sl_3 Demazure characters and try to decompose Q_{n,c}.
"""

from collections import defaultdict
from math import gcd
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, compute_Q, poly_to_list


def sl3_schur(a, b, q_max):
    """
    Schur polynomial s_{(a,b)}(x_1, x_2, x_3) specialized at x_i = q^i.
    
    For sl_3, partition (a, b) means highest weight (a-b)*omega_1 + b*omega_2
    if a >= b >= 0. But the Schur polynomial is indexed by partitions with
    at most 3 parts: s_{(l1, l2, l3)}(x1, x2, x3).
    
    Actually for 3 variables, we need partitions with at most 3 parts.
    s_{(a,b,0)}(x1,x2,x3) at x_i = q^i.
    
    Using the Weyl character formula or direct computation:
    s_{(a,b)}(q, q^2, q^3) = sum over SSYT of shape (a,b) with entries in {1,2,3}
                              of q^{sum of entries}
    """
    if a < 0 or b < 0 or a < b:
        return {}
    
    # Generate all semistandard Young tableaux of shape (a, b) with entries in {1,2,3}
    # Row i has length (a if i=0, b if i=1)
    # Entries weakly increasing along rows, strictly increasing down columns
    
    result = defaultdict(int)
    
    # For shape (a, b), we have a box at position (row, col) for
    # row 0: cols 0..a-1, row 1: cols 0..b-1
    # SSYT: row weakly increasing, column strictly increasing
    
    # Enumerate row 1 first (shorter), then row 0
    # Row 1 entries: weakly increasing, each in {1,2,3}, length b
    def gen_row(length, min_val):
        if length == 0:
            yield []
            return
        for v in range(min_val, 4):
            for rest in gen_row(length - 1, v):
                yield [v] + rest
    
    for row1 in gen_row(b, 1):
        for row0 in gen_row(a, 1):
            # Check column strict: row0[j] < row1[j] for j = 0..b-1
            valid = True
            for j in range(b):
                if row0[j] >= row1[j]:
                    valid = False
                    break
            if not valid:
                continue
            
            weight = sum(row0) + sum(row1)
            if weight <= q_max:
                result[weight] += 1
    
    return dict(result)


def sl3_demazure(w_index, a, b, q_max):
    """
    Demazure character for sl_3 at dominant weight (a, b) (meaning highest
    weight a*omega_1 + b*omega_2) for Weyl group element w.
    
    w_index: 0=id, 1=s1, 2=s2, 3=s1s2, 4=s2s1, 5=s1s2s1=w0
    
    For w = w0 (longest element), Demazure = full Schur polynomial.
    For smaller w, it's a subset.
    
    Specialized at x = (q, q^2, q^3).
    
    For simplicity, let me just compute the full Schur polynomial (w = w0).
    The Demazure characters for other w are subsets.
    """
    # For now, just return the Schur polynomial
    return sl3_schur(a, b, q_max)


def try_schur_decomp(Q_coeffs, q_max):
    """
    Try to decompose Q (given as coefficient list) as a non-negative integer
    combination of sl_3 Schur polynomials s_{(a,b)}(q, q^2, q^3).
    """
    Q = {k: v for k, v in enumerate(Q_coeffs) if v > 0}
    if not Q:
        return True, [], {}
    
    # Precompute all Schur polynomials up to degree of Q
    max_deg = max(Q.keys())
    schurs = {}
    for a in range(max_deg + 1):
        for b in range(a + 1):
            s = sl3_schur(a, b, max_deg)
            if s:
                schurs[(a, b)] = s
    
    decomp = []
    for _ in range(500):
        if not Q:
            break
        max_deg_q = max(k for k, v in Q.items() if v > 0)
        
        # Find Schur with this max degree
        best = None
        for (a, b), s in schurs.items():
            if not s:
                continue
            max_s = max(s.keys())
            if max_s != max_deg_q:
                continue
            # Check subtractability
            ok = True
            for d, c in s.items():
                if Q.get(d, 0) < c:
                    ok = False
                    break
            if ok:
                best = ((a, b), s)
                break
        
        if best is None:
            break
        
        (a, b), s = best
        decomp.append((a, b))
        for d, c in s.items():
            Q[d] = Q.get(d, 0) - c
        Q = {k: v for k, v in Q.items() if v > 0}
    
    return not Q, decomp, Q


def main():
    q_max = 80
    
    print("=" * 70)
    print("sl_3 Schur polynomials at (q, q^2, q^3)")
    print("=" * 70)
    
    for a in range(6):
        for b in range(a + 1):
            s = sl3_schur(a, b, 30)
            s_list = poly_to_list(s) if s else [0]
            while s_list and s_list[-1] == 0:
                s_list.pop()
            dim = sum(s_list)
            print(f"  s_({a},{b}): dim={dim}, deg={len(s_list)-1 if s_list != [0] else 0}, "
                  f"poly = {s_list[:15]}")
    
    print("\n" + "=" * 70)
    print("sl_3 Schur decomposition of Q_{n,c}")
    print("=" * 70)
    
    for c in [(1,1,0), (2,1,1), (2,2,1)]:
        d = sum(c)
        if d % 3 == 0:
            continue
        base = (d+1)*(d+2)//6 - 1
        print(f"\nProfile c = {c}, d = {d}, base = {base}")
        
        for n in range(1, 5):
            Q = compute_Q(c, n, q_max)
            coeffs = poly_to_list(Q)
            while coeffs and coeffs[-1] == 0:
                coeffs.pop()
            
            success, decomp, rem = try_schur_decomp(coeffs, q_max)
            
            if len(coeffs) <= 20:
                print(f"  n={n}: Q = {coeffs}")
            else:
                print(f"  n={n}: deg={len(coeffs)-1}, Q(1)={sum(coeffs)}")
            
            if success:
                from collections import Counter
                counts = Counter(decomp)
                print(f"    sl_3 Schur decomposition: YES, {len(decomp)} terms")
                for (a, b), cnt in sorted(counts.items()):
                    dim = sum(poly_to_list(sl3_schur(a, b, q_max)))
                    print(f"      {cnt} x s_({a},{b}) [dim={dim}]")
            else:
                print(f"    sl_3 Schur decomposition: FAILED")
                print(f"    Remainder has {len(rem)} nonzero terms: "
                      f"{dict(list(sorted(rem.items()))[:10])}")
    
    print("\n" + "=" * 70)
    print("h_m and sl_3 Schur decomposition")
    print("=" * 70)
    
    # h_m(1) = ((d+1)(d+2)/6)^m. For d=4: h_m(1) = 5^m.
    # Can h_m be decomposed into sl_3 Schur polynomials?
    
    for c in [(2,1,1), (2,2,1)]:
        d = sum(c)
        base_h = (d+1)*(d+2)//6
        print(f"\nProfile c = {c}, d = {d}, h_m(1) = {base_h}^m")
        
        for m in range(1, 4):
            Fm = compute_F_transfer(c, m, q_max)
            Fm_prev = compute_F_transfer(c, m-1, q_max)
            
            g_m = {}
            for k in set(list(Fm.keys()) + list(Fm_prev.keys())):
                val = Fm.get(k, 0) - Fm_prev.get(k, 0)
                if val != 0:
                    g_m[k] = val
            
            qq_m = {0: 1}
            for i in range(1, m + 1):
                new = {}
                for deg, coeff in qq_m.items():
                    new[deg] = new.get(deg, 0) + coeff
                    if deg + i <= q_max:
                        new[deg + i] = new.get(deg + i, 0) - coeff
                qq_m = {k: v for k, v in new.items() if v != 0}
            
            h_m = {}
            for d1, c1 in qq_m.items():
                for d2, c2 in g_m.items():
                    dt = d1 + d2
                    if dt <= q_max:
                        h_m[dt] = h_m.get(dt, 0) + c1 * c2
            h_m = {k: v for k, v in h_m.items() if v != 0}
            
            h_list = poly_to_list(h_m) if h_m else [0]
            while h_list and h_list[-1] == 0:
                h_list.pop()
            
            success, decomp, rem = try_schur_decomp(h_list, q_max)
            
            print(f"\n  m={m}: h_m(1)={sum(h_list)}, deg={len(h_list)-1}")
            if len(h_list) <= 20:
                print(f"    h_m = {h_list}")
            
            if success:
                from collections import Counter
                counts = Counter(decomp)
                print(f"    Schur decomp: YES, {len(decomp)} terms")
                for (a, b), cnt in sorted(counts.items()):
                    print(f"      {cnt} x s_({a},{b})")
            else:
                print(f"    Schur decomp: FAILED, {len(rem)} remainder terms")
                print(f"    Remainder: {dict(list(sorted(rem.items()))[:8])}")


if __name__ == "__main__":
    main()
