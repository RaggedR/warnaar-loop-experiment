"""
Seed 3, Layer 2: Crystal graph / Demazure character investigation.
Uses the v4 transfer matrix for window=2 support.
"""

from collections import defaultdict
from math import gcd
import sys
sys.path.insert(0, '/Users/robin/git/experiments/waarnar/loop-experiment/scratch/scripts')
from seed3_transfer_v4 import compute_F_transfer, compute_Q, poly_to_list


def sl3_weight_orbits(d):
    """Count C_3 and S_3 orbits of triples (a,b,c) with a+b+c=d, a,b,c>=0."""
    triples = [(a, b, d-a-b) for a in range(d+1) for b in range(d+1-a)]

    c3_seen = set()
    c3_orbits = []
    for t in triples:
        a, b, c = t
        canon = min((a,b,c), (b,c,a), (c,a,b))
        if canon not in c3_seen:
            c3_seen.add(canon)
            c3_orbits.append(canon)

    s3_seen = set()
    for t in triples:
        canon = tuple(sorted(t))
        s3_seen.add(canon)

    nontrivial_c3 = [o for o in c3_orbits if all(x > 0 for x in o)]

    print(f"  d={d}: {len(triples)} triples, {len(c3_orbits)} C3-orbits, "
          f"{len(s3_seen)} S3-orbits, "
          f"all-positive C3: {len(nontrivial_c3)}, "
          f"(d+1)(d+2)/6 = {(d+1)*(d+2)//6}, "
          f"base = {(d+1)*(d+2)//6 - 1}")

    return c3_orbits, nontrivial_c3


def demazure_char_sl2(a, b, q_max):
    """GL_2 key polynomial K_{(a,b)} at x_1=q, x_2=q^2 for a >= b >= 0."""
    if a < b or b < 0:
        return {}
    result = {}
    for j in range(a - b + 1):
        deg = a + 2*b + j
        if deg <= q_max:
            result[deg] = result.get(deg, 0) + 1
    return result


def try_key_decomp(Q_coeffs, q_max):
    """Greedy decomposition into GL_2 key polynomials."""
    Q = {k: v for k, v in enumerate(Q_coeffs) if v > 0}
    if not Q:
        return True, [], {}

    decomp = []
    for _ in range(500):
        if not Q:
            break
        max_deg = max(k for k, v in Q.items() if v > 0)

        best = None
        for a in range(max_deg + 1):
            for b in range(a + 1):
                K = demazure_char_sl2(a, b, q_max)
                if not K:
                    continue
                max_K = max(K.keys())
                if max_K != max_deg:
                    continue
                # Check subtractability
                ok = True
                for d_k, c_k in K.items():
                    if Q.get(d_k, 0) < c_k:
                        ok = False
                        break
                if ok:
                    best = ((a, b), K)
                    break
            if best:
                break

        if best is None:
            break
        (a, b), K = best
        decomp.append((a, b))
        for d_k, c_k in K.items():
            Q[d_k] = Q.get(d_k, 0) - c_k
        Q = {k: v for k, v in Q.items() if v > 0}

    return not Q, decomp, Q


def main():
    print("=" * 70)
    print("1. sl_3 weight orbit counting — checking Seed 8's claim")
    print("=" * 70)

    for d in [1, 2, 4, 5, 7, 8, 10, 11]:
        if d % 3 == 0:
            continue
        c3_orbits, nt = sl3_weight_orbits(d)

    print("\n" + "=" * 70)
    print("2. Q_{n,c}(q) and GL_2 key polynomial decomposition")
    print("=" * 70)

    q_max = 100
    profiles = [(1,1,0), (2,1,1), (1,2,1), (2,2,1)]

    for c in profiles:
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
            all_pos = all(x >= 0 for x in coeffs)
            eval1 = sum(coeffs)

            if len(coeffs) <= 20:
                print(f"  n={n}: Q = {coeffs}")
            else:
                print(f"  n={n}: deg={len(coeffs)-1}, Q(1)={eval1}, pos={all_pos}")

            # Try GL_2 key decomp
            success, decomp, rem = try_key_decomp(coeffs, q_max)
            if success:
                print(f"    Key decomp: YES, {len(decomp)} terms")
                # Summarize
                from collections import Counter
                counts = Counter(decomp)
                for (a,b), cnt in sorted(counts.items()):
                    print(f"      {cnt} x K_({a},{b})")
            else:
                print(f"    Key decomp: FAILED, remainder: {rem}")

    print("\n" + "=" * 70)
    print("3. D_3 symmetry: Q depends on c only up to dihedral action")
    print("=" * 70)

    q_max = 60
    for d in [4, 5]:
        print(f"\nd = {d}:")
        profiles_d = [(c0, c1, d-c0-c1) for c0 in range(d+1)
                      for c1 in range(d+1-c0)]

        # Group by D_3 orbit
        seen = set()
        orbit_list = []
        for c in profiles_d:
            c0, c1, c2 = c
            perms = {(c0,c1,c2),(c1,c2,c0),(c2,c0,c1),
                     (c2,c1,c0),(c0,c2,c1),(c1,c0,c2)}
            canon = min(perms)
            if canon not in seen:
                seen.add(canon)
                orbit_list.append((canon, sorted(perms & set(profiles_d))))

        for canon, orbit in orbit_list:
            print(f"  D_3 orbit of {canon} (size {len(orbit)})")

            q_vals = {}
            for cp in orbit:
                if max(cp) <= 2:  # can compute with our transfer matrix
                    try:
                        Q = compute_Q(cp, 2, q_max)
                        coeffs = poly_to_list(Q)
                        while coeffs and coeffs[-1] == 0:
                            coeffs.pop()
                        q_vals[cp] = tuple(coeffs)
                    except:
                        pass

            if q_vals:
                vals = set(q_vals.values())
                if len(vals) == 1:
                    v = list(vals)[0]
                    print(f"    Q_2 IDENTICAL for all computed: {v[:15]}...")
                else:
                    for cp, v in sorted(q_vals.items()):
                        print(f"    {cp}: Q_2 = {v[:15]}...")

    print("\n" + "=" * 70)
    print("4. h_m computation: h_m = (q;q)_m * [z^m] F_c(z,q)")
    print("=" * 70)

    q_max = 60
    for c in [(2,1,1), (2,2,1)]:
        d = sum(c)
        base_val = (d+1)*(d+2)//6
        print(f"\nProfile c = {c}, d = {d}, (d+1)(d+2)/6 = {base_val}")

        for m in range(1, 5):
            Fm = compute_F_transfer(c, m, q_max)
            Fm_prev = compute_F_transfer(c, m-1, q_max)

            # g_m = F_{c,m} - F_{c,m-1} (the increment)
            # Actually g_m = [z^m] F_c(z,q) as a power series...
            # But F_c(z,q) = sum_N F_{c,N}(q) z^N? No.
            # F_c(z,q) = sum_{Lambda} q^{|Lambda|} z^{max(Lambda)}
            #          = sum_N z^N [F_{c,N} - F_{c,N-1}]
            # So g_m = F_{c,m} - F_{c,m-1}.

            g_m = {}
            for k in set(list(Fm.keys()) + list(Fm_prev.keys())):
                val = Fm.get(k, 0) - Fm_prev.get(k, 0)
                if val != 0:
                    g_m[k] = val

            # h_m = (q;q)_m * g_m
            # (q;q)_m = prod_{i=1}^m (1-q^i)
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
            all_pos = all(x >= 0 for x in h_list)
            eval1 = sum(h_list)

            print(f"  m={m}: h_m(1)={eval1} (expected {base_val**m}), nonneg={all_pos}")
            if len(h_list) <= 20:
                print(f"    h_m = {h_list}")
            else:
                print(f"    h_m deg={len(h_list)-1}, first 15: {h_list[:15]}")


if __name__ == "__main__":
    main()
